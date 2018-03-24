/*
    Mosh: the mobile shell
    Copyright 2012 Keith Winstein

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    In addition, as a special exception, the copyright holders give
    permission to link the code of portions of this program with the
    OpenSSL library under certain conditions as described in each
    individual source file, and distribute linked combinations including
    the two.

    You must obey the GNU General Public License in all respects for all
    of the code used other than OpenSSL. If you modify file(s) with this
    exception, you may extend this exception to your version of the
    file(s), but you are not obligated to do so. If you do not wish to do
    so, delete this exception statement from your version. If you delete
    this exception statement from all source files in the program, then
    also delete it here.
*/

#include <algorithm>
#include <list>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "transportsender.h"
#include "transportfragment.h"

using namespace Network;
using namespace std;

template <class MyState>
TransportSender<MyState>::TransportSender( SproutConnection *s_connection, MyState &initial_state )
  : connection( s_connection ), 
    current_state( initial_state ),
    sent_states( 1, TimestampedState<MyState>( timestamp(), 0, initial_state ) ),
    assumed_receiver_state( sent_states.begin() ),
    fragmenter(),
    next_ack_time( timestamp() ),
    next_send_time( timestamp() ),
    verbose( false ),
    shutdown_in_progress( false ),
    shutdown_tries( 0 ),
    ack_num( 0 ),
    pending_data_ack( false ),
    SEND_MINDELAY( 0 ),
    last_heard( 0 ),
    mindelay_clock( -1 )
{
}

/* Try to send roughly two frames per RTT, bounded by limits on frame rate */
template <class MyState>
unsigned int TransportSender<MyState>::send_interval( void ) const
{
  int SEND_INTERVAL = lrint( ceil( connection->get_SRTT() / 4.0 ) );
  if ( SEND_INTERVAL < SEND_INTERVAL_MIN ) {
    SEND_INTERVAL = SEND_INTERVAL_MIN;
  } else if ( SEND_INTERVAL > SEND_INTERVAL_MAX ) {
    SEND_INTERVAL = SEND_INTERVAL_MAX;
  }

  return SEND_INTERVAL;
}

/* Housekeeping routine to calculate next send and ack times */
template <class MyState>
void TransportSender<MyState>::calculate_timers( void )
{
  uint64_t now = timestamp();

  /* Update assumed receiver state */
  update_assumed_receiver_state();

  /* Cut out common prefix of all states */
  rationalize_states();

  if ( pending_data_ack && (next_ack_time > now + ACK_DELAY) ) {
    next_ack_time = now + ACK_DELAY;
  }

  if ( !(current_state == sent_states.back().state) ) {
    if ( mindelay_clock == uint64_t( -1 ) ) {
      mindelay_clock = now;
    }

    next_send_time = max( mindelay_clock + SEND_MINDELAY,
			  sent_states.back().timestamp + send_interval() );
  } else if ( !(current_state == assumed_receiver_state->state)
	      && (last_heard + ACTIVE_RETRY_TIMEOUT > now) ) {
    next_send_time = sent_states.back().timestamp + send_interval();
    if ( mindelay_clock != uint64_t( -1 ) ) {
      next_send_time = max( next_send_time, mindelay_clock + SEND_MINDELAY );
    }
  } else if ( !(current_state == sent_states.front().state )
	      && (last_heard + ACTIVE_RETRY_TIMEOUT > now) ) {
    next_send_time = sent_states.back().timestamp + connection->timeout() + ACK_DELAY;
  } else {
    next_send_time = uint64_t(-1);
  }

  /* speed up shutdown sequence */
  if ( shutdown_in_progress || (ack_num == uint64_t(-1)) ) {
    next_ack_time = sent_states.back().timestamp + send_interval();
  }
}

