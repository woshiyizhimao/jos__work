
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
f0100015:	b8 00 40 11 00       	mov    $0x114000,%eax
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
f0100034:	bc 00 40 11 f0       	mov    $0xf0114000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 69 11 f0       	mov    $0xf0116970,%eax
f010004b:	2d 00 63 11 f0       	sub    $0xf0116300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 63 11 f0       	push   $0xf0116300
f0100058:	e8 27 31 00 00       	call   f0103184 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 88 04 00 00       	call   f01004ea <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 20 36 10 f0       	push   $0xf0103620
f010006f:	e8 38 26 00 00       	call   f01026ac <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 51 0f 00 00       	call   f0100fca <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 11 07 00 00       	call   f0100797 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 60 69 11 f0 00 	cmpl   $0x0,0xf0116960
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 60 69 11 f0    	mov    %esi,0xf0116960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 3b 36 10 f0       	push   $0xf010363b
f01000b5:	e8 f2 25 00 00       	call   f01026ac <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 c2 25 00 00       	call   f0102686 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 2f 45 10 f0 	movl   $0xf010452f,(%esp)
f01000cb:	e8 dc 25 00 00       	call   f01026ac <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 ba 06 00 00       	call   f0100797 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 53 36 10 f0       	push   $0xf0103653
f01000f7:	e8 b0 25 00 00       	call   f01026ac <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 7e 25 00 00       	call   f0102686 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 2f 45 10 f0 	movl   $0xf010452f,(%esp)
f010010f:	e8 98 25 00 00       	call   f01026ac <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 65 11 f0    	mov    0xf0116524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 65 11 f0    	mov    %edx,0xf0116524
f0100159:	88 81 20 63 11 f0    	mov    %al,-0xfee9ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 65 11 f0 00 	movl   $0x0,0xf0116524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f0 00 00 00    	je     f010027c <kbd_proc_data+0xfe>
f010018c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100191:	ec                   	in     (%dx),%al
f0100192:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100194:	3c e0                	cmp    $0xe0,%al
f0100196:	75 0d                	jne    f01001a5 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100198:	83 0d 00 63 11 f0 40 	orl    $0x40,0xf0116300
		return 0;
f010019f:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001a4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001a5:	55                   	push   %ebp
f01001a6:	89 e5                	mov    %esp,%ebp
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001ac:	84 c0                	test   %al,%al
f01001ae:	79 36                	jns    f01001e6 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b0:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001b6:	89 cb                	mov    %ecx,%ebx
f01001b8:	83 e3 40             	and    $0x40,%ebx
f01001bb:	83 e0 7f             	and    $0x7f,%eax
f01001be:	85 db                	test   %ebx,%ebx
f01001c0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001c3:	0f b6 d2             	movzbl %dl,%edx
f01001c6:	0f b6 82 c0 37 10 f0 	movzbl -0xfefc840(%edx),%eax
f01001cd:	83 c8 40             	or     $0x40,%eax
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	f7 d0                	not    %eax
f01001d5:	21 c8                	and    %ecx,%eax
f01001d7:	a3 00 63 11 f0       	mov    %eax,0xf0116300
		return 0;
f01001dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e1:	e9 9e 00 00 00       	jmp    f0100284 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001e6:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001ec:	f6 c1 40             	test   $0x40,%cl
f01001ef:	74 0e                	je     f01001ff <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f1:	83 c8 80             	or     $0xffffff80,%eax
f01001f4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001f6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f9:	89 0d 00 63 11 f0    	mov    %ecx,0xf0116300
	}

	shift |= shiftcode[data];
f01001ff:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100202:	0f b6 82 c0 37 10 f0 	movzbl -0xfefc840(%edx),%eax
f0100209:	0b 05 00 63 11 f0    	or     0xf0116300,%eax
f010020f:	0f b6 8a c0 36 10 f0 	movzbl -0xfefc940(%edx),%ecx
f0100216:	31 c8                	xor    %ecx,%eax
f0100218:	a3 00 63 11 f0       	mov    %eax,0xf0116300

	c = charcode[shift & (CTL | SHIFT)][data];
f010021d:	89 c1                	mov    %eax,%ecx
f010021f:	83 e1 03             	and    $0x3,%ecx
f0100222:	8b 0c 8d a0 36 10 f0 	mov    -0xfefc960(,%ecx,4),%ecx
f0100229:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010022d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100230:	a8 08                	test   $0x8,%al
f0100232:	74 1b                	je     f010024f <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100234:	89 da                	mov    %ebx,%edx
f0100236:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100239:	83 f9 19             	cmp    $0x19,%ecx
f010023c:	77 05                	ja     f0100243 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010023e:	83 eb 20             	sub    $0x20,%ebx
f0100241:	eb 0c                	jmp    f010024f <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100243:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100246:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100249:	83 fa 19             	cmp    $0x19,%edx
f010024c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010024f:	f7 d0                	not    %eax
f0100251:	a8 06                	test   $0x6,%al
f0100253:	75 2d                	jne    f0100282 <kbd_proc_data+0x104>
f0100255:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010025b:	75 25                	jne    f0100282 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010025d:	83 ec 0c             	sub    $0xc,%esp
f0100260:	68 6d 36 10 f0       	push   $0xf010366d
f0100265:	e8 42 24 00 00       	call   f01026ac <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026a:	ba 92 00 00 00       	mov    $0x92,%edx
f010026f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100274:	ee                   	out    %al,(%dx)
f0100275:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100278:	89 d8                	mov    %ebx,%eax
f010027a:	eb 08                	jmp    f0100284 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100281:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100282:	89 d8                	mov    %ebx,%eax
}
f0100284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100287:	c9                   	leave  
f0100288:	c3                   	ret    

f0100289 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100289:	55                   	push   %ebp
f010028a:	89 e5                	mov    %esp,%ebp
f010028c:	57                   	push   %edi
f010028d:	56                   	push   %esi
f010028e:	53                   	push   %ebx
f010028f:	83 ec 1c             	sub    $0x1c,%esp
f0100292:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100294:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100299:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029e:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a3:	eb 09                	jmp    f01002ae <cons_putc+0x25>
f01002a5:	89 ca                	mov    %ecx,%edx
f01002a7:	ec                   	in     (%dx),%al
f01002a8:	ec                   	in     (%dx),%al
f01002a9:	ec                   	in     (%dx),%al
f01002aa:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ab:	83 c3 01             	add    $0x1,%ebx
f01002ae:	89 f2                	mov    %esi,%edx
f01002b0:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b1:	a8 20                	test   $0x20,%al
f01002b3:	75 08                	jne    f01002bd <cons_putc+0x34>
f01002b5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002bb:	7e e8                	jle    f01002a5 <cons_putc+0x1c>
f01002bd:	89 f8                	mov    %edi,%eax
f01002bf:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c7:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c8:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cd:	be 79 03 00 00       	mov    $0x379,%esi
f01002d2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d7:	eb 09                	jmp    f01002e2 <cons_putc+0x59>
f01002d9:	89 ca                	mov    %ecx,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	89 f2                	mov    %esi,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002eb:	7f 04                	jg     f01002f1 <cons_putc+0x68>
f01002ed:	84 c0                	test   %al,%al
f01002ef:	79 e8                	jns    f01002d9 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002fa:	ee                   	out    %al,(%dx)
f01002fb:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100300:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100305:	ee                   	out    %al,(%dx)
f0100306:	b8 08 00 00 00       	mov    $0x8,%eax
f010030b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010030c:	89 fa                	mov    %edi,%edx
f010030e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100314:	89 f8                	mov    %edi,%eax
f0100316:	80 cc 07             	or     $0x7,%ah
f0100319:	85 d2                	test   %edx,%edx
f010031b:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010031e:	89 f8                	mov    %edi,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	83 f8 09             	cmp    $0x9,%eax
f0100326:	74 74                	je     f010039c <cons_putc+0x113>
f0100328:	83 f8 09             	cmp    $0x9,%eax
f010032b:	7f 0a                	jg     f0100337 <cons_putc+0xae>
f010032d:	83 f8 08             	cmp    $0x8,%eax
f0100330:	74 14                	je     f0100346 <cons_putc+0xbd>
f0100332:	e9 99 00 00 00       	jmp    f01003d0 <cons_putc+0x147>
f0100337:	83 f8 0a             	cmp    $0xa,%eax
f010033a:	74 3a                	je     f0100376 <cons_putc+0xed>
f010033c:	83 f8 0d             	cmp    $0xd,%eax
f010033f:	74 3d                	je     f010037e <cons_putc+0xf5>
f0100341:	e9 8a 00 00 00       	jmp    f01003d0 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100346:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f010034d:	66 85 c0             	test   %ax,%ax
f0100350:	0f 84 e6 00 00 00    	je     f010043c <cons_putc+0x1b3>
			crt_pos--;
f0100356:	83 e8 01             	sub    $0x1,%eax
f0100359:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010035f:	0f b7 c0             	movzwl %ax,%eax
f0100362:	66 81 e7 00 ff       	and    $0xff00,%di
f0100367:	83 cf 20             	or     $0x20,%edi
f010036a:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f0100370:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100374:	eb 78                	jmp    f01003ee <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100376:	66 83 05 28 65 11 f0 	addw   $0x50,0xf0116528
f010037d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010037e:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f0100385:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010038b:	c1 e8 16             	shr    $0x16,%eax
f010038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100391:	c1 e0 04             	shl    $0x4,%eax
f0100394:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
f010039a:	eb 52                	jmp    f01003ee <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010039c:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a1:	e8 e3 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003a6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ab:	e8 d9 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003b0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b5:	e8 cf fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bf:	e8 c5 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c9:	e8 bb fe ff ff       	call   f0100289 <cons_putc>
f01003ce:	eb 1e                	jmp    f01003ee <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003d0:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f01003d7:	8d 50 01             	lea    0x1(%eax),%edx
f01003da:	66 89 15 28 65 11 f0 	mov    %dx,0xf0116528
f01003e1:	0f b7 c0             	movzwl %ax,%eax
f01003e4:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f01003ea:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003ee:	66 81 3d 28 65 11 f0 	cmpw   $0x7cf,0xf0116528
f01003f5:	cf 07 
f01003f7:	76 43                	jbe    f010043c <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003f9:	a1 2c 65 11 f0       	mov    0xf011652c,%eax
f01003fe:	83 ec 04             	sub    $0x4,%esp
f0100401:	68 00 0f 00 00       	push   $0xf00
f0100406:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010040c:	52                   	push   %edx
f010040d:	50                   	push   %eax
f010040e:	e8 be 2d 00 00       	call   f01031d1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100413:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f0100419:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010041f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100425:	83 c4 10             	add    $0x10,%esp
f0100428:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010042d:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100430:	39 d0                	cmp    %edx,%eax
f0100432:	75 f4                	jne    f0100428 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100434:	66 83 2d 28 65 11 f0 	subw   $0x50,0xf0116528
f010043b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010043c:	8b 0d 30 65 11 f0    	mov    0xf0116530,%ecx
f0100442:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100447:	89 ca                	mov    %ecx,%edx
f0100449:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010044a:	0f b7 1d 28 65 11 f0 	movzwl 0xf0116528,%ebx
f0100451:	8d 71 01             	lea    0x1(%ecx),%esi
f0100454:	89 d8                	mov    %ebx,%eax
f0100456:	66 c1 e8 08          	shr    $0x8,%ax
f010045a:	89 f2                	mov    %esi,%edx
f010045c:	ee                   	out    %al,(%dx)
f010045d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100462:	89 ca                	mov    %ecx,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	89 d8                	mov    %ebx,%eax
f0100467:	89 f2                	mov    %esi,%edx
f0100469:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010046a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010046d:	5b                   	pop    %ebx
f010046e:	5e                   	pop    %esi
f010046f:	5f                   	pop    %edi
f0100470:	5d                   	pop    %ebp
f0100471:	c3                   	ret    

f0100472 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100472:	80 3d 34 65 11 f0 00 	cmpb   $0x0,0xf0116534
f0100479:	74 11                	je     f010048c <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010047b:	55                   	push   %ebp
f010047c:	89 e5                	mov    %esp,%ebp
f010047e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100481:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100486:	e8 b0 fc ff ff       	call   f010013b <cons_intr>
}
f010048b:	c9                   	leave  
f010048c:	f3 c3                	repz ret 

f010048e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010048e:	55                   	push   %ebp
f010048f:	89 e5                	mov    %esp,%ebp
f0100491:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100494:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f0100499:	e8 9d fc ff ff       	call   f010013b <cons_intr>
}
f010049e:	c9                   	leave  
f010049f:	c3                   	ret    

f01004a0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a6:	e8 c7 ff ff ff       	call   f0100472 <serial_intr>
	kbd_intr();
f01004ab:	e8 de ff ff ff       	call   f010048e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004b0:	a1 20 65 11 f0       	mov    0xf0116520,%eax
f01004b5:	3b 05 24 65 11 f0    	cmp    0xf0116524,%eax
f01004bb:	74 26                	je     f01004e3 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004bd:	8d 50 01             	lea    0x1(%eax),%edx
f01004c0:	89 15 20 65 11 f0    	mov    %edx,0xf0116520
f01004c6:	0f b6 88 20 63 11 f0 	movzbl -0xfee9ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004cd:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004cf:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004d5:	75 11                	jne    f01004e8 <cons_getc+0x48>
			cons.rpos = 0;
f01004d7:	c7 05 20 65 11 f0 00 	movl   $0x0,0xf0116520
f01004de:	00 00 00 
f01004e1:	eb 05                	jmp    f01004e8 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e8:	c9                   	leave  
f01004e9:	c3                   	ret    

f01004ea <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ea:	55                   	push   %ebp
f01004eb:	89 e5                	mov    %esp,%ebp
f01004ed:	57                   	push   %edi
f01004ee:	56                   	push   %esi
f01004ef:	53                   	push   %ebx
f01004f0:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004f3:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01004fa:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100501:	5a a5 
	if (*cp != 0xA55A) {
f0100503:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010050a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010050e:	74 11                	je     f0100521 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100510:	c7 05 30 65 11 f0 b4 	movl   $0x3b4,0xf0116530
f0100517:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010051a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010051f:	eb 16                	jmp    f0100537 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100521:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100528:	c7 05 30 65 11 f0 d4 	movl   $0x3d4,0xf0116530
f010052f:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100532:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100537:	8b 3d 30 65 11 f0    	mov    0xf0116530,%edi
f010053d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100542:	89 fa                	mov    %edi,%edx
f0100544:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100545:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100548:	89 da                	mov    %ebx,%edx
f010054a:	ec                   	in     (%dx),%al
f010054b:	0f b6 c8             	movzbl %al,%ecx
f010054e:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100551:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100556:	89 fa                	mov    %edi,%edx
f0100558:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100559:	89 da                	mov    %ebx,%edx
f010055b:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010055c:	89 35 2c 65 11 f0    	mov    %esi,0xf011652c
	crt_pos = pos;
f0100562:	0f b6 c0             	movzbl %al,%eax
f0100565:	09 c8                	or     %ecx,%eax
f0100567:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056d:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100572:	b8 00 00 00 00       	mov    $0x0,%eax
f0100577:	89 f2                	mov    %esi,%edx
f0100579:	ee                   	out    %al,(%dx)
f010057a:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010057f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100584:	ee                   	out    %al,(%dx)
f0100585:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010058a:	b8 0c 00 00 00       	mov    $0xc,%eax
f010058f:	89 da                	mov    %ebx,%edx
f0100591:	ee                   	out    %al,(%dx)
f0100592:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100597:	b8 00 00 00 00       	mov    $0x0,%eax
f010059c:	ee                   	out    %al,(%dx)
f010059d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a2:	b8 03 00 00 00       	mov    $0x3,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b2:	ee                   	out    %al,(%dx)
f01005b3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01005bd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005be:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005c3:	ec                   	in     (%dx),%al
f01005c4:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c6:	3c ff                	cmp    $0xff,%al
f01005c8:	0f 95 05 34 65 11 f0 	setne  0xf0116534
f01005cf:	89 f2                	mov    %esi,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 da                	mov    %ebx,%edx
f01005d4:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d5:	80 f9 ff             	cmp    $0xff,%cl
f01005d8:	75 10                	jne    f01005ea <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005da:	83 ec 0c             	sub    $0xc,%esp
f01005dd:	68 79 36 10 f0       	push   $0xf0103679
f01005e2:	e8 c5 20 00 00       	call   f01026ac <cprintf>
f01005e7:	83 c4 10             	add    $0x10,%esp
}
f01005ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ed:	5b                   	pop    %ebx
f01005ee:	5e                   	pop    %esi
f01005ef:	5f                   	pop    %edi
f01005f0:	5d                   	pop    %ebp
f01005f1:	c3                   	ret    

f01005f2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fb:	e8 89 fc ff ff       	call   f0100289 <cons_putc>
}
f0100600:	c9                   	leave  
f0100601:	c3                   	ret    

f0100602 <getchar>:

int
getchar(void)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100608:	e8 93 fe ff ff       	call   f01004a0 <cons_getc>
f010060d:	85 c0                	test   %eax,%eax
f010060f:	74 f7                	je     f0100608 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100611:	c9                   	leave  
f0100612:	c3                   	ret    

f0100613 <iscons>:

int
iscons(int fdnum)
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100616:	b8 01 00 00 00       	mov    $0x1,%eax
f010061b:	5d                   	pop    %ebp
f010061c:	c3                   	ret    

f010061d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010061d:	55                   	push   %ebp
f010061e:	89 e5                	mov    %esp,%ebp
f0100620:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100623:	68 c0 38 10 f0       	push   $0xf01038c0
f0100628:	68 de 38 10 f0       	push   $0xf01038de
f010062d:	68 e3 38 10 f0       	push   $0xf01038e3
f0100632:	e8 75 20 00 00       	call   f01026ac <cprintf>
f0100637:	83 c4 0c             	add    $0xc,%esp
f010063a:	68 94 39 10 f0       	push   $0xf0103994
f010063f:	68 ec 38 10 f0       	push   $0xf01038ec
f0100644:	68 e3 38 10 f0       	push   $0xf01038e3
f0100649:	e8 5e 20 00 00       	call   f01026ac <cprintf>
	return 0;
}
f010064e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100653:	c9                   	leave  
f0100654:	c3                   	ret    

f0100655 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100655:	55                   	push   %ebp
f0100656:	89 e5                	mov    %esp,%ebp
f0100658:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010065b:	68 f5 38 10 f0       	push   $0xf01038f5
f0100660:	e8 47 20 00 00       	call   f01026ac <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100665:	83 c4 08             	add    $0x8,%esp
f0100668:	68 0c 00 10 00       	push   $0x10000c
f010066d:	68 bc 39 10 f0       	push   $0xf01039bc
f0100672:	e8 35 20 00 00       	call   f01026ac <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100677:	83 c4 0c             	add    $0xc,%esp
f010067a:	68 0c 00 10 00       	push   $0x10000c
f010067f:	68 0c 00 10 f0       	push   $0xf010000c
f0100684:	68 e4 39 10 f0       	push   $0xf01039e4
f0100689:	e8 1e 20 00 00       	call   f01026ac <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010068e:	83 c4 0c             	add    $0xc,%esp
f0100691:	68 11 36 10 00       	push   $0x103611
f0100696:	68 11 36 10 f0       	push   $0xf0103611
f010069b:	68 08 3a 10 f0       	push   $0xf0103a08
f01006a0:	e8 07 20 00 00       	call   f01026ac <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006a5:	83 c4 0c             	add    $0xc,%esp
f01006a8:	68 00 63 11 00       	push   $0x116300
f01006ad:	68 00 63 11 f0       	push   $0xf0116300
f01006b2:	68 2c 3a 10 f0       	push   $0xf0103a2c
f01006b7:	e8 f0 1f 00 00       	call   f01026ac <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006bc:	83 c4 0c             	add    $0xc,%esp
f01006bf:	68 70 69 11 00       	push   $0x116970
f01006c4:	68 70 69 11 f0       	push   $0xf0116970
f01006c9:	68 50 3a 10 f0       	push   $0xf0103a50
f01006ce:	e8 d9 1f 00 00       	call   f01026ac <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006d3:	b8 6f 6d 11 f0       	mov    $0xf0116d6f,%eax
f01006d8:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006dd:	83 c4 08             	add    $0x8,%esp
f01006e0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006e5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006eb:	85 c0                	test   %eax,%eax
f01006ed:	0f 48 c2             	cmovs  %edx,%eax
f01006f0:	c1 f8 0a             	sar    $0xa,%eax
f01006f3:	50                   	push   %eax
f01006f4:	68 74 3a 10 f0       	push   $0xf0103a74
f01006f9:	e8 ae 1f 00 00       	call   f01026ac <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100703:	c9                   	leave  
f0100704:	c3                   	ret    

f0100705 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100705:	55                   	push   %ebp
f0100706:	89 e5                	mov    %esp,%ebp
f0100708:	57                   	push   %edi
f0100709:	56                   	push   %esi
f010070a:	53                   	push   %ebx
f010070b:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010070e:	89 ee                	mov    %ebp,%esi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();//获取ebp值
	cprintf("Stack backtrace:\n");//输出格式
f0100710:	68 0e 39 10 f0       	push   $0xf010390e
f0100715:	e8 92 1f 00 00       	call   f01026ac <cprintf>
	while (ebp) 
f010071a:	83 c4 10             	add    $0x10,%esp
f010071d:	eb 67                	jmp    f0100786 <mon_backtrace+0x81>
	{
	cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);//输出ebp,eip，其中eip通过ebp[1]得到
