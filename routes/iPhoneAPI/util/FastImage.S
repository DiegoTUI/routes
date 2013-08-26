//
//  FastImage.S
//  iPhoneApp
//
//  Created by Z.S. on 3/24/11.
//  Copyright 2011 deCarta. All rights reserved.
//

/*
 * This FastImage function code was written by Dan Posluns
 */


#include <TargetConditionals.h>
#if !(TARGET_IPHONE_SIMULATOR)

.macro def_fn
	.globl _$0
_$0:
.endm

/* Register map:

r0 <- source data ptr
r1 <- dest data ptr
r2 <- pixel/load count
r3 <- data
r4 <- data
r5 <- data
r6 <- data
r7 <- data
r8 <- data
r9 <- data
r12 <- data

*/

	.text
	.align 2
	.arm
	
def_fn FastImageRGBAtoRGB
	stmfd		sp!, {r4-r9}
	mov			r2, r2, lsr #3			@ Number of pixels * 4 bytes per pixel / 32 bytes per load
.L_FIRA_MAIN_LOOP:
	ldmia		r0!, {r3-r9, r12}
	
	bic			r3, r3, #0xFF000000
	bic			r4, r4, #0xFF000000
	bic			r5, r5, #0xFF000000
	orr			r3, r3, r4, lsl #24
	mov			r4, r4, lsr #8
	orr			r4, r4, r5, lsl #16
	mov			r5, r5, lsr #16
	orr			r5, r5, r6, lsl #8
	
	bic			r7, r7, #0xFF000000
	bic			r8, r8, #0xFF000000
	bic			r9, r9, #0xFF000000
	orr			r7, r7, r8, lsl #24
	mov			r8, r8, lsr #8
	orr			r8, r8, r9, lsl #16
	mov			r9, r9, lsr #16
	orr			r9, r9, r12, lsl #8
	
	stmia		r1!, {r3-r5, r7-r9}
	ldmia		r0!, {r3-r9, r12}		@ Unrolled 3 more times
	
	bic			r3, r3, #0xFF000000
	bic			r4, r4, #0xFF000000
	bic			r5, r5, #0xFF000000
	orr			r3, r3, r4, lsl #24
	mov			r4, r4, lsr #8
	orr			r4, r4, r5, lsl #16
	mov			r5, r5, lsr #16
	orr			r5, r5, r6, lsl #8
	
	bic			r7, r7, #0xFF000000
	bic			r8, r8, #0xFF000000
	bic			r9, r9, #0xFF000000
	orr			r7, r7, r8, lsl #24
	mov			r8, r8, lsr #8
	orr			r8, r8, r9, lsl #16
	mov			r9, r9, lsr #16
	orr			r9, r9, r12, lsl #8
	
	stmia		r1!, {r3-r5, r7-r9}
	ldmia		r0!, {r3-r9, r12}
	
	bic			r3, r3, #0xFF000000
	bic			r4, r4, #0xFF000000
	bic			r5, r5, #0xFF000000
	orr			r3, r3, r4, lsl #24
	mov			r4, r4, lsr #8
	orr			r4, r4, r5, lsl #16
	mov			r5, r5, lsr #16
	orr			r5, r5, r6, lsl #8
	
	bic			r7, r7, #0xFF000000
	bic			r8, r8, #0xFF000000
	bic			r9, r9, #0xFF000000
	orr			r7, r7, r8, lsl #24
	mov			r8, r8, lsr #8
	orr			r8, r8, r9, lsl #16
	mov			r9, r9, lsr #16
	orr			r9, r9, r12, lsl #8
	
	stmia		r1!, {r3-r5, r7-r9}
	ldmia		r0!, {r3-r9, r12}
	
	bic			r3, r3, #0xFF000000
	bic			r4, r4, #0xFF000000
	bic			r5, r5, #0xFF000000
	orr			r3, r3, r4, lsl #24
	mov			r4, r4, lsr #8
	orr			r4, r4, r5, lsl #16
	mov			r5, r5, lsr #16
	orr			r5, r5, r6, lsl #8
	
	bic			r7, r7, #0xFF000000
	bic			r8, r8, #0xFF000000
	bic			r9, r9, #0xFF000000
	orr			r7, r7, r8, lsl #24
	mov			r8, r8, lsr #8
	orr			r8, r8, r9, lsl #16
	mov			r9, r9, lsr #16
	orr			r9, r9, r12, lsl #8
	
	stmia		r1!, {r3-r5, r7-r9}
	subs		r2, r2, #4
	bgt			.L_FIRA_MAIN_LOOP
	
	ldmfd		sp!, {r4-r9}
	bx			lr

	
