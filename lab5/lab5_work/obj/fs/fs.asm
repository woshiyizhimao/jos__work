
obj/fs/fs：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 f5 18 00 00       	call   801926 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 40 37 80 00       	push   $0x803740
  8000b7:	e8 a3 19 00 00       	call   801a5f <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 57 37 80 00       	push   $0x803757
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 67 37 80 00       	push   $0x803767
  8000e0:	e8 a1 18 00 00       	call   801986 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 70 37 80 00       	push   $0x803770
  80010b:	68 7d 37 80 00       	push   $0x80377d
  800110:	6a 44                	push   $0x44
  800112:	68 67 37 80 00       	push   $0x803767
  800117:	e8 6a 18 00 00       	call   801986 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 70 37 80 00       	push   $0x803770
  8001cf:	68 7d 37 80 00       	push   $0x80377d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 67 37 80 00       	push   $0x803767
  8001db:	e8 a6 17 00 00       	call   801986 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 94 37 80 00       	push   $0x803794
  80029f:	6a 27                	push   $0x27
  8002a1:	68 98 38 80 00       	push   $0x803898
  8002a6:	e8 db 16 00 00       	call   801986 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 c4 37 80 00       	push   $0x8037c4
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 98 38 80 00       	push   $0x803898
  8002c6:	e8 bb 16 00 00       	call   801986 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	// 2018/12/11 edited by Lethe
	addr = ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if ((r = sys_page_alloc(0, addr, PTE_U | PTE_P | PTE_W)) < 0)
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 09 21 00 00       	call   8023e7 <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
                panic("in bc_pgfault, sys_page_alloc: %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 e8 37 80 00       	push   $0x8037e8
  8002eb:	6a 36                	push   $0x36
  8002ed:	68 98 38 80 00       	push   $0x803898
  8002f2:	e8 8f 16 00 00       	call   801986 <_panic>

        if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
                panic("in bc_pgfault, ide_read: %e", r);
  800311:	50                   	push   %eax
  800312:	68 a0 38 80 00       	push   $0x8038a0
  800317:	6a 39                	push   $0x39
  800319:	68 98 38 80 00       	push   $0x803898
  80031e:	e8 63 16 00 00       	call   801986 <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 e7 20 00 00       	call   80242a <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 0c 38 80 00       	push   $0x80380c
  800350:	6a 3e                	push   $0x3e
  800352:	68 98 38 80 00       	push   $0x803898
  800357:	e8 2a 16 00 00       	call   801986 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 56 03 00 00       	call   8006c4 <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 bc 38 80 00       	push   $0x8038bc
  80037b:	6a 44                	push   $0x44
  80037d:	68 98 38 80 00       	push   $0x803898
  800382:	e8 ff 15 00 00       	call   801986 <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 2c 38 80 00       	push   $0x80382c
  8003b0:	6a 09                	push   $0x9
  8003b2:	68 98 38 80 00       	push   $0x803898
  8003b7:	e8 ca 15 00 00       	call   801986 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 d5 38 80 00       	push   $0x8038d5
  800427:	6a 54                	push   $0x54
  800429:	68 98 38 80 00       	push   $0x803898
  80042e:	e8 53 15 00 00       	call   801986 <_panic>

	// LAB 5: Your code here.
	// 2018/12/11 edited by Lethe
	int r;

        addr = ROUNDDOWN(addr, PGSIZE);
  800433:	89 de                	mov    %ebx,%esi
  800435:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        if (va_is_mapped(addr) && va_is_dirty(addr)) {
  80043b:	83 ec 0c             	sub    $0xc,%esp
  80043e:	56                   	push   %esi
  80043f:	e8 82 ff ff ff       	call   8003c6 <va_is_mapped>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	84 c0                	test   %al,%al
  800449:	74 7a                	je     8004c5 <flush_block+0xb9>
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	56                   	push   %esi
  80044f:	e8 a0 ff ff ff       	call   8003f4 <va_is_dirty>
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	84 c0                	test   %al,%al
  800459:	74 6a                	je     8004c5 <flush_block+0xb9>
                if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  80045b:	83 ec 04             	sub    $0x4,%esp
  80045e:	6a 08                	push   $0x8
  800460:	56                   	push   %esi
  800461:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800467:	c1 eb 0c             	shr    $0xc,%ebx
  80046a:	c1 e3 03             	shl    $0x3,%ebx
  80046d:	53                   	push   %ebx
  80046e:	e8 3d fd ff ff       	call   8001b0 <ide_write>
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	85 c0                	test   %eax,%eax
  800478:	79 12                	jns    80048c <flush_block+0x80>
                        panic("in flush_block, ide_write: %e", r);
  80047a:	50                   	push   %eax
  80047b:	68 f0 38 80 00       	push   $0x8038f0
  800480:	6a 5d                	push   $0x5d
  800482:	68 98 38 80 00       	push   $0x803898
  800487:	e8 fa 14 00 00       	call   801986 <_panic>
                if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80048c:	89 f0                	mov    %esi,%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800498:	83 ec 0c             	sub    $0xc,%esp
  80049b:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a0:	50                   	push   %eax
  8004a1:	56                   	push   %esi
  8004a2:	6a 00                	push   $0x0
  8004a4:	56                   	push   %esi
  8004a5:	6a 00                	push   $0x0
  8004a7:	e8 7e 1f 00 00       	call   80242a <sys_page_map>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 12                	jns    8004c5 <flush_block+0xb9>
                        panic("in flush_block, sys_page_map: %e", r);
  8004b3:	50                   	push   %eax
  8004b4:	68 50 38 80 00       	push   $0x803850
  8004b9:	6a 5f                	push   $0x5f
  8004bb:	68 98 38 80 00       	push   $0x803898
  8004c0:	e8 c1 14 00 00       	call   801986 <_panic>
        }
	//panic("flush_block not implemented");
}
  8004c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c8:	5b                   	pop    %ebx
  8004c9:	5e                   	pop    %esi
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004d5:	68 74 02 80 00       	push   $0x800274
  8004da:	e8 f9 20 00 00       	call   8025d8 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004e6:	e8 a3 fe ff ff       	call   80038e <diskaddr>
  8004eb:	83 c4 0c             	add    $0xc,%esp
  8004ee:	68 08 01 00 00       	push   $0x108
  8004f3:	50                   	push   %eax
  8004f4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	e8 76 1c 00 00       	call   802176 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800500:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800507:	e8 82 fe ff ff       	call   80038e <diskaddr>
  80050c:	83 c4 08             	add    $0x8,%esp
  80050f:	68 0e 39 80 00       	push   $0x80390e
  800514:	50                   	push   %eax
  800515:	e8 ca 1a 00 00       	call   801fe4 <strcpy>
	flush_block(diskaddr(1));
  80051a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800521:	e8 68 fe ff ff       	call   80038e <diskaddr>
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	e8 de fe ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80052e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800535:	e8 54 fe ff ff       	call   80038e <diskaddr>
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 84 fe ff ff       	call   8003c6 <va_is_mapped>
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	84 c0                	test   %al,%al
  800547:	75 16                	jne    80055f <bc_init+0x93>
  800549:	68 30 39 80 00       	push   $0x803930
  80054e:	68 7d 37 80 00       	push   $0x80377d
  800553:	6a 71                	push   $0x71
  800555:	68 98 38 80 00       	push   $0x803898
  80055a:	e8 27 14 00 00       	call   801986 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 25 fe ff ff       	call   80038e <diskaddr>
  800569:	89 04 24             	mov    %eax,(%esp)
  80056c:	e8 83 fe ff ff       	call   8003f4 <va_is_dirty>
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	84 c0                	test   %al,%al
  800576:	74 16                	je     80058e <bc_init+0xc2>
  800578:	68 15 39 80 00       	push   $0x803915
  80057d:	68 7d 37 80 00       	push   $0x80377d
  800582:	6a 72                	push   $0x72
  800584:	68 98 38 80 00       	push   $0x803898
  800589:	e8 f8 13 00 00       	call   801986 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80058e:	83 ec 0c             	sub    $0xc,%esp
  800591:	6a 01                	push   $0x1
  800593:	e8 f6 fd ff ff       	call   80038e <diskaddr>
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	50                   	push   %eax
  80059c:	6a 00                	push   $0x0
  80059e:	e8 c9 1e 00 00       	call   80246c <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005aa:	e8 df fd ff ff       	call   80038e <diskaddr>
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	e8 0f fe ff ff       	call   8003c6 <va_is_mapped>
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	84 c0                	test   %al,%al
  8005bc:	74 16                	je     8005d4 <bc_init+0x108>
  8005be:	68 2f 39 80 00       	push   $0x80392f
  8005c3:	68 7d 37 80 00       	push   $0x80377d
  8005c8:	6a 76                	push   $0x76
  8005ca:	68 98 38 80 00       	push   $0x803898
  8005cf:	e8 b2 13 00 00       	call   801986 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	6a 01                	push   $0x1
  8005d9:	e8 b0 fd ff ff       	call   80038e <diskaddr>
  8005de:	83 c4 08             	add    $0x8,%esp
  8005e1:	68 0e 39 80 00       	push   $0x80390e
  8005e6:	50                   	push   %eax
  8005e7:	e8 a2 1a 00 00       	call   80208e <strcmp>
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	74 16                	je     800609 <bc_init+0x13d>
  8005f3:	68 74 38 80 00       	push   $0x803874
  8005f8:	68 7d 37 80 00       	push   $0x80377d
  8005fd:	6a 79                	push   $0x79
  8005ff:	68 98 38 80 00       	push   $0x803898
  800604:	e8 7d 13 00 00       	call   801986 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	6a 01                	push   $0x1
  80060e:	e8 7b fd ff ff       	call   80038e <diskaddr>
  800613:	83 c4 0c             	add    $0xc,%esp
  800616:	68 08 01 00 00       	push   $0x108
  80061b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800621:	52                   	push   %edx
  800622:	50                   	push   %eax
  800623:	e8 4e 1b 00 00       	call   802176 <memmove>
	flush_block(diskaddr(1));
  800628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062f:	e8 5a fd ff ff       	call   80038e <diskaddr>
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	e8 d0 fd ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  80063c:	c7 04 24 4a 39 80 00 	movl   $0x80394a,(%esp)
  800643:	e8 17 14 00 00       	call   801a5f <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80064f:	e8 3a fd ff ff       	call   80038e <diskaddr>
  800654:	83 c4 0c             	add    $0xc,%esp
  800657:	68 08 01 00 00       	push   $0x108
  80065c:	50                   	push   %eax
  80065d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	e8 0d 1b 00 00       	call   802176 <memmove>
}
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    

