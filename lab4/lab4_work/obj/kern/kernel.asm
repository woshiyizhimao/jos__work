
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
f0100048:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 a5 59 00 00       	call   f0105a06 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 60 10 f0       	push   $0xf01060a0
f010006d:	e8 d4 36 00 00       	call   f0103746 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 a4 36 00 00       	call   f0103720 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 3a 69 10 f0 	movl   $0xf010693a,(%esp)
f0100083:	e8 be 36 00 00       	call   f0103746 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 66 08 00 00       	call   f01008fb <monitor>
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
f01000a1:	b8 08 10 27 f0       	mov    $0xf0271008,%eax
f01000a6:	2d 28 ea 22 f0       	sub    $0xf022ea28,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 28 ea 22 f0       	push   $0xf022ea28
f01000b3:	e8 2e 53 00 00       	call   f01053e6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 74 05 00 00       	call   f0100631 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 61 10 f0       	push   $0xf010610c
f01000ca:	e8 77 36 00 00       	call   f0103746 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 ca 11 00 00       	call   f010129e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 54 2e 00 00       	call   f0102f2d <env_init>
	trap_init();
f01000d9:	e8 25 37 00 00       	call   f0103803 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 19 56 00 00       	call   f01056fc <mp_init>
	lapic_init();
f01000e3:	e8 39 59 00 00       	call   f0105a21 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 80 35 00 00       	call   f010366d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 7b 5b 00 00       	call   f0105c74 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 c4 60 10 f0       	push   $0xf01060c4
f010010f:	6a 58                	push   $0x58
f0100111:	68 27 61 10 f0       	push   $0xf0106127
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 62 56 10 f0       	mov    $0xf0105662,%eax
f0100123:	2d e8 55 10 f0       	sub    $0xf01055e8,%eax
f0100128:	50                   	push   %eax
f0100129:	68 e8 55 10 f0       	push   $0xf01055e8
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 fb 52 00 00       	call   f0105433 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 bf 58 00 00       	call   f0105a06 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 00 23 f0       	add    $0xf0230020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 90 23 f0       	add    $0xf0239000,%eax
f010016b:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 ee 59 00 00       	call   f0105b6f <lapic_startap>
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
f010018f:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0100196:	05 20 00 23 f0       	add    $0xf0230020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 bc 4f 22 f0       	push   $0xf0224fbc
f01001a9:	e8 53 2f 00 00       	call   f0103101 <env_create>
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001ae:	e8 da 40 00 00       	call   f010428d <sched_yield>

f01001b3 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 e8 60 10 f0       	push   $0xf01060e8
f01001cb:	6a 6f                	push   $0x6f
f01001cd:	68 27 61 10 f0       	push   $0xf0106127
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 22 58 00 00       	call   f0105a06 <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 33 61 10 f0       	push   $0xf0106133
f01001ed:	e8 54 35 00 00       	call   f0103746 <cprintf>

	lapic_init();
f01001f2:	e8 2a 58 00 00       	call   f0105a21 <lapic_init>
	env_init_percpu();
f01001f7:	e8 01 2d 00 00       	call   f0102efd <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 59 35 00 00       	call   f010375a <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 00 58 00 00       	call   f0105a06 <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021f:	e8 50 5a 00 00       	call   f0105c74 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100224:	e8 64 40 00 00       	call   f010428d <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 49 61 10 f0       	push   $0xf0106149
f010023e:	e8 03 35 00 00       	call   f0103746 <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 d1 34 00 00       	call   f0103720 <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 3a 69 10 f0 	movl   $0xf010693a,(%esp)
f0100256:	e8 eb 34 00 00       	call   f0103746 <cprintf>
	va_end(ap);
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f01002a0:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f0 00 00 00    	je     f01003c3 <kbd_proc_data+0xfe>
f01002d3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002db:	3c e0                	cmp    $0xe0,%al
f01002dd:	75 0d                	jne    f01002ec <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002df:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f01002e6:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002eb:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f3:	84 c0                	test   %al,%al
f01002f5:	79 36                	jns    f010032d <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f7:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f01002fd:	89 cb                	mov    %ecx,%ebx
f01002ff:	83 e3 40             	and    $0x40,%ebx
f0100302:	83 e0 7f             	and    $0x7f,%eax
f0100305:	85 db                	test   %ebx,%ebx
f0100307:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030a:	0f b6 d2             	movzbl %dl,%edx
f010030d:	0f b6 82 c0 62 10 f0 	movzbl -0xfef9d40(%edx),%eax
f0100314:	83 c8 40             	or     $0x40,%eax
f0100317:	0f b6 c0             	movzbl %al,%eax
f010031a:	f7 d0                	not    %eax
f010031c:	21 c8                	and    %ecx,%eax
f010031e:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f0100323:	b8 00 00 00 00       	mov    $0x0,%eax
f0100328:	e9 9e 00 00 00       	jmp    f01003cb <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010032d:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100333:	f6 c1 40             	test   $0x40,%cl
f0100336:	74 0e                	je     f0100346 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100338:	83 c8 80             	or     $0xffffff80,%eax
f010033b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010033d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100340:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f0100346:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100349:	0f b6 82 c0 62 10 f0 	movzbl -0xfef9d40(%edx),%eax
f0100350:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f0100356:	0f b6 8a c0 61 10 f0 	movzbl -0xfef9e40(%edx),%ecx
f010035d:	31 c8                	xor    %ecx,%eax
f010035f:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100364:	89 c1                	mov    %eax,%ecx
f0100366:	83 e1 03             	and    $0x3,%ecx
f0100369:	8b 0c 8d a0 61 10 f0 	mov    -0xfef9e60(,%ecx,4),%ecx
f0100370:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100374:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100377:	a8 08                	test   $0x8,%al
f0100379:	74 1b                	je     f0100396 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010037b:	89 da                	mov    %ebx,%edx
f010037d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100380:	83 f9 19             	cmp    $0x19,%ecx
f0100383:	77 05                	ja     f010038a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100385:	83 eb 20             	sub    $0x20,%ebx
f0100388:	eb 0c                	jmp    f0100396 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010038a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010038d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100390:	83 fa 19             	cmp    $0x19,%edx
f0100393:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100396:	f7 d0                	not    %eax
f0100398:	a8 06                	test   $0x6,%al
f010039a:	75 2d                	jne    f01003c9 <kbd_proc_data+0x104>
f010039c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a2:	75 25                	jne    f01003c9 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003a4:	83 ec 0c             	sub    $0xc,%esp
f01003a7:	68 63 61 10 f0       	push   $0xf0106163
f01003ac:	e8 95 33 00 00       	call   f0103746 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b1:	ba 92 00 00 00       	mov    $0x92,%edx
f01003b6:	b8 03 00 00 00       	mov    $0x3,%eax
f01003bb:	ee                   	out    %al,(%dx)
f01003bc:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003bf:	89 d8                	mov    %ebx,%eax
f01003c1:	eb 08                	jmp    f01003cb <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003c8:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c9:	89 d8                	mov    %ebx,%eax
}
f01003cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003ce:	c9                   	leave  
f01003cf:	c3                   	ret    

f01003d0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d0:	55                   	push   %ebp
f01003d1:	89 e5                	mov    %esp,%ebp
f01003d3:	57                   	push   %edi
f01003d4:	56                   	push   %esi
f01003d5:	53                   	push   %ebx
f01003d6:	83 ec 1c             	sub    $0x1c,%esp
f01003d9:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003db:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e0:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ea:	eb 09                	jmp    f01003f5 <cons_putc+0x25>
f01003ec:	89 ca                	mov    %ecx,%edx
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	ec                   	in     (%dx),%al
f01003f1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f2:	83 c3 01             	add    $0x1,%ebx
f01003f5:	89 f2                	mov    %esi,%edx
f01003f7:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f8:	a8 20                	test   $0x20,%al
f01003fa:	75 08                	jne    f0100404 <cons_putc+0x34>
f01003fc:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100402:	7e e8                	jle    f01003ec <cons_putc+0x1c>
f0100404:	89 f8                	mov    %edi,%eax
f0100406:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100409:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040e:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010040f:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100414:	be 79 03 00 00       	mov    $0x379,%esi
f0100419:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041e:	eb 09                	jmp    f0100429 <cons_putc+0x59>
f0100420:	89 ca                	mov    %ecx,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	ec                   	in     (%dx),%al
f0100424:	ec                   	in     (%dx),%al
f0100425:	ec                   	in     (%dx),%al
f0100426:	83 c3 01             	add    $0x1,%ebx
f0100429:	89 f2                	mov    %esi,%edx
f010042b:	ec                   	in     (%dx),%al
f010042c:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100432:	7f 04                	jg     f0100438 <cons_putc+0x68>
f0100434:	84 c0                	test   %al,%al
f0100436:	79 e8                	jns    f0100420 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100438:	ba 78 03 00 00       	mov    $0x378,%edx
f010043d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100441:	ee                   	out    %al,(%dx)
f0100442:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100447:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100452:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100453:	89 fa                	mov    %edi,%edx
f0100455:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010045b:	89 f8                	mov    %edi,%eax
f010045d:	80 cc 07             	or     $0x7,%ah
f0100460:	85 d2                	test   %edx,%edx
f0100462:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100465:	89 f8                	mov    %edi,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	83 f8 09             	cmp    $0x9,%eax
f010046d:	74 74                	je     f01004e3 <cons_putc+0x113>
f010046f:	83 f8 09             	cmp    $0x9,%eax
f0100472:	7f 0a                	jg     f010047e <cons_putc+0xae>
f0100474:	83 f8 08             	cmp    $0x8,%eax
f0100477:	74 14                	je     f010048d <cons_putc+0xbd>
f0100479:	e9 99 00 00 00       	jmp    f0100517 <cons_putc+0x147>
f010047e:	83 f8 0a             	cmp    $0xa,%eax
f0100481:	74 3a                	je     f01004bd <cons_putc+0xed>
f0100483:	83 f8 0d             	cmp    $0xd,%eax
f0100486:	74 3d                	je     f01004c5 <cons_putc+0xf5>
f0100488:	e9 8a 00 00 00       	jmp    f0100517 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010048d:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f0100494:	66 85 c0             	test   %ax,%ax
f0100497:	0f 84 e6 00 00 00    	je     f0100583 <cons_putc+0x1b3>
			crt_pos--;
f010049d:	83 e8 01             	sub    $0x1,%eax
f01004a0:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ae:	83 cf 20             	or     $0x20,%edi
f01004b1:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01004b7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004bb:	eb 78                	jmp    f0100535 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004bd:	66 83 05 28 f2 22 f0 	addw   $0x50,0xf022f228
f01004c4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004c5:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004cc:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d2:	c1 e8 16             	shr    $0x16,%eax
f01004d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d8:	c1 e0 04             	shl    $0x4,%eax
f01004db:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
f01004e1:	eb 52                	jmp    f0100535 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e8:	e8 e3 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f2:	e8 d9 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fc:	e8 cf fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 c5 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 bb fe ff ff       	call   f01003d0 <cons_putc>
f0100515:	eb 1e                	jmp    f0100535 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100517:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010051e:	8d 50 01             	lea    0x1(%eax),%edx
f0100521:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f0100528:	0f b7 c0             	movzwl %ax,%eax
f010052b:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100531:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100535:	66 81 3d 28 f2 22 f0 	cmpw   $0x7cf,0xf022f228
f010053c:	cf 07 
f010053e:	76 43                	jbe    f0100583 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100540:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f0100545:	83 ec 04             	sub    $0x4,%esp
f0100548:	68 00 0f 00 00       	push   $0xf00
f010054d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100553:	52                   	push   %edx
f0100554:	50                   	push   %eax
f0100555:	e8 d9 4e 00 00       	call   f0105433 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010055a:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100560:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100566:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010056c:	83 c4 10             	add    $0x10,%esp
f010056f:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100574:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100577:	39 d0                	cmp    %edx,%eax
f0100579:	75 f4                	jne    f010056f <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010057b:	66 83 2d 28 f2 22 f0 	subw   $0x50,0xf022f228
f0100582:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100583:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100589:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058e:	89 ca                	mov    %ecx,%edx
f0100590:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100591:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
f0100598:	8d 71 01             	lea    0x1(%ecx),%esi
f010059b:	89 d8                	mov    %ebx,%eax
f010059d:	66 c1 e8 08          	shr    $0x8,%ax
f01005a1:	89 f2                	mov    %esi,%edx
f01005a3:	ee                   	out    %al,(%dx)
f01005a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a9:	89 ca                	mov    %ecx,%edx
f01005ab:	ee                   	out    %al,(%dx)
f01005ac:	89 d8                	mov    %ebx,%eax
f01005ae:	89 f2                	mov    %esi,%edx
f01005b0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b4:	5b                   	pop    %ebx
f01005b5:	5e                   	pop    %esi
f01005b6:	5f                   	pop    %edi
f01005b7:	5d                   	pop    %ebp
f01005b8:	c3                   	ret    

f01005b9 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b9:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
f01005c0:	74 11                	je     f01005d3 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005c8:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005cd:	e8 b0 fc ff ff       	call   f0100282 <cons_intr>
}
f01005d2:	c9                   	leave  
f01005d3:	f3 c3                	repz ret 

f01005d5 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005db:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005e0:	e8 9d fc ff ff       	call   f0100282 <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005ed:	e8 c7 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f2:	e8 de ff ff ff       	call   f01005d5 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005f7:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f01005fc:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f0100602:	74 26                	je     f010062a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100604:	8d 50 01             	lea    0x1(%eax),%edx
f0100607:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f010060d:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100614:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100616:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010061c:	75 11                	jne    f010062f <cons_getc+0x48>
			cons.rpos = 0;
f010061e:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
f0100625:	00 00 00 
f0100628:	eb 05                	jmp    f010062f <cons_getc+0x48>
		return c;
	}
	return 0;
f010062a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    

f0100631 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100631:	55                   	push   %ebp
f0100632:	89 e5                	mov    %esp,%ebp
f0100634:	57                   	push   %edi
f0100635:	56                   	push   %esi
f0100636:	53                   	push   %ebx
f0100637:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010063a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100641:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100648:	5a a5 
	if (*cp != 0xA55A) {
f010064a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100651:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100655:	74 11                	je     f0100668 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100657:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
f010065e:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100661:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100666:	eb 16                	jmp    f010067e <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100668:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010066f:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
f0100676:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100679:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010067e:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
f0100684:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100689:	89 fa                	mov    %edi,%edx
f010068b:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010068c:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068f:	89 da                	mov    %ebx,%edx
f0100691:	ec                   	in     (%dx),%al
f0100692:	0f b6 c8             	movzbl %al,%ecx
f0100695:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100698:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 da                	mov    %ebx,%edx
f01006a2:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006a3:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f01006a9:	0f b6 c0             	movzbl %al,%eax
f01006ac:	09 c8                	or     %ecx,%eax
f01006ae:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006b4:	e8 1c ff ff ff       	call   f01005d5 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006b9:	83 ec 0c             	sub    $0xc,%esp
f01006bc:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006c3:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c8:	50                   	push   %eax
f01006c9:	e8 27 2f 00 00       	call   f01035f5 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ce:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	89 f2                	mov    %esi,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006e0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006eb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f0:	89 da                	mov    %ebx,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100703:	b8 03 00 00 00       	mov    $0x3,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100719:	b8 01 00 00 00       	mov    $0x1,%eax
f010071e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100724:	ec                   	in     (%dx),%al
f0100725:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100727:	83 c4 10             	add    $0x10,%esp
f010072a:	3c ff                	cmp    $0xff,%al
f010072c:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
f0100733:	89 f2                	mov    %esi,%edx
f0100735:	ec                   	in     (%dx),%al
f0100736:	89 da                	mov    %ebx,%edx
f0100738:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100739:	80 f9 ff             	cmp    $0xff,%cl
f010073c:	75 10                	jne    f010074e <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010073e:	83 ec 0c             	sub    $0xc,%esp
f0100741:	68 6f 61 10 f0       	push   $0xf010616f
f0100746:	e8 fb 2f 00 00       	call   f0103746 <cprintf>
f010074b:	83 c4 10             	add    $0x10,%esp
}
f010074e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100751:	5b                   	pop    %ebx
f0100752:	5e                   	pop    %esi
f0100753:	5f                   	pop    %edi
f0100754:	5d                   	pop    %ebp
f0100755:	c3                   	ret    

f0100756 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010075c:	8b 45 08             	mov    0x8(%ebp),%eax
f010075f:	e8 6c fc ff ff       	call   f01003d0 <cons_putc>
}
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    

f0100766 <getchar>:

int
getchar(void)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
f0100769:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076c:	e8 76 fe ff ff       	call   f01005e7 <cons_getc>
f0100771:	85 c0                	test   %eax,%eax
f0100773:	74 f7                	je     f010076c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100775:	c9                   	leave  
f0100776:	c3                   	ret    

f0100777 <iscons>:

int
iscons(int fdnum)
{
f0100777:	55                   	push   %ebp
f0100778:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	5d                   	pop    %ebp
f0100780:	c3                   	ret    

f0100781 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100781:	55                   	push   %ebp
f0100782:	89 e5                	mov    %esp,%ebp
f0100784:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100787:	68 c0 63 10 f0       	push   $0xf01063c0
f010078c:	68 de 63 10 f0       	push   $0xf01063de
f0100791:	68 e3 63 10 f0       	push   $0xf01063e3
f0100796:	e8 ab 2f 00 00       	call   f0103746 <cprintf>
f010079b:	83 c4 0c             	add    $0xc,%esp
f010079e:	68 94 64 10 f0       	push   $0xf0106494
f01007a3:	68 ec 63 10 f0       	push   $0xf01063ec
f01007a8:	68 e3 63 10 f0       	push   $0xf01063e3
f01007ad:	e8 94 2f 00 00       	call   f0103746 <cprintf>
	return 0;
}
f01007b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b7:	c9                   	leave  
f01007b8:	c3                   	ret    

f01007b9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b9:	55                   	push   %ebp
f01007ba:	89 e5                	mov    %esp,%ebp
f01007bc:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007bf:	68 f5 63 10 f0       	push   $0xf01063f5
f01007c4:	e8 7d 2f 00 00       	call   f0103746 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c9:	83 c4 08             	add    $0x8,%esp
f01007cc:	68 0c 00 10 00       	push   $0x10000c
f01007d1:	68 bc 64 10 f0       	push   $0xf01064bc
f01007d6:	e8 6b 2f 00 00       	call   f0103746 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007db:	83 c4 0c             	add    $0xc,%esp
f01007de:	68 0c 00 10 00       	push   $0x10000c
f01007e3:	68 0c 00 10 f0       	push   $0xf010000c
f01007e8:	68 e4 64 10 f0       	push   $0xf01064e4
f01007ed:	e8 54 2f 00 00       	call   f0103746 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	68 81 60 10 00       	push   $0x106081
f01007fa:	68 81 60 10 f0       	push   $0xf0106081
f01007ff:	68 08 65 10 f0       	push   $0xf0106508
f0100804:	e8 3d 2f 00 00       	call   f0103746 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100809:	83 c4 0c             	add    $0xc,%esp
f010080c:	68 28 ea 22 00       	push   $0x22ea28
f0100811:	68 28 ea 22 f0       	push   $0xf022ea28
f0100816:	68 2c 65 10 f0       	push   $0xf010652c
f010081b:	e8 26 2f 00 00       	call   f0103746 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 08 10 27 00       	push   $0x271008
f0100828:	68 08 10 27 f0       	push   $0xf0271008
f010082d:	68 50 65 10 f0       	push   $0xf0106550
f0100832:	e8 0f 2f 00 00       	call   f0103746 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100837:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
f010083c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100841:	83 c4 08             	add    $0x8,%esp
f0100844:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100849:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010084f:	85 c0                	test   %eax,%eax
f0100851:	0f 48 c2             	cmovs  %edx,%eax
f0100854:	c1 f8 0a             	sar    $0xa,%eax
f0100857:	50                   	push   %eax
f0100858:	68 74 65 10 f0       	push   $0xf0106574
f010085d:	e8 e4 2e 00 00       	call   f0103746 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100862:	b8 00 00 00 00       	mov    $0x0,%eax
f0100867:	c9                   	leave  
f0100868:	c3                   	ret    

f0100869 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100869:	55                   	push   %ebp
f010086a:	89 e5                	mov    %esp,%ebp
f010086c:	57                   	push   %edi
f010086d:	56                   	push   %esi
f010086e:	53                   	push   %ebx
f010086f:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100872:	89 ee                	mov    %ebp,%esi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();//获取ebp值
	cprintf("Stack backtrace:\n");//输出格式
f0100874:	68 0e 64 10 f0       	push   $0xf010640e
f0100879:	e8 c8 2e 00 00       	call   f0103746 <cprintf>
	while (ebp) 
f010087e:	83 c4 10             	add    $0x10,%esp
f0100881:	eb 67                	jmp    f01008ea <mon_backtrace+0x81>
	{
	cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);//输出ebp,eip，其中eip通过ebp[1]得到
f0100883:	83 ec 04             	sub    $0x4,%esp
f0100886:	ff 76 04             	pushl  0x4(%esi)
f0100889:	56                   	push   %esi
f010088a:	68 20 64 10 f0       	push   $0xf0106420
f010088f:	e8 b2 2e 00 00       	call   f0103746 <cprintf>
f0100894:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100897:	8d 7e 1c             	lea    0x1c(%esi),%edi
f010089a:	83 c4 10             	add    $0x10,%esp
	int j=2;
	while(j!=7) //输出args[i]
	     {
	     cprintf(" %08x", ebp[j]);
f010089d:	83 ec 08             	sub    $0x8,%esp
f01008a0:	ff 33                	pushl  (%ebx)
f01008a2:	68 39 64 10 f0       	push   $0xf0106439
f01008a7:	e8 9a 2e 00 00       	call   f0103746 <cprintf>
f01008ac:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");//输出格式
	while (ebp) 
	{
	cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);//输出ebp,eip，其中eip通过ebp[1]得到
	int j=2;
	while(j!=7) //输出args[i]
f01008af:	83 c4 10             	add    $0x10,%esp
f01008b2:	39 fb                	cmp    %edi,%ebx
f01008b4:	75 e7                	jne    f010089d <mon_backtrace+0x34>
	     {
	     cprintf(" %08x", ebp[j]);
	     j++;
	     } 
	debuginfo_eip(ebp[1],&info);
f01008b6:	83 ec 08             	sub    $0x8,%esp
f01008b9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008bc:	50                   	push   %eax
f01008bd:	ff 76 04             	pushl  0x4(%esi)
f01008c0:	e8 99 40 00 00       	call   f010495e <debuginfo_eip>
	cprintf("\n    %s:%d:  %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f01008c5:	83 c4 08             	add    $0x8,%esp
f01008c8:	8b 46 04             	mov    0x4(%esi),%eax
f01008cb:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008ce:	50                   	push   %eax
f01008cf:	ff 75 d8             	pushl  -0x28(%ebp)
f01008d2:	ff 75 dc             	pushl  -0x24(%ebp)
f01008d5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008d8:	ff 75 d0             	pushl  -0x30(%ebp)
f01008db:	68 3f 64 10 f0       	push   $0xf010643f
f01008e0:	e8 61 2e 00 00       	call   f0103746 <cprintf>
	ebp = (uint32_t *) (*ebp);
f01008e5:	8b 36                	mov    (%esi),%esi
f01008e7:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();//获取ebp值
	cprintf("Stack backtrace:\n");//输出格式
	while (ebp) 
f01008ea:	85 f6                	test   %esi,%esi
f01008ec:	75 95                	jne    f0100883 <mon_backtrace+0x1a>
	debuginfo_eip(ebp[1],&info);
	cprintf("\n    %s:%d:  %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
	ebp = (uint32_t *) (*ebp);
	}
	return 0;
}
f01008ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008f6:	5b                   	pop    %ebx
f01008f7:	5e                   	pop    %esi
f01008f8:	5f                   	pop    %edi
f01008f9:	5d                   	pop    %ebp
f01008fa:	c3                   	ret    

f01008fb <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008fb:	55                   	push   %ebp
f01008fc:	89 e5                	mov    %esp,%ebp
f01008fe:	57                   	push   %edi
f01008ff:	56                   	push   %esi
f0100900:	53                   	push   %ebx
f0100901:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100904:	68 a0 65 10 f0       	push   $0xf01065a0
f0100909:	e8 38 2e 00 00       	call   f0103746 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010090e:	c7 04 24 c4 65 10 f0 	movl   $0xf01065c4,(%esp)
f0100915:	e8 2c 2e 00 00       	call   f0103746 <cprintf>

	if (tf != NULL)
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100921:	74 0e                	je     f0100931 <monitor+0x36>
		print_trapframe(tf);
f0100923:	83 ec 0c             	sub    $0xc,%esp
f0100926:	ff 75 08             	pushl  0x8(%ebp)
f0100929:	e8 22 33 00 00       	call   f0103c50 <print_trapframe>
f010092e:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100931:	83 ec 0c             	sub    $0xc,%esp
f0100934:	68 55 64 10 f0       	push   $0xf0106455
f0100939:	e8 51 48 00 00       	call   f010518f <readline>
f010093e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100940:	83 c4 10             	add    $0x10,%esp
f0100943:	85 c0                	test   %eax,%eax
f0100945:	74 ea                	je     f0100931 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100947:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010094e:	be 00 00 00 00       	mov    $0x0,%esi
f0100953:	eb 0a                	jmp    f010095f <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100955:	c6 03 00             	movb   $0x0,(%ebx)
f0100958:	89 f7                	mov    %esi,%edi
f010095a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010095d:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010095f:	0f b6 03             	movzbl (%ebx),%eax
f0100962:	84 c0                	test   %al,%al
f0100964:	74 63                	je     f01009c9 <monitor+0xce>
f0100966:	83 ec 08             	sub    $0x8,%esp
f0100969:	0f be c0             	movsbl %al,%eax
f010096c:	50                   	push   %eax
f010096d:	68 59 64 10 f0       	push   $0xf0106459
f0100972:	e8 32 4a 00 00       	call   f01053a9 <strchr>
f0100977:	83 c4 10             	add    $0x10,%esp
f010097a:	85 c0                	test   %eax,%eax
f010097c:	75 d7                	jne    f0100955 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010097e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100981:	74 46                	je     f01009c9 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100983:	83 fe 0f             	cmp    $0xf,%esi
f0100986:	75 14                	jne    f010099c <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100988:	83 ec 08             	sub    $0x8,%esp
f010098b:	6a 10                	push   $0x10
f010098d:	68 5e 64 10 f0       	push   $0xf010645e
f0100992:	e8 af 2d 00 00       	call   f0103746 <cprintf>
f0100997:	83 c4 10             	add    $0x10,%esp
f010099a:	eb 95                	jmp    f0100931 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010099c:	8d 7e 01             	lea    0x1(%esi),%edi
f010099f:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009a3:	eb 03                	jmp    f01009a8 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009a5:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a8:	0f b6 03             	movzbl (%ebx),%eax
f01009ab:	84 c0                	test   %al,%al
f01009ad:	74 ae                	je     f010095d <monitor+0x62>
f01009af:	83 ec 08             	sub    $0x8,%esp
f01009b2:	0f be c0             	movsbl %al,%eax
f01009b5:	50                   	push   %eax
f01009b6:	68 59 64 10 f0       	push   $0xf0106459
f01009bb:	e8 e9 49 00 00       	call   f01053a9 <strchr>
f01009c0:	83 c4 10             	add    $0x10,%esp
f01009c3:	85 c0                	test   %eax,%eax
f01009c5:	74 de                	je     f01009a5 <monitor+0xaa>
f01009c7:	eb 94                	jmp    f010095d <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009c9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009d0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009d1:	85 f6                	test   %esi,%esi
f01009d3:	0f 84 58 ff ff ff    	je     f0100931 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009d9:	83 ec 08             	sub    $0x8,%esp
f01009dc:	68 de 63 10 f0       	push   $0xf01063de
f01009e1:	ff 75 a8             	pushl  -0x58(%ebp)
f01009e4:	e8 62 49 00 00       	call   f010534b <strcmp>
f01009e9:	83 c4 10             	add    $0x10,%esp
f01009ec:	85 c0                	test   %eax,%eax
f01009ee:	74 1e                	je     f0100a0e <monitor+0x113>
f01009f0:	83 ec 08             	sub    $0x8,%esp
f01009f3:	68 ec 63 10 f0       	push   $0xf01063ec
f01009f8:	ff 75 a8             	pushl  -0x58(%ebp)
f01009fb:	e8 4b 49 00 00       	call   f010534b <strcmp>
f0100a00:	83 c4 10             	add    $0x10,%esp
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	75 2f                	jne    f0100a36 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a07:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a0c:	eb 05                	jmp    f0100a13 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a0e:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100a13:	83 ec 04             	sub    $0x4,%esp
f0100a16:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a19:	01 d0                	add    %edx,%eax
f0100a1b:	ff 75 08             	pushl  0x8(%ebp)
f0100a1e:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a21:	51                   	push   %ecx
f0100a22:	56                   	push   %esi
f0100a23:	ff 14 85 f4 65 10 f0 	call   *-0xfef9a0c(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	78 1d                	js     f0100a4e <monitor+0x153>
f0100a31:	e9 fb fe ff ff       	jmp    f0100931 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a36:	83 ec 08             	sub    $0x8,%esp
f0100a39:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a3c:	68 7b 64 10 f0       	push   $0xf010647b
f0100a41:	e8 00 2d 00 00       	call   f0103746 <cprintf>
f0100a46:	83 c4 10             	add    $0x10,%esp
f0100a49:	e9 e3 fe ff ff       	jmp    f0100931 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a51:	5b                   	pop    %ebx
f0100a52:	5e                   	pop    %esi
f0100a53:	5f                   	pop    %edi
f0100a54:	5d                   	pop    %ebp
f0100a55:	c3                   	ret    

f0100a56 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a56:	55                   	push   %ebp
f0100a57:	89 e5                	mov    %esp,%ebp
f0100a59:	53                   	push   %ebx
f0100a5a:	83 ec 04             	sub    $0x4,%esp
f0100a5d:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a5f:	83 3d 38 f2 22 f0 00 	cmpl   $0x0,0xf022f238
f0100a66:	75 0f                	jne    f0100a77 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a68:	b8 07 20 27 f0       	mov    $0xf0272007,%eax
f0100a6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a72:	a3 38 f2 22 f0       	mov    %eax,0xf022f238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc, nextfree:%x\n", nextfree);
f0100a77:	83 ec 08             	sub    $0x8,%esp
f0100a7a:	ff 35 38 f2 22 f0    	pushl  0xf022f238
f0100a80:	68 04 66 10 f0       	push   $0xf0106604
f0100a85:	e8 bc 2c 00 00       	call   f0103746 <cprintf>
	result = nextfree;
f0100a8a:	a1 38 f2 22 f0       	mov    0xf022f238,%eax
	if (n != 0) {
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	85 db                	test   %ebx,%ebx
f0100a94:	74 13                	je     f0100aa9 <boot_alloc+0x53>
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100a96:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100a9d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aa3:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	}

	return result;
}
f0100aa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aac:	c9                   	leave  
f0100aad:	c3                   	ret    

f0100aae <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100aae:	89 d1                	mov    %edx,%ecx
f0100ab0:	c1 e9 16             	shr    $0x16,%ecx
f0100ab3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ab6:	a8 01                	test   $0x1,%al
f0100ab8:	74 52                	je     f0100b0c <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100abf:	89 c1                	mov    %eax,%ecx
f0100ac1:	c1 e9 0c             	shr    $0xc,%ecx
f0100ac4:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0100aca:	72 1b                	jb     f0100ae7 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100acc:	55                   	push   %ebp
f0100acd:	89 e5                	mov    %esp,%ebp
f0100acf:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad2:	50                   	push   %eax
f0100ad3:	68 c4 60 10 f0       	push   $0xf01060c4
f0100ad8:	68 81 03 00 00       	push   $0x381
f0100add:	68 1d 66 10 f0       	push   $0xf010661d
f0100ae2:	e8 59 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ae7:	c1 ea 0c             	shr    $0xc,%edx
f0100aea:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100af0:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100af7:	89 c2                	mov    %eax,%edx
f0100af9:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100afc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b01:	85 d2                	test   %edx,%edx
f0100b03:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b08:	0f 44 c2             	cmove  %edx,%eax
f0100b0b:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b11:	c3                   	ret    

f0100b12 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b12:	55                   	push   %ebp
f0100b13:	89 e5                	mov    %esp,%ebp
f0100b15:	57                   	push   %edi
f0100b16:	56                   	push   %esi
f0100b17:	53                   	push   %ebx
f0100b18:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b1b:	84 c0                	test   %al,%al
f0100b1d:	0f 85 a0 02 00 00    	jne    f0100dc3 <check_page_free_list+0x2b1>
f0100b23:	e9 ad 02 00 00       	jmp    f0100dd5 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b28:	83 ec 04             	sub    $0x4,%esp
f0100b2b:	68 84 69 10 f0       	push   $0xf0106984
f0100b30:	68 b4 02 00 00       	push   $0x2b4
f0100b35:	68 1d 66 10 f0       	push   $0xf010661d
f0100b3a:	e8 01 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b3f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b42:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b45:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b4b:	89 c2                	mov    %eax,%edx
f0100b4d:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0100b53:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b59:	0f 95 c2             	setne  %dl
f0100b5c:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b5f:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b63:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b65:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b69:	8b 00                	mov    (%eax),%eax
f0100b6b:	85 c0                	test   %eax,%eax
f0100b6d:	75 dc                	jne    f0100b4b <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b72:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b7e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b80:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b83:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b88:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b8d:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100b93:	eb 53                	jmp    f0100be8 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b95:	89 d8                	mov    %ebx,%eax
f0100b97:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100b9d:	c1 f8 03             	sar    $0x3,%eax
f0100ba0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ba3:	89 c2                	mov    %eax,%edx
f0100ba5:	c1 ea 16             	shr    $0x16,%edx
f0100ba8:	39 f2                	cmp    %esi,%edx
f0100baa:	73 3a                	jae    f0100be6 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bac:	89 c2                	mov    %eax,%edx
f0100bae:	c1 ea 0c             	shr    $0xc,%edx
f0100bb1:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100bb7:	72 12                	jb     f0100bcb <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb9:	50                   	push   %eax
f0100bba:	68 c4 60 10 f0       	push   $0xf01060c4
f0100bbf:	6a 58                	push   $0x58
f0100bc1:	68 29 66 10 f0       	push   $0xf0106629
f0100bc6:	e8 75 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bcb:	83 ec 04             	sub    $0x4,%esp
f0100bce:	68 80 00 00 00       	push   $0x80
f0100bd3:	68 97 00 00 00       	push   $0x97
f0100bd8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bdd:	50                   	push   %eax
f0100bde:	e8 03 48 00 00       	call   f01053e6 <memset>
f0100be3:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100be6:	8b 1b                	mov    (%ebx),%ebx
f0100be8:	85 db                	test   %ebx,%ebx
f0100bea:	75 a9                	jne    f0100b95 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bec:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bf1:	e8 60 fe ff ff       	call   f0100a56 <boot_alloc>
f0100bf6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf9:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bff:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
		assert(pp < pages + npages);
f0100c05:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100c0a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c0d:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c13:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c16:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1b:	e9 52 01 00 00       	jmp    f0100d72 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c20:	39 ca                	cmp    %ecx,%edx
f0100c22:	73 19                	jae    f0100c3d <check_page_free_list+0x12b>
f0100c24:	68 37 66 10 f0       	push   $0xf0106637
f0100c29:	68 43 66 10 f0       	push   $0xf0106643
f0100c2e:	68 ce 02 00 00       	push   $0x2ce
f0100c33:	68 1d 66 10 f0       	push   $0xf010661d
f0100c38:	e8 03 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c3d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c40:	72 19                	jb     f0100c5b <check_page_free_list+0x149>
f0100c42:	68 58 66 10 f0       	push   $0xf0106658
f0100c47:	68 43 66 10 f0       	push   $0xf0106643
f0100c4c:	68 cf 02 00 00       	push   $0x2cf
f0100c51:	68 1d 66 10 f0       	push   $0xf010661d
f0100c56:	e8 e5 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c5b:	89 d0                	mov    %edx,%eax
f0100c5d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c60:	a8 07                	test   $0x7,%al
f0100c62:	74 19                	je     f0100c7d <check_page_free_list+0x16b>
f0100c64:	68 a8 69 10 f0       	push   $0xf01069a8
f0100c69:	68 43 66 10 f0       	push   $0xf0106643
f0100c6e:	68 d0 02 00 00       	push   $0x2d0
f0100c73:	68 1d 66 10 f0       	push   $0xf010661d
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c7d:	c1 f8 03             	sar    $0x3,%eax
f0100c80:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c83:	85 c0                	test   %eax,%eax
f0100c85:	75 19                	jne    f0100ca0 <check_page_free_list+0x18e>
f0100c87:	68 6c 66 10 f0       	push   $0xf010666c
f0100c8c:	68 43 66 10 f0       	push   $0xf0106643
f0100c91:	68 d3 02 00 00       	push   $0x2d3
f0100c96:	68 1d 66 10 f0       	push   $0xf010661d
f0100c9b:	e8 a0 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ca0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ca5:	75 19                	jne    f0100cc0 <check_page_free_list+0x1ae>
f0100ca7:	68 7d 66 10 f0       	push   $0xf010667d
f0100cac:	68 43 66 10 f0       	push   $0xf0106643
f0100cb1:	68 d4 02 00 00       	push   $0x2d4
f0100cb6:	68 1d 66 10 f0       	push   $0xf010661d
f0100cbb:	e8 80 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cc0:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cc5:	75 19                	jne    f0100ce0 <check_page_free_list+0x1ce>
f0100cc7:	68 dc 69 10 f0       	push   $0xf01069dc
f0100ccc:	68 43 66 10 f0       	push   $0xf0106643
f0100cd1:	68 d5 02 00 00       	push   $0x2d5
f0100cd6:	68 1d 66 10 f0       	push   $0xf010661d
f0100cdb:	e8 60 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ce0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ce5:	75 19                	jne    f0100d00 <check_page_free_list+0x1ee>
f0100ce7:	68 96 66 10 f0       	push   $0xf0106696
f0100cec:	68 43 66 10 f0       	push   $0xf0106643
f0100cf1:	68 d6 02 00 00       	push   $0x2d6
f0100cf6:	68 1d 66 10 f0       	push   $0xf010661d
f0100cfb:	e8 40 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d00:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d05:	0f 86 f1 00 00 00    	jbe    f0100dfc <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d0b:	89 c7                	mov    %eax,%edi
f0100d0d:	c1 ef 0c             	shr    $0xc,%edi
f0100d10:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d13:	77 12                	ja     f0100d27 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d15:	50                   	push   %eax
f0100d16:	68 c4 60 10 f0       	push   $0xf01060c4
f0100d1b:	6a 58                	push   $0x58
f0100d1d:	68 29 66 10 f0       	push   $0xf0106629
f0100d22:	e8 19 f3 ff ff       	call   f0100040 <_panic>
f0100d27:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d2d:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d30:	0f 86 b6 00 00 00    	jbe    f0100dec <check_page_free_list+0x2da>
f0100d36:	68 00 6a 10 f0       	push   $0xf0106a00
f0100d3b:	68 43 66 10 f0       	push   $0xf0106643
f0100d40:	68 d7 02 00 00       	push   $0x2d7
f0100d45:	68 1d 66 10 f0       	push   $0xf010661d
f0100d4a:	e8 f1 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d4f:	68 b0 66 10 f0       	push   $0xf01066b0
f0100d54:	68 43 66 10 f0       	push   $0xf0106643
f0100d59:	68 d9 02 00 00       	push   $0x2d9
f0100d5e:	68 1d 66 10 f0       	push   $0xf010661d
f0100d63:	e8 d8 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d68:	83 c6 01             	add    $0x1,%esi
f0100d6b:	eb 03                	jmp    f0100d70 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d6d:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d70:	8b 12                	mov    (%edx),%edx
f0100d72:	85 d2                	test   %edx,%edx
f0100d74:	0f 85 a6 fe ff ff    	jne    f0100c20 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d7a:	85 f6                	test   %esi,%esi
f0100d7c:	7f 19                	jg     f0100d97 <check_page_free_list+0x285>
f0100d7e:	68 cd 66 10 f0       	push   $0xf01066cd
f0100d83:	68 43 66 10 f0       	push   $0xf0106643
f0100d88:	68 e1 02 00 00       	push   $0x2e1
f0100d8d:	68 1d 66 10 f0       	push   $0xf010661d
f0100d92:	e8 a9 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d97:	85 db                	test   %ebx,%ebx
f0100d99:	7f 19                	jg     f0100db4 <check_page_free_list+0x2a2>
f0100d9b:	68 df 66 10 f0       	push   $0xf01066df
f0100da0:	68 43 66 10 f0       	push   $0xf0106643
f0100da5:	68 e2 02 00 00       	push   $0x2e2
f0100daa:	68 1d 66 10 f0       	push   $0xf010661d
f0100daf:	e8 8c f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100db4:	83 ec 0c             	sub    $0xc,%esp
f0100db7:	68 48 6a 10 f0       	push   $0xf0106a48
f0100dbc:	e8 85 29 00 00       	call   f0103746 <cprintf>
}
f0100dc1:	eb 49                	jmp    f0100e0c <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100dc3:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0100dc8:	85 c0                	test   %eax,%eax
f0100dca:	0f 85 6f fd ff ff    	jne    f0100b3f <check_page_free_list+0x2d>
f0100dd0:	e9 53 fd ff ff       	jmp    f0100b28 <check_page_free_list+0x16>
f0100dd5:	83 3d 40 f2 22 f0 00 	cmpl   $0x0,0xf022f240
f0100ddc:	0f 84 46 fd ff ff    	je     f0100b28 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100de2:	be 00 04 00 00       	mov    $0x400,%esi
f0100de7:	e9 a1 fd ff ff       	jmp    f0100b8d <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dec:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100df1:	0f 85 76 ff ff ff    	jne    f0100d6d <check_page_free_list+0x25b>
f0100df7:	e9 53 ff ff ff       	jmp    f0100d4f <check_page_free_list+0x23d>
f0100dfc:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e01:	0f 85 61 ff ff ff    	jne    f0100d68 <check_page_free_list+0x256>
f0100e07:	e9 43 ff ff ff       	jmp    f0100d4f <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e0f:	5b                   	pop    %ebx
f0100e10:	5e                   	pop    %esi
f0100e11:	5f                   	pop    %edi
f0100e12:	5d                   	pop    %ebp
f0100e13:	c3                   	ret    

f0100e14 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e14:	55                   	push   %ebp
f0100e15:	89 e5                	mov    %esp,%ebp
f0100e17:	56                   	push   %esi
f0100e18:	53                   	push   %ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list = &pages[1];
f0100e19:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100e1e:	8d 58 08             	lea    0x8(%eax),%ebx
f0100e21:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
	struct PageInfo *tail = page_free_list;

	size_t i, mp_page = PGNUM(MPENTRY_PADDR);
	for (i = 1; i < npages_basemem; i++) {
f0100e27:	8b 35 44 f2 22 f0    	mov    0xf022f244,%esi
f0100e2d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e32:	eb 35                	jmp    f0100e69 <page_init+0x55>
		if (i == mp_page) continue;
f0100e34:	83 f8 07             	cmp    $0x7,%eax
f0100e37:	74 2d                	je     f0100e66 <page_init+0x52>
		pages[i].pp_ref = 0;
f0100e39:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100e40:	89 d1                	mov    %edx,%ecx
f0100e42:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0100e48:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = NULL;
f0100e4e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		tail->pp_link = &pages[i];
f0100e54:	89 d1                	mov    %edx,%ecx
f0100e56:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0100e5c:	89 0b                	mov    %ecx,(%ebx)
		tail = &pages[i];
f0100e5e:	89 d3                	mov    %edx,%ebx
f0100e60:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
	// free pages!
	page_free_list = &pages[1];
	struct PageInfo *tail = page_free_list;

	size_t i, mp_page = PGNUM(MPENTRY_PADDR);
	for (i = 1; i < npages_basemem; i++) {
f0100e66:	83 c0 01             	add    $0x1,%eax
f0100e69:	39 f0                	cmp    %esi,%eax
f0100e6b:	72 c7                	jb     f0100e34 <page_init+0x20>
		pages[i].pp_link = NULL;
		tail->pp_link = &pages[i];
		tail = &pages[i];
	}

	char *nextfree = boot_alloc(0);
f0100e6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e72:	e8 df fb ff ff       	call   f0100a56 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e7c:	77 15                	ja     f0100e93 <page_init+0x7f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e7e:	50                   	push   %eax
f0100e7f:	68 e8 60 10 f0       	push   $0xf01060e8
f0100e84:	68 4c 01 00 00       	push   $0x14c
f0100e89:	68 1d 66 10 f0       	push   $0xf010661d
f0100e8e:	e8 ad f1 ff ff       	call   f0100040 <_panic>
	size_t kern_end_page = PGNUM(PADDR(nextfree));
f0100e93:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0100e99:	c1 ee 0c             	shr    $0xc,%esi
	cprintf("kern end page:%d\n", kern_end_page);
f0100e9c:	83 ec 08             	sub    $0x8,%esp
f0100e9f:	56                   	push   %esi
f0100ea0:	68 f0 66 10 f0       	push   $0xf01066f0
f0100ea5:	e8 9c 28 00 00       	call   f0103746 <cprintf>
f0100eaa:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax

	for (i = kern_end_page; i < npages; i++) {
f0100eb1:	83 c4 10             	add    $0x10,%esp
f0100eb4:	eb 2c                	jmp    f0100ee2 <page_init+0xce>
		pages[i].pp_ref = 0;
f0100eb6:	89 c2                	mov    %eax,%edx
f0100eb8:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
f0100ebe:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = NULL;
f0100ec4:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		tail->pp_link = &pages[i];
f0100eca:	89 c2                	mov    %eax,%edx
f0100ecc:	03 15 90 fe 22 f0    	add    0xf022fe90,%edx
f0100ed2:	89 13                	mov    %edx,(%ebx)
		tail = &pages[i];
f0100ed4:	89 c3                	mov    %eax,%ebx
f0100ed6:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx

	char *nextfree = boot_alloc(0);
	size_t kern_end_page = PGNUM(PADDR(nextfree));
	cprintf("kern end page:%d\n", kern_end_page);

	for (i = kern_end_page; i < npages; i++) {
f0100edc:	83 c6 01             	add    $0x1,%esi
f0100edf:	83 c0 08             	add    $0x8,%eax
f0100ee2:	3b 35 88 fe 22 f0    	cmp    0xf022fe88,%esi
f0100ee8:	72 cc                	jb     f0100eb6 <page_init+0xa2>
		pages[i].pp_ref = 0;
		pages[i].pp_link = NULL;
		tail->pp_link = &pages[i];
		tail = &pages[i];
	}
}
f0100eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100eed:	5b                   	pop    %ebx
f0100eee:	5e                   	pop    %esi
f0100eef:	5d                   	pop    %ebp
f0100ef0:	c3                   	ret    

f0100ef1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ef1:	55                   	push   %ebp
f0100ef2:	89 e5                	mov    %esp,%ebp
f0100ef4:	53                   	push   %ebx
f0100ef5:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0100ef8:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100efe:	85 db                	test   %ebx,%ebx
f0100f00:	74 58                	je     f0100f5a <page_alloc+0x69>
		struct PageInfo *result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100f02:	8b 03                	mov    (%ebx),%eax
f0100f04:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
		result->pp_link = NULL;
f0100f09:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO) {
f0100f0f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f13:	74 45                	je     f0100f5a <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f15:	89 d8                	mov    %ebx,%eax
f0100f17:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100f1d:	c1 f8 03             	sar    $0x3,%eax
f0100f20:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f23:	89 c2                	mov    %eax,%edx
f0100f25:	c1 ea 0c             	shr    $0xc,%edx
f0100f28:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100f2e:	72 12                	jb     f0100f42 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f30:	50                   	push   %eax
f0100f31:	68 c4 60 10 f0       	push   $0xf01060c4
f0100f36:	6a 58                	push   $0x58
f0100f38:	68 29 66 10 f0       	push   $0xf0106629
f0100f3d:	e8 fe f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0100f42:	83 ec 04             	sub    $0x4,%esp
f0100f45:	68 00 10 00 00       	push   $0x1000
f0100f4a:	6a 00                	push   $0x0
f0100f4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f51:	50                   	push   %eax
f0100f52:	e8 8f 44 00 00       	call   f01053e6 <memset>
f0100f57:	83 c4 10             	add    $0x10,%esp
		}
		return result;
	}
	return NULL;
}
f0100f5a:	89 d8                	mov    %ebx,%eax
f0100f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f5f:	c9                   	leave  
f0100f60:	c3                   	ret    

f0100f61 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f61:	55                   	push   %ebp
f0100f62:	89 e5                	mov    %esp,%ebp
f0100f64:	83 ec 08             	sub    $0x8,%esp
f0100f67:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(pp->pp_ref == 0 && pp->pp_link == NULL);
f0100f6a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f6f:	75 05                	jne    f0100f76 <page_free+0x15>
f0100f71:	83 38 00             	cmpl   $0x0,(%eax)
f0100f74:	74 19                	je     f0100f8f <page_free+0x2e>
f0100f76:	68 6c 6a 10 f0       	push   $0xf0106a6c
f0100f7b:	68 43 66 10 f0       	push   $0xf0106643
f0100f80:	68 7b 01 00 00       	push   $0x17b
f0100f85:	68 1d 66 10 f0       	push   $0xf010661d
f0100f8a:	e8 b1 f0 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0100f8f:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
f0100f95:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f97:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
}
f0100f9c:	c9                   	leave  
f0100f9d:	c3                   	ret    

f0100f9e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f9e:	55                   	push   %ebp
f0100f9f:	89 e5                	mov    %esp,%ebp
f0100fa1:	83 ec 08             	sub    $0x8,%esp
f0100fa4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fa7:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fab:	83 e8 01             	sub    $0x1,%eax
f0100fae:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fb2:	66 85 c0             	test   %ax,%ax
f0100fb5:	75 0c                	jne    f0100fc3 <page_decref+0x25>
		page_free(pp);
f0100fb7:	83 ec 0c             	sub    $0xc,%esp
f0100fba:	52                   	push   %edx
f0100fbb:	e8 a1 ff ff ff       	call   f0100f61 <page_free>
f0100fc0:	83 c4 10             	add    $0x10,%esp
}
f0100fc3:	c9                   	leave  
f0100fc4:	c3                   	ret    

f0100fc5 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fc5:	55                   	push   %ebp
f0100fc6:	89 e5                	mov    %esp,%ebp
f0100fc8:	56                   	push   %esi
f0100fc9:	53                   	push   %ebx
f0100fca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int pde_index = PDX(va);
	int pte_index = PTX(va);
f0100fcd:	89 de                	mov    %ebx,%esi
f0100fcf:	c1 ee 0c             	shr    $0xc,%esi
f0100fd2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pde_t *pde = &pgdir[pde_index];
f0100fd8:	c1 eb 16             	shr    $0x16,%ebx
f0100fdb:	c1 e3 02             	shl    $0x2,%ebx
f0100fde:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P)) {
f0100fe1:	f6 03 01             	testb  $0x1,(%ebx)
f0100fe4:	75 2d                	jne    f0101013 <pgdir_walk+0x4e>
		if (create) {
f0100fe6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fea:	74 59                	je     f0101045 <pgdir_walk+0x80>
			//cprintf("page create va:%x, pde_index:%x, pte_index:%x\n", va, pde_index, pte_index);
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0100fec:	83 ec 0c             	sub    $0xc,%esp
f0100fef:	6a 01                	push   $0x1
f0100ff1:	e8 fb fe ff ff       	call   f0100ef1 <page_alloc>
			if (!page) return NULL;
f0100ff6:	83 c4 10             	add    $0x10,%esp
f0100ff9:	85 c0                	test   %eax,%eax
f0100ffb:	74 4f                	je     f010104c <pgdir_walk+0x87>

			page->pp_ref++;
f0100ffd:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0101002:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101008:	c1 f8 03             	sar    $0x3,%eax
f010100b:	c1 e0 0c             	shl    $0xc,%eax
f010100e:	83 c8 07             	or     $0x7,%eax
f0101011:	89 03                	mov    %eax,(%ebx)
		} else {
			return NULL;
		}
	}

	pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
f0101013:	8b 03                	mov    (%ebx),%eax
f0101015:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010101a:	89 c2                	mov    %eax,%edx
f010101c:	c1 ea 0c             	shr    $0xc,%edx
f010101f:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101025:	72 15                	jb     f010103c <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101027:	50                   	push   %eax
f0101028:	68 c4 60 10 f0       	push   $0xf01060c4
f010102d:	68 b4 01 00 00       	push   $0x1b4
f0101032:	68 1d 66 10 f0       	push   $0xf010661d
f0101037:	e8 04 f0 ff ff       	call   f0100040 <_panic>
	return &p[pte_index];
f010103c:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101043:	eb 0c                	jmp    f0101051 <pgdir_walk+0x8c>
			if (!page) return NULL;

			page->pp_ref++;
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
		} else {
			return NULL;
f0101045:	b8 00 00 00 00       	mov    $0x0,%eax
f010104a:	eb 05                	jmp    f0101051 <pgdir_walk+0x8c>
	pde_t *pde = &pgdir[pde_index];
	if (!(*pde & PTE_P)) {
		if (create) {
			//cprintf("page create va:%x, pde_index:%x, pte_index:%x\n", va, pde_index, pte_index);
			struct PageInfo *page = page_alloc(ALLOC_ZERO);
			if (!page) return NULL;
f010104c:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}

	pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
	return &p[pte_index];
}
f0101051:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101054:	5b                   	pop    %ebx
f0101055:	5e                   	pop    %esi
f0101056:	5d                   	pop    %ebp
f0101057:	c3                   	ret    

f0101058 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101058:	55                   	push   %ebp
f0101059:	89 e5                	mov    %esp,%ebp
f010105b:	57                   	push   %edi
f010105c:	56                   	push   %esi
f010105d:	53                   	push   %ebx
f010105e:	83 ec 28             	sub    $0x28,%esp
f0101061:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101064:	89 d7                	mov    %edx,%edi
	int pages = PGNUM(size);
f0101066:	89 c8                	mov    %ecx,%eax
f0101068:	c1 e8 0c             	shr    $0xc,%eax
f010106b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	cprintf("boot_map_region va:%x, pa:%x, size:%d, pages:%d\n", va, pa, size, pages);
f010106e:	50                   	push   %eax
f010106f:	51                   	push   %ecx
f0101070:	ff 75 08             	pushl  0x8(%ebp)
f0101073:	52                   	push   %edx
f0101074:	68 94 6a 10 f0       	push   $0xf0106a94
f0101079:	e8 c8 26 00 00       	call   f0103746 <cprintf>
	for (int i = 0; i < pages; i++) {
f010107e:	83 c4 20             	add    $0x20,%esp
f0101081:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101084:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0101089:	29 df                	sub    %ebx,%edi
		if (!pte) {
			panic("boot_map_region panic: out of memory");
		}
		*pte = pa | perm | PTE_P;
f010108b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010108e:	83 c8 01             	or     $0x1,%eax
f0101091:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pages = PGNUM(size);
	cprintf("boot_map_region va:%x, pa:%x, size:%d, pages:%d\n", va, pa, size, pages);
	for (int i = 0; i < pages; i++) {
f0101094:	eb 3f                	jmp    f01010d5 <boot_map_region+0x7d>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0101096:	83 ec 04             	sub    $0x4,%esp
f0101099:	6a 01                	push   $0x1
f010109b:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010109e:	50                   	push   %eax
f010109f:	ff 75 e0             	pushl  -0x20(%ebp)
f01010a2:	e8 1e ff ff ff       	call   f0100fc5 <pgdir_walk>
		if (!pte) {
f01010a7:	83 c4 10             	add    $0x10,%esp
f01010aa:	85 c0                	test   %eax,%eax
f01010ac:	75 17                	jne    f01010c5 <boot_map_region+0x6d>
			panic("boot_map_region panic: out of memory");
f01010ae:	83 ec 04             	sub    $0x4,%esp
f01010b1:	68 c8 6a 10 f0       	push   $0xf0106ac8
f01010b6:	68 cb 01 00 00       	push   $0x1cb
f01010bb:	68 1d 66 10 f0       	push   $0xf010661d
f01010c0:	e8 7b ef ff ff       	call   f0100040 <_panic>
		}
		*pte = pa | perm | PTE_P;
f01010c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010c8:	09 da                	or     %ebx,%edx
f01010ca:	89 10                	mov    %edx,(%eax)
		va += PGSIZE, pa += PGSIZE;
f01010cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pages = PGNUM(size);
	cprintf("boot_map_region va:%x, pa:%x, size:%d, pages:%d\n", va, pa, size, pages);
	for (int i = 0; i < pages; i++) {
f01010d2:	83 c6 01             	add    $0x1,%esi
f01010d5:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010d8:	7c bc                	jl     f0101096 <boot_map_region+0x3e>
			panic("boot_map_region panic: out of memory");
		}
		*pte = pa | perm | PTE_P;
		va += PGSIZE, pa += PGSIZE;
	}
}
f01010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010dd:	5b                   	pop    %ebx
f01010de:	5e                   	pop    %esi
f01010df:	5f                   	pop    %edi
f01010e0:	5d                   	pop    %ebp
f01010e1:	c3                   	ret    

f01010e2 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010e2:	55                   	push   %ebp
f01010e3:	89 e5                	mov    %esp,%ebp
f01010e5:	53                   	push   %ebx
f01010e6:	83 ec 08             	sub    $0x8,%esp
f01010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01010ec:	6a 00                	push   $0x0
f01010ee:	ff 75 0c             	pushl  0xc(%ebp)
f01010f1:	ff 75 08             	pushl  0x8(%ebp)
f01010f4:	e8 cc fe ff ff       	call   f0100fc5 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) {
f01010f9:	83 c4 10             	add    $0x10,%esp
f01010fc:	85 c0                	test   %eax,%eax
f01010fe:	74 37                	je     f0101137 <page_lookup+0x55>
f0101100:	f6 00 01             	testb  $0x1,(%eax)
f0101103:	74 39                	je     f010113e <page_lookup+0x5c>
		return NULL;
	}

	if (pte_store) {
f0101105:	85 db                	test   %ebx,%ebx
f0101107:	74 02                	je     f010110b <page_lookup+0x29>
		*pte_store = pte;
f0101109:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010110b:	8b 00                	mov    (%eax),%eax
f010110d:	c1 e8 0c             	shr    $0xc,%eax
f0101110:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0101116:	72 14                	jb     f010112c <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101118:	83 ec 04             	sub    $0x4,%esp
f010111b:	68 f0 6a 10 f0       	push   $0xf0106af0
f0101120:	6a 51                	push   $0x51
f0101122:	68 29 66 10 f0       	push   $0xf0106629
f0101127:	e8 14 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010112c:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0101132:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}

	return pa2page(PTE_ADDR(*pte));
f0101135:	eb 0c                	jmp    f0101143 <page_lookup+0x61>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (!pte || !(*pte & PTE_P)) {
		return NULL;
f0101137:	b8 00 00 00 00       	mov    $0x0,%eax
f010113c:	eb 05                	jmp    f0101143 <page_lookup+0x61>
f010113e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store) {
		*pte_store = pte;
	}

	return pa2page(PTE_ADDR(*pte));
}
f0101143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101146:	c9                   	leave  
f0101147:	c3                   	ret    

f0101148 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101148:	55                   	push   %ebp
f0101149:	89 e5                	mov    %esp,%ebp
f010114b:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010114e:	e8 b3 48 00 00       	call   f0105a06 <cpunum>
f0101153:	6b c0 74             	imul   $0x74,%eax,%eax
f0101156:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010115d:	74 16                	je     f0101175 <tlb_invalidate+0x2d>
f010115f:	e8 a2 48 00 00       	call   f0105a06 <cpunum>
f0101164:	6b c0 74             	imul   $0x74,%eax,%eax
f0101167:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010116d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101170:	39 50 60             	cmp    %edx,0x60(%eax)
f0101173:	75 06                	jne    f010117b <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101175:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101178:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010117b:	c9                   	leave  
f010117c:	c3                   	ret    

f010117d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010117d:	55                   	push   %ebp
f010117e:	89 e5                	mov    %esp,%ebp
f0101180:	56                   	push   %esi
f0101181:	53                   	push   %ebx
f0101182:	83 ec 14             	sub    $0x14,%esp
f0101185:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101188:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f010118b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010118e:	50                   	push   %eax
f010118f:	56                   	push   %esi
f0101190:	53                   	push   %ebx
f0101191:	e8 4c ff ff ff       	call   f01010e2 <page_lookup>
	if (!page || !(*pte & PTE_P)) {
f0101196:	83 c4 10             	add    $0x10,%esp
f0101199:	85 c0                	test   %eax,%eax
f010119b:	74 24                	je     f01011c1 <page_remove+0x44>
f010119d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01011a0:	f6 02 01             	testb  $0x1,(%edx)
f01011a3:	74 1c                	je     f01011c1 <page_remove+0x44>
		return;
	}
	*pte = 0;
f01011a5:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(page);
f01011ab:	83 ec 0c             	sub    $0xc,%esp
f01011ae:	50                   	push   %eax
f01011af:	e8 ea fd ff ff       	call   f0100f9e <page_decref>
	tlb_invalidate(pgdir, va);
f01011b4:	83 c4 08             	add    $0x8,%esp
f01011b7:	56                   	push   %esi
f01011b8:	53                   	push   %ebx
f01011b9:	e8 8a ff ff ff       	call   f0101148 <tlb_invalidate>
f01011be:	83 c4 10             	add    $0x10,%esp
}
f01011c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011c4:	5b                   	pop    %ebx
f01011c5:	5e                   	pop    %esi
f01011c6:	5d                   	pop    %ebp
f01011c7:	c3                   	ret    

f01011c8 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011c8:	55                   	push   %ebp
f01011c9:	89 e5                	mov    %esp,%ebp
f01011cb:	57                   	push   %edi
f01011cc:	56                   	push   %esi
f01011cd:	53                   	push   %ebx
f01011ce:	83 ec 10             	sub    $0x10,%esp
f01011d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011d4:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01011d7:	6a 01                	push   $0x1
f01011d9:	57                   	push   %edi
f01011da:	ff 75 08             	pushl  0x8(%ebp)
f01011dd:	e8 e3 fd ff ff       	call   f0100fc5 <pgdir_walk>
	if (!pte) {
f01011e2:	83 c4 10             	add    $0x10,%esp
f01011e5:	85 c0                	test   %eax,%eax
f01011e7:	74 38                	je     f0101221 <page_insert+0x59>
f01011e9:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
	}

	pp->pp_ref++;
f01011eb:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f01011f0:	f6 00 01             	testb  $0x1,(%eax)
f01011f3:	74 0f                	je     f0101204 <page_insert+0x3c>
		page_remove(pgdir, va);
f01011f5:	83 ec 08             	sub    $0x8,%esp
f01011f8:	57                   	push   %edi
f01011f9:	ff 75 08             	pushl  0x8(%ebp)
f01011fc:	e8 7c ff ff ff       	call   f010117d <page_remove>
f0101201:	83 c4 10             	add    $0x10,%esp
	}

	*pte = page2pa(pp) | perm | PTE_P;
f0101204:	2b 1d 90 fe 22 f0    	sub    0xf022fe90,%ebx
f010120a:	c1 fb 03             	sar    $0x3,%ebx
f010120d:	c1 e3 0c             	shl    $0xc,%ebx
f0101210:	8b 45 14             	mov    0x14(%ebp),%eax
f0101213:	83 c8 01             	or     $0x1,%eax
f0101216:	09 c3                	or     %eax,%ebx
f0101218:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010121a:	b8 00 00 00 00       	mov    $0x0,%eax
f010121f:	eb 05                	jmp    f0101226 <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (!pte) {
		return -E_NO_MEM;
f0101221:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}

	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101226:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101229:	5b                   	pop    %ebx
f010122a:	5e                   	pop    %esi
f010122b:	5f                   	pop    %edi
f010122c:	5d                   	pop    %ebp
f010122d:	c3                   	ret    

f010122e <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010122e:	55                   	push   %ebp
f010122f:	89 e5                	mov    %esp,%ebp
f0101231:	53                   	push   %ebx
f0101232:	83 ec 04             	sub    $0x4,%esp
f0101235:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	//panic("mmio_map_region not implemented");
	size_t begin = ROUNDDOWN(pa, PGSIZE), end = ROUNDUP(pa + size, PGSIZE);
f0101238:	8b 55 0c             	mov    0xc(%ebp),%edx
f010123b:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	size_t map_size = end - begin;
f0101242:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101248:	89 c2                	mov    %eax,%edx
f010124a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101250:	29 d3                	sub    %edx,%ebx
	if (base + map_size >= MMIOLIM) {
f0101252:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101258:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f010125b:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101261:	76 17                	jbe    f010127a <mmio_map_region+0x4c>
		panic("Overflow MMIOLIM");
f0101263:	83 ec 04             	sub    $0x4,%esp
f0101266:	68 02 67 10 f0       	push   $0xf0106702
f010126b:	68 62 02 00 00       	push   $0x262
f0101270:	68 1d 66 10 f0       	push   $0xf010661d
f0101275:	e8 c6 ed ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, map_size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010127a:	83 ec 08             	sub    $0x8,%esp
f010127d:	6a 1a                	push   $0x1a
f010127f:	50                   	push   %eax
f0101280:	89 d9                	mov    %ebx,%ecx
f0101282:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101287:	e8 cc fd ff ff       	call   f0101058 <boot_map_region>
	uintptr_t result = base;
f010128c:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base += map_size;
f0101291:	01 c3                	add    %eax,%ebx
f0101293:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void *)result;
}
f0101299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010129c:	c9                   	leave  
f010129d:	c3                   	ret    

f010129e <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010129e:	55                   	push   %ebp
f010129f:	89 e5                	mov    %esp,%ebp
f01012a1:	57                   	push   %edi
f01012a2:	56                   	push   %esi
f01012a3:	53                   	push   %ebx
f01012a4:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012a7:	6a 15                	push   $0x15
f01012a9:	e8 19 23 00 00       	call   f01035c7 <mc146818_read>
f01012ae:	89 c3                	mov    %eax,%ebx
f01012b0:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012b7:	e8 0b 23 00 00       	call   f01035c7 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012bc:	c1 e0 08             	shl    $0x8,%eax
f01012bf:	09 d8                	or     %ebx,%eax
f01012c1:	c1 e0 0a             	shl    $0xa,%eax
f01012c4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012ca:	85 c0                	test   %eax,%eax
f01012cc:	0f 48 c2             	cmovs  %edx,%eax
f01012cf:	c1 f8 0c             	sar    $0xc,%eax
f01012d2:	a3 44 f2 22 f0       	mov    %eax,0xf022f244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012d7:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01012de:	e8 e4 22 00 00       	call   f01035c7 <mc146818_read>
f01012e3:	89 c3                	mov    %eax,%ebx
f01012e5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01012ec:	e8 d6 22 00 00       	call   f01035c7 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01012f1:	c1 e0 08             	shl    $0x8,%eax
f01012f4:	09 d8                	or     %ebx,%eax
f01012f6:	c1 e0 0a             	shl    $0xa,%eax
f01012f9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012ff:	83 c4 10             	add    $0x10,%esp
f0101302:	85 c0                	test   %eax,%eax
f0101304:	0f 48 c2             	cmovs  %edx,%eax
f0101307:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010130a:	85 c0                	test   %eax,%eax
f010130c:	74 0e                	je     f010131c <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010130e:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101314:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
f010131a:	eb 0c                	jmp    f0101328 <mem_init+0x8a>
	else
		npages = npages_basemem;
f010131c:	8b 15 44 f2 22 f0    	mov    0xf022f244,%edx
f0101322:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101328:	c1 e0 0c             	shl    $0xc,%eax
f010132b:	c1 e8 0a             	shr    $0xa,%eax
f010132e:	50                   	push   %eax
f010132f:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f0101334:	c1 e0 0c             	shl    $0xc,%eax
f0101337:	c1 e8 0a             	shr    $0xa,%eax
f010133a:	50                   	push   %eax
f010133b:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0101340:	c1 e0 0c             	shl    $0xc,%eax
f0101343:	c1 e8 0a             	shr    $0xa,%eax
f0101346:	50                   	push   %eax
f0101347:	68 10 6b 10 f0       	push   $0xf0106b10
f010134c:	e8 f5 23 00 00       	call   f0103746 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101351:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101356:	e8 fb f6 ff ff       	call   f0100a56 <boot_alloc>
f010135b:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	memset(kern_pgdir, 0, PGSIZE);
f0101360:	83 c4 0c             	add    $0xc,%esp
f0101363:	68 00 10 00 00       	push   $0x1000
f0101368:	6a 00                	push   $0x0
f010136a:	50                   	push   %eax
f010136b:	e8 76 40 00 00       	call   f01053e6 <memset>

	cprintf("kern_pgdir:%x, npages:%d\n", kern_pgdir, npages);
f0101370:	83 c4 0c             	add    $0xc,%esp
f0101373:	ff 35 88 fe 22 f0    	pushl  0xf022fe88
f0101379:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010137f:	68 13 67 10 f0       	push   $0xf0106713
f0101384:	e8 bd 23 00 00       	call   f0103746 <cprintf>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101389:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010138e:	83 c4 10             	add    $0x10,%esp
f0101391:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101396:	77 15                	ja     f01013ad <mem_init+0x10f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101398:	50                   	push   %eax
f0101399:	68 e8 60 10 f0       	push   $0xf01060e8
f010139e:	68 94 00 00 00       	push   $0x94
f01013a3:	68 1d 66 10 f0       	push   $0xf010661d
f01013a8:	e8 93 ec ff ff       	call   f0100040 <_panic>
f01013ad:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013b3:	83 ca 05             	or     $0x5,%edx
f01013b6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f01013bc:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f01013c1:	c1 e0 03             	shl    $0x3,%eax
f01013c4:	e8 8d f6 ff ff       	call   f0100a56 <boot_alloc>
f01013c9:	a3 90 fe 22 f0       	mov    %eax,0xf022fe90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01013ce:	83 ec 04             	sub    $0x4,%esp
f01013d1:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01013d7:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013de:	52                   	push   %edx
f01013df:	6a 00                	push   $0x0
f01013e1:	50                   	push   %eax
f01013e2:	e8 ff 3f 00 00       	call   f01053e6 <memset>


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f01013e7:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ec:	e8 65 f6 ff ff       	call   f0100a56 <boot_alloc>
f01013f1:	a3 48 f2 22 f0       	mov    %eax,0xf022f248
	memset(envs, 0, sizeof(struct Env) * NENV);
f01013f6:	83 c4 0c             	add    $0xc,%esp
f01013f9:	68 00 f0 01 00       	push   $0x1f000
f01013fe:	6a 00                	push   $0x0
f0101400:	50                   	push   %eax
f0101401:	e8 e0 3f 00 00       	call   f01053e6 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101406:	e8 09 fa ff ff       	call   f0100e14 <page_init>

	check_page_free_list(1);
f010140b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101410:	e8 fd f6 ff ff       	call   f0100b12 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101415:	83 c4 10             	add    $0x10,%esp
f0101418:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f010141f:	75 17                	jne    f0101438 <mem_init+0x19a>
		panic("'pages' is a null pointer!");
f0101421:	83 ec 04             	sub    $0x4,%esp
f0101424:	68 2d 67 10 f0       	push   $0xf010672d
f0101429:	68 f5 02 00 00       	push   $0x2f5
f010142e:	68 1d 66 10 f0       	push   $0xf010661d
f0101433:	e8 08 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101438:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f010143d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101442:	eb 05                	jmp    f0101449 <mem_init+0x1ab>
		++nfree;
f0101444:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101447:	8b 00                	mov    (%eax),%eax
f0101449:	85 c0                	test   %eax,%eax
f010144b:	75 f7                	jne    f0101444 <mem_init+0x1a6>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010144d:	83 ec 0c             	sub    $0xc,%esp
f0101450:	6a 00                	push   $0x0
f0101452:	e8 9a fa ff ff       	call   f0100ef1 <page_alloc>
f0101457:	89 c7                	mov    %eax,%edi
f0101459:	83 c4 10             	add    $0x10,%esp
f010145c:	85 c0                	test   %eax,%eax
f010145e:	75 19                	jne    f0101479 <mem_init+0x1db>
f0101460:	68 48 67 10 f0       	push   $0xf0106748
f0101465:	68 43 66 10 f0       	push   $0xf0106643
f010146a:	68 fd 02 00 00       	push   $0x2fd
f010146f:	68 1d 66 10 f0       	push   $0xf010661d
f0101474:	e8 c7 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101479:	83 ec 0c             	sub    $0xc,%esp
f010147c:	6a 00                	push   $0x0
f010147e:	e8 6e fa ff ff       	call   f0100ef1 <page_alloc>
f0101483:	89 c6                	mov    %eax,%esi
f0101485:	83 c4 10             	add    $0x10,%esp
f0101488:	85 c0                	test   %eax,%eax
f010148a:	75 19                	jne    f01014a5 <mem_init+0x207>
f010148c:	68 5e 67 10 f0       	push   $0xf010675e
f0101491:	68 43 66 10 f0       	push   $0xf0106643
f0101496:	68 fe 02 00 00       	push   $0x2fe
f010149b:	68 1d 66 10 f0       	push   $0xf010661d
f01014a0:	e8 9b eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01014a5:	83 ec 0c             	sub    $0xc,%esp
f01014a8:	6a 00                	push   $0x0
f01014aa:	e8 42 fa ff ff       	call   f0100ef1 <page_alloc>
f01014af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014b2:	83 c4 10             	add    $0x10,%esp
f01014b5:	85 c0                	test   %eax,%eax
f01014b7:	75 19                	jne    f01014d2 <mem_init+0x234>
f01014b9:	68 74 67 10 f0       	push   $0xf0106774
f01014be:	68 43 66 10 f0       	push   $0xf0106643
f01014c3:	68 ff 02 00 00       	push   $0x2ff
f01014c8:	68 1d 66 10 f0       	push   $0xf010661d
f01014cd:	e8 6e eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014d2:	39 f7                	cmp    %esi,%edi
f01014d4:	75 19                	jne    f01014ef <mem_init+0x251>
f01014d6:	68 8a 67 10 f0       	push   $0xf010678a
f01014db:	68 43 66 10 f0       	push   $0xf0106643
f01014e0:	68 02 03 00 00       	push   $0x302
f01014e5:	68 1d 66 10 f0       	push   $0xf010661d
f01014ea:	e8 51 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f2:	39 c6                	cmp    %eax,%esi
f01014f4:	74 04                	je     f01014fa <mem_init+0x25c>
f01014f6:	39 c7                	cmp    %eax,%edi
f01014f8:	75 19                	jne    f0101513 <mem_init+0x275>
f01014fa:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01014ff:	68 43 66 10 f0       	push   $0xf0106643
f0101504:	68 03 03 00 00       	push   $0x303
f0101509:	68 1d 66 10 f0       	push   $0xf010661d
f010150e:	e8 2d eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101513:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101519:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f010151f:	c1 e2 0c             	shl    $0xc,%edx
f0101522:	89 f8                	mov    %edi,%eax
f0101524:	29 c8                	sub    %ecx,%eax
f0101526:	c1 f8 03             	sar    $0x3,%eax
f0101529:	c1 e0 0c             	shl    $0xc,%eax
f010152c:	39 d0                	cmp    %edx,%eax
f010152e:	72 19                	jb     f0101549 <mem_init+0x2ab>
f0101530:	68 9c 67 10 f0       	push   $0xf010679c
f0101535:	68 43 66 10 f0       	push   $0xf0106643
f010153a:	68 04 03 00 00       	push   $0x304
f010153f:	68 1d 66 10 f0       	push   $0xf010661d
f0101544:	e8 f7 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101549:	89 f0                	mov    %esi,%eax
f010154b:	29 c8                	sub    %ecx,%eax
f010154d:	c1 f8 03             	sar    $0x3,%eax
f0101550:	c1 e0 0c             	shl    $0xc,%eax
f0101553:	39 c2                	cmp    %eax,%edx
f0101555:	77 19                	ja     f0101570 <mem_init+0x2d2>
f0101557:	68 b9 67 10 f0       	push   $0xf01067b9
f010155c:	68 43 66 10 f0       	push   $0xf0106643
f0101561:	68 05 03 00 00       	push   $0x305
f0101566:	68 1d 66 10 f0       	push   $0xf010661d
f010156b:	e8 d0 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101570:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101573:	29 c8                	sub    %ecx,%eax
f0101575:	c1 f8 03             	sar    $0x3,%eax
f0101578:	c1 e0 0c             	shl    $0xc,%eax
f010157b:	39 c2                	cmp    %eax,%edx
f010157d:	77 19                	ja     f0101598 <mem_init+0x2fa>
f010157f:	68 d6 67 10 f0       	push   $0xf01067d6
f0101584:	68 43 66 10 f0       	push   $0xf0106643
f0101589:	68 06 03 00 00       	push   $0x306
f010158e:	68 1d 66 10 f0       	push   $0xf010661d
f0101593:	e8 a8 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101598:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f010159d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015a0:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f01015a7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015aa:	83 ec 0c             	sub    $0xc,%esp
f01015ad:	6a 00                	push   $0x0
f01015af:	e8 3d f9 ff ff       	call   f0100ef1 <page_alloc>
f01015b4:	83 c4 10             	add    $0x10,%esp
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	74 19                	je     f01015d4 <mem_init+0x336>
f01015bb:	68 f3 67 10 f0       	push   $0xf01067f3
f01015c0:	68 43 66 10 f0       	push   $0xf0106643
f01015c5:	68 0d 03 00 00       	push   $0x30d
f01015ca:	68 1d 66 10 f0       	push   $0xf010661d
f01015cf:	e8 6c ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015d4:	83 ec 0c             	sub    $0xc,%esp
f01015d7:	57                   	push   %edi
f01015d8:	e8 84 f9 ff ff       	call   f0100f61 <page_free>
	page_free(pp1);
f01015dd:	89 34 24             	mov    %esi,(%esp)
f01015e0:	e8 7c f9 ff ff       	call   f0100f61 <page_free>
	page_free(pp2);
f01015e5:	83 c4 04             	add    $0x4,%esp
f01015e8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015eb:	e8 71 f9 ff ff       	call   f0100f61 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015f7:	e8 f5 f8 ff ff       	call   f0100ef1 <page_alloc>
f01015fc:	89 c6                	mov    %eax,%esi
f01015fe:	83 c4 10             	add    $0x10,%esp
f0101601:	85 c0                	test   %eax,%eax
f0101603:	75 19                	jne    f010161e <mem_init+0x380>
f0101605:	68 48 67 10 f0       	push   $0xf0106748
f010160a:	68 43 66 10 f0       	push   $0xf0106643
f010160f:	68 14 03 00 00       	push   $0x314
f0101614:	68 1d 66 10 f0       	push   $0xf010661d
f0101619:	e8 22 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010161e:	83 ec 0c             	sub    $0xc,%esp
f0101621:	6a 00                	push   $0x0
f0101623:	e8 c9 f8 ff ff       	call   f0100ef1 <page_alloc>
f0101628:	89 c7                	mov    %eax,%edi
f010162a:	83 c4 10             	add    $0x10,%esp
f010162d:	85 c0                	test   %eax,%eax
f010162f:	75 19                	jne    f010164a <mem_init+0x3ac>
f0101631:	68 5e 67 10 f0       	push   $0xf010675e
f0101636:	68 43 66 10 f0       	push   $0xf0106643
f010163b:	68 15 03 00 00       	push   $0x315
f0101640:	68 1d 66 10 f0       	push   $0xf010661d
f0101645:	e8 f6 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010164a:	83 ec 0c             	sub    $0xc,%esp
f010164d:	6a 00                	push   $0x0
f010164f:	e8 9d f8 ff ff       	call   f0100ef1 <page_alloc>
f0101654:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101657:	83 c4 10             	add    $0x10,%esp
f010165a:	85 c0                	test   %eax,%eax
f010165c:	75 19                	jne    f0101677 <mem_init+0x3d9>
f010165e:	68 74 67 10 f0       	push   $0xf0106774
f0101663:	68 43 66 10 f0       	push   $0xf0106643
f0101668:	68 16 03 00 00       	push   $0x316
f010166d:	68 1d 66 10 f0       	push   $0xf010661d
f0101672:	e8 c9 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101677:	39 fe                	cmp    %edi,%esi
f0101679:	75 19                	jne    f0101694 <mem_init+0x3f6>
f010167b:	68 8a 67 10 f0       	push   $0xf010678a
f0101680:	68 43 66 10 f0       	push   $0xf0106643
f0101685:	68 18 03 00 00       	push   $0x318
f010168a:	68 1d 66 10 f0       	push   $0xf010661d
f010168f:	e8 ac e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101694:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101697:	39 c7                	cmp    %eax,%edi
f0101699:	74 04                	je     f010169f <mem_init+0x401>
f010169b:	39 c6                	cmp    %eax,%esi
f010169d:	75 19                	jne    f01016b8 <mem_init+0x41a>
f010169f:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01016a4:	68 43 66 10 f0       	push   $0xf0106643
f01016a9:	68 19 03 00 00       	push   $0x319
f01016ae:	68 1d 66 10 f0       	push   $0xf010661d
f01016b3:	e8 88 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016b8:	83 ec 0c             	sub    $0xc,%esp
f01016bb:	6a 00                	push   $0x0
f01016bd:	e8 2f f8 ff ff       	call   f0100ef1 <page_alloc>
f01016c2:	83 c4 10             	add    $0x10,%esp
f01016c5:	85 c0                	test   %eax,%eax
f01016c7:	74 19                	je     f01016e2 <mem_init+0x444>
f01016c9:	68 f3 67 10 f0       	push   $0xf01067f3
f01016ce:	68 43 66 10 f0       	push   $0xf0106643
f01016d3:	68 1a 03 00 00       	push   $0x31a
f01016d8:	68 1d 66 10 f0       	push   $0xf010661d
f01016dd:	e8 5e e9 ff ff       	call   f0100040 <_panic>
f01016e2:	89 f0                	mov    %esi,%eax
f01016e4:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01016ea:	c1 f8 03             	sar    $0x3,%eax
f01016ed:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016f0:	89 c2                	mov    %eax,%edx
f01016f2:	c1 ea 0c             	shr    $0xc,%edx
f01016f5:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01016fb:	72 12                	jb     f010170f <mem_init+0x471>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016fd:	50                   	push   %eax
f01016fe:	68 c4 60 10 f0       	push   $0xf01060c4
f0101703:	6a 58                	push   $0x58
f0101705:	68 29 66 10 f0       	push   $0xf0106629
f010170a:	e8 31 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010170f:	83 ec 04             	sub    $0x4,%esp
f0101712:	68 00 10 00 00       	push   $0x1000
f0101717:	6a 01                	push   $0x1
f0101719:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010171e:	50                   	push   %eax
f010171f:	e8 c2 3c 00 00       	call   f01053e6 <memset>
	page_free(pp0);
f0101724:	89 34 24             	mov    %esi,(%esp)
f0101727:	e8 35 f8 ff ff       	call   f0100f61 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010172c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101733:	e8 b9 f7 ff ff       	call   f0100ef1 <page_alloc>
f0101738:	83 c4 10             	add    $0x10,%esp
f010173b:	85 c0                	test   %eax,%eax
f010173d:	75 19                	jne    f0101758 <mem_init+0x4ba>
f010173f:	68 02 68 10 f0       	push   $0xf0106802
f0101744:	68 43 66 10 f0       	push   $0xf0106643
f0101749:	68 1f 03 00 00       	push   $0x31f
f010174e:	68 1d 66 10 f0       	push   $0xf010661d
f0101753:	e8 e8 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101758:	39 c6                	cmp    %eax,%esi
f010175a:	74 19                	je     f0101775 <mem_init+0x4d7>
f010175c:	68 20 68 10 f0       	push   $0xf0106820
f0101761:	68 43 66 10 f0       	push   $0xf0106643
f0101766:	68 20 03 00 00       	push   $0x320
f010176b:	68 1d 66 10 f0       	push   $0xf010661d
f0101770:	e8 cb e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101775:	89 f0                	mov    %esi,%eax
f0101777:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010177d:	c1 f8 03             	sar    $0x3,%eax
f0101780:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101783:	89 c2                	mov    %eax,%edx
f0101785:	c1 ea 0c             	shr    $0xc,%edx
f0101788:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f010178e:	72 12                	jb     f01017a2 <mem_init+0x504>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101790:	50                   	push   %eax
f0101791:	68 c4 60 10 f0       	push   $0xf01060c4
f0101796:	6a 58                	push   $0x58
f0101798:	68 29 66 10 f0       	push   $0xf0106629
f010179d:	e8 9e e8 ff ff       	call   f0100040 <_panic>
f01017a2:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01017a8:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017ae:	80 38 00             	cmpb   $0x0,(%eax)
f01017b1:	74 19                	je     f01017cc <mem_init+0x52e>
f01017b3:	68 30 68 10 f0       	push   $0xf0106830
f01017b8:	68 43 66 10 f0       	push   $0xf0106643
f01017bd:	68 23 03 00 00       	push   $0x323
f01017c2:	68 1d 66 10 f0       	push   $0xf010661d
f01017c7:	e8 74 e8 ff ff       	call   f0100040 <_panic>
f01017cc:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017cf:	39 d0                	cmp    %edx,%eax
f01017d1:	75 db                	jne    f01017ae <mem_init+0x510>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017d6:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

	// free the pages we took
	page_free(pp0);
f01017db:	83 ec 0c             	sub    $0xc,%esp
f01017de:	56                   	push   %esi
f01017df:	e8 7d f7 ff ff       	call   f0100f61 <page_free>
	page_free(pp1);
f01017e4:	89 3c 24             	mov    %edi,(%esp)
f01017e7:	e8 75 f7 ff ff       	call   f0100f61 <page_free>
	page_free(pp2);
f01017ec:	83 c4 04             	add    $0x4,%esp
f01017ef:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017f2:	e8 6a f7 ff ff       	call   f0100f61 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017f7:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01017fc:	83 c4 10             	add    $0x10,%esp
f01017ff:	eb 05                	jmp    f0101806 <mem_init+0x568>
		--nfree;
f0101801:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101804:	8b 00                	mov    (%eax),%eax
f0101806:	85 c0                	test   %eax,%eax
f0101808:	75 f7                	jne    f0101801 <mem_init+0x563>
		--nfree;
	assert(nfree == 0);
f010180a:	85 db                	test   %ebx,%ebx
f010180c:	74 19                	je     f0101827 <mem_init+0x589>
f010180e:	68 3a 68 10 f0       	push   $0xf010683a
f0101813:	68 43 66 10 f0       	push   $0xf0106643
f0101818:	68 30 03 00 00       	push   $0x330
f010181d:	68 1d 66 10 f0       	push   $0xf010661d
f0101822:	e8 19 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101827:	83 ec 0c             	sub    $0xc,%esp
f010182a:	68 6c 6b 10 f0       	push   $0xf0106b6c
f010182f:	e8 12 1f 00 00       	call   f0103746 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101834:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010183b:	e8 b1 f6 ff ff       	call   f0100ef1 <page_alloc>
f0101840:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101843:	83 c4 10             	add    $0x10,%esp
f0101846:	85 c0                	test   %eax,%eax
f0101848:	75 19                	jne    f0101863 <mem_init+0x5c5>
f010184a:	68 48 67 10 f0       	push   $0xf0106748
f010184f:	68 43 66 10 f0       	push   $0xf0106643
f0101854:	68 96 03 00 00       	push   $0x396
f0101859:	68 1d 66 10 f0       	push   $0xf010661d
f010185e:	e8 dd e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101863:	83 ec 0c             	sub    $0xc,%esp
f0101866:	6a 00                	push   $0x0
f0101868:	e8 84 f6 ff ff       	call   f0100ef1 <page_alloc>
f010186d:	89 c3                	mov    %eax,%ebx
f010186f:	83 c4 10             	add    $0x10,%esp
f0101872:	85 c0                	test   %eax,%eax
f0101874:	75 19                	jne    f010188f <mem_init+0x5f1>
f0101876:	68 5e 67 10 f0       	push   $0xf010675e
f010187b:	68 43 66 10 f0       	push   $0xf0106643
f0101880:	68 97 03 00 00       	push   $0x397
f0101885:	68 1d 66 10 f0       	push   $0xf010661d
f010188a:	e8 b1 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010188f:	83 ec 0c             	sub    $0xc,%esp
f0101892:	6a 00                	push   $0x0
f0101894:	e8 58 f6 ff ff       	call   f0100ef1 <page_alloc>
f0101899:	89 c6                	mov    %eax,%esi
f010189b:	83 c4 10             	add    $0x10,%esp
f010189e:	85 c0                	test   %eax,%eax
f01018a0:	75 19                	jne    f01018bb <mem_init+0x61d>
f01018a2:	68 74 67 10 f0       	push   $0xf0106774
f01018a7:	68 43 66 10 f0       	push   $0xf0106643
f01018ac:	68 98 03 00 00       	push   $0x398
f01018b1:	68 1d 66 10 f0       	push   $0xf010661d
f01018b6:	e8 85 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018bb:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018be:	75 19                	jne    f01018d9 <mem_init+0x63b>
f01018c0:	68 8a 67 10 f0       	push   $0xf010678a
f01018c5:	68 43 66 10 f0       	push   $0xf0106643
f01018ca:	68 9b 03 00 00       	push   $0x39b
f01018cf:	68 1d 66 10 f0       	push   $0xf010661d
f01018d4:	e8 67 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018d9:	39 c3                	cmp    %eax,%ebx
f01018db:	74 05                	je     f01018e2 <mem_init+0x644>
f01018dd:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018e0:	75 19                	jne    f01018fb <mem_init+0x65d>
f01018e2:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01018e7:	68 43 66 10 f0       	push   $0xf0106643
f01018ec:	68 9c 03 00 00       	push   $0x39c
f01018f1:	68 1d 66 10 f0       	push   $0xf010661d
f01018f6:	e8 45 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018fb:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101900:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101903:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f010190a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010190d:	83 ec 0c             	sub    $0xc,%esp
f0101910:	6a 00                	push   $0x0
f0101912:	e8 da f5 ff ff       	call   f0100ef1 <page_alloc>
f0101917:	83 c4 10             	add    $0x10,%esp
f010191a:	85 c0                	test   %eax,%eax
f010191c:	74 19                	je     f0101937 <mem_init+0x699>
f010191e:	68 f3 67 10 f0       	push   $0xf01067f3
f0101923:	68 43 66 10 f0       	push   $0xf0106643
f0101928:	68 a3 03 00 00       	push   $0x3a3
f010192d:	68 1d 66 10 f0       	push   $0xf010661d
f0101932:	e8 09 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101937:	83 ec 04             	sub    $0x4,%esp
f010193a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010193d:	50                   	push   %eax
f010193e:	6a 00                	push   $0x0
f0101940:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101946:	e8 97 f7 ff ff       	call   f01010e2 <page_lookup>
f010194b:	83 c4 10             	add    $0x10,%esp
f010194e:	85 c0                	test   %eax,%eax
f0101950:	74 19                	je     f010196b <mem_init+0x6cd>
f0101952:	68 8c 6b 10 f0       	push   $0xf0106b8c
f0101957:	68 43 66 10 f0       	push   $0xf0106643
f010195c:	68 a6 03 00 00       	push   $0x3a6
f0101961:	68 1d 66 10 f0       	push   $0xf010661d
f0101966:	e8 d5 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010196b:	6a 02                	push   $0x2
f010196d:	6a 00                	push   $0x0
f010196f:	53                   	push   %ebx
f0101970:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101976:	e8 4d f8 ff ff       	call   f01011c8 <page_insert>
f010197b:	83 c4 10             	add    $0x10,%esp
f010197e:	85 c0                	test   %eax,%eax
f0101980:	78 19                	js     f010199b <mem_init+0x6fd>
f0101982:	68 c4 6b 10 f0       	push   $0xf0106bc4
f0101987:	68 43 66 10 f0       	push   $0xf0106643
f010198c:	68 a9 03 00 00       	push   $0x3a9
f0101991:	68 1d 66 10 f0       	push   $0xf010661d
f0101996:	e8 a5 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010199b:	83 ec 0c             	sub    $0xc,%esp
f010199e:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019a1:	e8 bb f5 ff ff       	call   f0100f61 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019a6:	6a 02                	push   $0x2
f01019a8:	6a 00                	push   $0x0
f01019aa:	53                   	push   %ebx
f01019ab:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01019b1:	e8 12 f8 ff ff       	call   f01011c8 <page_insert>
f01019b6:	83 c4 20             	add    $0x20,%esp
f01019b9:	85 c0                	test   %eax,%eax
f01019bb:	74 19                	je     f01019d6 <mem_init+0x738>
f01019bd:	68 f4 6b 10 f0       	push   $0xf0106bf4
f01019c2:	68 43 66 10 f0       	push   $0xf0106643
f01019c7:	68 ad 03 00 00       	push   $0x3ad
f01019cc:	68 1d 66 10 f0       	push   $0xf010661d
f01019d1:	e8 6a e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019d6:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019dc:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f01019e1:	89 c1                	mov    %eax,%ecx
f01019e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019e6:	8b 17                	mov    (%edi),%edx
f01019e8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019f1:	29 c8                	sub    %ecx,%eax
f01019f3:	c1 f8 03             	sar    $0x3,%eax
f01019f6:	c1 e0 0c             	shl    $0xc,%eax
f01019f9:	39 c2                	cmp    %eax,%edx
f01019fb:	74 19                	je     f0101a16 <mem_init+0x778>
f01019fd:	68 24 6c 10 f0       	push   $0xf0106c24
f0101a02:	68 43 66 10 f0       	push   $0xf0106643
f0101a07:	68 ae 03 00 00       	push   $0x3ae
f0101a0c:	68 1d 66 10 f0       	push   $0xf010661d
f0101a11:	e8 2a e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a16:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a1b:	89 f8                	mov    %edi,%eax
f0101a1d:	e8 8c f0 ff ff       	call   f0100aae <check_va2pa>
f0101a22:	89 da                	mov    %ebx,%edx
f0101a24:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a27:	c1 fa 03             	sar    $0x3,%edx
f0101a2a:	c1 e2 0c             	shl    $0xc,%edx
f0101a2d:	39 d0                	cmp    %edx,%eax
f0101a2f:	74 19                	je     f0101a4a <mem_init+0x7ac>
f0101a31:	68 4c 6c 10 f0       	push   $0xf0106c4c
f0101a36:	68 43 66 10 f0       	push   $0xf0106643
f0101a3b:	68 af 03 00 00       	push   $0x3af
f0101a40:	68 1d 66 10 f0       	push   $0xf010661d
f0101a45:	e8 f6 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a4a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a4f:	74 19                	je     f0101a6a <mem_init+0x7cc>
f0101a51:	68 45 68 10 f0       	push   $0xf0106845
f0101a56:	68 43 66 10 f0       	push   $0xf0106643
f0101a5b:	68 b0 03 00 00       	push   $0x3b0
f0101a60:	68 1d 66 10 f0       	push   $0xf010661d
f0101a65:	e8 d6 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a6d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a72:	74 19                	je     f0101a8d <mem_init+0x7ef>
f0101a74:	68 56 68 10 f0       	push   $0xf0106856
f0101a79:	68 43 66 10 f0       	push   $0xf0106643
f0101a7e:	68 b1 03 00 00       	push   $0x3b1
f0101a83:	68 1d 66 10 f0       	push   $0xf010661d
f0101a88:	e8 b3 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a8d:	6a 02                	push   $0x2
f0101a8f:	68 00 10 00 00       	push   $0x1000
f0101a94:	56                   	push   %esi
f0101a95:	57                   	push   %edi
f0101a96:	e8 2d f7 ff ff       	call   f01011c8 <page_insert>
f0101a9b:	83 c4 10             	add    $0x10,%esp
f0101a9e:	85 c0                	test   %eax,%eax
f0101aa0:	74 19                	je     f0101abb <mem_init+0x81d>
f0101aa2:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0101aa7:	68 43 66 10 f0       	push   $0xf0106643
f0101aac:	68 b4 03 00 00       	push   $0x3b4
f0101ab1:	68 1d 66 10 f0       	push   $0xf010661d
f0101ab6:	e8 85 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101abb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac0:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101ac5:	e8 e4 ef ff ff       	call   f0100aae <check_va2pa>
f0101aca:	89 f2                	mov    %esi,%edx
f0101acc:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101ad2:	c1 fa 03             	sar    $0x3,%edx
f0101ad5:	c1 e2 0c             	shl    $0xc,%edx
f0101ad8:	39 d0                	cmp    %edx,%eax
f0101ada:	74 19                	je     f0101af5 <mem_init+0x857>
f0101adc:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0101ae1:	68 43 66 10 f0       	push   $0xf0106643
f0101ae6:	68 b5 03 00 00       	push   $0x3b5
f0101aeb:	68 1d 66 10 f0       	push   $0xf010661d
f0101af0:	e8 4b e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101af5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101afa:	74 19                	je     f0101b15 <mem_init+0x877>
f0101afc:	68 67 68 10 f0       	push   $0xf0106867
f0101b01:	68 43 66 10 f0       	push   $0xf0106643
f0101b06:	68 b6 03 00 00       	push   $0x3b6
f0101b0b:	68 1d 66 10 f0       	push   $0xf010661d
f0101b10:	e8 2b e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b15:	83 ec 0c             	sub    $0xc,%esp
f0101b18:	6a 00                	push   $0x0
f0101b1a:	e8 d2 f3 ff ff       	call   f0100ef1 <page_alloc>
f0101b1f:	83 c4 10             	add    $0x10,%esp
f0101b22:	85 c0                	test   %eax,%eax
f0101b24:	74 19                	je     f0101b3f <mem_init+0x8a1>
f0101b26:	68 f3 67 10 f0       	push   $0xf01067f3
f0101b2b:	68 43 66 10 f0       	push   $0xf0106643
f0101b30:	68 b9 03 00 00       	push   $0x3b9
f0101b35:	68 1d 66 10 f0       	push   $0xf010661d
f0101b3a:	e8 01 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b3f:	6a 02                	push   $0x2
f0101b41:	68 00 10 00 00       	push   $0x1000
f0101b46:	56                   	push   %esi
f0101b47:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b4d:	e8 76 f6 ff ff       	call   f01011c8 <page_insert>
f0101b52:	83 c4 10             	add    $0x10,%esp
f0101b55:	85 c0                	test   %eax,%eax
f0101b57:	74 19                	je     f0101b72 <mem_init+0x8d4>
f0101b59:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0101b5e:	68 43 66 10 f0       	push   $0xf0106643
f0101b63:	68 bc 03 00 00       	push   $0x3bc
f0101b68:	68 1d 66 10 f0       	push   $0xf010661d
f0101b6d:	e8 ce e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b72:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b77:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101b7c:	e8 2d ef ff ff       	call   f0100aae <check_va2pa>
f0101b81:	89 f2                	mov    %esi,%edx
f0101b83:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101b89:	c1 fa 03             	sar    $0x3,%edx
f0101b8c:	c1 e2 0c             	shl    $0xc,%edx
f0101b8f:	39 d0                	cmp    %edx,%eax
f0101b91:	74 19                	je     f0101bac <mem_init+0x90e>
f0101b93:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0101b98:	68 43 66 10 f0       	push   $0xf0106643
f0101b9d:	68 bd 03 00 00       	push   $0x3bd
f0101ba2:	68 1d 66 10 f0       	push   $0xf010661d
f0101ba7:	e8 94 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bb1:	74 19                	je     f0101bcc <mem_init+0x92e>
f0101bb3:	68 67 68 10 f0       	push   $0xf0106867
f0101bb8:	68 43 66 10 f0       	push   $0xf0106643
f0101bbd:	68 be 03 00 00       	push   $0x3be
f0101bc2:	68 1d 66 10 f0       	push   $0xf010661d
f0101bc7:	e8 74 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bcc:	83 ec 0c             	sub    $0xc,%esp
f0101bcf:	6a 00                	push   $0x0
f0101bd1:	e8 1b f3 ff ff       	call   f0100ef1 <page_alloc>
f0101bd6:	83 c4 10             	add    $0x10,%esp
f0101bd9:	85 c0                	test   %eax,%eax
f0101bdb:	74 19                	je     f0101bf6 <mem_init+0x958>
f0101bdd:	68 f3 67 10 f0       	push   $0xf01067f3
f0101be2:	68 43 66 10 f0       	push   $0xf0106643
f0101be7:	68 c2 03 00 00       	push   $0x3c2
f0101bec:	68 1d 66 10 f0       	push   $0xf010661d
f0101bf1:	e8 4a e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bf6:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101bfc:	8b 02                	mov    (%edx),%eax
f0101bfe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c03:	89 c1                	mov    %eax,%ecx
f0101c05:	c1 e9 0c             	shr    $0xc,%ecx
f0101c08:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101c0e:	72 15                	jb     f0101c25 <mem_init+0x987>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c10:	50                   	push   %eax
f0101c11:	68 c4 60 10 f0       	push   $0xf01060c4
f0101c16:	68 c5 03 00 00       	push   $0x3c5
f0101c1b:	68 1d 66 10 f0       	push   $0xf010661d
f0101c20:	e8 1b e4 ff ff       	call   f0100040 <_panic>
f0101c25:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c2d:	83 ec 04             	sub    $0x4,%esp
f0101c30:	6a 00                	push   $0x0
f0101c32:	68 00 10 00 00       	push   $0x1000
f0101c37:	52                   	push   %edx
f0101c38:	e8 88 f3 ff ff       	call   f0100fc5 <pgdir_walk>
f0101c3d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c40:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c43:	83 c4 10             	add    $0x10,%esp
f0101c46:	39 d0                	cmp    %edx,%eax
f0101c48:	74 19                	je     f0101c63 <mem_init+0x9c5>
f0101c4a:	68 e8 6c 10 f0       	push   $0xf0106ce8
f0101c4f:	68 43 66 10 f0       	push   $0xf0106643
f0101c54:	68 c6 03 00 00       	push   $0x3c6
f0101c59:	68 1d 66 10 f0       	push   $0xf010661d
f0101c5e:	e8 dd e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c63:	6a 06                	push   $0x6
f0101c65:	68 00 10 00 00       	push   $0x1000
f0101c6a:	56                   	push   %esi
f0101c6b:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101c71:	e8 52 f5 ff ff       	call   f01011c8 <page_insert>
f0101c76:	83 c4 10             	add    $0x10,%esp
f0101c79:	85 c0                	test   %eax,%eax
f0101c7b:	74 19                	je     f0101c96 <mem_init+0x9f8>
f0101c7d:	68 28 6d 10 f0       	push   $0xf0106d28
f0101c82:	68 43 66 10 f0       	push   $0xf0106643
f0101c87:	68 c9 03 00 00       	push   $0x3c9
f0101c8c:	68 1d 66 10 f0       	push   $0xf010661d
f0101c91:	e8 aa e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c96:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101c9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca1:	89 f8                	mov    %edi,%eax
f0101ca3:	e8 06 ee ff ff       	call   f0100aae <check_va2pa>
f0101ca8:	89 f2                	mov    %esi,%edx
f0101caa:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101cb0:	c1 fa 03             	sar    $0x3,%edx
f0101cb3:	c1 e2 0c             	shl    $0xc,%edx
f0101cb6:	39 d0                	cmp    %edx,%eax
f0101cb8:	74 19                	je     f0101cd3 <mem_init+0xa35>
f0101cba:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0101cbf:	68 43 66 10 f0       	push   $0xf0106643
f0101cc4:	68 ca 03 00 00       	push   $0x3ca
f0101cc9:	68 1d 66 10 f0       	push   $0xf010661d
f0101cce:	e8 6d e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101cd3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cd8:	74 19                	je     f0101cf3 <mem_init+0xa55>
f0101cda:	68 67 68 10 f0       	push   $0xf0106867
f0101cdf:	68 43 66 10 f0       	push   $0xf0106643
f0101ce4:	68 cb 03 00 00       	push   $0x3cb
f0101ce9:	68 1d 66 10 f0       	push   $0xf010661d
f0101cee:	e8 4d e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cf3:	83 ec 04             	sub    $0x4,%esp
f0101cf6:	6a 00                	push   $0x0
f0101cf8:	68 00 10 00 00       	push   $0x1000
f0101cfd:	57                   	push   %edi
f0101cfe:	e8 c2 f2 ff ff       	call   f0100fc5 <pgdir_walk>
f0101d03:	83 c4 10             	add    $0x10,%esp
f0101d06:	f6 00 04             	testb  $0x4,(%eax)
f0101d09:	75 19                	jne    f0101d24 <mem_init+0xa86>
f0101d0b:	68 68 6d 10 f0       	push   $0xf0106d68
f0101d10:	68 43 66 10 f0       	push   $0xf0106643
f0101d15:	68 cc 03 00 00       	push   $0x3cc
f0101d1a:	68 1d 66 10 f0       	push   $0xf010661d
f0101d1f:	e8 1c e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d24:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101d29:	f6 00 04             	testb  $0x4,(%eax)
f0101d2c:	75 19                	jne    f0101d47 <mem_init+0xaa9>
f0101d2e:	68 78 68 10 f0       	push   $0xf0106878
f0101d33:	68 43 66 10 f0       	push   $0xf0106643
f0101d38:	68 cd 03 00 00       	push   $0x3cd
f0101d3d:	68 1d 66 10 f0       	push   $0xf010661d
f0101d42:	e8 f9 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d47:	6a 02                	push   $0x2
f0101d49:	68 00 10 00 00       	push   $0x1000
f0101d4e:	56                   	push   %esi
f0101d4f:	50                   	push   %eax
f0101d50:	e8 73 f4 ff ff       	call   f01011c8 <page_insert>
f0101d55:	83 c4 10             	add    $0x10,%esp
f0101d58:	85 c0                	test   %eax,%eax
f0101d5a:	74 19                	je     f0101d75 <mem_init+0xad7>
f0101d5c:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0101d61:	68 43 66 10 f0       	push   $0xf0106643
f0101d66:	68 d0 03 00 00       	push   $0x3d0
f0101d6b:	68 1d 66 10 f0       	push   $0xf010661d
f0101d70:	e8 cb e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d75:	83 ec 04             	sub    $0x4,%esp
f0101d78:	6a 00                	push   $0x0
f0101d7a:	68 00 10 00 00       	push   $0x1000
f0101d7f:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d85:	e8 3b f2 ff ff       	call   f0100fc5 <pgdir_walk>
f0101d8a:	83 c4 10             	add    $0x10,%esp
f0101d8d:	f6 00 02             	testb  $0x2,(%eax)
f0101d90:	75 19                	jne    f0101dab <mem_init+0xb0d>
f0101d92:	68 9c 6d 10 f0       	push   $0xf0106d9c
f0101d97:	68 43 66 10 f0       	push   $0xf0106643
f0101d9c:	68 d1 03 00 00       	push   $0x3d1
f0101da1:	68 1d 66 10 f0       	push   $0xf010661d
f0101da6:	e8 95 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dab:	83 ec 04             	sub    $0x4,%esp
f0101dae:	6a 00                	push   $0x0
f0101db0:	68 00 10 00 00       	push   $0x1000
f0101db5:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101dbb:	e8 05 f2 ff ff       	call   f0100fc5 <pgdir_walk>
f0101dc0:	83 c4 10             	add    $0x10,%esp
f0101dc3:	f6 00 04             	testb  $0x4,(%eax)
f0101dc6:	74 19                	je     f0101de1 <mem_init+0xb43>
f0101dc8:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101dcd:	68 43 66 10 f0       	push   $0xf0106643
f0101dd2:	68 d2 03 00 00       	push   $0x3d2
f0101dd7:	68 1d 66 10 f0       	push   $0xf010661d
f0101ddc:	e8 5f e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101de1:	6a 02                	push   $0x2
f0101de3:	68 00 00 40 00       	push   $0x400000
f0101de8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101deb:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101df1:	e8 d2 f3 ff ff       	call   f01011c8 <page_insert>
f0101df6:	83 c4 10             	add    $0x10,%esp
f0101df9:	85 c0                	test   %eax,%eax
f0101dfb:	78 19                	js     f0101e16 <mem_init+0xb78>
f0101dfd:	68 08 6e 10 f0       	push   $0xf0106e08
f0101e02:	68 43 66 10 f0       	push   $0xf0106643
f0101e07:	68 d5 03 00 00       	push   $0x3d5
f0101e0c:	68 1d 66 10 f0       	push   $0xf010661d
f0101e11:	e8 2a e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e16:	6a 02                	push   $0x2
f0101e18:	68 00 10 00 00       	push   $0x1000
f0101e1d:	53                   	push   %ebx
f0101e1e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101e24:	e8 9f f3 ff ff       	call   f01011c8 <page_insert>
f0101e29:	83 c4 10             	add    $0x10,%esp
f0101e2c:	85 c0                	test   %eax,%eax
f0101e2e:	74 19                	je     f0101e49 <mem_init+0xbab>
f0101e30:	68 40 6e 10 f0       	push   $0xf0106e40
f0101e35:	68 43 66 10 f0       	push   $0xf0106643
f0101e3a:	68 d8 03 00 00       	push   $0x3d8
f0101e3f:	68 1d 66 10 f0       	push   $0xf010661d
f0101e44:	e8 f7 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e49:	83 ec 04             	sub    $0x4,%esp
f0101e4c:	6a 00                	push   $0x0
f0101e4e:	68 00 10 00 00       	push   $0x1000
f0101e53:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101e59:	e8 67 f1 ff ff       	call   f0100fc5 <pgdir_walk>
f0101e5e:	83 c4 10             	add    $0x10,%esp
f0101e61:	f6 00 04             	testb  $0x4,(%eax)
f0101e64:	74 19                	je     f0101e7f <mem_init+0xbe1>
f0101e66:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101e6b:	68 43 66 10 f0       	push   $0xf0106643
f0101e70:	68 d9 03 00 00       	push   $0x3d9
f0101e75:	68 1d 66 10 f0       	push   $0xf010661d
f0101e7a:	e8 c1 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e7f:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101e85:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e8a:	89 f8                	mov    %edi,%eax
f0101e8c:	e8 1d ec ff ff       	call   f0100aae <check_va2pa>
f0101e91:	89 c1                	mov    %eax,%ecx
f0101e93:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e96:	89 d8                	mov    %ebx,%eax
f0101e98:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101e9e:	c1 f8 03             	sar    $0x3,%eax
f0101ea1:	c1 e0 0c             	shl    $0xc,%eax
f0101ea4:	39 c1                	cmp    %eax,%ecx
f0101ea6:	74 19                	je     f0101ec1 <mem_init+0xc23>
f0101ea8:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0101ead:	68 43 66 10 f0       	push   $0xf0106643
f0101eb2:	68 dc 03 00 00       	push   $0x3dc
f0101eb7:	68 1d 66 10 f0       	push   $0xf010661d
f0101ebc:	e8 7f e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ec1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ec6:	89 f8                	mov    %edi,%eax
f0101ec8:	e8 e1 eb ff ff       	call   f0100aae <check_va2pa>
f0101ecd:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ed0:	74 19                	je     f0101eeb <mem_init+0xc4d>
f0101ed2:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101ed7:	68 43 66 10 f0       	push   $0xf0106643
f0101edc:	68 dd 03 00 00       	push   $0x3dd
f0101ee1:	68 1d 66 10 f0       	push   $0xf010661d
f0101ee6:	e8 55 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101eeb:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ef0:	74 19                	je     f0101f0b <mem_init+0xc6d>
f0101ef2:	68 8e 68 10 f0       	push   $0xf010688e
f0101ef7:	68 43 66 10 f0       	push   $0xf0106643
f0101efc:	68 df 03 00 00       	push   $0x3df
f0101f01:	68 1d 66 10 f0       	push   $0xf010661d
f0101f06:	e8 35 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f0b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f10:	74 19                	je     f0101f2b <mem_init+0xc8d>
f0101f12:	68 9f 68 10 f0       	push   $0xf010689f
f0101f17:	68 43 66 10 f0       	push   $0xf0106643
f0101f1c:	68 e0 03 00 00       	push   $0x3e0
f0101f21:	68 1d 66 10 f0       	push   $0xf010661d
f0101f26:	e8 15 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f2b:	83 ec 0c             	sub    $0xc,%esp
f0101f2e:	6a 00                	push   $0x0
f0101f30:	e8 bc ef ff ff       	call   f0100ef1 <page_alloc>
f0101f35:	83 c4 10             	add    $0x10,%esp
f0101f38:	85 c0                	test   %eax,%eax
f0101f3a:	74 04                	je     f0101f40 <mem_init+0xca2>
f0101f3c:	39 c6                	cmp    %eax,%esi
f0101f3e:	74 19                	je     f0101f59 <mem_init+0xcbb>
f0101f40:	68 d8 6e 10 f0       	push   $0xf0106ed8
f0101f45:	68 43 66 10 f0       	push   $0xf0106643
f0101f4a:	68 e3 03 00 00       	push   $0x3e3
f0101f4f:	68 1d 66 10 f0       	push   $0xf010661d
f0101f54:	e8 e7 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f59:	83 ec 08             	sub    $0x8,%esp
f0101f5c:	6a 00                	push   $0x0
f0101f5e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f64:	e8 14 f2 ff ff       	call   f010117d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f69:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101f6f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f74:	89 f8                	mov    %edi,%eax
f0101f76:	e8 33 eb ff ff       	call   f0100aae <check_va2pa>
f0101f7b:	83 c4 10             	add    $0x10,%esp
f0101f7e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f81:	74 19                	je     f0101f9c <mem_init+0xcfe>
f0101f83:	68 fc 6e 10 f0       	push   $0xf0106efc
f0101f88:	68 43 66 10 f0       	push   $0xf0106643
f0101f8d:	68 e7 03 00 00       	push   $0x3e7
f0101f92:	68 1d 66 10 f0       	push   $0xf010661d
f0101f97:	e8 a4 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa1:	89 f8                	mov    %edi,%eax
f0101fa3:	e8 06 eb ff ff       	call   f0100aae <check_va2pa>
f0101fa8:	89 da                	mov    %ebx,%edx
f0101faa:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101fb0:	c1 fa 03             	sar    $0x3,%edx
f0101fb3:	c1 e2 0c             	shl    $0xc,%edx
f0101fb6:	39 d0                	cmp    %edx,%eax
f0101fb8:	74 19                	je     f0101fd3 <mem_init+0xd35>
f0101fba:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101fbf:	68 43 66 10 f0       	push   $0xf0106643
f0101fc4:	68 e8 03 00 00       	push   $0x3e8
f0101fc9:	68 1d 66 10 f0       	push   $0xf010661d
f0101fce:	e8 6d e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fd3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fd8:	74 19                	je     f0101ff3 <mem_init+0xd55>
f0101fda:	68 45 68 10 f0       	push   $0xf0106845
f0101fdf:	68 43 66 10 f0       	push   $0xf0106643
f0101fe4:	68 e9 03 00 00       	push   $0x3e9
f0101fe9:	68 1d 66 10 f0       	push   $0xf010661d
f0101fee:	e8 4d e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ff3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ff8:	74 19                	je     f0102013 <mem_init+0xd75>
f0101ffa:	68 9f 68 10 f0       	push   $0xf010689f
f0101fff:	68 43 66 10 f0       	push   $0xf0106643
f0102004:	68 ea 03 00 00       	push   $0x3ea
f0102009:	68 1d 66 10 f0       	push   $0xf010661d
f010200e:	e8 2d e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102013:	6a 00                	push   $0x0
f0102015:	68 00 10 00 00       	push   $0x1000
f010201a:	53                   	push   %ebx
f010201b:	57                   	push   %edi
f010201c:	e8 a7 f1 ff ff       	call   f01011c8 <page_insert>
f0102021:	83 c4 10             	add    $0x10,%esp
f0102024:	85 c0                	test   %eax,%eax
f0102026:	74 19                	je     f0102041 <mem_init+0xda3>
f0102028:	68 20 6f 10 f0       	push   $0xf0106f20
f010202d:	68 43 66 10 f0       	push   $0xf0106643
f0102032:	68 ed 03 00 00       	push   $0x3ed
f0102037:	68 1d 66 10 f0       	push   $0xf010661d
f010203c:	e8 ff df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102041:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102046:	75 19                	jne    f0102061 <mem_init+0xdc3>
f0102048:	68 b0 68 10 f0       	push   $0xf01068b0
f010204d:	68 43 66 10 f0       	push   $0xf0106643
f0102052:	68 ee 03 00 00       	push   $0x3ee
f0102057:	68 1d 66 10 f0       	push   $0xf010661d
f010205c:	e8 df df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102061:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102064:	74 19                	je     f010207f <mem_init+0xde1>
f0102066:	68 bc 68 10 f0       	push   $0xf01068bc
f010206b:	68 43 66 10 f0       	push   $0xf0106643
f0102070:	68 ef 03 00 00       	push   $0x3ef
f0102075:	68 1d 66 10 f0       	push   $0xf010661d
f010207a:	e8 c1 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010207f:	83 ec 08             	sub    $0x8,%esp
f0102082:	68 00 10 00 00       	push   $0x1000
f0102087:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010208d:	e8 eb f0 ff ff       	call   f010117d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102092:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102098:	ba 00 00 00 00       	mov    $0x0,%edx
f010209d:	89 f8                	mov    %edi,%eax
f010209f:	e8 0a ea ff ff       	call   f0100aae <check_va2pa>
f01020a4:	83 c4 10             	add    $0x10,%esp
f01020a7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020aa:	74 19                	je     f01020c5 <mem_init+0xe27>
f01020ac:	68 fc 6e 10 f0       	push   $0xf0106efc
f01020b1:	68 43 66 10 f0       	push   $0xf0106643
f01020b6:	68 f3 03 00 00       	push   $0x3f3
f01020bb:	68 1d 66 10 f0       	push   $0xf010661d
f01020c0:	e8 7b df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ca:	89 f8                	mov    %edi,%eax
f01020cc:	e8 dd e9 ff ff       	call   f0100aae <check_va2pa>
f01020d1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020d4:	74 19                	je     f01020ef <mem_init+0xe51>
f01020d6:	68 58 6f 10 f0       	push   $0xf0106f58
f01020db:	68 43 66 10 f0       	push   $0xf0106643
f01020e0:	68 f4 03 00 00       	push   $0x3f4
f01020e5:	68 1d 66 10 f0       	push   $0xf010661d
f01020ea:	e8 51 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020ef:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020f4:	74 19                	je     f010210f <mem_init+0xe71>
f01020f6:	68 d1 68 10 f0       	push   $0xf01068d1
f01020fb:	68 43 66 10 f0       	push   $0xf0106643
f0102100:	68 f5 03 00 00       	push   $0x3f5
f0102105:	68 1d 66 10 f0       	push   $0xf010661d
f010210a:	e8 31 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010210f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102114:	74 19                	je     f010212f <mem_init+0xe91>
f0102116:	68 9f 68 10 f0       	push   $0xf010689f
f010211b:	68 43 66 10 f0       	push   $0xf0106643
f0102120:	68 f6 03 00 00       	push   $0x3f6
f0102125:	68 1d 66 10 f0       	push   $0xf010661d
f010212a:	e8 11 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010212f:	83 ec 0c             	sub    $0xc,%esp
f0102132:	6a 00                	push   $0x0
f0102134:	e8 b8 ed ff ff       	call   f0100ef1 <page_alloc>
f0102139:	83 c4 10             	add    $0x10,%esp
f010213c:	39 c3                	cmp    %eax,%ebx
f010213e:	75 04                	jne    f0102144 <mem_init+0xea6>
f0102140:	85 c0                	test   %eax,%eax
f0102142:	75 19                	jne    f010215d <mem_init+0xebf>
f0102144:	68 80 6f 10 f0       	push   $0xf0106f80
f0102149:	68 43 66 10 f0       	push   $0xf0106643
f010214e:	68 f9 03 00 00       	push   $0x3f9
f0102153:	68 1d 66 10 f0       	push   $0xf010661d
f0102158:	e8 e3 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010215d:	83 ec 0c             	sub    $0xc,%esp
f0102160:	6a 00                	push   $0x0
f0102162:	e8 8a ed ff ff       	call   f0100ef1 <page_alloc>
f0102167:	83 c4 10             	add    $0x10,%esp
f010216a:	85 c0                	test   %eax,%eax
f010216c:	74 19                	je     f0102187 <mem_init+0xee9>
f010216e:	68 f3 67 10 f0       	push   $0xf01067f3
f0102173:	68 43 66 10 f0       	push   $0xf0106643
f0102178:	68 fc 03 00 00       	push   $0x3fc
f010217d:	68 1d 66 10 f0       	push   $0xf010661d
f0102182:	e8 b9 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102187:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f010218d:	8b 11                	mov    (%ecx),%edx
f010218f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102195:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102198:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010219e:	c1 f8 03             	sar    $0x3,%eax
f01021a1:	c1 e0 0c             	shl    $0xc,%eax
f01021a4:	39 c2                	cmp    %eax,%edx
f01021a6:	74 19                	je     f01021c1 <mem_init+0xf23>
f01021a8:	68 24 6c 10 f0       	push   $0xf0106c24
f01021ad:	68 43 66 10 f0       	push   $0xf0106643
f01021b2:	68 ff 03 00 00       	push   $0x3ff
f01021b7:	68 1d 66 10 f0       	push   $0xf010661d
f01021bc:	e8 7f de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01021c1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ca:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021cf:	74 19                	je     f01021ea <mem_init+0xf4c>
f01021d1:	68 56 68 10 f0       	push   $0xf0106856
f01021d6:	68 43 66 10 f0       	push   $0xf0106643
f01021db:	68 01 04 00 00       	push   $0x401
f01021e0:	68 1d 66 10 f0       	push   $0xf010661d
f01021e5:	e8 56 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ed:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021f3:	83 ec 0c             	sub    $0xc,%esp
f01021f6:	50                   	push   %eax
f01021f7:	e8 65 ed ff ff       	call   f0100f61 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021fc:	83 c4 0c             	add    $0xc,%esp
f01021ff:	6a 01                	push   $0x1
f0102201:	68 00 10 40 00       	push   $0x401000
f0102206:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010220c:	e8 b4 ed ff ff       	call   f0100fc5 <pgdir_walk>
f0102211:	89 c7                	mov    %eax,%edi
f0102213:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102216:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010221b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010221e:	8b 40 04             	mov    0x4(%eax),%eax
f0102221:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102226:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f010222c:	89 c2                	mov    %eax,%edx
f010222e:	c1 ea 0c             	shr    $0xc,%edx
f0102231:	83 c4 10             	add    $0x10,%esp
f0102234:	39 ca                	cmp    %ecx,%edx
f0102236:	72 15                	jb     f010224d <mem_init+0xfaf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102238:	50                   	push   %eax
f0102239:	68 c4 60 10 f0       	push   $0xf01060c4
f010223e:	68 08 04 00 00       	push   $0x408
f0102243:	68 1d 66 10 f0       	push   $0xf010661d
f0102248:	e8 f3 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010224d:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102252:	39 c7                	cmp    %eax,%edi
f0102254:	74 19                	je     f010226f <mem_init+0xfd1>
f0102256:	68 e2 68 10 f0       	push   $0xf01068e2
f010225b:	68 43 66 10 f0       	push   $0xf0106643
f0102260:	68 09 04 00 00       	push   $0x409
f0102265:	68 1d 66 10 f0       	push   $0xf010661d
f010226a:	e8 d1 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010226f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102272:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102279:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010227c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102282:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102288:	c1 f8 03             	sar    $0x3,%eax
f010228b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010228e:	89 c2                	mov    %eax,%edx
f0102290:	c1 ea 0c             	shr    $0xc,%edx
f0102293:	39 d1                	cmp    %edx,%ecx
f0102295:	77 12                	ja     f01022a9 <mem_init+0x100b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102297:	50                   	push   %eax
f0102298:	68 c4 60 10 f0       	push   $0xf01060c4
f010229d:	6a 58                	push   $0x58
f010229f:	68 29 66 10 f0       	push   $0xf0106629
f01022a4:	e8 97 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022a9:	83 ec 04             	sub    $0x4,%esp
f01022ac:	68 00 10 00 00       	push   $0x1000
f01022b1:	68 ff 00 00 00       	push   $0xff
f01022b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022bb:	50                   	push   %eax
f01022bc:	e8 25 31 00 00       	call   f01053e6 <memset>
	page_free(pp0);
f01022c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022c4:	89 3c 24             	mov    %edi,(%esp)
f01022c7:	e8 95 ec ff ff       	call   f0100f61 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022cc:	83 c4 0c             	add    $0xc,%esp
f01022cf:	6a 01                	push   $0x1
f01022d1:	6a 00                	push   $0x0
f01022d3:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01022d9:	e8 e7 ec ff ff       	call   f0100fc5 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022de:	89 fa                	mov    %edi,%edx
f01022e0:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f01022e6:	c1 fa 03             	sar    $0x3,%edx
f01022e9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022ec:	89 d0                	mov    %edx,%eax
f01022ee:	c1 e8 0c             	shr    $0xc,%eax
f01022f1:	83 c4 10             	add    $0x10,%esp
f01022f4:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01022fa:	72 12                	jb     f010230e <mem_init+0x1070>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022fc:	52                   	push   %edx
f01022fd:	68 c4 60 10 f0       	push   $0xf01060c4
f0102302:	6a 58                	push   $0x58
f0102304:	68 29 66 10 f0       	push   $0xf0106629
f0102309:	e8 32 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010230e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102317:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010231d:	f6 00 01             	testb  $0x1,(%eax)
f0102320:	74 19                	je     f010233b <mem_init+0x109d>
f0102322:	68 fa 68 10 f0       	push   $0xf01068fa
f0102327:	68 43 66 10 f0       	push   $0xf0106643
f010232c:	68 13 04 00 00       	push   $0x413
f0102331:	68 1d 66 10 f0       	push   $0xf010661d
f0102336:	e8 05 dd ff ff       	call   f0100040 <_panic>
f010233b:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010233e:	39 d0                	cmp    %edx,%eax
f0102340:	75 db                	jne    f010231d <mem_init+0x107f>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102342:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102347:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010234d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102350:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102356:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102359:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240

	// free the pages we took
	page_free(pp0);
f010235f:	83 ec 0c             	sub    $0xc,%esp
f0102362:	50                   	push   %eax
f0102363:	e8 f9 eb ff ff       	call   f0100f61 <page_free>
	page_free(pp1);
f0102368:	89 1c 24             	mov    %ebx,(%esp)
f010236b:	e8 f1 eb ff ff       	call   f0100f61 <page_free>
	page_free(pp2);
f0102370:	89 34 24             	mov    %esi,(%esp)
f0102373:	e8 e9 eb ff ff       	call   f0100f61 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102378:	83 c4 08             	add    $0x8,%esp
f010237b:	68 01 10 00 00       	push   $0x1001
f0102380:	6a 00                	push   $0x0
f0102382:	e8 a7 ee ff ff       	call   f010122e <mmio_map_region>
f0102387:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102389:	83 c4 08             	add    $0x8,%esp
f010238c:	68 00 10 00 00       	push   $0x1000
f0102391:	6a 00                	push   $0x0
f0102393:	e8 96 ee ff ff       	call   f010122e <mmio_map_region>
f0102398:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010239a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01023a0:	83 c4 10             	add    $0x10,%esp
f01023a3:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01023a9:	76 07                	jbe    f01023b2 <mem_init+0x1114>
f01023ab:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01023b0:	76 19                	jbe    f01023cb <mem_init+0x112d>
f01023b2:	68 a4 6f 10 f0       	push   $0xf0106fa4
f01023b7:	68 43 66 10 f0       	push   $0xf0106643
f01023bc:	68 23 04 00 00       	push   $0x423
f01023c1:	68 1d 66 10 f0       	push   $0xf010661d
f01023c6:	e8 75 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01023cb:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01023d1:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023d7:	77 08                	ja     f01023e1 <mem_init+0x1143>
f01023d9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023df:	77 19                	ja     f01023fa <mem_init+0x115c>
f01023e1:	68 cc 6f 10 f0       	push   $0xf0106fcc
f01023e6:	68 43 66 10 f0       	push   $0xf0106643
f01023eb:	68 24 04 00 00       	push   $0x424
f01023f0:	68 1d 66 10 f0       	push   $0xf010661d
f01023f5:	e8 46 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023fa:	89 da                	mov    %ebx,%edx
f01023fc:	09 f2                	or     %esi,%edx
f01023fe:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102404:	74 19                	je     f010241f <mem_init+0x1181>
f0102406:	68 f4 6f 10 f0       	push   $0xf0106ff4
f010240b:	68 43 66 10 f0       	push   $0xf0106643
f0102410:	68 26 04 00 00       	push   $0x426
f0102415:	68 1d 66 10 f0       	push   $0xf010661d
f010241a:	e8 21 dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010241f:	39 c6                	cmp    %eax,%esi
f0102421:	73 19                	jae    f010243c <mem_init+0x119e>
f0102423:	68 11 69 10 f0       	push   $0xf0106911
f0102428:	68 43 66 10 f0       	push   $0xf0106643
f010242d:	68 28 04 00 00       	push   $0x428
f0102432:	68 1d 66 10 f0       	push   $0xf010661d
f0102437:	e8 04 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010243c:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102442:	89 da                	mov    %ebx,%edx
f0102444:	89 f8                	mov    %edi,%eax
f0102446:	e8 63 e6 ff ff       	call   f0100aae <check_va2pa>
f010244b:	85 c0                	test   %eax,%eax
f010244d:	74 19                	je     f0102468 <mem_init+0x11ca>
f010244f:	68 1c 70 10 f0       	push   $0xf010701c
f0102454:	68 43 66 10 f0       	push   $0xf0106643
f0102459:	68 2a 04 00 00       	push   $0x42a
f010245e:	68 1d 66 10 f0       	push   $0xf010661d
f0102463:	e8 d8 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102468:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010246e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102471:	89 c2                	mov    %eax,%edx
f0102473:	89 f8                	mov    %edi,%eax
f0102475:	e8 34 e6 ff ff       	call   f0100aae <check_va2pa>
f010247a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010247f:	74 19                	je     f010249a <mem_init+0x11fc>
f0102481:	68 40 70 10 f0       	push   $0xf0107040
f0102486:	68 43 66 10 f0       	push   $0xf0106643
f010248b:	68 2b 04 00 00       	push   $0x42b
f0102490:	68 1d 66 10 f0       	push   $0xf010661d
f0102495:	e8 a6 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010249a:	89 f2                	mov    %esi,%edx
f010249c:	89 f8                	mov    %edi,%eax
f010249e:	e8 0b e6 ff ff       	call   f0100aae <check_va2pa>
f01024a3:	85 c0                	test   %eax,%eax
f01024a5:	74 19                	je     f01024c0 <mem_init+0x1222>
f01024a7:	68 70 70 10 f0       	push   $0xf0107070
f01024ac:	68 43 66 10 f0       	push   $0xf0106643
f01024b1:	68 2c 04 00 00       	push   $0x42c
f01024b6:	68 1d 66 10 f0       	push   $0xf010661d
f01024bb:	e8 80 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024c0:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024c6:	89 f8                	mov    %edi,%eax
f01024c8:	e8 e1 e5 ff ff       	call   f0100aae <check_va2pa>
f01024cd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024d0:	74 19                	je     f01024eb <mem_init+0x124d>
f01024d2:	68 94 70 10 f0       	push   $0xf0107094
f01024d7:	68 43 66 10 f0       	push   $0xf0106643
f01024dc:	68 2d 04 00 00       	push   $0x42d
f01024e1:	68 1d 66 10 f0       	push   $0xf010661d
f01024e6:	e8 55 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024eb:	83 ec 04             	sub    $0x4,%esp
f01024ee:	6a 00                	push   $0x0
f01024f0:	53                   	push   %ebx
f01024f1:	57                   	push   %edi
f01024f2:	e8 ce ea ff ff       	call   f0100fc5 <pgdir_walk>
f01024f7:	83 c4 10             	add    $0x10,%esp
f01024fa:	f6 00 1a             	testb  $0x1a,(%eax)
f01024fd:	75 19                	jne    f0102518 <mem_init+0x127a>
f01024ff:	68 c0 70 10 f0       	push   $0xf01070c0
f0102504:	68 43 66 10 f0       	push   $0xf0106643
f0102509:	68 2f 04 00 00       	push   $0x42f
f010250e:	68 1d 66 10 f0       	push   $0xf010661d
f0102513:	e8 28 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102518:	83 ec 04             	sub    $0x4,%esp
f010251b:	6a 00                	push   $0x0
f010251d:	53                   	push   %ebx
f010251e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102524:	e8 9c ea ff ff       	call   f0100fc5 <pgdir_walk>
f0102529:	8b 00                	mov    (%eax),%eax
f010252b:	83 c4 10             	add    $0x10,%esp
f010252e:	83 e0 04             	and    $0x4,%eax
f0102531:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102534:	74 19                	je     f010254f <mem_init+0x12b1>
f0102536:	68 04 71 10 f0       	push   $0xf0107104
f010253b:	68 43 66 10 f0       	push   $0xf0106643
f0102540:	68 30 04 00 00       	push   $0x430
f0102545:	68 1d 66 10 f0       	push   $0xf010661d
f010254a:	e8 f1 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010254f:	83 ec 04             	sub    $0x4,%esp
f0102552:	6a 00                	push   $0x0
f0102554:	53                   	push   %ebx
f0102555:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010255b:	e8 65 ea ff ff       	call   f0100fc5 <pgdir_walk>
f0102560:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102566:	83 c4 0c             	add    $0xc,%esp
f0102569:	6a 00                	push   $0x0
f010256b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010256e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102574:	e8 4c ea ff ff       	call   f0100fc5 <pgdir_walk>
f0102579:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010257f:	83 c4 0c             	add    $0xc,%esp
f0102582:	6a 00                	push   $0x0
f0102584:	56                   	push   %esi
f0102585:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010258b:	e8 35 ea ff ff       	call   f0100fc5 <pgdir_walk>
f0102590:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102596:	c7 04 24 23 69 10 f0 	movl   $0xf0106923,(%esp)
f010259d:	e8 a4 11 00 00       	call   f0103746 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	cprintf("pages map va:%x, pa:%x\n", UPAGES, PADDR(pages));
f01025a2:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025a7:	83 c4 10             	add    $0x10,%esp
f01025aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025af:	77 15                	ja     f01025c6 <mem_init+0x1328>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025b1:	50                   	push   %eax
f01025b2:	68 e8 60 10 f0       	push   $0xf01060e8
f01025b7:	68 bd 00 00 00       	push   $0xbd
f01025bc:	68 1d 66 10 f0       	push   $0xf010661d
f01025c1:	e8 7a da ff ff       	call   f0100040 <_panic>
f01025c6:	83 ec 04             	sub    $0x4,%esp
f01025c9:	05 00 00 00 10       	add    $0x10000000,%eax
f01025ce:	50                   	push   %eax
f01025cf:	68 00 00 00 ef       	push   $0xef000000
f01025d4:	68 3c 69 10 f0       	push   $0xf010693c
f01025d9:	e8 68 11 00 00       	call   f0103746 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01025de:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025e3:	83 c4 10             	add    $0x10,%esp
f01025e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025eb:	77 15                	ja     f0102602 <mem_init+0x1364>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025ed:	50                   	push   %eax
f01025ee:	68 e8 60 10 f0       	push   $0xf01060e8
f01025f3:	68 be 00 00 00       	push   $0xbe
f01025f8:	68 1d 66 10 f0       	push   $0xf010661d
f01025fd:	e8 3e da ff ff       	call   f0100040 <_panic>
f0102602:	83 ec 08             	sub    $0x8,%esp
f0102605:	6a 04                	push   $0x4
f0102607:	05 00 00 00 10       	add    $0x10000000,%eax
f010260c:	50                   	push   %eax
f010260d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102612:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102617:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010261c:	e8 37 ea ff ff       	call   f0101058 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102621:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102626:	83 c4 10             	add    $0x10,%esp
f0102629:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010262e:	77 15                	ja     f0102645 <mem_init+0x13a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102630:	50                   	push   %eax
f0102631:	68 e8 60 10 f0       	push   $0xf01060e8
f0102636:	68 c7 00 00 00       	push   $0xc7
f010263b:	68 1d 66 10 f0       	push   $0xf010661d
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
f0102645:	83 ec 08             	sub    $0x8,%esp
f0102648:	6a 04                	push   $0x4
f010264a:	05 00 00 00 10       	add    $0x10000000,%eax
f010264f:	50                   	push   %eax
f0102650:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102655:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010265a:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010265f:	e8 f4 e9 ff ff       	call   f0101058 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102664:	83 c4 10             	add    $0x10,%esp
f0102667:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f010266c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102671:	77 15                	ja     f0102688 <mem_init+0x13ea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102673:	50                   	push   %eax
f0102674:	68 e8 60 10 f0       	push   $0xf01060e8
f0102679:	68 d5 00 00 00       	push   $0xd5
f010267e:	68 1d 66 10 f0       	push   $0xf010661d
f0102683:	e8 b8 d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// cprintf("bootstack map va:%x, pa:%x\n", KSTACKTOP-KSTKSIZE, PADDR(bootstack));
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102688:	83 ec 08             	sub    $0x8,%esp
f010268b:	6a 02                	push   $0x2
f010268d:	68 00 60 11 00       	push   $0x116000
f0102692:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102697:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010269c:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01026a1:	e8 b2 e9 ff ff       	call   f0101058 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01026a6:	83 c4 08             	add    $0x8,%esp
f01026a9:	6a 02                	push   $0x2
f01026ab:	6a 00                	push   $0x0
f01026ad:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026b2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026b7:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01026bc:	e8 97 e9 ff ff       	call   f0101058 <boot_map_region>
f01026c1:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f01026c8:	83 c4 10             	add    $0x10,%esp
f01026cb:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
f01026d0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026d5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026db:	77 15                	ja     f01026f2 <mem_init+0x1454>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026dd:	53                   	push   %ebx
f01026de:	68 e8 60 10 f0       	push   $0xf01060e8
f01026e3:	68 16 01 00 00       	push   $0x116
f01026e8:	68 1d 66 10 f0       	push   $0xf010661d
f01026ed:	e8 4e d9 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		int kstacktop_i = KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f01026f2:	83 ec 08             	sub    $0x8,%esp
f01026f5:	6a 02                	push   $0x2
f01026f7:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01026fd:	50                   	push   %eax
f01026fe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102703:	89 f2                	mov    %esi,%edx
f0102705:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010270a:	e8 49 e9 ff ff       	call   f0101058 <boot_map_region>
f010270f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102715:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
f010271b:	83 c4 10             	add    $0x10,%esp
f010271e:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102723:	39 d8                	cmp    %ebx,%eax
f0102725:	75 ae                	jne    f01026d5 <mem_init+0x1437>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102727:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010272d:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0102732:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102735:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010273c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102741:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102744:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010274a:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010274d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102752:	eb 55                	jmp    f01027a9 <mem_init+0x150b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102754:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010275a:	89 f8                	mov    %edi,%eax
f010275c:	e8 4d e3 ff ff       	call   f0100aae <check_va2pa>
f0102761:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102768:	77 15                	ja     f010277f <mem_init+0x14e1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010276a:	56                   	push   %esi
f010276b:	68 e8 60 10 f0       	push   $0xf01060e8
f0102770:	68 48 03 00 00       	push   $0x348
f0102775:	68 1d 66 10 f0       	push   $0xf010661d
f010277a:	e8 c1 d8 ff ff       	call   f0100040 <_panic>
f010277f:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102786:	39 c2                	cmp    %eax,%edx
f0102788:	74 19                	je     f01027a3 <mem_init+0x1505>
f010278a:	68 38 71 10 f0       	push   $0xf0107138
f010278f:	68 43 66 10 f0       	push   $0xf0106643
f0102794:	68 48 03 00 00       	push   $0x348
f0102799:	68 1d 66 10 f0       	push   $0xf010661d
f010279e:	e8 9d d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027a9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027ac:	77 a6                	ja     f0102754 <mem_init+0x14b6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027ae:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027b4:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027b7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027bc:	89 da                	mov    %ebx,%edx
f01027be:	89 f8                	mov    %edi,%eax
f01027c0:	e8 e9 e2 ff ff       	call   f0100aae <check_va2pa>
f01027c5:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01027cc:	77 15                	ja     f01027e3 <mem_init+0x1545>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ce:	56                   	push   %esi
f01027cf:	68 e8 60 10 f0       	push   $0xf01060e8
f01027d4:	68 4d 03 00 00       	push   $0x34d
f01027d9:	68 1d 66 10 f0       	push   $0xf010661d
f01027de:	e8 5d d8 ff ff       	call   f0100040 <_panic>
f01027e3:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027ea:	39 d0                	cmp    %edx,%eax
f01027ec:	74 19                	je     f0102807 <mem_init+0x1569>
f01027ee:	68 6c 71 10 f0       	push   $0xf010716c
f01027f3:	68 43 66 10 f0       	push   $0xf0106643
f01027f8:	68 4d 03 00 00       	push   $0x34d
f01027fd:	68 1d 66 10 f0       	push   $0xf010661d
f0102802:	e8 39 d8 ff ff       	call   f0100040 <_panic>
f0102807:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010280d:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102813:	75 a7                	jne    f01027bc <mem_init+0x151e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102815:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102818:	c1 e6 0c             	shl    $0xc,%esi
f010281b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102820:	eb 30                	jmp    f0102852 <mem_init+0x15b4>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102822:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102828:	89 f8                	mov    %edi,%eax
f010282a:	e8 7f e2 ff ff       	call   f0100aae <check_va2pa>
f010282f:	39 c3                	cmp    %eax,%ebx
f0102831:	74 19                	je     f010284c <mem_init+0x15ae>
f0102833:	68 a0 71 10 f0       	push   $0xf01071a0
f0102838:	68 43 66 10 f0       	push   $0xf0106643
f010283d:	68 51 03 00 00       	push   $0x351
f0102842:	68 1d 66 10 f0       	push   $0xf010661d
f0102847:	e8 f4 d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010284c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102852:	39 f3                	cmp    %esi,%ebx
f0102854:	72 cc                	jb     f0102822 <mem_init+0x1584>
f0102856:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010285b:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010285e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102861:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102864:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010286a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010286d:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010286f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102872:	05 00 80 00 20       	add    $0x20008000,%eax
f0102877:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010287a:	89 da                	mov    %ebx,%edx
f010287c:	89 f8                	mov    %edi,%eax
f010287e:	e8 2b e2 ff ff       	call   f0100aae <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102883:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102889:	77 15                	ja     f01028a0 <mem_init+0x1602>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010288b:	56                   	push   %esi
f010288c:	68 e8 60 10 f0       	push   $0xf01060e8
f0102891:	68 59 03 00 00       	push   $0x359
f0102896:	68 1d 66 10 f0       	push   $0xf010661d
f010289b:	e8 a0 d7 ff ff       	call   f0100040 <_panic>
f01028a0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01028a3:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f01028aa:	39 d0                	cmp    %edx,%eax
f01028ac:	74 19                	je     f01028c7 <mem_init+0x1629>
f01028ae:	68 c8 71 10 f0       	push   $0xf01071c8
f01028b3:	68 43 66 10 f0       	push   $0xf0106643
f01028b8:	68 59 03 00 00       	push   $0x359
f01028bd:	68 1d 66 10 f0       	push   $0xf010661d
f01028c2:	e8 79 d7 ff ff       	call   f0100040 <_panic>
f01028c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028cd:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01028d0:	75 a8                	jne    f010287a <mem_init+0x15dc>
f01028d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028d5:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028db:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028de:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028e0:	89 da                	mov    %ebx,%edx
f01028e2:	89 f8                	mov    %edi,%eax
f01028e4:	e8 c5 e1 ff ff       	call   f0100aae <check_va2pa>
f01028e9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028ec:	74 19                	je     f0102907 <mem_init+0x1669>
f01028ee:	68 10 72 10 f0       	push   $0xf0107210
f01028f3:	68 43 66 10 f0       	push   $0xf0106643
f01028f8:	68 5b 03 00 00       	push   $0x35b
f01028fd:	68 1d 66 10 f0       	push   $0xf010661d
f0102902:	e8 39 d7 ff ff       	call   f0100040 <_panic>
f0102907:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010290d:	39 de                	cmp    %ebx,%esi
f010290f:	75 cf                	jne    f01028e0 <mem_init+0x1642>
f0102911:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102914:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f010291b:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102922:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102928:	81 fe 00 10 27 f0    	cmp    $0xf0271000,%esi
f010292e:	0f 85 2d ff ff ff    	jne    f0102861 <mem_init+0x15c3>
f0102934:	b8 00 00 00 00       	mov    $0x0,%eax
f0102939:	eb 2a                	jmp    f0102965 <mem_init+0x16c7>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010293b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102941:	83 fa 04             	cmp    $0x4,%edx
f0102944:	77 1f                	ja     f0102965 <mem_init+0x16c7>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102946:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010294a:	75 7e                	jne    f01029ca <mem_init+0x172c>
f010294c:	68 54 69 10 f0       	push   $0xf0106954
f0102951:	68 43 66 10 f0       	push   $0xf0106643
f0102956:	68 66 03 00 00       	push   $0x366
f010295b:	68 1d 66 10 f0       	push   $0xf010661d
f0102960:	e8 db d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102965:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010296a:	76 3f                	jbe    f01029ab <mem_init+0x170d>
				assert(pgdir[i] & PTE_P);
f010296c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010296f:	f6 c2 01             	test   $0x1,%dl
f0102972:	75 19                	jne    f010298d <mem_init+0x16ef>
f0102974:	68 54 69 10 f0       	push   $0xf0106954
f0102979:	68 43 66 10 f0       	push   $0xf0106643
f010297e:	68 6a 03 00 00       	push   $0x36a
f0102983:	68 1d 66 10 f0       	push   $0xf010661d
f0102988:	e8 b3 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010298d:	f6 c2 02             	test   $0x2,%dl
f0102990:	75 38                	jne    f01029ca <mem_init+0x172c>
f0102992:	68 65 69 10 f0       	push   $0xf0106965
f0102997:	68 43 66 10 f0       	push   $0xf0106643
f010299c:	68 6b 03 00 00       	push   $0x36b
f01029a1:	68 1d 66 10 f0       	push   $0xf010661d
f01029a6:	e8 95 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029ab:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029af:	74 19                	je     f01029ca <mem_init+0x172c>
f01029b1:	68 76 69 10 f0       	push   $0xf0106976
f01029b6:	68 43 66 10 f0       	push   $0xf0106643
f01029bb:	68 6d 03 00 00       	push   $0x36d
f01029c0:	68 1d 66 10 f0       	push   $0xf010661d
f01029c5:	e8 76 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029ca:	83 c0 01             	add    $0x1,%eax
f01029cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01029d2:	0f 86 63 ff ff ff    	jbe    f010293b <mem_init+0x169d>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029d8:	83 ec 0c             	sub    $0xc,%esp
f01029db:	68 34 72 10 f0       	push   $0xf0107234
f01029e0:	e8 61 0d 00 00       	call   f0103746 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029e5:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029ea:	83 c4 10             	add    $0x10,%esp
f01029ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029f2:	77 15                	ja     f0102a09 <mem_init+0x176b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029f4:	50                   	push   %eax
f01029f5:	68 e8 60 10 f0       	push   $0xf01060e8
f01029fa:	68 ee 00 00 00       	push   $0xee
f01029ff:	68 1d 66 10 f0       	push   $0xf010661d
f0102a04:	e8 37 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a09:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a0e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a11:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a16:	e8 f7 e0 ff ff       	call   f0100b12 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a1b:	0f 20 c0             	mov    %cr0,%eax
f0102a1e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a21:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a26:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a29:	83 ec 0c             	sub    $0xc,%esp
f0102a2c:	6a 00                	push   $0x0
f0102a2e:	e8 be e4 ff ff       	call   f0100ef1 <page_alloc>
f0102a33:	89 c3                	mov    %eax,%ebx
f0102a35:	83 c4 10             	add    $0x10,%esp
f0102a38:	85 c0                	test   %eax,%eax
f0102a3a:	75 19                	jne    f0102a55 <mem_init+0x17b7>
f0102a3c:	68 48 67 10 f0       	push   $0xf0106748
f0102a41:	68 43 66 10 f0       	push   $0xf0106643
f0102a46:	68 45 04 00 00       	push   $0x445
f0102a4b:	68 1d 66 10 f0       	push   $0xf010661d
f0102a50:	e8 eb d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a55:	83 ec 0c             	sub    $0xc,%esp
f0102a58:	6a 00                	push   $0x0
f0102a5a:	e8 92 e4 ff ff       	call   f0100ef1 <page_alloc>
f0102a5f:	89 c7                	mov    %eax,%edi
f0102a61:	83 c4 10             	add    $0x10,%esp
f0102a64:	85 c0                	test   %eax,%eax
f0102a66:	75 19                	jne    f0102a81 <mem_init+0x17e3>
f0102a68:	68 5e 67 10 f0       	push   $0xf010675e
f0102a6d:	68 43 66 10 f0       	push   $0xf0106643
f0102a72:	68 46 04 00 00       	push   $0x446
f0102a77:	68 1d 66 10 f0       	push   $0xf010661d
f0102a7c:	e8 bf d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a81:	83 ec 0c             	sub    $0xc,%esp
f0102a84:	6a 00                	push   $0x0
f0102a86:	e8 66 e4 ff ff       	call   f0100ef1 <page_alloc>
f0102a8b:	89 c6                	mov    %eax,%esi
f0102a8d:	83 c4 10             	add    $0x10,%esp
f0102a90:	85 c0                	test   %eax,%eax
f0102a92:	75 19                	jne    f0102aad <mem_init+0x180f>
f0102a94:	68 74 67 10 f0       	push   $0xf0106774
f0102a99:	68 43 66 10 f0       	push   $0xf0106643
f0102a9e:	68 47 04 00 00       	push   $0x447
f0102aa3:	68 1d 66 10 f0       	push   $0xf010661d
f0102aa8:	e8 93 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102aad:	83 ec 0c             	sub    $0xc,%esp
f0102ab0:	53                   	push   %ebx
f0102ab1:	e8 ab e4 ff ff       	call   f0100f61 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ab6:	89 f8                	mov    %edi,%eax
f0102ab8:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102abe:	c1 f8 03             	sar    $0x3,%eax
f0102ac1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ac4:	89 c2                	mov    %eax,%edx
f0102ac6:	c1 ea 0c             	shr    $0xc,%edx
f0102ac9:	83 c4 10             	add    $0x10,%esp
f0102acc:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102ad2:	72 12                	jb     f0102ae6 <mem_init+0x1848>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ad4:	50                   	push   %eax
f0102ad5:	68 c4 60 10 f0       	push   $0xf01060c4
f0102ada:	6a 58                	push   $0x58
f0102adc:	68 29 66 10 f0       	push   $0xf0106629
f0102ae1:	e8 5a d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ae6:	83 ec 04             	sub    $0x4,%esp
f0102ae9:	68 00 10 00 00       	push   $0x1000
f0102aee:	6a 01                	push   $0x1
f0102af0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102af5:	50                   	push   %eax
f0102af6:	e8 eb 28 00 00       	call   f01053e6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102afb:	89 f0                	mov    %esi,%eax
f0102afd:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102b03:	c1 f8 03             	sar    $0x3,%eax
f0102b06:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b09:	89 c2                	mov    %eax,%edx
f0102b0b:	c1 ea 0c             	shr    $0xc,%edx
f0102b0e:	83 c4 10             	add    $0x10,%esp
f0102b11:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102b17:	72 12                	jb     f0102b2b <mem_init+0x188d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b19:	50                   	push   %eax
f0102b1a:	68 c4 60 10 f0       	push   $0xf01060c4
f0102b1f:	6a 58                	push   $0x58
f0102b21:	68 29 66 10 f0       	push   $0xf0106629
f0102b26:	e8 15 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b2b:	83 ec 04             	sub    $0x4,%esp
f0102b2e:	68 00 10 00 00       	push   $0x1000
f0102b33:	6a 02                	push   $0x2
f0102b35:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b3a:	50                   	push   %eax
f0102b3b:	e8 a6 28 00 00       	call   f01053e6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b40:	6a 02                	push   $0x2
f0102b42:	68 00 10 00 00       	push   $0x1000
f0102b47:	57                   	push   %edi
f0102b48:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102b4e:	e8 75 e6 ff ff       	call   f01011c8 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b53:	83 c4 20             	add    $0x20,%esp
f0102b56:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b5b:	74 19                	je     f0102b76 <mem_init+0x18d8>
f0102b5d:	68 45 68 10 f0       	push   $0xf0106845
f0102b62:	68 43 66 10 f0       	push   $0xf0106643
f0102b67:	68 4c 04 00 00       	push   $0x44c
f0102b6c:	68 1d 66 10 f0       	push   $0xf010661d
f0102b71:	e8 ca d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b76:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b7d:	01 01 01 
f0102b80:	74 19                	je     f0102b9b <mem_init+0x18fd>
f0102b82:	68 54 72 10 f0       	push   $0xf0107254
f0102b87:	68 43 66 10 f0       	push   $0xf0106643
f0102b8c:	68 4d 04 00 00       	push   $0x44d
f0102b91:	68 1d 66 10 f0       	push   $0xf010661d
f0102b96:	e8 a5 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b9b:	6a 02                	push   $0x2
f0102b9d:	68 00 10 00 00       	push   $0x1000
f0102ba2:	56                   	push   %esi
f0102ba3:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102ba9:	e8 1a e6 ff ff       	call   f01011c8 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bae:	83 c4 10             	add    $0x10,%esp
f0102bb1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bb8:	02 02 02 
f0102bbb:	74 19                	je     f0102bd6 <mem_init+0x1938>
f0102bbd:	68 78 72 10 f0       	push   $0xf0107278
f0102bc2:	68 43 66 10 f0       	push   $0xf0106643
f0102bc7:	68 4f 04 00 00       	push   $0x44f
f0102bcc:	68 1d 66 10 f0       	push   $0xf010661d
f0102bd1:	e8 6a d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102bd6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102bdb:	74 19                	je     f0102bf6 <mem_init+0x1958>
f0102bdd:	68 67 68 10 f0       	push   $0xf0106867
f0102be2:	68 43 66 10 f0       	push   $0xf0106643
f0102be7:	68 50 04 00 00       	push   $0x450
f0102bec:	68 1d 66 10 f0       	push   $0xf010661d
f0102bf1:	e8 4a d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bf6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bfb:	74 19                	je     f0102c16 <mem_init+0x1978>
f0102bfd:	68 d1 68 10 f0       	push   $0xf01068d1
f0102c02:	68 43 66 10 f0       	push   $0xf0106643
f0102c07:	68 51 04 00 00       	push   $0x451
f0102c0c:	68 1d 66 10 f0       	push   $0xf010661d
f0102c11:	e8 2a d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c16:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c1d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c20:	89 f0                	mov    %esi,%eax
f0102c22:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c28:	c1 f8 03             	sar    $0x3,%eax
f0102c2b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c2e:	89 c2                	mov    %eax,%edx
f0102c30:	c1 ea 0c             	shr    $0xc,%edx
f0102c33:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c39:	72 12                	jb     f0102c4d <mem_init+0x19af>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c3b:	50                   	push   %eax
f0102c3c:	68 c4 60 10 f0       	push   $0xf01060c4
f0102c41:	6a 58                	push   $0x58
f0102c43:	68 29 66 10 f0       	push   $0xf0106629
f0102c48:	e8 f3 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c4d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c54:	03 03 03 
f0102c57:	74 19                	je     f0102c72 <mem_init+0x19d4>
f0102c59:	68 9c 72 10 f0       	push   $0xf010729c
f0102c5e:	68 43 66 10 f0       	push   $0xf0106643
f0102c63:	68 53 04 00 00       	push   $0x453
f0102c68:	68 1d 66 10 f0       	push   $0xf010661d
f0102c6d:	e8 ce d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c72:	83 ec 08             	sub    $0x8,%esp
f0102c75:	68 00 10 00 00       	push   $0x1000
f0102c7a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102c80:	e8 f8 e4 ff ff       	call   f010117d <page_remove>
	assert(pp2->pp_ref == 0);
f0102c85:	83 c4 10             	add    $0x10,%esp
f0102c88:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c8d:	74 19                	je     f0102ca8 <mem_init+0x1a0a>
f0102c8f:	68 9f 68 10 f0       	push   $0xf010689f
f0102c94:	68 43 66 10 f0       	push   $0xf0106643
f0102c99:	68 55 04 00 00       	push   $0x455
f0102c9e:	68 1d 66 10 f0       	push   $0xf010661d
f0102ca3:	e8 98 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ca8:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102cae:	8b 11                	mov    (%ecx),%edx
f0102cb0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102cb6:	89 d8                	mov    %ebx,%eax
f0102cb8:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102cbe:	c1 f8 03             	sar    $0x3,%eax
f0102cc1:	c1 e0 0c             	shl    $0xc,%eax
f0102cc4:	39 c2                	cmp    %eax,%edx
f0102cc6:	74 19                	je     f0102ce1 <mem_init+0x1a43>
f0102cc8:	68 24 6c 10 f0       	push   $0xf0106c24
f0102ccd:	68 43 66 10 f0       	push   $0xf0106643
f0102cd2:	68 58 04 00 00       	push   $0x458
f0102cd7:	68 1d 66 10 f0       	push   $0xf010661d
f0102cdc:	e8 5f d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102ce1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ce7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cec:	74 19                	je     f0102d07 <mem_init+0x1a69>
f0102cee:	68 56 68 10 f0       	push   $0xf0106856
f0102cf3:	68 43 66 10 f0       	push   $0xf0106643
f0102cf8:	68 5a 04 00 00       	push   $0x45a
f0102cfd:	68 1d 66 10 f0       	push   $0xf010661d
f0102d02:	e8 39 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d07:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d0d:	83 ec 0c             	sub    $0xc,%esp
f0102d10:	53                   	push   %ebx
f0102d11:	e8 4b e2 ff ff       	call   f0100f61 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d16:	c7 04 24 c8 72 10 f0 	movl   $0xf01072c8,(%esp)
f0102d1d:	e8 24 0a 00 00       	call   f0103746 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d22:	83 c4 10             	add    $0x10,%esp
f0102d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d28:	5b                   	pop    %ebx
f0102d29:	5e                   	pop    %esi
f0102d2a:	5f                   	pop    %edi
f0102d2b:	5d                   	pop    %ebp
f0102d2c:	c3                   	ret    

f0102d2d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d2d:	55                   	push   %ebp
f0102d2e:	89 e5                	mov    %esp,%ebp
f0102d30:	57                   	push   %edi
f0102d31:	56                   	push   %esi
f0102d32:	53                   	push   %ebx
f0102d33:	83 ec 1c             	sub    $0x1c,%esp
f0102d36:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d39:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE), end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102d3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d3f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102d45:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d48:	03 45 10             	add    0x10(%ebp),%eax
f0102d4b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t check_va = (uint32_t)va;

	// cprintf("check va:%x, len:%x, begin:%x, end:%x\n", va, len, begin, end);

	for (; begin < end; begin += PGSIZE) {
f0102d58:	eb 3f                	jmp    f0102d99 <user_mem_check+0x6c>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)begin, 0);
f0102d5a:	83 ec 04             	sub    $0x4,%esp
f0102d5d:	6a 00                	push   $0x0
f0102d5f:	53                   	push   %ebx
f0102d60:	ff 77 60             	pushl  0x60(%edi)
f0102d63:	e8 5d e2 ff ff       	call   f0100fc5 <pgdir_walk>
		if ((begin >= ULIM) || !pte || (*pte & perm) != perm) {
f0102d68:	83 c4 10             	add    $0x10,%esp
f0102d6b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d71:	77 0c                	ja     f0102d7f <user_mem_check+0x52>
f0102d73:	85 c0                	test   %eax,%eax
f0102d75:	74 08                	je     f0102d7f <user_mem_check+0x52>
f0102d77:	89 f2                	mov    %esi,%edx
f0102d79:	23 10                	and    (%eax),%edx
f0102d7b:	39 d6                	cmp    %edx,%esi
f0102d7d:	74 14                	je     f0102d93 <user_mem_check+0x66>
			user_mem_check_addr = (begin >= check_va ? begin : check_va);
f0102d7f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d82:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102d86:	89 1d 3c f2 22 f0    	mov    %ebx,0xf022f23c
			return -E_FAULT;
f0102d8c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d91:	eb 10                	jmp    f0102da3 <user_mem_check+0x76>
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE), end = (uint32_t)ROUNDUP(va + len, PGSIZE);
	uint32_t check_va = (uint32_t)va;

	// cprintf("check va:%x, len:%x, begin:%x, end:%x\n", va, len, begin, end);

	for (; begin < end; begin += PGSIZE) {
f0102d93:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d99:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d9c:	72 bc                	jb     f0102d5a <user_mem_check+0x2d>
			user_mem_check_addr = (begin >= check_va ? begin : check_va);
			return -E_FAULT;
		}
	}

	return 0;
f0102d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102da6:	5b                   	pop    %ebx
f0102da7:	5e                   	pop    %esi
f0102da8:	5f                   	pop    %edi
f0102da9:	5d                   	pop    %ebp
f0102daa:	c3                   	ret    

f0102dab <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102dab:	55                   	push   %ebp
f0102dac:	89 e5                	mov    %esp,%ebp
f0102dae:	53                   	push   %ebx
f0102daf:	83 ec 04             	sub    $0x4,%esp
f0102db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U | PTE_P) < 0) {
f0102db5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102db8:	83 c8 05             	or     $0x5,%eax
f0102dbb:	50                   	push   %eax
f0102dbc:	ff 75 10             	pushl  0x10(%ebp)
f0102dbf:	ff 75 0c             	pushl  0xc(%ebp)
f0102dc2:	53                   	push   %ebx
f0102dc3:	e8 65 ff ff ff       	call   f0102d2d <user_mem_check>
f0102dc8:	83 c4 10             	add    $0x10,%esp
f0102dcb:	85 c0                	test   %eax,%eax
f0102dcd:	79 21                	jns    f0102df0 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102dcf:	83 ec 04             	sub    $0x4,%esp
f0102dd2:	ff 35 3c f2 22 f0    	pushl  0xf022f23c
f0102dd8:	ff 73 48             	pushl  0x48(%ebx)
f0102ddb:	68 f4 72 10 f0       	push   $0xf01072f4
f0102de0:	e8 61 09 00 00       	call   f0103746 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102de5:	89 1c 24             	mov    %ebx,(%esp)
f0102de8:	e8 13 06 00 00       	call   f0103400 <env_destroy>
f0102ded:	83 c4 10             	add    $0x10,%esp
	}
}
f0102df0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102df3:	c9                   	leave  
f0102df4:	c3                   	ret    

f0102df5 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102df5:	55                   	push   %ebp
f0102df6:	89 e5                	mov    %esp,%ebp
f0102df8:	57                   	push   %edi
f0102df9:	56                   	push   %esi
f0102dfa:	53                   	push   %ebx
f0102dfb:	83 ec 0c             	sub    $0xc,%esp
f0102dfe:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va + len, PGSIZE);
f0102e00:	89 d3                	mov    %edx,%ebx
f0102e02:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e08:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102e0f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102e15:	eb 3d                	jmp    f0102e54 <region_alloc+0x5f>
		struct PageInfo *p = page_alloc(0);
f0102e17:	83 ec 0c             	sub    $0xc,%esp
f0102e1a:	6a 00                	push   $0x0
f0102e1c:	e8 d0 e0 ff ff       	call   f0100ef1 <page_alloc>
		if (!p) panic("env region_alloc failed");
f0102e21:	83 c4 10             	add    $0x10,%esp
f0102e24:	85 c0                	test   %eax,%eax
f0102e26:	75 17                	jne    f0102e3f <region_alloc+0x4a>
f0102e28:	83 ec 04             	sub    $0x4,%esp
f0102e2b:	68 29 73 10 f0       	push   $0xf0107329
f0102e30:	68 2a 01 00 00       	push   $0x12a
f0102e35:	68 41 73 10 f0       	push   $0xf0107341
f0102e3a:	e8 01 d2 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, p, begin, PTE_W | PTE_U);
f0102e3f:	6a 06                	push   $0x6
f0102e41:	53                   	push   %ebx
f0102e42:	50                   	push   %eax
f0102e43:	ff 77 60             	pushl  0x60(%edi)
f0102e46:	e8 7d e3 ff ff       	call   f01011c8 <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va + len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102e4b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e51:	83 c4 10             	add    $0x10,%esp
f0102e54:	39 f3                	cmp    %esi,%ebx
f0102e56:	72 bf                	jb     f0102e17 <region_alloc+0x22>
		struct PageInfo *p = page_alloc(0);
		if (!p) panic("env region_alloc failed");
		page_insert(e->env_pgdir, p, begin, PTE_W | PTE_U);
	}
}
f0102e58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e5b:	5b                   	pop    %ebx
f0102e5c:	5e                   	pop    %esi
f0102e5d:	5f                   	pop    %edi
f0102e5e:	5d                   	pop    %ebp
f0102e5f:	c3                   	ret    

f0102e60 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e60:	55                   	push   %ebp
f0102e61:	89 e5                	mov    %esp,%ebp
f0102e63:	56                   	push   %esi
f0102e64:	53                   	push   %ebx
f0102e65:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e68:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e6b:	85 c0                	test   %eax,%eax
f0102e6d:	75 1a                	jne    f0102e89 <envid2env+0x29>
		*env_store = curenv;
f0102e6f:	e8 92 2b 00 00       	call   f0105a06 <cpunum>
f0102e74:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e77:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e80:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e82:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e87:	eb 70                	jmp    f0102ef9 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e89:	89 c3                	mov    %eax,%ebx
f0102e8b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e91:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e94:	03 1d 48 f2 22 f0    	add    0xf022f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e9a:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e9e:	74 05                	je     f0102ea5 <envid2env+0x45>
f0102ea0:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102ea3:	74 10                	je     f0102eb5 <envid2env+0x55>
		*env_store = 0;
f0102ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ea8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102eae:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eb3:	eb 44                	jmp    f0102ef9 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102eb5:	84 d2                	test   %dl,%dl
f0102eb7:	74 36                	je     f0102eef <envid2env+0x8f>
f0102eb9:	e8 48 2b 00 00       	call   f0105a06 <cpunum>
f0102ebe:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ec1:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0102ec7:	74 26                	je     f0102eef <envid2env+0x8f>
f0102ec9:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ecc:	e8 35 2b 00 00       	call   f0105a06 <cpunum>
f0102ed1:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ed4:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102eda:	3b 70 48             	cmp    0x48(%eax),%esi
f0102edd:	74 10                	je     f0102eef <envid2env+0x8f>
		*env_store = 0;
f0102edf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ee2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ee8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eed:	eb 0a                	jmp    f0102ef9 <envid2env+0x99>
	}

	*env_store = e;
f0102eef:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ef2:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ef9:	5b                   	pop    %ebx
f0102efa:	5e                   	pop    %esi
f0102efb:	5d                   	pop    %ebp
f0102efc:	c3                   	ret    

f0102efd <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102efd:	55                   	push   %ebp
f0102efe:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f00:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102f05:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102f08:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f0d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102f0f:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102f11:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f16:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102f18:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102f1a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102f1c:	ea 23 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f23
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f23:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f28:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f2b:	5d                   	pop    %ebp
f0102f2c:	c3                   	ret    

f0102f2d <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f2d:	55                   	push   %ebp
f0102f2e:	89 e5                	mov    %esp,%ebp
f0102f30:	56                   	push   %esi
f0102f31:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	for (int i = NENV-1; i >= 0; i--) {
		struct Env *e = &envs[i];
f0102f32:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
f0102f38:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
f0102f3e:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f44:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f47:	89 c1                	mov    %eax,%ecx
		e->env_id = 0;
f0102f49:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		e->env_status = ENV_FREE;
f0102f50:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		e->env_link = env_free_list;
f0102f57:	89 50 44             	mov    %edx,0x44(%eax)
f0102f5a:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = e;
f0102f5d:	89 ca                	mov    %ecx,%edx
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	for (int i = NENV-1; i >= 0; i--) {
f0102f5f:	39 d8                	cmp    %ebx,%eax
f0102f61:	75 e4                	jne    f0102f47 <env_init+0x1a>
f0102f63:	89 35 4c f2 22 f0    	mov    %esi,0xf022f24c
		e->env_link = env_free_list;
		env_free_list = e;
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f69:	e8 8f ff ff ff       	call   f0102efd <env_init_percpu>
}
f0102f6e:	5b                   	pop    %ebx
f0102f6f:	5e                   	pop    %esi
f0102f70:	5d                   	pop    %ebp
f0102f71:	c3                   	ret    

f0102f72 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f72:	55                   	push   %ebp
f0102f73:	89 e5                	mov    %esp,%ebp
f0102f75:	53                   	push   %ebx
f0102f76:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f79:	8b 1d 4c f2 22 f0    	mov    0xf022f24c,%ebx
f0102f7f:	85 db                	test   %ebx,%ebx
f0102f81:	0f 84 69 01 00 00    	je     f01030f0 <env_alloc+0x17e>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f87:	83 ec 0c             	sub    $0xc,%esp
f0102f8a:	6a 01                	push   $0x1
f0102f8c:	e8 60 df ff ff       	call   f0100ef1 <page_alloc>
f0102f91:	83 c4 10             	add    $0x10,%esp
f0102f94:	85 c0                	test   %eax,%eax
f0102f96:	0f 84 5b 01 00 00    	je     f01030f7 <env_alloc+0x185>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102f9c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102fa1:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102fa7:	c1 f8 03             	sar    $0x3,%eax
f0102faa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fad:	89 c2                	mov    %eax,%edx
f0102faf:	c1 ea 0c             	shr    $0xc,%edx
f0102fb2:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102fb8:	72 12                	jb     f0102fcc <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fba:	50                   	push   %eax
f0102fbb:	68 c4 60 10 f0       	push   $0xf01060c4
f0102fc0:	6a 58                	push   $0x58
f0102fc2:	68 29 66 10 f0       	push   $0xf0106629
f0102fc7:	e8 74 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102fcc:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0102fd1:	89 43 60             	mov    %eax,0x60(%ebx)
	// cprintf("env:%d pgno:%d env_pgdir_addr:%x,val:%x kern_pgdir_addr:%x,val:%x\n",
	//	e->env_id, p-pages, &e->env_pgdir, e->env_pgdir, &kern_pgdir, kern_pgdir);
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fd4:	83 ec 04             	sub    $0x4,%esp
f0102fd7:	68 00 10 00 00       	push   $0x1000
f0102fdc:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102fe2:	50                   	push   %eax
f0102fe3:	e8 b3 24 00 00       	call   f010549b <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fe8:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102feb:	83 c4 10             	add    $0x10,%esp
f0102fee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ff3:	77 15                	ja     f010300a <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ff5:	50                   	push   %eax
f0102ff6:	68 e8 60 10 f0       	push   $0xf01060e8
f0102ffb:	68 c8 00 00 00       	push   $0xc8
f0103000:	68 41 73 10 f0       	push   $0xf0107341
f0103005:	e8 36 d0 ff ff       	call   f0100040 <_panic>
f010300a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103010:	83 ca 05             	or     $0x5,%edx
f0103013:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103019:	8b 43 48             	mov    0x48(%ebx),%eax
f010301c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103021:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103026:	ba 00 10 00 00       	mov    $0x1000,%edx
f010302b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010302e:	89 da                	mov    %ebx,%edx
f0103030:	2b 15 48 f2 22 f0    	sub    0xf022f248,%edx
f0103036:	c1 fa 02             	sar    $0x2,%edx
f0103039:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010303f:	09 d0                	or     %edx,%eax
f0103041:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103044:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103047:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010304a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103051:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103058:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010305f:	83 ec 04             	sub    $0x4,%esp
f0103062:	6a 44                	push   $0x44
f0103064:	6a 00                	push   $0x0
f0103066:	53                   	push   %ebx
f0103067:	e8 7a 23 00 00       	call   f01053e6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010306c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103072:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103078:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010307e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103085:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f010308b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103092:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103099:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010309d:	8b 43 44             	mov    0x44(%ebx),%eax
f01030a0:	a3 4c f2 22 f0       	mov    %eax,0xf022f24c
	*newenv_store = e;
f01030a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01030a8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030aa:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01030ad:	e8 54 29 00 00       	call   f0105a06 <cpunum>
f01030b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01030b5:	83 c4 10             	add    $0x10,%esp
f01030b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01030bd:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01030c4:	74 11                	je     f01030d7 <env_alloc+0x165>
f01030c6:	e8 3b 29 00 00       	call   f0105a06 <cpunum>
f01030cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ce:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01030d4:	8b 50 48             	mov    0x48(%eax),%edx
f01030d7:	83 ec 04             	sub    $0x4,%esp
f01030da:	53                   	push   %ebx
f01030db:	52                   	push   %edx
f01030dc:	68 4c 73 10 f0       	push   $0xf010734c
f01030e1:	e8 60 06 00 00       	call   f0103746 <cprintf>
	return 0;
f01030e6:	83 c4 10             	add    $0x10,%esp
f01030e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01030ee:	eb 0c                	jmp    f01030fc <env_alloc+0x18a>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030f0:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030f5:	eb 05                	jmp    f01030fc <env_alloc+0x18a>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01030f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030ff:	c9                   	leave  
f0103100:	c3                   	ret    

f0103101 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103101:	55                   	push   %ebp
f0103102:	89 e5                	mov    %esp,%ebp
f0103104:	57                   	push   %edi
f0103105:	56                   	push   %esi
f0103106:	53                   	push   %ebx
f0103107:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
f010310a:	6a 00                	push   $0x0
f010310c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010310f:	50                   	push   %eax
f0103110:	e8 5d fe ff ff       	call   f0102f72 <env_alloc>
	e->env_type = type;
f0103115:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103118:	8b 45 0c             	mov    0xc(%ebp),%eax
f010311b:	89 47 50             	mov    %eax,0x50(%edi)
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	cprintf("load_icode for env:%x, env_pgdir va=%x, pa=%x\n", e->env_id, e->env_pgdir, PADDR(e->env_pgdir));
f010311e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103121:	83 c4 10             	add    $0x10,%esp
f0103124:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103129:	77 15                	ja     f0103140 <env_create+0x3f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010312b:	50                   	push   %eax
f010312c:	68 e8 60 10 f0       	push   $0xf01060e8
f0103131:	68 65 01 00 00       	push   $0x165
f0103136:	68 41 73 10 f0       	push   $0xf0107341
f010313b:	e8 00 cf ff ff       	call   f0100040 <_panic>
f0103140:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103146:	52                   	push   %edx
f0103147:	50                   	push   %eax
f0103148:	ff 77 48             	pushl  0x48(%edi)
f010314b:	68 98 73 10 f0       	push   $0xf0107398
f0103150:	e8 f1 05 00 00       	call   f0103746 <cprintf>

	struct Elf *env_elf;
	struct Proghdr *ph, *eph;
	env_elf = (struct Elf*)binary;
	ph = (struct Proghdr*)((uint8_t*)(env_elf) + env_elf->e_phoff);
f0103155:	8b 45 08             	mov    0x8(%ebp),%eax
f0103158:	89 c3                	mov    %eax,%ebx
f010315a:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + env_elf->e_phnum;
f010315d:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103161:	c1 e6 05             	shl    $0x5,%esi
f0103164:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103166:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103169:	83 c4 10             	add    $0x10,%esp
f010316c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103171:	77 15                	ja     f0103188 <env_create+0x87>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103173:	50                   	push   %eax
f0103174:	68 e8 60 10 f0       	push   $0xf01060e8
f0103179:	68 6d 01 00 00       	push   $0x16d
f010317e:	68 41 73 10 f0       	push   $0xf0107341
f0103183:	e8 b8 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103188:	05 00 00 00 10       	add    $0x10000000,%eax
f010318d:	0f 22 d8             	mov    %eax,%cr3
f0103190:	eb 44                	jmp    f01031d6 <env_create+0xd5>

	for (; ph < eph; ph++) {
		if(ph->p_type == ELF_PROG_LOAD) {
f0103192:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103195:	75 3c                	jne    f01031d3 <env_create+0xd2>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103197:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010319a:	8b 53 08             	mov    0x8(%ebx),%edx
f010319d:	89 f8                	mov    %edi,%eax
f010319f:	e8 51 fc ff ff       	call   f0102df5 <region_alloc>
			memcpy((void*)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
f01031a4:	83 ec 04             	sub    $0x4,%esp
f01031a7:	ff 73 10             	pushl  0x10(%ebx)
f01031aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01031ad:	03 43 04             	add    0x4(%ebx),%eax
f01031b0:	50                   	push   %eax
f01031b1:	ff 73 08             	pushl  0x8(%ebx)
f01031b4:	e8 e2 22 00 00       	call   f010549b <memcpy>
			memset((void*)(ph->p_va + ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
f01031b9:	8b 43 10             	mov    0x10(%ebx),%eax
f01031bc:	83 c4 0c             	add    $0xc,%esp
f01031bf:	8b 53 14             	mov    0x14(%ebx),%edx
f01031c2:	29 c2                	sub    %eax,%edx
f01031c4:	52                   	push   %edx
f01031c5:	6a 00                	push   $0x0
f01031c7:	03 43 08             	add    0x8(%ebx),%eax
f01031ca:	50                   	push   %eax
f01031cb:	e8 16 22 00 00       	call   f01053e6 <memset>
f01031d0:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr*)((uint8_t*)(env_elf) + env_elf->e_phoff);
	eph = ph + env_elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++) {
f01031d3:	83 c3 20             	add    $0x20,%ebx
f01031d6:	39 de                	cmp    %ebx,%esi
f01031d8:	77 b8                	ja     f0103192 <env_create+0x91>
			memcpy((void*)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
			memset((void*)(ph->p_va + ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = env_elf->e_entry;
f01031da:	8b 45 08             	mov    0x8(%ebp),%eax
f01031dd:	8b 40 18             	mov    0x18(%eax),%eax
f01031e0:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(kern_pgdir));
f01031e3:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ed:	77 15                	ja     f0103204 <env_create+0x103>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031ef:	50                   	push   %eax
f01031f0:	68 e8 60 10 f0       	push   $0xf01060e8
f01031f5:	68 78 01 00 00       	push   $0x178
f01031fa:	68 41 73 10 f0       	push   $0xf0107341
f01031ff:	e8 3c ce ff ff       	call   f0100040 <_panic>
f0103204:	05 00 00 00 10       	add    $0x10000000,%eax
f0103209:	0f 22 d8             	mov    %eax,%cr3

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f010320c:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103211:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103216:	89 f8                	mov    %edi,%eax
f0103218:	e8 d8 fb ff ff       	call   f0102df5 <region_alloc>
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
	e->env_type = type;
	load_icode(e, binary);
}
f010321d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103220:	5b                   	pop    %ebx
f0103221:	5e                   	pop    %esi
f0103222:	5f                   	pop    %edi
f0103223:	5d                   	pop    %ebp
f0103224:	c3                   	ret    

f0103225 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103225:	55                   	push   %ebp
f0103226:	89 e5                	mov    %esp,%ebp
f0103228:	57                   	push   %edi
f0103229:	56                   	push   %esi
f010322a:	53                   	push   %ebx
f010322b:	83 ec 1c             	sub    $0x1c,%esp
f010322e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103231:	e8 d0 27 00 00       	call   f0105a06 <cpunum>
f0103236:	6b c0 74             	imul   $0x74,%eax,%eax
f0103239:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f010323f:	75 29                	jne    f010326a <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103241:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103246:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010324b:	77 15                	ja     f0103262 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010324d:	50                   	push   %eax
f010324e:	68 e8 60 10 f0       	push   $0xf01060e8
f0103253:	68 a0 01 00 00       	push   $0x1a0
f0103258:	68 41 73 10 f0       	push   $0xf0107341
f010325d:	e8 de cd ff ff       	call   f0100040 <_panic>
f0103262:	05 00 00 00 10       	add    $0x10000000,%eax
f0103267:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010326a:	8b 5f 48             	mov    0x48(%edi),%ebx
f010326d:	e8 94 27 00 00       	call   f0105a06 <cpunum>
f0103272:	6b c0 74             	imul   $0x74,%eax,%eax
f0103275:	ba 00 00 00 00       	mov    $0x0,%edx
f010327a:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103281:	74 11                	je     f0103294 <env_free+0x6f>
f0103283:	e8 7e 27 00 00       	call   f0105a06 <cpunum>
f0103288:	6b c0 74             	imul   $0x74,%eax,%eax
f010328b:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103291:	8b 50 48             	mov    0x48(%eax),%edx
f0103294:	83 ec 04             	sub    $0x4,%esp
f0103297:	53                   	push   %ebx
f0103298:	52                   	push   %edx
f0103299:	68 61 73 10 f0       	push   $0xf0107361
f010329e:	e8 a3 04 00 00       	call   f0103746 <cprintf>
f01032a3:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032b0:	89 d0                	mov    %edx,%eax
f01032b2:	c1 e0 02             	shl    $0x2,%eax
f01032b5:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032b8:	8b 47 60             	mov    0x60(%edi),%eax
f01032bb:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01032be:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032c4:	0f 84 a8 00 00 00    	je     f0103372 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032ca:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032d0:	89 f0                	mov    %esi,%eax
f01032d2:	c1 e8 0c             	shr    $0xc,%eax
f01032d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032d8:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f01032de:	77 15                	ja     f01032f5 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032e0:	56                   	push   %esi
f01032e1:	68 c4 60 10 f0       	push   $0xf01060c4
f01032e6:	68 af 01 00 00       	push   $0x1af
f01032eb:	68 41 73 10 f0       	push   $0xf0107341
f01032f0:	e8 4b cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032f8:	c1 e0 16             	shl    $0x16,%eax
f01032fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032fe:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103303:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010330a:	01 
f010330b:	74 17                	je     f0103324 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010330d:	83 ec 08             	sub    $0x8,%esp
f0103310:	89 d8                	mov    %ebx,%eax
f0103312:	c1 e0 0c             	shl    $0xc,%eax
f0103315:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103318:	50                   	push   %eax
f0103319:	ff 77 60             	pushl  0x60(%edi)
f010331c:	e8 5c de ff ff       	call   f010117d <page_remove>
f0103321:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103324:	83 c3 01             	add    $0x1,%ebx
f0103327:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010332d:	75 d4                	jne    f0103303 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010332f:	8b 47 60             	mov    0x60(%edi),%eax
f0103332:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103335:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010333c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010333f:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0103345:	72 14                	jb     f010335b <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103347:	83 ec 04             	sub    $0x4,%esp
f010334a:	68 f0 6a 10 f0       	push   $0xf0106af0
f010334f:	6a 51                	push   $0x51
f0103351:	68 29 66 10 f0       	push   $0xf0106629
f0103356:	e8 e5 cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010335b:	83 ec 0c             	sub    $0xc,%esp
f010335e:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0103363:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103366:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103369:	50                   	push   %eax
f010336a:	e8 2f dc ff ff       	call   f0100f9e <page_decref>
f010336f:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103372:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103376:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103379:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010337e:	0f 85 29 ff ff ff    	jne    f01032ad <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103384:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103387:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010338c:	77 15                	ja     f01033a3 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010338e:	50                   	push   %eax
f010338f:	68 e8 60 10 f0       	push   $0xf01060e8
f0103394:	68 bd 01 00 00       	push   $0x1bd
f0103399:	68 41 73 10 f0       	push   $0xf0107341
f010339e:	e8 9d cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01033a3:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033aa:	05 00 00 00 10       	add    $0x10000000,%eax
f01033af:	c1 e8 0c             	shr    $0xc,%eax
f01033b2:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01033b8:	72 14                	jb     f01033ce <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01033ba:	83 ec 04             	sub    $0x4,%esp
f01033bd:	68 f0 6a 10 f0       	push   $0xf0106af0
f01033c2:	6a 51                	push   $0x51
f01033c4:	68 29 66 10 f0       	push   $0xf0106629
f01033c9:	e8 72 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01033ce:	83 ec 0c             	sub    $0xc,%esp
f01033d1:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f01033d7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033da:	50                   	push   %eax
f01033db:	e8 be db ff ff       	call   f0100f9e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033e0:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033e7:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f01033ec:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033ef:	89 3d 4c f2 22 f0    	mov    %edi,0xf022f24c
}
f01033f5:	83 c4 10             	add    $0x10,%esp
f01033f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033fb:	5b                   	pop    %ebx
f01033fc:	5e                   	pop    %esi
f01033fd:	5f                   	pop    %edi
f01033fe:	5d                   	pop    %ebp
f01033ff:	c3                   	ret    

f0103400 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103400:	55                   	push   %ebp
f0103401:	89 e5                	mov    %esp,%ebp
f0103403:	57                   	push   %edi
f0103404:	56                   	push   %esi
f0103405:	53                   	push   %ebx
f0103406:	83 ec 1c             	sub    $0x1c,%esp
f0103409:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	cprintf("in env_destroy curenv:%x, cpunum:%d, e:%x, ecpunum:%d\n", curenv->env_id, thiscpu->cpu_id, e->env_id, e->env_cpunum);
f010340c:	8b 7b 5c             	mov    0x5c(%ebx),%edi
f010340f:	8b 43 48             	mov    0x48(%ebx),%eax
f0103412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103415:	e8 ec 25 00 00       	call   f0105a06 <cpunum>
f010341a:	6b c0 74             	imul   $0x74,%eax,%eax
f010341d:	0f b6 b0 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%esi
f0103424:	e8 dd 25 00 00       	call   f0105a06 <cpunum>
f0103429:	83 ec 0c             	sub    $0xc,%esp
f010342c:	57                   	push   %edi
f010342d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103430:	56                   	push   %esi
f0103431:	6b c0 74             	imul   $0x74,%eax,%eax
f0103434:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010343a:	ff 70 48             	pushl  0x48(%eax)
f010343d:	68 c8 73 10 f0       	push   $0xf01073c8
f0103442:	e8 ff 02 00 00       	call   f0103746 <cprintf>
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103447:	83 c4 20             	add    $0x20,%esp
f010344a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010344e:	75 2c                	jne    f010347c <env_destroy+0x7c>
f0103450:	e8 b1 25 00 00       	call   f0105a06 <cpunum>
f0103455:	6b c0 74             	imul   $0x74,%eax,%eax
f0103458:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f010345e:	74 1c                	je     f010347c <env_destroy+0x7c>
		cprintf("set e:%x to dying\n", e->env_id);
f0103460:	83 ec 08             	sub    $0x8,%esp
f0103463:	ff 73 48             	pushl  0x48(%ebx)
f0103466:	68 77 73 10 f0       	push   $0xf0107377
f010346b:	e8 d6 02 00 00       	call   f0103746 <cprintf>
		e->env_status = ENV_DYING;
f0103470:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103477:	83 c4 10             	add    $0x10,%esp
f010347a:	eb 33                	jmp    f01034af <env_destroy+0xaf>
	}

	env_free(e);
f010347c:	83 ec 0c             	sub    $0xc,%esp
f010347f:	53                   	push   %ebx
f0103480:	e8 a0 fd ff ff       	call   f0103225 <env_free>

	if (curenv == e) {
f0103485:	e8 7c 25 00 00       	call   f0105a06 <cpunum>
f010348a:	6b c0 74             	imul   $0x74,%eax,%eax
f010348d:	83 c4 10             	add    $0x10,%esp
f0103490:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0103496:	75 17                	jne    f01034af <env_destroy+0xaf>
		curenv = NULL;
f0103498:	e8 69 25 00 00       	call   f0105a06 <cpunum>
f010349d:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a0:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01034a7:	00 00 00 
		sched_yield();
f01034aa:	e8 de 0d 00 00       	call   f010428d <sched_yield>
	}
}
f01034af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034b2:	5b                   	pop    %ebx
f01034b3:	5e                   	pop    %esi
f01034b4:	5f                   	pop    %edi
f01034b5:	5d                   	pop    %ebp
f01034b6:	c3                   	ret    

f01034b7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034b7:	55                   	push   %ebp
f01034b8:	89 e5                	mov    %esp,%ebp
f01034ba:	53                   	push   %ebx
f01034bb:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01034be:	e8 43 25 00 00       	call   f0105a06 <cpunum>
f01034c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c6:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f01034cc:	e8 35 25 00 00       	call   f0105a06 <cpunum>
f01034d1:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01034d4:	8b 65 08             	mov    0x8(%ebp),%esp
f01034d7:	61                   	popa   
f01034d8:	07                   	pop    %es
f01034d9:	1f                   	pop    %ds
f01034da:	83 c4 08             	add    $0x8,%esp
f01034dd:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01034de:	83 ec 04             	sub    $0x4,%esp
f01034e1:	68 8a 73 10 f0       	push   $0xf010738a
f01034e6:	68 f6 01 00 00       	push   $0x1f6
f01034eb:	68 41 73 10 f0       	push   $0xf0107341
f01034f0:	e8 4b cb ff ff       	call   f0100040 <_panic>

f01034f5 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034f5:	55                   	push   %ebp
f01034f6:	89 e5                	mov    %esp,%ebp
f01034f8:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	// panic("env_run not yet implemented");
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01034fb:	e8 06 25 00 00       	call   f0105a06 <cpunum>
f0103500:	6b c0 74             	imul   $0x74,%eax,%eax
f0103503:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010350a:	74 29                	je     f0103535 <env_run+0x40>
f010350c:	e8 f5 24 00 00       	call   f0105a06 <cpunum>
f0103511:	6b c0 74             	imul   $0x74,%eax,%eax
f0103514:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010351a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010351e:	75 15                	jne    f0103535 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f0103520:	e8 e1 24 00 00       	call   f0105a06 <cpunum>
f0103525:	6b c0 74             	imul   $0x74,%eax,%eax
f0103528:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010352e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f0103535:	e8 cc 24 00 00       	call   f0105a06 <cpunum>
f010353a:	6b c0 74             	imul   $0x74,%eax,%eax
f010353d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103540:	89 90 28 00 23 f0    	mov    %edx,-0xfdcffd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103546:	e8 bb 24 00 00       	call   f0105a06 <cpunum>
f010354b:	6b c0 74             	imul   $0x74,%eax,%eax
f010354e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103554:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010355b:	e8 a6 24 00 00       	call   f0105a06 <cpunum>
f0103560:	6b c0 74             	imul   $0x74,%eax,%eax
f0103563:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103569:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f010356d:	e8 94 24 00 00       	call   f0105a06 <cpunum>
f0103572:	6b c0 74             	imul   $0x74,%eax,%eax
f0103575:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010357b:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010357e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103583:	77 15                	ja     f010359a <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103585:	50                   	push   %eax
f0103586:	68 e8 60 10 f0       	push   $0xf01060e8
f010358b:	68 1c 02 00 00       	push   $0x21c
f0103590:	68 41 73 10 f0       	push   $0xf0107341
f0103595:	e8 a6 ca ff ff       	call   f0100040 <_panic>
f010359a:	05 00 00 00 10       	add    $0x10000000,%eax
f010359f:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01035a2:	83 ec 0c             	sub    $0xc,%esp
f01035a5:	68 c0 03 12 f0       	push   $0xf01203c0
f01035aa:	e8 62 27 00 00       	call   f0105d11 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01035af:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f01035b1:	e8 50 24 00 00       	call   f0105a06 <cpunum>
f01035b6:	83 c4 04             	add    $0x4,%esp
f01035b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01035bc:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01035c2:	e8 f0 fe ff ff       	call   f01034b7 <env_pop_tf>

f01035c7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035c7:	55                   	push   %ebp
f01035c8:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035ca:	ba 70 00 00 00       	mov    $0x70,%edx
f01035cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035d3:	ba 71 00 00 00       	mov    $0x71,%edx
f01035d8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01035d9:	0f b6 c0             	movzbl %al,%eax
}
f01035dc:	5d                   	pop    %ebp
f01035dd:	c3                   	ret    

f01035de <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035de:	55                   	push   %ebp
f01035df:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035e1:	ba 70 00 00 00       	mov    $0x70,%edx
f01035e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01035e9:	ee                   	out    %al,(%dx)
f01035ea:	ba 71 00 00 00       	mov    $0x71,%edx
f01035ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035f2:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035f3:	5d                   	pop    %ebp
f01035f4:	c3                   	ret    

f01035f5 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035f5:	55                   	push   %ebp
f01035f6:	89 e5                	mov    %esp,%ebp
f01035f8:	56                   	push   %esi
f01035f9:	53                   	push   %ebx
f01035fa:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01035fd:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103603:	80 3d 50 f2 22 f0 00 	cmpb   $0x0,0xf022f250
f010360a:	74 5a                	je     f0103666 <irq_setmask_8259A+0x71>
f010360c:	89 c6                	mov    %eax,%esi
f010360e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103613:	ee                   	out    %al,(%dx)
f0103614:	66 c1 e8 08          	shr    $0x8,%ax
f0103618:	ba a1 00 00 00       	mov    $0xa1,%edx
f010361d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010361e:	83 ec 0c             	sub    $0xc,%esp
f0103621:	68 ff 73 10 f0       	push   $0xf01073ff
f0103626:	e8 1b 01 00 00       	call   f0103746 <cprintf>
f010362b:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010362e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103633:	0f b7 f6             	movzwl %si,%esi
f0103636:	f7 d6                	not    %esi
f0103638:	0f a3 de             	bt     %ebx,%esi
f010363b:	73 11                	jae    f010364e <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010363d:	83 ec 08             	sub    $0x8,%esp
f0103640:	53                   	push   %ebx
f0103641:	68 bb 78 10 f0       	push   $0xf01078bb
f0103646:	e8 fb 00 00 00       	call   f0103746 <cprintf>
f010364b:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010364e:	83 c3 01             	add    $0x1,%ebx
f0103651:	83 fb 10             	cmp    $0x10,%ebx
f0103654:	75 e2                	jne    f0103638 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103656:	83 ec 0c             	sub    $0xc,%esp
f0103659:	68 3a 69 10 f0       	push   $0xf010693a
f010365e:	e8 e3 00 00 00       	call   f0103746 <cprintf>
f0103663:	83 c4 10             	add    $0x10,%esp
}
f0103666:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103669:	5b                   	pop    %ebx
f010366a:	5e                   	pop    %esi
f010366b:	5d                   	pop    %ebp
f010366c:	c3                   	ret    

f010366d <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010366d:	c6 05 50 f2 22 f0 01 	movb   $0x1,0xf022f250
f0103674:	ba 21 00 00 00       	mov    $0x21,%edx
f0103679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010367e:	ee                   	out    %al,(%dx)
f010367f:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103684:	ee                   	out    %al,(%dx)
f0103685:	ba 20 00 00 00       	mov    $0x20,%edx
f010368a:	b8 11 00 00 00       	mov    $0x11,%eax
f010368f:	ee                   	out    %al,(%dx)
f0103690:	ba 21 00 00 00       	mov    $0x21,%edx
f0103695:	b8 20 00 00 00       	mov    $0x20,%eax
f010369a:	ee                   	out    %al,(%dx)
f010369b:	b8 04 00 00 00       	mov    $0x4,%eax
f01036a0:	ee                   	out    %al,(%dx)
f01036a1:	b8 03 00 00 00       	mov    $0x3,%eax
f01036a6:	ee                   	out    %al,(%dx)
f01036a7:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036ac:	b8 11 00 00 00       	mov    $0x11,%eax
f01036b1:	ee                   	out    %al,(%dx)
f01036b2:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036b7:	b8 28 00 00 00       	mov    $0x28,%eax
f01036bc:	ee                   	out    %al,(%dx)
f01036bd:	b8 02 00 00 00       	mov    $0x2,%eax
f01036c2:	ee                   	out    %al,(%dx)
f01036c3:	b8 01 00 00 00       	mov    $0x1,%eax
f01036c8:	ee                   	out    %al,(%dx)
f01036c9:	ba 20 00 00 00       	mov    $0x20,%edx
f01036ce:	b8 68 00 00 00       	mov    $0x68,%eax
f01036d3:	ee                   	out    %al,(%dx)
f01036d4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036d9:	ee                   	out    %al,(%dx)
f01036da:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036df:	b8 68 00 00 00       	mov    $0x68,%eax
f01036e4:	ee                   	out    %al,(%dx)
f01036e5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036ea:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036eb:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01036f2:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036f6:	74 13                	je     f010370b <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036f8:	55                   	push   %ebp
f01036f9:	89 e5                	mov    %esp,%ebp
f01036fb:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01036fe:	0f b7 c0             	movzwl %ax,%eax
f0103701:	50                   	push   %eax
f0103702:	e8 ee fe ff ff       	call   f01035f5 <irq_setmask_8259A>
f0103707:	83 c4 10             	add    $0x10,%esp
}
f010370a:	c9                   	leave  
f010370b:	f3 c3                	repz ret 

f010370d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010370d:	55                   	push   %ebp
f010370e:	89 e5                	mov    %esp,%ebp
f0103710:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103713:	ff 75 08             	pushl  0x8(%ebp)
f0103716:	e8 3b d0 ff ff       	call   f0100756 <cputchar>
	*cnt++;
}
f010371b:	83 c4 10             	add    $0x10,%esp
f010371e:	c9                   	leave  
f010371f:	c3                   	ret    

f0103720 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103720:	55                   	push   %ebp
f0103721:	89 e5                	mov    %esp,%ebp
f0103723:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010372d:	ff 75 0c             	pushl  0xc(%ebp)
f0103730:	ff 75 08             	pushl  0x8(%ebp)
f0103733:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103736:	50                   	push   %eax
f0103737:	68 0d 37 10 f0       	push   $0xf010370d
f010373c:	e8 39 16 00 00       	call   f0104d7a <vprintfmt>
	return cnt;
}
f0103741:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103744:	c9                   	leave  
f0103745:	c3                   	ret    

f0103746 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103746:	55                   	push   %ebp
f0103747:	89 e5                	mov    %esp,%ebp
f0103749:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010374c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010374f:	50                   	push   %eax
f0103750:	ff 75 08             	pushl  0x8(%ebp)
f0103753:	e8 c8 ff ff ff       	call   f0103720 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103758:	c9                   	leave  
f0103759:	c3                   	ret    

f010375a <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010375a:	55                   	push   %ebp
f010375b:	89 e5                	mov    %esp,%ebp
f010375d:	57                   	push   %edi
f010375e:	56                   	push   %esi
f010375f:	53                   	push   %ebx
f0103760:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cpu_id = thiscpu->cpu_id;
f0103763:	e8 9e 22 00 00       	call   f0105a06 <cpunum>
f0103768:	6b c0 74             	imul   $0x74,%eax,%eax
f010376b:	0f b6 b0 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%esi
f0103772:	89 f0                	mov    %esi,%eax
f0103774:	0f b6 d8             	movzbl %al,%ebx
	struct Taskstate *this_ts = &thiscpu->cpu_ts;
f0103777:	e8 8a 22 00 00       	call   f0105a06 <cpunum>
f010377c:	6b c0 74             	imul   $0x74,%eax,%eax
f010377f:	8d 90 2c 00 23 f0    	lea    -0xfdcffd4(%eax),%edx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	this_ts->ts_esp0 = KSTACKTOP - cpu_id * (KSTKSIZE + KSTKGAP);
f0103785:	89 df                	mov    %ebx,%edi
f0103787:	c1 e7 10             	shl    $0x10,%edi
f010378a:	b9 00 00 00 f0       	mov    $0xf0000000,%ecx
f010378f:	29 f9                	sub    %edi,%ecx
f0103791:	89 88 30 00 23 f0    	mov    %ecx,-0xfdcffd0(%eax)
	this_ts->ts_ss0 = GD_KD;
f0103797:	66 c7 80 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%eax)
f010379e:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f01037a0:	66 c7 80 92 00 23 f0 	movw   $0x68,-0xfdcff6e(%eax)
f01037a7:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f01037a9:	8d 43 05             	lea    0x5(%ebx),%eax
f01037ac:	66 c7 04 c5 40 03 12 	movw   $0x67,-0xfedfcc0(,%eax,8)
f01037b3:	f0 67 00 
f01037b6:	66 89 14 c5 42 03 12 	mov    %dx,-0xfedfcbe(,%eax,8)
f01037bd:	f0 
f01037be:	89 d1                	mov    %edx,%ecx
f01037c0:	c1 e9 10             	shr    $0x10,%ecx
f01037c3:	88 0c c5 44 03 12 f0 	mov    %cl,-0xfedfcbc(,%eax,8)
f01037ca:	c6 04 c5 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%eax,8)
f01037d1:	40 
f01037d2:	c1 ea 18             	shr    $0x18,%edx
f01037d5:	88 14 c5 47 03 12 f0 	mov    %dl,-0xfedfcb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id].sd_s = 0;
f01037dc:	c6 04 c5 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%eax,8)
f01037e3:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037e4:	89 f0                	mov    %esi,%eax
f01037e6:	0f b6 f0             	movzbl %al,%esi
f01037e9:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f01037f0:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037f3:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f01037f8:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpu_id << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f01037fb:	83 c4 0c             	add    $0xc,%esp
f01037fe:	5b                   	pop    %ebx
f01037ff:	5e                   	pop    %esi
f0103800:	5f                   	pop    %edi
f0103801:	5d                   	pop    %ebp
f0103802:	c3                   	ret    

f0103803 <trap_init>:
}


void
trap_init(void)
{
f0103803:	55                   	push   %ebp
f0103804:	89 e5                	mov    %esp,%ebp
f0103806:	83 ec 08             	sub    $0x8,%esp
	void handler39();
	void handler46();
	void handler51();


	SETGATE(idt[T_DIVIDE], 0, GD_KT, handler0, 0);
f0103809:	b8 30 41 10 f0       	mov    $0xf0104130,%eax
f010380e:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f0103814:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f010381b:	08 00 
f010381d:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f0103824:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f010382b:	c1 e8 10             	shr    $0x10,%eax
f010382e:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, handler1, 0);
f0103834:	b8 36 41 10 f0       	mov    $0xf0104136,%eax
f0103839:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f010383f:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f0103846:	08 00 
f0103848:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f010384f:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f0103856:	c1 e8 10             	shr    $0x10,%eax
f0103859:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
	SETGATE(idt[T_NMI], 0, GD_KT, handler2, 0);
f010385f:	b8 3c 41 10 f0       	mov    $0xf010413c,%eax
f0103864:	66 a3 70 f2 22 f0    	mov    %ax,0xf022f270
f010386a:	66 c7 05 72 f2 22 f0 	movw   $0x8,0xf022f272
f0103871:	08 00 
f0103873:	c6 05 74 f2 22 f0 00 	movb   $0x0,0xf022f274
f010387a:	c6 05 75 f2 22 f0 8e 	movb   $0x8e,0xf022f275
f0103881:	c1 e8 10             	shr    $0x10,%eax
f0103884:	66 a3 76 f2 22 f0    	mov    %ax,0xf022f276

	// T_BRKPT DPL 3
	SETGATE(idt[T_BRKPT], 0, GD_KT, handler3, 3);
f010388a:	b8 42 41 10 f0       	mov    $0xf0104142,%eax
f010388f:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f0103895:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f010389c:	08 00 
f010389e:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f01038a5:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f01038ac:	c1 e8 10             	shr    $0x10,%eax
f01038af:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e

	SETGATE(idt[T_OFLOW], 0, GD_KT, handler4, 0);
f01038b5:	b8 48 41 10 f0       	mov    $0xf0104148,%eax
f01038ba:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f01038c0:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f01038c7:	08 00 
f01038c9:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f01038d0:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f01038d7:	c1 e8 10             	shr    $0x10,%eax
f01038da:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
	SETGATE(idt[T_BOUND], 0, GD_KT, handler5, 0);
f01038e0:	b8 4e 41 10 f0       	mov    $0xf010414e,%eax
f01038e5:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f01038eb:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f01038f2:	08 00 
f01038f4:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f01038fb:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103902:	c1 e8 10             	shr    $0x10,%eax
f0103905:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, handler6, 0);
f010390b:	b8 54 41 10 f0       	mov    $0xf0104154,%eax
f0103910:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103916:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f010391d:	08 00 
f010391f:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103926:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f010392d:	c1 e8 10             	shr    $0x10,%eax
f0103930:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, handler7, 0);
f0103936:	b8 5a 41 10 f0       	mov    $0xf010415a,%eax
f010393b:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103941:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f0103948:	08 00 
f010394a:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103951:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f0103958:	c1 e8 10             	shr    $0x10,%eax
f010395b:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, handler8, 0);
f0103961:	b8 5e 41 10 f0       	mov    $0xf010415e,%eax
f0103966:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f010396c:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f0103973:	08 00 
f0103975:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f010397c:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f0103983:	c1 e8 10             	shr    $0x10,%eax
f0103986:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, handler10, 0);
f010398c:	b8 64 41 10 f0       	mov    $0xf0104164,%eax
f0103991:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f0103997:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f010399e:	08 00 
f01039a0:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f01039a7:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f01039ae:	c1 e8 10             	shr    $0x10,%eax
f01039b1:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, handler11, 0);
f01039b7:	b8 68 41 10 f0       	mov    $0xf0104168,%eax
f01039bc:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f01039c2:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f01039c9:	08 00 
f01039cb:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f01039d2:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f01039d9:	c1 e8 10             	shr    $0x10,%eax
f01039dc:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
	SETGATE(idt[T_STACK], 0, GD_KT, handler12, 0);
f01039e2:	b8 6c 41 10 f0       	mov    $0xf010416c,%eax
f01039e7:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f01039ed:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f01039f4:	08 00 
f01039f6:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f01039fd:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103a04:	c1 e8 10             	shr    $0x10,%eax
f0103a07:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, handler13, 0);
f0103a0d:	b8 70 41 10 f0       	mov    $0xf0104170,%eax
f0103a12:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103a18:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103a1f:	08 00 
f0103a21:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103a28:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103a2f:	c1 e8 10             	shr    $0x10,%eax
f0103a32:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, handler14, 0);
f0103a38:	b8 74 41 10 f0       	mov    $0xf0104174,%eax
f0103a3d:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103a43:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103a4a:	08 00 
f0103a4c:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103a53:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103a5a:	c1 e8 10             	shr    $0x10,%eax
f0103a5d:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, handler16, 0);
f0103a63:	b8 78 41 10 f0       	mov    $0xf0104178,%eax
f0103a68:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103a6e:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103a75:	08 00 
f0103a77:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103a7e:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103a85:	c1 e8 10             	shr    $0x10,%eax
f0103a88:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6

	// T_SYSCALL DPL 3
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
f0103a8e:	b8 7e 41 10 f0       	mov    $0xf010417e,%eax
f0103a93:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103a99:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103aa0:	08 00 
f0103aa2:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103aa9:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103ab0:	c1 e8 10             	shr    $0x10,%eax
f0103ab3:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6

	// IRQs
	SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 0, GD_KT, handler32, 0);
f0103ab9:	b8 84 41 10 f0       	mov    $0xf0104184,%eax
f0103abe:	66 a3 60 f3 22 f0    	mov    %ax,0xf022f360
f0103ac4:	66 c7 05 62 f3 22 f0 	movw   $0x8,0xf022f362
f0103acb:	08 00 
f0103acd:	c6 05 64 f3 22 f0 00 	movb   $0x0,0xf022f364
f0103ad4:	c6 05 65 f3 22 f0 8e 	movb   $0x8e,0xf022f365
f0103adb:	c1 e8 10             	shr    $0x10,%eax
f0103ade:	66 a3 66 f3 22 f0    	mov    %ax,0xf022f366
	SETGATE(idt[IRQ_OFFSET+IRQ_KBD], 0, GD_KT, handler33, 0);
f0103ae4:	b8 8a 41 10 f0       	mov    $0xf010418a,%eax
f0103ae9:	66 a3 68 f3 22 f0    	mov    %ax,0xf022f368
f0103aef:	66 c7 05 6a f3 22 f0 	movw   $0x8,0xf022f36a
f0103af6:	08 00 
f0103af8:	c6 05 6c f3 22 f0 00 	movb   $0x0,0xf022f36c
f0103aff:	c6 05 6d f3 22 f0 8e 	movb   $0x8e,0xf022f36d
f0103b06:	c1 e8 10             	shr    $0x10,%eax
f0103b09:	66 a3 6e f3 22 f0    	mov    %ax,0xf022f36e
	SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL], 0, GD_KT, handler36, 0);
f0103b0f:	b8 90 41 10 f0       	mov    $0xf0104190,%eax
f0103b14:	66 a3 80 f3 22 f0    	mov    %ax,0xf022f380
f0103b1a:	66 c7 05 82 f3 22 f0 	movw   $0x8,0xf022f382
f0103b21:	08 00 
f0103b23:	c6 05 84 f3 22 f0 00 	movb   $0x0,0xf022f384
f0103b2a:	c6 05 85 f3 22 f0 8e 	movb   $0x8e,0xf022f385
f0103b31:	c1 e8 10             	shr    $0x10,%eax
f0103b34:	66 a3 86 f3 22 f0    	mov    %ax,0xf022f386
	SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS], 0, GD_KT, handler39, 0);
f0103b3a:	b8 96 41 10 f0       	mov    $0xf0104196,%eax
f0103b3f:	66 a3 98 f3 22 f0    	mov    %ax,0xf022f398
f0103b45:	66 c7 05 9a f3 22 f0 	movw   $0x8,0xf022f39a
f0103b4c:	08 00 
f0103b4e:	c6 05 9c f3 22 f0 00 	movb   $0x0,0xf022f39c
f0103b55:	c6 05 9d f3 22 f0 8e 	movb   $0x8e,0xf022f39d
f0103b5c:	c1 e8 10             	shr    $0x10,%eax
f0103b5f:	66 a3 9e f3 22 f0    	mov    %ax,0xf022f39e
	SETGATE(idt[IRQ_OFFSET+IRQ_IDE], 0, GD_KT, handler46, 0);
f0103b65:	b8 9c 41 10 f0       	mov    $0xf010419c,%eax
f0103b6a:	66 a3 d0 f3 22 f0    	mov    %ax,0xf022f3d0
f0103b70:	66 c7 05 d2 f3 22 f0 	movw   $0x8,0xf022f3d2
f0103b77:	08 00 
f0103b79:	c6 05 d4 f3 22 f0 00 	movb   $0x0,0xf022f3d4
f0103b80:	c6 05 d5 f3 22 f0 8e 	movb   $0x8e,0xf022f3d5
f0103b87:	c1 e8 10             	shr    $0x10,%eax
f0103b8a:	66 a3 d6 f3 22 f0    	mov    %ax,0xf022f3d6
	SETGATE(idt[IRQ_OFFSET+IRQ_ERROR], 0, GD_KT, handler51, 0);
f0103b90:	b8 a2 41 10 f0       	mov    $0xf01041a2,%eax
f0103b95:	66 a3 f8 f3 22 f0    	mov    %ax,0xf022f3f8
f0103b9b:	66 c7 05 fa f3 22 f0 	movw   $0x8,0xf022f3fa
f0103ba2:	08 00 
f0103ba4:	c6 05 fc f3 22 f0 00 	movb   $0x0,0xf022f3fc
f0103bab:	c6 05 fd f3 22 f0 8e 	movb   $0x8e,0xf022f3fd
f0103bb2:	c1 e8 10             	shr    $0x10,%eax
f0103bb5:	66 a3 fe f3 22 f0    	mov    %ax,0xf022f3fe

	// Per-CPU setup 
	trap_init_percpu();
f0103bbb:	e8 9a fb ff ff       	call   f010375a <trap_init_percpu>
}
f0103bc0:	c9                   	leave  
f0103bc1:	c3                   	ret    

f0103bc2 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103bc2:	55                   	push   %ebp
f0103bc3:	89 e5                	mov    %esp,%ebp
f0103bc5:	53                   	push   %ebx
f0103bc6:	83 ec 0c             	sub    $0xc,%esp
f0103bc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103bcc:	ff 33                	pushl  (%ebx)
f0103bce:	68 13 74 10 f0       	push   $0xf0107413
f0103bd3:	e8 6e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103bd8:	83 c4 08             	add    $0x8,%esp
f0103bdb:	ff 73 04             	pushl  0x4(%ebx)
f0103bde:	68 22 74 10 f0       	push   $0xf0107422
f0103be3:	e8 5e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103be8:	83 c4 08             	add    $0x8,%esp
f0103beb:	ff 73 08             	pushl  0x8(%ebx)
f0103bee:	68 31 74 10 f0       	push   $0xf0107431
f0103bf3:	e8 4e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103bf8:	83 c4 08             	add    $0x8,%esp
f0103bfb:	ff 73 0c             	pushl  0xc(%ebx)
f0103bfe:	68 40 74 10 f0       	push   $0xf0107440
f0103c03:	e8 3e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c08:	83 c4 08             	add    $0x8,%esp
f0103c0b:	ff 73 10             	pushl  0x10(%ebx)
f0103c0e:	68 4f 74 10 f0       	push   $0xf010744f
f0103c13:	e8 2e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c18:	83 c4 08             	add    $0x8,%esp
f0103c1b:	ff 73 14             	pushl  0x14(%ebx)
f0103c1e:	68 5e 74 10 f0       	push   $0xf010745e
f0103c23:	e8 1e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c28:	83 c4 08             	add    $0x8,%esp
f0103c2b:	ff 73 18             	pushl  0x18(%ebx)
f0103c2e:	68 6d 74 10 f0       	push   $0xf010746d
f0103c33:	e8 0e fb ff ff       	call   f0103746 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c38:	83 c4 08             	add    $0x8,%esp
f0103c3b:	ff 73 1c             	pushl  0x1c(%ebx)
f0103c3e:	68 7c 74 10 f0       	push   $0xf010747c
f0103c43:	e8 fe fa ff ff       	call   f0103746 <cprintf>
}
f0103c48:	83 c4 10             	add    $0x10,%esp
f0103c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c4e:	c9                   	leave  
f0103c4f:	c3                   	ret    

f0103c50 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103c50:	55                   	push   %ebp
f0103c51:	89 e5                	mov    %esp,%ebp
f0103c53:	56                   	push   %esi
f0103c54:	53                   	push   %ebx
f0103c55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103c58:	e8 a9 1d 00 00       	call   f0105a06 <cpunum>
f0103c5d:	83 ec 04             	sub    $0x4,%esp
f0103c60:	50                   	push   %eax
f0103c61:	53                   	push   %ebx
f0103c62:	68 e0 74 10 f0       	push   $0xf01074e0
f0103c67:	e8 da fa ff ff       	call   f0103746 <cprintf>
	print_regs(&tf->tf_regs);
f0103c6c:	89 1c 24             	mov    %ebx,(%esp)
f0103c6f:	e8 4e ff ff ff       	call   f0103bc2 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103c74:	83 c4 08             	add    $0x8,%esp
f0103c77:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103c7b:	50                   	push   %eax
f0103c7c:	68 fe 74 10 f0       	push   $0xf01074fe
f0103c81:	e8 c0 fa ff ff       	call   f0103746 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103c86:	83 c4 08             	add    $0x8,%esp
f0103c89:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103c8d:	50                   	push   %eax
f0103c8e:	68 11 75 10 f0       	push   $0xf0107511
f0103c93:	e8 ae fa ff ff       	call   f0103746 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c98:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103c9b:	83 c4 10             	add    $0x10,%esp
f0103c9e:	83 f8 13             	cmp    $0x13,%eax
f0103ca1:	77 09                	ja     f0103cac <print_trapframe+0x5c>
		return excnames[trapno];
f0103ca3:	8b 14 85 a0 77 10 f0 	mov    -0xfef8860(,%eax,4),%edx
f0103caa:	eb 1f                	jmp    f0103ccb <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103cac:	83 f8 30             	cmp    $0x30,%eax
f0103caf:	74 15                	je     f0103cc6 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103cb1:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103cb4:	83 fa 10             	cmp    $0x10,%edx
f0103cb7:	b9 aa 74 10 f0       	mov    $0xf01074aa,%ecx
f0103cbc:	ba 97 74 10 f0       	mov    $0xf0107497,%edx
f0103cc1:	0f 43 d1             	cmovae %ecx,%edx
f0103cc4:	eb 05                	jmp    f0103ccb <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103cc6:	ba 8b 74 10 f0       	mov    $0xf010748b,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ccb:	83 ec 04             	sub    $0x4,%esp
f0103cce:	52                   	push   %edx
f0103ccf:	50                   	push   %eax
f0103cd0:	68 24 75 10 f0       	push   $0xf0107524
f0103cd5:	e8 6c fa ff ff       	call   f0103746 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103cda:	83 c4 10             	add    $0x10,%esp
f0103cdd:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103ce3:	75 1a                	jne    f0103cff <print_trapframe+0xaf>
f0103ce5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ce9:	75 14                	jne    f0103cff <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103ceb:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103cee:	83 ec 08             	sub    $0x8,%esp
f0103cf1:	50                   	push   %eax
f0103cf2:	68 36 75 10 f0       	push   $0xf0107536
f0103cf7:	e8 4a fa ff ff       	call   f0103746 <cprintf>
f0103cfc:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103cff:	83 ec 08             	sub    $0x8,%esp
f0103d02:	ff 73 2c             	pushl  0x2c(%ebx)
f0103d05:	68 45 75 10 f0       	push   $0xf0107545
f0103d0a:	e8 37 fa ff ff       	call   f0103746 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103d0f:	83 c4 10             	add    $0x10,%esp
f0103d12:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d16:	75 49                	jne    f0103d61 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103d18:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103d1b:	89 c2                	mov    %eax,%edx
f0103d1d:	83 e2 01             	and    $0x1,%edx
f0103d20:	ba c4 74 10 f0       	mov    $0xf01074c4,%edx
f0103d25:	b9 b9 74 10 f0       	mov    $0xf01074b9,%ecx
f0103d2a:	0f 44 ca             	cmove  %edx,%ecx
f0103d2d:	89 c2                	mov    %eax,%edx
f0103d2f:	83 e2 02             	and    $0x2,%edx
f0103d32:	ba d6 74 10 f0       	mov    $0xf01074d6,%edx
f0103d37:	be d0 74 10 f0       	mov    $0xf01074d0,%esi
f0103d3c:	0f 45 d6             	cmovne %esi,%edx
f0103d3f:	83 e0 04             	and    $0x4,%eax
f0103d42:	be 2c 76 10 f0       	mov    $0xf010762c,%esi
f0103d47:	b8 db 74 10 f0       	mov    $0xf01074db,%eax
f0103d4c:	0f 44 c6             	cmove  %esi,%eax
f0103d4f:	51                   	push   %ecx
f0103d50:	52                   	push   %edx
f0103d51:	50                   	push   %eax
f0103d52:	68 53 75 10 f0       	push   $0xf0107553
f0103d57:	e8 ea f9 ff ff       	call   f0103746 <cprintf>
f0103d5c:	83 c4 10             	add    $0x10,%esp
f0103d5f:	eb 10                	jmp    f0103d71 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103d61:	83 ec 0c             	sub    $0xc,%esp
f0103d64:	68 3a 69 10 f0       	push   $0xf010693a
f0103d69:	e8 d8 f9 ff ff       	call   f0103746 <cprintf>
f0103d6e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103d71:	83 ec 08             	sub    $0x8,%esp
f0103d74:	ff 73 30             	pushl  0x30(%ebx)
f0103d77:	68 62 75 10 f0       	push   $0xf0107562
f0103d7c:	e8 c5 f9 ff ff       	call   f0103746 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103d81:	83 c4 08             	add    $0x8,%esp
f0103d84:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d88:	50                   	push   %eax
f0103d89:	68 71 75 10 f0       	push   $0xf0107571
f0103d8e:	e8 b3 f9 ff ff       	call   f0103746 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d93:	83 c4 08             	add    $0x8,%esp
f0103d96:	ff 73 38             	pushl  0x38(%ebx)
f0103d99:	68 84 75 10 f0       	push   $0xf0107584
f0103d9e:	e8 a3 f9 ff ff       	call   f0103746 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103da3:	83 c4 10             	add    $0x10,%esp
f0103da6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103daa:	74 25                	je     f0103dd1 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103dac:	83 ec 08             	sub    $0x8,%esp
f0103daf:	ff 73 3c             	pushl  0x3c(%ebx)
f0103db2:	68 93 75 10 f0       	push   $0xf0107593
f0103db7:	e8 8a f9 ff ff       	call   f0103746 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103dbc:	83 c4 08             	add    $0x8,%esp
f0103dbf:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103dc3:	50                   	push   %eax
f0103dc4:	68 a2 75 10 f0       	push   $0xf01075a2
f0103dc9:	e8 78 f9 ff ff       	call   f0103746 <cprintf>
f0103dce:	83 c4 10             	add    $0x10,%esp
	}
}
f0103dd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103dd4:	5b                   	pop    %ebx
f0103dd5:	5e                   	pop    %esi
f0103dd6:	5d                   	pop    %ebp
f0103dd7:	c3                   	ret    

f0103dd8 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103dd8:	55                   	push   %ebp
f0103dd9:	89 e5                	mov    %esp,%ebp
f0103ddb:	57                   	push   %edi
f0103ddc:	56                   	push   %esi
f0103ddd:	53                   	push   %ebx
f0103dde:	83 ec 0c             	sub    $0xc,%esp
f0103de1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103de4:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) {
f0103de7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103deb:	75 1e                	jne    f0103e0b <page_fault_handler+0x33>
		print_trapframe(tf);
f0103ded:	83 ec 0c             	sub    $0xc,%esp
f0103df0:	53                   	push   %ebx
f0103df1:	e8 5a fe ff ff       	call   f0103c50 <print_trapframe>
		panic("kernel page fault at va:%x\n", fault_va);
f0103df6:	56                   	push   %esi
f0103df7:	68 b5 75 10 f0       	push   $0xf01075b5
f0103dfc:	68 67 01 00 00       	push   $0x167
f0103e01:	68 d1 75 10 f0       	push   $0xf01075d1
f0103e06:	e8 35 c2 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103e0b:	e8 f6 1b 00 00       	call   f0105a06 <cpunum>
f0103e10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e13:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103e19:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103e1d:	0f 84 a7 00 00 00    	je     f0103eca <page_fault_handler+0xf2>
		struct UTrapframe *utf;
		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp <= UXSTACKTOP-1) {
f0103e23:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e26:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103e2c:	83 e8 38             	sub    $0x38,%eax
f0103e2f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103e35:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103e3a:	0f 46 d0             	cmovbe %eax,%edx
f0103e3d:	89 d7                	mov    %edx,%edi
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}

		user_mem_assert(curenv, (void*)utf, 1, PTE_W);
f0103e3f:	e8 c2 1b 00 00       	call   f0105a06 <cpunum>
f0103e44:	6a 02                	push   $0x2
f0103e46:	6a 01                	push   $0x1
f0103e48:	57                   	push   %edi
f0103e49:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e4c:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103e52:	e8 54 ef ff ff       	call   f0102dab <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0103e57:	89 fa                	mov    %edi,%edx
f0103e59:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0103e5b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103e5e:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0103e61:	8d 7f 08             	lea    0x8(%edi),%edi
f0103e64:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103e69:	89 de                	mov    %ebx,%esi
f0103e6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103e6d:	8b 43 30             	mov    0x30(%ebx),%eax
f0103e70:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0103e73:	8b 43 38             	mov    0x38(%ebx),%eax
f0103e76:	89 d7                	mov    %edx,%edi
f0103e78:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0103e7b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e7e:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0103e81:	e8 80 1b 00 00       	call   f0105a06 <cpunum>
f0103e86:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e89:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0103e8f:	e8 72 1b 00 00       	call   f0105a06 <cpunum>
f0103e94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e97:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103e9d:	8b 40 64             	mov    0x64(%eax),%eax
f0103ea0:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f0103ea3:	e8 5e 1b 00 00       	call   f0105a06 <cpunum>
f0103ea8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eab:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103eb1:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0103eb4:	e8 4d 1b 00 00       	call   f0105a06 <cpunum>
f0103eb9:	83 c4 04             	add    $0x4,%esp
f0103ebc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ebf:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103ec5:	e8 2b f6 ff ff       	call   f01034f5 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103eca:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ecd:	e8 34 1b 00 00       	call   f0105a06 <cpunum>
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ed2:	57                   	push   %edi
f0103ed3:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ed4:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ed7:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103edd:	ff 70 48             	pushl  0x48(%eax)
f0103ee0:	68 78 77 10 f0       	push   $0xf0107778
f0103ee5:	e8 5c f8 ff ff       	call   f0103746 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103eea:	89 1c 24             	mov    %ebx,(%esp)
f0103eed:	e8 5e fd ff ff       	call   f0103c50 <print_trapframe>
	env_destroy(curenv);
f0103ef2:	e8 0f 1b 00 00       	call   f0105a06 <cpunum>
f0103ef7:	83 c4 04             	add    $0x4,%esp
f0103efa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103efd:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103f03:	e8 f8 f4 ff ff       	call   f0103400 <env_destroy>
f0103f08:	83 c4 10             	add    $0x10,%esp
f0103f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f0e:	5b                   	pop    %ebx
f0103f0f:	5e                   	pop    %esi
f0103f10:	5f                   	pop    %edi
f0103f11:	5d                   	pop    %ebp
f0103f12:	c3                   	ret    

f0103f13 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f13:	55                   	push   %ebp
f0103f14:	89 e5                	mov    %esp,%ebp
f0103f16:	57                   	push   %edi
f0103f17:	56                   	push   %esi
f0103f18:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f1b:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103f1c:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f0103f23:	74 01                	je     f0103f26 <trap+0x13>
		asm volatile("hlt");
f0103f25:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103f26:	e8 db 1a 00 00       	call   f0105a06 <cpunum>
f0103f2b:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f2e:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f34:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f39:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103f3d:	83 f8 02             	cmp    $0x2,%eax
f0103f40:	75 10                	jne    f0103f52 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103f42:	83 ec 0c             	sub    $0xc,%esp
f0103f45:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f4a:	e8 25 1d 00 00       	call   f0105c74 <spin_lock>
f0103f4f:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f52:	9c                   	pushf  
f0103f53:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f54:	f6 c4 02             	test   $0x2,%ah
f0103f57:	74 19                	je     f0103f72 <trap+0x5f>
f0103f59:	68 dd 75 10 f0       	push   $0xf01075dd
f0103f5e:	68 43 66 10 f0       	push   $0xf0106643
f0103f63:	68 30 01 00 00       	push   $0x130
f0103f68:	68 d1 75 10 f0       	push   $0xf01075d1
f0103f6d:	e8 ce c0 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103f72:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f76:	83 e0 03             	and    $0x3,%eax
f0103f79:	66 83 f8 03          	cmp    $0x3,%ax
f0103f7d:	0f 85 a0 00 00 00    	jne    f0104023 <trap+0x110>
f0103f83:	83 ec 0c             	sub    $0xc,%esp
f0103f86:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f8b:	e8 e4 1c 00 00       	call   f0105c74 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103f90:	e8 71 1a 00 00       	call   f0105a06 <cpunum>
f0103f95:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f98:	83 c4 10             	add    $0x10,%esp
f0103f9b:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103fa2:	75 19                	jne    f0103fbd <trap+0xaa>
f0103fa4:	68 f6 75 10 f0       	push   $0xf01075f6
f0103fa9:	68 43 66 10 f0       	push   $0xf0106643
f0103fae:	68 38 01 00 00       	push   $0x138
f0103fb3:	68 d1 75 10 f0       	push   $0xf01075d1
f0103fb8:	e8 83 c0 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103fbd:	e8 44 1a 00 00       	call   f0105a06 <cpunum>
f0103fc2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc5:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103fcb:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103fcf:	75 2d                	jne    f0103ffe <trap+0xeb>
			env_free(curenv);
f0103fd1:	e8 30 1a 00 00       	call   f0105a06 <cpunum>
f0103fd6:	83 ec 0c             	sub    $0xc,%esp
f0103fd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fdc:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103fe2:	e8 3e f2 ff ff       	call   f0103225 <env_free>
			curenv = NULL;
f0103fe7:	e8 1a 1a 00 00       	call   f0105a06 <cpunum>
f0103fec:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fef:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f0103ff6:	00 00 00 
			sched_yield();
f0103ff9:	e8 8f 02 00 00       	call   f010428d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103ffe:	e8 03 1a 00 00       	call   f0105a06 <cpunum>
f0104003:	6b c0 74             	imul   $0x74,%eax,%eax
f0104006:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010400c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104011:	89 c7                	mov    %eax,%edi
f0104013:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104015:	e8 ec 19 00 00       	call   f0105a06 <cpunum>
f010401a:	6b c0 74             	imul   $0x74,%eax,%eax
f010401d:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104023:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f0104029:	8b 46 28             	mov    0x28(%esi),%eax
f010402c:	83 f8 0e             	cmp    $0xe,%eax
f010402f:	75 11                	jne    f0104042 <trap+0x12f>
		return page_fault_handler(tf);
f0104031:	83 ec 0c             	sub    $0xc,%esp
f0104034:	56                   	push   %esi
f0104035:	e8 9e fd ff ff       	call   f0103dd8 <page_fault_handler>
f010403a:	83 c4 10             	add    $0x10,%esp
f010403d:	e9 ad 00 00 00       	jmp    f01040ef <trap+0x1dc>
	}

	if (tf->tf_trapno == T_BRKPT) {
f0104042:	83 f8 03             	cmp    $0x3,%eax
f0104045:	75 11                	jne    f0104058 <trap+0x145>
		return monitor(tf);
f0104047:	83 ec 0c             	sub    $0xc,%esp
f010404a:	56                   	push   %esi
f010404b:	e8 ab c8 ff ff       	call   f01008fb <monitor>
f0104050:	83 c4 10             	add    $0x10,%esp
f0104053:	e9 97 00 00 00       	jmp    f01040ef <trap+0x1dc>
	}

	if (tf->tf_trapno == T_SYSCALL) {
f0104058:	83 f8 30             	cmp    $0x30,%eax
f010405b:	75 21                	jne    f010407e <trap+0x16b>
		tf->tf_regs.reg_eax = syscall(
f010405d:	83 ec 08             	sub    $0x8,%esp
f0104060:	ff 76 04             	pushl  0x4(%esi)
f0104063:	ff 36                	pushl  (%esi)
f0104065:	ff 76 10             	pushl  0x10(%esi)
f0104068:	ff 76 18             	pushl  0x18(%esi)
f010406b:	ff 76 14             	pushl  0x14(%esi)
f010406e:	ff 76 1c             	pushl  0x1c(%esi)
f0104071:	e8 a0 02 00 00       	call   f0104316 <syscall>
f0104076:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104079:	83 c4 20             	add    $0x20,%esp
f010407c:	eb 71                	jmp    f01040ef <trap+0x1dc>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010407e:	83 f8 27             	cmp    $0x27,%eax
f0104081:	75 1a                	jne    f010409d <trap+0x18a>
		cprintf("Spurious interrupt on irq 7\n");
f0104083:	83 ec 0c             	sub    $0xc,%esp
f0104086:	68 fd 75 10 f0       	push   $0xf01075fd
f010408b:	e8 b6 f6 ff ff       	call   f0103746 <cprintf>
		print_trapframe(tf);
f0104090:	89 34 24             	mov    %esi,(%esp)
f0104093:	e8 b8 fb ff ff       	call   f0103c50 <print_trapframe>
f0104098:	83 c4 10             	add    $0x10,%esp
f010409b:	eb 52                	jmp    f01040ef <trap+0x1dc>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010409d:	83 f8 20             	cmp    $0x20,%eax
f01040a0:	75 0a                	jne    f01040ac <trap+0x199>
		// cprintf("irq timer\n");
		lapic_eoi();
f01040a2:	e8 aa 1a 00 00       	call   f0105b51 <lapic_eoi>
		sched_yield();
f01040a7:	e8 e1 01 00 00       	call   f010428d <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01040ac:	83 ec 0c             	sub    $0xc,%esp
f01040af:	56                   	push   %esi
f01040b0:	e8 9b fb ff ff       	call   f0103c50 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01040b5:	83 c4 10             	add    $0x10,%esp
f01040b8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01040bd:	75 17                	jne    f01040d6 <trap+0x1c3>
		panic("unhandled trap in kernel");
f01040bf:	83 ec 04             	sub    $0x4,%esp
f01040c2:	68 1a 76 10 f0       	push   $0xf010761a
f01040c7:	68 16 01 00 00       	push   $0x116
f01040cc:	68 d1 75 10 f0       	push   $0xf01075d1
f01040d1:	e8 6a bf ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01040d6:	e8 2b 19 00 00       	call   f0105a06 <cpunum>
f01040db:	83 ec 0c             	sub    $0xc,%esp
f01040de:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e1:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01040e7:	e8 14 f3 ff ff       	call   f0103400 <env_destroy>
f01040ec:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01040ef:	e8 12 19 00 00       	call   f0105a06 <cpunum>
f01040f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f7:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01040fe:	74 2a                	je     f010412a <trap+0x217>
f0104100:	e8 01 19 00 00       	call   f0105a06 <cpunum>
f0104105:	6b c0 74             	imul   $0x74,%eax,%eax
f0104108:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010410e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104112:	75 16                	jne    f010412a <trap+0x217>
		env_run(curenv);
f0104114:	e8 ed 18 00 00       	call   f0105a06 <cpunum>
f0104119:	83 ec 0c             	sub    $0xc,%esp
f010411c:	6b c0 74             	imul   $0x74,%eax,%eax
f010411f:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104125:	e8 cb f3 ff ff       	call   f01034f5 <env_run>
	else
		sched_yield();
f010412a:	e8 5e 01 00 00       	call   f010428d <sched_yield>
f010412f:	90                   	nop

f0104130 <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f0104130:	6a 00                	push   $0x0
f0104132:	6a 00                	push   $0x0
f0104134:	eb 72                	jmp    f01041a8 <_alltraps>

f0104136 <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f0104136:	6a 00                	push   $0x0
f0104138:	6a 01                	push   $0x1
f010413a:	eb 6c                	jmp    f01041a8 <_alltraps>

f010413c <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f010413c:	6a 00                	push   $0x0
f010413e:	6a 02                	push   $0x2
f0104140:	eb 66                	jmp    f01041a8 <_alltraps>

f0104142 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f0104142:	6a 00                	push   $0x0
f0104144:	6a 03                	push   $0x3
f0104146:	eb 60                	jmp    f01041a8 <_alltraps>

f0104148 <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f0104148:	6a 00                	push   $0x0
f010414a:	6a 04                	push   $0x4
f010414c:	eb 5a                	jmp    f01041a8 <_alltraps>

f010414e <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f010414e:	6a 00                	push   $0x0
f0104150:	6a 05                	push   $0x5
f0104152:	eb 54                	jmp    f01041a8 <_alltraps>

f0104154 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f0104154:	6a 00                	push   $0x0
f0104156:	6a 06                	push   $0x6
f0104158:	eb 4e                	jmp    f01041a8 <_alltraps>

f010415a <handler7>:
TRAPHANDLER(handler7, T_DEVICE)
f010415a:	6a 07                	push   $0x7
f010415c:	eb 4a                	jmp    f01041a8 <_alltraps>

f010415e <handler8>:
TRAPHANDLER_NOEC(handler8, T_DBLFLT)
f010415e:	6a 00                	push   $0x0
f0104160:	6a 08                	push   $0x8
f0104162:	eb 44                	jmp    f01041a8 <_alltraps>

f0104164 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f0104164:	6a 0a                	push   $0xa
f0104166:	eb 40                	jmp    f01041a8 <_alltraps>

f0104168 <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f0104168:	6a 0b                	push   $0xb
f010416a:	eb 3c                	jmp    f01041a8 <_alltraps>

f010416c <handler12>:
TRAPHANDLER(handler12, T_STACK)
f010416c:	6a 0c                	push   $0xc
f010416e:	eb 38                	jmp    f01041a8 <_alltraps>

f0104170 <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104170:	6a 0d                	push   $0xd
f0104172:	eb 34                	jmp    f01041a8 <_alltraps>

f0104174 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104174:	6a 0e                	push   $0xe
f0104176:	eb 30                	jmp    f01041a8 <_alltraps>

f0104178 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0104178:	6a 00                	push   $0x0
f010417a:	6a 10                	push   $0x10
f010417c:	eb 2a                	jmp    f01041a8 <_alltraps>

f010417e <handler48>:
TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f010417e:	6a 00                	push   $0x0
f0104180:	6a 30                	push   $0x30
f0104182:	eb 24                	jmp    f01041a8 <_alltraps>

f0104184 <handler32>:
TRAPHANDLER_NOEC(handler32, IRQ_OFFSET + IRQ_TIMER)
f0104184:	6a 00                	push   $0x0
f0104186:	6a 20                	push   $0x20
f0104188:	eb 1e                	jmp    f01041a8 <_alltraps>

f010418a <handler33>:
TRAPHANDLER_NOEC(handler33, IRQ_OFFSET + IRQ_KBD)
f010418a:	6a 00                	push   $0x0
f010418c:	6a 21                	push   $0x21
f010418e:	eb 18                	jmp    f01041a8 <_alltraps>

f0104190 <handler36>:
TRAPHANDLER_NOEC(handler36, IRQ_OFFSET + IRQ_SERIAL)
f0104190:	6a 00                	push   $0x0
f0104192:	6a 24                	push   $0x24
f0104194:	eb 12                	jmp    f01041a8 <_alltraps>

f0104196 <handler39>:
TRAPHANDLER_NOEC(handler39, IRQ_OFFSET + IRQ_SPURIOUS)
f0104196:	6a 00                	push   $0x0
f0104198:	6a 27                	push   $0x27
f010419a:	eb 0c                	jmp    f01041a8 <_alltraps>

f010419c <handler46>:
TRAPHANDLER_NOEC(handler46, IRQ_OFFSET + IRQ_IDE)
f010419c:	6a 00                	push   $0x0
f010419e:	6a 2e                	push   $0x2e
f01041a0:	eb 06                	jmp    f01041a8 <_alltraps>

f01041a2 <handler51>:
TRAPHANDLER_NOEC(handler51, IRQ_OFFSET + IRQ_ERROR)
f01041a2:	6a 00                	push   $0x0
f01041a4:	6a 33                	push   $0x33
f01041a6:	eb 00                	jmp    f01041a8 <_alltraps>

f01041a8 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01041a8:	1e                   	push   %ds
	pushl %es
f01041a9:	06                   	push   %es
	pushal
f01041aa:	60                   	pusha  
	movw $GD_KD, %ax
f01041ab:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01041af:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01041b1:	8e c0                	mov    %eax,%es
	pushl %esp
f01041b3:	54                   	push   %esp
f01041b4:	e8 5a fd ff ff       	call   f0103f13 <trap>

f01041b9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01041b9:	55                   	push   %ebp
f01041ba:	89 e5                	mov    %esp,%ebp
f01041bc:	83 ec 08             	sub    $0x8,%esp
f01041bf:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
f01041c4:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041c7:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01041cc:	8b 02                	mov    (%edx),%eax
f01041ce:	83 e8 01             	sub    $0x1,%eax
f01041d1:	83 f8 02             	cmp    $0x2,%eax
f01041d4:	76 10                	jbe    f01041e6 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041d6:	83 c1 01             	add    $0x1,%ecx
f01041d9:	83 c2 7c             	add    $0x7c,%edx
f01041dc:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041e2:	75 e8                	jne    f01041cc <sched_halt+0x13>
f01041e4:	eb 08                	jmp    f01041ee <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01041e6:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041ec:	75 1f                	jne    f010420d <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01041ee:	83 ec 0c             	sub    $0xc,%esp
f01041f1:	68 f0 77 10 f0       	push   $0xf01077f0
f01041f6:	e8 4b f5 ff ff       	call   f0103746 <cprintf>
f01041fb:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01041fe:	83 ec 0c             	sub    $0xc,%esp
f0104201:	6a 00                	push   $0x0
f0104203:	e8 f3 c6 ff ff       	call   f01008fb <monitor>
f0104208:	83 c4 10             	add    $0x10,%esp
f010420b:	eb f1                	jmp    f01041fe <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010420d:	e8 f4 17 00 00       	call   f0105a06 <cpunum>
f0104212:	6b c0 74             	imul   $0x74,%eax,%eax
f0104215:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f010421c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010421f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104224:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104229:	77 12                	ja     f010423d <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010422b:	50                   	push   %eax
f010422c:	68 e8 60 10 f0       	push   $0xf01060e8
f0104231:	6a 4a                	push   $0x4a
f0104233:	68 19 78 10 f0       	push   $0xf0107819
f0104238:	e8 03 be ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010423d:	05 00 00 00 10       	add    $0x10000000,%eax
f0104242:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104245:	e8 bc 17 00 00       	call   f0105a06 <cpunum>
f010424a:	6b d0 74             	imul   $0x74,%eax,%edx
f010424d:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104253:	b8 02 00 00 00       	mov    $0x2,%eax
f0104258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010425c:	83 ec 0c             	sub    $0xc,%esp
f010425f:	68 c0 03 12 f0       	push   $0xf01203c0
f0104264:	e8 a8 1a 00 00       	call   f0105d11 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104269:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010426b:	e8 96 17 00 00       	call   f0105a06 <cpunum>
f0104270:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104273:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f0104279:	bd 00 00 00 00       	mov    $0x0,%ebp
f010427e:	89 c4                	mov    %eax,%esp
f0104280:	6a 00                	push   $0x0
f0104282:	6a 00                	push   $0x0
f0104284:	fb                   	sti    
f0104285:	f4                   	hlt    
f0104286:	eb fd                	jmp    f0104285 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104288:	83 c4 10             	add    $0x10,%esp
f010428b:	c9                   	leave  
f010428c:	c3                   	ret    

f010428d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010428d:	55                   	push   %ebp
f010428e:	89 e5                	mov    %esp,%ebp
f0104290:	57                   	push   %edi
f0104291:	56                   	push   %esi
f0104292:	53                   	push   %ebx
f0104293:	83 ec 0c             	sub    $0xc,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = curenv;
f0104296:	e8 6b 17 00 00       	call   f0105a06 <cpunum>
f010429b:	6b c0 74             	imul   $0x74,%eax,%eax
f010429e:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	int start_envid = idle ? ENVX(idle->env_id)+1 : 0;
f01042a4:	85 f6                	test   %esi,%esi
f01042a6:	74 0e                	je     f01042b6 <sched_yield+0x29>
f01042a8:	8b 4e 48             	mov    0x48(%esi),%ecx
f01042ab:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01042b1:	83 c1 01             	add    $0x1,%ecx
f01042b4:	eb 05                	jmp    f01042bb <sched_yield+0x2e>
f01042b6:	b9 00 00 00 00       	mov    $0x0,%ecx

	for (int i = 0; i < NENV; i++) {
		int j = (start_envid + i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
f01042bb:	8b 1d 48 f2 22 f0    	mov    0xf022f248,%ebx
f01042c1:	89 ca                	mov    %ecx,%edx
f01042c3:	81 c1 00 04 00 00    	add    $0x400,%ecx
f01042c9:	89 d7                	mov    %edx,%edi
f01042cb:	c1 ff 1f             	sar    $0x1f,%edi
f01042ce:	c1 ef 16             	shr    $0x16,%edi
f01042d1:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f01042d4:	25 ff 03 00 00       	and    $0x3ff,%eax
f01042d9:	29 f8                	sub    %edi,%eax
f01042db:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01042de:	01 d8                	add    %ebx,%eax
f01042e0:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01042e4:	75 09                	jne    f01042ef <sched_yield+0x62>
			env_run(&envs[j]);
f01042e6:	83 ec 0c             	sub    $0xc,%esp
f01042e9:	50                   	push   %eax
f01042ea:	e8 06 f2 ff ff       	call   f01034f5 <env_run>
f01042ef:	83 c2 01             	add    $0x1,%edx

	// LAB 4: Your code here.
	idle = curenv;
	int start_envid = idle ? ENVX(idle->env_id)+1 : 0;

	for (int i = 0; i < NENV; i++) {
f01042f2:	39 ca                	cmp    %ecx,%edx
f01042f4:	75 d3                	jne    f01042c9 <sched_yield+0x3c>
		if (envs[j].env_status == ENV_RUNNABLE) {
			env_run(&envs[j]);
		}
	}

	if (idle && idle->env_status == ENV_RUNNING) {
f01042f6:	85 f6                	test   %esi,%esi
f01042f8:	74 0f                	je     f0104309 <sched_yield+0x7c>
f01042fa:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f01042fe:	75 09                	jne    f0104309 <sched_yield+0x7c>
		env_run(idle);
f0104300:	83 ec 0c             	sub    $0xc,%esp
f0104303:	56                   	push   %esi
f0104304:	e8 ec f1 ff ff       	call   f01034f5 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104309:	e8 ab fe ff ff       	call   f01041b9 <sched_halt>
}
f010430e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104311:	5b                   	pop    %ebx
f0104312:	5e                   	pop    %esi
f0104313:	5f                   	pop    %edi
f0104314:	5d                   	pop    %ebp
f0104315:	c3                   	ret    

f0104316 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104316:	55                   	push   %ebp
f0104317:	89 e5                	mov    %esp,%ebp
f0104319:	57                   	push   %edi
f010431a:	56                   	push   %esi
f010431b:	53                   	push   %ebx
f010431c:	83 ec 1c             	sub    $0x1c,%esp
f010431f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104322:	83 f8 0c             	cmp    $0xc,%eax
f0104325:	0f 87 27 05 00 00    	ja     f0104852 <syscall+0x53c>
f010432b:	ff 24 85 60 78 10 f0 	jmp    *-0xfef87a0(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104332:	e8 cf 16 00 00       	call   f0105a06 <cpunum>
f0104337:	6a 00                	push   $0x0
f0104339:	ff 75 10             	pushl  0x10(%ebp)
f010433c:	ff 75 0c             	pushl  0xc(%ebp)
f010433f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104342:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104348:	e8 5e ea ff ff       	call   f0102dab <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010434d:	83 c4 0c             	add    $0xc,%esp
f0104350:	ff 75 0c             	pushl  0xc(%ebp)
f0104353:	ff 75 10             	pushl  0x10(%ebp)
f0104356:	68 26 78 10 f0       	push   $0xf0107826
f010435b:	e8 e6 f3 ff ff       	call   f0103746 <cprintf>
f0104360:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
f0104363:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104368:	e9 f1 04 00 00       	jmp    f010485e <syscall+0x548>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010436d:	e8 75 c2 ff ff       	call   f01005e7 <cons_getc>
f0104372:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104374:	e9 e5 04 00 00       	jmp    f010485e <syscall+0x548>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104379:	e8 88 16 00 00       	call   f0105a06 <cpunum>
f010437e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104381:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104387:	8b 58 48             	mov    0x48(%eax),%ebx
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f010438a:	e9 cf 04 00 00       	jmp    f010485e <syscall+0x548>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010438f:	83 ec 04             	sub    $0x4,%esp
f0104392:	6a 01                	push   $0x1
f0104394:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104397:	50                   	push   %eax
f0104398:	ff 75 0c             	pushl  0xc(%ebp)
f010439b:	e8 c0 ea ff ff       	call   f0102e60 <envid2env>
f01043a0:	83 c4 10             	add    $0x10,%esp
		return r;
f01043a3:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01043a5:	85 c0                	test   %eax,%eax
f01043a7:	0f 88 b1 04 00 00    	js     f010485e <syscall+0x548>
		return r;
	if (e == curenv)
f01043ad:	e8 54 16 00 00       	call   f0105a06 <cpunum>
f01043b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01043b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b8:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f01043be:	75 23                	jne    f01043e3 <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01043c0:	e8 41 16 00 00       	call   f0105a06 <cpunum>
f01043c5:	83 ec 08             	sub    $0x8,%esp
f01043c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043cb:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01043d1:	ff 70 48             	pushl  0x48(%eax)
f01043d4:	68 2b 78 10 f0       	push   $0xf010782b
f01043d9:	e8 68 f3 ff ff       	call   f0103746 <cprintf>
f01043de:	83 c4 10             	add    $0x10,%esp
f01043e1:	eb 25                	jmp    f0104408 <syscall+0xf2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01043e3:	8b 5a 48             	mov    0x48(%edx),%ebx
f01043e6:	e8 1b 16 00 00       	call   f0105a06 <cpunum>
f01043eb:	83 ec 04             	sub    $0x4,%esp
f01043ee:	53                   	push   %ebx
f01043ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f2:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01043f8:	ff 70 48             	pushl  0x48(%eax)
f01043fb:	68 46 78 10 f0       	push   $0xf0107846
f0104400:	e8 41 f3 ff ff       	call   f0103746 <cprintf>
f0104405:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104408:	83 ec 0c             	sub    $0xc,%esp
f010440b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010440e:	e8 ed ef ff ff       	call   f0103400 <env_destroy>
f0104413:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104416:	bb 00 00 00 00       	mov    $0x0,%ebx
f010441b:	e9 3e 04 00 00       	jmp    f010485e <syscall+0x548>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104420:	e8 68 fe ff ff       	call   f010428d <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");
	struct Env *e;
	int ret = env_alloc(&e, curenv->env_id);
f0104425:	e8 dc 15 00 00       	call   f0105a06 <cpunum>
f010442a:	83 ec 08             	sub    $0x8,%esp
f010442d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104430:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104436:	ff 70 48             	pushl  0x48(%eax)
f0104439:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010443c:	50                   	push   %eax
f010443d:	e8 30 eb ff ff       	call   f0102f72 <env_alloc>
	if (ret) return ret;
f0104442:	83 c4 10             	add    $0x10,%esp
f0104445:	89 c3                	mov    %eax,%ebx
f0104447:	85 c0                	test   %eax,%eax
f0104449:	0f 85 0f 04 00 00    	jne    f010485e <syscall+0x548>

	e->env_status = ENV_NOT_RUNNABLE;
f010444f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104452:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104459:	e8 a8 15 00 00       	call   f0105a06 <cpunum>
f010445e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104461:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
f0104467:	b9 11 00 00 00       	mov    $0x11,%ecx
f010446c:	89 df                	mov    %ebx,%edi
f010446e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0104470:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104473:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f010447a:	8b 58 48             	mov    0x48(%eax),%ebx
f010447d:	e9 dc 03 00 00       	jmp    f010485e <syscall+0x548>
	// envid's status.

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f0104482:	83 ec 04             	sub    $0x4,%esp
f0104485:	6a 01                	push   $0x1
f0104487:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010448a:	50                   	push   %eax
f010448b:	ff 75 0c             	pushl  0xc(%ebp)
f010448e:	e8 cd e9 ff ff       	call   f0102e60 <envid2env>
f0104493:	89 c3                	mov    %eax,%ebx
f0104495:	83 c4 10             	add    $0x10,%esp
f0104498:	85 c0                	test   %eax,%eax
f010449a:	75 1b                	jne    f01044b7 <syscall+0x1a1>

	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f010449c:	8b 45 10             	mov    0x10(%ebp),%eax
f010449f:	83 e8 02             	sub    $0x2,%eax
f01044a2:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01044a7:	75 18                	jne    f01044c1 <syscall+0x1ab>

	e->env_status = status;
f01044a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01044af:	89 48 54             	mov    %ecx,0x54(%eax)
f01044b2:	e9 a7 03 00 00       	jmp    f010485e <syscall+0x548>
	// envid's status.

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f01044b7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01044bc:	e9 9d 03 00 00       	jmp    f010485e <syscall+0x548>

	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f01044c1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f01044c6:	e9 93 03 00 00       	jmp    f010485e <syscall+0x548>
	//   allocated!

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f01044cb:	83 ec 04             	sub    $0x4,%esp
f01044ce:	6a 01                	push   $0x1
f01044d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044d3:	50                   	push   %eax
f01044d4:	ff 75 0c             	pushl  0xc(%ebp)
f01044d7:	e8 84 e9 ff ff       	call   f0102e60 <envid2env>
f01044dc:	83 c4 10             	add    $0x10,%esp
f01044df:	85 c0                	test   %eax,%eax
f01044e1:	78 57                	js     f010453a <syscall+0x224>

	int valid_perm = (PTE_U|PTE_P);
	if (va >= (void *)UTOP || (perm & valid_perm) != valid_perm) {
f01044e3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01044ea:	77 58                	ja     f0104544 <syscall+0x22e>
f01044ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01044ef:	83 e0 05             	and    $0x5,%eax
f01044f2:	83 f8 05             	cmp    $0x5,%eax
f01044f5:	75 57                	jne    f010454e <syscall+0x238>
		return -E_INVAL;
	}

	struct PageInfo *p = page_alloc(1);
f01044f7:	83 ec 0c             	sub    $0xc,%esp
f01044fa:	6a 01                	push   $0x1
f01044fc:	e8 f0 c9 ff ff       	call   f0100ef1 <page_alloc>
f0104501:	89 c6                	mov    %eax,%esi
	if (!p) return -E_NO_MEM;
f0104503:	83 c4 10             	add    $0x10,%esp
f0104506:	85 c0                	test   %eax,%eax
f0104508:	74 4e                	je     f0104558 <syscall+0x242>

	int ret = page_insert(e->env_pgdir, p, va, perm);
f010450a:	ff 75 14             	pushl  0x14(%ebp)
f010450d:	ff 75 10             	pushl  0x10(%ebp)
f0104510:	50                   	push   %eax
f0104511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104514:	ff 70 60             	pushl  0x60(%eax)
f0104517:	e8 ac cc ff ff       	call   f01011c8 <page_insert>
	if (ret) {
f010451c:	83 c4 10             	add    $0x10,%esp
		page_free(p);
	}
	return ret;
f010451f:	89 c3                	mov    %eax,%ebx

	struct PageInfo *p = page_alloc(1);
	if (!p) return -E_NO_MEM;

	int ret = page_insert(e->env_pgdir, p, va, perm);
	if (ret) {
f0104521:	85 c0                	test   %eax,%eax
f0104523:	0f 84 35 03 00 00    	je     f010485e <syscall+0x548>
		page_free(p);
f0104529:	83 ec 0c             	sub    $0xc,%esp
f010452c:	56                   	push   %esi
f010452d:	e8 2f ca ff ff       	call   f0100f61 <page_free>
f0104532:	83 c4 10             	add    $0x10,%esp
f0104535:	e9 24 03 00 00       	jmp    f010485e <syscall+0x548>
	//   allocated!

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f010453a:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010453f:	e9 1a 03 00 00       	jmp    f010485e <syscall+0x548>

	int valid_perm = (PTE_U|PTE_P);
	if (va >= (void *)UTOP || (perm & valid_perm) != valid_perm) {
		return -E_INVAL;
f0104544:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104549:	e9 10 03 00 00       	jmp    f010485e <syscall+0x548>
f010454e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104553:	e9 06 03 00 00       	jmp    f010485e <syscall+0x548>
	}

	struct PageInfo *p = page_alloc(1);
	if (!p) return -E_NO_MEM;
f0104558:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010455d:	e9 fc 02 00 00       	jmp    f010485e <syscall+0x548>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");
	struct Env *srcenv, *dstenv;
	if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &dstenv, 1)) {
f0104562:	83 ec 04             	sub    $0x4,%esp
f0104565:	6a 01                	push   $0x1
f0104567:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010456a:	50                   	push   %eax
f010456b:	ff 75 0c             	pushl  0xc(%ebp)
f010456e:	e8 ed e8 ff ff       	call   f0102e60 <envid2env>
f0104573:	83 c4 10             	add    $0x10,%esp
f0104576:	85 c0                	test   %eax,%eax
f0104578:	0f 85 88 00 00 00    	jne    f0104606 <syscall+0x2f0>
f010457e:	83 ec 04             	sub    $0x4,%esp
f0104581:	6a 01                	push   $0x1
f0104583:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104586:	50                   	push   %eax
f0104587:	ff 75 14             	pushl  0x14(%ebp)
f010458a:	e8 d1 e8 ff ff       	call   f0102e60 <envid2env>
f010458f:	83 c4 10             	add    $0x10,%esp
f0104592:	85 c0                	test   %eax,%eax
f0104594:	75 7a                	jne    f0104610 <syscall+0x2fa>
		return -E_BAD_ENV;
	}

	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || PGOFF(srcva) || PGOFF(dstva)) {
f0104596:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010459d:	77 7b                	ja     f010461a <syscall+0x304>
f010459f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01045a6:	77 72                	ja     f010461a <syscall+0x304>
f01045a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01045ab:	0b 45 18             	or     0x18(%ebp),%eax
f01045ae:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01045b3:	75 6f                	jne    f0104624 <syscall+0x30e>
		return -E_INVAL;
	}

	pte_t *pte;
	struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01045b5:	83 ec 04             	sub    $0x4,%esp
f01045b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045bb:	50                   	push   %eax
f01045bc:	ff 75 10             	pushl  0x10(%ebp)
f01045bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01045c2:	ff 70 60             	pushl  0x60(%eax)
f01045c5:	e8 18 cb ff ff       	call   f01010e2 <page_lookup>
	if (!p) return -E_INVAL;
f01045ca:	83 c4 10             	add    $0x10,%esp
f01045cd:	85 c0                	test   %eax,%eax
f01045cf:	74 5d                	je     f010462e <syscall+0x318>

	int valid_perm = (PTE_U|PTE_P);
	if ((perm&valid_perm) != valid_perm) return -E_INVAL;
f01045d1:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01045d4:	83 e2 05             	and    $0x5,%edx
f01045d7:	83 fa 05             	cmp    $0x5,%edx
f01045da:	75 5c                	jne    f0104638 <syscall+0x322>

	if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01045dc:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01045e0:	74 08                	je     f01045ea <syscall+0x2d4>
f01045e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01045e5:	f6 02 02             	testb  $0x2,(%edx)
f01045e8:	74 58                	je     f0104642 <syscall+0x32c>

	int ret = page_insert(dstenv->env_pgdir, p, dstva, perm);
f01045ea:	ff 75 1c             	pushl  0x1c(%ebp)
f01045ed:	ff 75 18             	pushl  0x18(%ebp)
f01045f0:	50                   	push   %eax
f01045f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045f4:	ff 70 60             	pushl  0x60(%eax)
f01045f7:	e8 cc cb ff ff       	call   f01011c8 <page_insert>
f01045fc:	83 c4 10             	add    $0x10,%esp
	return ret;
f01045ff:	89 c3                	mov    %eax,%ebx
f0104601:	e9 58 02 00 00       	jmp    f010485e <syscall+0x548>

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");
	struct Env *srcenv, *dstenv;
	if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &dstenv, 1)) {
		return -E_BAD_ENV;
f0104606:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010460b:	e9 4e 02 00 00       	jmp    f010485e <syscall+0x548>
f0104610:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104615:	e9 44 02 00 00       	jmp    f010485e <syscall+0x548>
	}

	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || PGOFF(srcva) || PGOFF(dstva)) {
		return -E_INVAL;
f010461a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010461f:	e9 3a 02 00 00       	jmp    f010485e <syscall+0x548>
f0104624:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104629:	e9 30 02 00 00       	jmp    f010485e <syscall+0x548>
	}

	pte_t *pte;
	struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (!p) return -E_INVAL;
f010462e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104633:	e9 26 02 00 00       	jmp    f010485e <syscall+0x548>

	int valid_perm = (PTE_U|PTE_P);
	if ((perm&valid_perm) != valid_perm) return -E_INVAL;
f0104638:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010463d:	e9 1c 02 00 00       	jmp    f010485e <syscall+0x548>

	if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104642:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104647:	e9 12 02 00 00       	jmp    f010485e <syscall+0x548>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f010464c:	83 ec 04             	sub    $0x4,%esp
f010464f:	6a 01                	push   $0x1
f0104651:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104654:	50                   	push   %eax
f0104655:	ff 75 0c             	pushl  0xc(%ebp)
f0104658:	e8 03 e8 ff ff       	call   f0102e60 <envid2env>
f010465d:	89 c3                	mov    %eax,%ebx
f010465f:	83 c4 10             	add    $0x10,%esp
f0104662:	85 c0                	test   %eax,%eax
f0104664:	75 2b                	jne    f0104691 <syscall+0x37b>

	if (va >= (void *)UTOP || PGOFF(va)) return -E_INVAL;
f0104666:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010466d:	77 2c                	ja     f010469b <syscall+0x385>
f010466f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104676:	75 2d                	jne    f01046a5 <syscall+0x38f>

	page_remove(e->env_pgdir, va);
f0104678:	83 ec 08             	sub    $0x8,%esp
f010467b:	ff 75 10             	pushl  0x10(%ebp)
f010467e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104681:	ff 70 60             	pushl  0x60(%eax)
f0104684:	e8 f4 ca ff ff       	call   f010117d <page_remove>
f0104689:	83 c4 10             	add    $0x10,%esp
f010468c:	e9 cd 01 00 00       	jmp    f010485e <syscall+0x548>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f0104691:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104696:	e9 c3 01 00 00       	jmp    f010485e <syscall+0x548>

	if (va >= (void *)UTOP || PGOFF(va)) return -E_INVAL;
f010469b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046a0:	e9 b9 01 00 00       	jmp    f010485e <syscall+0x548>
f01046a5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
f01046aa:	e9 af 01 00 00       	jmp    f010485e <syscall+0x548>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f01046af:	83 ec 04             	sub    $0x4,%esp
f01046b2:	6a 01                	push   $0x1
f01046b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046b7:	50                   	push   %eax
f01046b8:	ff 75 0c             	pushl  0xc(%ebp)
f01046bb:	e8 a0 e7 ff ff       	call   f0102e60 <envid2env>
f01046c0:	89 c3                	mov    %eax,%ebx
f01046c2:	83 c4 10             	add    $0x10,%esp
f01046c5:	85 c0                	test   %eax,%eax
f01046c7:	75 0e                	jne    f01046d7 <syscall+0x3c1>

	e->env_pgfault_upcall = func;
f01046c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01046cf:	89 48 64             	mov    %ecx,0x64(%eax)
f01046d2:	e9 87 01 00 00       	jmp    f010485e <syscall+0x548>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1)) return -E_BAD_ENV;
f01046d7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
f01046dc:	e9 7d 01 00 00       	jmp    f010485e <syscall+0x548>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 0)) return -E_BAD_ENV;
f01046e1:	83 ec 04             	sub    $0x4,%esp
f01046e4:	6a 00                	push   $0x0
f01046e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01046e9:	50                   	push   %eax
f01046ea:	ff 75 0c             	pushl  0xc(%ebp)
f01046ed:	e8 6e e7 ff ff       	call   f0102e60 <envid2env>
f01046f2:	89 c3                	mov    %eax,%ebx
f01046f4:	83 c4 10             	add    $0x10,%esp
f01046f7:	85 c0                	test   %eax,%eax
f01046f9:	0f 85 f3 00 00 00    	jne    f01047f2 <syscall+0x4dc>

	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f01046ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104702:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104706:	0f 84 ed 00 00 00    	je     f01047f9 <syscall+0x4e3>

	if (srcva < (void *) UTOP) {
f010470c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104713:	0f 87 a5 00 00 00    	ja     f01047be <syscall+0x4a8>
		if(PGOFF(srcva)) return -E_INVAL;
f0104719:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104720:	75 6d                	jne    f010478f <syscall+0x479>

		pte_t *pte;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104722:	e8 df 12 00 00       	call   f0105a06 <cpunum>
f0104727:	83 ec 04             	sub    $0x4,%esp
f010472a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010472d:	52                   	push   %edx
f010472e:	ff 75 14             	pushl  0x14(%ebp)
f0104731:	6b c0 74             	imul   $0x74,%eax,%eax
f0104734:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010473a:	ff 70 60             	pushl  0x60(%eax)
f010473d:	e8 a0 c9 ff ff       	call   f01010e2 <page_lookup>
		if (!p) return -E_INVAL;
f0104742:	83 c4 10             	add    $0x10,%esp
f0104745:	85 c0                	test   %eax,%eax
f0104747:	74 50                	je     f0104799 <syscall+0x483>

		int valid_perm = (PTE_U|PTE_P);
		if ((perm & valid_perm) != valid_perm) {
f0104749:	8b 55 18             	mov    0x18(%ebp),%edx
f010474c:	83 e2 05             	and    $0x5,%edx
f010474f:	83 fa 05             	cmp    $0x5,%edx
f0104752:	75 4f                	jne    f01047a3 <syscall+0x48d>
			return -E_INVAL;
		}

		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104754:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104758:	74 08                	je     f0104762 <syscall+0x44c>
f010475a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010475d:	f6 02 02             	testb  $0x2,(%edx)
f0104760:	74 4b                	je     f01047ad <syscall+0x497>

		if (e->env_ipc_dstva < (void *)UTOP) {
f0104762:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104765:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104768:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010476e:	77 4e                	ja     f01047be <syscall+0x4a8>
			int ret = page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm);
f0104770:	ff 75 18             	pushl  0x18(%ebp)
f0104773:	51                   	push   %ecx
f0104774:	50                   	push   %eax
f0104775:	ff 72 60             	pushl  0x60(%edx)
f0104778:	e8 4b ca ff ff       	call   f01011c8 <page_insert>
			if (ret) return ret;
f010477d:	83 c4 10             	add    $0x10,%esp
f0104780:	85 c0                	test   %eax,%eax
f0104782:	75 33                	jne    f01047b7 <syscall+0x4a1>
			e->env_ipc_perm = perm;
f0104784:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104787:	8b 7d 18             	mov    0x18(%ebp),%edi
f010478a:	89 78 78             	mov    %edi,0x78(%eax)
f010478d:	eb 2f                	jmp    f01047be <syscall+0x4a8>
	if (envid2env(envid, &e, 0)) return -E_BAD_ENV;

	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;

	if (srcva < (void *) UTOP) {
		if(PGOFF(srcva)) return -E_INVAL;
f010478f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104794:	e9 c5 00 00 00       	jmp    f010485e <syscall+0x548>

		pte_t *pte;
		struct PageInfo *p = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!p) return -E_INVAL;
f0104799:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010479e:	e9 bb 00 00 00       	jmp    f010485e <syscall+0x548>

		int valid_perm = (PTE_U|PTE_P);
		if ((perm & valid_perm) != valid_perm) {
			return -E_INVAL;
f01047a3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047a8:	e9 b1 00 00 00       	jmp    f010485e <syscall+0x548>
		}

		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01047ad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047b2:	e9 a7 00 00 00       	jmp    f010485e <syscall+0x548>

		if (e->env_ipc_dstva < (void *)UTOP) {
			int ret = page_insert(e->env_pgdir, p, e->env_ipc_dstva, perm);
			if (ret) return ret;
f01047b7:	89 c3                	mov    %eax,%ebx
f01047b9:	e9 a0 00 00 00       	jmp    f010485e <syscall+0x548>
			e->env_ipc_perm = perm;
		}
	}

	e->env_ipc_recving = 0;
f01047be:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01047c1:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id;
f01047c5:	e8 3c 12 00 00       	call   f0105a06 <cpunum>
f01047ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01047cd:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01047d3:	8b 40 48             	mov    0x48(%eax),%eax
f01047d6:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;
f01047d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047dc:	8b 7d 10             	mov    0x10(%ebp),%edi
f01047df:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f01047e2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f01047e9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f01047f0:	eb 6c                	jmp    f010485e <syscall+0x548>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 0)) return -E_BAD_ENV;
f01047f2:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01047f7:	eb 65                	jmp    f010485e <syscall+0x548>

	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f01047f9:	bb f8 ff ff ff       	mov    $0xfffffff8,%ebx
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f01047fe:	eb 5e                	jmp    f010485e <syscall+0x548>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");
	if ((dstva < (void *)UTOP) && PGOFF(dstva))
f0104800:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104807:	77 09                	ja     f0104812 <syscall+0x4fc>
f0104809:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104810:	75 47                	jne    f0104859 <syscall+0x543>
		return -E_INVAL;

	curenv->env_ipc_recving = 1;
f0104812:	e8 ef 11 00 00       	call   f0105a06 <cpunum>
f0104817:	6b c0 74             	imul   $0x74,%eax,%eax
f010481a:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104820:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104824:	e8 dd 11 00 00       	call   f0105a06 <cpunum>
f0104829:	6b c0 74             	imul   $0x74,%eax,%eax
f010482c:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104832:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104839:	e8 c8 11 00 00       	call   f0105a06 <cpunum>
f010483e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104841:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104847:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010484a:	89 78 6c             	mov    %edi,0x6c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010484d:	e8 3b fa ff ff       	call   f010428d <sched_yield>
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	default:
		return -E_INVAL;
f0104852:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104857:	eb 05                	jmp    f010485e <syscall+0x548>
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
f0104859:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	default:
		return -E_INVAL;
	}
}
f010485e:	89 d8                	mov    %ebx,%eax
f0104860:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104863:	5b                   	pop    %ebx
f0104864:	5e                   	pop    %esi
f0104865:	5f                   	pop    %edi
f0104866:	5d                   	pop    %ebp
f0104867:	c3                   	ret    

f0104868 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104868:	55                   	push   %ebp
f0104869:	89 e5                	mov    %esp,%ebp
f010486b:	57                   	push   %edi
f010486c:	56                   	push   %esi
f010486d:	53                   	push   %ebx
f010486e:	83 ec 14             	sub    $0x14,%esp
f0104871:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104874:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104877:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010487a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010487d:	8b 1a                	mov    (%edx),%ebx
f010487f:	8b 01                	mov    (%ecx),%eax
f0104881:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104884:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010488b:	eb 7f                	jmp    f010490c <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010488d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104890:	01 d8                	add    %ebx,%eax
f0104892:	89 c6                	mov    %eax,%esi
f0104894:	c1 ee 1f             	shr    $0x1f,%esi
f0104897:	01 c6                	add    %eax,%esi
f0104899:	d1 fe                	sar    %esi
f010489b:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010489e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01048a1:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01048a4:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01048a6:	eb 03                	jmp    f01048ab <stab_binsearch+0x43>
			m--;
f01048a8:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01048ab:	39 c3                	cmp    %eax,%ebx
f01048ad:	7f 0d                	jg     f01048bc <stab_binsearch+0x54>
f01048af:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01048b3:	83 ea 0c             	sub    $0xc,%edx
f01048b6:	39 f9                	cmp    %edi,%ecx
f01048b8:	75 ee                	jne    f01048a8 <stab_binsearch+0x40>
f01048ba:	eb 05                	jmp    f01048c1 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01048bc:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01048bf:	eb 4b                	jmp    f010490c <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01048c1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01048c4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01048c7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01048cb:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01048ce:	76 11                	jbe    f01048e1 <stab_binsearch+0x79>
			*region_left = m;
f01048d0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01048d3:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01048d5:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01048d8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01048df:	eb 2b                	jmp    f010490c <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01048e1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01048e4:	73 14                	jae    f01048fa <stab_binsearch+0x92>
			*region_right = m - 1;
f01048e6:	83 e8 01             	sub    $0x1,%eax
f01048e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01048ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048ef:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01048f1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01048f8:	eb 12                	jmp    f010490c <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01048fa:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048fd:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01048ff:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104903:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104905:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010490c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010490f:	0f 8e 78 ff ff ff    	jle    f010488d <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104915:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104919:	75 0f                	jne    f010492a <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010491b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010491e:	8b 00                	mov    (%eax),%eax
f0104920:	83 e8 01             	sub    $0x1,%eax
f0104923:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104926:	89 06                	mov    %eax,(%esi)
f0104928:	eb 2c                	jmp    f0104956 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010492a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010492d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010492f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104932:	8b 0e                	mov    (%esi),%ecx
f0104934:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104937:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010493a:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010493d:	eb 03                	jmp    f0104942 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010493f:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104942:	39 c8                	cmp    %ecx,%eax
f0104944:	7e 0b                	jle    f0104951 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104946:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010494a:	83 ea 0c             	sub    $0xc,%edx
f010494d:	39 df                	cmp    %ebx,%edi
f010494f:	75 ee                	jne    f010493f <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104951:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104954:	89 06                	mov    %eax,(%esi)
	}
}
f0104956:	83 c4 14             	add    $0x14,%esp
f0104959:	5b                   	pop    %ebx
f010495a:	5e                   	pop    %esi
f010495b:	5f                   	pop    %edi
f010495c:	5d                   	pop    %ebp
f010495d:	c3                   	ret    

f010495e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010495e:	55                   	push   %ebp
f010495f:	89 e5                	mov    %esp,%ebp
f0104961:	57                   	push   %edi
f0104962:	56                   	push   %esi
f0104963:	53                   	push   %ebx
f0104964:	83 ec 3c             	sub    $0x3c,%esp
f0104967:	8b 7d 08             	mov    0x8(%ebp),%edi
f010496a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file="<unknown>";
f010496d:	c7 03 94 78 10 f0    	movl   $0xf0107894,(%ebx)
	info->eip_line = 0;
f0104973:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010497a:	c7 43 08 94 78 10 f0 	movl   $0xf0107894,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104981:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104988:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010498b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104992:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104998:	0f 87 a3 00 00 00    	ja     f0104a41 <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010499e:	e8 63 10 00 00       	call   f0105a06 <cpunum>
f01049a3:	6a 04                	push   $0x4
f01049a5:	6a 10                	push   $0x10
f01049a7:	68 00 00 20 00       	push   $0x200000
f01049ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01049af:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01049b5:	e8 73 e3 ff ff       	call   f0102d2d <user_mem_check>
f01049ba:	83 c4 10             	add    $0x10,%esp
f01049bd:	85 c0                	test   %eax,%eax
f01049bf:	0f 85 54 02 00 00    	jne    f0104c19 <debuginfo_eip+0x2bb>
			return -1;

		stabs = usd->stabs;
f01049c5:	a1 00 00 20 00       	mov    0x200000,%eax
f01049ca:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f01049cd:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01049d3:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01049d9:	89 55 bc             	mov    %edx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01049dc:	a1 0c 00 20 00       	mov    0x20000c,%eax
f01049e1:	89 45 b8             	mov    %eax,-0x48(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
f01049e4:	e8 1d 10 00 00       	call   f0105a06 <cpunum>
f01049e9:	6a 04                	push   $0x4
f01049eb:	89 f2                	mov    %esi,%edx
f01049ed:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01049f0:	29 ca                	sub    %ecx,%edx
f01049f2:	c1 fa 02             	sar    $0x2,%edx
f01049f5:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01049fb:	52                   	push   %edx
f01049fc:	51                   	push   %ecx
f01049fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a00:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104a06:	e8 22 e3 ff ff       	call   f0102d2d <user_mem_check>
f0104a0b:	83 c4 10             	add    $0x10,%esp
f0104a0e:	85 c0                	test   %eax,%eax
f0104a10:	0f 85 0a 02 00 00    	jne    f0104c20 <debuginfo_eip+0x2c2>
			return -1;
		
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f0104a16:	e8 eb 0f 00 00       	call   f0105a06 <cpunum>
f0104a1b:	6a 04                	push   $0x4
f0104a1d:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104a20:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104a23:	29 ca                	sub    %ecx,%edx
f0104a25:	52                   	push   %edx
f0104a26:	51                   	push   %ecx
f0104a27:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a2a:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104a30:	e8 f8 e2 ff ff       	call   f0102d2d <user_mem_check>
f0104a35:	83 c4 10             	add    $0x10,%esp
f0104a38:	85 c0                	test   %eax,%eax
f0104a3a:	74 1f                	je     f0104a5b <debuginfo_eip+0xfd>
f0104a3c:	e9 e6 01 00 00       	jmp    f0104c27 <debuginfo_eip+0x2c9>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104a41:	c7 45 b8 6d 54 11 f0 	movl   $0xf011546d,-0x48(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104a48:	c7 45 bc bd 1d 11 f0 	movl   $0xf0111dbd,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104a4f:	be bc 1d 11 f0       	mov    $0xf0111dbc,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104a54:	c7 45 c0 78 7d 10 f0 	movl   $0xf0107d78,-0x40(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104a5b:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104a5e:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0104a61:	0f 83 c7 01 00 00    	jae    f0104c2e <debuginfo_eip+0x2d0>
f0104a67:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104a6b:	0f 85 c4 01 00 00    	jne    f0104c35 <debuginfo_eip+0x2d7>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104a71:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104a78:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104a7b:	c1 fe 02             	sar    $0x2,%esi
f0104a7e:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104a84:	83 e8 01             	sub    $0x1,%eax
f0104a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104a8a:	83 ec 08             	sub    $0x8,%esp
f0104a8d:	57                   	push   %edi
f0104a8e:	6a 64                	push   $0x64
f0104a90:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104a93:	89 d1                	mov    %edx,%ecx
f0104a95:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a98:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104a9b:	89 f0                	mov    %esi,%eax
f0104a9d:	e8 c6 fd ff ff       	call   f0104868 <stab_binsearch>
	if (lfile == 0)
f0104aa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104aa5:	83 c4 10             	add    $0x10,%esp
f0104aa8:	85 c0                	test   %eax,%eax
f0104aaa:	0f 84 8c 01 00 00    	je     f0104c3c <debuginfo_eip+0x2de>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104ab0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ab6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104ab9:	83 ec 08             	sub    $0x8,%esp
f0104abc:	57                   	push   %edi
f0104abd:	6a 24                	push   $0x24
f0104abf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104ac2:	89 d1                	mov    %edx,%ecx
f0104ac4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104ac7:	89 f0                	mov    %esi,%eax
f0104ac9:	e8 9a fd ff ff       	call   f0104868 <stab_binsearch>

	if (lfun <= rfun) {
f0104ace:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ad1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104ad4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104ad7:	83 c4 10             	add    $0x10,%esp
f0104ada:	39 d0                	cmp    %edx,%eax
f0104adc:	7f 2b                	jg     f0104b09 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104ade:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ae1:	8d 0c 96             	lea    (%esi,%edx,4),%ecx
f0104ae4:	8b 11                	mov    (%ecx),%edx
f0104ae6:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104ae9:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0104aec:	39 f2                	cmp    %esi,%edx
f0104aee:	73 06                	jae    f0104af6 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104af0:	03 55 bc             	add    -0x44(%ebp),%edx
f0104af3:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104af6:	8b 51 08             	mov    0x8(%ecx),%edx
f0104af9:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104afc:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104afe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104b01:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104b04:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104b07:	eb 0f                	jmp    f0104b18 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104b09:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104b0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b15:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104b18:	83 ec 08             	sub    $0x8,%esp
f0104b1b:	6a 3a                	push   $0x3a
f0104b1d:	ff 73 08             	pushl  0x8(%ebx)
f0104b20:	e8 a5 08 00 00       	call   f01053ca <strfind>
f0104b25:	2b 43 08             	sub    0x8(%ebx),%eax
f0104b28:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
f0104b2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b2e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104b31:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104b34:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104b37:	03 0c 86             	add    (%esi,%eax,4),%ecx
f0104b3a:	89 0b                	mov    %ecx,(%ebx)
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0104b3c:	83 c4 08             	add    $0x8,%esp
f0104b3f:	57                   	push   %edi
f0104b40:	6a 44                	push   $0x44
f0104b42:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104b45:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104b48:	89 f0                	mov    %esi,%eax
f0104b4a:	e8 19 fd ff ff       	call   f0104868 <stab_binsearch>
	if(lline>rline){
f0104b4f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104b52:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104b55:	83 c4 10             	add    $0x10,%esp
f0104b58:	39 c2                	cmp    %eax,%edx
f0104b5a:	0f 8f e3 00 00 00    	jg     f0104c43 <debuginfo_eip+0x2e5>
	return -1;
	}
	else{
	info->eip_line=stabs[rline].n_desc;
f0104b60:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104b63:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104b68:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104b6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b6e:	89 d0                	mov    %edx,%eax
f0104b70:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104b73:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104b76:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104b7a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104b7d:	eb 0a                	jmp    f0104b89 <debuginfo_eip+0x22b>
f0104b7f:	83 e8 01             	sub    $0x1,%eax
f0104b82:	83 ea 0c             	sub    $0xc,%edx
f0104b85:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104b89:	39 c7                	cmp    %eax,%edi
f0104b8b:	7e 05                	jle    f0104b92 <debuginfo_eip+0x234>
f0104b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b90:	eb 47                	jmp    f0104bd9 <debuginfo_eip+0x27b>
	       && stabs[lline].n_type != N_SOL
f0104b92:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104b96:	80 f9 84             	cmp    $0x84,%cl
f0104b99:	75 0e                	jne    f0104ba9 <debuginfo_eip+0x24b>
f0104b9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b9e:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ba2:	74 1c                	je     f0104bc0 <debuginfo_eip+0x262>
f0104ba4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ba7:	eb 17                	jmp    f0104bc0 <debuginfo_eip+0x262>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ba9:	80 f9 64             	cmp    $0x64,%cl
f0104bac:	75 d1                	jne    f0104b7f <debuginfo_eip+0x221>
f0104bae:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104bb2:	74 cb                	je     f0104b7f <debuginfo_eip+0x221>
f0104bb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bb7:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104bbb:	74 03                	je     f0104bc0 <debuginfo_eip+0x262>
f0104bbd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104bc0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104bc3:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104bc6:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104bc9:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104bcc:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104bcf:	29 f8                	sub    %edi,%eax
f0104bd1:	39 c2                	cmp    %eax,%edx
f0104bd3:	73 04                	jae    f0104bd9 <debuginfo_eip+0x27b>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104bd5:	01 fa                	add    %edi,%edx
f0104bd7:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104bd9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104bdc:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104bdf:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104be4:	39 f2                	cmp    %esi,%edx
f0104be6:	7d 67                	jge    f0104c4f <debuginfo_eip+0x2f1>
		for (lline = lfun + 1;
f0104be8:	83 c2 01             	add    $0x1,%edx
f0104beb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104bee:	89 d0                	mov    %edx,%eax
f0104bf0:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104bf3:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104bf6:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104bf9:	eb 04                	jmp    f0104bff <debuginfo_eip+0x2a1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104bfb:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104bff:	39 c6                	cmp    %eax,%esi
f0104c01:	7e 47                	jle    f0104c4a <debuginfo_eip+0x2ec>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104c03:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c07:	83 c0 01             	add    $0x1,%eax
f0104c0a:	83 c2 0c             	add    $0xc,%edx
f0104c0d:	80 f9 a0             	cmp    $0xa0,%cl
f0104c10:	74 e9                	je     f0104bfb <debuginfo_eip+0x29d>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104c12:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c17:	eb 36                	jmp    f0104c4f <debuginfo_eip+0x2f1>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104c19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c1e:	eb 2f                	jmp    f0104c4f <debuginfo_eip+0x2f1>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
			return -1;
f0104c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c25:	eb 28                	jmp    f0104c4f <debuginfo_eip+0x2f1>
		
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f0104c27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c2c:	eb 21                	jmp    f0104c4f <debuginfo_eip+0x2f1>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104c2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c33:	eb 1a                	jmp    f0104c4f <debuginfo_eip+0x2f1>
f0104c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c3a:	eb 13                	jmp    f0104c4f <debuginfo_eip+0x2f1>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c41:	eb 0c                	jmp    f0104c4f <debuginfo_eip+0x2f1>
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
	if(lline>rline){
	return -1;
f0104c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104c48:	eb 05                	jmp    f0104c4f <debuginfo_eip+0x2f1>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104c4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c52:	5b                   	pop    %ebx
f0104c53:	5e                   	pop    %esi
f0104c54:	5f                   	pop    %edi
f0104c55:	5d                   	pop    %ebp
f0104c56:	c3                   	ret    

f0104c57 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104c57:	55                   	push   %ebp
f0104c58:	89 e5                	mov    %esp,%ebp
f0104c5a:	57                   	push   %edi
f0104c5b:	56                   	push   %esi
f0104c5c:	53                   	push   %ebx
f0104c5d:	83 ec 1c             	sub    $0x1c,%esp
f0104c60:	89 c7                	mov    %eax,%edi
f0104c62:	89 d6                	mov    %edx,%esi
f0104c64:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c67:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c6d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104c70:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104c73:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c78:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c7b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104c7e:	39 d3                	cmp    %edx,%ebx
f0104c80:	72 05                	jb     f0104c87 <printnum+0x30>
f0104c82:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104c85:	77 45                	ja     f0104ccc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104c87:	83 ec 0c             	sub    $0xc,%esp
f0104c8a:	ff 75 18             	pushl  0x18(%ebp)
f0104c8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c90:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104c93:	53                   	push   %ebx
f0104c94:	ff 75 10             	pushl  0x10(%ebp)
f0104c97:	83 ec 08             	sub    $0x8,%esp
f0104c9a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c9d:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ca0:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ca3:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ca6:	e8 55 11 00 00       	call   f0105e00 <__udivdi3>
f0104cab:	83 c4 18             	add    $0x18,%esp
f0104cae:	52                   	push   %edx
f0104caf:	50                   	push   %eax
f0104cb0:	89 f2                	mov    %esi,%edx
f0104cb2:	89 f8                	mov    %edi,%eax
f0104cb4:	e8 9e ff ff ff       	call   f0104c57 <printnum>
f0104cb9:	83 c4 20             	add    $0x20,%esp
f0104cbc:	eb 18                	jmp    f0104cd6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104cbe:	83 ec 08             	sub    $0x8,%esp
f0104cc1:	56                   	push   %esi
f0104cc2:	ff 75 18             	pushl  0x18(%ebp)
f0104cc5:	ff d7                	call   *%edi
f0104cc7:	83 c4 10             	add    $0x10,%esp
f0104cca:	eb 03                	jmp    f0104ccf <printnum+0x78>
f0104ccc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ccf:	83 eb 01             	sub    $0x1,%ebx
f0104cd2:	85 db                	test   %ebx,%ebx
f0104cd4:	7f e8                	jg     f0104cbe <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104cd6:	83 ec 08             	sub    $0x8,%esp
f0104cd9:	56                   	push   %esi
f0104cda:	83 ec 04             	sub    $0x4,%esp
f0104cdd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ce0:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ce3:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ce6:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ce9:	e8 42 12 00 00       	call   f0105f30 <__umoddi3>
f0104cee:	83 c4 14             	add    $0x14,%esp
f0104cf1:	0f be 80 9e 78 10 f0 	movsbl -0xfef8762(%eax),%eax
f0104cf8:	50                   	push   %eax
f0104cf9:	ff d7                	call   *%edi
}
f0104cfb:	83 c4 10             	add    $0x10,%esp
f0104cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d01:	5b                   	pop    %ebx
f0104d02:	5e                   	pop    %esi
f0104d03:	5f                   	pop    %edi
f0104d04:	5d                   	pop    %ebp
f0104d05:	c3                   	ret    

f0104d06 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104d06:	55                   	push   %ebp
f0104d07:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104d09:	83 fa 01             	cmp    $0x1,%edx
f0104d0c:	7e 0e                	jle    f0104d1c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104d0e:	8b 10                	mov    (%eax),%edx
f0104d10:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104d13:	89 08                	mov    %ecx,(%eax)
f0104d15:	8b 02                	mov    (%edx),%eax
f0104d17:	8b 52 04             	mov    0x4(%edx),%edx
f0104d1a:	eb 22                	jmp    f0104d3e <getuint+0x38>
	else if (lflag)
f0104d1c:	85 d2                	test   %edx,%edx
f0104d1e:	74 10                	je     f0104d30 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104d20:	8b 10                	mov    (%eax),%edx
f0104d22:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104d25:	89 08                	mov    %ecx,(%eax)
f0104d27:	8b 02                	mov    (%edx),%eax
f0104d29:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d2e:	eb 0e                	jmp    f0104d3e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104d30:	8b 10                	mov    (%eax),%edx
f0104d32:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104d35:	89 08                	mov    %ecx,(%eax)
f0104d37:	8b 02                	mov    (%edx),%eax
f0104d39:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104d3e:	5d                   	pop    %ebp
f0104d3f:	c3                   	ret    

f0104d40 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104d40:	55                   	push   %ebp
f0104d41:	89 e5                	mov    %esp,%ebp
f0104d43:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104d46:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104d4a:	8b 10                	mov    (%eax),%edx
f0104d4c:	3b 50 04             	cmp    0x4(%eax),%edx
f0104d4f:	73 0a                	jae    f0104d5b <sprintputch+0x1b>
		*b->buf++ = ch;
f0104d51:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104d54:	89 08                	mov    %ecx,(%eax)
f0104d56:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d59:	88 02                	mov    %al,(%edx)
}
f0104d5b:	5d                   	pop    %ebp
f0104d5c:	c3                   	ret    

f0104d5d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104d5d:	55                   	push   %ebp
f0104d5e:	89 e5                	mov    %esp,%ebp
f0104d60:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104d63:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104d66:	50                   	push   %eax
f0104d67:	ff 75 10             	pushl  0x10(%ebp)
f0104d6a:	ff 75 0c             	pushl  0xc(%ebp)
f0104d6d:	ff 75 08             	pushl  0x8(%ebp)
f0104d70:	e8 05 00 00 00       	call   f0104d7a <vprintfmt>
	va_end(ap);
}
f0104d75:	83 c4 10             	add    $0x10,%esp
f0104d78:	c9                   	leave  
f0104d79:	c3                   	ret    

f0104d7a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104d7a:	55                   	push   %ebp
f0104d7b:	89 e5                	mov    %esp,%ebp
f0104d7d:	57                   	push   %edi
f0104d7e:	56                   	push   %esi
f0104d7f:	53                   	push   %ebx
f0104d80:	83 ec 2c             	sub    $0x2c,%esp
f0104d83:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d89:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d8c:	eb 12                	jmp    f0104da0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104d8e:	85 c0                	test   %eax,%eax
f0104d90:	0f 84 89 03 00 00    	je     f010511f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104d96:	83 ec 08             	sub    $0x8,%esp
f0104d99:	53                   	push   %ebx
f0104d9a:	50                   	push   %eax
f0104d9b:	ff d6                	call   *%esi
f0104d9d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104da0:	83 c7 01             	add    $0x1,%edi
f0104da3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104da7:	83 f8 25             	cmp    $0x25,%eax
f0104daa:	75 e2                	jne    f0104d8e <vprintfmt+0x14>
f0104dac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104db0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104db7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104dbe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104dc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dca:	eb 07                	jmp    f0104dd3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dcc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104dcf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dd3:	8d 47 01             	lea    0x1(%edi),%eax
f0104dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104dd9:	0f b6 07             	movzbl (%edi),%eax
f0104ddc:	0f b6 c8             	movzbl %al,%ecx
f0104ddf:	83 e8 23             	sub    $0x23,%eax
f0104de2:	3c 55                	cmp    $0x55,%al
f0104de4:	0f 87 1a 03 00 00    	ja     f0105104 <vprintfmt+0x38a>
f0104dea:	0f b6 c0             	movzbl %al,%eax
f0104ded:	ff 24 85 60 79 10 f0 	jmp    *-0xfef86a0(,%eax,4)
f0104df4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104df7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104dfb:	eb d6                	jmp    f0104dd3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e00:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e05:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104e08:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104e0b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104e0f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104e12:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104e15:	83 fa 09             	cmp    $0x9,%edx
f0104e18:	77 39                	ja     f0104e53 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104e1a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104e1d:	eb e9                	jmp    f0104e08 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104e1f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e22:	8d 48 04             	lea    0x4(%eax),%ecx
f0104e25:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104e28:	8b 00                	mov    (%eax),%eax
f0104e2a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104e30:	eb 27                	jmp    f0104e59 <vprintfmt+0xdf>
f0104e32:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e35:	85 c0                	test   %eax,%eax
f0104e37:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e3c:	0f 49 c8             	cmovns %eax,%ecx
f0104e3f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e45:	eb 8c                	jmp    f0104dd3 <vprintfmt+0x59>
f0104e47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104e4a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104e51:	eb 80                	jmp    f0104dd3 <vprintfmt+0x59>
f0104e53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e56:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104e59:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104e5d:	0f 89 70 ff ff ff    	jns    f0104dd3 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104e63:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e66:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104e69:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104e70:	e9 5e ff ff ff       	jmp    f0104dd3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104e75:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104e7b:	e9 53 ff ff ff       	jmp    f0104dd3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104e80:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e83:	8d 50 04             	lea    0x4(%eax),%edx
f0104e86:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e89:	83 ec 08             	sub    $0x8,%esp
f0104e8c:	53                   	push   %ebx
f0104e8d:	ff 30                	pushl  (%eax)
f0104e8f:	ff d6                	call   *%esi
			break;
f0104e91:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104e97:	e9 04 ff ff ff       	jmp    f0104da0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104e9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e9f:	8d 50 04             	lea    0x4(%eax),%edx
f0104ea2:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ea5:	8b 00                	mov    (%eax),%eax
f0104ea7:	99                   	cltd   
f0104ea8:	31 d0                	xor    %edx,%eax
f0104eaa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104eac:	83 f8 09             	cmp    $0x9,%eax
f0104eaf:	7f 0b                	jg     f0104ebc <vprintfmt+0x142>
f0104eb1:	8b 14 85 c0 7a 10 f0 	mov    -0xfef8540(,%eax,4),%edx
f0104eb8:	85 d2                	test   %edx,%edx
f0104eba:	75 18                	jne    f0104ed4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104ebc:	50                   	push   %eax
f0104ebd:	68 b6 78 10 f0       	push   $0xf01078b6
f0104ec2:	53                   	push   %ebx
f0104ec3:	56                   	push   %esi
f0104ec4:	e8 94 fe ff ff       	call   f0104d5d <printfmt>
f0104ec9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ecc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104ecf:	e9 cc fe ff ff       	jmp    f0104da0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104ed4:	52                   	push   %edx
f0104ed5:	68 55 66 10 f0       	push   $0xf0106655
f0104eda:	53                   	push   %ebx
f0104edb:	56                   	push   %esi
f0104edc:	e8 7c fe ff ff       	call   f0104d5d <printfmt>
f0104ee1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ee4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ee7:	e9 b4 fe ff ff       	jmp    f0104da0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104eec:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eef:	8d 50 04             	lea    0x4(%eax),%edx
f0104ef2:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ef5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104ef7:	85 ff                	test   %edi,%edi
f0104ef9:	b8 af 78 10 f0       	mov    $0xf01078af,%eax
f0104efe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104f01:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f05:	0f 8e 94 00 00 00    	jle    f0104f9f <vprintfmt+0x225>
f0104f0b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104f0f:	0f 84 98 00 00 00    	je     f0104fad <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104f15:	83 ec 08             	sub    $0x8,%esp
f0104f18:	ff 75 d0             	pushl  -0x30(%ebp)
f0104f1b:	57                   	push   %edi
f0104f1c:	e8 5f 03 00 00       	call   f0105280 <strnlen>
f0104f21:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104f24:	29 c1                	sub    %eax,%ecx
f0104f26:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104f29:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104f2c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104f30:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f33:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104f36:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104f38:	eb 0f                	jmp    f0104f49 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104f3a:	83 ec 08             	sub    $0x8,%esp
f0104f3d:	53                   	push   %ebx
f0104f3e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f41:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104f43:	83 ef 01             	sub    $0x1,%edi
f0104f46:	83 c4 10             	add    $0x10,%esp
f0104f49:	85 ff                	test   %edi,%edi
f0104f4b:	7f ed                	jg     f0104f3a <vprintfmt+0x1c0>
f0104f4d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104f50:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104f53:	85 c9                	test   %ecx,%ecx
f0104f55:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f5a:	0f 49 c1             	cmovns %ecx,%eax
f0104f5d:	29 c1                	sub    %eax,%ecx
f0104f5f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104f62:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f65:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f68:	89 cb                	mov    %ecx,%ebx
f0104f6a:	eb 4d                	jmp    f0104fb9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104f6c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104f70:	74 1b                	je     f0104f8d <vprintfmt+0x213>
f0104f72:	0f be c0             	movsbl %al,%eax
f0104f75:	83 e8 20             	sub    $0x20,%eax
f0104f78:	83 f8 5e             	cmp    $0x5e,%eax
f0104f7b:	76 10                	jbe    f0104f8d <vprintfmt+0x213>
					putch('?', putdat);
f0104f7d:	83 ec 08             	sub    $0x8,%esp
f0104f80:	ff 75 0c             	pushl  0xc(%ebp)
f0104f83:	6a 3f                	push   $0x3f
f0104f85:	ff 55 08             	call   *0x8(%ebp)
f0104f88:	83 c4 10             	add    $0x10,%esp
f0104f8b:	eb 0d                	jmp    f0104f9a <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104f8d:	83 ec 08             	sub    $0x8,%esp
f0104f90:	ff 75 0c             	pushl  0xc(%ebp)
f0104f93:	52                   	push   %edx
f0104f94:	ff 55 08             	call   *0x8(%ebp)
f0104f97:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104f9a:	83 eb 01             	sub    $0x1,%ebx
f0104f9d:	eb 1a                	jmp    f0104fb9 <vprintfmt+0x23f>
f0104f9f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104fa2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104fa5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104fa8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104fab:	eb 0c                	jmp    f0104fb9 <vprintfmt+0x23f>
f0104fad:	89 75 08             	mov    %esi,0x8(%ebp)
f0104fb0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104fb3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104fb6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104fb9:	83 c7 01             	add    $0x1,%edi
f0104fbc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104fc0:	0f be d0             	movsbl %al,%edx
f0104fc3:	85 d2                	test   %edx,%edx
f0104fc5:	74 23                	je     f0104fea <vprintfmt+0x270>
f0104fc7:	85 f6                	test   %esi,%esi
f0104fc9:	78 a1                	js     f0104f6c <vprintfmt+0x1f2>
f0104fcb:	83 ee 01             	sub    $0x1,%esi
f0104fce:	79 9c                	jns    f0104f6c <vprintfmt+0x1f2>
f0104fd0:	89 df                	mov    %ebx,%edi
f0104fd2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fd5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104fd8:	eb 18                	jmp    f0104ff2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104fda:	83 ec 08             	sub    $0x8,%esp
f0104fdd:	53                   	push   %ebx
f0104fde:	6a 20                	push   $0x20
f0104fe0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104fe2:	83 ef 01             	sub    $0x1,%edi
f0104fe5:	83 c4 10             	add    $0x10,%esp
f0104fe8:	eb 08                	jmp    f0104ff2 <vprintfmt+0x278>
f0104fea:	89 df                	mov    %ebx,%edi
f0104fec:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ff2:	85 ff                	test   %edi,%edi
f0104ff4:	7f e4                	jg     f0104fda <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ff6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ff9:	e9 a2 fd ff ff       	jmp    f0104da0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104ffe:	83 fa 01             	cmp    $0x1,%edx
f0105001:	7e 16                	jle    f0105019 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105003:	8b 45 14             	mov    0x14(%ebp),%eax
f0105006:	8d 50 08             	lea    0x8(%eax),%edx
f0105009:	89 55 14             	mov    %edx,0x14(%ebp)
f010500c:	8b 50 04             	mov    0x4(%eax),%edx
f010500f:	8b 00                	mov    (%eax),%eax
f0105011:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105014:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105017:	eb 32                	jmp    f010504b <vprintfmt+0x2d1>
	else if (lflag)
f0105019:	85 d2                	test   %edx,%edx
f010501b:	74 18                	je     f0105035 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010501d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105020:	8d 50 04             	lea    0x4(%eax),%edx
f0105023:	89 55 14             	mov    %edx,0x14(%ebp)
f0105026:	8b 00                	mov    (%eax),%eax
f0105028:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010502b:	89 c1                	mov    %eax,%ecx
f010502d:	c1 f9 1f             	sar    $0x1f,%ecx
f0105030:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105033:	eb 16                	jmp    f010504b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105035:	8b 45 14             	mov    0x14(%ebp),%eax
f0105038:	8d 50 04             	lea    0x4(%eax),%edx
f010503b:	89 55 14             	mov    %edx,0x14(%ebp)
f010503e:	8b 00                	mov    (%eax),%eax
f0105040:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105043:	89 c1                	mov    %eax,%ecx
f0105045:	c1 f9 1f             	sar    $0x1f,%ecx
f0105048:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010504b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010504e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105051:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105056:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010505a:	79 74                	jns    f01050d0 <vprintfmt+0x356>
				putch('-', putdat);
f010505c:	83 ec 08             	sub    $0x8,%esp
f010505f:	53                   	push   %ebx
f0105060:	6a 2d                	push   $0x2d
f0105062:	ff d6                	call   *%esi
				num = -(long long) num;
f0105064:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105067:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010506a:	f7 d8                	neg    %eax
f010506c:	83 d2 00             	adc    $0x0,%edx
f010506f:	f7 da                	neg    %edx
f0105071:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105074:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105079:	eb 55                	jmp    f01050d0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010507b:	8d 45 14             	lea    0x14(%ebp),%eax
f010507e:	e8 83 fc ff ff       	call   f0104d06 <getuint>
			base = 10;
f0105083:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105088:	eb 46                	jmp    f01050d0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010508a:	8d 45 14             	lea    0x14(%ebp),%eax
f010508d:	e8 74 fc ff ff       	call   f0104d06 <getuint>
			base = 8;
f0105092:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105097:	eb 37                	jmp    f01050d0 <vprintfmt+0x356>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105099:	83 ec 08             	sub    $0x8,%esp
f010509c:	53                   	push   %ebx
f010509d:	6a 30                	push   $0x30
f010509f:	ff d6                	call   *%esi
			putch('x', putdat);
f01050a1:	83 c4 08             	add    $0x8,%esp
f01050a4:	53                   	push   %ebx
f01050a5:	6a 78                	push   $0x78
f01050a7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01050a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01050ac:	8d 50 04             	lea    0x4(%eax),%edx
f01050af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01050b2:	8b 00                	mov    (%eax),%eax
f01050b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01050b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01050bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01050c1:	eb 0d                	jmp    f01050d0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01050c3:	8d 45 14             	lea    0x14(%ebp),%eax
f01050c6:	e8 3b fc ff ff       	call   f0104d06 <getuint>
			base = 16;
f01050cb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01050d0:	83 ec 0c             	sub    $0xc,%esp
f01050d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01050d7:	57                   	push   %edi
f01050d8:	ff 75 e0             	pushl  -0x20(%ebp)
f01050db:	51                   	push   %ecx
f01050dc:	52                   	push   %edx
f01050dd:	50                   	push   %eax
f01050de:	89 da                	mov    %ebx,%edx
f01050e0:	89 f0                	mov    %esi,%eax
f01050e2:	e8 70 fb ff ff       	call   f0104c57 <printnum>
			break;
f01050e7:	83 c4 20             	add    $0x20,%esp
f01050ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050ed:	e9 ae fc ff ff       	jmp    f0104da0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01050f2:	83 ec 08             	sub    $0x8,%esp
f01050f5:	53                   	push   %ebx
f01050f6:	51                   	push   %ecx
f01050f7:	ff d6                	call   *%esi
			break;
f01050f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01050ff:	e9 9c fc ff ff       	jmp    f0104da0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105104:	83 ec 08             	sub    $0x8,%esp
f0105107:	53                   	push   %ebx
f0105108:	6a 25                	push   $0x25
f010510a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010510c:	83 c4 10             	add    $0x10,%esp
f010510f:	eb 03                	jmp    f0105114 <vprintfmt+0x39a>
f0105111:	83 ef 01             	sub    $0x1,%edi
f0105114:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105118:	75 f7                	jne    f0105111 <vprintfmt+0x397>
f010511a:	e9 81 fc ff ff       	jmp    f0104da0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010511f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105122:	5b                   	pop    %ebx
f0105123:	5e                   	pop    %esi
f0105124:	5f                   	pop    %edi
f0105125:	5d                   	pop    %ebp
f0105126:	c3                   	ret    

f0105127 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105127:	55                   	push   %ebp
f0105128:	89 e5                	mov    %esp,%ebp
f010512a:	83 ec 18             	sub    $0x18,%esp
f010512d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105130:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105133:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105136:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010513a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010513d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105144:	85 c0                	test   %eax,%eax
f0105146:	74 26                	je     f010516e <vsnprintf+0x47>
f0105148:	85 d2                	test   %edx,%edx
f010514a:	7e 22                	jle    f010516e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010514c:	ff 75 14             	pushl  0x14(%ebp)
f010514f:	ff 75 10             	pushl  0x10(%ebp)
f0105152:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105155:	50                   	push   %eax
f0105156:	68 40 4d 10 f0       	push   $0xf0104d40
f010515b:	e8 1a fc ff ff       	call   f0104d7a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105160:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105163:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105166:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105169:	83 c4 10             	add    $0x10,%esp
f010516c:	eb 05                	jmp    f0105173 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010516e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105173:	c9                   	leave  
f0105174:	c3                   	ret    

f0105175 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105175:	55                   	push   %ebp
f0105176:	89 e5                	mov    %esp,%ebp
f0105178:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010517b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010517e:	50                   	push   %eax
f010517f:	ff 75 10             	pushl  0x10(%ebp)
f0105182:	ff 75 0c             	pushl  0xc(%ebp)
f0105185:	ff 75 08             	pushl  0x8(%ebp)
f0105188:	e8 9a ff ff ff       	call   f0105127 <vsnprintf>
	va_end(ap);

	return rc;
}
f010518d:	c9                   	leave  
f010518e:	c3                   	ret    

f010518f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010518f:	55                   	push   %ebp
f0105190:	89 e5                	mov    %esp,%ebp
f0105192:	57                   	push   %edi
f0105193:	56                   	push   %esi
f0105194:	53                   	push   %ebx
f0105195:	83 ec 0c             	sub    $0xc,%esp
f0105198:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010519b:	85 c0                	test   %eax,%eax
f010519d:	74 11                	je     f01051b0 <readline+0x21>
		cprintf("%s", prompt);
f010519f:	83 ec 08             	sub    $0x8,%esp
f01051a2:	50                   	push   %eax
f01051a3:	68 55 66 10 f0       	push   $0xf0106655
f01051a8:	e8 99 e5 ff ff       	call   f0103746 <cprintf>
f01051ad:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01051b0:	83 ec 0c             	sub    $0xc,%esp
f01051b3:	6a 00                	push   $0x0
f01051b5:	e8 bd b5 ff ff       	call   f0100777 <iscons>
f01051ba:	89 c7                	mov    %eax,%edi
f01051bc:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01051bf:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01051c4:	e8 9d b5 ff ff       	call   f0100766 <getchar>
f01051c9:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01051cb:	85 c0                	test   %eax,%eax
f01051cd:	79 18                	jns    f01051e7 <readline+0x58>
			cprintf("read error: %e\n", c);
f01051cf:	83 ec 08             	sub    $0x8,%esp
f01051d2:	50                   	push   %eax
f01051d3:	68 e8 7a 10 f0       	push   $0xf0107ae8
f01051d8:	e8 69 e5 ff ff       	call   f0103746 <cprintf>
			return NULL;
f01051dd:	83 c4 10             	add    $0x10,%esp
f01051e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01051e5:	eb 79                	jmp    f0105260 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01051e7:	83 f8 08             	cmp    $0x8,%eax
f01051ea:	0f 94 c2             	sete   %dl
f01051ed:	83 f8 7f             	cmp    $0x7f,%eax
f01051f0:	0f 94 c0             	sete   %al
f01051f3:	08 c2                	or     %al,%dl
f01051f5:	74 1a                	je     f0105211 <readline+0x82>
f01051f7:	85 f6                	test   %esi,%esi
f01051f9:	7e 16                	jle    f0105211 <readline+0x82>
			if (echoing)
f01051fb:	85 ff                	test   %edi,%edi
f01051fd:	74 0d                	je     f010520c <readline+0x7d>
				cputchar('\b');
f01051ff:	83 ec 0c             	sub    $0xc,%esp
f0105202:	6a 08                	push   $0x8
f0105204:	e8 4d b5 ff ff       	call   f0100756 <cputchar>
f0105209:	83 c4 10             	add    $0x10,%esp
			i--;
f010520c:	83 ee 01             	sub    $0x1,%esi
f010520f:	eb b3                	jmp    f01051c4 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105211:	83 fb 1f             	cmp    $0x1f,%ebx
f0105214:	7e 23                	jle    f0105239 <readline+0xaa>
f0105216:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010521c:	7f 1b                	jg     f0105239 <readline+0xaa>
			if (echoing)
f010521e:	85 ff                	test   %edi,%edi
f0105220:	74 0c                	je     f010522e <readline+0x9f>
				cputchar(c);
f0105222:	83 ec 0c             	sub    $0xc,%esp
f0105225:	53                   	push   %ebx
f0105226:	e8 2b b5 ff ff       	call   f0100756 <cputchar>
f010522b:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010522e:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f0105234:	8d 76 01             	lea    0x1(%esi),%esi
f0105237:	eb 8b                	jmp    f01051c4 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105239:	83 fb 0a             	cmp    $0xa,%ebx
f010523c:	74 05                	je     f0105243 <readline+0xb4>
f010523e:	83 fb 0d             	cmp    $0xd,%ebx
f0105241:	75 81                	jne    f01051c4 <readline+0x35>
			if (echoing)
f0105243:	85 ff                	test   %edi,%edi
f0105245:	74 0d                	je     f0105254 <readline+0xc5>
				cputchar('\n');
f0105247:	83 ec 0c             	sub    $0xc,%esp
f010524a:	6a 0a                	push   $0xa
f010524c:	e8 05 b5 ff ff       	call   f0100756 <cputchar>
f0105251:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105254:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f010525b:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f0105260:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105263:	5b                   	pop    %ebx
f0105264:	5e                   	pop    %esi
f0105265:	5f                   	pop    %edi
f0105266:	5d                   	pop    %ebp
f0105267:	c3                   	ret    

f0105268 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105268:	55                   	push   %ebp
f0105269:	89 e5                	mov    %esp,%ebp
f010526b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010526e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105273:	eb 03                	jmp    f0105278 <strlen+0x10>
		n++;
f0105275:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105278:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010527c:	75 f7                	jne    f0105275 <strlen+0xd>
		n++;
	return n;
}
f010527e:	5d                   	pop    %ebp
f010527f:	c3                   	ret    

f0105280 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105280:	55                   	push   %ebp
f0105281:	89 e5                	mov    %esp,%ebp
f0105283:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105286:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105289:	ba 00 00 00 00       	mov    $0x0,%edx
f010528e:	eb 03                	jmp    f0105293 <strnlen+0x13>
		n++;
f0105290:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105293:	39 c2                	cmp    %eax,%edx
f0105295:	74 08                	je     f010529f <strnlen+0x1f>
f0105297:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010529b:	75 f3                	jne    f0105290 <strnlen+0x10>
f010529d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010529f:	5d                   	pop    %ebp
f01052a0:	c3                   	ret    

f01052a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01052a1:	55                   	push   %ebp
f01052a2:	89 e5                	mov    %esp,%ebp
f01052a4:	53                   	push   %ebx
f01052a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01052a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01052ab:	89 c2                	mov    %eax,%edx
f01052ad:	83 c2 01             	add    $0x1,%edx
f01052b0:	83 c1 01             	add    $0x1,%ecx
f01052b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01052b7:	88 5a ff             	mov    %bl,-0x1(%edx)
f01052ba:	84 db                	test   %bl,%bl
f01052bc:	75 ef                	jne    f01052ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01052be:	5b                   	pop    %ebx
f01052bf:	5d                   	pop    %ebp
f01052c0:	c3                   	ret    

f01052c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01052c1:	55                   	push   %ebp
f01052c2:	89 e5                	mov    %esp,%ebp
f01052c4:	53                   	push   %ebx
f01052c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01052c8:	53                   	push   %ebx
f01052c9:	e8 9a ff ff ff       	call   f0105268 <strlen>
f01052ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01052d1:	ff 75 0c             	pushl  0xc(%ebp)
f01052d4:	01 d8                	add    %ebx,%eax
f01052d6:	50                   	push   %eax
f01052d7:	e8 c5 ff ff ff       	call   f01052a1 <strcpy>
	return dst;
}
f01052dc:	89 d8                	mov    %ebx,%eax
f01052de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01052e1:	c9                   	leave  
f01052e2:	c3                   	ret    

f01052e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01052e3:	55                   	push   %ebp
f01052e4:	89 e5                	mov    %esp,%ebp
f01052e6:	56                   	push   %esi
f01052e7:	53                   	push   %ebx
f01052e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01052eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01052ee:	89 f3                	mov    %esi,%ebx
f01052f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01052f3:	89 f2                	mov    %esi,%edx
f01052f5:	eb 0f                	jmp    f0105306 <strncpy+0x23>
		*dst++ = *src;
f01052f7:	83 c2 01             	add    $0x1,%edx
f01052fa:	0f b6 01             	movzbl (%ecx),%eax
f01052fd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105300:	80 39 01             	cmpb   $0x1,(%ecx)
f0105303:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105306:	39 da                	cmp    %ebx,%edx
f0105308:	75 ed                	jne    f01052f7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010530a:	89 f0                	mov    %esi,%eax
f010530c:	5b                   	pop    %ebx
f010530d:	5e                   	pop    %esi
f010530e:	5d                   	pop    %ebp
f010530f:	c3                   	ret    

f0105310 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105310:	55                   	push   %ebp
f0105311:	89 e5                	mov    %esp,%ebp
f0105313:	56                   	push   %esi
f0105314:	53                   	push   %ebx
f0105315:	8b 75 08             	mov    0x8(%ebp),%esi
f0105318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010531b:	8b 55 10             	mov    0x10(%ebp),%edx
f010531e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105320:	85 d2                	test   %edx,%edx
f0105322:	74 21                	je     f0105345 <strlcpy+0x35>
f0105324:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105328:	89 f2                	mov    %esi,%edx
f010532a:	eb 09                	jmp    f0105335 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010532c:	83 c2 01             	add    $0x1,%edx
f010532f:	83 c1 01             	add    $0x1,%ecx
f0105332:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105335:	39 c2                	cmp    %eax,%edx
f0105337:	74 09                	je     f0105342 <strlcpy+0x32>
f0105339:	0f b6 19             	movzbl (%ecx),%ebx
f010533c:	84 db                	test   %bl,%bl
f010533e:	75 ec                	jne    f010532c <strlcpy+0x1c>
f0105340:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105342:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105345:	29 f0                	sub    %esi,%eax
}
f0105347:	5b                   	pop    %ebx
f0105348:	5e                   	pop    %esi
f0105349:	5d                   	pop    %ebp
f010534a:	c3                   	ret    

f010534b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010534b:	55                   	push   %ebp
f010534c:	89 e5                	mov    %esp,%ebp
f010534e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105351:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105354:	eb 06                	jmp    f010535c <strcmp+0x11>
		p++, q++;
f0105356:	83 c1 01             	add    $0x1,%ecx
f0105359:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010535c:	0f b6 01             	movzbl (%ecx),%eax
f010535f:	84 c0                	test   %al,%al
f0105361:	74 04                	je     f0105367 <strcmp+0x1c>
f0105363:	3a 02                	cmp    (%edx),%al
f0105365:	74 ef                	je     f0105356 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105367:	0f b6 c0             	movzbl %al,%eax
f010536a:	0f b6 12             	movzbl (%edx),%edx
f010536d:	29 d0                	sub    %edx,%eax
}
f010536f:	5d                   	pop    %ebp
f0105370:	c3                   	ret    

f0105371 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105371:	55                   	push   %ebp
f0105372:	89 e5                	mov    %esp,%ebp
f0105374:	53                   	push   %ebx
f0105375:	8b 45 08             	mov    0x8(%ebp),%eax
f0105378:	8b 55 0c             	mov    0xc(%ebp),%edx
f010537b:	89 c3                	mov    %eax,%ebx
f010537d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105380:	eb 06                	jmp    f0105388 <strncmp+0x17>
		n--, p++, q++;
f0105382:	83 c0 01             	add    $0x1,%eax
f0105385:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105388:	39 d8                	cmp    %ebx,%eax
f010538a:	74 15                	je     f01053a1 <strncmp+0x30>
f010538c:	0f b6 08             	movzbl (%eax),%ecx
f010538f:	84 c9                	test   %cl,%cl
f0105391:	74 04                	je     f0105397 <strncmp+0x26>
f0105393:	3a 0a                	cmp    (%edx),%cl
f0105395:	74 eb                	je     f0105382 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105397:	0f b6 00             	movzbl (%eax),%eax
f010539a:	0f b6 12             	movzbl (%edx),%edx
f010539d:	29 d0                	sub    %edx,%eax
f010539f:	eb 05                	jmp    f01053a6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01053a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01053a6:	5b                   	pop    %ebx
f01053a7:	5d                   	pop    %ebp
f01053a8:	c3                   	ret    

f01053a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01053a9:	55                   	push   %ebp
f01053aa:	89 e5                	mov    %esp,%ebp
f01053ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01053af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01053b3:	eb 07                	jmp    f01053bc <strchr+0x13>
		if (*s == c)
f01053b5:	38 ca                	cmp    %cl,%dl
f01053b7:	74 0f                	je     f01053c8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01053b9:	83 c0 01             	add    $0x1,%eax
f01053bc:	0f b6 10             	movzbl (%eax),%edx
f01053bf:	84 d2                	test   %dl,%dl
f01053c1:	75 f2                	jne    f01053b5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01053c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01053c8:	5d                   	pop    %ebp
f01053c9:	c3                   	ret    

f01053ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01053ca:	55                   	push   %ebp
f01053cb:	89 e5                	mov    %esp,%ebp
f01053cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01053d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01053d4:	eb 03                	jmp    f01053d9 <strfind+0xf>
f01053d6:	83 c0 01             	add    $0x1,%eax
f01053d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01053dc:	38 ca                	cmp    %cl,%dl
f01053de:	74 04                	je     f01053e4 <strfind+0x1a>
f01053e0:	84 d2                	test   %dl,%dl
f01053e2:	75 f2                	jne    f01053d6 <strfind+0xc>
			break;
	return (char *) s;
}
f01053e4:	5d                   	pop    %ebp
f01053e5:	c3                   	ret    

f01053e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01053e6:	55                   	push   %ebp
f01053e7:	89 e5                	mov    %esp,%ebp
f01053e9:	57                   	push   %edi
f01053ea:	56                   	push   %esi
f01053eb:	53                   	push   %ebx
f01053ec:	8b 7d 08             	mov    0x8(%ebp),%edi
f01053ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01053f2:	85 c9                	test   %ecx,%ecx
f01053f4:	74 36                	je     f010542c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01053f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01053fc:	75 28                	jne    f0105426 <memset+0x40>
f01053fe:	f6 c1 03             	test   $0x3,%cl
f0105401:	75 23                	jne    f0105426 <memset+0x40>
		c &= 0xFF;
f0105403:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105407:	89 d3                	mov    %edx,%ebx
f0105409:	c1 e3 08             	shl    $0x8,%ebx
f010540c:	89 d6                	mov    %edx,%esi
f010540e:	c1 e6 18             	shl    $0x18,%esi
f0105411:	89 d0                	mov    %edx,%eax
f0105413:	c1 e0 10             	shl    $0x10,%eax
f0105416:	09 f0                	or     %esi,%eax
f0105418:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010541a:	89 d8                	mov    %ebx,%eax
f010541c:	09 d0                	or     %edx,%eax
f010541e:	c1 e9 02             	shr    $0x2,%ecx
f0105421:	fc                   	cld    
f0105422:	f3 ab                	rep stos %eax,%es:(%edi)
f0105424:	eb 06                	jmp    f010542c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105426:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105429:	fc                   	cld    
f010542a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010542c:	89 f8                	mov    %edi,%eax
f010542e:	5b                   	pop    %ebx
f010542f:	5e                   	pop    %esi
f0105430:	5f                   	pop    %edi
f0105431:	5d                   	pop    %ebp
f0105432:	c3                   	ret    

f0105433 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105433:	55                   	push   %ebp
f0105434:	89 e5                	mov    %esp,%ebp
f0105436:	57                   	push   %edi
f0105437:	56                   	push   %esi
f0105438:	8b 45 08             	mov    0x8(%ebp),%eax
f010543b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010543e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105441:	39 c6                	cmp    %eax,%esi
f0105443:	73 35                	jae    f010547a <memmove+0x47>
f0105445:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105448:	39 d0                	cmp    %edx,%eax
f010544a:	73 2e                	jae    f010547a <memmove+0x47>
		s += n;
		d += n;
f010544c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010544f:	89 d6                	mov    %edx,%esi
f0105451:	09 fe                	or     %edi,%esi
f0105453:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105459:	75 13                	jne    f010546e <memmove+0x3b>
f010545b:	f6 c1 03             	test   $0x3,%cl
f010545e:	75 0e                	jne    f010546e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105460:	83 ef 04             	sub    $0x4,%edi
f0105463:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105466:	c1 e9 02             	shr    $0x2,%ecx
f0105469:	fd                   	std    
f010546a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010546c:	eb 09                	jmp    f0105477 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010546e:	83 ef 01             	sub    $0x1,%edi
f0105471:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105474:	fd                   	std    
f0105475:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105477:	fc                   	cld    
f0105478:	eb 1d                	jmp    f0105497 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010547a:	89 f2                	mov    %esi,%edx
f010547c:	09 c2                	or     %eax,%edx
f010547e:	f6 c2 03             	test   $0x3,%dl
f0105481:	75 0f                	jne    f0105492 <memmove+0x5f>
f0105483:	f6 c1 03             	test   $0x3,%cl
f0105486:	75 0a                	jne    f0105492 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105488:	c1 e9 02             	shr    $0x2,%ecx
f010548b:	89 c7                	mov    %eax,%edi
f010548d:	fc                   	cld    
f010548e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105490:	eb 05                	jmp    f0105497 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105492:	89 c7                	mov    %eax,%edi
f0105494:	fc                   	cld    
f0105495:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105497:	5e                   	pop    %esi
f0105498:	5f                   	pop    %edi
f0105499:	5d                   	pop    %ebp
f010549a:	c3                   	ret    

f010549b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010549b:	55                   	push   %ebp
f010549c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010549e:	ff 75 10             	pushl  0x10(%ebp)
f01054a1:	ff 75 0c             	pushl  0xc(%ebp)
f01054a4:	ff 75 08             	pushl  0x8(%ebp)
f01054a7:	e8 87 ff ff ff       	call   f0105433 <memmove>
}
f01054ac:	c9                   	leave  
f01054ad:	c3                   	ret    

f01054ae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01054ae:	55                   	push   %ebp
f01054af:	89 e5                	mov    %esp,%ebp
f01054b1:	56                   	push   %esi
f01054b2:	53                   	push   %ebx
f01054b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01054b6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054b9:	89 c6                	mov    %eax,%esi
f01054bb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01054be:	eb 1a                	jmp    f01054da <memcmp+0x2c>
		if (*s1 != *s2)
f01054c0:	0f b6 08             	movzbl (%eax),%ecx
f01054c3:	0f b6 1a             	movzbl (%edx),%ebx
f01054c6:	38 d9                	cmp    %bl,%cl
f01054c8:	74 0a                	je     f01054d4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01054ca:	0f b6 c1             	movzbl %cl,%eax
f01054cd:	0f b6 db             	movzbl %bl,%ebx
f01054d0:	29 d8                	sub    %ebx,%eax
f01054d2:	eb 0f                	jmp    f01054e3 <memcmp+0x35>
		s1++, s2++;
f01054d4:	83 c0 01             	add    $0x1,%eax
f01054d7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01054da:	39 f0                	cmp    %esi,%eax
f01054dc:	75 e2                	jne    f01054c0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01054de:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01054e3:	5b                   	pop    %ebx
f01054e4:	5e                   	pop    %esi
f01054e5:	5d                   	pop    %ebp
f01054e6:	c3                   	ret    

f01054e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01054e7:	55                   	push   %ebp
f01054e8:	89 e5                	mov    %esp,%ebp
f01054ea:	53                   	push   %ebx
f01054eb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01054ee:	89 c1                	mov    %eax,%ecx
f01054f0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01054f3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01054f7:	eb 0a                	jmp    f0105503 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01054f9:	0f b6 10             	movzbl (%eax),%edx
f01054fc:	39 da                	cmp    %ebx,%edx
f01054fe:	74 07                	je     f0105507 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105500:	83 c0 01             	add    $0x1,%eax
f0105503:	39 c8                	cmp    %ecx,%eax
f0105505:	72 f2                	jb     f01054f9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105507:	5b                   	pop    %ebx
f0105508:	5d                   	pop    %ebp
f0105509:	c3                   	ret    

f010550a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010550a:	55                   	push   %ebp
f010550b:	89 e5                	mov    %esp,%ebp
f010550d:	57                   	push   %edi
f010550e:	56                   	push   %esi
f010550f:	53                   	push   %ebx
f0105510:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105513:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105516:	eb 03                	jmp    f010551b <strtol+0x11>
		s++;
f0105518:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010551b:	0f b6 01             	movzbl (%ecx),%eax
f010551e:	3c 20                	cmp    $0x20,%al
f0105520:	74 f6                	je     f0105518 <strtol+0xe>
f0105522:	3c 09                	cmp    $0x9,%al
f0105524:	74 f2                	je     f0105518 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105526:	3c 2b                	cmp    $0x2b,%al
f0105528:	75 0a                	jne    f0105534 <strtol+0x2a>
		s++;
f010552a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010552d:	bf 00 00 00 00       	mov    $0x0,%edi
f0105532:	eb 11                	jmp    f0105545 <strtol+0x3b>
f0105534:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105539:	3c 2d                	cmp    $0x2d,%al
f010553b:	75 08                	jne    f0105545 <strtol+0x3b>
		s++, neg = 1;
f010553d:	83 c1 01             	add    $0x1,%ecx
f0105540:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105545:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010554b:	75 15                	jne    f0105562 <strtol+0x58>
f010554d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105550:	75 10                	jne    f0105562 <strtol+0x58>
f0105552:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105556:	75 7c                	jne    f01055d4 <strtol+0xca>
		s += 2, base = 16;
f0105558:	83 c1 02             	add    $0x2,%ecx
f010555b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105560:	eb 16                	jmp    f0105578 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105562:	85 db                	test   %ebx,%ebx
f0105564:	75 12                	jne    f0105578 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105566:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010556b:	80 39 30             	cmpb   $0x30,(%ecx)
f010556e:	75 08                	jne    f0105578 <strtol+0x6e>
		s++, base = 8;
f0105570:	83 c1 01             	add    $0x1,%ecx
f0105573:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105578:	b8 00 00 00 00       	mov    $0x0,%eax
f010557d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105580:	0f b6 11             	movzbl (%ecx),%edx
f0105583:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105586:	89 f3                	mov    %esi,%ebx
f0105588:	80 fb 09             	cmp    $0x9,%bl
f010558b:	77 08                	ja     f0105595 <strtol+0x8b>
			dig = *s - '0';
f010558d:	0f be d2             	movsbl %dl,%edx
f0105590:	83 ea 30             	sub    $0x30,%edx
f0105593:	eb 22                	jmp    f01055b7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105595:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105598:	89 f3                	mov    %esi,%ebx
f010559a:	80 fb 19             	cmp    $0x19,%bl
f010559d:	77 08                	ja     f01055a7 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010559f:	0f be d2             	movsbl %dl,%edx
f01055a2:	83 ea 57             	sub    $0x57,%edx
f01055a5:	eb 10                	jmp    f01055b7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01055a7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01055aa:	89 f3                	mov    %esi,%ebx
f01055ac:	80 fb 19             	cmp    $0x19,%bl
f01055af:	77 16                	ja     f01055c7 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01055b1:	0f be d2             	movsbl %dl,%edx
f01055b4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01055b7:	3b 55 10             	cmp    0x10(%ebp),%edx
f01055ba:	7d 0b                	jge    f01055c7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01055bc:	83 c1 01             	add    $0x1,%ecx
f01055bf:	0f af 45 10          	imul   0x10(%ebp),%eax
f01055c3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01055c5:	eb b9                	jmp    f0105580 <strtol+0x76>

	if (endptr)
f01055c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01055cb:	74 0d                	je     f01055da <strtol+0xd0>
		*endptr = (char *) s;
f01055cd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01055d0:	89 0e                	mov    %ecx,(%esi)
f01055d2:	eb 06                	jmp    f01055da <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01055d4:	85 db                	test   %ebx,%ebx
f01055d6:	74 98                	je     f0105570 <strtol+0x66>
f01055d8:	eb 9e                	jmp    f0105578 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01055da:	89 c2                	mov    %eax,%edx
f01055dc:	f7 da                	neg    %edx
f01055de:	85 ff                	test   %edi,%edi
f01055e0:	0f 45 c2             	cmovne %edx,%eax
}
f01055e3:	5b                   	pop    %ebx
f01055e4:	5e                   	pop    %esi
f01055e5:	5f                   	pop    %edi
f01055e6:	5d                   	pop    %ebp
f01055e7:	c3                   	ret    

f01055e8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01055e8:	fa                   	cli    

	xorw    %ax, %ax
f01055e9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01055eb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01055ed:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01055ef:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01055f1:	0f 01 16             	lgdtl  (%esi)
f01055f4:	74 70                	je     f0105666 <mpsearch1+0x3>
	movl    %cr0, %eax
f01055f6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01055f9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01055fd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105600:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105606:	08 00                	or     %al,(%eax)

f0105608 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105608:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010560c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010560e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105610:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105612:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105616:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105618:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010561a:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010561f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105622:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105625:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010562a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010562d:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105633:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105638:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f010563d:	ff d0                	call   *%eax

f010563f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010563f:	eb fe                	jmp    f010563f <spin>
f0105641:	8d 76 00             	lea    0x0(%esi),%esi

f0105644 <gdt>:
	...
f010564c:	ff                   	(bad)  
f010564d:	ff 00                	incl   (%eax)
f010564f:	00 00                	add    %al,(%eax)
f0105651:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105658:	00                   	.byte 0x0
f0105659:	92                   	xchg   %eax,%edx
f010565a:	cf                   	iret   
	...

f010565c <gdtdesc>:
f010565c:	17                   	pop    %ss
f010565d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105662 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105662:	90                   	nop

f0105663 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105663:	55                   	push   %ebp
f0105664:	89 e5                	mov    %esp,%ebp
f0105666:	57                   	push   %edi
f0105667:	56                   	push   %esi
f0105668:	53                   	push   %ebx
f0105669:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010566c:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0105672:	89 c3                	mov    %eax,%ebx
f0105674:	c1 eb 0c             	shr    $0xc,%ebx
f0105677:	39 cb                	cmp    %ecx,%ebx
f0105679:	72 12                	jb     f010568d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010567b:	50                   	push   %eax
f010567c:	68 c4 60 10 f0       	push   $0xf01060c4
f0105681:	6a 57                	push   $0x57
f0105683:	68 85 7c 10 f0       	push   $0xf0107c85
f0105688:	e8 b3 a9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010568d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105693:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105695:	89 c2                	mov    %eax,%edx
f0105697:	c1 ea 0c             	shr    $0xc,%edx
f010569a:	39 ca                	cmp    %ecx,%edx
f010569c:	72 12                	jb     f01056b0 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010569e:	50                   	push   %eax
f010569f:	68 c4 60 10 f0       	push   $0xf01060c4
f01056a4:	6a 57                	push   $0x57
f01056a6:	68 85 7c 10 f0       	push   $0xf0107c85
f01056ab:	e8 90 a9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01056b0:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01056b6:	eb 2f                	jmp    f01056e7 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01056b8:	83 ec 04             	sub    $0x4,%esp
f01056bb:	6a 04                	push   $0x4
f01056bd:	68 95 7c 10 f0       	push   $0xf0107c95
f01056c2:	53                   	push   %ebx
f01056c3:	e8 e6 fd ff ff       	call   f01054ae <memcmp>
f01056c8:	83 c4 10             	add    $0x10,%esp
f01056cb:	85 c0                	test   %eax,%eax
f01056cd:	75 15                	jne    f01056e4 <mpsearch1+0x81>
f01056cf:	89 da                	mov    %ebx,%edx
f01056d1:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01056d4:	0f b6 0a             	movzbl (%edx),%ecx
f01056d7:	01 c8                	add    %ecx,%eax
f01056d9:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01056dc:	39 d7                	cmp    %edx,%edi
f01056de:	75 f4                	jne    f01056d4 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01056e0:	84 c0                	test   %al,%al
f01056e2:	74 0e                	je     f01056f2 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01056e4:	83 c3 10             	add    $0x10,%ebx
f01056e7:	39 f3                	cmp    %esi,%ebx
f01056e9:	72 cd                	jb     f01056b8 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01056eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01056f0:	eb 02                	jmp    f01056f4 <mpsearch1+0x91>
f01056f2:	89 d8                	mov    %ebx,%eax
}
f01056f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01056f7:	5b                   	pop    %ebx
f01056f8:	5e                   	pop    %esi
f01056f9:	5f                   	pop    %edi
f01056fa:	5d                   	pop    %ebp
f01056fb:	c3                   	ret    

f01056fc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01056fc:	55                   	push   %ebp
f01056fd:	89 e5                	mov    %esp,%ebp
f01056ff:	57                   	push   %edi
f0105700:	56                   	push   %esi
f0105701:	53                   	push   %ebx
f0105702:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105705:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f010570c:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010570f:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105716:	75 16                	jne    f010572e <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105718:	68 00 04 00 00       	push   $0x400
f010571d:	68 c4 60 10 f0       	push   $0xf01060c4
f0105722:	6a 6f                	push   $0x6f
f0105724:	68 85 7c 10 f0       	push   $0xf0107c85
f0105729:	e8 12 a9 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010572e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105735:	85 c0                	test   %eax,%eax
f0105737:	74 16                	je     f010574f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105739:	c1 e0 04             	shl    $0x4,%eax
f010573c:	ba 00 04 00 00       	mov    $0x400,%edx
f0105741:	e8 1d ff ff ff       	call   f0105663 <mpsearch1>
f0105746:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105749:	85 c0                	test   %eax,%eax
f010574b:	75 3c                	jne    f0105789 <mp_init+0x8d>
f010574d:	eb 20                	jmp    f010576f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010574f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105756:	c1 e0 0a             	shl    $0xa,%eax
f0105759:	2d 00 04 00 00       	sub    $0x400,%eax
f010575e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105763:	e8 fb fe ff ff       	call   f0105663 <mpsearch1>
f0105768:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010576b:	85 c0                	test   %eax,%eax
f010576d:	75 1a                	jne    f0105789 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010576f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105774:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105779:	e8 e5 fe ff ff       	call   f0105663 <mpsearch1>
f010577e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105781:	85 c0                	test   %eax,%eax
f0105783:	0f 84 5d 02 00 00    	je     f01059e6 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105789:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010578c:	8b 70 04             	mov    0x4(%eax),%esi
f010578f:	85 f6                	test   %esi,%esi
f0105791:	74 06                	je     f0105799 <mp_init+0x9d>
f0105793:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105797:	74 15                	je     f01057ae <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105799:	83 ec 0c             	sub    $0xc,%esp
f010579c:	68 f8 7a 10 f0       	push   $0xf0107af8
f01057a1:	e8 a0 df ff ff       	call   f0103746 <cprintf>
f01057a6:	83 c4 10             	add    $0x10,%esp
f01057a9:	e9 38 02 00 00       	jmp    f01059e6 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057ae:	89 f0                	mov    %esi,%eax
f01057b0:	c1 e8 0c             	shr    $0xc,%eax
f01057b3:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01057b9:	72 15                	jb     f01057d0 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057bb:	56                   	push   %esi
f01057bc:	68 c4 60 10 f0       	push   $0xf01060c4
f01057c1:	68 90 00 00 00       	push   $0x90
f01057c6:	68 85 7c 10 f0       	push   $0xf0107c85
f01057cb:	e8 70 a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01057d0:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01057d6:	83 ec 04             	sub    $0x4,%esp
f01057d9:	6a 04                	push   $0x4
f01057db:	68 9a 7c 10 f0       	push   $0xf0107c9a
f01057e0:	53                   	push   %ebx
f01057e1:	e8 c8 fc ff ff       	call   f01054ae <memcmp>
f01057e6:	83 c4 10             	add    $0x10,%esp
f01057e9:	85 c0                	test   %eax,%eax
f01057eb:	74 15                	je     f0105802 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01057ed:	83 ec 0c             	sub    $0xc,%esp
f01057f0:	68 28 7b 10 f0       	push   $0xf0107b28
f01057f5:	e8 4c df ff ff       	call   f0103746 <cprintf>
f01057fa:	83 c4 10             	add    $0x10,%esp
f01057fd:	e9 e4 01 00 00       	jmp    f01059e6 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105802:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105806:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010580a:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010580d:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105812:	b8 00 00 00 00       	mov    $0x0,%eax
f0105817:	eb 0d                	jmp    f0105826 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105819:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105820:	f0 
f0105821:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105823:	83 c0 01             	add    $0x1,%eax
f0105826:	39 c7                	cmp    %eax,%edi
f0105828:	75 ef                	jne    f0105819 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010582a:	84 d2                	test   %dl,%dl
f010582c:	74 15                	je     f0105843 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010582e:	83 ec 0c             	sub    $0xc,%esp
f0105831:	68 5c 7b 10 f0       	push   $0xf0107b5c
f0105836:	e8 0b df ff ff       	call   f0103746 <cprintf>
f010583b:	83 c4 10             	add    $0x10,%esp
f010583e:	e9 a3 01 00 00       	jmp    f01059e6 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105843:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105847:	3c 01                	cmp    $0x1,%al
f0105849:	74 1d                	je     f0105868 <mp_init+0x16c>
f010584b:	3c 04                	cmp    $0x4,%al
f010584d:	74 19                	je     f0105868 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010584f:	83 ec 08             	sub    $0x8,%esp
f0105852:	0f b6 c0             	movzbl %al,%eax
f0105855:	50                   	push   %eax
f0105856:	68 80 7b 10 f0       	push   $0xf0107b80
f010585b:	e8 e6 de ff ff       	call   f0103746 <cprintf>
f0105860:	83 c4 10             	add    $0x10,%esp
f0105863:	e9 7e 01 00 00       	jmp    f01059e6 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105868:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f010586c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105870:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105875:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010587a:	01 ce                	add    %ecx,%esi
f010587c:	eb 0d                	jmp    f010588b <mp_init+0x18f>
f010587e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105885:	f0 
f0105886:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105888:	83 c0 01             	add    $0x1,%eax
f010588b:	39 c7                	cmp    %eax,%edi
f010588d:	75 ef                	jne    f010587e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010588f:	89 d0                	mov    %edx,%eax
f0105891:	02 43 2a             	add    0x2a(%ebx),%al
f0105894:	74 15                	je     f01058ab <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105896:	83 ec 0c             	sub    $0xc,%esp
f0105899:	68 a0 7b 10 f0       	push   $0xf0107ba0
f010589e:	e8 a3 de ff ff       	call   f0103746 <cprintf>
f01058a3:	83 c4 10             	add    $0x10,%esp
f01058a6:	e9 3b 01 00 00       	jmp    f01059e6 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01058ab:	85 db                	test   %ebx,%ebx
f01058ad:	0f 84 33 01 00 00    	je     f01059e6 <mp_init+0x2ea>
		return;
	ismp = 1;
f01058b3:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f01058ba:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01058bd:	8b 43 24             	mov    0x24(%ebx),%eax
f01058c0:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01058c5:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01058c8:	be 00 00 00 00       	mov    $0x0,%esi
f01058cd:	e9 85 00 00 00       	jmp    f0105957 <mp_init+0x25b>
		switch (*p) {
f01058d2:	0f b6 07             	movzbl (%edi),%eax
f01058d5:	84 c0                	test   %al,%al
f01058d7:	74 06                	je     f01058df <mp_init+0x1e3>
f01058d9:	3c 04                	cmp    $0x4,%al
f01058db:	77 55                	ja     f0105932 <mp_init+0x236>
f01058dd:	eb 4e                	jmp    f010592d <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01058df:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01058e3:	74 11                	je     f01058f6 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01058e5:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f01058ec:	05 20 00 23 f0       	add    $0xf0230020,%eax
f01058f1:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f01058f6:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f01058fb:	83 f8 07             	cmp    $0x7,%eax
f01058fe:	7f 13                	jg     f0105913 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105900:	6b d0 74             	imul   $0x74,%eax,%edx
f0105903:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f0105909:	83 c0 01             	add    $0x1,%eax
f010590c:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f0105911:	eb 15                	jmp    f0105928 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105913:	83 ec 08             	sub    $0x8,%esp
f0105916:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010591a:	50                   	push   %eax
f010591b:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0105920:	e8 21 de ff ff       	call   f0103746 <cprintf>
f0105925:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105928:	83 c7 14             	add    $0x14,%edi
			continue;
f010592b:	eb 27                	jmp    f0105954 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010592d:	83 c7 08             	add    $0x8,%edi
			continue;
f0105930:	eb 22                	jmp    f0105954 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105932:	83 ec 08             	sub    $0x8,%esp
f0105935:	0f b6 c0             	movzbl %al,%eax
f0105938:	50                   	push   %eax
f0105939:	68 f8 7b 10 f0       	push   $0xf0107bf8
f010593e:	e8 03 de ff ff       	call   f0103746 <cprintf>
			ismp = 0;
f0105943:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f010594a:	00 00 00 
			i = conf->entry;
f010594d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105951:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105954:	83 c6 01             	add    $0x1,%esi
f0105957:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010595b:	39 c6                	cmp    %eax,%esi
f010595d:	0f 82 6f ff ff ff    	jb     f01058d2 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105963:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105968:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010596f:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105976:	75 26                	jne    f010599e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105978:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f010597f:	00 00 00 
		lapicaddr = 0;
f0105982:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105989:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010598c:	83 ec 0c             	sub    $0xc,%esp
f010598f:	68 18 7c 10 f0       	push   $0xf0107c18
f0105994:	e8 ad dd ff ff       	call   f0103746 <cprintf>
		return;
f0105999:	83 c4 10             	add    $0x10,%esp
f010599c:	eb 48                	jmp    f01059e6 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010599e:	83 ec 04             	sub    $0x4,%esp
f01059a1:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f01059a7:	0f b6 00             	movzbl (%eax),%eax
f01059aa:	50                   	push   %eax
f01059ab:	68 9f 7c 10 f0       	push   $0xf0107c9f
f01059b0:	e8 91 dd ff ff       	call   f0103746 <cprintf>

	if (mp->imcrp) {
f01059b5:	83 c4 10             	add    $0x10,%esp
f01059b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059bb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01059bf:	74 25                	je     f01059e6 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01059c1:	83 ec 0c             	sub    $0xc,%esp
f01059c4:	68 44 7c 10 f0       	push   $0xf0107c44
f01059c9:	e8 78 dd ff ff       	call   f0103746 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01059ce:	ba 22 00 00 00       	mov    $0x22,%edx
f01059d3:	b8 70 00 00 00       	mov    $0x70,%eax
f01059d8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01059d9:	ba 23 00 00 00       	mov    $0x23,%edx
f01059de:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01059df:	83 c8 01             	or     $0x1,%eax
f01059e2:	ee                   	out    %al,(%dx)
f01059e3:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01059e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059e9:	5b                   	pop    %ebx
f01059ea:	5e                   	pop    %esi
f01059eb:	5f                   	pop    %edi
f01059ec:	5d                   	pop    %ebp
f01059ed:	c3                   	ret    

f01059ee <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01059ee:	55                   	push   %ebp
f01059ef:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01059f1:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f01059f7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01059fa:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01059fc:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105a01:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105a04:	5d                   	pop    %ebp
f0105a05:	c3                   	ret    

f0105a06 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105a06:	55                   	push   %ebp
f0105a07:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105a09:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105a0e:	85 c0                	test   %eax,%eax
f0105a10:	74 08                	je     f0105a1a <cpunum+0x14>
		return lapic[ID] >> 24;
f0105a12:	8b 40 20             	mov    0x20(%eax),%eax
f0105a15:	c1 e8 18             	shr    $0x18,%eax
f0105a18:	eb 05                	jmp    f0105a1f <cpunum+0x19>
	return 0;
f0105a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a1f:	5d                   	pop    %ebp
f0105a20:	c3                   	ret    

f0105a21 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105a21:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105a26:	85 c0                	test   %eax,%eax
f0105a28:	0f 84 21 01 00 00    	je     f0105b4f <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105a2e:	55                   	push   %ebp
f0105a2f:	89 e5                	mov    %esp,%ebp
f0105a31:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105a34:	68 00 10 00 00       	push   $0x1000
f0105a39:	50                   	push   %eax
f0105a3a:	e8 ef b7 ff ff       	call   f010122e <mmio_map_region>
f0105a3f:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105a44:	ba 27 01 00 00       	mov    $0x127,%edx
f0105a49:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105a4e:	e8 9b ff ff ff       	call   f01059ee <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105a53:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105a58:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105a5d:	e8 8c ff ff ff       	call   f01059ee <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105a62:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105a67:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105a6c:	e8 7d ff ff ff       	call   f01059ee <lapicw>
	lapicw(TICR, 10000000); 
f0105a71:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105a76:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105a7b:	e8 6e ff ff ff       	call   f01059ee <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105a80:	e8 81 ff ff ff       	call   f0105a06 <cpunum>
f0105a85:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a88:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105a8d:	83 c4 10             	add    $0x10,%esp
f0105a90:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105a96:	74 0f                	je     f0105aa7 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105a98:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a9d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105aa2:	e8 47 ff ff ff       	call   f01059ee <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105aa7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105aac:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ab1:	e8 38 ff ff ff       	call   f01059ee <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105ab6:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105abb:	8b 40 30             	mov    0x30(%eax),%eax
f0105abe:	c1 e8 10             	shr    $0x10,%eax
f0105ac1:	3c 03                	cmp    $0x3,%al
f0105ac3:	76 0f                	jbe    f0105ad4 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105ac5:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105aca:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105acf:	e8 1a ff ff ff       	call   f01059ee <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ad4:	ba 33 00 00 00       	mov    $0x33,%edx
f0105ad9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ade:	e8 0b ff ff ff       	call   f01059ee <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ae3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ae8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105aed:	e8 fc fe ff ff       	call   f01059ee <lapicw>
	lapicw(ESR, 0);
f0105af2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105af7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105afc:	e8 ed fe ff ff       	call   f01059ee <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105b01:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b06:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105b0b:	e8 de fe ff ff       	call   f01059ee <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105b10:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b15:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b1a:	e8 cf fe ff ff       	call   f01059ee <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105b1f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105b24:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b29:	e8 c0 fe ff ff       	call   f01059ee <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105b2e:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105b34:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b3a:	f6 c4 10             	test   $0x10,%ah
f0105b3d:	75 f5                	jne    f0105b34 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105b3f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b44:	b8 20 00 00 00       	mov    $0x20,%eax
f0105b49:	e8 a0 fe ff ff       	call   f01059ee <lapicw>
}
f0105b4e:	c9                   	leave  
f0105b4f:	f3 c3                	repz ret 

f0105b51 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105b51:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105b58:	74 13                	je     f0105b6d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105b5a:	55                   	push   %ebp
f0105b5b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105b5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b62:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105b67:	e8 82 fe ff ff       	call   f01059ee <lapicw>
}
f0105b6c:	5d                   	pop    %ebp
f0105b6d:	f3 c3                	repz ret 

f0105b6f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105b6f:	55                   	push   %ebp
f0105b70:	89 e5                	mov    %esp,%ebp
f0105b72:	56                   	push   %esi
f0105b73:	53                   	push   %ebx
f0105b74:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b7a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105b7f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105b84:	ee                   	out    %al,(%dx)
f0105b85:	ba 71 00 00 00       	mov    $0x71,%edx
f0105b8a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105b8f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b90:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105b97:	75 19                	jne    f0105bb2 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b99:	68 67 04 00 00       	push   $0x467
f0105b9e:	68 c4 60 10 f0       	push   $0xf01060c4
f0105ba3:	68 98 00 00 00       	push   $0x98
f0105ba8:	68 bc 7c 10 f0       	push   $0xf0107cbc
f0105bad:	e8 8e a4 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105bb2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105bb9:	00 00 
	wrv[1] = addr >> 4;
f0105bbb:	89 d8                	mov    %ebx,%eax
f0105bbd:	c1 e8 04             	shr    $0x4,%eax
f0105bc0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105bc6:	c1 e6 18             	shl    $0x18,%esi
f0105bc9:	89 f2                	mov    %esi,%edx
f0105bcb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105bd0:	e8 19 fe ff ff       	call   f01059ee <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105bd5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105bda:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105bdf:	e8 0a fe ff ff       	call   f01059ee <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105be4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105be9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105bee:	e8 fb fd ff ff       	call   f01059ee <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105bf3:	c1 eb 0c             	shr    $0xc,%ebx
f0105bf6:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105bf9:	89 f2                	mov    %esi,%edx
f0105bfb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c00:	e8 e9 fd ff ff       	call   f01059ee <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c05:	89 da                	mov    %ebx,%edx
f0105c07:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c0c:	e8 dd fd ff ff       	call   f01059ee <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105c11:	89 f2                	mov    %esi,%edx
f0105c13:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c18:	e8 d1 fd ff ff       	call   f01059ee <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105c1d:	89 da                	mov    %ebx,%edx
f0105c1f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c24:	e8 c5 fd ff ff       	call   f01059ee <lapicw>
		microdelay(200);
	}
}
f0105c29:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105c2c:	5b                   	pop    %ebx
f0105c2d:	5e                   	pop    %esi
f0105c2e:	5d                   	pop    %ebp
f0105c2f:	c3                   	ret    

f0105c30 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105c30:	55                   	push   %ebp
f0105c31:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105c33:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c36:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105c3c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c41:	e8 a8 fd ff ff       	call   f01059ee <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105c46:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105c4c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105c52:	f6 c4 10             	test   $0x10,%ah
f0105c55:	75 f5                	jne    f0105c4c <lapic_ipi+0x1c>
		;
}
f0105c57:	5d                   	pop    %ebp
f0105c58:	c3                   	ret    

f0105c59 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105c59:	55                   	push   %ebp
f0105c5a:	89 e5                	mov    %esp,%ebp
f0105c5c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105c5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105c65:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c68:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105c6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105c72:	5d                   	pop    %ebp
f0105c73:	c3                   	ret    

f0105c74 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105c74:	55                   	push   %ebp
f0105c75:	89 e5                	mov    %esp,%ebp
f0105c77:	56                   	push   %esi
f0105c78:	53                   	push   %ebx
f0105c79:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105c7c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105c7f:	74 14                	je     f0105c95 <spin_lock+0x21>
f0105c81:	8b 73 08             	mov    0x8(%ebx),%esi
f0105c84:	e8 7d fd ff ff       	call   f0105a06 <cpunum>
f0105c89:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c8c:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105c91:	39 c6                	cmp    %eax,%esi
f0105c93:	74 07                	je     f0105c9c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105c95:	ba 01 00 00 00       	mov    $0x1,%edx
f0105c9a:	eb 20                	jmp    f0105cbc <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105c9c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105c9f:	e8 62 fd ff ff       	call   f0105a06 <cpunum>
f0105ca4:	83 ec 0c             	sub    $0xc,%esp
f0105ca7:	53                   	push   %ebx
f0105ca8:	50                   	push   %eax
f0105ca9:	68 cc 7c 10 f0       	push   $0xf0107ccc
f0105cae:	6a 41                	push   $0x41
f0105cb0:	68 30 7d 10 f0       	push   $0xf0107d30
f0105cb5:	e8 86 a3 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105cba:	f3 90                	pause  
f0105cbc:	89 d0                	mov    %edx,%eax
f0105cbe:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105cc1:	85 c0                	test   %eax,%eax
f0105cc3:	75 f5                	jne    f0105cba <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105cc5:	e8 3c fd ff ff       	call   f0105a06 <cpunum>
f0105cca:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ccd:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105cd2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105cd5:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105cd8:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105cda:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cdf:	eb 0b                	jmp    f0105cec <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105ce1:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ce4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105ce7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ce9:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105cec:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105cf2:	76 11                	jbe    f0105d05 <spin_lock+0x91>
f0105cf4:	83 f8 09             	cmp    $0x9,%eax
f0105cf7:	7e e8                	jle    f0105ce1 <spin_lock+0x6d>
f0105cf9:	eb 0a                	jmp    f0105d05 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105cfb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105d02:	83 c0 01             	add    $0x1,%eax
f0105d05:	83 f8 09             	cmp    $0x9,%eax
f0105d08:	7e f1                	jle    f0105cfb <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105d0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105d0d:	5b                   	pop    %ebx
f0105d0e:	5e                   	pop    %esi
f0105d0f:	5d                   	pop    %ebp
f0105d10:	c3                   	ret    

f0105d11 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105d11:	55                   	push   %ebp
f0105d12:	89 e5                	mov    %esp,%ebp
f0105d14:	57                   	push   %edi
f0105d15:	56                   	push   %esi
f0105d16:	53                   	push   %ebx
f0105d17:	83 ec 4c             	sub    $0x4c,%esp
f0105d1a:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105d1d:	83 3e 00             	cmpl   $0x0,(%esi)
f0105d20:	74 18                	je     f0105d3a <spin_unlock+0x29>
f0105d22:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105d25:	e8 dc fc ff ff       	call   f0105a06 <cpunum>
f0105d2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d2d:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105d32:	39 c3                	cmp    %eax,%ebx
f0105d34:	0f 84 a5 00 00 00    	je     f0105ddf <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105d3a:	83 ec 04             	sub    $0x4,%esp
f0105d3d:	6a 28                	push   $0x28
f0105d3f:	8d 46 0c             	lea    0xc(%esi),%eax
f0105d42:	50                   	push   %eax
f0105d43:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105d46:	53                   	push   %ebx
f0105d47:	e8 e7 f6 ff ff       	call   f0105433 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105d4c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105d4f:	0f b6 38             	movzbl (%eax),%edi
f0105d52:	8b 76 04             	mov    0x4(%esi),%esi
f0105d55:	e8 ac fc ff ff       	call   f0105a06 <cpunum>
f0105d5a:	57                   	push   %edi
f0105d5b:	56                   	push   %esi
f0105d5c:	50                   	push   %eax
f0105d5d:	68 f8 7c 10 f0       	push   $0xf0107cf8
f0105d62:	e8 df d9 ff ff       	call   f0103746 <cprintf>
f0105d67:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105d6a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105d6d:	eb 54                	jmp    f0105dc3 <spin_unlock+0xb2>
f0105d6f:	83 ec 08             	sub    $0x8,%esp
f0105d72:	57                   	push   %edi
f0105d73:	50                   	push   %eax
f0105d74:	e8 e5 eb ff ff       	call   f010495e <debuginfo_eip>
f0105d79:	83 c4 10             	add    $0x10,%esp
f0105d7c:	85 c0                	test   %eax,%eax
f0105d7e:	78 27                	js     f0105da7 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105d80:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105d82:	83 ec 04             	sub    $0x4,%esp
f0105d85:	89 c2                	mov    %eax,%edx
f0105d87:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105d8a:	52                   	push   %edx
f0105d8b:	ff 75 b0             	pushl  -0x50(%ebp)
f0105d8e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105d91:	ff 75 ac             	pushl  -0x54(%ebp)
f0105d94:	ff 75 a8             	pushl  -0x58(%ebp)
f0105d97:	50                   	push   %eax
f0105d98:	68 40 7d 10 f0       	push   $0xf0107d40
f0105d9d:	e8 a4 d9 ff ff       	call   f0103746 <cprintf>
f0105da2:	83 c4 20             	add    $0x20,%esp
f0105da5:	eb 12                	jmp    f0105db9 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105da7:	83 ec 08             	sub    $0x8,%esp
f0105daa:	ff 36                	pushl  (%esi)
f0105dac:	68 57 7d 10 f0       	push   $0xf0107d57
f0105db1:	e8 90 d9 ff ff       	call   f0103746 <cprintf>
f0105db6:	83 c4 10             	add    $0x10,%esp
f0105db9:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105dbc:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105dbf:	39 c3                	cmp    %eax,%ebx
f0105dc1:	74 08                	je     f0105dcb <spin_unlock+0xba>
f0105dc3:	89 de                	mov    %ebx,%esi
f0105dc5:	8b 03                	mov    (%ebx),%eax
f0105dc7:	85 c0                	test   %eax,%eax
f0105dc9:	75 a4                	jne    f0105d6f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105dcb:	83 ec 04             	sub    $0x4,%esp
f0105dce:	68 5f 7d 10 f0       	push   $0xf0107d5f
f0105dd3:	6a 67                	push   $0x67
f0105dd5:	68 30 7d 10 f0       	push   $0xf0107d30
f0105dda:	e8 61 a2 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105ddf:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105de6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105ded:	b8 00 00 00 00       	mov    $0x0,%eax
f0105df2:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105df8:	5b                   	pop    %ebx
f0105df9:	5e                   	pop    %esi
f0105dfa:	5f                   	pop    %edi
f0105dfb:	5d                   	pop    %ebp
f0105dfc:	c3                   	ret    
f0105dfd:	66 90                	xchg   %ax,%ax
f0105dff:	90                   	nop

f0105e00 <__udivdi3>:
f0105e00:	55                   	push   %ebp
f0105e01:	57                   	push   %edi
f0105e02:	56                   	push   %esi
f0105e03:	53                   	push   %ebx
f0105e04:	83 ec 1c             	sub    $0x1c,%esp
f0105e07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105e0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105e0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e17:	85 f6                	test   %esi,%esi
f0105e19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105e1d:	89 ca                	mov    %ecx,%edx
f0105e1f:	89 f8                	mov    %edi,%eax
f0105e21:	75 3d                	jne    f0105e60 <__udivdi3+0x60>
f0105e23:	39 cf                	cmp    %ecx,%edi
f0105e25:	0f 87 c5 00 00 00    	ja     f0105ef0 <__udivdi3+0xf0>
f0105e2b:	85 ff                	test   %edi,%edi
f0105e2d:	89 fd                	mov    %edi,%ebp
f0105e2f:	75 0b                	jne    f0105e3c <__udivdi3+0x3c>
f0105e31:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e36:	31 d2                	xor    %edx,%edx
f0105e38:	f7 f7                	div    %edi
f0105e3a:	89 c5                	mov    %eax,%ebp
f0105e3c:	89 c8                	mov    %ecx,%eax
f0105e3e:	31 d2                	xor    %edx,%edx
f0105e40:	f7 f5                	div    %ebp
f0105e42:	89 c1                	mov    %eax,%ecx
f0105e44:	89 d8                	mov    %ebx,%eax
f0105e46:	89 cf                	mov    %ecx,%edi
f0105e48:	f7 f5                	div    %ebp
f0105e4a:	89 c3                	mov    %eax,%ebx
f0105e4c:	89 d8                	mov    %ebx,%eax
f0105e4e:	89 fa                	mov    %edi,%edx
f0105e50:	83 c4 1c             	add    $0x1c,%esp
f0105e53:	5b                   	pop    %ebx
f0105e54:	5e                   	pop    %esi
f0105e55:	5f                   	pop    %edi
f0105e56:	5d                   	pop    %ebp
f0105e57:	c3                   	ret    
f0105e58:	90                   	nop
f0105e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105e60:	39 ce                	cmp    %ecx,%esi
f0105e62:	77 74                	ja     f0105ed8 <__udivdi3+0xd8>
f0105e64:	0f bd fe             	bsr    %esi,%edi
f0105e67:	83 f7 1f             	xor    $0x1f,%edi
f0105e6a:	0f 84 98 00 00 00    	je     f0105f08 <__udivdi3+0x108>
f0105e70:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105e75:	89 f9                	mov    %edi,%ecx
f0105e77:	89 c5                	mov    %eax,%ebp
f0105e79:	29 fb                	sub    %edi,%ebx
f0105e7b:	d3 e6                	shl    %cl,%esi
f0105e7d:	89 d9                	mov    %ebx,%ecx
f0105e7f:	d3 ed                	shr    %cl,%ebp
f0105e81:	89 f9                	mov    %edi,%ecx
f0105e83:	d3 e0                	shl    %cl,%eax
f0105e85:	09 ee                	or     %ebp,%esi
f0105e87:	89 d9                	mov    %ebx,%ecx
f0105e89:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e8d:	89 d5                	mov    %edx,%ebp
f0105e8f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105e93:	d3 ed                	shr    %cl,%ebp
f0105e95:	89 f9                	mov    %edi,%ecx
f0105e97:	d3 e2                	shl    %cl,%edx
f0105e99:	89 d9                	mov    %ebx,%ecx
f0105e9b:	d3 e8                	shr    %cl,%eax
f0105e9d:	09 c2                	or     %eax,%edx
f0105e9f:	89 d0                	mov    %edx,%eax
f0105ea1:	89 ea                	mov    %ebp,%edx
f0105ea3:	f7 f6                	div    %esi
f0105ea5:	89 d5                	mov    %edx,%ebp
f0105ea7:	89 c3                	mov    %eax,%ebx
f0105ea9:	f7 64 24 0c          	mull   0xc(%esp)
f0105ead:	39 d5                	cmp    %edx,%ebp
f0105eaf:	72 10                	jb     f0105ec1 <__udivdi3+0xc1>
f0105eb1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105eb5:	89 f9                	mov    %edi,%ecx
f0105eb7:	d3 e6                	shl    %cl,%esi
f0105eb9:	39 c6                	cmp    %eax,%esi
f0105ebb:	73 07                	jae    f0105ec4 <__udivdi3+0xc4>
f0105ebd:	39 d5                	cmp    %edx,%ebp
f0105ebf:	75 03                	jne    f0105ec4 <__udivdi3+0xc4>
f0105ec1:	83 eb 01             	sub    $0x1,%ebx
f0105ec4:	31 ff                	xor    %edi,%edi
f0105ec6:	89 d8                	mov    %ebx,%eax
f0105ec8:	89 fa                	mov    %edi,%edx
f0105eca:	83 c4 1c             	add    $0x1c,%esp
f0105ecd:	5b                   	pop    %ebx
f0105ece:	5e                   	pop    %esi
f0105ecf:	5f                   	pop    %edi
f0105ed0:	5d                   	pop    %ebp
f0105ed1:	c3                   	ret    
f0105ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105ed8:	31 ff                	xor    %edi,%edi
f0105eda:	31 db                	xor    %ebx,%ebx
f0105edc:	89 d8                	mov    %ebx,%eax
f0105ede:	89 fa                	mov    %edi,%edx
f0105ee0:	83 c4 1c             	add    $0x1c,%esp
f0105ee3:	5b                   	pop    %ebx
f0105ee4:	5e                   	pop    %esi
f0105ee5:	5f                   	pop    %edi
f0105ee6:	5d                   	pop    %ebp
f0105ee7:	c3                   	ret    
f0105ee8:	90                   	nop
f0105ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ef0:	89 d8                	mov    %ebx,%eax
f0105ef2:	f7 f7                	div    %edi
f0105ef4:	31 ff                	xor    %edi,%edi
f0105ef6:	89 c3                	mov    %eax,%ebx
f0105ef8:	89 d8                	mov    %ebx,%eax
f0105efa:	89 fa                	mov    %edi,%edx
f0105efc:	83 c4 1c             	add    $0x1c,%esp
f0105eff:	5b                   	pop    %ebx
f0105f00:	5e                   	pop    %esi
f0105f01:	5f                   	pop    %edi
f0105f02:	5d                   	pop    %ebp
f0105f03:	c3                   	ret    
f0105f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105f08:	39 ce                	cmp    %ecx,%esi
f0105f0a:	72 0c                	jb     f0105f18 <__udivdi3+0x118>
f0105f0c:	31 db                	xor    %ebx,%ebx
f0105f0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105f12:	0f 87 34 ff ff ff    	ja     f0105e4c <__udivdi3+0x4c>
f0105f18:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105f1d:	e9 2a ff ff ff       	jmp    f0105e4c <__udivdi3+0x4c>
f0105f22:	66 90                	xchg   %ax,%ax
f0105f24:	66 90                	xchg   %ax,%ax
f0105f26:	66 90                	xchg   %ax,%ax
f0105f28:	66 90                	xchg   %ax,%ax
f0105f2a:	66 90                	xchg   %ax,%ax
f0105f2c:	66 90                	xchg   %ax,%ax
f0105f2e:	66 90                	xchg   %ax,%ax

f0105f30 <__umoddi3>:
f0105f30:	55                   	push   %ebp
f0105f31:	57                   	push   %edi
f0105f32:	56                   	push   %esi
f0105f33:	53                   	push   %ebx
f0105f34:	83 ec 1c             	sub    $0x1c,%esp
f0105f37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105f3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105f3f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105f47:	85 d2                	test   %edx,%edx
f0105f49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f51:	89 f3                	mov    %esi,%ebx
f0105f53:	89 3c 24             	mov    %edi,(%esp)
f0105f56:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f5a:	75 1c                	jne    f0105f78 <__umoddi3+0x48>
f0105f5c:	39 f7                	cmp    %esi,%edi
f0105f5e:	76 50                	jbe    f0105fb0 <__umoddi3+0x80>
f0105f60:	89 c8                	mov    %ecx,%eax
f0105f62:	89 f2                	mov    %esi,%edx
f0105f64:	f7 f7                	div    %edi
f0105f66:	89 d0                	mov    %edx,%eax
f0105f68:	31 d2                	xor    %edx,%edx
f0105f6a:	83 c4 1c             	add    $0x1c,%esp
f0105f6d:	5b                   	pop    %ebx
f0105f6e:	5e                   	pop    %esi
f0105f6f:	5f                   	pop    %edi
f0105f70:	5d                   	pop    %ebp
f0105f71:	c3                   	ret    
f0105f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105f78:	39 f2                	cmp    %esi,%edx
f0105f7a:	89 d0                	mov    %edx,%eax
f0105f7c:	77 52                	ja     f0105fd0 <__umoddi3+0xa0>
f0105f7e:	0f bd ea             	bsr    %edx,%ebp
f0105f81:	83 f5 1f             	xor    $0x1f,%ebp
f0105f84:	75 5a                	jne    f0105fe0 <__umoddi3+0xb0>
f0105f86:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105f8a:	0f 82 e0 00 00 00    	jb     f0106070 <__umoddi3+0x140>
f0105f90:	39 0c 24             	cmp    %ecx,(%esp)
f0105f93:	0f 86 d7 00 00 00    	jbe    f0106070 <__umoddi3+0x140>
f0105f99:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105f9d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105fa1:	83 c4 1c             	add    $0x1c,%esp
f0105fa4:	5b                   	pop    %ebx
f0105fa5:	5e                   	pop    %esi
f0105fa6:	5f                   	pop    %edi
f0105fa7:	5d                   	pop    %ebp
f0105fa8:	c3                   	ret    
f0105fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fb0:	85 ff                	test   %edi,%edi
f0105fb2:	89 fd                	mov    %edi,%ebp
f0105fb4:	75 0b                	jne    f0105fc1 <__umoddi3+0x91>
f0105fb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105fbb:	31 d2                	xor    %edx,%edx
f0105fbd:	f7 f7                	div    %edi
f0105fbf:	89 c5                	mov    %eax,%ebp
f0105fc1:	89 f0                	mov    %esi,%eax
f0105fc3:	31 d2                	xor    %edx,%edx
f0105fc5:	f7 f5                	div    %ebp
f0105fc7:	89 c8                	mov    %ecx,%eax
f0105fc9:	f7 f5                	div    %ebp
f0105fcb:	89 d0                	mov    %edx,%eax
f0105fcd:	eb 99                	jmp    f0105f68 <__umoddi3+0x38>
f0105fcf:	90                   	nop
f0105fd0:	89 c8                	mov    %ecx,%eax
f0105fd2:	89 f2                	mov    %esi,%edx
f0105fd4:	83 c4 1c             	add    $0x1c,%esp
f0105fd7:	5b                   	pop    %ebx
f0105fd8:	5e                   	pop    %esi
f0105fd9:	5f                   	pop    %edi
f0105fda:	5d                   	pop    %ebp
f0105fdb:	c3                   	ret    
f0105fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105fe0:	8b 34 24             	mov    (%esp),%esi
f0105fe3:	bf 20 00 00 00       	mov    $0x20,%edi
f0105fe8:	89 e9                	mov    %ebp,%ecx
f0105fea:	29 ef                	sub    %ebp,%edi
f0105fec:	d3 e0                	shl    %cl,%eax
f0105fee:	89 f9                	mov    %edi,%ecx
f0105ff0:	89 f2                	mov    %esi,%edx
f0105ff2:	d3 ea                	shr    %cl,%edx
f0105ff4:	89 e9                	mov    %ebp,%ecx
f0105ff6:	09 c2                	or     %eax,%edx
f0105ff8:	89 d8                	mov    %ebx,%eax
f0105ffa:	89 14 24             	mov    %edx,(%esp)
f0105ffd:	89 f2                	mov    %esi,%edx
f0105fff:	d3 e2                	shl    %cl,%edx
f0106001:	89 f9                	mov    %edi,%ecx
f0106003:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106007:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010600b:	d3 e8                	shr    %cl,%eax
f010600d:	89 e9                	mov    %ebp,%ecx
f010600f:	89 c6                	mov    %eax,%esi
f0106011:	d3 e3                	shl    %cl,%ebx
f0106013:	89 f9                	mov    %edi,%ecx
f0106015:	89 d0                	mov    %edx,%eax
f0106017:	d3 e8                	shr    %cl,%eax
f0106019:	89 e9                	mov    %ebp,%ecx
f010601b:	09 d8                	or     %ebx,%eax
f010601d:	89 d3                	mov    %edx,%ebx
f010601f:	89 f2                	mov    %esi,%edx
f0106021:	f7 34 24             	divl   (%esp)
f0106024:	89 d6                	mov    %edx,%esi
f0106026:	d3 e3                	shl    %cl,%ebx
f0106028:	f7 64 24 04          	mull   0x4(%esp)
f010602c:	39 d6                	cmp    %edx,%esi
f010602e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106032:	89 d1                	mov    %edx,%ecx
f0106034:	89 c3                	mov    %eax,%ebx
f0106036:	72 08                	jb     f0106040 <__umoddi3+0x110>
f0106038:	75 11                	jne    f010604b <__umoddi3+0x11b>
f010603a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010603e:	73 0b                	jae    f010604b <__umoddi3+0x11b>
f0106040:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106044:	1b 14 24             	sbb    (%esp),%edx
f0106047:	89 d1                	mov    %edx,%ecx
f0106049:	89 c3                	mov    %eax,%ebx
f010604b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010604f:	29 da                	sub    %ebx,%edx
f0106051:	19 ce                	sbb    %ecx,%esi
f0106053:	89 f9                	mov    %edi,%ecx
f0106055:	89 f0                	mov    %esi,%eax
f0106057:	d3 e0                	shl    %cl,%eax
f0106059:	89 e9                	mov    %ebp,%ecx
f010605b:	d3 ea                	shr    %cl,%edx
f010605d:	89 e9                	mov    %ebp,%ecx
f010605f:	d3 ee                	shr    %cl,%esi
f0106061:	09 d0                	or     %edx,%eax
f0106063:	89 f2                	mov    %esi,%edx
f0106065:	83 c4 1c             	add    $0x1c,%esp
f0106068:	5b                   	pop    %ebx
f0106069:	5e                   	pop    %esi
f010606a:	5f                   	pop    %edi
f010606b:	5d                   	pop    %ebp
f010606c:	c3                   	ret    
f010606d:	8d 76 00             	lea    0x0(%esi),%esi
f0106070:	29 f9                	sub    %edi,%ecx
f0106072:	19 d6                	sbb    %edx,%esi
f0106074:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106078:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010607c:	e9 18 ff ff ff       	jmp    f0105f99 <__umoddi3+0x69>