def_fn FastImageRGBAtoRGB565
	stmfd		sp!, {r4-r11, lr}

	@ Set up our bitmask registers
	mov			r11, #0x000007E0
	mov			r12, #0x001F0000
	orr			r12, r12, #0x0000001F
.L_RGBA_RGB565_LOOP:
	ldmfd		r0!, {r3-r10}			@ load 8 pixels
	
	and			r14, r12, r3, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r3, r11, r3, lsr #5		@ r3 <- [0000 0G60]
	orr			r3, r3, r14, lsr #16	@ r3 <- [0000 R5G6B5]
	
	and			r14, r12, r4, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r4, r11, r4, lsr #5		@ r4 <- [0000 0G60]
	orr			r4, r4, r14, lsr #16	@ r4 <- [0000 R5G6B5]
	
	and			r14, r12, r5, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r5, r11, r5, lsr #5		@ r5 <- [0000 0G60]
	orr			r5, r5, r14, lsr #16	@ r5 <- [0000 R5G6B5]

	and			r14, r12, r6, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r6, r11, r6, lsr #5		@ r6 <- [0000 0G60]
	orr			r6, r6, r14, lsr #16	@ r6 <- [0000 R5G6B5]

	and			r14, r12, r7, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r7, r11, r7, lsr #5		@ r7 <- [0000 0G60]
	orr			r7, r7, r14, lsr #16	@ r7 <- [0000 R5G6B5]

	and			r14, r12, r8, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r8, r11, r8, lsr #5		@ r8 <- [0000 0G60]
	orr			r8, r8, r14, lsr #16	@ r8 <- [0000 R5G6B5]

	and			r14, r12, r9, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r9, r11, r9, lsr #5		@ r9 <- [0000 0G60]
	orr			r9, r9, r14, lsr #16	@ r9 <- [0000 R5G6B5]

	and			r14, r12, r10, lsr #3	@ r14 <- [0..B5 0..R5]
	orr			r14, r14, lsl #27		@ r14 <- [R50B5 0..R5]
	and			r10, r11, r10, lsr #5	@ r10 <- [0000 0G60]
	orr			r10, r10, r14, lsr #16	@ r10 <- [0000 R5G6B5]

	orr			r3, r3, r4, lsl #16
	orr			r5, r5, r6, lsl #16
	orr			r7, r7, r8, lsl #16
	orr			r9, r9, r10, lsl #16

	stmia		r1!, {r3, r5, r7, r9}
	
	subs		r2, r2, #8
	bgt			.L_RGBA_RGB565_LOOP
	
	ldmfd		sp!, {r4-r11, lr}
	bx			lr


def_fn FastImagePremultiplyRGBA
	stmfd		sp!, {r4-r11, lr}
	
	@ Set up bitmask #0x00FF00FF in r14
	mov			r14, #0x0000FF00
	orr			r14, r14, #0xFF000000
	
.L_PREMULTIPLY_LOOP:
	ldmfd		r0!, {r3-r10}			@ load 8 pixels
	
	mov			r11, r3, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_0
	and			r12, r3, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r3, r3, r14				@ r3 <- [00 BB 00 RR ]
	mul			r3, r11, r3				@ r3 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r3, r3, r14				@ r3 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r3, r11, r3, lsr #8		@ r3 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_0:
	mov			r11, r4, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_1
	and			r12, r4, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r4, r4, r14				@ r4 <- [00 BB 00 RR ]
	mul			r4, r11, r4				@ r4 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r4, r4, r14				@ r4 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r4, r11, r4, lsr #8		@ r4 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_1:
	mov			r11, r5, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_2
	and			r12, r5, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r5, r5, r14				@ r5 <- [00 BB 00 RR ]
	mul			r5, r11, r5				@ r5 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r5, r5, r14				@ r5 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r5, r11, r5, lsr #8		@ r5 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_2:
	mov			r11, r6, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_3
	and			r12, r6, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r6, r6, r14				@ r6 <- [00 BB 00 RR ]
	mul			r6, r11, r6				@ r6 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r6, r6, r14				@ r6 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r6, r11, r6, lsr #8		@ r6 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_3:
	mov			r11, r7, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_4
	and			r12, r7, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r7, r7, r14				@ r7 <- [00 BB 00 RR ]
	mul			r7, r11, r7				@ r7 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r7, r7, r14				@ r7 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r7, r11, r7, lsr #8		@ r7 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_4:
	mov			r11, r8, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_5
	and			r12, r8, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r8, r8, r14				@ r8 <- [00 BB 00 RR ]
	mul			r8, r11, r8				@ r8 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r8, r8, r14				@ r8 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r8, r11, r8, lsr #8		@ r8 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_5:
	mov			r11, r9, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_6
	and			r12, r9, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r9, r9, r14				@ r9 <- [00 BB 00 RR ]
	mul			r9, r11, r9				@ r9 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r9, r9, r14				@ r9 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r9, r11, r9, lsr #8		@ r9 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_6:
	mov			r11, r10, lsr #24		@ r11 <- alpha
	cmp			r11, #0xFF
	beq			.L_PREMULTIPLY_SKIP_7
	and			r12, r10, #0xFF00		@ r12 <- [00 00 GG 00 ]
	bic			r10, r10, r14			@ r10 <- [00 BB 00 RR ]
	mul			r10, r11, r10			@ r10 <- [BB .. RR ..]
	mla			r11, r12, r11, r11		@ r11 <- [00 GG .. AA]
	and			r10, r10, r14			@ r10 <- [BB 00 RR 00 ]
	and			r11, r14, r11, ror #8	@ r11 <- [AA 00 GG 00]
	orr			r10, r11, r10, lsr #8	@ r10 <- [AA BB GG RR]
	