0080066e <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800674:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800679:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80067f:	74 14                	je     800695 <check_super+0x27>
		panic("bad file system magic number");
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	68 5f 39 80 00       	push   $0x80395f
  800689:	6a 0f                	push   $0xf
  80068b:	68 7c 39 80 00       	push   $0x80397c
  800690:	e8 f1 12 00 00       	call   801986 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800695:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80069c:	76 14                	jbe    8006b2 <check_super+0x44>
		panic("file system is too large");
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	68 84 39 80 00       	push   $0x803984
  8006a6:	6a 12                	push   $0x12
  8006a8:	68 7c 39 80 00       	push   $0x80397c
  8006ad:	e8 d4 12 00 00       	call   801986 <_panic>

	cprintf("superblock is good\n");
  8006b2:	83 ec 0c             	sub    $0xc,%esp
  8006b5:	68 9d 39 80 00       	push   $0x80399d
  8006ba:	e8 a0 13 00 00       	call   801a5f <cprintf>
}
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	53                   	push   %ebx
  8006c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006cb:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	74 24                	je     8006f9 <block_is_free+0x35>
		return 0;
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006da:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006dd:	76 1f                	jbe    8006fe <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006df:	89 cb                	mov    %ecx,%ebx
  8006e1:	c1 eb 05             	shr    $0x5,%ebx
  8006e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8006e9:	d3 e0                	shl    %cl,%eax
  8006eb:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8006f1:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006f4:	0f 95 c0             	setne  %al
  8006f7:	eb 05                	jmp    8006fe <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8006f9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8006fe:	5b                   	pop    %ebx
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 04             	sub    $0x4,%esp
  800708:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	75 14                	jne    800723 <free_block+0x22>
		panic("attempt to free zero block");
  80070f:	83 ec 04             	sub    $0x4,%esp
  800712:	68 b1 39 80 00       	push   $0x8039b1
  800717:	6a 2d                	push   $0x2d
  800719:	68 7c 39 80 00       	push   $0x80397c
  80071e:	e8 63 12 00 00       	call   801986 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800723:	89 cb                	mov    %ecx,%ebx
  800725:	c1 eb 05             	shr    $0x5,%ebx
  800728:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80072e:	b8 01 00 00 00       	mov    $0x1,%eax
  800733:	d3 e0                	shl    %cl,%eax
  800735:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//edit by Lethe 2018/12/14
	uint32_t bmpblock_start = 2;
	for (uint32_t blockno = 0; blockno < super->s_nblocks; blockno++) {
  800742:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800747:	8b 70 04             	mov    0x4(%eax),%esi
  80074a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074f:	eb 49                	jmp    80079a <alloc_block+0x5d>
		if (block_is_free(blockno)) {                   //搜索free的block
  800751:	53                   	push   %ebx
  800752:	e8 6d ff ff ff       	call   8006c4 <block_is_free>
  800757:	83 c4 04             	add    $0x4,%esp
  80075a:	84 c0                	test   %al,%al
  80075c:	74 39                	je     800797 <alloc_block+0x5a>
			bitmap[blockno / 32] &= ~(1 << (blockno % 32));     //标记为已使用
  80075e:	89 de                	mov    %ebx,%esi
  800760:	c1 ee 05             	shr    $0x5,%esi
  800763:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800769:	b8 01 00 00 00       	mov    $0x1,%eax
  80076e:	89 d9                	mov    %ebx,%ecx
  800770:	d3 e0                	shl    %cl,%eax
  800772:	f7 d0                	not    %eax
  800774:	21 04 b2             	and    %eax,(%edx,%esi,4)
			flush_block(diskaddr(bmpblock_start + (blockno / 32) / NINDIRECT)); 
  800777:	83 ec 0c             	sub    $0xc,%esp
  80077a:	89 d8                	mov    %ebx,%eax
  80077c:	c1 e8 0f             	shr    $0xf,%eax
  80077f:	83 c0 02             	add    $0x2,%eax
  800782:	50                   	push   %eax
  800783:	e8 06 fc ff ff       	call   80038e <diskaddr>
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	e8 7c fc ff ff       	call   80040c <flush_block>
			//将刚刚修改的bitmap block写到磁盘中
			return blockno;
  800790:	89 d8                	mov    %ebx,%eax
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 0c                	jmp    8007a3 <alloc_block+0x66>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//edit by Lethe 2018/12/14
	uint32_t bmpblock_start = 2;
	for (uint32_t blockno = 0; blockno < super->s_nblocks; blockno++) {
  800797:	83 c3 01             	add    $0x1,%ebx
  80079a:	39 f3                	cmp    %esi,%ebx
  80079c:	75 b3                	jne    800751 <alloc_block+0x14>
			//将刚刚修改的bitmap block写到磁盘中
			return blockno;
		}
	}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  80079e:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	57                   	push   %edi
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	83 ec 1c             	sub    $0x1c,%esp
  8007b3:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
	//edit by Lethe 2018/12/14
	int bn;
	uint32_t *indirects;
	if (filebno >= NDIRECT + NINDIRECT)
  8007b6:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007bc:	0f 87 85 00 00 00    	ja     800847 <file_block_walk+0x9d>
		return -E_INVAL;

	if (filebno < NDIRECT) {
  8007c2:	83 fa 09             	cmp    $0x9,%edx
  8007c5:	77 10                	ja     8007d7 <file_block_walk+0x2d>
		*ppdiskbno = &(f->f_direct[filebno]);
  8007c7:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007ce:	89 01                	mov    %eax,(%ecx)
			indirects = diskaddr(bn);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		}
	}

	return 0;
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	eb 7c                	jmp    800853 <file_block_walk+0xa9>
  8007d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007da:	89 d3                	mov    %edx,%ebx
  8007dc:	89 c6                	mov    %eax,%esi

	if (filebno < NDIRECT) {
		*ppdiskbno = &(f->f_direct[filebno]);
	} 
	else {
		if (f->f_indirect) {
  8007de:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	74 1c                	je     800804 <file_block_walk+0x5a>
			indirects = diskaddr(f->f_indirect);
  8007e8:	83 ec 0c             	sub    $0xc,%esp
  8007eb:	50                   	push   %eax
  8007ec:	e8 9d fb ff ff       	call   80038e <diskaddr>
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
  8007f1:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  8007f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007f8:	89 06                	mov    %eax,(%esi)
  8007fa:	83 c4 10             	add    $0x10,%esp
			indirects = diskaddr(bn);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		}
	}

	return 0;
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	eb 4f                	jmp    800853 <file_block_walk+0xa9>
		if (f->f_indirect) {
			indirects = diskaddr(f->f_indirect);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		} 
		else {
			if (!alloc)
  800804:	89 f8                	mov    %edi,%eax
  800806:	84 c0                	test   %al,%al
  800808:	74 44                	je     80084e <file_block_walk+0xa4>
				return -E_NOT_FOUND;
			if ((bn = alloc_block()) < 0)
  80080a:	e8 2e ff ff ff       	call   80073d <alloc_block>
  80080f:	89 c7                	mov    %eax,%edi
  800811:	85 c0                	test   %eax,%eax
  800813:	78 3e                	js     800853 <file_block_walk+0xa9>
				return bn;
			f->f_indirect = bn;
  800815:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			flush_block(diskaddr(bn));
  80081b:	83 ec 0c             	sub    $0xc,%esp
  80081e:	50                   	push   %eax
  80081f:	e8 6a fb ff ff       	call   80038e <diskaddr>
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	e8 e0 fb ff ff       	call   80040c <flush_block>
			indirects = diskaddr(bn);
  80082c:	89 3c 24             	mov    %edi,(%esp)
  80082f:	e8 5a fb ff ff       	call   80038e <diskaddr>
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
  800834:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800838:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80083b:	89 03                	mov    %eax,(%ebx)
  80083d:	83 c4 10             	add    $0x10,%esp
		}
	}

	return 0;
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
  800845:	eb 0c                	jmp    800853 <file_block_walk+0xa9>
       // LAB 5: Your code here.
	//edit by Lethe 2018/12/14
	int bn;
	uint32_t *indirects;
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb 05                	jmp    800853 <file_block_walk+0xa9>
			indirects = diskaddr(f->f_indirect);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		} 
		else {
			if (!alloc)
				return -E_NOT_FOUND;
  80084e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		}
	}

	return 0;
       //panic("file_block_walk not implemented");
}
  800853:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5f                   	pop    %edi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800860:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800865:	8b 70 04             	mov    0x4(%eax),%esi
  800868:	bb 00 00 00 00       	mov    $0x0,%ebx
  80086d:	eb 29                	jmp    800898 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  80086f:	8d 43 02             	lea    0x2(%ebx),%eax
  800872:	50                   	push   %eax
  800873:	e8 4c fe ff ff       	call   8006c4 <block_is_free>
  800878:	83 c4 04             	add    $0x4,%esp
  80087b:	84 c0                	test   %al,%al
  80087d:	74 16                	je     800895 <check_bitmap+0x3a>
  80087f:	68 cc 39 80 00       	push   $0x8039cc
  800884:	68 7d 37 80 00       	push   $0x80377d
  800889:	6a 5a                	push   $0x5a
  80088b:	68 7c 39 80 00       	push   $0x80397c
  800890:	e8 f1 10 00 00       	call   801986 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800895:	83 c3 01             	add    $0x1,%ebx
  800898:	89 d8                	mov    %ebx,%eax
  80089a:	c1 e0 0f             	shl    $0xf,%eax
  80089d:	39 f0                	cmp    %esi,%eax
  80089f:	72 ce                	jb     80086f <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008a1:	83 ec 0c             	sub    $0xc,%esp
  8008a4:	6a 00                	push   $0x0
  8008a6:	e8 19 fe ff ff       	call   8006c4 <block_is_free>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 16                	je     8008c8 <check_bitmap+0x6d>
  8008b2:	68 e0 39 80 00       	push   $0x8039e0
  8008b7:	68 7d 37 80 00       	push   $0x80377d
  8008bc:	6a 5d                	push   $0x5d
  8008be:	68 7c 39 80 00       	push   $0x80397c
  8008c3:	e8 be 10 00 00       	call   801986 <_panic>
	assert(!block_is_free(1));
  8008c8:	83 ec 0c             	sub    $0xc,%esp
  8008cb:	6a 01                	push   $0x1
  8008cd:	e8 f2 fd ff ff       	call   8006c4 <block_is_free>
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	84 c0                	test   %al,%al
  8008d7:	74 16                	je     8008ef <check_bitmap+0x94>
  8008d9:	68 f2 39 80 00       	push   $0x8039f2
  8008de:	68 7d 37 80 00       	push   $0x80377d
  8008e3:	6a 5e                	push   $0x5e
  8008e5:	68 7c 39 80 00       	push   $0x80397c
  8008ea:	e8 97 10 00 00       	call   801986 <_panic>

	cprintf("bitmap is good\n");
  8008ef:	83 ec 0c             	sub    $0xc,%esp
  8008f2:	68 04 3a 80 00       	push   $0x803a04
  8008f7:	e8 63 11 00 00       	call   801a5f <cprintf>
}
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  80090c:	e8 4e f7 ff ff       	call   80005f <ide_probe_disk1>
  800911:	84 c0                	test   %al,%al
  800913:	74 0f                	je     800924 <fs_init+0x1e>
               ide_set_disk(1);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 a4 f7 ff ff       	call   8000c3 <ide_set_disk>
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	eb 0d                	jmp    800931 <fs_init+0x2b>
       else
               ide_set_disk(0);
  800924:	83 ec 0c             	sub    $0xc,%esp
  800927:	6a 00                	push   $0x0
  800929:	e8 95 f7 ff ff       	call   8000c3 <ide_set_disk>
  80092e:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800931:	e8 96 fb ff ff       	call   8004cc <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800936:	83 ec 0c             	sub    $0xc,%esp
  800939:	6a 01                	push   $0x1
  80093b:	e8 4e fa ff ff       	call   80038e <diskaddr>
  800940:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800945:	e8 24 fd ff ff       	call   80066e <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80094a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800951:	e8 38 fa ff ff       	call   80038e <diskaddr>
  800956:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  80095b:	e8 fb fe ff ff       	call   80085b <check_bitmap>
	
}
  800960:	83 c4 10             	add    $0x10,%esp
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 24             	sub    $0x24,%esp
       // LAB 5: Your code here.
	//edit by Lethe 2018/12/14
	int r;
        uint32_t *pdiskbno;
        if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0) {
  80096b:	6a 01                	push   $0x1
  80096d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	e8 2f fe ff ff       	call   8007aa <file_block_walk>
  80097b:	83 c4 10             	add    $0x10,%esp
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 46                	js     8009c8 <file_get_block+0x63>
		return r;
        }

        int bn;
        if (*pdiskbno == 0) {           //此时*pdiskbno保存着文件f第filebno块block的索引
  800982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800985:	83 38 00             	cmpl   $0x0,(%eax)
  800988:	75 24                	jne    8009ae <file_get_block+0x49>
		if ((bn = alloc_block()) < 0) {
  80098a:	e8 ae fd ff ff       	call   80073d <alloc_block>
  80098f:	89 c2                	mov    %eax,%edx
  800991:	85 c0                	test   %eax,%eax
  800993:	78 33                	js     8009c8 <file_get_block+0x63>
  			return bn;
            }
		*pdiskbno = bn;
  800995:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800998:	89 10                	mov    %edx,(%eax)
		flush_block(diskaddr(bn));
  80099a:	83 ec 0c             	sub    $0xc,%esp
  80099d:	52                   	push   %edx
  80099e:	e8 eb f9 ff ff       	call   80038e <diskaddr>
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	e8 61 fa ff ff       	call   80040c <flush_block>
  8009ab:	83 c4 10             	add    $0x10,%esp
        }
        *blk = diskaddr(*pdiskbno);
  8009ae:	83 ec 0c             	sub    $0xc,%esp
  8009b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b4:	ff 30                	pushl  (%eax)
  8009b6:	e8 d3 f9 ff ff       	call   80038e <diskaddr>
  8009bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009be:	89 02                	mov    %eax,(%edx)
        return 0;
  8009c0:	83 c4 10             	add    $0x10,%esp
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
       //panic("file_get_block not implemented");
}
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009d6:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009dc:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009e2:	eb 03                	jmp    8009e7 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009e4:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009e7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8009ea:	74 f8                	je     8009e4 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009ec:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8009f2:	83 c1 08             	add    $0x8,%ecx
  8009f5:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8009fb:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800a02:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 06                	je     800a12 <walk_path+0x48>
		*pdir = 0;
  800a0c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a12:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a18:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a23:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a29:	e9 5f 01 00 00       	jmp    800b8d <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a2e:	83 c7 01             	add    $0x1,%edi
  800a31:	eb 02                	jmp    800a35 <walk_path+0x6b>
  800a33:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a35:	0f b6 17             	movzbl (%edi),%edx
  800a38:	80 fa 2f             	cmp    $0x2f,%dl
  800a3b:	74 04                	je     800a41 <walk_path+0x77>
  800a3d:	84 d2                	test   %dl,%dl
  800a3f:	75 ed                	jne    800a2e <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a41:	89 fb                	mov    %edi,%ebx
  800a43:	29 c3                	sub    %eax,%ebx
  800a45:	83 fb 7f             	cmp    $0x7f,%ebx
  800a48:	0f 8f 69 01 00 00    	jg     800bb7 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a4e:	83 ec 04             	sub    $0x4,%esp
  800a51:	53                   	push   %ebx
  800a52:	50                   	push   %eax
  800a53:	56                   	push   %esi
  800a54:	e8 1d 17 00 00       	call   802176 <memmove>
		name[path - p] = '\0';
  800a59:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a60:	00 
  800a61:	83 c4 10             	add    $0x10,%esp
  800a64:	eb 03                	jmp    800a69 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a66:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a69:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a6c:	74 f8                	je     800a66 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a6e:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a74:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a7b:	0f 85 3d 01 00 00    	jne    800bbe <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a81:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a87:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a8c:	74 19                	je     800aa7 <walk_path+0xdd>
  800a8e:	68 14 3a 80 00       	push   $0x803a14
  800a93:	68 7d 37 80 00       	push   $0x80377d
  800a98:	68 e1 00 00 00       	push   $0xe1
  800a9d:	68 7c 39 80 00       	push   $0x80397c
  800aa2:	e8 df 0e 00 00       	call   801986 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800aa7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	0f 48 c2             	cmovs  %edx,%eax
  800ab2:	c1 f8 0c             	sar    $0xc,%eax
  800ab5:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800abb:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800ac2:	00 00 00 
  800ac5:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800acb:	eb 5e                	jmp    800b2b <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800acd:	83 ec 04             	sub    $0x4,%esp
  800ad0:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800ad6:	50                   	push   %eax
  800ad7:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800add:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ae3:	e8 7d fe ff ff       	call   800965 <file_get_block>
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	0f 88 ee 00 00 00    	js     800be1 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800af3:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800af9:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800aff:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	e8 7f 15 00 00       	call   80208e <strcmp>
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	85 c0                	test   %eax,%eax
  800b14:	0f 84 ab 00 00 00    	je     800bc5 <walk_path+0x1fb>
  800b1a:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b20:	39 fb                	cmp    %edi,%ebx
  800b22:	75 db                	jne    800aff <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b24:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b2b:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b31:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b37:	75 94                	jne    800acd <walk_path+0x103>
  800b39:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b3f:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b44:	80 3f 00             	cmpb   $0x0,(%edi)
  800b47:	0f 85 a3 00 00 00    	jne    800bf0 <walk_path+0x226>
				if (pdir)
  800b4d:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b53:	85 c0                	test   %eax,%eax
  800b55:	74 08                	je     800b5f <walk_path+0x195>
					*pdir = dir;
  800b57:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b5d:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b5f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b63:	74 15                	je     800b7a <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b6e:	50                   	push   %eax
  800b6f:	ff 75 08             	pushl  0x8(%ebp)
  800b72:	e8 6d 14 00 00       	call   801fe4 <strcpy>
  800b77:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b7a:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b86:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b8b:	eb 63                	jmp    800bf0 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b8d:	80 38 00             	cmpb   $0x0,(%eax)
  800b90:	0f 85 9d fe ff ff    	jne    800a33 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800b96:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	74 02                	je     800ba2 <walk_path+0x1d8>
		*pdir = dir;
  800ba0:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ba2:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800ba8:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800bae:	89 08                	mov    %ecx,(%eax)
	return 0;
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	eb 39                	jmp    800bf0 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800bb7:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bbc:	eb 32                	jmp    800bf0 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800bbe:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bc3:	eb 2b                	jmp    800bf0 <walk_path+0x226>
  800bc5:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bcb:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800bd1:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bd7:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bdd:	89 f8                	mov    %edi,%eax
  800bdf:	eb ac                	jmp    800b8d <walk_path+0x1c3>
  800be1:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800be7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800bea:	0f 84 4f ff ff ff    	je     800b3f <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800bfe:	6a 00                	push   $0x0
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	e8 ba fd ff ff       	call   8009ca <walk_path>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 2c             	sub    $0x2c,%esp
  800c1b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c1e:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c2a:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c2f:	39 ca                	cmp    %ecx,%edx
  800c31:	7e 7c                	jle    800caf <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c33:	29 ca                	sub    %ecx,%edx
  800c35:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c38:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c3c:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c3f:	89 ce                	mov    %ecx,%esi
  800c41:	01 d1                	add    %edx,%ecx
  800c43:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c46:	eb 5d                	jmp    800ca5 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c48:	83 ec 04             	sub    $0x4,%esp
  800c4b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c4e:	50                   	push   %eax
  800c4f:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c55:	85 f6                	test   %esi,%esi
  800c57:	0f 49 c6             	cmovns %esi,%eax
  800c5a:	c1 f8 0c             	sar    $0xc,%eax
  800c5d:	50                   	push   %eax
  800c5e:	ff 75 08             	pushl  0x8(%ebp)
  800c61:	e8 ff fc ff ff       	call   800965 <file_get_block>
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	78 42                	js     800caf <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c6d:	89 f2                	mov    %esi,%edx
  800c6f:	c1 fa 1f             	sar    $0x1f,%edx
  800c72:	c1 ea 14             	shr    $0x14,%edx
  800c75:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c78:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c7d:	29 d0                	sub    %edx,%eax
  800c7f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c82:	29 da                	sub    %ebx,%edx
  800c84:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800c89:	29 c3                	sub    %eax,%ebx
  800c8b:	39 da                	cmp    %ebx,%edx
  800c8d:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c90:	83 ec 04             	sub    $0x4,%esp
  800c93:	53                   	push   %ebx
  800c94:	03 45 e4             	add    -0x1c(%ebp),%eax
  800c97:	50                   	push   %eax
  800c98:	57                   	push   %edi
  800c99:	e8 d8 14 00 00       	call   802176 <memmove>
		pos += bn;
  800c9e:	01 de                	add    %ebx,%esi
		buf += bn;
  800ca0:	01 df                	add    %ebx,%edi
  800ca2:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800ca5:	89 f3                	mov    %esi,%ebx
  800ca7:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800caa:	77 9c                	ja     800c48 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800cac:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 2c             	sub    $0x2c,%esp
  800cc0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800cc3:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cc9:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800ccc:	0f 8e a7 00 00 00    	jle    800d79 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800cd2:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800cd8:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cdd:	0f 49 f8             	cmovns %eax,%edi
  800ce0:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce6:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cee:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800cf4:	0f 49 c2             	cmovns %edx,%eax
  800cf7:	c1 f8 0c             	sar    $0xc,%eax
  800cfa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800cfd:	89 c3                	mov    %eax,%ebx
  800cff:	eb 39                	jmp    800d3a <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	6a 00                	push   $0x0
  800d06:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d09:	89 da                	mov    %ebx,%edx
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	e8 98 fa ff ff       	call   8007aa <file_block_walk>
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	85 c0                	test   %eax,%eax
  800d17:	78 4d                	js     800d66 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d1c:	8b 00                	mov    (%eax),%eax
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	74 15                	je     800d37 <file_set_size+0x80>
		free_block(*ptr);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	e8 d6 f9 ff ff       	call   800701 <free_block>
		*ptr = 0;
  800d2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d34:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d37:	83 c3 01             	add    $0x1,%ebx
  800d3a:	39 df                	cmp    %ebx,%edi
  800d3c:	77 c3                	ja     800d01 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d3e:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d42:	77 35                	ja     800d79 <file_set_size+0xc2>
  800d44:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	74 2b                	je     800d79 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	e8 aa f9 ff ff       	call   800701 <free_block>
		f->f_indirect = 0;
  800d57:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d5e:	00 00 00 
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	eb 13                	jmp    800d79 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	50                   	push   %eax
  800d6a:	68 31 3a 80 00       	push   $0x803a31
  800d6f:	e8 eb 0c 00 00       	call   801a5f <cprintf>
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	eb be                	jmp    800d37 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	56                   	push   %esi
  800d86:	e8 81 f6 ff ff       	call   80040c <flush_block>
	return 0;
}
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 2c             	sub    $0x2c,%esp
  800da1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800da4:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	03 45 10             	add    0x10(%ebp),%eax
  800dac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800daf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db2:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800db8:	76 72                	jbe    800e2c <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800dba:	83 ec 08             	sub    $0x8,%esp
  800dbd:	50                   	push   %eax
  800dbe:	51                   	push   %ecx
  800dbf:	e8 f3 fe ff ff       	call   800cb7 <file_set_size>
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	79 61                	jns    800e2c <file_write+0x94>
  800dcb:	eb 69                	jmp    800e36 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800dd3:	50                   	push   %eax
  800dd4:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800dda:	85 f6                	test   %esi,%esi
  800ddc:	0f 49 c6             	cmovns %esi,%eax
  800ddf:	c1 f8 0c             	sar    $0xc,%eax
  800de2:	50                   	push   %eax
  800de3:	ff 75 08             	pushl  0x8(%ebp)
  800de6:	e8 7a fb ff ff       	call   800965 <file_get_block>
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	78 44                	js     800e36 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800df2:	89 f2                	mov    %esi,%edx
  800df4:	c1 fa 1f             	sar    $0x1f,%edx
  800df7:	c1 ea 14             	shr    $0x14,%edx
  800dfa:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800dfd:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e02:	29 d0                	sub    %edx,%eax
  800e04:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e07:	29 d9                	sub    %ebx,%ecx
  800e09:	89 cb                	mov    %ecx,%ebx
  800e0b:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e10:	29 c2                	sub    %eax,%edx
  800e12:	39 d1                	cmp    %edx,%ecx
  800e14:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	53                   	push   %ebx
  800e1b:	57                   	push   %edi
  800e1c:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e1f:	50                   	push   %eax
  800e20:	e8 51 13 00 00       	call   802176 <memmove>
		pos += bn;
  800e25:	01 de                	add    %ebx,%esi
		buf += bn;
  800e27:	01 df                	add    %ebx,%edi
  800e29:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e2c:	89 f3                	mov    %esi,%ebx
  800e2e:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e31:	77 9a                	ja     800dcd <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e33:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
  800e43:	83 ec 10             	sub    $0x10,%esp
  800e46:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4e:	eb 3c                	jmp    800e8c <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	6a 00                	push   $0x0
  800e55:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e58:	89 da                	mov    %ebx,%edx
  800e5a:	89 f0                	mov    %esi,%eax
  800e5c:	e8 49 f9 ff ff       	call   8007aa <file_block_walk>
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 21                	js     800e89 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	74 1a                	je     800e89 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e6f:	8b 00                	mov    (%eax),%eax
  800e71:	85 c0                	test   %eax,%eax
  800e73:	74 14                	je     800e89 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	50                   	push   %eax
  800e79:	e8 10 f5 ff ff       	call   80038e <diskaddr>
  800e7e:	89 04 24             	mov    %eax,(%esp)
  800e81:	e8 86 f5 ff ff       	call   80040c <flush_block>
  800e86:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e89:	83 c3 01             	add    $0x1,%ebx
  800e8c:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800e92:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800e98:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800e9e:	85 c9                	test   %ecx,%ecx
  800ea0:	0f 49 c1             	cmovns %ecx,%eax
  800ea3:	c1 f8 0c             	sar    $0xc,%eax
  800ea6:	39 c3                	cmp    %eax,%ebx
  800ea8:	7c a6                	jl     800e50 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	56                   	push   %esi
  800eae:	e8 59 f5 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  800eb3:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	74 14                	je     800ed4 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	50                   	push   %eax
  800ec4:	e8 c5 f4 ff ff       	call   80038e <diskaddr>
  800ec9:	89 04 24             	mov    %eax,(%esp)
  800ecc:	e8 3b f5 ff ff       	call   80040c <flush_block>
  800ed1:	83 c4 10             	add    $0x10,%esp
}
  800ed4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800ee7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800eed:	50                   	push   %eax
  800eee:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800ef4:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
  800efd:	e8 c8 fa ff ff       	call   8009ca <walk_path>
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	0f 84 d1 00 00 00    	je     800fde <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f0d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f10:	0f 85 0c 01 00 00    	jne    801022 <file_create+0x147>
  800f16:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f1c:	85 f6                	test   %esi,%esi
  800f1e:	0f 84 c1 00 00 00    	je     800fe5 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f24:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f2a:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f2f:	74 19                	je     800f4a <file_create+0x6f>
  800f31:	68 14 3a 80 00       	push   $0x803a14
  800f36:	68 7d 37 80 00       	push   $0x80377d
  800f3b:	68 fa 00 00 00       	push   $0xfa
  800f40:	68 7c 39 80 00       	push   $0x80397c
  800f45:	e8 3c 0a 00 00       	call   801986 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f4a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f50:	85 c0                	test   %eax,%eax
  800f52:	0f 48 c2             	cmovs  %edx,%eax
  800f55:	c1 f8 0c             	sar    $0xc,%eax
  800f58:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f63:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f69:	eb 3b                	jmp    800fa6 <file_create+0xcb>
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	57                   	push   %edi
  800f6f:	53                   	push   %ebx
  800f70:	56                   	push   %esi
  800f71:	e8 ef f9 ff ff       	call   800965 <file_get_block>
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	0f 88 a1 00 00 00    	js     801022 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800f81:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f87:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f8d:	80 38 00             	cmpb   $0x0,(%eax)
  800f90:	75 08                	jne    800f9a <file_create+0xbf>
				*file = &f[j];
  800f92:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f98:	eb 52                	jmp    800fec <file_create+0x111>
  800f9a:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800f9f:	39 d0                	cmp    %edx,%eax
  800fa1:	75 ea                	jne    800f8d <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fa3:	83 c3 01             	add    $0x1,%ebx
  800fa6:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800fac:	75 bd                	jne    800f6b <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800fae:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fb5:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	53                   	push   %ebx
  800fc3:	56                   	push   %esi
  800fc4:	e8 9c f9 ff ff       	call   800965 <file_get_block>
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 52                	js     801022 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fd0:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fd6:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fdc:	eb 0e                	jmp    800fec <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800fde:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800fe3:	eb 3d                	jmp    801022 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800fe5:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800fea:	eb 36                	jmp    801022 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ff5:	50                   	push   %eax
  800ff6:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800ffc:	e8 e3 0f 00 00       	call   801fe4 <strcpy>
	*pf = f;
  801001:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100a:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80100c:	83 c4 04             	add    $0x4,%esp
  80100f:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801015:	e8 24 fe ff ff       	call   800e3e <file_flush>
	return 0;
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	53                   	push   %ebx
  80102e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801031:	bb 01 00 00 00       	mov    $0x1,%ebx
  801036:	eb 17                	jmp    80104f <fs_sync+0x25>
		flush_block(diskaddr(i));
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	53                   	push   %ebx
  80103c:	e8 4d f3 ff ff       	call   80038e <diskaddr>
  801041:	89 04 24             	mov    %eax,(%esp)
  801044:	e8 c3 f3 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801049:	83 c3 01             	add    $0x1,%ebx
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801054:	39 58 04             	cmp    %ebx,0x4(%eax)
  801057:	77 df                	ja     801038 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801059:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    

0080105e <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801064:	e8 c1 ff ff ff       	call   80102a <fs_sync>
	return 0;
}
  801069:	b8 00 00 00 00       	mov    $0x0,%eax
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  801078:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801082:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801084:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801087:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80108d:	83 c0 01             	add    $0x1,%eax
  801090:	83 c2 10             	add    $0x10,%edx
  801093:	3d 00 04 00 00       	cmp    $0x400,%eax
  801098:	75 e8                	jne    801082 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	c1 e0 04             	shl    $0x4,%eax
  8010b1:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010b7:	e8 d7 1e 00 00       	call   802f93 <pageref>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	74 07                	je     8010ca <openfile_alloc+0x2e>
  8010c3:	83 f8 01             	cmp    $0x1,%eax
  8010c6:	74 20                	je     8010e8 <openfile_alloc+0x4c>
  8010c8:	eb 51                	jmp    80111b <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010ca:	83 ec 04             	sub    $0x4,%esp
  8010cd:	6a 07                	push   $0x7
  8010cf:	89 d8                	mov    %ebx,%eax
  8010d1:	c1 e0 04             	shl    $0x4,%eax
  8010d4:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 06 13 00 00       	call   8023e7 <sys_page_alloc>
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 43                	js     80112b <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010e8:	c1 e3 04             	shl    $0x4,%ebx
  8010eb:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8010f1:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8010f8:	04 00 00 
			*o = &opentab[i];
  8010fb:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	68 00 10 00 00       	push   $0x1000
  801105:	6a 00                	push   $0x0
  801107:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80110d:	e8 17 10 00 00       	call   802129 <memset>
			return (*o)->o_fileid;
  801112:	8b 06                	mov    (%esi),%eax
  801114:	8b 00                	mov    (%eax),%eax
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	eb 10                	jmp    80112b <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80111b:	83 c3 01             	add    $0x1,%ebx
  80111e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801124:	75 83                	jne    8010a9 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801126:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80112b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    

00801132 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 18             	sub    $0x18,%esp
  80113b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80113e:	89 fb                	mov    %edi,%ebx
  801140:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801146:	89 de                	mov    %ebx,%esi
  801148:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80114b:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801151:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801157:	e8 37 1e 00 00       	call   802f93 <pageref>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	83 f8 01             	cmp    $0x1,%eax
  801162:	7e 17                	jle    80117b <openfile_lookup+0x49>
  801164:	c1 e3 04             	shl    $0x4,%ebx
  801167:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  80116d:	75 13                	jne    801182 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  80116f:	8b 45 10             	mov    0x10(%ebp),%eax
  801172:	89 30                	mov    %esi,(%eax)
	return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	eb 0c                	jmp    801187 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80117b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801180:	eb 05                	jmp    801187 <openfile_lookup+0x55>
  801182:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  801187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	53                   	push   %ebx
  801193:	83 ec 18             	sub    $0x18,%esp
  801196:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	ff 33                	pushl  (%ebx)
  80119f:	ff 75 08             	pushl  0x8(%ebp)
  8011a2:	e8 8b ff ff ff       	call   801132 <openfile_lookup>
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 14                	js     8011c2 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	ff 73 04             	pushl  0x4(%ebx)
  8011b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b7:	ff 70 04             	pushl  0x4(%eax)
  8011ba:	e8 f8 fa ff ff       	call   800cb7 <file_set_size>
  8011bf:	83 c4 10             	add    $0x10,%esp
}
  8011c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 18             	sub    $0x18,%esp
  8011ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:
	//edit by Lethe 2018/12/14
	struct OpenFile *o;
	int r;
	r = openfile_lookup(envid, req->req_fileid, &o);
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	ff 33                	pushl  (%ebx)
  8011d7:	ff 75 08             	pushl  0x8(%ebp)
  8011da:	e8 53 ff ff ff       	call   801132 <openfile_lookup>
	if (r < 0)      //通过fileid找到Openfile结构
  8011df:	83 c4 10             	add    $0x10,%esp
		return r;
  8011e2:	89 c2                	mov    %eax,%edx
	// Lab 5: Your code here:
	//edit by Lethe 2018/12/14
	struct OpenFile *o;
	int r;
	r = openfile_lookup(envid, req->req_fileid, &o);
	if (r < 0)      //通过fileid找到Openfile结构
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 2b                	js     801213 <serve_read+0x4c>
		return r;
	if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)   
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	8b 50 0c             	mov    0xc(%eax),%edx
  8011ee:	ff 72 04             	pushl  0x4(%edx)
  8011f1:	ff 73 04             	pushl  0x4(%ebx)
  8011f4:	53                   	push   %ebx
  8011f5:	ff 70 04             	pushl  0x4(%eax)
  8011f8:	e8 15 fa ff ff       	call   800c12 <file_read>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 0d                	js     801211 <serve_read+0x4a>
		//调用fs.c中函数进行真正的读操作
		return r;
	o->o_fd->fd_offset += r;
  801204:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801207:	8b 52 0c             	mov    0xc(%edx),%edx
  80120a:	01 42 04             	add    %eax,0x4(%edx)
    
	return r;
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	eb 02                	jmp    801213 <serve_read+0x4c>
	r = openfile_lookup(envid, req->req_fileid, &o);
	if (r < 0)      //通过fileid找到Openfile结构
		return r;
	if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)   
		//调用fs.c中函数进行真正的读操作
		return r;
  801211:	89 c2                	mov    %eax,%edx
	o->o_fd->fd_offset += r;
    
	return r;
	//return 0;
}
  801213:	89 d0                	mov    %edx,%eax
  801215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 20             	sub    $0x20,%esp
  801223:	8b 75 0c             	mov    0xc(%ebp),%esi

	// LAB 5: Your code here.
	//edit byLethe 2018/12/14
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  801226:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	ff 36                	pushl  (%esi)
  80122c:	ff 75 08             	pushl  0x8(%ebp)
  80122f:	e8 fe fe ff ff       	call   801132 <openfile_lookup>
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 36                	js     801271 <serve_write+0x57>
  80123b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return r;
	}
	int total = 0;
	while (1) {
		r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  801240:	8d 7e 08             	lea    0x8(%esi),%edi
  801243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801246:	8b 50 0c             	mov    0xc(%eax),%edx
  801249:	ff 72 04             	pushl  0x4(%edx)
  80124c:	ff 76 04             	pushl  0x4(%esi)
  80124f:	57                   	push   %edi
  801250:	ff 70 04             	pushl  0x4(%eax)
  801253:	e8 40 fb ff ff       	call   800d98 <file_write>
		if (r < 0) 
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 12                	js     801271 <serve_write+0x57>
			return r;
		total += r;
  80125f:	01 c3                	add    %eax,%ebx
		o->o_fd->fd_offset += r;
  801261:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801264:	8b 52 0c             	mov    0xc(%edx),%edx
  801267:	01 42 04             	add    %eax,0x4(%edx)
		if (req->req_n <= total)
  80126a:	39 5e 04             	cmp    %ebx,0x4(%esi)
  80126d:	77 d4                	ja     801243 <serve_write+0x29>
	int total = 0;
	while (1) {
		r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
		if (r < 0) 
			return r;
		total += r;
  80126f:	89 d8                	mov    %ebx,%eax
		if (req->req_n <= total)
			break;
	}
	return total;
	//panic("serve_write not implemented");
}
  801271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801274:	5b                   	pop    %ebx
  801275:	5e                   	pop    %esi
  801276:	5f                   	pop    %edi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	53                   	push   %ebx
  80127d:	83 ec 18             	sub    $0x18,%esp
  801280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801283:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	ff 33                	pushl  (%ebx)
  801289:	ff 75 08             	pushl  0x8(%ebp)
  80128c:	e8 a1 fe ff ff       	call   801132 <openfile_lookup>
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	78 3f                	js     8012d7 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129e:	ff 70 04             	pushl  0x4(%eax)
  8012a1:	53                   	push   %ebx
  8012a2:	e8 3d 0d 00 00       	call   801fe4 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012aa:	8b 50 04             	mov    0x4(%eax),%edx
  8012ad:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012b3:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012b9:	8b 40 04             	mov    0x4(%eax),%eax
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012c6:	0f 94 c0             	sete   %al
  8012c9:	0f b6 c0             	movzbl %al,%eax
  8012cc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012da:	c9                   	leave  
  8012db:	c3                   	ret    

