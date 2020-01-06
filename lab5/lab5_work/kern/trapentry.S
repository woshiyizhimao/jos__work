/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*
  * edited by Lethe 
  */
  TRAPHANDLER_NOEC(divide_error,T_DIVIDE)		#0
  TRAPHANDLER_NOEC(debug_exception,T_DEBUG)		#1
  TRAPHANDLER_NOEC(non_maskable_interrupt,T_NMI)	#2 can't find it in 80386 manual
  TRAPHANDLER_NOEC(_breakpoint,T_BRKPT)			#3
  TRAPHANDLER_NOEC(overflow,T_OFLOW)			#4
  TRAPHANDLER_NOEC(bounds_check,T_BOUND)		#5
  TRAPHANDLER_NOEC(illegal_opcode,T_ILLOP)		#6
  TRAPHANDLER_NOEC(device_not_available,T_DEVICE)	#7
  TRAPHANDLER(double_fault,T_DBLFLT)			#8
  TRAPHANDLER(invalid_task_switch_segment,T_TSS)	#10
  TRAPHANDLER(segment_not_present,T_SEGNP)		#11
  TRAPHANDLER(stack_exception,T_STACK)			#12
  TRAPHANDLER(general_protection_fault,T_GPFLT)		#13
  TRAPHANDLER(page_fault,T_PGFLT)			#14
  TRAPHANDLER_NOEC(floating_point_error,T_FPERR)	#16
  TRAPHANDLER_NOEC(alignment_check,T_ALIGN)		#17
  TRAPHANDLER_NOEC(machine_check,T_MCHK)		#18
  TRAPHANDLER_NOEC(SIMD_floating_point_error,T_SIMDERR)	#19
  TRAPHANDLER_NOEC(system_call,T_SYSCALL)		#48

/*
 * exercise 13, lab4
 * edited by Lethe 2018/12/7
 */
   TRAPHANDLER_NOEC(irq_handler32,IRQ_OFFSET+IRQ_TIMER)		#32
   TRAPHANDLER_NOEC(irq_handler33,IRQ_OFFSET+IRQ_KBD)		#33
   TRAPHANDLER_NOEC(irq_handler36,IRQ_OFFSET+IRQ_SERIAL)	#36
   TRAPHANDLER_NOEC(irq_handler39,IRQ_OFFSET+IRQ_SPURIOUS)	#39
   TRAPHANDLER_NOEC(irq_handler46,IRQ_OFFSET+IRQ_IDE)		#46
   TRAPHANDLER_NOEC(irq_handler51,IRQ_OFFSET+IRQ_ERROR)		#51

/*
 * Lab 3: Your code here for _alltraps
 */
 /*
  * edited by Lethe 
  */
 _alltraps:
		# push values in reverse to make the stack look like
		# a struct Trapframe
		# everything below tf_trapno is already on stack

		# we should push %ds %es in order after tf_trapno is pushed
		pushl %ds
		pushl %es

		# registers involved in struct PushRegs can be pushed
		# by pusha at a time
		pushal

		# load GD_KD into %ds and %es
		movl $GD_KD,%eax
		movw %ax,%ds
		movw %ax,%es

		pushl %esp
		
		# below copy from entry.s
		# Clear the frame pointer register (EBP)
		# so that once we get into debugging C code,
		# stack backtraces will be terminated properly.
		movl	$0x0,%ebp			# nuke frame pointer

		call trap