f010071f:	83 ec 04             	sub    $0x4,%esp
f0100722:	ff 76 04             	pushl  0x4(%esi)
f0100725:	56                   	push   %esi
f0100726:	68 20 39 10 f0       	push   $0xf0103920
f010072b:	e8 7c 1f 00 00       	call   f01026ac <cprintf>
f0100730:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100733:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100736:	83 c4 10             	add    $0x10,%esp
	int j=2;
	while(j!=7) //输出args[i]
	     {
	     cprintf(" %08x", ebp[j]);
f0100739:	83 ec 08             	sub    $0x8,%esp
f010073c:	ff 33                	pushl  (%ebx)
f010073e:	68 39 39 10 f0       	push   $0xf0103939
f0100743:	e8 64 1f 00 00       	call   f01026ac <cprintf>
f0100748:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");//输出格式
	while (ebp) 
	{
	cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);//输出ebp,eip，其中eip通过ebp[1]得到
	int j=2;
	while(j!=7) //输出args[i]
f010074b:	83 c4 10             	add    $0x10,%esp
f010074e:	39 fb                	cmp    %edi,%ebx
f0100750:	75 e7                	jne    f0100739 <mon_backtrace+0x34>
	     {
	     cprintf(" %08x", ebp[j]);
	     j++;
	     } 
	debuginfo_eip(ebp[1],&info);
f0100752:	83 ec 08             	sub    $0x8,%esp
f0100755:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100758:	50                   	push   %eax
f0100759:	ff 76 04             	pushl  0x4(%esi)
f010075c:	e8 55 20 00 00       	call   f01027b6 <debuginfo_eip>
	cprintf("\n    %s:%d:  %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f0100761:	83 c4 08             	add    $0x8,%esp
f0100764:	8b 46 04             	mov    0x4(%esi),%eax
f0100767:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010076a:	50                   	push   %eax
f010076b:	ff 75 d8             	pushl  -0x28(%ebp)
f010076e:	ff 75 dc             	pushl  -0x24(%ebp)
f0100771:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100774:	ff 75 d0             	pushl  -0x30(%ebp)
f0100777:	68 3f 39 10 f0       	push   $0xf010393f
f010077c:	e8 2b 1f 00 00       	call   f01026ac <cprintf>
	ebp = (uint32_t *) (*ebp);
f0100781:	8b 36                	mov    (%esi),%esi
f0100783:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();//获取ebp值
	cprintf("Stack backtrace:\n");//输出格式
	while (ebp) 
f0100786:	85 f6                	test   %esi,%esi
f0100788:	75 95                	jne    f010071f <mon_backtrace+0x1a>
	debuginfo_eip(ebp[1],&info);
	cprintf("\n    %s:%d:  %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
	ebp = (uint32_t *) (*ebp);
	}
	return 0;
}
f010078a:	b8 00 00 00 00       	mov    $0x0,%eax
f010078f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100792:	5b                   	pop    %ebx
f0100793:	5e                   	pop    %esi
f0100794:	5f                   	pop    %edi
f0100795:	5d                   	pop    %ebp
f0100796:	c3                   	ret    

f0100797 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100797:	55                   	push   %ebp
f0100798:	89 e5                	mov    %esp,%ebp
f010079a:	57                   	push   %edi
f010079b:	56                   	push   %esi
f010079c:	53                   	push   %ebx
f010079d:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007a0:	68 a0 3a 10 f0       	push   $0xf0103aa0
f01007a5:	e8 02 1f 00 00       	call   f01026ac <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007aa:	c7 04 24 c4 3a 10 f0 	movl   $0xf0103ac4,(%esp)
f01007b1:	e8 f6 1e 00 00       	call   f01026ac <cprintf>
f01007b6:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007b9:	83 ec 0c             	sub    $0xc,%esp
f01007bc:	68 55 39 10 f0       	push   $0xf0103955
f01007c1:	e8 67 27 00 00       	call   f0102f2d <readline>
f01007c6:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007c8:	83 c4 10             	add    $0x10,%esp
f01007cb:	85 c0                	test   %eax,%eax
f01007cd:	74 ea                	je     f01007b9 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007cf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007d6:	be 00 00 00 00       	mov    $0x0,%esi
f01007db:	eb 0a                	jmp    f01007e7 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007dd:	c6 03 00             	movb   $0x0,(%ebx)
f01007e0:	89 f7                	mov    %esi,%edi
f01007e2:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007e5:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007e7:	0f b6 03             	movzbl (%ebx),%eax
f01007ea:	84 c0                	test   %al,%al
f01007ec:	74 63                	je     f0100851 <monitor+0xba>
f01007ee:	83 ec 08             	sub    $0x8,%esp
f01007f1:	0f be c0             	movsbl %al,%eax
f01007f4:	50                   	push   %eax
f01007f5:	68 59 39 10 f0       	push   $0xf0103959
f01007fa:	e8 48 29 00 00       	call   f0103147 <strchr>
f01007ff:	83 c4 10             	add    $0x10,%esp
f0100802:	85 c0                	test   %eax,%eax
f0100804:	75 d7                	jne    f01007dd <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100806:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100809:	74 46                	je     f0100851 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010080b:	83 fe 0f             	cmp    $0xf,%esi
f010080e:	75 14                	jne    f0100824 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100810:	83 ec 08             	sub    $0x8,%esp
f0100813:	6a 10                	push   $0x10
f0100815:	68 5e 39 10 f0       	push   $0xf010395e
f010081a:	e8 8d 1e 00 00       	call   f01026ac <cprintf>
f010081f:	83 c4 10             	add    $0x10,%esp
f0100822:	eb 95                	jmp    f01007b9 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100824:	8d 7e 01             	lea    0x1(%esi),%edi
f0100827:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010082b:	eb 03                	jmp    f0100830 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010082d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100830:	0f b6 03             	movzbl (%ebx),%eax
f0100833:	84 c0                	test   %al,%al
f0100835:	74 ae                	je     f01007e5 <monitor+0x4e>
f0100837:	83 ec 08             	sub    $0x8,%esp
f010083a:	0f be c0             	movsbl %al,%eax
f010083d:	50                   	push   %eax
f010083e:	68 59 39 10 f0       	push   $0xf0103959
f0100843:	e8 ff 28 00 00       	call   f0103147 <strchr>
f0100848:	83 c4 10             	add    $0x10,%esp
f010084b:	85 c0                	test   %eax,%eax
f010084d:	74 de                	je     f010082d <monitor+0x96>
f010084f:	eb 94                	jmp    f01007e5 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100851:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100858:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100859:	85 f6                	test   %esi,%esi
f010085b:	0f 84 58 ff ff ff    	je     f01007b9 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100861:	83 ec 08             	sub    $0x8,%esp
f0100864:	68 de 38 10 f0       	push   $0xf01038de
f0100869:	ff 75 a8             	pushl  -0x58(%ebp)
f010086c:	e8 78 28 00 00       	call   f01030e9 <strcmp>
f0100871:	83 c4 10             	add    $0x10,%esp
f0100874:	85 c0                	test   %eax,%eax
f0100876:	74 1e                	je     f0100896 <monitor+0xff>
f0100878:	83 ec 08             	sub    $0x8,%esp
f010087b:	68 ec 38 10 f0       	push   $0xf01038ec
f0100880:	ff 75 a8             	pushl  -0x58(%ebp)
f0100883:	e8 61 28 00 00       	call   f01030e9 <strcmp>
f0100888:	83 c4 10             	add    $0x10,%esp
f010088b:	85 c0                	test   %eax,%eax
f010088d:	75 2f                	jne    f01008be <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010088f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100894:	eb 05                	jmp    f010089b <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100896:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010089b:	83 ec 04             	sub    $0x4,%esp
f010089e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008a1:	01 d0                	add    %edx,%eax
f01008a3:	ff 75 08             	pushl  0x8(%ebp)
f01008a6:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008a9:	51                   	push   %ecx
f01008aa:	56                   	push   %esi
f01008ab:	ff 14 85 f4 3a 10 f0 	call   *-0xfefc50c(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008b2:	83 c4 10             	add    $0x10,%esp
f01008b5:	85 c0                	test   %eax,%eax
f01008b7:	78 1d                	js     f01008d6 <monitor+0x13f>
f01008b9:	e9 fb fe ff ff       	jmp    f01007b9 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008be:	83 ec 08             	sub    $0x8,%esp
f01008c1:	ff 75 a8             	pushl  -0x58(%ebp)
f01008c4:	68 7b 39 10 f0       	push   $0xf010397b
f01008c9:	e8 de 1d 00 00       	call   f01026ac <cprintf>
f01008ce:	83 c4 10             	add    $0x10,%esp
f01008d1:	e9 e3 fe ff ff       	jmp    f01007b9 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d9:	5b                   	pop    %ebx
f01008da:	5e                   	pop    %esi
f01008db:	5f                   	pop    %edi
f01008dc:	5d                   	pop    %ebp
f01008dd:	c3                   	ret    

f01008de <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008de:	55                   	push   %ebp
f01008df:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008e1:	83 3d 38 65 11 f0 00 	cmpl   $0x0,0xf0116538
f01008e8:	75 11                	jne    f01008fb <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01008ea:	ba 6f 79 11 f0       	mov    $0xf011796f,%edx
f01008ef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008f5:	89 15 38 65 11 f0    	mov    %edx,0xf0116538
	// LAB 2: Your code here.
	//cprintf("boot_alloc, nextfree:%x\n", nextfree);
	if((nextfree+n)>(char *)0xffffffff)
		panic("out of memory!\n");
	char *res;
	res = nextfree;
f01008fb:	8b 15 38 65 11 f0    	mov    0xf0116538,%edx
	if(n>0)
f0100901:	85 c0                	test   %eax,%eax
f0100903:	74 11                	je     f0100916 <boot_alloc+0x38>
		nextfree = ROUNDUP( nextfree+n,PGSIZE);
f0100905:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f010090c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100911:	a3 38 65 11 f0       	mov    %eax,0xf0116538
	return res;
}
f0100916:	89 d0                	mov    %edx,%eax
f0100918:	5d                   	pop    %ebp
f0100919:	c3                   	ret    

f010091a <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010091a:	89 d1                	mov    %edx,%ecx
f010091c:	c1 e9 16             	shr    $0x16,%ecx
f010091f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100922:	a8 01                	test   $0x1,%al
f0100924:	74 52                	je     f0100978 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100926:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010092b:	89 c1                	mov    %eax,%ecx
f010092d:	c1 e9 0c             	shr    $0xc,%ecx
f0100930:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f0100936:	72 1b                	jb     f0100953 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010093e:	50                   	push   %eax
f010093f:	68 04 3b 10 f0       	push   $0xf0103b04
f0100944:	68 d1 02 00 00       	push   $0x2d1
f0100949:	68 80 42 10 f0       	push   $0xf0104280
f010094e:	e8 38 f7 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100953:	c1 ea 0c             	shr    $0xc,%edx
f0100956:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010095c:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100963:	89 c2                	mov    %eax,%edx
f0100965:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010096d:	85 d2                	test   %edx,%edx
f010096f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100974:	0f 44 c2             	cmove  %edx,%eax
f0100977:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f010097d:	c3                   	ret    

f010097e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010097e:	55                   	push   %ebp
f010097f:	89 e5                	mov    %esp,%ebp
f0100981:	57                   	push   %edi
f0100982:	56                   	push   %esi
f0100983:	53                   	push   %ebx
f0100984:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100987:	84 c0                	test   %al,%al
f0100989:	0f 85 72 02 00 00    	jne    f0100c01 <check_page_free_list+0x283>
f010098f:	e9 7f 02 00 00       	jmp    f0100c13 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100994:	83 ec 04             	sub    $0x4,%esp
f0100997:	68 28 3b 10 f0       	push   $0xf0103b28
f010099c:	68 14 02 00 00       	push   $0x214
f01009a1:	68 80 42 10 f0       	push   $0xf0104280
f01009a6:	e8 e0 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009ab:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009ae:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009b7:	89 c2                	mov    %eax,%edx
f01009b9:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01009bf:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01009c5:	0f 95 c2             	setne  %dl
f01009c8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01009cb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01009cf:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01009d1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009d5:	8b 00                	mov    (%eax),%eax
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	75 dc                	jne    f01009b7 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01009db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01009e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01009ea:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01009ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009ef:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009f4:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009f9:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f01009ff:	eb 53                	jmp    f0100a54 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a01:	89 d8                	mov    %ebx,%eax
f0100a03:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100a09:	c1 f8 03             	sar    $0x3,%eax
f0100a0c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a0f:	89 c2                	mov    %eax,%edx
f0100a11:	c1 ea 16             	shr    $0x16,%edx
f0100a14:	39 f2                	cmp    %esi,%edx
f0100a16:	73 3a                	jae    f0100a52 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a18:	89 c2                	mov    %eax,%edx
f0100a1a:	c1 ea 0c             	shr    $0xc,%edx
f0100a1d:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100a23:	72 12                	jb     f0100a37 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a25:	50                   	push   %eax
f0100a26:	68 04 3b 10 f0       	push   $0xf0103b04
f0100a2b:	6a 52                	push   $0x52
f0100a2d:	68 8c 42 10 f0       	push   $0xf010428c
f0100a32:	e8 54 f6 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a37:	83 ec 04             	sub    $0x4,%esp
f0100a3a:	68 80 00 00 00       	push   $0x80
f0100a3f:	68 97 00 00 00       	push   $0x97
f0100a44:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a49:	50                   	push   %eax
f0100a4a:	e8 35 27 00 00       	call   f0103184 <memset>
f0100a4f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a52:	8b 1b                	mov    (%ebx),%ebx
f0100a54:	85 db                	test   %ebx,%ebx
f0100a56:	75 a9                	jne    f0100a01 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a58:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a5d:	e8 7c fe ff ff       	call   f01008de <boot_alloc>
f0100a62:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a65:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a6b:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
		assert(pp < pages + npages);
f0100a71:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0100a76:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100a79:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a7c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100a7f:	be 00 00 00 00       	mov    $0x0,%esi
f0100a84:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a87:	e9 30 01 00 00       	jmp    f0100bbc <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a8c:	39 ca                	cmp    %ecx,%edx
f0100a8e:	73 19                	jae    f0100aa9 <check_page_free_list+0x12b>
f0100a90:	68 9a 42 10 f0       	push   $0xf010429a
f0100a95:	68 a6 42 10 f0       	push   $0xf01042a6
f0100a9a:	68 2e 02 00 00       	push   $0x22e
f0100a9f:	68 80 42 10 f0       	push   $0xf0104280
f0100aa4:	e8 e2 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100aa9:	39 fa                	cmp    %edi,%edx
f0100aab:	72 19                	jb     f0100ac6 <check_page_free_list+0x148>
f0100aad:	68 bb 42 10 f0       	push   $0xf01042bb
f0100ab2:	68 a6 42 10 f0       	push   $0xf01042a6
f0100ab7:	68 2f 02 00 00       	push   $0x22f
f0100abc:	68 80 42 10 f0       	push   $0xf0104280
f0100ac1:	e8 c5 f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ac6:	89 d0                	mov    %edx,%eax
f0100ac8:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100acb:	a8 07                	test   $0x7,%al
f0100acd:	74 19                	je     f0100ae8 <check_page_free_list+0x16a>
f0100acf:	68 4c 3b 10 f0       	push   $0xf0103b4c
f0100ad4:	68 a6 42 10 f0       	push   $0xf01042a6
f0100ad9:	68 30 02 00 00       	push   $0x230
f0100ade:	68 80 42 10 f0       	push   $0xf0104280
f0100ae3:	e8 a3 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ae8:	c1 f8 03             	sar    $0x3,%eax
f0100aeb:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100aee:	85 c0                	test   %eax,%eax
f0100af0:	75 19                	jne    f0100b0b <check_page_free_list+0x18d>
f0100af2:	68 cf 42 10 f0       	push   $0xf01042cf
f0100af7:	68 a6 42 10 f0       	push   $0xf01042a6
f0100afc:	68 33 02 00 00       	push   $0x233
f0100b01:	68 80 42 10 f0       	push   $0xf0104280
f0100b06:	e8 80 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b0b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b10:	75 19                	jne    f0100b2b <check_page_free_list+0x1ad>
f0100b12:	68 e0 42 10 f0       	push   $0xf01042e0
f0100b17:	68 a6 42 10 f0       	push   $0xf01042a6
f0100b1c:	68 34 02 00 00       	push   $0x234
f0100b21:	68 80 42 10 f0       	push   $0xf0104280
f0100b26:	e8 60 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b2b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b30:	75 19                	jne    f0100b4b <check_page_free_list+0x1cd>
f0100b32:	68 80 3b 10 f0       	push   $0xf0103b80
f0100b37:	68 a6 42 10 f0       	push   $0xf01042a6
f0100b3c:	68 35 02 00 00       	push   $0x235
f0100b41:	68 80 42 10 f0       	push   $0xf0104280
f0100b46:	e8 40 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b4b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b50:	75 19                	jne    f0100b6b <check_page_free_list+0x1ed>
f0100b52:	68 f9 42 10 f0       	push   $0xf01042f9
f0100b57:	68 a6 42 10 f0       	push   $0xf01042a6
f0100b5c:	68 36 02 00 00       	push   $0x236
f0100b61:	68 80 42 10 f0       	push   $0xf0104280
f0100b66:	e8 20 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b6b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100b70:	76 3f                	jbe    f0100bb1 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b72:	89 c3                	mov    %eax,%ebx
f0100b74:	c1 eb 0c             	shr    $0xc,%ebx
f0100b77:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100b7a:	77 12                	ja     f0100b8e <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b7c:	50                   	push   %eax
f0100b7d:	68 04 3b 10 f0       	push   $0xf0103b04
f0100b82:	6a 52                	push   $0x52
f0100b84:	68 8c 42 10 f0       	push   $0xf010428c
f0100b89:	e8 fd f4 ff ff       	call   f010008b <_panic>
f0100b8e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b93:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100b96:	76 1e                	jbe    f0100bb6 <check_page_free_list+0x238>
f0100b98:	68 a4 3b 10 f0       	push   $0xf0103ba4
f0100b9d:	68 a6 42 10 f0       	push   $0xf01042a6
f0100ba2:	68 37 02 00 00       	push   $0x237
f0100ba7:	68 80 42 10 f0       	push   $0xf0104280
f0100bac:	e8 da f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100bb1:	83 c6 01             	add    $0x1,%esi
f0100bb4:	eb 04                	jmp    f0100bba <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100bb6:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bba:	8b 12                	mov    (%edx),%edx
f0100bbc:	85 d2                	test   %edx,%edx
f0100bbe:	0f 85 c8 fe ff ff    	jne    f0100a8c <check_page_free_list+0x10e>
f0100bc4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100bc7:	85 f6                	test   %esi,%esi
f0100bc9:	7f 19                	jg     f0100be4 <check_page_free_list+0x266>
f0100bcb:	68 13 43 10 f0       	push   $0xf0104313
f0100bd0:	68 a6 42 10 f0       	push   $0xf01042a6
f0100bd5:	68 3f 02 00 00       	push   $0x23f
f0100bda:	68 80 42 10 f0       	push   $0xf0104280
f0100bdf:	e8 a7 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100be4:	85 db                	test   %ebx,%ebx
f0100be6:	7f 42                	jg     f0100c2a <check_page_free_list+0x2ac>
f0100be8:	68 25 43 10 f0       	push   $0xf0104325
f0100bed:	68 a6 42 10 f0       	push   $0xf01042a6
f0100bf2:	68 40 02 00 00       	push   $0x240
f0100bf7:	68 80 42 10 f0       	push   $0xf0104280
f0100bfc:	e8 8a f4 ff ff       	call   f010008b <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c01:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0100c06:	85 c0                	test   %eax,%eax
f0100c08:	0f 85 9d fd ff ff    	jne    f01009ab <check_page_free_list+0x2d>
f0100c0e:	e9 81 fd ff ff       	jmp    f0100994 <check_page_free_list+0x16>
f0100c13:	83 3d 3c 65 11 f0 00 	cmpl   $0x0,0xf011653c
f0100c1a:	0f 84 74 fd ff ff    	je     f0100994 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c20:	be 00 04 00 00       	mov    $0x400,%esi
f0100c25:	e9 cf fd ff ff       	jmp    f01009f9 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c2d:	5b                   	pop    %ebx
f0100c2e:	5e                   	pop    %esi
f0100c2f:	5f                   	pop    %edi
f0100c30:	5d                   	pop    %ebp
f0100c31:	c3                   	ret    

f0100c32 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c32:	55                   	push   %ebp
f0100c33:	89 e5                	mov    %esp,%ebp
f0100c35:	56                   	push   %esi
f0100c36:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    size_t i;
    for (i = 1; i < npages_basemem; i++) {
f0100c37:	8b 35 40 65 11 f0    	mov    0xf0116540,%esi
f0100c3d:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100c43:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c48:	b8 01 00 00 00       	mov    $0x1,%eax
f0100c4d:	eb 27                	jmp    f0100c76 <page_init+0x44>
        pages[i].pp_ref = 0;
f0100c4f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100c56:	89 d1                	mov    %edx,%ecx
f0100c58:	03 0d 6c 69 11 f0    	add    0xf011696c,%ecx
f0100c5e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100c64:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    size_t i;
    for (i = 1; i < npages_basemem; i++) {
f0100c66:	83 c0 01             	add    $0x1,%eax
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
f0100c69:	89 d3                	mov    %edx,%ebx
f0100c6b:	03 1d 6c 69 11 f0    	add    0xf011696c,%ebx
f0100c71:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    size_t i;
    for (i = 1; i < npages_basemem; i++) {
f0100c76:	39 f0                	cmp    %esi,%eax
f0100c78:	72 d5                	jb     f0100c4f <page_init+0x1d>
f0100c7a:	84 d2                	test   %dl,%dl
f0100c7c:	74 06                	je     f0100c84 <page_init+0x52>
f0100c7e:	89 1d 3c 65 11 f0    	mov    %ebx,0xf011653c
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }

    char *nextfree = boot_alloc(0);
f0100c84:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c89:	e8 50 fc ff ff       	call   f01008de <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c8e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100c93:	77 15                	ja     f0100caa <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c95:	50                   	push   %eax
f0100c96:	68 ec 3b 10 f0       	push   $0xf0103bec
f0100c9b:	68 09 01 00 00       	push   $0x109
f0100ca0:	68 80 42 10 f0       	push   $0xf0104280
f0100ca5:	e8 e1 f3 ff ff       	call   f010008b <_panic>
    size_t kern_end_page = PGNUM(PADDR(nextfree));
f0100caa:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0100cb0:	c1 eb 0c             	shr    $0xc,%ebx
    cprintf("kern end pages:%d\n", kern_end_page);
f0100cb3:	83 ec 08             	sub    $0x8,%esp
f0100cb6:	53                   	push   %ebx
f0100cb7:	68 36 43 10 f0       	push   $0xf0104336
f0100cbc:	e8 eb 19 00 00       	call   f01026ac <cprintf>
f0100cc1:	8b 0d 3c 65 11 f0    	mov    0xf011653c,%ecx
f0100cc7:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax

    for (i = kern_end_page; i < npages; i++) {
f0100cce:	83 c4 10             	add    $0x10,%esp
f0100cd1:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cd6:	eb 23                	jmp    f0100cfb <page_init+0xc9>
        pages[i].pp_ref = 0;
f0100cd8:	89 c2                	mov    %eax,%edx
f0100cda:	03 15 6c 69 11 f0    	add    0xf011696c,%edx
f0100ce0:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0100ce6:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f0100ce8:	89 c1                	mov    %eax,%ecx
f0100cea:	03 0d 6c 69 11 f0    	add    0xf011696c,%ecx

    char *nextfree = boot_alloc(0);
    size_t kern_end_page = PGNUM(PADDR(nextfree));
    cprintf("kern end pages:%d\n", kern_end_page);

    for (i = kern_end_page; i < npages; i++) {
f0100cf0:	83 c3 01             	add    $0x1,%ebx
f0100cf3:	83 c0 08             	add    $0x8,%eax
f0100cf6:	ba 01 00 00 00       	mov    $0x1,%edx
f0100cfb:	3b 1d 64 69 11 f0    	cmp    0xf0116964,%ebx
f0100d01:	72 d5                	jb     f0100cd8 <page_init+0xa6>
f0100d03:	84 d2                	test   %dl,%dl
f0100d05:	74 06                	je     f0100d0d <page_init+0xdb>
f0100d07:	89 0d 3c 65 11 f0    	mov    %ecx,0xf011653c
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
}
f0100d0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d10:	5b                   	pop    %ebx
f0100d11:	5e                   	pop    %esi
f0100d12:	5d                   	pop    %ebp
f0100d13:	c3                   	ret    

f0100d14 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d14:	55                   	push   %ebp
f0100d15:	89 e5                	mov    %esp,%ebp
f0100d17:	53                   	push   %ebx
f0100d18:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list)
f0100d1b:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100d21:	85 db                	test   %ebx,%ebx
f0100d23:	74 52                	je     f0100d77 <page_alloc+0x63>
	{
		struct PageInfo* pp = page_free_list;
		page_free_list = page_free_list -> pp_link;
f0100d25:	8b 03                	mov    (%ebx),%eax
f0100d27:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
		if(alloc_flags & ALLOC_ZERO)
f0100d2c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d30:	74 45                	je     f0100d77 <page_alloc+0x63>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d32:	89 d8                	mov    %ebx,%eax
f0100d34:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100d3a:	c1 f8 03             	sar    $0x3,%eax
f0100d3d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d40:	89 c2                	mov    %eax,%edx
f0100d42:	c1 ea 0c             	shr    $0xc,%edx
f0100d45:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100d4b:	72 12                	jb     f0100d5f <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d4d:	50                   	push   %eax
f0100d4e:	68 04 3b 10 f0       	push   $0xf0103b04
f0100d53:	6a 52                	push   $0x52
f0100d55:	68 8c 42 10 f0       	push   $0xf010428c
f0100d5a:	e8 2c f3 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp),0,PGSIZE);
f0100d5f:	83 ec 04             	sub    $0x4,%esp
f0100d62:	68 00 10 00 00       	push   $0x1000
f0100d67:	6a 00                	push   $0x0
f0100d69:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d6e:	50                   	push   %eax
f0100d6f:	e8 10 24 00 00       	call   f0103184 <memset>
f0100d74:	83 c4 10             	add    $0x10,%esp
		return pp;
	}
		
	return NULL;
}
f0100d77:	89 d8                	mov    %ebx,%eax
f0100d79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d7c:	c9                   	leave  
f0100d7d:	c3                   	ret    

f0100d7e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100d7e:	55                   	push   %ebp
f0100d7f:	89 e5                	mov    %esp,%ebp
f0100d81:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//assert(pp->pp_ref==0 && pp->pp_link == NULL);
	pp->pp_link = page_free_list;
f0100d84:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100d8a:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100d8c:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
}
f0100d91:	5d                   	pop    %ebp
f0100d92:	c3                   	ret    

f0100d93 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100d93:	55                   	push   %ebp
f0100d94:	89 e5                	mov    %esp,%ebp
f0100d96:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100d99:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100d9d:	83 e8 01             	sub    $0x1,%eax
f0100da0:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100da4:	66 85 c0             	test   %ax,%ax
f0100da7:	75 09                	jne    f0100db2 <page_decref+0x1f>
		page_free(pp);
f0100da9:	52                   	push   %edx
f0100daa:	e8 cf ff ff ff       	call   f0100d7e <page_free>
f0100daf:	83 c4 04             	add    $0x4,%esp
}
f0100db2:	c9                   	leave  
f0100db3:	c3                   	ret    

f0100db4 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100db4:	55                   	push   %ebp
f0100db5:	89 e5                	mov    %esp,%ebp
f0100db7:	56                   	push   %esi
f0100db8:	53                   	push   %ebx
f0100db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	int pde_index = PDX(va);
    int pte_index = PTX(va);
f0100dbc:	89 de                	mov    %ebx,%esi
f0100dbe:	c1 ee 0c             	shr    $0xc,%esi
f0100dc1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    pde_t *pde = &pgdir[pde_index];
f0100dc7:	c1 eb 16             	shr    $0x16,%ebx
f0100dca:	c1 e3 02             	shl    $0x2,%ebx
f0100dcd:	03 5d 08             	add    0x8(%ebp),%ebx
    if (!(*pde & PTE_P)) {
f0100dd0:	f6 03 01             	testb  $0x1,(%ebx)
f0100dd3:	75 2d                	jne    f0100e02 <pgdir_walk+0x4e>
        if (create) {
f0100dd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100dd9:	74 59                	je     f0100e34 <pgdir_walk+0x80>
            struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0100ddb:	83 ec 0c             	sub    $0xc,%esp
f0100dde:	6a 01                	push   $0x1
f0100de0:	e8 2f ff ff ff       	call   f0100d14 <page_alloc>
            if (!page) return NULL;
f0100de5:	83 c4 10             	add    $0x10,%esp
f0100de8:	85 c0                	test   %eax,%eax
f0100dea:	74 4f                	je     f0100e3b <pgdir_walk+0x87>

            page->pp_ref++;
f0100dec:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
            *pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0100df1:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100df7:	c1 f8 03             	sar    $0x3,%eax
f0100dfa:	c1 e0 0c             	shl    $0xc,%eax
f0100dfd:	83 c8 07             	or     $0x7,%eax
f0100e00:	89 03                	mov    %eax,(%ebx)
        } else {
            return NULL;
        }   
    }   

    pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
f0100e02:	8b 03                	mov    (%ebx),%eax
f0100e04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e09:	89 c2                	mov    %eax,%edx
f0100e0b:	c1 ea 0c             	shr    $0xc,%edx
f0100e0e:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100e14:	72 15                	jb     f0100e2b <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e16:	50                   	push   %eax
f0100e17:	68 04 3b 10 f0       	push   $0xf0103b04
f0100e1c:	68 72 01 00 00       	push   $0x172
f0100e21:	68 80 42 10 f0       	push   $0xf0104280
f0100e26:	e8 60 f2 ff ff       	call   f010008b <_panic>
    return &p[pte_index];
f0100e2b:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100e32:	eb 0c                	jmp    f0100e40 <pgdir_walk+0x8c>
            if (!page) return NULL;

            page->pp_ref++;
            *pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
        } else {
            return NULL;
f0100e34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e39:	eb 05                	jmp    f0100e40 <pgdir_walk+0x8c>
    int pte_index = PTX(va);
    pde_t *pde = &pgdir[pde_index];
    if (!(*pde & PTE_P)) {
        if (create) {
            struct PageInfo *page = page_alloc(ALLOC_ZERO);
            if (!page) return NULL;
f0100e3b:	b8 00 00 00 00       	mov    $0x0,%eax
        }   
    }   

    pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
    return &p[pte_index];
}
f0100e40:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e43:	5b                   	pop    %ebx
f0100e44:	5e                   	pop    %esi
f0100e45:	5d                   	pop    %ebp
f0100e46:	c3                   	ret    

f0100e47 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100e47:	55                   	push   %ebp
f0100e48:	89 e5                	mov    %esp,%ebp
f0100e4a:	57                   	push   %edi
f0100e4b:	56                   	push   %esi
f0100e4c:	53                   	push   %ebx
f0100e4d:	83 ec 1c             	sub    $0x1c,%esp
f0100e50:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e53:	8b 45 08             	mov    0x8(%ebp),%eax
	int pages = PGNUM(size);
f0100e56:	c1 e9 0c             	shr    $0xc,%ecx
f0100e59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    int i;
	for (i = 0; i < pages; i++) {
f0100e5c:	89 c3                	mov    %eax,%ebx
f0100e5e:	be 00 00 00 00       	mov    $0x0,%esi
        pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0100e63:	89 d7                	mov    %edx,%edi
f0100e65:	29 c7                	sub    %eax,%edi
        if (!pte) {
            panic("boot_map_region panic: out of memory");
        }
        *pte = pa | perm | PTE_P;
f0100e67:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e6a:	83 c8 01             	or     $0x1,%eax
f0100e6d:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pages = PGNUM(size);
    int i;
	for (i = 0; i < pages; i++) {
f0100e70:	eb 3f                	jmp    f0100eb1 <boot_map_region+0x6a>
        pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0100e72:	83 ec 04             	sub    $0x4,%esp
f0100e75:	6a 01                	push   $0x1
f0100e77:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0100e7a:	50                   	push   %eax
f0100e7b:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e7e:	e8 31 ff ff ff       	call   f0100db4 <pgdir_walk>
        if (!pte) {
f0100e83:	83 c4 10             	add    $0x10,%esp
f0100e86:	85 c0                	test   %eax,%eax
f0100e88:	75 17                	jne    f0100ea1 <boot_map_region+0x5a>
            panic("boot_map_region panic: out of memory");
f0100e8a:	83 ec 04             	sub    $0x4,%esp
f0100e8d:	68 10 3c 10 f0       	push   $0xf0103c10
f0100e92:	68 89 01 00 00       	push   $0x189
f0100e97:	68 80 42 10 f0       	push   $0xf0104280
f0100e9c:	e8 ea f1 ff ff       	call   f010008b <_panic>
        }
        *pte = pa | perm | PTE_P;
f0100ea1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ea4:	09 da                	or     %ebx,%edx
f0100ea6:	89 10                	mov    %edx,(%eax)
        va += PGSIZE, pa += PGSIZE;
f0100ea8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pages = PGNUM(size);
    int i;
	for (i = 0; i < pages; i++) {
f0100eae:	83 c6 01             	add    $0x1,%esi
f0100eb1:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100eb4:	7c bc                	jl     f0100e72 <boot_map_region+0x2b>
        }
        *pte = pa | perm | PTE_P;
        va += PGSIZE, pa += PGSIZE;
    }
	// Fill this function in
}
f0100eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb9:	5b                   	pop    %ebx
f0100eba:	5e                   	pop    %esi
f0100ebb:	5f                   	pop    %edi
f0100ebc:	5d                   	pop    %ebp
f0100ebd:	c3                   	ret    

