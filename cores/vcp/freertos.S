/*
 * FreeRTOS Kernel V10.3.1
 * Copyright (C) 2020 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * http://www.FreeRTOS.org
 * http://aws.amazon.com/freertos
 *
 * 1 tab == 4 spaces!
 */
/*********************************************************************************************************
*                                          PUBLIC FUNCTIONS
*********************************************************************************************************/
                                                                @ External references.

                                                                @ Functions declared in this file.
                                                                @ Functions related to exception handling.
    .global  FreeRTOS_ARM_ExceptUndefInstrHndlr
    .global  FreeRTOS_ARM_ExceptSwiHndlr
    .global  FreeRTOS_ARM_ExceptPrefetchAbortHndlr
    .global  FreeRTOS_ARM_ExceptDataAbortHndlr
    .global  FreeRTOS_ARM_ExceptIrqHndlr
    .global  FreeRTOS_ARM_ExceptFiqHndlr

    .global  FreeRTOS_ARM_DRegCntGet
    .global  CPU_WaitForEvent
    .global  CPU_DSB

    .global  CPU_SR_Save
    .global  CPU_SR_Restore

    .global  BSP_UndefAbortExceptionHook


/*********************************************************************************************************
*                                               EQUATES
*********************************************************************************************************/

#define FreeRTOS_ARM_CONTROL_INT_DIS        0xC0                     // Disable both FIQ and IRQ.
#define FreeRTOS_ARM_CONTROL_FIQ_DIS        0x40                     // Disable FIQ.
#define FreeRTOS_ARM_CONTROL_IRQ_DIS        0x80                     // Disable IRQ.
#define FreeRTOS_ARM_CONTROL_THUMB          0x20                     // Set THUMB mode.
#define FreeRTOS_ARM_CONTROL_ARM            0x00                     // Set ARM mode.

#define FreeRTOS_ARM_MODE_MASK              0x1F
#define FreeRTOS_ARM_MODE_USR               0x10
#define FreeRTOS_ARM_MODE_FIQ               0x11
#define FreeRTOS_ARM_MODE_IRQ               0x12
#define FreeRTOS_ARM_MODE_SVC               0x13
#define FreeRTOS_ARM_MODE_ABT               0x17
#define FreeRTOS_ARM_MODE_UND               0x1B
#define FreeRTOS_ARM_MODE_SYS               0x1F

#define FreeRTOS_ARM_EXCEPT_RESET           0x00
#define FreeRTOS_ARM_EXCEPT_UNDEF_INSTR     0x01
#define FreeRTOS_ARM_EXCEPT_SWI             0x02
#define FreeRTOS_ARM_EXCEPT_PREFETCH_ABORT  0x03
#define FreeRTOS_ARM_EXCEPT_DATA_ABORT      0x04
#define FreeRTOS_ARM_EXCEPT_ADDR_ABORT      0x05
#define FreeRTOS_ARM_EXCEPT_IRQ             0x06
#define FreeRTOS_ARM_EXCEPT_FIQ             0x07

#define FreeRTOS_ARM_FPEXC_EN               0x40000000


/*********************************************************************************************************
*                                     CODE GENERATION DIRECTIVES
*********************************************************************************************************/

//    RSEG CODE:CODE:NOROOT(2)
//    AAPCS INTERWORK
//    PRESERVE8
//    REQUIRE8
//    CODE32

