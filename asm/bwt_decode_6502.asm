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
// Detect and determine size of the REU.
//------------------------------------------------------------------
reu_detect:
                        lda #$00
                        rts


//------------------------------------------------------------------
// Create frequency table for all bytes in the target.
// We use two bytes/byte separated in hi and low tables.
//------------------------------------------------------------------
gen_freq_table:     
                        lda #< target
                        sta $f8
                        lda #> target
                        sta $f9

                        ldy #$00
                        lda ($f8), y
                        tax
                        inc $freq_low, x
                        bne next
                        inc $frew_hi, x

//------------------------------------------------------------------
// BWT decode state and data fields.
//------------------------------------------------------------------

.pc = $8000 "BWT Decode test data."
target_size: .byte $10, $00
target_addr: .byte $00, $c0
target_row:  .byte $03
target_data  .byte $3a, $30, $33, $32, $32


//======================================================================
// EOF bwt_decode_6502.asm
//======================================================================
