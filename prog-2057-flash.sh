#!/bin/bash
#
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

######################################

# libgpiod version detection by targeting the first line only
# This avoids reading the LGPL license lines.
GPIOD_VER_STR=$(gpioset --version | head -n 1)
if [[ "$GPIOD_VER_STR" == *"v2"* ]]; then
    GPIOD_VER=2
else
    GPIOD_VER=1
fi
echo "Detected libgpiod version: $GPIOD_VER ($GPIOD_VER_STR)"

######################################

# Find correct gpiochip for header (Works for Pi 0 through Pi 5)
# On Pi 5, the header is typically on the RP1 chip (pinctrl-rp1).
CHIP=$(gpiodetect | grep -E "pinctrl-rp1|pinctrl-bcm2" | awk '{print $1}' | head -n1 | tr -d ':')
[ -z "$CHIP" ] && CHIP="gpiochip0"
echo "Using $CHIP for GPIO"

######################################

# Helper function for cross-version GPIO sets
set_gpio() {
    local line=$1
    local val=$2
    if [ "$GPIOD_VER" -eq "2" ]; then
        # v2 tools require a hold period or they release the line immediately
        gpioset --hold-period 10ms -t 0 -c "$CHIP" "$line=$val"
    else
        gpioset "$CHIP" "$line=$val"
    fi
}

# Helper function to "float" a pin (set to input)
float_gpio() {
    local line=$1
    if [ "$GPIOD_VER" -eq "2" ]; then
        # v2 tools require a hold period or they release the line immediately
        gpioget -c "$CHIP" "$line" > /dev/null 2>&1
    else
        gpioget "$CHIP" "$line" > /dev/null 2>&1
    fi
}

######################################
#
# Float the SSEL pin at this point so that it won't mess
# with the FPGA's ability to boot from flash!echo "Floating SSEL..."
echo ""
echo "Changing SSEL to an input so is not driven by the Pi"
float_gpio $SSEL

######################################
# set the CRESET to low
echo "Resetting FPGA (Holding CRESET low)..."
if [ "$GPIOD_VER" -eq "2" ]; then
    # Pi 5/Trixie: Keep reset low in background to maintain persistence
    gpioset -c "$CHIP" "$CRESET=0" &
    RESET_PID=$!
else
    # Older Pi/v1: Persistence is often the default behavior
    set_gpio $CRESET 0
    RESET_PID=""
fi
sleep 1

# Note that we KEEP the reset asserted here so the
# FPGA does not try to mess with the SPI bus while
# we are talking to the FLASH.

######################################
# Cycle FRESET low and back hi to reset the FLASH
echo "Resetting FLASH..."
set_gpio $FRESET 0
sleep 1

echo "Floating the FRESET so it is not driven by the Pi"
float_gpio $FRESET

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
[ -n "$RESET_PID" ] && kill $RESET_PID
set_gpio $CRESET 1

echo "Floating the CRESET so it is not driven by the Pi"
float_gpio $CRESET

echo "Done."
