
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 8e 20 f0 00 	cmpl   $0x0,0xf0208e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 8e 20 f0    	mov    %esi,0xf0208e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 99 5b 00 00       	call   f0105bfa <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 62 10 f0       	push   $0xf01062a0
f010006d:	e8 94 37 00 00       	call   f0103806 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 64 37 00 00       	call   f01037e0 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 e0 76 10 f0 	movl   $0xf01076e0,(%esp)
f0100083:	e8 7e 37 00 00       	call   f0103806 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 06 0a 00 00       	call   f0100a9b <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 a0 24 f0       	mov    $0xf024a008,%eax
f01000a6:	2d d8 7c 20 f0       	sub    $0xf0207cd8,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 d8 7c 20 f0       	push   $0xf0207cd8
f01000b3:	e8 20 55 00 00       	call   f01055d8 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 8b 05 00 00       	call   f0100648 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 63 10 f0       	push   $0xf010630c
f01000ca:	e8 37 37 00 00       	call   f0103806 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 93 13 00 00       	call   f0101467 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 c0 2f 00 00       	call   f0103099 <env_init>
	trap_init();
f01000d9:	e8 fb 37 00 00       	call   f01038d9 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 0d 58 00 00       	call   f01058f0 <mp_init>
	lapic_init();
f01000e3:	e8 2d 5b 00 00       	call   f0105c15 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 40 36 00 00       	call   f010372d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 6f 5d 00 00       	call   f0105e68 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 8e 20 f0 07 	cmpl   $0x7,0xf0208e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 c4 62 10 f0       	push   $0xf01062c4
f010010f:	6a 6c                	push   $0x6c
f0100111:	68 27 63 10 f0       	push   $0xf0106327
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 56 58 10 f0       	mov    $0xf0105856,%eax
f0100123:	2d dc 57 10 f0       	sub    $0xf01057dc,%eax
f0100128:	50                   	push   %eax
f0100129:	68 dc 57 10 f0       	push   $0xf01057dc
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 ed 54 00 00       	call   f0105625 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 90 20 f0       	mov    $0xf0209020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 b3 5a 00 00       	call   f0105bfa <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 90 20 f0       	add    $0xf0209020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 90 20 f0       	sub    $0xf0209020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 20 21 f0       	add    $0xf0212000,%eax
f010016b:	a3 84 8e 20 f0       	mov    %eax,0xf0208e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 e2 5b 00 00       	call   f0105d63 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 93 20 f0 74 	imul   $0x74,0xf02093c4,%eax
f0100196:	05 20 90 20 f0       	add    $0xf0209020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 64 6f 1c f0       	push   $0xf01c6f64
f01001a9:	e8 9f 30 00 00       	call   f010324d <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 9c 7f 1f f0       	push   $0xf01f7f9c
f01001b8:	e8 90 30 00 00       	call   f010324d <env_create>
ENV_CREATE(user_dumbfork,ENV_TYPE_USER);
//>>>>>>> lab4
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 2a 04 00 00       	call   f01005ec <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 4c 42 00 00       	call   f0104413 <sched_yield>

f01001c7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cd:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 15                	ja     f01001ee <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 e8 62 10 f0       	push   $0xf01062e8
f01001df:	68 83 00 00 00       	push   $0x83
f01001e4:	68 27 63 10 f0       	push   $0xf0106327
f01001e9:	e8 52 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f3:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f6:	e8 ff 59 00 00       	call   f0105bfa <cpunum>
f01001fb:	83 ec 08             	sub    $0x8,%esp
f01001fe:	50                   	push   %eax
f01001ff:	68 33 63 10 f0       	push   $0xf0106333
f0100204:	e8 fd 35 00 00       	call   f0103806 <cprintf>

	lapic_init();
f0100209:	e8 07 5a 00 00       	call   f0105c15 <lapic_init>
	env_init_percpu();
f010020e:	e8 56 2e 00 00       	call   f0103069 <env_init_percpu>
	trap_init_percpu();
f0100213:	e8 02 36 00 00       	call   f010381a <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100218:	e8 dd 59 00 00       	call   f0105bfa <cpunum>
f010021d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100220:	81 c2 20 90 20 f0    	add    $0xf0209020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100226:	b8 01 00 00 00       	mov    $0x1,%eax
f010022b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022f:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100236:	e8 2d 5c 00 00       	call   f0105e68 <spin_lock>
	// exercise 5, lab 4
	lock_kernel();

	// edited by Lethe  
	// exercise 6, lab 4
	sched_yield();
f010023b:	e8 d3 41 00 00       	call   f0104413 <sched_yield>

f0100240 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100240:	55                   	push   %ebp
f0100241:	89 e5                	mov    %esp,%ebp
f0100243:	53                   	push   %ebx
f0100244:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100247:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010024a:	ff 75 0c             	pushl  0xc(%ebp)
f010024d:	ff 75 08             	pushl  0x8(%ebp)
f0100250:	68 49 63 10 f0       	push   $0xf0106349
f0100255:	e8 ac 35 00 00       	call   f0103806 <cprintf>
	vcprintf(fmt, ap);
f010025a:	83 c4 08             	add    $0x8,%esp
f010025d:	53                   	push   %ebx
f010025e:	ff 75 10             	pushl  0x10(%ebp)
f0100261:	e8 7a 35 00 00       	call   f01037e0 <vcprintf>
	cprintf("\n");
f0100266:	c7 04 24 e0 76 10 f0 	movl   $0xf01076e0,(%esp)
f010026d:	e8 94 35 00 00       	call   f0103806 <cprintf>
	va_end(ap);
}
f0100272:	83 c4 10             	add    $0x10,%esp
f0100275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100278:	c9                   	leave  
f0100279:	c3                   	ret    

f010027a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010027a:	55                   	push   %ebp
f010027b:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100282:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100283:	a8 01                	test   $0x1,%al
f0100285:	74 0b                	je     f0100292 <serial_proc_data+0x18>
f0100287:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010028c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028d:	0f b6 c0             	movzbl %al,%eax
f0100290:	eb 05                	jmp    f0100297 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100297:	5d                   	pop    %ebp
f0100298:	c3                   	ret    

f0100299 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100299:	55                   	push   %ebp
f010029a:	89 e5                	mov    %esp,%ebp
f010029c:	53                   	push   %ebx
f010029d:	83 ec 04             	sub    $0x4,%esp
f01002a0:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002a2:	eb 2b                	jmp    f01002cf <cons_intr+0x36>
		if (c == 0)
f01002a4:	85 c0                	test   %eax,%eax
f01002a6:	74 27                	je     f01002cf <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a8:	8b 0d 24 82 20 f0    	mov    0xf0208224,%ecx
f01002ae:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b1:	89 15 24 82 20 f0    	mov    %edx,0xf0208224
f01002b7:	88 81 20 80 20 f0    	mov    %al,-0xfdf7fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c3:	75 0a                	jne    f01002cf <cons_intr+0x36>
			cons.wpos = 0;
f01002c5:	c7 05 24 82 20 f0 00 	movl   $0x0,0xf0208224
f01002cc:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002cf:	ff d3                	call   *%ebx
f01002d1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d4:	75 ce                	jne    f01002a4 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d6:	83 c4 04             	add    $0x4,%esp
f01002d9:	5b                   	pop    %ebx
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <kbd_proc_data>:
f01002dc:	ba 64 00 00 00       	mov    $0x64,%edx
f01002e1:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002e2:	a8 01                	test   $0x1,%al
f01002e4:	0f 84 f0 00 00 00    	je     f01003da <kbd_proc_data+0xfe>
f01002ea:	ba 60 00 00 00       	mov    $0x60,%edx
f01002ef:	ec                   	in     (%dx),%al
f01002f0:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002f2:	3c e0                	cmp    $0xe0,%al
f01002f4:	75 0d                	jne    f0100303 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002f6:	83 0d 00 80 20 f0 40 	orl    $0x40,0xf0208000
		return 0;
f01002fd:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100302:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100303:	55                   	push   %ebp
f0100304:	89 e5                	mov    %esp,%ebp
f0100306:	53                   	push   %ebx
f0100307:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010030a:	84 c0                	test   %al,%al
f010030c:	79 36                	jns    f0100344 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010030e:	8b 0d 00 80 20 f0    	mov    0xf0208000,%ecx
f0100314:	89 cb                	mov    %ecx,%ebx
f0100316:	83 e3 40             	and    $0x40,%ebx
f0100319:	83 e0 7f             	and    $0x7f,%eax
f010031c:	85 db                	test   %ebx,%ebx
f010031e:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100321:	0f b6 d2             	movzbl %dl,%edx
f0100324:	0f b6 82 c0 64 10 f0 	movzbl -0xfef9b40(%edx),%eax
f010032b:	83 c8 40             	or     $0x40,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	f7 d0                	not    %eax
f0100333:	21 c8                	and    %ecx,%eax
f0100335:	a3 00 80 20 f0       	mov    %eax,0xf0208000
		return 0;
f010033a:	b8 00 00 00 00       	mov    $0x0,%eax
f010033f:	e9 9e 00 00 00       	jmp    f01003e2 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100344:	8b 0d 00 80 20 f0    	mov    0xf0208000,%ecx
f010034a:	f6 c1 40             	test   $0x40,%cl
f010034d:	74 0e                	je     f010035d <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010034f:	83 c8 80             	or     $0xffffff80,%eax
f0100352:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100354:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100357:	89 0d 00 80 20 f0    	mov    %ecx,0xf0208000
	}

	shift |= shiftcode[data];
f010035d:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100360:	0f b6 82 c0 64 10 f0 	movzbl -0xfef9b40(%edx),%eax
f0100367:	0b 05 00 80 20 f0    	or     0xf0208000,%eax
f010036d:	0f b6 8a c0 63 10 f0 	movzbl -0xfef9c40(%edx),%ecx
f0100374:	31 c8                	xor    %ecx,%eax
f0100376:	a3 00 80 20 f0       	mov    %eax,0xf0208000

	c = charcode[shift & (CTL | SHIFT)][data];
f010037b:	89 c1                	mov    %eax,%ecx
f010037d:	83 e1 03             	and    $0x3,%ecx
f0100380:	8b 0c 8d a0 63 10 f0 	mov    -0xfef9c60(,%ecx,4),%ecx
f0100387:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010038b:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010038e:	a8 08                	test   $0x8,%al
f0100390:	74 1b                	je     f01003ad <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100392:	89 da                	mov    %ebx,%edx
f0100394:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100397:	83 f9 19             	cmp    $0x19,%ecx
f010039a:	77 05                	ja     f01003a1 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010039c:	83 eb 20             	sub    $0x20,%ebx
f010039f:	eb 0c                	jmp    f01003ad <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003a1:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003a4:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003a7:	83 fa 19             	cmp    $0x19,%edx
f01003aa:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003ad:	f7 d0                	not    %eax
f01003af:	a8 06                	test   $0x6,%al
f01003b1:	75 2d                	jne    f01003e0 <kbd_proc_data+0x104>
f01003b3:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003b9:	75 25                	jne    f01003e0 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003bb:	83 ec 0c             	sub    $0xc,%esp
f01003be:	68 63 63 10 f0       	push   $0xf0106363
f01003c3:	e8 3e 34 00 00       	call   f0103806 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c8:	ba 92 00 00 00       	mov    $0x92,%edx
f01003cd:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d2:	ee                   	out    %al,(%dx)
f01003d3:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d6:	89 d8                	mov    %ebx,%eax
f01003d8:	eb 08                	jmp    f01003e2 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003df:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003e0:	89 d8                	mov    %ebx,%eax
}
f01003e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003e5:	c9                   	leave  
f01003e6:	c3                   	ret    

f01003e7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e7:	55                   	push   %ebp
f01003e8:	89 e5                	mov    %esp,%ebp
f01003ea:	57                   	push   %edi
f01003eb:	56                   	push   %esi
f01003ec:	53                   	push   %ebx
f01003ed:	83 ec 1c             	sub    $0x1c,%esp
f01003f0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003f2:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003fc:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100401:	eb 09                	jmp    f010040c <cons_putc+0x25>
f0100403:	89 ca                	mov    %ecx,%edx
f0100405:	ec                   	in     (%dx),%al
f0100406:	ec                   	in     (%dx),%al
f0100407:	ec                   	in     (%dx),%al
f0100408:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100409:	83 c3 01             	add    $0x1,%ebx
f010040c:	89 f2                	mov    %esi,%edx
f010040e:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040f:	a8 20                	test   $0x20,%al
f0100411:	75 08                	jne    f010041b <cons_putc+0x34>
f0100413:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100419:	7e e8                	jle    f0100403 <cons_putc+0x1c>
f010041b:	89 f8                	mov    %edi,%eax
f010041d:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100420:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100425:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100426:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010042b:	be 79 03 00 00       	mov    $0x379,%esi
f0100430:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100435:	eb 09                	jmp    f0100440 <cons_putc+0x59>
f0100437:	89 ca                	mov    %ecx,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	ec                   	in     (%dx),%al
f010043b:	ec                   	in     (%dx),%al
f010043c:	ec                   	in     (%dx),%al
f010043d:	83 c3 01             	add    $0x1,%ebx
f0100440:	89 f2                	mov    %esi,%edx
f0100442:	ec                   	in     (%dx),%al
f0100443:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100449:	7f 04                	jg     f010044f <cons_putc+0x68>
f010044b:	84 c0                	test   %al,%al
f010044d:	79 e8                	jns    f0100437 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100454:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100458:	ee                   	out    %al,(%dx)
f0100459:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100463:	ee                   	out    %al,(%dx)
f0100464:	b8 08 00 00 00       	mov    $0x8,%eax
f0100469:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010046a:	89 fa                	mov    %edi,%edx
f010046c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100472:	89 f8                	mov    %edi,%eax
f0100474:	80 cc 07             	or     $0x7,%ah
f0100477:	85 d2                	test   %edx,%edx
f0100479:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010047c:	89 f8                	mov    %edi,%eax
f010047e:	0f b6 c0             	movzbl %al,%eax
f0100481:	83 f8 09             	cmp    $0x9,%eax
f0100484:	74 74                	je     f01004fa <cons_putc+0x113>
f0100486:	83 f8 09             	cmp    $0x9,%eax
f0100489:	7f 0a                	jg     f0100495 <cons_putc+0xae>
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	74 14                	je     f01004a4 <cons_putc+0xbd>
f0100490:	e9 99 00 00 00       	jmp    f010052e <cons_putc+0x147>
f0100495:	83 f8 0a             	cmp    $0xa,%eax
f0100498:	74 3a                	je     f01004d4 <cons_putc+0xed>
f010049a:	83 f8 0d             	cmp    $0xd,%eax
f010049d:	74 3d                	je     f01004dc <cons_putc+0xf5>
f010049f:	e9 8a 00 00 00       	jmp    f010052e <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004a4:	0f b7 05 28 82 20 f0 	movzwl 0xf0208228,%eax
f01004ab:	66 85 c0             	test   %ax,%ax
f01004ae:	0f 84 e6 00 00 00    	je     f010059a <cons_putc+0x1b3>
			crt_pos--;
f01004b4:	83 e8 01             	sub    $0x1,%eax
f01004b7:	66 a3 28 82 20 f0    	mov    %ax,0xf0208228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004bd:	0f b7 c0             	movzwl %ax,%eax
f01004c0:	66 81 e7 00 ff       	and    $0xff00,%di
f01004c5:	83 cf 20             	or     $0x20,%edi
f01004c8:	8b 15 2c 82 20 f0    	mov    0xf020822c,%edx
f01004ce:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004d2:	eb 78                	jmp    f010054c <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004d4:	66 83 05 28 82 20 f0 	addw   $0x50,0xf0208228
f01004db:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004dc:	0f b7 05 28 82 20 f0 	movzwl 0xf0208228,%eax
f01004e3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e9:	c1 e8 16             	shr    $0x16,%eax
f01004ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ef:	c1 e0 04             	shl    $0x4,%eax
f01004f2:	66 a3 28 82 20 f0    	mov    %ax,0xf0208228
f01004f8:	eb 52                	jmp    f010054c <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ff:	e8 e3 fe ff ff       	call   f01003e7 <cons_putc>
		cons_putc(' ');
f0100504:	b8 20 00 00 00       	mov    $0x20,%eax
f0100509:	e8 d9 fe ff ff       	call   f01003e7 <cons_putc>
		cons_putc(' ');
f010050e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100513:	e8 cf fe ff ff       	call   f01003e7 <cons_putc>
		cons_putc(' ');
f0100518:	b8 20 00 00 00       	mov    $0x20,%eax
f010051d:	e8 c5 fe ff ff       	call   f01003e7 <cons_putc>
		cons_putc(' ');
f0100522:	b8 20 00 00 00       	mov    $0x20,%eax
f0100527:	e8 bb fe ff ff       	call   f01003e7 <cons_putc>
f010052c:	eb 1e                	jmp    f010054c <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010052e:	0f b7 05 28 82 20 f0 	movzwl 0xf0208228,%eax
f0100535:	8d 50 01             	lea    0x1(%eax),%edx
f0100538:	66 89 15 28 82 20 f0 	mov    %dx,0xf0208228
f010053f:	0f b7 c0             	movzwl %ax,%eax
f0100542:	8b 15 2c 82 20 f0    	mov    0xf020822c,%edx
f0100548:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010054c:	66 81 3d 28 82 20 f0 	cmpw   $0x7cf,0xf0208228
f0100553:	cf 07 
f0100555:	76 43                	jbe    f010059a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100557:	a1 2c 82 20 f0       	mov    0xf020822c,%eax
f010055c:	83 ec 04             	sub    $0x4,%esp
f010055f:	68 00 0f 00 00       	push   $0xf00
f0100564:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010056a:	52                   	push   %edx
f010056b:	50                   	push   %eax
f010056c:	e8 b4 50 00 00       	call   f0105625 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100571:	8b 15 2c 82 20 f0    	mov    0xf020822c,%edx
f0100577:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010057d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100583:	83 c4 10             	add    $0x10,%esp
f0100586:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010058b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010058e:	39 d0                	cmp    %edx,%eax
f0100590:	75 f4                	jne    f0100586 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100592:	66 83 2d 28 82 20 f0 	subw   $0x50,0xf0208228
f0100599:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010059a:	8b 0d 30 82 20 f0    	mov    0xf0208230,%ecx
f01005a0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a5:	89 ca                	mov    %ecx,%edx
f01005a7:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a8:	0f b7 1d 28 82 20 f0 	movzwl 0xf0208228,%ebx
f01005af:	8d 71 01             	lea    0x1(%ecx),%esi
f01005b2:	89 d8                	mov    %ebx,%eax
f01005b4:	66 c1 e8 08          	shr    $0x8,%ax
f01005b8:	89 f2                	mov    %esi,%edx
f01005ba:	ee                   	out    %al,(%dx)
f01005bb:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c0:	89 ca                	mov    %ecx,%edx
f01005c2:	ee                   	out    %al,(%dx)
f01005c3:	89 d8                	mov    %ebx,%eax
f01005c5:	89 f2                	mov    %esi,%edx
f01005c7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005cb:	5b                   	pop    %ebx
f01005cc:	5e                   	pop    %esi
f01005cd:	5f                   	pop    %edi
f01005ce:	5d                   	pop    %ebp
f01005cf:	c3                   	ret    

f01005d0 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005d0:	80 3d 34 82 20 f0 00 	cmpb   $0x0,0xf0208234
f01005d7:	74 11                	je     f01005ea <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d9:	55                   	push   %ebp
f01005da:	89 e5                	mov    %esp,%ebp
f01005dc:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005df:	b8 7a 02 10 f0       	mov    $0xf010027a,%eax
f01005e4:	e8 b0 fc ff ff       	call   f0100299 <cons_intr>
}
f01005e9:	c9                   	leave  
f01005ea:	f3 c3                	repz ret 

f01005ec <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005ec:	55                   	push   %ebp
f01005ed:	89 e5                	mov    %esp,%ebp
f01005ef:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f2:	b8 dc 02 10 f0       	mov    $0xf01002dc,%eax
f01005f7:	e8 9d fc ff ff       	call   f0100299 <cons_intr>
}
f01005fc:	c9                   	leave  
f01005fd:	c3                   	ret    

f01005fe <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005fe:	55                   	push   %ebp
f01005ff:	89 e5                	mov    %esp,%ebp
f0100601:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100604:	e8 c7 ff ff ff       	call   f01005d0 <serial_intr>
	kbd_intr();
f0100609:	e8 de ff ff ff       	call   f01005ec <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010060e:	a1 20 82 20 f0       	mov    0xf0208220,%eax
f0100613:	3b 05 24 82 20 f0    	cmp    0xf0208224,%eax
f0100619:	74 26                	je     f0100641 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010061b:	8d 50 01             	lea    0x1(%eax),%edx
f010061e:	89 15 20 82 20 f0    	mov    %edx,0xf0208220
f0100624:	0f b6 88 20 80 20 f0 	movzbl -0xfdf7fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010062b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010062d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100633:	75 11                	jne    f0100646 <cons_getc+0x48>
			cons.rpos = 0;
f0100635:	c7 05 20 82 20 f0 00 	movl   $0x0,0xf0208220
f010063c:	00 00 00 
f010063f:	eb 05                	jmp    f0100646 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100641:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100646:	c9                   	leave  
f0100647:	c3                   	ret    

f0100648 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100648:	55                   	push   %ebp
f0100649:	89 e5                	mov    %esp,%ebp
f010064b:	57                   	push   %edi
f010064c:	56                   	push   %esi
f010064d:	53                   	push   %ebx
f010064e:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100651:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100658:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065f:	5a a5 
	if (*cp != 0xA55A) {
f0100661:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100668:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066c:	74 11                	je     f010067f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010066e:	c7 05 30 82 20 f0 b4 	movl   $0x3b4,0xf0208230
f0100675:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100678:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010067d:	eb 16                	jmp    f0100695 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010067f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100686:	c7 05 30 82 20 f0 d4 	movl   $0x3d4,0xf0208230
f010068d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100690:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100695:	8b 3d 30 82 20 f0    	mov    0xf0208230,%edi
f010069b:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006a0:	89 fa                	mov    %edi,%edx
f01006a2:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a3:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a6:	89 da                	mov    %ebx,%edx
f01006a8:	ec                   	in     (%dx),%al
f01006a9:	0f b6 c8             	movzbl %al,%ecx
f01006ac:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006af:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b4:	89 fa                	mov    %edi,%edx
f01006b6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b7:	89 da                	mov    %ebx,%edx
f01006b9:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ba:	89 35 2c 82 20 f0    	mov    %esi,0xf020822c
	crt_pos = pos;
f01006c0:	0f b6 c0             	movzbl %al,%eax
f01006c3:	09 c8                	or     %ecx,%eax
f01006c5:	66 a3 28 82 20 f0    	mov    %ax,0xf0208228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006cb:	e8 1c ff ff ff       	call   f01005ec <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006d0:	83 ec 0c             	sub    $0xc,%esp
f01006d3:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006da:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006df:	50                   	push   %eax
f01006e0:	e8 d0 2f 00 00       	call   f01036b5 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e5:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
f01006f2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006f7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100702:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100707:	89 da                	mov    %ebx,%edx
f0100709:	ee                   	out    %al,(%dx)
f010070a:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010070f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100714:	ee                   	out    %al,(%dx)
f0100715:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010071a:	b8 03 00 00 00       	mov    $0x3,%eax
f010071f:	ee                   	out    %al,(%dx)
f0100720:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100725:	b8 00 00 00 00       	mov    $0x0,%eax
f010072a:	ee                   	out    %al,(%dx)
f010072b:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100730:	b8 01 00 00 00       	mov    $0x1,%eax
f0100735:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100736:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010073b:	ec                   	in     (%dx),%al
f010073c:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073e:	83 c4 10             	add    $0x10,%esp
f0100741:	3c ff                	cmp    $0xff,%al
f0100743:	0f 95 05 34 82 20 f0 	setne  0xf0208234
f010074a:	89 f2                	mov    %esi,%edx
f010074c:	ec                   	in     (%dx),%al
f010074d:	89 da                	mov    %ebx,%edx
f010074f:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100750:	80 f9 ff             	cmp    $0xff,%cl
f0100753:	74 21                	je     f0100776 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100755:	83 ec 0c             	sub    $0xc,%esp
f0100758:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010075f:	25 ef ff 00 00       	and    $0xffef,%eax
f0100764:	50                   	push   %eax
f0100765:	e8 4b 2f 00 00       	call   f01036b5 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010076a:	83 c4 10             	add    $0x10,%esp
f010076d:	80 3d 34 82 20 f0 00 	cmpb   $0x0,0xf0208234
f0100774:	75 10                	jne    f0100786 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100776:	83 ec 0c             	sub    $0xc,%esp
f0100779:	68 6f 63 10 f0       	push   $0xf010636f
f010077e:	e8 83 30 00 00       	call   f0103806 <cprintf>
f0100783:	83 c4 10             	add    $0x10,%esp
}
f0100786:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100789:	5b                   	pop    %ebx
f010078a:	5e                   	pop    %esi
f010078b:	5f                   	pop    %edi
f010078c:	5d                   	pop    %ebp
f010078d:	c3                   	ret    

f010078e <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078e:	55                   	push   %ebp
f010078f:	89 e5                	mov    %esp,%ebp
f0100791:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100794:	8b 45 08             	mov    0x8(%ebp),%eax
f0100797:	e8 4b fc ff ff       	call   f01003e7 <cons_putc>
}
f010079c:	c9                   	leave  
f010079d:	c3                   	ret    

f010079e <getchar>:

int
getchar(void)
{
f010079e:	55                   	push   %ebp
f010079f:	89 e5                	mov    %esp,%ebp
f01007a1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a4:	e8 55 fe ff ff       	call   f01005fe <cons_getc>
f01007a9:	85 c0                	test   %eax,%eax
f01007ab:	74 f7                	je     f01007a4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007ad:	c9                   	leave  
f01007ae:	c3                   	ret    

f01007af <iscons>:

int
iscons(int fdnum)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b7:	5d                   	pop    %ebp
f01007b8:	c3                   	ret    

f01007b9 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b9:	55                   	push   %ebp
f01007ba:	89 e5                	mov    %esp,%ebp
f01007bc:	56                   	push   %esi
f01007bd:	53                   	push   %ebx
f01007be:	bb 00 6a 10 f0       	mov    $0xf0106a00,%ebx
f01007c3:	be 30 6a 10 f0       	mov    $0xf0106a30,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c8:	83 ec 04             	sub    $0x4,%esp
f01007cb:	ff 73 04             	pushl  0x4(%ebx)
f01007ce:	ff 33                	pushl  (%ebx)
f01007d0:	68 c0 65 10 f0       	push   $0xf01065c0
f01007d5:	e8 2c 30 00 00       	call   f0103806 <cprintf>
f01007da:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01007dd:	83 c4 10             	add    $0x10,%esp
f01007e0:	39 f3                	cmp    %esi,%ebx
f01007e2:	75 e4                	jne    f01007c8 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ec:	5b                   	pop    %ebx
f01007ed:	5e                   	pop    %esi
f01007ee:	5d                   	pop    %ebp
f01007ef:	c3                   	ret    

f01007f0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f6:	68 c9 65 10 f0       	push   $0xf01065c9
f01007fb:	e8 06 30 00 00       	call   f0103806 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100800:	83 c4 08             	add    $0x8,%esp
f0100803:	68 0c 00 10 00       	push   $0x10000c
f0100808:	68 d8 66 10 f0       	push   $0xf01066d8
f010080d:	e8 f4 2f 00 00       	call   f0103806 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100812:	83 c4 0c             	add    $0xc,%esp
f0100815:	68 0c 00 10 00       	push   $0x10000c
f010081a:	68 0c 00 10 f0       	push   $0xf010000c
f010081f:	68 00 67 10 f0       	push   $0xf0106700
f0100824:	e8 dd 2f 00 00       	call   f0103806 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	68 81 62 10 00       	push   $0x106281
f0100831:	68 81 62 10 f0       	push   $0xf0106281
f0100836:	68 24 67 10 f0       	push   $0xf0106724
f010083b:	e8 c6 2f 00 00       	call   f0103806 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100840:	83 c4 0c             	add    $0xc,%esp
f0100843:	68 d8 7c 20 00       	push   $0x207cd8
f0100848:	68 d8 7c 20 f0       	push   $0xf0207cd8
f010084d:	68 48 67 10 f0       	push   $0xf0106748
f0100852:	e8 af 2f 00 00       	call   f0103806 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100857:	83 c4 0c             	add    $0xc,%esp
f010085a:	68 08 a0 24 00       	push   $0x24a008
f010085f:	68 08 a0 24 f0       	push   $0xf024a008
f0100864:	68 6c 67 10 f0       	push   $0xf010676c
f0100869:	e8 98 2f 00 00       	call   f0103806 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010086e:	b8 07 a4 24 f0       	mov    $0xf024a407,%eax
f0100873:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100878:	83 c4 08             	add    $0x8,%esp
f010087b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100880:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100886:	85 c0                	test   %eax,%eax
f0100888:	0f 48 c2             	cmovs  %edx,%eax
f010088b:	c1 f8 0a             	sar    $0xa,%eax
f010088e:	50                   	push   %eax
f010088f:	68 90 67 10 f0       	push   $0xf0106790
f0100894:	e8 6d 2f 00 00       	call   f0103806 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100899:	b8 00 00 00 00       	mov    $0x0,%eax
f010089e:	c9                   	leave  
f010089f:	c3                   	ret    

f01008a0 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a0:	55                   	push   %ebp
f01008a1:	89 e5                	mov    %esp,%ebp
f01008a3:	57                   	push   %edi
f01008a4:	56                   	push   %esi
f01008a5:	53                   	push   %ebx
f01008a6:	83 ec 38             	sub    $0x38,%esp
	// Your code here.
	//added by Lethe
	cprintf("Stack backtrace:\n");
f01008a9:	68 e2 65 10 f0       	push   $0xf01065e2
f01008ae:	e8 53 2f 00 00       	call   f0103806 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b3:	89 eb                	mov    %ebp,%ebx
f01008b5:	89 d8                	mov    %ebx,%eax
	uint32_t ebp,eip,*p;
	ebp=read_ebp();
	p=(uint32_t*)ebp;
f01008b7:	83 c4 10             	add    $0x10,%esp
	do{
		eip=*(p+1);
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,eip,*(p+2),*(p+3),*(p+4),*(p+5),*(p+6));
		struct Eipdebuginfo  info;
		debuginfo_eip(eip,&info);
f01008ba:	8d 7d d0             	lea    -0x30(%ebp),%edi
	cprintf("Stack backtrace:\n");
	uint32_t ebp,eip,*p;
	ebp=read_ebp();
	p=(uint32_t*)ebp;
	do{
		eip=*(p+1);
f01008bd:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,eip,*(p+2),*(p+3),*(p+4),*(p+5),*(p+6));
f01008c0:	ff 73 18             	pushl  0x18(%ebx)
f01008c3:	ff 73 14             	pushl  0x14(%ebx)
f01008c6:	ff 73 10             	pushl  0x10(%ebx)
f01008c9:	ff 73 0c             	pushl  0xc(%ebx)
f01008cc:	ff 73 08             	pushl  0x8(%ebx)
f01008cf:	56                   	push   %esi
f01008d0:	50                   	push   %eax
f01008d1:	68 bc 67 10 f0       	push   $0xf01067bc
f01008d6:	e8 2b 2f 00 00       	call   f0103806 <cprintf>
		struct Eipdebuginfo  info;
		debuginfo_eip(eip,&info);
f01008db:	83 c4 18             	add    $0x18,%esp
f01008de:	57                   	push   %edi
f01008df:	56                   	push   %esi
f01008e0:	e8 69 42 00 00       	call   f0104b4e <debuginfo_eip>
		cprintf ("\t%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,eip-info.eip_fn_addr);
f01008e5:	83 c4 08             	add    $0x8,%esp
f01008e8:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01008eb:	56                   	push   %esi
f01008ec:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ef:	ff 75 dc             	pushl  -0x24(%ebp)
f01008f2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008f5:	ff 75 d0             	pushl  -0x30(%ebp)
f01008f8:	68 f4 65 10 f0       	push   $0xf01065f4
f01008fd:	e8 04 2f 00 00       	call   f0103806 <cprintf>
		ebp=*p;
f0100902:	8b 03                	mov    (%ebx),%eax
		p=(uint32_t*)ebp;
f0100904:	89 c3                	mov    %eax,%ebx
	}while(ebp);
f0100906:	83 c4 20             	add    $0x20,%esp
f0100909:	85 c0                	test   %eax,%eax
f010090b:	75 b0                	jne    f01008bd <mon_backtrace+0x1d>

	return 0;
}
f010090d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100910:	5b                   	pop    %ebx
f0100911:	5e                   	pop    %esi
f0100912:	5f                   	pop    %edi
f0100913:	5d                   	pop    %ebp
f0100914:	c3                   	ret    

f0100915 <mon_showmappings>:

//edit by Lethe 2018/10/31
int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100915:	55                   	push   %ebp
f0100916:	89 e5                	mov    %esp,%ebp
f0100918:	57                   	push   %edi
f0100919:	56                   	push   %esi
f010091a:	53                   	push   %ebx
f010091b:	83 ec 1c             	sub    $0x1c,%esp
f010091e:	8b 75 0c             	mov    0xc(%ebp),%esi
    // 参数检查
    if (argc != 3) {
f0100921:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100925:	74 1a                	je     f0100941 <mon_showmappings+0x2c>
        cprintf("Requir 2 virtual address as arguments.\n");
f0100927:	83 ec 0c             	sub    $0xc,%esp
f010092a:	68 f0 67 10 f0       	push   $0xf01067f0
f010092f:	e8 d2 2e 00 00       	call   f0103806 <cprintf>
        return -1;
f0100934:	83 c4 10             	add    $0x10,%esp
f0100937:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010093c:	e9 52 01 00 00       	jmp    f0100a93 <mon_showmappings+0x17e>
    }
    char *errChar;
    uintptr_t start_addr = strtol(argv[1], &errChar, 16);
f0100941:	83 ec 04             	sub    $0x4,%esp
f0100944:	6a 10                	push   $0x10
f0100946:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100949:	50                   	push   %eax
f010094a:	ff 76 04             	pushl  0x4(%esi)
f010094d:	e8 aa 4d 00 00       	call   f01056fc <strtol>
f0100952:	89 c3                	mov    %eax,%ebx
    if (*errChar) {
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010095a:	80 38 00             	cmpb   $0x0,(%eax)
f010095d:	74 1d                	je     f010097c <mon_showmappings+0x67>
        cprintf("Invalid virtual address: %s.\n", argv[1]);
f010095f:	83 ec 08             	sub    $0x8,%esp
f0100962:	ff 76 04             	pushl  0x4(%esi)
f0100965:	68 05 66 10 f0       	push   $0xf0106605
f010096a:	e8 97 2e 00 00       	call   f0103806 <cprintf>
        return -1;
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100977:	e9 17 01 00 00       	jmp    f0100a93 <mon_showmappings+0x17e>
    }
    uintptr_t end_addr = strtol(argv[2], &errChar, 16);
f010097c:	83 ec 04             	sub    $0x4,%esp
f010097f:	6a 10                	push   $0x10
f0100981:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100984:	50                   	push   %eax
f0100985:	ff 76 08             	pushl  0x8(%esi)
f0100988:	e8 6f 4d 00 00       	call   f01056fc <strtol>
    if (*errChar) {
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100993:	80 3a 00             	cmpb   $0x0,(%edx)
f0100996:	74 1d                	je     f01009b5 <mon_showmappings+0xa0>
        cprintf("Invalid virtual address: %s.\n", argv[2]);
f0100998:	83 ec 08             	sub    $0x8,%esp
f010099b:	ff 76 08             	pushl  0x8(%esi)
f010099e:	68 05 66 10 f0       	push   $0xf0106605
f01009a3:	e8 5e 2e 00 00       	call   f0103806 <cprintf>
        return -1;
f01009a8:	83 c4 10             	add    $0x10,%esp
f01009ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009b0:	e9 de 00 00 00       	jmp    f0100a93 <mon_showmappings+0x17e>
    }
    if (start_addr > end_addr) {
f01009b5:	39 c3                	cmp    %eax,%ebx
f01009b7:	76 1a                	jbe    f01009d3 <mon_showmappings+0xbe>
        cprintf("Address 1 must be lower than address 2\n");
f01009b9:	83 ec 0c             	sub    $0xc,%esp
f01009bc:	68 18 68 10 f0       	push   $0xf0106818
f01009c1:	e8 40 2e 00 00       	call   f0103806 <cprintf>
        return -1;
f01009c6:	83 c4 10             	add    $0x10,%esp
f01009c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009ce:	e9 c0 00 00 00       	jmp    f0100a93 <mon_showmappings+0x17e>
    }
    
    // 按页对齐
    start_addr = ROUNDDOWN(start_addr, PGSIZE);
f01009d3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    end_addr = ROUNDUP(end_addr, PGSIZE);
f01009d9:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009df:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

    // 开始循环
    uintptr_t cur_addr = start_addr;
    while (cur_addr <= end_addr) {
f01009e5:	e9 9c 00 00 00       	jmp    f0100a86 <mon_showmappings+0x171>
        pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
f01009ea:	83 ec 04             	sub    $0x4,%esp
f01009ed:	6a 00                	push   $0x0
f01009ef:	53                   	push   %ebx
f01009f0:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f01009f6:	e8 ae 07 00 00       	call   f01011a9 <pgdir_walk>
f01009fb:	89 c6                	mov    %eax,%esi
        // 记录自己一个错误
        // if ( !cur_pte) {
        if ( !cur_pte || !(*cur_pte & PTE_P)) {
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	74 06                	je     f0100a0a <mon_showmappings+0xf5>
f0100a04:	8b 00                	mov    (%eax),%eax
f0100a06:	a8 01                	test   $0x1,%al
f0100a08:	75 13                	jne    f0100a1d <mon_showmappings+0x108>
            cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
f0100a0a:	83 ec 08             	sub    $0x8,%esp
f0100a0d:	53                   	push   %ebx
f0100a0e:	68 40 68 10 f0       	push   $0xf0106840
f0100a13:	e8 ee 2d 00 00       	call   f0103806 <cprintf>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	eb 63                	jmp    f0100a80 <mon_showmappings+0x16b>
        } else {
            cprintf( "Virtual address [%08x] - physical address [%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
f0100a1d:	83 ec 04             	sub    $0x4,%esp
f0100a20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a25:	50                   	push   %eax
f0100a26:	53                   	push   %ebx
f0100a27:	68 68 68 10 f0       	push   $0xf0106868
f0100a2c:	e8 d5 2d 00 00       	call   f0103806 <cprintf>
            char perm_PS = (*cur_pte & PTE_PS) ? 'S':'-';
f0100a31:	8b 06                	mov    (%esi),%eax
f0100a33:	83 c4 10             	add    $0x10,%esp
f0100a36:	89 c2                	mov    %eax,%edx
f0100a38:	81 e2 80 00 00 00    	and    $0x80,%edx
f0100a3e:	83 fa 01             	cmp    $0x1,%edx
f0100a41:	19 d2                	sbb    %edx,%edx
f0100a43:	83 e2 da             	and    $0xffffffda,%edx
f0100a46:	83 c2 53             	add    $0x53,%edx
            char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
f0100a49:	89 c1                	mov    %eax,%ecx
f0100a4b:	83 e1 02             	and    $0x2,%ecx
f0100a4e:	83 f9 01             	cmp    $0x1,%ecx
f0100a51:	19 c9                	sbb    %ecx,%ecx
f0100a53:	83 e1 d6             	and    $0xffffffd6,%ecx
f0100a56:	83 c1 57             	add    $0x57,%ecx
            char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
f0100a59:	83 e0 04             	and    $0x4,%eax
f0100a5c:	83 f8 01             	cmp    $0x1,%eax
f0100a5f:	19 c0                	sbb    %eax,%eax
f0100a61:	83 e0 d8             	and    $0xffffffd8,%eax
f0100a64:	83 c0 55             	add    $0x55,%eax
            // 进入 else 分支说明 PTE_P 肯定为真了
            cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
f0100a67:	0f be c9             	movsbl %cl,%ecx
f0100a6a:	51                   	push   %ecx
f0100a6b:	0f be c0             	movsbl %al,%eax
f0100a6e:	50                   	push   %eax
f0100a6f:	0f be d2             	movsbl %dl,%edx
f0100a72:	52                   	push   %edx
f0100a73:	68 23 66 10 f0       	push   $0xf0106623
f0100a78:	e8 89 2d 00 00       	call   f0103806 <cprintf>
f0100a7d:	83 c4 10             	add    $0x10,%esp
        }
        cur_addr += PGSIZE;
f0100a80:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    start_addr = ROUNDDOWN(start_addr, PGSIZE);
    end_addr = ROUNDUP(end_addr, PGSIZE);

    // 开始循环
    uintptr_t cur_addr = start_addr;
    while (cur_addr <= end_addr) {
f0100a86:	39 fb                	cmp    %edi,%ebx
f0100a88:	0f 86 5c ff ff ff    	jbe    f01009ea <mon_showmappings+0xd5>
            // 进入 else 分支说明 PTE_P 肯定为真了
            cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
        }
        cur_addr += PGSIZE;
    }
    return 0;
f0100a8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a96:	5b                   	pop    %ebx
f0100a97:	5e                   	pop    %esi
f0100a98:	5f                   	pop    %edi
f0100a99:	5d                   	pop    %ebp
f0100a9a:	c3                   	ret    

f0100a9b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a9b:	55                   	push   %ebp
f0100a9c:	89 e5                	mov    %esp,%ebp
f0100a9e:	57                   	push   %edi
f0100a9f:	56                   	push   %esi
f0100aa0:	53                   	push   %ebx
f0100aa1:	83 ec 68             	sub    $0x68,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100aa4:	68 a8 68 10 f0       	push   $0xf01068a8
f0100aa9:	e8 58 2d 00 00       	call   f0103806 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100aae:	c7 04 24 cc 68 10 f0 	movl   $0xf01068cc,(%esp)
f0100ab5:	e8 4c 2d 00 00       	call   f0103806 <cprintf>
	int x = 1, y = 3, z = 4;

	cprintf("x %d, y %x, z %d\n", x, y, z);
f0100aba:	6a 04                	push   $0x4
f0100abc:	6a 03                	push   $0x3
f0100abe:	6a 01                	push   $0x1
f0100ac0:	68 31 66 10 f0       	push   $0xf0106631
f0100ac5:	e8 3c 2d 00 00       	call   f0103806 <cprintf>
	
	unsigned int i = 0x00646c72;
f0100aca:	c7 45 e4 72 6c 64 00 	movl   $0x646c72,-0x1c(%ebp)

	cprintf("H%x Wo%s", 57616, &i);
f0100ad1:	83 c4 1c             	add    $0x1c,%esp
f0100ad4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100ad7:	50                   	push   %eax
f0100ad8:	68 10 e1 00 00       	push   $0xe110
f0100add:	68 43 66 10 f0       	push   $0xf0106643
f0100ae2:	e8 1f 2d 00 00       	call   f0103806 <cprintf>
	

	cprintf("x=%d y=%d\n", 3);
f0100ae7:	83 c4 08             	add    $0x8,%esp
f0100aea:	6a 03                	push   $0x3
f0100aec:	68 4c 66 10 f0       	push   $0xf010664c
f0100af1:	e8 10 2d 00 00       	call   f0103806 <cprintf>
	cprintf("%ared求求操作系统对我好点吧！\n");
	cprintf("%apur求求操作系统对我好点吧！\n");
	cprintf("%aorg求求操作系统对我好点吧！\n");*/


	if (tf != NULL)
f0100af6:	83 c4 10             	add    $0x10,%esp
f0100af9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100afd:	74 0e                	je     f0100b0d <monitor+0x72>
		print_trapframe(tf);
f0100aff:	83 ec 0c             	sub    $0xc,%esp
f0100b02:	ff 75 08             	pushl  0x8(%ebp)
f0100b05:	e8 9d 32 00 00       	call   f0103da7 <print_trapframe>
f0100b0a:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100b0d:	83 ec 0c             	sub    $0xc,%esp
f0100b10:	68 57 66 10 f0       	push   $0xf0106657
f0100b15:	e8 4f 48 00 00       	call   f0105369 <readline>
f0100b1a:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b1c:	83 c4 10             	add    $0x10,%esp
f0100b1f:	85 c0                	test   %eax,%eax
f0100b21:	74 ea                	je     f0100b0d <monitor+0x72>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b23:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b2a:	be 00 00 00 00       	mov    $0x0,%esi
f0100b2f:	eb 0a                	jmp    f0100b3b <monitor+0xa0>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b31:	c6 03 00             	movb   $0x0,(%ebx)
f0100b34:	89 f7                	mov    %esi,%edi
f0100b36:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b39:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b3b:	0f b6 03             	movzbl (%ebx),%eax
f0100b3e:	84 c0                	test   %al,%al
f0100b40:	74 63                	je     f0100ba5 <monitor+0x10a>
f0100b42:	83 ec 08             	sub    $0x8,%esp
f0100b45:	0f be c0             	movsbl %al,%eax
f0100b48:	50                   	push   %eax
f0100b49:	68 5b 66 10 f0       	push   $0xf010665b
f0100b4e:	e8 48 4a 00 00       	call   f010559b <strchr>
f0100b53:	83 c4 10             	add    $0x10,%esp
f0100b56:	85 c0                	test   %eax,%eax
f0100b58:	75 d7                	jne    f0100b31 <monitor+0x96>
			*buf++ = 0;
		if (*buf == 0)
f0100b5a:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b5d:	74 46                	je     f0100ba5 <monitor+0x10a>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b5f:	83 fe 0f             	cmp    $0xf,%esi
f0100b62:	75 14                	jne    f0100b78 <monitor+0xdd>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b64:	83 ec 08             	sub    $0x8,%esp
f0100b67:	6a 10                	push   $0x10
f0100b69:	68 60 66 10 f0       	push   $0xf0106660
f0100b6e:	e8 93 2c 00 00       	call   f0103806 <cprintf>
f0100b73:	83 c4 10             	add    $0x10,%esp
f0100b76:	eb 95                	jmp    f0100b0d <monitor+0x72>
			return 0;
		}
		argv[argc++] = buf;
f0100b78:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b7b:	89 5c b5 a4          	mov    %ebx,-0x5c(%ebp,%esi,4)
f0100b7f:	eb 03                	jmp    f0100b84 <monitor+0xe9>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b81:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b84:	0f b6 03             	movzbl (%ebx),%eax
f0100b87:	84 c0                	test   %al,%al
f0100b89:	74 ae                	je     f0100b39 <monitor+0x9e>
f0100b8b:	83 ec 08             	sub    $0x8,%esp
f0100b8e:	0f be c0             	movsbl %al,%eax
f0100b91:	50                   	push   %eax
f0100b92:	68 5b 66 10 f0       	push   $0xf010665b
f0100b97:	e8 ff 49 00 00       	call   f010559b <strchr>
f0100b9c:	83 c4 10             	add    $0x10,%esp
f0100b9f:	85 c0                	test   %eax,%eax
f0100ba1:	74 de                	je     f0100b81 <monitor+0xe6>
f0100ba3:	eb 94                	jmp    f0100b39 <monitor+0x9e>
			buf++;
	}
	argv[argc] = 0;
f0100ba5:	c7 44 b5 a4 00 00 00 	movl   $0x0,-0x5c(%ebp,%esi,4)
f0100bac:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100bad:	85 f6                	test   %esi,%esi
f0100baf:	0f 84 58 ff ff ff    	je     f0100b0d <monitor+0x72>
f0100bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100bba:	83 ec 08             	sub    $0x8,%esp
f0100bbd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bc0:	ff 34 85 00 6a 10 f0 	pushl  -0xfef9600(,%eax,4)
f0100bc7:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100bca:	e8 6e 49 00 00       	call   f010553d <strcmp>
f0100bcf:	83 c4 10             	add    $0x10,%esp
f0100bd2:	85 c0                	test   %eax,%eax
f0100bd4:	75 21                	jne    f0100bf7 <monitor+0x15c>
			return commands[i].func(argc, argv, tf);
f0100bd6:	83 ec 04             	sub    $0x4,%esp
f0100bd9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bdc:	ff 75 08             	pushl  0x8(%ebp)
f0100bdf:	8d 55 a4             	lea    -0x5c(%ebp),%edx
f0100be2:	52                   	push   %edx
f0100be3:	56                   	push   %esi
f0100be4:	ff 14 85 08 6a 10 f0 	call   *-0xfef95f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100beb:	83 c4 10             	add    $0x10,%esp
f0100bee:	85 c0                	test   %eax,%eax
f0100bf0:	78 25                	js     f0100c17 <monitor+0x17c>
f0100bf2:	e9 16 ff ff ff       	jmp    f0100b0d <monitor+0x72>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100bf7:	83 c3 01             	add    $0x1,%ebx
f0100bfa:	83 fb 04             	cmp    $0x4,%ebx
f0100bfd:	75 bb                	jne    f0100bba <monitor+0x11f>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100bff:	83 ec 08             	sub    $0x8,%esp
f0100c02:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100c05:	68 7d 66 10 f0       	push   $0xf010667d
f0100c0a:	e8 f7 2b 00 00       	call   f0103806 <cprintf>
f0100c0f:	83 c4 10             	add    $0x10,%esp
f0100c12:	e9 f6 fe ff ff       	jmp    f0100b0d <monitor+0x72>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c1a:	5b                   	pop    %ebx
f0100c1b:	5e                   	pop    %esi
f0100c1c:	5f                   	pop    %edi
f0100c1d:	5d                   	pop    %ebp
f0100c1e:	c3                   	ret    

f0100c1f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c1f:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c21:	83 3d 38 82 20 f0 00 	cmpl   $0x0,0xf0208238
f0100c28:	75 0f                	jne    f0100c39 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c2a:	b8 07 b0 24 f0       	mov    $0xf024b007,%eax
f0100c2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c34:	a3 38 82 20 f0       	mov    %eax,0xf0208238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	// edited by Lethe 
	result=nextfree;
f0100c39:	a1 38 82 20 f0       	mov    0xf0208238,%eax
	if(n==0){
f0100c3e:	85 d2                	test   %edx,%edx
f0100c40:	74 3e                	je     f0100c80 <boot_alloc+0x61>
	}else{
		//if n>0, allocates enough pages of contiguous physical memory
		//change the value of nextfree(in fact its value is an address)

		//call ROUNDUP to ensure nextfree is kept aligned
		nextfree=ROUNDUP(nextfree+n,PGSIZE);
f0100c42:	8d 8c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ecx
f0100c49:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100c4f:	89 0d 38 82 20 f0    	mov    %ecx,0xf0208238
		if((uint32_t)nextfree+n-KERNBASE>(npages*PGSIZE)){
f0100c55:	8d 8c 11 00 00 00 10 	lea    0x10000000(%ecx,%edx,1),%ecx
f0100c5c:	8b 15 88 8e 20 f0    	mov    0xf0208e88,%edx
f0100c62:	c1 e2 0c             	shl    $0xc,%edx
f0100c65:	39 d1                	cmp    %edx,%ecx
f0100c67:	76 17                	jbe    f0100c80 <boot_alloc+0x61>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c69:	55                   	push   %ebp
f0100c6a:	89 e5                	mov    %esp,%ebp
f0100c6c:	83 ec 0c             	sub    $0xc,%esp

		//call ROUNDUP to ensure nextfree is kept aligned
		nextfree=ROUNDUP(nextfree+n,PGSIZE);
		if((uint32_t)nextfree+n-KERNBASE>(npages*PGSIZE)){
			//if out of memory, panic!
			panic("Out of memory!");}
f0100c6f:	68 30 6a 10 f0       	push   $0xf0106a30
f0100c74:	6a 75                	push   $0x75
f0100c76:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100c7b:	e8 c0 f3 ff ff       	call   f0100040 <_panic>
	//take advantage of this feature, when we call this function the first time, 
	//the value of nextfree is 0, then it will "points" to the end of the kernel's 
	//bss segment
	//2.ROUNDUP is definited in types.h, i have a question that whether nextfree equals
	//to ROUNDUP(nextfree+0,PGSIZE)
}
f0100c80:	f3 c3                	repz ret 

f0100c82 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100c82:	89 d1                	mov    %edx,%ecx
f0100c84:	c1 e9 16             	shr    $0x16,%ecx
f0100c87:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c8a:	a8 01                	test   $0x1,%al
f0100c8c:	74 52                	je     f0100ce0 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c93:	89 c1                	mov    %eax,%ecx
f0100c95:	c1 e9 0c             	shr    $0xc,%ecx
f0100c98:	3b 0d 88 8e 20 f0    	cmp    0xf0208e88,%ecx
f0100c9e:	72 1b                	jb     f0100cbb <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ca0:	55                   	push   %ebp
f0100ca1:	89 e5                	mov    %esp,%ebp
f0100ca3:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca6:	50                   	push   %eax
f0100ca7:	68 c4 62 10 f0       	push   $0xf01062c4
f0100cac:	68 12 04 00 00       	push   $0x412
f0100cb1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100cb6:	e8 85 f3 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100cbb:	c1 ea 0c             	shr    $0xc,%edx
f0100cbe:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100cc4:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ccb:	89 c2                	mov    %eax,%edx
f0100ccd:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100cd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cd5:	85 d2                	test   %edx,%edx
f0100cd7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100cdc:	0f 44 c2             	cmove  %edx,%eax
f0100cdf:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ce0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ce5:	c3                   	ret    

f0100ce6 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ce6:	55                   	push   %ebp
f0100ce7:	89 e5                	mov    %esp,%ebp
f0100ce9:	57                   	push   %edi
f0100cea:	56                   	push   %esi
f0100ceb:	53                   	push   %ebx
f0100cec:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cef:	84 c0                	test   %al,%al
f0100cf1:	0f 85 91 02 00 00    	jne    f0100f88 <check_page_free_list+0x2a2>
f0100cf7:	e9 9e 02 00 00       	jmp    f0100f9a <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100cfc:	83 ec 04             	sub    $0x4,%esp
f0100cff:	68 64 6d 10 f0       	push   $0xf0106d64
f0100d04:	68 47 03 00 00       	push   $0x347
f0100d09:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100d0e:	e8 2d f3 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100d13:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100d16:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100d19:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100d1f:	89 c2                	mov    %eax,%edx
f0100d21:	2b 15 90 8e 20 f0    	sub    0xf0208e90,%edx
f0100d27:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100d2d:	0f 95 c2             	setne  %dl
f0100d30:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100d33:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100d37:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100d39:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d3d:	8b 00                	mov    (%eax),%eax
f0100d3f:	85 c0                	test   %eax,%eax
f0100d41:	75 dc                	jne    f0100d1f <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100d4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d52:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100d54:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d57:	a3 40 82 20 f0       	mov    %eax,0xf0208240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d5c:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d61:	8b 1d 40 82 20 f0    	mov    0xf0208240,%ebx
f0100d67:	eb 53                	jmp    f0100dbc <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d69:	89 d8                	mov    %ebx,%eax
f0100d6b:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0100d71:	c1 f8 03             	sar    $0x3,%eax
f0100d74:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d77:	89 c2                	mov    %eax,%edx
f0100d79:	c1 ea 16             	shr    $0x16,%edx
f0100d7c:	39 f2                	cmp    %esi,%edx
f0100d7e:	73 3a                	jae    f0100dba <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d80:	89 c2                	mov    %eax,%edx
f0100d82:	c1 ea 0c             	shr    $0xc,%edx
f0100d85:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0100d8b:	72 12                	jb     f0100d9f <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d8d:	50                   	push   %eax
f0100d8e:	68 c4 62 10 f0       	push   $0xf01062c4
f0100d93:	6a 58                	push   $0x58
f0100d95:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0100d9a:	e8 a1 f2 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d9f:	83 ec 04             	sub    $0x4,%esp
f0100da2:	68 80 00 00 00       	push   $0x80
f0100da7:	68 97 00 00 00       	push   $0x97
f0100dac:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100db1:	50                   	push   %eax
f0100db2:	e8 21 48 00 00       	call   f01055d8 <memset>
f0100db7:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100dba:	8b 1b                	mov    (%ebx),%ebx
f0100dbc:	85 db                	test   %ebx,%ebx
f0100dbe:	75 a9                	jne    f0100d69 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100dc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc5:	e8 55 fe ff ff       	call   f0100c1f <boot_alloc>
f0100dca:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dcd:	8b 15 40 82 20 f0    	mov    0xf0208240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100dd3:	8b 0d 90 8e 20 f0    	mov    0xf0208e90,%ecx
		assert(pp < pages + npages);
f0100dd9:	a1 88 8e 20 f0       	mov    0xf0208e88,%eax
f0100dde:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100de1:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100de4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100de7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100dea:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100def:	e9 52 01 00 00       	jmp    f0100f46 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100df4:	39 ca                	cmp    %ecx,%edx
f0100df6:	73 19                	jae    f0100e11 <check_page_free_list+0x12b>
f0100df8:	68 59 6a 10 f0       	push   $0xf0106a59
f0100dfd:	68 65 6a 10 f0       	push   $0xf0106a65
f0100e02:	68 61 03 00 00       	push   $0x361
f0100e07:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100e0c:	e8 2f f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100e11:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100e14:	72 19                	jb     f0100e2f <check_page_free_list+0x149>
f0100e16:	68 7a 6a 10 f0       	push   $0xf0106a7a
f0100e1b:	68 65 6a 10 f0       	push   $0xf0106a65
f0100e20:	68 62 03 00 00       	push   $0x362
f0100e25:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100e2a:	e8 11 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e2f:	89 d0                	mov    %edx,%eax
f0100e31:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100e34:	a8 07                	test   $0x7,%al
f0100e36:	74 19                	je     f0100e51 <check_page_free_list+0x16b>
f0100e38:	68 88 6d 10 f0       	push   $0xf0106d88
f0100e3d:	68 65 6a 10 f0       	push   $0xf0106a65
f0100e42:	68 63 03 00 00       	push   $0x363
f0100e47:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100e4c:	e8 ef f1 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e51:	c1 f8 03             	sar    $0x3,%eax
f0100e54:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100e57:	85 c0                	test   %eax,%eax
f0100e59:	75 19                	jne    f0100e74 <check_page_free_list+0x18e>
f0100e5b:	68 8e 6a 10 f0       	push   $0xf0106a8e
f0100e60:	68 65 6a 10 f0       	push   $0xf0106a65
f0100e65:	68 66 03 00 00       	push   $0x366
f0100e6a:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100e6f:	e8 cc f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e74:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e79:	75 19                	jne    f0100e94 <check_page_free_list+0x1ae>
f0100e7b:	68 9f 6a 10 f0       	push   $0xf0106a9f
f0100e80:	68 65 6a 10 f0       	push   $0xf0106a65
f0100e85:	68 67 03 00 00       	push   $0x367
f0100e8a:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100e8f:	e8 ac f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e94:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e99:	75 19                	jne    f0100eb4 <check_page_free_list+0x1ce>
f0100e9b:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0100ea0:	68 65 6a 10 f0       	push   $0xf0106a65
f0100ea5:	68 68 03 00 00       	push   $0x368
f0100eaa:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100eaf:	e8 8c f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100eb4:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100eb9:	75 19                	jne    f0100ed4 <check_page_free_list+0x1ee>
f0100ebb:	68 b8 6a 10 f0       	push   $0xf0106ab8
f0100ec0:	68 65 6a 10 f0       	push   $0xf0106a65
f0100ec5:	68 69 03 00 00       	push   $0x369
f0100eca:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100ecf:	e8 6c f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ed4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ed9:	0f 86 de 00 00 00    	jbe    f0100fbd <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100edf:	89 c7                	mov    %eax,%edi
f0100ee1:	c1 ef 0c             	shr    $0xc,%edi
f0100ee4:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100ee7:	77 12                	ja     f0100efb <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee9:	50                   	push   %eax
f0100eea:	68 c4 62 10 f0       	push   $0xf01062c4
f0100eef:	6a 58                	push   $0x58
f0100ef1:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0100ef6:	e8 45 f1 ff ff       	call   f0100040 <_panic>
f0100efb:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100f01:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100f04:	0f 86 a7 00 00 00    	jbe    f0100fb1 <check_page_free_list+0x2cb>
f0100f0a:	68 e0 6d 10 f0       	push   $0xf0106de0
f0100f0f:	68 65 6a 10 f0       	push   $0xf0106a65
f0100f14:	68 6a 03 00 00       	push   $0x36a
f0100f19:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100f1e:	e8 1d f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f23:	68 d2 6a 10 f0       	push   $0xf0106ad2
f0100f28:	68 65 6a 10 f0       	push   $0xf0106a65
f0100f2d:	68 6c 03 00 00       	push   $0x36c
f0100f32:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100f37:	e8 04 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100f3c:	83 c6 01             	add    $0x1,%esi
f0100f3f:	eb 03                	jmp    f0100f44 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100f41:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f44:	8b 12                	mov    (%edx),%edx
f0100f46:	85 d2                	test   %edx,%edx
f0100f48:	0f 85 a6 fe ff ff    	jne    f0100df4 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f4e:	85 f6                	test   %esi,%esi
f0100f50:	7f 19                	jg     f0100f6b <check_page_free_list+0x285>
f0100f52:	68 ef 6a 10 f0       	push   $0xf0106aef
f0100f57:	68 65 6a 10 f0       	push   $0xf0106a65
f0100f5c:	68 74 03 00 00       	push   $0x374
f0100f61:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100f66:	e8 d5 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f6b:	85 db                	test   %ebx,%ebx
f0100f6d:	7f 5e                	jg     f0100fcd <check_page_free_list+0x2e7>
f0100f6f:	68 01 6b 10 f0       	push   $0xf0106b01
f0100f74:	68 65 6a 10 f0       	push   $0xf0106a65
f0100f79:	68 75 03 00 00       	push   $0x375
f0100f7e:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0100f83:	e8 b8 f0 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f88:	a1 40 82 20 f0       	mov    0xf0208240,%eax
f0100f8d:	85 c0                	test   %eax,%eax
f0100f8f:	0f 85 7e fd ff ff    	jne    f0100d13 <check_page_free_list+0x2d>
f0100f95:	e9 62 fd ff ff       	jmp    f0100cfc <check_page_free_list+0x16>
f0100f9a:	83 3d 40 82 20 f0 00 	cmpl   $0x0,0xf0208240
f0100fa1:	0f 84 55 fd ff ff    	je     f0100cfc <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fa7:	be 00 04 00 00       	mov    $0x400,%esi
f0100fac:	e9 b0 fd ff ff       	jmp    f0100d61 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100fb1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fb6:	75 89                	jne    f0100f41 <check_page_free_list+0x25b>
f0100fb8:	e9 66 ff ff ff       	jmp    f0100f23 <check_page_free_list+0x23d>
f0100fbd:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fc2:	0f 85 74 ff ff ff    	jne    f0100f3c <check_page_free_list+0x256>
f0100fc8:	e9 56 ff ff ff       	jmp    f0100f23 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fd0:	5b                   	pop    %ebx
f0100fd1:	5e                   	pop    %esi
f0100fd2:	5f                   	pop    %edi
f0100fd3:	5d                   	pop    %ebp
f0100fd4:	c3                   	ret    

f0100fd5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fd5:	55                   	push   %ebp
f0100fd6:	89 e5                	mov    %esp,%ebp
f0100fd8:	56                   	push   %esi
f0100fd9:	53                   	push   %ebx
	// Physical address of startup code for non-boot CPUs (APs)
	// #define MPENTRY_PADDR	0x7000

	size_t i;
	size_t mp_page = MPENTRY_PADDR / PGSIZE;
	for (i = 0; i < npages; i++) {
f0100fda:	be 00 00 00 00       	mov    $0x0,%esi
f0100fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100fe4:	e9 de 00 00 00       	jmp    f01010c7 <page_init+0xf2>
		if(i==0){
f0100fe9:	85 db                	test   %ebx,%ebx
f0100feb:	75 16                	jne    f0101003 <page_init+0x2e>
			//the first page is not free
			pages[i].pp_ref=1;
f0100fed:	a1 90 8e 20 f0       	mov    0xf0208e90,%eax
f0100ff2:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link=NULL;
f0100ff8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ffe:	e9 be 00 00 00       	jmp    f01010c1 <page_init+0xec>
		}else if(i>=1&&i<npages_basemem){
f0101003:	3b 1d 44 82 20 f0    	cmp    0xf0208244,%ebx
f0101009:	73 41                	jae    f010104c <page_init+0x77>
			//the rest of base memory is free
			//npages_basemem: amount of base memory (in pages)

			// change for lab4
			if (i == mp_page) {
f010100b:	83 fb 07             	cmp    $0x7,%ebx
f010100e:	75 17                	jne    f0101027 <page_init+0x52>
				// avoid adding the page at MPENTRY_PADDR to the free list
				pages[i].pp_ref = 1;
f0101010:	a1 90 8e 20 f0       	mov    0xf0208e90,%eax
f0101015:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
				pages[i].pp_link = NULL;
f010101b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
				continue;
f0101022:	e9 9a 00 00 00       	jmp    f01010c1 <page_init+0xec>
			}

			pages[i].pp_ref=0;
f0101027:	89 f0                	mov    %esi,%eax
f0101029:	03 05 90 8e 20 f0    	add    0xf0208e90,%eax
f010102f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link=page_free_list;
f0101035:	8b 15 40 82 20 f0    	mov    0xf0208240,%edx
f010103b:	89 10                	mov    %edx,(%eax)
			page_free_list=&pages[i];
f010103d:	89 f0                	mov    %esi,%eax
f010103f:	03 05 90 8e 20 f0    	add    0xf0208e90,%eax
f0101045:	a3 40 82 20 f0       	mov    %eax,0xf0208240
f010104a:	eb 75                	jmp    f01010c1 <page_init+0xec>
		}else if(i>=npages_basemem&&i<EXTPHYSMEM/PGSIZE){
f010104c:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0101052:	77 16                	ja     f010106a <page_init+0x95>
			//IO hole
			pages[i].pp_ref=1;
f0101054:	89 f0                	mov    %esi,%eax
f0101056:	03 05 90 8e 20 f0    	add    0xf0208e90,%eax
f010105c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link=NULL;
f0101062:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101068:	eb 57                	jmp    f01010c1 <page_init+0xec>
		}else if(i>=EXTPHYSMEM/PGSIZE&&i<((uint32_t)(boot_alloc(0)-KERNBASE)/PGSIZE)){
f010106a:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0101070:	76 2c                	jbe    f010109e <page_init+0xc9>
f0101072:	b8 00 00 00 00       	mov    $0x0,%eax
f0101077:	e8 a3 fb ff ff       	call   f0100c1f <boot_alloc>
f010107c:	05 00 00 00 10       	add    $0x10000000,%eax
f0101081:	c1 e8 0c             	shr    $0xc,%eax
f0101084:	39 c3                	cmp    %eax,%ebx
f0101086:	73 16                	jae    f010109e <page_init+0xc9>
			//used extended memory
			pages[i].pp_ref=1;
f0101088:	89 f0                	mov    %esi,%eax
f010108a:	03 05 90 8e 20 f0    	add    0xf0208e90,%eax
f0101090:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link=NULL;
f0101096:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010109c:	eb 23                	jmp    f01010c1 <page_init+0xec>
		}else{
			//unused extended memory
			pages[i].pp_ref=0;
f010109e:	89 f0                	mov    %esi,%eax
f01010a0:	03 05 90 8e 20 f0    	add    0xf0208e90,%eax
f01010a6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link=page_free_list;
f01010ac:	8b 15 40 82 20 f0    	mov    0xf0208240,%edx
f01010b2:	89 10                	mov    %edx,(%eax)
			page_free_list=&pages[i];
f01010b4:	89 f0                	mov    %esi,%eax
f01010b6:	03 05 90 8e 20 f0    	add    0xf0208e90,%eax
f01010bc:	a3 40 82 20 f0       	mov    %eax,0xf0208240
	// Physical address of startup code for non-boot CPUs (APs)
	// #define MPENTRY_PADDR	0x7000

	size_t i;
	size_t mp_page = MPENTRY_PADDR / PGSIZE;
	for (i = 0; i < npages; i++) {
f01010c1:	83 c3 01             	add    $0x1,%ebx
f01010c4:	83 c6 08             	add    $0x8,%esi
f01010c7:	3b 1d 88 8e 20 f0    	cmp    0xf0208e88,%ebx
f01010cd:	0f 82 16 ff ff ff    	jb     f0100fe9 <page_init+0x14>
			pages[i].pp_ref=0;
			pages[i].pp_link=page_free_list;
			page_free_list=&pages[i];
		}
	}
}
f01010d3:	5b                   	pop    %ebx
f01010d4:	5e                   	pop    %esi
f01010d5:	5d                   	pop    %ebp
f01010d6:	c3                   	ret    

f01010d7 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010d7:	55                   	push   %ebp
f01010d8:	89 e5                	mov    %esp,%ebp
f01010da:	53                   	push   %ebx
f01010db:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	// edited by Lethe 
	if(page_free_list){
f01010de:	8b 1d 40 82 20 f0    	mov    0xf0208240,%ebx
f01010e4:	85 db                	test   %ebx,%ebx
f01010e6:	74 58                	je     f0101140 <page_alloc+0x69>
		struct PageInfo *ret=page_free_list;
		//change page_free_list
		page_free_list=page_free_list->pp_link;
f01010e8:	8b 03                	mov    (%ebx),%eax
f01010ea:	a3 40 82 20 f0       	mov    %eax,0xf0208240
		//set the pp_link field of the allocated page to NULL
		ret->pp_link=NULL;
f01010ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		//If (alloc_flags & ALLOC_ZERO), fills the entire
		// returned physical page with '\0' bytes
		if(alloc_flags & ALLOC_ZERO){
f01010f5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010f9:	74 45                	je     f0101140 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010fb:	89 d8                	mov    %ebx,%eax
f01010fd:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0101103:	c1 f8 03             	sar    $0x3,%eax
f0101106:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101109:	89 c2                	mov    %eax,%edx
f010110b:	c1 ea 0c             	shr    $0xc,%edx
f010110e:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0101114:	72 12                	jb     f0101128 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101116:	50                   	push   %eax
f0101117:	68 c4 62 10 f0       	push   $0xf01062c4
f010111c:	6a 58                	push   $0x58
f010111e:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0101123:	e8 18 ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(ret),0,PGSIZE);
f0101128:	83 ec 04             	sub    $0x4,%esp
f010112b:	68 00 10 00 00       	push   $0x1000
f0101130:	6a 00                	push   $0x0
f0101132:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101137:	50                   	push   %eax
f0101138:	e8 9b 44 00 00       	call   f01055d8 <memset>
f010113d:	83 c4 10             	add    $0x10,%esp
		
		return ret;
	}
	//out of free memory,it means that page_free_list is null
	return NULL;
}
f0101140:	89 d8                	mov    %ebx,%eax
f0101142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101145:	c9                   	leave  
f0101146:	c3                   	ret    

f0101147 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101147:	55                   	push   %ebp
f0101148:	89 e5                	mov    %esp,%ebp
f010114a:	83 ec 08             	sub    $0x8,%esp
f010114d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	// edited by Lethe 
	if(pp->pp_ref!=0 || pp->pp_link!=NULL){
f0101150:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101155:	75 05                	jne    f010115c <page_free+0x15>
f0101157:	83 38 00             	cmpl   $0x0,(%eax)
f010115a:	74 17                	je     f0101173 <page_free+0x2c>
		panic("pp->pp_ref is nonzero or pp->pp_link is not NULL");
f010115c:	83 ec 04             	sub    $0x4,%esp
f010115f:	68 28 6e 10 f0       	push   $0xf0106e28
f0101164:	68 c1 01 00 00       	push   $0x1c1
f0101169:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010116e:	e8 cd ee ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link=page_free_list;
f0101173:	8b 15 40 82 20 f0    	mov    0xf0208240,%edx
f0101179:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f010117b:	a3 40 82 20 f0       	mov    %eax,0xf0208240
}
f0101180:	c9                   	leave  
f0101181:	c3                   	ret    

f0101182 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101182:	55                   	push   %ebp
f0101183:	89 e5                	mov    %esp,%ebp
f0101185:	83 ec 08             	sub    $0x8,%esp
f0101188:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010118b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010118f:	83 e8 01             	sub    $0x1,%eax
f0101192:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101196:	66 85 c0             	test   %ax,%ax
f0101199:	75 0c                	jne    f01011a7 <page_decref+0x25>
		page_free(pp);
f010119b:	83 ec 0c             	sub    $0xc,%esp
f010119e:	52                   	push   %edx
f010119f:	e8 a3 ff ff ff       	call   f0101147 <page_free>
f01011a4:	83 c4 10             	add    $0x10,%esp
}
f01011a7:	c9                   	leave  
f01011a8:	c3                   	ret    

f01011a9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01011a9:	55                   	push   %ebp
f01011aa:	89 e5                	mov    %esp,%ebp
f01011ac:	56                   	push   %esi
f01011ad:	53                   	push   %ebx
f01011ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	//very important! you should distinguish physical
	//address with virtual address

	//get page directory index and page table index
	uint32_t pd_index = PDX(va), pt_index = PTX(va);
f01011b1:	89 de                	mov    %ebx,%esi
f01011b3:	c1 ee 0c             	shr    $0xc,%esi
f01011b6:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//is corresponding pde exists?
	if (!(pgdir[pd_index] & PTE_P)) {
f01011bc:	c1 eb 16             	shr    $0x16,%ebx
f01011bf:	c1 e3 02             	shl    $0x2,%ebx
f01011c2:	03 5d 08             	add    0x8(%ebp),%ebx
f01011c5:	f6 03 01             	testb  $0x1,(%ebx)
f01011c8:	75 2d                	jne    f01011f7 <pgdir_walk+0x4e>
	//bit and
	//PTE_P: present flags
	//pde doesn't exist

	//create page or not?
	if (create) {
f01011ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011ce:	74 59                	je     f0101229 <pgdir_walk+0x80>
		//create a new zero page
		struct PageInfo *new_pg = page_alloc(ALLOC_ZERO);
f01011d0:	83 ec 0c             	sub    $0xc,%esp
f01011d3:	6a 01                	push   $0x1
f01011d5:	e8 fd fe ff ff       	call   f01010d7 <page_alloc>
		if (!new_pg) return NULL;//allocation fails
f01011da:	83 c4 10             	add    $0x10,%esp
f01011dd:	85 c0                	test   %eax,%eax
f01011df:	74 4f                	je     f0101230 <pgdir_walk+0x87>
		new_pg->pp_ref++;
f01011e1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		//set flags, present, user and writeable
		//NOTICE: pgdir[pd_index] stores a physical address
		pgdir[pd_index] = page2pa(new_pg) | PTE_P | PTE_U | PTE_W;
f01011e6:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f01011ec:	c1 f8 03             	sar    $0x3,%eax
f01011ef:	c1 e0 0c             	shl    $0xc,%eax
f01011f2:	83 c8 07             	or     $0x7,%eax
f01011f5:	89 03                	mov    %eax,(%ebx)
		//don't create
		return NULL;
	}
	}
	//NOTICE: here returns a virtual address
	pte_t *ret = KADDR(PTE_ADDR(pgdir[pd_index]));
f01011f7:	8b 03                	mov    (%ebx),%eax
f01011f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011fe:	89 c2                	mov    %eax,%edx
f0101200:	c1 ea 0c             	shr    $0xc,%edx
f0101203:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0101209:	72 15                	jb     f0101220 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010120b:	50                   	push   %eax
f010120c:	68 c4 62 10 f0       	push   $0xf01062c4
f0101211:	68 0f 02 00 00       	push   $0x20f
f0101216:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010121b:	e8 20 ee ff ff       	call   f0100040 <_panic>
	return (pte_t*)(ret + pt_index);
f0101220:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101227:	eb 0c                	jmp    f0101235 <pgdir_walk+0x8c>
		//NOTICE: pgdir[pd_index] stores a physical address
		pgdir[pd_index] = page2pa(new_pg) | PTE_P | PTE_U | PTE_W;
	}
	else {
		//don't create
		return NULL;
f0101229:	b8 00 00 00 00       	mov    $0x0,%eax
f010122e:	eb 05                	jmp    f0101235 <pgdir_walk+0x8c>

	//create page or not?
	if (create) {
		//create a new zero page
		struct PageInfo *new_pg = page_alloc(ALLOC_ZERO);
		if (!new_pg) return NULL;//allocation fails
f0101230:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	}
	//NOTICE: here returns a virtual address
	pte_t *ret = KADDR(PTE_ADDR(pgdir[pd_index]));
	return (pte_t*)(ret + pt_index);
}
f0101235:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101238:	5b                   	pop    %ebx
f0101239:	5e                   	pop    %esi
f010123a:	5d                   	pop    %ebp
f010123b:	c3                   	ret    

f010123c <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010123c:	55                   	push   %ebp
f010123d:	89 e5                	mov    %esp,%ebp
f010123f:	57                   	push   %edi
f0101240:	56                   	push   %esi
f0101241:	53                   	push   %ebx
f0101242:	83 ec 1c             	sub    $0x1c,%esp
f0101245:	89 c7                	mov    %eax,%edi
f0101247:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010124a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	// edited by Lethe 
	int i;
	pte_t *entry=NULL;
	for(i=0;i<size;i+=PGSIZE){
f010124d:	bb 00 00 00 00       	mov    $0x0,%ebx
		//match one virtual page with one physical page each time
		entry=pgdir_walk(pgdir,(void *)va,1);
		//here pa is a phsical address
		*entry=pa|perm|PTE_P;
f0101252:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101255:	83 c8 01             	or     $0x1,%eax
f0101258:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	// edited by Lethe 
	int i;
	pte_t *entry=NULL;
	for(i=0;i<size;i+=PGSIZE){
f010125b:	eb 1f                	jmp    f010127c <boot_map_region+0x40>
		//match one virtual page with one physical page each time
		entry=pgdir_walk(pgdir,(void *)va,1);
f010125d:	83 ec 04             	sub    $0x4,%esp
f0101260:	6a 01                	push   $0x1
f0101262:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101265:	01 d8                	add    %ebx,%eax
f0101267:	50                   	push   %eax
f0101268:	57                   	push   %edi
f0101269:	e8 3b ff ff ff       	call   f01011a9 <pgdir_walk>
		//here pa is a phsical address
		*entry=pa|perm|PTE_P;
f010126e:	0b 75 dc             	or     -0x24(%ebp),%esi
f0101271:	89 30                	mov    %esi,(%eax)
{
	// Fill this function in
	// edited by Lethe 
	int i;
	pte_t *entry=NULL;
	for(i=0;i<size;i+=PGSIZE){
f0101273:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101279:	83 c4 10             	add    $0x10,%esp
f010127c:	89 de                	mov    %ebx,%esi
f010127e:	03 75 08             	add    0x8(%ebp),%esi
f0101281:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101284:	77 d7                	ja     f010125d <boot_map_region+0x21>
		//here pa is a phsical address
		*entry=pa|perm|PTE_P;
		pa+=PGSIZE;
		va+=PGSIZE;
	}
}
f0101286:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101289:	5b                   	pop    %ebx
f010128a:	5e                   	pop    %esi
f010128b:	5f                   	pop    %edi
f010128c:	5d                   	pop    %ebp
f010128d:	c3                   	ret    

f010128e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010128e:	55                   	push   %ebp
f010128f:	89 e5                	mov    %esp,%ebp
f0101291:	53                   	push   %ebx
f0101292:	83 ec 08             	sub    $0x8,%esp
f0101295:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// edited by Lethe 
	// match but don't create
	pte_t *entry=pgdir_walk(pgdir,va,0);
f0101298:	6a 00                	push   $0x0
f010129a:	ff 75 0c             	pushl  0xc(%ebp)
f010129d:	ff 75 08             	pushl  0x8(%ebp)
f01012a0:	e8 04 ff ff ff       	call   f01011a9 <pgdir_walk>
	if(!entry){
f01012a5:	83 c4 10             	add    $0x10,%esp
f01012a8:	85 c0                	test   %eax,%eax
f01012aa:	74 38                	je     f01012e4 <page_lookup+0x56>
f01012ac:	89 c1                	mov    %eax,%ecx
		//not exist
		return NULL;
	}
	if(!(*entry & PTE_P)){
f01012ae:	8b 10                	mov    (%eax),%edx
f01012b0:	f6 c2 01             	test   $0x1,%dl
f01012b3:	74 36                	je     f01012eb <page_lookup+0x5d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b5:	c1 ea 0c             	shr    $0xc,%edx
f01012b8:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f01012be:	72 14                	jb     f01012d4 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
f01012c0:	83 ec 04             	sub    $0x4,%esp
f01012c3:	68 5c 6e 10 f0       	push   $0xf0106e5c
f01012c8:	6a 51                	push   $0x51
f01012ca:	68 4b 6a 10 f0       	push   $0xf0106a4b
f01012cf:	e8 6c ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012d4:	a1 90 8e 20 f0       	mov    0xf0208e90,%eax
f01012d9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	}
	
	struct PageInfo *ret=pa2page(PTE_ADDR(*entry));
	//if pte_store is not zero, then we store in it the address
	//of the pte for this page
	if(pte_store){
f01012dc:	85 db                	test   %ebx,%ebx
f01012de:	74 10                	je     f01012f0 <page_lookup+0x62>
		*pte_store=entry;
f01012e0:	89 0b                	mov    %ecx,(%ebx)
f01012e2:	eb 0c                	jmp    f01012f0 <page_lookup+0x62>
	// edited by Lethe 
	// match but don't create
	pte_t *entry=pgdir_walk(pgdir,va,0);
	if(!entry){
		//not exist
		return NULL;
f01012e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e9:	eb 05                	jmp    f01012f0 <page_lookup+0x62>
	}
	if(!(*entry & PTE_P)){
		//the entry is not valid for address translation
		return NULL;
f01012eb:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store){
		*pte_store=entry;
	}
	
	return ret;
}
f01012f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012f3:	c9                   	leave  
f01012f4:	c3                   	ret    

f01012f5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012f5:	55                   	push   %ebp
f01012f6:	89 e5                	mov    %esp,%ebp
f01012f8:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012fb:	e8 fa 48 00 00       	call   f0105bfa <cpunum>
f0101300:	6b c0 74             	imul   $0x74,%eax,%eax
f0101303:	83 b8 28 90 20 f0 00 	cmpl   $0x0,-0xfdf6fd8(%eax)
f010130a:	74 16                	je     f0101322 <tlb_invalidate+0x2d>
f010130c:	e8 e9 48 00 00       	call   f0105bfa <cpunum>
f0101311:	6b c0 74             	imul   $0x74,%eax,%eax
f0101314:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f010131a:	8b 55 08             	mov    0x8(%ebp),%edx
f010131d:	39 50 60             	cmp    %edx,0x60(%eax)
f0101320:	75 06                	jne    f0101328 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101322:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101325:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101328:	c9                   	leave  
f0101329:	c3                   	ret    

f010132a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010132a:	55                   	push   %ebp
f010132b:	89 e5                	mov    %esp,%ebp
f010132d:	56                   	push   %esi
f010132e:	53                   	push   %ebx
f010132f:	83 ec 14             	sub    $0x14,%esp
f0101332:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101335:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	// edited by Lethe 
	// use page_lookup
	pte_t *pte=pgdir_walk(pgdir,va,0);
f0101338:	6a 00                	push   $0x0
f010133a:	56                   	push   %esi
f010133b:	53                   	push   %ebx
f010133c:	e8 68 fe ff ff       	call   f01011a9 <pgdir_walk>
f0101341:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pte_t **pte_store=&pte;
	struct PageInfo *pp=page_lookup(pgdir,va,pte_store);
f0101344:	83 c4 0c             	add    $0xc,%esp
f0101347:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010134a:	50                   	push   %eax
f010134b:	56                   	push   %esi
f010134c:	53                   	push   %ebx
f010134d:	e8 3c ff ff ff       	call   f010128e <page_lookup>

	if(!pp){
f0101352:	83 c4 10             	add    $0x10,%esp
f0101355:	85 c0                	test   %eax,%eax
f0101357:	74 1f                	je     f0101378 <page_remove+0x4e>
		//need to consider that here
		return;
	}
	
	//decrement the reference count on the page
	page_decref(pp);
f0101359:	83 ec 0c             	sub    $0xc,%esp
f010135c:	50                   	push   %eax
f010135d:	e8 20 fe ff ff       	call   f0101182 <page_decref>
	//corresponding page table entry set to 0
	**pte_store=0;
f0101362:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101365:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//TLB be invalidated
	tlb_invalidate(pgdir,va);
f010136b:	83 c4 08             	add    $0x8,%esp
f010136e:	56                   	push   %esi
f010136f:	53                   	push   %ebx
f0101370:	e8 80 ff ff ff       	call   f01012f5 <tlb_invalidate>
f0101375:	83 c4 10             	add    $0x10,%esp
}
f0101378:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010137b:	5b                   	pop    %ebx
f010137c:	5e                   	pop    %esi
f010137d:	5d                   	pop    %ebp
f010137e:	c3                   	ret    

f010137f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010137f:	55                   	push   %ebp
f0101380:	89 e5                	mov    %esp,%ebp
f0101382:	57                   	push   %edi
f0101383:	56                   	push   %esi
f0101384:	53                   	push   %ebx
f0101385:	83 ec 10             	sub    $0x10,%esp
f0101388:	8b 75 08             	mov    0x8(%ebp),%esi
f010138b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// edited by Lethe 
	// purpose: map the physical page 'pp' at virtual address 'va'
	// get address of the corresponding page_table_entry
	pte_t *entry=pgdir_walk(pgdir,va,1);
f010138e:	6a 01                	push   $0x1
f0101390:	ff 75 10             	pushl  0x10(%ebp)
f0101393:	56                   	push   %esi
f0101394:	e8 10 fe ff ff       	call   f01011a9 <pgdir_walk>
	
	if(!entry){
f0101399:	83 c4 10             	add    $0x10,%esp
f010139c:	85 c0                	test   %eax,%eax
f010139e:	74 50                	je     f01013f0 <page_insert+0x71>
f01013a0:	89 c7                	mov    %eax,%edi
		//allocation failed
		return -E_NO_MEM;
	}

	pp->pp_ref++;
f01013a2:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(*entry & PTE_P){
f01013a7:	f6 00 01             	testb  $0x1,(%eax)
f01013aa:	74 1b                	je     f01013c7 <page_insert+0x48>
		//one page is already existed
		//TLB be invliadated
		tlb_invalidate(pgdir,va);
f01013ac:	83 ec 08             	sub    $0x8,%esp
f01013af:	ff 75 10             	pushl  0x10(%ebp)
f01013b2:	56                   	push   %esi
f01013b3:	e8 3d ff ff ff       	call   f01012f5 <tlb_invalidate>
		//remove page
		page_remove(pgdir,va);
f01013b8:	83 c4 08             	add    $0x8,%esp
f01013bb:	ff 75 10             	pushl  0x10(%ebp)
f01013be:	56                   	push   %esi
f01013bf:	e8 66 ff ff ff       	call   f010132a <page_remove>
f01013c4:	83 c4 10             	add    $0x10,%esp
	}

	*entry=page2pa(pp)|perm|PTE_P;
f01013c7:	2b 1d 90 8e 20 f0    	sub    0xf0208e90,%ebx
f01013cd:	c1 fb 03             	sar    $0x3,%ebx
f01013d0:	c1 e3 0c             	shl    $0xc,%ebx
f01013d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01013d6:	83 c8 01             	or     $0x1,%eax
f01013d9:	09 c3                	or     %eax,%ebx
f01013db:	89 1f                	mov    %ebx,(%edi)
	//insert the mapping relation into page directory
	pgdir[PDX(va)]|=perm;
f01013dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01013e0:	c1 e8 16             	shr    $0x16,%eax
f01013e3:	8b 55 14             	mov    0x14(%ebp),%edx
f01013e6:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f01013e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ee:	eb 05                	jmp    f01013f5 <page_insert+0x76>
	// get address of the corresponding page_table_entry
	pte_t *entry=pgdir_walk(pgdir,va,1);
	
	if(!entry){
		//allocation failed
		return -E_NO_MEM;
f01013f0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	*entry=page2pa(pp)|perm|PTE_P;
	//insert the mapping relation into page directory
	pgdir[PDX(va)]|=perm;
	return 0;
}
f01013f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013f8:	5b                   	pop    %ebx
f01013f9:	5e                   	pop    %esi
f01013fa:	5f                   	pop    %edi
f01013fb:	5d                   	pop    %ebp
f01013fc:	c3                   	ret    

f01013fd <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013fd:	55                   	push   %ebp
f01013fe:	89 e5                	mov    %esp,%ebp
f0101400:	53                   	push   %ebx
f0101401:	83 ec 04             	sub    $0x4,%esp
	// MMIO is defined in inc/memlayout.h
	// #define MMIOBASE	(MMIOLIM - PTSIZE)
	
	// ROUNDUP and ROUNDDOWN have the same effect when size is a multiple of PGSIZE
	//zstatic uintptr_t base = MMIOBASE;
	size = ROUNDUP(size, PGSIZE);
f0101404:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101407:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010140d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f0101413:	8b 45 08             	mov    0x8(%ebp),%eax
f0101416:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if(size + base >= MMIOLIM)
f010141b:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101421:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f0101424:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f010142a:	76 17                	jbe    f0101443 <mmio_map_region+0x46>
		panic("Overflow MMIOLIM!\n");
f010142c:	83 ec 04             	sub    $0x4,%esp
f010142f:	68 12 6b 10 f0       	push   $0xf0106b12
f0101434:	68 e9 02 00 00       	push   $0x2e9
f0101439:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010143e:	e8 fd eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101443:	83 ec 08             	sub    $0x8,%esp
f0101446:	6a 1a                	push   $0x1a
f0101448:	50                   	push   %eax
f0101449:	89 d9                	mov    %ebx,%ecx
f010144b:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f0101450:	e8 e7 fd ff ff       	call   f010123c <boot_map_region>
	uintptr_t ret = base;
f0101455:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base = base +size;
f010145a:	01 c3                	add    %eax,%ebx
f010145c:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void*) ret;

}
f0101462:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101465:	c9                   	leave  
f0101466:	c3                   	ret    

f0101467 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101467:	55                   	push   %ebp
f0101468:	89 e5                	mov    %esp,%ebp
f010146a:	57                   	push   %edi
f010146b:	56                   	push   %esi
f010146c:	53                   	push   %ebx
f010146d:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101470:	6a 15                	push   $0x15
f0101472:	e8 10 22 00 00       	call   f0103687 <mc146818_read>
f0101477:	89 c3                	mov    %eax,%ebx
f0101479:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101480:	e8 02 22 00 00       	call   f0103687 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101485:	c1 e0 08             	shl    $0x8,%eax
f0101488:	09 d8                	or     %ebx,%eax
f010148a:	c1 e0 0a             	shl    $0xa,%eax
f010148d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101493:	85 c0                	test   %eax,%eax
f0101495:	0f 48 c2             	cmovs  %edx,%eax
f0101498:	c1 f8 0c             	sar    $0xc,%eax
f010149b:	a3 44 82 20 f0       	mov    %eax,0xf0208244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01014a0:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01014a7:	e8 db 21 00 00       	call   f0103687 <mc146818_read>
f01014ac:	89 c3                	mov    %eax,%ebx
f01014ae:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01014b5:	e8 cd 21 00 00       	call   f0103687 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01014ba:	c1 e0 08             	shl    $0x8,%eax
f01014bd:	09 d8                	or     %ebx,%eax
f01014bf:	c1 e0 0a             	shl    $0xa,%eax
f01014c2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01014c8:	83 c4 10             	add    $0x10,%esp
f01014cb:	85 c0                	test   %eax,%eax
f01014cd:	0f 48 c2             	cmovs  %edx,%eax
f01014d0:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01014d3:	85 c0                	test   %eax,%eax
f01014d5:	74 0e                	je     f01014e5 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01014d7:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01014dd:	89 15 88 8e 20 f0    	mov    %edx,0xf0208e88
f01014e3:	eb 0c                	jmp    f01014f1 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01014e5:	8b 15 44 82 20 f0    	mov    0xf0208244,%edx
f01014eb:	89 15 88 8e 20 f0    	mov    %edx,0xf0208e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014f1:	c1 e0 0c             	shl    $0xc,%eax
f01014f4:	c1 e8 0a             	shr    $0xa,%eax
f01014f7:	50                   	push   %eax
f01014f8:	a1 44 82 20 f0       	mov    0xf0208244,%eax
f01014fd:	c1 e0 0c             	shl    $0xc,%eax
f0101500:	c1 e8 0a             	shr    $0xa,%eax
f0101503:	50                   	push   %eax
f0101504:	a1 88 8e 20 f0       	mov    0xf0208e88,%eax
f0101509:	c1 e0 0c             	shl    $0xc,%eax
f010150c:	c1 e8 0a             	shr    $0xa,%eax
f010150f:	50                   	push   %eax
f0101510:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0101515:	e8 ec 22 00 00       	call   f0103806 <cprintf>
	// comment the next line for debug, edited by lETHE
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010151a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010151f:	e8 fb f6 ff ff       	call   f0100c1f <boot_alloc>
f0101524:	a3 8c 8e 20 f0       	mov    %eax,0xf0208e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101529:	83 c4 0c             	add    $0xc,%esp
f010152c:	68 00 10 00 00       	push   $0x1000
f0101531:	6a 00                	push   $0x0
f0101533:	50                   	push   %eax
f0101534:	e8 9f 40 00 00       	call   f01055d8 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101539:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010153e:	83 c4 10             	add    $0x10,%esp
f0101541:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101546:	77 15                	ja     f010155d <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101548:	50                   	push   %eax
f0101549:	68 e8 62 10 f0       	push   $0xf01062e8
f010154e:	68 a4 00 00 00       	push   $0xa4
f0101553:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101558:	e8 e3 ea ff ff       	call   f0100040 <_panic>
f010155d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101563:	83 ca 05             	or     $0x5,%edx
f0101566:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	// edited by Lethe 
	pages=(struct PageInfo *)boot_alloc(npages*(sizeof(struct PageInfo)));
f010156c:	a1 88 8e 20 f0       	mov    0xf0208e88,%eax
f0101571:	c1 e0 03             	shl    $0x3,%eax
f0101574:	e8 a6 f6 ff ff       	call   f0100c1f <boot_alloc>
f0101579:	a3 90 8e 20 f0       	mov    %eax,0xf0208e90
	memset(pages,0,npages*(sizeof(struct PageInfo)));
f010157e:	83 ec 04             	sub    $0x4,%esp
f0101581:	8b 0d 88 8e 20 f0    	mov    0xf0208e88,%ecx
f0101587:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010158e:	52                   	push   %edx
f010158f:	6a 00                	push   $0x0
f0101591:	50                   	push   %eax
f0101592:	e8 41 40 00 00       	call   f01055d8 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	// edited by Lethe
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f0101597:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010159c:	e8 7e f6 ff ff       	call   f0100c1f <boot_alloc>
f01015a1:	a3 48 82 20 f0       	mov    %eax,0xf0208248
	memset(envs, 0, sizeof(struct Env) * NENV);
f01015a6:	83 c4 0c             	add    $0xc,%esp
f01015a9:	68 00 f0 01 00       	push   $0x1f000
f01015ae:	6a 00                	push   $0x0
f01015b0:	50                   	push   %eax
f01015b1:	e8 22 40 00 00       	call   f01055d8 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015b6:	e8 1a fa ff ff       	call   f0100fd5 <page_init>

	check_page_free_list(1);
f01015bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01015c0:	e8 21 f7 ff ff       	call   f0100ce6 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015c5:	83 c4 10             	add    $0x10,%esp
f01015c8:	83 3d 90 8e 20 f0 00 	cmpl   $0x0,0xf0208e90
f01015cf:	75 17                	jne    f01015e8 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f01015d1:	83 ec 04             	sub    $0x4,%esp
f01015d4:	68 25 6b 10 f0       	push   $0xf0106b25
f01015d9:	68 86 03 00 00       	push   $0x386
f01015de:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01015e3:	e8 58 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015e8:	a1 40 82 20 f0       	mov    0xf0208240,%eax
f01015ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015f2:	eb 05                	jmp    f01015f9 <mem_init+0x192>
		++nfree;
f01015f4:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015f7:	8b 00                	mov    (%eax),%eax
f01015f9:	85 c0                	test   %eax,%eax
f01015fb:	75 f7                	jne    f01015f4 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015fd:	83 ec 0c             	sub    $0xc,%esp
f0101600:	6a 00                	push   $0x0
f0101602:	e8 d0 fa ff ff       	call   f01010d7 <page_alloc>
f0101607:	89 c7                	mov    %eax,%edi
f0101609:	83 c4 10             	add    $0x10,%esp
f010160c:	85 c0                	test   %eax,%eax
f010160e:	75 19                	jne    f0101629 <mem_init+0x1c2>
f0101610:	68 40 6b 10 f0       	push   $0xf0106b40
f0101615:	68 65 6a 10 f0       	push   $0xf0106a65
f010161a:	68 8e 03 00 00       	push   $0x38e
f010161f:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101624:	e8 17 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101629:	83 ec 0c             	sub    $0xc,%esp
f010162c:	6a 00                	push   $0x0
f010162e:	e8 a4 fa ff ff       	call   f01010d7 <page_alloc>
f0101633:	89 c6                	mov    %eax,%esi
f0101635:	83 c4 10             	add    $0x10,%esp
f0101638:	85 c0                	test   %eax,%eax
f010163a:	75 19                	jne    f0101655 <mem_init+0x1ee>
f010163c:	68 56 6b 10 f0       	push   $0xf0106b56
f0101641:	68 65 6a 10 f0       	push   $0xf0106a65
f0101646:	68 8f 03 00 00       	push   $0x38f
f010164b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101650:	e8 eb e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101655:	83 ec 0c             	sub    $0xc,%esp
f0101658:	6a 00                	push   $0x0
f010165a:	e8 78 fa ff ff       	call   f01010d7 <page_alloc>
f010165f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101662:	83 c4 10             	add    $0x10,%esp
f0101665:	85 c0                	test   %eax,%eax
f0101667:	75 19                	jne    f0101682 <mem_init+0x21b>
f0101669:	68 6c 6b 10 f0       	push   $0xf0106b6c
f010166e:	68 65 6a 10 f0       	push   $0xf0106a65
f0101673:	68 90 03 00 00       	push   $0x390
f0101678:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010167d:	e8 be e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101682:	39 f7                	cmp    %esi,%edi
f0101684:	75 19                	jne    f010169f <mem_init+0x238>
f0101686:	68 82 6b 10 f0       	push   $0xf0106b82
f010168b:	68 65 6a 10 f0       	push   $0xf0106a65
f0101690:	68 93 03 00 00       	push   $0x393
f0101695:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010169a:	e8 a1 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010169f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a2:	39 c6                	cmp    %eax,%esi
f01016a4:	74 04                	je     f01016aa <mem_init+0x243>
f01016a6:	39 c7                	cmp    %eax,%edi
f01016a8:	75 19                	jne    f01016c3 <mem_init+0x25c>
f01016aa:	68 b8 6e 10 f0       	push   $0xf0106eb8
f01016af:	68 65 6a 10 f0       	push   $0xf0106a65
f01016b4:	68 94 03 00 00       	push   $0x394
f01016b9:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01016be:	e8 7d e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016c3:	8b 0d 90 8e 20 f0    	mov    0xf0208e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c9:	8b 15 88 8e 20 f0    	mov    0xf0208e88,%edx
f01016cf:	c1 e2 0c             	shl    $0xc,%edx
f01016d2:	89 f8                	mov    %edi,%eax
f01016d4:	29 c8                	sub    %ecx,%eax
f01016d6:	c1 f8 03             	sar    $0x3,%eax
f01016d9:	c1 e0 0c             	shl    $0xc,%eax
f01016dc:	39 d0                	cmp    %edx,%eax
f01016de:	72 19                	jb     f01016f9 <mem_init+0x292>
f01016e0:	68 94 6b 10 f0       	push   $0xf0106b94
f01016e5:	68 65 6a 10 f0       	push   $0xf0106a65
f01016ea:	68 95 03 00 00       	push   $0x395
f01016ef:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01016f4:	e8 47 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f9:	89 f0                	mov    %esi,%eax
f01016fb:	29 c8                	sub    %ecx,%eax
f01016fd:	c1 f8 03             	sar    $0x3,%eax
f0101700:	c1 e0 0c             	shl    $0xc,%eax
f0101703:	39 c2                	cmp    %eax,%edx
f0101705:	77 19                	ja     f0101720 <mem_init+0x2b9>
f0101707:	68 b1 6b 10 f0       	push   $0xf0106bb1
f010170c:	68 65 6a 10 f0       	push   $0xf0106a65
f0101711:	68 96 03 00 00       	push   $0x396
f0101716:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010171b:	e8 20 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101720:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101723:	29 c8                	sub    %ecx,%eax
f0101725:	c1 f8 03             	sar    $0x3,%eax
f0101728:	c1 e0 0c             	shl    $0xc,%eax
f010172b:	39 c2                	cmp    %eax,%edx
f010172d:	77 19                	ja     f0101748 <mem_init+0x2e1>
f010172f:	68 ce 6b 10 f0       	push   $0xf0106bce
f0101734:	68 65 6a 10 f0       	push   $0xf0106a65
f0101739:	68 97 03 00 00       	push   $0x397
f010173e:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101743:	e8 f8 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101748:	a1 40 82 20 f0       	mov    0xf0208240,%eax
f010174d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101750:	c7 05 40 82 20 f0 00 	movl   $0x0,0xf0208240
f0101757:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010175a:	83 ec 0c             	sub    $0xc,%esp
f010175d:	6a 00                	push   $0x0
f010175f:	e8 73 f9 ff ff       	call   f01010d7 <page_alloc>
f0101764:	83 c4 10             	add    $0x10,%esp
f0101767:	85 c0                	test   %eax,%eax
f0101769:	74 19                	je     f0101784 <mem_init+0x31d>
f010176b:	68 eb 6b 10 f0       	push   $0xf0106beb
f0101770:	68 65 6a 10 f0       	push   $0xf0106a65
f0101775:	68 9e 03 00 00       	push   $0x39e
f010177a:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010177f:	e8 bc e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101784:	83 ec 0c             	sub    $0xc,%esp
f0101787:	57                   	push   %edi
f0101788:	e8 ba f9 ff ff       	call   f0101147 <page_free>
	page_free(pp1);
f010178d:	89 34 24             	mov    %esi,(%esp)
f0101790:	e8 b2 f9 ff ff       	call   f0101147 <page_free>
	page_free(pp2);
f0101795:	83 c4 04             	add    $0x4,%esp
f0101798:	ff 75 d4             	pushl  -0x2c(%ebp)
f010179b:	e8 a7 f9 ff ff       	call   f0101147 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a7:	e8 2b f9 ff ff       	call   f01010d7 <page_alloc>
f01017ac:	89 c6                	mov    %eax,%esi
f01017ae:	83 c4 10             	add    $0x10,%esp
f01017b1:	85 c0                	test   %eax,%eax
f01017b3:	75 19                	jne    f01017ce <mem_init+0x367>
f01017b5:	68 40 6b 10 f0       	push   $0xf0106b40
f01017ba:	68 65 6a 10 f0       	push   $0xf0106a65
f01017bf:	68 a5 03 00 00       	push   $0x3a5
f01017c4:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017ce:	83 ec 0c             	sub    $0xc,%esp
f01017d1:	6a 00                	push   $0x0
f01017d3:	e8 ff f8 ff ff       	call   f01010d7 <page_alloc>
f01017d8:	89 c7                	mov    %eax,%edi
f01017da:	83 c4 10             	add    $0x10,%esp
f01017dd:	85 c0                	test   %eax,%eax
f01017df:	75 19                	jne    f01017fa <mem_init+0x393>
f01017e1:	68 56 6b 10 f0       	push   $0xf0106b56
f01017e6:	68 65 6a 10 f0       	push   $0xf0106a65
f01017eb:	68 a6 03 00 00       	push   $0x3a6
f01017f0:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01017f5:	e8 46 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017fa:	83 ec 0c             	sub    $0xc,%esp
f01017fd:	6a 00                	push   $0x0
f01017ff:	e8 d3 f8 ff ff       	call   f01010d7 <page_alloc>
f0101804:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101807:	83 c4 10             	add    $0x10,%esp
f010180a:	85 c0                	test   %eax,%eax
f010180c:	75 19                	jne    f0101827 <mem_init+0x3c0>
f010180e:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0101813:	68 65 6a 10 f0       	push   $0xf0106a65
f0101818:	68 a7 03 00 00       	push   $0x3a7
f010181d:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101822:	e8 19 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101827:	39 fe                	cmp    %edi,%esi
f0101829:	75 19                	jne    f0101844 <mem_init+0x3dd>
f010182b:	68 82 6b 10 f0       	push   $0xf0106b82
f0101830:	68 65 6a 10 f0       	push   $0xf0106a65
f0101835:	68 a9 03 00 00       	push   $0x3a9
f010183a:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010183f:	e8 fc e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101844:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101847:	39 c7                	cmp    %eax,%edi
f0101849:	74 04                	je     f010184f <mem_init+0x3e8>
f010184b:	39 c6                	cmp    %eax,%esi
f010184d:	75 19                	jne    f0101868 <mem_init+0x401>
f010184f:	68 b8 6e 10 f0       	push   $0xf0106eb8
f0101854:	68 65 6a 10 f0       	push   $0xf0106a65
f0101859:	68 aa 03 00 00       	push   $0x3aa
f010185e:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101863:	e8 d8 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101868:	83 ec 0c             	sub    $0xc,%esp
f010186b:	6a 00                	push   $0x0
f010186d:	e8 65 f8 ff ff       	call   f01010d7 <page_alloc>
f0101872:	83 c4 10             	add    $0x10,%esp
f0101875:	85 c0                	test   %eax,%eax
f0101877:	74 19                	je     f0101892 <mem_init+0x42b>
f0101879:	68 eb 6b 10 f0       	push   $0xf0106beb
f010187e:	68 65 6a 10 f0       	push   $0xf0106a65
f0101883:	68 ab 03 00 00       	push   $0x3ab
f0101888:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010188d:	e8 ae e7 ff ff       	call   f0100040 <_panic>
f0101892:	89 f0                	mov    %esi,%eax
f0101894:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f010189a:	c1 f8 03             	sar    $0x3,%eax
f010189d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a0:	89 c2                	mov    %eax,%edx
f01018a2:	c1 ea 0c             	shr    $0xc,%edx
f01018a5:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f01018ab:	72 12                	jb     f01018bf <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ad:	50                   	push   %eax
f01018ae:	68 c4 62 10 f0       	push   $0xf01062c4
f01018b3:	6a 58                	push   $0x58
f01018b5:	68 4b 6a 10 f0       	push   $0xf0106a4b
f01018ba:	e8 81 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018bf:	83 ec 04             	sub    $0x4,%esp
f01018c2:	68 00 10 00 00       	push   $0x1000
f01018c7:	6a 01                	push   $0x1
f01018c9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018ce:	50                   	push   %eax
f01018cf:	e8 04 3d 00 00       	call   f01055d8 <memset>
	page_free(pp0);
f01018d4:	89 34 24             	mov    %esi,(%esp)
f01018d7:	e8 6b f8 ff ff       	call   f0101147 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018e3:	e8 ef f7 ff ff       	call   f01010d7 <page_alloc>
f01018e8:	83 c4 10             	add    $0x10,%esp
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	75 19                	jne    f0101908 <mem_init+0x4a1>
f01018ef:	68 fa 6b 10 f0       	push   $0xf0106bfa
f01018f4:	68 65 6a 10 f0       	push   $0xf0106a65
f01018f9:	68 b0 03 00 00       	push   $0x3b0
f01018fe:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101903:	e8 38 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101908:	39 c6                	cmp    %eax,%esi
f010190a:	74 19                	je     f0101925 <mem_init+0x4be>
f010190c:	68 18 6c 10 f0       	push   $0xf0106c18
f0101911:	68 65 6a 10 f0       	push   $0xf0106a65
f0101916:	68 b1 03 00 00       	push   $0x3b1
f010191b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101920:	e8 1b e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101925:	89 f0                	mov    %esi,%eax
f0101927:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f010192d:	c1 f8 03             	sar    $0x3,%eax
f0101930:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101933:	89 c2                	mov    %eax,%edx
f0101935:	c1 ea 0c             	shr    $0xc,%edx
f0101938:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f010193e:	72 12                	jb     f0101952 <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101940:	50                   	push   %eax
f0101941:	68 c4 62 10 f0       	push   $0xf01062c4
f0101946:	6a 58                	push   $0x58
f0101948:	68 4b 6a 10 f0       	push   $0xf0106a4b
f010194d:	e8 ee e6 ff ff       	call   f0100040 <_panic>
f0101952:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101958:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010195e:	80 38 00             	cmpb   $0x0,(%eax)
f0101961:	74 19                	je     f010197c <mem_init+0x515>
f0101963:	68 28 6c 10 f0       	push   $0xf0106c28
f0101968:	68 65 6a 10 f0       	push   $0xf0106a65
f010196d:	68 b4 03 00 00       	push   $0x3b4
f0101972:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101977:	e8 c4 e6 ff ff       	call   f0100040 <_panic>
f010197c:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010197f:	39 d0                	cmp    %edx,%eax
f0101981:	75 db                	jne    f010195e <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101983:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101986:	a3 40 82 20 f0       	mov    %eax,0xf0208240

	// free the pages we took
	page_free(pp0);
f010198b:	83 ec 0c             	sub    $0xc,%esp
f010198e:	56                   	push   %esi
f010198f:	e8 b3 f7 ff ff       	call   f0101147 <page_free>
	page_free(pp1);
f0101994:	89 3c 24             	mov    %edi,(%esp)
f0101997:	e8 ab f7 ff ff       	call   f0101147 <page_free>
	page_free(pp2);
f010199c:	83 c4 04             	add    $0x4,%esp
f010199f:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019a2:	e8 a0 f7 ff ff       	call   f0101147 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019a7:	a1 40 82 20 f0       	mov    0xf0208240,%eax
f01019ac:	83 c4 10             	add    $0x10,%esp
f01019af:	eb 05                	jmp    f01019b6 <mem_init+0x54f>
		--nfree;
f01019b1:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019b4:	8b 00                	mov    (%eax),%eax
f01019b6:	85 c0                	test   %eax,%eax
f01019b8:	75 f7                	jne    f01019b1 <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f01019ba:	85 db                	test   %ebx,%ebx
f01019bc:	74 19                	je     f01019d7 <mem_init+0x570>
f01019be:	68 32 6c 10 f0       	push   $0xf0106c32
f01019c3:	68 65 6a 10 f0       	push   $0xf0106a65
f01019c8:	68 c1 03 00 00       	push   $0x3c1
f01019cd:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01019d2:	e8 69 e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019d7:	83 ec 0c             	sub    $0xc,%esp
f01019da:	68 d8 6e 10 f0       	push   $0xf0106ed8
f01019df:	e8 22 1e 00 00       	call   f0103806 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019eb:	e8 e7 f6 ff ff       	call   f01010d7 <page_alloc>
f01019f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019f3:	83 c4 10             	add    $0x10,%esp
f01019f6:	85 c0                	test   %eax,%eax
f01019f8:	75 19                	jne    f0101a13 <mem_init+0x5ac>
f01019fa:	68 40 6b 10 f0       	push   $0xf0106b40
f01019ff:	68 65 6a 10 f0       	push   $0xf0106a65
f0101a04:	68 27 04 00 00       	push   $0x427
f0101a09:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101a0e:	e8 2d e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a13:	83 ec 0c             	sub    $0xc,%esp
f0101a16:	6a 00                	push   $0x0
f0101a18:	e8 ba f6 ff ff       	call   f01010d7 <page_alloc>
f0101a1d:	89 c3                	mov    %eax,%ebx
f0101a1f:	83 c4 10             	add    $0x10,%esp
f0101a22:	85 c0                	test   %eax,%eax
f0101a24:	75 19                	jne    f0101a3f <mem_init+0x5d8>
f0101a26:	68 56 6b 10 f0       	push   $0xf0106b56
f0101a2b:	68 65 6a 10 f0       	push   $0xf0106a65
f0101a30:	68 28 04 00 00       	push   $0x428
f0101a35:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101a3a:	e8 01 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3f:	83 ec 0c             	sub    $0xc,%esp
f0101a42:	6a 00                	push   $0x0
f0101a44:	e8 8e f6 ff ff       	call   f01010d7 <page_alloc>
f0101a49:	89 c6                	mov    %eax,%esi
f0101a4b:	83 c4 10             	add    $0x10,%esp
f0101a4e:	85 c0                	test   %eax,%eax
f0101a50:	75 19                	jne    f0101a6b <mem_init+0x604>
f0101a52:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0101a57:	68 65 6a 10 f0       	push   $0xf0106a65
f0101a5c:	68 29 04 00 00       	push   $0x429
f0101a61:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101a66:	e8 d5 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a6b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a6e:	75 19                	jne    f0101a89 <mem_init+0x622>
f0101a70:	68 82 6b 10 f0       	push   $0xf0106b82
f0101a75:	68 65 6a 10 f0       	push   $0xf0106a65
f0101a7a:	68 2c 04 00 00       	push   $0x42c
f0101a7f:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101a84:	e8 b7 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a89:	39 c3                	cmp    %eax,%ebx
f0101a8b:	74 05                	je     f0101a92 <mem_init+0x62b>
f0101a8d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a90:	75 19                	jne    f0101aab <mem_init+0x644>
f0101a92:	68 b8 6e 10 f0       	push   $0xf0106eb8
f0101a97:	68 65 6a 10 f0       	push   $0xf0106a65
f0101a9c:	68 2d 04 00 00       	push   $0x42d
f0101aa1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101aa6:	e8 95 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aab:	a1 40 82 20 f0       	mov    0xf0208240,%eax
f0101ab0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101ab3:	c7 05 40 82 20 f0 00 	movl   $0x0,0xf0208240
f0101aba:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101abd:	83 ec 0c             	sub    $0xc,%esp
f0101ac0:	6a 00                	push   $0x0
f0101ac2:	e8 10 f6 ff ff       	call   f01010d7 <page_alloc>
f0101ac7:	83 c4 10             	add    $0x10,%esp
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	74 19                	je     f0101ae7 <mem_init+0x680>
f0101ace:	68 eb 6b 10 f0       	push   $0xf0106beb
f0101ad3:	68 65 6a 10 f0       	push   $0xf0106a65
f0101ad8:	68 34 04 00 00       	push   $0x434
f0101add:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101ae2:	e8 59 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101ae7:	83 ec 04             	sub    $0x4,%esp
f0101aea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aed:	50                   	push   %eax
f0101aee:	6a 00                	push   $0x0
f0101af0:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101af6:	e8 93 f7 ff ff       	call   f010128e <page_lookup>
f0101afb:	83 c4 10             	add    $0x10,%esp
f0101afe:	85 c0                	test   %eax,%eax
f0101b00:	74 19                	je     f0101b1b <mem_init+0x6b4>
f0101b02:	68 f8 6e 10 f0       	push   $0xf0106ef8
f0101b07:	68 65 6a 10 f0       	push   $0xf0106a65
f0101b0c:	68 37 04 00 00       	push   $0x437
f0101b11:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101b16:	e8 25 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b1b:	6a 02                	push   $0x2
f0101b1d:	6a 00                	push   $0x0
f0101b1f:	53                   	push   %ebx
f0101b20:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101b26:	e8 54 f8 ff ff       	call   f010137f <page_insert>
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	78 19                	js     f0101b4b <mem_init+0x6e4>
f0101b32:	68 30 6f 10 f0       	push   $0xf0106f30
f0101b37:	68 65 6a 10 f0       	push   $0xf0106a65
f0101b3c:	68 3a 04 00 00       	push   $0x43a
f0101b41:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101b46:	e8 f5 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b4b:	83 ec 0c             	sub    $0xc,%esp
f0101b4e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b51:	e8 f1 f5 ff ff       	call   f0101147 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b56:	6a 02                	push   $0x2
f0101b58:	6a 00                	push   $0x0
f0101b5a:	53                   	push   %ebx
f0101b5b:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101b61:	e8 19 f8 ff ff       	call   f010137f <page_insert>
f0101b66:	83 c4 20             	add    $0x20,%esp
f0101b69:	85 c0                	test   %eax,%eax
f0101b6b:	74 19                	je     f0101b86 <mem_init+0x71f>
f0101b6d:	68 60 6f 10 f0       	push   $0xf0106f60
f0101b72:	68 65 6a 10 f0       	push   $0xf0106a65
f0101b77:	68 3e 04 00 00       	push   $0x43e
f0101b7c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101b81:	e8 ba e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b86:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b8c:	a1 90 8e 20 f0       	mov    0xf0208e90,%eax
f0101b91:	89 c1                	mov    %eax,%ecx
f0101b93:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b96:	8b 17                	mov    (%edi),%edx
f0101b98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba1:	29 c8                	sub    %ecx,%eax
f0101ba3:	c1 f8 03             	sar    $0x3,%eax
f0101ba6:	c1 e0 0c             	shl    $0xc,%eax
f0101ba9:	39 c2                	cmp    %eax,%edx
f0101bab:	74 19                	je     f0101bc6 <mem_init+0x75f>
f0101bad:	68 90 6f 10 f0       	push   $0xf0106f90
f0101bb2:	68 65 6a 10 f0       	push   $0xf0106a65
f0101bb7:	68 3f 04 00 00       	push   $0x43f
f0101bbc:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101bc1:	e8 7a e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bcb:	89 f8                	mov    %edi,%eax
f0101bcd:	e8 b0 f0 ff ff       	call   f0100c82 <check_va2pa>
f0101bd2:	89 da                	mov    %ebx,%edx
f0101bd4:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101bd7:	c1 fa 03             	sar    $0x3,%edx
f0101bda:	c1 e2 0c             	shl    $0xc,%edx
f0101bdd:	39 d0                	cmp    %edx,%eax
f0101bdf:	74 19                	je     f0101bfa <mem_init+0x793>
f0101be1:	68 b8 6f 10 f0       	push   $0xf0106fb8
f0101be6:	68 65 6a 10 f0       	push   $0xf0106a65
f0101beb:	68 40 04 00 00       	push   $0x440
f0101bf0:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101bf5:	e8 46 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bfa:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bff:	74 19                	je     f0101c1a <mem_init+0x7b3>
f0101c01:	68 3d 6c 10 f0       	push   $0xf0106c3d
f0101c06:	68 65 6a 10 f0       	push   $0xf0106a65
f0101c0b:	68 41 04 00 00       	push   $0x441
f0101c10:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101c15:	e8 26 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c1d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c22:	74 19                	je     f0101c3d <mem_init+0x7d6>
f0101c24:	68 4e 6c 10 f0       	push   $0xf0106c4e
f0101c29:	68 65 6a 10 f0       	push   $0xf0106a65
f0101c2e:	68 42 04 00 00       	push   $0x442
f0101c33:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101c38:	e8 03 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c3d:	6a 02                	push   $0x2
f0101c3f:	68 00 10 00 00       	push   $0x1000
f0101c44:	56                   	push   %esi
f0101c45:	57                   	push   %edi
f0101c46:	e8 34 f7 ff ff       	call   f010137f <page_insert>
f0101c4b:	83 c4 10             	add    $0x10,%esp
f0101c4e:	85 c0                	test   %eax,%eax
f0101c50:	74 19                	je     f0101c6b <mem_init+0x804>
f0101c52:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0101c57:	68 65 6a 10 f0       	push   $0xf0106a65
f0101c5c:	68 45 04 00 00       	push   $0x445
f0101c61:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101c66:	e8 d5 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c70:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f0101c75:	e8 08 f0 ff ff       	call   f0100c82 <check_va2pa>
f0101c7a:	89 f2                	mov    %esi,%edx
f0101c7c:	2b 15 90 8e 20 f0    	sub    0xf0208e90,%edx
f0101c82:	c1 fa 03             	sar    $0x3,%edx
f0101c85:	c1 e2 0c             	shl    $0xc,%edx
f0101c88:	39 d0                	cmp    %edx,%eax
f0101c8a:	74 19                	je     f0101ca5 <mem_init+0x83e>
f0101c8c:	68 24 70 10 f0       	push   $0xf0107024
f0101c91:	68 65 6a 10 f0       	push   $0xf0106a65
f0101c96:	68 46 04 00 00       	push   $0x446
f0101c9b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101ca0:	e8 9b e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101caa:	74 19                	je     f0101cc5 <mem_init+0x85e>
f0101cac:	68 5f 6c 10 f0       	push   $0xf0106c5f
f0101cb1:	68 65 6a 10 f0       	push   $0xf0106a65
f0101cb6:	68 47 04 00 00       	push   $0x447
f0101cbb:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101cc0:	e8 7b e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cc5:	83 ec 0c             	sub    $0xc,%esp
f0101cc8:	6a 00                	push   $0x0
f0101cca:	e8 08 f4 ff ff       	call   f01010d7 <page_alloc>
f0101ccf:	83 c4 10             	add    $0x10,%esp
f0101cd2:	85 c0                	test   %eax,%eax
f0101cd4:	74 19                	je     f0101cef <mem_init+0x888>
f0101cd6:	68 eb 6b 10 f0       	push   $0xf0106beb
f0101cdb:	68 65 6a 10 f0       	push   $0xf0106a65
f0101ce0:	68 4a 04 00 00       	push   $0x44a
f0101ce5:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101cea:	e8 51 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cef:	6a 02                	push   $0x2
f0101cf1:	68 00 10 00 00       	push   $0x1000
f0101cf6:	56                   	push   %esi
f0101cf7:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101cfd:	e8 7d f6 ff ff       	call   f010137f <page_insert>
f0101d02:	83 c4 10             	add    $0x10,%esp
f0101d05:	85 c0                	test   %eax,%eax
f0101d07:	74 19                	je     f0101d22 <mem_init+0x8bb>
f0101d09:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0101d0e:	68 65 6a 10 f0       	push   $0xf0106a65
f0101d13:	68 4d 04 00 00       	push   $0x44d
f0101d18:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101d1d:	e8 1e e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d27:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f0101d2c:	e8 51 ef ff ff       	call   f0100c82 <check_va2pa>
f0101d31:	89 f2                	mov    %esi,%edx
f0101d33:	2b 15 90 8e 20 f0    	sub    0xf0208e90,%edx
f0101d39:	c1 fa 03             	sar    $0x3,%edx
f0101d3c:	c1 e2 0c             	shl    $0xc,%edx
f0101d3f:	39 d0                	cmp    %edx,%eax
f0101d41:	74 19                	je     f0101d5c <mem_init+0x8f5>
f0101d43:	68 24 70 10 f0       	push   $0xf0107024
f0101d48:	68 65 6a 10 f0       	push   $0xf0106a65
f0101d4d:	68 4e 04 00 00       	push   $0x44e
f0101d52:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101d57:	e8 e4 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d5c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d61:	74 19                	je     f0101d7c <mem_init+0x915>
f0101d63:	68 5f 6c 10 f0       	push   $0xf0106c5f
f0101d68:	68 65 6a 10 f0       	push   $0xf0106a65
f0101d6d:	68 4f 04 00 00       	push   $0x44f
f0101d72:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101d77:	e8 c4 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d7c:	83 ec 0c             	sub    $0xc,%esp
f0101d7f:	6a 00                	push   $0x0
f0101d81:	e8 51 f3 ff ff       	call   f01010d7 <page_alloc>
f0101d86:	83 c4 10             	add    $0x10,%esp
f0101d89:	85 c0                	test   %eax,%eax
f0101d8b:	74 19                	je     f0101da6 <mem_init+0x93f>
f0101d8d:	68 eb 6b 10 f0       	push   $0xf0106beb
f0101d92:	68 65 6a 10 f0       	push   $0xf0106a65
f0101d97:	68 53 04 00 00       	push   $0x453
f0101d9c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101da1:	e8 9a e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101da6:	8b 15 8c 8e 20 f0    	mov    0xf0208e8c,%edx
f0101dac:	8b 02                	mov    (%edx),%eax
f0101dae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101db3:	89 c1                	mov    %eax,%ecx
f0101db5:	c1 e9 0c             	shr    $0xc,%ecx
f0101db8:	3b 0d 88 8e 20 f0    	cmp    0xf0208e88,%ecx
f0101dbe:	72 15                	jb     f0101dd5 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dc0:	50                   	push   %eax
f0101dc1:	68 c4 62 10 f0       	push   $0xf01062c4
f0101dc6:	68 56 04 00 00       	push   $0x456
f0101dcb:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101dd0:	e8 6b e2 ff ff       	call   f0100040 <_panic>
f0101dd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ddd:	83 ec 04             	sub    $0x4,%esp
f0101de0:	6a 00                	push   $0x0
f0101de2:	68 00 10 00 00       	push   $0x1000
f0101de7:	52                   	push   %edx
f0101de8:	e8 bc f3 ff ff       	call   f01011a9 <pgdir_walk>
f0101ded:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101df0:	8d 51 04             	lea    0x4(%ecx),%edx
f0101df3:	83 c4 10             	add    $0x10,%esp
f0101df6:	39 d0                	cmp    %edx,%eax
f0101df8:	74 19                	je     f0101e13 <mem_init+0x9ac>
f0101dfa:	68 54 70 10 f0       	push   $0xf0107054
f0101dff:	68 65 6a 10 f0       	push   $0xf0106a65
f0101e04:	68 57 04 00 00       	push   $0x457
f0101e09:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101e0e:	e8 2d e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e13:	6a 06                	push   $0x6
f0101e15:	68 00 10 00 00       	push   $0x1000
f0101e1a:	56                   	push   %esi
f0101e1b:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101e21:	e8 59 f5 ff ff       	call   f010137f <page_insert>
f0101e26:	83 c4 10             	add    $0x10,%esp
f0101e29:	85 c0                	test   %eax,%eax
f0101e2b:	74 19                	je     f0101e46 <mem_init+0x9df>
f0101e2d:	68 94 70 10 f0       	push   $0xf0107094
f0101e32:	68 65 6a 10 f0       	push   $0xf0106a65
f0101e37:	68 5a 04 00 00       	push   $0x45a
f0101e3c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101e41:	e8 fa e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e46:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi
f0101e4c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e51:	89 f8                	mov    %edi,%eax
f0101e53:	e8 2a ee ff ff       	call   f0100c82 <check_va2pa>
f0101e58:	89 f2                	mov    %esi,%edx
f0101e5a:	2b 15 90 8e 20 f0    	sub    0xf0208e90,%edx
f0101e60:	c1 fa 03             	sar    $0x3,%edx
f0101e63:	c1 e2 0c             	shl    $0xc,%edx
f0101e66:	39 d0                	cmp    %edx,%eax
f0101e68:	74 19                	je     f0101e83 <mem_init+0xa1c>
f0101e6a:	68 24 70 10 f0       	push   $0xf0107024
f0101e6f:	68 65 6a 10 f0       	push   $0xf0106a65
f0101e74:	68 5b 04 00 00       	push   $0x45b
f0101e79:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101e7e:	e8 bd e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e83:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e88:	74 19                	je     f0101ea3 <mem_init+0xa3c>
f0101e8a:	68 5f 6c 10 f0       	push   $0xf0106c5f
f0101e8f:	68 65 6a 10 f0       	push   $0xf0106a65
f0101e94:	68 5c 04 00 00       	push   $0x45c
f0101e99:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101e9e:	e8 9d e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ea3:	83 ec 04             	sub    $0x4,%esp
f0101ea6:	6a 00                	push   $0x0
f0101ea8:	68 00 10 00 00       	push   $0x1000
f0101ead:	57                   	push   %edi
f0101eae:	e8 f6 f2 ff ff       	call   f01011a9 <pgdir_walk>
f0101eb3:	83 c4 10             	add    $0x10,%esp
f0101eb6:	f6 00 04             	testb  $0x4,(%eax)
f0101eb9:	75 19                	jne    f0101ed4 <mem_init+0xa6d>
f0101ebb:	68 d4 70 10 f0       	push   $0xf01070d4
f0101ec0:	68 65 6a 10 f0       	push   $0xf0106a65
f0101ec5:	68 5d 04 00 00       	push   $0x45d
f0101eca:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101ecf:	e8 6c e1 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ed4:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f0101ed9:	f6 00 04             	testb  $0x4,(%eax)
f0101edc:	75 19                	jne    f0101ef7 <mem_init+0xa90>
f0101ede:	68 70 6c 10 f0       	push   $0xf0106c70
f0101ee3:	68 65 6a 10 f0       	push   $0xf0106a65
f0101ee8:	68 5e 04 00 00       	push   $0x45e
f0101eed:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101ef2:	e8 49 e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ef7:	6a 02                	push   $0x2
f0101ef9:	68 00 10 00 00       	push   $0x1000
f0101efe:	56                   	push   %esi
f0101eff:	50                   	push   %eax
f0101f00:	e8 7a f4 ff ff       	call   f010137f <page_insert>
f0101f05:	83 c4 10             	add    $0x10,%esp
f0101f08:	85 c0                	test   %eax,%eax
f0101f0a:	74 19                	je     f0101f25 <mem_init+0xabe>
f0101f0c:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0101f11:	68 65 6a 10 f0       	push   $0xf0106a65
f0101f16:	68 61 04 00 00       	push   $0x461
f0101f1b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101f20:	e8 1b e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f25:	83 ec 04             	sub    $0x4,%esp
f0101f28:	6a 00                	push   $0x0
f0101f2a:	68 00 10 00 00       	push   $0x1000
f0101f2f:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101f35:	e8 6f f2 ff ff       	call   f01011a9 <pgdir_walk>
f0101f3a:	83 c4 10             	add    $0x10,%esp
f0101f3d:	f6 00 02             	testb  $0x2,(%eax)
f0101f40:	75 19                	jne    f0101f5b <mem_init+0xaf4>
f0101f42:	68 08 71 10 f0       	push   $0xf0107108
f0101f47:	68 65 6a 10 f0       	push   $0xf0106a65
f0101f4c:	68 62 04 00 00       	push   $0x462
f0101f51:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101f56:	e8 e5 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5b:	83 ec 04             	sub    $0x4,%esp
f0101f5e:	6a 00                	push   $0x0
f0101f60:	68 00 10 00 00       	push   $0x1000
f0101f65:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101f6b:	e8 39 f2 ff ff       	call   f01011a9 <pgdir_walk>
f0101f70:	83 c4 10             	add    $0x10,%esp
f0101f73:	f6 00 04             	testb  $0x4,(%eax)
f0101f76:	74 19                	je     f0101f91 <mem_init+0xb2a>
f0101f78:	68 3c 71 10 f0       	push   $0xf010713c
f0101f7d:	68 65 6a 10 f0       	push   $0xf0106a65
f0101f82:	68 63 04 00 00       	push   $0x463
f0101f87:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101f8c:	e8 af e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f91:	6a 02                	push   $0x2
f0101f93:	68 00 00 40 00       	push   $0x400000
f0101f98:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f9b:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101fa1:	e8 d9 f3 ff ff       	call   f010137f <page_insert>
f0101fa6:	83 c4 10             	add    $0x10,%esp
f0101fa9:	85 c0                	test   %eax,%eax
f0101fab:	78 19                	js     f0101fc6 <mem_init+0xb5f>
f0101fad:	68 74 71 10 f0       	push   $0xf0107174
f0101fb2:	68 65 6a 10 f0       	push   $0xf0106a65
f0101fb7:	68 66 04 00 00       	push   $0x466
f0101fbc:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101fc1:	e8 7a e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fc6:	6a 02                	push   $0x2
f0101fc8:	68 00 10 00 00       	push   $0x1000
f0101fcd:	53                   	push   %ebx
f0101fce:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0101fd4:	e8 a6 f3 ff ff       	call   f010137f <page_insert>
f0101fd9:	83 c4 10             	add    $0x10,%esp
f0101fdc:	85 c0                	test   %eax,%eax
f0101fde:	74 19                	je     f0101ff9 <mem_init+0xb92>
f0101fe0:	68 ac 71 10 f0       	push   $0xf01071ac
f0101fe5:	68 65 6a 10 f0       	push   $0xf0106a65
f0101fea:	68 69 04 00 00       	push   $0x469
f0101fef:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101ff4:	e8 47 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ff9:	83 ec 04             	sub    $0x4,%esp
f0101ffc:	6a 00                	push   $0x0
f0101ffe:	68 00 10 00 00       	push   $0x1000
f0102003:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102009:	e8 9b f1 ff ff       	call   f01011a9 <pgdir_walk>
f010200e:	83 c4 10             	add    $0x10,%esp
f0102011:	f6 00 04             	testb  $0x4,(%eax)
f0102014:	74 19                	je     f010202f <mem_init+0xbc8>
f0102016:	68 3c 71 10 f0       	push   $0xf010713c
f010201b:	68 65 6a 10 f0       	push   $0xf0106a65
f0102020:	68 6a 04 00 00       	push   $0x46a
f0102025:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010202a:	e8 11 e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010202f:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi
f0102035:	ba 00 00 00 00       	mov    $0x0,%edx
f010203a:	89 f8                	mov    %edi,%eax
f010203c:	e8 41 ec ff ff       	call   f0100c82 <check_va2pa>
f0102041:	89 c1                	mov    %eax,%ecx
f0102043:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102046:	89 d8                	mov    %ebx,%eax
f0102048:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f010204e:	c1 f8 03             	sar    $0x3,%eax
f0102051:	c1 e0 0c             	shl    $0xc,%eax
f0102054:	39 c1                	cmp    %eax,%ecx
f0102056:	74 19                	je     f0102071 <mem_init+0xc0a>
f0102058:	68 e8 71 10 f0       	push   $0xf01071e8
f010205d:	68 65 6a 10 f0       	push   $0xf0106a65
f0102062:	68 6d 04 00 00       	push   $0x46d
f0102067:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010206c:	e8 cf df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102071:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102076:	89 f8                	mov    %edi,%eax
f0102078:	e8 05 ec ff ff       	call   f0100c82 <check_va2pa>
f010207d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102080:	74 19                	je     f010209b <mem_init+0xc34>
f0102082:	68 14 72 10 f0       	push   $0xf0107214
f0102087:	68 65 6a 10 f0       	push   $0xf0106a65
f010208c:	68 6e 04 00 00       	push   $0x46e
f0102091:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102096:	e8 a5 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010209b:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01020a0:	74 19                	je     f01020bb <mem_init+0xc54>
f01020a2:	68 86 6c 10 f0       	push   $0xf0106c86
f01020a7:	68 65 6a 10 f0       	push   $0xf0106a65
f01020ac:	68 70 04 00 00       	push   $0x470
f01020b1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01020b6:	e8 85 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020bb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020c0:	74 19                	je     f01020db <mem_init+0xc74>
f01020c2:	68 97 6c 10 f0       	push   $0xf0106c97
f01020c7:	68 65 6a 10 f0       	push   $0xf0106a65
f01020cc:	68 71 04 00 00       	push   $0x471
f01020d1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01020d6:	e8 65 df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020db:	83 ec 0c             	sub    $0xc,%esp
f01020de:	6a 00                	push   $0x0
f01020e0:	e8 f2 ef ff ff       	call   f01010d7 <page_alloc>
f01020e5:	83 c4 10             	add    $0x10,%esp
f01020e8:	85 c0                	test   %eax,%eax
f01020ea:	74 04                	je     f01020f0 <mem_init+0xc89>
f01020ec:	39 c6                	cmp    %eax,%esi
f01020ee:	74 19                	je     f0102109 <mem_init+0xca2>
f01020f0:	68 44 72 10 f0       	push   $0xf0107244
f01020f5:	68 65 6a 10 f0       	push   $0xf0106a65
f01020fa:	68 74 04 00 00       	push   $0x474
f01020ff:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102104:	e8 37 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102109:	83 ec 08             	sub    $0x8,%esp
f010210c:	6a 00                	push   $0x0
f010210e:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102114:	e8 11 f2 ff ff       	call   f010132a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102119:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi
f010211f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102124:	89 f8                	mov    %edi,%eax
f0102126:	e8 57 eb ff ff       	call   f0100c82 <check_va2pa>
f010212b:	83 c4 10             	add    $0x10,%esp
f010212e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102131:	74 19                	je     f010214c <mem_init+0xce5>
f0102133:	68 68 72 10 f0       	push   $0xf0107268
f0102138:	68 65 6a 10 f0       	push   $0xf0106a65
f010213d:	68 78 04 00 00       	push   $0x478
f0102142:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102147:	e8 f4 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010214c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102151:	89 f8                	mov    %edi,%eax
f0102153:	e8 2a eb ff ff       	call   f0100c82 <check_va2pa>
f0102158:	89 da                	mov    %ebx,%edx
f010215a:	2b 15 90 8e 20 f0    	sub    0xf0208e90,%edx
f0102160:	c1 fa 03             	sar    $0x3,%edx
f0102163:	c1 e2 0c             	shl    $0xc,%edx
f0102166:	39 d0                	cmp    %edx,%eax
f0102168:	74 19                	je     f0102183 <mem_init+0xd1c>
f010216a:	68 14 72 10 f0       	push   $0xf0107214
f010216f:	68 65 6a 10 f0       	push   $0xf0106a65
f0102174:	68 79 04 00 00       	push   $0x479
f0102179:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010217e:	e8 bd de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102183:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102188:	74 19                	je     f01021a3 <mem_init+0xd3c>
f010218a:	68 3d 6c 10 f0       	push   $0xf0106c3d
f010218f:	68 65 6a 10 f0       	push   $0xf0106a65
f0102194:	68 7a 04 00 00       	push   $0x47a
f0102199:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010219e:	e8 9d de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021a3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021a8:	74 19                	je     f01021c3 <mem_init+0xd5c>
f01021aa:	68 97 6c 10 f0       	push   $0xf0106c97
f01021af:	68 65 6a 10 f0       	push   $0xf0106a65
f01021b4:	68 7b 04 00 00       	push   $0x47b
f01021b9:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01021be:	e8 7d de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021c3:	6a 00                	push   $0x0
f01021c5:	68 00 10 00 00       	push   $0x1000
f01021ca:	53                   	push   %ebx
f01021cb:	57                   	push   %edi
f01021cc:	e8 ae f1 ff ff       	call   f010137f <page_insert>
f01021d1:	83 c4 10             	add    $0x10,%esp
f01021d4:	85 c0                	test   %eax,%eax
f01021d6:	74 19                	je     f01021f1 <mem_init+0xd8a>
f01021d8:	68 8c 72 10 f0       	push   $0xf010728c
f01021dd:	68 65 6a 10 f0       	push   $0xf0106a65
f01021e2:	68 7e 04 00 00       	push   $0x47e
f01021e7:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01021ec:	e8 4f de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021f1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f6:	75 19                	jne    f0102211 <mem_init+0xdaa>
f01021f8:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01021fd:	68 65 6a 10 f0       	push   $0xf0106a65
f0102202:	68 7f 04 00 00       	push   $0x47f
f0102207:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010220c:	e8 2f de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102211:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102214:	74 19                	je     f010222f <mem_init+0xdc8>
f0102216:	68 b4 6c 10 f0       	push   $0xf0106cb4
f010221b:	68 65 6a 10 f0       	push   $0xf0106a65
f0102220:	68 80 04 00 00       	push   $0x480
f0102225:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010222a:	e8 11 de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010222f:	83 ec 08             	sub    $0x8,%esp
f0102232:	68 00 10 00 00       	push   $0x1000
f0102237:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f010223d:	e8 e8 f0 ff ff       	call   f010132a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102242:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi
f0102248:	ba 00 00 00 00       	mov    $0x0,%edx
f010224d:	89 f8                	mov    %edi,%eax
f010224f:	e8 2e ea ff ff       	call   f0100c82 <check_va2pa>
f0102254:	83 c4 10             	add    $0x10,%esp
f0102257:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225a:	74 19                	je     f0102275 <mem_init+0xe0e>
f010225c:	68 68 72 10 f0       	push   $0xf0107268
f0102261:	68 65 6a 10 f0       	push   $0xf0106a65
f0102266:	68 84 04 00 00       	push   $0x484
f010226b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102270:	e8 cb dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102275:	ba 00 10 00 00       	mov    $0x1000,%edx
f010227a:	89 f8                	mov    %edi,%eax
f010227c:	e8 01 ea ff ff       	call   f0100c82 <check_va2pa>
f0102281:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102284:	74 19                	je     f010229f <mem_init+0xe38>
f0102286:	68 c4 72 10 f0       	push   $0xf01072c4
f010228b:	68 65 6a 10 f0       	push   $0xf0106a65
f0102290:	68 85 04 00 00       	push   $0x485
f0102295:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010229a:	e8 a1 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010229f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a4:	74 19                	je     f01022bf <mem_init+0xe58>
f01022a6:	68 c9 6c 10 f0       	push   $0xf0106cc9
f01022ab:	68 65 6a 10 f0       	push   $0xf0106a65
f01022b0:	68 86 04 00 00       	push   $0x486
f01022b5:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01022ba:	e8 81 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022bf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c4:	74 19                	je     f01022df <mem_init+0xe78>
f01022c6:	68 97 6c 10 f0       	push   $0xf0106c97
f01022cb:	68 65 6a 10 f0       	push   $0xf0106a65
f01022d0:	68 87 04 00 00       	push   $0x487
f01022d5:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01022da:	e8 61 dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022df:	83 ec 0c             	sub    $0xc,%esp
f01022e2:	6a 00                	push   $0x0
f01022e4:	e8 ee ed ff ff       	call   f01010d7 <page_alloc>
f01022e9:	83 c4 10             	add    $0x10,%esp
f01022ec:	39 c3                	cmp    %eax,%ebx
f01022ee:	75 04                	jne    f01022f4 <mem_init+0xe8d>
f01022f0:	85 c0                	test   %eax,%eax
f01022f2:	75 19                	jne    f010230d <mem_init+0xea6>
f01022f4:	68 ec 72 10 f0       	push   $0xf01072ec
f01022f9:	68 65 6a 10 f0       	push   $0xf0106a65
f01022fe:	68 8a 04 00 00       	push   $0x48a
f0102303:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102308:	e8 33 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010230d:	83 ec 0c             	sub    $0xc,%esp
f0102310:	6a 00                	push   $0x0
f0102312:	e8 c0 ed ff ff       	call   f01010d7 <page_alloc>
f0102317:	83 c4 10             	add    $0x10,%esp
f010231a:	85 c0                	test   %eax,%eax
f010231c:	74 19                	je     f0102337 <mem_init+0xed0>
f010231e:	68 eb 6b 10 f0       	push   $0xf0106beb
f0102323:	68 65 6a 10 f0       	push   $0xf0106a65
f0102328:	68 8d 04 00 00       	push   $0x48d
f010232d:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102337:	8b 0d 8c 8e 20 f0    	mov    0xf0208e8c,%ecx
f010233d:	8b 11                	mov    (%ecx),%edx
f010233f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102345:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102348:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f010234e:	c1 f8 03             	sar    $0x3,%eax
f0102351:	c1 e0 0c             	shl    $0xc,%eax
f0102354:	39 c2                	cmp    %eax,%edx
f0102356:	74 19                	je     f0102371 <mem_init+0xf0a>
f0102358:	68 90 6f 10 f0       	push   $0xf0106f90
f010235d:	68 65 6a 10 f0       	push   $0xf0106a65
f0102362:	68 90 04 00 00       	push   $0x490
f0102367:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010236c:	e8 cf dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102371:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102377:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010237a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010237f:	74 19                	je     f010239a <mem_init+0xf33>
f0102381:	68 4e 6c 10 f0       	push   $0xf0106c4e
f0102386:	68 65 6a 10 f0       	push   $0xf0106a65
f010238b:	68 92 04 00 00       	push   $0x492
f0102390:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102395:	e8 a6 dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010239a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010239d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023a3:	83 ec 0c             	sub    $0xc,%esp
f01023a6:	50                   	push   %eax
f01023a7:	e8 9b ed ff ff       	call   f0101147 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023ac:	83 c4 0c             	add    $0xc,%esp
f01023af:	6a 01                	push   $0x1
f01023b1:	68 00 10 40 00       	push   $0x401000
f01023b6:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f01023bc:	e8 e8 ed ff ff       	call   f01011a9 <pgdir_walk>
f01023c1:	89 c7                	mov    %eax,%edi
f01023c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c6:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f01023cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023ce:	8b 40 04             	mov    0x4(%eax),%eax
f01023d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d6:	8b 0d 88 8e 20 f0    	mov    0xf0208e88,%ecx
f01023dc:	89 c2                	mov    %eax,%edx
f01023de:	c1 ea 0c             	shr    $0xc,%edx
f01023e1:	83 c4 10             	add    $0x10,%esp
f01023e4:	39 ca                	cmp    %ecx,%edx
f01023e6:	72 15                	jb     f01023fd <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e8:	50                   	push   %eax
f01023e9:	68 c4 62 10 f0       	push   $0xf01062c4
f01023ee:	68 99 04 00 00       	push   $0x499
f01023f3:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01023f8:	e8 43 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023fd:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102402:	39 c7                	cmp    %eax,%edi
f0102404:	74 19                	je     f010241f <mem_init+0xfb8>
f0102406:	68 da 6c 10 f0       	push   $0xf0106cda
f010240b:	68 65 6a 10 f0       	push   $0xf0106a65
f0102410:	68 9a 04 00 00       	push   $0x49a
f0102415:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010241a:	e8 21 dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010241f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102422:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102429:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102432:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0102438:	c1 f8 03             	sar    $0x3,%eax
f010243b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010243e:	89 c2                	mov    %eax,%edx
f0102440:	c1 ea 0c             	shr    $0xc,%edx
f0102443:	39 d1                	cmp    %edx,%ecx
f0102445:	77 12                	ja     f0102459 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102447:	50                   	push   %eax
f0102448:	68 c4 62 10 f0       	push   $0xf01062c4
f010244d:	6a 58                	push   $0x58
f010244f:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0102454:	e8 e7 db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102459:	83 ec 04             	sub    $0x4,%esp
f010245c:	68 00 10 00 00       	push   $0x1000
f0102461:	68 ff 00 00 00       	push   $0xff
f0102466:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010246b:	50                   	push   %eax
f010246c:	e8 67 31 00 00       	call   f01055d8 <memset>
	page_free(pp0);
f0102471:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102474:	89 3c 24             	mov    %edi,(%esp)
f0102477:	e8 cb ec ff ff       	call   f0101147 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010247c:	83 c4 0c             	add    $0xc,%esp
f010247f:	6a 01                	push   $0x1
f0102481:	6a 00                	push   $0x0
f0102483:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102489:	e8 1b ed ff ff       	call   f01011a9 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010248e:	89 fa                	mov    %edi,%edx
f0102490:	2b 15 90 8e 20 f0    	sub    0xf0208e90,%edx
f0102496:	c1 fa 03             	sar    $0x3,%edx
f0102499:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010249c:	89 d0                	mov    %edx,%eax
f010249e:	c1 e8 0c             	shr    $0xc,%eax
f01024a1:	83 c4 10             	add    $0x10,%esp
f01024a4:	3b 05 88 8e 20 f0    	cmp    0xf0208e88,%eax
f01024aa:	72 12                	jb     f01024be <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ac:	52                   	push   %edx
f01024ad:	68 c4 62 10 f0       	push   $0xf01062c4
f01024b2:	6a 58                	push   $0x58
f01024b4:	68 4b 6a 10 f0       	push   $0xf0106a4b
f01024b9:	e8 82 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01024be:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024c7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024cd:	f6 00 01             	testb  $0x1,(%eax)
f01024d0:	74 19                	je     f01024eb <mem_init+0x1084>
f01024d2:	68 f2 6c 10 f0       	push   $0xf0106cf2
f01024d7:	68 65 6a 10 f0       	push   $0xf0106a65
f01024dc:	68 a4 04 00 00       	push   $0x4a4
f01024e1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01024e6:	e8 55 db ff ff       	call   f0100040 <_panic>
f01024eb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024ee:	39 c2                	cmp    %eax,%edx
f01024f0:	75 db                	jne    f01024cd <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024f2:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f01024f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102500:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102506:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102509:	89 0d 40 82 20 f0    	mov    %ecx,0xf0208240

	// free the pages we took
	page_free(pp0);
f010250f:	83 ec 0c             	sub    $0xc,%esp
f0102512:	50                   	push   %eax
f0102513:	e8 2f ec ff ff       	call   f0101147 <page_free>
	page_free(pp1);
f0102518:	89 1c 24             	mov    %ebx,(%esp)
f010251b:	e8 27 ec ff ff       	call   f0101147 <page_free>
	page_free(pp2);
f0102520:	89 34 24             	mov    %esi,(%esp)
f0102523:	e8 1f ec ff ff       	call   f0101147 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102528:	83 c4 08             	add    $0x8,%esp
f010252b:	68 01 10 00 00       	push   $0x1001
f0102530:	6a 00                	push   $0x0
f0102532:	e8 c6 ee ff ff       	call   f01013fd <mmio_map_region>
f0102537:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102539:	83 c4 08             	add    $0x8,%esp
f010253c:	68 00 10 00 00       	push   $0x1000
f0102541:	6a 00                	push   $0x0
f0102543:	e8 b5 ee ff ff       	call   f01013fd <mmio_map_region>
f0102548:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010254a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102550:	83 c4 10             	add    $0x10,%esp
f0102553:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102559:	76 07                	jbe    f0102562 <mem_init+0x10fb>
f010255b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102560:	76 19                	jbe    f010257b <mem_init+0x1114>
f0102562:	68 10 73 10 f0       	push   $0xf0107310
f0102567:	68 65 6a 10 f0       	push   $0xf0106a65
f010256c:	68 b4 04 00 00       	push   $0x4b4
f0102571:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102576:	e8 c5 da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010257b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102581:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102587:	77 08                	ja     f0102591 <mem_init+0x112a>
f0102589:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010258f:	77 19                	ja     f01025aa <mem_init+0x1143>
f0102591:	68 38 73 10 f0       	push   $0xf0107338
f0102596:	68 65 6a 10 f0       	push   $0xf0106a65
f010259b:	68 b5 04 00 00       	push   $0x4b5
f01025a0:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01025a5:	e8 96 da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025aa:	89 da                	mov    %ebx,%edx
f01025ac:	09 f2                	or     %esi,%edx
f01025ae:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025b4:	74 19                	je     f01025cf <mem_init+0x1168>
f01025b6:	68 60 73 10 f0       	push   $0xf0107360
f01025bb:	68 65 6a 10 f0       	push   $0xf0106a65
f01025c0:	68 b7 04 00 00       	push   $0x4b7
f01025c5:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01025ca:	e8 71 da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01025cf:	39 c6                	cmp    %eax,%esi
f01025d1:	73 19                	jae    f01025ec <mem_init+0x1185>
f01025d3:	68 09 6d 10 f0       	push   $0xf0106d09
f01025d8:	68 65 6a 10 f0       	push   $0xf0106a65
f01025dd:	68 b9 04 00 00       	push   $0x4b9
f01025e2:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01025e7:	e8 54 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025ec:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi
f01025f2:	89 da                	mov    %ebx,%edx
f01025f4:	89 f8                	mov    %edi,%eax
f01025f6:	e8 87 e6 ff ff       	call   f0100c82 <check_va2pa>
f01025fb:	85 c0                	test   %eax,%eax
f01025fd:	74 19                	je     f0102618 <mem_init+0x11b1>
f01025ff:	68 88 73 10 f0       	push   $0xf0107388
f0102604:	68 65 6a 10 f0       	push   $0xf0106a65
f0102609:	68 bb 04 00 00       	push   $0x4bb
f010260e:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102613:	e8 28 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102618:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010261e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102621:	89 c2                	mov    %eax,%edx
f0102623:	89 f8                	mov    %edi,%eax
f0102625:	e8 58 e6 ff ff       	call   f0100c82 <check_va2pa>
f010262a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010262f:	74 19                	je     f010264a <mem_init+0x11e3>
f0102631:	68 ac 73 10 f0       	push   $0xf01073ac
f0102636:	68 65 6a 10 f0       	push   $0xf0106a65
f010263b:	68 bc 04 00 00       	push   $0x4bc
f0102640:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102645:	e8 f6 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010264a:	89 f2                	mov    %esi,%edx
f010264c:	89 f8                	mov    %edi,%eax
f010264e:	e8 2f e6 ff ff       	call   f0100c82 <check_va2pa>
f0102653:	85 c0                	test   %eax,%eax
f0102655:	74 19                	je     f0102670 <mem_init+0x1209>
f0102657:	68 dc 73 10 f0       	push   $0xf01073dc
f010265c:	68 65 6a 10 f0       	push   $0xf0106a65
f0102661:	68 bd 04 00 00       	push   $0x4bd
f0102666:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010266b:	e8 d0 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102670:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102676:	89 f8                	mov    %edi,%eax
f0102678:	e8 05 e6 ff ff       	call   f0100c82 <check_va2pa>
f010267d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102680:	74 19                	je     f010269b <mem_init+0x1234>
f0102682:	68 00 74 10 f0       	push   $0xf0107400
f0102687:	68 65 6a 10 f0       	push   $0xf0106a65
f010268c:	68 be 04 00 00       	push   $0x4be
f0102691:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102696:	e8 a5 d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010269b:	83 ec 04             	sub    $0x4,%esp
f010269e:	6a 00                	push   $0x0
f01026a0:	53                   	push   %ebx
f01026a1:	57                   	push   %edi
f01026a2:	e8 02 eb ff ff       	call   f01011a9 <pgdir_walk>
f01026a7:	83 c4 10             	add    $0x10,%esp
f01026aa:	f6 00 1a             	testb  $0x1a,(%eax)
f01026ad:	75 19                	jne    f01026c8 <mem_init+0x1261>
f01026af:	68 2c 74 10 f0       	push   $0xf010742c
f01026b4:	68 65 6a 10 f0       	push   $0xf0106a65
f01026b9:	68 c0 04 00 00       	push   $0x4c0
f01026be:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01026c3:	e8 78 d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026c8:	83 ec 04             	sub    $0x4,%esp
f01026cb:	6a 00                	push   $0x0
f01026cd:	53                   	push   %ebx
f01026ce:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f01026d4:	e8 d0 ea ff ff       	call   f01011a9 <pgdir_walk>
f01026d9:	8b 00                	mov    (%eax),%eax
f01026db:	83 c4 10             	add    $0x10,%esp
f01026de:	83 e0 04             	and    $0x4,%eax
f01026e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026e4:	74 19                	je     f01026ff <mem_init+0x1298>
f01026e6:	68 70 74 10 f0       	push   $0xf0107470
f01026eb:	68 65 6a 10 f0       	push   $0xf0106a65
f01026f0:	68 c1 04 00 00       	push   $0x4c1
f01026f5:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01026fa:	e8 41 d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026ff:	83 ec 04             	sub    $0x4,%esp
f0102702:	6a 00                	push   $0x0
f0102704:	53                   	push   %ebx
f0102705:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f010270b:	e8 99 ea ff ff       	call   f01011a9 <pgdir_walk>
f0102710:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102716:	83 c4 0c             	add    $0xc,%esp
f0102719:	6a 00                	push   $0x0
f010271b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010271e:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102724:	e8 80 ea ff ff       	call   f01011a9 <pgdir_walk>
f0102729:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010272f:	83 c4 0c             	add    $0xc,%esp
f0102732:	6a 00                	push   $0x0
f0102734:	56                   	push   %esi
f0102735:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f010273b:	e8 69 ea ff ff       	call   f01011a9 <pgdir_walk>
f0102740:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102746:	c7 04 24 1b 6d 10 f0 	movl   $0xf0106d1b,(%esp)
f010274d:	e8 b4 10 00 00       	call   f0103806 <cprintf>
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	// edited by Lethe 
	// boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
	// calculate the size of pages
	boot_map_region(kern_pgdir,UPAGES,ROUNDUP((sizeof(struct PageInfo) * npages),PGSIZE)
f0102752:	a1 90 8e 20 f0       	mov    0xf0208e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102757:	83 c4 10             	add    $0x10,%esp
f010275a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010275f:	77 15                	ja     f0102776 <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102761:	50                   	push   %eax
f0102762:	68 e8 62 10 f0       	push   $0xf01062e8
f0102767:	68 d3 00 00 00       	push   $0xd3
f010276c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102771:	e8 ca d8 ff ff       	call   f0100040 <_panic>
f0102776:	8b 15 88 8e 20 f0    	mov    0xf0208e88,%edx
f010277c:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102783:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102789:	83 ec 08             	sub    $0x8,%esp
f010278c:	6a 05                	push   $0x5
f010278e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102793:	50                   	push   %eax
f0102794:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102799:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f010279e:	e8 99 ea ff ff       	call   f010123c <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	// edited by Lethe 
	boot_map_region(kern_pgdir, UENVS, ROUNDUP((sizeof(struct Env) * NENV), PGSIZE)
f01027a3:	a1 48 82 20 f0       	mov    0xf0208248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a8:	83 c4 10             	add    $0x10,%esp
f01027ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027b0:	77 15                	ja     f01027c7 <mem_init+0x1360>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b2:	50                   	push   %eax
f01027b3:	68 e8 62 10 f0       	push   $0xf01062e8
f01027b8:	68 de 00 00 00       	push   $0xde
f01027bd:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01027c2:	e8 79 d8 ff ff       	call   f0100040 <_panic>
f01027c7:	83 ec 08             	sub    $0x8,%esp
f01027ca:	6a 05                	push   $0x5
f01027cc:	05 00 00 00 10       	add    $0x10000000,%eax
f01027d1:	50                   	push   %eax
f01027d2:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01027d7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027dc:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f01027e1:	e8 56 ea ff ff       	call   f010123c <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	// edited by Lethe 
	boot_map_region(kern_pgdir,KERNBASE,ROUNDUP((0xFFFFFFFF-KERNBASE),PGSIZE)
f01027e6:	83 c4 08             	add    $0x8,%esp
f01027e9:	6a 03                	push   $0x3
f01027eb:	6a 00                	push   $0x0
f01027ed:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027f2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027f7:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f01027fc:	e8 3b ea ff ff       	call   f010123c <boot_map_region>
f0102801:	c7 45 c4 00 a0 20 f0 	movl   $0xf020a000,-0x3c(%ebp)
f0102808:	83 c4 10             	add    $0x10,%esp
f010280b:	bb 00 a0 20 f0       	mov    $0xf020a000,%ebx
f0102810:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102815:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010281b:	77 15                	ja     f0102832 <mem_init+0x13cb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010281d:	53                   	push   %ebx
f010281e:	68 e8 62 10 f0       	push   $0xf01062e8
f0102823:	68 38 01 00 00       	push   $0x138
f0102828:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010282d:	e8 0e d8 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	// edited by Lethe 
	// boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir,
f0102832:	83 ec 08             	sub    $0x8,%esp
f0102835:	6a 03                	push   $0x3
f0102837:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010283d:	50                   	push   %eax
f010283e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102843:	89 f2                	mov    %esi,%edx
f0102845:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
f010284a:	e8 ed e9 ff ff       	call   f010123c <boot_map_region>
f010284f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102855:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:
	// edited by Lethe 
	// boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
	int i;
	for (i = 0; i < NCPU; i++) {
f010285b:	83 c4 10             	add    $0x10,%esp
f010285e:	b8 00 a0 24 f0       	mov    $0xf024a000,%eax
f0102863:	39 d8                	cmp    %ebx,%eax
f0102865:	75 ae                	jne    f0102815 <mem_init+0x13ae>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102867:	8b 3d 8c 8e 20 f0    	mov    0xf0208e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010286d:	a1 88 8e 20 f0       	mov    0xf0208e88,%eax
f0102872:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102875:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010287c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102881:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102884:	8b 35 90 8e 20 f0    	mov    0xf0208e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010288a:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010288d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102892:	eb 55                	jmp    f01028e9 <mem_init+0x1482>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102894:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010289a:	89 f8                	mov    %edi,%eax
f010289c:	e8 e1 e3 ff ff       	call   f0100c82 <check_va2pa>
f01028a1:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01028a8:	77 15                	ja     f01028bf <mem_init+0x1458>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028aa:	56                   	push   %esi
f01028ab:	68 e8 62 10 f0       	push   $0xf01062e8
f01028b0:	68 d9 03 00 00       	push   $0x3d9
f01028b5:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01028ba:	e8 81 d7 ff ff       	call   f0100040 <_panic>
f01028bf:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01028c6:	39 c2                	cmp    %eax,%edx
f01028c8:	74 19                	je     f01028e3 <mem_init+0x147c>
f01028ca:	68 a4 74 10 f0       	push   $0xf01074a4
f01028cf:	68 65 6a 10 f0       	push   $0xf0106a65
f01028d4:	68 d9 03 00 00       	push   $0x3d9
f01028d9:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01028de:	e8 5d d7 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028e3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028e9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01028ec:	77 a6                	ja     f0102894 <mem_init+0x142d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028ee:	8b 35 48 82 20 f0    	mov    0xf0208248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028f4:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028f7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028fc:	89 da                	mov    %ebx,%edx
f01028fe:	89 f8                	mov    %edi,%eax
f0102900:	e8 7d e3 ff ff       	call   f0100c82 <check_va2pa>
f0102905:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010290c:	77 15                	ja     f0102923 <mem_init+0x14bc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010290e:	56                   	push   %esi
f010290f:	68 e8 62 10 f0       	push   $0xf01062e8
f0102914:	68 de 03 00 00       	push   $0x3de
f0102919:	68 3f 6a 10 f0       	push   $0xf0106a3f
f010291e:	e8 1d d7 ff ff       	call   f0100040 <_panic>
f0102923:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010292a:	39 d0                	cmp    %edx,%eax
f010292c:	74 19                	je     f0102947 <mem_init+0x14e0>
f010292e:	68 d8 74 10 f0       	push   $0xf01074d8
f0102933:	68 65 6a 10 f0       	push   $0xf0106a65
f0102938:	68 de 03 00 00       	push   $0x3de
f010293d:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102942:	e8 f9 d6 ff ff       	call   f0100040 <_panic>
f0102947:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010294d:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102953:	75 a7                	jne    f01028fc <mem_init+0x1495>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102955:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102958:	c1 e6 0c             	shl    $0xc,%esi
f010295b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102960:	eb 30                	jmp    f0102992 <mem_init+0x152b>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102962:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102968:	89 f8                	mov    %edi,%eax
f010296a:	e8 13 e3 ff ff       	call   f0100c82 <check_va2pa>
f010296f:	39 c3                	cmp    %eax,%ebx
f0102971:	74 19                	je     f010298c <mem_init+0x1525>
f0102973:	68 0c 75 10 f0       	push   $0xf010750c
f0102978:	68 65 6a 10 f0       	push   $0xf0106a65
f010297d:	68 e2 03 00 00       	push   $0x3e2
f0102982:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102987:	e8 b4 d6 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102992:	39 f3                	cmp    %esi,%ebx
f0102994:	72 cc                	jb     f0102962 <mem_init+0x14fb>
f0102996:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010299b:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010299e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029a4:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01029aa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01029ad:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029af:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029b2:	05 00 80 00 20       	add    $0x20008000,%eax
f01029b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029ba:	89 da                	mov    %ebx,%edx
f01029bc:	89 f8                	mov    %edi,%eax
f01029be:	e8 bf e2 ff ff       	call   f0100c82 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029c3:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029c9:	77 15                	ja     f01029e0 <mem_init+0x1579>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029cb:	56                   	push   %esi
f01029cc:	68 e8 62 10 f0       	push   $0xf01062e8
f01029d1:	68 ea 03 00 00       	push   $0x3ea
f01029d6:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01029db:	e8 60 d6 ff ff       	call   f0100040 <_panic>
f01029e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01029e3:	8d 94 0b 00 a0 20 f0 	lea    -0xfdf6000(%ebx,%ecx,1),%edx
f01029ea:	39 d0                	cmp    %edx,%eax
f01029ec:	74 19                	je     f0102a07 <mem_init+0x15a0>
f01029ee:	68 34 75 10 f0       	push   $0xf0107534
f01029f3:	68 65 6a 10 f0       	push   $0xf0106a65
f01029f8:	68 ea 03 00 00       	push   $0x3ea
f01029fd:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102a02:	e8 39 d6 ff ff       	call   f0100040 <_panic>
f0102a07:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a0d:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102a10:	75 a8                	jne    f01029ba <mem_init+0x1553>
f0102a12:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a15:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102a1b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102a1e:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a20:	89 da                	mov    %ebx,%edx
f0102a22:	89 f8                	mov    %edi,%eax
f0102a24:	e8 59 e2 ff ff       	call   f0100c82 <check_va2pa>
f0102a29:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a2c:	74 19                	je     f0102a47 <mem_init+0x15e0>
f0102a2e:	68 7c 75 10 f0       	push   $0xf010757c
f0102a33:	68 65 6a 10 f0       	push   $0xf0106a65
f0102a38:	68 ec 03 00 00       	push   $0x3ec
f0102a3d:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102a42:	e8 f9 d5 ff ff       	call   f0100040 <_panic>
f0102a47:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a4d:	39 de                	cmp    %ebx,%esi
f0102a4f:	75 cf                	jne    f0102a20 <mem_init+0x15b9>
f0102a51:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102a54:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a5b:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a62:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a68:	81 fe 00 a0 24 f0    	cmp    $0xf024a000,%esi
f0102a6e:	0f 85 2d ff ff ff    	jne    f01029a1 <mem_init+0x153a>
f0102a74:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a79:	eb 2a                	jmp    f0102aa5 <mem_init+0x163e>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a7b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a81:	83 fa 04             	cmp    $0x4,%edx
f0102a84:	77 1f                	ja     f0102aa5 <mem_init+0x163e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a86:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a8a:	75 7e                	jne    f0102b0a <mem_init+0x16a3>
f0102a8c:	68 34 6d 10 f0       	push   $0xf0106d34
f0102a91:	68 65 6a 10 f0       	push   $0xf0106a65
f0102a96:	68 f7 03 00 00       	push   $0x3f7
f0102a9b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102aa0:	e8 9b d5 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102aa5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102aaa:	76 3f                	jbe    f0102aeb <mem_init+0x1684>
				assert(pgdir[i] & PTE_P);
f0102aac:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102aaf:	f6 c2 01             	test   $0x1,%dl
f0102ab2:	75 19                	jne    f0102acd <mem_init+0x1666>
f0102ab4:	68 34 6d 10 f0       	push   $0xf0106d34
f0102ab9:	68 65 6a 10 f0       	push   $0xf0106a65
f0102abe:	68 fb 03 00 00       	push   $0x3fb
f0102ac3:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102ac8:	e8 73 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102acd:	f6 c2 02             	test   $0x2,%dl
f0102ad0:	75 38                	jne    f0102b0a <mem_init+0x16a3>
f0102ad2:	68 45 6d 10 f0       	push   $0xf0106d45
f0102ad7:	68 65 6a 10 f0       	push   $0xf0106a65
f0102adc:	68 fc 03 00 00       	push   $0x3fc
f0102ae1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102ae6:	e8 55 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102aeb:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102aef:	74 19                	je     f0102b0a <mem_init+0x16a3>
f0102af1:	68 56 6d 10 f0       	push   $0xf0106d56
f0102af6:	68 65 6a 10 f0       	push   $0xf0106a65
f0102afb:	68 fe 03 00 00       	push   $0x3fe
f0102b00:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102b05:	e8 36 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b0a:	83 c0 01             	add    $0x1,%eax
f0102b0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b12:	0f 86 63 ff ff ff    	jbe    f0102a7b <mem_init+0x1614>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b18:	83 ec 0c             	sub    $0xc,%esp
f0102b1b:	68 a0 75 10 f0       	push   $0xf01075a0
f0102b20:	e8 e1 0c 00 00       	call   f0103806 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b25:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b2a:	83 c4 10             	add    $0x10,%esp
f0102b2d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b32:	77 15                	ja     f0102b49 <mem_init+0x16e2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b34:	50                   	push   %eax
f0102b35:	68 e8 62 10 f0       	push   $0xf01062e8
f0102b3a:	68 0c 01 00 00       	push   $0x10c
f0102b3f:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102b44:	e8 f7 d4 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b49:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b4e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b51:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b56:	e8 8b e1 ff ff       	call   f0100ce6 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102b5b:	0f 20 c0             	mov    %cr0,%eax
f0102b5e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b61:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b66:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b69:	83 ec 0c             	sub    $0xc,%esp
f0102b6c:	6a 00                	push   $0x0
f0102b6e:	e8 64 e5 ff ff       	call   f01010d7 <page_alloc>
f0102b73:	89 c3                	mov    %eax,%ebx
f0102b75:	83 c4 10             	add    $0x10,%esp
f0102b78:	85 c0                	test   %eax,%eax
f0102b7a:	75 19                	jne    f0102b95 <mem_init+0x172e>
f0102b7c:	68 40 6b 10 f0       	push   $0xf0106b40
f0102b81:	68 65 6a 10 f0       	push   $0xf0106a65
f0102b86:	68 d6 04 00 00       	push   $0x4d6
f0102b8b:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102b90:	e8 ab d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b95:	83 ec 0c             	sub    $0xc,%esp
f0102b98:	6a 00                	push   $0x0
f0102b9a:	e8 38 e5 ff ff       	call   f01010d7 <page_alloc>
f0102b9f:	89 c7                	mov    %eax,%edi
f0102ba1:	83 c4 10             	add    $0x10,%esp
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	75 19                	jne    f0102bc1 <mem_init+0x175a>
f0102ba8:	68 56 6b 10 f0       	push   $0xf0106b56
f0102bad:	68 65 6a 10 f0       	push   $0xf0106a65
f0102bb2:	68 d7 04 00 00       	push   $0x4d7
f0102bb7:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102bbc:	e8 7f d4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bc1:	83 ec 0c             	sub    $0xc,%esp
f0102bc4:	6a 00                	push   $0x0
f0102bc6:	e8 0c e5 ff ff       	call   f01010d7 <page_alloc>
f0102bcb:	89 c6                	mov    %eax,%esi
f0102bcd:	83 c4 10             	add    $0x10,%esp
f0102bd0:	85 c0                	test   %eax,%eax
f0102bd2:	75 19                	jne    f0102bed <mem_init+0x1786>
f0102bd4:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0102bd9:	68 65 6a 10 f0       	push   $0xf0106a65
f0102bde:	68 d8 04 00 00       	push   $0x4d8
f0102be3:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102be8:	e8 53 d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102bed:	83 ec 0c             	sub    $0xc,%esp
f0102bf0:	53                   	push   %ebx
f0102bf1:	e8 51 e5 ff ff       	call   f0101147 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf6:	89 f8                	mov    %edi,%eax
f0102bf8:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0102bfe:	c1 f8 03             	sar    $0x3,%eax
f0102c01:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c04:	89 c2                	mov    %eax,%edx
f0102c06:	c1 ea 0c             	shr    $0xc,%edx
f0102c09:	83 c4 10             	add    $0x10,%esp
f0102c0c:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0102c12:	72 12                	jb     f0102c26 <mem_init+0x17bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c14:	50                   	push   %eax
f0102c15:	68 c4 62 10 f0       	push   $0xf01062c4
f0102c1a:	6a 58                	push   $0x58
f0102c1c:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0102c21:	e8 1a d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c26:	83 ec 04             	sub    $0x4,%esp
f0102c29:	68 00 10 00 00       	push   $0x1000
f0102c2e:	6a 01                	push   $0x1
f0102c30:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c35:	50                   	push   %eax
f0102c36:	e8 9d 29 00 00       	call   f01055d8 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c3b:	89 f0                	mov    %esi,%eax
f0102c3d:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0102c43:	c1 f8 03             	sar    $0x3,%eax
f0102c46:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c49:	89 c2                	mov    %eax,%edx
f0102c4b:	c1 ea 0c             	shr    $0xc,%edx
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0102c57:	72 12                	jb     f0102c6b <mem_init+0x1804>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c59:	50                   	push   %eax
f0102c5a:	68 c4 62 10 f0       	push   $0xf01062c4
f0102c5f:	6a 58                	push   $0x58
f0102c61:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0102c66:	e8 d5 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c6b:	83 ec 04             	sub    $0x4,%esp
f0102c6e:	68 00 10 00 00       	push   $0x1000
f0102c73:	6a 02                	push   $0x2
f0102c75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c7a:	50                   	push   %eax
f0102c7b:	e8 58 29 00 00       	call   f01055d8 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c80:	6a 02                	push   $0x2
f0102c82:	68 00 10 00 00       	push   $0x1000
f0102c87:	57                   	push   %edi
f0102c88:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102c8e:	e8 ec e6 ff ff       	call   f010137f <page_insert>
	assert(pp1->pp_ref == 1);
f0102c93:	83 c4 20             	add    $0x20,%esp
f0102c96:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c9b:	74 19                	je     f0102cb6 <mem_init+0x184f>
f0102c9d:	68 3d 6c 10 f0       	push   $0xf0106c3d
f0102ca2:	68 65 6a 10 f0       	push   $0xf0106a65
f0102ca7:	68 dd 04 00 00       	push   $0x4dd
f0102cac:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102cb1:	e8 8a d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cb6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cbd:	01 01 01 
f0102cc0:	74 19                	je     f0102cdb <mem_init+0x1874>
f0102cc2:	68 c0 75 10 f0       	push   $0xf01075c0
f0102cc7:	68 65 6a 10 f0       	push   $0xf0106a65
f0102ccc:	68 de 04 00 00       	push   $0x4de
f0102cd1:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102cd6:	e8 65 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cdb:	6a 02                	push   $0x2
f0102cdd:	68 00 10 00 00       	push   $0x1000
f0102ce2:	56                   	push   %esi
f0102ce3:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102ce9:	e8 91 e6 ff ff       	call   f010137f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cee:	83 c4 10             	add    $0x10,%esp
f0102cf1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cf8:	02 02 02 
f0102cfb:	74 19                	je     f0102d16 <mem_init+0x18af>
f0102cfd:	68 e4 75 10 f0       	push   $0xf01075e4
f0102d02:	68 65 6a 10 f0       	push   $0xf0106a65
f0102d07:	68 e0 04 00 00       	push   $0x4e0
f0102d0c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102d11:	e8 2a d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d16:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d1b:	74 19                	je     f0102d36 <mem_init+0x18cf>
f0102d1d:	68 5f 6c 10 f0       	push   $0xf0106c5f
f0102d22:	68 65 6a 10 f0       	push   $0xf0106a65
f0102d27:	68 e1 04 00 00       	push   $0x4e1
f0102d2c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102d31:	e8 0a d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102d36:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d3b:	74 19                	je     f0102d56 <mem_init+0x18ef>
f0102d3d:	68 c9 6c 10 f0       	push   $0xf0106cc9
f0102d42:	68 65 6a 10 f0       	push   $0xf0106a65
f0102d47:	68 e2 04 00 00       	push   $0x4e2
f0102d4c:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102d51:	e8 ea d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d56:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d5d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d60:	89 f0                	mov    %esi,%eax
f0102d62:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0102d68:	c1 f8 03             	sar    $0x3,%eax
f0102d6b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d6e:	89 c2                	mov    %eax,%edx
f0102d70:	c1 ea 0c             	shr    $0xc,%edx
f0102d73:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0102d79:	72 12                	jb     f0102d8d <mem_init+0x1926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d7b:	50                   	push   %eax
f0102d7c:	68 c4 62 10 f0       	push   $0xf01062c4
f0102d81:	6a 58                	push   $0x58
f0102d83:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0102d88:	e8 b3 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d8d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d94:	03 03 03 
f0102d97:	74 19                	je     f0102db2 <mem_init+0x194b>
f0102d99:	68 08 76 10 f0       	push   $0xf0107608
f0102d9e:	68 65 6a 10 f0       	push   $0xf0106a65
f0102da3:	68 e4 04 00 00       	push   $0x4e4
f0102da8:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102dad:	e8 8e d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102db2:	83 ec 08             	sub    $0x8,%esp
f0102db5:	68 00 10 00 00       	push   $0x1000
f0102dba:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f0102dc0:	e8 65 e5 ff ff       	call   f010132a <page_remove>
	assert(pp2->pp_ref == 0);
f0102dc5:	83 c4 10             	add    $0x10,%esp
f0102dc8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102dcd:	74 19                	je     f0102de8 <mem_init+0x1981>
f0102dcf:	68 97 6c 10 f0       	push   $0xf0106c97
f0102dd4:	68 65 6a 10 f0       	push   $0xf0106a65
f0102dd9:	68 e6 04 00 00       	push   $0x4e6
f0102dde:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102de3:	e8 58 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102de8:	8b 0d 8c 8e 20 f0    	mov    0xf0208e8c,%ecx
f0102dee:	8b 11                	mov    (%ecx),%edx
f0102df0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102df6:	89 d8                	mov    %ebx,%eax
f0102df8:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f0102dfe:	c1 f8 03             	sar    $0x3,%eax
f0102e01:	c1 e0 0c             	shl    $0xc,%eax
f0102e04:	39 c2                	cmp    %eax,%edx
f0102e06:	74 19                	je     f0102e21 <mem_init+0x19ba>
f0102e08:	68 90 6f 10 f0       	push   $0xf0106f90
f0102e0d:	68 65 6a 10 f0       	push   $0xf0106a65
f0102e12:	68 e9 04 00 00       	push   $0x4e9
f0102e17:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102e1c:	e8 1f d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102e21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e27:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e2c:	74 19                	je     f0102e47 <mem_init+0x19e0>
f0102e2e:	68 4e 6c 10 f0       	push   $0xf0106c4e
f0102e33:	68 65 6a 10 f0       	push   $0xf0106a65
f0102e38:	68 eb 04 00 00       	push   $0x4eb
f0102e3d:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0102e42:	e8 f9 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e47:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e4d:	83 ec 0c             	sub    $0xc,%esp
f0102e50:	53                   	push   %ebx
f0102e51:	e8 f1 e2 ff ff       	call   f0101147 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e56:	c7 04 24 34 76 10 f0 	movl   $0xf0107634,(%esp)
f0102e5d:	e8 a4 09 00 00       	call   f0103806 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e62:	83 c4 10             	add    $0x10,%esp
f0102e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e68:	5b                   	pop    %ebx
f0102e69:	5e                   	pop    %esi
f0102e6a:	5f                   	pop    %edi
f0102e6b:	5d                   	pop    %ebp
f0102e6c:	c3                   	ret    

f0102e6d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e6d:	55                   	push   %ebp
f0102e6e:	89 e5                	mov    %esp,%ebp
f0102e70:	57                   	push   %edi
f0102e71:	56                   	push   %esi
f0102e72:	53                   	push   %ebx
f0102e73:	83 ec 1c             	sub    $0x1c,%esp
f0102e76:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	// edited by Lethe 
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102e79:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e81:	89 c3                	mov    %eax,%ebx
f0102e83:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102e86:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e89:	03 45 10             	add    0x10(%ebp),%eax
f0102e8c:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (cur_va = begin; cur_va < end; cur_va += PGSIZE) {
		// not create
		pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);

		if ((!pte) || (cur_va >= ULIM)
			|| ((*pte & (perm | PTE_P)) != (perm | PTE_P))) {
f0102e99:	8b 75 14             	mov    0x14(%ebp),%esi
f0102e9c:	83 ce 01             	or     $0x1,%esi
	// edited by Lethe 
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
	pte_t *pte = NULL;
	uint32_t cur_va;
	for (cur_va = begin; cur_va < end; cur_va += PGSIZE) {
f0102e9f:	eb 4c                	jmp    f0102eed <user_mem_check+0x80>
		// not create
		pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
f0102ea1:	83 ec 04             	sub    $0x4,%esp
f0102ea4:	6a 00                	push   $0x0
f0102ea6:	53                   	push   %ebx
f0102ea7:	ff 77 60             	pushl  0x60(%edi)
f0102eaa:	e8 fa e2 ff ff       	call   f01011a9 <pgdir_walk>

		if ((!pte) || (cur_va >= ULIM)
f0102eaf:	83 c4 10             	add    $0x10,%esp
f0102eb2:	85 c0                	test   %eax,%eax
f0102eb4:	74 10                	je     f0102ec6 <user_mem_check+0x59>
f0102eb6:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ebc:	77 08                	ja     f0102ec6 <user_mem_check+0x59>
			|| ((*pte & (perm | PTE_P)) != (perm | PTE_P))) {
f0102ebe:	89 f2                	mov    %esi,%edx
f0102ec0:	23 10                	and    (%eax),%edx
f0102ec2:	39 d6                	cmp    %edx,%esi
f0102ec4:	74 21                	je     f0102ee7 <user_mem_check+0x7a>
			// 1. pte is null, it means that the page table page not exist
			// 2. permission doesn't match
			// 3. user program can't access va ge ULIM
			if (cur_va == begin) {
f0102ec6:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102ec9:	75 0f                	jne    f0102eda <user_mem_check+0x6d>
				// recover to va before page aligned
				user_mem_check_addr = (uintptr_t)va;
f0102ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ece:	a3 3c 82 20 f0       	mov    %eax,0xf020823c
			}
			else {
				// set user_mem_check_addr
				user_mem_check_addr = cur_va;
			}
			return - E_FAULT;
f0102ed3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ed8:	eb 1d                	jmp    f0102ef7 <user_mem_check+0x8a>
				// recover to va before page aligned
				user_mem_check_addr = (uintptr_t)va;
			}
			else {
				// set user_mem_check_addr
				user_mem_check_addr = cur_va;
f0102eda:	89 1d 3c 82 20 f0    	mov    %ebx,0xf020823c
			}
			return - E_FAULT;
f0102ee0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ee5:	eb 10                	jmp    f0102ef7 <user_mem_check+0x8a>
	// edited by Lethe 
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
	pte_t *pte = NULL;
	uint32_t cur_va;
	for (cur_va = begin; cur_va < end; cur_va += PGSIZE) {
f0102ee7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102eed:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102ef0:	72 af                	jb     f0102ea1 <user_mem_check+0x34>
				user_mem_check_addr = cur_va;
			}
			return - E_FAULT;
		}// end if
	}// end for
	return 0;
f0102ef2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102efa:	5b                   	pop    %ebx
f0102efb:	5e                   	pop    %esi
f0102efc:	5f                   	pop    %edi
f0102efd:	5d                   	pop    %ebp
f0102efe:	c3                   	ret    

f0102eff <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102eff:	55                   	push   %ebp
f0102f00:	89 e5                	mov    %esp,%ebp
f0102f02:	53                   	push   %ebx
f0102f03:	83 ec 04             	sub    $0x4,%esp
f0102f06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f09:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f0c:	83 c8 04             	or     $0x4,%eax
f0102f0f:	50                   	push   %eax
f0102f10:	ff 75 10             	pushl  0x10(%ebp)
f0102f13:	ff 75 0c             	pushl  0xc(%ebp)
f0102f16:	53                   	push   %ebx
f0102f17:	e8 51 ff ff ff       	call   f0102e6d <user_mem_check>
f0102f1c:	83 c4 10             	add    $0x10,%esp
f0102f1f:	85 c0                	test   %eax,%eax
f0102f21:	79 21                	jns    f0102f44 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f23:	83 ec 04             	sub    $0x4,%esp
f0102f26:	ff 35 3c 82 20 f0    	pushl  0xf020823c
f0102f2c:	ff 73 48             	pushl  0x48(%ebx)
f0102f2f:	68 60 76 10 f0       	push   $0xf0107660
f0102f34:	e8 cd 08 00 00       	call   f0103806 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f39:	89 1c 24             	mov    %ebx,(%esp)
f0102f3c:	e8 0c 06 00 00       	call   f010354d <env_destroy>
f0102f41:	83 c4 10             	add    $0x10,%esp
	}
}
f0102f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f47:	c9                   	leave  
f0102f48:	c3                   	ret    

f0102f49 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f49:	55                   	push   %ebp
f0102f4a:	89 e5                	mov    %esp,%ebp
f0102f4c:	57                   	push   %edi
f0102f4d:	56                   	push   %esi
f0102f4e:	53                   	push   %ebx
f0102f4f:	83 ec 0c             	sub    $0xc,%esp
f0102f52:	89 c7                	mov    %eax,%edi
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	// edited by Lethe  
	// Round down to the nearest multiple of n(inc/type.h)
	void * begin = (void *)ROUNDDOWN(va, PGSIZE);
f0102f54:	89 d3                	mov    %edx,%ebx
f0102f56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// Round up to the nearest multiple of n(inc/type.h)
	void * end = (void *)ROUNDUP(va + len, PGSIZE);
f0102f5c:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f63:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	struct PageInfo * p = NULL;
	int r;

	void * i;
	for (i = begin; i < end; i += PGSIZE) {
f0102f69:	eb 55                	jmp    f0102fc0 <region_alloc+0x77>
		// call page_alloc but don't intialize it
		p = page_alloc(0);
f0102f6b:	83 ec 0c             	sub    $0xc,%esp
f0102f6e:	6a 00                	push   $0x0
f0102f70:	e8 62 e1 ff ff       	call   f01010d7 <page_alloc>

		if (!p) {
f0102f75:	83 c4 10             	add    $0x10,%esp
f0102f78:	85 c0                	test   %eax,%eax
f0102f7a:	75 16                	jne    f0102f92 <region_alloc+0x49>
			// return null if out of free memory
			panic("region alloc failed: %e\n", p);
f0102f7c:	6a 00                	push   $0x0
f0102f7e:	68 95 76 10 f0       	push   $0xf0107695
f0102f83:	68 45 01 00 00       	push   $0x145
f0102f88:	68 ae 76 10 f0       	push   $0xf01076ae
f0102f8d:	e8 ae d0 ff ff       	call   f0100040 <_panic>
		}

		// int page_insert(pde_t *pgdir
		// ,struct PageInfo *pp, void *va, int perm)
		// return 0 on success
		r = page_insert(e->env_pgdir, p, i, (PTE_W | PTE_U));
f0102f92:	6a 06                	push   $0x6
f0102f94:	53                   	push   %ebx
f0102f95:	50                   	push   %eax
f0102f96:	ff 77 60             	pushl  0x60(%edi)
f0102f99:	e8 e1 e3 ff ff       	call   f010137f <page_insert>

		if (r != 0) {
f0102f9e:	83 c4 10             	add    $0x10,%esp
f0102fa1:	85 c0                	test   %eax,%eax
f0102fa3:	74 15                	je     f0102fba <region_alloc+0x71>
			// if true, it means that page_insert failed
			panic("region alloc failed: %e\n", r);
f0102fa5:	50                   	push   %eax
f0102fa6:	68 95 76 10 f0       	push   $0xf0107695
f0102fab:	68 4f 01 00 00       	push   $0x14f
f0102fb0:	68 ae 76 10 f0       	push   $0xf01076ae
f0102fb5:	e8 86 d0 ff ff       	call   f0100040 <_panic>

	struct PageInfo * p = NULL;
	int r;

	void * i;
	for (i = begin; i < end; i += PGSIZE) {
f0102fba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fc0:	39 f3                	cmp    %esi,%ebx
f0102fc2:	72 a7                	jb     f0102f6b <region_alloc+0x22>
		if (r != 0) {
			// if true, it means that page_insert failed
			panic("region alloc failed: %e\n", r);
		}
	}// end for
}
f0102fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fc7:	5b                   	pop    %ebx
f0102fc8:	5e                   	pop    %esi
f0102fc9:	5f                   	pop    %edi
f0102fca:	5d                   	pop    %ebp
f0102fcb:	c3                   	ret    

f0102fcc <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102fcc:	55                   	push   %ebp
f0102fcd:	89 e5                	mov    %esp,%ebp
f0102fcf:	56                   	push   %esi
f0102fd0:	53                   	push   %ebx
f0102fd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fd4:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102fd7:	85 c0                	test   %eax,%eax
f0102fd9:	75 1a                	jne    f0102ff5 <envid2env+0x29>
		*env_store = curenv;
f0102fdb:	e8 1a 2c 00 00       	call   f0105bfa <cpunum>
f0102fe0:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fe3:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0102fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fec:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fee:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ff3:	eb 70                	jmp    f0103065 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ff5:	89 c3                	mov    %eax,%ebx
f0102ff7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ffd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103000:	03 1d 48 82 20 f0    	add    0xf0208248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103006:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010300a:	74 05                	je     f0103011 <envid2env+0x45>
f010300c:	3b 43 48             	cmp    0x48(%ebx),%eax
f010300f:	74 10                	je     f0103021 <envid2env+0x55>
		*env_store = 0;
f0103011:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103014:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010301a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010301f:	eb 44                	jmp    f0103065 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103021:	84 d2                	test   %dl,%dl
f0103023:	74 36                	je     f010305b <envid2env+0x8f>
f0103025:	e8 d0 2b 00 00       	call   f0105bfa <cpunum>
f010302a:	6b c0 74             	imul   $0x74,%eax,%eax
f010302d:	3b 98 28 90 20 f0    	cmp    -0xfdf6fd8(%eax),%ebx
f0103033:	74 26                	je     f010305b <envid2env+0x8f>
f0103035:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103038:	e8 bd 2b 00 00       	call   f0105bfa <cpunum>
f010303d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103040:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0103046:	3b 70 48             	cmp    0x48(%eax),%esi
f0103049:	74 10                	je     f010305b <envid2env+0x8f>
		*env_store = 0;
f010304b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010304e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103054:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103059:	eb 0a                	jmp    f0103065 <envid2env+0x99>
	}

	*env_store = e;
f010305b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010305e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103060:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103065:	5b                   	pop    %ebx
f0103066:	5e                   	pop    %esi
f0103067:	5d                   	pop    %ebp
f0103068:	c3                   	ret    

f0103069 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103069:	55                   	push   %ebp
f010306a:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010306c:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0103071:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103074:	b8 23 00 00 00       	mov    $0x23,%eax
f0103079:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010307b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010307d:	b8 10 00 00 00       	mov    $0x10,%eax
f0103082:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103084:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103086:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103088:	ea 8f 30 10 f0 08 00 	ljmp   $0x8,$0xf010308f
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010308f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103094:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103097:	5d                   	pop    %ebp
f0103098:	c3                   	ret    

f0103099 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103099:	55                   	push   %ebp
f010309a:	89 e5                	mov    %esp,%ebp
f010309c:	56                   	push   %esi
f010309d:	53                   	push   %ebx
	// edited by Lethe 
	int i;
	for (i = NENV - 1; i >= 0; i--) {
		// initialize backwards to keep env_free_list points to
		// the first element of envs all the time
		envs[i].env_id = 0;
f010309e:	8b 35 48 82 20 f0    	mov    0xf0208248,%esi
f01030a4:	8b 15 4c 82 20 f0    	mov    0xf020824c,%edx
f01030aa:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01030b0:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01030b3:	89 c1                	mov    %eax,%ecx
f01030b5:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030bc:	89 50 44             	mov    %edx,0x44(%eax)
		env_free_list = envs + i;

		// we can initialize other data member by the way
		// we can also don't care them, it doesn't matter
		envs[i].env_parent_id = 0;
f01030bf:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[i].env_type = ENV_TYPE_USER;
f01030c6:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[i].env_status = 0;
f01030cd:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_runs = 0;
f01030d4:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
		envs[i].env_pgdir = NULL;
f01030db:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
f01030e2:	83 e8 7c             	sub    $0x7c,%eax
	for (i = NENV - 1; i >= 0; i--) {
		// initialize backwards to keep env_free_list points to
		// the first element of envs all the time
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs + i;
f01030e5:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	// edited by Lethe 
	int i;
	for (i = NENV - 1; i >= 0; i--) {
f01030e7:	39 d8                	cmp    %ebx,%eax
f01030e9:	75 c8                	jne    f01030b3 <env_init+0x1a>
f01030eb:	89 35 4c 82 20 f0    	mov    %esi,0xf020824c
		envs[i].env_runs = 0;
		envs[i].env_pgdir = NULL;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f01030f1:	e8 73 ff ff ff       	call   f0103069 <env_init_percpu>
}
f01030f6:	5b                   	pop    %ebx
f01030f7:	5e                   	pop    %esi
f01030f8:	5d                   	pop    %ebp
f01030f9:	c3                   	ret    

f01030fa <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030fa:	55                   	push   %ebp
f01030fb:	89 e5                	mov    %esp,%ebp
f01030fd:	53                   	push   %ebx
f01030fe:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103101:	8b 1d 4c 82 20 f0    	mov    0xf020824c,%ebx
f0103107:	85 db                	test   %ebx,%ebx
f0103109:	0f 84 2d 01 00 00    	je     f010323c <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010310f:	83 ec 0c             	sub    $0xc,%esp
f0103112:	6a 01                	push   $0x1
f0103114:	e8 be df ff ff       	call   f01010d7 <page_alloc>
f0103119:	83 c4 10             	add    $0x10,%esp
f010311c:	85 c0                	test   %eax,%eax
f010311e:	0f 84 1f 01 00 00    	je     f0103243 <env_alloc+0x149>
	// LAB 3: Your code here.
	// edited by Lethe

	// according to hints above, increment env_pgdir's
	// pp_ref for env_free to work correctly
	p->pp_ref++;
f0103124:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103129:	2b 05 90 8e 20 f0    	sub    0xf0208e90,%eax
f010312f:	c1 f8 03             	sar    $0x3,%eax
f0103132:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103135:	89 c2                	mov    %eax,%edx
f0103137:	c1 ea 0c             	shr    $0xc,%edx
f010313a:	3b 15 88 8e 20 f0    	cmp    0xf0208e88,%edx
f0103140:	72 12                	jb     f0103154 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103142:	50                   	push   %eax
f0103143:	68 c4 62 10 f0       	push   $0xf01062c4
f0103148:	6a 58                	push   $0x58
f010314a:	68 4b 6a 10 f0       	push   $0xf0106a4b
f010314f:	e8 ec ce ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103154:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103159:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010315c:	83 ec 04             	sub    $0x4,%esp
f010315f:	68 00 10 00 00       	push   $0x1000
f0103164:	ff 35 8c 8e 20 f0    	pushl  0xf0208e8c
f010316a:	50                   	push   %eax
f010316b:	e8 1d 25 00 00       	call   f010568d <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103170:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103173:	83 c4 10             	add    $0x10,%esp
f0103176:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010317b:	77 15                	ja     f0103192 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010317d:	50                   	push   %eax
f010317e:	68 e8 62 10 f0       	push   $0xf01062e8
f0103183:	68 d4 00 00 00       	push   $0xd4
f0103188:	68 ae 76 10 f0       	push   $0xf01076ae
f010318d:	e8 ae ce ff ff       	call   f0100040 <_panic>
f0103192:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103198:	83 ca 05             	or     $0x5,%edx
f010319b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031a1:	8b 43 48             	mov    0x48(%ebx),%eax
f01031a4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031a9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031ae:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031b3:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031b6:	89 da                	mov    %ebx,%edx
f01031b8:	2b 15 48 82 20 f0    	sub    0xf0208248,%edx
f01031be:	c1 fa 02             	sar    $0x2,%edx
f01031c1:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031c7:	09 d0                	or     %edx,%eax
f01031c9:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031cf:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031d2:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031d9:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031e0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031e7:	83 ec 04             	sub    $0x4,%esp
f01031ea:	6a 44                	push   $0x44
f01031ec:	6a 00                	push   $0x0
f01031ee:	53                   	push   %ebx
f01031ef:	e8 e4 23 00 00       	call   f01055d8 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031f4:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031fa:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103200:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103206:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010320d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	// edited by Lethe 
	e->env_tf.tf_eflags |= FL_IF;
f0103213:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010321a:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103221:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103225:	8b 43 44             	mov    0x44(%ebx),%eax
f0103228:	a3 4c 82 20 f0       	mov    %eax,0xf020824c
	*newenv_store = e;
f010322d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103230:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103232:	83 c4 10             	add    $0x10,%esp
f0103235:	b8 00 00 00 00       	mov    $0x0,%eax
f010323a:	eb 0c                	jmp    f0103248 <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010323c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103241:	eb 05                	jmp    f0103248 <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103243:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010324b:	c9                   	leave  
f010324c:	c3                   	ret    

f010324d <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010324d:	55                   	push   %ebp
f010324e:	89 e5                	mov    %esp,%ebp
f0103250:	57                   	push   %edi
f0103251:	56                   	push   %esi
f0103252:	53                   	push   %ebx
f0103253:	83 ec 34             	sub    $0x34,%esp
f0103256:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	// edited by Lethe  
	int ret = 0;
	struct Env * e = NULL;
f0103259:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	ret = env_alloc(&e, 0);
f0103260:	6a 00                	push   $0x0
f0103262:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103265:	50                   	push   %eax
f0103266:	e8 8f fe ff ff       	call   f01030fa <env_alloc>
	if (ret < 0) {
f010326b:	83 c4 10             	add    $0x10,%esp
f010326e:	85 c0                	test   %eax,%eax
f0103270:	79 15                	jns    f0103287 <env_create+0x3a>
		// retrun <0 on failure
		panic("env_create failed: %e\n", ret);
f0103272:	50                   	push   %eax
f0103273:	68 b9 76 10 f0       	push   $0xf01076b9
f0103278:	68 cf 01 00 00       	push   $0x1cf
f010327d:	68 ae 76 10 f0       	push   $0xf01076ae
f0103282:	e8 b9 cd ff ff       	call   f0100040 <_panic>
	}

	load_icode(e, binary);
f0103287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010328a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf * elfhdr = (struct Elf *)binary;
	struct Proghdr *ph, *eph;

	// contents below are same to that in main.c
	// is this a valid ELF?
	if (elfhdr->e_magic != ELF_MAGIC) {
f010328d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103293:	74 17                	je     f01032ac <env_create+0x5f>
		// invalid ELF
		panic("Not a valid ELF!\n");
f0103295:	83 ec 04             	sub    $0x4,%esp
f0103298:	68 d0 76 10 f0       	push   $0xf01076d0
f010329d:	68 91 01 00 00       	push   $0x191
f01032a2:	68 ae 76 10 f0       	push   $0xf01076ae
f01032a7:	e8 94 cd ff ff       	call   f0100040 <_panic>
	// load each program segment
	/*
		e_phoff holds the program header table's file offset in bytes.
		e_phnum holds the number of entries in the program header table.
	*/
	ph = (struct Proghdr *)((uint8_t *)elfhdr + elfhdr->e_phoff);
f01032ac:	89 fb                	mov    %edi,%ebx
f01032ae:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f01032b1:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032b5:	c1 e6 05             	shl    $0x5,%esi
f01032b8:	01 de                	add    %ebx,%esi
		lcr3(uint32_t val)
		{
			__asm __volatile("movl %0,%%cr3" : : "r" (val));
		}
	*/
	lcr3(PADDR(e->env_pgdir));
f01032ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032bd:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032c0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032c5:	77 15                	ja     f01032dc <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032c7:	50                   	push   %eax
f01032c8:	68 e8 62 10 f0       	push   $0xf01062e8
f01032cd:	68 a3 01 00 00       	push   $0x1a3
f01032d2:	68 ae 76 10 f0       	push   $0xf01076ae
f01032d7:	e8 64 cd ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01032dc:	05 00 00 00 10       	add    $0x10000000,%eax
f01032e1:	0f 22 d8             	mov    %eax,%cr3
f01032e4:	eb 5c                	jmp    f0103342 <env_create+0xf5>
	for (; ph < eph; ph++) {
		// only load segments with ph->p_type == ELF_PROG_LOAD
		if (ph->p_type == ELF_PROG_LOAD) {
f01032e6:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032e9:	75 35                	jne    f0103320 <env_create+0xd3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01032eb:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032ee:	8b 53 08             	mov    0x8(%ebx),%edx
f01032f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032f4:	e8 50 fc ff ff       	call   f0102f49 <region_alloc>
			// initialize this region
			memset((void *)ph->p_va, 0, ph->p_memsz);
f01032f9:	83 ec 04             	sub    $0x4,%esp
f01032fc:	ff 73 14             	pushl  0x14(%ebx)
f01032ff:	6a 00                	push   $0x0
f0103301:	ff 73 08             	pushl  0x8(%ebx)
f0103304:	e8 cf 22 00 00       	call   f01055d8 <memset>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103309:	83 c4 0c             	add    $0xc,%esp
f010330c:	ff 73 10             	pushl  0x10(%ebx)
f010330f:	89 f8                	mov    %edi,%eax
f0103311:	03 43 04             	add    0x4(%ebx),%eax
f0103314:	50                   	push   %eax
f0103315:	ff 73 08             	pushl  0x8(%ebx)
f0103318:	e8 08 23 00 00       	call   f0105625 <memmove>
f010331d:	83 c4 10             	add    $0x10,%esp
		}
		if (ph->p_filesz > ph->p_memsz) {
f0103320:	8b 43 14             	mov    0x14(%ebx),%eax
f0103323:	39 43 10             	cmp    %eax,0x10(%ebx)
f0103326:	76 17                	jbe    f010333f <env_create+0xf2>
			// The ELF header should have ph->p_filesz <= ph->p_memsz
			panic("The ELF header should have ph->p_filesz <= ph->p_memsz!");
f0103328:	83 ec 04             	sub    $0x4,%esp
f010332b:	68 f0 76 10 f0       	push   $0xf01076f0
f0103330:	68 ae 01 00 00       	push   $0x1ae
f0103335:	68 ae 76 10 f0       	push   $0xf01076ae
f010333a:	e8 01 cd ff ff       	call   f0100040 <_panic>
		{
			__asm __volatile("movl %0,%%cr3" : : "r" (val));
		}
	*/
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++) {
f010333f:	83 c3 20             	add    $0x20,%ebx
f0103342:	39 de                	cmp    %ebx,%esi
f0103344:	77 a0                	ja     f01032e6 <env_create+0x99>
			// The ELF header should have ph->p_filesz <= ph->p_memsz
			panic("The ELF header should have ph->p_filesz <= ph->p_memsz!");
		}
	}

	e->env_tf.tf_eip = elfhdr->e_entry;
f0103346:	8b 47 18             	mov    0x18(%edi),%eax
f0103349:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010334c:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	// edited by Lethe  
	lcr3(PADDR(kern_pgdir));
f010334f:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103354:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103359:	77 15                	ja     f0103370 <env_create+0x123>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010335b:	50                   	push   %eax
f010335c:	68 e8 62 10 f0       	push   $0xf01062e8
f0103361:	68 b9 01 00 00       	push   $0x1b9
f0103366:	68 ae 76 10 f0       	push   $0xf01076ae
f010336b:	e8 d0 cc ff ff       	call   f0100040 <_panic>
f0103370:	05 00 00 00 10       	add    $0x10000000,%eax
f0103375:	0f 22 d8             	mov    %eax,%cr3

	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103378:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010337d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103382:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103385:	e8 bf fb ff ff       	call   f0102f49 <region_alloc>
		// retrun <0 on failure
		panic("env_create failed: %e\n", ret);
	}

	load_icode(e, binary);
	e->env_type = type;
f010338a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010338d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103390:	89 48 50             	mov    %ecx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	// 2018/12/11 edited by Lethe
	if (type == ENV_TYPE_FS)
f0103393:	83 f9 01             	cmp    $0x1,%ecx
f0103396:	75 07                	jne    f010339f <env_create+0x152>
              e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103398:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)


}
f010339f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033a2:	5b                   	pop    %ebx
f01033a3:	5e                   	pop    %esi
f01033a4:	5f                   	pop    %edi
f01033a5:	5d                   	pop    %ebp
f01033a6:	c3                   	ret    

f01033a7 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033a7:	55                   	push   %ebp
f01033a8:	89 e5                	mov    %esp,%ebp
f01033aa:	57                   	push   %edi
f01033ab:	56                   	push   %esi
f01033ac:	53                   	push   %ebx
f01033ad:	83 ec 1c             	sub    $0x1c,%esp
f01033b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033b3:	e8 42 28 00 00       	call   f0105bfa <cpunum>
f01033b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01033bb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033c2:	39 b8 28 90 20 f0    	cmp    %edi,-0xfdf6fd8(%eax)
f01033c8:	75 30                	jne    f01033fa <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01033ca:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033d4:	77 15                	ja     f01033eb <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033d6:	50                   	push   %eax
f01033d7:	68 e8 62 10 f0       	push   $0xf01062e8
f01033dc:	68 ec 01 00 00       	push   $0x1ec
f01033e1:	68 ae 76 10 f0       	push   $0xf01076ae
f01033e6:	e8 55 cc ff ff       	call   f0100040 <_panic>
f01033eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01033f0:	0f 22 d8             	mov    %eax,%cr3
f01033f3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01033fd:	89 d0                	mov    %edx,%eax
f01033ff:	c1 e0 02             	shl    $0x2,%eax
f0103402:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103405:	8b 47 60             	mov    0x60(%edi),%eax
f0103408:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010340b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103411:	0f 84 a8 00 00 00    	je     f01034bf <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103417:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010341d:	89 f0                	mov    %esi,%eax
f010341f:	c1 e8 0c             	shr    $0xc,%eax
f0103422:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103425:	39 05 88 8e 20 f0    	cmp    %eax,0xf0208e88
f010342b:	77 15                	ja     f0103442 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010342d:	56                   	push   %esi
f010342e:	68 c4 62 10 f0       	push   $0xf01062c4
f0103433:	68 fb 01 00 00       	push   $0x1fb
f0103438:	68 ae 76 10 f0       	push   $0xf01076ae
f010343d:	e8 fe cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103442:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103445:	c1 e0 16             	shl    $0x16,%eax
f0103448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010344b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103450:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103457:	01 
f0103458:	74 17                	je     f0103471 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010345a:	83 ec 08             	sub    $0x8,%esp
f010345d:	89 d8                	mov    %ebx,%eax
f010345f:	c1 e0 0c             	shl    $0xc,%eax
f0103462:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103465:	50                   	push   %eax
f0103466:	ff 77 60             	pushl  0x60(%edi)
f0103469:	e8 bc de ff ff       	call   f010132a <page_remove>
f010346e:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103471:	83 c3 01             	add    $0x1,%ebx
f0103474:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010347a:	75 d4                	jne    f0103450 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010347c:	8b 47 60             	mov    0x60(%edi),%eax
f010347f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103482:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103489:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010348c:	3b 05 88 8e 20 f0    	cmp    0xf0208e88,%eax
f0103492:	72 14                	jb     f01034a8 <env_free+0x101>
		panic("pa2page called with invalid pa");
f0103494:	83 ec 04             	sub    $0x4,%esp
f0103497:	68 5c 6e 10 f0       	push   $0xf0106e5c
f010349c:	6a 51                	push   $0x51
f010349e:	68 4b 6a 10 f0       	push   $0xf0106a4b
f01034a3:	e8 98 cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01034a8:	83 ec 0c             	sub    $0xc,%esp
f01034ab:	a1 90 8e 20 f0       	mov    0xf0208e90,%eax
f01034b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034b3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034b6:	50                   	push   %eax
f01034b7:	e8 c6 dc ff ff       	call   f0101182 <page_decref>
f01034bc:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034bf:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01034c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034c6:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01034cb:	0f 85 29 ff ff ff    	jne    f01033fa <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034d1:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034d4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d9:	77 15                	ja     f01034f0 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034db:	50                   	push   %eax
f01034dc:	68 e8 62 10 f0       	push   $0xf01062e8
f01034e1:	68 09 02 00 00       	push   $0x209
f01034e6:	68 ae 76 10 f0       	push   $0xf01076ae
f01034eb:	e8 50 cb ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01034f0:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034f7:	05 00 00 00 10       	add    $0x10000000,%eax
f01034fc:	c1 e8 0c             	shr    $0xc,%eax
f01034ff:	3b 05 88 8e 20 f0    	cmp    0xf0208e88,%eax
f0103505:	72 14                	jb     f010351b <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103507:	83 ec 04             	sub    $0x4,%esp
f010350a:	68 5c 6e 10 f0       	push   $0xf0106e5c
f010350f:	6a 51                	push   $0x51
f0103511:	68 4b 6a 10 f0       	push   $0xf0106a4b
f0103516:	e8 25 cb ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010351b:	83 ec 0c             	sub    $0xc,%esp
f010351e:	8b 15 90 8e 20 f0    	mov    0xf0208e90,%edx
f0103524:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103527:	50                   	push   %eax
f0103528:	e8 55 dc ff ff       	call   f0101182 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010352d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103534:	a1 4c 82 20 f0       	mov    0xf020824c,%eax
f0103539:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010353c:	89 3d 4c 82 20 f0    	mov    %edi,0xf020824c
}
f0103542:	83 c4 10             	add    $0x10,%esp
f0103545:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103548:	5b                   	pop    %ebx
f0103549:	5e                   	pop    %esi
f010354a:	5f                   	pop    %edi
f010354b:	5d                   	pop    %ebp
f010354c:	c3                   	ret    

f010354d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010354d:	55                   	push   %ebp
f010354e:	89 e5                	mov    %esp,%ebp
f0103550:	53                   	push   %ebx
f0103551:	83 ec 04             	sub    $0x4,%esp
f0103554:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103557:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010355b:	75 19                	jne    f0103576 <env_destroy+0x29>
f010355d:	e8 98 26 00 00       	call   f0105bfa <cpunum>
f0103562:	6b c0 74             	imul   $0x74,%eax,%eax
f0103565:	3b 98 28 90 20 f0    	cmp    -0xfdf6fd8(%eax),%ebx
f010356b:	74 09                	je     f0103576 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010356d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103574:	eb 33                	jmp    f01035a9 <env_destroy+0x5c>
	}

	env_free(e);
f0103576:	83 ec 0c             	sub    $0xc,%esp
f0103579:	53                   	push   %ebx
f010357a:	e8 28 fe ff ff       	call   f01033a7 <env_free>

	if (curenv == e) {
f010357f:	e8 76 26 00 00       	call   f0105bfa <cpunum>
f0103584:	6b c0 74             	imul   $0x74,%eax,%eax
f0103587:	83 c4 10             	add    $0x10,%esp
f010358a:	3b 98 28 90 20 f0    	cmp    -0xfdf6fd8(%eax),%ebx
f0103590:	75 17                	jne    f01035a9 <env_destroy+0x5c>
		curenv = NULL;
f0103592:	e8 63 26 00 00       	call   f0105bfa <cpunum>
f0103597:	6b c0 74             	imul   $0x74,%eax,%eax
f010359a:	c7 80 28 90 20 f0 00 	movl   $0x0,-0xfdf6fd8(%eax)
f01035a1:	00 00 00 
		sched_yield();
f01035a4:	e8 6a 0e 00 00       	call   f0104413 <sched_yield>
	}
}
f01035a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ac:	c9                   	leave  
f01035ad:	c3                   	ret    

f01035ae <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035ae:	55                   	push   %ebp
f01035af:	89 e5                	mov    %esp,%ebp
f01035b1:	53                   	push   %ebx
f01035b2:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035b5:	e8 40 26 00 00       	call   f0105bfa <cpunum>
f01035ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01035bd:	8b 98 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%ebx
f01035c3:	e8 32 26 00 00       	call   f0105bfa <cpunum>
f01035c8:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01035cb:	8b 65 08             	mov    0x8(%ebp),%esp
f01035ce:	61                   	popa   
f01035cf:	07                   	pop    %es
f01035d0:	1f                   	pop    %ds
f01035d1:	83 c4 08             	add    $0x8,%esp
f01035d4:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035d5:	83 ec 04             	sub    $0x4,%esp
f01035d8:	68 e2 76 10 f0       	push   $0xf01076e2
f01035dd:	68 3f 02 00 00       	push   $0x23f
f01035e2:	68 ae 76 10 f0       	push   $0xf01076ae
f01035e7:	e8 54 ca ff ff       	call   f0100040 <_panic>

f01035ec <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035ec:	55                   	push   %ebp
f01035ed:	89 e5                	mov    %esp,%ebp
f01035ef:	53                   	push   %ebx
f01035f0:	83 ec 04             	sub    $0x4,%esp
f01035f3:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.

	// edited by Lethe  
	// if this is the first call to env_run, curenv is NULL
	if (curenv&&curenv->env_status == ENV_RUNNING) {
f01035f6:	e8 ff 25 00 00       	call   f0105bfa <cpunum>
f01035fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fe:	83 b8 28 90 20 f0 00 	cmpl   $0x0,-0xfdf6fd8(%eax)
f0103605:	74 29                	je     f0103630 <env_run+0x44>
f0103607:	e8 ee 25 00 00       	call   f0105bfa <cpunum>
f010360c:	6b c0 74             	imul   $0x74,%eax,%eax
f010360f:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0103615:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103619:	75 15                	jne    f0103630 <env_run+0x44>
		// there is a env running now
		curenv->env_status = ENV_RUNNABLE;
f010361b:	e8 da 25 00 00       	call   f0105bfa <cpunum>
f0103620:	6b c0 74             	imul   $0x74,%eax,%eax
f0103623:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0103629:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}

	// switch to env e
	curenv = e;
f0103630:	e8 c5 25 00 00       	call   f0105bfa <cpunum>
f0103635:	6b c0 74             	imul   $0x74,%eax,%eax
f0103638:	89 98 28 90 20 f0    	mov    %ebx,-0xfdf6fd8(%eax)
	e->env_status = ENV_RUNNING;
f010363e:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103645:	83 43 58 01          	addl   $0x1,0x58(%ebx)

	// Use lcr3() to switch to its address space
	lcr3(PADDR(e->env_pgdir));
f0103649:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010364c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103651:	77 15                	ja     f0103668 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103653:	50                   	push   %eax
f0103654:	68 e8 62 10 f0       	push   $0xf01062e8
f0103659:	68 6b 02 00 00       	push   $0x26b
f010365e:	68 ae 76 10 f0       	push   $0xf01076ae
f0103663:	e8 d8 c9 ff ff       	call   f0100040 <_panic>
f0103668:	05 00 00 00 10       	add    $0x10000000,%eax
f010366d:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103670:	83 ec 0c             	sub    $0xc,%esp
f0103673:	68 c0 03 12 f0       	push   $0xf01203c0
f0103678:	e8 88 28 00 00       	call   f0105f05 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010367d:	f3 90                	pause  
	/*
		Use env_pop_tf() to restore the environment's
		registers and drop into user mode in the
		environment.
	*/
	env_pop_tf(&(e->env_tf));
f010367f:	89 1c 24             	mov    %ebx,(%esp)
f0103682:	e8 27 ff ff ff       	call   f01035ae <env_pop_tf>

f0103687 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103687:	55                   	push   %ebp
f0103688:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010368a:	ba 70 00 00 00       	mov    $0x70,%edx
f010368f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103692:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103693:	ba 71 00 00 00       	mov    $0x71,%edx
f0103698:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103699:	0f b6 c0             	movzbl %al,%eax
}
f010369c:	5d                   	pop    %ebp
f010369d:	c3                   	ret    

f010369e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010369e:	55                   	push   %ebp
f010369f:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036a1:	ba 70 00 00 00       	mov    $0x70,%edx
f01036a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a9:	ee                   	out    %al,(%dx)
f01036aa:	ba 71 00 00 00       	mov    $0x71,%edx
f01036af:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036b2:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036b3:	5d                   	pop    %ebp
f01036b4:	c3                   	ret    

f01036b5 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01036b5:	55                   	push   %ebp
f01036b6:	89 e5                	mov    %esp,%ebp
f01036b8:	56                   	push   %esi
f01036b9:	53                   	push   %ebx
f01036ba:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01036bd:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f01036c3:	80 3d 50 82 20 f0 00 	cmpb   $0x0,0xf0208250
f01036ca:	74 5a                	je     f0103726 <irq_setmask_8259A+0x71>
f01036cc:	89 c6                	mov    %eax,%esi
f01036ce:	ba 21 00 00 00       	mov    $0x21,%edx
f01036d3:	ee                   	out    %al,(%dx)
f01036d4:	66 c1 e8 08          	shr    $0x8,%ax
f01036d8:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036dd:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01036de:	83 ec 0c             	sub    $0xc,%esp
f01036e1:	68 28 77 10 f0       	push   $0xf0107728
f01036e6:	e8 1b 01 00 00       	call   f0103806 <cprintf>
f01036eb:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01036ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01036f3:	0f b7 f6             	movzwl %si,%esi
f01036f6:	f7 d6                	not    %esi
f01036f8:	0f a3 de             	bt     %ebx,%esi
f01036fb:	73 11                	jae    f010370e <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01036fd:	83 ec 08             	sub    $0x8,%esp
f0103700:	53                   	push   %ebx
f0103701:	68 cb 7b 10 f0       	push   $0xf0107bcb
f0103706:	e8 fb 00 00 00       	call   f0103806 <cprintf>
f010370b:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010370e:	83 c3 01             	add    $0x1,%ebx
f0103711:	83 fb 10             	cmp    $0x10,%ebx
f0103714:	75 e2                	jne    f01036f8 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103716:	83 ec 0c             	sub    $0xc,%esp
f0103719:	68 e0 76 10 f0       	push   $0xf01076e0
f010371e:	e8 e3 00 00 00       	call   f0103806 <cprintf>
f0103723:	83 c4 10             	add    $0x10,%esp
}
f0103726:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103729:	5b                   	pop    %ebx
f010372a:	5e                   	pop    %esi
f010372b:	5d                   	pop    %ebp
f010372c:	c3                   	ret    

f010372d <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010372d:	c6 05 50 82 20 f0 01 	movb   $0x1,0xf0208250
f0103734:	ba 21 00 00 00       	mov    $0x21,%edx
f0103739:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010373e:	ee                   	out    %al,(%dx)
f010373f:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103744:	ee                   	out    %al,(%dx)
f0103745:	ba 20 00 00 00       	mov    $0x20,%edx
f010374a:	b8 11 00 00 00       	mov    $0x11,%eax
f010374f:	ee                   	out    %al,(%dx)
f0103750:	ba 21 00 00 00       	mov    $0x21,%edx
f0103755:	b8 20 00 00 00       	mov    $0x20,%eax
f010375a:	ee                   	out    %al,(%dx)
f010375b:	b8 04 00 00 00       	mov    $0x4,%eax
f0103760:	ee                   	out    %al,(%dx)
f0103761:	b8 03 00 00 00       	mov    $0x3,%eax
f0103766:	ee                   	out    %al,(%dx)
f0103767:	ba a0 00 00 00       	mov    $0xa0,%edx
f010376c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103771:	ee                   	out    %al,(%dx)
f0103772:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103777:	b8 28 00 00 00       	mov    $0x28,%eax
f010377c:	ee                   	out    %al,(%dx)
f010377d:	b8 02 00 00 00       	mov    $0x2,%eax
f0103782:	ee                   	out    %al,(%dx)
f0103783:	b8 01 00 00 00       	mov    $0x1,%eax
f0103788:	ee                   	out    %al,(%dx)
f0103789:	ba 20 00 00 00       	mov    $0x20,%edx
f010378e:	b8 68 00 00 00       	mov    $0x68,%eax
f0103793:	ee                   	out    %al,(%dx)
f0103794:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103799:	ee                   	out    %al,(%dx)
f010379a:	ba a0 00 00 00       	mov    $0xa0,%edx
f010379f:	b8 68 00 00 00       	mov    $0x68,%eax
f01037a4:	ee                   	out    %al,(%dx)
f01037a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037aa:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01037ab:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01037b2:	66 83 f8 ff          	cmp    $0xffff,%ax
f01037b6:	74 13                	je     f01037cb <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01037b8:	55                   	push   %ebp
f01037b9:	89 e5                	mov    %esp,%ebp
f01037bb:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01037be:	0f b7 c0             	movzwl %ax,%eax
f01037c1:	50                   	push   %eax
f01037c2:	e8 ee fe ff ff       	call   f01036b5 <irq_setmask_8259A>
f01037c7:	83 c4 10             	add    $0x10,%esp
}
f01037ca:	c9                   	leave  
f01037cb:	f3 c3                	repz ret 

f01037cd <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037cd:	55                   	push   %ebp
f01037ce:	89 e5                	mov    %esp,%ebp
f01037d0:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037d3:	ff 75 08             	pushl  0x8(%ebp)
f01037d6:	e8 b3 cf ff ff       	call   f010078e <cputchar>
	*cnt++;
}
f01037db:	83 c4 10             	add    $0x10,%esp
f01037de:	c9                   	leave  
f01037df:	c3                   	ret    

f01037e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037e0:	55                   	push   %ebp
f01037e1:	89 e5                	mov    %esp,%ebp
f01037e3:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01037e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01037ed:	ff 75 0c             	pushl  0xc(%ebp)
f01037f0:	ff 75 08             	pushl  0x8(%ebp)
f01037f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037f6:	50                   	push   %eax
f01037f7:	68 cd 37 10 f0       	push   $0xf01037cd
f01037fc:	e8 53 17 00 00       	call   f0104f54 <vprintfmt>
	return cnt;
}
f0103801:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103804:	c9                   	leave  
f0103805:	c3                   	ret    

f0103806 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103806:	55                   	push   %ebp
f0103807:	89 e5                	mov    %esp,%ebp
f0103809:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010380c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010380f:	50                   	push   %eax
f0103810:	ff 75 08             	pushl  0x8(%ebp)
f0103813:	e8 c8 ff ff ff       	call   f01037e0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103818:	c9                   	leave  
f0103819:	c3                   	ret    

f010381a <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010381a:	55                   	push   %ebp
f010381b:	89 e5                	mov    %esp,%ebp
f010381d:	57                   	push   %edi
f010381e:	56                   	push   %esi
f010381f:	53                   	push   %ebx
f0103820:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here:
	// edited by Lethe 

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int cpu_id = thiscpu->cpu_id;
f0103823:	e8 d2 23 00 00       	call   f0105bfa <cpunum>
f0103828:	6b c0 74             	imul   $0x74,%eax,%eax
f010382b:	0f b6 98 20 90 20 f0 	movzbl -0xfdf6fe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_id*( KSTKSIZE  + KSTKGAP);
f0103832:	e8 c3 23 00 00       	call   f0105bfa <cpunum>
f0103837:	6b c0 74             	imul   $0x74,%eax,%eax
f010383a:	89 d9                	mov    %ebx,%ecx
f010383c:	c1 e1 10             	shl    $0x10,%ecx
f010383f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103844:	29 ca                	sub    %ecx,%edx
f0103846:	89 90 30 90 20 f0    	mov    %edx,-0xfdf6fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010384c:	e8 a9 23 00 00       	call   f0105bfa <cpunum>
f0103851:	6b c0 74             	imul   $0x74,%eax,%eax
f0103854:	66 c7 80 34 90 20 f0 	movw   $0x10,-0xfdf6fcc(%eax)
f010385b:	10 00 
	
	// lab4 ts.ts_esp0 = KSTACKTOP;
	// lab4 ts.ts_ss0 = GD_KD;
	
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f010385d:	83 c3 05             	add    $0x5,%ebx
f0103860:	e8 95 23 00 00       	call   f0105bfa <cpunum>
f0103865:	89 c7                	mov    %eax,%edi
f0103867:	e8 8e 23 00 00       	call   f0105bfa <cpunum>
f010386c:	89 c6                	mov    %eax,%esi
f010386e:	e8 87 23 00 00       	call   f0105bfa <cpunum>
f0103873:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f010387a:	f0 67 00 
f010387d:	6b ff 74             	imul   $0x74,%edi,%edi
f0103880:	81 c7 2c 90 20 f0    	add    $0xf020902c,%edi
f0103886:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f010388d:	f0 
f010388e:	6b d6 74             	imul   $0x74,%esi,%edx
f0103891:	81 c2 2c 90 20 f0    	add    $0xf020902c,%edx
f0103897:	c1 ea 10             	shr    $0x10,%edx
f010389a:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f01038a1:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f01038a8:	40 
f01038a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ac:	05 2c 90 20 f0       	add    $0xf020902c,%eax
f01038b1:	c1 e8 18             	shr    $0x18,%eax
f01038b4:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
	sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpu_id].sd_s = 0;
f01038bb:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f01038c2:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01038c3:	c1 e3 03             	shl    $0x3,%ebx
f01038c6:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01038c9:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f01038ce:	0f 01 18             	lidtl  (%eax)
	
	ltr(GD_TSS0+8*cpu_id);
	//end lethe
	// Load the IDT
	lidt(&idt_pd);
}
f01038d1:	83 c4 0c             	add    $0xc,%esp
f01038d4:	5b                   	pop    %ebx
f01038d5:	5e                   	pop    %esi
f01038d6:	5f                   	pop    %edi
f01038d7:	5d                   	pop    %ebp
f01038d8:	c3                   	ret    

f01038d9 <trap_init>:
}


void
trap_init(void)
{
f01038d9:	55                   	push   %ebp
f01038da:	89 e5                	mov    %esp,%ebp
f01038dc:	83 ec 08             	sub    $0x8,%esp
	// look up the definition of SETGATE in inc/mmu.h
	// #define SETGATE(gate, istrap, sel, off, dpl)
	// istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate

	// from #0 to #7
	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_error, 0);
f01038df:	b8 9a 42 10 f0       	mov    $0xf010429a,%eax
f01038e4:	66 a3 60 82 20 f0    	mov    %ax,0xf0208260
f01038ea:	66 c7 05 62 82 20 f0 	movw   $0x8,0xf0208262
f01038f1:	08 00 
f01038f3:	c6 05 64 82 20 f0 00 	movb   $0x0,0xf0208264
f01038fa:	c6 05 65 82 20 f0 8e 	movb   $0x8e,0xf0208265
f0103901:	c1 e8 10             	shr    $0x10,%eax
f0103904:	66 a3 66 82 20 f0    	mov    %ax,0xf0208266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_exception, 0);
f010390a:	b8 a4 42 10 f0       	mov    $0xf01042a4,%eax
f010390f:	66 a3 68 82 20 f0    	mov    %ax,0xf0208268
f0103915:	66 c7 05 6a 82 20 f0 	movw   $0x8,0xf020826a
f010391c:	08 00 
f010391e:	c6 05 6c 82 20 f0 00 	movb   $0x0,0xf020826c
f0103925:	c6 05 6d 82 20 f0 8e 	movb   $0x8e,0xf020826d
f010392c:	c1 e8 10             	shr    $0x10,%eax
f010392f:	66 a3 6e 82 20 f0    	mov    %ax,0xf020826e
	SETGATE(idt[T_NMI], 0, GD_KT, non_maskable_interrupt, 0);
f0103935:	b8 aa 42 10 f0       	mov    $0xf01042aa,%eax
f010393a:	66 a3 70 82 20 f0    	mov    %ax,0xf0208270
f0103940:	66 c7 05 72 82 20 f0 	movw   $0x8,0xf0208272
f0103947:	08 00 
f0103949:	c6 05 74 82 20 f0 00 	movb   $0x0,0xf0208274
f0103950:	c6 05 75 82 20 f0 8e 	movb   $0x8e,0xf0208275
f0103957:	c1 e8 10             	shr    $0x10,%eax
f010395a:	66 a3 76 82 20 f0    	mov    %ax,0xf0208276

	// pay more attention to this
	SETGATE(idt[T_BRKPT], 0, GD_KT, _breakpoint, 3);
f0103960:	b8 b0 42 10 f0       	mov    $0xf01042b0,%eax
f0103965:	66 a3 78 82 20 f0    	mov    %ax,0xf0208278
f010396b:	66 c7 05 7a 82 20 f0 	movw   $0x8,0xf020827a
f0103972:	08 00 
f0103974:	c6 05 7c 82 20 f0 00 	movb   $0x0,0xf020827c
f010397b:	c6 05 7d 82 20 f0 ee 	movb   $0xee,0xf020827d
f0103982:	c1 e8 10             	shr    $0x10,%eax
f0103985:	66 a3 7e 82 20 f0    	mov    %ax,0xf020827e

	SETGATE(idt[T_OFLOW], 0, GD_KT, overflow, 0);
f010398b:	b8 b6 42 10 f0       	mov    $0xf01042b6,%eax
f0103990:	66 a3 80 82 20 f0    	mov    %ax,0xf0208280
f0103996:	66 c7 05 82 82 20 f0 	movw   $0x8,0xf0208282
f010399d:	08 00 
f010399f:	c6 05 84 82 20 f0 00 	movb   $0x0,0xf0208284
f01039a6:	c6 05 85 82 20 f0 8e 	movb   $0x8e,0xf0208285
f01039ad:	c1 e8 10             	shr    $0x10,%eax
f01039b0:	66 a3 86 82 20 f0    	mov    %ax,0xf0208286
	SETGATE(idt[T_BOUND], 0, GD_KT, bounds_check, 0);
f01039b6:	b8 bc 42 10 f0       	mov    $0xf01042bc,%eax
f01039bb:	66 a3 88 82 20 f0    	mov    %ax,0xf0208288
f01039c1:	66 c7 05 8a 82 20 f0 	movw   $0x8,0xf020828a
f01039c8:	08 00 
f01039ca:	c6 05 8c 82 20 f0 00 	movb   $0x0,0xf020828c
f01039d1:	c6 05 8d 82 20 f0 8e 	movb   $0x8e,0xf020828d
f01039d8:	c1 e8 10             	shr    $0x10,%eax
f01039db:	66 a3 8e 82 20 f0    	mov    %ax,0xf020828e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illegal_opcode, 0);
f01039e1:	b8 c2 42 10 f0       	mov    $0xf01042c2,%eax
f01039e6:	66 a3 90 82 20 f0    	mov    %ax,0xf0208290
f01039ec:	66 c7 05 92 82 20 f0 	movw   $0x8,0xf0208292
f01039f3:	08 00 
f01039f5:	c6 05 94 82 20 f0 00 	movb   $0x0,0xf0208294
f01039fc:	c6 05 95 82 20 f0 8e 	movb   $0x8e,0xf0208295
f0103a03:	c1 e8 10             	shr    $0x10,%eax
f0103a06:	66 a3 96 82 20 f0    	mov    %ax,0xf0208296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_not_available, 0);
f0103a0c:	b8 c8 42 10 f0       	mov    $0xf01042c8,%eax
f0103a11:	66 a3 98 82 20 f0    	mov    %ax,0xf0208298
f0103a17:	66 c7 05 9a 82 20 f0 	movw   $0x8,0xf020829a
f0103a1e:	08 00 
f0103a20:	c6 05 9c 82 20 f0 00 	movb   $0x0,0xf020829c
f0103a27:	c6 05 9d 82 20 f0 8e 	movb   $0x8e,0xf020829d
f0103a2e:	c1 e8 10             	shr    $0x10,%eax
f0103a31:	66 a3 9e 82 20 f0    	mov    %ax,0xf020829e

	// from #8 to #14, without #9
	SETGATE(idt[T_DBLFLT], 0, GD_KT, double_fault, 0);
f0103a37:	b8 ce 42 10 f0       	mov    $0xf01042ce,%eax
f0103a3c:	66 a3 a0 82 20 f0    	mov    %ax,0xf02082a0
f0103a42:	66 c7 05 a2 82 20 f0 	movw   $0x8,0xf02082a2
f0103a49:	08 00 
f0103a4b:	c6 05 a4 82 20 f0 00 	movb   $0x0,0xf02082a4
f0103a52:	c6 05 a5 82 20 f0 8e 	movb   $0x8e,0xf02082a5
f0103a59:	c1 e8 10             	shr    $0x10,%eax
f0103a5c:	66 a3 a6 82 20 f0    	mov    %ax,0xf02082a6
	SETGATE(idt[T_TSS], 0, GD_KT, invalid_task_switch_segment, 0);
f0103a62:	b8 d2 42 10 f0       	mov    $0xf01042d2,%eax
f0103a67:	66 a3 b0 82 20 f0    	mov    %ax,0xf02082b0
f0103a6d:	66 c7 05 b2 82 20 f0 	movw   $0x8,0xf02082b2
f0103a74:	08 00 
f0103a76:	c6 05 b4 82 20 f0 00 	movb   $0x0,0xf02082b4
f0103a7d:	c6 05 b5 82 20 f0 8e 	movb   $0x8e,0xf02082b5
f0103a84:	c1 e8 10             	shr    $0x10,%eax
f0103a87:	66 a3 b6 82 20 f0    	mov    %ax,0xf02082b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segment_not_present, 0);
f0103a8d:	b8 d6 42 10 f0       	mov    $0xf01042d6,%eax
f0103a92:	66 a3 b8 82 20 f0    	mov    %ax,0xf02082b8
f0103a98:	66 c7 05 ba 82 20 f0 	movw   $0x8,0xf02082ba
f0103a9f:	08 00 
f0103aa1:	c6 05 bc 82 20 f0 00 	movb   $0x0,0xf02082bc
f0103aa8:	c6 05 bd 82 20 f0 8e 	movb   $0x8e,0xf02082bd
f0103aaf:	c1 e8 10             	shr    $0x10,%eax
f0103ab2:	66 a3 be 82 20 f0    	mov    %ax,0xf02082be
	SETGATE(idt[T_STACK], 0, GD_KT, stack_exception, 0);
f0103ab8:	b8 da 42 10 f0       	mov    $0xf01042da,%eax
f0103abd:	66 a3 c0 82 20 f0    	mov    %ax,0xf02082c0
f0103ac3:	66 c7 05 c2 82 20 f0 	movw   $0x8,0xf02082c2
f0103aca:	08 00 
f0103acc:	c6 05 c4 82 20 f0 00 	movb   $0x0,0xf02082c4
f0103ad3:	c6 05 c5 82 20 f0 8e 	movb   $0x8e,0xf02082c5
f0103ada:	c1 e8 10             	shr    $0x10,%eax
f0103add:	66 a3 c6 82 20 f0    	mov    %ax,0xf02082c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, general_protection_fault, 0);
f0103ae3:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f0103ae8:	66 a3 c8 82 20 f0    	mov    %ax,0xf02082c8
f0103aee:	66 c7 05 ca 82 20 f0 	movw   $0x8,0xf02082ca
f0103af5:	08 00 
f0103af7:	c6 05 cc 82 20 f0 00 	movb   $0x0,0xf02082cc
f0103afe:	c6 05 cd 82 20 f0 8e 	movb   $0x8e,0xf02082cd
f0103b05:	c1 e8 10             	shr    $0x10,%eax
f0103b08:	66 a3 ce 82 20 f0    	mov    %ax,0xf02082ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, page_fault, 0);
f0103b0e:	b8 e2 42 10 f0       	mov    $0xf01042e2,%eax
f0103b13:	66 a3 d0 82 20 f0    	mov    %ax,0xf02082d0
f0103b19:	66 c7 05 d2 82 20 f0 	movw   $0x8,0xf02082d2
f0103b20:	08 00 
f0103b22:	c6 05 d4 82 20 f0 00 	movb   $0x0,0xf02082d4
f0103b29:	c6 05 d5 82 20 f0 8e 	movb   $0x8e,0xf02082d5
f0103b30:	c1 e8 10             	shr    $0x10,%eax
f0103b33:	66 a3 d6 82 20 f0    	mov    %ax,0xf02082d6

	// from #16 to #19
	SETGATE(idt[T_FPERR], 0, GD_KT, floating_point_error, 0);
f0103b39:	b8 e6 42 10 f0       	mov    $0xf01042e6,%eax
f0103b3e:	66 a3 e0 82 20 f0    	mov    %ax,0xf02082e0
f0103b44:	66 c7 05 e2 82 20 f0 	movw   $0x8,0xf02082e2
f0103b4b:	08 00 
f0103b4d:	c6 05 e4 82 20 f0 00 	movb   $0x0,0xf02082e4
f0103b54:	c6 05 e5 82 20 f0 8e 	movb   $0x8e,0xf02082e5
f0103b5b:	c1 e8 10             	shr    $0x10,%eax
f0103b5e:	66 a3 e6 82 20 f0    	mov    %ax,0xf02082e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, alignment_check, 0);
f0103b64:	b8 ec 42 10 f0       	mov    $0xf01042ec,%eax
f0103b69:	66 a3 e8 82 20 f0    	mov    %ax,0xf02082e8
f0103b6f:	66 c7 05 ea 82 20 f0 	movw   $0x8,0xf02082ea
f0103b76:	08 00 
f0103b78:	c6 05 ec 82 20 f0 00 	movb   $0x0,0xf02082ec
f0103b7f:	c6 05 ed 82 20 f0 8e 	movb   $0x8e,0xf02082ed
f0103b86:	c1 e8 10             	shr    $0x10,%eax
f0103b89:	66 a3 ee 82 20 f0    	mov    %ax,0xf02082ee
	SETGATE(idt[T_MCHK], 0, GD_KT, machine_check, 0);
f0103b8f:	b8 f2 42 10 f0       	mov    $0xf01042f2,%eax
f0103b94:	66 a3 f0 82 20 f0    	mov    %ax,0xf02082f0
f0103b9a:	66 c7 05 f2 82 20 f0 	movw   $0x8,0xf02082f2
f0103ba1:	08 00 
f0103ba3:	c6 05 f4 82 20 f0 00 	movb   $0x0,0xf02082f4
f0103baa:	c6 05 f5 82 20 f0 8e 	movb   $0x8e,0xf02082f5
f0103bb1:	c1 e8 10             	shr    $0x10,%eax
f0103bb4:	66 a3 f6 82 20 f0    	mov    %ax,0xf02082f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, SIMD_floating_point_error, 0);
f0103bba:	b8 f8 42 10 f0       	mov    $0xf01042f8,%eax
f0103bbf:	66 a3 f8 82 20 f0    	mov    %ax,0xf02082f8
f0103bc5:	66 c7 05 fa 82 20 f0 	movw   $0x8,0xf02082fa
f0103bcc:	08 00 
f0103bce:	c6 05 fc 82 20 f0 00 	movb   $0x0,0xf02082fc
f0103bd5:	c6 05 fd 82 20 f0 8e 	movb   $0x8e,0xf02082fd
f0103bdc:	c1 e8 10             	shr    $0x10,%eax
f0103bdf:	66 a3 fe 82 20 f0    	mov    %ax,0xf02082fe

	// #48, syscall
	SETGATE(idt[T_SYSCALL], 0, GD_KT, system_call, 3);
f0103be5:	b8 fe 42 10 f0       	mov    $0xf01042fe,%eax
f0103bea:	66 a3 e0 83 20 f0    	mov    %ax,0xf02083e0
f0103bf0:	66 c7 05 e2 83 20 f0 	movw   $0x8,0xf02083e2
f0103bf7:	08 00 
f0103bf9:	c6 05 e4 83 20 f0 00 	movb   $0x0,0xf02083e4
f0103c00:	c6 05 e5 83 20 f0 ee 	movb   $0xee,0xf02083e5
f0103c07:	c1 e8 10             	shr    $0x10,%eax
f0103c0a:	66 a3 e6 83 20 f0    	mov    %ax,0xf02083e6

	// exercise 13, lab 4
	// edited by Lethe 
	// Notice! istrap 0 for an interrupt gate
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_handler32, 0);
f0103c10:	b8 04 43 10 f0       	mov    $0xf0104304,%eax
f0103c15:	66 a3 60 83 20 f0    	mov    %ax,0xf0208360
f0103c1b:	66 c7 05 62 83 20 f0 	movw   $0x8,0xf0208362
f0103c22:	08 00 
f0103c24:	c6 05 64 83 20 f0 00 	movb   $0x0,0xf0208364
f0103c2b:	c6 05 65 83 20 f0 8e 	movb   $0x8e,0xf0208365
f0103c32:	c1 e8 10             	shr    $0x10,%eax
f0103c35:	66 a3 66 83 20 f0    	mov    %ax,0xf0208366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_handler33, 0);
f0103c3b:	b8 0a 43 10 f0       	mov    $0xf010430a,%eax
f0103c40:	66 a3 68 83 20 f0    	mov    %ax,0xf0208368
f0103c46:	66 c7 05 6a 83 20 f0 	movw   $0x8,0xf020836a
f0103c4d:	08 00 
f0103c4f:	c6 05 6c 83 20 f0 00 	movb   $0x0,0xf020836c
f0103c56:	c6 05 6d 83 20 f0 8e 	movb   $0x8e,0xf020836d
f0103c5d:	c1 e8 10             	shr    $0x10,%eax
f0103c60:	66 a3 6e 83 20 f0    	mov    %ax,0xf020836e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_handler36, 0);
f0103c66:	b8 10 43 10 f0       	mov    $0xf0104310,%eax
f0103c6b:	66 a3 80 83 20 f0    	mov    %ax,0xf0208380
f0103c71:	66 c7 05 82 83 20 f0 	movw   $0x8,0xf0208382
f0103c78:	08 00 
f0103c7a:	c6 05 84 83 20 f0 00 	movb   $0x0,0xf0208384
f0103c81:	c6 05 85 83 20 f0 8e 	movb   $0x8e,0xf0208385
f0103c88:	c1 e8 10             	shr    $0x10,%eax
f0103c8b:	66 a3 86 83 20 f0    	mov    %ax,0xf0208386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_handler39, 0);
f0103c91:	b8 16 43 10 f0       	mov    $0xf0104316,%eax
f0103c96:	66 a3 98 83 20 f0    	mov    %ax,0xf0208398
f0103c9c:	66 c7 05 9a 83 20 f0 	movw   $0x8,0xf020839a
f0103ca3:	08 00 
f0103ca5:	c6 05 9c 83 20 f0 00 	movb   $0x0,0xf020839c
f0103cac:	c6 05 9d 83 20 f0 8e 	movb   $0x8e,0xf020839d
f0103cb3:	c1 e8 10             	shr    $0x10,%eax
f0103cb6:	66 a3 9e 83 20 f0    	mov    %ax,0xf020839e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_handler46, 0);
f0103cbc:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f0103cc1:	66 a3 d0 83 20 f0    	mov    %ax,0xf02083d0
f0103cc7:	66 c7 05 d2 83 20 f0 	movw   $0x8,0xf02083d2
f0103cce:	08 00 
f0103cd0:	c6 05 d4 83 20 f0 00 	movb   $0x0,0xf02083d4
f0103cd7:	c6 05 d5 83 20 f0 8e 	movb   $0x8e,0xf02083d5
f0103cde:	c1 e8 10             	shr    $0x10,%eax
f0103ce1:	66 a3 d6 83 20 f0    	mov    %ax,0xf02083d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_handler51, 0);
f0103ce7:	b8 22 43 10 f0       	mov    $0xf0104322,%eax
f0103cec:	66 a3 f8 83 20 f0    	mov    %ax,0xf02083f8
f0103cf2:	66 c7 05 fa 83 20 f0 	movw   $0x8,0xf02083fa
f0103cf9:	08 00 
f0103cfb:	c6 05 fc 83 20 f0 00 	movb   $0x0,0xf02083fc
f0103d02:	c6 05 fd 83 20 f0 8e 	movb   $0x8e,0xf02083fd
f0103d09:	c1 e8 10             	shr    $0x10,%eax
f0103d0c:	66 a3 fe 83 20 f0    	mov    %ax,0xf02083fe

	// Per-CPU setup 
	trap_init_percpu();
f0103d12:	e8 03 fb ff ff       	call   f010381a <trap_init_percpu>
}
f0103d17:	c9                   	leave  
f0103d18:	c3                   	ret    

f0103d19 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d19:	55                   	push   %ebp
f0103d1a:	89 e5                	mov    %esp,%ebp
f0103d1c:	53                   	push   %ebx
f0103d1d:	83 ec 0c             	sub    $0xc,%esp
f0103d20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d23:	ff 33                	pushl  (%ebx)
f0103d25:	68 3c 77 10 f0       	push   $0xf010773c
f0103d2a:	e8 d7 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d2f:	83 c4 08             	add    $0x8,%esp
f0103d32:	ff 73 04             	pushl  0x4(%ebx)
f0103d35:	68 4b 77 10 f0       	push   $0xf010774b
f0103d3a:	e8 c7 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d3f:	83 c4 08             	add    $0x8,%esp
f0103d42:	ff 73 08             	pushl  0x8(%ebx)
f0103d45:	68 5a 77 10 f0       	push   $0xf010775a
f0103d4a:	e8 b7 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d4f:	83 c4 08             	add    $0x8,%esp
f0103d52:	ff 73 0c             	pushl  0xc(%ebx)
f0103d55:	68 69 77 10 f0       	push   $0xf0107769
f0103d5a:	e8 a7 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d5f:	83 c4 08             	add    $0x8,%esp
f0103d62:	ff 73 10             	pushl  0x10(%ebx)
f0103d65:	68 78 77 10 f0       	push   $0xf0107778
f0103d6a:	e8 97 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d6f:	83 c4 08             	add    $0x8,%esp
f0103d72:	ff 73 14             	pushl  0x14(%ebx)
f0103d75:	68 87 77 10 f0       	push   $0xf0107787
f0103d7a:	e8 87 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d7f:	83 c4 08             	add    $0x8,%esp
f0103d82:	ff 73 18             	pushl  0x18(%ebx)
f0103d85:	68 96 77 10 f0       	push   $0xf0107796
f0103d8a:	e8 77 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d8f:	83 c4 08             	add    $0x8,%esp
f0103d92:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d95:	68 a5 77 10 f0       	push   $0xf01077a5
f0103d9a:	e8 67 fa ff ff       	call   f0103806 <cprintf>
}
f0103d9f:	83 c4 10             	add    $0x10,%esp
f0103da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103da5:	c9                   	leave  
f0103da6:	c3                   	ret    

f0103da7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103da7:	55                   	push   %ebp
f0103da8:	89 e5                	mov    %esp,%ebp
f0103daa:	56                   	push   %esi
f0103dab:	53                   	push   %ebx
f0103dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103daf:	e8 46 1e 00 00       	call   f0105bfa <cpunum>
f0103db4:	83 ec 04             	sub    $0x4,%esp
f0103db7:	50                   	push   %eax
f0103db8:	53                   	push   %ebx
f0103db9:	68 09 78 10 f0       	push   $0xf0107809
f0103dbe:	e8 43 fa ff ff       	call   f0103806 <cprintf>
	print_regs(&tf->tf_regs);
f0103dc3:	89 1c 24             	mov    %ebx,(%esp)
f0103dc6:	e8 4e ff ff ff       	call   f0103d19 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103dcb:	83 c4 08             	add    $0x8,%esp
f0103dce:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103dd2:	50                   	push   %eax
f0103dd3:	68 27 78 10 f0       	push   $0xf0107827
f0103dd8:	e8 29 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ddd:	83 c4 08             	add    $0x8,%esp
f0103de0:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103de4:	50                   	push   %eax
f0103de5:	68 3a 78 10 f0       	push   $0xf010783a
f0103dea:	e8 17 fa ff ff       	call   f0103806 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103def:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103df2:	83 c4 10             	add    $0x10,%esp
f0103df5:	83 f8 13             	cmp    $0x13,%eax
f0103df8:	77 09                	ja     f0103e03 <print_trapframe+0x5c>
		return excnames[trapno];
f0103dfa:	8b 14 85 e0 7a 10 f0 	mov    -0xfef8520(,%eax,4),%edx
f0103e01:	eb 1f                	jmp    f0103e22 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e03:	83 f8 30             	cmp    $0x30,%eax
f0103e06:	74 15                	je     f0103e1d <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e08:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e0b:	83 fa 10             	cmp    $0x10,%edx
f0103e0e:	b9 d3 77 10 f0       	mov    $0xf01077d3,%ecx
f0103e13:	ba c0 77 10 f0       	mov    $0xf01077c0,%edx
f0103e18:	0f 43 d1             	cmovae %ecx,%edx
f0103e1b:	eb 05                	jmp    f0103e22 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e1d:	ba b4 77 10 f0       	mov    $0xf01077b4,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e22:	83 ec 04             	sub    $0x4,%esp
f0103e25:	52                   	push   %edx
f0103e26:	50                   	push   %eax
f0103e27:	68 4d 78 10 f0       	push   $0xf010784d
f0103e2c:	e8 d5 f9 ff ff       	call   f0103806 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e31:	83 c4 10             	add    $0x10,%esp
f0103e34:	3b 1d 60 8a 20 f0    	cmp    0xf0208a60,%ebx
f0103e3a:	75 1a                	jne    f0103e56 <print_trapframe+0xaf>
f0103e3c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e40:	75 14                	jne    f0103e56 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103e42:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e45:	83 ec 08             	sub    $0x8,%esp
f0103e48:	50                   	push   %eax
f0103e49:	68 5f 78 10 f0       	push   $0xf010785f
f0103e4e:	e8 b3 f9 ff ff       	call   f0103806 <cprintf>
f0103e53:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e56:	83 ec 08             	sub    $0x8,%esp
f0103e59:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e5c:	68 6e 78 10 f0       	push   $0xf010786e
f0103e61:	e8 a0 f9 ff ff       	call   f0103806 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e66:	83 c4 10             	add    $0x10,%esp
f0103e69:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e6d:	75 49                	jne    f0103eb8 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e6f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e72:	89 c2                	mov    %eax,%edx
f0103e74:	83 e2 01             	and    $0x1,%edx
f0103e77:	ba ed 77 10 f0       	mov    $0xf01077ed,%edx
f0103e7c:	b9 e2 77 10 f0       	mov    $0xf01077e2,%ecx
f0103e81:	0f 44 ca             	cmove  %edx,%ecx
f0103e84:	89 c2                	mov    %eax,%edx
f0103e86:	83 e2 02             	and    $0x2,%edx
f0103e89:	ba ff 77 10 f0       	mov    $0xf01077ff,%edx
f0103e8e:	be f9 77 10 f0       	mov    $0xf01077f9,%esi
f0103e93:	0f 45 d6             	cmovne %esi,%edx
f0103e96:	83 e0 04             	and    $0x4,%eax
f0103e99:	be 39 79 10 f0       	mov    $0xf0107939,%esi
f0103e9e:	b8 04 78 10 f0       	mov    $0xf0107804,%eax
f0103ea3:	0f 44 c6             	cmove  %esi,%eax
f0103ea6:	51                   	push   %ecx
f0103ea7:	52                   	push   %edx
f0103ea8:	50                   	push   %eax
f0103ea9:	68 7c 78 10 f0       	push   $0xf010787c
f0103eae:	e8 53 f9 ff ff       	call   f0103806 <cprintf>
f0103eb3:	83 c4 10             	add    $0x10,%esp
f0103eb6:	eb 10                	jmp    f0103ec8 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103eb8:	83 ec 0c             	sub    $0xc,%esp
f0103ebb:	68 e0 76 10 f0       	push   $0xf01076e0
f0103ec0:	e8 41 f9 ff ff       	call   f0103806 <cprintf>
f0103ec5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ec8:	83 ec 08             	sub    $0x8,%esp
f0103ecb:	ff 73 30             	pushl  0x30(%ebx)
f0103ece:	68 8b 78 10 f0       	push   $0xf010788b
f0103ed3:	e8 2e f9 ff ff       	call   f0103806 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ed8:	83 c4 08             	add    $0x8,%esp
f0103edb:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103edf:	50                   	push   %eax
f0103ee0:	68 9a 78 10 f0       	push   $0xf010789a
f0103ee5:	e8 1c f9 ff ff       	call   f0103806 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103eea:	83 c4 08             	add    $0x8,%esp
f0103eed:	ff 73 38             	pushl  0x38(%ebx)
f0103ef0:	68 ad 78 10 f0       	push   $0xf01078ad
f0103ef5:	e8 0c f9 ff ff       	call   f0103806 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103efa:	83 c4 10             	add    $0x10,%esp
f0103efd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f01:	74 25                	je     f0103f28 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f03:	83 ec 08             	sub    $0x8,%esp
f0103f06:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f09:	68 bc 78 10 f0       	push   $0xf01078bc
f0103f0e:	e8 f3 f8 ff ff       	call   f0103806 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f13:	83 c4 08             	add    $0x8,%esp
f0103f16:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f1a:	50                   	push   %eax
f0103f1b:	68 cb 78 10 f0       	push   $0xf01078cb
f0103f20:	e8 e1 f8 ff ff       	call   f0103806 <cprintf>
f0103f25:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f28:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f2b:	5b                   	pop    %ebx
f0103f2c:	5e                   	pop    %esi
f0103f2d:	5d                   	pop    %ebp
f0103f2e:	c3                   	ret    

f0103f2f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f2f:	55                   	push   %ebp
f0103f30:	89 e5                	mov    %esp,%ebp
f0103f32:	57                   	push   %edi
f0103f33:	56                   	push   %esi
f0103f34:	53                   	push   %ebx
f0103f35:	83 ec 0c             	sub    $0xc,%esp
f0103f38:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f3b:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// edited by Lethe 
	if ((tf->tf_cs & 3) == 0) {
f0103f3e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f42:	75 15                	jne    f0103f59 <page_fault_handler+0x2a>
		panic("Kernel-mode page faults, fault virtual address: %d\n", fault_va);
f0103f44:	56                   	push   %esi
f0103f45:	68 84 7a 10 f0       	push   $0xf0107a84
f0103f4a:	68 98 01 00 00       	push   $0x198
f0103f4f:	68 de 78 10 f0       	push   $0xf01078de
f0103f54:	e8 e7 c0 ff ff       	call   f0100040 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	// check for the page fault call at first
	if (curenv->env_pgfault_upcall) {
f0103f59:	e8 9c 1c 00 00       	call   f0105bfa <cpunum>
f0103f5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f61:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0103f67:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103f6b:	0f 84 a7 00 00 00    	je     f0104018 <page_fault_handler+0xe9>
		struct UTrapframe * utf = NULL;
		uintptr_t utf_addr = 0;

		if (((UXSTACKTOP - PGSIZE) <= (tf->tf_esp)) && 
f0103f71:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f74:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			// if the user env is already running on the user exception stack
			// when an exception occurs, the trap handler needs one word of 
			// scratch space at the top of the trap-time stack for recursive case

			// 4 bytes equal to 32 bits
			utf_addr = (tf->tf_esp) - sizeof(struct UTrapframe) - 4;
f0103f7a:	83 e8 38             	sub    $0x38,%eax
f0103f7d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f83:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103f88:	0f 46 d0             	cmovbe %eax,%edx
f0103f8b:	89 d7                	mov    %edx,%edi
		// If it can, then the function simply returns.
		// If it cannot, 'env' is destroyed and, if env is the current
		// environment, this function will not return.

		// argument lens is doesn't matter at here, so we set 1
		user_mem_assert(curenv, (void *)utf_addr, 1, PTE_U|PTE_W);
f0103f8d:	e8 68 1c 00 00       	call   f0105bfa <cpunum>
f0103f92:	6a 06                	push   $0x6
f0103f94:	6a 01                	push   $0x1
f0103f96:	57                   	push   %edi
f0103f97:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9a:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0103fa0:	e8 5a ef ff ff       	call   f0102eff <user_mem_assert>
		// set utf points to address of the newly allocated
		// user exception stack fram
		utf = (struct UTrapframe *)utf_addr;

		// set UTrapFrame
		utf->utf_fault_va = fault_va;
f0103fa5:	89 fa                	mov    %edi,%edx
f0103fa7:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0103fa9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103fac:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0103faf:	8d 7f 08             	lea    0x8(%edi),%edi
f0103fb2:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103fb7:	89 de                	mov    %ebx,%esi
f0103fb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103fbb:	8b 43 30             	mov    0x30(%ebx),%eax
f0103fbe:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0103fc1:	8b 43 38             	mov    0x38(%ebx),%eax
f0103fc4:	89 d7                	mov    %edx,%edi
f0103fc6:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0103fc9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fcc:	89 42 30             	mov    %eax,0x30(%edx)

		// branch to curenv->env_pgfault_upcall
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0103fcf:	e8 26 1c 00 00       	call   f0105bfa <cpunum>
f0103fd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd7:	8b 98 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%ebx
f0103fdd:	e8 18 1c 00 00       	call   f0105bfa <cpunum>
f0103fe2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe5:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0103feb:	8b 40 64             	mov    0x64(%eax),%eax
f0103fee:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = utf_addr;
f0103ff1:	e8 04 1c 00 00       	call   f0105bfa <cpunum>
f0103ff6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff9:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0103fff:	89 78 3c             	mov    %edi,0x3c(%eax)

		// env_run doesn't return
		env_run(curenv);
f0104002:	e8 f3 1b 00 00       	call   f0105bfa <cpunum>
f0104007:	83 c4 04             	add    $0x4,%esp
f010400a:	6b c0 74             	imul   $0x74,%eax,%eax
f010400d:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104013:	e8 d4 f5 ff ff       	call   f01035ec <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104018:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010401b:	e8 da 1b 00 00       	call   f0105bfa <cpunum>
		// env_run doesn't return
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104020:	57                   	push   %edi
f0104021:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104022:	6b c0 74             	imul   $0x74,%eax,%eax
		// env_run doesn't return
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104025:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f010402b:	ff 70 48             	pushl  0x48(%eax)
f010402e:	68 b8 7a 10 f0       	push   $0xf0107ab8
f0104033:	e8 ce f7 ff ff       	call   f0103806 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104038:	89 1c 24             	mov    %ebx,(%esp)
f010403b:	e8 67 fd ff ff       	call   f0103da7 <print_trapframe>
	env_destroy(curenv);
f0104040:	e8 b5 1b 00 00       	call   f0105bfa <cpunum>
f0104045:	83 c4 04             	add    $0x4,%esp
f0104048:	6b c0 74             	imul   $0x74,%eax,%eax
f010404b:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104051:	e8 f7 f4 ff ff       	call   f010354d <env_destroy>
}
f0104056:	83 c4 10             	add    $0x10,%esp
f0104059:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010405c:	5b                   	pop    %ebx
f010405d:	5e                   	pop    %esi
f010405e:	5f                   	pop    %edi
f010405f:	5d                   	pop    %ebp
f0104060:	c3                   	ret    

f0104061 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104061:	55                   	push   %ebp
f0104062:	89 e5                	mov    %esp,%ebp
f0104064:	57                   	push   %edi
f0104065:	56                   	push   %esi
f0104066:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104069:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010406a:	83 3d 80 8e 20 f0 00 	cmpl   $0x0,0xf0208e80
f0104071:	74 01                	je     f0104074 <trap+0x13>
		asm volatile("hlt");
f0104073:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104074:	e8 81 1b 00 00       	call   f0105bfa <cpunum>
f0104079:	6b d0 74             	imul   $0x74,%eax,%edx
f010407c:	81 c2 20 90 20 f0    	add    $0xf0209020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104082:	b8 01 00 00 00       	mov    $0x1,%eax
f0104087:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010408b:	83 f8 02             	cmp    $0x2,%eax
f010408e:	75 10                	jne    f01040a0 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104090:	83 ec 0c             	sub    $0xc,%esp
f0104093:	68 c0 03 12 f0       	push   $0xf01203c0
f0104098:	e8 cb 1d 00 00       	call   f0105e68 <spin_lock>
f010409d:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01040a0:	9c                   	pushf  
f01040a1:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01040a2:	f6 c4 02             	test   $0x2,%ah
f01040a5:	74 19                	je     f01040c0 <trap+0x5f>
f01040a7:	68 ea 78 10 f0       	push   $0xf01078ea
f01040ac:	68 65 6a 10 f0       	push   $0xf0106a65
f01040b1:	68 5e 01 00 00       	push   $0x15e
f01040b6:	68 de 78 10 f0       	push   $0xf01078de
f01040bb:	e8 80 bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01040c0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040c4:	83 e0 03             	and    $0x3,%eax
f01040c7:	66 83 f8 03          	cmp    $0x3,%ax
f01040cb:	0f 85 a0 00 00 00    	jne    f0104171 <trap+0x110>
f01040d1:	83 ec 0c             	sub    $0xc,%esp
f01040d4:	68 c0 03 12 f0       	push   $0xf01203c0
f01040d9:	e8 8a 1d 00 00       	call   f0105e68 <spin_lock>
		// LAB 4: Your code here.
		// edited by Lethe 
		// exercise 5, lab 4
		lock_kernel();

		assert(curenv);
f01040de:	e8 17 1b 00 00       	call   f0105bfa <cpunum>
f01040e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e6:	83 c4 10             	add    $0x10,%esp
f01040e9:	83 b8 28 90 20 f0 00 	cmpl   $0x0,-0xfdf6fd8(%eax)
f01040f0:	75 19                	jne    f010410b <trap+0xaa>
f01040f2:	68 03 79 10 f0       	push   $0xf0107903
f01040f7:	68 65 6a 10 f0       	push   $0xf0106a65
f01040fc:	68 69 01 00 00       	push   $0x169
f0104101:	68 de 78 10 f0       	push   $0xf01078de
f0104106:	e8 35 bf ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010410b:	e8 ea 1a 00 00       	call   f0105bfa <cpunum>
f0104110:	6b c0 74             	imul   $0x74,%eax,%eax
f0104113:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0104119:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010411d:	75 2d                	jne    f010414c <trap+0xeb>
			env_free(curenv);
f010411f:	e8 d6 1a 00 00       	call   f0105bfa <cpunum>
f0104124:	83 ec 0c             	sub    $0xc,%esp
f0104127:	6b c0 74             	imul   $0x74,%eax,%eax
f010412a:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104130:	e8 72 f2 ff ff       	call   f01033a7 <env_free>
			curenv = NULL;
f0104135:	e8 c0 1a 00 00       	call   f0105bfa <cpunum>
f010413a:	6b c0 74             	imul   $0x74,%eax,%eax
f010413d:	c7 80 28 90 20 f0 00 	movl   $0x0,-0xfdf6fd8(%eax)
f0104144:	00 00 00 
			sched_yield();
f0104147:	e8 c7 02 00 00       	call   f0104413 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010414c:	e8 a9 1a 00 00       	call   f0105bfa <cpunum>
f0104151:	6b c0 74             	imul   $0x74,%eax,%eax
f0104154:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f010415a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010415f:	89 c7                	mov    %eax,%edi
f0104161:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104163:	e8 92 1a 00 00       	call   f0105bfa <cpunum>
f0104168:	6b c0 74             	imul   $0x74,%eax,%eax
f010416b:	8b b0 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104171:	89 35 60 8a 20 f0    	mov    %esi,0xf0208a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// edited by Lethe 
	switch (tf->tf_trapno)
f0104177:	8b 46 28             	mov    0x28(%esi),%eax
f010417a:	83 f8 0e             	cmp    $0xe,%eax
f010417d:	74 0c                	je     f010418b <trap+0x12a>
f010417f:	83 f8 30             	cmp    $0x30,%eax
f0104182:	74 29                	je     f01041ad <trap+0x14c>
f0104184:	83 f8 03             	cmp    $0x3,%eax
f0104187:	75 48                	jne    f01041d1 <trap+0x170>
f0104189:	eb 11                	jmp    f010419c <trap+0x13b>
	{
	case T_PGFLT:
		page_fault_handler(tf);
f010418b:	83 ec 0c             	sub    $0xc,%esp
f010418e:	56                   	push   %esi
f010418f:	e8 9b fd ff ff       	call   f0103f2f <page_fault_handler>
f0104194:	83 c4 10             	add    $0x10,%esp
f0104197:	e9 be 00 00 00       	jmp    f010425a <trap+0x1f9>
		return;

	case T_BRKPT:
		monitor(tf);
f010419c:	83 ec 0c             	sub    $0xc,%esp
f010419f:	56                   	push   %esi
f01041a0:	e8 f6 c8 ff ff       	call   f0100a9b <monitor>
f01041a5:	83 c4 10             	add    $0x10,%esp
f01041a8:	e9 ad 00 00 00       	jmp    f010425a <trap+0x1f9>
		return;

	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f01041ad:	83 ec 08             	sub    $0x8,%esp
f01041b0:	ff 76 04             	pushl  0x4(%esi)
f01041b3:	ff 36                	pushl  (%esi)
f01041b5:	ff 76 10             	pushl  0x10(%esi)
f01041b8:	ff 76 18             	pushl  0x18(%esi)
f01041bb:	ff 76 14             	pushl  0x14(%esi)
f01041be:	ff 76 1c             	pushl  0x1c(%esi)
f01041c1:	e8 cf 02 00 00       	call   f0104495 <syscall>
f01041c6:	89 46 1c             	mov    %eax,0x1c(%esi)
f01041c9:	83 c4 20             	add    $0x20,%esp
f01041cc:	e9 89 00 00 00       	jmp    f010425a <trap+0x1f9>


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041d1:	83 f8 27             	cmp    $0x27,%eax
f01041d4:	75 1a                	jne    f01041f0 <trap+0x18f>
		cprintf("Spurious interrupt on irq 7\n");
f01041d6:	83 ec 0c             	sub    $0xc,%esp
f01041d9:	68 0a 79 10 f0       	push   $0xf010790a
f01041de:	e8 23 f6 ff ff       	call   f0103806 <cprintf>
		print_trapframe(tf);
f01041e3:	89 34 24             	mov    %esi,(%esp)
f01041e6:	e8 bc fb ff ff       	call   f0103da7 <print_trapframe>
f01041eb:	83 c4 10             	add    $0x10,%esp
f01041ee:	eb 6a                	jmp    f010425a <trap+0x1f9>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	// edited by Lethe 
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01041f0:	83 f8 20             	cmp    $0x20,%eax
f01041f3:	75 0a                	jne    f01041ff <trap+0x19e>
		lapic_eoi();
f01041f5:	e8 4b 1b 00 00       	call   f0105d45 <lapic_eoi>
		sched_yield();
f01041fa:	e8 14 02 00 00       	call   f0104413 <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	//edit by Lethe 2018/12/14
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f01041ff:	83 f8 21             	cmp    $0x21,%eax
f0104202:	75 07                	jne    f010420b <trap+0x1aa>
                kbd_intr();
f0104204:	e8 e3 c3 ff ff       	call   f01005ec <kbd_intr>
f0104209:	eb 4f                	jmp    f010425a <trap+0x1f9>
                return;
        }
        if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f010420b:	83 f8 24             	cmp    $0x24,%eax
f010420e:	75 07                	jne    f0104217 <trap+0x1b6>
                serial_intr();
f0104210:	e8 bb c3 ff ff       	call   f01005d0 <serial_intr>
f0104215:	eb 43                	jmp    f010425a <trap+0x1f9>
                return;
        }

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104217:	83 ec 0c             	sub    $0xc,%esp
f010421a:	56                   	push   %esi
f010421b:	e8 87 fb ff ff       	call   f0103da7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104220:	83 c4 10             	add    $0x10,%esp
f0104223:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104228:	75 17                	jne    f0104241 <trap+0x1e0>
		panic("unhandled trap in kernel");
f010422a:	83 ec 04             	sub    $0x4,%esp
f010422d:	68 27 79 10 f0       	push   $0xf0107927
f0104232:	68 44 01 00 00       	push   $0x144
f0104237:	68 de 78 10 f0       	push   $0xf01078de
f010423c:	e8 ff bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104241:	e8 b4 19 00 00       	call   f0105bfa <cpunum>
f0104246:	83 ec 0c             	sub    $0xc,%esp
f0104249:	6b c0 74             	imul   $0x74,%eax,%eax
f010424c:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104252:	e8 f6 f2 ff ff       	call   f010354d <env_destroy>
f0104257:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010425a:	e8 9b 19 00 00       	call   f0105bfa <cpunum>
f010425f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104262:	83 b8 28 90 20 f0 00 	cmpl   $0x0,-0xfdf6fd8(%eax)
f0104269:	74 2a                	je     f0104295 <trap+0x234>
f010426b:	e8 8a 19 00 00       	call   f0105bfa <cpunum>
f0104270:	6b c0 74             	imul   $0x74,%eax,%eax
f0104273:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0104279:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010427d:	75 16                	jne    f0104295 <trap+0x234>
		env_run(curenv);
f010427f:	e8 76 19 00 00       	call   f0105bfa <cpunum>
f0104284:	83 ec 0c             	sub    $0xc,%esp
f0104287:	6b c0 74             	imul   $0x74,%eax,%eax
f010428a:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104290:	e8 57 f3 ff ff       	call   f01035ec <env_run>
	else
		sched_yield();
f0104295:	e8 79 01 00 00       	call   f0104413 <sched_yield>

f010429a <divide_error>:
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*
  * edited by Lethe 
  */
  TRAPHANDLER_NOEC(divide_error,T_DIVIDE)		#0
f010429a:	6a 00                	push   $0x0
f010429c:	6a 00                	push   $0x0
f010429e:	e9 85 00 00 00       	jmp    f0104328 <_alltraps>
f01042a3:	90                   	nop

f01042a4 <debug_exception>:
  TRAPHANDLER_NOEC(debug_exception,T_DEBUG)		#1
f01042a4:	6a 00                	push   $0x0
f01042a6:	6a 01                	push   $0x1
f01042a8:	eb 7e                	jmp    f0104328 <_alltraps>

f01042aa <non_maskable_interrupt>:
  TRAPHANDLER_NOEC(non_maskable_interrupt,T_NMI)	#2 can't find it in 80386 manual
f01042aa:	6a 00                	push   $0x0
f01042ac:	6a 02                	push   $0x2
f01042ae:	eb 78                	jmp    f0104328 <_alltraps>

f01042b0 <_breakpoint>:
  TRAPHANDLER_NOEC(_breakpoint,T_BRKPT)			#3
f01042b0:	6a 00                	push   $0x0
f01042b2:	6a 03                	push   $0x3
f01042b4:	eb 72                	jmp    f0104328 <_alltraps>

f01042b6 <overflow>:
  TRAPHANDLER_NOEC(overflow,T_OFLOW)			#4
f01042b6:	6a 00                	push   $0x0
f01042b8:	6a 04                	push   $0x4
f01042ba:	eb 6c                	jmp    f0104328 <_alltraps>

f01042bc <bounds_check>:
  TRAPHANDLER_NOEC(bounds_check,T_BOUND)		#5
f01042bc:	6a 00                	push   $0x0
f01042be:	6a 05                	push   $0x5
f01042c0:	eb 66                	jmp    f0104328 <_alltraps>

f01042c2 <illegal_opcode>:
  TRAPHANDLER_NOEC(illegal_opcode,T_ILLOP)		#6
f01042c2:	6a 00                	push   $0x0
f01042c4:	6a 06                	push   $0x6
f01042c6:	eb 60                	jmp    f0104328 <_alltraps>

f01042c8 <device_not_available>:
  TRAPHANDLER_NOEC(device_not_available,T_DEVICE)	#7
f01042c8:	6a 00                	push   $0x0
f01042ca:	6a 07                	push   $0x7
f01042cc:	eb 5a                	jmp    f0104328 <_alltraps>

f01042ce <double_fault>:
  TRAPHANDLER(double_fault,T_DBLFLT)			#8
f01042ce:	6a 08                	push   $0x8
f01042d0:	eb 56                	jmp    f0104328 <_alltraps>

f01042d2 <invalid_task_switch_segment>:
  TRAPHANDLER(invalid_task_switch_segment,T_TSS)	#10
f01042d2:	6a 0a                	push   $0xa
f01042d4:	eb 52                	jmp    f0104328 <_alltraps>

f01042d6 <segment_not_present>:
  TRAPHANDLER(segment_not_present,T_SEGNP)		#11
f01042d6:	6a 0b                	push   $0xb
f01042d8:	eb 4e                	jmp    f0104328 <_alltraps>

f01042da <stack_exception>:
  TRAPHANDLER(stack_exception,T_STACK)			#12
f01042da:	6a 0c                	push   $0xc
f01042dc:	eb 4a                	jmp    f0104328 <_alltraps>

f01042de <general_protection_fault>:
  TRAPHANDLER(general_protection_fault,T_GPFLT)		#13
f01042de:	6a 0d                	push   $0xd
f01042e0:	eb 46                	jmp    f0104328 <_alltraps>

f01042e2 <page_fault>:
  TRAPHANDLER(page_fault,T_PGFLT)			#14
f01042e2:	6a 0e                	push   $0xe
f01042e4:	eb 42                	jmp    f0104328 <_alltraps>

f01042e6 <floating_point_error>:
  TRAPHANDLER_NOEC(floating_point_error,T_FPERR)	#16
f01042e6:	6a 00                	push   $0x0
f01042e8:	6a 10                	push   $0x10
f01042ea:	eb 3c                	jmp    f0104328 <_alltraps>

f01042ec <alignment_check>:
  TRAPHANDLER_NOEC(alignment_check,T_ALIGN)		#17
f01042ec:	6a 00                	push   $0x0
f01042ee:	6a 11                	push   $0x11
f01042f0:	eb 36                	jmp    f0104328 <_alltraps>

f01042f2 <machine_check>:
  TRAPHANDLER_NOEC(machine_check,T_MCHK)		#18
f01042f2:	6a 00                	push   $0x0
f01042f4:	6a 12                	push   $0x12
f01042f6:	eb 30                	jmp    f0104328 <_alltraps>

f01042f8 <SIMD_floating_point_error>:
  TRAPHANDLER_NOEC(SIMD_floating_point_error,T_SIMDERR)	#19
f01042f8:	6a 00                	push   $0x0
f01042fa:	6a 13                	push   $0x13
f01042fc:	eb 2a                	jmp    f0104328 <_alltraps>

f01042fe <system_call>:
  TRAPHANDLER_NOEC(system_call,T_SYSCALL)		#48
f01042fe:	6a 00                	push   $0x0
f0104300:	6a 30                	push   $0x30
f0104302:	eb 24                	jmp    f0104328 <_alltraps>

f0104304 <irq_handler32>:

/*
 * exercise 13, lab4
 * edited by Lethe 2018/12/7
 */
   TRAPHANDLER_NOEC(irq_handler32,IRQ_OFFSET+IRQ_TIMER)		#32
f0104304:	6a 00                	push   $0x0
f0104306:	6a 20                	push   $0x20
f0104308:	eb 1e                	jmp    f0104328 <_alltraps>

f010430a <irq_handler33>:
   TRAPHANDLER_NOEC(irq_handler33,IRQ_OFFSET+IRQ_KBD)		#33
f010430a:	6a 00                	push   $0x0
f010430c:	6a 21                	push   $0x21
f010430e:	eb 18                	jmp    f0104328 <_alltraps>

f0104310 <irq_handler36>:
   TRAPHANDLER_NOEC(irq_handler36,IRQ_OFFSET+IRQ_SERIAL)	#36
f0104310:	6a 00                	push   $0x0
f0104312:	6a 24                	push   $0x24
f0104314:	eb 12                	jmp    f0104328 <_alltraps>

f0104316 <irq_handler39>:
   TRAPHANDLER_NOEC(irq_handler39,IRQ_OFFSET+IRQ_SPURIOUS)	#39
f0104316:	6a 00                	push   $0x0
f0104318:	6a 27                	push   $0x27
f010431a:	eb 0c                	jmp    f0104328 <_alltraps>

f010431c <irq_handler46>:
   TRAPHANDLER_NOEC(irq_handler46,IRQ_OFFSET+IRQ_IDE)		#46
f010431c:	6a 00                	push   $0x0
f010431e:	6a 2e                	push   $0x2e
f0104320:	eb 06                	jmp    f0104328 <_alltraps>

f0104322 <irq_handler51>:
   TRAPHANDLER_NOEC(irq_handler51,IRQ_OFFSET+IRQ_ERROR)		#51
f0104322:	6a 00                	push   $0x0
f0104324:	6a 33                	push   $0x33
f0104326:	eb 00                	jmp    f0104328 <_alltraps>

f0104328 <_alltraps>:
		# push values in reverse to make the stack look like
		# a struct Trapframe
		# everything below tf_trapno is already on stack

		# we should push %ds %es in order after tf_trapno is pushed
		pushl %ds
f0104328:	1e                   	push   %ds
		pushl %es
f0104329:	06                   	push   %es

		# registers involved in struct PushRegs can be pushed
		# by pusha at a time
		pushal
f010432a:	60                   	pusha  

		# load GD_KD into %ds and %es
		movl $GD_KD,%eax
f010432b:	b8 10 00 00 00       	mov    $0x10,%eax
		movw %ax,%ds
f0104330:	8e d8                	mov    %eax,%ds
		movw %ax,%es
f0104332:	8e c0                	mov    %eax,%es

		pushl %esp
f0104334:	54                   	push   %esp
		
		# below copy from entry.s
		# Clear the frame pointer register (EBP)
		# so that once we get into debugging C code,
		# stack backtraces will be terminated properly.
		movl	$0x0,%ebp			# nuke frame pointer
f0104335:	bd 00 00 00 00       	mov    $0x0,%ebp

		call trap
f010433a:	e8 22 fd ff ff       	call   f0104061 <trap>

f010433f <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010433f:	55                   	push   %ebp
f0104340:	89 e5                	mov    %esp,%ebp
f0104342:	83 ec 08             	sub    $0x8,%esp
f0104345:	a1 48 82 20 f0       	mov    0xf0208248,%eax
f010434a:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010434d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104352:	8b 02                	mov    (%edx),%eax
f0104354:	83 e8 01             	sub    $0x1,%eax
f0104357:	83 f8 02             	cmp    $0x2,%eax
f010435a:	76 10                	jbe    f010436c <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010435c:	83 c1 01             	add    $0x1,%ecx
f010435f:	83 c2 7c             	add    $0x7c,%edx
f0104362:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104368:	75 e8                	jne    f0104352 <sched_halt+0x13>
f010436a:	eb 08                	jmp    f0104374 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010436c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104372:	75 1f                	jne    f0104393 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104374:	83 ec 0c             	sub    $0xc,%esp
f0104377:	68 30 7b 10 f0       	push   $0xf0107b30
f010437c:	e8 85 f4 ff ff       	call   f0103806 <cprintf>
f0104381:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104384:	83 ec 0c             	sub    $0xc,%esp
f0104387:	6a 00                	push   $0x0
f0104389:	e8 0d c7 ff ff       	call   f0100a9b <monitor>
f010438e:	83 c4 10             	add    $0x10,%esp
f0104391:	eb f1                	jmp    f0104384 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104393:	e8 62 18 00 00       	call   f0105bfa <cpunum>
f0104398:	6b c0 74             	imul   $0x74,%eax,%eax
f010439b:	c7 80 28 90 20 f0 00 	movl   $0x0,-0xfdf6fd8(%eax)
f01043a2:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01043a5:	a1 8c 8e 20 f0       	mov    0xf0208e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043af:	77 12                	ja     f01043c3 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043b1:	50                   	push   %eax
f01043b2:	68 e8 62 10 f0       	push   $0xf01062e8
f01043b7:	6a 4e                	push   $0x4e
f01043b9:	68 59 7b 10 f0       	push   $0xf0107b59
f01043be:	e8 7d bc ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01043c3:	05 00 00 00 10       	add    $0x10000000,%eax
f01043c8:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01043cb:	e8 2a 18 00 00       	call   f0105bfa <cpunum>
f01043d0:	6b d0 74             	imul   $0x74,%eax,%edx
f01043d3:	81 c2 20 90 20 f0    	add    $0xf0209020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01043d9:	b8 02 00 00 00       	mov    $0x2,%eax
f01043de:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01043e2:	83 ec 0c             	sub    $0xc,%esp
f01043e5:	68 c0 03 12 f0       	push   $0xf01203c0
f01043ea:	e8 16 1b 00 00       	call   f0105f05 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01043ef:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01043f1:	e8 04 18 00 00       	call   f0105bfa <cpunum>
f01043f6:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01043f9:	8b 80 30 90 20 f0    	mov    -0xfdf6fd0(%eax),%eax
f01043ff:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104404:	89 c4                	mov    %eax,%esp
f0104406:	6a 00                	push   $0x0
f0104408:	6a 00                	push   $0x0
f010440a:	fb                   	sti    
f010440b:	f4                   	hlt    
f010440c:	eb fd                	jmp    f010440b <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010440e:	83 c4 10             	add    $0x10,%esp
f0104411:	c9                   	leave  
f0104412:	c3                   	ret    

f0104413 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104413:	55                   	push   %ebp
f0104414:	89 e5                	mov    %esp,%ebp
f0104416:	57                   	push   %edi
f0104417:	56                   	push   %esi
f0104418:	53                   	push   %ebx
f0104419:	83 ec 0c             	sub    $0xc,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.

	idle = curenv;
f010441c:	e8 d9 17 00 00       	call   f0105bfa <cpunum>
f0104421:	6b c0 74             	imul   $0x74,%eax,%eax
f0104424:	8b b0 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%esi
	int idx = ((idle != NULL) ? (ENVX(idle->env_id)) : -1);
f010442a:	85 f6                	test   %esi,%esi
f010442c:	74 0b                	je     f0104439 <sched_yield+0x26>
f010442e:	8b 7e 48             	mov    0x48(%esi),%edi
f0104431:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
f0104437:	eb 05                	jmp    f010443e <sched_yield+0x2b>
f0104439:	bf ff ff ff ff       	mov    $0xffffffff,%edi
	
	int find_cnt;
	for (find_cnt = 0; find_cnt < NENV; find_cnt++) {
		idx = (idx + 1) % NENV;
		if (envs[idx].env_status == ENV_RUNNABLE) {
f010443e:	8b 1d 48 82 20 f0    	mov    0xf0208248,%ebx
f0104444:	b9 00 04 00 00       	mov    $0x400,%ecx
	idle = curenv;
	int idx = ((idle != NULL) ? (ENVX(idle->env_id)) : -1);
	
	int find_cnt;
	for (find_cnt = 0; find_cnt < NENV; find_cnt++) {
		idx = (idx + 1) % NENV;
f0104449:	8d 47 01             	lea    0x1(%edi),%eax
f010444c:	99                   	cltd   
f010444d:	c1 ea 16             	shr    $0x16,%edx
f0104450:	01 d0                	add    %edx,%eax
f0104452:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104457:	29 d0                	sub    %edx,%eax
f0104459:	89 c7                	mov    %eax,%edi
		if (envs[idx].env_status == ENV_RUNNABLE) {
f010445b:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010445e:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104461:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104465:	75 09                	jne    f0104470 <sched_yield+0x5d>
			env_run(&envs[idx]);
f0104467:	83 ec 0c             	sub    $0xc,%esp
f010446a:	52                   	push   %edx
f010446b:	e8 7c f1 ff ff       	call   f01035ec <env_run>

	idle = curenv;
	int idx = ((idle != NULL) ? (ENVX(idle->env_id)) : -1);
	
	int find_cnt;
	for (find_cnt = 0; find_cnt < NENV; find_cnt++) {
f0104470:	83 e9 01             	sub    $0x1,%ecx
f0104473:	75 d4                	jne    f0104449 <sched_yield+0x36>
			env_run(&envs[idx]);
			return;
		}
	}

	if (idle &&idle->env_status == ENV_RUNNING) {
f0104475:	85 f6                	test   %esi,%esi
f0104477:	74 0f                	je     f0104488 <sched_yield+0x75>
f0104479:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f010447d:	75 09                	jne    f0104488 <sched_yield+0x75>
		env_run(idle);
f010447f:	83 ec 0c             	sub    $0xc,%esp
f0104482:	56                   	push   %esi
f0104483:	e8 64 f1 ff ff       	call   f01035ec <env_run>
		return;
	}

	// sched_halt never returns
	sched_halt();
f0104488:	e8 b2 fe ff ff       	call   f010433f <sched_halt>
}
f010448d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104490:	5b                   	pop    %ebx
f0104491:	5e                   	pop    %esi
f0104492:	5f                   	pop    %edi
f0104493:	5d                   	pop    %ebp
f0104494:	c3                   	ret    

f0104495 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104495:	55                   	push   %ebp
f0104496:	89 e5                	mov    %esp,%ebp
f0104498:	57                   	push   %edi
f0104499:	56                   	push   %esi
f010449a:	83 ec 10             	sub    $0x10,%esp
f010449d:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.
	// edited by Lethe 

	//panic("syscall not implemented");

	switch (syscallno) {
f01044a0:	83 f8 0d             	cmp    $0xd,%eax
f01044a3:	0f 87 9c 05 00 00    	ja     f0104a45 <syscall+0x5b0>
f01044a9:	ff 24 85 6c 7b 10 f0 	jmp    *-0xfef8494(,%eax,4)

	// LAB 3: Your code here.
	// edited by Lethe 
	// use function user_mem_assert in kern/pmap.c
	// check whether it has permissions 'perm | PTE_U | PTE_P'
	user_mem_assert(curenv, s, len, 0);
f01044b0:	e8 45 17 00 00       	call   f0105bfa <cpunum>
f01044b5:	6a 00                	push   $0x0
f01044b7:	ff 75 10             	pushl  0x10(%ebp)
f01044ba:	ff 75 0c             	pushl  0xc(%ebp)
f01044bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c0:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f01044c6:	e8 34 ea ff ff       	call   f0102eff <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01044cb:	83 c4 0c             	add    $0xc,%esp
f01044ce:	ff 75 0c             	pushl  0xc(%ebp)
f01044d1:	ff 75 10             	pushl  0x10(%ebp)
f01044d4:	68 66 7b 10 f0       	push   $0xf0107b66
f01044d9:	e8 28 f3 ff ff       	call   f0103806 <cprintf>
f01044de:	83 c4 10             	add    $0x10,%esp
		// look up system call numbers' definitions
		// in inc/syscall.h
	case SYS_cputs:
		// static void sys_cputs(const char *s, size_t len)
		sys_cputs((char *)a1, a2);
		return 0;
f01044e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01044e6:	e9 66 05 00 00       	jmp    f0104a51 <syscall+0x5bc>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01044eb:	e8 0e c1 ff ff       	call   f01005fe <cons_getc>
		sys_cputs((char *)a1, a2);
		return 0;

	case SYS_cgetc:
		// static int sys_cgetc(void)
		return sys_cgetc();
f01044f0:	e9 5c 05 00 00       	jmp    f0104a51 <syscall+0x5bc>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01044f5:	e8 00 17 00 00       	call   f0105bfa <cpunum>
f01044fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01044fd:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0104503:	8b 40 48             	mov    0x48(%eax),%eax
		// static int sys_cgetc(void)
		return sys_cgetc();

	case SYS_getenvid:
		// static envid_t sys_getenvid(void)
		return (int)sys_getenvid();
f0104506:	e9 46 05 00 00       	jmp    f0104a51 <syscall+0x5bc>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010450b:	83 ec 04             	sub    $0x4,%esp
f010450e:	6a 01                	push   $0x1
f0104510:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104513:	50                   	push   %eax
f0104514:	ff 75 0c             	pushl  0xc(%ebp)
f0104517:	e8 b0 ea ff ff       	call   f0102fcc <envid2env>
f010451c:	83 c4 10             	add    $0x10,%esp
f010451f:	85 c0                	test   %eax,%eax
f0104521:	0f 88 2a 05 00 00    	js     f0104a51 <syscall+0x5bc>
		return r;
	env_destroy(e);
f0104527:	83 ec 0c             	sub    $0xc,%esp
f010452a:	ff 75 f4             	pushl  -0xc(%ebp)
f010452d:	e8 1b f0 ff ff       	call   f010354d <env_destroy>
f0104532:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104535:	b8 00 00 00 00       	mov    $0x0,%eax
f010453a:	e9 12 05 00 00       	jmp    f0104a51 <syscall+0x5bc>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010453f:	e8 cf fe ff ff       	call   f0104413 <sched_yield>
	// LAB 4: Your code here.
	
	// edited by Lethe 2018/12/7
	

	struct Env * childEnv = NULL;
f0104544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct Env * parentEnv = curenv;
f010454b:	e8 aa 16 00 00       	call   f0105bfa <cpunum>
f0104550:	6b c0 74             	imul   $0x74,%eax,%eax
f0104553:	8b b0 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%esi

	// env_alloc(struct Env **newenv_store, envid_t parent_id)
	// On success, the new environment is stored in *newenv_store.
	// Returns 0 on success, < 0 on failure.
	int ret;
	ret = env_alloc(&childEnv, parentEnv->env_id);
f0104559:	83 ec 08             	sub    $0x8,%esp
f010455c:	ff 76 48             	pushl  0x48(%esi)
f010455f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104562:	50                   	push   %eax
f0104563:	e8 92 eb ff ff       	call   f01030fa <env_alloc>

	if (ret < 0) {
f0104568:	83 c4 10             	add    $0x10,%esp
f010456b:	85 c0                	test   %eax,%eax
f010456d:	0f 88 de 04 00 00    	js     f0104a51 <syscall+0x5bc>
		// return <0 on error
		return ret;
	}

	// set some value of childEnv
	childEnv->env_tf = parentEnv->env_tf;
f0104573:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104578:	8b 7d f4             	mov    -0xc(%ebp),%edi
f010457b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	childEnv->env_status = ENV_NOT_RUNNABLE;
f010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104580:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	childEnv->env_tf.tf_regs.reg_eax = 0;
f0104587:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	// return envid of new environment
	return childEnv->env_id;
f010458e:	8b 40 48             	mov    0x48(%eax),%eax
f0104591:	e9 bb 04 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// envid's status.

	// LAB 4: Your code here.
	
	// edited by Lethe 2018/12/7
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0104596:	8b 45 10             	mov    0x10(%ebp),%eax
f0104599:	83 e8 02             	sub    $0x2,%eax
f010459c:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01045a1:	75 2b                	jne    f01045ce <syscall+0x139>
	// Converts an envid to an env pointer.
	// int envid2env(envid_t envid, struct Env **env_store, bool checkperm)
	// If checkperm is set, the specified environment must be either the
	// current environment or an immediate child of the current environment.
	struct Env * e;
	if (envid2env(envid, &e, 1) < 0) {
f01045a3:	83 ec 04             	sub    $0x4,%esp
f01045a6:	6a 01                	push   $0x1
f01045a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045ab:	50                   	push   %eax
f01045ac:	ff 75 0c             	pushl  0xc(%ebp)
f01045af:	e8 18 ea ff ff       	call   f0102fcc <envid2env>
f01045b4:	83 c4 10             	add    $0x10,%esp
f01045b7:	85 c0                	test   %eax,%eax
f01045b9:	78 1d                	js     f01045d8 <syscall+0x143>
		//		or the caller doesn't have permission to change envid.
		return -E_BAD_ENV;
	}

	// set status
	e->env_status = status;
f01045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045be:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01045c1:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f01045c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01045c9:	e9 83 04 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// LAB 4: Your code here.
	
	// edited by Lethe 2018/12/7
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		// return -E_INVAL if status is not a valid status for an environment.
		return -E_INVAL;
f01045ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01045d3:	e9 79 04 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// current environment or an immediate child of the current environment.
	struct Env * e;
	if (envid2env(envid, &e, 1) < 0) {
		//	-E_BAD_ENV if environment envid doesn't currently exist,
		//		or the caller doesn't have permission to change envid.
		return -E_BAD_ENV;
f01045d8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		// static envid_t sys_exofork(void)
		return (int)sys_exofork();

	case SYS_env_set_status:
		// static int sys_env_set_status(envid_t envid, int status)
		return sys_env_set_status((envid_t)a1, (int)a2);
f01045dd:	e9 6f 04 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	// check parameters at first
	// check 1
	if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
f01045e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01045e5:	83 e0 05             	and    $0x5,%eax
f01045e8:	83 f8 05             	cmp    $0x5,%eax
f01045eb:	0f 85 99 00 00 00    	jne    f010468a <syscall+0x1f5>
	if ((perm & (~PTE_SYSCALL)) != 0) {
		// no other bits may be set
		return -E_INVAL;
	}
	// check 3
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
f01045f1:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01045f8:	0f 85 96 00 00 00    	jne    f0104694 <syscall+0x1ff>
f01045fe:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104605:	0f 87 89 00 00 00    	ja     f0104694 <syscall+0x1ff>
		// return -E_INVAL if va >= UTOP, or va is not page-aligned
		return -E_INVAL;
f010460b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	if ((perm & (~PTE_SYSCALL)) != 0) {
		// no other bits may be set
		return -E_INVAL;
	}
	// check 3
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
f0104610:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104617:	0f 85 34 04 00 00    	jne    f0104a51 <syscall+0x5bc>
		// return -E_INVAL if va >= UTOP, or va is not page-aligned
		return -E_INVAL;
	}

	// check envid and caller's permission
	struct Env * e = NULL;
f010461d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int ret = 0;
	if ((ret = envid2env(envid, &e, 1)) < 0) {
f0104624:	83 ec 04             	sub    $0x4,%esp
f0104627:	6a 01                	push   $0x1
f0104629:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010462c:	50                   	push   %eax
f010462d:	ff 75 0c             	pushl  0xc(%ebp)
f0104630:	e8 97 e9 ff ff       	call   f0102fcc <envid2env>
f0104635:	83 c4 10             	add    $0x10,%esp
f0104638:	85 c0                	test   %eax,%eax
f010463a:	0f 88 11 04 00 00    	js     f0104a51 <syscall+0x5bc>
	}

	// alloc a page
	// page_alloc(1) will initialize the returnd page with '\0'
	// Returns NULL if out of free memory.
	struct PageInfo * page = page_alloc(1);
f0104640:	83 ec 0c             	sub    $0xc,%esp
f0104643:	6a 01                	push   $0x1
f0104645:	e8 8d ca ff ff       	call   f01010d7 <page_alloc>
f010464a:	89 c6                	mov    %eax,%esi
	if (!page) {
f010464c:	83 c4 10             	add    $0x10,%esp
f010464f:	85 c0                	test   %eax,%eax
f0104651:	74 4b                	je     f010469e <syscall+0x209>
	}

	// map it at 'va' with permission 'perm' in the address space of 'envid'.
	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	// return 0 on success; -E_NO_MEM, if page table couldn't be allocated
	ret = page_insert(e->env_pgdir, page, va, perm);
f0104653:	ff 75 14             	pushl  0x14(%ebp)
f0104656:	ff 75 10             	pushl  0x10(%ebp)
f0104659:	50                   	push   %eax
f010465a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010465d:	ff 70 60             	pushl  0x60(%eax)
f0104660:	e8 1a cd ff ff       	call   f010137f <page_insert>
f0104665:	89 c7                	mov    %eax,%edi
	if (ret < 0) {
f0104667:	83 c4 10             	add    $0x10,%esp
		page_free(page);
		return ret;
	}
	
	// return 0 on success
	return 0;
f010466a:	b8 00 00 00 00       	mov    $0x0,%eax

	// map it at 'va' with permission 'perm' in the address space of 'envid'.
	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	// return 0 on success; -E_NO_MEM, if page table couldn't be allocated
	ret = page_insert(e->env_pgdir, page, va, perm);
	if (ret < 0) {
f010466f:	85 ff                	test   %edi,%edi
f0104671:	0f 89 da 03 00 00    	jns    f0104a51 <syscall+0x5bc>
		//   If page_insert() fails, remember to free the page you
		//   allocated!
		page_free(page);
f0104677:	83 ec 0c             	sub    $0xc,%esp
f010467a:	56                   	push   %esi
f010467b:	e8 c7 ca ff ff       	call   f0101147 <page_free>
f0104680:	83 c4 10             	add    $0x10,%esp
		return ret;
f0104683:	89 f8                	mov    %edi,%eax
f0104685:	e9 c7 03 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// edited by Lethe 2018/12/7
	// check parameters at first
	// check 1
	if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
		// PTE_U | PTE_P must be set
		return -E_INVAL;
f010468a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010468f:	e9 bd 03 00 00       	jmp    f0104a51 <syscall+0x5bc>
		return -E_INVAL;
	}
	// check 3
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
		// return -E_INVAL if va >= UTOP, or va is not page-aligned
		return -E_INVAL;
f0104694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104699:	e9 b3 03 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// Returns NULL if out of free memory.
	struct PageInfo * page = page_alloc(1);
	if (!page) {
		//	-E_NO_MEM if there's no memory to allocate the new page,
		//		or to allocate any necessary page tables.
		return -E_NO_MEM;
f010469e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01046a3:	e9 a9 03 00 00       	jmp    f0104a51 <syscall+0x5bc>

	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	// again, check parameters at first
	struct Env *srcE = NULL, *dstE = NULL;
f01046a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01046af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int ret = 0;

	// check 1
	// return -E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	if ((ret=envid2env(srcenvid,&srcE,1))<0) {
f01046b6:	83 ec 04             	sub    $0x4,%esp
f01046b9:	6a 01                	push   $0x1
f01046bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01046be:	50                   	push   %eax
f01046bf:	ff 75 0c             	pushl  0xc(%ebp)
f01046c2:	e8 05 e9 ff ff       	call   f0102fcc <envid2env>
f01046c7:	83 c4 10             	add    $0x10,%esp
f01046ca:	85 c0                	test   %eax,%eax
f01046cc:	0f 88 be 00 00 00    	js     f0104790 <syscall+0x2fb>
		return -E_BAD_ENV;
	}
	if ((ret = envid2env(dstenvid, &dstE, 1))<0) {
f01046d2:	83 ec 04             	sub    $0x4,%esp
f01046d5:	6a 01                	push   $0x1
f01046d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01046da:	50                   	push   %eax
f01046db:	ff 75 14             	pushl  0x14(%ebp)
f01046de:	e8 e9 e8 ff ff       	call   f0102fcc <envid2env>
f01046e3:	83 c4 10             	add    $0x10,%esp
f01046e6:	85 c0                	test   %eax,%eax
f01046e8:	0f 88 ac 00 00 00    	js     f010479a <syscall+0x305>
	}
	
	// check 2
	// return -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (((uintptr_t)srcva >= UTOP) || (ROUNDDOWN(srcva, PGSIZE) != srcva)) {
f01046ee:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046f5:	0f 87 a9 00 00 00    	ja     f01047a4 <syscall+0x30f>
		return -E_INVAL;
	}
	if (((uintptr_t)dstva >= UTOP) || (ROUNDDOWN(dstva, PGSIZE) != dstva)) {
f01046fb:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104702:	0f 85 a6 00 00 00    	jne    f01047ae <syscall+0x319>
f0104708:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010470f:	0f 87 99 00 00 00    	ja     f01047ae <syscall+0x319>
		return -E_INVAL;
f0104715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	// return -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (((uintptr_t)srcva >= UTOP) || (ROUNDDOWN(srcva, PGSIZE) != srcva)) {
		return -E_INVAL;
	}
	if (((uintptr_t)dstva >= UTOP) || (ROUNDDOWN(dstva, PGSIZE) != dstva)) {
f010471a:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104721:	0f 85 2a 03 00 00    	jne    f0104a51 <syscall+0x5bc>
	// check 3
	// return -E_INVAL is srcva is not mapped in srcenvid's address space.

	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	// Return NULL if there is no page mapped at va.
	pte_t * srcPte = NULL;
f0104727:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo * page = NULL;
	page = page_lookup(srcE->env_pgdir, srcva, &srcPte);
f010472e:	83 ec 04             	sub    $0x4,%esp
f0104731:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104734:	50                   	push   %eax
f0104735:	ff 75 10             	pushl  0x10(%ebp)
f0104738:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010473b:	ff 70 60             	pushl  0x60(%eax)
f010473e:	e8 4b cb ff ff       	call   f010128e <page_lookup>
	if (!page) {
f0104743:	83 c4 10             	add    $0x10,%esp
f0104746:	85 c0                	test   %eax,%eax
f0104748:	74 6e                	je     f01047b8 <syscall+0x323>
		return -E_INVAL;
	}

	// check 4
	// return -E_INVAL if perm is inappropriate (see sys_page_alloc).
	if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
f010474a:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010474d:	83 e2 05             	and    $0x5,%edx
f0104750:	83 fa 05             	cmp    $0x5,%edx
f0104753:	75 6d                	jne    f01047c2 <syscall+0x32d>
		// PTE_U | PTE_P must be set
		return -E_INVAL;
	}
	if ((perm & (~PTE_SYSCALL)) != 0) {
f0104755:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f010475c:	75 6e                	jne    f01047cc <syscall+0x337>
		return -E_INVAL;
	}

	// check 5
	// return -E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's address space.
	if ((perm & PTE_W) && (((*srcPte) & PTE_W) == 0)) {
f010475e:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104762:	74 08                	je     f010476c <syscall+0x2d7>
f0104764:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104767:	f6 02 02             	testb  $0x2,(%edx)
f010476a:	74 6a                	je     f01047d6 <syscall+0x341>

	// check 6
	// return -E_NO_MEM if there's no memory to allocate any necessary page tables.
	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	// return 0 on success; -E_NO_MEM, if page table couldn't be allocated
	ret = page_insert(dstE->env_pgdir, page, dstva, perm);
f010476c:	ff 75 1c             	pushl  0x1c(%ebp)
f010476f:	ff 75 18             	pushl  0x18(%ebp)
f0104772:	50                   	push   %eax
f0104773:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104776:	ff 70 60             	pushl  0x60(%eax)
f0104779:	e8 01 cc ff ff       	call   f010137f <page_insert>
f010477e:	83 c4 10             	add    $0x10,%esp
f0104781:	85 c0                	test   %eax,%eax
f0104783:	ba 00 00 00 00       	mov    $0x0,%edx
f0104788:	0f 4f c2             	cmovg  %edx,%eax
f010478b:	e9 c1 02 00 00       	jmp    f0104a51 <syscall+0x5bc>

	// check 1
	// return -E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	if ((ret=envid2env(srcenvid,&srcE,1))<0) {
		return -E_BAD_ENV;
f0104790:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104795:	e9 b7 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	}
	if ((ret = envid2env(dstenvid, &dstE, 1))<0) {
		return -E_BAD_ENV;
f010479a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010479f:	e9 ad 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	
	// check 2
	// return -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (((uintptr_t)srcva >= UTOP) || (ROUNDDOWN(srcva, PGSIZE) != srcva)) {
		return -E_INVAL;
f01047a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047a9:	e9 a3 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	}
	if (((uintptr_t)dstva >= UTOP) || (ROUNDDOWN(dstva, PGSIZE) != dstva)) {
		return -E_INVAL;
f01047ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047b3:	e9 99 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// Return NULL if there is no page mapped at va.
	pte_t * srcPte = NULL;
	struct PageInfo * page = NULL;
	page = page_lookup(srcE->env_pgdir, srcva, &srcPte);
	if (!page) {
		return -E_INVAL;
f01047b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047bd:	e9 8f 02 00 00       	jmp    f0104a51 <syscall+0x5bc>

	// check 4
	// return -E_INVAL if perm is inappropriate (see sys_page_alloc).
	if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
		// PTE_U | PTE_P must be set
		return -E_INVAL;
f01047c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047c7:	e9 85 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	}
	if ((perm & (~PTE_SYSCALL)) != 0) {
		// no other bits may be set
		return -E_INVAL;
f01047cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047d1:	e9 7b 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	}

	// check 5
	// return -E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's address space.
	if ((perm & PTE_W) && (((*srcPte) & PTE_W) == 0)) {
		return -E_INVAL;
f01047d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);

	case SYS_page_map:
		// static int sys_page_map(envid_t srcenvid, void *srcva,
		// envid_t dstenvid, void *dstva, int perm)
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);
f01047db:	e9 71 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	
	// check 1
	// return -E_BAD_ENV if environment envid doesn't currently exist,
	//		or the caller doesn't have permission to change envid.
	struct Env * e;
	if (envid2env(envid, &e, 1) < 0) {
f01047e0:	83 ec 04             	sub    $0x4,%esp
f01047e3:	6a 01                	push   $0x1
f01047e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01047e8:	50                   	push   %eax
f01047e9:	ff 75 0c             	pushl  0xc(%ebp)
f01047ec:	e8 db e7 ff ff       	call   f0102fcc <envid2env>
f01047f1:	83 c4 10             	add    $0x10,%esp
f01047f4:	85 c0                	test   %eax,%eax
f01047f6:	78 39                	js     f0104831 <syscall+0x39c>
		return -E_BAD_ENV;
	}

	// check 2
	// return -E_INVAL if va >= UTOP, or va is not page-aligned.
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
f01047f8:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047ff:	77 3a                	ja     f010483b <syscall+0x3a6>
		return -E_INVAL;
f0104801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_BAD_ENV;
	}

	// check 2
	// return -E_INVAL if va >= UTOP, or va is not page-aligned.
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
f0104806:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010480d:	0f 85 3e 02 00 00    	jne    f0104a51 <syscall+0x5bc>
		return -E_INVAL;
	}

	// unmap the page by call page_remove
	page_remove(e->env_pgdir, va);
f0104813:	83 ec 08             	sub    $0x8,%esp
f0104816:	ff 75 10             	pushl  0x10(%ebp)
f0104819:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010481c:	ff 70 60             	pushl  0x60(%eax)
f010481f:	e8 06 cb ff ff       	call   f010132a <page_remove>
f0104824:	83 c4 10             	add    $0x10,%esp
	
	// return 0 on success
	return 0;
f0104827:	b8 00 00 00 00       	mov    $0x0,%eax
f010482c:	e9 20 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	// check 1
	// return -E_BAD_ENV if environment envid doesn't currently exist,
	//		or the caller doesn't have permission to change envid.
	struct Env * e;
	if (envid2env(envid, &e, 1) < 0) {
		return -E_BAD_ENV;
f0104831:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104836:	e9 16 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
	}

	// check 2
	// return -E_INVAL if va >= UTOP, or va is not page-aligned.
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
		return -E_INVAL;
f010483b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104840:	e9 0c 02 00 00       	jmp    f0104a51 <syscall+0x5bc>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	struct Env * e = NULL;
f0104845:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int ret = 0;
	if ((ret = envid2env(envid, &e, 1)) < 0) {
f010484c:	83 ec 04             	sub    $0x4,%esp
f010484f:	6a 01                	push   $0x1
f0104851:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104854:	50                   	push   %eax
f0104855:	ff 75 0c             	pushl  0xc(%ebp)
f0104858:	e8 6f e7 ff ff       	call   f0102fcc <envid2env>
f010485d:	83 c4 10             	add    $0x10,%esp
f0104860:	85 c0                	test   %eax,%eax
f0104862:	0f 88 e9 01 00 00    	js     f0104a51 <syscall+0x5bc>
		return ret;
	}

	e->env_pgfault_upcall = func;
f0104868:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010486b:	8b 7d 10             	mov    0x10(%ebp),%edi
f010486e:	89 78 64             	mov    %edi,0x64(%eax)
	// return 0 on success
	return 0;
f0104871:	b8 00 00 00 00       	mov    $0x0,%eax
f0104876:	e9 d6 01 00 00       	jmp    f0104a51 <syscall+0x5bc>
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	struct Env * e = NULL;
f010487b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	int r = 0;

	// check 1, return -E_BAD_ENV if environment envid doesn't currently exist
	// no need to check permissions, so we set checkperm 0 here
	if ((r = envid2env(envid, &e, 0)) < 0) {
f0104882:	83 ec 04             	sub    $0x4,%esp
f0104885:	6a 00                	push   $0x0
f0104887:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010488a:	50                   	push   %eax
f010488b:	ff 75 0c             	pushl  0xc(%ebp)
f010488e:	e8 39 e7 ff ff       	call   f0102fcc <envid2env>
f0104893:	83 c4 10             	add    $0x10,%esp
f0104896:	85 c0                	test   %eax,%eax
f0104898:	0f 88 b3 01 00 00    	js     f0104a51 <syscall+0x5bc>
		return r;
	}

	// check 2, return -E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv
	if (((e->env_ipc_recving) == false)) {
f010489e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01048a1:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01048a5:	0f 84 fe 00 00 00    	je     f01049a9 <syscall+0x514>
		return -E_IPC_NOT_RECV;
	}

	if (srcva < (void *)UTOP) {
f01048ab:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01048b2:	0f 87 b5 00 00 00    	ja     f010496d <syscall+0x4d8>
		// check 3, return -E_INVAL if srcva < UTOP but srcva is not page-aligned.
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) {
			return -E_INVAL;
f01048b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_IPC_NOT_RECV;
	}

	if (srcva < (void *)UTOP) {
		// check 3, return -E_INVAL if srcva < UTOP but srcva is not page-aligned.
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) {
f01048bd:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01048c4:	0f 85 87 01 00 00    	jne    f0104a51 <syscall+0x5bc>
			return -E_INVAL;
		}

		// check 4, return -E_INVAL if srcva < UTOP and perm is inappropriate
		// check 4_1
		if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
f01048ca:	8b 55 18             	mov    0x18(%ebp),%edx
f01048cd:	83 e2 05             	and    $0x5,%edx
f01048d0:	83 fa 05             	cmp    $0x5,%edx
f01048d3:	0f 85 78 01 00 00    	jne    f0104a51 <syscall+0x5bc>
			// PTE_U | PTE_P must be set
			return -E_INVAL;
		}
		// check 4_2
		if ((perm & (~PTE_SYSCALL)) != 0) {
f01048d9:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f01048e0:	0f 85 6b 01 00 00    	jne    f0104a51 <syscall+0x5bc>
			return -E_INVAL;
		}

		// check 5, return -E_INVAL if srcva < UTOP but srcva 
		// is not mapped in the caller's address space.
		pte_t * pte = NULL;
f01048e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f01048ed:	e8 08 13 00 00       	call   f0105bfa <cpunum>
f01048f2:	83 ec 04             	sub    $0x4,%esp
f01048f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01048f8:	52                   	push   %edx
f01048f9:	ff 75 14             	pushl  0x14(%ebp)
f01048fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ff:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0104905:	ff 70 60             	pushl  0x60(%eax)
f0104908:	e8 81 c9 ff ff       	call   f010128e <page_lookup>
f010490d:	89 c1                	mov    %eax,%ecx
		if (!pg) {
f010490f:	83 c4 10             	add    $0x10,%esp
f0104912:	85 c0                	test   %eax,%eax
f0104914:	74 43                	je     f0104959 <syscall+0x4c4>
			return -E_INVAL;
		}

		// check 6, return -E_INVAL if (perm & PTE_W), but srcva is read-only in the
		// current environment's address space.
		if ((perm & PTE_W) && (!((*pte) & PTE_W))) {
f0104916:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010491a:	74 11                	je     f010492d <syscall+0x498>
			// perm has the permission of write while srcva doesn't have permission of write
			// check the bit PTE_W of *pte instead of check PTE_R
			return -E_INVAL;
f010491c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return -E_INVAL;
		}

		// check 6, return -E_INVAL if (perm & PTE_W), but srcva is read-only in the
		// current environment's address space.
		if ((perm & PTE_W) && (!((*pte) & PTE_W))) {
f0104921:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104924:	f6 02 02             	testb  $0x2,(%edx)
f0104927:	0f 84 24 01 00 00    	je     f0104a51 <syscall+0x5bc>
			return -E_INVAL;
		}

		// check 7, return -E_NO_MEM if there's not enough memory 
		// to map srcva in envid's address space.
		if ((e->env_ipc_dstva) < (void *)UTOP) {
f010492d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104930:	8b 42 6c             	mov    0x6c(%edx),%eax
f0104933:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104938:	77 33                	ja     f010496d <syscall+0x4d8>
			// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
			if ((r = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm)) < 0) {
f010493a:	ff 75 18             	pushl  0x18(%ebp)
f010493d:	50                   	push   %eax
f010493e:	51                   	push   %ecx
f010493f:	ff 72 60             	pushl  0x60(%edx)
f0104942:	e8 38 ca ff ff       	call   f010137f <page_insert>
f0104947:	83 c4 10             	add    $0x10,%esp
f010494a:	85 c0                	test   %eax,%eax
f010494c:	78 15                	js     f0104963 <syscall+0x4ce>
				return -E_NO_MEM;
			}

			// env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
			e->env_ipc_perm = perm;
f010494e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104951:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104954:	89 48 78             	mov    %ecx,0x78(%eax)
f0104957:	eb 14                	jmp    f010496d <syscall+0x4d8>
		// check 5, return -E_INVAL if srcva < UTOP but srcva 
		// is not mapped in the caller's address space.
		pte_t * pte = NULL;
		struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) {
			return -E_INVAL;
f0104959:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010495e:	e9 ee 00 00 00       	jmp    f0104a51 <syscall+0x5bc>
		// check 7, return -E_NO_MEM if there's not enough memory 
		// to map srcva in envid's address space.
		if ((e->env_ipc_dstva) < (void *)UTOP) {
			// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
			if ((r = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm)) < 0) {
				return -E_NO_MEM;
f0104963:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104968:	e9 e4 00 00 00       	jmp    f0104a51 <syscall+0x5bc>
			e->env_ipc_perm = perm;
		}
	}

	// At here, the send succeeds, and the target's ipc fields should be updated
	e->env_ipc_recving = 0;				// env_ipc_recving is set to 0 to block future sends;
f010496d:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0104970:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id;	// env_ipc_from is set to the sending envid;
f0104974:	e8 81 12 00 00       	call   f0105bfa <cpunum>
f0104979:	6b c0 74             	imul   $0x74,%eax,%eax
f010497c:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f0104982:	8b 40 48             	mov    0x48(%eax),%eax
f0104985:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;			// env_ipc_value is set to the 'value' parameter;
f0104988:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010498b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010498e:	89 48 70             	mov    %ecx,0x70(%eax)

	e->env_status = ENV_RUNNABLE;
f0104991:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;	
f0104998:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f010499f:	b8 00 00 00 00       	mov    $0x0,%eax
f01049a4:	e9 a8 00 00 00       	jmp    f0104a51 <syscall+0x5bc>
		return r;
	}

	// check 2, return -E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv
	if (((e->env_ipc_recving) == false)) {
		return -E_IPC_NOT_RECV;
f01049a9:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	
	// exercise 15, lab 4
	// edited by Lethe 
	case SYS_ipc_try_send:
		// static int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
f01049ae:	e9 9e 00 00 00       	jmp    f0104a51 <syscall+0x5bc>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if ((dstva < (void *)UTOP) && (dstva != ROUNDDOWN(dstva, PGSIZE))) {
f01049b3:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01049ba:	77 0d                	ja     f01049c9 <syscall+0x534>
f01049bc:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01049c3:	0f 85 83 00 00 00    	jne    f0104a4c <syscall+0x5b7>
		return -E_INVAL;
	}

	curenv->env_ipc_recving = 1;
f01049c9:	e8 2c 12 00 00       	call   f0105bfa <cpunum>
f01049ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d1:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f01049d7:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f01049db:	e8 1a 12 00 00       	call   f0105bfa <cpunum>
f01049e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e3:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f01049e9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01049ec:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01049ef:	e8 06 12 00 00       	call   f0105bfa <cpunum>
f01049f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f7:	8b 80 28 90 20 f0    	mov    -0xfdf6fd8(%eax),%eax
f01049fd:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104a04:	e8 0a fa ff ff       	call   f0104413 <sched_yield>
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
	case SYS_ipc_recv:
		// static int sys_ipc_recv(void *dstva)
		return sys_ipc_recv((void *)a1);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe((envid_t)a1,(struct Trapframe *)a2);
f0104a09:	8b 75 10             	mov    0x10(%ebp),%esi
	// Remember to check whether the user has supplied us with a good
	// address!
	//edit by Lethe 2018/12/14
	int r;
	struct Env *e;
	if ((r = envid2env(envid, &e, 1)) < 0) {
f0104a0c:	83 ec 04             	sub    $0x4,%esp
f0104a0f:	6a 01                	push   $0x1
f0104a11:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104a14:	50                   	push   %eax
f0104a15:	ff 75 0c             	pushl  0xc(%ebp)
f0104a18:	e8 af e5 ff ff       	call   f0102fcc <envid2env>
f0104a1d:	83 c4 10             	add    $0x10,%esp
f0104a20:	85 c0                	test   %eax,%eax
f0104a22:	78 2d                	js     f0104a51 <syscall+0x5bc>
		return r;
	}
	tf->tf_eflags = FL_IF;
f0104a24:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a27:	c7 40 38 00 02 00 00 	movl   $0x200,0x38(%eax)
	tf->tf_eflags &= ~FL_IOPL_MASK;         //普通进程不能有IO权限
	tf->tf_cs = GD_UT | 3;
f0104a2e:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	e->env_tf = *tf;
f0104a34:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a39:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0104a3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0;
f0104a3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a43:	eb 0c                	jmp    f0104a51 <syscall+0x5bc>
		return sys_ipc_recv((void *)a1);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe((envid_t)a1,(struct Trapframe *)a2);

	default:
		return -E_INVAL;
f0104a45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a4a:	eb 05                	jmp    f0104a51 <syscall+0x5bc>
	case SYS_ipc_try_send:
		// static int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
	case SYS_ipc_recv:
		// static int sys_ipc_recv(void *dstva)
		return sys_ipc_recv((void *)a1);
f0104a4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return sys_env_set_trapframe((envid_t)a1,(struct Trapframe *)a2);

	default:
		return -E_INVAL;
	}
}
f0104a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a54:	5e                   	pop    %esi
f0104a55:	5f                   	pop    %edi
f0104a56:	5d                   	pop    %ebp
f0104a57:	c3                   	ret    

f0104a58 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a58:	55                   	push   %ebp
f0104a59:	89 e5                	mov    %esp,%ebp
f0104a5b:	57                   	push   %edi
f0104a5c:	56                   	push   %esi
f0104a5d:	53                   	push   %ebx
f0104a5e:	83 ec 14             	sub    $0x14,%esp
f0104a61:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a67:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a6d:	8b 1a                	mov    (%edx),%ebx
f0104a6f:	8b 01                	mov    (%ecx),%eax
f0104a71:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a74:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a7b:	eb 7f                	jmp    f0104afc <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a80:	01 d8                	add    %ebx,%eax
f0104a82:	89 c6                	mov    %eax,%esi
f0104a84:	c1 ee 1f             	shr    $0x1f,%esi
f0104a87:	01 c6                	add    %eax,%esi
f0104a89:	d1 fe                	sar    %esi
f0104a8b:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104a8e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a91:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104a94:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a96:	eb 03                	jmp    f0104a9b <stab_binsearch+0x43>
			m--;
f0104a98:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a9b:	39 c3                	cmp    %eax,%ebx
f0104a9d:	7f 0d                	jg     f0104aac <stab_binsearch+0x54>
f0104a9f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104aa3:	83 ea 0c             	sub    $0xc,%edx
f0104aa6:	39 f9                	cmp    %edi,%ecx
f0104aa8:	75 ee                	jne    f0104a98 <stab_binsearch+0x40>
f0104aaa:	eb 05                	jmp    f0104ab1 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104aac:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104aaf:	eb 4b                	jmp    f0104afc <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ab1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ab4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ab7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104abb:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104abe:	76 11                	jbe    f0104ad1 <stab_binsearch+0x79>
			*region_left = m;
f0104ac0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ac3:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104ac5:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ac8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104acf:	eb 2b                	jmp    f0104afc <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104ad1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ad4:	73 14                	jae    f0104aea <stab_binsearch+0x92>
			*region_right = m - 1;
f0104ad6:	83 e8 01             	sub    $0x1,%eax
f0104ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104adc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104adf:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ae1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ae8:	eb 12                	jmp    f0104afc <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104aea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104aed:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104aef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104af3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104af5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104afc:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104aff:	0f 8e 78 ff ff ff    	jle    f0104a7d <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b05:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b09:	75 0f                	jne    f0104b1a <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104b0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b0e:	8b 00                	mov    (%eax),%eax
f0104b10:	83 e8 01             	sub    $0x1,%eax
f0104b13:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b16:	89 06                	mov    %eax,(%esi)
f0104b18:	eb 2c                	jmp    f0104b46 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b1d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b1f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b22:	8b 0e                	mov    (%esi),%ecx
f0104b24:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b27:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b2a:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b2d:	eb 03                	jmp    f0104b32 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b2f:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b32:	39 c8                	cmp    %ecx,%eax
f0104b34:	7e 0b                	jle    f0104b41 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104b36:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b3a:	83 ea 0c             	sub    $0xc,%edx
f0104b3d:	39 df                	cmp    %ebx,%edi
f0104b3f:	75 ee                	jne    f0104b2f <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b41:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b44:	89 06                	mov    %eax,(%esi)
	}
}
f0104b46:	83 c4 14             	add    $0x14,%esp
f0104b49:	5b                   	pop    %ebx
f0104b4a:	5e                   	pop    %esi
f0104b4b:	5f                   	pop    %edi
f0104b4c:	5d                   	pop    %ebp
f0104b4d:	c3                   	ret    

f0104b4e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b4e:	55                   	push   %ebp
f0104b4f:	89 e5                	mov    %esp,%ebp
f0104b51:	57                   	push   %edi
f0104b52:	56                   	push   %esi
f0104b53:	53                   	push   %ebx
f0104b54:	83 ec 3c             	sub    $0x3c,%esp
f0104b57:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104b5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104b5d:	c7 03 a4 7b 10 f0    	movl   $0xf0107ba4,(%ebx)
	info->eip_line = 0;
f0104b63:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104b6a:	c7 43 08 a4 7b 10 f0 	movl   $0xf0107ba4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104b71:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104b78:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104b7b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104b82:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104b88:	0f 87 a3 00 00 00    	ja     f0104c31 <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// edited by Lethe 
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U)) {
f0104b8e:	e8 67 10 00 00       	call   f0105bfa <cpunum>
f0104b93:	6a 04                	push   $0x4
f0104b95:	6a 10                	push   $0x10
f0104b97:	68 00 00 20 00       	push   $0x200000
f0104b9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9f:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104ba5:	e8 c3 e2 ff ff       	call   f0102e6d <user_mem_check>
f0104baa:	83 c4 10             	add    $0x10,%esp
f0104bad:	85 c0                	test   %eax,%eax
f0104baf:	0f 85 3e 02 00 00    	jne    f0104df3 <debuginfo_eip+0x2a5>
			return -1;
		}

		stabs = usd->stabs;
f0104bb5:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bba:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104bbd:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104bc3:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104bc9:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104bcc:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104bd1:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		// edited by Lethe 
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
f0104bd4:	e8 21 10 00 00       	call   f0105bfa <cpunum>
f0104bd9:	6a 04                	push   $0x4
f0104bdb:	89 f2                	mov    %esi,%edx
f0104bdd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104be0:	29 ca                	sub    %ecx,%edx
f0104be2:	c1 fa 02             	sar    $0x2,%edx
f0104be5:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104beb:	52                   	push   %edx
f0104bec:	51                   	push   %ecx
f0104bed:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf0:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104bf6:	e8 72 e2 ff ff       	call   f0102e6d <user_mem_check>
f0104bfb:	83 c4 10             	add    $0x10,%esp
f0104bfe:	85 c0                	test   %eax,%eax
f0104c00:	0f 85 f4 01 00 00    	jne    f0104dfa <debuginfo_eip+0x2ac>
			return -1;
		}
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
f0104c06:	e8 ef 0f 00 00       	call   f0105bfa <cpunum>
f0104c0b:	6a 04                	push   $0x4
f0104c0d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104c10:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104c13:	29 ca                	sub    %ecx,%edx
f0104c15:	52                   	push   %edx
f0104c16:	51                   	push   %ecx
f0104c17:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1a:	ff b0 28 90 20 f0    	pushl  -0xfdf6fd8(%eax)
f0104c20:	e8 48 e2 ff ff       	call   f0102e6d <user_mem_check>
f0104c25:	83 c4 10             	add    $0x10,%esp
f0104c28:	85 c0                	test   %eax,%eax
f0104c2a:	74 1f                	je     f0104c4b <debuginfo_eip+0xfd>
f0104c2c:	e9 d0 01 00 00       	jmp    f0104e01 <debuginfo_eip+0x2b3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104c31:	c7 45 bc cd 5c 11 f0 	movl   $0xf0115ccd,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104c38:	c7 45 b8 19 25 11 f0 	movl   $0xf0112519,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c3f:	be 18 25 11 f0       	mov    $0xf0112518,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c44:	c7 45 c0 50 81 10 f0 	movl   $0xf0108150,-0x40(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c4b:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c4e:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104c51:	0f 83 b1 01 00 00    	jae    f0104e08 <debuginfo_eip+0x2ba>
f0104c57:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104c5b:	0f 85 ae 01 00 00    	jne    f0104e0f <debuginfo_eip+0x2c1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c61:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c68:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104c6b:	c1 fe 02             	sar    $0x2,%esi
f0104c6e:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104c74:	83 e8 01             	sub    $0x1,%eax
f0104c77:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c7a:	83 ec 08             	sub    $0x8,%esp
f0104c7d:	57                   	push   %edi
f0104c7e:	6a 64                	push   $0x64
f0104c80:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104c83:	89 d1                	mov    %edx,%ecx
f0104c85:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c88:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104c8b:	89 f0                	mov    %esi,%eax
f0104c8d:	e8 c6 fd ff ff       	call   f0104a58 <stab_binsearch>
	if (lfile == 0)
f0104c92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c95:	83 c4 10             	add    $0x10,%esp
f0104c98:	85 c0                	test   %eax,%eax
f0104c9a:	0f 84 76 01 00 00    	je     f0104e16 <debuginfo_eip+0x2c8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104ca0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104ca3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ca6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104ca9:	83 ec 08             	sub    $0x8,%esp
f0104cac:	57                   	push   %edi
f0104cad:	6a 24                	push   $0x24
f0104caf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104cb2:	89 d1                	mov    %edx,%ecx
f0104cb4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104cb7:	89 f0                	mov    %esi,%eax
f0104cb9:	e8 9a fd ff ff       	call   f0104a58 <stab_binsearch>

	if (lfun <= rfun) {
f0104cbe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104cc1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cc4:	83 c4 10             	add    $0x10,%esp
f0104cc7:	39 d0                	cmp    %edx,%eax
f0104cc9:	7f 2e                	jg     f0104cf9 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104ccb:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104cce:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104cd1:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104cd4:	8b 36                	mov    (%esi),%esi
f0104cd6:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104cd9:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104cdc:	39 ce                	cmp    %ecx,%esi
f0104cde:	73 06                	jae    f0104ce6 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ce0:	03 75 b8             	add    -0x48(%ebp),%esi
f0104ce3:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ce6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ce9:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104cec:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104cef:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104cf1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104cf4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104cf7:	eb 0f                	jmp    f0104d08 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104cf9:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104cfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104d02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d05:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104d08:	83 ec 08             	sub    $0x8,%esp
f0104d0b:	6a 3a                	push   $0x3a
f0104d0d:	ff 73 08             	pushl  0x8(%ebx)
f0104d10:	e8 a7 08 00 00       	call   f01055bc <strfind>
f0104d15:	2b 43 08             	sub    0x8(%ebx),%eax
f0104d18:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	// added by Lethe 
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0104d1b:	83 c4 08             	add    $0x8,%esp
f0104d1e:	57                   	push   %edi
f0104d1f:	6a 44                	push   $0x44
f0104d21:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104d24:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104d27:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d2a:	89 f8                	mov    %edi,%eax
f0104d2c:	e8 27 fd ff ff       	call   f0104a58 <stab_binsearch>
	
	if(lline<=rline){
f0104d31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104d34:	83 c4 10             	add    $0x10,%esp
f0104d37:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104d3a:	0f 8f dd 00 00 00    	jg     f0104e1d <debuginfo_eip+0x2cf>
		//found
		info->eip_line=stabs[lline].n_desc;
f0104d40:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d43:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104d46:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104d4a:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d50:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104d54:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d57:	eb 0a                	jmp    f0104d63 <debuginfo_eip+0x215>
f0104d59:	83 e8 01             	sub    $0x1,%eax
f0104d5c:	83 ea 0c             	sub    $0xc,%edx
f0104d5f:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104d63:	39 c7                	cmp    %eax,%edi
f0104d65:	7e 05                	jle    f0104d6c <debuginfo_eip+0x21e>
f0104d67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d6a:	eb 47                	jmp    f0104db3 <debuginfo_eip+0x265>
	       && stabs[lline].n_type != N_SOL
f0104d6c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d70:	80 f9 84             	cmp    $0x84,%cl
f0104d73:	75 0e                	jne    f0104d83 <debuginfo_eip+0x235>
f0104d75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d78:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d7c:	74 1c                	je     f0104d9a <debuginfo_eip+0x24c>
f0104d7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d81:	eb 17                	jmp    f0104d9a <debuginfo_eip+0x24c>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d83:	80 f9 64             	cmp    $0x64,%cl
f0104d86:	75 d1                	jne    f0104d59 <debuginfo_eip+0x20b>
f0104d88:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104d8c:	74 cb                	je     f0104d59 <debuginfo_eip+0x20b>
f0104d8e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d91:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d95:	74 03                	je     f0104d9a <debuginfo_eip+0x24c>
f0104d97:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d9a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d9d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104da0:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104da3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104da6:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104da9:	29 f8                	sub    %edi,%eax
f0104dab:	39 c2                	cmp    %eax,%edx
f0104dad:	73 04                	jae    f0104db3 <debuginfo_eip+0x265>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104daf:	01 fa                	add    %edi,%edx
f0104db1:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104db3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104db6:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104db9:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104dbe:	39 f2                	cmp    %esi,%edx
f0104dc0:	7d 67                	jge    f0104e29 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
f0104dc2:	83 c2 01             	add    $0x1,%edx
f0104dc5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104dc8:	89 d0                	mov    %edx,%eax
f0104dca:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104dcd:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104dd0:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104dd3:	eb 04                	jmp    f0104dd9 <debuginfo_eip+0x28b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104dd5:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104dd9:	39 c6                	cmp    %eax,%esi
f0104ddb:	7e 47                	jle    f0104e24 <debuginfo_eip+0x2d6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ddd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104de1:	83 c0 01             	add    $0x1,%eax
f0104de4:	83 c2 0c             	add    $0xc,%edx
f0104de7:	80 f9 a0             	cmp    $0xa0,%cl
f0104dea:	74 e9                	je     f0104dd5 <debuginfo_eip+0x287>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104dec:	b8 00 00 00 00       	mov    $0x0,%eax
f0104df1:	eb 36                	jmp    f0104e29 <debuginfo_eip+0x2db>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// edited by Lethe 
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U)) {
			return -1;
f0104df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104df8:	eb 2f                	jmp    f0104e29 <debuginfo_eip+0x2db>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		// edited by Lethe 
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U)) {
			return -1;
f0104dfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dff:	eb 28                	jmp    f0104e29 <debuginfo_eip+0x2db>
		}
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) {
			return -1;
f0104e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e06:	eb 21                	jmp    f0104e29 <debuginfo_eip+0x2db>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104e08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e0d:	eb 1a                	jmp    f0104e29 <debuginfo_eip+0x2db>
f0104e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e14:	eb 13                	jmp    f0104e29 <debuginfo_eip+0x2db>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e1b:	eb 0c                	jmp    f0104e29 <debuginfo_eip+0x2db>
		//found
		info->eip_line=stabs[lline].n_desc;
	}
	else{
		//not found
		return -1;
f0104e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e22:	eb 05                	jmp    f0104e29 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e24:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e29:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e2c:	5b                   	pop    %ebx
f0104e2d:	5e                   	pop    %esi
f0104e2e:	5f                   	pop    %edi
f0104e2f:	5d                   	pop    %ebp
f0104e30:	c3                   	ret    

f0104e31 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e31:	55                   	push   %ebp
f0104e32:	89 e5                	mov    %esp,%ebp
f0104e34:	57                   	push   %edi
f0104e35:	56                   	push   %esi
f0104e36:	53                   	push   %ebx
f0104e37:	83 ec 1c             	sub    $0x1c,%esp
f0104e3a:	89 c7                	mov    %eax,%edi
f0104e3c:	89 d6                	mov    %edx,%esi
f0104e3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e41:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e44:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e47:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e52:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e55:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e58:	39 d3                	cmp    %edx,%ebx
f0104e5a:	72 05                	jb     f0104e61 <printnum+0x30>
f0104e5c:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e5f:	77 45                	ja     f0104ea6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e61:	83 ec 0c             	sub    $0xc,%esp
f0104e64:	ff 75 18             	pushl  0x18(%ebp)
f0104e67:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e6a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e6d:	53                   	push   %ebx
f0104e6e:	ff 75 10             	pushl  0x10(%ebp)
f0104e71:	83 ec 08             	sub    $0x8,%esp
f0104e74:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e77:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e7a:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e7d:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e80:	e8 7b 11 00 00       	call   f0106000 <__udivdi3>
f0104e85:	83 c4 18             	add    $0x18,%esp
f0104e88:	52                   	push   %edx
f0104e89:	50                   	push   %eax
f0104e8a:	89 f2                	mov    %esi,%edx
f0104e8c:	89 f8                	mov    %edi,%eax
f0104e8e:	e8 9e ff ff ff       	call   f0104e31 <printnum>
f0104e93:	83 c4 20             	add    $0x20,%esp
f0104e96:	eb 18                	jmp    f0104eb0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e98:	83 ec 08             	sub    $0x8,%esp
f0104e9b:	56                   	push   %esi
f0104e9c:	ff 75 18             	pushl  0x18(%ebp)
f0104e9f:	ff d7                	call   *%edi
f0104ea1:	83 c4 10             	add    $0x10,%esp
f0104ea4:	eb 03                	jmp    f0104ea9 <printnum+0x78>
f0104ea6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ea9:	83 eb 01             	sub    $0x1,%ebx
f0104eac:	85 db                	test   %ebx,%ebx
f0104eae:	7f e8                	jg     f0104e98 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104eb0:	83 ec 08             	sub    $0x8,%esp
f0104eb3:	56                   	push   %esi
f0104eb4:	83 ec 04             	sub    $0x4,%esp
f0104eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104eba:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ebd:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ec0:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ec3:	e8 68 12 00 00       	call   f0106130 <__umoddi3>
f0104ec8:	83 c4 14             	add    $0x14,%esp
f0104ecb:	0f be 80 ae 7b 10 f0 	movsbl -0xfef8452(%eax),%eax
f0104ed2:	50                   	push   %eax
f0104ed3:	ff d7                	call   *%edi
}
f0104ed5:	83 c4 10             	add    $0x10,%esp
f0104ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104edb:	5b                   	pop    %ebx
f0104edc:	5e                   	pop    %esi
f0104edd:	5f                   	pop    %edi
f0104ede:	5d                   	pop    %ebp
f0104edf:	c3                   	ret    

f0104ee0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104ee0:	55                   	push   %ebp
f0104ee1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104ee3:	83 fa 01             	cmp    $0x1,%edx
f0104ee6:	7e 0e                	jle    f0104ef6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104ee8:	8b 10                	mov    (%eax),%edx
f0104eea:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104eed:	89 08                	mov    %ecx,(%eax)
f0104eef:	8b 02                	mov    (%edx),%eax
f0104ef1:	8b 52 04             	mov    0x4(%edx),%edx
f0104ef4:	eb 22                	jmp    f0104f18 <getuint+0x38>
	else if (lflag)
f0104ef6:	85 d2                	test   %edx,%edx
f0104ef8:	74 10                	je     f0104f0a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104efa:	8b 10                	mov    (%eax),%edx
f0104efc:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104eff:	89 08                	mov    %ecx,(%eax)
f0104f01:	8b 02                	mov    (%edx),%eax
f0104f03:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f08:	eb 0e                	jmp    f0104f18 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104f0a:	8b 10                	mov    (%eax),%edx
f0104f0c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f0f:	89 08                	mov    %ecx,(%eax)
f0104f11:	8b 02                	mov    (%edx),%eax
f0104f13:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104f18:	5d                   	pop    %ebp
f0104f19:	c3                   	ret    

f0104f1a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f1a:	55                   	push   %ebp
f0104f1b:	89 e5                	mov    %esp,%ebp
f0104f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f20:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f24:	8b 10                	mov    (%eax),%edx
f0104f26:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f29:	73 0a                	jae    f0104f35 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f2b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f2e:	89 08                	mov    %ecx,(%eax)
f0104f30:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f33:	88 02                	mov    %al,(%edx)
}
f0104f35:	5d                   	pop    %ebp
f0104f36:	c3                   	ret    

f0104f37 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104f37:	55                   	push   %ebp
f0104f38:	89 e5                	mov    %esp,%ebp
f0104f3a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f3d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f40:	50                   	push   %eax
f0104f41:	ff 75 10             	pushl  0x10(%ebp)
f0104f44:	ff 75 0c             	pushl  0xc(%ebp)
f0104f47:	ff 75 08             	pushl  0x8(%ebp)
f0104f4a:	e8 05 00 00 00       	call   f0104f54 <vprintfmt>
	va_end(ap);
}
f0104f4f:	83 c4 10             	add    $0x10,%esp
f0104f52:	c9                   	leave  
f0104f53:	c3                   	ret    

f0104f54 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f54:	55                   	push   %ebp
f0104f55:	89 e5                	mov    %esp,%ebp
f0104f57:	57                   	push   %edi
f0104f58:	56                   	push   %esi
f0104f59:	53                   	push   %ebx
f0104f5a:	83 ec 2c             	sub    $0x2c,%esp
f0104f5d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f63:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f66:	eb 12                	jmp    f0104f7a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f68:	85 c0                	test   %eax,%eax
f0104f6a:	0f 84 89 03 00 00    	je     f01052f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104f70:	83 ec 08             	sub    $0x8,%esp
f0104f73:	53                   	push   %ebx
f0104f74:	50                   	push   %eax
f0104f75:	ff d6                	call   *%esi
f0104f77:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f7a:	83 c7 01             	add    $0x1,%edi
f0104f7d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f81:	83 f8 25             	cmp    $0x25,%eax
f0104f84:	75 e2                	jne    f0104f68 <vprintfmt+0x14>
f0104f86:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f8a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f91:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f98:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f9f:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fa4:	eb 07                	jmp    f0104fad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104fa9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fad:	8d 47 01             	lea    0x1(%edi),%eax
f0104fb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fb3:	0f b6 07             	movzbl (%edi),%eax
f0104fb6:	0f b6 c8             	movzbl %al,%ecx
f0104fb9:	83 e8 23             	sub    $0x23,%eax
f0104fbc:	3c 55                	cmp    $0x55,%al
f0104fbe:	0f 87 1a 03 00 00    	ja     f01052de <vprintfmt+0x38a>
f0104fc4:	0f b6 c0             	movzbl %al,%eax
f0104fc7:	ff 24 85 00 7d 10 f0 	jmp    *-0xfef8300(,%eax,4)
f0104fce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104fd1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104fd5:	eb d6                	jmp    f0104fad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fda:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fdf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104fe2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fe5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104fe9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104fec:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104fef:	83 fa 09             	cmp    $0x9,%edx
f0104ff2:	77 39                	ja     f010502d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104ff4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104ff7:	eb e9                	jmp    f0104fe2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104ff9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ffc:	8d 48 04             	lea    0x4(%eax),%ecx
f0104fff:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105002:	8b 00                	mov    (%eax),%eax
f0105004:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105007:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010500a:	eb 27                	jmp    f0105033 <vprintfmt+0xdf>
f010500c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010500f:	85 c0                	test   %eax,%eax
f0105011:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105016:	0f 49 c8             	cmovns %eax,%ecx
f0105019:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010501c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010501f:	eb 8c                	jmp    f0104fad <vprintfmt+0x59>
f0105021:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105024:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010502b:	eb 80                	jmp    f0104fad <vprintfmt+0x59>
f010502d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105030:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105033:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105037:	0f 89 70 ff ff ff    	jns    f0104fad <vprintfmt+0x59>
				width = precision, precision = -1;
f010503d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105040:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105043:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010504a:	e9 5e ff ff ff       	jmp    f0104fad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010504f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105052:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105055:	e9 53 ff ff ff       	jmp    f0104fad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010505a:	8b 45 14             	mov    0x14(%ebp),%eax
f010505d:	8d 50 04             	lea    0x4(%eax),%edx
f0105060:	89 55 14             	mov    %edx,0x14(%ebp)
f0105063:	83 ec 08             	sub    $0x8,%esp
f0105066:	53                   	push   %ebx
f0105067:	ff 30                	pushl  (%eax)
f0105069:	ff d6                	call   *%esi
			break;
f010506b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010506e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105071:	e9 04 ff ff ff       	jmp    f0104f7a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105076:	8b 45 14             	mov    0x14(%ebp),%eax
f0105079:	8d 50 04             	lea    0x4(%eax),%edx
f010507c:	89 55 14             	mov    %edx,0x14(%ebp)
f010507f:	8b 00                	mov    (%eax),%eax
f0105081:	99                   	cltd   
f0105082:	31 d0                	xor    %edx,%eax
f0105084:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105086:	83 f8 0f             	cmp    $0xf,%eax
f0105089:	7f 0b                	jg     f0105096 <vprintfmt+0x142>
f010508b:	8b 14 85 60 7e 10 f0 	mov    -0xfef81a0(,%eax,4),%edx
f0105092:	85 d2                	test   %edx,%edx
f0105094:	75 18                	jne    f01050ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105096:	50                   	push   %eax
f0105097:	68 c6 7b 10 f0       	push   $0xf0107bc6
f010509c:	53                   	push   %ebx
f010509d:	56                   	push   %esi
f010509e:	e8 94 fe ff ff       	call   f0104f37 <printfmt>
f01050a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01050a9:	e9 cc fe ff ff       	jmp    f0104f7a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01050ae:	52                   	push   %edx
f01050af:	68 77 6a 10 f0       	push   $0xf0106a77
f01050b4:	53                   	push   %ebx
f01050b5:	56                   	push   %esi
f01050b6:	e8 7c fe ff ff       	call   f0104f37 <printfmt>
f01050bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050c1:	e9 b4 fe ff ff       	jmp    f0104f7a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01050c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01050c9:	8d 50 04             	lea    0x4(%eax),%edx
f01050cc:	89 55 14             	mov    %edx,0x14(%ebp)
f01050cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01050d1:	85 ff                	test   %edi,%edi
f01050d3:	b8 bf 7b 10 f0       	mov    $0xf0107bbf,%eax
f01050d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01050db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050df:	0f 8e 94 00 00 00    	jle    f0105179 <vprintfmt+0x225>
f01050e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01050e9:	0f 84 98 00 00 00    	je     f0105187 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050ef:	83 ec 08             	sub    $0x8,%esp
f01050f2:	ff 75 d0             	pushl  -0x30(%ebp)
f01050f5:	57                   	push   %edi
f01050f6:	e8 77 03 00 00       	call   f0105472 <strnlen>
f01050fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01050fe:	29 c1                	sub    %eax,%ecx
f0105100:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105103:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105106:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010510a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010510d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105110:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105112:	eb 0f                	jmp    f0105123 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105114:	83 ec 08             	sub    $0x8,%esp
f0105117:	53                   	push   %ebx
f0105118:	ff 75 e0             	pushl  -0x20(%ebp)
f010511b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010511d:	83 ef 01             	sub    $0x1,%edi
f0105120:	83 c4 10             	add    $0x10,%esp
f0105123:	85 ff                	test   %edi,%edi
f0105125:	7f ed                	jg     f0105114 <vprintfmt+0x1c0>
f0105127:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010512a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010512d:	85 c9                	test   %ecx,%ecx
f010512f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105134:	0f 49 c1             	cmovns %ecx,%eax
f0105137:	29 c1                	sub    %eax,%ecx
f0105139:	89 75 08             	mov    %esi,0x8(%ebp)
f010513c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010513f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105142:	89 cb                	mov    %ecx,%ebx
f0105144:	eb 4d                	jmp    f0105193 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105146:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010514a:	74 1b                	je     f0105167 <vprintfmt+0x213>
f010514c:	0f be c0             	movsbl %al,%eax
f010514f:	83 e8 20             	sub    $0x20,%eax
f0105152:	83 f8 5e             	cmp    $0x5e,%eax
f0105155:	76 10                	jbe    f0105167 <vprintfmt+0x213>
					putch('?', putdat);
f0105157:	83 ec 08             	sub    $0x8,%esp
f010515a:	ff 75 0c             	pushl  0xc(%ebp)
f010515d:	6a 3f                	push   $0x3f
f010515f:	ff 55 08             	call   *0x8(%ebp)
f0105162:	83 c4 10             	add    $0x10,%esp
f0105165:	eb 0d                	jmp    f0105174 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105167:	83 ec 08             	sub    $0x8,%esp
f010516a:	ff 75 0c             	pushl  0xc(%ebp)
f010516d:	52                   	push   %edx
f010516e:	ff 55 08             	call   *0x8(%ebp)
f0105171:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105174:	83 eb 01             	sub    $0x1,%ebx
f0105177:	eb 1a                	jmp    f0105193 <vprintfmt+0x23f>
f0105179:	89 75 08             	mov    %esi,0x8(%ebp)
f010517c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010517f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105182:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105185:	eb 0c                	jmp    f0105193 <vprintfmt+0x23f>
f0105187:	89 75 08             	mov    %esi,0x8(%ebp)
f010518a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010518d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105190:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105193:	83 c7 01             	add    $0x1,%edi
f0105196:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010519a:	0f be d0             	movsbl %al,%edx
f010519d:	85 d2                	test   %edx,%edx
f010519f:	74 23                	je     f01051c4 <vprintfmt+0x270>
f01051a1:	85 f6                	test   %esi,%esi
f01051a3:	78 a1                	js     f0105146 <vprintfmt+0x1f2>
f01051a5:	83 ee 01             	sub    $0x1,%esi
f01051a8:	79 9c                	jns    f0105146 <vprintfmt+0x1f2>
f01051aa:	89 df                	mov    %ebx,%edi
f01051ac:	8b 75 08             	mov    0x8(%ebp),%esi
f01051af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051b2:	eb 18                	jmp    f01051cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01051b4:	83 ec 08             	sub    $0x8,%esp
f01051b7:	53                   	push   %ebx
f01051b8:	6a 20                	push   $0x20
f01051ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01051bc:	83 ef 01             	sub    $0x1,%edi
f01051bf:	83 c4 10             	add    $0x10,%esp
f01051c2:	eb 08                	jmp    f01051cc <vprintfmt+0x278>
f01051c4:	89 df                	mov    %ebx,%edi
f01051c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01051c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051cc:	85 ff                	test   %edi,%edi
f01051ce:	7f e4                	jg     f01051b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051d3:	e9 a2 fd ff ff       	jmp    f0104f7a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051d8:	83 fa 01             	cmp    $0x1,%edx
f01051db:	7e 16                	jle    f01051f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01051dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01051e0:	8d 50 08             	lea    0x8(%eax),%edx
f01051e3:	89 55 14             	mov    %edx,0x14(%ebp)
f01051e6:	8b 50 04             	mov    0x4(%eax),%edx
f01051e9:	8b 00                	mov    (%eax),%eax
f01051eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051f1:	eb 32                	jmp    f0105225 <vprintfmt+0x2d1>
	else if (lflag)
f01051f3:	85 d2                	test   %edx,%edx
f01051f5:	74 18                	je     f010520f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01051f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01051fa:	8d 50 04             	lea    0x4(%eax),%edx
f01051fd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105200:	8b 00                	mov    (%eax),%eax
f0105202:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105205:	89 c1                	mov    %eax,%ecx
f0105207:	c1 f9 1f             	sar    $0x1f,%ecx
f010520a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010520d:	eb 16                	jmp    f0105225 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010520f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105212:	8d 50 04             	lea    0x4(%eax),%edx
f0105215:	89 55 14             	mov    %edx,0x14(%ebp)
f0105218:	8b 00                	mov    (%eax),%eax
f010521a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010521d:	89 c1                	mov    %eax,%ecx
f010521f:	c1 f9 1f             	sar    $0x1f,%ecx
f0105222:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105225:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105228:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010522b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105230:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105234:	79 74                	jns    f01052aa <vprintfmt+0x356>
				putch('-', putdat);
f0105236:	83 ec 08             	sub    $0x8,%esp
f0105239:	53                   	push   %ebx
f010523a:	6a 2d                	push   $0x2d
f010523c:	ff d6                	call   *%esi
				num = -(long long) num;
f010523e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105241:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105244:	f7 d8                	neg    %eax
f0105246:	83 d2 00             	adc    $0x0,%edx
f0105249:	f7 da                	neg    %edx
f010524b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010524e:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105253:	eb 55                	jmp    f01052aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105255:	8d 45 14             	lea    0x14(%ebp),%eax
f0105258:	e8 83 fc ff ff       	call   f0104ee0 <getuint>
			base = 10;
f010525d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105262:	eb 46                	jmp    f01052aa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
f0105264:	8d 45 14             	lea    0x14(%ebp),%eax
f0105267:	e8 74 fc ff ff       	call   f0104ee0 <getuint>
			base=8;
f010526c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105271:	eb 37                	jmp    f01052aa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0105273:	83 ec 08             	sub    $0x8,%esp
f0105276:	53                   	push   %ebx
f0105277:	6a 30                	push   $0x30
f0105279:	ff d6                	call   *%esi
			putch('x', putdat);
f010527b:	83 c4 08             	add    $0x8,%esp
f010527e:	53                   	push   %ebx
f010527f:	6a 78                	push   $0x78
f0105281:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105283:	8b 45 14             	mov    0x14(%ebp),%eax
f0105286:	8d 50 04             	lea    0x4(%eax),%edx
f0105289:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010528c:	8b 00                	mov    (%eax),%eax
f010528e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105293:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105296:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010529b:	eb 0d                	jmp    f01052aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010529d:	8d 45 14             	lea    0x14(%ebp),%eax
f01052a0:	e8 3b fc ff ff       	call   f0104ee0 <getuint>
			base = 16;
f01052a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01052aa:	83 ec 0c             	sub    $0xc,%esp
f01052ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01052b1:	57                   	push   %edi
f01052b2:	ff 75 e0             	pushl  -0x20(%ebp)
f01052b5:	51                   	push   %ecx
f01052b6:	52                   	push   %edx
f01052b7:	50                   	push   %eax
f01052b8:	89 da                	mov    %ebx,%edx
f01052ba:	89 f0                	mov    %esi,%eax
f01052bc:	e8 70 fb ff ff       	call   f0104e31 <printnum>
			break;
f01052c1:	83 c4 20             	add    $0x20,%esp
f01052c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052c7:	e9 ae fc ff ff       	jmp    f0104f7a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052cc:	83 ec 08             	sub    $0x8,%esp
f01052cf:	53                   	push   %ebx
f01052d0:	51                   	push   %ecx
f01052d1:	ff d6                	call   *%esi
			break;
f01052d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01052d9:	e9 9c fc ff ff       	jmp    f0104f7a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01052de:	83 ec 08             	sub    $0x8,%esp
f01052e1:	53                   	push   %ebx
f01052e2:	6a 25                	push   $0x25
f01052e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01052e6:	83 c4 10             	add    $0x10,%esp
f01052e9:	eb 03                	jmp    f01052ee <vprintfmt+0x39a>
f01052eb:	83 ef 01             	sub    $0x1,%edi
f01052ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01052f2:	75 f7                	jne    f01052eb <vprintfmt+0x397>
f01052f4:	e9 81 fc ff ff       	jmp    f0104f7a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01052f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052fc:	5b                   	pop    %ebx
f01052fd:	5e                   	pop    %esi
f01052fe:	5f                   	pop    %edi
f01052ff:	5d                   	pop    %ebp
f0105300:	c3                   	ret    

f0105301 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105301:	55                   	push   %ebp
f0105302:	89 e5                	mov    %esp,%ebp
f0105304:	83 ec 18             	sub    $0x18,%esp
f0105307:	8b 45 08             	mov    0x8(%ebp),%eax
f010530a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010530d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105310:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105314:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105317:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010531e:	85 c0                	test   %eax,%eax
f0105320:	74 26                	je     f0105348 <vsnprintf+0x47>
f0105322:	85 d2                	test   %edx,%edx
f0105324:	7e 22                	jle    f0105348 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105326:	ff 75 14             	pushl  0x14(%ebp)
f0105329:	ff 75 10             	pushl  0x10(%ebp)
f010532c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010532f:	50                   	push   %eax
f0105330:	68 1a 4f 10 f0       	push   $0xf0104f1a
f0105335:	e8 1a fc ff ff       	call   f0104f54 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010533a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010533d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105340:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105343:	83 c4 10             	add    $0x10,%esp
f0105346:	eb 05                	jmp    f010534d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105348:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010534d:	c9                   	leave  
f010534e:	c3                   	ret    

f010534f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010534f:	55                   	push   %ebp
f0105350:	89 e5                	mov    %esp,%ebp
f0105352:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105355:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105358:	50                   	push   %eax
f0105359:	ff 75 10             	pushl  0x10(%ebp)
f010535c:	ff 75 0c             	pushl  0xc(%ebp)
f010535f:	ff 75 08             	pushl  0x8(%ebp)
f0105362:	e8 9a ff ff ff       	call   f0105301 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105367:	c9                   	leave  
f0105368:	c3                   	ret    

f0105369 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105369:	55                   	push   %ebp
f010536a:	89 e5                	mov    %esp,%ebp
f010536c:	57                   	push   %edi
f010536d:	56                   	push   %esi
f010536e:	53                   	push   %ebx
f010536f:	83 ec 0c             	sub    $0xc,%esp
f0105372:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105375:	85 c0                	test   %eax,%eax
f0105377:	74 11                	je     f010538a <readline+0x21>
		cprintf("%s", prompt);
f0105379:	83 ec 08             	sub    $0x8,%esp
f010537c:	50                   	push   %eax
f010537d:	68 77 6a 10 f0       	push   $0xf0106a77
f0105382:	e8 7f e4 ff ff       	call   f0103806 <cprintf>
f0105387:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f010538a:	83 ec 0c             	sub    $0xc,%esp
f010538d:	6a 00                	push   $0x0
f010538f:	e8 1b b4 ff ff       	call   f01007af <iscons>
f0105394:	89 c7                	mov    %eax,%edi
f0105396:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105399:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010539e:	e8 fb b3 ff ff       	call   f010079e <getchar>
f01053a3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01053a5:	85 c0                	test   %eax,%eax
f01053a7:	79 29                	jns    f01053d2 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01053a9:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01053ae:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01053b1:	0f 84 9b 00 00 00    	je     f0105452 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01053b7:	83 ec 08             	sub    $0x8,%esp
f01053ba:	53                   	push   %ebx
f01053bb:	68 bf 7e 10 f0       	push   $0xf0107ebf
f01053c0:	e8 41 e4 ff ff       	call   f0103806 <cprintf>
f01053c5:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01053c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01053cd:	e9 80 00 00 00       	jmp    f0105452 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01053d2:	83 f8 08             	cmp    $0x8,%eax
f01053d5:	0f 94 c2             	sete   %dl
f01053d8:	83 f8 7f             	cmp    $0x7f,%eax
f01053db:	0f 94 c0             	sete   %al
f01053de:	08 c2                	or     %al,%dl
f01053e0:	74 1a                	je     f01053fc <readline+0x93>
f01053e2:	85 f6                	test   %esi,%esi
f01053e4:	7e 16                	jle    f01053fc <readline+0x93>
			if (echoing)
f01053e6:	85 ff                	test   %edi,%edi
f01053e8:	74 0d                	je     f01053f7 <readline+0x8e>
				cputchar('\b');
f01053ea:	83 ec 0c             	sub    $0xc,%esp
f01053ed:	6a 08                	push   $0x8
f01053ef:	e8 9a b3 ff ff       	call   f010078e <cputchar>
f01053f4:	83 c4 10             	add    $0x10,%esp
			i--;
f01053f7:	83 ee 01             	sub    $0x1,%esi
f01053fa:	eb a2                	jmp    f010539e <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01053fc:	83 fb 1f             	cmp    $0x1f,%ebx
f01053ff:	7e 26                	jle    f0105427 <readline+0xbe>
f0105401:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105407:	7f 1e                	jg     f0105427 <readline+0xbe>
			if (echoing)
f0105409:	85 ff                	test   %edi,%edi
f010540b:	74 0c                	je     f0105419 <readline+0xb0>
				cputchar(c);
f010540d:	83 ec 0c             	sub    $0xc,%esp
f0105410:	53                   	push   %ebx
f0105411:	e8 78 b3 ff ff       	call   f010078e <cputchar>
f0105416:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105419:	88 9e 80 8a 20 f0    	mov    %bl,-0xfdf7580(%esi)
f010541f:	8d 76 01             	lea    0x1(%esi),%esi
f0105422:	e9 77 ff ff ff       	jmp    f010539e <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105427:	83 fb 0a             	cmp    $0xa,%ebx
f010542a:	74 09                	je     f0105435 <readline+0xcc>
f010542c:	83 fb 0d             	cmp    $0xd,%ebx
f010542f:	0f 85 69 ff ff ff    	jne    f010539e <readline+0x35>
			if (echoing)
f0105435:	85 ff                	test   %edi,%edi
f0105437:	74 0d                	je     f0105446 <readline+0xdd>
				cputchar('\n');
f0105439:	83 ec 0c             	sub    $0xc,%esp
f010543c:	6a 0a                	push   $0xa
f010543e:	e8 4b b3 ff ff       	call   f010078e <cputchar>
f0105443:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105446:	c6 86 80 8a 20 f0 00 	movb   $0x0,-0xfdf7580(%esi)
			return buf;
f010544d:	b8 80 8a 20 f0       	mov    $0xf0208a80,%eax
		}
	}
}
f0105452:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105455:	5b                   	pop    %ebx
f0105456:	5e                   	pop    %esi
f0105457:	5f                   	pop    %edi
f0105458:	5d                   	pop    %ebp
f0105459:	c3                   	ret    

f010545a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010545a:	55                   	push   %ebp
f010545b:	89 e5                	mov    %esp,%ebp
f010545d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105460:	b8 00 00 00 00       	mov    $0x0,%eax
f0105465:	eb 03                	jmp    f010546a <strlen+0x10>
		n++;
f0105467:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010546a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010546e:	75 f7                	jne    f0105467 <strlen+0xd>
		n++;
	return n;
}
f0105470:	5d                   	pop    %ebp
f0105471:	c3                   	ret    

f0105472 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105472:	55                   	push   %ebp
f0105473:	89 e5                	mov    %esp,%ebp
f0105475:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105478:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010547b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105480:	eb 03                	jmp    f0105485 <strnlen+0x13>
		n++;
f0105482:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105485:	39 c2                	cmp    %eax,%edx
f0105487:	74 08                	je     f0105491 <strnlen+0x1f>
f0105489:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010548d:	75 f3                	jne    f0105482 <strnlen+0x10>
f010548f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105491:	5d                   	pop    %ebp
f0105492:	c3                   	ret    

f0105493 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105493:	55                   	push   %ebp
f0105494:	89 e5                	mov    %esp,%ebp
f0105496:	53                   	push   %ebx
f0105497:	8b 45 08             	mov    0x8(%ebp),%eax
f010549a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010549d:	89 c2                	mov    %eax,%edx
f010549f:	83 c2 01             	add    $0x1,%edx
f01054a2:	83 c1 01             	add    $0x1,%ecx
f01054a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01054a9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01054ac:	84 db                	test   %bl,%bl
f01054ae:	75 ef                	jne    f010549f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01054b0:	5b                   	pop    %ebx
f01054b1:	5d                   	pop    %ebp
f01054b2:	c3                   	ret    

f01054b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054b3:	55                   	push   %ebp
f01054b4:	89 e5                	mov    %esp,%ebp
f01054b6:	53                   	push   %ebx
f01054b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054ba:	53                   	push   %ebx
f01054bb:	e8 9a ff ff ff       	call   f010545a <strlen>
f01054c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01054c3:	ff 75 0c             	pushl  0xc(%ebp)
f01054c6:	01 d8                	add    %ebx,%eax
f01054c8:	50                   	push   %eax
f01054c9:	e8 c5 ff ff ff       	call   f0105493 <strcpy>
	return dst;
}
f01054ce:	89 d8                	mov    %ebx,%eax
f01054d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01054d3:	c9                   	leave  
f01054d4:	c3                   	ret    

f01054d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01054d5:	55                   	push   %ebp
f01054d6:	89 e5                	mov    %esp,%ebp
f01054d8:	56                   	push   %esi
f01054d9:	53                   	push   %ebx
f01054da:	8b 75 08             	mov    0x8(%ebp),%esi
f01054dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054e0:	89 f3                	mov    %esi,%ebx
f01054e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054e5:	89 f2                	mov    %esi,%edx
f01054e7:	eb 0f                	jmp    f01054f8 <strncpy+0x23>
		*dst++ = *src;
f01054e9:	83 c2 01             	add    $0x1,%edx
f01054ec:	0f b6 01             	movzbl (%ecx),%eax
f01054ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01054f2:	80 39 01             	cmpb   $0x1,(%ecx)
f01054f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01054f8:	39 da                	cmp    %ebx,%edx
f01054fa:	75 ed                	jne    f01054e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01054fc:	89 f0                	mov    %esi,%eax
f01054fe:	5b                   	pop    %ebx
f01054ff:	5e                   	pop    %esi
f0105500:	5d                   	pop    %ebp
f0105501:	c3                   	ret    

f0105502 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105502:	55                   	push   %ebp
f0105503:	89 e5                	mov    %esp,%ebp
f0105505:	56                   	push   %esi
f0105506:	53                   	push   %ebx
f0105507:	8b 75 08             	mov    0x8(%ebp),%esi
f010550a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010550d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105510:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105512:	85 d2                	test   %edx,%edx
f0105514:	74 21                	je     f0105537 <strlcpy+0x35>
f0105516:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010551a:	89 f2                	mov    %esi,%edx
f010551c:	eb 09                	jmp    f0105527 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010551e:	83 c2 01             	add    $0x1,%edx
f0105521:	83 c1 01             	add    $0x1,%ecx
f0105524:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105527:	39 c2                	cmp    %eax,%edx
f0105529:	74 09                	je     f0105534 <strlcpy+0x32>
f010552b:	0f b6 19             	movzbl (%ecx),%ebx
f010552e:	84 db                	test   %bl,%bl
f0105530:	75 ec                	jne    f010551e <strlcpy+0x1c>
f0105532:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105534:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105537:	29 f0                	sub    %esi,%eax
}
f0105539:	5b                   	pop    %ebx
f010553a:	5e                   	pop    %esi
f010553b:	5d                   	pop    %ebp
f010553c:	c3                   	ret    

f010553d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010553d:	55                   	push   %ebp
f010553e:	89 e5                	mov    %esp,%ebp
f0105540:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105543:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105546:	eb 06                	jmp    f010554e <strcmp+0x11>
		p++, q++;
f0105548:	83 c1 01             	add    $0x1,%ecx
f010554b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010554e:	0f b6 01             	movzbl (%ecx),%eax
f0105551:	84 c0                	test   %al,%al
f0105553:	74 04                	je     f0105559 <strcmp+0x1c>
f0105555:	3a 02                	cmp    (%edx),%al
f0105557:	74 ef                	je     f0105548 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105559:	0f b6 c0             	movzbl %al,%eax
f010555c:	0f b6 12             	movzbl (%edx),%edx
f010555f:	29 d0                	sub    %edx,%eax
}
f0105561:	5d                   	pop    %ebp
f0105562:	c3                   	ret    

f0105563 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105563:	55                   	push   %ebp
f0105564:	89 e5                	mov    %esp,%ebp
f0105566:	53                   	push   %ebx
f0105567:	8b 45 08             	mov    0x8(%ebp),%eax
f010556a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010556d:	89 c3                	mov    %eax,%ebx
f010556f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105572:	eb 06                	jmp    f010557a <strncmp+0x17>
		n--, p++, q++;
f0105574:	83 c0 01             	add    $0x1,%eax
f0105577:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010557a:	39 d8                	cmp    %ebx,%eax
f010557c:	74 15                	je     f0105593 <strncmp+0x30>
f010557e:	0f b6 08             	movzbl (%eax),%ecx
f0105581:	84 c9                	test   %cl,%cl
f0105583:	74 04                	je     f0105589 <strncmp+0x26>
f0105585:	3a 0a                	cmp    (%edx),%cl
f0105587:	74 eb                	je     f0105574 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105589:	0f b6 00             	movzbl (%eax),%eax
f010558c:	0f b6 12             	movzbl (%edx),%edx
f010558f:	29 d0                	sub    %edx,%eax
f0105591:	eb 05                	jmp    f0105598 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105593:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105598:	5b                   	pop    %ebx
f0105599:	5d                   	pop    %ebp
f010559a:	c3                   	ret    

f010559b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010559b:	55                   	push   %ebp
f010559c:	89 e5                	mov    %esp,%ebp
f010559e:	8b 45 08             	mov    0x8(%ebp),%eax
f01055a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055a5:	eb 07                	jmp    f01055ae <strchr+0x13>
		if (*s == c)
f01055a7:	38 ca                	cmp    %cl,%dl
f01055a9:	74 0f                	je     f01055ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01055ab:	83 c0 01             	add    $0x1,%eax
f01055ae:	0f b6 10             	movzbl (%eax),%edx
f01055b1:	84 d2                	test   %dl,%dl
f01055b3:	75 f2                	jne    f01055a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055ba:	5d                   	pop    %ebp
f01055bb:	c3                   	ret    

f01055bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055bc:	55                   	push   %ebp
f01055bd:	89 e5                	mov    %esp,%ebp
f01055bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01055c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055c6:	eb 03                	jmp    f01055cb <strfind+0xf>
f01055c8:	83 c0 01             	add    $0x1,%eax
f01055cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01055ce:	38 ca                	cmp    %cl,%dl
f01055d0:	74 04                	je     f01055d6 <strfind+0x1a>
f01055d2:	84 d2                	test   %dl,%dl
f01055d4:	75 f2                	jne    f01055c8 <strfind+0xc>
			break;
	return (char *) s;
}
f01055d6:	5d                   	pop    %ebp
f01055d7:	c3                   	ret    

f01055d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01055d8:	55                   	push   %ebp
f01055d9:	89 e5                	mov    %esp,%ebp
f01055db:	57                   	push   %edi
f01055dc:	56                   	push   %esi
f01055dd:	53                   	push   %ebx
f01055de:	8b 7d 08             	mov    0x8(%ebp),%edi
f01055e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01055e4:	85 c9                	test   %ecx,%ecx
f01055e6:	74 36                	je     f010561e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01055e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01055ee:	75 28                	jne    f0105618 <memset+0x40>
f01055f0:	f6 c1 03             	test   $0x3,%cl
f01055f3:	75 23                	jne    f0105618 <memset+0x40>
		c &= 0xFF;
f01055f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01055f9:	89 d3                	mov    %edx,%ebx
f01055fb:	c1 e3 08             	shl    $0x8,%ebx
f01055fe:	89 d6                	mov    %edx,%esi
f0105600:	c1 e6 18             	shl    $0x18,%esi
f0105603:	89 d0                	mov    %edx,%eax
f0105605:	c1 e0 10             	shl    $0x10,%eax
f0105608:	09 f0                	or     %esi,%eax
f010560a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010560c:	89 d8                	mov    %ebx,%eax
f010560e:	09 d0                	or     %edx,%eax
f0105610:	c1 e9 02             	shr    $0x2,%ecx
f0105613:	fc                   	cld    
f0105614:	f3 ab                	rep stos %eax,%es:(%edi)
f0105616:	eb 06                	jmp    f010561e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105618:	8b 45 0c             	mov    0xc(%ebp),%eax
f010561b:	fc                   	cld    
f010561c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010561e:	89 f8                	mov    %edi,%eax
f0105620:	5b                   	pop    %ebx
f0105621:	5e                   	pop    %esi
f0105622:	5f                   	pop    %edi
f0105623:	5d                   	pop    %ebp
f0105624:	c3                   	ret    

f0105625 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105625:	55                   	push   %ebp
f0105626:	89 e5                	mov    %esp,%ebp
f0105628:	57                   	push   %edi
f0105629:	56                   	push   %esi
f010562a:	8b 45 08             	mov    0x8(%ebp),%eax
f010562d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105630:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105633:	39 c6                	cmp    %eax,%esi
f0105635:	73 35                	jae    f010566c <memmove+0x47>
f0105637:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010563a:	39 d0                	cmp    %edx,%eax
f010563c:	73 2e                	jae    f010566c <memmove+0x47>
		s += n;
		d += n;
f010563e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105641:	89 d6                	mov    %edx,%esi
f0105643:	09 fe                	or     %edi,%esi
f0105645:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010564b:	75 13                	jne    f0105660 <memmove+0x3b>
f010564d:	f6 c1 03             	test   $0x3,%cl
f0105650:	75 0e                	jne    f0105660 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105652:	83 ef 04             	sub    $0x4,%edi
f0105655:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105658:	c1 e9 02             	shr    $0x2,%ecx
f010565b:	fd                   	std    
f010565c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010565e:	eb 09                	jmp    f0105669 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105660:	83 ef 01             	sub    $0x1,%edi
f0105663:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105666:	fd                   	std    
f0105667:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105669:	fc                   	cld    
f010566a:	eb 1d                	jmp    f0105689 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010566c:	89 f2                	mov    %esi,%edx
f010566e:	09 c2                	or     %eax,%edx
f0105670:	f6 c2 03             	test   $0x3,%dl
f0105673:	75 0f                	jne    f0105684 <memmove+0x5f>
f0105675:	f6 c1 03             	test   $0x3,%cl
f0105678:	75 0a                	jne    f0105684 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010567a:	c1 e9 02             	shr    $0x2,%ecx
f010567d:	89 c7                	mov    %eax,%edi
f010567f:	fc                   	cld    
f0105680:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105682:	eb 05                	jmp    f0105689 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105684:	89 c7                	mov    %eax,%edi
f0105686:	fc                   	cld    
f0105687:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105689:	5e                   	pop    %esi
f010568a:	5f                   	pop    %edi
f010568b:	5d                   	pop    %ebp
f010568c:	c3                   	ret    

f010568d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010568d:	55                   	push   %ebp
f010568e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105690:	ff 75 10             	pushl  0x10(%ebp)
f0105693:	ff 75 0c             	pushl  0xc(%ebp)
f0105696:	ff 75 08             	pushl  0x8(%ebp)
f0105699:	e8 87 ff ff ff       	call   f0105625 <memmove>
}
f010569e:	c9                   	leave  
f010569f:	c3                   	ret    

f01056a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01056a0:	55                   	push   %ebp
f01056a1:	89 e5                	mov    %esp,%ebp
f01056a3:	56                   	push   %esi
f01056a4:	53                   	push   %ebx
f01056a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056ab:	89 c6                	mov    %eax,%esi
f01056ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056b0:	eb 1a                	jmp    f01056cc <memcmp+0x2c>
		if (*s1 != *s2)
f01056b2:	0f b6 08             	movzbl (%eax),%ecx
f01056b5:	0f b6 1a             	movzbl (%edx),%ebx
f01056b8:	38 d9                	cmp    %bl,%cl
f01056ba:	74 0a                	je     f01056c6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056bc:	0f b6 c1             	movzbl %cl,%eax
f01056bf:	0f b6 db             	movzbl %bl,%ebx
f01056c2:	29 d8                	sub    %ebx,%eax
f01056c4:	eb 0f                	jmp    f01056d5 <memcmp+0x35>
		s1++, s2++;
f01056c6:	83 c0 01             	add    $0x1,%eax
f01056c9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056cc:	39 f0                	cmp    %esi,%eax
f01056ce:	75 e2                	jne    f01056b2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056d5:	5b                   	pop    %ebx
f01056d6:	5e                   	pop    %esi
f01056d7:	5d                   	pop    %ebp
f01056d8:	c3                   	ret    

f01056d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01056d9:	55                   	push   %ebp
f01056da:	89 e5                	mov    %esp,%ebp
f01056dc:	53                   	push   %ebx
f01056dd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01056e0:	89 c1                	mov    %eax,%ecx
f01056e2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01056e5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056e9:	eb 0a                	jmp    f01056f5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01056eb:	0f b6 10             	movzbl (%eax),%edx
f01056ee:	39 da                	cmp    %ebx,%edx
f01056f0:	74 07                	je     f01056f9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01056f2:	83 c0 01             	add    $0x1,%eax
f01056f5:	39 c8                	cmp    %ecx,%eax
f01056f7:	72 f2                	jb     f01056eb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01056f9:	5b                   	pop    %ebx
f01056fa:	5d                   	pop    %ebp
f01056fb:	c3                   	ret    

f01056fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01056fc:	55                   	push   %ebp
f01056fd:	89 e5                	mov    %esp,%ebp
f01056ff:	57                   	push   %edi
f0105700:	56                   	push   %esi
f0105701:	53                   	push   %ebx
f0105702:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105705:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105708:	eb 03                	jmp    f010570d <strtol+0x11>
		s++;
f010570a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010570d:	0f b6 01             	movzbl (%ecx),%eax
f0105710:	3c 20                	cmp    $0x20,%al
f0105712:	74 f6                	je     f010570a <strtol+0xe>
f0105714:	3c 09                	cmp    $0x9,%al
f0105716:	74 f2                	je     f010570a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105718:	3c 2b                	cmp    $0x2b,%al
f010571a:	75 0a                	jne    f0105726 <strtol+0x2a>
		s++;
f010571c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010571f:	bf 00 00 00 00       	mov    $0x0,%edi
f0105724:	eb 11                	jmp    f0105737 <strtol+0x3b>
f0105726:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010572b:	3c 2d                	cmp    $0x2d,%al
f010572d:	75 08                	jne    f0105737 <strtol+0x3b>
		s++, neg = 1;
f010572f:	83 c1 01             	add    $0x1,%ecx
f0105732:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105737:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010573d:	75 15                	jne    f0105754 <strtol+0x58>
f010573f:	80 39 30             	cmpb   $0x30,(%ecx)
f0105742:	75 10                	jne    f0105754 <strtol+0x58>
f0105744:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105748:	75 7c                	jne    f01057c6 <strtol+0xca>
		s += 2, base = 16;
f010574a:	83 c1 02             	add    $0x2,%ecx
f010574d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105752:	eb 16                	jmp    f010576a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105754:	85 db                	test   %ebx,%ebx
f0105756:	75 12                	jne    f010576a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105758:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010575d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105760:	75 08                	jne    f010576a <strtol+0x6e>
		s++, base = 8;
f0105762:	83 c1 01             	add    $0x1,%ecx
f0105765:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010576a:	b8 00 00 00 00       	mov    $0x0,%eax
f010576f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105772:	0f b6 11             	movzbl (%ecx),%edx
f0105775:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105778:	89 f3                	mov    %esi,%ebx
f010577a:	80 fb 09             	cmp    $0x9,%bl
f010577d:	77 08                	ja     f0105787 <strtol+0x8b>
			dig = *s - '0';
f010577f:	0f be d2             	movsbl %dl,%edx
f0105782:	83 ea 30             	sub    $0x30,%edx
f0105785:	eb 22                	jmp    f01057a9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105787:	8d 72 9f             	lea    -0x61(%edx),%esi
f010578a:	89 f3                	mov    %esi,%ebx
f010578c:	80 fb 19             	cmp    $0x19,%bl
f010578f:	77 08                	ja     f0105799 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105791:	0f be d2             	movsbl %dl,%edx
f0105794:	83 ea 57             	sub    $0x57,%edx
f0105797:	eb 10                	jmp    f01057a9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105799:	8d 72 bf             	lea    -0x41(%edx),%esi
f010579c:	89 f3                	mov    %esi,%ebx
f010579e:	80 fb 19             	cmp    $0x19,%bl
f01057a1:	77 16                	ja     f01057b9 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01057a3:	0f be d2             	movsbl %dl,%edx
f01057a6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01057a9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01057ac:	7d 0b                	jge    f01057b9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01057ae:	83 c1 01             	add    $0x1,%ecx
f01057b1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057b5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01057b7:	eb b9                	jmp    f0105772 <strtol+0x76>

	if (endptr)
f01057b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057bd:	74 0d                	je     f01057cc <strtol+0xd0>
		*endptr = (char *) s;
f01057bf:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057c2:	89 0e                	mov    %ecx,(%esi)
f01057c4:	eb 06                	jmp    f01057cc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01057c6:	85 db                	test   %ebx,%ebx
f01057c8:	74 98                	je     f0105762 <strtol+0x66>
f01057ca:	eb 9e                	jmp    f010576a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01057cc:	89 c2                	mov    %eax,%edx
f01057ce:	f7 da                	neg    %edx
f01057d0:	85 ff                	test   %edi,%edi
f01057d2:	0f 45 c2             	cmovne %edx,%eax
}
f01057d5:	5b                   	pop    %ebx
f01057d6:	5e                   	pop    %esi
f01057d7:	5f                   	pop    %edi
f01057d8:	5d                   	pop    %ebp
f01057d9:	c3                   	ret    
f01057da:	66 90                	xchg   %ax,%ax

f01057dc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01057dc:	fa                   	cli    

	xorw    %ax, %ax
f01057dd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01057df:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01057e1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01057e3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01057e5:	0f 01 16             	lgdtl  (%esi)
f01057e8:	74 70                	je     f010585a <mpsearch1+0x3>
	movl    %cr0, %eax
f01057ea:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01057ed:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01057f1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01057f4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01057fa:	08 00                	or     %al,(%eax)

f01057fc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01057fc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105800:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105802:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105804:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105806:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010580a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010580c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010580e:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105813:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105816:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105819:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010581e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105821:	8b 25 84 8e 20 f0    	mov    0xf0208e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105827:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010582c:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105831:	ff d0                	call   *%eax

f0105833 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105833:	eb fe                	jmp    f0105833 <spin>
f0105835:	8d 76 00             	lea    0x0(%esi),%esi

f0105838 <gdt>:
	...
f0105840:	ff                   	(bad)  
f0105841:	ff 00                	incl   (%eax)
f0105843:	00 00                	add    %al,(%eax)
f0105845:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010584c:	00                   	.byte 0x0
f010584d:	92                   	xchg   %eax,%edx
f010584e:	cf                   	iret   
	...

f0105850 <gdtdesc>:
f0105850:	17                   	pop    %ss
f0105851:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105856 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105856:	90                   	nop

f0105857 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105857:	55                   	push   %ebp
f0105858:	89 e5                	mov    %esp,%ebp
f010585a:	57                   	push   %edi
f010585b:	56                   	push   %esi
f010585c:	53                   	push   %ebx
f010585d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105860:	8b 0d 88 8e 20 f0    	mov    0xf0208e88,%ecx
f0105866:	89 c3                	mov    %eax,%ebx
f0105868:	c1 eb 0c             	shr    $0xc,%ebx
f010586b:	39 cb                	cmp    %ecx,%ebx
f010586d:	72 12                	jb     f0105881 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010586f:	50                   	push   %eax
f0105870:	68 c4 62 10 f0       	push   $0xf01062c4
f0105875:	6a 57                	push   $0x57
f0105877:	68 5d 80 10 f0       	push   $0xf010805d
f010587c:	e8 bf a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105881:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105887:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105889:	89 c2                	mov    %eax,%edx
f010588b:	c1 ea 0c             	shr    $0xc,%edx
f010588e:	39 ca                	cmp    %ecx,%edx
f0105890:	72 12                	jb     f01058a4 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105892:	50                   	push   %eax
f0105893:	68 c4 62 10 f0       	push   $0xf01062c4
f0105898:	6a 57                	push   $0x57
f010589a:	68 5d 80 10 f0       	push   $0xf010805d
f010589f:	e8 9c a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01058a4:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01058aa:	eb 2f                	jmp    f01058db <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058ac:	83 ec 04             	sub    $0x4,%esp
f01058af:	6a 04                	push   $0x4
f01058b1:	68 6d 80 10 f0       	push   $0xf010806d
f01058b6:	53                   	push   %ebx
f01058b7:	e8 e4 fd ff ff       	call   f01056a0 <memcmp>
f01058bc:	83 c4 10             	add    $0x10,%esp
f01058bf:	85 c0                	test   %eax,%eax
f01058c1:	75 15                	jne    f01058d8 <mpsearch1+0x81>
f01058c3:	89 da                	mov    %ebx,%edx
f01058c5:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01058c8:	0f b6 0a             	movzbl (%edx),%ecx
f01058cb:	01 c8                	add    %ecx,%eax
f01058cd:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058d0:	39 d7                	cmp    %edx,%edi
f01058d2:	75 f4                	jne    f01058c8 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058d4:	84 c0                	test   %al,%al
f01058d6:	74 0e                	je     f01058e6 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01058d8:	83 c3 10             	add    $0x10,%ebx
f01058db:	39 f3                	cmp    %esi,%ebx
f01058dd:	72 cd                	jb     f01058ac <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01058df:	b8 00 00 00 00       	mov    $0x0,%eax
f01058e4:	eb 02                	jmp    f01058e8 <mpsearch1+0x91>
f01058e6:	89 d8                	mov    %ebx,%eax
}
f01058e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058eb:	5b                   	pop    %ebx
f01058ec:	5e                   	pop    %esi
f01058ed:	5f                   	pop    %edi
f01058ee:	5d                   	pop    %ebp
f01058ef:	c3                   	ret    

f01058f0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01058f0:	55                   	push   %ebp
f01058f1:	89 e5                	mov    %esp,%ebp
f01058f3:	57                   	push   %edi
f01058f4:	56                   	push   %esi
f01058f5:	53                   	push   %ebx
f01058f6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01058f9:	c7 05 c0 93 20 f0 20 	movl   $0xf0209020,0xf02093c0
f0105900:	90 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105903:	83 3d 88 8e 20 f0 00 	cmpl   $0x0,0xf0208e88
f010590a:	75 16                	jne    f0105922 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010590c:	68 00 04 00 00       	push   $0x400
f0105911:	68 c4 62 10 f0       	push   $0xf01062c4
f0105916:	6a 6f                	push   $0x6f
f0105918:	68 5d 80 10 f0       	push   $0xf010805d
f010591d:	e8 1e a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105922:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105929:	85 c0                	test   %eax,%eax
f010592b:	74 16                	je     f0105943 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f010592d:	c1 e0 04             	shl    $0x4,%eax
f0105930:	ba 00 04 00 00       	mov    $0x400,%edx
f0105935:	e8 1d ff ff ff       	call   f0105857 <mpsearch1>
f010593a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010593d:	85 c0                	test   %eax,%eax
f010593f:	75 3c                	jne    f010597d <mp_init+0x8d>
f0105941:	eb 20                	jmp    f0105963 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105943:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010594a:	c1 e0 0a             	shl    $0xa,%eax
f010594d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105952:	ba 00 04 00 00       	mov    $0x400,%edx
f0105957:	e8 fb fe ff ff       	call   f0105857 <mpsearch1>
f010595c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010595f:	85 c0                	test   %eax,%eax
f0105961:	75 1a                	jne    f010597d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105963:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105968:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010596d:	e8 e5 fe ff ff       	call   f0105857 <mpsearch1>
f0105972:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105975:	85 c0                	test   %eax,%eax
f0105977:	0f 84 5d 02 00 00    	je     f0105bda <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010597d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105980:	8b 70 04             	mov    0x4(%eax),%esi
f0105983:	85 f6                	test   %esi,%esi
f0105985:	74 06                	je     f010598d <mp_init+0x9d>
f0105987:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010598b:	74 15                	je     f01059a2 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010598d:	83 ec 0c             	sub    $0xc,%esp
f0105990:	68 d0 7e 10 f0       	push   $0xf0107ed0
f0105995:	e8 6c de ff ff       	call   f0103806 <cprintf>
f010599a:	83 c4 10             	add    $0x10,%esp
f010599d:	e9 38 02 00 00       	jmp    f0105bda <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059a2:	89 f0                	mov    %esi,%eax
f01059a4:	c1 e8 0c             	shr    $0xc,%eax
f01059a7:	3b 05 88 8e 20 f0    	cmp    0xf0208e88,%eax
f01059ad:	72 15                	jb     f01059c4 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059af:	56                   	push   %esi
f01059b0:	68 c4 62 10 f0       	push   $0xf01062c4
f01059b5:	68 90 00 00 00       	push   $0x90
f01059ba:	68 5d 80 10 f0       	push   $0xf010805d
f01059bf:	e8 7c a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059c4:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059ca:	83 ec 04             	sub    $0x4,%esp
f01059cd:	6a 04                	push   $0x4
f01059cf:	68 72 80 10 f0       	push   $0xf0108072
f01059d4:	53                   	push   %ebx
f01059d5:	e8 c6 fc ff ff       	call   f01056a0 <memcmp>
f01059da:	83 c4 10             	add    $0x10,%esp
f01059dd:	85 c0                	test   %eax,%eax
f01059df:	74 15                	je     f01059f6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01059e1:	83 ec 0c             	sub    $0xc,%esp
f01059e4:	68 00 7f 10 f0       	push   $0xf0107f00
f01059e9:	e8 18 de ff ff       	call   f0103806 <cprintf>
f01059ee:	83 c4 10             	add    $0x10,%esp
f01059f1:	e9 e4 01 00 00       	jmp    f0105bda <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01059f6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01059fa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01059fe:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a01:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a06:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a0b:	eb 0d                	jmp    f0105a1a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105a0d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a14:	f0 
f0105a15:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a17:	83 c0 01             	add    $0x1,%eax
f0105a1a:	39 c7                	cmp    %eax,%edi
f0105a1c:	75 ef                	jne    f0105a0d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a1e:	84 d2                	test   %dl,%dl
f0105a20:	74 15                	je     f0105a37 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a22:	83 ec 0c             	sub    $0xc,%esp
f0105a25:	68 34 7f 10 f0       	push   $0xf0107f34
f0105a2a:	e8 d7 dd ff ff       	call   f0103806 <cprintf>
f0105a2f:	83 c4 10             	add    $0x10,%esp
f0105a32:	e9 a3 01 00 00       	jmp    f0105bda <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a37:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a3b:	3c 01                	cmp    $0x1,%al
f0105a3d:	74 1d                	je     f0105a5c <mp_init+0x16c>
f0105a3f:	3c 04                	cmp    $0x4,%al
f0105a41:	74 19                	je     f0105a5c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a43:	83 ec 08             	sub    $0x8,%esp
f0105a46:	0f b6 c0             	movzbl %al,%eax
f0105a49:	50                   	push   %eax
f0105a4a:	68 58 7f 10 f0       	push   $0xf0107f58
f0105a4f:	e8 b2 dd ff ff       	call   f0103806 <cprintf>
f0105a54:	83 c4 10             	add    $0x10,%esp
f0105a57:	e9 7e 01 00 00       	jmp    f0105bda <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a5c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a60:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a64:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a69:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a6e:	01 ce                	add    %ecx,%esi
f0105a70:	eb 0d                	jmp    f0105a7f <mp_init+0x18f>
f0105a72:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105a79:	f0 
f0105a7a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a7c:	83 c0 01             	add    $0x1,%eax
f0105a7f:	39 c7                	cmp    %eax,%edi
f0105a81:	75 ef                	jne    f0105a72 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a83:	89 d0                	mov    %edx,%eax
f0105a85:	02 43 2a             	add    0x2a(%ebx),%al
f0105a88:	74 15                	je     f0105a9f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a8a:	83 ec 0c             	sub    $0xc,%esp
f0105a8d:	68 78 7f 10 f0       	push   $0xf0107f78
f0105a92:	e8 6f dd ff ff       	call   f0103806 <cprintf>
f0105a97:	83 c4 10             	add    $0x10,%esp
f0105a9a:	e9 3b 01 00 00       	jmp    f0105bda <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a9f:	85 db                	test   %ebx,%ebx
f0105aa1:	0f 84 33 01 00 00    	je     f0105bda <mp_init+0x2ea>
		return;
	ismp = 1;
f0105aa7:	c7 05 00 90 20 f0 01 	movl   $0x1,0xf0209000
f0105aae:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ab1:	8b 43 24             	mov    0x24(%ebx),%eax
f0105ab4:	a3 00 a0 24 f0       	mov    %eax,0xf024a000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ab9:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105abc:	be 00 00 00 00       	mov    $0x0,%esi
f0105ac1:	e9 85 00 00 00       	jmp    f0105b4b <mp_init+0x25b>
		switch (*p) {
f0105ac6:	0f b6 07             	movzbl (%edi),%eax
f0105ac9:	84 c0                	test   %al,%al
f0105acb:	74 06                	je     f0105ad3 <mp_init+0x1e3>
f0105acd:	3c 04                	cmp    $0x4,%al
f0105acf:	77 55                	ja     f0105b26 <mp_init+0x236>
f0105ad1:	eb 4e                	jmp    f0105b21 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105ad3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105ad7:	74 11                	je     f0105aea <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105ad9:	6b 05 c4 93 20 f0 74 	imul   $0x74,0xf02093c4,%eax
f0105ae0:	05 20 90 20 f0       	add    $0xf0209020,%eax
f0105ae5:	a3 c0 93 20 f0       	mov    %eax,0xf02093c0
			if (ncpu < NCPU) {
f0105aea:	a1 c4 93 20 f0       	mov    0xf02093c4,%eax
f0105aef:	83 f8 07             	cmp    $0x7,%eax
f0105af2:	7f 13                	jg     f0105b07 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105af4:	6b d0 74             	imul   $0x74,%eax,%edx
f0105af7:	88 82 20 90 20 f0    	mov    %al,-0xfdf6fe0(%edx)
				ncpu++;
f0105afd:	83 c0 01             	add    $0x1,%eax
f0105b00:	a3 c4 93 20 f0       	mov    %eax,0xf02093c4
f0105b05:	eb 15                	jmp    f0105b1c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105b07:	83 ec 08             	sub    $0x8,%esp
f0105b0a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b0e:	50                   	push   %eax
f0105b0f:	68 a8 7f 10 f0       	push   $0xf0107fa8
f0105b14:	e8 ed dc ff ff       	call   f0103806 <cprintf>
f0105b19:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b1c:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b1f:	eb 27                	jmp    f0105b48 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b21:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b24:	eb 22                	jmp    f0105b48 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b26:	83 ec 08             	sub    $0x8,%esp
f0105b29:	0f b6 c0             	movzbl %al,%eax
f0105b2c:	50                   	push   %eax
f0105b2d:	68 d0 7f 10 f0       	push   $0xf0107fd0
f0105b32:	e8 cf dc ff ff       	call   f0103806 <cprintf>
			ismp = 0;
f0105b37:	c7 05 00 90 20 f0 00 	movl   $0x0,0xf0209000
f0105b3e:	00 00 00 
			i = conf->entry;
f0105b41:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105b45:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b48:	83 c6 01             	add    $0x1,%esi
f0105b4b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b4f:	39 c6                	cmp    %eax,%esi
f0105b51:	0f 82 6f ff ff ff    	jb     f0105ac6 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b57:	a1 c0 93 20 f0       	mov    0xf02093c0,%eax
f0105b5c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b63:	83 3d 00 90 20 f0 00 	cmpl   $0x0,0xf0209000
f0105b6a:	75 26                	jne    f0105b92 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b6c:	c7 05 c4 93 20 f0 01 	movl   $0x1,0xf02093c4
f0105b73:	00 00 00 
		lapicaddr = 0;
f0105b76:	c7 05 00 a0 24 f0 00 	movl   $0x0,0xf024a000
f0105b7d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b80:	83 ec 0c             	sub    $0xc,%esp
f0105b83:	68 f0 7f 10 f0       	push   $0xf0107ff0
f0105b88:	e8 79 dc ff ff       	call   f0103806 <cprintf>
		return;
f0105b8d:	83 c4 10             	add    $0x10,%esp
f0105b90:	eb 48                	jmp    f0105bda <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b92:	83 ec 04             	sub    $0x4,%esp
f0105b95:	ff 35 c4 93 20 f0    	pushl  0xf02093c4
f0105b9b:	0f b6 00             	movzbl (%eax),%eax
f0105b9e:	50                   	push   %eax
f0105b9f:	68 77 80 10 f0       	push   $0xf0108077
f0105ba4:	e8 5d dc ff ff       	call   f0103806 <cprintf>

	if (mp->imcrp) {
f0105ba9:	83 c4 10             	add    $0x10,%esp
f0105bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105baf:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105bb3:	74 25                	je     f0105bda <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105bb5:	83 ec 0c             	sub    $0xc,%esp
f0105bb8:	68 1c 80 10 f0       	push   $0xf010801c
f0105bbd:	e8 44 dc ff ff       	call   f0103806 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bc2:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bc7:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bcc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bcd:	ba 23 00 00 00       	mov    $0x23,%edx
f0105bd2:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bd3:	83 c8 01             	or     $0x1,%eax
f0105bd6:	ee                   	out    %al,(%dx)
f0105bd7:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bdd:	5b                   	pop    %ebx
f0105bde:	5e                   	pop    %esi
f0105bdf:	5f                   	pop    %edi
f0105be0:	5d                   	pop    %ebp
f0105be1:	c3                   	ret    

f0105be2 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105be2:	55                   	push   %ebp
f0105be3:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105be5:	8b 0d 04 a0 24 f0    	mov    0xf024a004,%ecx
f0105beb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105bee:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105bf0:	a1 04 a0 24 f0       	mov    0xf024a004,%eax
f0105bf5:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105bf8:	5d                   	pop    %ebp
f0105bf9:	c3                   	ret    

f0105bfa <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105bfa:	55                   	push   %ebp
f0105bfb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105bfd:	a1 04 a0 24 f0       	mov    0xf024a004,%eax
f0105c02:	85 c0                	test   %eax,%eax
f0105c04:	74 08                	je     f0105c0e <cpunum+0x14>
		return lapic[ID] >> 24;
f0105c06:	8b 40 20             	mov    0x20(%eax),%eax
f0105c09:	c1 e8 18             	shr    $0x18,%eax
f0105c0c:	eb 05                	jmp    f0105c13 <cpunum+0x19>
	return 0;
f0105c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c13:	5d                   	pop    %ebp
f0105c14:	c3                   	ret    

f0105c15 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c15:	a1 00 a0 24 f0       	mov    0xf024a000,%eax
f0105c1a:	85 c0                	test   %eax,%eax
f0105c1c:	0f 84 21 01 00 00    	je     f0105d43 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c22:	55                   	push   %ebp
f0105c23:	89 e5                	mov    %esp,%ebp
f0105c25:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c28:	68 00 10 00 00       	push   $0x1000
f0105c2d:	50                   	push   %eax
f0105c2e:	e8 ca b7 ff ff       	call   f01013fd <mmio_map_region>
f0105c33:	a3 04 a0 24 f0       	mov    %eax,0xf024a004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c38:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c3d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c42:	e8 9b ff ff ff       	call   f0105be2 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c47:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c4c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c51:	e8 8c ff ff ff       	call   f0105be2 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c56:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c5b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c60:	e8 7d ff ff ff       	call   f0105be2 <lapicw>
	lapicw(TICR, 10000000); 
f0105c65:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c6a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c6f:	e8 6e ff ff ff       	call   f0105be2 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c74:	e8 81 ff ff ff       	call   f0105bfa <cpunum>
f0105c79:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c7c:	05 20 90 20 f0       	add    $0xf0209020,%eax
f0105c81:	83 c4 10             	add    $0x10,%esp
f0105c84:	39 05 c0 93 20 f0    	cmp    %eax,0xf02093c0
f0105c8a:	74 0f                	je     f0105c9b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c8c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c91:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c96:	e8 47 ff ff ff       	call   f0105be2 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c9b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ca0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ca5:	e8 38 ff ff ff       	call   f0105be2 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105caa:	a1 04 a0 24 f0       	mov    0xf024a004,%eax
f0105caf:	8b 40 30             	mov    0x30(%eax),%eax
f0105cb2:	c1 e8 10             	shr    $0x10,%eax
f0105cb5:	3c 03                	cmp    $0x3,%al
f0105cb7:	76 0f                	jbe    f0105cc8 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105cb9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cbe:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105cc3:	e8 1a ff ff ff       	call   f0105be2 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cc8:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ccd:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cd2:	e8 0b ff ff ff       	call   f0105be2 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105cd7:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cdc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ce1:	e8 fc fe ff ff       	call   f0105be2 <lapicw>
	lapicw(ESR, 0);
f0105ce6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ceb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105cf0:	e8 ed fe ff ff       	call   f0105be2 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105cf5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cfa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cff:	e8 de fe ff ff       	call   f0105be2 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105d04:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d09:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d0e:	e8 cf fe ff ff       	call   f0105be2 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d13:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d18:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d1d:	e8 c0 fe ff ff       	call   f0105be2 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d22:	8b 15 04 a0 24 f0    	mov    0xf024a004,%edx
f0105d28:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d2e:	f6 c4 10             	test   $0x10,%ah
f0105d31:	75 f5                	jne    f0105d28 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d33:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d38:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d3d:	e8 a0 fe ff ff       	call   f0105be2 <lapicw>
}
f0105d42:	c9                   	leave  
f0105d43:	f3 c3                	repz ret 

f0105d45 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d45:	83 3d 04 a0 24 f0 00 	cmpl   $0x0,0xf024a004
f0105d4c:	74 13                	je     f0105d61 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d4e:	55                   	push   %ebp
f0105d4f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d51:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d56:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d5b:	e8 82 fe ff ff       	call   f0105be2 <lapicw>
}
f0105d60:	5d                   	pop    %ebp
f0105d61:	f3 c3                	repz ret 

f0105d63 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d63:	55                   	push   %ebp
f0105d64:	89 e5                	mov    %esp,%ebp
f0105d66:	56                   	push   %esi
f0105d67:	53                   	push   %ebx
f0105d68:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d6e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d73:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105d78:	ee                   	out    %al,(%dx)
f0105d79:	ba 71 00 00 00       	mov    $0x71,%edx
f0105d7e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d83:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d84:	83 3d 88 8e 20 f0 00 	cmpl   $0x0,0xf0208e88
f0105d8b:	75 19                	jne    f0105da6 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d8d:	68 67 04 00 00       	push   $0x467
f0105d92:	68 c4 62 10 f0       	push   $0xf01062c4
f0105d97:	68 98 00 00 00       	push   $0x98
f0105d9c:	68 94 80 10 f0       	push   $0xf0108094
f0105da1:	e8 9a a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105da6:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105dad:	00 00 
	wrv[1] = addr >> 4;
f0105daf:	89 d8                	mov    %ebx,%eax
f0105db1:	c1 e8 04             	shr    $0x4,%eax
f0105db4:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105dba:	c1 e6 18             	shl    $0x18,%esi
f0105dbd:	89 f2                	mov    %esi,%edx
f0105dbf:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dc4:	e8 19 fe ff ff       	call   f0105be2 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105dc9:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105dce:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dd3:	e8 0a fe ff ff       	call   f0105be2 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105dd8:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105ddd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105de2:	e8 fb fd ff ff       	call   f0105be2 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105de7:	c1 eb 0c             	shr    $0xc,%ebx
f0105dea:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ded:	89 f2                	mov    %esi,%edx
f0105def:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105df4:	e8 e9 fd ff ff       	call   f0105be2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105df9:	89 da                	mov    %ebx,%edx
f0105dfb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e00:	e8 dd fd ff ff       	call   f0105be2 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e05:	89 f2                	mov    %esi,%edx
f0105e07:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e0c:	e8 d1 fd ff ff       	call   f0105be2 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e11:	89 da                	mov    %ebx,%edx
f0105e13:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e18:	e8 c5 fd ff ff       	call   f0105be2 <lapicw>
		microdelay(200);
	}
}
f0105e1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e20:	5b                   	pop    %ebx
f0105e21:	5e                   	pop    %esi
f0105e22:	5d                   	pop    %ebp
f0105e23:	c3                   	ret    

f0105e24 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e24:	55                   	push   %ebp
f0105e25:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e27:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e2a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e30:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e35:	e8 a8 fd ff ff       	call   f0105be2 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e3a:	8b 15 04 a0 24 f0    	mov    0xf024a004,%edx
f0105e40:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e46:	f6 c4 10             	test   $0x10,%ah
f0105e49:	75 f5                	jne    f0105e40 <lapic_ipi+0x1c>
		;
}
f0105e4b:	5d                   	pop    %ebp
f0105e4c:	c3                   	ret    

f0105e4d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e4d:	55                   	push   %ebp
f0105e4e:	89 e5                	mov    %esp,%ebp
f0105e50:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e59:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e5c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e66:	5d                   	pop    %ebp
f0105e67:	c3                   	ret    

f0105e68 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e68:	55                   	push   %ebp
f0105e69:	89 e5                	mov    %esp,%ebp
f0105e6b:	56                   	push   %esi
f0105e6c:	53                   	push   %ebx
f0105e6d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e70:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e73:	74 14                	je     f0105e89 <spin_lock+0x21>
f0105e75:	8b 73 08             	mov    0x8(%ebx),%esi
f0105e78:	e8 7d fd ff ff       	call   f0105bfa <cpunum>
f0105e7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e80:	05 20 90 20 f0       	add    $0xf0209020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e85:	39 c6                	cmp    %eax,%esi
f0105e87:	74 07                	je     f0105e90 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105e89:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e8e:	eb 20                	jmp    f0105eb0 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e90:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e93:	e8 62 fd ff ff       	call   f0105bfa <cpunum>
f0105e98:	83 ec 0c             	sub    $0xc,%esp
f0105e9b:	53                   	push   %ebx
f0105e9c:	50                   	push   %eax
f0105e9d:	68 a4 80 10 f0       	push   $0xf01080a4
f0105ea2:	6a 41                	push   $0x41
f0105ea4:	68 08 81 10 f0       	push   $0xf0108108
f0105ea9:	e8 92 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105eae:	f3 90                	pause  
f0105eb0:	89 d0                	mov    %edx,%eax
f0105eb2:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105eb5:	85 c0                	test   %eax,%eax
f0105eb7:	75 f5                	jne    f0105eae <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105eb9:	e8 3c fd ff ff       	call   f0105bfa <cpunum>
f0105ebe:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ec1:	05 20 90 20 f0       	add    $0xf0209020,%eax
f0105ec6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105ec9:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105ecc:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ece:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ed3:	eb 0b                	jmp    f0105ee0 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105ed5:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ed8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105edb:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105edd:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ee0:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105ee6:	76 11                	jbe    f0105ef9 <spin_lock+0x91>
f0105ee8:	83 f8 09             	cmp    $0x9,%eax
f0105eeb:	7e e8                	jle    f0105ed5 <spin_lock+0x6d>
f0105eed:	eb 0a                	jmp    f0105ef9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105eef:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105ef6:	83 c0 01             	add    $0x1,%eax
f0105ef9:	83 f8 09             	cmp    $0x9,%eax
f0105efc:	7e f1                	jle    f0105eef <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105efe:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f01:	5b                   	pop    %ebx
f0105f02:	5e                   	pop    %esi
f0105f03:	5d                   	pop    %ebp
f0105f04:	c3                   	ret    

f0105f05 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105f05:	55                   	push   %ebp
f0105f06:	89 e5                	mov    %esp,%ebp
f0105f08:	57                   	push   %edi
f0105f09:	56                   	push   %esi
f0105f0a:	53                   	push   %ebx
f0105f0b:	83 ec 4c             	sub    $0x4c,%esp
f0105f0e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f11:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f14:	74 18                	je     f0105f2e <spin_unlock+0x29>
f0105f16:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f19:	e8 dc fc ff ff       	call   f0105bfa <cpunum>
f0105f1e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f21:	05 20 90 20 f0       	add    $0xf0209020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f26:	39 c3                	cmp    %eax,%ebx
f0105f28:	0f 84 a5 00 00 00    	je     f0105fd3 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f2e:	83 ec 04             	sub    $0x4,%esp
f0105f31:	6a 28                	push   $0x28
f0105f33:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f36:	50                   	push   %eax
f0105f37:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f3a:	53                   	push   %ebx
f0105f3b:	e8 e5 f6 ff ff       	call   f0105625 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f40:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f43:	0f b6 38             	movzbl (%eax),%edi
f0105f46:	8b 76 04             	mov    0x4(%esi),%esi
f0105f49:	e8 ac fc ff ff       	call   f0105bfa <cpunum>
f0105f4e:	57                   	push   %edi
f0105f4f:	56                   	push   %esi
f0105f50:	50                   	push   %eax
f0105f51:	68 d0 80 10 f0       	push   $0xf01080d0
f0105f56:	e8 ab d8 ff ff       	call   f0103806 <cprintf>
f0105f5b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f5e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f61:	eb 54                	jmp    f0105fb7 <spin_unlock+0xb2>
f0105f63:	83 ec 08             	sub    $0x8,%esp
f0105f66:	57                   	push   %edi
f0105f67:	50                   	push   %eax
f0105f68:	e8 e1 eb ff ff       	call   f0104b4e <debuginfo_eip>
f0105f6d:	83 c4 10             	add    $0x10,%esp
f0105f70:	85 c0                	test   %eax,%eax
f0105f72:	78 27                	js     f0105f9b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105f74:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105f76:	83 ec 04             	sub    $0x4,%esp
f0105f79:	89 c2                	mov    %eax,%edx
f0105f7b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f7e:	52                   	push   %edx
f0105f7f:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f82:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f85:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f88:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f8b:	50                   	push   %eax
f0105f8c:	68 18 81 10 f0       	push   $0xf0108118
f0105f91:	e8 70 d8 ff ff       	call   f0103806 <cprintf>
f0105f96:	83 c4 20             	add    $0x20,%esp
f0105f99:	eb 12                	jmp    f0105fad <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f9b:	83 ec 08             	sub    $0x8,%esp
f0105f9e:	ff 36                	pushl  (%esi)
f0105fa0:	68 2f 81 10 f0       	push   $0xf010812f
f0105fa5:	e8 5c d8 ff ff       	call   f0103806 <cprintf>
f0105faa:	83 c4 10             	add    $0x10,%esp
f0105fad:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105fb0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105fb3:	39 c3                	cmp    %eax,%ebx
f0105fb5:	74 08                	je     f0105fbf <spin_unlock+0xba>
f0105fb7:	89 de                	mov    %ebx,%esi
f0105fb9:	8b 03                	mov    (%ebx),%eax
f0105fbb:	85 c0                	test   %eax,%eax
f0105fbd:	75 a4                	jne    f0105f63 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105fbf:	83 ec 04             	sub    $0x4,%esp
f0105fc2:	68 37 81 10 f0       	push   $0xf0108137
f0105fc7:	6a 67                	push   $0x67
f0105fc9:	68 08 81 10 f0       	push   $0xf0108108
f0105fce:	e8 6d a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105fd3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105fda:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105fe1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fe6:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105fe9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fec:	5b                   	pop    %ebx
f0105fed:	5e                   	pop    %esi
f0105fee:	5f                   	pop    %edi
f0105fef:	5d                   	pop    %ebp
f0105ff0:	c3                   	ret    
f0105ff1:	66 90                	xchg   %ax,%ax
f0105ff3:	66 90                	xchg   %ax,%ax
f0105ff5:	66 90                	xchg   %ax,%ax
f0105ff7:	66 90                	xchg   %ax,%ax
f0105ff9:	66 90                	xchg   %ax,%ax
f0105ffb:	66 90                	xchg   %ax,%ax
f0105ffd:	66 90                	xchg   %ax,%ax
f0105fff:	90                   	nop

f0106000 <__udivdi3>:
f0106000:	55                   	push   %ebp
f0106001:	57                   	push   %edi
f0106002:	56                   	push   %esi
f0106003:	53                   	push   %ebx
f0106004:	83 ec 1c             	sub    $0x1c,%esp
f0106007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010600b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010600f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106013:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106017:	85 f6                	test   %esi,%esi
f0106019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010601d:	89 ca                	mov    %ecx,%edx
f010601f:	89 f8                	mov    %edi,%eax
f0106021:	75 3d                	jne    f0106060 <__udivdi3+0x60>
f0106023:	39 cf                	cmp    %ecx,%edi
f0106025:	0f 87 c5 00 00 00    	ja     f01060f0 <__udivdi3+0xf0>
f010602b:	85 ff                	test   %edi,%edi
f010602d:	89 fd                	mov    %edi,%ebp
f010602f:	75 0b                	jne    f010603c <__udivdi3+0x3c>
f0106031:	b8 01 00 00 00       	mov    $0x1,%eax
f0106036:	31 d2                	xor    %edx,%edx
f0106038:	f7 f7                	div    %edi
f010603a:	89 c5                	mov    %eax,%ebp
f010603c:	89 c8                	mov    %ecx,%eax
f010603e:	31 d2                	xor    %edx,%edx
f0106040:	f7 f5                	div    %ebp
f0106042:	89 c1                	mov    %eax,%ecx
f0106044:	89 d8                	mov    %ebx,%eax
f0106046:	89 cf                	mov    %ecx,%edi
f0106048:	f7 f5                	div    %ebp
f010604a:	89 c3                	mov    %eax,%ebx
f010604c:	89 d8                	mov    %ebx,%eax
f010604e:	89 fa                	mov    %edi,%edx
f0106050:	83 c4 1c             	add    $0x1c,%esp
f0106053:	5b                   	pop    %ebx
f0106054:	5e                   	pop    %esi
f0106055:	5f                   	pop    %edi
f0106056:	5d                   	pop    %ebp
f0106057:	c3                   	ret    
f0106058:	90                   	nop
f0106059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106060:	39 ce                	cmp    %ecx,%esi
f0106062:	77 74                	ja     f01060d8 <__udivdi3+0xd8>
f0106064:	0f bd fe             	bsr    %esi,%edi
f0106067:	83 f7 1f             	xor    $0x1f,%edi
f010606a:	0f 84 98 00 00 00    	je     f0106108 <__udivdi3+0x108>
f0106070:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106075:	89 f9                	mov    %edi,%ecx
f0106077:	89 c5                	mov    %eax,%ebp
f0106079:	29 fb                	sub    %edi,%ebx
f010607b:	d3 e6                	shl    %cl,%esi
f010607d:	89 d9                	mov    %ebx,%ecx
f010607f:	d3 ed                	shr    %cl,%ebp
f0106081:	89 f9                	mov    %edi,%ecx
f0106083:	d3 e0                	shl    %cl,%eax
f0106085:	09 ee                	or     %ebp,%esi
f0106087:	89 d9                	mov    %ebx,%ecx
f0106089:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010608d:	89 d5                	mov    %edx,%ebp
f010608f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106093:	d3 ed                	shr    %cl,%ebp
f0106095:	89 f9                	mov    %edi,%ecx
f0106097:	d3 e2                	shl    %cl,%edx
f0106099:	89 d9                	mov    %ebx,%ecx
f010609b:	d3 e8                	shr    %cl,%eax
f010609d:	09 c2                	or     %eax,%edx
f010609f:	89 d0                	mov    %edx,%eax
f01060a1:	89 ea                	mov    %ebp,%edx
f01060a3:	f7 f6                	div    %esi
f01060a5:	89 d5                	mov    %edx,%ebp
f01060a7:	89 c3                	mov    %eax,%ebx
f01060a9:	f7 64 24 0c          	mull   0xc(%esp)
f01060ad:	39 d5                	cmp    %edx,%ebp
f01060af:	72 10                	jb     f01060c1 <__udivdi3+0xc1>
f01060b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01060b5:	89 f9                	mov    %edi,%ecx
f01060b7:	d3 e6                	shl    %cl,%esi
f01060b9:	39 c6                	cmp    %eax,%esi
f01060bb:	73 07                	jae    f01060c4 <__udivdi3+0xc4>
f01060bd:	39 d5                	cmp    %edx,%ebp
f01060bf:	75 03                	jne    f01060c4 <__udivdi3+0xc4>
f01060c1:	83 eb 01             	sub    $0x1,%ebx
f01060c4:	31 ff                	xor    %edi,%edi
f01060c6:	89 d8                	mov    %ebx,%eax
f01060c8:	89 fa                	mov    %edi,%edx
f01060ca:	83 c4 1c             	add    $0x1c,%esp
f01060cd:	5b                   	pop    %ebx
f01060ce:	5e                   	pop    %esi
f01060cf:	5f                   	pop    %edi
f01060d0:	5d                   	pop    %ebp
f01060d1:	c3                   	ret    
f01060d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060d8:	31 ff                	xor    %edi,%edi
f01060da:	31 db                	xor    %ebx,%ebx
f01060dc:	89 d8                	mov    %ebx,%eax
f01060de:	89 fa                	mov    %edi,%edx
f01060e0:	83 c4 1c             	add    $0x1c,%esp
f01060e3:	5b                   	pop    %ebx
f01060e4:	5e                   	pop    %esi
f01060e5:	5f                   	pop    %edi
f01060e6:	5d                   	pop    %ebp
f01060e7:	c3                   	ret    
f01060e8:	90                   	nop
f01060e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060f0:	89 d8                	mov    %ebx,%eax
f01060f2:	f7 f7                	div    %edi
f01060f4:	31 ff                	xor    %edi,%edi
f01060f6:	89 c3                	mov    %eax,%ebx
f01060f8:	89 d8                	mov    %ebx,%eax
f01060fa:	89 fa                	mov    %edi,%edx
f01060fc:	83 c4 1c             	add    $0x1c,%esp
f01060ff:	5b                   	pop    %ebx
f0106100:	5e                   	pop    %esi
f0106101:	5f                   	pop    %edi
f0106102:	5d                   	pop    %ebp
f0106103:	c3                   	ret    
f0106104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106108:	39 ce                	cmp    %ecx,%esi
f010610a:	72 0c                	jb     f0106118 <__udivdi3+0x118>
f010610c:	31 db                	xor    %ebx,%ebx
f010610e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106112:	0f 87 34 ff ff ff    	ja     f010604c <__udivdi3+0x4c>
f0106118:	bb 01 00 00 00       	mov    $0x1,%ebx
f010611d:	e9 2a ff ff ff       	jmp    f010604c <__udivdi3+0x4c>
f0106122:	66 90                	xchg   %ax,%ax
f0106124:	66 90                	xchg   %ax,%ax
f0106126:	66 90                	xchg   %ax,%ax
f0106128:	66 90                	xchg   %ax,%ax
f010612a:	66 90                	xchg   %ax,%ax
f010612c:	66 90                	xchg   %ax,%ax
f010612e:	66 90                	xchg   %ax,%ax

f0106130 <__umoddi3>:
f0106130:	55                   	push   %ebp
f0106131:	57                   	push   %edi
f0106132:	56                   	push   %esi
f0106133:	53                   	push   %ebx
f0106134:	83 ec 1c             	sub    $0x1c,%esp
f0106137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010613b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010613f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106143:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106147:	85 d2                	test   %edx,%edx
f0106149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010614d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106151:	89 f3                	mov    %esi,%ebx
f0106153:	89 3c 24             	mov    %edi,(%esp)
f0106156:	89 74 24 04          	mov    %esi,0x4(%esp)
f010615a:	75 1c                	jne    f0106178 <__umoddi3+0x48>
f010615c:	39 f7                	cmp    %esi,%edi
f010615e:	76 50                	jbe    f01061b0 <__umoddi3+0x80>
f0106160:	89 c8                	mov    %ecx,%eax
f0106162:	89 f2                	mov    %esi,%edx
f0106164:	f7 f7                	div    %edi
f0106166:	89 d0                	mov    %edx,%eax
f0106168:	31 d2                	xor    %edx,%edx
f010616a:	83 c4 1c             	add    $0x1c,%esp
f010616d:	5b                   	pop    %ebx
f010616e:	5e                   	pop    %esi
f010616f:	5f                   	pop    %edi
f0106170:	5d                   	pop    %ebp
f0106171:	c3                   	ret    
f0106172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106178:	39 f2                	cmp    %esi,%edx
f010617a:	89 d0                	mov    %edx,%eax
f010617c:	77 52                	ja     f01061d0 <__umoddi3+0xa0>
f010617e:	0f bd ea             	bsr    %edx,%ebp
f0106181:	83 f5 1f             	xor    $0x1f,%ebp
f0106184:	75 5a                	jne    f01061e0 <__umoddi3+0xb0>
f0106186:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010618a:	0f 82 e0 00 00 00    	jb     f0106270 <__umoddi3+0x140>
f0106190:	39 0c 24             	cmp    %ecx,(%esp)
f0106193:	0f 86 d7 00 00 00    	jbe    f0106270 <__umoddi3+0x140>
f0106199:	8b 44 24 08          	mov    0x8(%esp),%eax
f010619d:	8b 54 24 04          	mov    0x4(%esp),%edx
f01061a1:	83 c4 1c             	add    $0x1c,%esp
f01061a4:	5b                   	pop    %ebx
f01061a5:	5e                   	pop    %esi
f01061a6:	5f                   	pop    %edi
f01061a7:	5d                   	pop    %ebp
f01061a8:	c3                   	ret    
f01061a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061b0:	85 ff                	test   %edi,%edi
f01061b2:	89 fd                	mov    %edi,%ebp
f01061b4:	75 0b                	jne    f01061c1 <__umoddi3+0x91>
f01061b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01061bb:	31 d2                	xor    %edx,%edx
f01061bd:	f7 f7                	div    %edi
f01061bf:	89 c5                	mov    %eax,%ebp
f01061c1:	89 f0                	mov    %esi,%eax
f01061c3:	31 d2                	xor    %edx,%edx
f01061c5:	f7 f5                	div    %ebp
f01061c7:	89 c8                	mov    %ecx,%eax
f01061c9:	f7 f5                	div    %ebp
f01061cb:	89 d0                	mov    %edx,%eax
f01061cd:	eb 99                	jmp    f0106168 <__umoddi3+0x38>
f01061cf:	90                   	nop
f01061d0:	89 c8                	mov    %ecx,%eax
f01061d2:	89 f2                	mov    %esi,%edx
f01061d4:	83 c4 1c             	add    $0x1c,%esp
f01061d7:	5b                   	pop    %ebx
f01061d8:	5e                   	pop    %esi
f01061d9:	5f                   	pop    %edi
f01061da:	5d                   	pop    %ebp
f01061db:	c3                   	ret    
f01061dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01061e0:	8b 34 24             	mov    (%esp),%esi
f01061e3:	bf 20 00 00 00       	mov    $0x20,%edi
f01061e8:	89 e9                	mov    %ebp,%ecx
f01061ea:	29 ef                	sub    %ebp,%edi
f01061ec:	d3 e0                	shl    %cl,%eax
f01061ee:	89 f9                	mov    %edi,%ecx
f01061f0:	89 f2                	mov    %esi,%edx
f01061f2:	d3 ea                	shr    %cl,%edx
f01061f4:	89 e9                	mov    %ebp,%ecx
f01061f6:	09 c2                	or     %eax,%edx
f01061f8:	89 d8                	mov    %ebx,%eax
f01061fa:	89 14 24             	mov    %edx,(%esp)
f01061fd:	89 f2                	mov    %esi,%edx
f01061ff:	d3 e2                	shl    %cl,%edx
f0106201:	89 f9                	mov    %edi,%ecx
f0106203:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106207:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010620b:	d3 e8                	shr    %cl,%eax
f010620d:	89 e9                	mov    %ebp,%ecx
f010620f:	89 c6                	mov    %eax,%esi
f0106211:	d3 e3                	shl    %cl,%ebx
f0106213:	89 f9                	mov    %edi,%ecx
f0106215:	89 d0                	mov    %edx,%eax
f0106217:	d3 e8                	shr    %cl,%eax
f0106219:	89 e9                	mov    %ebp,%ecx
f010621b:	09 d8                	or     %ebx,%eax
f010621d:	89 d3                	mov    %edx,%ebx
f010621f:	89 f2                	mov    %esi,%edx
f0106221:	f7 34 24             	divl   (%esp)
f0106224:	89 d6                	mov    %edx,%esi
f0106226:	d3 e3                	shl    %cl,%ebx
f0106228:	f7 64 24 04          	mull   0x4(%esp)
f010622c:	39 d6                	cmp    %edx,%esi
f010622e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106232:	89 d1                	mov    %edx,%ecx
f0106234:	89 c3                	mov    %eax,%ebx
f0106236:	72 08                	jb     f0106240 <__umoddi3+0x110>
f0106238:	75 11                	jne    f010624b <__umoddi3+0x11b>
f010623a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010623e:	73 0b                	jae    f010624b <__umoddi3+0x11b>
f0106240:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106244:	1b 14 24             	sbb    (%esp),%edx
f0106247:	89 d1                	mov    %edx,%ecx
f0106249:	89 c3                	mov    %eax,%ebx
f010624b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010624f:	29 da                	sub    %ebx,%edx
f0106251:	19 ce                	sbb    %ecx,%esi
f0106253:	89 f9                	mov    %edi,%ecx
f0106255:	89 f0                	mov    %esi,%eax
f0106257:	d3 e0                	shl    %cl,%eax
f0106259:	89 e9                	mov    %ebp,%ecx
f010625b:	d3 ea                	shr    %cl,%edx
f010625d:	89 e9                	mov    %ebp,%ecx
f010625f:	d3 ee                	shr    %cl,%esi
f0106261:	09 d0                	or     %edx,%eax
f0106263:	89 f2                	mov    %esi,%edx
f0106265:	83 c4 1c             	add    $0x1c,%esp
f0106268:	5b                   	pop    %ebx
f0106269:	5e                   	pop    %esi
f010626a:	5f                   	pop    %edi
f010626b:	5d                   	pop    %ebp
f010626c:	c3                   	ret    
f010626d:	8d 76 00             	lea    0x0(%esi),%esi
f0106270:	29 f9                	sub    %edi,%ecx
f0106272:	19 d6                	sbb    %edx,%esi
f0106274:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010627c:	e9 18 ff ff ff       	jmp    f0106199 <__umoddi3+0x69>