008012dc <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e9:	ff 30                	pushl  (%eax)
  8012eb:	ff 75 08             	pushl  0x8(%ebp)
  8012ee:	e8 3f fe ff ff       	call   801132 <openfile_lookup>
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 16                	js     801310 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801300:	ff 70 04             	pushl  0x4(%eax)
  801303:	e8 36 fb ff ff       	call   800e3e <file_flush>
	return 0;
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	53                   	push   %ebx
  801316:	81 ec 18 04 00 00    	sub    $0x418,%esp
  80131c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  80131f:	68 00 04 00 00       	push   $0x400
  801324:	53                   	push   %ebx
  801325:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	e8 45 0e 00 00       	call   802176 <memmove>
	path[MAXPATHLEN-1] = 0;
  801331:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801335:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	e8 59 fd ff ff       	call   80109c <openfile_alloc>
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	0f 88 f0 00 00 00    	js     80143e <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  80134e:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801355:	74 33                	je     80138a <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	e8 6e fb ff ff       	call   800edb <file_create>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	79 37                	jns    8013ab <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801374:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80137b:	0f 85 bd 00 00 00    	jne    80143e <serve_open+0x12c>
  801381:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801384:	0f 85 b4 00 00 00    	jne    80143e <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	e8 58 f8 ff ff       	call   800bf8 <file_open>
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	0f 88 93 00 00 00    	js     80143e <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013ab:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013b2:	74 17                	je     8013cb <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	6a 00                	push   $0x0
  8013b9:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013bf:	e8 f3 f8 ff ff       	call   800cb7 <file_set_size>
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 73                	js     80143e <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	e8 17 f8 ff ff       	call   800bf8 <file_open>
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	78 56                	js     80143e <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8013e8:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013ee:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8013f4:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8013f7:	8b 50 0c             	mov    0xc(%eax),%edx
  8013fa:	8b 08                	mov    (%eax),%ecx
  8013fc:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8013ff:	8b 48 0c             	mov    0xc(%eax),%ecx
  801402:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801408:	83 e2 03             	and    $0x3,%edx
  80140b:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80140e:	8b 40 0c             	mov    0xc(%eax),%eax
  801411:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801417:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801419:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80141f:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801425:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801428:	8b 50 0c             	mov    0xc(%eax),%edx
  80142b:	8b 45 10             	mov    0x10(%ebp),%eax
  80142e:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801430:	8b 45 14             	mov    0x14(%ebp),%eax
  801433:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	56                   	push   %esi
  801447:	53                   	push   %ebx
  801448:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80144b:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80144e:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801451:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	53                   	push   %ebx
  80145c:	ff 35 44 50 80 00    	pushl  0x805044
  801462:	56                   	push   %esi
  801463:	e8 08 12 00 00       	call   802670 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80146f:	75 15                	jne    801486 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 f4             	pushl  -0xc(%ebp)
  801477:	68 50 3a 80 00       	push   $0x803a50
  80147c:	e8 de 05 00 00       	call   801a5f <cprintf>
				whom);
			continue; // just leave it hanging...
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	eb cb                	jmp    801451 <serve+0xe>
		}

		pg = NULL;
  801486:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80148d:	83 f8 01             	cmp    $0x1,%eax
  801490:	75 18                	jne    8014aa <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801492:	53                   	push   %ebx
  801493:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 35 44 50 80 00    	pushl  0x805044
  80149d:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a0:	e8 6d fe ff ff       	call   801312 <serve_open>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	eb 3c                	jmp    8014e6 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014aa:	83 f8 08             	cmp    $0x8,%eax
  8014ad:	77 1e                	ja     8014cd <serve+0x8a>
  8014af:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014b6:	85 d2                	test   %edx,%edx
  8014b8:	74 13                	je     8014cd <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	ff 35 44 50 80 00    	pushl  0x805044
  8014c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c6:	ff d2                	call   *%edx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	eb 19                	jmp    8014e6 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014cd:	83 ec 04             	sub    $0x4,%esp
  8014d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d3:	50                   	push   %eax
  8014d4:	68 80 3a 80 00       	push   $0x803a80
  8014d9:	e8 81 05 00 00       	call   801a5f <cprintf>
  8014de:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8014e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8014e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8014e9:	ff 75 ec             	pushl  -0x14(%ebp)
  8014ec:	50                   	push   %eax
  8014ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f0:	e8 13 12 00 00       	call   802708 <ipc_send>
		sys_page_unmap(0, fsreq);
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	ff 35 44 50 80 00    	pushl  0x805044
  8014fe:	6a 00                	push   $0x0
  801500:	e8 67 0f 00 00       	call   80246c <sys_page_unmap>
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	e9 44 ff ff ff       	jmp    801451 <serve+0xe>

0080150d <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801513:	c7 05 60 90 80 00 a3 	movl   $0x803aa3,0x809060
  80151a:	3a 80 00 
	cprintf("FS is running\n");
  80151d:	68 a6 3a 80 00       	push   $0x803aa6
  801522:	e8 38 05 00 00       	call   801a5f <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801527:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80152c:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801531:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801533:	c7 04 24 b5 3a 80 00 	movl   $0x803ab5,(%esp)
  80153a:	e8 20 05 00 00       	call   801a5f <cprintf>

	serve_init();
  80153f:	e8 2c fb ff ff       	call   801070 <serve_init>
	fs_init();
  801544:	e8 bd f3 ff ff       	call   800906 <fs_init>
        fs_test();
  801549:	e8 05 00 00 00       	call   801553 <fs_test>
	serve();
  80154e:	e8 f0 fe ff ff       	call   801443 <serve>

00801553 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80155a:	6a 07                	push   $0x7
  80155c:	68 00 10 00 00       	push   $0x1000
  801561:	6a 00                	push   $0x0
  801563:	e8 7f 0e 00 00       	call   8023e7 <sys_page_alloc>
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	79 12                	jns    801581 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80156f:	50                   	push   %eax
  801570:	68 c4 3a 80 00       	push   $0x803ac4
  801575:	6a 12                	push   $0x12
  801577:	68 d7 3a 80 00       	push   $0x803ad7
  80157c:	e8 05 04 00 00       	call   801986 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801581:	83 ec 04             	sub    $0x4,%esp
  801584:	68 00 10 00 00       	push   $0x1000
  801589:	ff 35 04 a0 80 00    	pushl  0x80a004
  80158f:	68 00 10 00 00       	push   $0x1000
  801594:	e8 dd 0b 00 00       	call   802176 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801599:	e8 9f f1 ff ff       	call   80073d <alloc_block>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	79 12                	jns    8015b7 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8015a5:	50                   	push   %eax
  8015a6:	68 e1 3a 80 00       	push   $0x803ae1
  8015ab:	6a 17                	push   $0x17
  8015ad:	68 d7 3a 80 00       	push   $0x803ad7
  8015b2:	e8 cf 03 00 00       	call   801986 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015b7:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	0f 49 d0             	cmovns %eax,%edx
  8015bf:	c1 fa 05             	sar    $0x5,%edx
  8015c2:	89 c3                	mov    %eax,%ebx
  8015c4:	c1 fb 1f             	sar    $0x1f,%ebx
  8015c7:	c1 eb 1b             	shr    $0x1b,%ebx
  8015ca:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015cd:	83 e1 1f             	and    $0x1f,%ecx
  8015d0:	29 d9                	sub    %ebx,%ecx
  8015d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d7:	d3 e0                	shl    %cl,%eax
  8015d9:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8015e0:	75 16                	jne    8015f8 <fs_test+0xa5>
  8015e2:	68 f1 3a 80 00       	push   $0x803af1
  8015e7:	68 7d 37 80 00       	push   $0x80377d
  8015ec:	6a 19                	push   $0x19
  8015ee:	68 d7 3a 80 00       	push   $0x803ad7
  8015f3:	e8 8e 03 00 00       	call   801986 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015f8:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8015fe:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801601:	74 16                	je     801619 <fs_test+0xc6>
  801603:	68 6c 3c 80 00       	push   $0x803c6c
  801608:	68 7d 37 80 00       	push   $0x80377d
  80160d:	6a 1b                	push   $0x1b
  80160f:	68 d7 3a 80 00       	push   $0x803ad7
  801614:	e8 6d 03 00 00       	call   801986 <_panic>
	cprintf("alloc_block is good\n");
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	68 0c 3b 80 00       	push   $0x803b0c
  801621:	e8 39 04 00 00       	call   801a5f <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	68 21 3b 80 00       	push   $0x803b21
  801632:	e8 c1 f5 ff ff       	call   800bf8 <file_open>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80163d:	74 1b                	je     80165a <fs_test+0x107>
  80163f:	89 c2                	mov    %eax,%edx
  801641:	c1 ea 1f             	shr    $0x1f,%edx
  801644:	84 d2                	test   %dl,%dl
  801646:	74 12                	je     80165a <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801648:	50                   	push   %eax
  801649:	68 2c 3b 80 00       	push   $0x803b2c
  80164e:	6a 1f                	push   $0x1f
  801650:	68 d7 3a 80 00       	push   $0x803ad7
  801655:	e8 2c 03 00 00       	call   801986 <_panic>
	else if (r == 0)
  80165a:	85 c0                	test   %eax,%eax
  80165c:	75 14                	jne    801672 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	68 8c 3c 80 00       	push   $0x803c8c
  801666:	6a 21                	push   $0x21
  801668:	68 d7 3a 80 00       	push   $0x803ad7
  80166d:	e8 14 03 00 00       	call   801986 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	68 45 3b 80 00       	push   $0x803b45
  80167e:	e8 75 f5 ff ff       	call   800bf8 <file_open>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	79 12                	jns    80169c <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80168a:	50                   	push   %eax
  80168b:	68 4e 3b 80 00       	push   $0x803b4e
  801690:	6a 23                	push   $0x23
  801692:	68 d7 3a 80 00       	push   $0x803ad7
  801697:	e8 ea 02 00 00       	call   801986 <_panic>
	cprintf("file_open is good\n");
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	68 65 3b 80 00       	push   $0x803b65
  8016a4:	e8 b6 03 00 00       	call   801a5f <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016a9:	83 c4 0c             	add    $0xc,%esp
  8016ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	6a 00                	push   $0x0
  8016b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b5:	e8 ab f2 ff ff       	call   800965 <file_get_block>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	79 12                	jns    8016d3 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016c1:	50                   	push   %eax
  8016c2:	68 78 3b 80 00       	push   $0x803b78
  8016c7:	6a 27                	push   $0x27
  8016c9:	68 d7 3a 80 00       	push   $0x803ad7
  8016ce:	e8 b3 02 00 00       	call   801986 <_panic>
	if (strcmp(blk, msg) != 0)
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	68 ac 3c 80 00       	push   $0x803cac
  8016db:	ff 75 f0             	pushl  -0x10(%ebp)
  8016de:	e8 ab 09 00 00       	call   80208e <strcmp>
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	74 14                	je     8016fe <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8016ea:	83 ec 04             	sub    $0x4,%esp
  8016ed:	68 d4 3c 80 00       	push   $0x803cd4
  8016f2:	6a 29                	push   $0x29
  8016f4:	68 d7 3a 80 00       	push   $0x803ad7
  8016f9:	e8 88 02 00 00       	call   801986 <_panic>
	cprintf("file_get_block is good\n");
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	68 8b 3b 80 00       	push   $0x803b8b
  801706:	e8 54 03 00 00       	call   801a5f <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	0f b6 10             	movzbl (%eax),%edx
  801711:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	c1 e8 0c             	shr    $0xc,%eax
  801719:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	a8 40                	test   $0x40,%al
  801725:	75 16                	jne    80173d <fs_test+0x1ea>
  801727:	68 a4 3b 80 00       	push   $0x803ba4
  80172c:	68 7d 37 80 00       	push   $0x80377d
  801731:	6a 2d                	push   $0x2d
  801733:	68 d7 3a 80 00       	push   $0x803ad7
  801738:	e8 49 02 00 00       	call   801986 <_panic>
	file_flush(f);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	ff 75 f4             	pushl  -0xc(%ebp)
  801743:	e8 f6 f6 ff ff       	call   800e3e <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174b:	c1 e8 0c             	shr    $0xc,%eax
  80174e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	a8 40                	test   $0x40,%al
  80175a:	74 16                	je     801772 <fs_test+0x21f>
  80175c:	68 a3 3b 80 00       	push   $0x803ba3
  801761:	68 7d 37 80 00       	push   $0x80377d
  801766:	6a 2f                	push   $0x2f
  801768:	68 d7 3a 80 00       	push   $0x803ad7
  80176d:	e8 14 02 00 00       	call   801986 <_panic>
	cprintf("file_flush is good\n");
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	68 bf 3b 80 00       	push   $0x803bbf
  80177a:	e8 e0 02 00 00       	call   801a5f <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80177f:	83 c4 08             	add    $0x8,%esp
  801782:	6a 00                	push   $0x0
  801784:	ff 75 f4             	pushl  -0xc(%ebp)
  801787:	e8 2b f5 ff ff       	call   800cb7 <file_set_size>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	79 12                	jns    8017a5 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801793:	50                   	push   %eax
  801794:	68 d3 3b 80 00       	push   $0x803bd3
  801799:	6a 33                	push   $0x33
  80179b:	68 d7 3a 80 00       	push   $0x803ad7
  8017a0:	e8 e1 01 00 00       	call   801986 <_panic>
	assert(f->f_direct[0] == 0);
  8017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a8:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017af:	74 16                	je     8017c7 <fs_test+0x274>
  8017b1:	68 e5 3b 80 00       	push   $0x803be5
  8017b6:	68 7d 37 80 00       	push   $0x80377d
  8017bb:	6a 34                	push   $0x34
  8017bd:	68 d7 3a 80 00       	push   $0x803ad7
  8017c2:	e8 bf 01 00 00       	call   801986 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017c7:	c1 e8 0c             	shr    $0xc,%eax
  8017ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d1:	a8 40                	test   $0x40,%al
  8017d3:	74 16                	je     8017eb <fs_test+0x298>
  8017d5:	68 f9 3b 80 00       	push   $0x803bf9
  8017da:	68 7d 37 80 00       	push   $0x80377d
  8017df:	6a 35                	push   $0x35
  8017e1:	68 d7 3a 80 00       	push   $0x803ad7
  8017e6:	e8 9b 01 00 00       	call   801986 <_panic>
	cprintf("file_truncate is good\n");
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	68 13 3c 80 00       	push   $0x803c13
  8017f3:	e8 67 02 00 00       	call   801a5f <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017f8:	c7 04 24 ac 3c 80 00 	movl   $0x803cac,(%esp)
  8017ff:	e8 a7 07 00 00       	call   801fab <strlen>
  801804:	83 c4 08             	add    $0x8,%esp
  801807:	50                   	push   %eax
  801808:	ff 75 f4             	pushl  -0xc(%ebp)
  80180b:	e8 a7 f4 ff ff       	call   800cb7 <file_set_size>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	79 12                	jns    801829 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801817:	50                   	push   %eax
  801818:	68 2a 3c 80 00       	push   $0x803c2a
  80181d:	6a 39                	push   $0x39
  80181f:	68 d7 3a 80 00       	push   $0x803ad7
  801824:	e8 5d 01 00 00       	call   801986 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182c:	89 c2                	mov    %eax,%edx
  80182e:	c1 ea 0c             	shr    $0xc,%edx
  801831:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801838:	f6 c2 40             	test   $0x40,%dl
  80183b:	74 16                	je     801853 <fs_test+0x300>
  80183d:	68 f9 3b 80 00       	push   $0x803bf9
  801842:	68 7d 37 80 00       	push   $0x80377d
  801847:	6a 3a                	push   $0x3a
  801849:	68 d7 3a 80 00       	push   $0x803ad7
  80184e:	e8 33 01 00 00       	call   801986 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801853:	83 ec 04             	sub    $0x4,%esp
  801856:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801859:	52                   	push   %edx
  80185a:	6a 00                	push   $0x0
  80185c:	50                   	push   %eax
  80185d:	e8 03 f1 ff ff       	call   800965 <file_get_block>
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	79 12                	jns    80187b <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801869:	50                   	push   %eax
  80186a:	68 3e 3c 80 00       	push   $0x803c3e
  80186f:	6a 3c                	push   $0x3c
  801871:	68 d7 3a 80 00       	push   $0x803ad7
  801876:	e8 0b 01 00 00       	call   801986 <_panic>
	strcpy(blk, msg);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	68 ac 3c 80 00       	push   $0x803cac
  801883:	ff 75 f0             	pushl  -0x10(%ebp)
  801886:	e8 59 07 00 00       	call   801fe4 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188e:	c1 e8 0c             	shr    $0xc,%eax
  801891:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	a8 40                	test   $0x40,%al
  80189d:	75 16                	jne    8018b5 <fs_test+0x362>
  80189f:	68 a4 3b 80 00       	push   $0x803ba4
  8018a4:	68 7d 37 80 00       	push   $0x80377d
  8018a9:	6a 3e                	push   $0x3e
  8018ab:	68 d7 3a 80 00       	push   $0x803ad7
  8018b0:	e8 d1 00 00 00       	call   801986 <_panic>
	file_flush(f);
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bb:	e8 7e f5 ff ff       	call   800e3e <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c3:	c1 e8 0c             	shr    $0xc,%eax
  8018c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	a8 40                	test   $0x40,%al
  8018d2:	74 16                	je     8018ea <fs_test+0x397>
  8018d4:	68 a3 3b 80 00       	push   $0x803ba3
  8018d9:	68 7d 37 80 00       	push   $0x80377d
  8018de:	6a 40                	push   $0x40
  8018e0:	68 d7 3a 80 00       	push   $0x803ad7
  8018e5:	e8 9c 00 00 00       	call   801986 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ed:	c1 e8 0c             	shr    $0xc,%eax
  8018f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f7:	a8 40                	test   $0x40,%al
  8018f9:	74 16                	je     801911 <fs_test+0x3be>
  8018fb:	68 f9 3b 80 00       	push   $0x803bf9
  801900:	68 7d 37 80 00       	push   $0x80377d
  801905:	6a 41                	push   $0x41
  801907:	68 d7 3a 80 00       	push   $0x803ad7
  80190c:	e8 75 00 00 00       	call   801986 <_panic>
	cprintf("file rewrite is good\n");
  801911:	83 ec 0c             	sub    $0xc,%esp
  801914:	68 53 3c 80 00       	push   $0x803c53
  801919:	e8 41 01 00 00       	call   801a5f <cprintf>
}
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80192e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  801931:	e8 73 0a 00 00       	call   8023a9 <sys_getenvid>
  801936:	25 ff 03 00 00       	and    $0x3ff,%eax
  80193b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80193e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801943:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801948:	85 db                	test   %ebx,%ebx
  80194a:	7e 07                	jle    801953 <libmain+0x2d>
		binaryname = argv[0];
  80194c:	8b 06                	mov    (%esi),%eax
  80194e:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801953:	83 ec 08             	sub    $0x8,%esp
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	e8 b0 fb ff ff       	call   80150d <umain>

	// exit gracefully
	exit();
  80195d:	e8 0a 00 00 00       	call   80196c <exit>
}
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801972:	e8 e9 0f 00 00       	call   802960 <close_all>
	sys_env_destroy(0);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	6a 00                	push   $0x0
  80197c:	e8 e7 09 00 00       	call   802368 <sys_env_destroy>
}
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	56                   	push   %esi
  80198a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80198b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80198e:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801994:	e8 10 0a 00 00       	call   8023a9 <sys_getenvid>
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	ff 75 0c             	pushl  0xc(%ebp)
  80199f:	ff 75 08             	pushl  0x8(%ebp)
  8019a2:	56                   	push   %esi
  8019a3:	50                   	push   %eax
  8019a4:	68 04 3d 80 00       	push   $0x803d04
  8019a9:	e8 b1 00 00 00       	call   801a5f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ae:	83 c4 18             	add    $0x18,%esp
  8019b1:	53                   	push   %ebx
  8019b2:	ff 75 10             	pushl  0x10(%ebp)
  8019b5:	e8 54 00 00 00       	call   801a0e <vcprintf>
	cprintf("\n");
  8019ba:	c7 04 24 13 39 80 00 	movl   $0x803913,(%esp)
  8019c1:	e8 99 00 00 00       	call   801a5f <cprintf>
  8019c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019c9:	cc                   	int3   
  8019ca:	eb fd                	jmp    8019c9 <_panic+0x43>

008019cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019d6:	8b 13                	mov    (%ebx),%edx
  8019d8:	8d 42 01             	lea    0x1(%edx),%eax
  8019db:	89 03                	mov    %eax,(%ebx)
  8019dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019e9:	75 1a                	jne    801a05 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	68 ff 00 00 00       	push   $0xff
  8019f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8019f6:	50                   	push   %eax
  8019f7:	e8 2f 09 00 00       	call   80232b <sys_cputs>
		b->idx = 0;
  8019fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a02:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a05:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a17:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a1e:	00 00 00 
	b.cnt = 0;
  801a21:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a28:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	ff 75 08             	pushl  0x8(%ebp)
  801a31:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a37:	50                   	push   %eax
  801a38:	68 cc 19 80 00       	push   $0x8019cc
  801a3d:	e8 54 01 00 00       	call   801b96 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a42:	83 c4 08             	add    $0x8,%esp
  801a45:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a4b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a51:	50                   	push   %eax
  801a52:	e8 d4 08 00 00       	call   80232b <sys_cputs>

	return b.cnt;
}
  801a57:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a65:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a68:	50                   	push   %eax
  801a69:	ff 75 08             	pushl  0x8(%ebp)
  801a6c:	e8 9d ff ff ff       	call   801a0e <vcprintf>
	va_end(ap);

	return cnt;
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	57                   	push   %edi
  801a77:	56                   	push   %esi
  801a78:	53                   	push   %ebx
  801a79:	83 ec 1c             	sub    $0x1c,%esp
  801a7c:	89 c7                	mov    %eax,%edi
  801a7e:	89 d6                	mov    %edx,%esi
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a86:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a89:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a94:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a97:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a9a:	39 d3                	cmp    %edx,%ebx
  801a9c:	72 05                	jb     801aa3 <printnum+0x30>
  801a9e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801aa1:	77 45                	ja     801ae8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	ff 75 18             	pushl  0x18(%ebp)
  801aa9:	8b 45 14             	mov    0x14(%ebp),%eax
  801aac:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801aaf:	53                   	push   %ebx
  801ab0:	ff 75 10             	pushl  0x10(%ebp)
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab9:	ff 75 e0             	pushl  -0x20(%ebp)
  801abc:	ff 75 dc             	pushl  -0x24(%ebp)
  801abf:	ff 75 d8             	pushl  -0x28(%ebp)
  801ac2:	e8 e9 19 00 00       	call   8034b0 <__udivdi3>
  801ac7:	83 c4 18             	add    $0x18,%esp
  801aca:	52                   	push   %edx
  801acb:	50                   	push   %eax
  801acc:	89 f2                	mov    %esi,%edx
  801ace:	89 f8                	mov    %edi,%eax
  801ad0:	e8 9e ff ff ff       	call   801a73 <printnum>
  801ad5:	83 c4 20             	add    $0x20,%esp
  801ad8:	eb 18                	jmp    801af2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801ada:	83 ec 08             	sub    $0x8,%esp
  801add:	56                   	push   %esi
  801ade:	ff 75 18             	pushl  0x18(%ebp)
  801ae1:	ff d7                	call   *%edi
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	eb 03                	jmp    801aeb <printnum+0x78>
  801ae8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801aeb:	83 eb 01             	sub    $0x1,%ebx
  801aee:	85 db                	test   %ebx,%ebx
  801af0:	7f e8                	jg     801ada <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	56                   	push   %esi
  801af6:	83 ec 04             	sub    $0x4,%esp
  801af9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afc:	ff 75 e0             	pushl  -0x20(%ebp)
  801aff:	ff 75 dc             	pushl  -0x24(%ebp)
  801b02:	ff 75 d8             	pushl  -0x28(%ebp)
  801b05:	e8 d6 1a 00 00       	call   8035e0 <__umoddi3>
  801b0a:	83 c4 14             	add    $0x14,%esp
  801b0d:	0f be 80 27 3d 80 00 	movsbl 0x803d27(%eax),%eax
  801b14:	50                   	push   %eax
  801b15:	ff d7                	call   *%edi
}
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b25:	83 fa 01             	cmp    $0x1,%edx
  801b28:	7e 0e                	jle    801b38 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b2a:	8b 10                	mov    (%eax),%edx
  801b2c:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b2f:	89 08                	mov    %ecx,(%eax)
  801b31:	8b 02                	mov    (%edx),%eax
  801b33:	8b 52 04             	mov    0x4(%edx),%edx
  801b36:	eb 22                	jmp    801b5a <getuint+0x38>
	else if (lflag)
  801b38:	85 d2                	test   %edx,%edx
  801b3a:	74 10                	je     801b4c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b3c:	8b 10                	mov    (%eax),%edx
  801b3e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b41:	89 08                	mov    %ecx,(%eax)
  801b43:	8b 02                	mov    (%edx),%eax
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4a:	eb 0e                	jmp    801b5a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b4c:	8b 10                	mov    (%eax),%edx
  801b4e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b51:	89 08                	mov    %ecx,(%eax)
  801b53:	8b 02                	mov    (%edx),%eax
  801b55:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b5a:	5d                   	pop    %ebp
  801b5b:	c3                   	ret    

