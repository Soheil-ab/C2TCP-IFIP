# C2TCP v1.0

Installation Guide
==================

Here we will provide you with a guides to do the tests on single machine. 
All schemes and tools are tested on Ubuntu 14.04 except BBR which requires Ubuntu 16.04 and above (here it is tested on Ubuntu 17.04)
If you are going to test BBR and won't like to chage the kernel manually each time, we recommend using two macines (or VMs) one with Ubuntu 14.04 for the tests with all schemes except BBR and the other with Ubuntu 17.04 for BBR.
If not, simply skip the Build BBR, and continue with the instructions.

### Getting the Source Code:

Note: C2TCP is implemented on Linux kernel 3.13.0 (Ubuntuu 14.04). 

Get the source code:

	cd ~
	git clone https://github.com/c2tcp/c2tcp.git
	cd c2tcp
	tar -xzf c2tcp.tar.gz

### Installing Required Tools

General Note: Installing any of the following tools/schemes, depending on your machine, might require other libraries (in addition to what have been mentioned here). So, if you get any errors of someting not being found when you try to `make`, install them using `apt-get`.
(Since C2TCP is applied to Kernel 3.13, we recommend using Ubuntu 14.04 as the base).


1. Install Mahimahi (http://mahimahi.mit.edu/#getting)

	```sh  
	cd ~/c2tcp/c2tcp
	sudo apt-get install build-essential git debhelper autotools-dev dh-autoreconf iptables protobuf-compiler libprotobuf-dev pkg-config libssl-dev dnsmasq-base ssl-cert libxcb-present-dev libcairo2-dev libpango1.0-dev iproute2 apache2-dev apache2-bin iptables dnsmasq-base gnuplot iproute2 apache2-api-20120211 libwww-perl
	git clone https://github.com/ravinet/mahimahi 
	cd mahimahi
	./autogen.sh && ./configure && make
	sudo make install
	sudo sysctl -w net.ipv4.ip_forward=1
	```

2. Install iperf

	```sh
	sudo apt-get install iperf
	```

### Installing Other Schemes 

Optional: You can skip each of these parts if you wanna just run evaluation for C2TCP, Cubic, Vegas, and NewReno.

Notice: BBR already has been pushed to Kernel 4.10 (Ubuntu 16.04). So we recommend you to install it on a separate VM (or machine). 
Our tests with BBR have been done on Ubuntu 17.04. If you want to install it on the same machine where you have installed other schemes, remember that you should handle changing the kernel back to 3.13.0 manually for the test of other schemes.
(Other schemes have been recommanded to be isntalled (& tested) on Ubuntu 14.04 (Kernel 3.13))
	
1. Build Sprout (http://alfalfa.mit.edu/)

	```sh  
	sudo apt-get install libboost-math-dev libboost-math1.54.0 libprotobuf8 libprotobuf-dev 
	cd ~/c2tcp/c2tcp/alfalfa
	./autogen.sh
	./configure --enable-examples && make	
	```

2. Build Verus (https://github.com/yzaki/verus)

	Required packages: libtbb libasio libalglib libboost-system

	```sh
	sudo apt-get install build-essential autoconf libtbb-dev libasio-dev libalglib-dev libboost-system-dev
	cd ~/c2tcp/c2tcp/verus
	autoreconf -i
	./configure && make
	```
3. Build BBR (http://queue.acm.org/detail.cfm?id=3022184)

	```sh
	wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10-rc1/linux-image-4.10.0-041000rc1-generic_4.10.0-041000rc1.201612252031_amd64.deb
	dpkg -i linux-image-4.10.0*.deb
	update-grub
	reboot
	
	#After reboot
	uname -a
	```

	Enablabe BBR and check it:
		
	```sh
	echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	sysctl -p
		
	#Check bbr
	
	sysctl net.ipv4.tcp_available_congestion_control
	lsmod | grep bbr
	```

### Adding C2TCP to Kernel

1. Get the kernel:

	```sh
	cd ~/c2tcp/
	wget http://www.kernel.org/pub/linux/kernel/v3.0/linux-3.13.tar.gz
	tar -xzf linux-3.13.tar.gz
	```
	
2. Apply C2TCP patch to the kernel

	```sh
	cd linux-3.13
	patch -p1 < ../c2tcp/c2tcp.kernel.3.13.patch
	```
3. Prepare it for being compiled:

	Open the kernel menu settings:
	
	```sh
	sudo cp /boot/config-`uname -r` .config
	sudo apt-get install libncurses5-dev
	sudo make menuconfig
	```
	
	The command above will open a window inside of the shell. We wanna decrease overall complilation time of the new Kernel, so at least do the followings:
	
	“Processor type and features” , then “Processor family ”. Choose the processor (Most likely you need to choose “Core 2/newer Xeon”).
	Return to the first menu. Go to "Device Drivers" and disable "staging drivers"
	
	(You can uncheck different drivers to expedite the compilation)
	
	Exit from Kernel Configuration window saving the changes on .config file. 
	
4. Compile the kenel:
	
	Finally, it’s time to compile the kernel. This will take time, please be patient ...
	(On one of our servers with 24 cores, this took 9 minutes)
	
	The option -j sets the number of cores that will be used for compilation, increase it from 4 to the number of cores that you have.
	
	```sh
	sudo make -j4
	```
	
5. Install kernel:
	
	After compiled successfully, we need to install it:
	
	```sh
	sudo make modules_install
	sudo make install
	```
	
6. Set the new kerenl as the default kernel: 

	The new kernel is installed; Now we need to boot from it. 
	
	```sh
	sudo apt-get install grub-pc
	sudo upgrade-from-grub-legacy
	sudo update-grub
	sudo update-initramfs -k 3.13.0 -u
	sudo update-grub
	```
	You might be aked to configure grub and install it on your partions. So follow the instructions on screen to do that.
	
	Install grub-customizer (It's a cool tool which makes life easier for changing the default kernel!):
	
	```sh
	sudo add-apt-repository ppa:danielrichter2007/grub-customizer
	sudo apt-get update
	sudo apt-get install grub-customizer
	```
	
	Then open grub-customizer and bring 3.13.0 at the first line (and its recovery at the second line), Save and Restart.

7. Verify the new kernel.

	```sh
	uname -r
	```
	You should see 3.13.0.
	
	Check whether C2TCP is there:
	
	```sh
	sysctl net.ipv4.tcp_c2tcp_enable
	```
	
	You should see:
	
	```sh
	net.ipv4.tcp_c2tcp_enable = 0
	```
	We will later enable C2TCP during our evaluation.
		
### Running The Evaluation

For the simplicity, first we disable password-timeout of sudo command:

	sudo visudo

Now add following line and save it:

	Defaults    timestamp_timeout=-1	
	
We have put required commands to run evaluation and generate the results for differnet schemes in one script.
Here, we run C2TCP (with Target=100ms, Interval=100ms), Cubic, TCP Vegas, and NewReno using the T-Mobile Downlink trace file with following command:
(For more information on how to use the script, check comments in "run.sh", "evaluate.sh", and "analysis.sh" scripts)

	cd ~/c2tcp/c2tcp/
	./evaluate.sh 1 1 1 1 0 0 0 0 5000

After that, you can check summary of results:	

	 cat sum/summary-20-TMobile-LTE-driving.down-TMobile-LTE-driving.up-20-480.txt
	
(Note: Here, we run evalaution on single machine. To run them on seprate machines (like Fig.5 in the paper) you need to run different components of the script (server, client, emulator) on your designated machines.)
