
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 50 4c 17 f0       	mov    $0xf0174c50,%eax
f010004b:	2d 26 3d 17 f0       	sub    $0xf0173d26,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 26 3d 17 f0       	push   $0xf0173d26
f0100058:	e8 fa 41 00 00       	call   f0104257 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9d 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 47 10 f0       	push   $0xf0104700
f010006f:	e8 86 2e 00 00       	call   f0102efa <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 7a 0f 00 00       	call   f0100ff3 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 ad 28 00 00       	call   f010292b <env_init>
	trap_init();
f010007e:	e8 e8 2e 00 00       	call   f0102f6b <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 c6 eb 12 f0       	push   $0xf012ebc6
f010008d:	e8 47 2a 00 00       	call   f0102ad9 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 8c 3f 17 f0    	pushl  0xf0173f8c
f010009b:	e8 91 2d 00 00       	call   f0102e31 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 40 4c 17 f0 00 	cmpl   $0x0,0xf0174c40
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 40 4c 17 f0    	mov    %esi,0xf0174c40

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 1b 47 10 f0       	push   $0xf010471b
f01000ca:	e8 2b 2e 00 00       	call   f0102efa <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 fb 2d 00 00       	call   f0102ed4 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 a0 56 10 f0 	movl   $0xf01056a0,(%esp)
f01000e0:	e8 15 2e 00 00       	call   f0102efa <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 ba 06 00 00       	call   f01007ac <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 33 47 10 f0       	push   $0xf0104733
f010010c:	e8 e9 2d 00 00       	call   f0102efa <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 b7 2d 00 00       	call   f0102ed4 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 a0 56 10 f0 	movl   $0xf01056a0,(%esp)
f0100124:	e8 d1 2d 00 00       	call   f0102efa <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 64 3f 17 f0    	mov    0xf0173f64,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 64 3f 17 f0    	mov    %edx,0xf0173f64
f010016e:	88 81 60 3d 17 f0    	mov    %al,-0xfe8c2a0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 64 3f 17 f0 00 	movl   $0x0,0xf0173f64
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f0 00 00 00    	je     f0100291 <kbd_proc_data+0xfe>
f01001a1:	ba 60 00 00 00       	mov    $0x60,%edx
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001a9:	3c e0                	cmp    $0xe0,%al
f01001ab:	75 0d                	jne    f01001ba <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001ad:	83 0d 40 3d 17 f0 40 	orl    $0x40,0xf0173d40
		return 0;
f01001b4:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001b9:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
f01001bd:	53                   	push   %ebx
f01001be:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c1:	84 c0                	test   %al,%al
f01001c3:	79 36                	jns    f01001fb <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c5:	8b 0d 40 3d 17 f0    	mov    0xf0173d40,%ecx
f01001cb:	89 cb                	mov    %ecx,%ebx
f01001cd:	83 e3 40             	and    $0x40,%ebx
f01001d0:	83 e0 7f             	and    $0x7f,%eax
f01001d3:	85 db                	test   %ebx,%ebx
f01001d5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d8:	0f b6 d2             	movzbl %dl,%edx
f01001db:	0f b6 82 a0 48 10 f0 	movzbl -0xfefb760(%edx),%eax
f01001e2:	83 c8 40             	or     $0x40,%eax
f01001e5:	0f b6 c0             	movzbl %al,%eax
f01001e8:	f7 d0                	not    %eax
f01001ea:	21 c8                	and    %ecx,%eax
f01001ec:	a3 40 3d 17 f0       	mov    %eax,0xf0173d40
		return 0;
f01001f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f6:	e9 9e 00 00 00       	jmp    f0100299 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001fb:	8b 0d 40 3d 17 f0    	mov    0xf0173d40,%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 0d 40 3d 17 f0    	mov    %ecx,0xf0173d40
	}

	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100217:	0f b6 82 a0 48 10 f0 	movzbl -0xfefb760(%edx),%eax
f010021e:	0b 05 40 3d 17 f0    	or     0xf0173d40,%eax
f0100224:	0f b6 8a a0 47 10 f0 	movzbl -0xfefb860(%edx),%ecx
f010022b:	31 c8                	xor    %ecx,%eax
f010022d:	a3 40 3d 17 f0       	mov    %eax,0xf0173d40

	c = charcode[shift & (CTL | SHIFT)][data];
f0100232:	89 c1                	mov    %eax,%ecx
f0100234:	83 e1 03             	and    $0x3,%ecx
f0100237:	8b 0c 8d 80 47 10 f0 	mov    -0xfefb880(,%ecx,4),%ecx
f010023e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100242:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100245:	a8 08                	test   $0x8,%al
f0100247:	74 1b                	je     f0100264 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100249:	89 da                	mov    %ebx,%edx
f010024b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010024e:	83 f9 19             	cmp    $0x19,%ecx
f0100251:	77 05                	ja     f0100258 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100253:	83 eb 20             	sub    $0x20,%ebx
f0100256:	eb 0c                	jmp    f0100264 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100258:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010025b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010025e:	83 fa 19             	cmp    $0x19,%edx
f0100261:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100264:	f7 d0                	not    %eax
f0100266:	a8 06                	test   $0x6,%al
f0100268:	75 2d                	jne    f0100297 <kbd_proc_data+0x104>
f010026a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100270:	75 25                	jne    f0100297 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100272:	83 ec 0c             	sub    $0xc,%esp
f0100275:	68 4d 47 10 f0       	push   $0xf010474d
f010027a:	e8 7b 2c 00 00       	call   f0102efa <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027f:	ba 92 00 00 00       	mov    $0x92,%edx
f0100284:	b8 03 00 00 00       	mov    $0x3,%eax
f0100289:	ee                   	out    %al,(%dx)
f010028a:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010028d:	89 d8                	mov    %ebx,%eax
f010028f:	eb 08                	jmp    f0100299 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100296:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100297:	89 d8                	mov    %ebx,%eax
}
f0100299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029c:	c9                   	leave  
f010029d:	c3                   	ret    

f010029e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	57                   	push   %edi
f01002a2:	56                   	push   %esi
f01002a3:	53                   	push   %ebx
f01002a4:	83 ec 1c             	sub    $0x1c,%esp
f01002a7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a9:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ae:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002b3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b8:	eb 09                	jmp    f01002c3 <cons_putc+0x25>
f01002ba:	89 ca                	mov    %ecx,%edx
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	ec                   	in     (%dx),%al
f01002be:	ec                   	in     (%dx),%al
f01002bf:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002c0:	83 c3 01             	add    $0x1,%ebx
f01002c3:	89 f2                	mov    %esi,%edx
f01002c5:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c6:	a8 20                	test   $0x20,%al
f01002c8:	75 08                	jne    f01002d2 <cons_putc+0x34>
f01002ca:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002d0:	7e e8                	jle    f01002ba <cons_putc+0x1c>
f01002d2:	89 f8                	mov    %edi,%eax
f01002d4:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002dc:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be 79 03 00 00       	mov    $0x379,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x59>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100300:	7f 04                	jg     f0100306 <cons_putc+0x68>
f0100302:	84 c0                	test   %al,%al
f0100304:	79 e8                	jns    f01002ee <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100306:	ba 78 03 00 00       	mov    $0x378,%edx
f010030b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010030f:	ee                   	out    %al,(%dx)
f0100310:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100315:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031a:	ee                   	out    %al,(%dx)
f010031b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100320:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100321:	89 fa                	mov    %edi,%edx
f0100323:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100329:	89 f8                	mov    %edi,%eax
f010032b:	80 cc 07             	or     $0x7,%ah
f010032e:	85 d2                	test   %edx,%edx
f0100330:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100333:	89 f8                	mov    %edi,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	83 f8 09             	cmp    $0x9,%eax
f010033b:	74 74                	je     f01003b1 <cons_putc+0x113>
f010033d:	83 f8 09             	cmp    $0x9,%eax
f0100340:	7f 0a                	jg     f010034c <cons_putc+0xae>
f0100342:	83 f8 08             	cmp    $0x8,%eax
f0100345:	74 14                	je     f010035b <cons_putc+0xbd>
f0100347:	e9 99 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
f010034c:	83 f8 0a             	cmp    $0xa,%eax
f010034f:	74 3a                	je     f010038b <cons_putc+0xed>
f0100351:	83 f8 0d             	cmp    $0xd,%eax
f0100354:	74 3d                	je     f0100393 <cons_putc+0xf5>
f0100356:	e9 8a 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010035b:	0f b7 05 68 3f 17 f0 	movzwl 0xf0173f68,%eax
f0100362:	66 85 c0             	test   %ax,%ax
f0100365:	0f 84 e6 00 00 00    	je     f0100451 <cons_putc+0x1b3>
			crt_pos--;
f010036b:	83 e8 01             	sub    $0x1,%eax
f010036e:	66 a3 68 3f 17 f0    	mov    %ax,0xf0173f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100374:	0f b7 c0             	movzwl %ax,%eax
f0100377:	66 81 e7 00 ff       	and    $0xff00,%di
f010037c:	83 cf 20             	or     $0x20,%edi
f010037f:	8b 15 6c 3f 17 f0    	mov    0xf0173f6c,%edx
f0100385:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100389:	eb 78                	jmp    f0100403 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038b:	66 83 05 68 3f 17 f0 	addw   $0x50,0xf0173f68
f0100392:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100393:	0f b7 05 68 3f 17 f0 	movzwl 0xf0173f68,%eax
f010039a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a0:	c1 e8 16             	shr    $0x16,%eax
f01003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a6:	c1 e0 04             	shl    $0x4,%eax
f01003a9:	66 a3 68 3f 17 f0    	mov    %ax,0xf0173f68
f01003af:	eb 52                	jmp    f0100403 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b6:	e8 e3 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c0:	e8 d9 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ca:	e8 cf fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d4:	e8 c5 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003de:	e8 bb fe ff ff       	call   f010029e <cons_putc>
f01003e3:	eb 1e                	jmp    f0100403 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e5:	0f b7 05 68 3f 17 f0 	movzwl 0xf0173f68,%eax
f01003ec:	8d 50 01             	lea    0x1(%eax),%edx
f01003ef:	66 89 15 68 3f 17 f0 	mov    %dx,0xf0173f68
f01003f6:	0f b7 c0             	movzwl %ax,%eax
f01003f9:	8b 15 6c 3f 17 f0    	mov    0xf0173f6c,%edx
f01003ff:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100403:	66 81 3d 68 3f 17 f0 	cmpw   $0x7cf,0xf0173f68
f010040a:	cf 07 
f010040c:	76 43                	jbe    f0100451 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040e:	a1 6c 3f 17 f0       	mov    0xf0173f6c,%eax
f0100413:	83 ec 04             	sub    $0x4,%esp
f0100416:	68 00 0f 00 00       	push   $0xf00
f010041b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100421:	52                   	push   %edx
f0100422:	50                   	push   %eax
f0100423:	e8 7c 3e 00 00       	call   f01042a4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100428:	8b 15 6c 3f 17 f0    	mov    0xf0173f6c,%edx
f010042e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100434:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010043a:	83 c4 10             	add    $0x10,%esp
f010043d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100442:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100445:	39 d0                	cmp    %edx,%eax
f0100447:	75 f4                	jne    f010043d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100449:	66 83 2d 68 3f 17 f0 	subw   $0x50,0xf0173f68
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 70 3f 17 f0    	mov    0xf0173f70,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 68 3f 17 f0 	movzwl 0xf0173f68,%ebx
f0100466:	8d 71 01             	lea    0x1(%ecx),%esi
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	66 c1 e8 08          	shr    $0x8,%ax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	89 d8                	mov    %ebx,%eax
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100482:	5b                   	pop    %ebx
f0100483:	5e                   	pop    %esi
f0100484:	5f                   	pop    %edi
f0100485:	5d                   	pop    %ebp
f0100486:	c3                   	ret    

f0100487 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100487:	80 3d 74 3f 17 f0 00 	cmpb   $0x0,0xf0173f74
f010048e:	74 11                	je     f01004a1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100496:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f010049b:	e8 b0 fc ff ff       	call   f0100150 <cons_intr>
}
f01004a0:	c9                   	leave  
f01004a1:	f3 c3                	repz ret 

f01004a3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a3:	55                   	push   %ebp
f01004a4:	89 e5                	mov    %esp,%ebp
f01004a6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a9:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004ae:	e8 9d fc ff ff       	call   f0100150 <cons_intr>
}
f01004b3:	c9                   	leave  
f01004b4:	c3                   	ret    

f01004b5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bb:	e8 c7 ff ff ff       	call   f0100487 <serial_intr>
	kbd_intr();
f01004c0:	e8 de ff ff ff       	call   f01004a3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c5:	a1 60 3f 17 f0       	mov    0xf0173f60,%eax
f01004ca:	3b 05 64 3f 17 f0    	cmp    0xf0173f64,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 60 3f 17 f0    	mov    %edx,0xf0173f60
f01004db:	0f b6 88 60 3d 17 f0 	movzbl -0xfe8c2a0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ea:	75 11                	jne    f01004fd <cons_getc+0x48>
			cons.rpos = 0;
f01004ec:	c7 05 60 3f 17 f0 00 	movl   $0x0,0xf0173f60
f01004f3:	00 00 00 
f01004f6:	eb 05                	jmp    f01004fd <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100508:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100516:	5a a5 
	if (*cp != 0xA55A) {
f0100518:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100523:	74 11                	je     f0100536 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 70 3f 17 f0 b4 	movl   $0x3b4,0xf0173f70
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100534:	eb 16                	jmp    f010054c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100536:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053d:	c7 05 70 3f 17 f0 d4 	movl   $0x3d4,0xf0173f70
f0100544:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100547:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054c:	8b 3d 70 3f 17 f0    	mov    0xf0173f70,%edi
f0100552:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100557:	89 fa                	mov    %edi,%edx
f0100559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055a:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	0f b6 c8             	movzbl %al,%ecx
f0100563:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056b:	89 fa                	mov    %edi,%edx
f010056d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056e:	89 da                	mov    %ebx,%edx
f0100570:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100571:	89 35 6c 3f 17 f0    	mov    %esi,0xf0173f6c
	crt_pos = pos;
f0100577:	0f b6 c0             	movzbl %al,%eax
f010057a:	09 c8                	or     %ecx,%eax
f010057c:	66 a3 68 3f 17 f0    	mov    %ax,0xf0173f68
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100582:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100587:	b8 00 00 00 00       	mov    $0x0,%eax
f010058c:	89 f2                	mov    %esi,%edx
f010058e:	ee                   	out    %al,(%dx)
f010058f:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100594:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100599:	ee                   	out    %al,(%dx)
f010059a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010059f:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a4:	89 da                	mov    %ebx,%edx
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b7:	b8 03 00 00 00       	mov    $0x3,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01005d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d8:	ec                   	in     (%dx),%al
f01005d9:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005db:	3c ff                	cmp    $0xff,%al
f01005dd:	0f 95 05 74 3f 17 f0 	setne  0xf0173f74
f01005e4:	89 f2                	mov    %esi,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 da                	mov    %ebx,%edx
f01005e9:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ea:	80 f9 ff             	cmp    $0xff,%cl
f01005ed:	75 10                	jne    f01005ff <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005ef:	83 ec 0c             	sub    $0xc,%esp
f01005f2:	68 59 47 10 f0       	push   $0xf0104759
f01005f7:	e8 fe 28 00 00       	call   f0102efa <cprintf>
f01005fc:	83 c4 10             	add    $0x10,%esp
}
f01005ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5e                   	pop    %esi
f0100604:	5f                   	pop    %edi
f0100605:	5d                   	pop    %ebp
f0100606:	c3                   	ret    

f0100607 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
f010060a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010060d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100610:	e8 89 fc ff ff       	call   f010029e <cons_putc>
}
f0100615:	c9                   	leave  
f0100616:	c3                   	ret    

f0100617 <getchar>:

int
getchar(void)
{
f0100617:	55                   	push   %ebp
f0100618:	89 e5                	mov    %esp,%ebp
f010061a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010061d:	e8 93 fe ff ff       	call   f01004b5 <cons_getc>
f0100622:	85 c0                	test   %eax,%eax
f0100624:	74 f7                	je     f010061d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <iscons>:

int
iscons(int fdnum)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010062b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100630:	5d                   	pop    %ebp
f0100631:	c3                   	ret    

f0100632 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100638:	68 a0 49 10 f0       	push   $0xf01049a0
f010063d:	68 be 49 10 f0       	push   $0xf01049be
f0100642:	68 c3 49 10 f0       	push   $0xf01049c3
f0100647:	e8 ae 28 00 00       	call   f0102efa <cprintf>
f010064c:	83 c4 0c             	add    $0xc,%esp
f010064f:	68 74 4a 10 f0       	push   $0xf0104a74
f0100654:	68 cc 49 10 f0       	push   $0xf01049cc
f0100659:	68 c3 49 10 f0       	push   $0xf01049c3
f010065e:	e8 97 28 00 00       	call   f0102efa <cprintf>
	return 0;
}
f0100663:	b8 00 00 00 00       	mov    $0x0,%eax
f0100668:	c9                   	leave  
f0100669:	c3                   	ret    

f010066a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010066a:	55                   	push   %ebp
f010066b:	89 e5                	mov    %esp,%ebp
f010066d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100670:	68 d5 49 10 f0       	push   $0xf01049d5
f0100675:	e8 80 28 00 00       	call   f0102efa <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067a:	83 c4 08             	add    $0x8,%esp
f010067d:	68 0c 00 10 00       	push   $0x10000c
f0100682:	68 9c 4a 10 f0       	push   $0xf0104a9c
f0100687:	e8 6e 28 00 00       	call   f0102efa <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068c:	83 c4 0c             	add    $0xc,%esp
f010068f:	68 0c 00 10 00       	push   $0x10000c
f0100694:	68 0c 00 10 f0       	push   $0xf010000c
f0100699:	68 c4 4a 10 f0       	push   $0xf0104ac4
f010069e:	e8 57 28 00 00       	call   f0102efa <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a3:	83 c4 0c             	add    $0xc,%esp
f01006a6:	68 e1 46 10 00       	push   $0x1046e1
f01006ab:	68 e1 46 10 f0       	push   $0xf01046e1
f01006b0:	68 e8 4a 10 f0       	push   $0xf0104ae8
f01006b5:	e8 40 28 00 00       	call   f0102efa <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	68 26 3d 17 00       	push   $0x173d26
f01006c2:	68 26 3d 17 f0       	push   $0xf0173d26
f01006c7:	68 0c 4b 10 f0       	push   $0xf0104b0c
f01006cc:	e8 29 28 00 00       	call   f0102efa <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d1:	83 c4 0c             	add    $0xc,%esp
f01006d4:	68 50 4c 17 00       	push   $0x174c50
f01006d9:	68 50 4c 17 f0       	push   $0xf0174c50
f01006de:	68 30 4b 10 f0       	push   $0xf0104b30
f01006e3:	e8 12 28 00 00       	call   f0102efa <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e8:	b8 4f 50 17 f0       	mov    $0xf017504f,%eax
f01006ed:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f2:	83 c4 08             	add    $0x8,%esp
f01006f5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006fa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100700:	85 c0                	test   %eax,%eax
f0100702:	0f 48 c2             	cmovs  %edx,%eax
f0100705:	c1 f8 0a             	sar    $0xa,%eax
f0100708:	50                   	push   %eax
f0100709:	68 54 4b 10 f0       	push   $0xf0104b54
f010070e:	e8 e7 27 00 00       	call   f0102efa <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100713:	b8 00 00 00 00       	mov    $0x0,%eax
f0100718:	c9                   	leave  
f0100719:	c3                   	ret    

f010071a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	57                   	push   %edi
f010071e:	56                   	push   %esi
f010071f:	53                   	push   %ebx
f0100720:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100723:	89 ee                	mov    %ebp,%esi
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();//获取ebp值
	cprintf("Stack backtrace:\n");//输出格式
f0100725:	68 ee 49 10 f0       	push   $0xf01049ee
f010072a:	e8 cb 27 00 00       	call   f0102efa <cprintf>
	while (ebp) 
f010072f:	83 c4 10             	add    $0x10,%esp
f0100732:	eb 67                	jmp    f010079b <mon_backtrace+0x81>
	{
	cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);//输出ebp,eip，其中eip通过ebp[1]得到
f0100734:	83 ec 04             	sub    $0x4,%esp
f0100737:	ff 76 04             	pushl  0x4(%esi)
f010073a:	56                   	push   %esi
f010073b:	68 00 4a 10 f0       	push   $0xf0104a00
f0100740:	e8 b5 27 00 00       	call   f0102efa <cprintf>
f0100745:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100748:	8d 7e 1c             	lea    0x1c(%esi),%edi
f010074b:	83 c4 10             	add    $0x10,%esp
	int j=2;
	while(j!=7) //输出args[i]
	     {
	     cprintf(" %08x", ebp[j]);
f010074e:	83 ec 08             	sub    $0x8,%esp
f0100751:	ff 33                	pushl  (%ebx)
f0100753:	68 19 4a 10 f0       	push   $0xf0104a19
f0100758:	e8 9d 27 00 00       	call   f0102efa <cprintf>
f010075d:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");//输出格式
	while (ebp) 
	{
	cprintf(" ebp %08x eip %08x args ", ebp, ebp[1]);//输出ebp,eip，其中eip通过ebp[1]得到
	int j=2;
	while(j!=7) //输出args[i]
f0100760:	83 c4 10             	add    $0x10,%esp
f0100763:	39 fb                	cmp    %edi,%ebx
f0100765:	75 e7                	jne    f010074e <mon_backtrace+0x34>
	     {
	     cprintf(" %08x", ebp[j]);
	     j++;
	     } 
	debuginfo_eip(ebp[1],&info);
f0100767:	83 ec 08             	sub    $0x8,%esp
f010076a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010076d:	50                   	push   %eax
f010076e:	ff 76 04             	pushl  0x4(%esi)
f0100771:	e8 70 30 00 00       	call   f01037e6 <debuginfo_eip>
	cprintf("\n    %s:%d:  %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f0100776:	83 c4 08             	add    $0x8,%esp
f0100779:	8b 46 04             	mov    0x4(%esi),%eax
f010077c:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010077f:	50                   	push   %eax
f0100780:	ff 75 d8             	pushl  -0x28(%ebp)
f0100783:	ff 75 dc             	pushl  -0x24(%ebp)
f0100786:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100789:	ff 75 d0             	pushl  -0x30(%ebp)
f010078c:	68 1f 4a 10 f0       	push   $0xf0104a1f
f0100791:	e8 64 27 00 00       	call   f0102efa <cprintf>
	ebp = (uint32_t *) (*ebp);
f0100796:	8b 36                	mov    (%esi),%esi
f0100798:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t *ebp = (uint32_t *) read_ebp();//获取ebp值
	cprintf("Stack backtrace:\n");//输出格式
	while (ebp) 
f010079b:	85 f6                	test   %esi,%esi
f010079d:	75 95                	jne    f0100734 <mon_backtrace+0x1a>
	debuginfo_eip(ebp[1],&info);
	cprintf("\n    %s:%d:  %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
	ebp = (uint32_t *) (*ebp);
	}
	return 0;
}
f010079f:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a7:	5b                   	pop    %ebx
f01007a8:	5e                   	pop    %esi
f01007a9:	5f                   	pop    %edi
f01007aa:	5d                   	pop    %ebp
f01007ab:	c3                   	ret    

f01007ac <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ac:	55                   	push   %ebp
f01007ad:	89 e5                	mov    %esp,%ebp
f01007af:	57                   	push   %edi
f01007b0:	56                   	push   %esi
f01007b1:	53                   	push   %ebx
f01007b2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b5:	68 80 4b 10 f0       	push   $0xf0104b80
f01007ba:	e8 3b 27 00 00       	call   f0102efa <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007bf:	c7 04 24 a4 4b 10 f0 	movl   $0xf0104ba4,(%esp)
f01007c6:	e8 2f 27 00 00       	call   f0102efa <cprintf>

	if (tf != NULL)
f01007cb:	83 c4 10             	add    $0x10,%esp
f01007ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007d2:	74 0e                	je     f01007e2 <monitor+0x36>
		print_trapframe(tf);
f01007d4:	83 ec 0c             	sub    $0xc,%esp
f01007d7:	ff 75 08             	pushl  0x8(%ebp)
f01007da:	e8 d4 2a 00 00       	call   f01032b3 <print_trapframe>
f01007df:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01007e2:	83 ec 0c             	sub    $0xc,%esp
f01007e5:	68 35 4a 10 f0       	push   $0xf0104a35
f01007ea:	e8 11 38 00 00       	call   f0104000 <readline>
f01007ef:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007f1:	83 c4 10             	add    $0x10,%esp
f01007f4:	85 c0                	test   %eax,%eax
f01007f6:	74 ea                	je     f01007e2 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007f8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007ff:	be 00 00 00 00       	mov    $0x0,%esi
f0100804:	eb 0a                	jmp    f0100810 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100806:	c6 03 00             	movb   $0x0,(%ebx)
f0100809:	89 f7                	mov    %esi,%edi
f010080b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010080e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100810:	0f b6 03             	movzbl (%ebx),%eax
f0100813:	84 c0                	test   %al,%al
f0100815:	74 63                	je     f010087a <monitor+0xce>
f0100817:	83 ec 08             	sub    $0x8,%esp
f010081a:	0f be c0             	movsbl %al,%eax
f010081d:	50                   	push   %eax
f010081e:	68 39 4a 10 f0       	push   $0xf0104a39
f0100823:	e8 f2 39 00 00       	call   f010421a <strchr>
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	85 c0                	test   %eax,%eax
f010082d:	75 d7                	jne    f0100806 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010082f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100832:	74 46                	je     f010087a <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100834:	83 fe 0f             	cmp    $0xf,%esi
f0100837:	75 14                	jne    f010084d <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100839:	83 ec 08             	sub    $0x8,%esp
f010083c:	6a 10                	push   $0x10
f010083e:	68 3e 4a 10 f0       	push   $0xf0104a3e
f0100843:	e8 b2 26 00 00       	call   f0102efa <cprintf>
f0100848:	83 c4 10             	add    $0x10,%esp
f010084b:	eb 95                	jmp    f01007e2 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010084d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100850:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100854:	eb 03                	jmp    f0100859 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100856:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100859:	0f b6 03             	movzbl (%ebx),%eax
f010085c:	84 c0                	test   %al,%al
f010085e:	74 ae                	je     f010080e <monitor+0x62>
f0100860:	83 ec 08             	sub    $0x8,%esp
f0100863:	0f be c0             	movsbl %al,%eax
f0100866:	50                   	push   %eax
f0100867:	68 39 4a 10 f0       	push   $0xf0104a39
f010086c:	e8 a9 39 00 00       	call   f010421a <strchr>
f0100871:	83 c4 10             	add    $0x10,%esp
f0100874:	85 c0                	test   %eax,%eax
f0100876:	74 de                	je     f0100856 <monitor+0xaa>
f0100878:	eb 94                	jmp    f010080e <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f010087a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100881:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100882:	85 f6                	test   %esi,%esi
f0100884:	0f 84 58 ff ff ff    	je     f01007e2 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	68 be 49 10 f0       	push   $0xf01049be
f0100892:	ff 75 a8             	pushl  -0x58(%ebp)
f0100895:	e8 22 39 00 00       	call   f01041bc <strcmp>
f010089a:	83 c4 10             	add    $0x10,%esp
f010089d:	85 c0                	test   %eax,%eax
f010089f:	74 1e                	je     f01008bf <monitor+0x113>
f01008a1:	83 ec 08             	sub    $0x8,%esp
f01008a4:	68 cc 49 10 f0       	push   $0xf01049cc
f01008a9:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ac:	e8 0b 39 00 00       	call   f01041bc <strcmp>
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	75 2f                	jne    f01008e7 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01008bd:	eb 05                	jmp    f01008c4 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008bf:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01008c4:	83 ec 04             	sub    $0x4,%esp
f01008c7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01008ca:	01 d0                	add    %edx,%eax
f01008cc:	ff 75 08             	pushl  0x8(%ebp)
f01008cf:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008d2:	51                   	push   %ecx
f01008d3:	56                   	push   %esi
f01008d4:	ff 14 85 d4 4b 10 f0 	call   *-0xfefb42c(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008db:	83 c4 10             	add    $0x10,%esp
f01008de:	85 c0                	test   %eax,%eax
f01008e0:	78 1d                	js     f01008ff <monitor+0x153>
f01008e2:	e9 fb fe ff ff       	jmp    f01007e2 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008e7:	83 ec 08             	sub    $0x8,%esp
f01008ea:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ed:	68 5b 4a 10 f0       	push   $0xf0104a5b
f01008f2:	e8 03 26 00 00       	call   f0102efa <cprintf>
f01008f7:	83 c4 10             	add    $0x10,%esp
f01008fa:	e9 e3 fe ff ff       	jmp    f01007e2 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100902:	5b                   	pop    %ebx
f0100903:	5e                   	pop    %esi
f0100904:	5f                   	pop    %edi
f0100905:	5d                   	pop    %ebp
f0100906:	c3                   	ret    

f0100907 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100907:	55                   	push   %ebp
f0100908:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010090a:	83 3d 78 3f 17 f0 00 	cmpl   $0x0,0xf0173f78
f0100911:	75 11                	jne    f0100924 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100913:	ba 4f 5c 17 f0       	mov    $0xf0175c4f,%edx
f0100918:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010091e:	89 15 78 3f 17 f0    	mov    %edx,0xf0173f78
	// LAB 2: Your code here.
	//cprintf("boot_alloc, nextfree:%x\n", nextfree);
	if((nextfree+n)>(char *)0xffffffff)
		panic("out of memory!\n");
	char *res;
	res = nextfree;
f0100924:	8b 15 78 3f 17 f0    	mov    0xf0173f78,%edx
	if(n>0)
f010092a:	85 c0                	test   %eax,%eax
f010092c:	74 11                	je     f010093f <boot_alloc+0x38>
		nextfree = ROUNDUP( nextfree+n,PGSIZE);
f010092e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100935:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010093a:	a3 78 3f 17 f0       	mov    %eax,0xf0173f78
	return res;
}
f010093f:	89 d0                	mov    %edx,%eax
f0100941:	5d                   	pop    %ebp
f0100942:	c3                   	ret    

f0100943 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100943:	89 d1                	mov    %edx,%ecx
f0100945:	c1 e9 16             	shr    $0x16,%ecx
f0100948:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010094b:	a8 01                	test   $0x1,%al
f010094d:	74 52                	je     f01009a1 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010094f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100954:	89 c1                	mov    %eax,%ecx
f0100956:	c1 e9 0c             	shr    $0xc,%ecx
f0100959:	3b 0d 44 4c 17 f0    	cmp    0xf0174c44,%ecx
f010095f:	72 1b                	jb     f010097c <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100961:	55                   	push   %ebp
f0100962:	89 e5                	mov    %esp,%ebp
f0100964:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100967:	50                   	push   %eax
f0100968:	68 e4 4b 10 f0       	push   $0xf0104be4
f010096d:	68 23 03 00 00       	push   $0x323
f0100972:	68 f1 53 10 f0       	push   $0xf01053f1
f0100977:	e8 24 f7 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f010097c:	c1 ea 0c             	shr    $0xc,%edx
f010097f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100985:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010098c:	89 c2                	mov    %eax,%edx
f010098e:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100991:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100996:	85 d2                	test   %edx,%edx
f0100998:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010099d:	0f 44 c2             	cmove  %edx,%eax
f01009a0:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009a6:	c3                   	ret    

f01009a7 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009a7:	55                   	push   %ebp
f01009a8:	89 e5                	mov    %esp,%ebp
f01009aa:	57                   	push   %edi
f01009ab:	56                   	push   %esi
f01009ac:	53                   	push   %ebx
f01009ad:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009b0:	84 c0                	test   %al,%al
f01009b2:	0f 85 72 02 00 00    	jne    f0100c2a <check_page_free_list+0x283>
f01009b8:	e9 7f 02 00 00       	jmp    f0100c3c <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009bd:	83 ec 04             	sub    $0x4,%esp
f01009c0:	68 08 4c 10 f0       	push   $0xf0104c08
f01009c5:	68 61 02 00 00       	push   $0x261
f01009ca:	68 f1 53 10 f0       	push   $0xf01053f1
f01009cf:	e8 cc f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009d4:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009da:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009e0:	89 c2                	mov    %eax,%edx
f01009e2:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f01009e8:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01009ee:	0f 95 c2             	setne  %dl
f01009f1:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01009f4:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01009f8:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01009fa:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009fe:	8b 00                	mov    (%eax),%eax
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	75 dc                	jne    f01009e0 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a10:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a13:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a15:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a18:	a3 80 3f 17 f0       	mov    %eax,0xf0173f80
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a1d:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a22:	8b 1d 80 3f 17 f0    	mov    0xf0173f80,%ebx
f0100a28:	eb 53                	jmp    f0100a7d <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a2a:	89 d8                	mov    %ebx,%eax
f0100a2c:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0100a32:	c1 f8 03             	sar    $0x3,%eax
f0100a35:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a38:	89 c2                	mov    %eax,%edx
f0100a3a:	c1 ea 16             	shr    $0x16,%edx
f0100a3d:	39 f2                	cmp    %esi,%edx
f0100a3f:	73 3a                	jae    f0100a7b <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a41:	89 c2                	mov    %eax,%edx
f0100a43:	c1 ea 0c             	shr    $0xc,%edx
f0100a46:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100a4c:	72 12                	jb     f0100a60 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a4e:	50                   	push   %eax
f0100a4f:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100a54:	6a 56                	push   $0x56
f0100a56:	68 fd 53 10 f0       	push   $0xf01053fd
f0100a5b:	e8 40 f6 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a60:	83 ec 04             	sub    $0x4,%esp
f0100a63:	68 80 00 00 00       	push   $0x80
f0100a68:	68 97 00 00 00       	push   $0x97
f0100a6d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a72:	50                   	push   %eax
f0100a73:	e8 df 37 00 00       	call   f0104257 <memset>
f0100a78:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a7b:	8b 1b                	mov    (%ebx),%ebx
f0100a7d:	85 db                	test   %ebx,%ebx
f0100a7f:	75 a9                	jne    f0100a2a <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a81:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a86:	e8 7c fe ff ff       	call   f0100907 <boot_alloc>
f0100a8b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a8e:	8b 15 80 3f 17 f0    	mov    0xf0173f80,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a94:	8b 0d 4c 4c 17 f0    	mov    0xf0174c4c,%ecx
		assert(pp < pages + npages);
f0100a9a:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f0100a9f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100aa2:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100aa5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100aa8:	be 00 00 00 00       	mov    $0x0,%esi
f0100aad:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ab0:	e9 30 01 00 00       	jmp    f0100be5 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ab5:	39 ca                	cmp    %ecx,%edx
f0100ab7:	73 19                	jae    f0100ad2 <check_page_free_list+0x12b>
f0100ab9:	68 0b 54 10 f0       	push   $0xf010540b
f0100abe:	68 17 54 10 f0       	push   $0xf0105417
f0100ac3:	68 7b 02 00 00       	push   $0x27b
f0100ac8:	68 f1 53 10 f0       	push   $0xf01053f1
f0100acd:	e8 ce f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100ad2:	39 fa                	cmp    %edi,%edx
f0100ad4:	72 19                	jb     f0100aef <check_page_free_list+0x148>
f0100ad6:	68 2c 54 10 f0       	push   $0xf010542c
f0100adb:	68 17 54 10 f0       	push   $0xf0105417
f0100ae0:	68 7c 02 00 00       	push   $0x27c
f0100ae5:	68 f1 53 10 f0       	push   $0xf01053f1
f0100aea:	e8 b1 f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100aef:	89 d0                	mov    %edx,%eax
f0100af1:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100af4:	a8 07                	test   $0x7,%al
f0100af6:	74 19                	je     f0100b11 <check_page_free_list+0x16a>
f0100af8:	68 2c 4c 10 f0       	push   $0xf0104c2c
f0100afd:	68 17 54 10 f0       	push   $0xf0105417
f0100b02:	68 7d 02 00 00       	push   $0x27d
f0100b07:	68 f1 53 10 f0       	push   $0xf01053f1
f0100b0c:	e8 8f f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b11:	c1 f8 03             	sar    $0x3,%eax
f0100b14:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b17:	85 c0                	test   %eax,%eax
f0100b19:	75 19                	jne    f0100b34 <check_page_free_list+0x18d>
f0100b1b:	68 40 54 10 f0       	push   $0xf0105440
f0100b20:	68 17 54 10 f0       	push   $0xf0105417
f0100b25:	68 80 02 00 00       	push   $0x280
f0100b2a:	68 f1 53 10 f0       	push   $0xf01053f1
f0100b2f:	e8 6c f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b34:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b39:	75 19                	jne    f0100b54 <check_page_free_list+0x1ad>
f0100b3b:	68 51 54 10 f0       	push   $0xf0105451
f0100b40:	68 17 54 10 f0       	push   $0xf0105417
f0100b45:	68 81 02 00 00       	push   $0x281
f0100b4a:	68 f1 53 10 f0       	push   $0xf01053f1
f0100b4f:	e8 4c f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b54:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b59:	75 19                	jne    f0100b74 <check_page_free_list+0x1cd>
f0100b5b:	68 60 4c 10 f0       	push   $0xf0104c60
f0100b60:	68 17 54 10 f0       	push   $0xf0105417
f0100b65:	68 82 02 00 00       	push   $0x282
f0100b6a:	68 f1 53 10 f0       	push   $0xf01053f1
f0100b6f:	e8 2c f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b74:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b79:	75 19                	jne    f0100b94 <check_page_free_list+0x1ed>
f0100b7b:	68 6a 54 10 f0       	push   $0xf010546a
f0100b80:	68 17 54 10 f0       	push   $0xf0105417
f0100b85:	68 83 02 00 00       	push   $0x283
f0100b8a:	68 f1 53 10 f0       	push   $0xf01053f1
f0100b8f:	e8 0c f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b94:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100b99:	76 3f                	jbe    f0100bda <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b9b:	89 c3                	mov    %eax,%ebx
f0100b9d:	c1 eb 0c             	shr    $0xc,%ebx
f0100ba0:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100ba3:	77 12                	ja     f0100bb7 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba5:	50                   	push   %eax
f0100ba6:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100bab:	6a 56                	push   $0x56
f0100bad:	68 fd 53 10 f0       	push   $0xf01053fd
f0100bb2:	e8 e9 f4 ff ff       	call   f01000a0 <_panic>
f0100bb7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bbc:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100bbf:	76 1e                	jbe    f0100bdf <check_page_free_list+0x238>
f0100bc1:	68 84 4c 10 f0       	push   $0xf0104c84
f0100bc6:	68 17 54 10 f0       	push   $0xf0105417
f0100bcb:	68 84 02 00 00       	push   $0x284
f0100bd0:	68 f1 53 10 f0       	push   $0xf01053f1
f0100bd5:	e8 c6 f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100bda:	83 c6 01             	add    $0x1,%esi
f0100bdd:	eb 04                	jmp    f0100be3 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100bdf:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be3:	8b 12                	mov    (%edx),%edx
f0100be5:	85 d2                	test   %edx,%edx
f0100be7:	0f 85 c8 fe ff ff    	jne    f0100ab5 <check_page_free_list+0x10e>
f0100bed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100bf0:	85 f6                	test   %esi,%esi
f0100bf2:	7f 19                	jg     f0100c0d <check_page_free_list+0x266>
f0100bf4:	68 84 54 10 f0       	push   $0xf0105484
f0100bf9:	68 17 54 10 f0       	push   $0xf0105417
f0100bfe:	68 8c 02 00 00       	push   $0x28c
f0100c03:	68 f1 53 10 f0       	push   $0xf01053f1
f0100c08:	e8 93 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c0d:	85 db                	test   %ebx,%ebx
f0100c0f:	7f 42                	jg     f0100c53 <check_page_free_list+0x2ac>
f0100c11:	68 96 54 10 f0       	push   $0xf0105496
f0100c16:	68 17 54 10 f0       	push   $0xf0105417
f0100c1b:	68 8d 02 00 00       	push   $0x28d
f0100c20:	68 f1 53 10 f0       	push   $0xf01053f1
f0100c25:	e8 76 f4 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c2a:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f0100c2f:	85 c0                	test   %eax,%eax
f0100c31:	0f 85 9d fd ff ff    	jne    f01009d4 <check_page_free_list+0x2d>
f0100c37:	e9 81 fd ff ff       	jmp    f01009bd <check_page_free_list+0x16>
f0100c3c:	83 3d 80 3f 17 f0 00 	cmpl   $0x0,0xf0173f80
f0100c43:	0f 84 74 fd ff ff    	je     f01009bd <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c49:	be 00 04 00 00       	mov    $0x400,%esi
f0100c4e:	e9 cf fd ff ff       	jmp    f0100a22 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c56:	5b                   	pop    %ebx
f0100c57:	5e                   	pop    %esi
f0100c58:	5f                   	pop    %edi
f0100c59:	5d                   	pop    %ebp
f0100c5a:	c3                   	ret    

f0100c5b <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c5b:	55                   	push   %ebp
f0100c5c:	89 e5                	mov    %esp,%ebp
f0100c5e:	56                   	push   %esi
f0100c5f:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    size_t i;
    for (i = 1; i < npages_basemem; i++) {
f0100c60:	8b 35 84 3f 17 f0    	mov    0xf0173f84,%esi
f0100c66:	8b 1d 80 3f 17 f0    	mov    0xf0173f80,%ebx
f0100c6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c71:	b8 01 00 00 00       	mov    $0x1,%eax
f0100c76:	eb 27                	jmp    f0100c9f <page_init+0x44>
        pages[i].pp_ref = 0;
f0100c78:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100c7f:	89 d1                	mov    %edx,%ecx
f0100c81:	03 0d 4c 4c 17 f0    	add    0xf0174c4c,%ecx
f0100c87:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100c8d:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    size_t i;
    for (i = 1; i < npages_basemem; i++) {
f0100c8f:	83 c0 01             	add    $0x1,%eax
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
f0100c92:	89 d3                	mov    %edx,%ebx
f0100c94:	03 1d 4c 4c 17 f0    	add    0xf0174c4c,%ebx
f0100c9a:	ba 01 00 00 00       	mov    $0x1,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
    size_t i;
    for (i = 1; i < npages_basemem; i++) {
f0100c9f:	39 f0                	cmp    %esi,%eax
f0100ca1:	72 d5                	jb     f0100c78 <page_init+0x1d>
f0100ca3:	84 d2                	test   %dl,%dl
f0100ca5:	74 06                	je     f0100cad <page_init+0x52>
f0100ca7:	89 1d 80 3f 17 f0    	mov    %ebx,0xf0173f80
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }

    char *nextfree = boot_alloc(0);
f0100cad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb2:	e8 50 fc ff ff       	call   f0100907 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100cb7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100cbc:	77 15                	ja     f0100cd3 <page_init+0x78>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100cbe:	50                   	push   %eax
f0100cbf:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0100cc4:	68 1c 01 00 00       	push   $0x11c
f0100cc9:	68 f1 53 10 f0       	push   $0xf01053f1
f0100cce:	e8 cd f3 ff ff       	call   f01000a0 <_panic>
    size_t kern_end_page = PGNUM(PADDR(nextfree));
f0100cd3:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0100cd9:	c1 eb 0c             	shr    $0xc,%ebx
    cprintf("kern end pages:%d\n", kern_end_page);
f0100cdc:	83 ec 08             	sub    $0x8,%esp
f0100cdf:	53                   	push   %ebx
f0100ce0:	68 a7 54 10 f0       	push   $0xf01054a7
f0100ce5:	e8 10 22 00 00       	call   f0102efa <cprintf>
f0100cea:	8b 0d 80 3f 17 f0    	mov    0xf0173f80,%ecx
f0100cf0:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax

    for (i = kern_end_page; i < npages; i++) {
f0100cf7:	83 c4 10             	add    $0x10,%esp
f0100cfa:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cff:	eb 23                	jmp    f0100d24 <page_init+0xc9>
        pages[i].pp_ref = 0;
f0100d01:	89 c2                	mov    %eax,%edx
f0100d03:	03 15 4c 4c 17 f0    	add    0xf0174c4c,%edx
f0100d09:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0100d0f:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f0100d11:	89 c1                	mov    %eax,%ecx
f0100d13:	03 0d 4c 4c 17 f0    	add    0xf0174c4c,%ecx

    char *nextfree = boot_alloc(0);
    size_t kern_end_page = PGNUM(PADDR(nextfree));
    cprintf("kern end pages:%d\n", kern_end_page);

    for (i = kern_end_page; i < npages; i++) {
f0100d19:	83 c3 01             	add    $0x1,%ebx
f0100d1c:	83 c0 08             	add    $0x8,%eax
f0100d1f:	ba 01 00 00 00       	mov    $0x1,%edx
f0100d24:	3b 1d 44 4c 17 f0    	cmp    0xf0174c44,%ebx
f0100d2a:	72 d5                	jb     f0100d01 <page_init+0xa6>
f0100d2c:	84 d2                	test   %dl,%dl
f0100d2e:	74 06                	je     f0100d36 <page_init+0xdb>
f0100d30:	89 0d 80 3f 17 f0    	mov    %ecx,0xf0173f80
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
}
f0100d36:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d39:	5b                   	pop    %ebx
f0100d3a:	5e                   	pop    %esi
f0100d3b:	5d                   	pop    %ebp
f0100d3c:	c3                   	ret    

f0100d3d <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d3d:	55                   	push   %ebp
f0100d3e:	89 e5                	mov    %esp,%ebp
f0100d40:	53                   	push   %ebx
f0100d41:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list)
f0100d44:	8b 1d 80 3f 17 f0    	mov    0xf0173f80,%ebx
f0100d4a:	85 db                	test   %ebx,%ebx
f0100d4c:	74 52                	je     f0100da0 <page_alloc+0x63>
	{
		struct PageInfo* pp = page_free_list;
		page_free_list = page_free_list -> pp_link;
f0100d4e:	8b 03                	mov    (%ebx),%eax
f0100d50:	a3 80 3f 17 f0       	mov    %eax,0xf0173f80
		if(alloc_flags & ALLOC_ZERO)
f0100d55:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d59:	74 45                	je     f0100da0 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d5b:	89 d8                	mov    %ebx,%eax
f0100d5d:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0100d63:	c1 f8 03             	sar    $0x3,%eax
f0100d66:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d69:	89 c2                	mov    %eax,%edx
f0100d6b:	c1 ea 0c             	shr    $0xc,%edx
f0100d6e:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100d74:	72 12                	jb     f0100d88 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d76:	50                   	push   %eax
f0100d77:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100d7c:	6a 56                	push   $0x56
f0100d7e:	68 fd 53 10 f0       	push   $0xf01053fd
f0100d83:	e8 18 f3 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp),0,PGSIZE);
f0100d88:	83 ec 04             	sub    $0x4,%esp
f0100d8b:	68 00 10 00 00       	push   $0x1000
f0100d90:	6a 00                	push   $0x0
f0100d92:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d97:	50                   	push   %eax
f0100d98:	e8 ba 34 00 00       	call   f0104257 <memset>
f0100d9d:	83 c4 10             	add    $0x10,%esp
		return pp;
	}
		
	return NULL;
}
f0100da0:	89 d8                	mov    %ebx,%eax
f0100da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100da5:	c9                   	leave  
f0100da6:	c3                   	ret    

f0100da7 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100da7:	55                   	push   %ebp
f0100da8:	89 e5                	mov    %esp,%ebp
f0100daa:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//assert(pp->pp_ref==0 && pp->pp_link == NULL);
	pp->pp_link = page_free_list;
f0100dad:	8b 15 80 3f 17 f0    	mov    0xf0173f80,%edx
f0100db3:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100db5:	a3 80 3f 17 f0       	mov    %eax,0xf0173f80
}
f0100dba:	5d                   	pop    %ebp
f0100dbb:	c3                   	ret    