00801b5c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b62:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b66:	8b 10                	mov    (%eax),%edx
  801b68:	3b 50 04             	cmp    0x4(%eax),%edx
  801b6b:	73 0a                	jae    801b77 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b6d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b70:	89 08                	mov    %ecx,(%eax)
  801b72:	8b 45 08             	mov    0x8(%ebp),%eax
  801b75:	88 02                	mov    %al,(%edx)
}
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b7f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b82:	50                   	push   %eax
  801b83:	ff 75 10             	pushl  0x10(%ebp)
  801b86:	ff 75 0c             	pushl  0xc(%ebp)
  801b89:	ff 75 08             	pushl  0x8(%ebp)
  801b8c:	e8 05 00 00 00       	call   801b96 <vprintfmt>
	va_end(ap);
}
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 2c             	sub    $0x2c,%esp
  801b9f:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ba5:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ba8:	eb 12                	jmp    801bbc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801baa:	85 c0                	test   %eax,%eax
  801bac:	0f 84 89 03 00 00    	je     801f3b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	53                   	push   %ebx
  801bb6:	50                   	push   %eax
  801bb7:	ff d6                	call   *%esi
  801bb9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bbc:	83 c7 01             	add    $0x1,%edi
  801bbf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bc3:	83 f8 25             	cmp    $0x25,%eax
  801bc6:	75 e2                	jne    801baa <vprintfmt+0x14>
  801bc8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bcc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bd3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bda:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801be1:	ba 00 00 00 00       	mov    $0x0,%edx
  801be6:	eb 07                	jmp    801bef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801beb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bef:	8d 47 01             	lea    0x1(%edi),%eax
  801bf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bf5:	0f b6 07             	movzbl (%edi),%eax
  801bf8:	0f b6 c8             	movzbl %al,%ecx
  801bfb:	83 e8 23             	sub    $0x23,%eax
  801bfe:	3c 55                	cmp    $0x55,%al
  801c00:	0f 87 1a 03 00 00    	ja     801f20 <vprintfmt+0x38a>
  801c06:	0f b6 c0             	movzbl %al,%eax
  801c09:	ff 24 85 60 3e 80 00 	jmp    *0x803e60(,%eax,4)
  801c10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c13:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c17:	eb d6                	jmp    801bef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c24:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c27:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c2b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c2e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c31:	83 fa 09             	cmp    $0x9,%edx
  801c34:	77 39                	ja     801c6f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c36:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c39:	eb e9                	jmp    801c24 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801c3e:	8d 48 04             	lea    0x4(%eax),%ecx
  801c41:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c44:	8b 00                	mov    (%eax),%eax
  801c46:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c4c:	eb 27                	jmp    801c75 <vprintfmt+0xdf>
  801c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c51:	85 c0                	test   %eax,%eax
  801c53:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c58:	0f 49 c8             	cmovns %eax,%ecx
  801c5b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c61:	eb 8c                	jmp    801bef <vprintfmt+0x59>
  801c63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c66:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c6d:	eb 80                	jmp    801bef <vprintfmt+0x59>
  801c6f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c72:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c75:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c79:	0f 89 70 ff ff ff    	jns    801bef <vprintfmt+0x59>
				width = precision, precision = -1;
  801c7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c85:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c8c:	e9 5e ff ff ff       	jmp    801bef <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c91:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c97:	e9 53 ff ff ff       	jmp    801bef <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c9c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c9f:	8d 50 04             	lea    0x4(%eax),%edx
  801ca2:	89 55 14             	mov    %edx,0x14(%ebp)
  801ca5:	83 ec 08             	sub    $0x8,%esp
  801ca8:	53                   	push   %ebx
  801ca9:	ff 30                	pushl  (%eax)
  801cab:	ff d6                	call   *%esi
			break;
  801cad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cb3:	e9 04 ff ff ff       	jmp    801bbc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801cbb:	8d 50 04             	lea    0x4(%eax),%edx
  801cbe:	89 55 14             	mov    %edx,0x14(%ebp)
  801cc1:	8b 00                	mov    (%eax),%eax
  801cc3:	99                   	cltd   
  801cc4:	31 d0                	xor    %edx,%eax
  801cc6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cc8:	83 f8 0f             	cmp    $0xf,%eax
  801ccb:	7f 0b                	jg     801cd8 <vprintfmt+0x142>
  801ccd:	8b 14 85 c0 3f 80 00 	mov    0x803fc0(,%eax,4),%edx
  801cd4:	85 d2                	test   %edx,%edx
  801cd6:	75 18                	jne    801cf0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801cd8:	50                   	push   %eax
  801cd9:	68 3f 3d 80 00       	push   $0x803d3f
  801cde:	53                   	push   %ebx
  801cdf:	56                   	push   %esi
  801ce0:	e8 94 fe ff ff       	call   801b79 <printfmt>
  801ce5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ce8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801ceb:	e9 cc fe ff ff       	jmp    801bbc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cf0:	52                   	push   %edx
  801cf1:	68 8f 37 80 00       	push   $0x80378f
  801cf6:	53                   	push   %ebx
  801cf7:	56                   	push   %esi
  801cf8:	e8 7c fe ff ff       	call   801b79 <printfmt>
  801cfd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d03:	e9 b4 fe ff ff       	jmp    801bbc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d08:	8b 45 14             	mov    0x14(%ebp),%eax
  801d0b:	8d 50 04             	lea    0x4(%eax),%edx
  801d0e:	89 55 14             	mov    %edx,0x14(%ebp)
  801d11:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d13:	85 ff                	test   %edi,%edi
  801d15:	b8 38 3d 80 00       	mov    $0x803d38,%eax
  801d1a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d21:	0f 8e 94 00 00 00    	jle    801dbb <vprintfmt+0x225>
  801d27:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d2b:	0f 84 98 00 00 00    	je     801dc9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	ff 75 d0             	pushl  -0x30(%ebp)
  801d37:	57                   	push   %edi
  801d38:	e8 86 02 00 00       	call   801fc3 <strnlen>
  801d3d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d40:	29 c1                	sub    %eax,%ecx
  801d42:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d45:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d48:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d4f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d52:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d54:	eb 0f                	jmp    801d65 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d56:	83 ec 08             	sub    $0x8,%esp
  801d59:	53                   	push   %ebx
  801d5a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d5d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d5f:	83 ef 01             	sub    $0x1,%edi
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 ff                	test   %edi,%edi
  801d67:	7f ed                	jg     801d56 <vprintfmt+0x1c0>
  801d69:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d6c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d6f:	85 c9                	test   %ecx,%ecx
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
  801d76:	0f 49 c1             	cmovns %ecx,%eax
  801d79:	29 c1                	sub    %eax,%ecx
  801d7b:	89 75 08             	mov    %esi,0x8(%ebp)
  801d7e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d81:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d84:	89 cb                	mov    %ecx,%ebx
  801d86:	eb 4d                	jmp    801dd5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d88:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d8c:	74 1b                	je     801da9 <vprintfmt+0x213>
  801d8e:	0f be c0             	movsbl %al,%eax
  801d91:	83 e8 20             	sub    $0x20,%eax
  801d94:	83 f8 5e             	cmp    $0x5e,%eax
  801d97:	76 10                	jbe    801da9 <vprintfmt+0x213>
					putch('?', putdat);
  801d99:	83 ec 08             	sub    $0x8,%esp
  801d9c:	ff 75 0c             	pushl  0xc(%ebp)
  801d9f:	6a 3f                	push   $0x3f
  801da1:	ff 55 08             	call   *0x8(%ebp)
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	eb 0d                	jmp    801db6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801da9:	83 ec 08             	sub    $0x8,%esp
  801dac:	ff 75 0c             	pushl  0xc(%ebp)
  801daf:	52                   	push   %edx
  801db0:	ff 55 08             	call   *0x8(%ebp)
  801db3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801db6:	83 eb 01             	sub    $0x1,%ebx
  801db9:	eb 1a                	jmp    801dd5 <vprintfmt+0x23f>
  801dbb:	89 75 08             	mov    %esi,0x8(%ebp)
  801dbe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dc1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dc4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dc7:	eb 0c                	jmp    801dd5 <vprintfmt+0x23f>
  801dc9:	89 75 08             	mov    %esi,0x8(%ebp)
  801dcc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dcf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dd2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dd5:	83 c7 01             	add    $0x1,%edi
  801dd8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ddc:	0f be d0             	movsbl %al,%edx
  801ddf:	85 d2                	test   %edx,%edx
  801de1:	74 23                	je     801e06 <vprintfmt+0x270>
  801de3:	85 f6                	test   %esi,%esi
  801de5:	78 a1                	js     801d88 <vprintfmt+0x1f2>
  801de7:	83 ee 01             	sub    $0x1,%esi
  801dea:	79 9c                	jns    801d88 <vprintfmt+0x1f2>
  801dec:	89 df                	mov    %ebx,%edi
  801dee:	8b 75 08             	mov    0x8(%ebp),%esi
  801df1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801df4:	eb 18                	jmp    801e0e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801df6:	83 ec 08             	sub    $0x8,%esp
  801df9:	53                   	push   %ebx
  801dfa:	6a 20                	push   $0x20
  801dfc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801dfe:	83 ef 01             	sub    $0x1,%edi
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	eb 08                	jmp    801e0e <vprintfmt+0x278>
  801e06:	89 df                	mov    %ebx,%edi
  801e08:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e0e:	85 ff                	test   %edi,%edi
  801e10:	7f e4                	jg     801df6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e15:	e9 a2 fd ff ff       	jmp    801bbc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e1a:	83 fa 01             	cmp    $0x1,%edx
  801e1d:	7e 16                	jle    801e35 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e22:	8d 50 08             	lea    0x8(%eax),%edx
  801e25:	89 55 14             	mov    %edx,0x14(%ebp)
  801e28:	8b 50 04             	mov    0x4(%eax),%edx
  801e2b:	8b 00                	mov    (%eax),%eax
  801e2d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e30:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e33:	eb 32                	jmp    801e67 <vprintfmt+0x2d1>
	else if (lflag)
  801e35:	85 d2                	test   %edx,%edx
  801e37:	74 18                	je     801e51 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e39:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3c:	8d 50 04             	lea    0x4(%eax),%edx
  801e3f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e42:	8b 00                	mov    (%eax),%eax
  801e44:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e47:	89 c1                	mov    %eax,%ecx
  801e49:	c1 f9 1f             	sar    $0x1f,%ecx
  801e4c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e4f:	eb 16                	jmp    801e67 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e51:	8b 45 14             	mov    0x14(%ebp),%eax
  801e54:	8d 50 04             	lea    0x4(%eax),%edx
  801e57:	89 55 14             	mov    %edx,0x14(%ebp)
  801e5a:	8b 00                	mov    (%eax),%eax
  801e5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e5f:	89 c1                	mov    %eax,%ecx
  801e61:	c1 f9 1f             	sar    $0x1f,%ecx
  801e64:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e67:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e6d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e72:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e76:	79 74                	jns    801eec <vprintfmt+0x356>
				putch('-', putdat);
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	53                   	push   %ebx
  801e7c:	6a 2d                	push   $0x2d
  801e7e:	ff d6                	call   *%esi
				num = -(long long) num;
  801e80:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e83:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e86:	f7 d8                	neg    %eax
  801e88:	83 d2 00             	adc    $0x0,%edx
  801e8b:	f7 da                	neg    %edx
  801e8d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e90:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e95:	eb 55                	jmp    801eec <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e97:	8d 45 14             	lea    0x14(%ebp),%eax
  801e9a:	e8 83 fc ff ff       	call   801b22 <getuint>
			base = 10;
  801e9f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ea4:	eb 46                	jmp    801eec <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  801ea6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ea9:	e8 74 fc ff ff       	call   801b22 <getuint>
			base=8;
  801eae:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801eb3:	eb 37                	jmp    801eec <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801eb5:	83 ec 08             	sub    $0x8,%esp
  801eb8:	53                   	push   %ebx
  801eb9:	6a 30                	push   $0x30
  801ebb:	ff d6                	call   *%esi
			putch('x', putdat);
  801ebd:	83 c4 08             	add    $0x8,%esp
  801ec0:	53                   	push   %ebx
  801ec1:	6a 78                	push   $0x78
  801ec3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ec5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec8:	8d 50 04             	lea    0x4(%eax),%edx
  801ecb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ece:	8b 00                	mov    (%eax),%eax
  801ed0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ed5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ed8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801edd:	eb 0d                	jmp    801eec <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801edf:	8d 45 14             	lea    0x14(%ebp),%eax
  801ee2:	e8 3b fc ff ff       	call   801b22 <getuint>
			base = 16;
  801ee7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ef3:	57                   	push   %edi
  801ef4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ef7:	51                   	push   %ecx
  801ef8:	52                   	push   %edx
  801ef9:	50                   	push   %eax
  801efa:	89 da                	mov    %ebx,%edx
  801efc:	89 f0                	mov    %esi,%eax
  801efe:	e8 70 fb ff ff       	call   801a73 <printnum>
			break;
  801f03:	83 c4 20             	add    $0x20,%esp
  801f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f09:	e9 ae fc ff ff       	jmp    801bbc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f0e:	83 ec 08             	sub    $0x8,%esp
  801f11:	53                   	push   %ebx
  801f12:	51                   	push   %ecx
  801f13:	ff d6                	call   *%esi
			break;
  801f15:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f1b:	e9 9c fc ff ff       	jmp    801bbc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f20:	83 ec 08             	sub    $0x8,%esp
  801f23:	53                   	push   %ebx
  801f24:	6a 25                	push   $0x25
  801f26:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f28:	83 c4 10             	add    $0x10,%esp
  801f2b:	eb 03                	jmp    801f30 <vprintfmt+0x39a>
  801f2d:	83 ef 01             	sub    $0x1,%edi
  801f30:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f34:	75 f7                	jne    801f2d <vprintfmt+0x397>
  801f36:	e9 81 fc ff ff       	jmp    801bbc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3e:	5b                   	pop    %ebx
  801f3f:	5e                   	pop    %esi
  801f40:	5f                   	pop    %edi
  801f41:	5d                   	pop    %ebp
  801f42:	c3                   	ret    

00801f43 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 18             	sub    $0x18,%esp
  801f49:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f52:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f56:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f60:	85 c0                	test   %eax,%eax
  801f62:	74 26                	je     801f8a <vsnprintf+0x47>
  801f64:	85 d2                	test   %edx,%edx
  801f66:	7e 22                	jle    801f8a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f68:	ff 75 14             	pushl  0x14(%ebp)
  801f6b:	ff 75 10             	pushl  0x10(%ebp)
  801f6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	68 5c 1b 80 00       	push   $0x801b5c
  801f77:	e8 1a fc ff ff       	call   801b96 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	eb 05                	jmp    801f8f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801f8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f97:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f9a:	50                   	push   %eax
  801f9b:	ff 75 10             	pushl  0x10(%ebp)
  801f9e:	ff 75 0c             	pushl  0xc(%ebp)
  801fa1:	ff 75 08             	pushl  0x8(%ebp)
  801fa4:	e8 9a ff ff ff       	call   801f43 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    

00801fab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb6:	eb 03                	jmp    801fbb <strlen+0x10>
		n++;
  801fb8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fbb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fbf:	75 f7                	jne    801fb8 <strlen+0xd>
		n++;
	return n;
}
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fcc:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd1:	eb 03                	jmp    801fd6 <strnlen+0x13>
		n++;
  801fd3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fd6:	39 c2                	cmp    %eax,%edx
  801fd8:	74 08                	je     801fe2 <strnlen+0x1f>
  801fda:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801fde:	75 f3                	jne    801fd3 <strnlen+0x10>
  801fe0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	53                   	push   %ebx
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801fee:	89 c2                	mov    %eax,%edx
  801ff0:	83 c2 01             	add    $0x1,%edx
  801ff3:	83 c1 01             	add    $0x1,%ecx
  801ff6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ffa:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ffd:	84 db                	test   %bl,%bl
  801fff:	75 ef                	jne    801ff0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802001:	5b                   	pop    %ebx
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	53                   	push   %ebx
  802008:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80200b:	53                   	push   %ebx
  80200c:	e8 9a ff ff ff       	call   801fab <strlen>
  802011:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802014:	ff 75 0c             	pushl  0xc(%ebp)
  802017:	01 d8                	add    %ebx,%eax
  802019:	50                   	push   %eax
  80201a:	e8 c5 ff ff ff       	call   801fe4 <strcpy>
	return dst;
}
  80201f:	89 d8                	mov    %ebx,%eax
  802021:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	56                   	push   %esi
  80202a:	53                   	push   %ebx
  80202b:	8b 75 08             	mov    0x8(%ebp),%esi
  80202e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802031:	89 f3                	mov    %esi,%ebx
  802033:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802036:	89 f2                	mov    %esi,%edx
  802038:	eb 0f                	jmp    802049 <strncpy+0x23>
		*dst++ = *src;
  80203a:	83 c2 01             	add    $0x1,%edx
  80203d:	0f b6 01             	movzbl (%ecx),%eax
  802040:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802043:	80 39 01             	cmpb   $0x1,(%ecx)
  802046:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802049:	39 da                	cmp    %ebx,%edx
  80204b:	75 ed                	jne    80203a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80204d:	89 f0                	mov    %esi,%eax
  80204f:	5b                   	pop    %ebx
  802050:	5e                   	pop    %esi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    

00802053 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	8b 75 08             	mov    0x8(%ebp),%esi
  80205b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205e:	8b 55 10             	mov    0x10(%ebp),%edx
  802061:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802063:	85 d2                	test   %edx,%edx
  802065:	74 21                	je     802088 <strlcpy+0x35>
  802067:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80206b:	89 f2                	mov    %esi,%edx
  80206d:	eb 09                	jmp    802078 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80206f:	83 c2 01             	add    $0x1,%edx
  802072:	83 c1 01             	add    $0x1,%ecx
  802075:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802078:	39 c2                	cmp    %eax,%edx
  80207a:	74 09                	je     802085 <strlcpy+0x32>
  80207c:	0f b6 19             	movzbl (%ecx),%ebx
  80207f:	84 db                	test   %bl,%bl
  802081:	75 ec                	jne    80206f <strlcpy+0x1c>
  802083:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  802085:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802088:	29 f0                	sub    %esi,%eax
}
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802094:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802097:	eb 06                	jmp    80209f <strcmp+0x11>
		p++, q++;
  802099:	83 c1 01             	add    $0x1,%ecx
  80209c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80209f:	0f b6 01             	movzbl (%ecx),%eax
  8020a2:	84 c0                	test   %al,%al
  8020a4:	74 04                	je     8020aa <strcmp+0x1c>
  8020a6:	3a 02                	cmp    (%edx),%al
  8020a8:	74 ef                	je     802099 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020aa:	0f b6 c0             	movzbl %al,%eax
  8020ad:	0f b6 12             	movzbl (%edx),%edx
  8020b0:	29 d0                	sub    %edx,%eax
}
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    

008020b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	53                   	push   %ebx
  8020b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020be:	89 c3                	mov    %eax,%ebx
  8020c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020c3:	eb 06                	jmp    8020cb <strncmp+0x17>
		n--, p++, q++;
  8020c5:	83 c0 01             	add    $0x1,%eax
  8020c8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020cb:	39 d8                	cmp    %ebx,%eax
  8020cd:	74 15                	je     8020e4 <strncmp+0x30>
  8020cf:	0f b6 08             	movzbl (%eax),%ecx
  8020d2:	84 c9                	test   %cl,%cl
  8020d4:	74 04                	je     8020da <strncmp+0x26>
  8020d6:	3a 0a                	cmp    (%edx),%cl
  8020d8:	74 eb                	je     8020c5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020da:	0f b6 00             	movzbl (%eax),%eax
  8020dd:	0f b6 12             	movzbl (%edx),%edx
  8020e0:	29 d0                	sub    %edx,%eax
  8020e2:	eb 05                	jmp    8020e9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8020e9:	5b                   	pop    %ebx
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    

008020ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8020f6:	eb 07                	jmp    8020ff <strchr+0x13>
		if (*s == c)
  8020f8:	38 ca                	cmp    %cl,%dl
  8020fa:	74 0f                	je     80210b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8020fc:	83 c0 01             	add    $0x1,%eax
  8020ff:	0f b6 10             	movzbl (%eax),%edx
  802102:	84 d2                	test   %dl,%dl
  802104:	75 f2                	jne    8020f8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802106:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    

0080210d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	8b 45 08             	mov    0x8(%ebp),%eax
  802113:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802117:	eb 03                	jmp    80211c <strfind+0xf>
  802119:	83 c0 01             	add    $0x1,%eax
  80211c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80211f:	38 ca                	cmp    %cl,%dl
  802121:	74 04                	je     802127 <strfind+0x1a>
  802123:	84 d2                	test   %dl,%dl
  802125:	75 f2                	jne    802119 <strfind+0xc>
			break;
	return (char *) s;
}
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	57                   	push   %edi
  80212d:	56                   	push   %esi
  80212e:	53                   	push   %ebx
  80212f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802132:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802135:	85 c9                	test   %ecx,%ecx
  802137:	74 36                	je     80216f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802139:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80213f:	75 28                	jne    802169 <memset+0x40>
  802141:	f6 c1 03             	test   $0x3,%cl
  802144:	75 23                	jne    802169 <memset+0x40>
		c &= 0xFF;
  802146:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80214a:	89 d3                	mov    %edx,%ebx
  80214c:	c1 e3 08             	shl    $0x8,%ebx
  80214f:	89 d6                	mov    %edx,%esi
  802151:	c1 e6 18             	shl    $0x18,%esi
  802154:	89 d0                	mov    %edx,%eax
  802156:	c1 e0 10             	shl    $0x10,%eax
  802159:	09 f0                	or     %esi,%eax
  80215b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80215d:	89 d8                	mov    %ebx,%eax
  80215f:	09 d0                	or     %edx,%eax
  802161:	c1 e9 02             	shr    $0x2,%ecx
  802164:	fc                   	cld    
  802165:	f3 ab                	rep stos %eax,%es:(%edi)
  802167:	eb 06                	jmp    80216f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802169:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216c:	fc                   	cld    
  80216d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80216f:	89 f8                	mov    %edi,%eax
  802171:	5b                   	pop    %ebx
  802172:	5e                   	pop    %esi
  802173:	5f                   	pop    %edi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	57                   	push   %edi
  80217a:	56                   	push   %esi
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802181:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802184:	39 c6                	cmp    %eax,%esi
  802186:	73 35                	jae    8021bd <memmove+0x47>
  802188:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80218b:	39 d0                	cmp    %edx,%eax
  80218d:	73 2e                	jae    8021bd <memmove+0x47>
		s += n;
		d += n;
  80218f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802192:	89 d6                	mov    %edx,%esi
  802194:	09 fe                	or     %edi,%esi
  802196:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80219c:	75 13                	jne    8021b1 <memmove+0x3b>
  80219e:	f6 c1 03             	test   $0x3,%cl
  8021a1:	75 0e                	jne    8021b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8021a3:	83 ef 04             	sub    $0x4,%edi
  8021a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021a9:	c1 e9 02             	shr    $0x2,%ecx
  8021ac:	fd                   	std    
  8021ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021af:	eb 09                	jmp    8021ba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021b1:	83 ef 01             	sub    $0x1,%edi
  8021b4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021b7:	fd                   	std    
  8021b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021ba:	fc                   	cld    
  8021bb:	eb 1d                	jmp    8021da <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	09 c2                	or     %eax,%edx
  8021c1:	f6 c2 03             	test   $0x3,%dl
  8021c4:	75 0f                	jne    8021d5 <memmove+0x5f>
  8021c6:	f6 c1 03             	test   $0x3,%cl
  8021c9:	75 0a                	jne    8021d5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8021cb:	c1 e9 02             	shr    $0x2,%ecx
  8021ce:	89 c7                	mov    %eax,%edi
  8021d0:	fc                   	cld    
  8021d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021d3:	eb 05                	jmp    8021da <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021d5:	89 c7                	mov    %eax,%edi
  8021d7:	fc                   	cld    
  8021d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    