f0100ebe <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ebe:	55                   	push   %ebp
f0100ebf:	89 e5                	mov    %esp,%ebp
f0100ec1:	53                   	push   %ebx
f0100ec2:	83 ec 08             	sub    $0x8,%esp
f0100ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100ec8:	6a 00                	push   $0x0
f0100eca:	ff 75 0c             	pushl  0xc(%ebp)
f0100ecd:	ff 75 08             	pushl  0x8(%ebp)
f0100ed0:	e8 df fe ff ff       	call   f0100db4 <pgdir_walk>
    if (!pte || !(*pte & PTE_P)) {
f0100ed5:	83 c4 10             	add    $0x10,%esp
f0100ed8:	85 c0                	test   %eax,%eax
f0100eda:	74 37                	je     f0100f13 <page_lookup+0x55>
f0100edc:	f6 00 01             	testb  $0x1,(%eax)
f0100edf:	74 39                	je     f0100f1a <page_lookup+0x5c>
        return NULL;
    }

    if (pte_store) {
f0100ee1:	85 db                	test   %ebx,%ebx
f0100ee3:	74 02                	je     f0100ee7 <page_lookup+0x29>
        *pte_store = pte;
f0100ee5:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ee7:	8b 00                	mov    (%eax),%eax
f0100ee9:	c1 e8 0c             	shr    $0xc,%eax
f0100eec:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0100ef2:	72 14                	jb     f0100f08 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100ef4:	83 ec 04             	sub    $0x4,%esp
f0100ef7:	68 38 3c 10 f0       	push   $0xf0103c38
f0100efc:	6a 4b                	push   $0x4b
f0100efe:	68 8c 42 10 f0       	push   $0xf010428c
f0100f03:	e8 83 f1 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100f08:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
f0100f0e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
    }

    return pa2page(PTE_ADDR(*pte));
f0100f11:	eb 0c                	jmp    f0100f1f <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
    if (!pte || !(*pte & PTE_P)) {
        return NULL;
f0100f13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f18:	eb 05                	jmp    f0100f1f <page_lookup+0x61>
f0100f1a:	b8 00 00 00 00       	mov    $0x0,%eax
        *pte_store = pte;
    }

    return pa2page(PTE_ADDR(*pte));
	
}
f0100f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f22:	c9                   	leave  
f0100f23:	c3                   	ret    

f0100f24 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f24:	55                   	push   %ebp
f0100f25:	89 e5                	mov    %esp,%ebp
f0100f27:	53                   	push   %ebx
f0100f28:	83 ec 18             	sub    $0x18,%esp
f0100f2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
    struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0100f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f31:	50                   	push   %eax
f0100f32:	53                   	push   %ebx
f0100f33:	ff 75 08             	pushl  0x8(%ebp)
f0100f36:	e8 83 ff ff ff       	call   f0100ebe <page_lookup>
    if (!page || !(*pte & PTE_P)) {
f0100f3b:	83 c4 10             	add    $0x10,%esp
f0100f3e:	85 c0                	test   %eax,%eax
f0100f40:	74 1d                	je     f0100f5f <page_remove+0x3b>
f0100f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100f45:	f6 02 01             	testb  $0x1,(%edx)
f0100f48:	74 15                	je     f0100f5f <page_remove+0x3b>
        return;
    }
    *pte = 0;
f0100f4a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    page_decref(page);
f0100f50:	83 ec 0c             	sub    $0xc,%esp
f0100f53:	50                   	push   %eax
f0100f54:	e8 3a fe ff ff       	call   f0100d93 <page_decref>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f59:	0f 01 3b             	invlpg (%ebx)
f0100f5c:	83 c4 10             	add    $0x10,%esp
    tlb_invalidate(pgdir, va);
		
	// Fill this function in
	
}
f0100f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f62:	c9                   	leave  
f0100f63:	c3                   	ret    

f0100f64 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f64:	55                   	push   %ebp
f0100f65:	89 e5                	mov    %esp,%ebp
f0100f67:	57                   	push   %edi
f0100f68:	56                   	push   %esi
f0100f69:	53                   	push   %ebx
f0100f6a:	83 ec 10             	sub    $0x10,%esp
f0100f6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f70:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100f73:	6a 01                	push   $0x1
f0100f75:	57                   	push   %edi
f0100f76:	ff 75 08             	pushl  0x8(%ebp)
f0100f79:	e8 36 fe ff ff       	call   f0100db4 <pgdir_walk>
    if (!pte) {
f0100f7e:	83 c4 10             	add    $0x10,%esp
f0100f81:	85 c0                	test   %eax,%eax
f0100f83:	74 38                	je     f0100fbd <page_insert+0x59>
f0100f85:	89 c6                	mov    %eax,%esi
        return -E_NO_MEM;
    }

    pp->pp_ref++;
f0100f87:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    if (*pte & PTE_P) {
f0100f8c:	f6 00 01             	testb  $0x1,(%eax)
f0100f8f:	74 0f                	je     f0100fa0 <page_insert+0x3c>
        page_remove(pgdir, va);
f0100f91:	83 ec 08             	sub    $0x8,%esp
f0100f94:	57                   	push   %edi
f0100f95:	ff 75 08             	pushl  0x8(%ebp)
f0100f98:	e8 87 ff ff ff       	call   f0100f24 <page_remove>
f0100f9d:	83 c4 10             	add    $0x10,%esp
    }

    *pte = page2pa(pp) | perm | PTE_P;
f0100fa0:	2b 1d 6c 69 11 f0    	sub    0xf011696c,%ebx
f0100fa6:	c1 fb 03             	sar    $0x3,%ebx
f0100fa9:	c1 e3 0c             	shl    $0xc,%ebx
f0100fac:	8b 45 14             	mov    0x14(%ebp),%eax
f0100faf:	83 c8 01             	or     $0x1,%eax
f0100fb2:	09 c3                	or     %eax,%ebx
f0100fb4:	89 1e                	mov    %ebx,(%esi)
    return 0;
f0100fb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fbb:	eb 05                	jmp    f0100fc2 <page_insert+0x5e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (!pte) {
        return -E_NO_MEM;
f0100fbd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir, va);
    }

    *pte = page2pa(pp) | perm | PTE_P;
    return 0;
}
f0100fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fc5:	5b                   	pop    %ebx
f0100fc6:	5e                   	pop    %esi
f0100fc7:	5f                   	pop    %edi
f0100fc8:	5d                   	pop    %ebp
f0100fc9:	c3                   	ret    

f0100fca <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100fca:	55                   	push   %ebp
f0100fcb:	89 e5                	mov    %esp,%ebp
f0100fcd:	57                   	push   %edi
f0100fce:	56                   	push   %esi
f0100fcf:	53                   	push   %ebx
f0100fd0:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100fd3:	6a 15                	push   $0x15
f0100fd5:	e8 6b 16 00 00       	call   f0102645 <mc146818_read>
f0100fda:	89 c3                	mov    %eax,%ebx
f0100fdc:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100fe3:	e8 5d 16 00 00       	call   f0102645 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100fe8:	c1 e0 08             	shl    $0x8,%eax
f0100feb:	09 d8                	or     %ebx,%eax
f0100fed:	c1 e0 0a             	shl    $0xa,%eax
f0100ff0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100ff6:	85 c0                	test   %eax,%eax
f0100ff8:	0f 48 c2             	cmovs  %edx,%eax
f0100ffb:	c1 f8 0c             	sar    $0xc,%eax
f0100ffe:	a3 40 65 11 f0       	mov    %eax,0xf0116540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101003:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010100a:	e8 36 16 00 00       	call   f0102645 <mc146818_read>
f010100f:	89 c3                	mov    %eax,%ebx
f0101011:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101018:	e8 28 16 00 00       	call   f0102645 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010101d:	c1 e0 08             	shl    $0x8,%eax
f0101020:	09 d8                	or     %ebx,%eax
f0101022:	c1 e0 0a             	shl    $0xa,%eax
f0101025:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010102b:	83 c4 10             	add    $0x10,%esp
f010102e:	85 c0                	test   %eax,%eax
f0101030:	0f 48 c2             	cmovs  %edx,%eax
f0101033:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101036:	85 c0                	test   %eax,%eax
f0101038:	74 0e                	je     f0101048 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010103a:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101040:	89 15 64 69 11 f0    	mov    %edx,0xf0116964
f0101046:	eb 0c                	jmp    f0101054 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101048:	8b 15 40 65 11 f0    	mov    0xf0116540,%edx
f010104e:	89 15 64 69 11 f0    	mov    %edx,0xf0116964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101054:	c1 e0 0c             	shl    $0xc,%eax
f0101057:	c1 e8 0a             	shr    $0xa,%eax
f010105a:	50                   	push   %eax
f010105b:	a1 40 65 11 f0       	mov    0xf0116540,%eax
f0101060:	c1 e0 0c             	shl    $0xc,%eax
f0101063:	c1 e8 0a             	shr    $0xa,%eax
f0101066:	50                   	push   %eax
f0101067:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f010106c:	c1 e0 0c             	shl    $0xc,%eax
f010106f:	c1 e8 0a             	shr    $0xa,%eax
f0101072:	50                   	push   %eax
f0101073:	68 58 3c 10 f0       	push   $0xf0103c58
f0101078:	e8 2f 16 00 00       	call   f01026ac <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010107d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101082:	e8 57 f8 ff ff       	call   f01008de <boot_alloc>
f0101087:	a3 68 69 11 f0       	mov    %eax,0xf0116968
	memset(kern_pgdir, 0, PGSIZE);
f010108c:	83 c4 0c             	add    $0xc,%esp
f010108f:	68 00 10 00 00       	push   $0x1000
f0101094:	6a 00                	push   $0x0
f0101096:	50                   	push   %eax
f0101097:	e8 e8 20 00 00       	call   f0103184 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010109c:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010a1:	83 c4 10             	add    $0x10,%esp
f01010a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010a9:	77 15                	ja     f01010c0 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010ab:	50                   	push   %eax
f01010ac:	68 ec 3b 10 f0       	push   $0xf0103bec
f01010b1:	68 8f 00 00 00       	push   $0x8f
f01010b6:	68 80 42 10 f0       	push   $0xf0104280
f01010bb:	e8 cb ef ff ff       	call   f010008b <_panic>
f01010c0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010c6:	83 ca 05             	or     $0x5,%edx
f01010c9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f01010cf:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f01010d4:	c1 e0 03             	shl    $0x3,%eax
f01010d7:	e8 02 f8 ff ff       	call   f01008de <boot_alloc>
f01010dc:	a3 6c 69 11 f0       	mov    %eax,0xf011696c
	memset(pages,0,sizeof(struct PageInfo) * npages);
f01010e1:	83 ec 04             	sub    $0x4,%esp
f01010e4:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f01010ea:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01010f1:	52                   	push   %edx
f01010f2:	6a 00                	push   $0x0
f01010f4:	50                   	push   %eax
f01010f5:	e8 8a 20 00 00       	call   f0103184 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01010fa:	e8 33 fb ff ff       	call   f0100c32 <page_init>

	check_page_free_list(1);
f01010ff:	b8 01 00 00 00       	mov    $0x1,%eax
f0101104:	e8 75 f8 ff ff       	call   f010097e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101109:	83 c4 10             	add    $0x10,%esp
f010110c:	83 3d 6c 69 11 f0 00 	cmpl   $0x0,0xf011696c
f0101113:	75 17                	jne    f010112c <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0101115:	83 ec 04             	sub    $0x4,%esp
f0101118:	68 49 43 10 f0       	push   $0xf0104349
f010111d:	68 51 02 00 00       	push   $0x251
f0101122:	68 80 42 10 f0       	push   $0xf0104280
f0101127:	e8 5f ef ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010112c:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101131:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101136:	eb 05                	jmp    f010113d <mem_init+0x173>
		++nfree;
f0101138:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010113b:	8b 00                	mov    (%eax),%eax
f010113d:	85 c0                	test   %eax,%eax
f010113f:	75 f7                	jne    f0101138 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101141:	83 ec 0c             	sub    $0xc,%esp
f0101144:	6a 00                	push   $0x0
f0101146:	e8 c9 fb ff ff       	call   f0100d14 <page_alloc>
f010114b:	89 c7                	mov    %eax,%edi
f010114d:	83 c4 10             	add    $0x10,%esp
f0101150:	85 c0                	test   %eax,%eax
f0101152:	75 19                	jne    f010116d <mem_init+0x1a3>
f0101154:	68 64 43 10 f0       	push   $0xf0104364
f0101159:	68 a6 42 10 f0       	push   $0xf01042a6
f010115e:	68 59 02 00 00       	push   $0x259
f0101163:	68 80 42 10 f0       	push   $0xf0104280
f0101168:	e8 1e ef ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010116d:	83 ec 0c             	sub    $0xc,%esp
f0101170:	6a 00                	push   $0x0
f0101172:	e8 9d fb ff ff       	call   f0100d14 <page_alloc>
f0101177:	89 c6                	mov    %eax,%esi
f0101179:	83 c4 10             	add    $0x10,%esp
f010117c:	85 c0                	test   %eax,%eax
f010117e:	75 19                	jne    f0101199 <mem_init+0x1cf>
f0101180:	68 7a 43 10 f0       	push   $0xf010437a
f0101185:	68 a6 42 10 f0       	push   $0xf01042a6
f010118a:	68 5a 02 00 00       	push   $0x25a
f010118f:	68 80 42 10 f0       	push   $0xf0104280
f0101194:	e8 f2 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101199:	83 ec 0c             	sub    $0xc,%esp
f010119c:	6a 00                	push   $0x0
f010119e:	e8 71 fb ff ff       	call   f0100d14 <page_alloc>
f01011a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011a6:	83 c4 10             	add    $0x10,%esp
f01011a9:	85 c0                	test   %eax,%eax
f01011ab:	75 19                	jne    f01011c6 <mem_init+0x1fc>
f01011ad:	68 90 43 10 f0       	push   $0xf0104390
f01011b2:	68 a6 42 10 f0       	push   $0xf01042a6
f01011b7:	68 5b 02 00 00       	push   $0x25b
f01011bc:	68 80 42 10 f0       	push   $0xf0104280
f01011c1:	e8 c5 ee ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01011c6:	39 f7                	cmp    %esi,%edi
f01011c8:	75 19                	jne    f01011e3 <mem_init+0x219>
f01011ca:	68 a6 43 10 f0       	push   $0xf01043a6
f01011cf:	68 a6 42 10 f0       	push   $0xf01042a6
f01011d4:	68 5e 02 00 00       	push   $0x25e
f01011d9:	68 80 42 10 f0       	push   $0xf0104280
f01011de:	e8 a8 ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01011e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01011e6:	39 c6                	cmp    %eax,%esi
f01011e8:	74 04                	je     f01011ee <mem_init+0x224>
f01011ea:	39 c7                	cmp    %eax,%edi
f01011ec:	75 19                	jne    f0101207 <mem_init+0x23d>
f01011ee:	68 94 3c 10 f0       	push   $0xf0103c94
f01011f3:	68 a6 42 10 f0       	push   $0xf01042a6
f01011f8:	68 5f 02 00 00       	push   $0x25f
f01011fd:	68 80 42 10 f0       	push   $0xf0104280
f0101202:	e8 84 ee ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101207:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010120d:	8b 15 64 69 11 f0    	mov    0xf0116964,%edx
f0101213:	c1 e2 0c             	shl    $0xc,%edx
f0101216:	89 f8                	mov    %edi,%eax
f0101218:	29 c8                	sub    %ecx,%eax
f010121a:	c1 f8 03             	sar    $0x3,%eax
f010121d:	c1 e0 0c             	shl    $0xc,%eax
f0101220:	39 d0                	cmp    %edx,%eax
f0101222:	72 19                	jb     f010123d <mem_init+0x273>
f0101224:	68 b8 43 10 f0       	push   $0xf01043b8
f0101229:	68 a6 42 10 f0       	push   $0xf01042a6
f010122e:	68 60 02 00 00       	push   $0x260
f0101233:	68 80 42 10 f0       	push   $0xf0104280
f0101238:	e8 4e ee ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010123d:	89 f0                	mov    %esi,%eax
f010123f:	29 c8                	sub    %ecx,%eax
f0101241:	c1 f8 03             	sar    $0x3,%eax
f0101244:	c1 e0 0c             	shl    $0xc,%eax
f0101247:	39 c2                	cmp    %eax,%edx
f0101249:	77 19                	ja     f0101264 <mem_init+0x29a>
f010124b:	68 d5 43 10 f0       	push   $0xf01043d5
f0101250:	68 a6 42 10 f0       	push   $0xf01042a6
f0101255:	68 61 02 00 00       	push   $0x261
f010125a:	68 80 42 10 f0       	push   $0xf0104280
f010125f:	e8 27 ee ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101264:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101267:	29 c8                	sub    %ecx,%eax
f0101269:	c1 f8 03             	sar    $0x3,%eax
f010126c:	c1 e0 0c             	shl    $0xc,%eax
f010126f:	39 c2                	cmp    %eax,%edx
f0101271:	77 19                	ja     f010128c <mem_init+0x2c2>
f0101273:	68 f2 43 10 f0       	push   $0xf01043f2
f0101278:	68 a6 42 10 f0       	push   $0xf01042a6
f010127d:	68 62 02 00 00       	push   $0x262
f0101282:	68 80 42 10 f0       	push   $0xf0104280
f0101287:	e8 ff ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010128c:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101291:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101294:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f010129b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010129e:	83 ec 0c             	sub    $0xc,%esp
f01012a1:	6a 00                	push   $0x0
f01012a3:	e8 6c fa ff ff       	call   f0100d14 <page_alloc>
f01012a8:	83 c4 10             	add    $0x10,%esp
f01012ab:	85 c0                	test   %eax,%eax
f01012ad:	74 19                	je     f01012c8 <mem_init+0x2fe>
f01012af:	68 0f 44 10 f0       	push   $0xf010440f
f01012b4:	68 a6 42 10 f0       	push   $0xf01042a6
f01012b9:	68 69 02 00 00       	push   $0x269
f01012be:	68 80 42 10 f0       	push   $0xf0104280
f01012c3:	e8 c3 ed ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01012c8:	83 ec 0c             	sub    $0xc,%esp
f01012cb:	57                   	push   %edi
f01012cc:	e8 ad fa ff ff       	call   f0100d7e <page_free>
	page_free(pp1);
f01012d1:	89 34 24             	mov    %esi,(%esp)
f01012d4:	e8 a5 fa ff ff       	call   f0100d7e <page_free>
	page_free(pp2);
f01012d9:	83 c4 04             	add    $0x4,%esp
f01012dc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01012df:	e8 9a fa ff ff       	call   f0100d7e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012eb:	e8 24 fa ff ff       	call   f0100d14 <page_alloc>
f01012f0:	89 c6                	mov    %eax,%esi
f01012f2:	83 c4 10             	add    $0x10,%esp
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	75 19                	jne    f0101312 <mem_init+0x348>
f01012f9:	68 64 43 10 f0       	push   $0xf0104364
f01012fe:	68 a6 42 10 f0       	push   $0xf01042a6
f0101303:	68 70 02 00 00       	push   $0x270
f0101308:	68 80 42 10 f0       	push   $0xf0104280
f010130d:	e8 79 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101312:	83 ec 0c             	sub    $0xc,%esp
f0101315:	6a 00                	push   $0x0
f0101317:	e8 f8 f9 ff ff       	call   f0100d14 <page_alloc>
f010131c:	89 c7                	mov    %eax,%edi
f010131e:	83 c4 10             	add    $0x10,%esp
f0101321:	85 c0                	test   %eax,%eax
f0101323:	75 19                	jne    f010133e <mem_init+0x374>
f0101325:	68 7a 43 10 f0       	push   $0xf010437a
f010132a:	68 a6 42 10 f0       	push   $0xf01042a6
f010132f:	68 71 02 00 00       	push   $0x271
f0101334:	68 80 42 10 f0       	push   $0xf0104280
f0101339:	e8 4d ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010133e:	83 ec 0c             	sub    $0xc,%esp
f0101341:	6a 00                	push   $0x0
f0101343:	e8 cc f9 ff ff       	call   f0100d14 <page_alloc>
f0101348:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010134b:	83 c4 10             	add    $0x10,%esp
f010134e:	85 c0                	test   %eax,%eax
f0101350:	75 19                	jne    f010136b <mem_init+0x3a1>
f0101352:	68 90 43 10 f0       	push   $0xf0104390
f0101357:	68 a6 42 10 f0       	push   $0xf01042a6
f010135c:	68 72 02 00 00       	push   $0x272
f0101361:	68 80 42 10 f0       	push   $0xf0104280
f0101366:	e8 20 ed ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010136b:	39 fe                	cmp    %edi,%esi
f010136d:	75 19                	jne    f0101388 <mem_init+0x3be>
f010136f:	68 a6 43 10 f0       	push   $0xf01043a6
f0101374:	68 a6 42 10 f0       	push   $0xf01042a6
f0101379:	68 74 02 00 00       	push   $0x274
f010137e:	68 80 42 10 f0       	push   $0xf0104280
f0101383:	e8 03 ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010138b:	39 c7                	cmp    %eax,%edi
f010138d:	74 04                	je     f0101393 <mem_init+0x3c9>
f010138f:	39 c6                	cmp    %eax,%esi
f0101391:	75 19                	jne    f01013ac <mem_init+0x3e2>
f0101393:	68 94 3c 10 f0       	push   $0xf0103c94
f0101398:	68 a6 42 10 f0       	push   $0xf01042a6
f010139d:	68 75 02 00 00       	push   $0x275
f01013a2:	68 80 42 10 f0       	push   $0xf0104280
f01013a7:	e8 df ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f01013ac:	83 ec 0c             	sub    $0xc,%esp
f01013af:	6a 00                	push   $0x0
f01013b1:	e8 5e f9 ff ff       	call   f0100d14 <page_alloc>
f01013b6:	83 c4 10             	add    $0x10,%esp
f01013b9:	85 c0                	test   %eax,%eax
f01013bb:	74 19                	je     f01013d6 <mem_init+0x40c>
f01013bd:	68 0f 44 10 f0       	push   $0xf010440f
f01013c2:	68 a6 42 10 f0       	push   $0xf01042a6
f01013c7:	68 76 02 00 00       	push   $0x276
f01013cc:	68 80 42 10 f0       	push   $0xf0104280
f01013d1:	e8 b5 ec ff ff       	call   f010008b <_panic>
f01013d6:	89 f0                	mov    %esi,%eax
f01013d8:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01013de:	c1 f8 03             	sar    $0x3,%eax
f01013e1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013e4:	89 c2                	mov    %eax,%edx
f01013e6:	c1 ea 0c             	shr    $0xc,%edx
f01013e9:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01013ef:	72 12                	jb     f0101403 <mem_init+0x439>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013f1:	50                   	push   %eax
f01013f2:	68 04 3b 10 f0       	push   $0xf0103b04
f01013f7:	6a 52                	push   $0x52
f01013f9:	68 8c 42 10 f0       	push   $0xf010428c
f01013fe:	e8 88 ec ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101403:	83 ec 04             	sub    $0x4,%esp
f0101406:	68 00 10 00 00       	push   $0x1000
f010140b:	6a 01                	push   $0x1
f010140d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101412:	50                   	push   %eax
f0101413:	e8 6c 1d 00 00       	call   f0103184 <memset>
	page_free(pp0);
f0101418:	89 34 24             	mov    %esi,(%esp)
f010141b:	e8 5e f9 ff ff       	call   f0100d7e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101420:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101427:	e8 e8 f8 ff ff       	call   f0100d14 <page_alloc>
f010142c:	83 c4 10             	add    $0x10,%esp
f010142f:	85 c0                	test   %eax,%eax
f0101431:	75 19                	jne    f010144c <mem_init+0x482>
f0101433:	68 1e 44 10 f0       	push   $0xf010441e
f0101438:	68 a6 42 10 f0       	push   $0xf01042a6
f010143d:	68 7b 02 00 00       	push   $0x27b
f0101442:	68 80 42 10 f0       	push   $0xf0104280
f0101447:	e8 3f ec ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f010144c:	39 c6                	cmp    %eax,%esi
f010144e:	74 19                	je     f0101469 <mem_init+0x49f>
f0101450:	68 3c 44 10 f0       	push   $0xf010443c
f0101455:	68 a6 42 10 f0       	push   $0xf01042a6
f010145a:	68 7c 02 00 00       	push   $0x27c
f010145f:	68 80 42 10 f0       	push   $0xf0104280
f0101464:	e8 22 ec ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101469:	89 f0                	mov    %esi,%eax
f010146b:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101471:	c1 f8 03             	sar    $0x3,%eax
f0101474:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101477:	89 c2                	mov    %eax,%edx
f0101479:	c1 ea 0c             	shr    $0xc,%edx
f010147c:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0101482:	72 12                	jb     f0101496 <mem_init+0x4cc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101484:	50                   	push   %eax
f0101485:	68 04 3b 10 f0       	push   $0xf0103b04
f010148a:	6a 52                	push   $0x52
f010148c:	68 8c 42 10 f0       	push   $0xf010428c
f0101491:	e8 f5 eb ff ff       	call   f010008b <_panic>
f0101496:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010149c:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014a2:	80 38 00             	cmpb   $0x0,(%eax)
f01014a5:	74 19                	je     f01014c0 <mem_init+0x4f6>
f01014a7:	68 4c 44 10 f0       	push   $0xf010444c
f01014ac:	68 a6 42 10 f0       	push   $0xf01042a6
f01014b1:	68 7f 02 00 00       	push   $0x27f
f01014b6:	68 80 42 10 f0       	push   $0xf0104280
f01014bb:	e8 cb eb ff ff       	call   f010008b <_panic>
f01014c0:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01014c3:	39 d0                	cmp    %edx,%eax
f01014c5:	75 db                	jne    f01014a2 <mem_init+0x4d8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01014c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014ca:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f01014cf:	83 ec 0c             	sub    $0xc,%esp
f01014d2:	56                   	push   %esi
f01014d3:	e8 a6 f8 ff ff       	call   f0100d7e <page_free>
	page_free(pp1);
f01014d8:	89 3c 24             	mov    %edi,(%esp)
f01014db:	e8 9e f8 ff ff       	call   f0100d7e <page_free>
	page_free(pp2);