f0100dbc <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100dbc:	55                   	push   %ebp
f0100dbd:	89 e5                	mov    %esp,%ebp
f0100dbf:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100dc2:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100dc6:	83 e8 01             	sub    $0x1,%eax
f0100dc9:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100dcd:	66 85 c0             	test   %ax,%ax
f0100dd0:	75 09                	jne    f0100ddb <page_decref+0x1f>
		page_free(pp);
f0100dd2:	52                   	push   %edx
f0100dd3:	e8 cf ff ff ff       	call   f0100da7 <page_free>
f0100dd8:	83 c4 04             	add    $0x4,%esp
}
f0100ddb:	c9                   	leave  
f0100ddc:	c3                   	ret    

f0100ddd <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ddd:	55                   	push   %ebp
f0100dde:	89 e5                	mov    %esp,%ebp
f0100de0:	56                   	push   %esi
f0100de1:	53                   	push   %ebx
f0100de2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	int pde_index = PDX(va);
    int pte_index = PTX(va);
f0100de5:	89 de                	mov    %ebx,%esi
f0100de7:	c1 ee 0c             	shr    $0xc,%esi
f0100dea:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    pde_t *pde = &pgdir[pde_index];
f0100df0:	c1 eb 16             	shr    $0x16,%ebx
f0100df3:	c1 e3 02             	shl    $0x2,%ebx
f0100df6:	03 5d 08             	add    0x8(%ebp),%ebx
    if (!(*pde & PTE_P)) {
f0100df9:	f6 03 01             	testb  $0x1,(%ebx)
f0100dfc:	75 2d                	jne    f0100e2b <pgdir_walk+0x4e>
        if (create) {
f0100dfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e02:	74 59                	je     f0100e5d <pgdir_walk+0x80>
            struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0100e04:	83 ec 0c             	sub    $0xc,%esp
f0100e07:	6a 01                	push   $0x1
f0100e09:	e8 2f ff ff ff       	call   f0100d3d <page_alloc>
            if (!page) return NULL;
f0100e0e:	83 c4 10             	add    $0x10,%esp
f0100e11:	85 c0                	test   %eax,%eax
f0100e13:	74 4f                	je     f0100e64 <pgdir_walk+0x87>

            page->pp_ref++;
f0100e15:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
            *pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0100e1a:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0100e20:	c1 f8 03             	sar    $0x3,%eax
f0100e23:	c1 e0 0c             	shl    $0xc,%eax
f0100e26:	83 c8 07             	or     $0x7,%eax
f0100e29:	89 03                	mov    %eax,(%ebx)
        } else {
            return NULL;
        }   
    }   

    pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
f0100e2b:	8b 03                	mov    (%ebx),%eax
f0100e2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e32:	89 c2                	mov    %eax,%edx
f0100e34:	c1 ea 0c             	shr    $0xc,%edx
f0100e37:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0100e3d:	72 15                	jb     f0100e54 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e3f:	50                   	push   %eax
f0100e40:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100e45:	68 85 01 00 00       	push   $0x185
f0100e4a:	68 f1 53 10 f0       	push   $0xf01053f1
f0100e4f:	e8 4c f2 ff ff       	call   f01000a0 <_panic>
    return &p[pte_index];
f0100e54:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100e5b:	eb 0c                	jmp    f0100e69 <pgdir_walk+0x8c>
            if (!page) return NULL;

            page->pp_ref++;
            *pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
        } else {
            return NULL;
f0100e5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e62:	eb 05                	jmp    f0100e69 <pgdir_walk+0x8c>
    int pte_index = PTX(va);
    pde_t *pde = &pgdir[pde_index];
    if (!(*pde & PTE_P)) {
        if (create) {
            struct PageInfo *page = page_alloc(ALLOC_ZERO);
            if (!page) return NULL;
f0100e64:	b8 00 00 00 00       	mov    $0x0,%eax
        }   
    }   

    pte_t *p = (pte_t *) KADDR(PTE_ADDR(*pde));
    return &p[pte_index];
}
f0100e69:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e6c:	5b                   	pop    %ebx
f0100e6d:	5e                   	pop    %esi
f0100e6e:	5d                   	pop    %ebp
f0100e6f:	c3                   	ret    

f0100e70 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100e70:	55                   	push   %ebp
f0100e71:	89 e5                	mov    %esp,%ebp
f0100e73:	57                   	push   %edi
f0100e74:	56                   	push   %esi
f0100e75:	53                   	push   %ebx
f0100e76:	83 ec 1c             	sub    $0x1c,%esp
f0100e79:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e7c:	8b 45 08             	mov    0x8(%ebp),%eax
	int pages = PGNUM(size);
f0100e7f:	c1 e9 0c             	shr    $0xc,%ecx
f0100e82:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    int i;
	for (i = 0; i < pages; i++) {
f0100e85:	89 c3                	mov    %eax,%ebx
f0100e87:	be 00 00 00 00       	mov    $0x0,%esi
        pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0100e8c:	89 d7                	mov    %edx,%edi
f0100e8e:	29 c7                	sub    %eax,%edi
        if (!pte) {
            panic("boot_map_region panic: out of memory");
        }
        *pte = pa | perm | PTE_P;
f0100e90:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e93:	83 c8 01             	or     $0x1,%eax
f0100e96:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pages = PGNUM(size);
    int i;
	for (i = 0; i < pages; i++) {
f0100e99:	eb 3f                	jmp    f0100eda <boot_map_region+0x6a>
        pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0100e9b:	83 ec 04             	sub    $0x4,%esp
f0100e9e:	6a 01                	push   $0x1
f0100ea0:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0100ea3:	50                   	push   %eax
f0100ea4:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ea7:	e8 31 ff ff ff       	call   f0100ddd <pgdir_walk>
        if (!pte) {
f0100eac:	83 c4 10             	add    $0x10,%esp
f0100eaf:	85 c0                	test   %eax,%eax
f0100eb1:	75 17                	jne    f0100eca <boot_map_region+0x5a>
            panic("boot_map_region panic: out of memory");
f0100eb3:	83 ec 04             	sub    $0x4,%esp
f0100eb6:	68 f0 4c 10 f0       	push   $0xf0104cf0
f0100ebb:	68 9c 01 00 00       	push   $0x19c
f0100ec0:	68 f1 53 10 f0       	push   $0xf01053f1
f0100ec5:	e8 d6 f1 ff ff       	call   f01000a0 <_panic>
        }
        *pte = pa | perm | PTE_P;
f0100eca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ecd:	09 da                	or     %ebx,%edx
f0100ecf:	89 10                	mov    %edx,(%eax)
        va += PGSIZE, pa += PGSIZE;
f0100ed1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pages = PGNUM(size);
    int i;
	for (i = 0; i < pages; i++) {
f0100ed7:	83 c6 01             	add    $0x1,%esi
f0100eda:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100edd:	7c bc                	jl     f0100e9b <boot_map_region+0x2b>
        }
        *pte = pa | perm | PTE_P;
        va += PGSIZE, pa += PGSIZE;
    }
	// Fill this function in
}
f0100edf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ee2:	5b                   	pop    %ebx
f0100ee3:	5e                   	pop    %esi
f0100ee4:	5f                   	pop    %edi
f0100ee5:	5d                   	pop    %ebp
f0100ee6:	c3                   	ret    

f0100ee7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ee7:	55                   	push   %ebp
f0100ee8:	89 e5                	mov    %esp,%ebp
f0100eea:	53                   	push   %ebx
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100ef1:	6a 00                	push   $0x0
f0100ef3:	ff 75 0c             	pushl  0xc(%ebp)
f0100ef6:	ff 75 08             	pushl  0x8(%ebp)
f0100ef9:	e8 df fe ff ff       	call   f0100ddd <pgdir_walk>
    if (!pte || !(*pte & PTE_P)) {
f0100efe:	83 c4 10             	add    $0x10,%esp
f0100f01:	85 c0                	test   %eax,%eax
f0100f03:	74 37                	je     f0100f3c <page_lookup+0x55>
f0100f05:	f6 00 01             	testb  $0x1,(%eax)
f0100f08:	74 39                	je     f0100f43 <page_lookup+0x5c>
        return NULL;
    }

    if (pte_store) {
f0100f0a:	85 db                	test   %ebx,%ebx
f0100f0c:	74 02                	je     f0100f10 <page_lookup+0x29>
        *pte_store = pte;
f0100f0e:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f10:	8b 00                	mov    (%eax),%eax
f0100f12:	c1 e8 0c             	shr    $0xc,%eax
f0100f15:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0100f1b:	72 14                	jb     f0100f31 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100f1d:	83 ec 04             	sub    $0x4,%esp
f0100f20:	68 18 4d 10 f0       	push   $0xf0104d18
f0100f25:	6a 4f                	push   $0x4f
f0100f27:	68 fd 53 10 f0       	push   $0xf01053fd
f0100f2c:	e8 6f f1 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100f31:	8b 15 4c 4c 17 f0    	mov    0xf0174c4c,%edx
f0100f37:	8d 04 c2             	lea    (%edx,%eax,8),%eax
    }

    return pa2page(PTE_ADDR(*pte));
f0100f3a:	eb 0c                	jmp    f0100f48 <page_lookup+0x61>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
    if (!pte || !(*pte & PTE_P)) {
        return NULL;
f0100f3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f41:	eb 05                	jmp    f0100f48 <page_lookup+0x61>
f0100f43:	b8 00 00 00 00       	mov    $0x0,%eax
        *pte_store = pte;
    }

    return pa2page(PTE_ADDR(*pte));
	
}
f0100f48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f4b:	c9                   	leave  
f0100f4c:	c3                   	ret    

f0100f4d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f4d:	55                   	push   %ebp
f0100f4e:	89 e5                	mov    %esp,%ebp
f0100f50:	53                   	push   %ebx
f0100f51:	83 ec 18             	sub    $0x18,%esp
f0100f54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
    struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0100f57:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f5a:	50                   	push   %eax
f0100f5b:	53                   	push   %ebx
f0100f5c:	ff 75 08             	pushl  0x8(%ebp)
f0100f5f:	e8 83 ff ff ff       	call   f0100ee7 <page_lookup>
    if (!page || !(*pte & PTE_P)) {
f0100f64:	83 c4 10             	add    $0x10,%esp
f0100f67:	85 c0                	test   %eax,%eax
f0100f69:	74 1d                	je     f0100f88 <page_remove+0x3b>
f0100f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100f6e:	f6 02 01             	testb  $0x1,(%edx)
f0100f71:	74 15                	je     f0100f88 <page_remove+0x3b>
        return;
    }
    *pte = 0;
f0100f73:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    page_decref(page);
f0100f79:	83 ec 0c             	sub    $0xc,%esp
f0100f7c:	50                   	push   %eax
f0100f7d:	e8 3a fe ff ff       	call   f0100dbc <page_decref>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f82:	0f 01 3b             	invlpg (%ebx)
f0100f85:	83 c4 10             	add    $0x10,%esp
    tlb_invalidate(pgdir, va);
		
	// Fill this function in
	
}
f0100f88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f8b:	c9                   	leave  
f0100f8c:	c3                   	ret    

f0100f8d <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f8d:	55                   	push   %ebp
f0100f8e:	89 e5                	mov    %esp,%ebp
f0100f90:	57                   	push   %edi
f0100f91:	56                   	push   %esi
f0100f92:	53                   	push   %ebx
f0100f93:	83 ec 10             	sub    $0x10,%esp
f0100f96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f99:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100f9c:	6a 01                	push   $0x1
f0100f9e:	57                   	push   %edi
f0100f9f:	ff 75 08             	pushl  0x8(%ebp)
f0100fa2:	e8 36 fe ff ff       	call   f0100ddd <pgdir_walk>
    if (!pte) {
f0100fa7:	83 c4 10             	add    $0x10,%esp
f0100faa:	85 c0                	test   %eax,%eax
f0100fac:	74 38                	je     f0100fe6 <page_insert+0x59>
f0100fae:	89 c6                	mov    %eax,%esi
        return -E_NO_MEM;
    }

    pp->pp_ref++;
f0100fb0:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    if (*pte & PTE_P) {
f0100fb5:	f6 00 01             	testb  $0x1,(%eax)
f0100fb8:	74 0f                	je     f0100fc9 <page_insert+0x3c>
        page_remove(pgdir, va);
f0100fba:	83 ec 08             	sub    $0x8,%esp
f0100fbd:	57                   	push   %edi
f0100fbe:	ff 75 08             	pushl  0x8(%ebp)
f0100fc1:	e8 87 ff ff ff       	call   f0100f4d <page_remove>
f0100fc6:	83 c4 10             	add    $0x10,%esp
    }

    *pte = page2pa(pp) | perm | PTE_P;
f0100fc9:	2b 1d 4c 4c 17 f0    	sub    0xf0174c4c,%ebx
f0100fcf:	c1 fb 03             	sar    $0x3,%ebx
f0100fd2:	c1 e3 0c             	shl    $0xc,%ebx
f0100fd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fd8:	83 c8 01             	or     $0x1,%eax
f0100fdb:	09 c3                	or     %eax,%ebx
f0100fdd:	89 1e                	mov    %ebx,(%esi)
    return 0;
f0100fdf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe4:	eb 05                	jmp    f0100feb <page_insert+0x5e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (!pte) {
        return -E_NO_MEM;
f0100fe6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        page_remove(pgdir, va);
    }

    *pte = page2pa(pp) | perm | PTE_P;
    return 0;
}
f0100feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fee:	5b                   	pop    %ebx
f0100fef:	5e                   	pop    %esi
f0100ff0:	5f                   	pop    %edi
f0100ff1:	5d                   	pop    %ebp
f0100ff2:	c3                   	ret    

f0100ff3 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100ff3:	55                   	push   %ebp
f0100ff4:	89 e5                	mov    %esp,%ebp
f0100ff6:	57                   	push   %edi
f0100ff7:	56                   	push   %esi
f0100ff8:	53                   	push   %ebx
f0100ff9:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ffc:	6a 15                	push   $0x15
f0100ffe:	e8 90 1e 00 00       	call   f0102e93 <mc146818_read>
f0101003:	89 c3                	mov    %eax,%ebx
f0101005:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010100c:	e8 82 1e 00 00       	call   f0102e93 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101011:	c1 e0 08             	shl    $0x8,%eax
f0101014:	09 d8                	or     %ebx,%eax
f0101016:	c1 e0 0a             	shl    $0xa,%eax
f0101019:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010101f:	85 c0                	test   %eax,%eax
f0101021:	0f 48 c2             	cmovs  %edx,%eax
f0101024:	c1 f8 0c             	sar    $0xc,%eax
f0101027:	a3 84 3f 17 f0       	mov    %eax,0xf0173f84
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010102c:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101033:	e8 5b 1e 00 00       	call   f0102e93 <mc146818_read>
f0101038:	89 c3                	mov    %eax,%ebx
f010103a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101041:	e8 4d 1e 00 00       	call   f0102e93 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101046:	c1 e0 08             	shl    $0x8,%eax
f0101049:	09 d8                	or     %ebx,%eax
f010104b:	c1 e0 0a             	shl    $0xa,%eax
f010104e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101054:	83 c4 10             	add    $0x10,%esp
f0101057:	85 c0                	test   %eax,%eax
f0101059:	0f 48 c2             	cmovs  %edx,%eax
f010105c:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010105f:	85 c0                	test   %eax,%eax
f0101061:	74 0e                	je     f0101071 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101063:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101069:	89 15 44 4c 17 f0    	mov    %edx,0xf0174c44
f010106f:	eb 0c                	jmp    f010107d <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101071:	8b 15 84 3f 17 f0    	mov    0xf0173f84,%edx
f0101077:	89 15 44 4c 17 f0    	mov    %edx,0xf0174c44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010107d:	c1 e0 0c             	shl    $0xc,%eax
f0101080:	c1 e8 0a             	shr    $0xa,%eax
f0101083:	50                   	push   %eax
f0101084:	a1 84 3f 17 f0       	mov    0xf0173f84,%eax
f0101089:	c1 e0 0c             	shl    $0xc,%eax
f010108c:	c1 e8 0a             	shr    $0xa,%eax
f010108f:	50                   	push   %eax
f0101090:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f0101095:	c1 e0 0c             	shl    $0xc,%eax
f0101098:	c1 e8 0a             	shr    $0xa,%eax
f010109b:	50                   	push   %eax
f010109c:	68 38 4d 10 f0       	push   $0xf0104d38
f01010a1:	e8 54 1e 00 00       	call   f0102efa <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010a6:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010ab:	e8 57 f8 ff ff       	call   f0100907 <boot_alloc>
f01010b0:	a3 48 4c 17 f0       	mov    %eax,0xf0174c48
	memset(kern_pgdir, 0, PGSIZE);
f01010b5:	83 c4 0c             	add    $0xc,%esp
f01010b8:	68 00 10 00 00       	push   $0x1000
f01010bd:	6a 00                	push   $0x0
f01010bf:	50                   	push   %eax
f01010c0:	e8 92 31 00 00       	call   f0104257 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010c5:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010ca:	83 c4 10             	add    $0x10,%esp
f01010cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010d2:	77 15                	ja     f01010e9 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010d4:	50                   	push   %eax
f01010d5:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01010da:	68 90 00 00 00       	push   $0x90
f01010df:	68 f1 53 10 f0       	push   $0xf01053f1
f01010e4:	e8 b7 ef ff ff       	call   f01000a0 <_panic>
f01010e9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010ef:	83 ca 05             	or     $0x5,%edx
f01010f2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f01010f8:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f01010fd:	c1 e0 03             	shl    $0x3,%eax
f0101100:	e8 02 f8 ff ff       	call   f0100907 <boot_alloc>
f0101105:	a3 4c 4c 17 f0       	mov    %eax,0xf0174c4c
	memset(pages,0,sizeof(struct PageInfo) * npages);
f010110a:	83 ec 04             	sub    $0x4,%esp
f010110d:	8b 3d 44 4c 17 f0    	mov    0xf0174c44,%edi
f0101113:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010111a:	52                   	push   %edx
f010111b:	6a 00                	push   $0x0
f010111d:	50                   	push   %eax
f010111e:	e8 34 31 00 00       	call   f0104257 <memset>
	//pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);//分配相应的空间
f0101123:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101128:	e8 da f7 ff ff       	call   f0100907 <boot_alloc>
f010112d:	a3 8c 3f 17 f0       	mov    %eax,0xf0173f8c
	memset(envs,0,sizeof(struct Env)*NENV);
f0101132:	83 c4 0c             	add    $0xc,%esp
f0101135:	68 00 80 01 00       	push   $0x18000
f010113a:	6a 00                	push   $0x0
f010113c:	50                   	push   %eax
f010113d:	e8 15 31 00 00       	call   f0104257 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101142:	e8 14 fb ff ff       	call   f0100c5b <page_init>

	check_page_free_list(1);
f0101147:	b8 01 00 00 00       	mov    $0x1,%eax
f010114c:	e8 56 f8 ff ff       	call   f01009a7 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101151:	83 c4 10             	add    $0x10,%esp
f0101154:	83 3d 4c 4c 17 f0 00 	cmpl   $0x0,0xf0174c4c
f010115b:	75 17                	jne    f0101174 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f010115d:	83 ec 04             	sub    $0x4,%esp
f0101160:	68 ba 54 10 f0       	push   $0xf01054ba
f0101165:	68 9e 02 00 00       	push   $0x29e
f010116a:	68 f1 53 10 f0       	push   $0xf01053f1
f010116f:	e8 2c ef ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101174:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f0101179:	bb 00 00 00 00       	mov    $0x0,%ebx
f010117e:	eb 05                	jmp    f0101185 <mem_init+0x192>
		++nfree;
f0101180:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101183:	8b 00                	mov    (%eax),%eax
f0101185:	85 c0                	test   %eax,%eax
f0101187:	75 f7                	jne    f0101180 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101189:	83 ec 0c             	sub    $0xc,%esp
f010118c:	6a 00                	push   $0x0
f010118e:	e8 aa fb ff ff       	call   f0100d3d <page_alloc>
f0101193:	89 c7                	mov    %eax,%edi
f0101195:	83 c4 10             	add    $0x10,%esp
f0101198:	85 c0                	test   %eax,%eax
f010119a:	75 19                	jne    f01011b5 <mem_init+0x1c2>
f010119c:	68 d5 54 10 f0       	push   $0xf01054d5
f01011a1:	68 17 54 10 f0       	push   $0xf0105417
f01011a6:	68 a6 02 00 00       	push   $0x2a6
f01011ab:	68 f1 53 10 f0       	push   $0xf01053f1
f01011b0:	e8 eb ee ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01011b5:	83 ec 0c             	sub    $0xc,%esp
f01011b8:	6a 00                	push   $0x0
f01011ba:	e8 7e fb ff ff       	call   f0100d3d <page_alloc>
f01011bf:	89 c6                	mov    %eax,%esi
f01011c1:	83 c4 10             	add    $0x10,%esp
f01011c4:	85 c0                	test   %eax,%eax
f01011c6:	75 19                	jne    f01011e1 <mem_init+0x1ee>
f01011c8:	68 eb 54 10 f0       	push   $0xf01054eb
f01011cd:	68 17 54 10 f0       	push   $0xf0105417
f01011d2:	68 a7 02 00 00       	push   $0x2a7
f01011d7:	68 f1 53 10 f0       	push   $0xf01053f1
f01011dc:	e8 bf ee ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01011e1:	83 ec 0c             	sub    $0xc,%esp
f01011e4:	6a 00                	push   $0x0
f01011e6:	e8 52 fb ff ff       	call   f0100d3d <page_alloc>
f01011eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011ee:	83 c4 10             	add    $0x10,%esp
f01011f1:	85 c0                	test   %eax,%eax
f01011f3:	75 19                	jne    f010120e <mem_init+0x21b>
f01011f5:	68 01 55 10 f0       	push   $0xf0105501
f01011fa:	68 17 54 10 f0       	push   $0xf0105417
f01011ff:	68 a8 02 00 00       	push   $0x2a8
f0101204:	68 f1 53 10 f0       	push   $0xf01053f1
f0101209:	e8 92 ee ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010120e:	39 f7                	cmp    %esi,%edi
f0101210:	75 19                	jne    f010122b <mem_init+0x238>
f0101212:	68 17 55 10 f0       	push   $0xf0105517
f0101217:	68 17 54 10 f0       	push   $0xf0105417
f010121c:	68 ab 02 00 00       	push   $0x2ab
f0101221:	68 f1 53 10 f0       	push   $0xf01053f1
f0101226:	e8 75 ee ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010122b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010122e:	39 c6                	cmp    %eax,%esi
f0101230:	74 04                	je     f0101236 <mem_init+0x243>
f0101232:	39 c7                	cmp    %eax,%edi
f0101234:	75 19                	jne    f010124f <mem_init+0x25c>
f0101236:	68 74 4d 10 f0       	push   $0xf0104d74
f010123b:	68 17 54 10 f0       	push   $0xf0105417
f0101240:	68 ac 02 00 00       	push   $0x2ac
f0101245:	68 f1 53 10 f0       	push   $0xf01053f1
f010124a:	e8 51 ee ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010124f:	8b 0d 4c 4c 17 f0    	mov    0xf0174c4c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101255:	8b 15 44 4c 17 f0    	mov    0xf0174c44,%edx
f010125b:	c1 e2 0c             	shl    $0xc,%edx
f010125e:	89 f8                	mov    %edi,%eax
f0101260:	29 c8                	sub    %ecx,%eax
f0101262:	c1 f8 03             	sar    $0x3,%eax
f0101265:	c1 e0 0c             	shl    $0xc,%eax
f0101268:	39 d0                	cmp    %edx,%eax
f010126a:	72 19                	jb     f0101285 <mem_init+0x292>
f010126c:	68 29 55 10 f0       	push   $0xf0105529
f0101271:	68 17 54 10 f0       	push   $0xf0105417
f0101276:	68 ad 02 00 00       	push   $0x2ad
f010127b:	68 f1 53 10 f0       	push   $0xf01053f1
f0101280:	e8 1b ee ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101285:	89 f0                	mov    %esi,%eax
f0101287:	29 c8                	sub    %ecx,%eax
f0101289:	c1 f8 03             	sar    $0x3,%eax
f010128c:	c1 e0 0c             	shl    $0xc,%eax
f010128f:	39 c2                	cmp    %eax,%edx
f0101291:	77 19                	ja     f01012ac <mem_init+0x2b9>
f0101293:	68 46 55 10 f0       	push   $0xf0105546
f0101298:	68 17 54 10 f0       	push   $0xf0105417
f010129d:	68 ae 02 00 00       	push   $0x2ae
f01012a2:	68 f1 53 10 f0       	push   $0xf01053f1
f01012a7:	e8 f4 ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012af:	29 c8                	sub    %ecx,%eax
f01012b1:	c1 f8 03             	sar    $0x3,%eax
f01012b4:	c1 e0 0c             	shl    $0xc,%eax
f01012b7:	39 c2                	cmp    %eax,%edx
f01012b9:	77 19                	ja     f01012d4 <mem_init+0x2e1>
f01012bb:	68 63 55 10 f0       	push   $0xf0105563
f01012c0:	68 17 54 10 f0       	push   $0xf0105417
f01012c5:	68 af 02 00 00       	push   $0x2af
f01012ca:	68 f1 53 10 f0       	push   $0xf01053f1
f01012cf:	e8 cc ed ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01012d4:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f01012d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01012dc:	c7 05 80 3f 17 f0 00 	movl   $0x0,0xf0173f80
f01012e3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01012e6:	83 ec 0c             	sub    $0xc,%esp
f01012e9:	6a 00                	push   $0x0
f01012eb:	e8 4d fa ff ff       	call   f0100d3d <page_alloc>
f01012f0:	83 c4 10             	add    $0x10,%esp
f01012f3:	85 c0                	test   %eax,%eax
f01012f5:	74 19                	je     f0101310 <mem_init+0x31d>
f01012f7:	68 80 55 10 f0       	push   $0xf0105580
f01012fc:	68 17 54 10 f0       	push   $0xf0105417
f0101301:	68 b6 02 00 00       	push   $0x2b6
f0101306:	68 f1 53 10 f0       	push   $0xf01053f1
f010130b:	e8 90 ed ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101310:	83 ec 0c             	sub    $0xc,%esp
f0101313:	57                   	push   %edi
f0101314:	e8 8e fa ff ff       	call   f0100da7 <page_free>
	page_free(pp1);
