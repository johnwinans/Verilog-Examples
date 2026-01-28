TOP=.

SUBDIRS= \
	minimal \
	halfadder \
	sim \
	blinky \
	types \
	always \
	vga \
	case \
	equality \
	modules \
	nonblock \
	fsm \
	uart \
	sb_io

include $(TOP)/Make.rules