f01014e0:	83 c4 04             	add    $0x4,%esp
f01014e3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014e6:	e8 93 f8 ff ff       	call   f0100d7e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014eb:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f01014f0:	83 c4 10             	add    $0x10,%esp
f01014f3:	eb 05                	jmp    f01014fa <mem_init+0x530>
		--nfree;
f01014f5:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014f8:	8b 00                	mov    (%eax),%eax
f01014fa:	85 c0                	test   %eax,%eax
f01014fc:	75 f7                	jne    f01014f5 <mem_init+0x52b>
		--nfree;
	assert(nfree == 0);
f01014fe:	85 db                	test   %ebx,%ebx
f0101500:	74 19                	je     f010151b <mem_init+0x551>
f0101502:	68 56 44 10 f0       	push   $0xf0104456
f0101507:	68 a6 42 10 f0       	push   $0xf01042a6
f010150c:	68 8c 02 00 00       	push   $0x28c
f0101511:	68 80 42 10 f0       	push   $0xf0104280
f0101516:	e8 70 eb ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010151b:	83 ec 0c             	sub    $0xc,%esp
f010151e:	68 b4 3c 10 f0       	push   $0xf0103cb4
f0101523:	e8 84 11 00 00       	call   f01026ac <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101528:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010152f:	e8 e0 f7 ff ff       	call   f0100d14 <page_alloc>
f0101534:	89 c6                	mov    %eax,%esi
f0101536:	83 c4 10             	add    $0x10,%esp
f0101539:	85 c0                	test   %eax,%eax
f010153b:	75 19                	jne    f0101556 <mem_init+0x58c>
f010153d:	68 64 43 10 f0       	push   $0xf0104364
f0101542:	68 a6 42 10 f0       	push   $0xf01042a6
f0101547:	68 e5 02 00 00       	push   $0x2e5
f010154c:	68 80 42 10 f0       	push   $0xf0104280
f0101551:	e8 35 eb ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101556:	83 ec 0c             	sub    $0xc,%esp
f0101559:	6a 00                	push   $0x0
f010155b:	e8 b4 f7 ff ff       	call   f0100d14 <page_alloc>
f0101560:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101563:	83 c4 10             	add    $0x10,%esp
f0101566:	85 c0                	test   %eax,%eax
f0101568:	75 19                	jne    f0101583 <mem_init+0x5b9>
f010156a:	68 7a 43 10 f0       	push   $0xf010437a
f010156f:	68 a6 42 10 f0       	push   $0xf01042a6
f0101574:	68 e6 02 00 00       	push   $0x2e6
f0101579:	68 80 42 10 f0       	push   $0xf0104280
f010157e:	e8 08 eb ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101583:	83 ec 0c             	sub    $0xc,%esp
f0101586:	6a 00                	push   $0x0
f0101588:	e8 87 f7 ff ff       	call   f0100d14 <page_alloc>
f010158d:	89 c3                	mov    %eax,%ebx
f010158f:	83 c4 10             	add    $0x10,%esp
f0101592:	85 c0                	test   %eax,%eax
f0101594:	75 19                	jne    f01015af <mem_init+0x5e5>
f0101596:	68 90 43 10 f0       	push   $0xf0104390
f010159b:	68 a6 42 10 f0       	push   $0xf01042a6
f01015a0:	68 e7 02 00 00       	push   $0x2e7
f01015a5:	68 80 42 10 f0       	push   $0xf0104280
f01015aa:	e8 dc ea ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015af:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015b2:	75 19                	jne    f01015cd <mem_init+0x603>
f01015b4:	68 a6 43 10 f0       	push   $0xf01043a6
f01015b9:	68 a6 42 10 f0       	push   $0xf01042a6
f01015be:	68 ea 02 00 00       	push   $0x2ea
f01015c3:	68 80 42 10 f0       	push   $0xf0104280
f01015c8:	e8 be ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015cd:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01015d0:	74 04                	je     f01015d6 <mem_init+0x60c>
f01015d2:	39 c6                	cmp    %eax,%esi
f01015d4:	75 19                	jne    f01015ef <mem_init+0x625>
f01015d6:	68 94 3c 10 f0       	push   $0xf0103c94
f01015db:	68 a6 42 10 f0       	push   $0xf01042a6
f01015e0:	68 eb 02 00 00       	push   $0x2eb
f01015e5:	68 80 42 10 f0       	push   $0xf0104280
f01015ea:	e8 9c ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015ef:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f01015f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015f7:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f01015fe:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101601:	83 ec 0c             	sub    $0xc,%esp
f0101604:	6a 00                	push   $0x0
f0101606:	e8 09 f7 ff ff       	call   f0100d14 <page_alloc>
f010160b:	83 c4 10             	add    $0x10,%esp
f010160e:	85 c0                	test   %eax,%eax
f0101610:	74 19                	je     f010162b <mem_init+0x661>
f0101612:	68 0f 44 10 f0       	push   $0xf010440f
f0101617:	68 a6 42 10 f0       	push   $0xf01042a6
f010161c:	68 f2 02 00 00       	push   $0x2f2
f0101621:	68 80 42 10 f0       	push   $0xf0104280
f0101626:	e8 60 ea ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010162b:	83 ec 04             	sub    $0x4,%esp
f010162e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101631:	50                   	push   %eax
f0101632:	6a 00                	push   $0x0
f0101634:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010163a:	e8 7f f8 ff ff       	call   f0100ebe <page_lookup>
f010163f:	83 c4 10             	add    $0x10,%esp
f0101642:	85 c0                	test   %eax,%eax
f0101644:	74 19                	je     f010165f <mem_init+0x695>
f0101646:	68 d4 3c 10 f0       	push   $0xf0103cd4
f010164b:	68 a6 42 10 f0       	push   $0xf01042a6
f0101650:	68 f5 02 00 00       	push   $0x2f5
f0101655:	68 80 42 10 f0       	push   $0xf0104280
f010165a:	e8 2c ea ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010165f:	6a 02                	push   $0x2
f0101661:	6a 00                	push   $0x0
f0101663:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101666:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010166c:	e8 f3 f8 ff ff       	call   f0100f64 <page_insert>
f0101671:	83 c4 10             	add    $0x10,%esp
f0101674:	85 c0                	test   %eax,%eax
f0101676:	78 19                	js     f0101691 <mem_init+0x6c7>
f0101678:	68 0c 3d 10 f0       	push   $0xf0103d0c
f010167d:	68 a6 42 10 f0       	push   $0xf01042a6
f0101682:	68 f8 02 00 00       	push   $0x2f8
f0101687:	68 80 42 10 f0       	push   $0xf0104280
f010168c:	e8 fa e9 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101691:	83 ec 0c             	sub    $0xc,%esp
f0101694:	56                   	push   %esi
f0101695:	e8 e4 f6 ff ff       	call   f0100d7e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010169a:	6a 02                	push   $0x2
f010169c:	6a 00                	push   $0x0
f010169e:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016a1:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016a7:	e8 b8 f8 ff ff       	call   f0100f64 <page_insert>
f01016ac:	83 c4 20             	add    $0x20,%esp
f01016af:	85 c0                	test   %eax,%eax
f01016b1:	74 19                	je     f01016cc <mem_init+0x702>
f01016b3:	68 3c 3d 10 f0       	push   $0xf0103d3c
f01016b8:	68 a6 42 10 f0       	push   $0xf01042a6
f01016bd:	68 fc 02 00 00       	push   $0x2fc
f01016c2:	68 80 42 10 f0       	push   $0xf0104280
f01016c7:	e8 bf e9 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01016cc:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016d2:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f01016d7:	89 c1                	mov    %eax,%ecx
f01016d9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01016dc:	8b 17                	mov    (%edi),%edx
f01016de:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016e4:	89 f0                	mov    %esi,%eax
f01016e6:	29 c8                	sub    %ecx,%eax
f01016e8:	c1 f8 03             	sar    $0x3,%eax
f01016eb:	c1 e0 0c             	shl    $0xc,%eax
f01016ee:	39 c2                	cmp    %eax,%edx
f01016f0:	74 19                	je     f010170b <mem_init+0x741>
f01016f2:	68 6c 3d 10 f0       	push   $0xf0103d6c
f01016f7:	68 a6 42 10 f0       	push   $0xf01042a6
f01016fc:	68 fd 02 00 00       	push   $0x2fd
f0101701:	68 80 42 10 f0       	push   $0xf0104280
f0101706:	e8 80 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010170b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101710:	89 f8                	mov    %edi,%eax
f0101712:	e8 03 f2 ff ff       	call   f010091a <check_va2pa>
f0101717:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010171a:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010171d:	c1 fa 03             	sar    $0x3,%edx
f0101720:	c1 e2 0c             	shl    $0xc,%edx
f0101723:	39 d0                	cmp    %edx,%eax
f0101725:	74 19                	je     f0101740 <mem_init+0x776>
f0101727:	68 94 3d 10 f0       	push   $0xf0103d94
f010172c:	68 a6 42 10 f0       	push   $0xf01042a6
f0101731:	68 fe 02 00 00       	push   $0x2fe
f0101736:	68 80 42 10 f0       	push   $0xf0104280
f010173b:	e8 4b e9 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101740:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101743:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101748:	74 19                	je     f0101763 <mem_init+0x799>
f010174a:	68 61 44 10 f0       	push   $0xf0104461
f010174f:	68 a6 42 10 f0       	push   $0xf01042a6
f0101754:	68 ff 02 00 00       	push   $0x2ff
f0101759:	68 80 42 10 f0       	push   $0xf0104280
f010175e:	e8 28 e9 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101763:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101768:	74 19                	je     f0101783 <mem_init+0x7b9>
f010176a:	68 72 44 10 f0       	push   $0xf0104472
f010176f:	68 a6 42 10 f0       	push   $0xf01042a6
f0101774:	68 00 03 00 00       	push   $0x300
f0101779:	68 80 42 10 f0       	push   $0xf0104280
f010177e:	e8 08 e9 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101783:	6a 02                	push   $0x2
f0101785:	68 00 10 00 00       	push   $0x1000
f010178a:	53                   	push   %ebx
f010178b:	57                   	push   %edi
f010178c:	e8 d3 f7 ff ff       	call   f0100f64 <page_insert>
f0101791:	83 c4 10             	add    $0x10,%esp
f0101794:	85 c0                	test   %eax,%eax
f0101796:	74 19                	je     f01017b1 <mem_init+0x7e7>
f0101798:	68 c4 3d 10 f0       	push   $0xf0103dc4
f010179d:	68 a6 42 10 f0       	push   $0xf01042a6
f01017a2:	68 03 03 00 00       	push   $0x303
f01017a7:	68 80 42 10 f0       	push   $0xf0104280
f01017ac:	e8 da e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017b6:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01017bb:	e8 5a f1 ff ff       	call   f010091a <check_va2pa>
f01017c0:	89 da                	mov    %ebx,%edx
f01017c2:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01017c8:	c1 fa 03             	sar    $0x3,%edx
f01017cb:	c1 e2 0c             	shl    $0xc,%edx
f01017ce:	39 d0                	cmp    %edx,%eax
f01017d0:	74 19                	je     f01017eb <mem_init+0x821>
f01017d2:	68 00 3e 10 f0       	push   $0xf0103e00
f01017d7:	68 a6 42 10 f0       	push   $0xf01042a6
f01017dc:	68 04 03 00 00       	push   $0x304
f01017e1:	68 80 42 10 f0       	push   $0xf0104280
f01017e6:	e8 a0 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01017eb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01017f0:	74 19                	je     f010180b <mem_init+0x841>
f01017f2:	68 83 44 10 f0       	push   $0xf0104483
f01017f7:	68 a6 42 10 f0       	push   $0xf01042a6
f01017fc:	68 05 03 00 00       	push   $0x305
f0101801:	68 80 42 10 f0       	push   $0xf0104280
f0101806:	e8 80 e8 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010180b:	83 ec 0c             	sub    $0xc,%esp
f010180e:	6a 00                	push   $0x0
f0101810:	e8 ff f4 ff ff       	call   f0100d14 <page_alloc>
f0101815:	83 c4 10             	add    $0x10,%esp
f0101818:	85 c0                	test   %eax,%eax
f010181a:	74 19                	je     f0101835 <mem_init+0x86b>
f010181c:	68 0f 44 10 f0       	push   $0xf010440f
f0101821:	68 a6 42 10 f0       	push   $0xf01042a6
f0101826:	68 08 03 00 00       	push   $0x308
f010182b:	68 80 42 10 f0       	push   $0xf0104280
f0101830:	e8 56 e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101835:	6a 02                	push   $0x2
f0101837:	68 00 10 00 00       	push   $0x1000
f010183c:	53                   	push   %ebx
f010183d:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101843:	e8 1c f7 ff ff       	call   f0100f64 <page_insert>
f0101848:	83 c4 10             	add    $0x10,%esp
f010184b:	85 c0                	test   %eax,%eax
f010184d:	74 19                	je     f0101868 <mem_init+0x89e>
f010184f:	68 c4 3d 10 f0       	push   $0xf0103dc4
f0101854:	68 a6 42 10 f0       	push   $0xf01042a6
f0101859:	68 0b 03 00 00       	push   $0x30b
f010185e:	68 80 42 10 f0       	push   $0xf0104280
f0101863:	e8 23 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101868:	ba 00 10 00 00       	mov    $0x1000,%edx
f010186d:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101872:	e8 a3 f0 ff ff       	call   f010091a <check_va2pa>
f0101877:	89 da                	mov    %ebx,%edx
f0101879:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f010187f:	c1 fa 03             	sar    $0x3,%edx
f0101882:	c1 e2 0c             	shl    $0xc,%edx
f0101885:	39 d0                	cmp    %edx,%eax
f0101887:	74 19                	je     f01018a2 <mem_init+0x8d8>
f0101889:	68 00 3e 10 f0       	push   $0xf0103e00
f010188e:	68 a6 42 10 f0       	push   $0xf01042a6
f0101893:	68 0c 03 00 00       	push   $0x30c
f0101898:	68 80 42 10 f0       	push   $0xf0104280
f010189d:	e8 e9 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01018a2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018a7:	74 19                	je     f01018c2 <mem_init+0x8f8>
f01018a9:	68 83 44 10 f0       	push   $0xf0104483
f01018ae:	68 a6 42 10 f0       	push   $0xf01042a6
f01018b3:	68 0d 03 00 00       	push   $0x30d
f01018b8:	68 80 42 10 f0       	push   $0xf0104280
f01018bd:	e8 c9 e7 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01018c2:	83 ec 0c             	sub    $0xc,%esp
f01018c5:	6a 00                	push   $0x0
f01018c7:	e8 48 f4 ff ff       	call   f0100d14 <page_alloc>
f01018cc:	83 c4 10             	add    $0x10,%esp
f01018cf:	85 c0                	test   %eax,%eax
f01018d1:	74 19                	je     f01018ec <mem_init+0x922>
f01018d3:	68 0f 44 10 f0       	push   $0xf010440f
f01018d8:	68 a6 42 10 f0       	push   $0xf01042a6
f01018dd:	68 11 03 00 00       	push   $0x311
f01018e2:	68 80 42 10 f0       	push   $0xf0104280
f01018e7:	e8 9f e7 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01018ec:	8b 15 68 69 11 f0    	mov    0xf0116968,%edx
f01018f2:	8b 02                	mov    (%edx),%eax
f01018f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018f9:	89 c1                	mov    %eax,%ecx
f01018fb:	c1 e9 0c             	shr    $0xc,%ecx
f01018fe:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f0101904:	72 15                	jb     f010191b <mem_init+0x951>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101906:	50                   	push   %eax
f0101907:	68 04 3b 10 f0       	push   $0xf0103b04
f010190c:	68 14 03 00 00       	push   $0x314
f0101911:	68 80 42 10 f0       	push   $0xf0104280
f0101916:	e8 70 e7 ff ff       	call   f010008b <_panic>
f010191b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101920:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101923:	83 ec 04             	sub    $0x4,%esp
f0101926:	6a 00                	push   $0x0
f0101928:	68 00 10 00 00       	push   $0x1000
f010192d:	52                   	push   %edx
f010192e:	e8 81 f4 ff ff       	call   f0100db4 <pgdir_walk>
f0101933:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101936:	8d 51 04             	lea    0x4(%ecx),%edx
f0101939:	83 c4 10             	add    $0x10,%esp
f010193c:	39 d0                	cmp    %edx,%eax
f010193e:	74 19                	je     f0101959 <mem_init+0x98f>
f0101940:	68 30 3e 10 f0       	push   $0xf0103e30
f0101945:	68 a6 42 10 f0       	push   $0xf01042a6
f010194a:	68 15 03 00 00       	push   $0x315
f010194f:	68 80 42 10 f0       	push   $0xf0104280
f0101954:	e8 32 e7 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101959:	6a 06                	push   $0x6
f010195b:	68 00 10 00 00       	push   $0x1000
f0101960:	53                   	push   %ebx
f0101961:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101967:	e8 f8 f5 ff ff       	call   f0100f64 <page_insert>
f010196c:	83 c4 10             	add    $0x10,%esp
f010196f:	85 c0                	test   %eax,%eax
f0101971:	74 19                	je     f010198c <mem_init+0x9c2>
f0101973:	68 70 3e 10 f0       	push   $0xf0103e70
f0101978:	68 a6 42 10 f0       	push   $0xf01042a6
f010197d:	68 18 03 00 00       	push   $0x318
f0101982:	68 80 42 10 f0       	push   $0xf0104280
f0101987:	e8 ff e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010198c:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101992:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101997:	89 f8                	mov    %edi,%eax
f0101999:	e8 7c ef ff ff       	call   f010091a <check_va2pa>
f010199e:	89 da                	mov    %ebx,%edx
f01019a0:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01019a6:	c1 fa 03             	sar    $0x3,%edx
f01019a9:	c1 e2 0c             	shl    $0xc,%edx
f01019ac:	39 d0                	cmp    %edx,%eax
f01019ae:	74 19                	je     f01019c9 <mem_init+0x9ff>
f01019b0:	68 00 3e 10 f0       	push   $0xf0103e00
f01019b5:	68 a6 42 10 f0       	push   $0xf01042a6
f01019ba:	68 19 03 00 00       	push   $0x319
f01019bf:	68 80 42 10 f0       	push   $0xf0104280
f01019c4:	e8 c2 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019c9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019ce:	74 19                	je     f01019e9 <mem_init+0xa1f>
f01019d0:	68 83 44 10 f0       	push   $0xf0104483
f01019d5:	68 a6 42 10 f0       	push   $0xf01042a6
f01019da:	68 1a 03 00 00       	push   $0x31a
f01019df:	68 80 42 10 f0       	push   $0xf0104280
f01019e4:	e8 a2 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01019e9:	83 ec 04             	sub    $0x4,%esp
f01019ec:	6a 00                	push   $0x0
f01019ee:	68 00 10 00 00       	push   $0x1000
f01019f3:	57                   	push   %edi
f01019f4:	e8 bb f3 ff ff       	call   f0100db4 <pgdir_walk>
f01019f9:	83 c4 10             	add    $0x10,%esp
f01019fc:	f6 00 04             	testb  $0x4,(%eax)
f01019ff:	75 19                	jne    f0101a1a <mem_init+0xa50>
f0101a01:	68 b0 3e 10 f0       	push   $0xf0103eb0
f0101a06:	68 a6 42 10 f0       	push   $0xf01042a6
f0101a0b:	68 1b 03 00 00       	push   $0x31b
f0101a10:	68 80 42 10 f0       	push   $0xf0104280
f0101a15:	e8 71 e6 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a1a:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101a1f:	f6 00 04             	testb  $0x4,(%eax)
f0101a22:	75 19                	jne    f0101a3d <mem_init+0xa73>
f0101a24:	68 94 44 10 f0       	push   $0xf0104494
f0101a29:	68 a6 42 10 f0       	push   $0xf01042a6
f0101a2e:	68 1c 03 00 00       	push   $0x31c
f0101a33:	68 80 42 10 f0       	push   $0xf0104280
f0101a38:	e8 4e e6 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a3d:	6a 02                	push   $0x2
f0101a3f:	68 00 10 00 00       	push   $0x1000
f0101a44:	53                   	push   %ebx
f0101a45:	50                   	push   %eax
f0101a46:	e8 19 f5 ff ff       	call   f0100f64 <page_insert>
f0101a4b:	83 c4 10             	add    $0x10,%esp
f0101a4e:	85 c0                	test   %eax,%eax
f0101a50:	74 19                	je     f0101a6b <mem_init+0xaa1>
f0101a52:	68 c4 3d 10 f0       	push   $0xf0103dc4
f0101a57:	68 a6 42 10 f0       	push   $0xf01042a6
f0101a5c:	68 1f 03 00 00       	push   $0x31f
f0101a61:	68 80 42 10 f0       	push   $0xf0104280
f0101a66:	e8 20 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a6b:	83 ec 04             	sub    $0x4,%esp
f0101a6e:	6a 00                	push   $0x0
f0101a70:	68 00 10 00 00       	push   $0x1000
f0101a75:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101a7b:	e8 34 f3 ff ff       	call   f0100db4 <pgdir_walk>
f0101a80:	83 c4 10             	add    $0x10,%esp
f0101a83:	f6 00 02             	testb  $0x2,(%eax)
f0101a86:	75 19                	jne    f0101aa1 <mem_init+0xad7>
f0101a88:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0101a8d:	68 a6 42 10 f0       	push   $0xf01042a6
f0101a92:	68 20 03 00 00       	push   $0x320
f0101a97:	68 80 42 10 f0       	push   $0xf0104280
f0101a9c:	e8 ea e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101aa1:	83 ec 04             	sub    $0x4,%esp
f0101aa4:	6a 00                	push   $0x0
f0101aa6:	68 00 10 00 00       	push   $0x1000
f0101aab:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ab1:	e8 fe f2 ff ff       	call   f0100db4 <pgdir_walk>
f0101ab6:	83 c4 10             	add    $0x10,%esp
f0101ab9:	f6 00 04             	testb  $0x4,(%eax)
f0101abc:	74 19                	je     f0101ad7 <mem_init+0xb0d>
f0101abe:	68 18 3f 10 f0       	push   $0xf0103f18
f0101ac3:	68 a6 42 10 f0       	push   $0xf01042a6
f0101ac8:	68 21 03 00 00       	push   $0x321
f0101acd:	68 80 42 10 f0       	push   $0xf0104280
f0101ad2:	e8 b4 e5 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ad7:	6a 02                	push   $0x2
f0101ad9:	68 00 00 40 00       	push   $0x400000
f0101ade:	56                   	push   %esi
f0101adf:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ae5:	e8 7a f4 ff ff       	call   f0100f64 <page_insert>
f0101aea:	83 c4 10             	add    $0x10,%esp
f0101aed:	85 c0                	test   %eax,%eax
f0101aef:	78 19                	js     f0101b0a <mem_init+0xb40>
f0101af1:	68 50 3f 10 f0       	push   $0xf0103f50
f0101af6:	68 a6 42 10 f0       	push   $0xf01042a6
f0101afb:	68 24 03 00 00       	push   $0x324
f0101b00:	68 80 42 10 f0       	push   $0xf0104280
f0101b05:	e8 81 e5 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b0a:	6a 02                	push   $0x2
f0101b0c:	68 00 10 00 00       	push   $0x1000
f0101b11:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b14:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b1a:	e8 45 f4 ff ff       	call   f0100f64 <page_insert>
f0101b1f:	83 c4 10             	add    $0x10,%esp
f0101b22:	85 c0                	test   %eax,%eax
f0101b24:	74 19                	je     f0101b3f <mem_init+0xb75>
f0101b26:	68 88 3f 10 f0       	push   $0xf0103f88
f0101b2b:	68 a6 42 10 f0       	push   $0xf01042a6
f0101b30:	68 27 03 00 00       	push   $0x327
f0101b35:	68 80 42 10 f0       	push   $0xf0104280
f0101b3a:	e8 4c e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b3f:	83 ec 04             	sub    $0x4,%esp
f0101b42:	6a 00                	push   $0x0
f0101b44:	68 00 10 00 00       	push   $0x1000
f0101b49:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b4f:	e8 60 f2 ff ff       	call   f0100db4 <pgdir_walk>
f0101b54:	83 c4 10             	add    $0x10,%esp
f0101b57:	f6 00 04             	testb  $0x4,(%eax)
f0101b5a:	74 19                	je     f0101b75 <mem_init+0xbab>
f0101b5c:	68 18 3f 10 f0       	push   $0xf0103f18
f0101b61:	68 a6 42 10 f0       	push   $0xf01042a6
f0101b66:	68 28 03 00 00       	push   $0x328
f0101b6b:	68 80 42 10 f0       	push   $0xf0104280
f0101b70:	e8 16 e5 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b75:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101b7b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b80:	89 f8                	mov    %edi,%eax
f0101b82:	e8 93 ed ff ff       	call   f010091a <check_va2pa>
f0101b87:	89 c1                	mov    %eax,%ecx
f0101b89:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b8f:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101b95:	c1 f8 03             	sar    $0x3,%eax
f0101b98:	c1 e0 0c             	shl    $0xc,%eax
f0101b9b:	39 c1                	cmp    %eax,%ecx
f0101b9d:	74 19                	je     f0101bb8 <mem_init+0xbee>
f0101b9f:	68 c4 3f 10 f0       	push   $0xf0103fc4
f0101ba4:	68 a6 42 10 f0       	push   $0xf01042a6
f0101ba9:	68 2b 03 00 00       	push   $0x32b
f0101bae:	68 80 42 10 f0       	push   $0xf0104280
f0101bb3:	e8 d3 e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bb8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bbd:	89 f8                	mov    %edi,%eax
f0101bbf:	e8 56 ed ff ff       	call   f010091a <check_va2pa>
f0101bc4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101bc7:	74 19                	je     f0101be2 <mem_init+0xc18>
f0101bc9:	68 f0 3f 10 f0       	push   $0xf0103ff0
f0101bce:	68 a6 42 10 f0       	push   $0xf01042a6
f0101bd3:	68 2c 03 00 00       	push   $0x32c
f0101bd8:	68 80 42 10 f0       	push   $0xf0104280
f0101bdd:	e8 a9 e4 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101be2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101be5:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101bea:	74 19                	je     f0101c05 <mem_init+0xc3b>
f0101bec:	68 aa 44 10 f0       	push   $0xf01044aa
f0101bf1:	68 a6 42 10 f0       	push   $0xf01042a6
f0101bf6:	68 2e 03 00 00       	push   $0x32e
f0101bfb:	68 80 42 10 f0       	push   $0xf0104280
f0101c00:	e8 86 e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101c05:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c0a:	74 19                	je     f0101c25 <mem_init+0xc5b>
f0101c0c:	68 bb 44 10 f0       	push   $0xf01044bb
f0101c11:	68 a6 42 10 f0       	push   $0xf01042a6
f0101c16:	68 2f 03 00 00       	push   $0x32f
f0101c1b:	68 80 42 10 f0       	push   $0xf0104280
f0101c20:	e8 66 e4 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c25:	83 ec 0c             	sub    $0xc,%esp
f0101c28:	6a 00                	push   $0x0
f0101c2a:	e8 e5 f0 ff ff       	call   f0100d14 <page_alloc>
f0101c2f:	83 c4 10             	add    $0x10,%esp
f0101c32:	85 c0                	test   %eax,%eax
f0101c34:	74 04                	je     f0101c3a <mem_init+0xc70>
f0101c36:	39 c3                	cmp    %eax,%ebx
f0101c38:	74 19                	je     f0101c53 <mem_init+0xc89>
f0101c3a:	68 20 40 10 f0       	push   $0xf0104020
f0101c3f:	68 a6 42 10 f0       	push   $0xf01042a6
f0101c44:	68 32 03 00 00       	push   $0x332
f0101c49:	68 80 42 10 f0       	push   $0xf0104280
f0101c4e:	e8 38 e4 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c53:	83 ec 08             	sub    $0x8,%esp
f0101c56:	6a 00                	push   $0x0
f0101c58:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101c5e:	e8 c1 f2 ff ff       	call   f0100f24 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c63:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101c69:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c6e:	89 f8                	mov    %edi,%eax
f0101c70:	e8 a5 ec ff ff       	call   f010091a <check_va2pa>
f0101c75:	83 c4 10             	add    $0x10,%esp
f0101c78:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c7b:	74 19                	je     f0101c96 <mem_init+0xccc>
f0101c7d:	68 44 40 10 f0       	push   $0xf0104044
f0101c82:	68 a6 42 10 f0       	push   $0xf01042a6
f0101c87:	68 36 03 00 00       	push   $0x336
f0101c8c:	68 80 42 10 f0       	push   $0xf0104280
f0101c91:	e8 f5 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c96:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c9b:	89 f8                	mov    %edi,%eax
f0101c9d:	e8 78 ec ff ff       	call   f010091a <check_va2pa>
f0101ca2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ca5:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101cab:	c1 fa 03             	sar    $0x3,%edx
f0101cae:	c1 e2 0c             	shl    $0xc,%edx
f0101cb1:	39 d0                	cmp    %edx,%eax
f0101cb3:	74 19                	je     f0101cce <mem_init+0xd04>
f0101cb5:	68 f0 3f 10 f0       	push   $0xf0103ff0
f0101cba:	68 a6 42 10 f0       	push   $0xf01042a6
f0101cbf:	68 37 03 00 00       	push   $0x337
f0101cc4:	68 80 42 10 f0       	push   $0xf0104280
f0101cc9:	e8 bd e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101cce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cd6:	74 19                	je     f0101cf1 <mem_init+0xd27>
f0101cd8:	68 61 44 10 f0       	push   $0xf0104461
f0101cdd:	68 a6 42 10 f0       	push   $0xf01042a6
f0101ce2:	68 38 03 00 00       	push   $0x338
f0101ce7:	68 80 42 10 f0       	push   $0xf0104280
f0101cec:	e8 9a e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101cf1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cf6:	74 19                	je     f0101d11 <mem_init+0xd47>
f0101cf8:	68 bb 44 10 f0       	push   $0xf01044bb
f0101cfd:	68 a6 42 10 f0       	push   $0xf01042a6
f0101d02:	68 39 03 00 00       	push   $0x339
f0101d07:	68 80 42 10 f0       	push   $0xf0104280
f0101d0c:	e8 7a e3 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d11:	6a 00                	push   $0x0
f0101d13:	68 00 10 00 00       	push   $0x1000
f0101d18:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d1b:	57                   	push   %edi
f0101d1c:	e8 43 f2 ff ff       	call   f0100f64 <page_insert>
f0101d21:	83 c4 10             	add    $0x10,%esp
f0101d24:	85 c0                	test   %eax,%eax
f0101d26:	74 19                	je     f0101d41 <mem_init+0xd77>
f0101d28:	68 68 40 10 f0       	push   $0xf0104068
f0101d2d:	68 a6 42 10 f0       	push   $0xf01042a6
f0101d32:	68 3c 03 00 00       	push   $0x33c
f0101d37:	68 80 42 10 f0       	push   $0xf0104280
f0101d3c:	e8 4a e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101d41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d44:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d49:	75 19                	jne    f0101d64 <mem_init+0xd9a>
f0101d4b:	68 cc 44 10 f0       	push   $0xf01044cc
f0101d50:	68 a6 42 10 f0       	push   $0xf01042a6
f0101d55:	68 3d 03 00 00       	push   $0x33d
f0101d5a:	68 80 42 10 f0       	push   $0xf0104280
f0101d5f:	e8 27 e3 ff ff       	call   f010008b <_panic>
	//assert(pp1->pp_link == NULL);

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d64:	83 ec 08             	sub    $0x8,%esp
f0101d67:	68 00 10 00 00       	push   $0x1000
f0101d6c:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101d72:	e8 ad f1 ff ff       	call   f0100f24 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d77:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101d7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d82:	89 f8                	mov    %edi,%eax
f0101d84:	e8 91 eb ff ff       	call   f010091a <check_va2pa>
f0101d89:	83 c4 10             	add    $0x10,%esp
f0101d8c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d8f:	74 19                	je     f0101daa <mem_init+0xde0>
f0101d91:	68 44 40 10 f0       	push   $0xf0104044
f0101d96:	68 a6 42 10 f0       	push   $0xf01042a6
f0101d9b:	68 42 03 00 00       	push   $0x342
f0101da0:	68 80 42 10 f0       	push   $0xf0104280
f0101da5:	e8 e1 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101daa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101daf:	89 f8                	mov    %edi,%eax
f0101db1:	e8 64 eb ff ff       	call   f010091a <check_va2pa>
f0101db6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101db9:	74 19                	je     f0101dd4 <mem_init+0xe0a>
f0101dbb:	68 a0 40 10 f0       	push   $0xf01040a0
f0101dc0:	68 a6 42 10 f0       	push   $0xf01042a6
f0101dc5:	68 43 03 00 00       	push   $0x343
f0101dca:	68 80 42 10 f0       	push   $0xf0104280
f0101dcf:	e8 b7 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101dd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ddc:	74 19                	je     f0101df7 <mem_init+0xe2d>
f0101dde:	68 d8 44 10 f0       	push   $0xf01044d8
f0101de3:	68 a6 42 10 f0       	push   $0xf01042a6
f0101de8:	68 44 03 00 00       	push   $0x344
f0101ded:	68 80 42 10 f0       	push   $0xf0104280
f0101df2:	e8 94 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101df7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dfc:	74 19                	je     f0101e17 <mem_init+0xe4d>
f0101dfe:	68 bb 44 10 f0       	push   $0xf01044bb
f0101e03:	68 a6 42 10 f0       	push   $0xf01042a6
f0101e08:	68 45 03 00 00       	push   $0x345
f0101e0d:	68 80 42 10 f0       	push   $0xf0104280
f0101e12:	e8 74 e2 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e17:	83 ec 0c             	sub    $0xc,%esp
f0101e1a:	6a 00                	push   $0x0
f0101e1c:	e8 f3 ee ff ff       	call   f0100d14 <page_alloc>
f0101e21:	83 c4 10             	add    $0x10,%esp
f0101e24:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e27:	75 04                	jne    f0101e2d <mem_init+0xe63>
f0101e29:	85 c0                	test   %eax,%eax
f0101e2b:	75 19                	jne    f0101e46 <mem_init+0xe7c>
f0101e2d:	68 c8 40 10 f0       	push   $0xf01040c8
f0101e32:	68 a6 42 10 f0       	push   $0xf01042a6
f0101e37:	68 48 03 00 00       	push   $0x348
f0101e3c:	68 80 42 10 f0       	push   $0xf0104280
f0101e41:	e8 45 e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e46:	83 ec 0c             	sub    $0xc,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	e8 c4 ee ff ff       	call   f0100d14 <page_alloc>
f0101e50:	83 c4 10             	add    $0x10,%esp
f0101e53:	85 c0                	test   %eax,%eax
f0101e55:	74 19                	je     f0101e70 <mem_init+0xea6>
f0101e57:	68 0f 44 10 f0       	push   $0xf010440f
f0101e5c:	68 a6 42 10 f0       	push   $0xf01042a6
f0101e61:	68 4b 03 00 00       	push   $0x34b
f0101e66:	68 80 42 10 f0       	push   $0xf0104280
f0101e6b:	e8 1b e2 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e70:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f0101e76:	8b 11                	mov    (%ecx),%edx
f0101e78:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e7e:	89 f0                	mov    %esi,%eax
f0101e80:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101e86:	c1 f8 03             	sar    $0x3,%eax
f0101e89:	c1 e0 0c             	shl    $0xc,%eax
f0101e8c:	39 c2                	cmp    %eax,%edx
f0101e8e:	74 19                	je     f0101ea9 <mem_init+0xedf>
f0101e90:	68 6c 3d 10 f0       	push   $0xf0103d6c
f0101e95:	68 a6 42 10 f0       	push   $0xf01042a6
f0101e9a:	68 4e 03 00 00       	push   $0x34e
f0101e9f:	68 80 42 10 f0       	push   $0xf0104280
f0101ea4:	e8 e2 e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101ea9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101eaf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101eb4:	74 19                	je     f0101ecf <mem_init+0xf05>
f0101eb6:	68 72 44 10 f0       	push   $0xf0104472
f0101ebb:	68 a6 42 10 f0       	push   $0xf01042a6
f0101ec0:	68 50 03 00 00       	push   $0x350
f0101ec5:	68 80 42 10 f0       	push   $0xf0104280
f0101eca:	e8 bc e1 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101ecf:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ed5:	83 ec 0c             	sub    $0xc,%esp
f0101ed8:	56                   	push   %esi
f0101ed9:	e8 a0 ee ff ff       	call   f0100d7e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101ede:	83 c4 0c             	add    $0xc,%esp
f0101ee1:	6a 01                	push   $0x1
f0101ee3:	68 00 10 40 00       	push   $0x401000
f0101ee8:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101eee:	e8 c1 ee ff ff       	call   f0100db4 <pgdir_walk>
f0101ef3:	89 c7                	mov    %eax,%edi
f0101ef5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ef8:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101efd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f00:	8b 40 04             	mov    0x4(%eax),%eax
f0101f03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f08:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101f0e:	89 c2                	mov    %eax,%edx
f0101f10:	c1 ea 0c             	shr    $0xc,%edx
f0101f13:	83 c4 10             	add    $0x10,%esp
f0101f16:	39 ca                	cmp    %ecx,%edx
f0101f18:	72 15                	jb     f0101f2f <mem_init+0xf65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f1a:	50                   	push   %eax
f0101f1b:	68 04 3b 10 f0       	push   $0xf0103b04
f0101f20:	68 57 03 00 00       	push   $0x357
f0101f25:	68 80 42 10 f0       	push   $0xf0104280
f0101f2a:	e8 5c e1 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f2f:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101f34:	39 c7                	cmp    %eax,%edi
f0101f36:	74 19                	je     f0101f51 <mem_init+0xf87>
f0101f38:	68 e9 44 10 f0       	push   $0xf01044e9
f0101f3d:	68 a6 42 10 f0       	push   $0xf01042a6
f0101f42:	68 58 03 00 00       	push   $0x358
f0101f47:	68 80 42 10 f0       	push   $0xf0104280
f0101f4c:	e8 3a e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f51:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f54:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101f5b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f61:	89 f0                	mov    %esi,%eax
f0101f63:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101f69:	c1 f8 03             	sar    $0x3,%eax
f0101f6c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f6f:	89 c2                	mov    %eax,%edx
f0101f71:	c1 ea 0c             	shr    $0xc,%edx
f0101f74:	39 d1                	cmp    %edx,%ecx
f0101f76:	77 12                	ja     f0101f8a <mem_init+0xfc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f78:	50                   	push   %eax
f0101f79:	68 04 3b 10 f0       	push   $0xf0103b04
f0101f7e:	6a 52                	push   $0x52
f0101f80:	68 8c 42 10 f0       	push   $0xf010428c
f0101f85:	e8 01 e1 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f8a:	83 ec 04             	sub    $0x4,%esp
f0101f8d:	68 00 10 00 00       	push   $0x1000
f0101f92:	68 ff 00 00 00       	push   $0xff
f0101f97:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f9c:	50                   	push   %eax
f0101f9d:	e8 e2 11 00 00       	call   f0103184 <memset>
	page_free(pp0);
