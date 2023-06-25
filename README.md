# Test Apps

These instructions have been verified on:
- Ubuntu 22.04.2 LTS on 2023-06-24
- Ubuntu 20.04.2 LTS on 2023-06-24

# Get the toolchain

## Install from packages (where available)

On Ubuntu 22.04.2 LTS, I was able to install the required tools like this:

```
sudo apt install iverilog
sudo apt install gtkwave
sudo apt install fpga-icestorm
sudo apt install nextpnr-ice40
```

Note that, on older systems, packages for these tools can be outdated or missing.

## Install from source

On Ubuntu 20.04.2 LTS I was able to build the toolchain and install it under `user/local` like this:

```
sudo apt install iverilog
sudo apt install gtkwave
sudo apt install build-essential libftdi-dev libboost-all-dev libeigen3-dev clang-format python3-dev cmake

nproc=3

git clone https://github.com/YosysHQ/icestorm.git
cd icestorm
    make -j$(nproc)
    sudo make install
cd ..

git clone https://github.com/YosysHQ/nextpnr
cd nextpnr
    cmake . -DARCH=ice40
    make -j$(nproc)
    sudo make install
cd ..

git clone https://github.com/YosysHQ/yosys.git
cd yosys
    make -j$(nproc)
    sudo make install
cd ..
```

# Configure for your FPGA board

By default, this repo is configured to build for the [upduino-v3-1](https://tinyvision.ai/products/upduino-v3-1).
If you are using a different board then you must create a configuration to suit your needs.

If you are using an [IceStick](https://www.latticesemi.com/icestick) then create a file named `Makefile.local` in
the top REPO directory and insert the following line into it:

```
include $(TOP)/Make.icestick.rules
```

If you are using a [2057-ICE40HX4K-TQ144-breakout](https://github.com/johnwinans/2057-ICE40HX4K-TQ144-breakout) then
then create a file named `Makefile.local` in the top REPO directory and insert the following line into it:

```
include $(TOP)/Make.2057.rules
```

To explicitly configure for the upduino-v3-1 you can create a file named `Makefile.local` in the top REPO directory and insert the following line into it:

```
include $(TOP)/Make.upduino.rules
```

If you decide to create a configuration for another board, please share it with the commulity by 
submitting a pull request, creating an issue, etc.


# To compile applications

You can compile/clean all the projects in this REPO from the top level directory
using `make` and `make clean`.  If you want to only build one then go into its
directory and `make`, `make clean` from there.

# To simulate an application and view a waveform of it running 

```
cd blinky2
make plot
```

Then, in gtkwave, open (double-click) the 'tb' object in the tree, click on 'uut'. 

![selecting signals to view](./pics/selsig.png)


Then, in the signals box below click on the 'clk' signal and ctrl-click on 'counter[24:0]'
(so that they are both selected at the same time) and click the Append button at the 
bottom left.  

At this point, you can zoom and scroll around the waveform on the right to see the 
clock signal ticking and the counter advancing on the rising/positive edge of 
the 'clk' signal.

![selecting signals to view](./pics/waveform.png)
