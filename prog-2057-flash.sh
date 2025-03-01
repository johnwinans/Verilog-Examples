#!/bin/bash

# To program the FLASH:
#
# sudo ./prog-flash.sh myfile.bin


# The 2057-ICE40HX4K-TQ144-breakout Rev 3.0 is connected to the Pi like this:
#
# Pi function	Signal
#
# GPIO23		CDONE
# GPIO24		CRESET*
# SPI_MOSI		FPGA_SDI
# SPI_MISO		FPGA_SDO
# SPI_SCK		FPGA_SCK
# GPIO12		FPGA_SS		(special case for booting)
# SPI_CE0		FPGA_CE0	(special case not used for booting)
# GPIO16		FRESET		(used to reset the flash)
#
# NOTE: The sysfs GPIO access system has been depreciated for Raspberry Pi OS Bookworm
#       so using the recommended gpiod system here.

CRESET=24
CDONE=23
SSEL=12
FRESET=16

SPI_DEV=/dev/spidev0.0

######################################

echo ""
if [ $# -ne 1 ]; then
	echo "Usage: $0 FPGA-bin-file"
	exit 1
fi

if [ $EUID -ne 0 ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

######################################

dpkg -s gpiod &> /dev/null
if [ $? -ne 0 ]; then
	echo "gpiod package required"
	echo "Use: sudo apt install gpiod -y"
	exit 1
fi

######################################

if [ -e ${SPI_DEV} ]; then
echo "OK: SPI driver loaded"
else
	echo "spidev does not exist"

	lsmod | grep spi_bcm2835 >& /dev/null
	
	if [ $? -ne 0 ]; then
		echo "SPI driver not loaded, try to load it..."
		modprobe spi_bcm2835

		if [ $? -eq 0 ]; then
			echo "OK: SPI driver loaded"
		else
			echo "Could not load SPI driver"
		exit 1
		fi
	fi
fi

GPIO_CHIP=$(gpiofind GPIO${SSEL} | cut -d ' ' -f1)
if [ -z $GPIO_CHIP ]; then
	echo "Cannot find GPIO${SSEL} interface"
	exit 1
else
	echo "OK: ${GPIO_CHIP} found"
fi

######################################
#
# Float the SSEL pin at this point so that it won't mess 
# with the FPGA's ability to boot from flash!
echo ""
echo "Changing SSEL to an input so is not driven by the Pi"
gpioget ${GPIO_CHIP} ${SSEL} >& /dev/null

######################################
# set the CRESET to low
echo "Resetting the FPGA"
gpioset ${GPIO_CHIP} ${CRESET}=0
sleep 1

# Note that we KEEP the reset asserted here so the 
# FPGA does not try to mess with the SPI bus while 
# we are talking to the FLASH.

######################################
# Cycle FRESET low and back hi to reset the FLASH
echo "Resetting the FLASH"
gpioset ${GPIO_CHIP} ${FRESET}=0
sleep 1

echo "Floating the FRESET so it is not driven by the Pi"
gpioget ${GPIO_CHIP} ${FRESET} >& /dev/null

######################################
# Program the FLASH
#
# AT45DB081 1081344 (264-byte page mode)
# AT45DB081 1048576 (256-byte page mode)
# AT45DB161D 2162688 (528-byte page mode)
# AT45DB161D 2097152 (512-byte page mode)
echo ""
TMPBIN=$$.bin
#dd if=/dev/zero bs=1081344 count=1 of=${TMPBIN}
dd if=/dev/zero bs=1048576 count=1 of=${TMPBIN}
#dd if=/dev/zero bs=2162688 count=1 of=${TMPBIN}
#dd if=/dev/zero bs=2097152 count=1 of=${TMPBIN}
dd if=$1 of=${TMPBIN} conv=notrunc
flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 --write ${TMPBIN}
rm -f ${TMPBIN}

######################################

echo ""
echo "Releasing CRESET..."
gpioset ${GPIO_CHIP} ${CRESET}=1

echo "Floating the CRESET so it is not driven by the Pi"
gpioget ${GPIO_CHIP} ${CRESET} >& /dev/null