f0101fa2:	89 34 24             	mov    %esi,(%esp)
f0101fa5:	e8 d4 ed ff ff       	call   f0100d7e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101faa:	83 c4 0c             	add    $0xc,%esp
f0101fad:	6a 01                	push   $0x1
f0101faf:	6a 00                	push   $0x0
f0101fb1:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101fb7:	e8 f8 ed ff ff       	call   f0100db4 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fbc:	89 f2                	mov    %esi,%edx
f0101fbe:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101fc4:	c1 fa 03             	sar    $0x3,%edx
f0101fc7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fca:	89 d0                	mov    %edx,%eax
f0101fcc:	c1 e8 0c             	shr    $0xc,%eax
f0101fcf:	83 c4 10             	add    $0x10,%esp
f0101fd2:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0101fd8:	72 12                	jb     f0101fec <mem_init+0x1022>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fda:	52                   	push   %edx
f0101fdb:	68 04 3b 10 f0       	push   $0xf0103b04
f0101fe0:	6a 52                	push   $0x52
f0101fe2:	68 8c 42 10 f0       	push   $0xf010428c
f0101fe7:	e8 9f e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101fec:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101ff5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ffb:	f6 00 01             	testb  $0x1,(%eax)
f0101ffe:	74 19                	je     f0102019 <mem_init+0x104f>
f0102000:	68 01 45 10 f0       	push   $0xf0104501
f0102005:	68 a6 42 10 f0       	push   $0xf01042a6
f010200a:	68 62 03 00 00       	push   $0x362
f010200f:	68 80 42 10 f0       	push   $0xf0104280
f0102014:	e8 72 e0 ff ff       	call   f010008b <_panic>
f0102019:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010201c:	39 d0                	cmp    %edx,%eax
f010201e:	75 db                	jne    f0101ffb <mem_init+0x1031>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102020:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0102025:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010202b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102031:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102034:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f0102039:	83 ec 0c             	sub    $0xc,%esp
f010203c:	56                   	push   %esi
f010203d:	e8 3c ed ff ff       	call   f0100d7e <page_free>
	page_free(pp1);
f0102042:	83 c4 04             	add    $0x4,%esp
f0102045:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102048:	e8 31 ed ff ff       	call   f0100d7e <page_free>
	page_free(pp2);
f010204d:	89 1c 24             	mov    %ebx,(%esp)
f0102050:	e8 29 ed ff ff       	call   f0100d7e <page_free>

	cprintf("check_page() succeeded!\n");
f0102055:	c7 04 24 18 45 10 f0 	movl   $0xf0104518,(%esp)
f010205c:	e8 4b 06 00 00       	call   f01026ac <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f0102061:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102066:	83 c4 10             	add    $0x10,%esp
f0102069:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010206e:	77 15                	ja     f0102085 <mem_init+0x10bb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102070:	50                   	push   %eax
f0102071:	68 ec 3b 10 f0       	push   $0xf0103bec
f0102076:	68 b2 00 00 00       	push   $0xb2
f010207b:	68 80 42 10 f0       	push   $0xf0104280
f0102080:	e8 06 e0 ff ff       	call   f010008b <_panic>
f0102085:	83 ec 08             	sub    $0x8,%esp
f0102088:	6a 04                	push   $0x4
f010208a:	05 00 00 00 10       	add    $0x10000000,%eax
f010208f:	50                   	push   %eax
f0102090:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102095:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010209a:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f010209f:	e8 a3 ed ff ff       	call   f0100e47 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020a4:	83 c4 10             	add    $0x10,%esp
f01020a7:	b8 00 c0 10 f0       	mov    $0xf010c000,%eax
f01020ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020b1:	77 15                	ja     f01020c8 <mem_init+0x10fe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020b3:	50                   	push   %eax
f01020b4:	68 ec 3b 10 f0       	push   $0xf0103bec
f01020b9:	68 be 00 00 00       	push   $0xbe
f01020be:	68 80 42 10 f0       	push   $0xf0104280
f01020c3:	e8 c3 df ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f01020c8:	83 ec 08             	sub    $0x8,%esp
f01020cb:	6a 02                	push   $0x2
f01020cd:	68 00 c0 10 00       	push   $0x10c000
f01020d2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020d7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020dc:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01020e1:	e8 61 ed ff ff       	call   f0100e47 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KERNBASE,-KERNBASE,0,PTE_W);
f01020e6:	83 c4 08             	add    $0x8,%esp
f01020e9:	6a 02                	push   $0x2
f01020eb:	6a 00                	push   $0x0
f01020ed:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020f2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020f7:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01020fc:	e8 46 ed ff ff       	call   f0100e47 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102101:	8b 35 68 69 11 f0    	mov    0xf0116968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102107:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f010210c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010210f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102116:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010211b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010211e:	8b 3d 6c 69 11 f0    	mov    0xf011696c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102124:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102127:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010212a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010212f:	eb 55                	jmp    f0102186 <mem_init+0x11bc>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102131:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102137:	89 f0                	mov    %esi,%eax
f0102139:	e8 dc e7 ff ff       	call   f010091a <check_va2pa>
f010213e:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102145:	77 15                	ja     f010215c <mem_init+0x1192>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102147:	57                   	push   %edi
f0102148:	68 ec 3b 10 f0       	push   $0xf0103bec
f010214d:	68 a4 02 00 00       	push   $0x2a4
f0102152:	68 80 42 10 f0       	push   $0xf0104280
f0102157:	e8 2f df ff ff       	call   f010008b <_panic>
f010215c:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f0102163:	39 c2                	cmp    %eax,%edx
f0102165:	74 19                	je     f0102180 <mem_init+0x11b6>
f0102167:	68 ec 40 10 f0       	push   $0xf01040ec
f010216c:	68 a6 42 10 f0       	push   $0xf01042a6
f0102171:	68 a4 02 00 00       	push   $0x2a4
f0102176:	68 80 42 10 f0       	push   $0xf0104280
f010217b:	e8 0b df ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102180:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102186:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102189:	77 a6                	ja     f0102131 <mem_init+0x1167>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010218b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010218e:	c1 e7 0c             	shl    $0xc,%edi
f0102191:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102196:	eb 30                	jmp    f01021c8 <mem_init+0x11fe>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102198:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010219e:	89 f0                	mov    %esi,%eax
f01021a0:	e8 75 e7 ff ff       	call   f010091a <check_va2pa>
f01021a5:	39 c3                	cmp    %eax,%ebx
f01021a7:	74 19                	je     f01021c2 <mem_init+0x11f8>
f01021a9:	68 20 41 10 f0       	push   $0xf0104120
f01021ae:	68 a6 42 10 f0       	push   $0xf01042a6
f01021b3:	68 a9 02 00 00       	push   $0x2a9
f01021b8:	68 80 42 10 f0       	push   $0xf0104280
f01021bd:	e8 c9 de ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021c8:	39 fb                	cmp    %edi,%ebx
f01021ca:	72 cc                	jb     f0102198 <mem_init+0x11ce>
f01021cc:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01021d1:	89 da                	mov    %ebx,%edx
f01021d3:	89 f0                	mov    %esi,%eax
f01021d5:	e8 40 e7 ff ff       	call   f010091a <check_va2pa>
f01021da:	8d 93 00 40 11 10    	lea    0x10114000(%ebx),%edx
f01021e0:	39 c2                	cmp    %eax,%edx
f01021e2:	74 19                	je     f01021fd <mem_init+0x1233>
f01021e4:	68 48 41 10 f0       	push   $0xf0104148
f01021e9:	68 a6 42 10 f0       	push   $0xf01042a6
f01021ee:	68 ad 02 00 00       	push   $0x2ad
f01021f3:	68 80 42 10 f0       	push   $0xf0104280
f01021f8:	e8 8e de ff ff       	call   f010008b <_panic>
f01021fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102203:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102209:	75 c6                	jne    f01021d1 <mem_init+0x1207>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010220b:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102210:	89 f0                	mov    %esi,%eax
f0102212:	e8 03 e7 ff ff       	call   f010091a <check_va2pa>
f0102217:	83 f8 ff             	cmp    $0xffffffff,%eax
f010221a:	74 51                	je     f010226d <mem_init+0x12a3>
f010221c:	68 90 41 10 f0       	push   $0xf0104190
f0102221:	68 a6 42 10 f0       	push   $0xf01042a6
f0102226:	68 ae 02 00 00       	push   $0x2ae
f010222b:	68 80 42 10 f0       	push   $0xf0104280
f0102230:	e8 56 de ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102235:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010223a:	72 36                	jb     f0102272 <mem_init+0x12a8>
f010223c:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102241:	76 07                	jbe    f010224a <mem_init+0x1280>
f0102243:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102248:	75 28                	jne    f0102272 <mem_init+0x12a8>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010224a:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010224e:	0f 85 83 00 00 00    	jne    f01022d7 <mem_init+0x130d>
f0102254:	68 31 45 10 f0       	push   $0xf0104531
f0102259:	68 a6 42 10 f0       	push   $0xf01042a6
f010225e:	68 b6 02 00 00       	push   $0x2b6
f0102263:	68 80 42 10 f0       	push   $0xf0104280
f0102268:	e8 1e de ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010226d:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102272:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102277:	76 3f                	jbe    f01022b8 <mem_init+0x12ee>
				assert(pgdir[i] & PTE_P);
f0102279:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010227c:	f6 c2 01             	test   $0x1,%dl
f010227f:	75 19                	jne    f010229a <mem_init+0x12d0>
f0102281:	68 31 45 10 f0       	push   $0xf0104531
f0102286:	68 a6 42 10 f0       	push   $0xf01042a6
f010228b:	68 ba 02 00 00       	push   $0x2ba
f0102290:	68 80 42 10 f0       	push   $0xf0104280
f0102295:	e8 f1 dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f010229a:	f6 c2 02             	test   $0x2,%dl
f010229d:	75 38                	jne    f01022d7 <mem_init+0x130d>
f010229f:	68 42 45 10 f0       	push   $0xf0104542
f01022a4:	68 a6 42 10 f0       	push   $0xf01042a6
f01022a9:	68 bb 02 00 00       	push   $0x2bb
f01022ae:	68 80 42 10 f0       	push   $0xf0104280
f01022b3:	e8 d3 dd ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f01022b8:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01022bc:	74 19                	je     f01022d7 <mem_init+0x130d>
f01022be:	68 53 45 10 f0       	push   $0xf0104553
f01022c3:	68 a6 42 10 f0       	push   $0xf01042a6
f01022c8:	68 bd 02 00 00       	push   $0x2bd
f01022cd:	68 80 42 10 f0       	push   $0xf0104280
f01022d2:	e8 b4 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01022d7:	83 c0 01             	add    $0x1,%eax
f01022da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01022df:	0f 86 50 ff ff ff    	jbe    f0102235 <mem_init+0x126b>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01022e5:	83 ec 0c             	sub    $0xc,%esp
f01022e8:	68 c0 41 10 f0       	push   $0xf01041c0
f01022ed:	e8 ba 03 00 00       	call   f01026ac <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01022f2:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022f7:	83 c4 10             	add    $0x10,%esp
f01022fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022ff:	77 15                	ja     f0102316 <mem_init+0x134c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102301:	50                   	push   %eax
f0102302:	68 ec 3b 10 f0       	push   $0xf0103bec
f0102307:	68 d2 00 00 00       	push   $0xd2
f010230c:	68 80 42 10 f0       	push   $0xf0104280
f0102311:	e8 75 dd ff ff       	call   f010008b <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102316:	05 00 00 00 10       	add    $0x10000000,%eax
f010231b:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010231e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102323:	e8 56 e6 ff ff       	call   f010097e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102328:	0f 20 c0             	mov    %cr0,%eax
f010232b:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010232e:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102333:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102336:	83 ec 0c             	sub    $0xc,%esp
f0102339:	6a 00                	push   $0x0
f010233b:	e8 d4 e9 ff ff       	call   f0100d14 <page_alloc>
f0102340:	89 c3                	mov    %eax,%ebx
f0102342:	83 c4 10             	add    $0x10,%esp
f0102345:	85 c0                	test   %eax,%eax
f0102347:	75 19                	jne    f0102362 <mem_init+0x1398>
f0102349:	68 64 43 10 f0       	push   $0xf0104364
f010234e:	68 a6 42 10 f0       	push   $0xf01042a6
f0102353:	68 7d 03 00 00       	push   $0x37d
f0102358:	68 80 42 10 f0       	push   $0xf0104280
f010235d:	e8 29 dd ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102362:	83 ec 0c             	sub    $0xc,%esp
f0102365:	6a 00                	push   $0x0
f0102367:	e8 a8 e9 ff ff       	call   f0100d14 <page_alloc>
f010236c:	89 c7                	mov    %eax,%edi
f010236e:	83 c4 10             	add    $0x10,%esp
f0102371:	85 c0                	test   %eax,%eax
f0102373:	75 19                	jne    f010238e <mem_init+0x13c4>
f0102375:	68 7a 43 10 f0       	push   $0xf010437a
f010237a:	68 a6 42 10 f0       	push   $0xf01042a6
f010237f:	68 7e 03 00 00       	push   $0x37e
f0102384:	68 80 42 10 f0       	push   $0xf0104280
f0102389:	e8 fd dc ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010238e:	83 ec 0c             	sub    $0xc,%esp
f0102391:	6a 00                	push   $0x0
f0102393:	e8 7c e9 ff ff       	call   f0100d14 <page_alloc>
f0102398:	89 c6                	mov    %eax,%esi
f010239a:	83 c4 10             	add    $0x10,%esp
f010239d:	85 c0                	test   %eax,%eax
f010239f:	75 19                	jne    f01023ba <mem_init+0x13f0>
f01023a1:	68 90 43 10 f0       	push   $0xf0104390
f01023a6:	68 a6 42 10 f0       	push   $0xf01042a6
f01023ab:	68 7f 03 00 00       	push   $0x37f
f01023b0:	68 80 42 10 f0       	push   $0xf0104280
f01023b5:	e8 d1 dc ff ff       	call   f010008b <_panic>
	page_free(pp0);
