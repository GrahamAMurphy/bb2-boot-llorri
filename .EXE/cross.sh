#!/bin/sh
# Cross-compile

# Compile Forth with bootboot1.  Forth is automatically copied from ROM
# to RAM page 0.
forth auto
smf sppbootfor.mem >sppbootfor.smf
motor -d 0 sppbootfor.mem >sppbootfor.abs