f0101319:	89 34 24             	mov    %esi,(%esp)
f010131c:	e8 86 fa ff ff       	call   f0100da7 <page_free>
	page_free(pp2);
f0101321:	83 c4 04             	add    $0x4,%esp
f0101324:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101327:	e8 7b fa ff ff       	call   f0100da7 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010132c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101333:	e8 05 fa ff ff       	call   f0100d3d <page_alloc>
f0101338:	89 c6                	mov    %eax,%esi
f010133a:	83 c4 10             	add    $0x10,%esp
f010133d:	85 c0                	test   %eax,%eax
f010133f:	75 19                	jne    f010135a <mem_init+0x367>
f0101341:	68 d5 54 10 f0       	push   $0xf01054d5
f0101346:	68 17 54 10 f0       	push   $0xf0105417
f010134b:	68 bd 02 00 00       	push   $0x2bd
f0101350:	68 f1 53 10 f0       	push   $0xf01053f1
f0101355:	e8 46 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010135a:	83 ec 0c             	sub    $0xc,%esp
f010135d:	6a 00                	push   $0x0
f010135f:	e8 d9 f9 ff ff       	call   f0100d3d <page_alloc>
f0101364:	89 c7                	mov    %eax,%edi
f0101366:	83 c4 10             	add    $0x10,%esp
f0101369:	85 c0                	test   %eax,%eax
f010136b:	75 19                	jne    f0101386 <mem_init+0x393>
f010136d:	68 eb 54 10 f0       	push   $0xf01054eb
f0101372:	68 17 54 10 f0       	push   $0xf0105417
f0101377:	68 be 02 00 00       	push   $0x2be
f010137c:	68 f1 53 10 f0       	push   $0xf01053f1
f0101381:	e8 1a ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101386:	83 ec 0c             	sub    $0xc,%esp
f0101389:	6a 00                	push   $0x0
f010138b:	e8 ad f9 ff ff       	call   f0100d3d <page_alloc>
f0101390:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101393:	83 c4 10             	add    $0x10,%esp
f0101396:	85 c0                	test   %eax,%eax
f0101398:	75 19                	jne    f01013b3 <mem_init+0x3c0>
f010139a:	68 01 55 10 f0       	push   $0xf0105501
f010139f:	68 17 54 10 f0       	push   $0xf0105417
f01013a4:	68 bf 02 00 00       	push   $0x2bf
f01013a9:	68 f1 53 10 f0       	push   $0xf01053f1
f01013ae:	e8 ed ec ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013b3:	39 fe                	cmp    %edi,%esi
f01013b5:	75 19                	jne    f01013d0 <mem_init+0x3dd>
f01013b7:	68 17 55 10 f0       	push   $0xf0105517
f01013bc:	68 17 54 10 f0       	push   $0xf0105417
f01013c1:	68 c1 02 00 00       	push   $0x2c1
f01013c6:	68 f1 53 10 f0       	push   $0xf01053f1
f01013cb:	e8 d0 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013d3:	39 c7                	cmp    %eax,%edi
f01013d5:	74 04                	je     f01013db <mem_init+0x3e8>
f01013d7:	39 c6                	cmp    %eax,%esi
f01013d9:	75 19                	jne    f01013f4 <mem_init+0x401>
f01013db:	68 74 4d 10 f0       	push   $0xf0104d74
f01013e0:	68 17 54 10 f0       	push   $0xf0105417
f01013e5:	68 c2 02 00 00       	push   $0x2c2
f01013ea:	68 f1 53 10 f0       	push   $0xf01053f1
f01013ef:	e8 ac ec ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01013f4:	83 ec 0c             	sub    $0xc,%esp
f01013f7:	6a 00                	push   $0x0
f01013f9:	e8 3f f9 ff ff       	call   f0100d3d <page_alloc>
f01013fe:	83 c4 10             	add    $0x10,%esp
f0101401:	85 c0                	test   %eax,%eax
f0101403:	74 19                	je     f010141e <mem_init+0x42b>
f0101405:	68 80 55 10 f0       	push   $0xf0105580
f010140a:	68 17 54 10 f0       	push   $0xf0105417
f010140f:	68 c3 02 00 00       	push   $0x2c3
f0101414:	68 f1 53 10 f0       	push   $0xf01053f1
f0101419:	e8 82 ec ff ff       	call   f01000a0 <_panic>
f010141e:	89 f0                	mov    %esi,%eax
f0101420:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101426:	c1 f8 03             	sar    $0x3,%eax
f0101429:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010142c:	89 c2                	mov    %eax,%edx
f010142e:	c1 ea 0c             	shr    $0xc,%edx
f0101431:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0101437:	72 12                	jb     f010144b <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101439:	50                   	push   %eax
f010143a:	68 e4 4b 10 f0       	push   $0xf0104be4
f010143f:	6a 56                	push   $0x56
f0101441:	68 fd 53 10 f0       	push   $0xf01053fd
f0101446:	e8 55 ec ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010144b:	83 ec 04             	sub    $0x4,%esp
f010144e:	68 00 10 00 00       	push   $0x1000
f0101453:	6a 01                	push   $0x1
f0101455:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010145a:	50                   	push   %eax
f010145b:	e8 f7 2d 00 00       	call   f0104257 <memset>
	page_free(pp0);
f0101460:	89 34 24             	mov    %esi,(%esp)
f0101463:	e8 3f f9 ff ff       	call   f0100da7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101468:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010146f:	e8 c9 f8 ff ff       	call   f0100d3d <page_alloc>
f0101474:	83 c4 10             	add    $0x10,%esp
f0101477:	85 c0                	test   %eax,%eax
f0101479:	75 19                	jne    f0101494 <mem_init+0x4a1>
f010147b:	68 8f 55 10 f0       	push   $0xf010558f
f0101480:	68 17 54 10 f0       	push   $0xf0105417
f0101485:	68 c8 02 00 00       	push   $0x2c8
f010148a:	68 f1 53 10 f0       	push   $0xf01053f1
f010148f:	e8 0c ec ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101494:	39 c6                	cmp    %eax,%esi
f0101496:	74 19                	je     f01014b1 <mem_init+0x4be>
f0101498:	68 ad 55 10 f0       	push   $0xf01055ad
f010149d:	68 17 54 10 f0       	push   $0xf0105417
f01014a2:	68 c9 02 00 00       	push   $0x2c9
f01014a7:	68 f1 53 10 f0       	push   $0xf01053f1
f01014ac:	e8 ef eb ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014b1:	89 f0                	mov    %esi,%eax
f01014b3:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01014b9:	c1 f8 03             	sar    $0x3,%eax
f01014bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014bf:	89 c2                	mov    %eax,%edx
f01014c1:	c1 ea 0c             	shr    $0xc,%edx
f01014c4:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f01014ca:	72 12                	jb     f01014de <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014cc:	50                   	push   %eax
f01014cd:	68 e4 4b 10 f0       	push   $0xf0104be4
f01014d2:	6a 56                	push   $0x56
f01014d4:	68 fd 53 10 f0       	push   $0xf01053fd
f01014d9:	e8 c2 eb ff ff       	call   f01000a0 <_panic>
f01014de:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01014e4:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014ea:	80 38 00             	cmpb   $0x0,(%eax)
f01014ed:	74 19                	je     f0101508 <mem_init+0x515>
f01014ef:	68 bd 55 10 f0       	push   $0xf01055bd
f01014f4:	68 17 54 10 f0       	push   $0xf0105417
f01014f9:	68 cc 02 00 00       	push   $0x2cc
f01014fe:	68 f1 53 10 f0       	push   $0xf01053f1
f0101503:	e8 98 eb ff ff       	call   f01000a0 <_panic>
f0101508:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010150b:	39 d0                	cmp    %edx,%eax
f010150d:	75 db                	jne    f01014ea <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010150f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101512:	a3 80 3f 17 f0       	mov    %eax,0xf0173f80

	// free the pages we took
	page_free(pp0);
f0101517:	83 ec 0c             	sub    $0xc,%esp
f010151a:	56                   	push   %esi
f010151b:	e8 87 f8 ff ff       	call   f0100da7 <page_free>
	page_free(pp1);
f0101520:	89 3c 24             	mov    %edi,(%esp)
f0101523:	e8 7f f8 ff ff       	call   f0100da7 <page_free>
	page_free(pp2);
f0101528:	83 c4 04             	add    $0x4,%esp
f010152b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010152e:	e8 74 f8 ff ff       	call   f0100da7 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101533:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	eb 05                	jmp    f0101542 <mem_init+0x54f>
		--nfree;
f010153d:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101540:	8b 00                	mov    (%eax),%eax
f0101542:	85 c0                	test   %eax,%eax
f0101544:	75 f7                	jne    f010153d <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101546:	85 db                	test   %ebx,%ebx
f0101548:	74 19                	je     f0101563 <mem_init+0x570>
f010154a:	68 c7 55 10 f0       	push   $0xf01055c7
f010154f:	68 17 54 10 f0       	push   $0xf0105417
f0101554:	68 d9 02 00 00       	push   $0x2d9
f0101559:	68 f1 53 10 f0       	push   $0xf01053f1
f010155e:	e8 3d eb ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101563:	83 ec 0c             	sub    $0xc,%esp
f0101566:	68 94 4d 10 f0       	push   $0xf0104d94
f010156b:	e8 8a 19 00 00       	call   f0102efa <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101577:	e8 c1 f7 ff ff       	call   f0100d3d <page_alloc>
f010157c:	89 c6                	mov    %eax,%esi
f010157e:	83 c4 10             	add    $0x10,%esp
f0101581:	85 c0                	test   %eax,%eax
f0101583:	75 19                	jne    f010159e <mem_init+0x5ab>
f0101585:	68 d5 54 10 f0       	push   $0xf01054d5
f010158a:	68 17 54 10 f0       	push   $0xf0105417
f010158f:	68 37 03 00 00       	push   $0x337
f0101594:	68 f1 53 10 f0       	push   $0xf01053f1
f0101599:	e8 02 eb ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010159e:	83 ec 0c             	sub    $0xc,%esp
f01015a1:	6a 00                	push   $0x0
f01015a3:	e8 95 f7 ff ff       	call   f0100d3d <page_alloc>
f01015a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ab:	83 c4 10             	add    $0x10,%esp
f01015ae:	85 c0                	test   %eax,%eax
f01015b0:	75 19                	jne    f01015cb <mem_init+0x5d8>
f01015b2:	68 eb 54 10 f0       	push   $0xf01054eb
f01015b7:	68 17 54 10 f0       	push   $0xf0105417
f01015bc:	68 38 03 00 00       	push   $0x338
f01015c1:	68 f1 53 10 f0       	push   $0xf01053f1
f01015c6:	e8 d5 ea ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01015cb:	83 ec 0c             	sub    $0xc,%esp
f01015ce:	6a 00                	push   $0x0
f01015d0:	e8 68 f7 ff ff       	call   f0100d3d <page_alloc>
f01015d5:	89 c3                	mov    %eax,%ebx
f01015d7:	83 c4 10             	add    $0x10,%esp
f01015da:	85 c0                	test   %eax,%eax
f01015dc:	75 19                	jne    f01015f7 <mem_init+0x604>
f01015de:	68 01 55 10 f0       	push   $0xf0105501
f01015e3:	68 17 54 10 f0       	push   $0xf0105417
f01015e8:	68 39 03 00 00       	push   $0x339
f01015ed:	68 f1 53 10 f0       	push   $0xf01053f1
f01015f2:	e8 a9 ea ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015f7:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015fa:	75 19                	jne    f0101615 <mem_init+0x622>
f01015fc:	68 17 55 10 f0       	push   $0xf0105517
f0101601:	68 17 54 10 f0       	push   $0xf0105417
f0101606:	68 3c 03 00 00       	push   $0x33c
f010160b:	68 f1 53 10 f0       	push   $0xf01053f1
f0101610:	e8 8b ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101615:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101618:	74 04                	je     f010161e <mem_init+0x62b>
f010161a:	39 c6                	cmp    %eax,%esi
f010161c:	75 19                	jne    f0101637 <mem_init+0x644>
f010161e:	68 74 4d 10 f0       	push   $0xf0104d74
f0101623:	68 17 54 10 f0       	push   $0xf0105417
f0101628:	68 3d 03 00 00       	push   $0x33d
f010162d:	68 f1 53 10 f0       	push   $0xf01053f1
f0101632:	e8 69 ea ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101637:	a1 80 3f 17 f0       	mov    0xf0173f80,%eax
f010163c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010163f:	c7 05 80 3f 17 f0 00 	movl   $0x0,0xf0173f80
f0101646:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101649:	83 ec 0c             	sub    $0xc,%esp
f010164c:	6a 00                	push   $0x0
f010164e:	e8 ea f6 ff ff       	call   f0100d3d <page_alloc>
f0101653:	83 c4 10             	add    $0x10,%esp
f0101656:	85 c0                	test   %eax,%eax
f0101658:	74 19                	je     f0101673 <mem_init+0x680>
f010165a:	68 80 55 10 f0       	push   $0xf0105580
f010165f:	68 17 54 10 f0       	push   $0xf0105417
f0101664:	68 44 03 00 00       	push   $0x344
f0101669:	68 f1 53 10 f0       	push   $0xf01053f1
f010166e:	e8 2d ea ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101673:	83 ec 04             	sub    $0x4,%esp
f0101676:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101679:	50                   	push   %eax
f010167a:	6a 00                	push   $0x0
f010167c:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101682:	e8 60 f8 ff ff       	call   f0100ee7 <page_lookup>
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	85 c0                	test   %eax,%eax
f010168c:	74 19                	je     f01016a7 <mem_init+0x6b4>
f010168e:	68 b4 4d 10 f0       	push   $0xf0104db4
f0101693:	68 17 54 10 f0       	push   $0xf0105417
f0101698:	68 47 03 00 00       	push   $0x347
f010169d:	68 f1 53 10 f0       	push   $0xf01053f1
f01016a2:	e8 f9 e9 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016a7:	6a 02                	push   $0x2
f01016a9:	6a 00                	push   $0x0
f01016ab:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016ae:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01016b4:	e8 d4 f8 ff ff       	call   f0100f8d <page_insert>
f01016b9:	83 c4 10             	add    $0x10,%esp
f01016bc:	85 c0                	test   %eax,%eax
f01016be:	78 19                	js     f01016d9 <mem_init+0x6e6>
f01016c0:	68 ec 4d 10 f0       	push   $0xf0104dec
f01016c5:	68 17 54 10 f0       	push   $0xf0105417
f01016ca:	68 4a 03 00 00       	push   $0x34a
f01016cf:	68 f1 53 10 f0       	push   $0xf01053f1
f01016d4:	e8 c7 e9 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016d9:	83 ec 0c             	sub    $0xc,%esp
f01016dc:	56                   	push   %esi
f01016dd:	e8 c5 f6 ff ff       	call   f0100da7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016e2:	6a 02                	push   $0x2
f01016e4:	6a 00                	push   $0x0
f01016e6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016e9:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01016ef:	e8 99 f8 ff ff       	call   f0100f8d <page_insert>
f01016f4:	83 c4 20             	add    $0x20,%esp
f01016f7:	85 c0                	test   %eax,%eax
f01016f9:	74 19                	je     f0101714 <mem_init+0x721>
f01016fb:	68 1c 4e 10 f0       	push   $0xf0104e1c
f0101700:	68 17 54 10 f0       	push   $0xf0105417
f0101705:	68 4e 03 00 00       	push   $0x34e
f010170a:	68 f1 53 10 f0       	push   $0xf01053f1
f010170f:	e8 8c e9 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101714:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010171a:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
f010171f:	89 c1                	mov    %eax,%ecx
f0101721:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101724:	8b 17                	mov    (%edi),%edx
f0101726:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010172c:	89 f0                	mov    %esi,%eax
f010172e:	29 c8                	sub    %ecx,%eax
f0101730:	c1 f8 03             	sar    $0x3,%eax
f0101733:	c1 e0 0c             	shl    $0xc,%eax
f0101736:	39 c2                	cmp    %eax,%edx
f0101738:	74 19                	je     f0101753 <mem_init+0x760>
f010173a:	68 4c 4e 10 f0       	push   $0xf0104e4c
f010173f:	68 17 54 10 f0       	push   $0xf0105417
f0101744:	68 4f 03 00 00       	push   $0x34f
f0101749:	68 f1 53 10 f0       	push   $0xf01053f1
f010174e:	e8 4d e9 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101753:	ba 00 00 00 00       	mov    $0x0,%edx
f0101758:	89 f8                	mov    %edi,%eax
f010175a:	e8 e4 f1 ff ff       	call   f0100943 <check_va2pa>
f010175f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101762:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101765:	c1 fa 03             	sar    $0x3,%edx
f0101768:	c1 e2 0c             	shl    $0xc,%edx
f010176b:	39 d0                	cmp    %edx,%eax
f010176d:	74 19                	je     f0101788 <mem_init+0x795>
f010176f:	68 74 4e 10 f0       	push   $0xf0104e74
f0101774:	68 17 54 10 f0       	push   $0xf0105417
f0101779:	68 50 03 00 00       	push   $0x350
f010177e:	68 f1 53 10 f0       	push   $0xf01053f1
f0101783:	e8 18 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101788:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010178b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101790:	74 19                	je     f01017ab <mem_init+0x7b8>
f0101792:	68 d2 55 10 f0       	push   $0xf01055d2
f0101797:	68 17 54 10 f0       	push   $0xf0105417
f010179c:	68 51 03 00 00       	push   $0x351
f01017a1:	68 f1 53 10 f0       	push   $0xf01053f1
f01017a6:	e8 f5 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f01017ab:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017b0:	74 19                	je     f01017cb <mem_init+0x7d8>
f01017b2:	68 e3 55 10 f0       	push   $0xf01055e3
f01017b7:	68 17 54 10 f0       	push   $0xf0105417
f01017bc:	68 52 03 00 00       	push   $0x352
f01017c1:	68 f1 53 10 f0       	push   $0xf01053f1
f01017c6:	e8 d5 e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017cb:	6a 02                	push   $0x2
f01017cd:	68 00 10 00 00       	push   $0x1000
f01017d2:	53                   	push   %ebx
f01017d3:	57                   	push   %edi
f01017d4:	e8 b4 f7 ff ff       	call   f0100f8d <page_insert>
f01017d9:	83 c4 10             	add    $0x10,%esp
f01017dc:	85 c0                	test   %eax,%eax
f01017de:	74 19                	je     f01017f9 <mem_init+0x806>
f01017e0:	68 a4 4e 10 f0       	push   $0xf0104ea4
f01017e5:	68 17 54 10 f0       	push   $0xf0105417
f01017ea:	68 55 03 00 00       	push   $0x355
f01017ef:	68 f1 53 10 f0       	push   $0xf01053f1
f01017f4:	e8 a7 e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017f9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017fe:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f0101803:	e8 3b f1 ff ff       	call   f0100943 <check_va2pa>
f0101808:	89 da                	mov    %ebx,%edx
f010180a:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f0101810:	c1 fa 03             	sar    $0x3,%edx
f0101813:	c1 e2 0c             	shl    $0xc,%edx
f0101816:	39 d0                	cmp    %edx,%eax
f0101818:	74 19                	je     f0101833 <mem_init+0x840>
f010181a:	68 e0 4e 10 f0       	push   $0xf0104ee0
f010181f:	68 17 54 10 f0       	push   $0xf0105417
f0101824:	68 56 03 00 00       	push   $0x356
f0101829:	68 f1 53 10 f0       	push   $0xf01053f1
f010182e:	e8 6d e8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101833:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101838:	74 19                	je     f0101853 <mem_init+0x860>
f010183a:	68 f4 55 10 f0       	push   $0xf01055f4
f010183f:	68 17 54 10 f0       	push   $0xf0105417
f0101844:	68 57 03 00 00       	push   $0x357
f0101849:	68 f1 53 10 f0       	push   $0xf01053f1
f010184e:	e8 4d e8 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101853:	83 ec 0c             	sub    $0xc,%esp
f0101856:	6a 00                	push   $0x0
f0101858:	e8 e0 f4 ff ff       	call   f0100d3d <page_alloc>
f010185d:	83 c4 10             	add    $0x10,%esp
f0101860:	85 c0                	test   %eax,%eax
f0101862:	74 19                	je     f010187d <mem_init+0x88a>
f0101864:	68 80 55 10 f0       	push   $0xf0105580
f0101869:	68 17 54 10 f0       	push   $0xf0105417
f010186e:	68 5a 03 00 00       	push   $0x35a
f0101873:	68 f1 53 10 f0       	push   $0xf01053f1
f0101878:	e8 23 e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010187d:	6a 02                	push   $0x2
f010187f:	68 00 10 00 00       	push   $0x1000
f0101884:	53                   	push   %ebx
f0101885:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f010188b:	e8 fd f6 ff ff       	call   f0100f8d <page_insert>
f0101890:	83 c4 10             	add    $0x10,%esp
f0101893:	85 c0                	test   %eax,%eax
f0101895:	74 19                	je     f01018b0 <mem_init+0x8bd>
f0101897:	68 a4 4e 10 f0       	push   $0xf0104ea4
f010189c:	68 17 54 10 f0       	push   $0xf0105417
f01018a1:	68 5d 03 00 00       	push   $0x35d
f01018a6:	68 f1 53 10 f0       	push   $0xf01053f1
f01018ab:	e8 f0 e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018b0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018b5:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f01018ba:	e8 84 f0 ff ff       	call   f0100943 <check_va2pa>
f01018bf:	89 da                	mov    %ebx,%edx
f01018c1:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f01018c7:	c1 fa 03             	sar    $0x3,%edx
f01018ca:	c1 e2 0c             	shl    $0xc,%edx
f01018cd:	39 d0                	cmp    %edx,%eax
f01018cf:	74 19                	je     f01018ea <mem_init+0x8f7>
f01018d1:	68 e0 4e 10 f0       	push   $0xf0104ee0
f01018d6:	68 17 54 10 f0       	push   $0xf0105417
f01018db:	68 5e 03 00 00       	push   $0x35e
f01018e0:	68 f1 53 10 f0       	push   $0xf01053f1
f01018e5:	e8 b6 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01018ea:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018ef:	74 19                	je     f010190a <mem_init+0x917>
f01018f1:	68 f4 55 10 f0       	push   $0xf01055f4
f01018f6:	68 17 54 10 f0       	push   $0xf0105417
f01018fb:	68 5f 03 00 00       	push   $0x35f
f0101900:	68 f1 53 10 f0       	push   $0xf01053f1
f0101905:	e8 96 e7 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010190a:	83 ec 0c             	sub    $0xc,%esp
f010190d:	6a 00                	push   $0x0
f010190f:	e8 29 f4 ff ff       	call   f0100d3d <page_alloc>
f0101914:	83 c4 10             	add    $0x10,%esp
f0101917:	85 c0                	test   %eax,%eax
f0101919:	74 19                	je     f0101934 <mem_init+0x941>
f010191b:	68 80 55 10 f0       	push   $0xf0105580
f0101920:	68 17 54 10 f0       	push   $0xf0105417
f0101925:	68 63 03 00 00       	push   $0x363
f010192a:	68 f1 53 10 f0       	push   $0xf01053f1
f010192f:	e8 6c e7 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101934:	8b 15 48 4c 17 f0    	mov    0xf0174c48,%edx
f010193a:	8b 02                	mov    (%edx),%eax
f010193c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101941:	89 c1                	mov    %eax,%ecx
f0101943:	c1 e9 0c             	shr    $0xc,%ecx
f0101946:	3b 0d 44 4c 17 f0    	cmp    0xf0174c44,%ecx
f010194c:	72 15                	jb     f0101963 <mem_init+0x970>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010194e:	50                   	push   %eax
f010194f:	68 e4 4b 10 f0       	push   $0xf0104be4
f0101954:	68 66 03 00 00       	push   $0x366
f0101959:	68 f1 53 10 f0       	push   $0xf01053f1
f010195e:	e8 3d e7 ff ff       	call   f01000a0 <_panic>
f0101963:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010196b:	83 ec 04             	sub    $0x4,%esp
f010196e:	6a 00                	push   $0x0
f0101970:	68 00 10 00 00       	push   $0x1000
f0101975:	52                   	push   %edx
f0101976:	e8 62 f4 ff ff       	call   f0100ddd <pgdir_walk>
f010197b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010197e:	8d 57 04             	lea    0x4(%edi),%edx
f0101981:	83 c4 10             	add    $0x10,%esp
f0101984:	39 d0                	cmp    %edx,%eax
f0101986:	74 19                	je     f01019a1 <mem_init+0x9ae>
f0101988:	68 10 4f 10 f0       	push   $0xf0104f10
f010198d:	68 17 54 10 f0       	push   $0xf0105417
f0101992:	68 67 03 00 00       	push   $0x367
f0101997:	68 f1 53 10 f0       	push   $0xf01053f1
f010199c:	e8 ff e6 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019a1:	6a 06                	push   $0x6
f01019a3:	68 00 10 00 00       	push   $0x1000
f01019a8:	53                   	push   %ebx
f01019a9:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01019af:	e8 d9 f5 ff ff       	call   f0100f8d <page_insert>
f01019b4:	83 c4 10             	add    $0x10,%esp
f01019b7:	85 c0                	test   %eax,%eax
f01019b9:	74 19                	je     f01019d4 <mem_init+0x9e1>
f01019bb:	68 50 4f 10 f0       	push   $0xf0104f50
f01019c0:	68 17 54 10 f0       	push   $0xf0105417
f01019c5:	68 6a 03 00 00       	push   $0x36a
f01019ca:	68 f1 53 10 f0       	push   $0xf01053f1
f01019cf:	e8 cc e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019d4:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f01019da:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019df:	89 f8                	mov    %edi,%eax
f01019e1:	e8 5d ef ff ff       	call   f0100943 <check_va2pa>
f01019e6:	89 da                	mov    %ebx,%edx
f01019e8:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f01019ee:	c1 fa 03             	sar    $0x3,%edx
f01019f1:	c1 e2 0c             	shl    $0xc,%edx
f01019f4:	39 d0                	cmp    %edx,%eax
f01019f6:	74 19                	je     f0101a11 <mem_init+0xa1e>
f01019f8:	68 e0 4e 10 f0       	push   $0xf0104ee0
f01019fd:	68 17 54 10 f0       	push   $0xf0105417
f0101a02:	68 6b 03 00 00       	push   $0x36b
f0101a07:	68 f1 53 10 f0       	push   $0xf01053f1
f0101a0c:	e8 8f e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a11:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a16:	74 19                	je     f0101a31 <mem_init+0xa3e>
f0101a18:	68 f4 55 10 f0       	push   $0xf01055f4
f0101a1d:	68 17 54 10 f0       	push   $0xf0105417
f0101a22:	68 6c 03 00 00       	push   $0x36c
f0101a27:	68 f1 53 10 f0       	push   $0xf01053f1
f0101a2c:	e8 6f e6 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a31:	83 ec 04             	sub    $0x4,%esp
f0101a34:	6a 00                	push   $0x0
f0101a36:	68 00 10 00 00       	push   $0x1000
f0101a3b:	57                   	push   %edi
f0101a3c:	e8 9c f3 ff ff       	call   f0100ddd <pgdir_walk>
f0101a41:	83 c4 10             	add    $0x10,%esp
f0101a44:	f6 00 04             	testb  $0x4,(%eax)
f0101a47:	75 19                	jne    f0101a62 <mem_init+0xa6f>
f0101a49:	68 90 4f 10 f0       	push   $0xf0104f90
f0101a4e:	68 17 54 10 f0       	push   $0xf0105417
f0101a53:	68 6d 03 00 00       	push   $0x36d
f0101a58:	68 f1 53 10 f0       	push   $0xf01053f1
f0101a5d:	e8 3e e6 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a62:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f0101a67:	f6 00 04             	testb  $0x4,(%eax)
f0101a6a:	75 19                	jne    f0101a85 <mem_init+0xa92>
f0101a6c:	68 05 56 10 f0       	push   $0xf0105605
f0101a71:	68 17 54 10 f0       	push   $0xf0105417
f0101a76:	68 6e 03 00 00       	push   $0x36e
f0101a7b:	68 f1 53 10 f0       	push   $0xf01053f1
f0101a80:	e8 1b e6 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a85:	6a 02                	push   $0x2
f0101a87:	68 00 10 00 00       	push   $0x1000
f0101a8c:	53                   	push   %ebx
f0101a8d:	50                   	push   %eax
f0101a8e:	e8 fa f4 ff ff       	call   f0100f8d <page_insert>
f0101a93:	83 c4 10             	add    $0x10,%esp
f0101a96:	85 c0                	test   %eax,%eax
f0101a98:	74 19                	je     f0101ab3 <mem_init+0xac0>
f0101a9a:	68 a4 4e 10 f0       	push   $0xf0104ea4
f0101a9f:	68 17 54 10 f0       	push   $0xf0105417
f0101aa4:	68 71 03 00 00       	push   $0x371
f0101aa9:	68 f1 53 10 f0       	push   $0xf01053f1
f0101aae:	e8 ed e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ab3:	83 ec 04             	sub    $0x4,%esp
f0101ab6:	6a 00                	push   $0x0
f0101ab8:	68 00 10 00 00       	push   $0x1000
f0101abd:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101ac3:	e8 15 f3 ff ff       	call   f0100ddd <pgdir_walk>
f0101ac8:	83 c4 10             	add    $0x10,%esp
f0101acb:	f6 00 02             	testb  $0x2,(%eax)
f0101ace:	75 19                	jne    f0101ae9 <mem_init+0xaf6>
f0101ad0:	68 c4 4f 10 f0       	push   $0xf0104fc4
f0101ad5:	68 17 54 10 f0       	push   $0xf0105417
f0101ada:	68 72 03 00 00       	push   $0x372
f0101adf:	68 f1 53 10 f0       	push   $0xf01053f1
f0101ae4:	e8 b7 e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ae9:	83 ec 04             	sub    $0x4,%esp
f0101aec:	6a 00                	push   $0x0
f0101aee:	68 00 10 00 00       	push   $0x1000
f0101af3:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101af9:	e8 df f2 ff ff       	call   f0100ddd <pgdir_walk>
f0101afe:	83 c4 10             	add    $0x10,%esp
f0101b01:	f6 00 04             	testb  $0x4,(%eax)
f0101b04:	74 19                	je     f0101b1f <mem_init+0xb2c>
f0101b06:	68 f8 4f 10 f0       	push   $0xf0104ff8
f0101b0b:	68 17 54 10 f0       	push   $0xf0105417
f0101b10:	68 73 03 00 00       	push   $0x373
f0101b15:	68 f1 53 10 f0       	push   $0xf01053f1
f0101b1a:	e8 81 e5 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b1f:	6a 02                	push   $0x2
f0101b21:	68 00 00 40 00       	push   $0x400000
f0101b26:	56                   	push   %esi
f0101b27:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101b2d:	e8 5b f4 ff ff       	call   f0100f8d <page_insert>
f0101b32:	83 c4 10             	add    $0x10,%esp
f0101b35:	85 c0                	test   %eax,%eax
f0101b37:	78 19                	js     f0101b52 <mem_init+0xb5f>
f0101b39:	68 30 50 10 f0       	push   $0xf0105030
f0101b3e:	68 17 54 10 f0       	push   $0xf0105417
f0101b43:	68 76 03 00 00       	push   $0x376
f0101b48:	68 f1 53 10 f0       	push   $0xf01053f1
f0101b4d:	e8 4e e5 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b52:	6a 02                	push   $0x2
f0101b54:	68 00 10 00 00       	push   $0x1000
f0101b59:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b5c:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101b62:	e8 26 f4 ff ff       	call   f0100f8d <page_insert>
f0101b67:	83 c4 10             	add    $0x10,%esp
f0101b6a:	85 c0                	test   %eax,%eax
f0101b6c:	74 19                	je     f0101b87 <mem_init+0xb94>
f0101b6e:	68 68 50 10 f0       	push   $0xf0105068
f0101b73:	68 17 54 10 f0       	push   $0xf0105417
f0101b78:	68 79 03 00 00       	push   $0x379
f0101b7d:	68 f1 53 10 f0       	push   $0xf01053f1
f0101b82:	e8 19 e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b87:	83 ec 04             	sub    $0x4,%esp
f0101b8a:	6a 00                	push   $0x0
f0101b8c:	68 00 10 00 00       	push   $0x1000
f0101b91:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101b97:	e8 41 f2 ff ff       	call   f0100ddd <pgdir_walk>
f0101b9c:	83 c4 10             	add    $0x10,%esp
f0101b9f:	f6 00 04             	testb  $0x4,(%eax)
f0101ba2:	74 19                	je     f0101bbd <mem_init+0xbca>
f0101ba4:	68 f8 4f 10 f0       	push   $0xf0104ff8
f0101ba9:	68 17 54 10 f0       	push   $0xf0105417
f0101bae:	68 7a 03 00 00       	push   $0x37a
f0101bb3:	68 f1 53 10 f0       	push   $0xf01053f1
f0101bb8:	e8 e3 e4 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bbd:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101bc3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc8:	89 f8                	mov    %edi,%eax
f0101bca:	e8 74 ed ff ff       	call   f0100943 <check_va2pa>
f0101bcf:	89 c1                	mov    %eax,%ecx
f0101bd1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bd7:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101bdd:	c1 f8 03             	sar    $0x3,%eax
f0101be0:	c1 e0 0c             	shl    $0xc,%eax
f0101be3:	39 c1                	cmp    %eax,%ecx
f0101be5:	74 19                	je     f0101c00 <mem_init+0xc0d>
f0101be7:	68 a4 50 10 f0       	push   $0xf01050a4
f0101bec:	68 17 54 10 f0       	push   $0xf0105417
f0101bf1:	68 7d 03 00 00       	push   $0x37d
f0101bf6:	68 f1 53 10 f0       	push   $0xf01053f1
f0101bfb:	e8 a0 e4 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c05:	89 f8                	mov    %edi,%eax
f0101c07:	e8 37 ed ff ff       	call   f0100943 <check_va2pa>
f0101c0c:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c0f:	74 19                	je     f0101c2a <mem_init+0xc37>
f0101c11:	68 d0 50 10 f0       	push   $0xf01050d0
f0101c16:	68 17 54 10 f0       	push   $0xf0105417
f0101c1b:	68 7e 03 00 00       	push   $0x37e
f0101c20:	68 f1 53 10 f0       	push   $0xf01053f1
f0101c25:	e8 76 e4 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c2d:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101c32:	74 19                	je     f0101c4d <mem_init+0xc5a>
f0101c34:	68 1b 56 10 f0       	push   $0xf010561b
f0101c39:	68 17 54 10 f0       	push   $0xf0105417
f0101c3e:	68 80 03 00 00       	push   $0x380
f0101c43:	68 f1 53 10 f0       	push   $0xf01053f1
f0101c48:	e8 53 e4 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101c4d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c52:	74 19                	je     f0101c6d <mem_init+0xc7a>
f0101c54:	68 2c 56 10 f0       	push   $0xf010562c
f0101c59:	68 17 54 10 f0       	push   $0xf0105417
f0101c5e:	68 81 03 00 00       	push   $0x381
f0101c63:	68 f1 53 10 f0       	push   $0xf01053f1
f0101c68:	e8 33 e4 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c6d:	83 ec 0c             	sub    $0xc,%esp
f0101c70:	6a 00                	push   $0x0
f0101c72:	e8 c6 f0 ff ff       	call   f0100d3d <page_alloc>
f0101c77:	83 c4 10             	add    $0x10,%esp
f0101c7a:	85 c0                	test   %eax,%eax
f0101c7c:	74 04                	je     f0101c82 <mem_init+0xc8f>
f0101c7e:	39 c3                	cmp    %eax,%ebx
f0101c80:	74 19                	je     f0101c9b <mem_init+0xca8>
f0101c82:	68 00 51 10 f0       	push   $0xf0105100
f0101c87:	68 17 54 10 f0       	push   $0xf0105417
f0101c8c:	68 84 03 00 00       	push   $0x384
f0101c91:	68 f1 53 10 f0       	push   $0xf01053f1
f0101c96:	e8 05 e4 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c9b:	83 ec 08             	sub    $0x8,%esp
f0101c9e:	6a 00                	push   $0x0
f0101ca0:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101ca6:	e8 a2 f2 ff ff       	call   f0100f4d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cab:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101cb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb6:	89 f8                	mov    %edi,%eax
f0101cb8:	e8 86 ec ff ff       	call   f0100943 <check_va2pa>
f0101cbd:	83 c4 10             	add    $0x10,%esp
f0101cc0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cc3:	74 19                	je     f0101cde <mem_init+0xceb>
f0101cc5:	68 24 51 10 f0       	push   $0xf0105124
f0101cca:	68 17 54 10 f0       	push   $0xf0105417
f0101ccf:	68 88 03 00 00       	push   $0x388
f0101cd4:	68 f1 53 10 f0       	push   $0xf01053f1
f0101cd9:	e8 c2 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cde:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce3:	89 f8                	mov    %edi,%eax
f0101ce5:	e8 59 ec ff ff       	call   f0100943 <check_va2pa>
f0101cea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ced:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f0101cf3:	c1 fa 03             	sar    $0x3,%edx
f0101cf6:	c1 e2 0c             	shl    $0xc,%edx
f0101cf9:	39 d0                	cmp    %edx,%eax
f0101cfb:	74 19                	je     f0101d16 <mem_init+0xd23>
f0101cfd:	68 d0 50 10 f0       	push   $0xf01050d0
f0101d02:	68 17 54 10 f0       	push   $0xf0105417
f0101d07:	68 89 03 00 00       	push   $0x389
f0101d0c:	68 f1 53 10 f0       	push   $0xf01053f1
f0101d11:	e8 8a e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101d16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d19:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d1e:	74 19                	je     f0101d39 <mem_init+0xd46>
f0101d20:	68 d2 55 10 f0       	push   $0xf01055d2
f0101d25:	68 17 54 10 f0       	push   $0xf0105417
f0101d2a:	68 8a 03 00 00       	push   $0x38a
f0101d2f:	68 f1 53 10 f0       	push   $0xf01053f1
f0101d34:	e8 67 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101d39:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d3e:	74 19                	je     f0101d59 <mem_init+0xd66>
f0101d40:	68 2c 56 10 f0       	push   $0xf010562c
f0101d45:	68 17 54 10 f0       	push   $0xf0105417
f0101d4a:	68 8b 03 00 00       	push   $0x38b
f0101d4f:	68 f1 53 10 f0       	push   $0xf01053f1
f0101d54:	e8 47 e3 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d59:	6a 00                	push   $0x0
f0101d5b:	68 00 10 00 00       	push   $0x1000
f0101d60:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d63:	57                   	push   %edi
f0101d64:	e8 24 f2 ff ff       	call   f0100f8d <page_insert>
f0101d69:	83 c4 10             	add    $0x10,%esp
f0101d6c:	85 c0                	test   %eax,%eax
f0101d6e:	74 19                	je     f0101d89 <mem_init+0xd96>
f0101d70:	68 48 51 10 f0       	push   $0xf0105148
f0101d75:	68 17 54 10 f0       	push   $0xf0105417
f0101d7a:	68 8e 03 00 00       	push   $0x38e
f0101d7f:	68 f1 53 10 f0       	push   $0xf01053f1
f0101d84:	e8 17 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101d89:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d8c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d91:	75 19                	jne    f0101dac <mem_init+0xdb9>
f0101d93:	68 3d 56 10 f0       	push   $0xf010563d
f0101d98:	68 17 54 10 f0       	push   $0xf0105417
f0101d9d:	68 8f 03 00 00       	push   $0x38f
f0101da2:	68 f1 53 10 f0       	push   $0xf01053f1
f0101da7:	e8 f4 e2 ff ff       	call   f01000a0 <_panic>
	//assert(pp1->pp_link == NULL);

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101dac:	83 ec 08             	sub    $0x8,%esp
f0101daf:	68 00 10 00 00       	push   $0x1000
f0101db4:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101dba:	e8 8e f1 ff ff       	call   f0100f4d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dbf:	8b 3d 48 4c 17 f0    	mov    0xf0174c48,%edi
f0101dc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dca:	89 f8                	mov    %edi,%eax
f0101dcc:	e8 72 eb ff ff       	call   f0100943 <check_va2pa>
f0101dd1:	83 c4 10             	add    $0x10,%esp
f0101dd4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dd7:	74 19                	je     f0101df2 <mem_init+0xdff>
f0101dd9:	68 24 51 10 f0       	push   $0xf0105124
f0101dde:	68 17 54 10 f0       	push   $0xf0105417
f0101de3:	68 94 03 00 00       	push   $0x394
f0101de8:	68 f1 53 10 f0       	push   $0xf01053f1
f0101ded:	e8 ae e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101df2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df7:	89 f8                	mov    %edi,%eax
f0101df9:	e8 45 eb ff ff       	call   f0100943 <check_va2pa>
f0101dfe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e01:	74 19                	je     f0101e1c <mem_init+0xe29>
f0101e03:	68 80 51 10 f0       	push   $0xf0105180
f0101e08:	68 17 54 10 f0       	push   $0xf0105417
f0101e0d:	68 95 03 00 00       	push   $0x395
f0101e12:	68 f1 53 10 f0       	push   $0xf01053f1
f0101e17:	e8 84 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101e1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e24:	74 19                	je     f0101e3f <mem_init+0xe4c>
f0101e26:	68 49 56 10 f0       	push   $0xf0105649
f0101e2b:	68 17 54 10 f0       	push   $0xf0105417
f0101e30:	68 96 03 00 00       	push   $0x396
f0101e35:	68 f1 53 10 f0       	push   $0xf01053f1
f0101e3a:	e8 61 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e3f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e44:	74 19                	je     f0101e5f <mem_init+0xe6c>
f0101e46:	68 2c 56 10 f0       	push   $0xf010562c
f0101e4b:	68 17 54 10 f0       	push   $0xf0105417
f0101e50:	68 97 03 00 00       	push   $0x397
f0101e55:	68 f1 53 10 f0       	push   $0xf01053f1
f0101e5a:	e8 41 e2 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e5f:	83 ec 0c             	sub    $0xc,%esp
f0101e62:	6a 00                	push   $0x0
f0101e64:	e8 d4 ee ff ff       	call   f0100d3d <page_alloc>
f0101e69:	83 c4 10             	add    $0x10,%esp
f0101e6c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101e6f:	75 04                	jne    f0101e75 <mem_init+0xe82>
f0101e71:	85 c0                	test   %eax,%eax
f0101e73:	75 19                	jne    f0101e8e <mem_init+0xe9b>
f0101e75:	68 a8 51 10 f0       	push   $0xf01051a8
f0101e7a:	68 17 54 10 f0       	push   $0xf0105417
f0101e7f:	68 9a 03 00 00       	push   $0x39a
f0101e84:	68 f1 53 10 f0       	push   $0xf01053f1
f0101e89:	e8 12 e2 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e8e:	83 ec 0c             	sub    $0xc,%esp
f0101e91:	6a 00                	push   $0x0
f0101e93:	e8 a5 ee ff ff       	call   f0100d3d <page_alloc>
f0101e98:	83 c4 10             	add    $0x10,%esp
f0101e9b:	85 c0                	test   %eax,%eax
f0101e9d:	74 19                	je     f0101eb8 <mem_init+0xec5>
f0101e9f:	68 80 55 10 f0       	push   $0xf0105580
f0101ea4:	68 17 54 10 f0       	push   $0xf0105417
f0101ea9:	68 9d 03 00 00       	push   $0x39d
f0101eae:	68 f1 53 10 f0       	push   $0xf01053f1
f0101eb3:	e8 e8 e1 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101eb8:	8b 0d 48 4c 17 f0    	mov    0xf0174c48,%ecx
f0101ebe:	8b 11                	mov    (%ecx),%edx
f0101ec0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ec6:	89 f0                	mov    %esi,%eax
f0101ec8:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101ece:	c1 f8 03             	sar    $0x3,%eax
f0101ed1:	c1 e0 0c             	shl    $0xc,%eax
f0101ed4:	39 c2                	cmp    %eax,%edx
f0101ed6:	74 19                	je     f0101ef1 <mem_init+0xefe>
f0101ed8:	68 4c 4e 10 f0       	push   $0xf0104e4c
f0101edd:	68 17 54 10 f0       	push   $0xf0105417
f0101ee2:	68 a0 03 00 00       	push   $0x3a0
f0101ee7:	68 f1 53 10 f0       	push   $0xf01053f1
f0101eec:	e8 af e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101ef1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ef7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101efc:	74 19                	je     f0101f17 <mem_init+0xf24>
f0101efe:	68 e3 55 10 f0       	push   $0xf01055e3
f0101f03:	68 17 54 10 f0       	push   $0xf0105417
f0101f08:	68 a2 03 00 00       	push   $0x3a2
f0101f0d:	68 f1 53 10 f0       	push   $0xf01053f1
f0101f12:	e8 89 e1 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0101f17:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f1d:	83 ec 0c             	sub    $0xc,%esp
f0101f20:	56                   	push   %esi
f0101f21:	e8 81 ee ff ff       	call   f0100da7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f26:	83 c4 0c             	add    $0xc,%esp
f0101f29:	6a 01                	push   $0x1
f0101f2b:	68 00 10 40 00       	push   $0x401000
f0101f30:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101f36:	e8 a2 ee ff ff       	call   f0100ddd <pgdir_walk>
f0101f3b:	89 c7                	mov    %eax,%edi
f0101f3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f40:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f0101f45:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f48:	8b 40 04             	mov    0x4(%eax),%eax
f0101f4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f50:	8b 0d 44 4c 17 f0    	mov    0xf0174c44,%ecx
f0101f56:	89 c2                	mov    %eax,%edx
f0101f58:	c1 ea 0c             	shr    $0xc,%edx
f0101f5b:	83 c4 10             	add    $0x10,%esp
f0101f5e:	39 ca                	cmp    %ecx,%edx
f0101f60:	72 15                	jb     f0101f77 <mem_init+0xf84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f62:	50                   	push   %eax
f0101f63:	68 e4 4b 10 f0       	push   $0xf0104be4
f0101f68:	68 a9 03 00 00       	push   $0x3a9
f0101f6d:	68 f1 53 10 f0       	push   $0xf01053f1
f0101f72:	e8 29 e1 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f77:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101f7c:	39 c7                	cmp    %eax,%edi
f0101f7e:	74 19                	je     f0101f99 <mem_init+0xfa6>
f0101f80:	68 5a 56 10 f0       	push   $0xf010565a
f0101f85:	68 17 54 10 f0       	push   $0xf0105417
f0101f8a:	68 aa 03 00 00       	push   $0x3aa
f0101f8f:	68 f1 53 10 f0       	push   $0xf01053f1
f0101f94:	e8 07 e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f99:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f9c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101fa3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fa9:	89 f0                	mov    %esi,%eax
f0101fab:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0101fb1:	c1 f8 03             	sar    $0x3,%eax
f0101fb4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fb7:	89 c2                	mov    %eax,%edx
f0101fb9:	c1 ea 0c             	shr    $0xc,%edx
f0101fbc:	39 d1                	cmp    %edx,%ecx
f0101fbe:	77 12                	ja     f0101fd2 <mem_init+0xfdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fc0:	50                   	push   %eax
f0101fc1:	68 e4 4b 10 f0       	push   $0xf0104be4
f0101fc6:	6a 56                	push   $0x56
f0101fc8:	68 fd 53 10 f0       	push   $0xf01053fd
f0101fcd:	e8 ce e0 ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fd2:	83 ec 04             	sub    $0x4,%esp
f0101fd5:	68 00 10 00 00       	push   $0x1000
f0101fda:	68 ff 00 00 00       	push   $0xff
f0101fdf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fe4:	50                   	push   %eax
f0101fe5:	e8 6d 22 00 00       	call   f0104257 <memset>
	page_free(pp0);