.L_PREMULTIPLY_SKIP_7:
	stmia		r1!, {r3-r10}
	subs		r2, r2, #8
	bgt			.L_PREMULTIPLY_LOOP
	
	ldmfd		sp!, {r4-r11, lr}
	bx			lr	


def_fn FastImageRLECompress
	stmfd		sp!, {r1, r4-r11, lr}
	
//	adr			r0, .L_TESTDATA
	ldr			r11, [r0]				@ r11 <- first pixel
	mov			r2, r2, lsl #16			@ shift pixel count into top 16 bits
	mov			r12, #0					@ makes the next four instructions basically a nop
	
	cmp			r0, #0
	
.L_RESUME_NO_NEW_WORD:
	@ Deduct however many words we repeated from the total
	mov			r12, r12, lsl #13		@ r12 <- difference between last jump in high bits
	uqsub16		r2, r2, r12				@ r2 <- remaining pixels in high bits, saturated to 0
	
	cmp			r2, #0x8000
	ble			.L_RLE_DONE

.L_FIRC_MAIN_LOOP:
	ldmia		r0!, {r3-r10}			@ load 8 pixels
	adr			r12, .L_START_POS
	cmp			r3, r11
	blne		.L_FIRC_DIFF
.L_START_POS:
	cmp			r4, r11
	blne		.L_FIRC_DIFF
	cmp			r5, r11
	blne		.L_FIRC_DIFF
	cmp			r6, r11
	blne		.L_FIRC_DIFF
	cmp			r7, r11
	blne		.L_FIRC_DIFF
	cmp			r8, r11
	blne		.L_FIRC_DIFF
	cmp			r9, r11
	blne		.L_FIRC_DIFF
	cmp			r10, r11
	sub			lr, pc, #4				@ lr <- address of following instruction

.L_FIRC_DIFF:
	sub			r12, lr, r12			@ r12 <- rle count * 8 (4 bytes/instruction * 2 instructions/rle)
	addeq		r12, r12, #8			@ (plus an additional 8 if we made it through the last test)
.L_SUB_POINT:
	add			r2, r2, r12, lsr #3		@ lower half r2 += count
	beq			.L_RESUME_NO_NEW_WORD	@ if the last test passed, deduct from total and continue