008021de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8021e1:	ff 75 10             	pushl  0x10(%ebp)
  8021e4:	ff 75 0c             	pushl  0xc(%ebp)
  8021e7:	ff 75 08             	pushl  0x8(%ebp)
  8021ea:	e8 87 ff ff ff       	call   802176 <memmove>
}
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	56                   	push   %esi
  8021f5:	53                   	push   %ebx
  8021f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021fc:	89 c6                	mov    %eax,%esi
  8021fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802201:	eb 1a                	jmp    80221d <memcmp+0x2c>
		if (*s1 != *s2)
  802203:	0f b6 08             	movzbl (%eax),%ecx
  802206:	0f b6 1a             	movzbl (%edx),%ebx
  802209:	38 d9                	cmp    %bl,%cl
  80220b:	74 0a                	je     802217 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80220d:	0f b6 c1             	movzbl %cl,%eax
  802210:	0f b6 db             	movzbl %bl,%ebx
  802213:	29 d8                	sub    %ebx,%eax
  802215:	eb 0f                	jmp    802226 <memcmp+0x35>
		s1++, s2++;
  802217:	83 c0 01             	add    $0x1,%eax
  80221a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80221d:	39 f0                	cmp    %esi,%eax
  80221f:	75 e2                	jne    802203 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802226:	5b                   	pop    %ebx
  802227:	5e                   	pop    %esi
  802228:	5d                   	pop    %ebp
  802229:	c3                   	ret    

0080222a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80222a:	55                   	push   %ebp
  80222b:	89 e5                	mov    %esp,%ebp
  80222d:	53                   	push   %ebx
  80222e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802231:	89 c1                	mov    %eax,%ecx
  802233:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802236:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80223a:	eb 0a                	jmp    802246 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80223c:	0f b6 10             	movzbl (%eax),%edx
  80223f:	39 da                	cmp    %ebx,%edx
  802241:	74 07                	je     80224a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802243:	83 c0 01             	add    $0x1,%eax
  802246:	39 c8                	cmp    %ecx,%eax
  802248:	72 f2                	jb     80223c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80224a:	5b                   	pop    %ebx
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    

0080224d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	57                   	push   %edi
  802251:	56                   	push   %esi
  802252:	53                   	push   %ebx
  802253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802256:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802259:	eb 03                	jmp    80225e <strtol+0x11>
		s++;
  80225b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80225e:	0f b6 01             	movzbl (%ecx),%eax
  802261:	3c 20                	cmp    $0x20,%al
  802263:	74 f6                	je     80225b <strtol+0xe>
  802265:	3c 09                	cmp    $0x9,%al
  802267:	74 f2                	je     80225b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802269:	3c 2b                	cmp    $0x2b,%al
  80226b:	75 0a                	jne    802277 <strtol+0x2a>
		s++;
  80226d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802270:	bf 00 00 00 00       	mov    $0x0,%edi
  802275:	eb 11                	jmp    802288 <strtol+0x3b>
  802277:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80227c:	3c 2d                	cmp    $0x2d,%al
  80227e:	75 08                	jne    802288 <strtol+0x3b>
		s++, neg = 1;
  802280:	83 c1 01             	add    $0x1,%ecx
  802283:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802288:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80228e:	75 15                	jne    8022a5 <strtol+0x58>
  802290:	80 39 30             	cmpb   $0x30,(%ecx)
  802293:	75 10                	jne    8022a5 <strtol+0x58>
  802295:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802299:	75 7c                	jne    802317 <strtol+0xca>
		s += 2, base = 16;
  80229b:	83 c1 02             	add    $0x2,%ecx
  80229e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022a3:	eb 16                	jmp    8022bb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8022a5:	85 db                	test   %ebx,%ebx
  8022a7:	75 12                	jne    8022bb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022a9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8022b1:	75 08                	jne    8022bb <strtol+0x6e>
		s++, base = 8;
  8022b3:	83 c1 01             	add    $0x1,%ecx
  8022b6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022c3:	0f b6 11             	movzbl (%ecx),%edx
  8022c6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022c9:	89 f3                	mov    %esi,%ebx
  8022cb:	80 fb 09             	cmp    $0x9,%bl
  8022ce:	77 08                	ja     8022d8 <strtol+0x8b>
			dig = *s - '0';
  8022d0:	0f be d2             	movsbl %dl,%edx
  8022d3:	83 ea 30             	sub    $0x30,%edx
  8022d6:	eb 22                	jmp    8022fa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8022d8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8022db:	89 f3                	mov    %esi,%ebx
  8022dd:	80 fb 19             	cmp    $0x19,%bl
  8022e0:	77 08                	ja     8022ea <strtol+0x9d>
			dig = *s - 'a' + 10;
  8022e2:	0f be d2             	movsbl %dl,%edx
  8022e5:	83 ea 57             	sub    $0x57,%edx
  8022e8:	eb 10                	jmp    8022fa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8022ea:	8d 72 bf             	lea    -0x41(%edx),%esi
  8022ed:	89 f3                	mov    %esi,%ebx
  8022ef:	80 fb 19             	cmp    $0x19,%bl
  8022f2:	77 16                	ja     80230a <strtol+0xbd>
			dig = *s - 'A' + 10;
  8022f4:	0f be d2             	movsbl %dl,%edx
  8022f7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8022fa:	3b 55 10             	cmp    0x10(%ebp),%edx
  8022fd:	7d 0b                	jge    80230a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8022ff:	83 c1 01             	add    $0x1,%ecx
  802302:	0f af 45 10          	imul   0x10(%ebp),%eax
  802306:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802308:	eb b9                	jmp    8022c3 <strtol+0x76>

	if (endptr)
  80230a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80230e:	74 0d                	je     80231d <strtol+0xd0>
		*endptr = (char *) s;
  802310:	8b 75 0c             	mov    0xc(%ebp),%esi
  802313:	89 0e                	mov    %ecx,(%esi)
  802315:	eb 06                	jmp    80231d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802317:	85 db                	test   %ebx,%ebx
  802319:	74 98                	je     8022b3 <strtol+0x66>
  80231b:	eb 9e                	jmp    8022bb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80231d:	89 c2                	mov    %eax,%edx
  80231f:	f7 da                	neg    %edx
  802321:	85 ff                	test   %edi,%edi
  802323:	0f 45 c2             	cmovne %edx,%eax
}
  802326:	5b                   	pop    %ebx
  802327:	5e                   	pop    %esi
  802328:	5f                   	pop    %edi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    

0080232b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	57                   	push   %edi
  80232f:	56                   	push   %esi
  802330:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802331:	b8 00 00 00 00       	mov    $0x0,%eax
  802336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802339:	8b 55 08             	mov    0x8(%ebp),%edx
  80233c:	89 c3                	mov    %eax,%ebx
  80233e:	89 c7                	mov    %eax,%edi
  802340:	89 c6                	mov    %eax,%esi
  802342:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    

00802349 <sys_cgetc>:

int
sys_cgetc(void)
{
  802349:	55                   	push   %ebp
  80234a:	89 e5                	mov    %esp,%ebp
  80234c:	57                   	push   %edi
  80234d:	56                   	push   %esi
  80234e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80234f:	ba 00 00 00 00       	mov    $0x0,%edx
  802354:	b8 01 00 00 00       	mov    $0x1,%eax
  802359:	89 d1                	mov    %edx,%ecx
  80235b:	89 d3                	mov    %edx,%ebx
  80235d:	89 d7                	mov    %edx,%edi
  80235f:	89 d6                	mov    %edx,%esi
  802361:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    

00802368 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	57                   	push   %edi
  80236c:	56                   	push   %esi
  80236d:	53                   	push   %ebx
  80236e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802371:	b9 00 00 00 00       	mov    $0x0,%ecx
  802376:	b8 03 00 00 00       	mov    $0x3,%eax
  80237b:	8b 55 08             	mov    0x8(%ebp),%edx
  80237e:	89 cb                	mov    %ecx,%ebx
  802380:	89 cf                	mov    %ecx,%edi
  802382:	89 ce                	mov    %ecx,%esi
  802384:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802386:	85 c0                	test   %eax,%eax
  802388:	7e 17                	jle    8023a1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80238a:	83 ec 0c             	sub    $0xc,%esp
  80238d:	50                   	push   %eax
  80238e:	6a 03                	push   $0x3
  802390:	68 1f 40 80 00       	push   $0x80401f
  802395:	6a 23                	push   $0x23
  802397:	68 3c 40 80 00       	push   $0x80403c
  80239c:	e8 e5 f5 ff ff       	call   801986 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    

008023a9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	57                   	push   %edi
  8023ad:	56                   	push   %esi
  8023ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023af:	ba 00 00 00 00       	mov    $0x0,%edx
  8023b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8023b9:	89 d1                	mov    %edx,%ecx
  8023bb:	89 d3                	mov    %edx,%ebx
  8023bd:	89 d7                	mov    %edx,%edi
  8023bf:	89 d6                	mov    %edx,%esi
  8023c1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023c3:	5b                   	pop    %ebx
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    

008023c8 <sys_yield>:

void
sys_yield(void)
{
  8023c8:	55                   	push   %ebp
  8023c9:	89 e5                	mov    %esp,%ebp
  8023cb:	57                   	push   %edi
  8023cc:	56                   	push   %esi
  8023cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8023d3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023d8:	89 d1                	mov    %edx,%ecx
  8023da:	89 d3                	mov    %edx,%ebx
  8023dc:	89 d7                	mov    %edx,%edi
  8023de:	89 d6                	mov    %edx,%esi
  8023e0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8023e2:	5b                   	pop    %ebx
  8023e3:	5e                   	pop    %esi
  8023e4:	5f                   	pop    %edi
  8023e5:	5d                   	pop    %ebp
  8023e6:	c3                   	ret    

008023e7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8023e7:	55                   	push   %ebp
  8023e8:	89 e5                	mov    %esp,%ebp
  8023ea:	57                   	push   %edi
  8023eb:	56                   	push   %esi
  8023ec:	53                   	push   %ebx
  8023ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023f0:	be 00 00 00 00       	mov    $0x0,%esi
  8023f5:	b8 04 00 00 00       	mov    $0x4,%eax
  8023fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023fd:	8b 55 08             	mov    0x8(%ebp),%edx
  802400:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802403:	89 f7                	mov    %esi,%edi
  802405:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802407:	85 c0                	test   %eax,%eax
  802409:	7e 17                	jle    802422 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80240b:	83 ec 0c             	sub    $0xc,%esp
  80240e:	50                   	push   %eax
  80240f:	6a 04                	push   $0x4
  802411:	68 1f 40 80 00       	push   $0x80401f
  802416:	6a 23                	push   $0x23
  802418:	68 3c 40 80 00       	push   $0x80403c
  80241d:	e8 64 f5 ff ff       	call   801986 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802422:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802425:	5b                   	pop    %ebx
  802426:	5e                   	pop    %esi
  802427:	5f                   	pop    %edi
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    

0080242a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	53                   	push   %ebx
  802430:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802433:	b8 05 00 00 00       	mov    $0x5,%eax
  802438:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80243b:	8b 55 08             	mov    0x8(%ebp),%edx
  80243e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802441:	8b 7d 14             	mov    0x14(%ebp),%edi
  802444:	8b 75 18             	mov    0x18(%ebp),%esi
  802447:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802449:	85 c0                	test   %eax,%eax
  80244b:	7e 17                	jle    802464 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80244d:	83 ec 0c             	sub    $0xc,%esp
  802450:	50                   	push   %eax
  802451:	6a 05                	push   $0x5
  802453:	68 1f 40 80 00       	push   $0x80401f
  802458:	6a 23                	push   $0x23
  80245a:	68 3c 40 80 00       	push   $0x80403c
  80245f:	e8 22 f5 ff ff       	call   801986 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802464:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802467:	5b                   	pop    %ebx
  802468:	5e                   	pop    %esi
  802469:	5f                   	pop    %edi
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    

0080246c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
  80246f:	57                   	push   %edi
  802470:	56                   	push   %esi
  802471:	53                   	push   %ebx
  802472:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802475:	bb 00 00 00 00       	mov    $0x0,%ebx
  80247a:	b8 06 00 00 00       	mov    $0x6,%eax
  80247f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802482:	8b 55 08             	mov    0x8(%ebp),%edx
  802485:	89 df                	mov    %ebx,%edi
  802487:	89 de                	mov    %ebx,%esi
  802489:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80248b:	85 c0                	test   %eax,%eax
  80248d:	7e 17                	jle    8024a6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80248f:	83 ec 0c             	sub    $0xc,%esp
  802492:	50                   	push   %eax
  802493:	6a 06                	push   $0x6
  802495:	68 1f 40 80 00       	push   $0x80401f
  80249a:	6a 23                	push   $0x23
  80249c:	68 3c 40 80 00       	push   $0x80403c
  8024a1:	e8 e0 f4 ff ff       	call   801986 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a9:	5b                   	pop    %ebx
  8024aa:	5e                   	pop    %esi
  8024ab:	5f                   	pop    %edi
  8024ac:	5d                   	pop    %ebp
  8024ad:	c3                   	ret    

008024ae <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024ae:	55                   	push   %ebp
  8024af:	89 e5                	mov    %esp,%ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8024c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8024c7:	89 df                	mov    %ebx,%edi
  8024c9:	89 de                	mov    %ebx,%esi
  8024cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	7e 17                	jle    8024e8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024d1:	83 ec 0c             	sub    $0xc,%esp
  8024d4:	50                   	push   %eax
  8024d5:	6a 08                	push   $0x8
  8024d7:	68 1f 40 80 00       	push   $0x80401f
  8024dc:	6a 23                	push   $0x23
  8024de:	68 3c 40 80 00       	push   $0x80403c
  8024e3:	e8 9e f4 ff ff       	call   801986 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8024e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024eb:	5b                   	pop    %ebx
  8024ec:	5e                   	pop    %esi
  8024ed:	5f                   	pop    %edi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    

008024f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	57                   	push   %edi
  8024f4:	56                   	push   %esi
  8024f5:	53                   	push   %ebx
  8024f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024fe:	b8 09 00 00 00       	mov    $0x9,%eax
  802503:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802506:	8b 55 08             	mov    0x8(%ebp),%edx
  802509:	89 df                	mov    %ebx,%edi
  80250b:	89 de                	mov    %ebx,%esi
  80250d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80250f:	85 c0                	test   %eax,%eax
  802511:	7e 17                	jle    80252a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802513:	83 ec 0c             	sub    $0xc,%esp
  802516:	50                   	push   %eax
  802517:	6a 09                	push   $0x9
  802519:	68 1f 40 80 00       	push   $0x80401f
  80251e:	6a 23                	push   $0x23
  802520:	68 3c 40 80 00       	push   $0x80403c
  802525:	e8 5c f4 ff ff       	call   801986 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80252a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    

00802532 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	57                   	push   %edi
  802536:	56                   	push   %esi
  802537:	53                   	push   %ebx
  802538:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80253b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802540:	b8 0a 00 00 00       	mov    $0xa,%eax
  802545:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802548:	8b 55 08             	mov    0x8(%ebp),%edx
  80254b:	89 df                	mov    %ebx,%edi
  80254d:	89 de                	mov    %ebx,%esi
  80254f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802551:	85 c0                	test   %eax,%eax
  802553:	7e 17                	jle    80256c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802555:	83 ec 0c             	sub    $0xc,%esp
  802558:	50                   	push   %eax
  802559:	6a 0a                	push   $0xa
  80255b:	68 1f 40 80 00       	push   $0x80401f
  802560:	6a 23                	push   $0x23
  802562:	68 3c 40 80 00       	push   $0x80403c
  802567:	e8 1a f4 ff ff       	call   801986 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80256c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    

00802574 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
  802577:	57                   	push   %edi
  802578:	56                   	push   %esi
  802579:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80257a:	be 00 00 00 00       	mov    $0x0,%esi
  80257f:	b8 0c 00 00 00       	mov    $0xc,%eax
  802584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802587:	8b 55 08             	mov    0x8(%ebp),%edx
  80258a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80258d:	8b 7d 14             	mov    0x14(%ebp),%edi
  802590:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802592:	5b                   	pop    %ebx
  802593:	5e                   	pop    %esi
  802594:	5f                   	pop    %edi
  802595:	5d                   	pop    %ebp
  802596:	c3                   	ret    

00802597 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802597:	55                   	push   %ebp
  802598:	89 e5                	mov    %esp,%ebp
  80259a:	57                   	push   %edi
  80259b:	56                   	push   %esi
  80259c:	53                   	push   %ebx
  80259d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025a5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ad:	89 cb                	mov    %ecx,%ebx
  8025af:	89 cf                	mov    %ecx,%edi
  8025b1:	89 ce                	mov    %ecx,%esi
  8025b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025b5:	85 c0                	test   %eax,%eax
  8025b7:	7e 17                	jle    8025d0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025b9:	83 ec 0c             	sub    $0xc,%esp
  8025bc:	50                   	push   %eax
  8025bd:	6a 0d                	push   $0xd
  8025bf:	68 1f 40 80 00       	push   $0x80401f
  8025c4:	6a 23                	push   $0x23
  8025c6:	68 3c 40 80 00       	push   $0x80403c
  8025cb:	e8 b6 f3 ff ff       	call   801986 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    

008025d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025d8:	55                   	push   %ebp
  8025d9:	89 e5                	mov    %esp,%ebp
  8025db:	53                   	push   %ebx
  8025dc:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025df:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8025e6:	75 57                	jne    80263f <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  8025e8:	e8 bc fd ff ff       	call   8023a9 <sys_getenvid>
  8025ed:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  8025ef:	83 ec 04             	sub    $0x4,%esp
  8025f2:	6a 07                	push   $0x7
  8025f4:	68 00 f0 bf ee       	push   $0xeebff000
  8025f9:	50                   	push   %eax
  8025fa:	e8 e8 fd ff ff       	call   8023e7 <sys_page_alloc>
		if (r) {
  8025ff:	83 c4 10             	add    $0x10,%esp
  802602:	85 c0                	test   %eax,%eax
  802604:	74 12                	je     802618 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  802606:	50                   	push   %eax
  802607:	68 4a 40 80 00       	push   $0x80404a
  80260c:	6a 25                	push   $0x25
  80260e:	68 63 40 80 00       	push   $0x804063
  802613:	e8 6e f3 ff ff       	call   801986 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  802618:	83 ec 08             	sub    $0x8,%esp
  80261b:	68 4c 26 80 00       	push   $0x80264c
  802620:	53                   	push   %ebx
  802621:	e8 0c ff ff ff       	call   802532 <sys_env_set_pgfault_upcall>
		if (r) {
  802626:	83 c4 10             	add    $0x10,%esp
  802629:	85 c0                	test   %eax,%eax
  80262b:	74 12                	je     80263f <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  80262d:	50                   	push   %eax
  80262e:	68 74 40 80 00       	push   $0x804074
  802633:	6a 2b                	push   $0x2b
  802635:	68 63 40 80 00       	push   $0x804063
  80263a:	e8 47 f3 ff ff       	call   801986 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80263f:	8b 45 08             	mov    0x8(%ebp),%eax
  802642:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802647:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80264a:	c9                   	leave  
  80264b:	c3                   	ret    

0080264c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80264c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80264d:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802652:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802654:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  802657:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  80265b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  802660:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  802664:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  802666:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  802669:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  80266a:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  80266d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  80266e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  80266f:	c3                   	ret    

00802670 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802670:	55                   	push   %ebp
  802671:	89 e5                	mov    %esp,%ebp
  802673:	56                   	push   %esi
  802674:	53                   	push   %ebx
  802675:	8b 75 08             	mov    0x8(%ebp),%esi
  802678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  80267e:	85 c0                	test   %eax,%eax
  802680:	74 3e                	je     8026c0 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  802682:	83 ec 0c             	sub    $0xc,%esp
  802685:	50                   	push   %eax
  802686:	e8 0c ff ff ff       	call   802597 <sys_ipc_recv>
  80268b:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  80268d:	83 c4 10             	add    $0x10,%esp
  802690:	85 f6                	test   %esi,%esi
  802692:	74 13                	je     8026a7 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802694:	b8 00 00 00 00       	mov    $0x0,%eax
  802699:	85 d2                	test   %edx,%edx
  80269b:	75 08                	jne    8026a5 <ipc_recv+0x35>
  80269d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026a2:	8b 40 74             	mov    0x74(%eax),%eax
  8026a5:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8026a7:	85 db                	test   %ebx,%ebx
  8026a9:	74 48                	je     8026f3 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  8026ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8026b0:	85 d2                	test   %edx,%edx
  8026b2:	75 08                	jne    8026bc <ipc_recv+0x4c>
  8026b4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026b9:	8b 40 78             	mov    0x78(%eax),%eax
  8026bc:	89 03                	mov    %eax,(%ebx)
  8026be:	eb 33                	jmp    8026f3 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  8026c0:	83 ec 0c             	sub    $0xc,%esp
  8026c3:	68 00 00 c0 ee       	push   $0xeec00000
  8026c8:	e8 ca fe ff ff       	call   802597 <sys_ipc_recv>
  8026cd:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  8026cf:	83 c4 10             	add    $0x10,%esp
  8026d2:	85 f6                	test   %esi,%esi
  8026d4:	74 13                	je     8026e9 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  8026d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8026db:	85 d2                	test   %edx,%edx
  8026dd:	75 08                	jne    8026e7 <ipc_recv+0x77>
  8026df:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026e4:	8b 40 74             	mov    0x74(%eax),%eax
  8026e7:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8026e9:	85 db                	test   %ebx,%ebx
  8026eb:	74 06                	je     8026f3 <ipc_recv+0x83>
			*perm_store = 0;
  8026ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  8026f3:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  8026f5:	85 d2                	test   %edx,%edx
  8026f7:	75 08                	jne    802701 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  8026f9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026fe:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  802701:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802704:	5b                   	pop    %ebx
  802705:	5e                   	pop    %esi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    

00802708 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802708:	55                   	push   %ebp
  802709:	89 e5                	mov    %esp,%ebp
  80270b:	57                   	push   %edi
  80270c:	56                   	push   %esi
  80270d:	53                   	push   %ebx
  80270e:	83 ec 0c             	sub    $0xc,%esp
  802711:	8b 7d 08             	mov    0x8(%ebp),%edi
  802714:	8b 75 0c             	mov    0xc(%ebp),%esi
  802717:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80271a:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  80271c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802721:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802724:	eb 1c                	jmp    802742 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  802726:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802729:	74 12                	je     80273d <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  80272b:	50                   	push   %eax
  80272c:	68 99 40 80 00       	push   $0x804099
  802731:	6a 4f                	push   $0x4f
  802733:	68 b4 40 80 00       	push   $0x8040b4
  802738:	e8 49 f2 ff ff       	call   801986 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  80273d:	e8 86 fc ff ff       	call   8023c8 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802742:	ff 75 14             	pushl  0x14(%ebp)
  802745:	53                   	push   %ebx
  802746:	56                   	push   %esi
  802747:	57                   	push   %edi
  802748:	e8 27 fe ff ff       	call   802574 <sys_ipc_try_send>
  80274d:	83 c4 10             	add    $0x10,%esp
  802750:	85 c0                	test   %eax,%eax
  802752:	78 d2                	js     802726 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802757:	5b                   	pop    %ebx
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    

0080275c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80275c:	55                   	push   %ebp
  80275d:	89 e5                	mov    %esp,%ebp
  80275f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802762:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802767:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80276a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802770:	8b 52 50             	mov    0x50(%edx),%edx
  802773:	39 ca                	cmp    %ecx,%edx
  802775:	75 0d                	jne    802784 <ipc_find_env+0x28>
			return envs[i].env_id;
  802777:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80277a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80277f:	8b 40 48             	mov    0x48(%eax),%eax
  802782:	eb 0f                	jmp    802793 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802784:	83 c0 01             	add    $0x1,%eax
  802787:	3d 00 04 00 00       	cmp    $0x400,%eax
  80278c:	75 d9                	jne    802767 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80278e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802793:	5d                   	pop    %ebp
  802794:	c3                   	ret    

00802795 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802795:	55                   	push   %ebp
  802796:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802798:	8b 45 08             	mov    0x8(%ebp),%eax
  80279b:	05 00 00 00 30       	add    $0x30000000,%eax
  8027a0:	c1 e8 0c             	shr    $0xc,%eax
}
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    

008027a5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8027a5:	55                   	push   %ebp
  8027a6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8027a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8027b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8027b5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8027ba:	5d                   	pop    %ebp
  8027bb:	c3                   	ret    

008027bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8027bc:	55                   	push   %ebp
  8027bd:	89 e5                	mov    %esp,%ebp
  8027bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027c2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8027c7:	89 c2                	mov    %eax,%edx
  8027c9:	c1 ea 16             	shr    $0x16,%edx
  8027cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027d3:	f6 c2 01             	test   $0x1,%dl
  8027d6:	74 11                	je     8027e9 <fd_alloc+0x2d>
  8027d8:	89 c2                	mov    %eax,%edx
  8027da:	c1 ea 0c             	shr    $0xc,%edx
  8027dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027e4:	f6 c2 01             	test   $0x1,%dl
  8027e7:	75 09                	jne    8027f2 <fd_alloc+0x36>
			*fd_store = fd;
  8027e9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8027eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8027f0:	eb 17                	jmp    802809 <fd_alloc+0x4d>
  8027f2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8027f7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8027fc:	75 c9                	jne    8027c7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8027fe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802804:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802809:	5d                   	pop    %ebp
  80280a:	c3                   	ret    

0080280b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80280b:	55                   	push   %ebp
  80280c:	89 e5                	mov    %esp,%ebp
  80280e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802811:	83 f8 1f             	cmp    $0x1f,%eax
  802814:	77 36                	ja     80284c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802816:	c1 e0 0c             	shl    $0xc,%eax
  802819:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80281e:	89 c2                	mov    %eax,%edx
  802820:	c1 ea 16             	shr    $0x16,%edx
  802823:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80282a:	f6 c2 01             	test   $0x1,%dl
  80282d:	74 24                	je     802853 <fd_lookup+0x48>
  80282f:	89 c2                	mov    %eax,%edx
  802831:	c1 ea 0c             	shr    $0xc,%edx
  802834:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80283b:	f6 c2 01             	test   $0x1,%dl
  80283e:	74 1a                	je     80285a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802840:	8b 55 0c             	mov    0xc(%ebp),%edx
  802843:	89 02                	mov    %eax,(%edx)
	return 0;
  802845:	b8 00 00 00 00       	mov    $0x0,%eax
  80284a:	eb 13                	jmp    80285f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80284c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802851:	eb 0c                	jmp    80285f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802858:	eb 05                	jmp    80285f <fd_lookup+0x54>
  80285a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    

00802861 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802861:	55                   	push   %ebp
  802862:	89 e5                	mov    %esp,%ebp
  802864:	83 ec 08             	sub    $0x8,%esp
  802867:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80286a:	ba 40 41 80 00       	mov    $0x804140,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80286f:	eb 13                	jmp    802884 <dev_lookup+0x23>
  802871:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802874:	39 08                	cmp    %ecx,(%eax)
  802876:	75 0c                	jne    802884 <dev_lookup+0x23>
			*dev = devtab[i];
  802878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80287b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80287d:	b8 00 00 00 00       	mov    $0x0,%eax
  802882:	eb 2e                	jmp    8028b2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802884:	8b 02                	mov    (%edx),%eax
  802886:	85 c0                	test   %eax,%eax
  802888:	75 e7                	jne    802871 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80288a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80288f:	8b 40 48             	mov    0x48(%eax),%eax
  802892:	83 ec 04             	sub    $0x4,%esp
  802895:	51                   	push   %ecx
  802896:	50                   	push   %eax
  802897:	68 c0 40 80 00       	push   $0x8040c0
  80289c:	e8 be f1 ff ff       	call   801a5f <cprintf>
	*dev = 0;
  8028a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8028aa:	83 c4 10             	add    $0x10,%esp
  8028ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8028b2:	c9                   	leave  
  8028b3:	c3                   	ret    

008028b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8028b4:	55                   	push   %ebp
  8028b5:	89 e5                	mov    %esp,%ebp
  8028b7:	56                   	push   %esi
  8028b8:	53                   	push   %ebx
  8028b9:	83 ec 10             	sub    $0x10,%esp
  8028bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8028bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8028c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028c5:	50                   	push   %eax
  8028c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8028cc:	c1 e8 0c             	shr    $0xc,%eax
  8028cf:	50                   	push   %eax
  8028d0:	e8 36 ff ff ff       	call   80280b <fd_lookup>
  8028d5:	83 c4 08             	add    $0x8,%esp
  8028d8:	85 c0                	test   %eax,%eax
  8028da:	78 05                	js     8028e1 <fd_close+0x2d>
	    || fd != fd2)
  8028dc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028df:	74 0c                	je     8028ed <fd_close+0x39>
		return (must_exist ? r : 0);
  8028e1:	84 db                	test   %bl,%bl
  8028e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8028e8:	0f 44 c2             	cmove  %edx,%eax
  8028eb:	eb 41                	jmp    80292e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8028ed:	83 ec 08             	sub    $0x8,%esp
  8028f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028f3:	50                   	push   %eax
  8028f4:	ff 36                	pushl  (%esi)
  8028f6:	e8 66 ff ff ff       	call   802861 <dev_lookup>
  8028fb:	89 c3                	mov    %eax,%ebx
  8028fd:	83 c4 10             	add    $0x10,%esp
  802900:	85 c0                	test   %eax,%eax
  802902:	78 1a                	js     80291e <fd_close+0x6a>
		if (dev->dev_close)
  802904:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802907:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80290a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80290f:	85 c0                	test   %eax,%eax
  802911:	74 0b                	je     80291e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802913:	83 ec 0c             	sub    $0xc,%esp
  802916:	56                   	push   %esi
  802917:	ff d0                	call   *%eax
  802919:	89 c3                	mov    %eax,%ebx
  80291b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80291e:	83 ec 08             	sub    $0x8,%esp
  802921:	56                   	push   %esi
  802922:	6a 00                	push   $0x0
  802924:	e8 43 fb ff ff       	call   80246c <sys_page_unmap>
	return r;
  802929:	83 c4 10             	add    $0x10,%esp
  80292c:	89 d8                	mov    %ebx,%eax
}
  80292e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802931:	5b                   	pop    %ebx
  802932:	5e                   	pop    %esi
  802933:	5d                   	pop    %ebp
  802934:	c3                   	ret    

00802935 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802935:	55                   	push   %ebp
  802936:	89 e5                	mov    %esp,%ebp
  802938:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80293b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80293e:	50                   	push   %eax
  80293f:	ff 75 08             	pushl  0x8(%ebp)
  802942:	e8 c4 fe ff ff       	call   80280b <fd_lookup>
  802947:	83 c4 08             	add    $0x8,%esp
  80294a:	85 c0                	test   %eax,%eax
  80294c:	78 10                	js     80295e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80294e:	83 ec 08             	sub    $0x8,%esp
  802951:	6a 01                	push   $0x1
  802953:	ff 75 f4             	pushl  -0xc(%ebp)
  802956:	e8 59 ff ff ff       	call   8028b4 <fd_close>
  80295b:	83 c4 10             	add    $0x10,%esp
}
  80295e:	c9                   	leave  
  80295f:	c3                   	ret    