f01023ba:	83 ec 0c             	sub    $0xc,%esp
f01023bd:	53                   	push   %ebx
f01023be:	e8 bb e9 ff ff       	call   f0100d7e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c3:	89 f8                	mov    %edi,%eax
f01023c5:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01023cb:	c1 f8 03             	sar    $0x3,%eax
f01023ce:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d1:	89 c2                	mov    %eax,%edx
f01023d3:	c1 ea 0c             	shr    $0xc,%edx
f01023d6:	83 c4 10             	add    $0x10,%esp
f01023d9:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01023df:	72 12                	jb     f01023f3 <mem_init+0x1429>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e1:	50                   	push   %eax
f01023e2:	68 04 3b 10 f0       	push   $0xf0103b04
f01023e7:	6a 52                	push   $0x52
f01023e9:	68 8c 42 10 f0       	push   $0xf010428c
f01023ee:	e8 98 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01023f3:	83 ec 04             	sub    $0x4,%esp
f01023f6:	68 00 10 00 00       	push   $0x1000
f01023fb:	6a 01                	push   $0x1
f01023fd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102402:	50                   	push   %eax
f0102403:	e8 7c 0d 00 00       	call   f0103184 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102408:	89 f0                	mov    %esi,%eax
f010240a:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102410:	c1 f8 03             	sar    $0x3,%eax
f0102413:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102416:	89 c2                	mov    %eax,%edx
f0102418:	c1 ea 0c             	shr    $0xc,%edx
f010241b:	83 c4 10             	add    $0x10,%esp
f010241e:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102424:	72 12                	jb     f0102438 <mem_init+0x146e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102426:	50                   	push   %eax
f0102427:	68 04 3b 10 f0       	push   $0xf0103b04
f010242c:	6a 52                	push   $0x52
f010242e:	68 8c 42 10 f0       	push   $0xf010428c
f0102433:	e8 53 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102438:	83 ec 04             	sub    $0x4,%esp
f010243b:	68 00 10 00 00       	push   $0x1000
f0102440:	6a 02                	push   $0x2
f0102442:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102447:	50                   	push   %eax
f0102448:	e8 37 0d 00 00       	call   f0103184 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010244d:	6a 02                	push   $0x2
f010244f:	68 00 10 00 00       	push   $0x1000
f0102454:	57                   	push   %edi
f0102455:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010245b:	e8 04 eb ff ff       	call   f0100f64 <page_insert>
	assert(pp1->pp_ref == 1);
f0102460:	83 c4 20             	add    $0x20,%esp
f0102463:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102468:	74 19                	je     f0102483 <mem_init+0x14b9>
f010246a:	68 61 44 10 f0       	push   $0xf0104461
f010246f:	68 a6 42 10 f0       	push   $0xf01042a6
f0102474:	68 84 03 00 00       	push   $0x384
f0102479:	68 80 42 10 f0       	push   $0xf0104280
f010247e:	e8 08 dc ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102483:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010248a:	01 01 01 
f010248d:	74 19                	je     f01024a8 <mem_init+0x14de>
f010248f:	68 e0 41 10 f0       	push   $0xf01041e0
f0102494:	68 a6 42 10 f0       	push   $0xf01042a6
f0102499:	68 85 03 00 00       	push   $0x385
f010249e:	68 80 42 10 f0       	push   $0xf0104280
f01024a3:	e8 e3 db ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01024a8:	6a 02                	push   $0x2
f01024aa:	68 00 10 00 00       	push   $0x1000
f01024af:	56                   	push   %esi
f01024b0:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01024b6:	e8 a9 ea ff ff       	call   f0100f64 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024bb:	83 c4 10             	add    $0x10,%esp
f01024be:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024c5:	02 02 02 
f01024c8:	74 19                	je     f01024e3 <mem_init+0x1519>
f01024ca:	68 04 42 10 f0       	push   $0xf0104204
f01024cf:	68 a6 42 10 f0       	push   $0xf01042a6
f01024d4:	68 87 03 00 00       	push   $0x387
f01024d9:	68 80 42 10 f0       	push   $0xf0104280
f01024de:	e8 a8 db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01024e3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024e8:	74 19                	je     f0102503 <mem_init+0x1539>
f01024ea:	68 83 44 10 f0       	push   $0xf0104483
f01024ef:	68 a6 42 10 f0       	push   $0xf01042a6
f01024f4:	68 88 03 00 00       	push   $0x388
f01024f9:	68 80 42 10 f0       	push   $0xf0104280
f01024fe:	e8 88 db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102503:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102508:	74 19                	je     f0102523 <mem_init+0x1559>
f010250a:	68 d8 44 10 f0       	push   $0xf01044d8
f010250f:	68 a6 42 10 f0       	push   $0xf01042a6
f0102514:	68 89 03 00 00       	push   $0x389
f0102519:	68 80 42 10 f0       	push   $0xf0104280
f010251e:	e8 68 db ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102523:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010252a:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010252d:	89 f0                	mov    %esi,%eax
f010252f:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102535:	c1 f8 03             	sar    $0x3,%eax
f0102538:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010253b:	89 c2                	mov    %eax,%edx
f010253d:	c1 ea 0c             	shr    $0xc,%edx
f0102540:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102546:	72 12                	jb     f010255a <mem_init+0x1590>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102548:	50                   	push   %eax
f0102549:	68 04 3b 10 f0       	push   $0xf0103b04
f010254e:	6a 52                	push   $0x52
f0102550:	68 8c 42 10 f0       	push   $0xf010428c
f0102555:	e8 31 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010255a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102561:	03 03 03 
f0102564:	74 19                	je     f010257f <mem_init+0x15b5>
f0102566:	68 28 42 10 f0       	push   $0xf0104228
f010256b:	68 a6 42 10 f0       	push   $0xf01042a6
f0102570:	68 8b 03 00 00       	push   $0x38b
f0102575:	68 80 42 10 f0       	push   $0xf0104280
f010257a:	e8 0c db ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010257f:	83 ec 08             	sub    $0x8,%esp
f0102582:	68 00 10 00 00       	push   $0x1000
f0102587:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010258d:	e8 92 e9 ff ff       	call   f0100f24 <page_remove>
	assert(pp2->pp_ref == 0);
f0102592:	83 c4 10             	add    $0x10,%esp
f0102595:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010259a:	74 19                	je     f01025b5 <mem_init+0x15eb>
f010259c:	68 bb 44 10 f0       	push   $0xf01044bb
f01025a1:	68 a6 42 10 f0       	push   $0xf01042a6
f01025a6:	68 8d 03 00 00       	push   $0x38d
f01025ab:	68 80 42 10 f0       	push   $0xf0104280
f01025b0:	e8 d6 da ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025b5:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f01025bb:	8b 11                	mov    (%ecx),%edx
f01025bd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025c3:	89 d8                	mov    %ebx,%eax
f01025c5:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01025cb:	c1 f8 03             	sar    $0x3,%eax
f01025ce:	c1 e0 0c             	shl    $0xc,%eax
f01025d1:	39 c2                	cmp    %eax,%edx
f01025d3:	74 19                	je     f01025ee <mem_init+0x1624>
f01025d5:	68 6c 3d 10 f0       	push   $0xf0103d6c
f01025da:	68 a6 42 10 f0       	push   $0xf01042a6
f01025df:	68 90 03 00 00       	push   $0x390
f01025e4:	68 80 42 10 f0       	push   $0xf0104280
f01025e9:	e8 9d da ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f01025ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025f4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025f9:	74 19                	je     f0102614 <mem_init+0x164a>
f01025fb:	68 72 44 10 f0       	push   $0xf0104472
f0102600:	68 a6 42 10 f0       	push   $0xf01042a6
f0102605:	68 92 03 00 00       	push   $0x392
f010260a:	68 80 42 10 f0       	push   $0xf0104280
f010260f:	e8 77 da ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102614:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010261a:	83 ec 0c             	sub    $0xc,%esp
f010261d:	53                   	push   %ebx
f010261e:	e8 5b e7 ff ff       	call   f0100d7e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102623:	c7 04 24 54 42 10 f0 	movl   $0xf0104254,(%esp)
f010262a:	e8 7d 00 00 00       	call   f01026ac <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010262f:	83 c4 10             	add    $0x10,%esp
f0102632:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102635:	5b                   	pop    %ebx
f0102636:	5e                   	pop    %esi
f0102637:	5f                   	pop    %edi
f0102638:	5d                   	pop    %ebp
f0102639:	c3                   	ret    

f010263a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010263a:	55                   	push   %ebp
f010263b:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010263d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102640:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102643:	5d                   	pop    %ebp
f0102644:	c3                   	ret    

f0102645 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102645:	55                   	push   %ebp
f0102646:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102648:	ba 70 00 00 00       	mov    $0x70,%edx
f010264d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102650:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102651:	ba 71 00 00 00       	mov    $0x71,%edx
f0102656:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102657:	0f b6 c0             	movzbl %al,%eax
}
f010265a:	5d                   	pop    %ebp
f010265b:	c3                   	ret    

f010265c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010265c:	55                   	push   %ebp
f010265d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010265f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102664:	8b 45 08             	mov    0x8(%ebp),%eax
f0102667:	ee                   	out    %al,(%dx)
f0102668:	ba 71 00 00 00       	mov    $0x71,%edx
f010266d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102670:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102671:	5d                   	pop    %ebp
f0102672:	c3                   	ret    

f0102673 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102673:	55                   	push   %ebp
f0102674:	89 e5                	mov    %esp,%ebp
f0102676:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102679:	ff 75 08             	pushl  0x8(%ebp)
f010267c:	e8 71 df ff ff       	call   f01005f2 <cputchar>
	*cnt++;
}
f0102681:	83 c4 10             	add    $0x10,%esp
f0102684:	c9                   	leave  
f0102685:	c3                   	ret    

f0102686 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102686:	55                   	push   %ebp
f0102687:	89 e5                	mov    %esp,%ebp
f0102689:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010268c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102693:	ff 75 0c             	pushl  0xc(%ebp)
f0102696:	ff 75 08             	pushl  0x8(%ebp)
f0102699:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010269c:	50                   	push   %eax
f010269d:	68 73 26 10 f0       	push   $0xf0102673
f01026a2:	e8 71 04 00 00       	call   f0102b18 <vprintfmt>
	return cnt;
}
f01026a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026aa:	c9                   	leave  
f01026ab:	c3                   	ret    

f01026ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01026ac:	55                   	push   %ebp
f01026ad:	89 e5                	mov    %esp,%ebp
f01026af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01026b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01026b5:	50                   	push   %eax
f01026b6:	ff 75 08             	pushl  0x8(%ebp)
f01026b9:	e8 c8 ff ff ff       	call   f0102686 <vcprintf>
	va_end(ap);

	return cnt;
}
f01026be:	c9                   	leave  
f01026bf:	c3                   	ret    

f01026c0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01026c0:	55                   	push   %ebp
f01026c1:	89 e5                	mov    %esp,%ebp
f01026c3:	57                   	push   %edi
f01026c4:	56                   	push   %esi
f01026c5:	53                   	push   %ebx
f01026c6:	83 ec 14             	sub    $0x14,%esp
f01026c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01026cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01026cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01026d2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01026d5:	8b 1a                	mov    (%edx),%ebx
f01026d7:	8b 01                	mov    (%ecx),%eax
f01026d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01026dc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01026e3:	eb 7f                	jmp    f0102764 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01026e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01026e8:	01 d8                	add    %ebx,%eax
f01026ea:	89 c6                	mov    %eax,%esi
f01026ec:	c1 ee 1f             	shr    $0x1f,%esi
f01026ef:	01 c6                	add    %eax,%esi
f01026f1:	d1 fe                	sar    %esi
f01026f3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01026f6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01026f9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01026fc:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01026fe:	eb 03                	jmp    f0102703 <stab_binsearch+0x43>
			m--;
f0102700:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102703:	39 c3                	cmp    %eax,%ebx
f0102705:	7f 0d                	jg     f0102714 <stab_binsearch+0x54>
f0102707:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010270b:	83 ea 0c             	sub    $0xc,%edx
f010270e:	39 f9                	cmp    %edi,%ecx
f0102710:	75 ee                	jne    f0102700 <stab_binsearch+0x40>
f0102712:	eb 05                	jmp    f0102719 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102714:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102717:	eb 4b                	jmp    f0102764 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102719:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010271c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010271f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102723:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102726:	76 11                	jbe    f0102739 <stab_binsearch+0x79>
			*region_left = m;
f0102728:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010272b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010272d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102730:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102737:	eb 2b                	jmp    f0102764 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102739:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010273c:	73 14                	jae    f0102752 <stab_binsearch+0x92>
			*region_right = m - 1;
f010273e:	83 e8 01             	sub    $0x1,%eax
f0102741:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102744:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102747:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102749:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102750:	eb 12                	jmp    f0102764 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102752:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102755:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102757:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010275b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010275d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102764:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102767:	0f 8e 78 ff ff ff    	jle    f01026e5 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010276d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102771:	75 0f                	jne    f0102782 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102776:	8b 00                	mov    (%eax),%eax
f0102778:	83 e8 01             	sub    $0x1,%eax
f010277b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010277e:	89 06                	mov    %eax,(%esi)
f0102780:	eb 2c                	jmp    f01027ae <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102782:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102785:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102787:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010278a:	8b 0e                	mov    (%esi),%ecx
f010278c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010278f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102792:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102795:	eb 03                	jmp    f010279a <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102797:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010279a:	39 c8                	cmp    %ecx,%eax
f010279c:	7e 0b                	jle    f01027a9 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010279e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01027a2:	83 ea 0c             	sub    $0xc,%edx
f01027a5:	39 df                	cmp    %ebx,%edi
f01027a7:	75 ee                	jne    f0102797 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01027a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027ac:	89 06                	mov    %eax,(%esi)
	}
}
f01027ae:	83 c4 14             	add    $0x14,%esp
f01027b1:	5b                   	pop    %ebx
f01027b2:	5e                   	pop    %esi
f01027b3:	5f                   	pop    %edi
f01027b4:	5d                   	pop    %ebp
f01027b5:	c3                   	ret    

f01027b6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01027b6:	55                   	push   %ebp
f01027b7:	89 e5                	mov    %esp,%ebp
f01027b9:	57                   	push   %edi
f01027ba:	56                   	push   %esi
f01027bb:	53                   	push   %ebx
f01027bc:	83 ec 3c             	sub    $0x3c,%esp
f01027bf:	8b 75 08             	mov    0x8(%ebp),%esi
f01027c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file="<unknown>";
f01027c5:	c7 03 61 45 10 f0    	movl   $0xf0104561,(%ebx)
	info->eip_line = 0;
f01027cb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01027d2:	c7 43 08 61 45 10 f0 	movl   $0xf0104561,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01027d9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01027e0:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01027e3:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01027ea:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01027f0:	76 11                	jbe    f0102803 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01027f2:	b8 08 be 10 f0       	mov    $0xf010be08,%eax
f01027f7:	3d 3d a0 10 f0       	cmp    $0xf010a03d,%eax
f01027fc:	77 19                	ja     f0102817 <debuginfo_eip+0x61>
f01027fe:	e9 c9 01 00 00       	jmp    f01029cc <debuginfo_eip+0x216>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102803:	83 ec 04             	sub    $0x4,%esp
f0102806:	68 6b 45 10 f0       	push   $0xf010456b
f010280b:	6a 7f                	push   $0x7f
f010280d:	68 78 45 10 f0       	push   $0xf0104578
f0102812:	e8 74 d8 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102817:	80 3d 07 be 10 f0 00 	cmpb   $0x0,0xf010be07
f010281e:	0f 85 af 01 00 00    	jne    f01029d3 <debuginfo_eip+0x21d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102824:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010282b:	b8 3c a0 10 f0       	mov    $0xf010a03c,%eax
f0102830:	2d b0 47 10 f0       	sub    $0xf01047b0,%eax
f0102835:	c1 f8 02             	sar    $0x2,%eax
f0102838:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010283e:	83 e8 01             	sub    $0x1,%eax
f0102841:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102844:	83 ec 08             	sub    $0x8,%esp
f0102847:	56                   	push   %esi
f0102848:	6a 64                	push   $0x64
f010284a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010284d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102850:	b8 b0 47 10 f0       	mov    $0xf01047b0,%eax
f0102855:	e8 66 fe ff ff       	call   f01026c0 <stab_binsearch>
	if (lfile == 0)