/* How many ms to wait until next event */
template <class MyState>
int TransportSender<MyState>::wait_time( void )
{
  calculate_timers();

  uint64_t next_wakeup = next_ack_time;
  if ( next_send_time < next_wakeup ) {
    next_wakeup = next_send_time;
  }

  uint64_t now = timestamp();

  if ( !connection->get_has_remote_addr() ) {
    return INT_MAX;
  }

  int ret = next_wakeup - now;
  if ( connection->get_tick_length() < ret ) {
    ret = connection->get_tick_length();
  }

  if ( ret < 0 ) {
    ret = 0;
  }

  return ret;
}

/* Send data or an empty ack if necessary */
template <class MyState>
void TransportSender<MyState>::tick( void )
{
  connection->tick(); /* send out queue if there is one */

  calculate_timers(); /* updates assumed receiver state and rationalizes */

  if ( !connection->get_has_remote_addr() ) {
    return;
  }

  uint64_t now = timestamp();

  if ( (now < next_ack_time)
       && (now < next_send_time) ) {
    return;
  }

  /* Determine if a new diff or empty ack needs to be sent */

  int len = connection->window_size();
  string diff;
  if ( len > 1000 ) {
    diff = current_state.diff_from( assumed_receiver_state->state, connection->window_size() );
  }

  //  attempt_prospective_resend_optimization( diff );

  /*
  if ( verbose ) {
    // verify diff has round-trip identity
    MyState newstate( assumed_receiver_state->state );
    newstate.apply_string( diff );
    if ( current_state.compare( newstate ) ) {
      fprintf( stderr, "Warning, round-trip Instruction verification failed!\n" );
    }
  }
*/

  if ( diff.empty() && (now >= next_ack_time) ) {
    send_empty_ack();
    mindelay_clock = uint64_t( -1 );
  } else if ( !diff.empty() && ( (now >= next_send_time)
			  || (now >= next_ack_time) ) ) {
    /* Send diffs or ack */
    send_to_receiver( diff );
    mindelay_clock = uint64_t( -1 );
  }
}

template <class MyState>
void TransportSender<MyState>::send_empty_ack( void )
{
  uint64_t now = timestamp();

  assert( now >= next_ack_time );

  uint64_t new_num = sent_states.back().num + 1;

  /* special case for shutdown sequence */
  if ( shutdown_in_progress ) {
    new_num = uint64_t( -1 );
  }

  //  sent_states.push_back( TimestampedState<MyState>( sent_states.back().timestamp, new_num, current_state ) );
  add_sent_state( now, new_num, current_state );
  send_in_fragments( "", new_num );

  next_ack_time = now + ACK_INTERVAL;
  next_send_time = uint64_t(-1);
}

template <class MyState>
void TransportSender<MyState>::add_sent_state( uint64_t the_timestamp, uint64_t num, MyState &state )
{
  sent_states.push_back( TimestampedState<MyState>( the_timestamp, num, state ) );
  if ( sent_states.size() > 32 ) { /* limit on state queue */
    typename sent_states_type::iterator last = sent_states.end();
    for ( int i = 0; i < 16; i++ ) { last--; }
    sent_states.erase( last ); /* erase state from middle of queue */
  }
}

template <class MyState>
void TransportSender<MyState>::send_to_receiver( string diff )
{
  uint64_t new_num = sent_states.back().num + 1; /* always increment state number for lossy SSP */

  /* special case for shutdown sequence */
  if ( shutdown_in_progress ) {
    new_num = uint64_t( -1 );
  }

  /* find lossy target state */
  MyState newstate( assumed_receiver_state->state );
  newstate.apply_string( diff );

  add_sent_state( timestamp(), new_num, newstate );

  send_in_fragments( diff, new_num ); // Can throw NetworkException

  /* successfully sent, probably */
  /* ("probably" because the FIRST size-exceeded datagram doesn't get an error) */
  assumed_receiver_state = sent_states.end();
  assumed_receiver_state--;
  next_ack_time = timestamp() + ACK_INTERVAL;
  next_send_time = uint64_t(-1);
}

