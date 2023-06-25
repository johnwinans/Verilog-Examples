#!/bin/bash

# To program the FLASH:
#
# sudo ./prog-flash.sh myfile.bin


# The 2057-ICE40HX4K-TQ144-breakout Rev 3.0 is connected to the PI like this:
#
# Signal		PI function
# CRESET*		GPIO24
# CDONE			GPIO23
# FPGA_SS		GPIO12	(special case for booting)
# FPGA_SDI		SPI_MOSI 
# FPGA_SDO		SPI_MISO
# FPGA_SCK		SPI_SCK
# FPGA_CE0		SPI_CE0 (special case not used for booting)
# FRESET		GPIO16	(used to reset the flash)

CRESET=24
CDONE=23
SSEL=12
FRESET=16

SPI_DEV=/dev/spidev0.0


######################################
echo ""
if [ $# -ne 1 ]; then
    echo "Usage: $0 FPGA-bin-file "
    exit 1
fi

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

######################################

if [ ! -d /sys/class/gpio/gpio${SSEL} ]; then
    echo "GPIO ${SSEL} not exported, trying to export..."
    echo ${SSEL} > /sys/class/gpio/export
    if [ ! -d /sys/class/gpio/gpio${SSEL} ]; then
	echo "ERROR: directory /sys/class/gpio/gpio${SSEL} does not exist"
	exit 1
    fi
else
    echo "OK: GPIO ${SSEL} exported"
fi

######################################
if [ ! -d /sys/class/gpio/gpio${CRESET} ]; then
    echo "GPIO ${CRESET} not exported, trying to export..."
    echo ${CRESET} > /sys/class/gpio/export
    if [ ! -d /sys/class/gpio/gpio${CRESET} ]; then
    echo "ERROR: directory /sys/class/gpio/gpio${CRESET} does not exist"
    exit 1
    fi
else
    echo "OK: GPIO ${CRESET} exported"
fi

######################################
if [ ! -d /sys/class/gpio/gpio${FRESET} ]; then
    echo "GPIO ${FRESET} not exported, trying to export..."
    echo ${FRESET} > /sys/class/gpio/export
    if [ ! -d /sys/class/gpio/gpio${FRESET} ]; then
    echo "ERROR: directory /sys/class/gpio/gpio${FRESET} does not exist"
    exit 1
    fi
else
    echo "OK: GPIO ${FRESET} exported"
fi

######################################

echo ""
if [ -e ${SPI_DEV} ]; then
    echo "OK: SPI driver loaded"
else
    echo "spidev does not exist"
    
    #lsmod | grep spi_bcm2708 >& /dev/null
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

######################################
#
# Float the SSEL pin at this point so that it won't mess 
# with the FPGA's ability to boot from flash!

echo "changing SSEL to an input so is not driven by the PI"
echo in > /sys/class/gpio/gpio${SSEL}/direction
cat /sys/class/gpio/gpio${SSEL}/direction



######################################
# set the CRESET to low

echo ""
echo "Changing direction to out"
echo out > /sys/class/gpio/gpio${CRESET}/direction
cat /sys/class/gpio/gpio${CRESET}/direction

echo "Resetting the FPGA (should be 0)"
echo 0 > /sys/class/gpio/gpio${CRESET}/value
cat /sys/class/gpio/gpio${CRESET}/value
sleep 1

# Note that we KEEP the reset asserted here so the 
# FPGA does not try to mess with the SPI bus while 
# we are talking to the FLASH.

######################################
# Cycle FRESET low and back hi to reset the FLASH
echo ""
echo "Changing FRESET direction to out"
echo out > /sys/class/gpio/gpio${FRESET}/direction
cat /sys/class/gpio/gpio${FRESET}/direction

echo "Resetting the FLASH (should be 0)"
echo 0 > /sys/class/gpio/gpio${FRESET}/value
cat /sys/class/gpio/gpio${FRESET}/value
sleep 1
echo "Floating the FRESET so it is not driven by the PI"
echo in > /sys/class/gpio/gpio${FRESET}/direction
cat /sys/class/gpio/gpio${FRESET}/direction


######################################
# program the FLASH
# 
# AT45DB081 1081344 (264-byte page mode)
# AT45DB081 1048576 (256-byte page mode)

TMPBIN=$$.bin
#dd if=/dev/zero bs=1081344 count=1 of=${TMPBIN}
dd if=/dev/zero bs=1048576 count=1 of=${TMPBIN}
dd if=$1 of=${TMPBIN} conv=notrunc
flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 --write ${TMPBIN}
rm -f ${TMPBIN}



######################################

echo "Releasing CRESET... (should be 1)"
echo 1 > /sys/class/gpio/gpio${CRESET}/value
cat /sys/class/gpio/gpio${CRESET}/value


echo "Floating the CRESET so it is not driven by the PI"
echo in > /sys/class/gpio/gpio${CRESET}/direction
cat /sys/class/gpio/gpio${CRESET}/direction