f010285a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010285d:	83 c4 10             	add    $0x10,%esp
f0102860:	85 c0                	test   %eax,%eax
f0102862:	0f 84 72 01 00 00    	je     f01029da <debuginfo_eip+0x224>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102868:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010286b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010286e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102871:	83 ec 08             	sub    $0x8,%esp
f0102874:	56                   	push   %esi
f0102875:	6a 24                	push   $0x24
f0102877:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010287a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010287d:	b8 b0 47 10 f0       	mov    $0xf01047b0,%eax
f0102882:	e8 39 fe ff ff       	call   f01026c0 <stab_binsearch>

	if (lfun <= rfun) {
f0102887:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010288a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010288d:	83 c4 10             	add    $0x10,%esp
f0102890:	39 d0                	cmp    %edx,%eax
f0102892:	7f 40                	jg     f01028d4 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102894:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102897:	c1 e1 02             	shl    $0x2,%ecx
f010289a:	8d b9 b0 47 10 f0    	lea    -0xfefb850(%ecx),%edi
f01028a0:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01028a3:	8b b9 b0 47 10 f0    	mov    -0xfefb850(%ecx),%edi
f01028a9:	b9 08 be 10 f0       	mov    $0xf010be08,%ecx
f01028ae:	81 e9 3d a0 10 f0    	sub    $0xf010a03d,%ecx
f01028b4:	39 cf                	cmp    %ecx,%edi
f01028b6:	73 09                	jae    f01028c1 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01028b8:	81 c7 3d a0 10 f0    	add    $0xf010a03d,%edi
f01028be:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01028c1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01028c4:	8b 4f 08             	mov    0x8(%edi),%ecx
f01028c7:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01028ca:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01028cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01028cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01028d2:	eb 0f                	jmp    f01028e3 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01028d4:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01028d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01028dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01028e3:	83 ec 08             	sub    $0x8,%esp
f01028e6:	6a 3a                	push   $0x3a
f01028e8:	ff 73 08             	pushl  0x8(%ebx)
f01028eb:	e8 78 08 00 00       	call   f0103168 <strfind>
f01028f0:	2b 43 08             	sub    0x8(%ebx),%eax
f01028f3:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
f01028f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028f9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01028fc:	8b 04 85 b0 47 10 f0 	mov    -0xfefb850(,%eax,4),%eax
f0102903:	05 3d a0 10 f0       	add    $0xf010a03d,%eax
f0102908:	89 03                	mov    %eax,(%ebx)
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f010290a:	83 c4 08             	add    $0x8,%esp
f010290d:	56                   	push   %esi
f010290e:	6a 44                	push   $0x44
f0102910:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102913:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102916:	b8 b0 47 10 f0       	mov    $0xf01047b0,%eax
f010291b:	e8 a0 fd ff ff       	call   f01026c0 <stab_binsearch>
	if(lline>rline){
f0102920:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102923:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102926:	83 c4 10             	add    $0x10,%esp
f0102929:	39 d0                	cmp    %edx,%eax
f010292b:	0f 8f b0 00 00 00    	jg     f01029e1 <debuginfo_eip+0x22b>
	return -1;
	}
	else{
	info->eip_line=stabs[rline].n_desc;
f0102931:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102934:	0f b7 14 95 b6 47 10 	movzwl -0xfefb84a(,%edx,4),%edx
f010293b:	f0 
f010293c:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010293f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102942:	89 c2                	mov    %eax,%edx
f0102944:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102947:	8d 04 85 b0 47 10 f0 	lea    -0xfefb850(,%eax,4),%eax
f010294e:	eb 06                	jmp    f0102956 <debuginfo_eip+0x1a0>
f0102950:	83 ea 01             	sub    $0x1,%edx
f0102953:	83 e8 0c             	sub    $0xc,%eax
f0102956:	39 d7                	cmp    %edx,%edi
f0102958:	7f 34                	jg     f010298e <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f010295a:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f010295e:	80 f9 84             	cmp    $0x84,%cl
f0102961:	74 0b                	je     f010296e <debuginfo_eip+0x1b8>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102963:	80 f9 64             	cmp    $0x64,%cl
f0102966:	75 e8                	jne    f0102950 <debuginfo_eip+0x19a>
f0102968:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f010296c:	74 e2                	je     f0102950 <debuginfo_eip+0x19a>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010296e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102971:	8b 14 85 b0 47 10 f0 	mov    -0xfefb850(,%eax,4),%edx
f0102978:	b8 08 be 10 f0       	mov    $0xf010be08,%eax
f010297d:	2d 3d a0 10 f0       	sub    $0xf010a03d,%eax
f0102982:	39 c2                	cmp    %eax,%edx
f0102984:	73 08                	jae    f010298e <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102986:	81 c2 3d a0 10 f0    	add    $0xf010a03d,%edx
f010298c:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010298e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102991:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102994:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102999:	39 f2                	cmp    %esi,%edx
f010299b:	7d 50                	jge    f01029ed <debuginfo_eip+0x237>
		for (lline = lfun + 1;
f010299d:	83 c2 01             	add    $0x1,%edx
f01029a0:	89 d0                	mov    %edx,%eax
f01029a2:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01029a5:	8d 14 95 b0 47 10 f0 	lea    -0xfefb850(,%edx,4),%edx
f01029ac:	eb 04                	jmp    f01029b2 <debuginfo_eip+0x1fc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01029ae:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01029b2:	39 c6                	cmp    %eax,%esi
f01029b4:	7e 32                	jle    f01029e8 <debuginfo_eip+0x232>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01029b6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01029ba:	83 c0 01             	add    $0x1,%eax
f01029bd:	83 c2 0c             	add    $0xc,%edx
f01029c0:	80 f9 a0             	cmp    $0xa0,%cl
f01029c3:	74 e9                	je     f01029ae <debuginfo_eip+0x1f8>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01029ca:	eb 21                	jmp    f01029ed <debuginfo_eip+0x237>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01029cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029d1:	eb 1a                	jmp    f01029ed <debuginfo_eip+0x237>
f01029d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029d8:	eb 13                	jmp    f01029ed <debuginfo_eip+0x237>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01029da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029df:	eb 0c                	jmp    f01029ed <debuginfo_eip+0x237>
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
	if(lline>rline){
	return -1;
f01029e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029e6:	eb 05                	jmp    f01029ed <debuginfo_eip+0x237>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029f0:	5b                   	pop    %ebx
f01029f1:	5e                   	pop    %esi
f01029f2:	5f                   	pop    %edi
f01029f3:	5d                   	pop    %ebp
f01029f4:	c3                   	ret    

f01029f5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01029f5:	55                   	push   %ebp
f01029f6:	89 e5                	mov    %esp,%ebp
f01029f8:	57                   	push   %edi
f01029f9:	56                   	push   %esi
f01029fa:	53                   	push   %ebx
f01029fb:	83 ec 1c             	sub    $0x1c,%esp
f01029fe:	89 c7                	mov    %eax,%edi
f0102a00:	89 d6                	mov    %edx,%esi
f0102a02:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a05:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102a08:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102a0b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102a11:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102a16:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102a19:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102a1c:	39 d3                	cmp    %edx,%ebx
f0102a1e:	72 05                	jb     f0102a25 <printnum+0x30>
f0102a20:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102a23:	77 45                	ja     f0102a6a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102a25:	83 ec 0c             	sub    $0xc,%esp
f0102a28:	ff 75 18             	pushl  0x18(%ebp)
f0102a2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102a2e:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102a31:	53                   	push   %ebx
f0102a32:	ff 75 10             	pushl  0x10(%ebp)
f0102a35:	83 ec 08             	sub    $0x8,%esp
f0102a38:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a3b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a3e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a41:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a44:	e8 47 09 00 00       	call   f0103390 <__udivdi3>
f0102a49:	83 c4 18             	add    $0x18,%esp
f0102a4c:	52                   	push   %edx
f0102a4d:	50                   	push   %eax
f0102a4e:	89 f2                	mov    %esi,%edx
f0102a50:	89 f8                	mov    %edi,%eax
f0102a52:	e8 9e ff ff ff       	call   f01029f5 <printnum>
f0102a57:	83 c4 20             	add    $0x20,%esp
f0102a5a:	eb 18                	jmp    f0102a74 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102a5c:	83 ec 08             	sub    $0x8,%esp
f0102a5f:	56                   	push   %esi
f0102a60:	ff 75 18             	pushl  0x18(%ebp)
f0102a63:	ff d7                	call   *%edi
f0102a65:	83 c4 10             	add    $0x10,%esp
f0102a68:	eb 03                	jmp    f0102a6d <printnum+0x78>
f0102a6a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102a6d:	83 eb 01             	sub    $0x1,%ebx
f0102a70:	85 db                	test   %ebx,%ebx
f0102a72:	7f e8                	jg     f0102a5c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102a74:	83 ec 08             	sub    $0x8,%esp
f0102a77:	56                   	push   %esi
f0102a78:	83 ec 04             	sub    $0x4,%esp
f0102a7b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a81:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a84:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a87:	e8 34 0a 00 00       	call   f01034c0 <__umoddi3>
f0102a8c:	83 c4 14             	add    $0x14,%esp
f0102a8f:	0f be 80 86 45 10 f0 	movsbl -0xfefba7a(%eax),%eax
f0102a96:	50                   	push   %eax
f0102a97:	ff d7                	call   *%edi
}
f0102a99:	83 c4 10             	add    $0x10,%esp
f0102a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a9f:	5b                   	pop    %ebx
f0102aa0:	5e                   	pop    %esi
f0102aa1:	5f                   	pop    %edi
f0102aa2:	5d                   	pop    %ebp
f0102aa3:	c3                   	ret    

f0102aa4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102aa4:	55                   	push   %ebp
f0102aa5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102aa7:	83 fa 01             	cmp    $0x1,%edx
f0102aaa:	7e 0e                	jle    f0102aba <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102aac:	8b 10                	mov    (%eax),%edx
f0102aae:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102ab1:	89 08                	mov    %ecx,(%eax)
f0102ab3:	8b 02                	mov    (%edx),%eax
f0102ab5:	8b 52 04             	mov    0x4(%edx),%edx
f0102ab8:	eb 22                	jmp    f0102adc <getuint+0x38>
	else if (lflag)
f0102aba:	85 d2                	test   %edx,%edx
f0102abc:	74 10                	je     f0102ace <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102abe:	8b 10                	mov    (%eax),%edx
f0102ac0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ac3:	89 08                	mov    %ecx,(%eax)
f0102ac5:	8b 02                	mov    (%edx),%eax
f0102ac7:	ba 00 00 00 00       	mov    $0x0,%edx
f0102acc:	eb 0e                	jmp    f0102adc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102ace:	8b 10                	mov    (%eax),%edx
f0102ad0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102ad3:	89 08                	mov    %ecx,(%eax)
f0102ad5:	8b 02                	mov    (%edx),%eax
f0102ad7:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102adc:	5d                   	pop    %ebp
f0102add:	c3                   	ret    

f0102ade <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102ade:	55                   	push   %ebp
f0102adf:	89 e5                	mov    %esp,%ebp
f0102ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102ae4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102ae8:	8b 10                	mov    (%eax),%edx
f0102aea:	3b 50 04             	cmp    0x4(%eax),%edx
f0102aed:	73 0a                	jae    f0102af9 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102aef:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102af2:	89 08                	mov    %ecx,(%eax)
f0102af4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102af7:	88 02                	mov    %al,(%edx)
}
f0102af9:	5d                   	pop    %ebp
f0102afa:	c3                   	ret    

f0102afb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102afb:	55                   	push   %ebp
f0102afc:	89 e5                	mov    %esp,%ebp
f0102afe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b01:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b04:	50                   	push   %eax
f0102b05:	ff 75 10             	pushl  0x10(%ebp)
f0102b08:	ff 75 0c             	pushl  0xc(%ebp)
f0102b0b:	ff 75 08             	pushl  0x8(%ebp)
f0102b0e:	e8 05 00 00 00       	call   f0102b18 <vprintfmt>
	va_end(ap);
}
f0102b13:	83 c4 10             	add    $0x10,%esp
f0102b16:	c9                   	leave  
f0102b17:	c3                   	ret    

f0102b18 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102b18:	55                   	push   %ebp
f0102b19:	89 e5                	mov    %esp,%ebp
f0102b1b:	57                   	push   %edi
f0102b1c:	56                   	push   %esi
f0102b1d:	53                   	push   %ebx
f0102b1e:	83 ec 2c             	sub    $0x2c,%esp
f0102b21:	8b 75 08             	mov    0x8(%ebp),%esi
f0102b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b27:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102b2a:	eb 12                	jmp    f0102b3e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102b2c:	85 c0                	test   %eax,%eax
f0102b2e:	0f 84 89 03 00 00    	je     f0102ebd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102b34:	83 ec 08             	sub    $0x8,%esp
f0102b37:	53                   	push   %ebx
f0102b38:	50                   	push   %eax
f0102b39:	ff d6                	call   *%esi
f0102b3b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102b3e:	83 c7 01             	add    $0x1,%edi
f0102b41:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102b45:	83 f8 25             	cmp    $0x25,%eax
f0102b48:	75 e2                	jne    f0102b2c <vprintfmt+0x14>
f0102b4a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102b4e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102b55:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102b5c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102b63:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b68:	eb 07                	jmp    f0102b71 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102b6d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b71:	8d 47 01             	lea    0x1(%edi),%eax
f0102b74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102b77:	0f b6 07             	movzbl (%edi),%eax
f0102b7a:	0f b6 c8             	movzbl %al,%ecx
f0102b7d:	83 e8 23             	sub    $0x23,%eax
f0102b80:	3c 55                	cmp    $0x55,%al
f0102b82:	0f 87 1a 03 00 00    	ja     f0102ea2 <vprintfmt+0x38a>
f0102b88:	0f b6 c0             	movzbl %al,%eax
f0102b8b:	ff 24 85 20 46 10 f0 	jmp    *-0xfefb9e0(,%eax,4)
f0102b92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102b95:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102b99:	eb d6                	jmp    f0102b71 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102b9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ba3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102ba6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102ba9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102bad:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102bb0:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102bb3:	83 fa 09             	cmp    $0x9,%edx
f0102bb6:	77 39                	ja     f0102bf1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102bb8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102bbb:	eb e9                	jmp    f0102ba6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102bbd:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bc0:	8d 48 04             	lea    0x4(%eax),%ecx
f0102bc3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102bc6:	8b 00                	mov    (%eax),%eax
f0102bc8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102bce:	eb 27                	jmp    f0102bf7 <vprintfmt+0xdf>
f0102bd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102bd3:	85 c0                	test   %eax,%eax
f0102bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102bda:	0f 49 c8             	cmovns %eax,%ecx
f0102bdd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102be0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102be3:	eb 8c                	jmp    f0102b71 <vprintfmt+0x59>
f0102be5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102be8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102bef:	eb 80                	jmp    f0102b71 <vprintfmt+0x59>
f0102bf1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102bf4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102bf7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102bfb:	0f 89 70 ff ff ff    	jns    f0102b71 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102c01:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c04:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102c07:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c0e:	e9 5e ff ff ff       	jmp    f0102b71 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102c13:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102c19:	e9 53 ff ff ff       	jmp    f0102b71 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102c1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c21:	8d 50 04             	lea    0x4(%eax),%edx
f0102c24:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c27:	83 ec 08             	sub    $0x8,%esp
f0102c2a:	53                   	push   %ebx
f0102c2b:	ff 30                	pushl  (%eax)
f0102c2d:	ff d6                	call   *%esi
			break;
f0102c2f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102c35:	e9 04 ff ff ff       	jmp    f0102b3e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102c3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c3d:	8d 50 04             	lea    0x4(%eax),%edx
f0102c40:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c43:	8b 00                	mov    (%eax),%eax
f0102c45:	99                   	cltd   
f0102c46:	31 d0                	xor    %edx,%eax
f0102c48:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102c4a:	83 f8 07             	cmp    $0x7,%eax
f0102c4d:	7f 0b                	jg     f0102c5a <vprintfmt+0x142>
f0102c4f:	8b 14 85 80 47 10 f0 	mov    -0xfefb880(,%eax,4),%edx
f0102c56:	85 d2                	test   %edx,%edx
f0102c58:	75 18                	jne    f0102c72 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102c5a:	50                   	push   %eax
f0102c5b:	68 9e 45 10 f0       	push   $0xf010459e
f0102c60:	53                   	push   %ebx
f0102c61:	56                   	push   %esi
f0102c62:	e8 94 fe ff ff       	call   f0102afb <printfmt>
f0102c67:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102c6d:	e9 cc fe ff ff       	jmp    f0102b3e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102c72:	52                   	push   %edx
f0102c73:	68 b8 42 10 f0       	push   $0xf01042b8
f0102c78:	53                   	push   %ebx
f0102c79:	56                   	push   %esi
f0102c7a:	e8 7c fe ff ff       	call   f0102afb <printfmt>
f0102c7f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c85:	e9 b4 fe ff ff       	jmp    f0102b3e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102c8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c8d:	8d 50 04             	lea    0x4(%eax),%edx
f0102c90:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c93:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102c95:	85 ff                	test   %edi,%edi
f0102c97:	b8 97 45 10 f0       	mov    $0xf0104597,%eax
f0102c9c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102c9f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102ca3:	0f 8e 94 00 00 00    	jle    f0102d3d <vprintfmt+0x225>
f0102ca9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102cad:	0f 84 98 00 00 00    	je     f0102d4b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cb3:	83 ec 08             	sub    $0x8,%esp
f0102cb6:	ff 75 d0             	pushl  -0x30(%ebp)
f0102cb9:	57                   	push   %edi
f0102cba:	e8 5f 03 00 00       	call   f010301e <strnlen>
f0102cbf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102cc2:	29 c1                	sub    %eax,%ecx
f0102cc4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102cc7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102cca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102cce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102cd1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102cd4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cd6:	eb 0f                	jmp    f0102ce7 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102cd8:	83 ec 08             	sub    $0x8,%esp
f0102cdb:	53                   	push   %ebx
f0102cdc:	ff 75 e0             	pushl  -0x20(%ebp)
f0102cdf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ce1:	83 ef 01             	sub    $0x1,%edi
f0102ce4:	83 c4 10             	add    $0x10,%esp
f0102ce7:	85 ff                	test   %edi,%edi
f0102ce9:	7f ed                	jg     f0102cd8 <vprintfmt+0x1c0>
f0102ceb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102cee:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102cf1:	85 c9                	test   %ecx,%ecx
f0102cf3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cf8:	0f 49 c1             	cmovns %ecx,%eax
f0102cfb:	29 c1                	sub    %eax,%ecx
f0102cfd:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d00:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d03:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d06:	89 cb                	mov    %ecx,%ebx
f0102d08:	eb 4d                	jmp    f0102d57 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102d0a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102d0e:	74 1b                	je     f0102d2b <vprintfmt+0x213>
f0102d10:	0f be c0             	movsbl %al,%eax
f0102d13:	83 e8 20             	sub    $0x20,%eax
f0102d16:	83 f8 5e             	cmp    $0x5e,%eax
f0102d19:	76 10                	jbe    f0102d2b <vprintfmt+0x213>
					putch('?', putdat);
f0102d1b:	83 ec 08             	sub    $0x8,%esp
f0102d1e:	ff 75 0c             	pushl  0xc(%ebp)
f0102d21:	6a 3f                	push   $0x3f
f0102d23:	ff 55 08             	call   *0x8(%ebp)
f0102d26:	83 c4 10             	add    $0x10,%esp
f0102d29:	eb 0d                	jmp    f0102d38 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102d2b:	83 ec 08             	sub    $0x8,%esp
f0102d2e:	ff 75 0c             	pushl  0xc(%ebp)
f0102d31:	52                   	push   %edx
f0102d32:	ff 55 08             	call   *0x8(%ebp)
f0102d35:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d38:	83 eb 01             	sub    $0x1,%ebx
f0102d3b:	eb 1a                	jmp    f0102d57 <vprintfmt+0x23f>
f0102d3d:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d40:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d43:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d46:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d49:	eb 0c                	jmp    f0102d57 <vprintfmt+0x23f>
f0102d4b:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d4e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d51:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d54:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d57:	83 c7 01             	add    $0x1,%edi
f0102d5a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102d5e:	0f be d0             	movsbl %al,%edx
f0102d61:	85 d2                	test   %edx,%edx
f0102d63:	74 23                	je     f0102d88 <vprintfmt+0x270>
f0102d65:	85 f6                	test   %esi,%esi
f0102d67:	78 a1                	js     f0102d0a <vprintfmt+0x1f2>
f0102d69:	83 ee 01             	sub    $0x1,%esi
f0102d6c:	79 9c                	jns    f0102d0a <vprintfmt+0x1f2>
f0102d6e:	89 df                	mov    %ebx,%edi
f0102d70:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d76:	eb 18                	jmp    f0102d90 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102d78:	83 ec 08             	sub    $0x8,%esp
f0102d7b:	53                   	push   %ebx
f0102d7c:	6a 20                	push   $0x20
f0102d7e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102d80:	83 ef 01             	sub    $0x1,%edi
f0102d83:	83 c4 10             	add    $0x10,%esp
f0102d86:	eb 08                	jmp    f0102d90 <vprintfmt+0x278>
f0102d88:	89 df                	mov    %ebx,%edi
f0102d8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d90:	85 ff                	test   %edi,%edi
f0102d92:	7f e4                	jg     f0102d78 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d97:	e9 a2 fd ff ff       	jmp    f0102b3e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102d9c:	83 fa 01             	cmp    $0x1,%edx
f0102d9f:	7e 16                	jle    f0102db7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102da1:	8b 45 14             	mov    0x14(%ebp),%eax
f0102da4:	8d 50 08             	lea    0x8(%eax),%edx
f0102da7:	89 55 14             	mov    %edx,0x14(%ebp)
f0102daa:	8b 50 04             	mov    0x4(%eax),%edx
f0102dad:	8b 00                	mov    (%eax),%eax
f0102daf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102db2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102db5:	eb 32                	jmp    f0102de9 <vprintfmt+0x2d1>
	else if (lflag)
f0102db7:	85 d2                	test   %edx,%edx
f0102db9:	74 18                	je     f0102dd3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102dbb:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dbe:	8d 50 04             	lea    0x4(%eax),%edx
f0102dc1:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dc4:	8b 00                	mov    (%eax),%eax
f0102dc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dc9:	89 c1                	mov    %eax,%ecx
f0102dcb:	c1 f9 1f             	sar    $0x1f,%ecx
f0102dce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102dd1:	eb 16                	jmp    f0102de9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102dd3:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dd6:	8d 50 04             	lea    0x4(%eax),%edx
f0102dd9:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ddc:	8b 00                	mov    (%eax),%eax
f0102dde:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102de1:	89 c1                	mov    %eax,%ecx
f0102de3:	c1 f9 1f             	sar    $0x1f,%ecx
f0102de6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102de9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102def:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102df4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102df8:	79 74                	jns    f0102e6e <vprintfmt+0x356>
				putch('-', putdat);
f0102dfa:	83 ec 08             	sub    $0x8,%esp
f0102dfd:	53                   	push   %ebx
f0102dfe:	6a 2d                	push   $0x2d
f0102e00:	ff d6                	call   *%esi
				num = -(long long) num;
f0102e02:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e05:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e08:	f7 d8                	neg    %eax
f0102e0a:	83 d2 00             	adc    $0x0,%edx
f0102e0d:	f7 da                	neg    %edx
f0102e0f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102e12:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102e17:	eb 55                	jmp    f0102e6e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102e19:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e1c:	e8 83 fc ff ff       	call   f0102aa4 <getuint>
			base = 10;
f0102e21:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102e26:	eb 46                	jmp    f0102e6e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0102e28:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e2b:	e8 74 fc ff ff       	call   f0102aa4 <getuint>
			base = 8;
f0102e30:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102e35:	eb 37                	jmp    f0102e6e <vprintfmt+0x356>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0102e37:	83 ec 08             	sub    $0x8,%esp
f0102e3a:	53                   	push   %ebx
f0102e3b:	6a 30                	push   $0x30
f0102e3d:	ff d6                	call   *%esi
			putch('x', putdat);
f0102e3f:	83 c4 08             	add    $0x8,%esp
f0102e42:	53                   	push   %ebx
f0102e43:	6a 78                	push   $0x78
f0102e45:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102e47:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e4a:	8d 50 04             	lea    0x4(%eax),%edx
f0102e4d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102e50:	8b 00                	mov    (%eax),%eax
f0102e52:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102e57:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102e5a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102e5f:	eb 0d                	jmp    f0102e6e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102e61:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e64:	e8 3b fc ff ff       	call   f0102aa4 <getuint>
			base = 16;
f0102e69:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102e6e:	83 ec 0c             	sub    $0xc,%esp
f0102e71:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102e75:	57                   	push   %edi
f0102e76:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e79:	51                   	push   %ecx
f0102e7a:	52                   	push   %edx
f0102e7b:	50                   	push   %eax
f0102e7c:	89 da                	mov    %ebx,%edx
f0102e7e:	89 f0                	mov    %esi,%eax
f0102e80:	e8 70 fb ff ff       	call   f01029f5 <printnum>
			break;
f0102e85:	83 c4 20             	add    $0x20,%esp
f0102e88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e8b:	e9 ae fc ff ff       	jmp    f0102b3e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102e90:	83 ec 08             	sub    $0x8,%esp
f0102e93:	53                   	push   %ebx
f0102e94:	51                   	push   %ecx
f0102e95:	ff d6                	call   *%esi
			break;
f0102e97:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102e9d:	e9 9c fc ff ff       	jmp    f0102b3e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102ea2:	83 ec 08             	sub    $0x8,%esp
f0102ea5:	53                   	push   %ebx
f0102ea6:	6a 25                	push   $0x25
f0102ea8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102eaa:	83 c4 10             	add    $0x10,%esp
f0102ead:	eb 03                	jmp    f0102eb2 <vprintfmt+0x39a>
f0102eaf:	83 ef 01             	sub    $0x1,%edi
f0102eb2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102eb6:	75 f7                	jne    f0102eaf <vprintfmt+0x397>
f0102eb8:	e9 81 fc ff ff       	jmp    f0102b3e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102ebd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ec0:	5b                   	pop    %ebx
f0102ec1:	5e                   	pop    %esi
f0102ec2:	5f                   	pop    %edi
f0102ec3:	5d                   	pop    %ebp
f0102ec4:	c3                   	ret    

f0102ec5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102ec5:	55                   	push   %ebp
f0102ec6:	89 e5                	mov    %esp,%ebp
f0102ec8:	83 ec 18             	sub    $0x18,%esp
f0102ecb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ece:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ed1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ed4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102ed8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102edb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102ee2:	85 c0                	test   %eax,%eax
f0102ee4:	74 26                	je     f0102f0c <vsnprintf+0x47>
f0102ee6:	85 d2                	test   %edx,%edx
f0102ee8:	7e 22                	jle    f0102f0c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102eea:	ff 75 14             	pushl  0x14(%ebp)
f0102eed:	ff 75 10             	pushl  0x10(%ebp)
f0102ef0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102ef3:	50                   	push   %eax
f0102ef4:	68 de 2a 10 f0       	push   $0xf0102ade
f0102ef9:	e8 1a fc ff ff       	call   f0102b18 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102efe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f01:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f07:	83 c4 10             	add    $0x10,%esp
f0102f0a:	eb 05                	jmp    f0102f11 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102f11:	c9                   	leave  
f0102f12:	c3                   	ret    

f0102f13 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102f13:	55                   	push   %ebp
f0102f14:	89 e5                	mov    %esp,%ebp
f0102f16:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102f19:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102f1c:	50                   	push   %eax
f0102f1d:	ff 75 10             	pushl  0x10(%ebp)
f0102f20:	ff 75 0c             	pushl  0xc(%ebp)
f0102f23:	ff 75 08             	pushl  0x8(%ebp)
f0102f26:	e8 9a ff ff ff       	call   f0102ec5 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102f2b:	c9                   	leave  
f0102f2c:	c3                   	ret    

f0102f2d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102f2d:	55                   	push   %ebp
f0102f2e:	89 e5                	mov    %esp,%ebp
f0102f30:	57                   	push   %edi
f0102f31:	56                   	push   %esi
f0102f32:	53                   	push   %ebx
f0102f33:	83 ec 0c             	sub    $0xc,%esp
f0102f36:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f39:	85 c0                	test   %eax,%eax
f0102f3b:	74 11                	je     f0102f4e <readline+0x21>
		cprintf("%s", prompt);
f0102f3d:	83 ec 08             	sub    $0x8,%esp
f0102f40:	50                   	push   %eax
f0102f41:	68 b8 42 10 f0       	push   $0xf01042b8
f0102f46:	e8 61 f7 ff ff       	call   f01026ac <cprintf>
f0102f4b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f4e:	83 ec 0c             	sub    $0xc,%esp
f0102f51:	6a 00                	push   $0x0
f0102f53:	e8 bb d6 ff ff       	call   f0100613 <iscons>
f0102f58:	89 c7                	mov    %eax,%edi
f0102f5a:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102f5d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102f62:	e8 9b d6 ff ff       	call   f0100602 <getchar>
f0102f67:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102f69:	85 c0                	test   %eax,%eax
f0102f6b:	79 18                	jns    f0102f85 <readline+0x58>
			cprintf("read error: %e\n", c);
f0102f6d:	83 ec 08             	sub    $0x8,%esp
f0102f70:	50                   	push   %eax
f0102f71:	68 a0 47 10 f0       	push   $0xf01047a0
f0102f76:	e8 31 f7 ff ff       	call   f01026ac <cprintf>
			return NULL;
f0102f7b:	83 c4 10             	add    $0x10,%esp
f0102f7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f83:	eb 79                	jmp    f0102ffe <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102f85:	83 f8 08             	cmp    $0x8,%eax
f0102f88:	0f 94 c2             	sete   %dl
f0102f8b:	83 f8 7f             	cmp    $0x7f,%eax
f0102f8e:	0f 94 c0             	sete   %al
f0102f91:	08 c2                	or     %al,%dl
f0102f93:	74 1a                	je     f0102faf <readline+0x82>
f0102f95:	85 f6                	test   %esi,%esi
f0102f97:	7e 16                	jle    f0102faf <readline+0x82>
			if (echoing)
f0102f99:	85 ff                	test   %edi,%edi
f0102f9b:	74 0d                	je     f0102faa <readline+0x7d>
				cputchar('\b');
f0102f9d:	83 ec 0c             	sub    $0xc,%esp
f0102fa0:	6a 08                	push   $0x8
f0102fa2:	e8 4b d6 ff ff       	call   f01005f2 <cputchar>
f0102fa7:	83 c4 10             	add    $0x10,%esp
			i--;
f0102faa:	83 ee 01             	sub    $0x1,%esi
f0102fad:	eb b3                	jmp    f0102f62 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102faf:	83 fb 1f             	cmp    $0x1f,%ebx
f0102fb2:	7e 23                	jle    f0102fd7 <readline+0xaa>
f0102fb4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102fba:	7f 1b                	jg     f0102fd7 <readline+0xaa>
			if (echoing)
f0102fbc:	85 ff                	test   %edi,%edi
f0102fbe:	74 0c                	je     f0102fcc <readline+0x9f>
				cputchar(c);
f0102fc0:	83 ec 0c             	sub    $0xc,%esp
f0102fc3:	53                   	push   %ebx
f0102fc4:	e8 29 d6 ff ff       	call   f01005f2 <cputchar>
f0102fc9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102fcc:	88 9e 60 65 11 f0    	mov    %bl,-0xfee9aa0(%esi)
f0102fd2:	8d 76 01             	lea    0x1(%esi),%esi
f0102fd5:	eb 8b                	jmp    f0102f62 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102fd7:	83 fb 0a             	cmp    $0xa,%ebx
f0102fda:	74 05                	je     f0102fe1 <readline+0xb4>
f0102fdc:	83 fb 0d             	cmp    $0xd,%ebx
f0102fdf:	75 81                	jne    f0102f62 <readline+0x35>
			if (echoing)
f0102fe1:	85 ff                	test   %edi,%edi
f0102fe3:	74 0d                	je     f0102ff2 <readline+0xc5>
				cputchar('\n');
f0102fe5:	83 ec 0c             	sub    $0xc,%esp
f0102fe8:	6a 0a                	push   $0xa
f0102fea:	e8 03 d6 ff ff       	call   f01005f2 <cputchar>
f0102fef:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0102ff2:	c6 86 60 65 11 f0 00 	movb   $0x0,-0xfee9aa0(%esi)
			return buf;
f0102ff9:	b8 60 65 11 f0       	mov    $0xf0116560,%eax
		}
	}
}
f0102ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103001:	5b                   	pop    %ebx
f0103002:	5e                   	pop    %esi
f0103003:	5f                   	pop    %edi
f0103004:	5d                   	pop    %ebp
f0103005:	c3                   	ret    

f0103006 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103006:	55                   	push   %ebp
f0103007:	89 e5                	mov    %esp,%ebp
f0103009:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010300c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103011:	eb 03                	jmp    f0103016 <strlen+0x10>
		n++;
f0103013:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103016:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010301a:	75 f7                	jne    f0103013 <strlen+0xd>
		n++;
	return n;
}
f010301c:	5d                   	pop    %ebp
f010301d:	c3                   	ret    

f010301e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010301e:	55                   	push   %ebp
f010301f:	89 e5                	mov    %esp,%ebp
f0103021:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103024:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103027:	ba 00 00 00 00       	mov    $0x0,%edx
f010302c:	eb 03                	jmp    f0103031 <strnlen+0x13>
		n++;
f010302e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103031:	39 c2                	cmp    %eax,%edx
f0103033:	74 08                	je     f010303d <strnlen+0x1f>
f0103035:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103039:	75 f3                	jne    f010302e <strnlen+0x10>
f010303b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010303d:	5d                   	pop    %ebp
f010303e:	c3                   	ret    

f010303f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010303f:	55                   	push   %ebp
f0103040:	89 e5                	mov    %esp,%ebp
f0103042:	53                   	push   %ebx
f0103043:	8b 45 08             	mov    0x8(%ebp),%eax
f0103046:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103049:	89 c2                	mov    %eax,%edx
f010304b:	83 c2 01             	add    $0x1,%edx
f010304e:	83 c1 01             	add    $0x1,%ecx
f0103051:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103055:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103058:	84 db                	test   %bl,%bl
f010305a:	75 ef                	jne    f010304b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010305c:	5b                   	pop    %ebx
f010305d:	5d                   	pop    %ebp
f010305e:	c3                   	ret    

f010305f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010305f:	55                   	push   %ebp
f0103060:	89 e5                	mov    %esp,%ebp
f0103062:	53                   	push   %ebx
f0103063:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103066:	53                   	push   %ebx
f0103067:	e8 9a ff ff ff       	call   f0103006 <strlen>
f010306c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010306f:	ff 75 0c             	pushl  0xc(%ebp)
f0103072:	01 d8                	add    %ebx,%eax
f0103074:	50                   	push   %eax
f0103075:	e8 c5 ff ff ff       	call   f010303f <strcpy>
	return dst;
}
f010307a:	89 d8                	mov    %ebx,%eax
f010307c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010307f:	c9                   	leave  
f0103080:	c3                   	ret    

f0103081 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103081:	55                   	push   %ebp
f0103082:	89 e5                	mov    %esp,%ebp
f0103084:	56                   	push   %esi
f0103085:	53                   	push   %ebx
f0103086:	8b 75 08             	mov    0x8(%ebp),%esi
f0103089:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010308c:	89 f3                	mov    %esi,%ebx
f010308e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103091:	89 f2                	mov    %esi,%edx
f0103093:	eb 0f                	jmp    f01030a4 <strncpy+0x23>
		*dst++ = *src;
f0103095:	83 c2 01             	add    $0x1,%edx
f0103098:	0f b6 01             	movzbl (%ecx),%eax
f010309b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010309e:	80 39 01             	cmpb   $0x1,(%ecx)
f01030a1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01030a4:	39 da                	cmp    %ebx,%edx
f01030a6:	75 ed                	jne    f0103095 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01030a8:	89 f0                	mov    %esi,%eax
f01030aa:	5b                   	pop    %ebx
f01030ab:	5e                   	pop    %esi
f01030ac:	5d                   	pop    %ebp
f01030ad:	c3                   	ret    

f01030ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01030ae:	55                   	push   %ebp
f01030af:	89 e5                	mov    %esp,%ebp
f01030b1:	56                   	push   %esi
f01030b2:	53                   	push   %ebx
f01030b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01030b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030b9:	8b 55 10             	mov    0x10(%ebp),%edx
f01030bc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01030be:	85 d2                	test   %edx,%edx
f01030c0:	74 21                	je     f01030e3 <strlcpy+0x35>
f01030c2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01030c6:	89 f2                	mov    %esi,%edx
f01030c8:	eb 09                	jmp    f01030d3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01030ca:	83 c2 01             	add    $0x1,%edx
f01030cd:	83 c1 01             	add    $0x1,%ecx
f01030d0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01030d3:	39 c2                	cmp    %eax,%edx
f01030d5:	74 09                	je     f01030e0 <strlcpy+0x32>
f01030d7:	0f b6 19             	movzbl (%ecx),%ebx
f01030da:	84 db                	test   %bl,%bl
f01030dc:	75 ec                	jne    f01030ca <strlcpy+0x1c>
f01030de:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01030e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01030e3:	29 f0                	sub    %esi,%eax
}
f01030e5:	5b                   	pop    %ebx
f01030e6:	5e                   	pop    %esi
f01030e7:	5d                   	pop    %ebp
f01030e8:	c3                   	ret    

f01030e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01030e9:	55                   	push   %ebp
f01030ea:	89 e5                	mov    %esp,%ebp
f01030ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01030f2:	eb 06                	jmp    f01030fa <strcmp+0x11>
		p++, q++;
f01030f4:	83 c1 01             	add    $0x1,%ecx
f01030f7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01030fa:	0f b6 01             	movzbl (%ecx),%eax
f01030fd:	84 c0                	test   %al,%al
f01030ff:	74 04                	je     f0103105 <strcmp+0x1c>
f0103101:	3a 02                	cmp    (%edx),%al
f0103103:	74 ef                	je     f01030f4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103105:	0f b6 c0             	movzbl %al,%eax
f0103108:	0f b6 12             	movzbl (%edx),%edx
f010310b:	29 d0                	sub    %edx,%eax
}
f010310d:	5d                   	pop    %ebp
f010310e:	c3                   	ret    

f010310f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010310f:	55                   	push   %ebp
f0103110:	89 e5                	mov    %esp,%ebp
f0103112:	53                   	push   %ebx
f0103113:	8b 45 08             	mov    0x8(%ebp),%eax
f0103116:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103119:	89 c3                	mov    %eax,%ebx
f010311b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010311e:	eb 06                	jmp    f0103126 <strncmp+0x17>
		n--, p++, q++;