f0101fea:	89 34 24             	mov    %esi,(%esp)
f0101fed:	e8 b5 ed ff ff       	call   f0100da7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ff2:	83 c4 0c             	add    $0xc,%esp
f0101ff5:	6a 01                	push   $0x1
f0101ff7:	6a 00                	push   $0x0
f0101ff9:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f0101fff:	e8 d9 ed ff ff       	call   f0100ddd <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102004:	89 f2                	mov    %esi,%edx
f0102006:	2b 15 4c 4c 17 f0    	sub    0xf0174c4c,%edx
f010200c:	c1 fa 03             	sar    $0x3,%edx
f010200f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102012:	89 d0                	mov    %edx,%eax
f0102014:	c1 e8 0c             	shr    $0xc,%eax
f0102017:	83 c4 10             	add    $0x10,%esp
f010201a:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0102020:	72 12                	jb     f0102034 <mem_init+0x1041>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102022:	52                   	push   %edx
f0102023:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102028:	6a 56                	push   $0x56
f010202a:	68 fd 53 10 f0       	push   $0xf01053fd
f010202f:	e8 6c e0 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102034:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010203a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010203d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102043:	f6 00 01             	testb  $0x1,(%eax)
f0102046:	74 19                	je     f0102061 <mem_init+0x106e>
f0102048:	68 72 56 10 f0       	push   $0xf0105672
f010204d:	68 17 54 10 f0       	push   $0xf0105417
f0102052:	68 b4 03 00 00       	push   $0x3b4
f0102057:	68 f1 53 10 f0       	push   $0xf01053f1
f010205c:	e8 3f e0 ff ff       	call   f01000a0 <_panic>
f0102061:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102064:	39 c2                	cmp    %eax,%edx
f0102066:	75 db                	jne    f0102043 <mem_init+0x1050>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102068:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010206d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102073:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102079:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010207c:	a3 80 3f 17 f0       	mov    %eax,0xf0173f80

	// free the pages we took
	page_free(pp0);
f0102081:	83 ec 0c             	sub    $0xc,%esp
f0102084:	56                   	push   %esi
f0102085:	e8 1d ed ff ff       	call   f0100da7 <page_free>
	page_free(pp1);
f010208a:	83 c4 04             	add    $0x4,%esp
f010208d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102090:	e8 12 ed ff ff       	call   f0100da7 <page_free>
	page_free(pp2);
f0102095:	89 1c 24             	mov    %ebx,(%esp)
f0102098:	e8 0a ed ff ff       	call   f0100da7 <page_free>

	cprintf("check_page() succeeded!\n");
f010209d:	c7 04 24 89 56 10 f0 	movl   $0xf0105689,(%esp)
f01020a4:	e8 51 0e 00 00       	call   f0102efa <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f01020a9:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020ae:	83 c4 10             	add    $0x10,%esp
f01020b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020b6:	77 15                	ja     f01020cd <mem_init+0x10da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020b8:	50                   	push   %eax
f01020b9:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01020be:	68 b9 00 00 00       	push   $0xb9
f01020c3:	68 f1 53 10 f0       	push   $0xf01053f1
f01020c8:	e8 d3 df ff ff       	call   f01000a0 <_panic>
f01020cd:	83 ec 08             	sub    $0x8,%esp
f01020d0:	6a 04                	push   $0x4
f01020d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01020d7:	50                   	push   %eax
f01020d8:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020dd:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020e2:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f01020e7:	e8 84 ed ff ff       	call   f0100e70 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	//并为其分配相应的映射，其权限为PTE_U | PTE_P
	boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U | PTE_P);
f01020ec:	a1 8c 3f 17 f0       	mov    0xf0173f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020f1:	83 c4 10             	add    $0x10,%esp
f01020f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020f9:	77 15                	ja     f0102110 <mem_init+0x111d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020fb:	50                   	push   %eax
f01020fc:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102101:	68 c3 00 00 00       	push   $0xc3
f0102106:	68 f1 53 10 f0       	push   $0xf01053f1
f010210b:	e8 90 df ff ff       	call   f01000a0 <_panic>
f0102110:	83 ec 08             	sub    $0x8,%esp
f0102113:	6a 05                	push   $0x5
f0102115:	05 00 00 00 10       	add    $0x10000000,%eax
f010211a:	50                   	push   %eax
f010211b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102120:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102125:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010212a:	e8 41 ed ff ff       	call   f0100e70 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010212f:	83 c4 10             	add    $0x10,%esp
f0102132:	b8 00 00 11 f0       	mov    $0xf0110000,%eax
f0102137:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010213c:	77 15                	ja     f0102153 <mem_init+0x1160>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010213e:	50                   	push   %eax
f010213f:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102144:	68 d1 00 00 00       	push   $0xd1
f0102149:	68 f1 53 10 f0       	push   $0xf01053f1
f010214e:	e8 4d df ff ff       	call   f01000a0 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0102153:	83 ec 08             	sub    $0x8,%esp
f0102156:	6a 02                	push   $0x2
f0102158:	68 00 00 11 00       	push   $0x110000
f010215d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102162:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102167:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f010216c:	e8 ff ec ff ff       	call   f0100e70 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KERNBASE,-KERNBASE,0,PTE_W);
f0102171:	83 c4 08             	add    $0x8,%esp
f0102174:	6a 02                	push   $0x2
f0102176:	6a 00                	push   $0x0
f0102178:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010217d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102182:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
f0102187:	e8 e4 ec ff ff       	call   f0100e70 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010218c:	8b 1d 48 4c 17 f0    	mov    0xf0174c48,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102192:	a1 44 4c 17 f0       	mov    0xf0174c44,%eax
f0102197:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010219a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021a9:	8b 3d 4c 4c 17 f0    	mov    0xf0174c4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021af:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021b2:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021b5:	be 00 00 00 00       	mov    $0x0,%esi
f01021ba:	eb 55                	jmp    f0102211 <mem_init+0x121e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021bc:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01021c2:	89 d8                	mov    %ebx,%eax
f01021c4:	e8 7a e7 ff ff       	call   f0100943 <check_va2pa>
f01021c9:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021d0:	77 15                	ja     f01021e7 <mem_init+0x11f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021d2:	57                   	push   %edi
f01021d3:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01021d8:	68 f1 02 00 00       	push   $0x2f1
f01021dd:	68 f1 53 10 f0       	push   $0xf01053f1
f01021e2:	e8 b9 de ff ff       	call   f01000a0 <_panic>
f01021e7:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01021ee:	39 d0                	cmp    %edx,%eax
f01021f0:	74 19                	je     f010220b <mem_init+0x1218>
f01021f2:	68 cc 51 10 f0       	push   $0xf01051cc
f01021f7:	68 17 54 10 f0       	push   $0xf0105417
f01021fc:	68 f1 02 00 00       	push   $0x2f1
f0102201:	68 f1 53 10 f0       	push   $0xf01053f1
f0102206:	e8 95 de ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010220b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102211:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102214:	77 a6                	ja     f01021bc <mem_init+0x11c9>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102216:	8b 3d 8c 3f 17 f0    	mov    0xf0173f8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010221c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010221f:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102224:	89 f2                	mov    %esi,%edx
f0102226:	89 d8                	mov    %ebx,%eax
f0102228:	e8 16 e7 ff ff       	call   f0100943 <check_va2pa>
f010222d:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102234:	77 15                	ja     f010224b <mem_init+0x1258>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102236:	57                   	push   %edi
f0102237:	68 cc 4c 10 f0       	push   $0xf0104ccc
f010223c:	68 f6 02 00 00       	push   $0x2f6
f0102241:	68 f1 53 10 f0       	push   $0xf01053f1
f0102246:	e8 55 de ff ff       	call   f01000a0 <_panic>
f010224b:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102252:	39 c2                	cmp    %eax,%edx
f0102254:	74 19                	je     f010226f <mem_init+0x127c>
f0102256:	68 00 52 10 f0       	push   $0xf0105200
f010225b:	68 17 54 10 f0       	push   $0xf0105417
f0102260:	68 f6 02 00 00       	push   $0x2f6
f0102265:	68 f1 53 10 f0       	push   $0xf01053f1
f010226a:	e8 31 de ff ff       	call   f01000a0 <_panic>
f010226f:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102275:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010227b:	75 a7                	jne    f0102224 <mem_init+0x1231>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010227d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102280:	c1 e7 0c             	shl    $0xc,%edi
f0102283:	be 00 00 00 00       	mov    $0x0,%esi
f0102288:	eb 30                	jmp    f01022ba <mem_init+0x12c7>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010228a:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102290:	89 d8                	mov    %ebx,%eax
f0102292:	e8 ac e6 ff ff       	call   f0100943 <check_va2pa>
f0102297:	39 c6                	cmp    %eax,%esi
f0102299:	74 19                	je     f01022b4 <mem_init+0x12c1>
f010229b:	68 34 52 10 f0       	push   $0xf0105234
f01022a0:	68 17 54 10 f0       	push   $0xf0105417
f01022a5:	68 fa 02 00 00       	push   $0x2fa
f01022aa:	68 f1 53 10 f0       	push   $0xf01053f1
f01022af:	e8 ec dd ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01022ba:	39 fe                	cmp    %edi,%esi
f01022bc:	72 cc                	jb     f010228a <mem_init+0x1297>
f01022be:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01022c3:	89 f2                	mov    %esi,%edx
f01022c5:	89 d8                	mov    %ebx,%eax
f01022c7:	e8 77 e6 ff ff       	call   f0100943 <check_va2pa>
f01022cc:	8d 96 00 80 11 10    	lea    0x10118000(%esi),%edx
f01022d2:	39 c2                	cmp    %eax,%edx
f01022d4:	74 19                	je     f01022ef <mem_init+0x12fc>
f01022d6:	68 5c 52 10 f0       	push   $0xf010525c
f01022db:	68 17 54 10 f0       	push   $0xf0105417
f01022e0:	68 fe 02 00 00       	push   $0x2fe
f01022e5:	68 f1 53 10 f0       	push   $0xf01053f1
f01022ea:	e8 b1 dd ff ff       	call   f01000a0 <_panic>
f01022ef:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01022f5:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01022fb:	75 c6                	jne    f01022c3 <mem_init+0x12d0>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022fd:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102302:	89 d8                	mov    %ebx,%eax
f0102304:	e8 3a e6 ff ff       	call   f0100943 <check_va2pa>
f0102309:	83 f8 ff             	cmp    $0xffffffff,%eax
f010230c:	74 51                	je     f010235f <mem_init+0x136c>
f010230e:	68 a4 52 10 f0       	push   $0xf01052a4
f0102313:	68 17 54 10 f0       	push   $0xf0105417
f0102318:	68 ff 02 00 00       	push   $0x2ff
f010231d:	68 f1 53 10 f0       	push   $0xf01053f1
f0102322:	e8 79 dd ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102327:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010232c:	72 36                	jb     f0102364 <mem_init+0x1371>
f010232e:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102333:	76 07                	jbe    f010233c <mem_init+0x1349>
f0102335:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010233a:	75 28                	jne    f0102364 <mem_init+0x1371>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010233c:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102340:	0f 85 83 00 00 00    	jne    f01023c9 <mem_init+0x13d6>
f0102346:	68 a2 56 10 f0       	push   $0xf01056a2
f010234b:	68 17 54 10 f0       	push   $0xf0105417
f0102350:	68 08 03 00 00       	push   $0x308
f0102355:	68 f1 53 10 f0       	push   $0xf01053f1
f010235a:	e8 41 dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010235f:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102364:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102369:	76 3f                	jbe    f01023aa <mem_init+0x13b7>
				assert(pgdir[i] & PTE_P);
f010236b:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010236e:	f6 c2 01             	test   $0x1,%dl
f0102371:	75 19                	jne    f010238c <mem_init+0x1399>
f0102373:	68 a2 56 10 f0       	push   $0xf01056a2
f0102378:	68 17 54 10 f0       	push   $0xf0105417
f010237d:	68 0c 03 00 00       	push   $0x30c
f0102382:	68 f1 53 10 f0       	push   $0xf01053f1
f0102387:	e8 14 dd ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f010238c:	f6 c2 02             	test   $0x2,%dl
f010238f:	75 38                	jne    f01023c9 <mem_init+0x13d6>
f0102391:	68 b3 56 10 f0       	push   $0xf01056b3
f0102396:	68 17 54 10 f0       	push   $0xf0105417
f010239b:	68 0d 03 00 00       	push   $0x30d
f01023a0:	68 f1 53 10 f0       	push   $0xf01053f1
f01023a5:	e8 f6 dc ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f01023aa:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01023ae:	74 19                	je     f01023c9 <mem_init+0x13d6>
f01023b0:	68 c4 56 10 f0       	push   $0xf01056c4
f01023b5:	68 17 54 10 f0       	push   $0xf0105417
f01023ba:	68 0f 03 00 00       	push   $0x30f
f01023bf:	68 f1 53 10 f0       	push   $0xf01053f1
f01023c4:	e8 d7 dc ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01023c9:	83 c0 01             	add    $0x1,%eax
f01023cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01023d1:	0f 86 50 ff ff ff    	jbe    f0102327 <mem_init+0x1334>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01023d7:	83 ec 0c             	sub    $0xc,%esp
f01023da:	68 d4 52 10 f0       	push   $0xf01052d4
f01023df:	e8 16 0b 00 00       	call   f0102efa <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01023e4:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023e9:	83 c4 10             	add    $0x10,%esp
f01023ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023f1:	77 15                	ja     f0102408 <mem_init+0x1415>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023f3:	50                   	push   %eax
f01023f4:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01023f9:	68 e5 00 00 00       	push   $0xe5
f01023fe:	68 f1 53 10 f0       	push   $0xf01053f1
f0102403:	e8 98 dc ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102408:	05 00 00 00 10       	add    $0x10000000,%eax
f010240d:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102410:	b8 00 00 00 00       	mov    $0x0,%eax
f0102415:	e8 8d e5 ff ff       	call   f01009a7 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010241a:	0f 20 c0             	mov    %cr0,%eax
f010241d:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102420:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102425:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102428:	83 ec 0c             	sub    $0xc,%esp
f010242b:	6a 00                	push   $0x0
f010242d:	e8 0b e9 ff ff       	call   f0100d3d <page_alloc>
f0102432:	89 c3                	mov    %eax,%ebx
f0102434:	83 c4 10             	add    $0x10,%esp
f0102437:	85 c0                	test   %eax,%eax
f0102439:	75 19                	jne    f0102454 <mem_init+0x1461>
f010243b:	68 d5 54 10 f0       	push   $0xf01054d5
f0102440:	68 17 54 10 f0       	push   $0xf0105417
f0102445:	68 cf 03 00 00       	push   $0x3cf
f010244a:	68 f1 53 10 f0       	push   $0xf01053f1
f010244f:	e8 4c dc ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0102454:	83 ec 0c             	sub    $0xc,%esp
f0102457:	6a 00                	push   $0x0
f0102459:	e8 df e8 ff ff       	call   f0100d3d <page_alloc>
f010245e:	89 c7                	mov    %eax,%edi
f0102460:	83 c4 10             	add    $0x10,%esp
f0102463:	85 c0                	test   %eax,%eax
f0102465:	75 19                	jne    f0102480 <mem_init+0x148d>
f0102467:	68 eb 54 10 f0       	push   $0xf01054eb
f010246c:	68 17 54 10 f0       	push   $0xf0105417
f0102471:	68 d0 03 00 00       	push   $0x3d0
f0102476:	68 f1 53 10 f0       	push   $0xf01053f1
f010247b:	e8 20 dc ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102480:	83 ec 0c             	sub    $0xc,%esp
f0102483:	6a 00                	push   $0x0
f0102485:	e8 b3 e8 ff ff       	call   f0100d3d <page_alloc>
f010248a:	89 c6                	mov    %eax,%esi
f010248c:	83 c4 10             	add    $0x10,%esp
f010248f:	85 c0                	test   %eax,%eax
f0102491:	75 19                	jne    f01024ac <mem_init+0x14b9>
f0102493:	68 01 55 10 f0       	push   $0xf0105501
f0102498:	68 17 54 10 f0       	push   $0xf0105417
f010249d:	68 d1 03 00 00       	push   $0x3d1
f01024a2:	68 f1 53 10 f0       	push   $0xf01053f1
f01024a7:	e8 f4 db ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f01024ac:	83 ec 0c             	sub    $0xc,%esp
f01024af:	53                   	push   %ebx
f01024b0:	e8 f2 e8 ff ff       	call   f0100da7 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024b5:	89 f8                	mov    %edi,%eax
f01024b7:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01024bd:	c1 f8 03             	sar    $0x3,%eax
f01024c0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024c3:	89 c2                	mov    %eax,%edx
f01024c5:	c1 ea 0c             	shr    $0xc,%edx
f01024c8:	83 c4 10             	add    $0x10,%esp
f01024cb:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f01024d1:	72 12                	jb     f01024e5 <mem_init+0x14f2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024d3:	50                   	push   %eax
f01024d4:	68 e4 4b 10 f0       	push   $0xf0104be4
f01024d9:	6a 56                	push   $0x56
f01024db:	68 fd 53 10 f0       	push   $0xf01053fd
f01024e0:	e8 bb db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01024e5:	83 ec 04             	sub    $0x4,%esp
f01024e8:	68 00 10 00 00       	push   $0x1000
f01024ed:	6a 01                	push   $0x1
f01024ef:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f4:	50                   	push   %eax
f01024f5:	e8 5d 1d 00 00       	call   f0104257 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024fa:	89 f0                	mov    %esi,%eax
f01024fc:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0102502:	c1 f8 03             	sar    $0x3,%eax
f0102505:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102508:	89 c2                	mov    %eax,%edx
f010250a:	c1 ea 0c             	shr    $0xc,%edx
f010250d:	83 c4 10             	add    $0x10,%esp
f0102510:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0102516:	72 12                	jb     f010252a <mem_init+0x1537>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102518:	50                   	push   %eax
f0102519:	68 e4 4b 10 f0       	push   $0xf0104be4
f010251e:	6a 56                	push   $0x56
f0102520:	68 fd 53 10 f0       	push   $0xf01053fd
f0102525:	e8 76 db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010252a:	83 ec 04             	sub    $0x4,%esp
f010252d:	68 00 10 00 00       	push   $0x1000
f0102532:	6a 02                	push   $0x2
f0102534:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102539:	50                   	push   %eax
f010253a:	e8 18 1d 00 00       	call   f0104257 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010253f:	6a 02                	push   $0x2
f0102541:	68 00 10 00 00       	push   $0x1000
f0102546:	57                   	push   %edi
f0102547:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f010254d:	e8 3b ea ff ff       	call   f0100f8d <page_insert>
	assert(pp1->pp_ref == 1);
f0102552:	83 c4 20             	add    $0x20,%esp
f0102555:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010255a:	74 19                	je     f0102575 <mem_init+0x1582>
f010255c:	68 d2 55 10 f0       	push   $0xf01055d2
f0102561:	68 17 54 10 f0       	push   $0xf0105417
f0102566:	68 d6 03 00 00       	push   $0x3d6
f010256b:	68 f1 53 10 f0       	push   $0xf01053f1
f0102570:	e8 2b db ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102575:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010257c:	01 01 01 
f010257f:	74 19                	je     f010259a <mem_init+0x15a7>
f0102581:	68 f4 52 10 f0       	push   $0xf01052f4
f0102586:	68 17 54 10 f0       	push   $0xf0105417
f010258b:	68 d7 03 00 00       	push   $0x3d7
f0102590:	68 f1 53 10 f0       	push   $0xf01053f1
f0102595:	e8 06 db ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010259a:	6a 02                	push   $0x2
f010259c:	68 00 10 00 00       	push   $0x1000
f01025a1:	56                   	push   %esi
f01025a2:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01025a8:	e8 e0 e9 ff ff       	call   f0100f8d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025ad:	83 c4 10             	add    $0x10,%esp
f01025b0:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025b7:	02 02 02 
f01025ba:	74 19                	je     f01025d5 <mem_init+0x15e2>
f01025bc:	68 18 53 10 f0       	push   $0xf0105318
f01025c1:	68 17 54 10 f0       	push   $0xf0105417
f01025c6:	68 d9 03 00 00       	push   $0x3d9
f01025cb:	68 f1 53 10 f0       	push   $0xf01053f1
f01025d0:	e8 cb da ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01025d5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025da:	74 19                	je     f01025f5 <mem_init+0x1602>
f01025dc:	68 f4 55 10 f0       	push   $0xf01055f4
f01025e1:	68 17 54 10 f0       	push   $0xf0105417
f01025e6:	68 da 03 00 00       	push   $0x3da
f01025eb:	68 f1 53 10 f0       	push   $0xf01053f1
f01025f0:	e8 ab da ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01025f5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01025fa:	74 19                	je     f0102615 <mem_init+0x1622>
f01025fc:	68 49 56 10 f0       	push   $0xf0105649
f0102601:	68 17 54 10 f0       	push   $0xf0105417
f0102606:	68 db 03 00 00       	push   $0x3db
f010260b:	68 f1 53 10 f0       	push   $0xf01053f1
f0102610:	e8 8b da ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102615:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010261c:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010261f:	89 f0                	mov    %esi,%eax
f0102621:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f0102627:	c1 f8 03             	sar    $0x3,%eax
f010262a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010262d:	89 c2                	mov    %eax,%edx
f010262f:	c1 ea 0c             	shr    $0xc,%edx
f0102632:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f0102638:	72 12                	jb     f010264c <mem_init+0x1659>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010263a:	50                   	push   %eax
f010263b:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102640:	6a 56                	push   $0x56
f0102642:	68 fd 53 10 f0       	push   $0xf01053fd
f0102647:	e8 54 da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010264c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102653:	03 03 03 
f0102656:	74 19                	je     f0102671 <mem_init+0x167e>
f0102658:	68 3c 53 10 f0       	push   $0xf010533c
f010265d:	68 17 54 10 f0       	push   $0xf0105417
f0102662:	68 dd 03 00 00       	push   $0x3dd
f0102667:	68 f1 53 10 f0       	push   $0xf01053f1
f010266c:	e8 2f da ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102671:	83 ec 08             	sub    $0x8,%esp
f0102674:	68 00 10 00 00       	push   $0x1000
f0102679:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f010267f:	e8 c9 e8 ff ff       	call   f0100f4d <page_remove>
	assert(pp2->pp_ref == 0);
f0102684:	83 c4 10             	add    $0x10,%esp
f0102687:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010268c:	74 19                	je     f01026a7 <mem_init+0x16b4>
f010268e:	68 2c 56 10 f0       	push   $0xf010562c
f0102693:	68 17 54 10 f0       	push   $0xf0105417
f0102698:	68 df 03 00 00       	push   $0x3df
f010269d:	68 f1 53 10 f0       	push   $0xf01053f1
f01026a2:	e8 f9 d9 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026a7:	8b 0d 48 4c 17 f0    	mov    0xf0174c48,%ecx
f01026ad:	8b 11                	mov    (%ecx),%edx
f01026af:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026b5:	89 d8                	mov    %ebx,%eax
f01026b7:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01026bd:	c1 f8 03             	sar    $0x3,%eax
f01026c0:	c1 e0 0c             	shl    $0xc,%eax
f01026c3:	39 c2                	cmp    %eax,%edx
f01026c5:	74 19                	je     f01026e0 <mem_init+0x16ed>
f01026c7:	68 4c 4e 10 f0       	push   $0xf0104e4c
f01026cc:	68 17 54 10 f0       	push   $0xf0105417
f01026d1:	68 e2 03 00 00       	push   $0x3e2
f01026d6:	68 f1 53 10 f0       	push   $0xf01053f1
f01026db:	e8 c0 d9 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01026e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026e6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01026eb:	74 19                	je     f0102706 <mem_init+0x1713>
f01026ed:	68 e3 55 10 f0       	push   $0xf01055e3
f01026f2:	68 17 54 10 f0       	push   $0xf0105417
f01026f7:	68 e4 03 00 00       	push   $0x3e4
f01026fc:	68 f1 53 10 f0       	push   $0xf01053f1
f0102701:	e8 9a d9 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102706:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010270c:	83 ec 0c             	sub    $0xc,%esp
f010270f:	53                   	push   %ebx
f0102710:	e8 92 e6 ff ff       	call   f0100da7 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102715:	c7 04 24 68 53 10 f0 	movl   $0xf0105368,(%esp)
f010271c:	e8 d9 07 00 00       	call   f0102efa <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102721:	83 c4 10             	add    $0x10,%esp
f0102724:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102727:	5b                   	pop    %ebx
f0102728:	5e                   	pop    %esi
f0102729:	5f                   	pop    %edi
f010272a:	5d                   	pop    %ebp
f010272b:	c3                   	ret    

