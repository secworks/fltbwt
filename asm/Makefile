#===================================================================
#
# Makefile
# --------
# Simple makefile for building the bwt decoder in 6502 asm.
#
#
# (c) 2013 Joachim Strombergson
#
#===================================================================

all:
	java -jar ~/bin/KickAssembler/KickAss.jar bwt_decode_6502.asm

run:
	~/bin/vice/x64.app/Contents/MacOS/x64 +confirmexit -reu bwt_decode_6502.prg

#===================================================================
# EOF Makefile
#===================================================================