f0103120:	83 c0 01             	add    $0x1,%eax
f0103123:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103126:	39 d8                	cmp    %ebx,%eax
f0103128:	74 15                	je     f010313f <strncmp+0x30>
f010312a:	0f b6 08             	movzbl (%eax),%ecx
f010312d:	84 c9                	test   %cl,%cl
f010312f:	74 04                	je     f0103135 <strncmp+0x26>
f0103131:	3a 0a                	cmp    (%edx),%cl
f0103133:	74 eb                	je     f0103120 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103135:	0f b6 00             	movzbl (%eax),%eax
f0103138:	0f b6 12             	movzbl (%edx),%edx
f010313b:	29 d0                	sub    %edx,%eax
f010313d:	eb 05                	jmp    f0103144 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010313f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103144:	5b                   	pop    %ebx
f0103145:	5d                   	pop    %ebp
f0103146:	c3                   	ret    

f0103147 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103147:	55                   	push   %ebp
f0103148:	89 e5                	mov    %esp,%ebp
f010314a:	8b 45 08             	mov    0x8(%ebp),%eax
f010314d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103151:	eb 07                	jmp    f010315a <strchr+0x13>
		if (*s == c)
f0103153:	38 ca                	cmp    %cl,%dl
f0103155:	74 0f                	je     f0103166 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103157:	83 c0 01             	add    $0x1,%eax
f010315a:	0f b6 10             	movzbl (%eax),%edx
f010315d:	84 d2                	test   %dl,%dl
f010315f:	75 f2                	jne    f0103153 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103161:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103166:	5d                   	pop    %ebp
f0103167:	c3                   	ret    

f0103168 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103168:	55                   	push   %ebp
f0103169:	89 e5                	mov    %esp,%ebp
f010316b:	8b 45 08             	mov    0x8(%ebp),%eax
f010316e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103172:	eb 03                	jmp    f0103177 <strfind+0xf>
f0103174:	83 c0 01             	add    $0x1,%eax
f0103177:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010317a:	38 ca                	cmp    %cl,%dl
f010317c:	74 04                	je     f0103182 <strfind+0x1a>
f010317e:	84 d2                	test   %dl,%dl
f0103180:	75 f2                	jne    f0103174 <strfind+0xc>
			break;
	return (char *) s;
}
f0103182:	5d                   	pop    %ebp
f0103183:	c3                   	ret    

f0103184 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103184:	55                   	push   %ebp
f0103185:	89 e5                	mov    %esp,%ebp
f0103187:	57                   	push   %edi
f0103188:	56                   	push   %esi
f0103189:	53                   	push   %ebx
f010318a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010318d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103190:	85 c9                	test   %ecx,%ecx
f0103192:	74 36                	je     f01031ca <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103194:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010319a:	75 28                	jne    f01031c4 <memset+0x40>
f010319c:	f6 c1 03             	test   $0x3,%cl
f010319f:	75 23                	jne    f01031c4 <memset+0x40>
		c &= 0xFF;
f01031a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01031a5:	89 d3                	mov    %edx,%ebx
f01031a7:	c1 e3 08             	shl    $0x8,%ebx
f01031aa:	89 d6                	mov    %edx,%esi
f01031ac:	c1 e6 18             	shl    $0x18,%esi
f01031af:	89 d0                	mov    %edx,%eax
f01031b1:	c1 e0 10             	shl    $0x10,%eax
f01031b4:	09 f0                	or     %esi,%eax
f01031b6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01031b8:	89 d8                	mov    %ebx,%eax
f01031ba:	09 d0                	or     %edx,%eax
f01031bc:	c1 e9 02             	shr    $0x2,%ecx
f01031bf:	fc                   	cld    
f01031c0:	f3 ab                	rep stos %eax,%es:(%edi)
f01031c2:	eb 06                	jmp    f01031ca <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01031c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031c7:	fc                   	cld    
f01031c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01031ca:	89 f8                	mov    %edi,%eax
f01031cc:	5b                   	pop    %ebx
f01031cd:	5e                   	pop    %esi
f01031ce:	5f                   	pop    %edi
f01031cf:	5d                   	pop    %ebp
f01031d0:	c3                   	ret    

f01031d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01031d1:	55                   	push   %ebp
f01031d2:	89 e5                	mov    %esp,%ebp
f01031d4:	57                   	push   %edi
f01031d5:	56                   	push   %esi
f01031d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01031df:	39 c6                	cmp    %eax,%esi
f01031e1:	73 35                	jae    f0103218 <memmove+0x47>
f01031e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01031e6:	39 d0                	cmp    %edx,%eax
f01031e8:	73 2e                	jae    f0103218 <memmove+0x47>
		s += n;
		d += n;
f01031ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031ed:	89 d6                	mov    %edx,%esi
f01031ef:	09 fe                	or     %edi,%esi
f01031f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01031f7:	75 13                	jne    f010320c <memmove+0x3b>
f01031f9:	f6 c1 03             	test   $0x3,%cl
f01031fc:	75 0e                	jne    f010320c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01031fe:	83 ef 04             	sub    $0x4,%edi
f0103201:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103204:	c1 e9 02             	shr    $0x2,%ecx
f0103207:	fd                   	std    
f0103208:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010320a:	eb 09                	jmp    f0103215 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010320c:	83 ef 01             	sub    $0x1,%edi
f010320f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103212:	fd                   	std    
f0103213:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103215:	fc                   	cld    
f0103216:	eb 1d                	jmp    f0103235 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103218:	89 f2                	mov    %esi,%edx
f010321a:	09 c2                	or     %eax,%edx
f010321c:	f6 c2 03             	test   $0x3,%dl
f010321f:	75 0f                	jne    f0103230 <memmove+0x5f>
f0103221:	f6 c1 03             	test   $0x3,%cl
f0103224:	75 0a                	jne    f0103230 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0103226:	c1 e9 02             	shr    $0x2,%ecx
f0103229:	89 c7                	mov    %eax,%edi
f010322b:	fc                   	cld    
f010322c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010322e:	eb 05                	jmp    f0103235 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103230:	89 c7                	mov    %eax,%edi
f0103232:	fc                   	cld    
f0103233:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103235:	5e                   	pop    %esi
f0103236:	5f                   	pop    %edi
f0103237:	5d                   	pop    %ebp
f0103238:	c3                   	ret    

f0103239 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103239:	55                   	push   %ebp
f010323a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010323c:	ff 75 10             	pushl  0x10(%ebp)
f010323f:	ff 75 0c             	pushl  0xc(%ebp)
f0103242:	ff 75 08             	pushl  0x8(%ebp)
f0103245:	e8 87 ff ff ff       	call   f01031d1 <memmove>
}
f010324a:	c9                   	leave  
f010324b:	c3                   	ret    

f010324c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010324c:	55                   	push   %ebp
f010324d:	89 e5                	mov    %esp,%ebp
f010324f:	56                   	push   %esi
f0103250:	53                   	push   %ebx
f0103251:	8b 45 08             	mov    0x8(%ebp),%eax
f0103254:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103257:	89 c6                	mov    %eax,%esi
f0103259:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010325c:	eb 1a                	jmp    f0103278 <memcmp+0x2c>
		if (*s1 != *s2)
f010325e:	0f b6 08             	movzbl (%eax),%ecx
f0103261:	0f b6 1a             	movzbl (%edx),%ebx
f0103264:	38 d9                	cmp    %bl,%cl
f0103266:	74 0a                	je     f0103272 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103268:	0f b6 c1             	movzbl %cl,%eax
f010326b:	0f b6 db             	movzbl %bl,%ebx
f010326e:	29 d8                	sub    %ebx,%eax
f0103270:	eb 0f                	jmp    f0103281 <memcmp+0x35>
		s1++, s2++;
f0103272:	83 c0 01             	add    $0x1,%eax
f0103275:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103278:	39 f0                	cmp    %esi,%eax
f010327a:	75 e2                	jne    f010325e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010327c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103281:	5b                   	pop    %ebx
f0103282:	5e                   	pop    %esi
f0103283:	5d                   	pop    %ebp
f0103284:	c3                   	ret    

f0103285 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103285:	55                   	push   %ebp
f0103286:	89 e5                	mov    %esp,%ebp
f0103288:	53                   	push   %ebx
f0103289:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010328c:	89 c1                	mov    %eax,%ecx
f010328e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103291:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103295:	eb 0a                	jmp    f01032a1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103297:	0f b6 10             	movzbl (%eax),%edx
f010329a:	39 da                	cmp    %ebx,%edx
f010329c:	74 07                	je     f01032a5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010329e:	83 c0 01             	add    $0x1,%eax
f01032a1:	39 c8                	cmp    %ecx,%eax
f01032a3:	72 f2                	jb     f0103297 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01032a5:	5b                   	pop    %ebx
f01032a6:	5d                   	pop    %ebp
f01032a7:	c3                   	ret    

f01032a8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01032a8:	55                   	push   %ebp
f01032a9:	89 e5                	mov    %esp,%ebp
f01032ab:	57                   	push   %edi
f01032ac:	56                   	push   %esi
f01032ad:	53                   	push   %ebx
f01032ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01032b4:	eb 03                	jmp    f01032b9 <strtol+0x11>
		s++;
f01032b6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01032b9:	0f b6 01             	movzbl (%ecx),%eax
f01032bc:	3c 20                	cmp    $0x20,%al
f01032be:	74 f6                	je     f01032b6 <strtol+0xe>
f01032c0:	3c 09                	cmp    $0x9,%al
f01032c2:	74 f2                	je     f01032b6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01032c4:	3c 2b                	cmp    $0x2b,%al
f01032c6:	75 0a                	jne    f01032d2 <strtol+0x2a>
		s++;
f01032c8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01032cb:	bf 00 00 00 00       	mov    $0x0,%edi
f01032d0:	eb 11                	jmp    f01032e3 <strtol+0x3b>
f01032d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01032d7:	3c 2d                	cmp    $0x2d,%al
f01032d9:	75 08                	jne    f01032e3 <strtol+0x3b>
		s++, neg = 1;
f01032db:	83 c1 01             	add    $0x1,%ecx
f01032de:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01032e3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01032e9:	75 15                	jne    f0103300 <strtol+0x58>
f01032eb:	80 39 30             	cmpb   $0x30,(%ecx)
f01032ee:	75 10                	jne    f0103300 <strtol+0x58>
f01032f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01032f4:	75 7c                	jne    f0103372 <strtol+0xca>
		s += 2, base = 16;
f01032f6:	83 c1 02             	add    $0x2,%ecx
f01032f9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01032fe:	eb 16                	jmp    f0103316 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103300:	85 db                	test   %ebx,%ebx
f0103302:	75 12                	jne    f0103316 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103304:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103309:	80 39 30             	cmpb   $0x30,(%ecx)
f010330c:	75 08                	jne    f0103316 <strtol+0x6e>
		s++, base = 8;
f010330e:	83 c1 01             	add    $0x1,%ecx
f0103311:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0103316:	b8 00 00 00 00       	mov    $0x0,%eax
f010331b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010331e:	0f b6 11             	movzbl (%ecx),%edx
f0103321:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103324:	89 f3                	mov    %esi,%ebx
f0103326:	80 fb 09             	cmp    $0x9,%bl
f0103329:	77 08                	ja     f0103333 <strtol+0x8b>
			dig = *s - '0';
f010332b:	0f be d2             	movsbl %dl,%edx
f010332e:	83 ea 30             	sub    $0x30,%edx
f0103331:	eb 22                	jmp    f0103355 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103333:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103336:	89 f3                	mov    %esi,%ebx
f0103338:	80 fb 19             	cmp    $0x19,%bl
f010333b:	77 08                	ja     f0103345 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010333d:	0f be d2             	movsbl %dl,%edx
f0103340:	83 ea 57             	sub    $0x57,%edx
f0103343:	eb 10                	jmp    f0103355 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0103345:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103348:	89 f3                	mov    %esi,%ebx
f010334a:	80 fb 19             	cmp    $0x19,%bl
f010334d:	77 16                	ja     f0103365 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010334f:	0f be d2             	movsbl %dl,%edx
f0103352:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103355:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103358:	7d 0b                	jge    f0103365 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010335a:	83 c1 01             	add    $0x1,%ecx
f010335d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103361:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103363:	eb b9                	jmp    f010331e <strtol+0x76>

	if (endptr)
f0103365:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103369:	74 0d                	je     f0103378 <strtol+0xd0>
		*endptr = (char *) s;
f010336b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010336e:	89 0e                	mov    %ecx,(%esi)
f0103370:	eb 06                	jmp    f0103378 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103372:	85 db                	test   %ebx,%ebx
f0103374:	74 98                	je     f010330e <strtol+0x66>
f0103376:	eb 9e                	jmp    f0103316 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103378:	89 c2                	mov    %eax,%edx
f010337a:	f7 da                	neg    %edx
f010337c:	85 ff                	test   %edi,%edi
f010337e:	0f 45 c2             	cmovne %edx,%eax
}
f0103381:	5b                   	pop    %ebx
f0103382:	5e                   	pop    %esi
f0103383:	5f                   	pop    %edi
f0103384:	5d                   	pop    %ebp
f0103385:	c3                   	ret    
f0103386:	66 90                	xchg   %ax,%ax
f0103388:	66 90                	xchg   %ax,%ax
f010338a:	66 90                	xchg   %ax,%ax
f010338c:	66 90                	xchg   %ax,%ax
f010338e:	66 90                	xchg   %ax,%ax

f0103390 <__udivdi3>:
f0103390:	55                   	push   %ebp
f0103391:	57                   	push   %edi
f0103392:	56                   	push   %esi
f0103393:	53                   	push   %ebx
f0103394:	83 ec 1c             	sub    $0x1c,%esp
f0103397:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010339b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010339f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01033a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01033a7:	85 f6                	test   %esi,%esi
f01033a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01033ad:	89 ca                	mov    %ecx,%edx
f01033af:	89 f8                	mov    %edi,%eax
f01033b1:	75 3d                	jne    f01033f0 <__udivdi3+0x60>
f01033b3:	39 cf                	cmp    %ecx,%edi
f01033b5:	0f 87 c5 00 00 00    	ja     f0103480 <__udivdi3+0xf0>
f01033bb:	85 ff                	test   %edi,%edi
f01033bd:	89 fd                	mov    %edi,%ebp
f01033bf:	75 0b                	jne    f01033cc <__udivdi3+0x3c>
f01033c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01033c6:	31 d2                	xor    %edx,%edx
f01033c8:	f7 f7                	div    %edi
f01033ca:	89 c5                	mov    %eax,%ebp
f01033cc:	89 c8                	mov    %ecx,%eax
f01033ce:	31 d2                	xor    %edx,%edx
f01033d0:	f7 f5                	div    %ebp
f01033d2:	89 c1                	mov    %eax,%ecx
f01033d4:	89 d8                	mov    %ebx,%eax
f01033d6:	89 cf                	mov    %ecx,%edi
f01033d8:	f7 f5                	div    %ebp
f01033da:	89 c3                	mov    %eax,%ebx
f01033dc:	89 d8                	mov    %ebx,%eax
f01033de:	89 fa                	mov    %edi,%edx
f01033e0:	83 c4 1c             	add    $0x1c,%esp
f01033e3:	5b                   	pop    %ebx
f01033e4:	5e                   	pop    %esi
f01033e5:	5f                   	pop    %edi
f01033e6:	5d                   	pop    %ebp
f01033e7:	c3                   	ret    
f01033e8:	90                   	nop
f01033e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01033f0:	39 ce                	cmp    %ecx,%esi
f01033f2:	77 74                	ja     f0103468 <__udivdi3+0xd8>
f01033f4:	0f bd fe             	bsr    %esi,%edi
f01033f7:	83 f7 1f             	xor    $0x1f,%edi
f01033fa:	0f 84 98 00 00 00    	je     f0103498 <__udivdi3+0x108>
f0103400:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103405:	89 f9                	mov    %edi,%ecx
f0103407:	89 c5                	mov    %eax,%ebp
f0103409:	29 fb                	sub    %edi,%ebx
f010340b:	d3 e6                	shl    %cl,%esi
f010340d:	89 d9                	mov    %ebx,%ecx
f010340f:	d3 ed                	shr    %cl,%ebp
f0103411:	89 f9                	mov    %edi,%ecx
f0103413:	d3 e0                	shl    %cl,%eax
f0103415:	09 ee                	or     %ebp,%esi
f0103417:	89 d9                	mov    %ebx,%ecx
f0103419:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010341d:	89 d5                	mov    %edx,%ebp
f010341f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103423:	d3 ed                	shr    %cl,%ebp
f0103425:	89 f9                	mov    %edi,%ecx
f0103427:	d3 e2                	shl    %cl,%edx
f0103429:	89 d9                	mov    %ebx,%ecx
f010342b:	d3 e8                	shr    %cl,%eax
f010342d:	09 c2                	or     %eax,%edx
f010342f:	89 d0                	mov    %edx,%eax
f0103431:	89 ea                	mov    %ebp,%edx
f0103433:	f7 f6                	div    %esi
f0103435:	89 d5                	mov    %edx,%ebp
f0103437:	89 c3                	mov    %eax,%ebx
f0103439:	f7 64 24 0c          	mull   0xc(%esp)
f010343d:	39 d5                	cmp    %edx,%ebp
f010343f:	72 10                	jb     f0103451 <__udivdi3+0xc1>
f0103441:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103445:	89 f9                	mov    %edi,%ecx
f0103447:	d3 e6                	shl    %cl,%esi
f0103449:	39 c6                	cmp    %eax,%esi
f010344b:	73 07                	jae    f0103454 <__udivdi3+0xc4>
f010344d:	39 d5                	cmp    %edx,%ebp
f010344f:	75 03                	jne    f0103454 <__udivdi3+0xc4>
f0103451:	83 eb 01             	sub    $0x1,%ebx
f0103454:	31 ff                	xor    %edi,%edi
f0103456:	89 d8                	mov    %ebx,%eax
f0103458:	89 fa                	mov    %edi,%edx
f010345a:	83 c4 1c             	add    $0x1c,%esp
f010345d:	5b                   	pop    %ebx
f010345e:	5e                   	pop    %esi
f010345f:	5f                   	pop    %edi
f0103460:	5d                   	pop    %ebp
f0103461:	c3                   	ret    
f0103462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103468:	31 ff                	xor    %edi,%edi
f010346a:	31 db                	xor    %ebx,%ebx
f010346c:	89 d8                	mov    %ebx,%eax
f010346e:	89 fa                	mov    %edi,%edx
f0103470:	83 c4 1c             	add    $0x1c,%esp
f0103473:	5b                   	pop    %ebx
f0103474:	5e                   	pop    %esi
f0103475:	5f                   	pop    %edi
f0103476:	5d                   	pop    %ebp
f0103477:	c3                   	ret    
f0103478:	90                   	nop
f0103479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103480:	89 d8                	mov    %ebx,%eax
f0103482:	f7 f7                	div    %edi
f0103484:	31 ff                	xor    %edi,%edi
f0103486:	89 c3                	mov    %eax,%ebx
f0103488:	89 d8                	mov    %ebx,%eax
f010348a:	89 fa                	mov    %edi,%edx
f010348c:	83 c4 1c             	add    $0x1c,%esp
f010348f:	5b                   	pop    %ebx
f0103490:	5e                   	pop    %esi
f0103491:	5f                   	pop    %edi
f0103492:	5d                   	pop    %ebp
f0103493:	c3                   	ret    
f0103494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103498:	39 ce                	cmp    %ecx,%esi
f010349a:	72 0c                	jb     f01034a8 <__udivdi3+0x118>
f010349c:	31 db                	xor    %ebx,%ebx
f010349e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01034a2:	0f 87 34 ff ff ff    	ja     f01033dc <__udivdi3+0x4c>
f01034a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01034ad:	e9 2a ff ff ff       	jmp    f01033dc <__udivdi3+0x4c>
f01034b2:	66 90                	xchg   %ax,%ax
f01034b4:	66 90                	xchg   %ax,%ax
f01034b6:	66 90                	xchg   %ax,%ax
f01034b8:	66 90                	xchg   %ax,%ax
f01034ba:	66 90                	xchg   %ax,%ax
f01034bc:	66 90                	xchg   %ax,%ax
f01034be:	66 90                	xchg   %ax,%ax

f01034c0 <__umoddi3>:
f01034c0:	55                   	push   %ebp
f01034c1:	57                   	push   %edi
f01034c2:	56                   	push   %esi
f01034c3:	53                   	push   %ebx
f01034c4:	83 ec 1c             	sub    $0x1c,%esp
f01034c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01034cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01034cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01034d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01034d7:	85 d2                	test   %edx,%edx
f01034d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01034dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034e1:	89 f3                	mov    %esi,%ebx
f01034e3:	89 3c 24             	mov    %edi,(%esp)
f01034e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034ea:	75 1c                	jne    f0103508 <__umoddi3+0x48>
f01034ec:	39 f7                	cmp    %esi,%edi
f01034ee:	76 50                	jbe    f0103540 <__umoddi3+0x80>
f01034f0:	89 c8                	mov    %ecx,%eax
f01034f2:	89 f2                	mov    %esi,%edx
f01034f4:	f7 f7                	div    %edi
f01034f6:	89 d0                	mov    %edx,%eax
f01034f8:	31 d2                	xor    %edx,%edx
f01034fa:	83 c4 1c             	add    $0x1c,%esp
f01034fd:	5b                   	pop    %ebx
f01034fe:	5e                   	pop    %esi
f01034ff:	5f                   	pop    %edi
f0103500:	5d                   	pop    %ebp
f0103501:	c3                   	ret    
f0103502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103508:	39 f2                	cmp    %esi,%edx
f010350a:	89 d0                	mov    %edx,%eax
f010350c:	77 52                	ja     f0103560 <__umoddi3+0xa0>
f010350e:	0f bd ea             	bsr    %edx,%ebp
f0103511:	83 f5 1f             	xor    $0x1f,%ebp
f0103514:	75 5a                	jne    f0103570 <__umoddi3+0xb0>
f0103516:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010351a:	0f 82 e0 00 00 00    	jb     f0103600 <__umoddi3+0x140>
f0103520:	39 0c 24             	cmp    %ecx,(%esp)
f0103523:	0f 86 d7 00 00 00    	jbe    f0103600 <__umoddi3+0x140>
f0103529:	8b 44 24 08          	mov    0x8(%esp),%eax
f010352d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103531:	83 c4 1c             	add    $0x1c,%esp
f0103534:	5b                   	pop    %ebx
f0103535:	5e                   	pop    %esi
f0103536:	5f                   	pop    %edi
f0103537:	5d                   	pop    %ebp
f0103538:	c3                   	ret    
f0103539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103540:	85 ff                	test   %edi,%edi
f0103542:	89 fd                	mov    %edi,%ebp
f0103544:	75 0b                	jne    f0103551 <__umoddi3+0x91>
f0103546:	b8 01 00 00 00       	mov    $0x1,%eax
f010354b:	31 d2                	xor    %edx,%edx
f010354d:	f7 f7                	div    %edi
f010354f:	89 c5                	mov    %eax,%ebp
f0103551:	89 f0                	mov    %esi,%eax
f0103553:	31 d2                	xor    %edx,%edx
f0103555:	f7 f5                	div    %ebp
f0103557:	89 c8                	mov    %ecx,%eax
f0103559:	f7 f5                	div    %ebp
f010355b:	89 d0                	mov    %edx,%eax
f010355d:	eb 99                	jmp    f01034f8 <__umoddi3+0x38>
f010355f:	90                   	nop
f0103560:	89 c8                	mov    %ecx,%eax
f0103562:	89 f2                	mov    %esi,%edx
f0103564:	83 c4 1c             	add    $0x1c,%esp
f0103567:	5b                   	pop    %ebx
f0103568:	5e                   	pop    %esi
f0103569:	5f                   	pop    %edi
f010356a:	5d                   	pop    %ebp
f010356b:	c3                   	ret    
f010356c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103570:	8b 34 24             	mov    (%esp),%esi
f0103573:	bf 20 00 00 00       	mov    $0x20,%edi
f0103578:	89 e9                	mov    %ebp,%ecx
f010357a:	29 ef                	sub    %ebp,%edi
f010357c:	d3 e0                	shl    %cl,%eax
f010357e:	89 f9                	mov    %edi,%ecx
f0103580:	89 f2                	mov    %esi,%edx
f0103582:	d3 ea                	shr    %cl,%edx
f0103584:	89 e9                	mov    %ebp,%ecx
f0103586:	09 c2                	or     %eax,%edx
f0103588:	89 d8                	mov    %ebx,%eax
f010358a:	89 14 24             	mov    %edx,(%esp)
f010358d:	89 f2                	mov    %esi,%edx
f010358f:	d3 e2                	shl    %cl,%edx
f0103591:	89 f9                	mov    %edi,%ecx
f0103593:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103597:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010359b:	d3 e8                	shr    %cl,%eax
f010359d:	89 e9                	mov    %ebp,%ecx
f010359f:	89 c6                	mov    %eax,%esi
f01035a1:	d3 e3                	shl    %cl,%ebx
f01035a3:	89 f9                	mov    %edi,%ecx
f01035a5:	89 d0                	mov    %edx,%eax
f01035a7:	d3 e8                	shr    %cl,%eax
f01035a9:	89 e9                	mov    %ebp,%ecx
f01035ab:	09 d8                	or     %ebx,%eax
f01035ad:	89 d3                	mov    %edx,%ebx
f01035af:	89 f2                	mov    %esi,%edx
f01035b1:	f7 34 24             	divl   (%esp)
f01035b4:	89 d6                	mov    %edx,%esi
f01035b6:	d3 e3                	shl    %cl,%ebx
f01035b8:	f7 64 24 04          	mull   0x4(%esp)
f01035bc:	39 d6                	cmp    %edx,%esi
f01035be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035c2:	89 d1                	mov    %edx,%ecx
f01035c4:	89 c3                	mov    %eax,%ebx
f01035c6:	72 08                	jb     f01035d0 <__umoddi3+0x110>
f01035c8:	75 11                	jne    f01035db <__umoddi3+0x11b>
f01035ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01035ce:	73 0b                	jae    f01035db <__umoddi3+0x11b>
f01035d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01035d4:	1b 14 24             	sbb    (%esp),%edx
f01035d7:	89 d1                	mov    %edx,%ecx
f01035d9:	89 c3                	mov    %eax,%ebx
f01035db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01035df:	29 da                	sub    %ebx,%edx
f01035e1:	19 ce                	sbb    %ecx,%esi
f01035e3:	89 f9                	mov    %edi,%ecx
f01035e5:	89 f0                	mov    %esi,%eax
f01035e7:	d3 e0                	shl    %cl,%eax
f01035e9:	89 e9                	mov    %ebp,%ecx
f01035eb:	d3 ea                	shr    %cl,%edx
f01035ed:	89 e9                	mov    %ebp,%ecx
f01035ef:	d3 ee                	shr    %cl,%esi
f01035f1:	09 d0                	or     %edx,%eax
f01035f3:	89 f2                	mov    %esi,%edx
f01035f5:	83 c4 1c             	add    $0x1c,%esp
f01035f8:	5b                   	pop    %ebx
f01035f9:	5e                   	pop    %esi
f01035fa:	5f                   	pop    %edi
f01035fb:	5d                   	pop    %ebp
f01035fc:	c3                   	ret    
f01035fd:	8d 76 00             	lea    0x0(%esi),%esi
f0103600:	29 f9                	sub    %edi,%ecx
f0103602:	19 d6                	sbb    %edx,%esi
f0103604:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010360c:	e9 18 ff ff ff       	jmp    f0103529 <__umoddi3+0x69>