00802960 <close_all>:

void
close_all(void)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	53                   	push   %ebx
  802964:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802967:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80296c:	83 ec 0c             	sub    $0xc,%esp
  80296f:	53                   	push   %ebx
  802970:	e8 c0 ff ff ff       	call   802935 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802975:	83 c3 01             	add    $0x1,%ebx
  802978:	83 c4 10             	add    $0x10,%esp
  80297b:	83 fb 20             	cmp    $0x20,%ebx
  80297e:	75 ec                	jne    80296c <close_all+0xc>
		close(i);
}
  802980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802983:	c9                   	leave  
  802984:	c3                   	ret    

00802985 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802985:	55                   	push   %ebp
  802986:	89 e5                	mov    %esp,%ebp
  802988:	57                   	push   %edi
  802989:	56                   	push   %esi
  80298a:	53                   	push   %ebx
  80298b:	83 ec 2c             	sub    $0x2c,%esp
  80298e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802991:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802994:	50                   	push   %eax
  802995:	ff 75 08             	pushl  0x8(%ebp)
  802998:	e8 6e fe ff ff       	call   80280b <fd_lookup>
  80299d:	83 c4 08             	add    $0x8,%esp
  8029a0:	85 c0                	test   %eax,%eax
  8029a2:	0f 88 c1 00 00 00    	js     802a69 <dup+0xe4>
		return r;
	close(newfdnum);
  8029a8:	83 ec 0c             	sub    $0xc,%esp
  8029ab:	56                   	push   %esi
  8029ac:	e8 84 ff ff ff       	call   802935 <close>

	newfd = INDEX2FD(newfdnum);
  8029b1:	89 f3                	mov    %esi,%ebx
  8029b3:	c1 e3 0c             	shl    $0xc,%ebx
  8029b6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8029bc:	83 c4 04             	add    $0x4,%esp
  8029bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8029c2:	e8 de fd ff ff       	call   8027a5 <fd2data>
  8029c7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8029c9:	89 1c 24             	mov    %ebx,(%esp)
  8029cc:	e8 d4 fd ff ff       	call   8027a5 <fd2data>
  8029d1:	83 c4 10             	add    $0x10,%esp
  8029d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029d7:	89 f8                	mov    %edi,%eax
  8029d9:	c1 e8 16             	shr    $0x16,%eax
  8029dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029e3:	a8 01                	test   $0x1,%al
  8029e5:	74 37                	je     802a1e <dup+0x99>
  8029e7:	89 f8                	mov    %edi,%eax
  8029e9:	c1 e8 0c             	shr    $0xc,%eax
  8029ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029f3:	f6 c2 01             	test   $0x1,%dl
  8029f6:	74 26                	je     802a1e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8029f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029ff:	83 ec 0c             	sub    $0xc,%esp
  802a02:	25 07 0e 00 00       	and    $0xe07,%eax
  802a07:	50                   	push   %eax
  802a08:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a0b:	6a 00                	push   $0x0
  802a0d:	57                   	push   %edi
  802a0e:	6a 00                	push   $0x0
  802a10:	e8 15 fa ff ff       	call   80242a <sys_page_map>
  802a15:	89 c7                	mov    %eax,%edi
  802a17:	83 c4 20             	add    $0x20,%esp
  802a1a:	85 c0                	test   %eax,%eax
  802a1c:	78 2e                	js     802a4c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a21:	89 d0                	mov    %edx,%eax
  802a23:	c1 e8 0c             	shr    $0xc,%eax
  802a26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a2d:	83 ec 0c             	sub    $0xc,%esp
  802a30:	25 07 0e 00 00       	and    $0xe07,%eax
  802a35:	50                   	push   %eax
  802a36:	53                   	push   %ebx
  802a37:	6a 00                	push   $0x0
  802a39:	52                   	push   %edx
  802a3a:	6a 00                	push   $0x0
  802a3c:	e8 e9 f9 ff ff       	call   80242a <sys_page_map>
  802a41:	89 c7                	mov    %eax,%edi
  802a43:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a46:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a48:	85 ff                	test   %edi,%edi
  802a4a:	79 1d                	jns    802a69 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a4c:	83 ec 08             	sub    $0x8,%esp
  802a4f:	53                   	push   %ebx
  802a50:	6a 00                	push   $0x0
  802a52:	e8 15 fa ff ff       	call   80246c <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a57:	83 c4 08             	add    $0x8,%esp
  802a5a:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a5d:	6a 00                	push   $0x0
  802a5f:	e8 08 fa ff ff       	call   80246c <sys_page_unmap>
	return r;
  802a64:	83 c4 10             	add    $0x10,%esp
  802a67:	89 f8                	mov    %edi,%eax
}
  802a69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a6c:	5b                   	pop    %ebx
  802a6d:	5e                   	pop    %esi
  802a6e:	5f                   	pop    %edi
  802a6f:	5d                   	pop    %ebp
  802a70:	c3                   	ret    

00802a71 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a71:	55                   	push   %ebp
  802a72:	89 e5                	mov    %esp,%ebp
  802a74:	53                   	push   %ebx
  802a75:	83 ec 14             	sub    $0x14,%esp
  802a78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a7e:	50                   	push   %eax
  802a7f:	53                   	push   %ebx
  802a80:	e8 86 fd ff ff       	call   80280b <fd_lookup>
  802a85:	83 c4 08             	add    $0x8,%esp
  802a88:	89 c2                	mov    %eax,%edx
  802a8a:	85 c0                	test   %eax,%eax
  802a8c:	78 6d                	js     802afb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a8e:	83 ec 08             	sub    $0x8,%esp
  802a91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a94:	50                   	push   %eax
  802a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a98:	ff 30                	pushl  (%eax)
  802a9a:	e8 c2 fd ff ff       	call   802861 <dev_lookup>
  802a9f:	83 c4 10             	add    $0x10,%esp
  802aa2:	85 c0                	test   %eax,%eax
  802aa4:	78 4c                	js     802af2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802aa6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802aa9:	8b 42 08             	mov    0x8(%edx),%eax
  802aac:	83 e0 03             	and    $0x3,%eax
  802aaf:	83 f8 01             	cmp    $0x1,%eax
  802ab2:	75 21                	jne    802ad5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ab4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ab9:	8b 40 48             	mov    0x48(%eax),%eax
  802abc:	83 ec 04             	sub    $0x4,%esp
  802abf:	53                   	push   %ebx
  802ac0:	50                   	push   %eax
  802ac1:	68 04 41 80 00       	push   $0x804104
  802ac6:	e8 94 ef ff ff       	call   801a5f <cprintf>
		return -E_INVAL;
  802acb:	83 c4 10             	add    $0x10,%esp
  802ace:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ad3:	eb 26                	jmp    802afb <read+0x8a>
	}
	if (!dev->dev_read)
  802ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ad8:	8b 40 08             	mov    0x8(%eax),%eax
  802adb:	85 c0                	test   %eax,%eax
  802add:	74 17                	je     802af6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802adf:	83 ec 04             	sub    $0x4,%esp
  802ae2:	ff 75 10             	pushl  0x10(%ebp)
  802ae5:	ff 75 0c             	pushl  0xc(%ebp)
  802ae8:	52                   	push   %edx
  802ae9:	ff d0                	call   *%eax
  802aeb:	89 c2                	mov    %eax,%edx
  802aed:	83 c4 10             	add    $0x10,%esp
  802af0:	eb 09                	jmp    802afb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802af2:	89 c2                	mov    %eax,%edx
  802af4:	eb 05                	jmp    802afb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802af6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802afb:	89 d0                	mov    %edx,%eax
  802afd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b00:	c9                   	leave  
  802b01:	c3                   	ret    

00802b02 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b02:	55                   	push   %ebp
  802b03:	89 e5                	mov    %esp,%ebp
  802b05:	57                   	push   %edi
  802b06:	56                   	push   %esi
  802b07:	53                   	push   %ebx
  802b08:	83 ec 0c             	sub    $0xc,%esp
  802b0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b0e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b11:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b16:	eb 21                	jmp    802b39 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b18:	83 ec 04             	sub    $0x4,%esp
  802b1b:	89 f0                	mov    %esi,%eax
  802b1d:	29 d8                	sub    %ebx,%eax
  802b1f:	50                   	push   %eax
  802b20:	89 d8                	mov    %ebx,%eax
  802b22:	03 45 0c             	add    0xc(%ebp),%eax
  802b25:	50                   	push   %eax
  802b26:	57                   	push   %edi
  802b27:	e8 45 ff ff ff       	call   802a71 <read>
		if (m < 0)
  802b2c:	83 c4 10             	add    $0x10,%esp
  802b2f:	85 c0                	test   %eax,%eax
  802b31:	78 10                	js     802b43 <readn+0x41>
			return m;
		if (m == 0)
  802b33:	85 c0                	test   %eax,%eax
  802b35:	74 0a                	je     802b41 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b37:	01 c3                	add    %eax,%ebx
  802b39:	39 f3                	cmp    %esi,%ebx
  802b3b:	72 db                	jb     802b18 <readn+0x16>
  802b3d:	89 d8                	mov    %ebx,%eax
  802b3f:	eb 02                	jmp    802b43 <readn+0x41>
  802b41:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b46:	5b                   	pop    %ebx
  802b47:	5e                   	pop    %esi
  802b48:	5f                   	pop    %edi
  802b49:	5d                   	pop    %ebp
  802b4a:	c3                   	ret    

00802b4b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b4b:	55                   	push   %ebp
  802b4c:	89 e5                	mov    %esp,%ebp
  802b4e:	53                   	push   %ebx
  802b4f:	83 ec 14             	sub    $0x14,%esp
  802b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b58:	50                   	push   %eax
  802b59:	53                   	push   %ebx
  802b5a:	e8 ac fc ff ff       	call   80280b <fd_lookup>
  802b5f:	83 c4 08             	add    $0x8,%esp
  802b62:	89 c2                	mov    %eax,%edx
  802b64:	85 c0                	test   %eax,%eax
  802b66:	78 68                	js     802bd0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b68:	83 ec 08             	sub    $0x8,%esp
  802b6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b6e:	50                   	push   %eax
  802b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b72:	ff 30                	pushl  (%eax)
  802b74:	e8 e8 fc ff ff       	call   802861 <dev_lookup>
  802b79:	83 c4 10             	add    $0x10,%esp
  802b7c:	85 c0                	test   %eax,%eax
  802b7e:	78 47                	js     802bc7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b83:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b87:	75 21                	jne    802baa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802b89:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b8e:	8b 40 48             	mov    0x48(%eax),%eax
  802b91:	83 ec 04             	sub    $0x4,%esp
  802b94:	53                   	push   %ebx
  802b95:	50                   	push   %eax
  802b96:	68 20 41 80 00       	push   $0x804120
  802b9b:	e8 bf ee ff ff       	call   801a5f <cprintf>
		return -E_INVAL;
  802ba0:	83 c4 10             	add    $0x10,%esp
  802ba3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ba8:	eb 26                	jmp    802bd0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802bad:	8b 52 0c             	mov    0xc(%edx),%edx
  802bb0:	85 d2                	test   %edx,%edx
  802bb2:	74 17                	je     802bcb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802bb4:	83 ec 04             	sub    $0x4,%esp
  802bb7:	ff 75 10             	pushl  0x10(%ebp)
  802bba:	ff 75 0c             	pushl  0xc(%ebp)
  802bbd:	50                   	push   %eax
  802bbe:	ff d2                	call   *%edx
  802bc0:	89 c2                	mov    %eax,%edx
  802bc2:	83 c4 10             	add    $0x10,%esp
  802bc5:	eb 09                	jmp    802bd0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bc7:	89 c2                	mov    %eax,%edx
  802bc9:	eb 05                	jmp    802bd0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802bcb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802bd0:	89 d0                	mov    %edx,%eax
  802bd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bd5:	c9                   	leave  
  802bd6:	c3                   	ret    

00802bd7 <seek>:

int
seek(int fdnum, off_t offset)
{
  802bd7:	55                   	push   %ebp
  802bd8:	89 e5                	mov    %esp,%ebp
  802bda:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bdd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802be0:	50                   	push   %eax
  802be1:	ff 75 08             	pushl  0x8(%ebp)
  802be4:	e8 22 fc ff ff       	call   80280b <fd_lookup>
  802be9:	83 c4 08             	add    $0x8,%esp
  802bec:	85 c0                	test   %eax,%eax
  802bee:	78 0e                	js     802bfe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802bf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bf6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bfe:	c9                   	leave  
  802bff:	c3                   	ret    

00802c00 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802c00:	55                   	push   %ebp
  802c01:	89 e5                	mov    %esp,%ebp
  802c03:	53                   	push   %ebx
  802c04:	83 ec 14             	sub    $0x14,%esp
  802c07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c0d:	50                   	push   %eax
  802c0e:	53                   	push   %ebx
  802c0f:	e8 f7 fb ff ff       	call   80280b <fd_lookup>
  802c14:	83 c4 08             	add    $0x8,%esp
  802c17:	89 c2                	mov    %eax,%edx
  802c19:	85 c0                	test   %eax,%eax
  802c1b:	78 65                	js     802c82 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c1d:	83 ec 08             	sub    $0x8,%esp
  802c20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c23:	50                   	push   %eax
  802c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c27:	ff 30                	pushl  (%eax)
  802c29:	e8 33 fc ff ff       	call   802861 <dev_lookup>
  802c2e:	83 c4 10             	add    $0x10,%esp
  802c31:	85 c0                	test   %eax,%eax
  802c33:	78 44                	js     802c79 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c38:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c3c:	75 21                	jne    802c5f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c3e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c43:	8b 40 48             	mov    0x48(%eax),%eax
  802c46:	83 ec 04             	sub    $0x4,%esp
  802c49:	53                   	push   %ebx
  802c4a:	50                   	push   %eax
  802c4b:	68 e0 40 80 00       	push   $0x8040e0
  802c50:	e8 0a ee ff ff       	call   801a5f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c55:	83 c4 10             	add    $0x10,%esp
  802c58:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c5d:	eb 23                	jmp    802c82 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c62:	8b 52 18             	mov    0x18(%edx),%edx
  802c65:	85 d2                	test   %edx,%edx
  802c67:	74 14                	je     802c7d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c69:	83 ec 08             	sub    $0x8,%esp
  802c6c:	ff 75 0c             	pushl  0xc(%ebp)
  802c6f:	50                   	push   %eax
  802c70:	ff d2                	call   *%edx
  802c72:	89 c2                	mov    %eax,%edx
  802c74:	83 c4 10             	add    $0x10,%esp
  802c77:	eb 09                	jmp    802c82 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c79:	89 c2                	mov    %eax,%edx
  802c7b:	eb 05                	jmp    802c82 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c7d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c82:	89 d0                	mov    %edx,%eax
  802c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c87:	c9                   	leave  
  802c88:	c3                   	ret    

00802c89 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802c89:	55                   	push   %ebp
  802c8a:	89 e5                	mov    %esp,%ebp
  802c8c:	53                   	push   %ebx
  802c8d:	83 ec 14             	sub    $0x14,%esp
  802c90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c96:	50                   	push   %eax
  802c97:	ff 75 08             	pushl  0x8(%ebp)
  802c9a:	e8 6c fb ff ff       	call   80280b <fd_lookup>
  802c9f:	83 c4 08             	add    $0x8,%esp
  802ca2:	89 c2                	mov    %eax,%edx
  802ca4:	85 c0                	test   %eax,%eax
  802ca6:	78 58                	js     802d00 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ca8:	83 ec 08             	sub    $0x8,%esp
  802cab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cae:	50                   	push   %eax
  802caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cb2:	ff 30                	pushl  (%eax)
  802cb4:	e8 a8 fb ff ff       	call   802861 <dev_lookup>
  802cb9:	83 c4 10             	add    $0x10,%esp
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	78 37                	js     802cf7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cc3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802cc7:	74 32                	je     802cfb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802cc9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802ccc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802cd3:	00 00 00 
	stat->st_isdir = 0;
  802cd6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cdd:	00 00 00 
	stat->st_dev = dev;
  802ce0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802ce6:	83 ec 08             	sub    $0x8,%esp
  802ce9:	53                   	push   %ebx
  802cea:	ff 75 f0             	pushl  -0x10(%ebp)
  802ced:	ff 50 14             	call   *0x14(%eax)
  802cf0:	89 c2                	mov    %eax,%edx
  802cf2:	83 c4 10             	add    $0x10,%esp
  802cf5:	eb 09                	jmp    802d00 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cf7:	89 c2                	mov    %eax,%edx
  802cf9:	eb 05                	jmp    802d00 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802cfb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802d00:	89 d0                	mov    %edx,%eax
  802d02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d05:	c9                   	leave  
  802d06:	c3                   	ret    

00802d07 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802d07:	55                   	push   %ebp
  802d08:	89 e5                	mov    %esp,%ebp
  802d0a:	56                   	push   %esi
  802d0b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802d0c:	83 ec 08             	sub    $0x8,%esp
  802d0f:	6a 00                	push   $0x0
  802d11:	ff 75 08             	pushl  0x8(%ebp)
  802d14:	e8 d6 01 00 00       	call   802eef <open>
  802d19:	89 c3                	mov    %eax,%ebx
  802d1b:	83 c4 10             	add    $0x10,%esp
  802d1e:	85 c0                	test   %eax,%eax
  802d20:	78 1b                	js     802d3d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802d22:	83 ec 08             	sub    $0x8,%esp
  802d25:	ff 75 0c             	pushl  0xc(%ebp)
  802d28:	50                   	push   %eax
  802d29:	e8 5b ff ff ff       	call   802c89 <fstat>
  802d2e:	89 c6                	mov    %eax,%esi
	close(fd);
  802d30:	89 1c 24             	mov    %ebx,(%esp)
  802d33:	e8 fd fb ff ff       	call   802935 <close>
	return r;
  802d38:	83 c4 10             	add    $0x10,%esp
  802d3b:	89 f0                	mov    %esi,%eax
}
  802d3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d40:	5b                   	pop    %ebx
  802d41:	5e                   	pop    %esi
  802d42:	5d                   	pop    %ebp
  802d43:	c3                   	ret    

