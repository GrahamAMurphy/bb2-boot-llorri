#!/bin/sh
# Usage: down.sh [modules] [sim=puck]

XSHIP_SPEED=19200
export XSHIP_SPEED

# process options
while [ $1 ]; do
	case $1 in
		modules)    modules="true";;	# use "real" modules
		sim=puck)   puck="true";;	# running on Puck hardware
	esac
	shift
done

# General libraries
squish -l struct.fr
if [ $modules ]; then
	squish -l modules3.fr
else
	squish -l modules2.fr
fi
squish -l cross-emul.fr
squish -l rtxprims.fr				# RTX prims used in instrlib
squish -l timers2.fr
squish -l far2.fr
squish -l farqueue.fr
squish -l fardump.fr				# debug
squish -l extend.fr				# needed by outbits, etc.
squish -l outbits2.fr

# Shared: h/w addresses, common code config, etc.
squish -l hw.fr					# SPP common
squish -l hw-wispr.fr				# SPP common - WISPR-specific
squish    hw-app-wispr.fr			# WISPR application-specific
squish -l config.fr				# SPP common
squish -l config-wispr.fr			# SPP common - WISPR-specific
squish    config-app-wispr.fr			# WISPR application-specific
squish -l farallot3.fr
squish    stat-db.fr
squish -l slotsched1.fr

# Host interface part 1 (part 2 loaded later)
# Host interface, time-keeping, low-level I/O, telemetry, etc.
squish -l time.fr
squish -l host-io-wispr.fr
squish -l host-tlm.fr
squish -l crit-hsk.fr

# Core functions
squish -l spi-user1.fr
squish -l adc1.fr
squish -l memory1.fr
squish -l farcopy.fr
squish -l cmd-dict1.fr
squish -l cmd-text1.fr
squish -l dump1.fr
squish -l alarm1.fr
squish -l sumcrc.fr
squish -l mem-cmd2.fr
squish -l defmacro1.fr
squish -l macro1.fr
squish -l macro-arch1.fr
squish -l macro-dump1.fr
squish -l monitor1.fr
squish -l cmd-echo1.fr
squish -l cmd-proc1.fr
squish -l stat-proc1.fr
squish -l safing1.fr
squish -l safing-extend.fr		# SPP extension

# Host interface part 2
# Host interface, commanding, etc.
squish -l host-cmd.fr
squish -l host-cmd-wispr.fr

# Orchestrator
squish -l telecmd1.fr
squish -l telemetry1.fr

# Application-specific code
squish macro-dflt.fr
squish monitor-dflt.fr
squish analogs.fr
squish crit-hsk-wispr.fr
# TBD

# Initialization
squish    main.fr

# Testing
squish tests/itf-test.fr

# Complete
echo "7 emit"
echo ".( Type 'go' to start program)"
echo "quit"