f010272c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010272c:	55                   	push   %ebp
f010272d:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010272f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102732:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102735:	5d                   	pop    %ebp
f0102736:	c3                   	ret    

f0102737 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102737:	55                   	push   %ebp
f0102738:	89 e5                	mov    %esp,%ebp
f010273a:	57                   	push   %edi
f010273b:	56                   	push   %esi
f010273c:	53                   	push   %ebx
f010273d:	83 ec 18             	sub    $0x18,%esp
f0102740:	8b 45 10             	mov    0x10(%ebp),%eax
	// LAB 3: Your code here.
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE), end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102743:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102746:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010274c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010274f:	8d bc 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edi
f0102756:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	int check_perm = (perm | PTE_P);
f010275c:	8b 75 14             	mov    0x14(%ebp),%esi
f010275f:	83 ce 01             	or     $0x1,%esi
	uint32_t check_va = (uint32_t)va;

	cprintf("check va:%x, len:%x, begin:%x, end:%x\n", va, len, begin, end);
f0102762:	57                   	push   %edi
f0102763:	53                   	push   %ebx
f0102764:	50                   	push   %eax
f0102765:	51                   	push   %ecx
f0102766:	68 94 53 10 f0       	push   $0xf0105394
f010276b:	e8 8a 07 00 00       	call   f0102efa <cprintf>

	for (; begin < end; begin += PGSIZE) {
f0102770:	83 c4 20             	add    $0x20,%esp
f0102773:	eb 42                	jmp    f01027b7 <user_mem_check+0x80>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)begin, 0);
f0102775:	83 ec 04             	sub    $0x4,%esp
f0102778:	6a 00                	push   $0x0
f010277a:	53                   	push   %ebx
f010277b:	8b 45 08             	mov    0x8(%ebp),%eax
f010277e:	ff 70 5c             	pushl  0x5c(%eax)
f0102781:	e8 57 e6 ff ff       	call   f0100ddd <pgdir_walk>
		if ((begin >= ULIM) || !pte || (*pte & check_perm) != check_perm) {
f0102786:	83 c4 10             	add    $0x10,%esp
f0102789:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010278f:	77 0c                	ja     f010279d <user_mem_check+0x66>
f0102791:	85 c0                	test   %eax,%eax
f0102793:	74 08                	je     f010279d <user_mem_check+0x66>
f0102795:	89 f2                	mov    %esi,%edx
f0102797:	23 10                	and    (%eax),%edx
f0102799:	39 d6                	cmp    %edx,%esi
f010279b:	74 14                	je     f01027b1 <user_mem_check+0x7a>
			user_mem_check_addr = (begin >= check_va ? begin : check_va);
f010279d:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f01027a0:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f01027a4:	89 1d 7c 3f 17 f0    	mov    %ebx,0xf0173f7c
			return -E_FAULT;
f01027aa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01027af:	eb 0f                	jmp    f01027c0 <user_mem_check+0x89>
	int check_perm = (perm | PTE_P);
	uint32_t check_va = (uint32_t)va;

	cprintf("check va:%x, len:%x, begin:%x, end:%x\n", va, len, begin, end);

	for (; begin < end; begin += PGSIZE) {
f01027b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027b7:	39 fb                	cmp    %edi,%ebx
f01027b9:	72 ba                	jb     f0102775 <user_mem_check+0x3e>
			user_mem_check_addr = (begin >= check_va ? begin : check_va);
			return -E_FAULT;
		}
	}

	return 0;
f01027bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01027c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027c3:	5b                   	pop    %ebx
f01027c4:	5e                   	pop    %esi
f01027c5:	5f                   	pop    %edi
f01027c6:	5d                   	pop    %ebp
f01027c7:	c3                   	ret    

f01027c8 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01027c8:	55                   	push   %ebp
f01027c9:	89 e5                	mov    %esp,%ebp
f01027cb:	53                   	push   %ebx
f01027cc:	83 ec 04             	sub    $0x4,%esp
f01027cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01027d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01027d5:	83 c8 04             	or     $0x4,%eax
f01027d8:	50                   	push   %eax
f01027d9:	ff 75 10             	pushl  0x10(%ebp)
f01027dc:	ff 75 0c             	pushl  0xc(%ebp)
f01027df:	53                   	push   %ebx
f01027e0:	e8 52 ff ff ff       	call   f0102737 <user_mem_check>
f01027e5:	83 c4 10             	add    $0x10,%esp
f01027e8:	85 c0                	test   %eax,%eax
f01027ea:	79 21                	jns    f010280d <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01027ec:	83 ec 04             	sub    $0x4,%esp
f01027ef:	ff 35 7c 3f 17 f0    	pushl  0xf0173f7c
f01027f5:	ff 73 48             	pushl  0x48(%ebx)
f01027f8:	68 bc 53 10 f0       	push   $0xf01053bc
f01027fd:	e8 f8 06 00 00       	call   f0102efa <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102802:	89 1c 24             	mov    %ebx,(%esp)
f0102805:	e8 d7 05 00 00       	call   f0102de1 <env_destroy>
f010280a:	83 c4 10             	add    $0x10,%esp
	}
}
f010280d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102810:	c9                   	leave  
f0102811:	c3                   	ret    

f0102812 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102812:	55                   	push   %ebp
f0102813:	89 e5                	mov    %esp,%ebp
f0102815:	57                   	push   %edi
f0102816:	56                   	push   %esi
f0102817:	53                   	push   %ebx
f0102818:	83 ec 0c             	sub    $0xc,%esp
f010281b:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *Start = ROUNDDOWN(va,PGSIZE),*End = ROUNDUP(va+len,PGSIZE);
f010281d:	89 d3                	mov    %edx,%ebx
f010281f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102825:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010282c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(;Start<End;Start+=PGSIZE)
f0102832:	eb 3d                	jmp    f0102871 <region_alloc+0x5f>
	{
	        struct PageInfo *p = page_alloc(0);
f0102834:	83 ec 0c             	sub    $0xc,%esp
f0102837:	6a 00                	push   $0x0
f0102839:	e8 ff e4 ff ff       	call   f0100d3d <page_alloc>
	        if(!p)
f010283e:	83 c4 10             	add    $0x10,%esp
f0102841:	85 c0                	test   %eax,%eax
f0102843:	75 17                	jne    f010285c <region_alloc+0x4a>
		        panic("env region_blloc failed");
f0102845:	83 ec 04             	sub    $0x4,%esp
f0102848:	68 d2 56 10 f0       	push   $0xf01056d2
f010284d:	68 1e 01 00 00       	push   $0x11e
f0102852:	68 ea 56 10 f0       	push   $0xf01056ea
f0102857:	e8 44 d8 ff ff       	call   f01000a0 <_panic>
	        page_insert(e->env_pgdir,p,Start,PTE_W|PTE_U);
f010285c:	6a 06                	push   $0x6
f010285e:	53                   	push   %ebx
f010285f:	50                   	push   %eax
f0102860:	ff 77 5c             	pushl  0x5c(%edi)
f0102863:	e8 25 e7 ff ff       	call   f0100f8d <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *Start = ROUNDDOWN(va,PGSIZE),*End = ROUNDUP(va+len,PGSIZE);
	for(;Start<End;Start+=PGSIZE)
f0102868:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010286e:	83 c4 10             	add    $0x10,%esp
f0102871:	39 f3                	cmp    %esi,%ebx
f0102873:	72 bf                	jb     f0102834 <region_alloc+0x22>
	        struct PageInfo *p = page_alloc(0);
	        if(!p)
		        panic("env region_blloc failed");
	        page_insert(e->env_pgdir,p,Start,PTE_W|PTE_U);
        }
}
f0102875:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102878:	5b                   	pop    %ebx
f0102879:	5e                   	pop    %esi
f010287a:	5f                   	pop    %edi
f010287b:	5d                   	pop    %ebp
f010287c:	c3                   	ret    

f010287d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010287d:	55                   	push   %ebp
f010287e:	89 e5                	mov    %esp,%ebp
f0102880:	8b 55 08             	mov    0x8(%ebp),%edx
f0102883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102886:	85 d2                	test   %edx,%edx
f0102888:	75 11                	jne    f010289b <envid2env+0x1e>
		*env_store = curenv;
f010288a:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
f010288f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102892:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102894:	b8 00 00 00 00       	mov    $0x0,%eax
f0102899:	eb 5e                	jmp    f01028f9 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010289b:	89 d0                	mov    %edx,%eax
f010289d:	25 ff 03 00 00       	and    $0x3ff,%eax
f01028a2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01028a5:	c1 e0 05             	shl    $0x5,%eax
f01028a8:	03 05 8c 3f 17 f0    	add    0xf0173f8c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01028ae:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01028b2:	74 05                	je     f01028b9 <envid2env+0x3c>
f01028b4:	3b 50 48             	cmp    0x48(%eax),%edx
f01028b7:	74 10                	je     f01028c9 <envid2env+0x4c>
		*env_store = 0;
f01028b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01028c2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028c7:	eb 30                	jmp    f01028f9 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01028c9:	84 c9                	test   %cl,%cl
f01028cb:	74 22                	je     f01028ef <envid2env+0x72>
f01028cd:	8b 15 88 3f 17 f0    	mov    0xf0173f88,%edx
f01028d3:	39 d0                	cmp    %edx,%eax
f01028d5:	74 18                	je     f01028ef <envid2env+0x72>
f01028d7:	8b 4a 48             	mov    0x48(%edx),%ecx
f01028da:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f01028dd:	74 10                	je     f01028ef <envid2env+0x72>
		*env_store = 0;
f01028df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01028e8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028ed:	eb 0a                	jmp    f01028f9 <envid2env+0x7c>
	}

	*env_store = e;
f01028ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01028f2:	89 01                	mov    %eax,(%ecx)
	return 0;
f01028f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01028f9:	5d                   	pop    %ebp
f01028fa:	c3                   	ret    

f01028fb <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01028fb:	55                   	push   %ebp
f01028fc:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01028fe:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102903:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102906:	b8 23 00 00 00       	mov    $0x23,%eax
f010290b:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010290d:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010290f:	b8 10 00 00 00       	mov    $0x10,%eax
f0102914:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102916:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102918:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010291a:	ea 21 29 10 f0 08 00 	ljmp   $0x8,$0xf0102921
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102921:	b8 00 00 00 00       	mov    $0x0,%eax
f0102926:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102929:	5d                   	pop    %ebp
f010292a:	c3                   	ret    

f010292b <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010292b:	55                   	push   %ebp
f010292c:	89 e5                	mov    %esp,%ebp
f010292e:	56                   	push   %esi
f010292f:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i = NENV;
	while(i-->0)
	{
	        envs[i].env_id = 0;
f0102930:	8b 35 8c 3f 17 f0    	mov    0xf0173f8c,%esi
f0102936:	8b 15 90 3f 17 f0    	mov    0xf0173f90,%edx
f010293c:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102942:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102945:	89 c1                	mov    %eax,%ecx
f0102947:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
	        envs[i].env_status = ENV_FREE;
f010294e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	        envs[i].env_link = env_free_list;
f0102955:	89 50 44             	mov    %edx,0x44(%eax)
f0102958:	83 e8 60             	sub    $0x60,%eax
	        env_free_list = &envs[i];
f010295b:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i = NENV;
	while(i-->0)
f010295d:	39 d8                	cmp    %ebx,%eax
f010295f:	75 e4                	jne    f0102945 <env_init+0x1a>
f0102961:	89 35 90 3f 17 f0    	mov    %esi,0xf0173f90
	        envs[i].env_link = env_free_list;
	        env_free_list = &envs[i];
        }

	// Per-CPU part of the initialization
	env_init_percpu();
f0102967:	e8 8f ff ff ff       	call   f01028fb <env_init_percpu>
}
f010296c:	5b                   	pop    %ebx
f010296d:	5e                   	pop    %esi
f010296e:	5d                   	pop    %ebp
f010296f:	c3                   	ret    

f0102970 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102970:	55                   	push   %ebp
f0102971:	89 e5                	mov    %esp,%ebp
f0102973:	53                   	push   %ebx
f0102974:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102977:	8b 1d 90 3f 17 f0    	mov    0xf0173f90,%ebx
f010297d:	85 db                	test   %ebx,%ebx
f010297f:	0f 84 43 01 00 00    	je     f0102ac8 <env_alloc+0x158>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102985:	83 ec 0c             	sub    $0xc,%esp
f0102988:	6a 01                	push   $0x1
f010298a:	e8 ae e3 ff ff       	call   f0100d3d <page_alloc>
f010298f:	83 c4 10             	add    $0x10,%esp
f0102992:	85 c0                	test   %eax,%eax
f0102994:	0f 84 35 01 00 00    	je     f0102acf <env_alloc+0x15f>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f010299a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010299f:	2b 05 4c 4c 17 f0    	sub    0xf0174c4c,%eax
f01029a5:	c1 f8 03             	sar    $0x3,%eax
f01029a8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029ab:	89 c2                	mov    %eax,%edx
f01029ad:	c1 ea 0c             	shr    $0xc,%edx
f01029b0:	3b 15 44 4c 17 f0    	cmp    0xf0174c44,%edx
f01029b6:	72 12                	jb     f01029ca <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029b8:	50                   	push   %eax
f01029b9:	68 e4 4b 10 f0       	push   $0xf0104be4
f01029be:	6a 56                	push   $0x56
f01029c0:	68 fd 53 10 f0       	push   $0xf01053fd
f01029c5:	e8 d6 d6 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f01029ca:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f01029cf:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir,kern_pgdir,PGSIZE);
f01029d2:	83 ec 04             	sub    $0x4,%esp
f01029d5:	68 00 10 00 00       	push   $0x1000
f01029da:	ff 35 48 4c 17 f0    	pushl  0xf0174c48
f01029e0:	50                   	push   %eax
f01029e1:	e8 26 19 00 00       	call   f010430c <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01029e6:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029e9:	83 c4 10             	add    $0x10,%esp
f01029ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029f1:	77 15                	ja     f0102a08 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029f3:	50                   	push   %eax
f01029f4:	68 cc 4c 10 f0       	push   $0xf0104ccc
f01029f9:	68 c4 00 00 00       	push   $0xc4
f01029fe:	68 ea 56 10 f0       	push   $0xf01056ea
f0102a03:	e8 98 d6 ff ff       	call   f01000a0 <_panic>
f0102a08:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a0e:	83 ca 05             	or     $0x5,%edx
f0102a11:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a17:	8b 43 48             	mov    0x48(%ebx),%eax
f0102a1a:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102a1f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102a24:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a29:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102a2c:	89 da                	mov    %ebx,%edx
f0102a2e:	2b 15 8c 3f 17 f0    	sub    0xf0173f8c,%edx
f0102a34:	c1 fa 05             	sar    $0x5,%edx
f0102a37:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102a3d:	09 d0                	or     %edx,%eax
f0102a3f:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102a42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a45:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102a48:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102a4f:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102a56:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102a5d:	83 ec 04             	sub    $0x4,%esp
f0102a60:	6a 44                	push   $0x44
f0102a62:	6a 00                	push   $0x0
f0102a64:	53                   	push   %ebx
f0102a65:	e8 ed 17 00 00       	call   f0104257 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102a6a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102a70:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102a76:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102a7c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102a83:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102a89:	8b 43 44             	mov    0x44(%ebx),%eax
f0102a8c:	a3 90 3f 17 f0       	mov    %eax,0xf0173f90
	*newenv_store = e;
f0102a91:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a94:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102a96:	8b 53 48             	mov    0x48(%ebx),%edx
f0102a99:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
f0102a9e:	83 c4 10             	add    $0x10,%esp
f0102aa1:	85 c0                	test   %eax,%eax
f0102aa3:	74 05                	je     f0102aaa <env_alloc+0x13a>
f0102aa5:	8b 40 48             	mov    0x48(%eax),%eax
f0102aa8:	eb 05                	jmp    f0102aaf <env_alloc+0x13f>
f0102aaa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aaf:	83 ec 04             	sub    $0x4,%esp
f0102ab2:	52                   	push   %edx
f0102ab3:	50                   	push   %eax
f0102ab4:	68 f5 56 10 f0       	push   $0xf01056f5
f0102ab9:	e8 3c 04 00 00       	call   f0102efa <cprintf>
	return 0;
f0102abe:	83 c4 10             	add    $0x10,%esp
f0102ac1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ac6:	eb 0c                	jmp    f0102ad4 <env_alloc+0x164>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102ac8:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102acd:	eb 05                	jmp    f0102ad4 <env_alloc+0x164>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102acf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ad7:	c9                   	leave  
f0102ad8:	c3                   	ret    

f0102ad9 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102ad9:	55                   	push   %ebp
f0102ada:	89 e5                	mov    %esp,%ebp
f0102adc:	57                   	push   %edi
f0102add:	56                   	push   %esi
f0102ade:	53                   	push   %ebx
f0102adf:	83 ec 34             	sub    $0x34,%esp
f0102ae2:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env * e;
	if(env_alloc(&e,0)<0)
f0102ae5:	6a 00                	push   $0x0
f0102ae7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102aea:	50                   	push   %eax
f0102aeb:	e8 80 fe ff ff       	call   f0102970 <env_alloc>
f0102af0:	83 c4 10             	add    $0x10,%esp
f0102af3:	85 c0                	test   %eax,%eax
f0102af5:	79 17                	jns    f0102b0e <env_create+0x35>
		panic("env_create: less than zero");
f0102af7:	83 ec 04             	sub    $0x4,%esp
f0102afa:	68 0a 57 10 f0       	push   $0xf010570a
f0102aff:	68 85 01 00 00       	push   $0x185
f0102b04:	68 ea 56 10 f0       	push   $0xf01056ea
f0102b09:	e8 92 d5 ff ff       	call   f01000a0 <_panic>
	e->env_type = type;
f0102b0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b11:	89 c1                	mov    %eax,%ecx
f0102b13:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b19:	89 41 50             	mov    %eax,0x50(%ecx)

	// LAB 3: Your code here.
	
	struct Elf * Env_elf = (struct Elf *)binary;
	struct Proghdr *ph,*End_ph;
	ph = (struct Proghdr *)((uint8_t*)(Env_elf) + Env_elf->e_phoff);
f0102b1c:	89 fb                	mov    %edi,%ebx
f0102b1e:	03 5f 1c             	add    0x1c(%edi),%ebx
	End_ph = ph + Env_elf->e_phnum;
f0102b21:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102b25:	c1 e6 05             	shl    $0x5,%esi
f0102b28:	01 de                	add    %ebx,%esi
	if(Env_elf->e_magic !=ELF_MAGIC)
f0102b2a:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102b30:	74 17                	je     f0102b49 <env_create+0x70>
	{
	        panic("load_icode:not an ELF file");
f0102b32:	83 ec 04             	sub    $0x4,%esp
f0102b35:	68 25 57 10 f0       	push   $0xf0105725
f0102b3a:	68 60 01 00 00       	push   $0x160
f0102b3f:	68 ea 56 10 f0       	push   $0xf01056ea
f0102b44:	e8 57 d5 ff ff       	call   f01000a0 <_panic>
        }
        lcr3(PADDR(e->env_pgdir));
f0102b49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b4c:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b54:	77 15                	ja     f0102b6b <env_create+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b56:	50                   	push   %eax
f0102b57:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102b5c:	68 62 01 00 00       	push   $0x162
f0102b61:	68 ea 56 10 f0       	push   $0xf01056ea
f0102b66:	e8 35 d5 ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b6b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b70:	0f 22 d8             	mov    %eax,%cr3
f0102b73:	eb 60                	jmp    f0102bd5 <env_create+0xfc>
        for(;ph<End_ph;ph++)
        {
	        if(ph->p_type == ELF_PROG_LOAD)
f0102b75:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102b78:	75 58                	jne    f0102bd2 <env_create+0xf9>
	        {
		        if(ph->p_filesz > ph->p_memsz)
f0102b7a:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102b7d:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102b80:	76 17                	jbe    f0102b99 <env_create+0xc0>
			        panic("load_icode: file size if greater than memory size");
f0102b82:	83 ec 04             	sub    $0x4,%esp
f0102b85:	68 64 57 10 f0       	push   $0xf0105764
f0102b8a:	68 68 01 00 00       	push   $0x168
f0102b8f:	68 ea 56 10 f0       	push   $0xf01056ea
f0102b94:	e8 07 d5 ff ff       	call   f01000a0 <_panic>
		        region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0102b99:	8b 53 08             	mov    0x8(%ebx),%edx
f0102b9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b9f:	e8 6e fc ff ff       	call   f0102812 <region_alloc>
		        memcpy((void*)ph->p_va,(void *)(binary+ph->p_offset),ph->p_filesz);
f0102ba4:	83 ec 04             	sub    $0x4,%esp
f0102ba7:	ff 73 10             	pushl  0x10(%ebx)
f0102baa:	89 f8                	mov    %edi,%eax
f0102bac:	03 43 04             	add    0x4(%ebx),%eax
f0102baf:	50                   	push   %eax
f0102bb0:	ff 73 08             	pushl  0x8(%ebx)
f0102bb3:	e8 54 17 00 00       	call   f010430c <memcpy>
		        memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz-ph->p_filesz);
f0102bb8:	8b 43 10             	mov    0x10(%ebx),%eax
f0102bbb:	83 c4 0c             	add    $0xc,%esp
f0102bbe:	8b 53 14             	mov    0x14(%ebx),%edx
f0102bc1:	29 c2                	sub    %eax,%edx
f0102bc3:	52                   	push   %edx
f0102bc4:	6a 00                	push   $0x0
f0102bc6:	03 43 08             	add    0x8(%ebx),%eax
f0102bc9:	50                   	push   %eax
f0102bca:	e8 88 16 00 00       	call   f0104257 <memset>
f0102bcf:	83 c4 10             	add    $0x10,%esp
	if(Env_elf->e_magic !=ELF_MAGIC)
	{
	        panic("load_icode:not an ELF file");
        }
        lcr3(PADDR(e->env_pgdir));
        for(;ph<End_ph;ph++)
f0102bd2:	83 c3 20             	add    $0x20,%ebx
f0102bd5:	39 de                	cmp    %ebx,%esi
f0102bd7:	77 9c                	ja     f0102b75 <env_create+0x9c>
		        region_alloc(e,(void *)ph->p_va,ph->p_memsz);
		        memcpy((void*)ph->p_va,(void *)(binary+ph->p_offset),ph->p_filesz);
		        memset((void*)(ph->p_va+ph->p_filesz),0,ph->p_memsz-ph->p_filesz);
	        }
        }
        e->env_tf.tf_eip = Env_elf->e_entry;
f0102bd9:	8b 47 18             	mov    0x18(%edi),%eax
f0102bdc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102bdf:	89 47 30             	mov    %eax,0x30(%edi)
        lcr3(PADDR(kern_pgdir));
f0102be2:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bec:	77 15                	ja     f0102c03 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bee:	50                   	push   %eax
f0102bef:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102bf4:	68 6f 01 00 00       	push   $0x16f
f0102bf9:	68 ea 56 10 f0       	push   $0xf01056ea
f0102bfe:	e8 9d d4 ff ff       	call   f01000a0 <_panic>
f0102c03:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c08:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	
	region_alloc(e,(void*)(USTACKTOP-PGSIZE),PGSIZE);
f0102c0b:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102c10:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102c15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c18:	e8 f5 fb ff ff       	call   f0102812 <region_alloc>
	struct Env * e;
	if(env_alloc(&e,0)<0)
		panic("env_create: less than zero");
	e->env_type = type;
	load_icode(e,binary);
}
f0102c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c20:	5b                   	pop    %ebx
f0102c21:	5e                   	pop    %esi
f0102c22:	5f                   	pop    %edi
f0102c23:	5d                   	pop    %ebp
f0102c24:	c3                   	ret    

f0102c25 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102c25:	55                   	push   %ebp
f0102c26:	89 e5                	mov    %esp,%ebp
f0102c28:	57                   	push   %edi
f0102c29:	56                   	push   %esi
f0102c2a:	53                   	push   %ebx
f0102c2b:	83 ec 1c             	sub    $0x1c,%esp
f0102c2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102c31:	8b 15 88 3f 17 f0    	mov    0xf0173f88,%edx
f0102c37:	39 fa                	cmp    %edi,%edx
f0102c39:	75 29                	jne    f0102c64 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102c3b:	a1 48 4c 17 f0       	mov    0xf0174c48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c40:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c45:	77 15                	ja     f0102c5c <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c47:	50                   	push   %eax
f0102c48:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102c4d:	68 98 01 00 00       	push   $0x198
f0102c52:	68 ea 56 10 f0       	push   $0xf01056ea
f0102c57:	e8 44 d4 ff ff       	call   f01000a0 <_panic>
f0102c5c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c61:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c64:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102c67:	85 d2                	test   %edx,%edx
f0102c69:	74 05                	je     f0102c70 <env_free+0x4b>
f0102c6b:	8b 42 48             	mov    0x48(%edx),%eax
f0102c6e:	eb 05                	jmp    f0102c75 <env_free+0x50>
f0102c70:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c75:	83 ec 04             	sub    $0x4,%esp
f0102c78:	51                   	push   %ecx
f0102c79:	50                   	push   %eax
f0102c7a:	68 40 57 10 f0       	push   $0xf0105740
f0102c7f:	e8 76 02 00 00       	call   f0102efa <cprintf>
f0102c84:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102c87:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102c8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102c91:	89 d0                	mov    %edx,%eax
f0102c93:	c1 e0 02             	shl    $0x2,%eax
f0102c96:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102c99:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102c9c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102c9f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102ca5:	0f 84 a8 00 00 00    	je     f0102d53 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102cab:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cb1:	89 f0                	mov    %esi,%eax
f0102cb3:	c1 e8 0c             	shr    $0xc,%eax
f0102cb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102cb9:	39 05 44 4c 17 f0    	cmp    %eax,0xf0174c44
f0102cbf:	77 15                	ja     f0102cd6 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cc1:	56                   	push   %esi
f0102cc2:	68 e4 4b 10 f0       	push   $0xf0104be4
f0102cc7:	68 a7 01 00 00       	push   $0x1a7
f0102ccc:	68 ea 56 10 f0       	push   $0xf01056ea
f0102cd1:	e8 ca d3 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cd9:	c1 e0 16             	shl    $0x16,%eax
f0102cdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102ce4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102ceb:	01 
f0102cec:	74 17                	je     f0102d05 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102cee:	83 ec 08             	sub    $0x8,%esp
f0102cf1:	89 d8                	mov    %ebx,%eax
f0102cf3:	c1 e0 0c             	shl    $0xc,%eax
f0102cf6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102cf9:	50                   	push   %eax
f0102cfa:	ff 77 5c             	pushl  0x5c(%edi)
f0102cfd:	e8 4b e2 ff ff       	call   f0100f4d <page_remove>
f0102d02:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d05:	83 c3 01             	add    $0x1,%ebx
f0102d08:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102d0e:	75 d4                	jne    f0102ce4 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102d10:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d13:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102d16:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102d20:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0102d26:	72 14                	jb     f0102d3c <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102d28:	83 ec 04             	sub    $0x4,%esp
f0102d2b:	68 18 4d 10 f0       	push   $0xf0104d18
f0102d30:	6a 4f                	push   $0x4f
f0102d32:	68 fd 53 10 f0       	push   $0xf01053fd
f0102d37:	e8 64 d3 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102d3c:	83 ec 0c             	sub    $0xc,%esp
f0102d3f:	a1 4c 4c 17 f0       	mov    0xf0174c4c,%eax
f0102d44:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d47:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102d4a:	50                   	push   %eax
f0102d4b:	e8 6c e0 ff ff       	call   f0100dbc <page_decref>
f0102d50:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d53:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102d57:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d5a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102d5f:	0f 85 29 ff ff ff    	jne    f0102c8e <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102d65:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d6d:	77 15                	ja     f0102d84 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d6f:	50                   	push   %eax
f0102d70:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102d75:	68 b5 01 00 00       	push   $0x1b5
f0102d7a:	68 ea 56 10 f0       	push   $0xf01056ea
f0102d7f:	e8 1c d3 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102d84:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d8b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d90:	c1 e8 0c             	shr    $0xc,%eax
f0102d93:	3b 05 44 4c 17 f0    	cmp    0xf0174c44,%eax
f0102d99:	72 14                	jb     f0102daf <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102d9b:	83 ec 04             	sub    $0x4,%esp
f0102d9e:	68 18 4d 10 f0       	push   $0xf0104d18
f0102da3:	6a 4f                	push   $0x4f
f0102da5:	68 fd 53 10 f0       	push   $0xf01053fd
f0102daa:	e8 f1 d2 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102daf:	83 ec 0c             	sub    $0xc,%esp
f0102db2:	8b 15 4c 4c 17 f0    	mov    0xf0174c4c,%edx
f0102db8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102dbb:	50                   	push   %eax
f0102dbc:	e8 fb df ff ff       	call   f0100dbc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102dc1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102dc8:	a1 90 3f 17 f0       	mov    0xf0173f90,%eax
f0102dcd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102dd0:	89 3d 90 3f 17 f0    	mov    %edi,0xf0173f90
}
f0102dd6:	83 c4 10             	add    $0x10,%esp
f0102dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ddc:	5b                   	pop    %ebx
f0102ddd:	5e                   	pop    %esi
f0102dde:	5f                   	pop    %edi
f0102ddf:	5d                   	pop    %ebp
f0102de0:	c3                   	ret    

f0102de1 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102de1:	55                   	push   %ebp
f0102de2:	89 e5                	mov    %esp,%ebp
f0102de4:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102de7:	ff 75 08             	pushl  0x8(%ebp)
f0102dea:	e8 36 fe ff ff       	call   f0102c25 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102def:	c7 04 24 98 57 10 f0 	movl   $0xf0105798,(%esp)
f0102df6:	e8 ff 00 00 00       	call   f0102efa <cprintf>
f0102dfb:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102dfe:	83 ec 0c             	sub    $0xc,%esp
f0102e01:	6a 00                	push   $0x0
f0102e03:	e8 a4 d9 ff ff       	call   f01007ac <monitor>
f0102e08:	83 c4 10             	add    $0x10,%esp
f0102e0b:	eb f1                	jmp    f0102dfe <env_destroy+0x1d>

f0102e0d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102e0d:	55                   	push   %ebp
f0102e0e:	89 e5                	mov    %esp,%ebp
f0102e10:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102e13:	8b 65 08             	mov    0x8(%ebp),%esp
f0102e16:	61                   	popa   
f0102e17:	07                   	pop    %es
f0102e18:	1f                   	pop    %ds
f0102e19:	83 c4 08             	add    $0x8,%esp
f0102e1c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102e1d:	68 56 57 10 f0       	push   $0xf0105756
f0102e22:	68 dd 01 00 00       	push   $0x1dd
f0102e27:	68 ea 56 10 f0       	push   $0xf01056ea
f0102e2c:	e8 6f d2 ff ff       	call   f01000a0 <_panic>

f0102e31 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102e31:	55                   	push   %ebp
f0102e32:	89 e5                	mov    %esp,%ebp
f0102e34:	83 ec 08             	sub    $0x8,%esp
f0102e37:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv && curenv->env_status == ENV_RUNNING)
f0102e3a:	8b 15 88 3f 17 f0    	mov    0xf0173f88,%edx
f0102e40:	85 d2                	test   %edx,%edx
f0102e42:	74 0d                	je     f0102e51 <env_run+0x20>
f0102e44:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102e48:	75 07                	jne    f0102e51 <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0102e4a:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	curenv = e;
f0102e51:	a3 88 3f 17 f0       	mov    %eax,0xf0173f88
	curenv->env_status = ENV_RUNNING;
f0102e56:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs ++;
f0102e5d:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0102e61:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e64:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102e6a:	77 15                	ja     f0102e81 <env_run+0x50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e6c:	52                   	push   %edx
f0102e6d:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0102e72:	68 00 02 00 00       	push   $0x200
f0102e77:	68 ea 56 10 f0       	push   $0xf01056ea
f0102e7c:	e8 1f d2 ff ff       	call   f01000a0 <_panic>
f0102e81:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102e87:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&curenv->env_tf);
f0102e8a:	83 ec 0c             	sub    $0xc,%esp
f0102e8d:	50                   	push   %eax
f0102e8e:	e8 7a ff ff ff       	call   f0102e0d <env_pop_tf>

f0102e93 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102e93:	55                   	push   %ebp
f0102e94:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102e96:	ba 70 00 00 00       	mov    $0x70,%edx
f0102e9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e9e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102e9f:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ea4:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102ea5:	0f b6 c0             	movzbl %al,%eax
}
f0102ea8:	5d                   	pop    %ebp
f0102ea9:	c3                   	ret    

f0102eaa <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102eaa:	55                   	push   %ebp
f0102eab:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ead:	ba 70 00 00 00       	mov    $0x70,%edx
f0102eb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eb5:	ee                   	out    %al,(%dx)
f0102eb6:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ebe:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102ebf:	5d                   	pop    %ebp
f0102ec0:	c3                   	ret    

f0102ec1 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102ec1:	55                   	push   %ebp
f0102ec2:	89 e5                	mov    %esp,%ebp
f0102ec4:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102ec7:	ff 75 08             	pushl  0x8(%ebp)
f0102eca:	e8 38 d7 ff ff       	call   f0100607 <cputchar>
	*cnt++;
}
f0102ecf:	83 c4 10             	add    $0x10,%esp
f0102ed2:	c9                   	leave  
f0102ed3:	c3                   	ret    

f0102ed4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102ed4:	55                   	push   %ebp
f0102ed5:	89 e5                	mov    %esp,%ebp
f0102ed7:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102eda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102ee1:	ff 75 0c             	pushl  0xc(%ebp)
f0102ee4:	ff 75 08             	pushl  0x8(%ebp)
f0102ee7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102eea:	50                   	push   %eax
f0102eeb:	68 c1 2e 10 f0       	push   $0xf0102ec1
f0102ef0:	e8 f6 0c 00 00       	call   f0103beb <vprintfmt>
	return cnt;
}
f0102ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ef8:	c9                   	leave  
f0102ef9:	c3                   	ret    

f0102efa <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102efa:	55                   	push   %ebp
f0102efb:	89 e5                	mov    %esp,%ebp
f0102efd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f00:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f03:	50                   	push   %eax
f0102f04:	ff 75 08             	pushl  0x8(%ebp)
f0102f07:	e8 c8 ff ff ff       	call   f0102ed4 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f0c:	c9                   	leave  
f0102f0d:	c3                   	ret    

f0102f0e <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102f0e:	55                   	push   %ebp
f0102f0f:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102f11:	b8 c0 47 17 f0       	mov    $0xf01747c0,%eax
f0102f16:	c7 05 c4 47 17 f0 00 	movl   $0xf0000000,0xf01747c4
f0102f1d:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102f20:	66 c7 05 c8 47 17 f0 	movw   $0x10,0xf01747c8
f0102f27:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102f29:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f0102f30:	67 00 
f0102f32:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f0102f38:	89 c2                	mov    %eax,%edx
f0102f3a:	c1 ea 10             	shr    $0x10,%edx
f0102f3d:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f0102f43:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f0102f4a:	c1 e8 18             	shr    $0x18,%eax
f0102f4d:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102f52:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102f59:	b8 28 00 00 00       	mov    $0x28,%eax
f0102f5e:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0102f61:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f0102f66:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102f69:	5d                   	pop    %ebp
f0102f6a:	c3                   	ret    

f0102f6b <trap_init>:
}