template <class MyState>
void TransportSender<MyState>::update_assumed_receiver_state( void )
{
  uint64_t now = timestamp();

  /* start from what is known and give benefit of the doubt to unacknowledged states
     transmitted recently enough ago */
  assumed_receiver_state = sent_states.begin();

  typename list< TimestampedState<MyState> >::iterator i = sent_states.begin();
  i++;

  while ( i != sent_states.end() ) {
    assert( now >= i->timestamp );

    if ( uint64_t(now - i->timestamp) < connection->timeout() + ACK_DELAY ) {
      assumed_receiver_state = i;
    } else {
      return;
    }

    i++;
  }
}

template <class MyState>
void TransportSender<MyState>::rationalize_states( void )
{
  const MyState * known_receiver_state = &sent_states.front().state;

  current_state.subtract( known_receiver_state );

  for ( typename list< TimestampedState<MyState> >::reverse_iterator i = sent_states.rbegin();
	i != sent_states.rend();
	i++ ) {
    i->state.subtract( known_receiver_state );
  }
}

template <class MyState>
void TransportSender<MyState>::send_in_fragments( string diff, uint64_t new_num )
{
  Instruction inst;

  inst.set_old_num( assumed_receiver_state->num );
  inst.set_new_num( new_num );
  inst.set_ack_num( ack_num );
  inst.set_throwaway_num( sent_states.front().num );
  inst.set_diff( diff );

  if ( new_num == uint64_t(-1) ) {
    shutdown_tries++;
  }

  vector<Fragment> fragments = fragmenter.make_fragments( inst, connection->get_MTU() );

  for ( vector<Fragment>::iterator i = fragments.begin();
        i != fragments.end();
        i++ ) {

    int time_to_next = 0;
    if ( i + 1 == fragments.end() ) {
      time_to_next = send_interval();
    }
    connection->queue_to_send( i->tostring(), time_to_next );

    if ( verbose ) {
      fprintf( stderr, "[%u] Sent [%d=>%d] id %d, frag %d ack=%d, throwaway=%d, len=%d, frame rate=%.2f, timeout=%d, srtt=%.1f\n",
	       (unsigned int)(timestamp() % 100000), (int)inst.old_num(), (int)inst.new_num(), (int)i->id, (int)i->fragment_num,
	       (int)inst.ack_num(), (int)inst.throwaway_num(), (int)i->contents.size(),
	       1000.0 / (double)send_interval(),
	       (int)connection->timeout(), connection->get_SRTT() );
    }

  }

  pending_data_ack = false;
}

template <class MyState>
void TransportSender<MyState>::process_acknowledgment_through( uint64_t ack_num )
{
  /* Ignore ack if we have culled the state it's acknowledging */

  if ( sent_states.end() !=
       find_if( sent_states.begin(), sent_states.end(),
		bind2nd( mem_fun_ref( &TimestampedState<MyState>::num_eq ), ack_num ) ) ) {
    sent_states.remove_if( bind2nd( mem_fun_ref( &TimestampedState<MyState>::num_lt ), ack_num ) );
  }

  assert( !sent_states.empty() );
}

/* give up on getting acknowledgement for shutdown */
template <class MyState>
bool TransportSender<MyState>::shutdown_ack_timed_out( void ) const
{
  return shutdown_tries >= SHUTDOWN_RETRIES;
}

/* Executed upon entry to new receiver state */
template <class MyState>
void TransportSender<MyState>::set_ack_num( uint64_t s_ack_num )
{
  ack_num = s_ack_num;
}

/* Investigate diff against known receiver state instead */
/* Mutates proposed_diff */
template <class MyState>
void TransportSender<MyState>::attempt_prospective_resend_optimization( string &proposed_diff )
{
  if ( assumed_receiver_state == sent_states.begin() ) {
    return;
  }

  string resend_diff = current_state.diff_from( sent_states.front().state );

  /* We do a prophylactic resend if it would make the diff shorter,
     or if it would lengthen it by no more than 100 bytes and still be
     less than 1000 bytes. */

  if ( (resend_diff.size() <= proposed_diff.size())
       || ( (resend_diff.size() < 1000)
	    && (resend_diff.size() - proposed_diff.size() < 100) ) ) {
    assumed_receiver_state = sent_states.begin();
    proposed_diff = resend_diff;
  }
}
