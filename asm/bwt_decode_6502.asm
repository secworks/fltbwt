//======================================================================
//
// bwt_decode_6502.asm
// --------------------
// Space efficient implementation of Burrows-Wheeler Transform
// decoder. The decoder uses REU for temporary storage.
// The decoder will destroy any contents in two banks (BANK and
// BANK+1) during decode operation.
// 
//
// Build:
// java -jar KickAss.jar bwt_decode_6502.asm
//
//
// Copyright (c) 2013, Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

//------------------------------------------------------------------
// Include KickAssembler Basic uppstart code.
//------------------------------------------------------------------
.pc =$0801 "Basic Upstart Program"
:BasicUpstart($4000)

//------------------------------------------------------------------
// bwt_decode()
//
// Start of the bwt decoder.
//
//------------------------------------------------------------------
bwt_decode:
                        // Step 1: Check REU availability
                        // Quit of not available.
                        jsr reu_detect
                        beq reu_available 
                        jmp no_reu

reu_available:
                        // Step 2: DMA copy block to bank N
                        inc $d020

                        // Step 3: For each byte in block:
                        // 3.1 Store rank in bank N+1 and N+2
                        // 3.2 Increase rank counter.

                        // Step 4: Starting with last byte, for
                        // each byte we perform pointer chasing 
                        // by getting char value and rank to 
                        // get next byte.
                        
                        // Step 5: Done.
                        rts


no_reu:                 // Print error message and quit.
                        rts


//------------------------------------------------------------------
// reu_detect()
// 
// If REU detected return 0x01 in accumulator. If not 0x00.
//------------------------------------------------------------------
reu_detect:
                        lda #$00
                        rts


//------------------------------------------------------------------
// Create frequency table for all bytes in the target.
// We use two bytes/byte separated in hi and low tables.
//------------------------------------------------------------------
// gen_freq_table:     
//                         lda #< target
//                         sta $f8
//                         lda #> target
//                         sta $f9
// 
//                         ldy #$00
//                         lda ($f8), y
//                         tax
//                         inc $freq_low, x
//                         bne next
//                         inc $frew_hi, x
// 
//------------------------------------------------------------------
// BWT decode state and data fields.
//------------------------------------------------------------------

// The bank number for the first bank in the REU to use.
// NOte that we will also use banks n+1 and n+2.
bwt_bank_n:  .byte $00


//======================================================================
// EOF bwt_decode_6502.asm
//======================================================================