void
trap_init(void)
{
f0102f6b:	55                   	push   %ebp
f0102f6c:	89 e5                	mov    %esp,%ebp
	void handler14();
	void handler15();
	void handler16();
	void handler48();

	SETGATE(idt[T_DIVIDE], 1, GD_KT, handler0, 0);
f0102f6e:	b8 bc 35 10 f0       	mov    $0xf01035bc,%eax
f0102f73:	66 a3 a0 3f 17 f0    	mov    %ax,0xf0173fa0
f0102f79:	66 c7 05 a2 3f 17 f0 	movw   $0x8,0xf0173fa2
f0102f80:	08 00 
f0102f82:	c6 05 a4 3f 17 f0 00 	movb   $0x0,0xf0173fa4
f0102f89:	c6 05 a5 3f 17 f0 8f 	movb   $0x8f,0xf0173fa5
f0102f90:	c1 e8 10             	shr    $0x10,%eax
f0102f93:	66 a3 a6 3f 17 f0    	mov    %ax,0xf0173fa6
	SETGATE(idt[T_DEBUG], 1, GD_KT, handler1, 0);
f0102f99:	b8 c2 35 10 f0       	mov    $0xf01035c2,%eax
f0102f9e:	66 a3 a8 3f 17 f0    	mov    %ax,0xf0173fa8
f0102fa4:	66 c7 05 aa 3f 17 f0 	movw   $0x8,0xf0173faa
f0102fab:	08 00 
f0102fad:	c6 05 ac 3f 17 f0 00 	movb   $0x0,0xf0173fac
f0102fb4:	c6 05 ad 3f 17 f0 8f 	movb   $0x8f,0xf0173fad
f0102fbb:	c1 e8 10             	shr    $0x10,%eax
f0102fbe:	66 a3 ae 3f 17 f0    	mov    %ax,0xf0173fae
	SETGATE(idt[T_NMI], 0, GD_KT, handler2, 0);
f0102fc4:	b8 c8 35 10 f0       	mov    $0xf01035c8,%eax
f0102fc9:	66 a3 b0 3f 17 f0    	mov    %ax,0xf0173fb0
f0102fcf:	66 c7 05 b2 3f 17 f0 	movw   $0x8,0xf0173fb2
f0102fd6:	08 00 
f0102fd8:	c6 05 b4 3f 17 f0 00 	movb   $0x0,0xf0173fb4
f0102fdf:	c6 05 b5 3f 17 f0 8e 	movb   $0x8e,0xf0173fb5
f0102fe6:	c1 e8 10             	shr    $0x10,%eax
f0102fe9:	66 a3 b6 3f 17 f0    	mov    %ax,0xf0173fb6
	SETGATE(idt[T_BRKPT], 1, GD_KT, handler3, 3);
f0102fef:	b8 ce 35 10 f0       	mov    $0xf01035ce,%eax
f0102ff4:	66 a3 b8 3f 17 f0    	mov    %ax,0xf0173fb8
f0102ffa:	66 c7 05 ba 3f 17 f0 	movw   $0x8,0xf0173fba
f0103001:	08 00 
f0103003:	c6 05 bc 3f 17 f0 00 	movb   $0x0,0xf0173fbc
f010300a:	c6 05 bd 3f 17 f0 ef 	movb   $0xef,0xf0173fbd
f0103011:	c1 e8 10             	shr    $0x10,%eax
f0103014:	66 a3 be 3f 17 f0    	mov    %ax,0xf0173fbe
	SETGATE(idt[T_OFLOW], 1, GD_KT, handler4, 0);
f010301a:	b8 d4 35 10 f0       	mov    $0xf01035d4,%eax
f010301f:	66 a3 c0 3f 17 f0    	mov    %ax,0xf0173fc0
f0103025:	66 c7 05 c2 3f 17 f0 	movw   $0x8,0xf0173fc2
f010302c:	08 00 
f010302e:	c6 05 c4 3f 17 f0 00 	movb   $0x0,0xf0173fc4
f0103035:	c6 05 c5 3f 17 f0 8f 	movb   $0x8f,0xf0173fc5
f010303c:	c1 e8 10             	shr    $0x10,%eax
f010303f:	66 a3 c6 3f 17 f0    	mov    %ax,0xf0173fc6
	SETGATE(idt[T_BOUND], 1, GD_KT, handler5, 0);
f0103045:	b8 da 35 10 f0       	mov    $0xf01035da,%eax
f010304a:	66 a3 c8 3f 17 f0    	mov    %ax,0xf0173fc8
f0103050:	66 c7 05 ca 3f 17 f0 	movw   $0x8,0xf0173fca
f0103057:	08 00 
f0103059:	c6 05 cc 3f 17 f0 00 	movb   $0x0,0xf0173fcc
f0103060:	c6 05 cd 3f 17 f0 8f 	movb   $0x8f,0xf0173fcd
f0103067:	c1 e8 10             	shr    $0x10,%eax
f010306a:	66 a3 ce 3f 17 f0    	mov    %ax,0xf0173fce
	SETGATE(idt[T_ILLOP], 1, GD_KT, handler6, 0);
f0103070:	b8 e0 35 10 f0       	mov    $0xf01035e0,%eax
f0103075:	66 a3 d0 3f 17 f0    	mov    %ax,0xf0173fd0
f010307b:	66 c7 05 d2 3f 17 f0 	movw   $0x8,0xf0173fd2
f0103082:	08 00 
f0103084:	c6 05 d4 3f 17 f0 00 	movb   $0x0,0xf0173fd4
f010308b:	c6 05 d5 3f 17 f0 8f 	movb   $0x8f,0xf0173fd5
f0103092:	c1 e8 10             	shr    $0x10,%eax
f0103095:	66 a3 d6 3f 17 f0    	mov    %ax,0xf0173fd6
	SETGATE(idt[T_DEVICE], 1, GD_KT, handler7, 0);
f010309b:	b8 e6 35 10 f0       	mov    $0xf01035e6,%eax
f01030a0:	66 a3 d8 3f 17 f0    	mov    %ax,0xf0173fd8
f01030a6:	66 c7 05 da 3f 17 f0 	movw   $0x8,0xf0173fda
f01030ad:	08 00 
f01030af:	c6 05 dc 3f 17 f0 00 	movb   $0x0,0xf0173fdc
f01030b6:	c6 05 dd 3f 17 f0 8f 	movb   $0x8f,0xf0173fdd
f01030bd:	c1 e8 10             	shr    $0x10,%eax
f01030c0:	66 a3 de 3f 17 f0    	mov    %ax,0xf0173fde
	SETGATE(idt[T_DBLFLT], 1, GD_KT, handler8, 0);
f01030c6:	b8 ea 35 10 f0       	mov    $0xf01035ea,%eax
f01030cb:	66 a3 e0 3f 17 f0    	mov    %ax,0xf0173fe0
f01030d1:	66 c7 05 e2 3f 17 f0 	movw   $0x8,0xf0173fe2
f01030d8:	08 00 
f01030da:	c6 05 e4 3f 17 f0 00 	movb   $0x0,0xf0173fe4
f01030e1:	c6 05 e5 3f 17 f0 8f 	movb   $0x8f,0xf0173fe5
f01030e8:	c1 e8 10             	shr    $0x10,%eax
f01030eb:	66 a3 e6 3f 17 f0    	mov    %ax,0xf0173fe6
	SETGATE(idt[T_TSS], 1, GD_KT, handler10, 0);
f01030f1:	b8 f0 35 10 f0       	mov    $0xf01035f0,%eax
f01030f6:	66 a3 f0 3f 17 f0    	mov    %ax,0xf0173ff0
f01030fc:	66 c7 05 f2 3f 17 f0 	movw   $0x8,0xf0173ff2
f0103103:	08 00 
f0103105:	c6 05 f4 3f 17 f0 00 	movb   $0x0,0xf0173ff4
f010310c:	c6 05 f5 3f 17 f0 8f 	movb   $0x8f,0xf0173ff5
f0103113:	c1 e8 10             	shr    $0x10,%eax
f0103116:	66 a3 f6 3f 17 f0    	mov    %ax,0xf0173ff6
	SETGATE(idt[T_SEGNP], 1, GD_KT, handler11, 0);
f010311c:	b8 f4 35 10 f0       	mov    $0xf01035f4,%eax
f0103121:	66 a3 f8 3f 17 f0    	mov    %ax,0xf0173ff8
f0103127:	66 c7 05 fa 3f 17 f0 	movw   $0x8,0xf0173ffa
f010312e:	08 00 
f0103130:	c6 05 fc 3f 17 f0 00 	movb   $0x0,0xf0173ffc
f0103137:	c6 05 fd 3f 17 f0 8f 	movb   $0x8f,0xf0173ffd
f010313e:	c1 e8 10             	shr    $0x10,%eax
f0103141:	66 a3 fe 3f 17 f0    	mov    %ax,0xf0173ffe
	SETGATE(idt[T_STACK], 1, GD_KT, handler12, 0);
f0103147:	b8 f8 35 10 f0       	mov    $0xf01035f8,%eax
f010314c:	66 a3 00 40 17 f0    	mov    %ax,0xf0174000
f0103152:	66 c7 05 02 40 17 f0 	movw   $0x8,0xf0174002
f0103159:	08 00 
f010315b:	c6 05 04 40 17 f0 00 	movb   $0x0,0xf0174004
f0103162:	c6 05 05 40 17 f0 8f 	movb   $0x8f,0xf0174005
f0103169:	c1 e8 10             	shr    $0x10,%eax
f010316c:	66 a3 06 40 17 f0    	mov    %ax,0xf0174006
	SETGATE(idt[T_GPFLT], 1, GD_KT, handler13, 0);
f0103172:	b8 fc 35 10 f0       	mov    $0xf01035fc,%eax
f0103177:	66 a3 08 40 17 f0    	mov    %ax,0xf0174008
f010317d:	66 c7 05 0a 40 17 f0 	movw   $0x8,0xf017400a
f0103184:	08 00 
f0103186:	c6 05 0c 40 17 f0 00 	movb   $0x0,0xf017400c
f010318d:	c6 05 0d 40 17 f0 8f 	movb   $0x8f,0xf017400d
f0103194:	c1 e8 10             	shr    $0x10,%eax
f0103197:	66 a3 0e 40 17 f0    	mov    %ax,0xf017400e
	SETGATE(idt[T_PGFLT], 1, GD_KT, handler14, 0);
f010319d:	b8 00 36 10 f0       	mov    $0xf0103600,%eax
f01031a2:	66 a3 10 40 17 f0    	mov    %ax,0xf0174010
f01031a8:	66 c7 05 12 40 17 f0 	movw   $0x8,0xf0174012
f01031af:	08 00 
f01031b1:	c6 05 14 40 17 f0 00 	movb   $0x0,0xf0174014
f01031b8:	c6 05 15 40 17 f0 8f 	movb   $0x8f,0xf0174015
f01031bf:	c1 e8 10             	shr    $0x10,%eax
f01031c2:	66 a3 16 40 17 f0    	mov    %ax,0xf0174016
	SETGATE(idt[T_FPERR], 1, GD_KT, handler16, 0);
f01031c8:	b8 04 36 10 f0       	mov    $0xf0103604,%eax
f01031cd:	66 a3 20 40 17 f0    	mov    %ax,0xf0174020
f01031d3:	66 c7 05 22 40 17 f0 	movw   $0x8,0xf0174022
f01031da:	08 00 
f01031dc:	c6 05 24 40 17 f0 00 	movb   $0x0,0xf0174024
f01031e3:	c6 05 25 40 17 f0 8f 	movb   $0x8f,0xf0174025
f01031ea:	c1 e8 10             	shr    $0x10,%eax
f01031ed:	66 a3 26 40 17 f0    	mov    %ax,0xf0174026
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
f01031f3:	b8 0a 36 10 f0       	mov    $0xf010360a,%eax
f01031f8:	66 a3 20 41 17 f0    	mov    %ax,0xf0174120
f01031fe:	66 c7 05 22 41 17 f0 	movw   $0x8,0xf0174122
f0103205:	08 00 
f0103207:	c6 05 24 41 17 f0 00 	movb   $0x0,0xf0174124
f010320e:	c6 05 25 41 17 f0 ee 	movb   $0xee,0xf0174125
f0103215:	c1 e8 10             	shr    $0x10,%eax
f0103218:	66 a3 26 41 17 f0    	mov    %ax,0xf0174126

	// Per-CPU setup 
	trap_init_percpu();
f010321e:	e8 eb fc ff ff       	call   f0102f0e <trap_init_percpu>
}
f0103223:	5d                   	pop    %ebp
f0103224:	c3                   	ret    

f0103225 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103225:	55                   	push   %ebp
f0103226:	89 e5                	mov    %esp,%ebp
f0103228:	53                   	push   %ebx
f0103229:	83 ec 0c             	sub    $0xc,%esp
f010322c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010322f:	ff 33                	pushl  (%ebx)
f0103231:	68 ce 57 10 f0       	push   $0xf01057ce
f0103236:	e8 bf fc ff ff       	call   f0102efa <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010323b:	83 c4 08             	add    $0x8,%esp
f010323e:	ff 73 04             	pushl  0x4(%ebx)
f0103241:	68 dd 57 10 f0       	push   $0xf01057dd
f0103246:	e8 af fc ff ff       	call   f0102efa <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010324b:	83 c4 08             	add    $0x8,%esp
f010324e:	ff 73 08             	pushl  0x8(%ebx)
f0103251:	68 ec 57 10 f0       	push   $0xf01057ec
f0103256:	e8 9f fc ff ff       	call   f0102efa <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010325b:	83 c4 08             	add    $0x8,%esp
f010325e:	ff 73 0c             	pushl  0xc(%ebx)
f0103261:	68 fb 57 10 f0       	push   $0xf01057fb
f0103266:	e8 8f fc ff ff       	call   f0102efa <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010326b:	83 c4 08             	add    $0x8,%esp
f010326e:	ff 73 10             	pushl  0x10(%ebx)
f0103271:	68 0a 58 10 f0       	push   $0xf010580a
f0103276:	e8 7f fc ff ff       	call   f0102efa <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010327b:	83 c4 08             	add    $0x8,%esp
f010327e:	ff 73 14             	pushl  0x14(%ebx)
f0103281:	68 19 58 10 f0       	push   $0xf0105819
f0103286:	e8 6f fc ff ff       	call   f0102efa <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010328b:	83 c4 08             	add    $0x8,%esp
f010328e:	ff 73 18             	pushl  0x18(%ebx)
f0103291:	68 28 58 10 f0       	push   $0xf0105828
f0103296:	e8 5f fc ff ff       	call   f0102efa <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010329b:	83 c4 08             	add    $0x8,%esp
f010329e:	ff 73 1c             	pushl  0x1c(%ebx)
f01032a1:	68 37 58 10 f0       	push   $0xf0105837
f01032a6:	e8 4f fc ff ff       	call   f0102efa <cprintf>
}
f01032ab:	83 c4 10             	add    $0x10,%esp
f01032ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032b1:	c9                   	leave  
f01032b2:	c3                   	ret    

f01032b3 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01032b3:	55                   	push   %ebp
f01032b4:	89 e5                	mov    %esp,%ebp
f01032b6:	56                   	push   %esi
f01032b7:	53                   	push   %ebx
f01032b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01032bb:	83 ec 08             	sub    $0x8,%esp
f01032be:	53                   	push   %ebx
f01032bf:	68 89 59 10 f0       	push   $0xf0105989
f01032c4:	e8 31 fc ff ff       	call   f0102efa <cprintf>
	print_regs(&tf->tf_regs);
f01032c9:	89 1c 24             	mov    %ebx,(%esp)
f01032cc:	e8 54 ff ff ff       	call   f0103225 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01032d1:	83 c4 08             	add    $0x8,%esp
f01032d4:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01032d8:	50                   	push   %eax
f01032d9:	68 88 58 10 f0       	push   $0xf0105888
f01032de:	e8 17 fc ff ff       	call   f0102efa <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01032e3:	83 c4 08             	add    $0x8,%esp
f01032e6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01032ea:	50                   	push   %eax
f01032eb:	68 9b 58 10 f0       	push   $0xf010589b
f01032f0:	e8 05 fc ff ff       	call   f0102efa <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01032f5:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01032f8:	83 c4 10             	add    $0x10,%esp
f01032fb:	83 f8 13             	cmp    $0x13,%eax
f01032fe:	77 09                	ja     f0103309 <print_trapframe+0x56>
		return excnames[trapno];
f0103300:	8b 14 85 60 5b 10 f0 	mov    -0xfefa4a0(,%eax,4),%edx
f0103307:	eb 10                	jmp    f0103319 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103309:	83 f8 30             	cmp    $0x30,%eax
f010330c:	b9 52 58 10 f0       	mov    $0xf0105852,%ecx
f0103311:	ba 46 58 10 f0       	mov    $0xf0105846,%edx
f0103316:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103319:	83 ec 04             	sub    $0x4,%esp
f010331c:	52                   	push   %edx
f010331d:	50                   	push   %eax
f010331e:	68 ae 58 10 f0       	push   $0xf01058ae
f0103323:	e8 d2 fb ff ff       	call   f0102efa <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103328:	83 c4 10             	add    $0x10,%esp
f010332b:	3b 1d a0 47 17 f0    	cmp    0xf01747a0,%ebx
f0103331:	75 1a                	jne    f010334d <print_trapframe+0x9a>
f0103333:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103337:	75 14                	jne    f010334d <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103339:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010333c:	83 ec 08             	sub    $0x8,%esp
f010333f:	50                   	push   %eax
f0103340:	68 c0 58 10 f0       	push   $0xf01058c0
f0103345:	e8 b0 fb ff ff       	call   f0102efa <cprintf>
f010334a:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010334d:	83 ec 08             	sub    $0x8,%esp
f0103350:	ff 73 2c             	pushl  0x2c(%ebx)
f0103353:	68 cf 58 10 f0       	push   $0xf01058cf
f0103358:	e8 9d fb ff ff       	call   f0102efa <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010335d:	83 c4 10             	add    $0x10,%esp
f0103360:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103364:	75 49                	jne    f01033af <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103366:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103369:	89 c2                	mov    %eax,%edx
f010336b:	83 e2 01             	and    $0x1,%edx
f010336e:	ba 6c 58 10 f0       	mov    $0xf010586c,%edx
f0103373:	b9 61 58 10 f0       	mov    $0xf0105861,%ecx
f0103378:	0f 44 ca             	cmove  %edx,%ecx
f010337b:	89 c2                	mov    %eax,%edx
f010337d:	83 e2 02             	and    $0x2,%edx
f0103380:	ba 7e 58 10 f0       	mov    $0xf010587e,%edx
f0103385:	be 78 58 10 f0       	mov    $0xf0105878,%esi
f010338a:	0f 45 d6             	cmovne %esi,%edx
f010338d:	83 e0 04             	and    $0x4,%eax
f0103390:	be b4 59 10 f0       	mov    $0xf01059b4,%esi
f0103395:	b8 83 58 10 f0       	mov    $0xf0105883,%eax
f010339a:	0f 44 c6             	cmove  %esi,%eax
f010339d:	51                   	push   %ecx
f010339e:	52                   	push   %edx
f010339f:	50                   	push   %eax
f01033a0:	68 dd 58 10 f0       	push   $0xf01058dd
f01033a5:	e8 50 fb ff ff       	call   f0102efa <cprintf>
f01033aa:	83 c4 10             	add    $0x10,%esp
f01033ad:	eb 10                	jmp    f01033bf <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01033af:	83 ec 0c             	sub    $0xc,%esp
f01033b2:	68 a0 56 10 f0       	push   $0xf01056a0
f01033b7:	e8 3e fb ff ff       	call   f0102efa <cprintf>
f01033bc:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01033bf:	83 ec 08             	sub    $0x8,%esp
f01033c2:	ff 73 30             	pushl  0x30(%ebx)
f01033c5:	68 ec 58 10 f0       	push   $0xf01058ec
f01033ca:	e8 2b fb ff ff       	call   f0102efa <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01033cf:	83 c4 08             	add    $0x8,%esp
f01033d2:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01033d6:	50                   	push   %eax
f01033d7:	68 fb 58 10 f0       	push   $0xf01058fb
f01033dc:	e8 19 fb ff ff       	call   f0102efa <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01033e1:	83 c4 08             	add    $0x8,%esp
f01033e4:	ff 73 38             	pushl  0x38(%ebx)
f01033e7:	68 0e 59 10 f0       	push   $0xf010590e
f01033ec:	e8 09 fb ff ff       	call   f0102efa <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01033f1:	83 c4 10             	add    $0x10,%esp
f01033f4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01033f8:	74 25                	je     f010341f <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01033fa:	83 ec 08             	sub    $0x8,%esp
f01033fd:	ff 73 3c             	pushl  0x3c(%ebx)
f0103400:	68 1d 59 10 f0       	push   $0xf010591d
f0103405:	e8 f0 fa ff ff       	call   f0102efa <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010340a:	83 c4 08             	add    $0x8,%esp
f010340d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103411:	50                   	push   %eax
f0103412:	68 2c 59 10 f0       	push   $0xf010592c
f0103417:	e8 de fa ff ff       	call   f0102efa <cprintf>
f010341c:	83 c4 10             	add    $0x10,%esp
	}
}
f010341f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103422:	5b                   	pop    %ebx
f0103423:	5e                   	pop    %esi
f0103424:	5d                   	pop    %ebp
f0103425:	c3                   	ret    

f0103426 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103426:	55                   	push   %ebp
f0103427:	89 e5                	mov    %esp,%ebp
f0103429:	53                   	push   %ebx
f010342a:	83 ec 04             	sub    $0x4,%esp
f010342d:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103430:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) {
f0103433:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103437:	75 15                	jne    f010344e <page_fault_handler+0x28>
		panic("kernel page fault at va:%x\n", fault_va);
f0103439:	50                   	push   %eax
f010343a:	68 3f 59 10 f0       	push   $0xf010593f
f010343f:	68 05 01 00 00       	push   $0x105
f0103444:	68 5b 59 10 f0       	push   $0xf010595b
f0103449:	e8 52 cc ff ff       	call   f01000a0 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010344e:	ff 73 30             	pushl  0x30(%ebx)
f0103451:	50                   	push   %eax
f0103452:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
f0103457:	ff 70 48             	pushl  0x48(%eax)
f010345a:	68 00 5b 10 f0       	push   $0xf0105b00
f010345f:	e8 96 fa ff ff       	call   f0102efa <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103464:	89 1c 24             	mov    %ebx,(%esp)
f0103467:	e8 47 fe ff ff       	call   f01032b3 <print_trapframe>
	env_destroy(curenv);
f010346c:	83 c4 04             	add    $0x4,%esp
f010346f:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f0103475:	e8 67 f9 ff ff       	call   f0102de1 <env_destroy>
}
f010347a:	83 c4 10             	add    $0x10,%esp
f010347d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103480:	c9                   	leave  
f0103481:	c3                   	ret    

f0103482 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103482:	55                   	push   %ebp
f0103483:	89 e5                	mov    %esp,%ebp
f0103485:	57                   	push   %edi
f0103486:	56                   	push   %esi
f0103487:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010348a:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010348b:	9c                   	pushf  
f010348c:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010348d:	f6 c4 02             	test   $0x2,%ah
f0103490:	74 19                	je     f01034ab <trap+0x29>
f0103492:	68 67 59 10 f0       	push   $0xf0105967
f0103497:	68 17 54 10 f0       	push   $0xf0105417
f010349c:	68 dc 00 00 00       	push   $0xdc
f01034a1:	68 5b 59 10 f0       	push   $0xf010595b
f01034a6:	e8 f5 cb ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01034ab:	83 ec 08             	sub    $0x8,%esp
f01034ae:	56                   	push   %esi
f01034af:	68 80 59 10 f0       	push   $0xf0105980
f01034b4:	e8 41 fa ff ff       	call   f0102efa <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01034b9:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01034bd:	83 e0 03             	and    $0x3,%eax
f01034c0:	83 c4 10             	add    $0x10,%esp
f01034c3:	66 83 f8 03          	cmp    $0x3,%ax
f01034c7:	75 31                	jne    f01034fa <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f01034c9:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
f01034ce:	85 c0                	test   %eax,%eax
f01034d0:	75 19                	jne    f01034eb <trap+0x69>
f01034d2:	68 9b 59 10 f0       	push   $0xf010599b
f01034d7:	68 17 54 10 f0       	push   $0xf0105417
f01034dc:	68 e2 00 00 00       	push   $0xe2
f01034e1:	68 5b 59 10 f0       	push   $0xf010595b
f01034e6:	e8 b5 cb ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01034eb:	b9 11 00 00 00       	mov    $0x11,%ecx
f01034f0:	89 c7                	mov    %eax,%edi
f01034f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01034f4:	8b 35 88 3f 17 f0    	mov    0xf0173f88,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01034fa:	89 35 a0 47 17 f0    	mov    %esi,0xf01747a0
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f0103500:	8b 46 28             	mov    0x28(%esi),%eax
f0103503:	83 f8 0e             	cmp    $0xe,%eax
f0103506:	75 0e                	jne    f0103516 <trap+0x94>
		return page_fault_handler(tf);
f0103508:	83 ec 0c             	sub    $0xc,%esp
f010350b:	56                   	push   %esi
f010350c:	e8 15 ff ff ff       	call   f0103426 <page_fault_handler>
f0103511:	83 c4 10             	add    $0x10,%esp
f0103514:	eb 74                	jmp    f010358a <trap+0x108>
	}

	if (tf->tf_trapno == T_BRKPT) {
f0103516:	83 f8 03             	cmp    $0x3,%eax
f0103519:	75 0e                	jne    f0103529 <trap+0xa7>
		return monitor(tf);
f010351b:	83 ec 0c             	sub    $0xc,%esp
f010351e:	56                   	push   %esi
f010351f:	e8 88 d2 ff ff       	call   f01007ac <monitor>
f0103524:	83 c4 10             	add    $0x10,%esp
f0103527:	eb 61                	jmp    f010358a <trap+0x108>
	}

	if (tf->tf_trapno == T_SYSCALL) {
f0103529:	83 f8 30             	cmp    $0x30,%eax
f010352c:	75 21                	jne    f010354f <trap+0xcd>
		tf->tf_regs.reg_eax = syscall(
f010352e:	83 ec 08             	sub    $0x8,%esp
f0103531:	ff 76 04             	pushl  0x4(%esi)
f0103534:	ff 36                	pushl  (%esi)
f0103536:	ff 76 10             	pushl  0x10(%esi)
f0103539:	ff 76 18             	pushl  0x18(%esi)
f010353c:	ff 76 14             	pushl  0x14(%esi)
f010353f:	ff 76 1c             	pushl  0x1c(%esi)
f0103542:	e8 da 00 00 00       	call   f0103621 <syscall>
f0103547:	89 46 1c             	mov    %eax,0x1c(%esi)
f010354a:	83 c4 20             	add    $0x20,%esp
f010354d:	eb 3b                	jmp    f010358a <trap+0x108>
		);
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010354f:	83 ec 0c             	sub    $0xc,%esp
f0103552:	56                   	push   %esi
f0103553:	e8 5b fd ff ff       	call   f01032b3 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103558:	83 c4 10             	add    $0x10,%esp
f010355b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103560:	75 17                	jne    f0103579 <trap+0xf7>
		panic("unhandled trap in kernel");
f0103562:	83 ec 04             	sub    $0x4,%esp
f0103565:	68 a2 59 10 f0       	push   $0xf01059a2
f010356a:	68 cb 00 00 00       	push   $0xcb
f010356f:	68 5b 59 10 f0       	push   $0xf010595b
f0103574:	e8 27 cb ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f0103579:	83 ec 0c             	sub    $0xc,%esp
f010357c:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f0103582:	e8 5a f8 ff ff       	call   f0102de1 <env_destroy>
f0103587:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010358a:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
f010358f:	85 c0                	test   %eax,%eax
f0103591:	74 06                	je     f0103599 <trap+0x117>
f0103593:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103597:	74 19                	je     f01035b2 <trap+0x130>
f0103599:	68 24 5b 10 f0       	push   $0xf0105b24
f010359e:	68 17 54 10 f0       	push   $0xf0105417
f01035a3:	68 f4 00 00 00       	push   $0xf4
f01035a8:	68 5b 59 10 f0       	push   $0xf010595b
f01035ad:	e8 ee ca ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f01035b2:	83 ec 0c             	sub    $0xc,%esp
f01035b5:	50                   	push   %eax
f01035b6:	e8 76 f8 ff ff       	call   f0102e31 <env_run>
f01035bb:	90                   	nop

f01035bc <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f01035bc:	6a 00                	push   $0x0
f01035be:	6a 00                	push   $0x0
f01035c0:	eb 4e                	jmp    f0103610 <_alltraps>

f01035c2 <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f01035c2:	6a 00                	push   $0x0
f01035c4:	6a 01                	push   $0x1
f01035c6:	eb 48                	jmp    f0103610 <_alltraps>

f01035c8 <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f01035c8:	6a 00                	push   $0x0
f01035ca:	6a 02                	push   $0x2
f01035cc:	eb 42                	jmp    f0103610 <_alltraps>

f01035ce <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f01035ce:	6a 00                	push   $0x0
f01035d0:	6a 03                	push   $0x3
f01035d2:	eb 3c                	jmp    f0103610 <_alltraps>

f01035d4 <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f01035d4:	6a 00                	push   $0x0
f01035d6:	6a 04                	push   $0x4
f01035d8:	eb 36                	jmp    f0103610 <_alltraps>

f01035da <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f01035da:	6a 00                	push   $0x0
f01035dc:	6a 05                	push   $0x5
f01035de:	eb 30                	jmp    f0103610 <_alltraps>

f01035e0 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f01035e0:	6a 00                	push   $0x0
f01035e2:	6a 06                	push   $0x6
f01035e4:	eb 2a                	jmp    f0103610 <_alltraps>

f01035e6 <handler7>:
TRAPHANDLER(handler7, T_DEVICE)
f01035e6:	6a 07                	push   $0x7
f01035e8:	eb 26                	jmp    f0103610 <_alltraps>

f01035ea <handler8>:
TRAPHANDLER_NOEC(handler8, T_DBLFLT)
f01035ea:	6a 00                	push   $0x0
f01035ec:	6a 08                	push   $0x8
f01035ee:	eb 20                	jmp    f0103610 <_alltraps>

f01035f0 <handler10>:
TRAPHANDLER(handler10, T_TSS)
f01035f0:	6a 0a                	push   $0xa
f01035f2:	eb 1c                	jmp    f0103610 <_alltraps>

f01035f4 <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f01035f4:	6a 0b                	push   $0xb
f01035f6:	eb 18                	jmp    f0103610 <_alltraps>

f01035f8 <handler12>:
TRAPHANDLER(handler12, T_STACK)
f01035f8:	6a 0c                	push   $0xc
f01035fa:	eb 14                	jmp    f0103610 <_alltraps>

f01035fc <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f01035fc:	6a 0d                	push   $0xd
f01035fe:	eb 10                	jmp    f0103610 <_alltraps>

f0103600 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0103600:	6a 0e                	push   $0xe
f0103602:	eb 0c                	jmp    f0103610 <_alltraps>

f0103604 <handler16>:
TRAPHANDLER_NOEC(handler16, T_FPERR)
f0103604:	6a 00                	push   $0x0
f0103606:	6a 10                	push   $0x10
f0103608:	eb 06                	jmp    f0103610 <_alltraps>

f010360a <handler48>:
TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f010360a:	6a 00                	push   $0x0
f010360c:	6a 30                	push   $0x30
f010360e:	eb 00                	jmp    f0103610 <_alltraps>

f0103610 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0103610:	1e                   	push   %ds
	pushl %es
f0103611:	06                   	push   %es
	pushal
f0103612:	60                   	pusha  
	movw $GD_KD, %ax
f0103613:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0103617:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103619:	8e c0                	mov    %eax,%es
	pushl %esp
f010361b:	54                   	push   %esp
f010361c:	e8 61 fe ff ff       	call   f0103482 <trap>

f0103621 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103621:	55                   	push   %ebp
f0103622:	89 e5                	mov    %esp,%ebp
f0103624:	83 ec 18             	sub    $0x18,%esp
f0103627:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) 
f010362a:	83 f8 01             	cmp    $0x1,%eax
f010362d:	74 44                	je     f0103673 <syscall+0x52>
f010362f:	83 f8 01             	cmp    $0x1,%eax
f0103632:	72 0f                	jb     f0103643 <syscall+0x22>
f0103634:	83 f8 02             	cmp    $0x2,%eax
f0103637:	74 41                	je     f010367a <syscall+0x59>
f0103639:	83 f8 03             	cmp    $0x3,%eax
f010363c:	74 46                	je     f0103684 <syscall+0x63>
f010363e:	e9 a6 00 00 00       	jmp    f01036e9 <syscall+0xc8>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv,s,len,0);
f0103643:	6a 00                	push   $0x0
f0103645:	ff 75 10             	pushl  0x10(%ebp)
f0103648:	ff 75 0c             	pushl  0xc(%ebp)
f010364b:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f0103651:	e8 72 f1 ff ff       	call   f01027c8 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103656:	83 c4 0c             	add    $0xc,%esp
f0103659:	ff 75 0c             	pushl  0xc(%ebp)
f010365c:	ff 75 10             	pushl  0x10(%ebp)
f010365f:	68 b0 5b 10 f0       	push   $0xf0105bb0
f0103664:	e8 91 f8 ff ff       	call   f0102efa <cprintf>
f0103669:	83 c4 10             	add    $0x10,%esp

	switch (syscallno) 
	{
	case SYS_cputs:
		sys_cputs((char *)a1,a2);
	        return 0;
f010366c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103671:	eb 7b                	jmp    f01036ee <syscall+0xcd>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103673:	e8 3d ce ff ff       	call   f01004b5 <cons_getc>
	{
	case SYS_cputs:
		sys_cputs((char *)a1,a2);
	        return 0;
        case SYS_cgetc:
	        return sys_cgetc();
f0103678:	eb 74                	jmp    f01036ee <syscall+0xcd>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010367a:	a1 88 3f 17 f0       	mov    0xf0173f88,%eax
f010367f:	8b 40 48             	mov    0x48(%eax),%eax
		sys_cputs((char *)a1,a2);
	        return 0;
        case SYS_cgetc:
	        return sys_cgetc();
        case SYS_getenvid:
	        return sys_getenvid();
f0103682:	eb 6a                	jmp    f01036ee <syscall+0xcd>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103684:	83 ec 04             	sub    $0x4,%esp
f0103687:	6a 01                	push   $0x1
f0103689:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010368c:	50                   	push   %eax
f010368d:	ff 75 0c             	pushl  0xc(%ebp)
f0103690:	e8 e8 f1 ff ff       	call   f010287d <envid2env>
f0103695:	83 c4 10             	add    $0x10,%esp
f0103698:	85 c0                	test   %eax,%eax
f010369a:	78 52                	js     f01036ee <syscall+0xcd>
		return r;
	if (e == curenv)
f010369c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010369f:	8b 15 88 3f 17 f0    	mov    0xf0173f88,%edx
f01036a5:	39 d0                	cmp    %edx,%eax
f01036a7:	75 15                	jne    f01036be <syscall+0x9d>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01036a9:	83 ec 08             	sub    $0x8,%esp
f01036ac:	ff 70 48             	pushl  0x48(%eax)
f01036af:	68 b5 5b 10 f0       	push   $0xf0105bb5
f01036b4:	e8 41 f8 ff ff       	call   f0102efa <cprintf>
f01036b9:	83 c4 10             	add    $0x10,%esp
f01036bc:	eb 16                	jmp    f01036d4 <syscall+0xb3>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01036be:	83 ec 04             	sub    $0x4,%esp
f01036c1:	ff 70 48             	pushl  0x48(%eax)
f01036c4:	ff 72 48             	pushl  0x48(%edx)
f01036c7:	68 d0 5b 10 f0       	push   $0xf0105bd0
f01036cc:	e8 29 f8 ff ff       	call   f0102efa <cprintf>
f01036d1:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01036d4:	83 ec 0c             	sub    $0xc,%esp
f01036d7:	ff 75 f4             	pushl  -0xc(%ebp)
f01036da:	e8 02 f7 ff ff       	call   f0102de1 <env_destroy>
f01036df:	83 c4 10             	add    $0x10,%esp
	return 0;
f01036e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01036e7:	eb 05                	jmp    f01036ee <syscall+0xcd>
        case SYS_getenvid:
	        return sys_getenvid();
        case SYS_env_destroy:
	        return sys_env_destroy(a1);
	default:
		return -E_INVAL;
f01036e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01036ee:	c9                   	leave  
f01036ef:	c3                   	ret    

f01036f0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01036f0:	55                   	push   %ebp
f01036f1:	89 e5                	mov    %esp,%ebp
f01036f3:	57                   	push   %edi
f01036f4:	56                   	push   %esi
f01036f5:	53                   	push   %ebx
f01036f6:	83 ec 14             	sub    $0x14,%esp
f01036f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01036fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01036ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103702:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103705:	8b 1a                	mov    (%edx),%ebx
f0103707:	8b 01                	mov    (%ecx),%eax
f0103709:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010370c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103713:	eb 7f                	jmp    f0103794 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103715:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103718:	01 d8                	add    %ebx,%eax
f010371a:	89 c6                	mov    %eax,%esi
f010371c:	c1 ee 1f             	shr    $0x1f,%esi
f010371f:	01 c6                	add    %eax,%esi
f0103721:	d1 fe                	sar    %esi
f0103723:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103726:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103729:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010372c:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010372e:	eb 03                	jmp    f0103733 <stab_binsearch+0x43>
			m--;
f0103730:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103733:	39 c3                	cmp    %eax,%ebx
f0103735:	7f 0d                	jg     f0103744 <stab_binsearch+0x54>
f0103737:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010373b:	83 ea 0c             	sub    $0xc,%edx
f010373e:	39 f9                	cmp    %edi,%ecx
f0103740:	75 ee                	jne    f0103730 <stab_binsearch+0x40>
f0103742:	eb 05                	jmp    f0103749 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103744:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103747:	eb 4b                	jmp    f0103794 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103749:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010374c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010374f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103753:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103756:	76 11                	jbe    f0103769 <stab_binsearch+0x79>
			*region_left = m;
f0103758:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010375b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010375d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103760:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103767:	eb 2b                	jmp    f0103794 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103769:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010376c:	73 14                	jae    f0103782 <stab_binsearch+0x92>
			*region_right = m - 1;
f010376e:	83 e8 01             	sub    $0x1,%eax
f0103771:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103774:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103777:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103779:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103780:	eb 12                	jmp    f0103794 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103782:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103785:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103787:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010378b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010378d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103794:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103797:	0f 8e 78 ff ff ff    	jle    f0103715 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010379d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01037a1:	75 0f                	jne    f01037b2 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01037a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01037a6:	8b 00                	mov    (%eax),%eax
f01037a8:	83 e8 01             	sub    $0x1,%eax
f01037ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01037ae:	89 06                	mov    %eax,(%esi)
f01037b0:	eb 2c                	jmp    f01037de <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037b5:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01037b7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01037ba:	8b 0e                	mov    (%esi),%ecx
f01037bc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01037bf:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01037c2:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037c5:	eb 03                	jmp    f01037ca <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01037c7:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037ca:	39 c8                	cmp    %ecx,%eax
f01037cc:	7e 0b                	jle    f01037d9 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01037ce:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01037d2:	83 ea 0c             	sub    $0xc,%edx
f01037d5:	39 df                	cmp    %ebx,%edi
f01037d7:	75 ee                	jne    f01037c7 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01037d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01037dc:	89 06                	mov    %eax,(%esi)
	}
}
f01037de:	83 c4 14             	add    $0x14,%esp
f01037e1:	5b                   	pop    %ebx
f01037e2:	5e                   	pop    %esi
f01037e3:	5f                   	pop    %edi
f01037e4:	5d                   	pop    %ebp
f01037e5:	c3                   	ret    