/*********************************************************************************************************
*                               UNDEFINED INSTRUCTION EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptUndefInstrHndlr:
                                                                @ LR offset to return from this exception:  0.
    STMFD   SP!, {R0-R3}                                        @ Push working registers.
    MOV     R2, LR                                              @ Save link register.
    MOV     R0, #FreeRTOS_ARM_EXCEPT_UNDEF_INSTR                  @ Set exception ID to FreeRTOS_ARM_EXCEPT_UNDEF_INSTR.
    BL BSP_UndefAbortExceptionHook
    B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                                SOFTWARE INTERRUPT EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptSwiHndlr:
    B	FreeRTOS_SWI_Handler
    //STMFD   SP!, {R0-R3}                                        @ Push working registers.
    //MOV     R2, LR                                              @ Save link register.
    //MOV     R0, #FreeRTOS_ARM_EXCEPT_SWI                          @ Set exception ID to FreeRTOS_ARM_EXCEPT_SWI.
    //B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                                  PREFETCH ABORT EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptPrefetchAbortHndlr:
    SUB     LR, LR, #4                                          @ LR offset to return from this exception: -4.
    STMFD   SP!, {R0-R3}                                        @ Push working registers.
    MOV     R2, LR                                              @ Save link register.
    MOV     R0, #FreeRTOS_ARM_EXCEPT_PREFETCH_ABORT               @ Set exception ID to FreeRTOS_ARM_EXCEPT_PREFETCH_ABORT.
    BL BSP_UndefAbortExceptionHook
    B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                                    DATA ABORT EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptDataAbortHndlr:
    SUB     LR, LR, #8                                          @ LR offset to return from this exception: -8.
    STMFD   SP!, {R0-R3}                                        @ Push working registers.
    MOV     R2, LR                                              @ Save link register.
    MOV     R0, #FreeRTOS_ARM_EXCEPT_DATA_ABORT                   @ Set exception ID to FreeRTOS_ARM_EXCEPT_DATA_ABORT.
    BL BSP_UndefAbortExceptionHook
    B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                                   ADDRESS ABORT EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptAddrAbortHndlr:
    SUB     LR, LR, #8                                          @ LR offset to return from this exception: -8.
    STMFD   SP!, {R0-R3}                                        @ Push working registers.
    MOV     R2, LR                                              @ Save link register.
    MOV     R0, #FreeRTOS_ARM_EXCEPT_ADDR_ABORT                   @ Set exception ID to FreeRTOS_ARM_EXCEPT_ADDR_ABORT.
    BL BSP_UndefAbortExceptionHook
    B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                                 INTERRUPT REQUEST EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptIrqHndlr:
    B FreeRTOS_IRQ_Handler
    //SUB     LR, LR, #4                                          @ LR offset to return from this exception: -4.
    //STMFD   SP!, {R0-R3}                                        @ Push working registers.
    //MOV     R2, LR                                              @ Save link register.
    //MOV     R0, #FreeRTOS_ARM_EXCEPT_IRQ                          @ Set exception ID to FreeRTOS_ARM_EXCEPT_IRQ.
    //B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                              FAST INTERRUPT REQUEST EXCEPTION HANDLER
*
* Register Usage:  R0     Exception Type
*                  R1
*                  R2     Return PC
*********************************************************************************************************/

FreeRTOS_ARM_ExceptFiqHndlr:
    SUB     LR, LR, #4                                          @ LR offset to return from this exception: -4.
    STMFD   SP!, {R0-R3}                                        @ Push working registers.
    MOV     R2, LR                                              @ Save link register.
    MOV     R0, #FreeRTOS_ARM_EXCEPT_FIQ                          @ Set exception ID to FreeRTOS_ARM_EXCEPT_FIQ.
    B            FreeRTOS_ARM_ExceptHndlr                         @ Branch to global exception handler.


/*********************************************************************************************************
*                                      GLOBAL EXCEPTION HANDLER
*
*********************************************************************************************************/

FreeRTOS_ARM_ExceptHndlr:

     BX      LR


/*********************************************************************************************************
*                              VFP/NEON REGISTER COUNT
*
* Register Usage:  R0     Double Register Count
*********************************************************************************************************/

FreeRTOS_ARM_DRegCntGet:
    MOV     R0, #0
    BX      LR


CPU_WaitForEvent:
        DSB
        WFE                                     @ Wait for exception
        BX      LR


CPU_DSB:
        DSB
        ISB
        BX      LR

/*********************************************************************************************************
*                                      CRITICAL SECTION FUNCTIONS
*
* Description : Disable/Enable interrupts by preserving the state of interrupts.  Generally speaking, the
*               state of the interrupt disable flag is stored in the local variable 'cpu_sr' & interrupts
*               are then disabled ('cpu_sr' is allocated in all functions that need to disable interrupts).
*               The previous interrupt state is restored by copying 'cpu_sr' into the CPU's status register.
*
* Prototypes  : CPU_SR  CPU_SR_Save   (void);
*               void    CPU_SR_Restore(CPU_SR  cpu_sr);
*
* Note(s)     : (1) These functions are used in general like this :
*
*                       void  Task (void  *p_arg)
*                       {
*                           CPU_SR_ALLOC();                     // Allocate storage for CPU status register
*                               :
*                               :
*                           CPU_CRITICAL_ENTER();               // cpu_sr = CPU_SR_Save();
*                               :
*                               :
*                           CPU_CRITICAL_EXIT();                // CPU_SR_Restore(cpu_sr);
*                               :
*                       }
*********************************************************************************************************/

CPU_SR_Save:
        MRS     R0, CPSR
        CPSID   IF                                              @ Set IRQ & FIQ bits in CPSR to DISABLE all interrupts
        DSB
        BX      LR                                              @ DISABLED, return the original CPSR contents in R0


CPU_SR_Restore:
        DSB
        MSR     CPSR_c, R0
        BX      LR


    .end
