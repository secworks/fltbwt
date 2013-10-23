//======================================================================
//
// bwt_decode_6502.asm
// --------------------
// Space efficient implementation of Burrows-Wheeler Transform
// decoder. The decoder uses REU for temporary storage.
// The decoder will destroy any contents in two banks (BANK and
// BANK+1) during decode operation.
//
// Usage in the REU:
// Bank n: Copy of the block.
// Bank n+1 : Low byte char index.
// Bank n+2 : High byte char index.
// 
// Usage in main memory:
// rank_low: Low byte rank table. 256 Bytes
// rank_high: High bute rank table. 256 Bytes.
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
// Rank tables. Placed in the screen.
//------------------------------------------------------------------
.pc = $0400 "Rank tables" virtual 
rank_table_low:  .fill $100, $00
rank_table_high: .fill $100, $00


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
.pc =$4000 "bwt_decode"
bwt_decode:
                        // Step 1: Check REU availability
                        // Quit if not available.
                        jsr reu_detect
                        cmp #$00
                        bne reu_available
                        jmp no_reu

reu_available:
                        // Step 2: DMA copy block to bank N
                        inc $d020
                        
                        jsr block_copy

                        // Step 3: For each byte in block:
                        // 3.1 Store rank in bank N+1 and N+2
                        // 3.2 Increase rank counter.

                        jsr gen_rank

                        // Step 4: Starting with last byte, for
                        // each byte we perform pointer chasing 
                        // by getting char value and rank to 
                        // get next byte.
                        
                        jsr block_decode

                        // Step 5: Done.
                        rts


no_reu:
                        // Print error message and quit.
                        ldx #$00
reu_fail_l1:            lda no_reu_error, x
                        sta $0400, x
                        inx
                        cpx #$14
                        bne reu_fail_l1
                        rts

//------------------------------------------------------------------
// reu_detect()
// 
// This routine tries to change the values of the REU base register
// control registers. If the REU is present the values can change.
// This is basically borrowed from:
// http://commodore64.wikispaces.com/Programming+the+REU
//------------------------------------------------------------------
reu_detect:

                        lda $df02
                        eor #$aa
                        sta $df02
                        lda $df02
                        beq reu_detect_fail
                        lda #$01
                        rts
                        
reu_detect_fail:        lda #$00
                        rts


//------------------------------------------------------------------
//------------------------------------------------------------------
block_copy:
                        rts


//------------------------------------------------------------------
// gen_rank()
//
// 1. Zero fill the rank table.
// 2. For each char in the block store the current rank
//    in the REU at the index of the char.
// 3. Increase the rank table for the char.
//------------------------------------------------------------------
gen_rank:
                        ldx #$00
                        lda #$00
gen_rank_l1:            sta rank_table_low, x
                        sta rank_table_high, x
                        inx
                        bne gen_rank_l1
                        rts


//------------------------------------------------------------------
//------------------------------------------------------------------
block_decode:
                        rts               


//------------------------------------------------------------------
// BWT decode data and local tables.
//------------------------------------------------------------------
// No REU error string
no_reu_error:           .text "error: no reu found."

// The bank number for the first bank in the REU to use.
// Note that we will also use banks n+1 and n+2.
bwt_bank_n:  .byte $00

ran_table_lo: 

//------------------------------------------------------------------
// Test data.
//------------------------------------------------------------------

test_index:
                        .byte $00, $00

test_block:
                        .byte $00, $10, $20


//======================================================================
// EOF bwt_decode_6502.asm
//======================================================================