f01037e6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01037e6:	55                   	push   %ebp
f01037e7:	89 e5                	mov    %esp,%ebp
f01037e9:	57                   	push   %edi
f01037ea:	56                   	push   %esi
f01037eb:	53                   	push   %ebx
f01037ec:	83 ec 3c             	sub    $0x3c,%esp
f01037ef:	8b 75 08             	mov    0x8(%ebp),%esi
f01037f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file="<unknown>";
f01037f5:	c7 03 e8 5b 10 f0    	movl   $0xf0105be8,(%ebx)
	info->eip_line = 0;
f01037fb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103802:	c7 43 08 e8 5b 10 f0 	movl   $0xf0105be8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103809:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103810:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103813:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010381a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103820:	0f 87 8a 00 00 00    	ja     f01038b0 <debuginfo_eip+0xca>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0103826:	6a 04                	push   $0x4
f0103828:	6a 10                	push   $0x10
f010382a:	68 00 00 20 00       	push   $0x200000
f010382f:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f0103835:	e8 fd ee ff ff       	call   f0102737 <user_mem_check>
f010383a:	83 c4 10             	add    $0x10,%esp
f010383d:	85 c0                	test   %eax,%eax
f010383f:	0f 85 45 02 00 00    	jne    f0103a8a <debuginfo_eip+0x2a4>
			return -1;

		stabs = usd->stabs;
f0103845:	a1 00 00 20 00       	mov    0x200000,%eax
f010384a:	89 c1                	mov    %eax,%ecx
f010384c:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f010384f:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0103855:	a1 08 00 20 00       	mov    0x200008,%eax
f010385a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010385d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103863:	89 55 b8             	mov    %edx,-0x48(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
f0103866:	6a 04                	push   $0x4
f0103868:	89 f8                	mov    %edi,%eax
f010386a:	29 c8                	sub    %ecx,%eax
f010386c:	c1 f8 02             	sar    $0x2,%eax
f010386f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103875:	50                   	push   %eax
f0103876:	51                   	push   %ecx
f0103877:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f010387d:	e8 b5 ee ff ff       	call   f0102737 <user_mem_check>
f0103882:	83 c4 10             	add    $0x10,%esp
f0103885:	85 c0                	test   %eax,%eax
f0103887:	0f 85 04 02 00 00    	jne    f0103a91 <debuginfo_eip+0x2ab>
			return -1;
		
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f010388d:	6a 04                	push   $0x4
f010388f:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0103892:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103895:	29 ca                	sub    %ecx,%edx
f0103897:	52                   	push   %edx
f0103898:	51                   	push   %ecx
f0103899:	ff 35 88 3f 17 f0    	pushl  0xf0173f88
f010389f:	e8 93 ee ff ff       	call   f0102737 <user_mem_check>
f01038a4:	83 c4 10             	add    $0x10,%esp
f01038a7:	85 c0                	test   %eax,%eax
f01038a9:	74 1f                	je     f01038ca <debuginfo_eip+0xe4>
f01038ab:	e9 e8 01 00 00       	jmp    f0103a98 <debuginfo_eip+0x2b2>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01038b0:	c7 45 b8 f3 ff 10 f0 	movl   $0xf010fff3,-0x48(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01038b7:	c7 45 bc 81 d5 10 f0 	movl   $0xf010d581,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01038be:	bf 80 d5 10 f0       	mov    $0xf010d580,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01038c3:	c7 45 c0 10 5e 10 f0 	movl   $0xf0105e10,-0x40(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01038ca:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01038cd:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01038d0:	0f 83 c9 01 00 00    	jae    f0103a9f <debuginfo_eip+0x2b9>
f01038d6:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01038da:	0f 85 c6 01 00 00    	jne    f0103aa6 <debuginfo_eip+0x2c0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01038e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01038e7:	2b 7d c0             	sub    -0x40(%ebp),%edi
f01038ea:	c1 ff 02             	sar    $0x2,%edi
f01038ed:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01038f3:	83 e8 01             	sub    $0x1,%eax
f01038f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01038f9:	83 ec 08             	sub    $0x8,%esp
f01038fc:	56                   	push   %esi
f01038fd:	6a 64                	push   $0x64
f01038ff:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103902:	89 d1                	mov    %edx,%ecx
f0103904:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103907:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010390a:	89 f8                	mov    %edi,%eax
f010390c:	e8 df fd ff ff       	call   f01036f0 <stab_binsearch>
	if (lfile == 0)
f0103911:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103914:	83 c4 10             	add    $0x10,%esp
f0103917:	85 c0                	test   %eax,%eax
f0103919:	0f 84 8e 01 00 00    	je     f0103aad <debuginfo_eip+0x2c7>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010391f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103922:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103925:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103928:	83 ec 08             	sub    $0x8,%esp
f010392b:	56                   	push   %esi
f010392c:	6a 24                	push   $0x24
f010392e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103931:	89 d1                	mov    %edx,%ecx
f0103933:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103936:	89 f8                	mov    %edi,%eax
f0103938:	e8 b3 fd ff ff       	call   f01036f0 <stab_binsearch>

	if (lfun <= rfun) {
f010393d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103940:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103943:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103946:	83 c4 10             	add    $0x10,%esp
f0103949:	39 d0                	cmp    %edx,%eax
f010394b:	7f 2b                	jg     f0103978 <debuginfo_eip+0x192>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010394d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103950:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103953:	8b 11                	mov    (%ecx),%edx
f0103955:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103958:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010395b:	39 fa                	cmp    %edi,%edx
f010395d:	73 06                	jae    f0103965 <debuginfo_eip+0x17f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010395f:	03 55 bc             	add    -0x44(%ebp),%edx
f0103962:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103965:	8b 51 08             	mov    0x8(%ecx),%edx
f0103968:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010396b:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010396d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103970:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103973:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103976:	eb 0f                	jmp    f0103987 <debuginfo_eip+0x1a1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103978:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010397b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010397e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103981:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103984:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103987:	83 ec 08             	sub    $0x8,%esp
f010398a:	6a 3a                	push   $0x3a
f010398c:	ff 73 08             	pushl  0x8(%ebx)
f010398f:	e8 a7 08 00 00       	call   f010423b <strfind>
f0103994:	2b 43 08             	sub    0x8(%ebx),%eax
f0103997:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
f010399a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010399d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01039a0:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01039a3:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01039a6:	03 0c 87             	add    (%edi,%eax,4),%ecx
f01039a9:	89 0b                	mov    %ecx,(%ebx)
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f01039ab:	83 c4 08             	add    $0x8,%esp
f01039ae:	56                   	push   %esi
f01039af:	6a 44                	push   $0x44
f01039b1:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01039b4:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01039b7:	89 fe                	mov    %edi,%esi
f01039b9:	89 f8                	mov    %edi,%eax
f01039bb:	e8 30 fd ff ff       	call   f01036f0 <stab_binsearch>
	if(lline>rline){
f01039c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039c6:	83 c4 10             	add    $0x10,%esp
f01039c9:	39 c2                	cmp    %eax,%edx
f01039cb:	0f 8f e3 00 00 00    	jg     f0103ab4 <debuginfo_eip+0x2ce>
	return -1;
	}
	else{
	info->eip_line=stabs[rline].n_desc;
f01039d1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01039d4:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01039d9:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01039dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01039df:	89 d0                	mov    %edx,%eax
f01039e1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01039e4:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01039e7:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01039eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01039ee:	eb 0a                	jmp    f01039fa <debuginfo_eip+0x214>
f01039f0:	83 e8 01             	sub    $0x1,%eax
f01039f3:	83 ea 0c             	sub    $0xc,%edx
f01039f6:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01039fa:	39 c7                	cmp    %eax,%edi
f01039fc:	7e 05                	jle    f0103a03 <debuginfo_eip+0x21d>
f01039fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a01:	eb 47                	jmp    f0103a4a <debuginfo_eip+0x264>
	       && stabs[lline].n_type != N_SOL
f0103a03:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103a07:	80 f9 84             	cmp    $0x84,%cl
f0103a0a:	75 0e                	jne    f0103a1a <debuginfo_eip+0x234>
f0103a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a0f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103a13:	74 1c                	je     f0103a31 <debuginfo_eip+0x24b>
f0103a15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a18:	eb 17                	jmp    f0103a31 <debuginfo_eip+0x24b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103a1a:	80 f9 64             	cmp    $0x64,%cl
f0103a1d:	75 d1                	jne    f01039f0 <debuginfo_eip+0x20a>
f0103a1f:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103a23:	74 cb                	je     f01039f0 <debuginfo_eip+0x20a>
f0103a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a28:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103a2c:	74 03                	je     f0103a31 <debuginfo_eip+0x24b>
f0103a2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103a31:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103a34:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103a37:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103a3a:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103a3d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103a40:	29 f8                	sub    %edi,%eax
f0103a42:	39 c2                	cmp    %eax,%edx
f0103a44:	73 04                	jae    f0103a4a <debuginfo_eip+0x264>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103a46:	01 fa                	add    %edi,%edx
f0103a48:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103a4a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a4d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a50:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103a55:	39 f2                	cmp    %esi,%edx
f0103a57:	7d 67                	jge    f0103ac0 <debuginfo_eip+0x2da>
		for (lline = lfun + 1;
f0103a59:	83 c2 01             	add    $0x1,%edx
f0103a5c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103a5f:	89 d0                	mov    %edx,%eax
f0103a61:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103a64:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103a67:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103a6a:	eb 04                	jmp    f0103a70 <debuginfo_eip+0x28a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103a6c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103a70:	39 c6                	cmp    %eax,%esi
f0103a72:	7e 47                	jle    f0103abb <debuginfo_eip+0x2d5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103a74:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103a78:	83 c0 01             	add    $0x1,%eax
f0103a7b:	83 c2 0c             	add    $0xc,%edx
f0103a7e:	80 f9 a0             	cmp    $0xa0,%cl
f0103a81:	74 e9                	je     f0103a6c <debuginfo_eip+0x286>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a83:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a88:	eb 36                	jmp    f0103ac0 <debuginfo_eip+0x2da>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0103a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a8f:	eb 2f                	jmp    f0103ac0 <debuginfo_eip+0x2da>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
			return -1;
f0103a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a96:	eb 28                	jmp    f0103ac0 <debuginfo_eip+0x2da>
		
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f0103a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a9d:	eb 21                	jmp    f0103ac0 <debuginfo_eip+0x2da>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103aa4:	eb 1a                	jmp    f0103ac0 <debuginfo_eip+0x2da>
f0103aa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103aab:	eb 13                	jmp    f0103ac0 <debuginfo_eip+0x2da>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ab2:	eb 0c                	jmp    f0103ac0 <debuginfo_eip+0x2da>
	//	which one.
	// Your code here.
	info->eip_file=stabstr+stabs[lfile].n_strx;
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
	if(lline>rline){
	return -1;
f0103ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ab9:	eb 05                	jmp    f0103ac0 <debuginfo_eip+0x2da>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103abb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ac3:	5b                   	pop    %ebx
f0103ac4:	5e                   	pop    %esi
f0103ac5:	5f                   	pop    %edi
f0103ac6:	5d                   	pop    %ebp
f0103ac7:	c3                   	ret    

f0103ac8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103ac8:	55                   	push   %ebp
f0103ac9:	89 e5                	mov    %esp,%ebp
f0103acb:	57                   	push   %edi
f0103acc:	56                   	push   %esi
f0103acd:	53                   	push   %ebx
f0103ace:	83 ec 1c             	sub    $0x1c,%esp
f0103ad1:	89 c7                	mov    %eax,%edi
f0103ad3:	89 d6                	mov    %edx,%esi
f0103ad5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103adb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ade:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103ae1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ae4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103ae9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103aec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103aef:	39 d3                	cmp    %edx,%ebx
f0103af1:	72 05                	jb     f0103af8 <printnum+0x30>
f0103af3:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103af6:	77 45                	ja     f0103b3d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103af8:	83 ec 0c             	sub    $0xc,%esp
f0103afb:	ff 75 18             	pushl  0x18(%ebp)
f0103afe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b01:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103b04:	53                   	push   %ebx
f0103b05:	ff 75 10             	pushl  0x10(%ebp)
f0103b08:	83 ec 08             	sub    $0x8,%esp
f0103b0b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b0e:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b11:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b14:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b17:	e8 44 09 00 00       	call   f0104460 <__udivdi3>
f0103b1c:	83 c4 18             	add    $0x18,%esp
f0103b1f:	52                   	push   %edx
f0103b20:	50                   	push   %eax
f0103b21:	89 f2                	mov    %esi,%edx
f0103b23:	89 f8                	mov    %edi,%eax
f0103b25:	e8 9e ff ff ff       	call   f0103ac8 <printnum>
f0103b2a:	83 c4 20             	add    $0x20,%esp
f0103b2d:	eb 18                	jmp    f0103b47 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103b2f:	83 ec 08             	sub    $0x8,%esp
f0103b32:	56                   	push   %esi
f0103b33:	ff 75 18             	pushl  0x18(%ebp)
f0103b36:	ff d7                	call   *%edi
f0103b38:	83 c4 10             	add    $0x10,%esp
f0103b3b:	eb 03                	jmp    f0103b40 <printnum+0x78>
f0103b3d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b40:	83 eb 01             	sub    $0x1,%ebx
f0103b43:	85 db                	test   %ebx,%ebx
f0103b45:	7f e8                	jg     f0103b2f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103b47:	83 ec 08             	sub    $0x8,%esp
f0103b4a:	56                   	push   %esi
f0103b4b:	83 ec 04             	sub    $0x4,%esp
f0103b4e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b51:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b54:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b57:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b5a:	e8 31 0a 00 00       	call   f0104590 <__umoddi3>
f0103b5f:	83 c4 14             	add    $0x14,%esp
f0103b62:	0f be 80 f2 5b 10 f0 	movsbl -0xfefa40e(%eax),%eax
f0103b69:	50                   	push   %eax
f0103b6a:	ff d7                	call   *%edi
}
f0103b6c:	83 c4 10             	add    $0x10,%esp
f0103b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b72:	5b                   	pop    %ebx
f0103b73:	5e                   	pop    %esi
f0103b74:	5f                   	pop    %edi
f0103b75:	5d                   	pop    %ebp
f0103b76:	c3                   	ret    

f0103b77 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103b77:	55                   	push   %ebp
f0103b78:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103b7a:	83 fa 01             	cmp    $0x1,%edx
f0103b7d:	7e 0e                	jle    f0103b8d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103b7f:	8b 10                	mov    (%eax),%edx
f0103b81:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103b84:	89 08                	mov    %ecx,(%eax)
f0103b86:	8b 02                	mov    (%edx),%eax
f0103b88:	8b 52 04             	mov    0x4(%edx),%edx
f0103b8b:	eb 22                	jmp    f0103baf <getuint+0x38>
	else if (lflag)
f0103b8d:	85 d2                	test   %edx,%edx
f0103b8f:	74 10                	je     f0103ba1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103b91:	8b 10                	mov    (%eax),%edx
f0103b93:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103b96:	89 08                	mov    %ecx,(%eax)
f0103b98:	8b 02                	mov    (%edx),%eax
f0103b9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b9f:	eb 0e                	jmp    f0103baf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103ba1:	8b 10                	mov    (%eax),%edx
f0103ba3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103ba6:	89 08                	mov    %ecx,(%eax)
f0103ba8:	8b 02                	mov    (%edx),%eax
f0103baa:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103baf:	5d                   	pop    %ebp
f0103bb0:	c3                   	ret    

f0103bb1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103bb1:	55                   	push   %ebp
f0103bb2:	89 e5                	mov    %esp,%ebp
f0103bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103bb7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103bbb:	8b 10                	mov    (%eax),%edx
f0103bbd:	3b 50 04             	cmp    0x4(%eax),%edx
f0103bc0:	73 0a                	jae    f0103bcc <sprintputch+0x1b>
		*b->buf++ = ch;
f0103bc2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103bc5:	89 08                	mov    %ecx,(%eax)
f0103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bca:	88 02                	mov    %al,(%edx)
}
f0103bcc:	5d                   	pop    %ebp
f0103bcd:	c3                   	ret    

f0103bce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103bce:	55                   	push   %ebp
f0103bcf:	89 e5                	mov    %esp,%ebp
f0103bd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103bd4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103bd7:	50                   	push   %eax
f0103bd8:	ff 75 10             	pushl  0x10(%ebp)
f0103bdb:	ff 75 0c             	pushl  0xc(%ebp)
f0103bde:	ff 75 08             	pushl  0x8(%ebp)
f0103be1:	e8 05 00 00 00       	call   f0103beb <vprintfmt>
	va_end(ap);
}
f0103be6:	83 c4 10             	add    $0x10,%esp
f0103be9:	c9                   	leave  
f0103bea:	c3                   	ret    

f0103beb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103beb:	55                   	push   %ebp
f0103bec:	89 e5                	mov    %esp,%ebp
f0103bee:	57                   	push   %edi
f0103bef:	56                   	push   %esi
f0103bf0:	53                   	push   %ebx
f0103bf1:	83 ec 2c             	sub    $0x2c,%esp
f0103bf4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bfa:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103bfd:	eb 12                	jmp    f0103c11 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103bff:	85 c0                	test   %eax,%eax
f0103c01:	0f 84 89 03 00 00    	je     f0103f90 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0103c07:	83 ec 08             	sub    $0x8,%esp
f0103c0a:	53                   	push   %ebx
f0103c0b:	50                   	push   %eax
f0103c0c:	ff d6                	call   *%esi
f0103c0e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103c11:	83 c7 01             	add    $0x1,%edi
f0103c14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103c18:	83 f8 25             	cmp    $0x25,%eax
f0103c1b:	75 e2                	jne    f0103bff <vprintfmt+0x14>
f0103c1d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103c21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103c28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103c2f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103c36:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c3b:	eb 07                	jmp    f0103c44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103c40:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c44:	8d 47 01             	lea    0x1(%edi),%eax
f0103c47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103c4a:	0f b6 07             	movzbl (%edi),%eax
f0103c4d:	0f b6 c8             	movzbl %al,%ecx
f0103c50:	83 e8 23             	sub    $0x23,%eax
f0103c53:	3c 55                	cmp    $0x55,%al
f0103c55:	0f 87 1a 03 00 00    	ja     f0103f75 <vprintfmt+0x38a>
f0103c5b:	0f b6 c0             	movzbl %al,%eax
f0103c5e:	ff 24 85 80 5c 10 f0 	jmp    *-0xfefa380(,%eax,4)
f0103c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103c68:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103c6c:	eb d6                	jmp    f0103c44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c71:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103c79:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103c7c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103c80:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103c83:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103c86:	83 fa 09             	cmp    $0x9,%edx
f0103c89:	77 39                	ja     f0103cc4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103c8b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103c8e:	eb e9                	jmp    f0103c79 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103c90:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c93:	8d 48 04             	lea    0x4(%eax),%ecx
f0103c96:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103c99:	8b 00                	mov    (%eax),%eax
f0103c9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103ca1:	eb 27                	jmp    f0103cca <vprintfmt+0xdf>
f0103ca3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ca6:	85 c0                	test   %eax,%eax
f0103ca8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103cad:	0f 49 c8             	cmovns %eax,%ecx
f0103cb0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103cb6:	eb 8c                	jmp    f0103c44 <vprintfmt+0x59>
f0103cb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103cbb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103cc2:	eb 80                	jmp    f0103c44 <vprintfmt+0x59>
f0103cc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103cc7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103cca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103cce:	0f 89 70 ff ff ff    	jns    f0103c44 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103cd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103cd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103cda:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103ce1:	e9 5e ff ff ff       	jmp    f0103c44 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ce6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ce9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103cec:	e9 53 ff ff ff       	jmp    f0103c44 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103cf1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cf4:	8d 50 04             	lea    0x4(%eax),%edx
f0103cf7:	89 55 14             	mov    %edx,0x14(%ebp)
f0103cfa:	83 ec 08             	sub    $0x8,%esp
f0103cfd:	53                   	push   %ebx
f0103cfe:	ff 30                	pushl  (%eax)
f0103d00:	ff d6                	call   *%esi
			break;
f0103d02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103d08:	e9 04 ff ff ff       	jmp    f0103c11 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d10:	8d 50 04             	lea    0x4(%eax),%edx
f0103d13:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d16:	8b 00                	mov    (%eax),%eax
f0103d18:	99                   	cltd   
f0103d19:	31 d0                	xor    %edx,%eax
f0103d1b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103d1d:	83 f8 07             	cmp    $0x7,%eax
f0103d20:	7f 0b                	jg     f0103d2d <vprintfmt+0x142>
f0103d22:	8b 14 85 e0 5d 10 f0 	mov    -0xfefa220(,%eax,4),%edx
f0103d29:	85 d2                	test   %edx,%edx
f0103d2b:	75 18                	jne    f0103d45 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0103d2d:	50                   	push   %eax
f0103d2e:	68 0a 5c 10 f0       	push   $0xf0105c0a
f0103d33:	53                   	push   %ebx
f0103d34:	56                   	push   %esi
f0103d35:	e8 94 fe ff ff       	call   f0103bce <printfmt>
f0103d3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103d40:	e9 cc fe ff ff       	jmp    f0103c11 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103d45:	52                   	push   %edx
f0103d46:	68 29 54 10 f0       	push   $0xf0105429
f0103d4b:	53                   	push   %ebx
f0103d4c:	56                   	push   %esi
f0103d4d:	e8 7c fe ff ff       	call   f0103bce <printfmt>
f0103d52:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d58:	e9 b4 fe ff ff       	jmp    f0103c11 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103d5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d60:	8d 50 04             	lea    0x4(%eax),%edx
f0103d63:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d66:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103d68:	85 ff                	test   %edi,%edi
f0103d6a:	b8 03 5c 10 f0       	mov    $0xf0105c03,%eax
f0103d6f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103d72:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103d76:	0f 8e 94 00 00 00    	jle    f0103e10 <vprintfmt+0x225>
f0103d7c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103d80:	0f 84 98 00 00 00    	je     f0103e1e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d86:	83 ec 08             	sub    $0x8,%esp
f0103d89:	ff 75 d0             	pushl  -0x30(%ebp)
f0103d8c:	57                   	push   %edi
f0103d8d:	e8 5f 03 00 00       	call   f01040f1 <strnlen>
f0103d92:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103d95:	29 c1                	sub    %eax,%ecx
f0103d97:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103d9a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103d9d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103da1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103da4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103da7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103da9:	eb 0f                	jmp    f0103dba <vprintfmt+0x1cf>
					putch(padc, putdat);
f0103dab:	83 ec 08             	sub    $0x8,%esp
f0103dae:	53                   	push   %ebx
f0103daf:	ff 75 e0             	pushl  -0x20(%ebp)
f0103db2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103db4:	83 ef 01             	sub    $0x1,%edi
f0103db7:	83 c4 10             	add    $0x10,%esp
f0103dba:	85 ff                	test   %edi,%edi
f0103dbc:	7f ed                	jg     f0103dab <vprintfmt+0x1c0>
f0103dbe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103dc1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103dc4:	85 c9                	test   %ecx,%ecx
f0103dc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dcb:	0f 49 c1             	cmovns %ecx,%eax
f0103dce:	29 c1                	sub    %eax,%ecx
f0103dd0:	89 75 08             	mov    %esi,0x8(%ebp)
f0103dd3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103dd6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103dd9:	89 cb                	mov    %ecx,%ebx
f0103ddb:	eb 4d                	jmp    f0103e2a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103ddd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103de1:	74 1b                	je     f0103dfe <vprintfmt+0x213>
f0103de3:	0f be c0             	movsbl %al,%eax
f0103de6:	83 e8 20             	sub    $0x20,%eax
f0103de9:	83 f8 5e             	cmp    $0x5e,%eax
f0103dec:	76 10                	jbe    f0103dfe <vprintfmt+0x213>
					putch('?', putdat);
f0103dee:	83 ec 08             	sub    $0x8,%esp
f0103df1:	ff 75 0c             	pushl  0xc(%ebp)
f0103df4:	6a 3f                	push   $0x3f
f0103df6:	ff 55 08             	call   *0x8(%ebp)
f0103df9:	83 c4 10             	add    $0x10,%esp
f0103dfc:	eb 0d                	jmp    f0103e0b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0103dfe:	83 ec 08             	sub    $0x8,%esp
f0103e01:	ff 75 0c             	pushl  0xc(%ebp)
f0103e04:	52                   	push   %edx
f0103e05:	ff 55 08             	call   *0x8(%ebp)
f0103e08:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e0b:	83 eb 01             	sub    $0x1,%ebx
f0103e0e:	eb 1a                	jmp    f0103e2a <vprintfmt+0x23f>
f0103e10:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e13:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e16:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e19:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103e1c:	eb 0c                	jmp    f0103e2a <vprintfmt+0x23f>
f0103e1e:	89 75 08             	mov    %esi,0x8(%ebp)
f0103e21:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103e24:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103e27:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103e2a:	83 c7 01             	add    $0x1,%edi
f0103e2d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103e31:	0f be d0             	movsbl %al,%edx
f0103e34:	85 d2                	test   %edx,%edx
f0103e36:	74 23                	je     f0103e5b <vprintfmt+0x270>
f0103e38:	85 f6                	test   %esi,%esi
f0103e3a:	78 a1                	js     f0103ddd <vprintfmt+0x1f2>
f0103e3c:	83 ee 01             	sub    $0x1,%esi
f0103e3f:	79 9c                	jns    f0103ddd <vprintfmt+0x1f2>
f0103e41:	89 df                	mov    %ebx,%edi
f0103e43:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e49:	eb 18                	jmp    f0103e63 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103e4b:	83 ec 08             	sub    $0x8,%esp
f0103e4e:	53                   	push   %ebx
f0103e4f:	6a 20                	push   $0x20
f0103e51:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e53:	83 ef 01             	sub    $0x1,%edi
f0103e56:	83 c4 10             	add    $0x10,%esp
f0103e59:	eb 08                	jmp    f0103e63 <vprintfmt+0x278>
f0103e5b:	89 df                	mov    %ebx,%edi
f0103e5d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e63:	85 ff                	test   %edi,%edi
f0103e65:	7f e4                	jg     f0103e4b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e6a:	e9 a2 fd ff ff       	jmp    f0103c11 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103e6f:	83 fa 01             	cmp    $0x1,%edx
f0103e72:	7e 16                	jle    f0103e8a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103e74:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e77:	8d 50 08             	lea    0x8(%eax),%edx
f0103e7a:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e7d:	8b 50 04             	mov    0x4(%eax),%edx
f0103e80:	8b 00                	mov    (%eax),%eax
f0103e82:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e85:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103e88:	eb 32                	jmp    f0103ebc <vprintfmt+0x2d1>
	else if (lflag)
f0103e8a:	85 d2                	test   %edx,%edx
f0103e8c:	74 18                	je     f0103ea6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0103e8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e91:	8d 50 04             	lea    0x4(%eax),%edx
f0103e94:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e97:	8b 00                	mov    (%eax),%eax
f0103e99:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e9c:	89 c1                	mov    %eax,%ecx
f0103e9e:	c1 f9 1f             	sar    $0x1f,%ecx
f0103ea1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103ea4:	eb 16                	jmp    f0103ebc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103ea6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ea9:	8d 50 04             	lea    0x4(%eax),%edx
f0103eac:	89 55 14             	mov    %edx,0x14(%ebp)
f0103eaf:	8b 00                	mov    (%eax),%eax
f0103eb1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103eb4:	89 c1                	mov    %eax,%ecx
f0103eb6:	c1 f9 1f             	sar    $0x1f,%ecx
f0103eb9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103ebc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ebf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103ec2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103ec7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103ecb:	79 74                	jns    f0103f41 <vprintfmt+0x356>
				putch('-', putdat);
f0103ecd:	83 ec 08             	sub    $0x8,%esp
f0103ed0:	53                   	push   %ebx
f0103ed1:	6a 2d                	push   $0x2d
f0103ed3:	ff d6                	call   *%esi
				num = -(long long) num;
f0103ed5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ed8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103edb:	f7 d8                	neg    %eax
f0103edd:	83 d2 00             	adc    $0x0,%edx
f0103ee0:	f7 da                	neg    %edx
f0103ee2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103ee5:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103eea:	eb 55                	jmp    f0103f41 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103eec:	8d 45 14             	lea    0x14(%ebp),%eax
f0103eef:	e8 83 fc ff ff       	call   f0103b77 <getuint>
			base = 10;
f0103ef4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103ef9:	eb 46                	jmp    f0103f41 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0103efb:	8d 45 14             	lea    0x14(%ebp),%eax
f0103efe:	e8 74 fc ff ff       	call   f0103b77 <getuint>
			base = 8;
f0103f03:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0103f08:	eb 37                	jmp    f0103f41 <vprintfmt+0x356>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0103f0a:	83 ec 08             	sub    $0x8,%esp
f0103f0d:	53                   	push   %ebx
f0103f0e:	6a 30                	push   $0x30
f0103f10:	ff d6                	call   *%esi
			putch('x', putdat);
f0103f12:	83 c4 08             	add    $0x8,%esp
f0103f15:	53                   	push   %ebx
f0103f16:	6a 78                	push   $0x78
f0103f18:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103f1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f1d:	8d 50 04             	lea    0x4(%eax),%edx
f0103f20:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103f23:	8b 00                	mov    (%eax),%eax
f0103f25:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103f2a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103f2d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103f32:	eb 0d                	jmp    f0103f41 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103f34:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f37:	e8 3b fc ff ff       	call   f0103b77 <getuint>
			base = 16;
f0103f3c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103f41:	83 ec 0c             	sub    $0xc,%esp
f0103f44:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103f48:	57                   	push   %edi
f0103f49:	ff 75 e0             	pushl  -0x20(%ebp)
f0103f4c:	51                   	push   %ecx
f0103f4d:	52                   	push   %edx
f0103f4e:	50                   	push   %eax
f0103f4f:	89 da                	mov    %ebx,%edx
f0103f51:	89 f0                	mov    %esi,%eax
f0103f53:	e8 70 fb ff ff       	call   f0103ac8 <printnum>
			break;
f0103f58:	83 c4 20             	add    $0x20,%esp
f0103f5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f5e:	e9 ae fc ff ff       	jmp    f0103c11 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103f63:	83 ec 08             	sub    $0x8,%esp
f0103f66:	53                   	push   %ebx
f0103f67:	51                   	push   %ecx
f0103f68:	ff d6                	call   *%esi
			break;
f0103f6a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103f70:	e9 9c fc ff ff       	jmp    f0103c11 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103f75:	83 ec 08             	sub    $0x8,%esp
f0103f78:	53                   	push   %ebx
f0103f79:	6a 25                	push   $0x25
f0103f7b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103f7d:	83 c4 10             	add    $0x10,%esp
f0103f80:	eb 03                	jmp    f0103f85 <vprintfmt+0x39a>
f0103f82:	83 ef 01             	sub    $0x1,%edi
f0103f85:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103f89:	75 f7                	jne    f0103f82 <vprintfmt+0x397>
f0103f8b:	e9 81 fc ff ff       	jmp    f0103c11 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f93:	5b                   	pop    %ebx
f0103f94:	5e                   	pop    %esi
f0103f95:	5f                   	pop    %edi
f0103f96:	5d                   	pop    %ebp
f0103f97:	c3                   	ret    

f0103f98 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103f98:	55                   	push   %ebp
f0103f99:	89 e5                	mov    %esp,%ebp
f0103f9b:	83 ec 18             	sub    $0x18,%esp
f0103f9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103fa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103fa7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103fab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103fae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103fb5:	85 c0                	test   %eax,%eax
f0103fb7:	74 26                	je     f0103fdf <vsnprintf+0x47>
f0103fb9:	85 d2                	test   %edx,%edx
f0103fbb:	7e 22                	jle    f0103fdf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103fbd:	ff 75 14             	pushl  0x14(%ebp)
f0103fc0:	ff 75 10             	pushl  0x10(%ebp)
f0103fc3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103fc6:	50                   	push   %eax
f0103fc7:	68 b1 3b 10 f0       	push   $0xf0103bb1
f0103fcc:	e8 1a fc ff ff       	call   f0103beb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103fd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103fd4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fda:	83 c4 10             	add    $0x10,%esp
f0103fdd:	eb 05                	jmp    f0103fe4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103fdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103fe4:	c9                   	leave  
f0103fe5:	c3                   	ret    

f0103fe6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103fe6:	55                   	push   %ebp
f0103fe7:	89 e5                	mov    %esp,%ebp
f0103fe9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103fec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103fef:	50                   	push   %eax
f0103ff0:	ff 75 10             	pushl  0x10(%ebp)
f0103ff3:	ff 75 0c             	pushl  0xc(%ebp)
f0103ff6:	ff 75 08             	pushl  0x8(%ebp)
f0103ff9:	e8 9a ff ff ff       	call   f0103f98 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103ffe:	c9                   	leave  
f0103fff:	c3                   	ret    

f0104000 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104000:	55                   	push   %ebp
f0104001:	89 e5                	mov    %esp,%ebp
f0104003:	57                   	push   %edi
f0104004:	56                   	push   %esi
f0104005:	53                   	push   %ebx
f0104006:	83 ec 0c             	sub    $0xc,%esp
f0104009:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010400c:	85 c0                	test   %eax,%eax
f010400e:	74 11                	je     f0104021 <readline+0x21>
		cprintf("%s", prompt);
f0104010:	83 ec 08             	sub    $0x8,%esp
f0104013:	50                   	push   %eax
f0104014:	68 29 54 10 f0       	push   $0xf0105429
f0104019:	e8 dc ee ff ff       	call   f0102efa <cprintf>
f010401e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104021:	83 ec 0c             	sub    $0xc,%esp
f0104024:	6a 00                	push   $0x0
f0104026:	e8 fd c5 ff ff       	call   f0100628 <iscons>
f010402b:	89 c7                	mov    %eax,%edi
f010402d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104030:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104035:	e8 dd c5 ff ff       	call   f0100617 <getchar>
f010403a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010403c:	85 c0                	test   %eax,%eax
f010403e:	79 18                	jns    f0104058 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104040:	83 ec 08             	sub    $0x8,%esp
f0104043:	50                   	push   %eax
f0104044:	68 00 5e 10 f0       	push   $0xf0105e00
f0104049:	e8 ac ee ff ff       	call   f0102efa <cprintf>
			return NULL;
f010404e:	83 c4 10             	add    $0x10,%esp
f0104051:	b8 00 00 00 00       	mov    $0x0,%eax
f0104056:	eb 79                	jmp    f01040d1 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104058:	83 f8 08             	cmp    $0x8,%eax
f010405b:	0f 94 c2             	sete   %dl
f010405e:	83 f8 7f             	cmp    $0x7f,%eax
f0104061:	0f 94 c0             	sete   %al
f0104064:	08 c2                	or     %al,%dl
f0104066:	74 1a                	je     f0104082 <readline+0x82>
f0104068:	85 f6                	test   %esi,%esi
f010406a:	7e 16                	jle    f0104082 <readline+0x82>
			if (echoing)
f010406c:	85 ff                	test   %edi,%edi
f010406e:	74 0d                	je     f010407d <readline+0x7d>
				cputchar('\b');
f0104070:	83 ec 0c             	sub    $0xc,%esp
f0104073:	6a 08                	push   $0x8
f0104075:	e8 8d c5 ff ff       	call   f0100607 <cputchar>
f010407a:	83 c4 10             	add    $0x10,%esp
			i--;
f010407d:	83 ee 01             	sub    $0x1,%esi
f0104080:	eb b3                	jmp    f0104035 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104082:	83 fb 1f             	cmp    $0x1f,%ebx
f0104085:	7e 23                	jle    f01040aa <readline+0xaa>
f0104087:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010408d:	7f 1b                	jg     f01040aa <readline+0xaa>
			if (echoing)
f010408f:	85 ff                	test   %edi,%edi
f0104091:	74 0c                	je     f010409f <readline+0x9f>
				cputchar(c);
f0104093:	83 ec 0c             	sub    $0xc,%esp
f0104096:	53                   	push   %ebx
f0104097:	e8 6b c5 ff ff       	call   f0100607 <cputchar>
f010409c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010409f:	88 9e 40 48 17 f0    	mov    %bl,-0xfe8b7c0(%esi)
f01040a5:	8d 76 01             	lea    0x1(%esi),%esi
f01040a8:	eb 8b                	jmp    f0104035 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01040aa:	83 fb 0a             	cmp    $0xa,%ebx
f01040ad:	74 05                	je     f01040b4 <readline+0xb4>
f01040af:	83 fb 0d             	cmp    $0xd,%ebx
f01040b2:	75 81                	jne    f0104035 <readline+0x35>
			if (echoing)
f01040b4:	85 ff                	test   %edi,%edi
f01040b6:	74 0d                	je     f01040c5 <readline+0xc5>
				cputchar('\n');
f01040b8:	83 ec 0c             	sub    $0xc,%esp
f01040bb:	6a 0a                	push   $0xa
f01040bd:	e8 45 c5 ff ff       	call   f0100607 <cputchar>
f01040c2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01040c5:	c6 86 40 48 17 f0 00 	movb   $0x0,-0xfe8b7c0(%esi)
			return buf;
f01040cc:	b8 40 48 17 f0       	mov    $0xf0174840,%eax
		}
	}
}
f01040d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040d4:	5b                   	pop    %ebx
f01040d5:	5e                   	pop    %esi
f01040d6:	5f                   	pop    %edi
f01040d7:	5d                   	pop    %ebp
f01040d8:	c3                   	ret    

f01040d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01040d9:	55                   	push   %ebp
f01040da:	89 e5                	mov    %esp,%ebp
f01040dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01040df:	b8 00 00 00 00       	mov    $0x0,%eax
f01040e4:	eb 03                	jmp    f01040e9 <strlen+0x10>
		n++;
f01040e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01040e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01040ed:	75 f7                	jne    f01040e6 <strlen+0xd>
		n++;
	return n;
}
f01040ef:	5d                   	pop    %ebp
f01040f0:	c3                   	ret    