.L_OUTPUT_WORD:
	@ Output a compressed word (high byte is RLE count)
	tst			r2, #0xFF00
	orrne		r11, r11, #0xFF000000	@ if remaining bytes >= 256, output 255
	biceq		r11, r11, #0xFF000000	@ otherwise, output the correct amount
	orreq		r11, r11, r2, lsl #24	@ put byte count into upper byte of r11
	str			r11, [r1], #4
	sub			r2, r2, r11, lsr #24	@ subtract however many we output from the total
	bne			.L_OUTPUT_WORD

	@ Deduct however many words we repeated from the total pixels we are processing
	mov			r11, r12, lsl #13		@ r11 <- difference between last jump in high bits
	uqsub16		r2, r2, r11				@ r2 <- remaining pixels in high bits, saturated to 0
	cmp			r2, #0x8000
	ble			.L_RLE_DONE
	
	@ Load the next word in the sequence
	adr			r12, .L_SUB_POINT
	sub			r12, r12, lr			@ r12 <- index into where we jumped away * 4 * 2
	ldr			r11, [r0, -r12, lsr #1]	@ r11 <- value we loaded at that index
	cmp			r12, #8
	blt			.L_FIRC_MAIN_LOOP
	mov			r12, lr					@ r12 <- new starting position
	mov			pc, lr					@ resume wherever we were at

.L_NO_LOAD_NEW_WORD:
	@ Deduct however many words we repeated from the total
	mov			r12, r12, lsl #13		@ r12 <- difference between last jump in high bits
	uqsub16		r2, r2, r12				@ r2 <- remaining pixels in high bits, saturated to 0
	cmp			r2, #0x8000
	bgt			.L_FIRC_MAIN_LOOP
	
.L_RLE_DONE:
	cmp			r2, #0
	ble			.L_RLE_REALLY_DONE
.L_RLE_DONE_2:
	@ Output a compressed word (high byte is RLE count)
	tst			r2, #0xFF00
	orrne		r11, r11, #0xFF000000	@ if remaining bytes >= 256, output 255
	biceq		r11, r11, #0xFF000000	@ otherwise, output the correct amount
	orreq		r11, r11, r2, lsl #24	@ put byte count into upper byte of r11
	str			r11, [r1], #4
	sub			r2, r2, r11, lsr #24	@ subtract however many we output from the total
	bne			.L_RLE_DONE_2
	
.L_RLE_REALLY_DONE:
	ldmfd		sp!, {r0, r4-r11, lr}
	sub			r0, r1, r0				@ r0 <- total number of bytes written
	bx			lr

/*
.L_TESTDATA:
	.word		0xFFBABEDD, 0xFFBABEDD, 0xFFBABEDD, 0xFFBABEDD, 0xFFBABEDD, 0xFF000000, 0xFF012345, 0xFF012345
	.word		0xFF012345, 0xFFAAAAAA, 0xFFAAAAAA, 0xFFAAAAAA, 0xFFAAAAAA, 0xFFAAAAAA, 0xFFAAAAAA, 0xFFAAAAAA
	.word		0xFFCCCCCC, 0xFFCCCCCC, 0xFF121212, 0xFF902100, 0xFFABCDEF, 0xFFABCDEF, 0xFFABCDEF, 0xFFABCDEF
	.word		0xFF000000, 0xFF111111, 0xFF222222, 0xFF333333, 0xFF444444, 0xFF555555, 0xFF666666, 0x77777777
	.word		0xFF888888, 0xFF999999, 0xFFAAAAAA, 0xFFBBBBBB, 0xFFCCCCCC, 0xFFDDDDDD, 0xFFEEEEEE, 0xFFEEEEEE
	.word		0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
	.word		0xFFFFFFFF, 0xFF999999, 0xFF999999, 0xFF999999, 0xFFBABEDD, 0xFFBABEDD, 0xFFBABEDD, 0xFFBBBBBB
	.word		0xFFBABEDD, 0xFFBABEDD, 0xFF121212, 0xFF121212, 0xFF121212, 0xFF121212, 0xFF121212, 0xFF121212
*/
	
def_fn FastImageRLEUncompress
	stmfd		sp!, {r4-r11}

.L_RLE_UNCOMPRESS_MAINLOOP:
	ldr			r12, [r0], #4			@ r12 <- next word to uncompress
	orr			r3, r12, #0xFF000000	@ r3 <- word with 0xFF in high byte instead of count
	mov			r12, r12, lsr #24		@ r12 <- rle count
	subs		r12, r12, #8			@ if rle count < 8
	adrlt		r4, .L_RLE_OUTPUT_SUB_POINT - (8 * 4)
	sublt		r4, r4, r12, lsl #2		@	... figure out how far ahead to jump to store the correct number
	bxlt		r4
		
	mov			r4, r3					@ else, copy the value into 7 other registers
	mov			r5, r3
	mov			r6, r3
	mov			r7, r3
	mov			r8, r3
	mov			r9, r3
	mov			r10, r3
.L_RLE_OUTPUT_BLIT_LOOP:
	stmia		r1!, {r3-r10}			@ blit the registers out
	subs		r12, r12, #8
	bge			.L_RLE_OUTPUT_BLIT_LOOP
	adr			r4, .L_RLE_OUTPUT_SUB_POINT - (8 * 4)
	sub			r4, r4, r12, lsl #2		@	... figure out how far ahead to jump to store the correct number
	bx			r4
	
	str			r3, [r1], #4
	str			r3, [r1], #4
	str			r3, [r1], #4
	str			r3, [r1], #4
	str			r3, [r1], #4
	str			r3, [r1], #4
	str			r3, [r1], #4
.L_RLE_OUTPUT_SUB_POINT:
	subs		r2, r2, #4
	bgt			.L_RLE_UNCOMPRESS_MAINLOOP
	
	ldmfd		sp!, {r4-r11}
	bx			lr
	
	
#endif //TARGET_IPHONE_SIMULATOR