00802d44 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d44:	55                   	push   %ebp
  802d45:	89 e5                	mov    %esp,%ebp
  802d47:	56                   	push   %esi
  802d48:	53                   	push   %ebx
  802d49:	89 c6                	mov    %eax,%esi
  802d4b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d4d:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d54:	75 12                	jne    802d68 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d56:	83 ec 0c             	sub    $0xc,%esp
  802d59:	6a 01                	push   $0x1
  802d5b:	e8 fc f9 ff ff       	call   80275c <ipc_find_env>
  802d60:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d65:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d68:	6a 07                	push   $0x7
  802d6a:	68 00 b0 80 00       	push   $0x80b000
  802d6f:	56                   	push   %esi
  802d70:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d76:	e8 8d f9 ff ff       	call   802708 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d7b:	83 c4 0c             	add    $0xc,%esp
  802d7e:	6a 00                	push   $0x0
  802d80:	53                   	push   %ebx
  802d81:	6a 00                	push   $0x0
  802d83:	e8 e8 f8 ff ff       	call   802670 <ipc_recv>
}
  802d88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d8b:	5b                   	pop    %ebx
  802d8c:	5e                   	pop    %esi
  802d8d:	5d                   	pop    %ebp
  802d8e:	c3                   	ret    

00802d8f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802d8f:	55                   	push   %ebp
  802d90:	89 e5                	mov    %esp,%ebp
  802d92:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802d95:	8b 45 08             	mov    0x8(%ebp),%eax
  802d98:	8b 40 0c             	mov    0xc(%eax),%eax
  802d9b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802da3:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802da8:	ba 00 00 00 00       	mov    $0x0,%edx
  802dad:	b8 02 00 00 00       	mov    $0x2,%eax
  802db2:	e8 8d ff ff ff       	call   802d44 <fsipc>
}
  802db7:	c9                   	leave  
  802db8:	c3                   	ret    

00802db9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802db9:	55                   	push   %ebp
  802dba:	89 e5                	mov    %esp,%ebp
  802dbc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  802dc2:	8b 40 0c             	mov    0xc(%eax),%eax
  802dc5:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802dca:	ba 00 00 00 00       	mov    $0x0,%edx
  802dcf:	b8 06 00 00 00       	mov    $0x6,%eax
  802dd4:	e8 6b ff ff ff       	call   802d44 <fsipc>
}
  802dd9:	c9                   	leave  
  802dda:	c3                   	ret    

00802ddb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802ddb:	55                   	push   %ebp
  802ddc:	89 e5                	mov    %esp,%ebp
  802dde:	53                   	push   %ebx
  802ddf:	83 ec 04             	sub    $0x4,%esp
  802de2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802de5:	8b 45 08             	mov    0x8(%ebp),%eax
  802de8:	8b 40 0c             	mov    0xc(%eax),%eax
  802deb:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802df0:	ba 00 00 00 00       	mov    $0x0,%edx
  802df5:	b8 05 00 00 00       	mov    $0x5,%eax
  802dfa:	e8 45 ff ff ff       	call   802d44 <fsipc>
  802dff:	85 c0                	test   %eax,%eax
  802e01:	78 2c                	js     802e2f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802e03:	83 ec 08             	sub    $0x8,%esp
  802e06:	68 00 b0 80 00       	push   $0x80b000
  802e0b:	53                   	push   %ebx
  802e0c:	e8 d3 f1 ff ff       	call   801fe4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802e11:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802e16:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802e1c:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802e21:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e27:	83 c4 10             	add    $0x10,%esp
  802e2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e32:	c9                   	leave  
  802e33:	c3                   	ret    

00802e34 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e34:	55                   	push   %ebp
  802e35:	89 e5                	mov    %esp,%ebp
  802e37:	83 ec 0c             	sub    $0xc,%esp
  802e3a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  802e40:	8b 52 0c             	mov    0xc(%edx),%edx
  802e43:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802e49:	a3 04 b0 80 00       	mov    %eax,0x80b004

	memmove(fsipcbuf.write.req_buf, buf, n);
  802e4e:	50                   	push   %eax
  802e4f:	ff 75 0c             	pushl  0xc(%ebp)
  802e52:	68 08 b0 80 00       	push   $0x80b008
  802e57:	e8 1a f3 ff ff       	call   802176 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802e5c:	ba 00 00 00 00       	mov    $0x0,%edx
  802e61:	b8 04 00 00 00       	mov    $0x4,%eax
  802e66:	e8 d9 fe ff ff       	call   802d44 <fsipc>
	//panic("devfile_write not implemented");
}
  802e6b:	c9                   	leave  
  802e6c:	c3                   	ret    

00802e6d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e6d:	55                   	push   %ebp
  802e6e:	89 e5                	mov    %esp,%ebp
  802e70:	56                   	push   %esi
  802e71:	53                   	push   %ebx
  802e72:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802e75:	8b 45 08             	mov    0x8(%ebp),%eax
  802e78:	8b 40 0c             	mov    0xc(%eax),%eax
  802e7b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802e80:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802e86:	ba 00 00 00 00       	mov    $0x0,%edx
  802e8b:	b8 03 00 00 00       	mov    $0x3,%eax
  802e90:	e8 af fe ff ff       	call   802d44 <fsipc>
  802e95:	89 c3                	mov    %eax,%ebx
  802e97:	85 c0                	test   %eax,%eax
  802e99:	78 4b                	js     802ee6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802e9b:	39 c6                	cmp    %eax,%esi
  802e9d:	73 16                	jae    802eb5 <devfile_read+0x48>
  802e9f:	68 50 41 80 00       	push   $0x804150
  802ea4:	68 7d 37 80 00       	push   $0x80377d
  802ea9:	6a 7c                	push   $0x7c
  802eab:	68 57 41 80 00       	push   $0x804157
  802eb0:	e8 d1 ea ff ff       	call   801986 <_panic>
	assert(r <= PGSIZE);
  802eb5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802eba:	7e 16                	jle    802ed2 <devfile_read+0x65>
  802ebc:	68 62 41 80 00       	push   $0x804162
  802ec1:	68 7d 37 80 00       	push   $0x80377d
  802ec6:	6a 7d                	push   $0x7d
  802ec8:	68 57 41 80 00       	push   $0x804157
  802ecd:	e8 b4 ea ff ff       	call   801986 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802ed2:	83 ec 04             	sub    $0x4,%esp
  802ed5:	50                   	push   %eax
  802ed6:	68 00 b0 80 00       	push   $0x80b000
  802edb:	ff 75 0c             	pushl  0xc(%ebp)
  802ede:	e8 93 f2 ff ff       	call   802176 <memmove>
	return r;
  802ee3:	83 c4 10             	add    $0x10,%esp
}
  802ee6:	89 d8                	mov    %ebx,%eax
  802ee8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eeb:	5b                   	pop    %ebx
  802eec:	5e                   	pop    %esi
  802eed:	5d                   	pop    %ebp
  802eee:	c3                   	ret    

00802eef <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802eef:	55                   	push   %ebp
  802ef0:	89 e5                	mov    %esp,%ebp
  802ef2:	53                   	push   %ebx
  802ef3:	83 ec 20             	sub    $0x20,%esp
  802ef6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802ef9:	53                   	push   %ebx
  802efa:	e8 ac f0 ff ff       	call   801fab <strlen>
  802eff:	83 c4 10             	add    $0x10,%esp
  802f02:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f07:	7f 67                	jg     802f70 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f09:	83 ec 0c             	sub    $0xc,%esp
  802f0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f0f:	50                   	push   %eax
  802f10:	e8 a7 f8 ff ff       	call   8027bc <fd_alloc>
  802f15:	83 c4 10             	add    $0x10,%esp
		return r;
  802f18:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f1a:	85 c0                	test   %eax,%eax
  802f1c:	78 57                	js     802f75 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f1e:	83 ec 08             	sub    $0x8,%esp
  802f21:	53                   	push   %ebx
  802f22:	68 00 b0 80 00       	push   $0x80b000
  802f27:	e8 b8 f0 ff ff       	call   801fe4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f2f:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f37:	b8 01 00 00 00       	mov    $0x1,%eax
  802f3c:	e8 03 fe ff ff       	call   802d44 <fsipc>
  802f41:	89 c3                	mov    %eax,%ebx
  802f43:	83 c4 10             	add    $0x10,%esp
  802f46:	85 c0                	test   %eax,%eax
  802f48:	79 14                	jns    802f5e <open+0x6f>
		fd_close(fd, 0);
  802f4a:	83 ec 08             	sub    $0x8,%esp
  802f4d:	6a 00                	push   $0x0
  802f4f:	ff 75 f4             	pushl  -0xc(%ebp)
  802f52:	e8 5d f9 ff ff       	call   8028b4 <fd_close>
		return r;
  802f57:	83 c4 10             	add    $0x10,%esp
  802f5a:	89 da                	mov    %ebx,%edx
  802f5c:	eb 17                	jmp    802f75 <open+0x86>
	}

	return fd2num(fd);
  802f5e:	83 ec 0c             	sub    $0xc,%esp
  802f61:	ff 75 f4             	pushl  -0xc(%ebp)
  802f64:	e8 2c f8 ff ff       	call   802795 <fd2num>
  802f69:	89 c2                	mov    %eax,%edx
  802f6b:	83 c4 10             	add    $0x10,%esp
  802f6e:	eb 05                	jmp    802f75 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802f70:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802f75:	89 d0                	mov    %edx,%eax
  802f77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f7a:	c9                   	leave  
  802f7b:	c3                   	ret    

00802f7c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802f7c:	55                   	push   %ebp
  802f7d:	89 e5                	mov    %esp,%ebp
  802f7f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802f82:	ba 00 00 00 00       	mov    $0x0,%edx
  802f87:	b8 08 00 00 00       	mov    $0x8,%eax
  802f8c:	e8 b3 fd ff ff       	call   802d44 <fsipc>
}
  802f91:	c9                   	leave  
  802f92:	c3                   	ret    

00802f93 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f93:	55                   	push   %ebp
  802f94:	89 e5                	mov    %esp,%ebp
  802f96:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f99:	89 d0                	mov    %edx,%eax
  802f9b:	c1 e8 16             	shr    $0x16,%eax
  802f9e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fa5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802faa:	f6 c1 01             	test   $0x1,%cl
  802fad:	74 1d                	je     802fcc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802faf:	c1 ea 0c             	shr    $0xc,%edx
  802fb2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fb9:	f6 c2 01             	test   $0x1,%dl
  802fbc:	74 0e                	je     802fcc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fbe:	c1 ea 0c             	shr    $0xc,%edx
  802fc1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fc8:	ef 
  802fc9:	0f b7 c0             	movzwl %ax,%eax
}
  802fcc:	5d                   	pop    %ebp
  802fcd:	c3                   	ret    

00802fce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fce:	55                   	push   %ebp
  802fcf:	89 e5                	mov    %esp,%ebp
  802fd1:	56                   	push   %esi
  802fd2:	53                   	push   %ebx
  802fd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fd6:	83 ec 0c             	sub    $0xc,%esp
  802fd9:	ff 75 08             	pushl  0x8(%ebp)
  802fdc:	e8 c4 f7 ff ff       	call   8027a5 <fd2data>
  802fe1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802fe3:	83 c4 08             	add    $0x8,%esp
  802fe6:	68 6e 41 80 00       	push   $0x80416e
  802feb:	53                   	push   %ebx
  802fec:	e8 f3 ef ff ff       	call   801fe4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ff1:	8b 46 04             	mov    0x4(%esi),%eax
  802ff4:	2b 06                	sub    (%esi),%eax
  802ff6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ffc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803003:	00 00 00 
	stat->st_dev = &devpipe;
  803006:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80300d:	90 80 00 
	return 0;
}
  803010:	b8 00 00 00 00       	mov    $0x0,%eax
  803015:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803018:	5b                   	pop    %ebx
  803019:	5e                   	pop    %esi
  80301a:	5d                   	pop    %ebp
  80301b:	c3                   	ret    

0080301c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80301c:	55                   	push   %ebp
  80301d:	89 e5                	mov    %esp,%ebp
  80301f:	53                   	push   %ebx
  803020:	83 ec 0c             	sub    $0xc,%esp
  803023:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803026:	53                   	push   %ebx
  803027:	6a 00                	push   $0x0
  803029:	e8 3e f4 ff ff       	call   80246c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80302e:	89 1c 24             	mov    %ebx,(%esp)
  803031:	e8 6f f7 ff ff       	call   8027a5 <fd2data>
  803036:	83 c4 08             	add    $0x8,%esp
  803039:	50                   	push   %eax
  80303a:	6a 00                	push   $0x0
  80303c:	e8 2b f4 ff ff       	call   80246c <sys_page_unmap>
}
  803041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803044:	c9                   	leave  
  803045:	c3                   	ret    

00803046 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803046:	55                   	push   %ebp
  803047:	89 e5                	mov    %esp,%ebp
  803049:	57                   	push   %edi
  80304a:	56                   	push   %esi
  80304b:	53                   	push   %ebx
  80304c:	83 ec 1c             	sub    $0x1c,%esp
  80304f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803052:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803054:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803059:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80305c:	83 ec 0c             	sub    $0xc,%esp
  80305f:	ff 75 e0             	pushl  -0x20(%ebp)
  803062:	e8 2c ff ff ff       	call   802f93 <pageref>
  803067:	89 c3                	mov    %eax,%ebx
  803069:	89 3c 24             	mov    %edi,(%esp)
  80306c:	e8 22 ff ff ff       	call   802f93 <pageref>
  803071:	83 c4 10             	add    $0x10,%esp
  803074:	39 c3                	cmp    %eax,%ebx
  803076:	0f 94 c1             	sete   %cl
  803079:	0f b6 c9             	movzbl %cl,%ecx
  80307c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80307f:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803085:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803088:	39 ce                	cmp    %ecx,%esi
  80308a:	74 1b                	je     8030a7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80308c:	39 c3                	cmp    %eax,%ebx
  80308e:	75 c4                	jne    803054 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803090:	8b 42 58             	mov    0x58(%edx),%eax
  803093:	ff 75 e4             	pushl  -0x1c(%ebp)
  803096:	50                   	push   %eax
  803097:	56                   	push   %esi
  803098:	68 75 41 80 00       	push   $0x804175
  80309d:	e8 bd e9 ff ff       	call   801a5f <cprintf>
  8030a2:	83 c4 10             	add    $0x10,%esp
  8030a5:	eb ad                	jmp    803054 <_pipeisclosed+0xe>
	}
}
  8030a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030ad:	5b                   	pop    %ebx
  8030ae:	5e                   	pop    %esi
  8030af:	5f                   	pop    %edi
  8030b0:	5d                   	pop    %ebp
  8030b1:	c3                   	ret    

008030b2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030b2:	55                   	push   %ebp
  8030b3:	89 e5                	mov    %esp,%ebp
  8030b5:	57                   	push   %edi
  8030b6:	56                   	push   %esi
  8030b7:	53                   	push   %ebx
  8030b8:	83 ec 28             	sub    $0x28,%esp
  8030bb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030be:	56                   	push   %esi
  8030bf:	e8 e1 f6 ff ff       	call   8027a5 <fd2data>
  8030c4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030c6:	83 c4 10             	add    $0x10,%esp
  8030c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8030ce:	eb 4b                	jmp    80311b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030d0:	89 da                	mov    %ebx,%edx
  8030d2:	89 f0                	mov    %esi,%eax
  8030d4:	e8 6d ff ff ff       	call   803046 <_pipeisclosed>
  8030d9:	85 c0                	test   %eax,%eax
  8030db:	75 48                	jne    803125 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030dd:	e8 e6 f2 ff ff       	call   8023c8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8030e5:	8b 0b                	mov    (%ebx),%ecx
  8030e7:	8d 51 20             	lea    0x20(%ecx),%edx
  8030ea:	39 d0                	cmp    %edx,%eax
  8030ec:	73 e2                	jae    8030d0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030f1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030f5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030f8:	89 c2                	mov    %eax,%edx
  8030fa:	c1 fa 1f             	sar    $0x1f,%edx
  8030fd:	89 d1                	mov    %edx,%ecx
  8030ff:	c1 e9 1b             	shr    $0x1b,%ecx
  803102:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803105:	83 e2 1f             	and    $0x1f,%edx
  803108:	29 ca                	sub    %ecx,%edx
  80310a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80310e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803112:	83 c0 01             	add    $0x1,%eax
  803115:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803118:	83 c7 01             	add    $0x1,%edi
  80311b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80311e:	75 c2                	jne    8030e2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803120:	8b 45 10             	mov    0x10(%ebp),%eax
  803123:	eb 05                	jmp    80312a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803125:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80312a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80312d:	5b                   	pop    %ebx
  80312e:	5e                   	pop    %esi
  80312f:	5f                   	pop    %edi
  803130:	5d                   	pop    %ebp
  803131:	c3                   	ret    

00803132 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803132:	55                   	push   %ebp
  803133:	89 e5                	mov    %esp,%ebp
  803135:	57                   	push   %edi
  803136:	56                   	push   %esi
  803137:	53                   	push   %ebx
  803138:	83 ec 18             	sub    $0x18,%esp
  80313b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80313e:	57                   	push   %edi
  80313f:	e8 61 f6 ff ff       	call   8027a5 <fd2data>
  803144:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803146:	83 c4 10             	add    $0x10,%esp
  803149:	bb 00 00 00 00       	mov    $0x0,%ebx
  80314e:	eb 3d                	jmp    80318d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803150:	85 db                	test   %ebx,%ebx
  803152:	74 04                	je     803158 <devpipe_read+0x26>
				return i;
  803154:	89 d8                	mov    %ebx,%eax
  803156:	eb 44                	jmp    80319c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803158:	89 f2                	mov    %esi,%edx
  80315a:	89 f8                	mov    %edi,%eax
  80315c:	e8 e5 fe ff ff       	call   803046 <_pipeisclosed>
  803161:	85 c0                	test   %eax,%eax
  803163:	75 32                	jne    803197 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803165:	e8 5e f2 ff ff       	call   8023c8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80316a:	8b 06                	mov    (%esi),%eax
  80316c:	3b 46 04             	cmp    0x4(%esi),%eax
  80316f:	74 df                	je     803150 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803171:	99                   	cltd   
  803172:	c1 ea 1b             	shr    $0x1b,%edx
  803175:	01 d0                	add    %edx,%eax
  803177:	83 e0 1f             	and    $0x1f,%eax
  80317a:	29 d0                	sub    %edx,%eax
  80317c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803184:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803187:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80318a:	83 c3 01             	add    $0x1,%ebx
  80318d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803190:	75 d8                	jne    80316a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803192:	8b 45 10             	mov    0x10(%ebp),%eax
  803195:	eb 05                	jmp    80319c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803197:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80319c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80319f:	5b                   	pop    %ebx
  8031a0:	5e                   	pop    %esi
  8031a1:	5f                   	pop    %edi
  8031a2:	5d                   	pop    %ebp
  8031a3:	c3                   	ret    

008031a4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8031a4:	55                   	push   %ebp
  8031a5:	89 e5                	mov    %esp,%ebp
  8031a7:	56                   	push   %esi
  8031a8:	53                   	push   %ebx
  8031a9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8031ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031af:	50                   	push   %eax
  8031b0:	e8 07 f6 ff ff       	call   8027bc <fd_alloc>
  8031b5:	83 c4 10             	add    $0x10,%esp
  8031b8:	89 c2                	mov    %eax,%edx
  8031ba:	85 c0                	test   %eax,%eax
  8031bc:	0f 88 2c 01 00 00    	js     8032ee <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031c2:	83 ec 04             	sub    $0x4,%esp
  8031c5:	68 07 04 00 00       	push   $0x407
  8031ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8031cd:	6a 00                	push   $0x0
  8031cf:	e8 13 f2 ff ff       	call   8023e7 <sys_page_alloc>
  8031d4:	83 c4 10             	add    $0x10,%esp
  8031d7:	89 c2                	mov    %eax,%edx
  8031d9:	85 c0                	test   %eax,%eax
  8031db:	0f 88 0d 01 00 00    	js     8032ee <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031e1:	83 ec 0c             	sub    $0xc,%esp
  8031e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031e7:	50                   	push   %eax
  8031e8:	e8 cf f5 ff ff       	call   8027bc <fd_alloc>
  8031ed:	89 c3                	mov    %eax,%ebx
  8031ef:	83 c4 10             	add    $0x10,%esp
  8031f2:	85 c0                	test   %eax,%eax
  8031f4:	0f 88 e2 00 00 00    	js     8032dc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031fa:	83 ec 04             	sub    $0x4,%esp
  8031fd:	68 07 04 00 00       	push   $0x407
  803202:	ff 75 f0             	pushl  -0x10(%ebp)
  803205:	6a 00                	push   $0x0
  803207:	e8 db f1 ff ff       	call   8023e7 <sys_page_alloc>
  80320c:	89 c3                	mov    %eax,%ebx
  80320e:	83 c4 10             	add    $0x10,%esp
  803211:	85 c0                	test   %eax,%eax
  803213:	0f 88 c3 00 00 00    	js     8032dc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803219:	83 ec 0c             	sub    $0xc,%esp
  80321c:	ff 75 f4             	pushl  -0xc(%ebp)
  80321f:	e8 81 f5 ff ff       	call   8027a5 <fd2data>
  803224:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803226:	83 c4 0c             	add    $0xc,%esp
  803229:	68 07 04 00 00       	push   $0x407
  80322e:	50                   	push   %eax
  80322f:	6a 00                	push   $0x0
  803231:	e8 b1 f1 ff ff       	call   8023e7 <sys_page_alloc>
  803236:	89 c3                	mov    %eax,%ebx
  803238:	83 c4 10             	add    $0x10,%esp
  80323b:	85 c0                	test   %eax,%eax
  80323d:	0f 88 89 00 00 00    	js     8032cc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803243:	83 ec 0c             	sub    $0xc,%esp
  803246:	ff 75 f0             	pushl  -0x10(%ebp)
  803249:	e8 57 f5 ff ff       	call   8027a5 <fd2data>
  80324e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803255:	50                   	push   %eax
  803256:	6a 00                	push   $0x0
  803258:	56                   	push   %esi
  803259:	6a 00                	push   $0x0
  80325b:	e8 ca f1 ff ff       	call   80242a <sys_page_map>
  803260:	89 c3                	mov    %eax,%ebx
  803262:	83 c4 20             	add    $0x20,%esp
  803265:	85 c0                	test   %eax,%eax
  803267:	78 55                	js     8032be <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803269:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803272:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803274:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803277:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80327e:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803284:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803287:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80328c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803293:	83 ec 0c             	sub    $0xc,%esp
  803296:	ff 75 f4             	pushl  -0xc(%ebp)
  803299:	e8 f7 f4 ff ff       	call   802795 <fd2num>
  80329e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032a1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8032a3:	83 c4 04             	add    $0x4,%esp
  8032a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8032a9:	e8 e7 f4 ff ff       	call   802795 <fd2num>
  8032ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032b1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8032b4:	83 c4 10             	add    $0x10,%esp
  8032b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8032bc:	eb 30                	jmp    8032ee <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032be:	83 ec 08             	sub    $0x8,%esp
  8032c1:	56                   	push   %esi
  8032c2:	6a 00                	push   $0x0
  8032c4:	e8 a3 f1 ff ff       	call   80246c <sys_page_unmap>
  8032c9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032cc:	83 ec 08             	sub    $0x8,%esp
  8032cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8032d2:	6a 00                	push   $0x0
  8032d4:	e8 93 f1 ff ff       	call   80246c <sys_page_unmap>
  8032d9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032dc:	83 ec 08             	sub    $0x8,%esp
  8032df:	ff 75 f4             	pushl  -0xc(%ebp)
  8032e2:	6a 00                	push   $0x0
  8032e4:	e8 83 f1 ff ff       	call   80246c <sys_page_unmap>
  8032e9:	83 c4 10             	add    $0x10,%esp
  8032ec:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8032ee:	89 d0                	mov    %edx,%eax
  8032f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032f3:	5b                   	pop    %ebx
  8032f4:	5e                   	pop    %esi
  8032f5:	5d                   	pop    %ebp
  8032f6:	c3                   	ret    