f01040f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01040f1:	55                   	push   %ebp
f01040f2:	89 e5                	mov    %esp,%ebp
f01040f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01040fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01040ff:	eb 03                	jmp    f0104104 <strnlen+0x13>
		n++;
f0104101:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104104:	39 c2                	cmp    %eax,%edx
f0104106:	74 08                	je     f0104110 <strnlen+0x1f>
f0104108:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010410c:	75 f3                	jne    f0104101 <strnlen+0x10>
f010410e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104110:	5d                   	pop    %ebp
f0104111:	c3                   	ret    

f0104112 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104112:	55                   	push   %ebp
f0104113:	89 e5                	mov    %esp,%ebp
f0104115:	53                   	push   %ebx
f0104116:	8b 45 08             	mov    0x8(%ebp),%eax
f0104119:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010411c:	89 c2                	mov    %eax,%edx
f010411e:	83 c2 01             	add    $0x1,%edx
f0104121:	83 c1 01             	add    $0x1,%ecx
f0104124:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104128:	88 5a ff             	mov    %bl,-0x1(%edx)
f010412b:	84 db                	test   %bl,%bl
f010412d:	75 ef                	jne    f010411e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010412f:	5b                   	pop    %ebx
f0104130:	5d                   	pop    %ebp
f0104131:	c3                   	ret    

f0104132 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104132:	55                   	push   %ebp
f0104133:	89 e5                	mov    %esp,%ebp
f0104135:	53                   	push   %ebx
f0104136:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104139:	53                   	push   %ebx
f010413a:	e8 9a ff ff ff       	call   f01040d9 <strlen>
f010413f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104142:	ff 75 0c             	pushl  0xc(%ebp)
f0104145:	01 d8                	add    %ebx,%eax
f0104147:	50                   	push   %eax
f0104148:	e8 c5 ff ff ff       	call   f0104112 <strcpy>
	return dst;
}
f010414d:	89 d8                	mov    %ebx,%eax
f010414f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104152:	c9                   	leave  
f0104153:	c3                   	ret    

f0104154 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104154:	55                   	push   %ebp
f0104155:	89 e5                	mov    %esp,%ebp
f0104157:	56                   	push   %esi
f0104158:	53                   	push   %ebx
f0104159:	8b 75 08             	mov    0x8(%ebp),%esi
f010415c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010415f:	89 f3                	mov    %esi,%ebx
f0104161:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104164:	89 f2                	mov    %esi,%edx
f0104166:	eb 0f                	jmp    f0104177 <strncpy+0x23>
		*dst++ = *src;
f0104168:	83 c2 01             	add    $0x1,%edx
f010416b:	0f b6 01             	movzbl (%ecx),%eax
f010416e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104171:	80 39 01             	cmpb   $0x1,(%ecx)
f0104174:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104177:	39 da                	cmp    %ebx,%edx
f0104179:	75 ed                	jne    f0104168 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010417b:	89 f0                	mov    %esi,%eax
f010417d:	5b                   	pop    %ebx
f010417e:	5e                   	pop    %esi
f010417f:	5d                   	pop    %ebp
f0104180:	c3                   	ret    

f0104181 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104181:	55                   	push   %ebp
f0104182:	89 e5                	mov    %esp,%ebp
f0104184:	56                   	push   %esi
f0104185:	53                   	push   %ebx
f0104186:	8b 75 08             	mov    0x8(%ebp),%esi
f0104189:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010418c:	8b 55 10             	mov    0x10(%ebp),%edx
f010418f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104191:	85 d2                	test   %edx,%edx
f0104193:	74 21                	je     f01041b6 <strlcpy+0x35>
f0104195:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104199:	89 f2                	mov    %esi,%edx
f010419b:	eb 09                	jmp    f01041a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010419d:	83 c2 01             	add    $0x1,%edx
f01041a0:	83 c1 01             	add    $0x1,%ecx
f01041a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01041a6:	39 c2                	cmp    %eax,%edx
f01041a8:	74 09                	je     f01041b3 <strlcpy+0x32>
f01041aa:	0f b6 19             	movzbl (%ecx),%ebx
f01041ad:	84 db                	test   %bl,%bl
f01041af:	75 ec                	jne    f010419d <strlcpy+0x1c>
f01041b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01041b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01041b6:	29 f0                	sub    %esi,%eax
}
f01041b8:	5b                   	pop    %ebx
f01041b9:	5e                   	pop    %esi
f01041ba:	5d                   	pop    %ebp
f01041bb:	c3                   	ret    

f01041bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01041bc:	55                   	push   %ebp
f01041bd:	89 e5                	mov    %esp,%ebp
f01041bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01041c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01041c5:	eb 06                	jmp    f01041cd <strcmp+0x11>
		p++, q++;
f01041c7:	83 c1 01             	add    $0x1,%ecx
f01041ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01041cd:	0f b6 01             	movzbl (%ecx),%eax
f01041d0:	84 c0                	test   %al,%al
f01041d2:	74 04                	je     f01041d8 <strcmp+0x1c>
f01041d4:	3a 02                	cmp    (%edx),%al
f01041d6:	74 ef                	je     f01041c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01041d8:	0f b6 c0             	movzbl %al,%eax
f01041db:	0f b6 12             	movzbl (%edx),%edx
f01041de:	29 d0                	sub    %edx,%eax
}
f01041e0:	5d                   	pop    %ebp
f01041e1:	c3                   	ret    

f01041e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01041e2:	55                   	push   %ebp
f01041e3:	89 e5                	mov    %esp,%ebp
f01041e5:	53                   	push   %ebx
f01041e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01041e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01041ec:	89 c3                	mov    %eax,%ebx
f01041ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01041f1:	eb 06                	jmp    f01041f9 <strncmp+0x17>
		n--, p++, q++;
f01041f3:	83 c0 01             	add    $0x1,%eax
f01041f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01041f9:	39 d8                	cmp    %ebx,%eax
f01041fb:	74 15                	je     f0104212 <strncmp+0x30>
f01041fd:	0f b6 08             	movzbl (%eax),%ecx
f0104200:	84 c9                	test   %cl,%cl
f0104202:	74 04                	je     f0104208 <strncmp+0x26>
f0104204:	3a 0a                	cmp    (%edx),%cl
f0104206:	74 eb                	je     f01041f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104208:	0f b6 00             	movzbl (%eax),%eax
f010420b:	0f b6 12             	movzbl (%edx),%edx
f010420e:	29 d0                	sub    %edx,%eax
f0104210:	eb 05                	jmp    f0104217 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104212:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104217:	5b                   	pop    %ebx
f0104218:	5d                   	pop    %ebp
f0104219:	c3                   	ret    

f010421a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010421a:	55                   	push   %ebp
f010421b:	89 e5                	mov    %esp,%ebp
f010421d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104220:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104224:	eb 07                	jmp    f010422d <strchr+0x13>
		if (*s == c)
f0104226:	38 ca                	cmp    %cl,%dl
f0104228:	74 0f                	je     f0104239 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010422a:	83 c0 01             	add    $0x1,%eax
f010422d:	0f b6 10             	movzbl (%eax),%edx
f0104230:	84 d2                	test   %dl,%dl
f0104232:	75 f2                	jne    f0104226 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104234:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104239:	5d                   	pop    %ebp
f010423a:	c3                   	ret    

f010423b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010423b:	55                   	push   %ebp
f010423c:	89 e5                	mov    %esp,%ebp
f010423e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104241:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104245:	eb 03                	jmp    f010424a <strfind+0xf>
f0104247:	83 c0 01             	add    $0x1,%eax
f010424a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010424d:	38 ca                	cmp    %cl,%dl
f010424f:	74 04                	je     f0104255 <strfind+0x1a>
f0104251:	84 d2                	test   %dl,%dl
f0104253:	75 f2                	jne    f0104247 <strfind+0xc>
			break;
	return (char *) s;
}
f0104255:	5d                   	pop    %ebp
f0104256:	c3                   	ret    

f0104257 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104257:	55                   	push   %ebp
f0104258:	89 e5                	mov    %esp,%ebp
f010425a:	57                   	push   %edi
f010425b:	56                   	push   %esi
f010425c:	53                   	push   %ebx
f010425d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104260:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104263:	85 c9                	test   %ecx,%ecx
f0104265:	74 36                	je     f010429d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104267:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010426d:	75 28                	jne    f0104297 <memset+0x40>
f010426f:	f6 c1 03             	test   $0x3,%cl
f0104272:	75 23                	jne    f0104297 <memset+0x40>
		c &= 0xFF;
f0104274:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104278:	89 d3                	mov    %edx,%ebx
f010427a:	c1 e3 08             	shl    $0x8,%ebx
f010427d:	89 d6                	mov    %edx,%esi
f010427f:	c1 e6 18             	shl    $0x18,%esi
f0104282:	89 d0                	mov    %edx,%eax
f0104284:	c1 e0 10             	shl    $0x10,%eax
f0104287:	09 f0                	or     %esi,%eax
f0104289:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010428b:	89 d8                	mov    %ebx,%eax
f010428d:	09 d0                	or     %edx,%eax
f010428f:	c1 e9 02             	shr    $0x2,%ecx
f0104292:	fc                   	cld    
f0104293:	f3 ab                	rep stos %eax,%es:(%edi)
f0104295:	eb 06                	jmp    f010429d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104297:	8b 45 0c             	mov    0xc(%ebp),%eax
f010429a:	fc                   	cld    
f010429b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010429d:	89 f8                	mov    %edi,%eax
f010429f:	5b                   	pop    %ebx
f01042a0:	5e                   	pop    %esi
f01042a1:	5f                   	pop    %edi
f01042a2:	5d                   	pop    %ebp
f01042a3:	c3                   	ret    

f01042a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01042a4:	55                   	push   %ebp
f01042a5:	89 e5                	mov    %esp,%ebp
f01042a7:	57                   	push   %edi
f01042a8:	56                   	push   %esi
f01042a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01042ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01042af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01042b2:	39 c6                	cmp    %eax,%esi
f01042b4:	73 35                	jae    f01042eb <memmove+0x47>
f01042b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01042b9:	39 d0                	cmp    %edx,%eax
f01042bb:	73 2e                	jae    f01042eb <memmove+0x47>
		s += n;
		d += n;
f01042bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01042c0:	89 d6                	mov    %edx,%esi
f01042c2:	09 fe                	or     %edi,%esi
f01042c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01042ca:	75 13                	jne    f01042df <memmove+0x3b>
f01042cc:	f6 c1 03             	test   $0x3,%cl
f01042cf:	75 0e                	jne    f01042df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01042d1:	83 ef 04             	sub    $0x4,%edi
f01042d4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01042d7:	c1 e9 02             	shr    $0x2,%ecx
f01042da:	fd                   	std    
f01042db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01042dd:	eb 09                	jmp    f01042e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01042df:	83 ef 01             	sub    $0x1,%edi
f01042e2:	8d 72 ff             	lea    -0x1(%edx),%esi
f01042e5:	fd                   	std    
f01042e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01042e8:	fc                   	cld    
f01042e9:	eb 1d                	jmp    f0104308 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01042eb:	89 f2                	mov    %esi,%edx
f01042ed:	09 c2                	or     %eax,%edx
f01042ef:	f6 c2 03             	test   $0x3,%dl
f01042f2:	75 0f                	jne    f0104303 <memmove+0x5f>
f01042f4:	f6 c1 03             	test   $0x3,%cl
f01042f7:	75 0a                	jne    f0104303 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01042f9:	c1 e9 02             	shr    $0x2,%ecx
f01042fc:	89 c7                	mov    %eax,%edi
f01042fe:	fc                   	cld    
f01042ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104301:	eb 05                	jmp    f0104308 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104303:	89 c7                	mov    %eax,%edi
f0104305:	fc                   	cld    
f0104306:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104308:	5e                   	pop    %esi
f0104309:	5f                   	pop    %edi
f010430a:	5d                   	pop    %ebp
f010430b:	c3                   	ret    

f010430c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010430c:	55                   	push   %ebp
f010430d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010430f:	ff 75 10             	pushl  0x10(%ebp)
f0104312:	ff 75 0c             	pushl  0xc(%ebp)
f0104315:	ff 75 08             	pushl  0x8(%ebp)
f0104318:	e8 87 ff ff ff       	call   f01042a4 <memmove>
}
f010431d:	c9                   	leave  
f010431e:	c3                   	ret    

f010431f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010431f:	55                   	push   %ebp
f0104320:	89 e5                	mov    %esp,%ebp
f0104322:	56                   	push   %esi
f0104323:	53                   	push   %ebx
f0104324:	8b 45 08             	mov    0x8(%ebp),%eax
f0104327:	8b 55 0c             	mov    0xc(%ebp),%edx
f010432a:	89 c6                	mov    %eax,%esi
f010432c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010432f:	eb 1a                	jmp    f010434b <memcmp+0x2c>
		if (*s1 != *s2)
f0104331:	0f b6 08             	movzbl (%eax),%ecx
f0104334:	0f b6 1a             	movzbl (%edx),%ebx
f0104337:	38 d9                	cmp    %bl,%cl
f0104339:	74 0a                	je     f0104345 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010433b:	0f b6 c1             	movzbl %cl,%eax
f010433e:	0f b6 db             	movzbl %bl,%ebx
f0104341:	29 d8                	sub    %ebx,%eax
f0104343:	eb 0f                	jmp    f0104354 <memcmp+0x35>
		s1++, s2++;
f0104345:	83 c0 01             	add    $0x1,%eax
f0104348:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010434b:	39 f0                	cmp    %esi,%eax
f010434d:	75 e2                	jne    f0104331 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010434f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104354:	5b                   	pop    %ebx
f0104355:	5e                   	pop    %esi
f0104356:	5d                   	pop    %ebp
f0104357:	c3                   	ret    

f0104358 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104358:	55                   	push   %ebp
f0104359:	89 e5                	mov    %esp,%ebp
f010435b:	53                   	push   %ebx
f010435c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010435f:	89 c1                	mov    %eax,%ecx
f0104361:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104364:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104368:	eb 0a                	jmp    f0104374 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010436a:	0f b6 10             	movzbl (%eax),%edx
f010436d:	39 da                	cmp    %ebx,%edx
f010436f:	74 07                	je     f0104378 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104371:	83 c0 01             	add    $0x1,%eax
f0104374:	39 c8                	cmp    %ecx,%eax
f0104376:	72 f2                	jb     f010436a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104378:	5b                   	pop    %ebx
f0104379:	5d                   	pop    %ebp
f010437a:	c3                   	ret    

f010437b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010437b:	55                   	push   %ebp
f010437c:	89 e5                	mov    %esp,%ebp
f010437e:	57                   	push   %edi
f010437f:	56                   	push   %esi
f0104380:	53                   	push   %ebx
f0104381:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104384:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104387:	eb 03                	jmp    f010438c <strtol+0x11>
		s++;
f0104389:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010438c:	0f b6 01             	movzbl (%ecx),%eax
f010438f:	3c 20                	cmp    $0x20,%al
f0104391:	74 f6                	je     f0104389 <strtol+0xe>
f0104393:	3c 09                	cmp    $0x9,%al
f0104395:	74 f2                	je     f0104389 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104397:	3c 2b                	cmp    $0x2b,%al
f0104399:	75 0a                	jne    f01043a5 <strtol+0x2a>
		s++;
f010439b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010439e:	bf 00 00 00 00       	mov    $0x0,%edi
f01043a3:	eb 11                	jmp    f01043b6 <strtol+0x3b>
f01043a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01043aa:	3c 2d                	cmp    $0x2d,%al
f01043ac:	75 08                	jne    f01043b6 <strtol+0x3b>
		s++, neg = 1;
f01043ae:	83 c1 01             	add    $0x1,%ecx
f01043b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01043b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01043bc:	75 15                	jne    f01043d3 <strtol+0x58>
f01043be:	80 39 30             	cmpb   $0x30,(%ecx)
f01043c1:	75 10                	jne    f01043d3 <strtol+0x58>
f01043c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01043c7:	75 7c                	jne    f0104445 <strtol+0xca>
		s += 2, base = 16;
f01043c9:	83 c1 02             	add    $0x2,%ecx
f01043cc:	bb 10 00 00 00       	mov    $0x10,%ebx
f01043d1:	eb 16                	jmp    f01043e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01043d3:	85 db                	test   %ebx,%ebx
f01043d5:	75 12                	jne    f01043e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01043d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01043dc:	80 39 30             	cmpb   $0x30,(%ecx)
f01043df:	75 08                	jne    f01043e9 <strtol+0x6e>
		s++, base = 8;
f01043e1:	83 c1 01             	add    $0x1,%ecx
f01043e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01043e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01043ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01043f1:	0f b6 11             	movzbl (%ecx),%edx
f01043f4:	8d 72 d0             	lea    -0x30(%edx),%esi
f01043f7:	89 f3                	mov    %esi,%ebx
f01043f9:	80 fb 09             	cmp    $0x9,%bl
f01043fc:	77 08                	ja     f0104406 <strtol+0x8b>
			dig = *s - '0';
f01043fe:	0f be d2             	movsbl %dl,%edx
f0104401:	83 ea 30             	sub    $0x30,%edx
f0104404:	eb 22                	jmp    f0104428 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104406:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104409:	89 f3                	mov    %esi,%ebx
f010440b:	80 fb 19             	cmp    $0x19,%bl
f010440e:	77 08                	ja     f0104418 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104410:	0f be d2             	movsbl %dl,%edx
f0104413:	83 ea 57             	sub    $0x57,%edx
f0104416:	eb 10                	jmp    f0104428 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0104418:	8d 72 bf             	lea    -0x41(%edx),%esi
f010441b:	89 f3                	mov    %esi,%ebx
f010441d:	80 fb 19             	cmp    $0x19,%bl
f0104420:	77 16                	ja     f0104438 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104422:	0f be d2             	movsbl %dl,%edx
f0104425:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104428:	3b 55 10             	cmp    0x10(%ebp),%edx
f010442b:	7d 0b                	jge    f0104438 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010442d:	83 c1 01             	add    $0x1,%ecx
f0104430:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104434:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104436:	eb b9                	jmp    f01043f1 <strtol+0x76>

	if (endptr)
f0104438:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010443c:	74 0d                	je     f010444b <strtol+0xd0>
		*endptr = (char *) s;
f010443e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104441:	89 0e                	mov    %ecx,(%esi)
f0104443:	eb 06                	jmp    f010444b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104445:	85 db                	test   %ebx,%ebx
f0104447:	74 98                	je     f01043e1 <strtol+0x66>
f0104449:	eb 9e                	jmp    f01043e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010444b:	89 c2                	mov    %eax,%edx
f010444d:	f7 da                	neg    %edx
f010444f:	85 ff                	test   %edi,%edi
f0104451:	0f 45 c2             	cmovne %edx,%eax
}
f0104454:	5b                   	pop    %ebx
f0104455:	5e                   	pop    %esi
f0104456:	5f                   	pop    %edi
f0104457:	5d                   	pop    %ebp
f0104458:	c3                   	ret    
f0104459:	66 90                	xchg   %ax,%ax
f010445b:	66 90                	xchg   %ax,%ax
f010445d:	66 90                	xchg   %ax,%ax
f010445f:	90                   	nop

f0104460 <__udivdi3>:
f0104460:	55                   	push   %ebp
f0104461:	57                   	push   %edi
f0104462:	56                   	push   %esi
f0104463:	53                   	push   %ebx
f0104464:	83 ec 1c             	sub    $0x1c,%esp
f0104467:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010446b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010446f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104473:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104477:	85 f6                	test   %esi,%esi
f0104479:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010447d:	89 ca                	mov    %ecx,%edx
f010447f:	89 f8                	mov    %edi,%eax
f0104481:	75 3d                	jne    f01044c0 <__udivdi3+0x60>
f0104483:	39 cf                	cmp    %ecx,%edi
f0104485:	0f 87 c5 00 00 00    	ja     f0104550 <__udivdi3+0xf0>
f010448b:	85 ff                	test   %edi,%edi
f010448d:	89 fd                	mov    %edi,%ebp
f010448f:	75 0b                	jne    f010449c <__udivdi3+0x3c>
f0104491:	b8 01 00 00 00       	mov    $0x1,%eax
f0104496:	31 d2                	xor    %edx,%edx
f0104498:	f7 f7                	div    %edi
f010449a:	89 c5                	mov    %eax,%ebp
f010449c:	89 c8                	mov    %ecx,%eax
f010449e:	31 d2                	xor    %edx,%edx
f01044a0:	f7 f5                	div    %ebp
f01044a2:	89 c1                	mov    %eax,%ecx
f01044a4:	89 d8                	mov    %ebx,%eax
f01044a6:	89 cf                	mov    %ecx,%edi
f01044a8:	f7 f5                	div    %ebp
f01044aa:	89 c3                	mov    %eax,%ebx
f01044ac:	89 d8                	mov    %ebx,%eax
f01044ae:	89 fa                	mov    %edi,%edx
f01044b0:	83 c4 1c             	add    $0x1c,%esp
f01044b3:	5b                   	pop    %ebx
f01044b4:	5e                   	pop    %esi
f01044b5:	5f                   	pop    %edi
f01044b6:	5d                   	pop    %ebp
f01044b7:	c3                   	ret    
f01044b8:	90                   	nop
f01044b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01044c0:	39 ce                	cmp    %ecx,%esi
f01044c2:	77 74                	ja     f0104538 <__udivdi3+0xd8>
f01044c4:	0f bd fe             	bsr    %esi,%edi
f01044c7:	83 f7 1f             	xor    $0x1f,%edi
f01044ca:	0f 84 98 00 00 00    	je     f0104568 <__udivdi3+0x108>
f01044d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01044d5:	89 f9                	mov    %edi,%ecx
f01044d7:	89 c5                	mov    %eax,%ebp
f01044d9:	29 fb                	sub    %edi,%ebx
f01044db:	d3 e6                	shl    %cl,%esi
f01044dd:	89 d9                	mov    %ebx,%ecx
f01044df:	d3 ed                	shr    %cl,%ebp
f01044e1:	89 f9                	mov    %edi,%ecx
f01044e3:	d3 e0                	shl    %cl,%eax
f01044e5:	09 ee                	or     %ebp,%esi
f01044e7:	89 d9                	mov    %ebx,%ecx
f01044e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01044ed:	89 d5                	mov    %edx,%ebp
f01044ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01044f3:	d3 ed                	shr    %cl,%ebp
f01044f5:	89 f9                	mov    %edi,%ecx
f01044f7:	d3 e2                	shl    %cl,%edx
f01044f9:	89 d9                	mov    %ebx,%ecx
f01044fb:	d3 e8                	shr    %cl,%eax
f01044fd:	09 c2                	or     %eax,%edx
f01044ff:	89 d0                	mov    %edx,%eax
f0104501:	89 ea                	mov    %ebp,%edx
f0104503:	f7 f6                	div    %esi
f0104505:	89 d5                	mov    %edx,%ebp
f0104507:	89 c3                	mov    %eax,%ebx
f0104509:	f7 64 24 0c          	mull   0xc(%esp)
f010450d:	39 d5                	cmp    %edx,%ebp
f010450f:	72 10                	jb     f0104521 <__udivdi3+0xc1>
f0104511:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104515:	89 f9                	mov    %edi,%ecx
f0104517:	d3 e6                	shl    %cl,%esi
f0104519:	39 c6                	cmp    %eax,%esi
f010451b:	73 07                	jae    f0104524 <__udivdi3+0xc4>
f010451d:	39 d5                	cmp    %edx,%ebp
f010451f:	75 03                	jne    f0104524 <__udivdi3+0xc4>
f0104521:	83 eb 01             	sub    $0x1,%ebx
f0104524:	31 ff                	xor    %edi,%edi
f0104526:	89 d8                	mov    %ebx,%eax
f0104528:	89 fa                	mov    %edi,%edx
f010452a:	83 c4 1c             	add    $0x1c,%esp
f010452d:	5b                   	pop    %ebx
f010452e:	5e                   	pop    %esi
f010452f:	5f                   	pop    %edi
f0104530:	5d                   	pop    %ebp
f0104531:	c3                   	ret    
f0104532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104538:	31 ff                	xor    %edi,%edi
f010453a:	31 db                	xor    %ebx,%ebx
f010453c:	89 d8                	mov    %ebx,%eax
f010453e:	89 fa                	mov    %edi,%edx
f0104540:	83 c4 1c             	add    $0x1c,%esp
f0104543:	5b                   	pop    %ebx
f0104544:	5e                   	pop    %esi
f0104545:	5f                   	pop    %edi
f0104546:	5d                   	pop    %ebp
f0104547:	c3                   	ret    
f0104548:	90                   	nop
f0104549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104550:	89 d8                	mov    %ebx,%eax
f0104552:	f7 f7                	div    %edi
f0104554:	31 ff                	xor    %edi,%edi
f0104556:	89 c3                	mov    %eax,%ebx
f0104558:	89 d8                	mov    %ebx,%eax
f010455a:	89 fa                	mov    %edi,%edx
f010455c:	83 c4 1c             	add    $0x1c,%esp
f010455f:	5b                   	pop    %ebx
f0104560:	5e                   	pop    %esi
f0104561:	5f                   	pop    %edi
f0104562:	5d                   	pop    %ebp
f0104563:	c3                   	ret    
f0104564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104568:	39 ce                	cmp    %ecx,%esi
f010456a:	72 0c                	jb     f0104578 <__udivdi3+0x118>
f010456c:	31 db                	xor    %ebx,%ebx
f010456e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104572:	0f 87 34 ff ff ff    	ja     f01044ac <__udivdi3+0x4c>
f0104578:	bb 01 00 00 00       	mov    $0x1,%ebx
f010457d:	e9 2a ff ff ff       	jmp    f01044ac <__udivdi3+0x4c>
f0104582:	66 90                	xchg   %ax,%ax
f0104584:	66 90                	xchg   %ax,%ax
f0104586:	66 90                	xchg   %ax,%ax
f0104588:	66 90                	xchg   %ax,%ax
f010458a:	66 90                	xchg   %ax,%ax
f010458c:	66 90                	xchg   %ax,%ax
f010458e:	66 90                	xchg   %ax,%ax

f0104590 <__umoddi3>:
f0104590:	55                   	push   %ebp
f0104591:	57                   	push   %edi
f0104592:	56                   	push   %esi
f0104593:	53                   	push   %ebx
f0104594:	83 ec 1c             	sub    $0x1c,%esp
f0104597:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010459b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010459f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01045a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01045a7:	85 d2                	test   %edx,%edx
f01045a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01045b1:	89 f3                	mov    %esi,%ebx
f01045b3:	89 3c 24             	mov    %edi,(%esp)
f01045b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01045ba:	75 1c                	jne    f01045d8 <__umoddi3+0x48>
f01045bc:	39 f7                	cmp    %esi,%edi
f01045be:	76 50                	jbe    f0104610 <__umoddi3+0x80>
f01045c0:	89 c8                	mov    %ecx,%eax
f01045c2:	89 f2                	mov    %esi,%edx
f01045c4:	f7 f7                	div    %edi
f01045c6:	89 d0                	mov    %edx,%eax
f01045c8:	31 d2                	xor    %edx,%edx
f01045ca:	83 c4 1c             	add    $0x1c,%esp
f01045cd:	5b                   	pop    %ebx
f01045ce:	5e                   	pop    %esi
f01045cf:	5f                   	pop    %edi
f01045d0:	5d                   	pop    %ebp
f01045d1:	c3                   	ret    
f01045d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01045d8:	39 f2                	cmp    %esi,%edx
f01045da:	89 d0                	mov    %edx,%eax
f01045dc:	77 52                	ja     f0104630 <__umoddi3+0xa0>
f01045de:	0f bd ea             	bsr    %edx,%ebp
f01045e1:	83 f5 1f             	xor    $0x1f,%ebp
f01045e4:	75 5a                	jne    f0104640 <__umoddi3+0xb0>
f01045e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01045ea:	0f 82 e0 00 00 00    	jb     f01046d0 <__umoddi3+0x140>
f01045f0:	39 0c 24             	cmp    %ecx,(%esp)
f01045f3:	0f 86 d7 00 00 00    	jbe    f01046d0 <__umoddi3+0x140>
f01045f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01045fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104601:	83 c4 1c             	add    $0x1c,%esp
f0104604:	5b                   	pop    %ebx
f0104605:	5e                   	pop    %esi
f0104606:	5f                   	pop    %edi
f0104607:	5d                   	pop    %ebp
f0104608:	c3                   	ret    
f0104609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104610:	85 ff                	test   %edi,%edi
f0104612:	89 fd                	mov    %edi,%ebp
f0104614:	75 0b                	jne    f0104621 <__umoddi3+0x91>
f0104616:	b8 01 00 00 00       	mov    $0x1,%eax
f010461b:	31 d2                	xor    %edx,%edx
f010461d:	f7 f7                	div    %edi
f010461f:	89 c5                	mov    %eax,%ebp
f0104621:	89 f0                	mov    %esi,%eax
f0104623:	31 d2                	xor    %edx,%edx
f0104625:	f7 f5                	div    %ebp
f0104627:	89 c8                	mov    %ecx,%eax
f0104629:	f7 f5                	div    %ebp
f010462b:	89 d0                	mov    %edx,%eax
f010462d:	eb 99                	jmp    f01045c8 <__umoddi3+0x38>
f010462f:	90                   	nop
f0104630:	89 c8                	mov    %ecx,%eax
f0104632:	89 f2                	mov    %esi,%edx
f0104634:	83 c4 1c             	add    $0x1c,%esp
f0104637:	5b                   	pop    %ebx
f0104638:	5e                   	pop    %esi
f0104639:	5f                   	pop    %edi
f010463a:	5d                   	pop    %ebp
f010463b:	c3                   	ret    
f010463c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104640:	8b 34 24             	mov    (%esp),%esi
f0104643:	bf 20 00 00 00       	mov    $0x20,%edi
f0104648:	89 e9                	mov    %ebp,%ecx
f010464a:	29 ef                	sub    %ebp,%edi
f010464c:	d3 e0                	shl    %cl,%eax
f010464e:	89 f9                	mov    %edi,%ecx
f0104650:	89 f2                	mov    %esi,%edx
f0104652:	d3 ea                	shr    %cl,%edx
f0104654:	89 e9                	mov    %ebp,%ecx
f0104656:	09 c2                	or     %eax,%edx
f0104658:	89 d8                	mov    %ebx,%eax
f010465a:	89 14 24             	mov    %edx,(%esp)
f010465d:	89 f2                	mov    %esi,%edx
f010465f:	d3 e2                	shl    %cl,%edx
f0104661:	89 f9                	mov    %edi,%ecx
f0104663:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104667:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010466b:	d3 e8                	shr    %cl,%eax
f010466d:	89 e9                	mov    %ebp,%ecx
f010466f:	89 c6                	mov    %eax,%esi
f0104671:	d3 e3                	shl    %cl,%ebx
f0104673:	89 f9                	mov    %edi,%ecx
f0104675:	89 d0                	mov    %edx,%eax
f0104677:	d3 e8                	shr    %cl,%eax
f0104679:	89 e9                	mov    %ebp,%ecx
f010467b:	09 d8                	or     %ebx,%eax
f010467d:	89 d3                	mov    %edx,%ebx
f010467f:	89 f2                	mov    %esi,%edx
f0104681:	f7 34 24             	divl   (%esp)
f0104684:	89 d6                	mov    %edx,%esi
f0104686:	d3 e3                	shl    %cl,%ebx
f0104688:	f7 64 24 04          	mull   0x4(%esp)
f010468c:	39 d6                	cmp    %edx,%esi
f010468e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104692:	89 d1                	mov    %edx,%ecx
f0104694:	89 c3                	mov    %eax,%ebx
f0104696:	72 08                	jb     f01046a0 <__umoddi3+0x110>
f0104698:	75 11                	jne    f01046ab <__umoddi3+0x11b>
f010469a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010469e:	73 0b                	jae    f01046ab <__umoddi3+0x11b>
f01046a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01046a4:	1b 14 24             	sbb    (%esp),%edx
f01046a7:	89 d1                	mov    %edx,%ecx
f01046a9:	89 c3                	mov    %eax,%ebx
f01046ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01046af:	29 da                	sub    %ebx,%edx
f01046b1:	19 ce                	sbb    %ecx,%esi
f01046b3:	89 f9                	mov    %edi,%ecx
f01046b5:	89 f0                	mov    %esi,%eax
f01046b7:	d3 e0                	shl    %cl,%eax
f01046b9:	89 e9                	mov    %ebp,%ecx
f01046bb:	d3 ea                	shr    %cl,%edx
f01046bd:	89 e9                	mov    %ebp,%ecx
f01046bf:	d3 ee                	shr    %cl,%esi
f01046c1:	09 d0                	or     %edx,%eax
f01046c3:	89 f2                	mov    %esi,%edx
f01046c5:	83 c4 1c             	add    $0x1c,%esp
f01046c8:	5b                   	pop    %ebx
f01046c9:	5e                   	pop    %esi
f01046ca:	5f                   	pop    %edi
f01046cb:	5d                   	pop    %ebp
f01046cc:	c3                   	ret    
f01046cd:	8d 76 00             	lea    0x0(%esi),%esi
f01046d0:	29 f9                	sub    %edi,%ecx
f01046d2:	19 d6                	sbb    %edx,%esi
f01046d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01046dc:	e9 18 ff ff ff       	jmp    f01045f9 <__umoddi3+0x69>
