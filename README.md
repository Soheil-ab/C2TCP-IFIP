# C2TCP v2.0

This is C2TCP: A Cellular Controlled delay TCP.

Installation Guide
==================

Here we will provide you with detailed instructions to test C2TCP on single machine.

### Getting the Source Code:

Note: C2TCP is implemented on Linux kernel 4.13.1. 

Get the source code:

	cd ~
	git clone https://github.com/c2tcp/c2tcp.git
	cd c2tcp
	tar -xzf c2tcp.tar.gz

### Installing Required Tools

General Note: Installing any of the following tools/schemes, depending on your machine, might require other libraries (in addition to what have been mentioned here). So, if you get any errors mentioning that something not being found when you try to `make`, install them using `apt-get`.

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

BBR, C2TCP, Vegas, Reno, and Cubic are already part of the patch. To install Sprout and Verus follow the following instructions: 

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

### Adding C2TCP to Kernel

### Option 1:

Simply install the debian packages of the patched kernel:

    ```sh
    cd ~/c2tcp/
    sudo dpkg -i linux-image*
    sudo dpkg -i linux-header*
    sudo reboot 
    uname -r
    ```
    
### Option 2:

Build kernel from source file.

1. Get the kernel:

	```sh
	cd ~/c2tcp/
	wget http://www.kernel.org/pub/linux/kernel/v4.0/linux-4.13.1.tar.gz
	tar -xzf linux-4.13.1.tar.gz
	```
	
2. Apply C2TCP patch to the kernel

	```sh
	cd linux-4.13.1
	patch -p1 < ~/c2tcp/c2tcp.kernel.4.13.1.patch
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
    
    If you want to have BBR and Vegas protocols, you need to select them in this step, before compiling the kernel.

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
	sudo update-initramfs -k 4.13.1 -u
	sudo update-grub
	```
	You might be aked to configure grub and install it on your partions. So follow the instructions on screen to do that.
	
	Install grub-customizer (It's a cool tool which makes life easier for changing the default kernel!):
	
	```sh
	sudo add-apt-repository ppa:danielrichter2007/grub-customizer
	sudo apt-get update
	sudo apt-get install grub-customizer
	```
	
	Then open grub-customizer and bring 4.13.1.0 at the first line (and its recovery at the second line), Save and Restart.

7. Verify the new kernel.

	```sh
	uname -r
	```
	You should see 4.13.1.0.
	
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