008032f7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8032f7:	55                   	push   %ebp
  8032f8:	89 e5                	mov    %esp,%ebp
  8032fa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803300:	50                   	push   %eax
  803301:	ff 75 08             	pushl  0x8(%ebp)
  803304:	e8 02 f5 ff ff       	call   80280b <fd_lookup>
  803309:	83 c4 10             	add    $0x10,%esp
  80330c:	85 c0                	test   %eax,%eax
  80330e:	78 18                	js     803328 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803310:	83 ec 0c             	sub    $0xc,%esp
  803313:	ff 75 f4             	pushl  -0xc(%ebp)
  803316:	e8 8a f4 ff ff       	call   8027a5 <fd2data>
	return _pipeisclosed(fd, p);
  80331b:	89 c2                	mov    %eax,%edx
  80331d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803320:	e8 21 fd ff ff       	call   803046 <_pipeisclosed>
  803325:	83 c4 10             	add    $0x10,%esp
}
  803328:	c9                   	leave  
  803329:	c3                   	ret    

0080332a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80332a:	55                   	push   %ebp
  80332b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80332d:	b8 00 00 00 00       	mov    $0x0,%eax
  803332:	5d                   	pop    %ebp
  803333:	c3                   	ret    

00803334 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803334:	55                   	push   %ebp
  803335:	89 e5                	mov    %esp,%ebp
  803337:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80333a:	68 8d 41 80 00       	push   $0x80418d
  80333f:	ff 75 0c             	pushl  0xc(%ebp)
  803342:	e8 9d ec ff ff       	call   801fe4 <strcpy>
	return 0;
}
  803347:	b8 00 00 00 00       	mov    $0x0,%eax
  80334c:	c9                   	leave  
  80334d:	c3                   	ret    

0080334e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80334e:	55                   	push   %ebp
  80334f:	89 e5                	mov    %esp,%ebp
  803351:	57                   	push   %edi
  803352:	56                   	push   %esi
  803353:	53                   	push   %ebx
  803354:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80335a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80335f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803365:	eb 2d                	jmp    803394 <devcons_write+0x46>
		m = n - tot;
  803367:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80336a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80336c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80336f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803374:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803377:	83 ec 04             	sub    $0x4,%esp
  80337a:	53                   	push   %ebx
  80337b:	03 45 0c             	add    0xc(%ebp),%eax
  80337e:	50                   	push   %eax
  80337f:	57                   	push   %edi
  803380:	e8 f1 ed ff ff       	call   802176 <memmove>
		sys_cputs(buf, m);
  803385:	83 c4 08             	add    $0x8,%esp
  803388:	53                   	push   %ebx
  803389:	57                   	push   %edi
  80338a:	e8 9c ef ff ff       	call   80232b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80338f:	01 de                	add    %ebx,%esi
  803391:	83 c4 10             	add    $0x10,%esp
  803394:	89 f0                	mov    %esi,%eax
  803396:	3b 75 10             	cmp    0x10(%ebp),%esi
  803399:	72 cc                	jb     803367 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80339b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80339e:	5b                   	pop    %ebx
  80339f:	5e                   	pop    %esi
  8033a0:	5f                   	pop    %edi
  8033a1:	5d                   	pop    %ebp
  8033a2:	c3                   	ret    

008033a3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8033a3:	55                   	push   %ebp
  8033a4:	89 e5                	mov    %esp,%ebp
  8033a6:	83 ec 08             	sub    $0x8,%esp
  8033a9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8033ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8033b2:	74 2a                	je     8033de <devcons_read+0x3b>
  8033b4:	eb 05                	jmp    8033bb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8033b6:	e8 0d f0 ff ff       	call   8023c8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8033bb:	e8 89 ef ff ff       	call   802349 <sys_cgetc>
  8033c0:	85 c0                	test   %eax,%eax
  8033c2:	74 f2                	je     8033b6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8033c4:	85 c0                	test   %eax,%eax
  8033c6:	78 16                	js     8033de <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8033c8:	83 f8 04             	cmp    $0x4,%eax
  8033cb:	74 0c                	je     8033d9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8033cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8033d0:	88 02                	mov    %al,(%edx)
	return 1;
  8033d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8033d7:	eb 05                	jmp    8033de <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8033d9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8033de:	c9                   	leave  
  8033df:	c3                   	ret    

008033e0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8033e0:	55                   	push   %ebp
  8033e1:	89 e5                	mov    %esp,%ebp
  8033e3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8033e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8033e9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8033ec:	6a 01                	push   $0x1
  8033ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8033f1:	50                   	push   %eax
  8033f2:	e8 34 ef ff ff       	call   80232b <sys_cputs>
}
  8033f7:	83 c4 10             	add    $0x10,%esp
  8033fa:	c9                   	leave  
  8033fb:	c3                   	ret    

008033fc <getchar>:

int
getchar(void)
{
  8033fc:	55                   	push   %ebp
  8033fd:	89 e5                	mov    %esp,%ebp
  8033ff:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803402:	6a 01                	push   $0x1
  803404:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803407:	50                   	push   %eax
  803408:	6a 00                	push   $0x0
  80340a:	e8 62 f6 ff ff       	call   802a71 <read>
	if (r < 0)
  80340f:	83 c4 10             	add    $0x10,%esp
  803412:	85 c0                	test   %eax,%eax
  803414:	78 0f                	js     803425 <getchar+0x29>
		return r;
	if (r < 1)
  803416:	85 c0                	test   %eax,%eax
  803418:	7e 06                	jle    803420 <getchar+0x24>
		return -E_EOF;
	return c;
  80341a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80341e:	eb 05                	jmp    803425 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803420:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803425:	c9                   	leave  
  803426:	c3                   	ret    

00803427 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803427:	55                   	push   %ebp
  803428:	89 e5                	mov    %esp,%ebp
  80342a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80342d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803430:	50                   	push   %eax
  803431:	ff 75 08             	pushl  0x8(%ebp)
  803434:	e8 d2 f3 ff ff       	call   80280b <fd_lookup>
  803439:	83 c4 10             	add    $0x10,%esp
  80343c:	85 c0                	test   %eax,%eax
  80343e:	78 11                	js     803451 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803443:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803449:	39 10                	cmp    %edx,(%eax)
  80344b:	0f 94 c0             	sete   %al
  80344e:	0f b6 c0             	movzbl %al,%eax
}
  803451:	c9                   	leave  
  803452:	c3                   	ret    

00803453 <opencons>:

int
opencons(void)
{
  803453:	55                   	push   %ebp
  803454:	89 e5                	mov    %esp,%ebp
  803456:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803459:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80345c:	50                   	push   %eax
  80345d:	e8 5a f3 ff ff       	call   8027bc <fd_alloc>
  803462:	83 c4 10             	add    $0x10,%esp
		return r;
  803465:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803467:	85 c0                	test   %eax,%eax
  803469:	78 3e                	js     8034a9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80346b:	83 ec 04             	sub    $0x4,%esp
  80346e:	68 07 04 00 00       	push   $0x407
  803473:	ff 75 f4             	pushl  -0xc(%ebp)
  803476:	6a 00                	push   $0x0
  803478:	e8 6a ef ff ff       	call   8023e7 <sys_page_alloc>
  80347d:	83 c4 10             	add    $0x10,%esp
		return r;
  803480:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803482:	85 c0                	test   %eax,%eax
  803484:	78 23                	js     8034a9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803486:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80348c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80348f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803494:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80349b:	83 ec 0c             	sub    $0xc,%esp
  80349e:	50                   	push   %eax
  80349f:	e8 f1 f2 ff ff       	call   802795 <fd2num>
  8034a4:	89 c2                	mov    %eax,%edx
  8034a6:	83 c4 10             	add    $0x10,%esp
}
  8034a9:	89 d0                	mov    %edx,%eax
  8034ab:	c9                   	leave  
  8034ac:	c3                   	ret    
  8034ad:	66 90                	xchg   %ax,%ax
  8034af:	90                   	nop

008034b0 <__udivdi3>:
  8034b0:	55                   	push   %ebp
  8034b1:	57                   	push   %edi
  8034b2:	56                   	push   %esi
  8034b3:	53                   	push   %ebx
  8034b4:	83 ec 1c             	sub    $0x1c,%esp
  8034b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8034bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8034bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8034c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8034c7:	85 f6                	test   %esi,%esi
  8034c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8034cd:	89 ca                	mov    %ecx,%edx
  8034cf:	89 f8                	mov    %edi,%eax
  8034d1:	75 3d                	jne    803510 <__udivdi3+0x60>
  8034d3:	39 cf                	cmp    %ecx,%edi
  8034d5:	0f 87 c5 00 00 00    	ja     8035a0 <__udivdi3+0xf0>
  8034db:	85 ff                	test   %edi,%edi
  8034dd:	89 fd                	mov    %edi,%ebp
  8034df:	75 0b                	jne    8034ec <__udivdi3+0x3c>
  8034e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8034e6:	31 d2                	xor    %edx,%edx
  8034e8:	f7 f7                	div    %edi
  8034ea:	89 c5                	mov    %eax,%ebp
  8034ec:	89 c8                	mov    %ecx,%eax
  8034ee:	31 d2                	xor    %edx,%edx
  8034f0:	f7 f5                	div    %ebp
  8034f2:	89 c1                	mov    %eax,%ecx
  8034f4:	89 d8                	mov    %ebx,%eax
  8034f6:	89 cf                	mov    %ecx,%edi
  8034f8:	f7 f5                	div    %ebp
  8034fa:	89 c3                	mov    %eax,%ebx
  8034fc:	89 d8                	mov    %ebx,%eax
  8034fe:	89 fa                	mov    %edi,%edx
  803500:	83 c4 1c             	add    $0x1c,%esp
  803503:	5b                   	pop    %ebx
  803504:	5e                   	pop    %esi
  803505:	5f                   	pop    %edi
  803506:	5d                   	pop    %ebp
  803507:	c3                   	ret    
  803508:	90                   	nop
  803509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803510:	39 ce                	cmp    %ecx,%esi
  803512:	77 74                	ja     803588 <__udivdi3+0xd8>
  803514:	0f bd fe             	bsr    %esi,%edi
  803517:	83 f7 1f             	xor    $0x1f,%edi
  80351a:	0f 84 98 00 00 00    	je     8035b8 <__udivdi3+0x108>
  803520:	bb 20 00 00 00       	mov    $0x20,%ebx
  803525:	89 f9                	mov    %edi,%ecx
  803527:	89 c5                	mov    %eax,%ebp
  803529:	29 fb                	sub    %edi,%ebx
  80352b:	d3 e6                	shl    %cl,%esi
  80352d:	89 d9                	mov    %ebx,%ecx
  80352f:	d3 ed                	shr    %cl,%ebp
  803531:	89 f9                	mov    %edi,%ecx
  803533:	d3 e0                	shl    %cl,%eax
  803535:	09 ee                	or     %ebp,%esi
  803537:	89 d9                	mov    %ebx,%ecx
  803539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80353d:	89 d5                	mov    %edx,%ebp
  80353f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803543:	d3 ed                	shr    %cl,%ebp
  803545:	89 f9                	mov    %edi,%ecx
  803547:	d3 e2                	shl    %cl,%edx
  803549:	89 d9                	mov    %ebx,%ecx
  80354b:	d3 e8                	shr    %cl,%eax
  80354d:	09 c2                	or     %eax,%edx
  80354f:	89 d0                	mov    %edx,%eax
  803551:	89 ea                	mov    %ebp,%edx
  803553:	f7 f6                	div    %esi
  803555:	89 d5                	mov    %edx,%ebp
  803557:	89 c3                	mov    %eax,%ebx
  803559:	f7 64 24 0c          	mull   0xc(%esp)
  80355d:	39 d5                	cmp    %edx,%ebp
  80355f:	72 10                	jb     803571 <__udivdi3+0xc1>
  803561:	8b 74 24 08          	mov    0x8(%esp),%esi
  803565:	89 f9                	mov    %edi,%ecx
  803567:	d3 e6                	shl    %cl,%esi
  803569:	39 c6                	cmp    %eax,%esi
  80356b:	73 07                	jae    803574 <__udivdi3+0xc4>
  80356d:	39 d5                	cmp    %edx,%ebp
  80356f:	75 03                	jne    803574 <__udivdi3+0xc4>
  803571:	83 eb 01             	sub    $0x1,%ebx
  803574:	31 ff                	xor    %edi,%edi
  803576:	89 d8                	mov    %ebx,%eax
  803578:	89 fa                	mov    %edi,%edx
  80357a:	83 c4 1c             	add    $0x1c,%esp
  80357d:	5b                   	pop    %ebx
  80357e:	5e                   	pop    %esi
  80357f:	5f                   	pop    %edi
  803580:	5d                   	pop    %ebp
  803581:	c3                   	ret    
  803582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803588:	31 ff                	xor    %edi,%edi
  80358a:	31 db                	xor    %ebx,%ebx
  80358c:	89 d8                	mov    %ebx,%eax
  80358e:	89 fa                	mov    %edi,%edx
  803590:	83 c4 1c             	add    $0x1c,%esp
  803593:	5b                   	pop    %ebx
  803594:	5e                   	pop    %esi
  803595:	5f                   	pop    %edi
  803596:	5d                   	pop    %ebp
  803597:	c3                   	ret    
  803598:	90                   	nop
  803599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035a0:	89 d8                	mov    %ebx,%eax
  8035a2:	f7 f7                	div    %edi
  8035a4:	31 ff                	xor    %edi,%edi
  8035a6:	89 c3                	mov    %eax,%ebx
  8035a8:	89 d8                	mov    %ebx,%eax
  8035aa:	89 fa                	mov    %edi,%edx
  8035ac:	83 c4 1c             	add    $0x1c,%esp
  8035af:	5b                   	pop    %ebx
  8035b0:	5e                   	pop    %esi
  8035b1:	5f                   	pop    %edi
  8035b2:	5d                   	pop    %ebp
  8035b3:	c3                   	ret    
  8035b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035b8:	39 ce                	cmp    %ecx,%esi
  8035ba:	72 0c                	jb     8035c8 <__udivdi3+0x118>
  8035bc:	31 db                	xor    %ebx,%ebx
  8035be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8035c2:	0f 87 34 ff ff ff    	ja     8034fc <__udivdi3+0x4c>
  8035c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8035cd:	e9 2a ff ff ff       	jmp    8034fc <__udivdi3+0x4c>
  8035d2:	66 90                	xchg   %ax,%ax
  8035d4:	66 90                	xchg   %ax,%ax
  8035d6:	66 90                	xchg   %ax,%ax
  8035d8:	66 90                	xchg   %ax,%ax
  8035da:	66 90                	xchg   %ax,%ax
  8035dc:	66 90                	xchg   %ax,%ax
  8035de:	66 90                	xchg   %ax,%ax

008035e0 <__umoddi3>:
  8035e0:	55                   	push   %ebp
  8035e1:	57                   	push   %edi
  8035e2:	56                   	push   %esi
  8035e3:	53                   	push   %ebx
  8035e4:	83 ec 1c             	sub    $0x1c,%esp
  8035e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8035eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8035ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8035f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8035f7:	85 d2                	test   %edx,%edx
  8035f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8035fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803601:	89 f3                	mov    %esi,%ebx
  803603:	89 3c 24             	mov    %edi,(%esp)
  803606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80360a:	75 1c                	jne    803628 <__umoddi3+0x48>
  80360c:	39 f7                	cmp    %esi,%edi
  80360e:	76 50                	jbe    803660 <__umoddi3+0x80>
  803610:	89 c8                	mov    %ecx,%eax
  803612:	89 f2                	mov    %esi,%edx
  803614:	f7 f7                	div    %edi
  803616:	89 d0                	mov    %edx,%eax
  803618:	31 d2                	xor    %edx,%edx
  80361a:	83 c4 1c             	add    $0x1c,%esp
  80361d:	5b                   	pop    %ebx
  80361e:	5e                   	pop    %esi
  80361f:	5f                   	pop    %edi
  803620:	5d                   	pop    %ebp
  803621:	c3                   	ret    
  803622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803628:	39 f2                	cmp    %esi,%edx
  80362a:	89 d0                	mov    %edx,%eax
  80362c:	77 52                	ja     803680 <__umoddi3+0xa0>
  80362e:	0f bd ea             	bsr    %edx,%ebp
  803631:	83 f5 1f             	xor    $0x1f,%ebp
  803634:	75 5a                	jne    803690 <__umoddi3+0xb0>
  803636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80363a:	0f 82 e0 00 00 00    	jb     803720 <__umoddi3+0x140>
  803640:	39 0c 24             	cmp    %ecx,(%esp)
  803643:	0f 86 d7 00 00 00    	jbe    803720 <__umoddi3+0x140>
  803649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80364d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803651:	83 c4 1c             	add    $0x1c,%esp
  803654:	5b                   	pop    %ebx
  803655:	5e                   	pop    %esi
  803656:	5f                   	pop    %edi
  803657:	5d                   	pop    %ebp
  803658:	c3                   	ret    
  803659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803660:	85 ff                	test   %edi,%edi
  803662:	89 fd                	mov    %edi,%ebp
  803664:	75 0b                	jne    803671 <__umoddi3+0x91>
  803666:	b8 01 00 00 00       	mov    $0x1,%eax
  80366b:	31 d2                	xor    %edx,%edx
  80366d:	f7 f7                	div    %edi
  80366f:	89 c5                	mov    %eax,%ebp
  803671:	89 f0                	mov    %esi,%eax
  803673:	31 d2                	xor    %edx,%edx
  803675:	f7 f5                	div    %ebp
  803677:	89 c8                	mov    %ecx,%eax
  803679:	f7 f5                	div    %ebp
  80367b:	89 d0                	mov    %edx,%eax
  80367d:	eb 99                	jmp    803618 <__umoddi3+0x38>
  80367f:	90                   	nop
  803680:	89 c8                	mov    %ecx,%eax
  803682:	89 f2                	mov    %esi,%edx
  803684:	83 c4 1c             	add    $0x1c,%esp
  803687:	5b                   	pop    %ebx
  803688:	5e                   	pop    %esi
  803689:	5f                   	pop    %edi
  80368a:	5d                   	pop    %ebp
  80368b:	c3                   	ret    
  80368c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803690:	8b 34 24             	mov    (%esp),%esi
  803693:	bf 20 00 00 00       	mov    $0x20,%edi
  803698:	89 e9                	mov    %ebp,%ecx
  80369a:	29 ef                	sub    %ebp,%edi
  80369c:	d3 e0                	shl    %cl,%eax
  80369e:	89 f9                	mov    %edi,%ecx
  8036a0:	89 f2                	mov    %esi,%edx
  8036a2:	d3 ea                	shr    %cl,%edx
  8036a4:	89 e9                	mov    %ebp,%ecx
  8036a6:	09 c2                	or     %eax,%edx
  8036a8:	89 d8                	mov    %ebx,%eax
  8036aa:	89 14 24             	mov    %edx,(%esp)
  8036ad:	89 f2                	mov    %esi,%edx
  8036af:	d3 e2                	shl    %cl,%edx
  8036b1:	89 f9                	mov    %edi,%ecx
  8036b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8036bb:	d3 e8                	shr    %cl,%eax
  8036bd:	89 e9                	mov    %ebp,%ecx
  8036bf:	89 c6                	mov    %eax,%esi
  8036c1:	d3 e3                	shl    %cl,%ebx
  8036c3:	89 f9                	mov    %edi,%ecx
  8036c5:	89 d0                	mov    %edx,%eax
  8036c7:	d3 e8                	shr    %cl,%eax
  8036c9:	89 e9                	mov    %ebp,%ecx
  8036cb:	09 d8                	or     %ebx,%eax
  8036cd:	89 d3                	mov    %edx,%ebx
  8036cf:	89 f2                	mov    %esi,%edx
  8036d1:	f7 34 24             	divl   (%esp)
  8036d4:	89 d6                	mov    %edx,%esi
  8036d6:	d3 e3                	shl    %cl,%ebx
  8036d8:	f7 64 24 04          	mull   0x4(%esp)
  8036dc:	39 d6                	cmp    %edx,%esi
  8036de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036e2:	89 d1                	mov    %edx,%ecx
  8036e4:	89 c3                	mov    %eax,%ebx
  8036e6:	72 08                	jb     8036f0 <__umoddi3+0x110>
  8036e8:	75 11                	jne    8036fb <__umoddi3+0x11b>
  8036ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8036ee:	73 0b                	jae    8036fb <__umoddi3+0x11b>
  8036f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8036f4:	1b 14 24             	sbb    (%esp),%edx
  8036f7:	89 d1                	mov    %edx,%ecx
  8036f9:	89 c3                	mov    %eax,%ebx
  8036fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8036ff:	29 da                	sub    %ebx,%edx
  803701:	19 ce                	sbb    %ecx,%esi
  803703:	89 f9                	mov    %edi,%ecx
  803705:	89 f0                	mov    %esi,%eax
  803707:	d3 e0                	shl    %cl,%eax
  803709:	89 e9                	mov    %ebp,%ecx
  80370b:	d3 ea                	shr    %cl,%edx
  80370d:	89 e9                	mov    %ebp,%ecx
  80370f:	d3 ee                	shr    %cl,%esi
  803711:	09 d0                	or     %edx,%eax
  803713:	89 f2                	mov    %esi,%edx
  803715:	83 c4 1c             	add    $0x1c,%esp
  803718:	5b                   	pop    %ebx
  803719:	5e                   	pop    %esi
  80371a:	5f                   	pop    %edi
  80371b:	5d                   	pop    %ebp
  80371c:	c3                   	ret    
  80371d:	8d 76 00             	lea    0x0(%esi),%esi
  803720:	29 f9                	sub    %edi,%ecx
  803722:	19 d6                	sbb    %edx,%esi
  803724:	89 74 24 04          	mov    %esi,0x4(%esp)
  803728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80372c:	e9 18 ff ff ff       	jmp    803649 <__umoddi3+0x69>
