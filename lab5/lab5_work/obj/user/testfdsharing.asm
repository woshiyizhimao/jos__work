
obj/user/testfdsharing.debug：     文件格式 elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 80 23 80 00       	push   $0x802380
  800043:	e8 c7 18 00 00       	call   80190f <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 85 23 80 00       	push   $0x802385
  800057:	6a 0c                	push   $0xc
  800059:	68 93 23 80 00       	push   $0x802393
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 89 15 00 00       	call   8015f7 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 a1 14 00 00       	call   801522 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 a8 23 80 00       	push   $0x8023a8
  800090:	6a 0f                	push   $0xf
  800092:	68 93 23 80 00       	push   $0x802393
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 c5 0e 00 00       	call   800f66 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 b2 23 80 00       	push   $0x8023b2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 93 23 80 00       	push   $0x802393
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 2b 15 00 00       	call   8015f7 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 37 14 00 00       	call   801522 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 34 24 80 00       	push   $0x802434
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 93 23 80 00       	push   $0x802393
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 68 09 00 00       	call   800a83 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 60 24 80 00       	push   $0x802460
  80012a:	6a 19                	push   $0x19
  80012c:	68 93 23 80 00       	push   $0x802393
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 bb 23 80 00       	push   $0x8023bb
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 a9 14 00 00       	call   8015f7 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 ff 11 00 00       	call   801355 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 a8 1b 00 00       	call   801d0f <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 a8 13 00 00       	call   801522 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 98 24 80 00       	push   $0x802498
  80018b:	6a 21                	push   $0x21
  80018d:	68 93 23 80 00       	push   $0x802393
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 d4 23 80 00       	push   $0x8023d4
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 a9 11 00 00       	call   801355 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 73 0a 00 00       	call   800c3b <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 77 11 00 00       	call   801380 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 e7 09 00 00       	call   800bfa <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 10 0a 00 00       	call   800c3b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 c8 24 80 00       	push   $0x8024c8
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 2f 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d4 08 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 87 1d 00 00       	call   8020e0 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 74 1e 00 00       	call   802210 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 eb 24 80 00 	movsbl 0x8024eb(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 89 03 00 00    	je     8007cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 1a 03 00 00    	ja     8007b2 <vprintfmt+0x38a>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 03 25 80 00       	push   $0x802503
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 31 2a 80 00       	push   $0x802a31
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 fc 24 80 00       	mov    $0x8024fc,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 86 02 00 00       	call   800855 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	79 74                	jns    80077e <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d6                	call   *%esi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 55                	jmp    80077e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 83 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800736:	eb 46                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 74 fc ff ff       	call   8003b4 <getuint>
			base=8;
  800740:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800745:	eb 37                	jmp    80077e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 30                	push   $0x30
  80074d:	ff d6                	call   *%esi
			putch('x', putdat);
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 78                	push   $0x78
  800755:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 3b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800779:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800785:	57                   	push   %edi
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 da                	mov    %ebx,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 70 fb ff ff       	call   800305 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 ae fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	51                   	push   %ecx
  8007a5:	ff d6                	call   *%esi
			break;
  8007a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 9c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 03                	jmp    8007c2 <vprintfmt+0x39a>
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c6:	75 f7                	jne    8007bf <vprintfmt+0x397>
  8007c8:	e9 81 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5f                   	pop    %edi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 26                	je     80081c <vsnprintf+0x47>
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	7e 22                	jle    80081c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fa:	ff 75 14             	pushl  0x14(%ebp)
  8007fd:	ff 75 10             	pushl  0x10(%ebp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	68 ee 03 80 00       	push   $0x8003ee
  800809:	e8 1a fc ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	50                   	push   %eax
  80082d:	ff 75 10             	pushl  0x10(%ebp)
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 9a ff ff ff       	call   8007d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 03                	jmp    80084d <strlen+0x10>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800851:	75 f7                	jne    80084a <strlen+0xd>
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	eb 03                	jmp    800868 <strnlen+0x13>
		n++;
  800865:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 08                	je     800874 <strnlen+0x1f>
  80086c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800870:	75 f3                	jne    800865 <strnlen+0x10>
  800872:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089d:	53                   	push   %ebx
  80089e:	e8 9a ff ff ff       	call   80083d <strlen>
  8008a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 c5 ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 0f                	jmp    8008db <strncpy+0x23>
		*dst++ = *src;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	39 da                	cmp    %ebx,%edx
  8008dd:	75 ed                	jne    8008cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 21                	je     80091a <strlcpy+0x35>
  8008f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 09                	jmp    80090a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 09                	je     800917 <strlcpy+0x32>
  80090e:	0f b6 19             	movzbl (%ecx),%ebx
  800911:	84 db                	test   %bl,%bl
  800913:	75 ec                	jne    800901 <strlcpy+0x1c>
  800915:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f0                	sub    %esi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	eb 06                	jmp    800931 <strcmp+0x11>
		p++, q++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 04                	je     80093c <strcmp+0x1c>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	74 ef                	je     80092b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x17>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 15                	je     800976 <strncmp+0x30>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x26>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 07                	jmp    800991 <strchr+0x13>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0f                	je     80099d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	eb 03                	jmp    8009ae <strfind+0xf>
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 04                	je     8009b9 <strfind+0x1a>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	75 f2                	jne    8009ab <strfind+0xc>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 36                	je     800a01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d1:	75 28                	jne    8009fb <memset+0x40>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 23                	jne    8009fb <memset+0x40>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 35                	jae    800a4f <memmove+0x47>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2e                	jae    800a4f <memmove+0x47>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	09 fe                	or     %edi,%esi
  800a28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2e:	75 13                	jne    800a43 <memmove+0x3b>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 09                	jmp    800a4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	83 ef 01             	sub    $0x1,%edi
  800a46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a49:	fd                   	std    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4c:	fc                   	cld    
  800a4d:	eb 1d                	jmp    800a6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0f                	jne    800a67 <memmove+0x5f>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0a                	jne    800a67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 05                	jmp    800a6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 87 ff ff ff       	call   800a08 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	eb 1a                	jmp    800aaf <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 0a                	je     800aa9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0f                	jmp    800ab8 <memcmp+0x35>
		s1++, s2++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	39 f0                	cmp    %esi,%eax
  800ab1:	75 e2                	jne    800a95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	eb 0a                	jmp    800ad8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 07                	je     800adc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	39 c8                	cmp    %ecx,%eax
  800ada:	72 f2                	jb     800ace <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	eb 03                	jmp    800af0 <strtol+0x11>
		s++;
  800aed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f6                	je     800aed <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f2                	je     800aed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 0a                	jne    800b09 <strtol+0x2a>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb 11                	jmp    800b1a <strtol+0x3b>
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0e:	3c 2d                	cmp    $0x2d,%al
  800b10:	75 08                	jne    800b1a <strtol+0x3b>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 15                	jne    800b37 <strtol+0x58>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 10                	jne    800b37 <strtol+0x58>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	75 7c                	jne    800ba9 <strtol+0xca>
		s += 2, base = 16;
  800b2d:	83 c1 02             	add    $0x2,%ecx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 16                	jmp    800b4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 12                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 08                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 11             	movzbl (%ecx),%edx
  800b58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x8b>
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
  800b68:	eb 22                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb 10                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 16                	ja     800b9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8f:	7d 0b                	jge    800b9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb b9                	jmp    800b55 <strtol+0x76>

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 0d                	je     800baf <strtol+0xd0>
		*endptr = (char *) s;
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	89 0e                	mov    %ecx,(%esi)
  800ba7:	eb 06                	jmp    800baf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	74 98                	je     800b45 <strtol+0x66>
  800bad:	eb 9e                	jmp    800b4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	85 ff                	test   %edi,%edi
  800bb5:	0f 45 c2             	cmovne %edx,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 cb                	mov    %ecx,%ebx
  800c12:	89 cf                	mov    %ecx,%edi
  800c14:	89 ce                	mov    %ecx,%esi
  800c16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 df 27 80 00       	push   $0x8027df
  800c27:	6a 23                	push   $0x23
  800c29:	68 fc 27 80 00       	push   $0x8027fc
  800c2e:	e8 e5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 04                	push   $0x4
  800ca3:	68 df 27 80 00       	push   $0x8027df
  800ca8:	6a 23                	push   $0x23
  800caa:	68 fc 27 80 00       	push   $0x8027fc
  800caf:	e8 64 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 05                	push   $0x5
  800ce5:	68 df 27 80 00       	push   $0x8027df
  800cea:	6a 23                	push   $0x23
  800cec:	68 fc 27 80 00       	push   $0x8027fc
  800cf1:	e8 22 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 df 27 80 00       	push   $0x8027df
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 fc 27 80 00       	push   $0x8027fc
  800d33:	e8 e0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 df 27 80 00       	push   $0x8027df
  800d6e:	6a 23                	push   $0x23
  800d70:	68 fc 27 80 00       	push   $0x8027fc
  800d75:	e8 9e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 09 00 00 00       	mov    $0x9,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 09                	push   $0x9
  800dab:	68 df 27 80 00       	push   $0x8027df
  800db0:	6a 23                	push   $0x23
  800db2:	68 fc 27 80 00       	push   $0x8027fc
  800db7:	e8 5c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 df 27 80 00       	push   $0x8027df
  800df2:	6a 23                	push   $0x23
  800df4:	68 fc 27 80 00       	push   $0x8027fc
  800df9:	e8 1a f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 0d                	push   $0xd
  800e51:	68 df 27 80 00       	push   $0x8027df
  800e56:	6a 23                	push   $0x23
  800e58:	68 fc 27 80 00       	push   $0x8027fc
  800e5d:	e8 b6 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	75 14                	jne    800e8e <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	68 0c 28 80 00       	push   $0x80280c
  800e82:	6a 23                	push   $0x23
  800e84:	68 cf 28 80 00       	push   $0x8028cf
  800e89:	e8 8a f3 ff ff       	call   800218 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	c1 e8 0c             	shr    $0xc,%eax
  800e93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e9a:	f6 c4 08             	test   $0x8,%ah
  800e9d:	75 14                	jne    800eb3 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	68 30 28 80 00       	push   $0x802830
  800ea7:	6a 2d                	push   $0x2d
  800ea9:	68 cf 28 80 00       	push   $0x8028cf
  800eae:	e8 65 f3 ff ff       	call   800218 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800eb3:	e8 83 fd ff ff       	call   800c3b <sys_getenvid>
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	6a 07                	push   $0x7
  800ebd:	68 00 f0 7f 00       	push   $0x7ff000
  800ec2:	50                   	push   %eax
  800ec3:	e8 b1 fd ff ff       	call   800c79 <sys_page_alloc>
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	79 12                	jns    800ee1 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800ecf:	50                   	push   %eax
  800ed0:	68 da 28 80 00       	push   $0x8028da
  800ed5:	6a 3b                	push   $0x3b
  800ed7:	68 cf 28 80 00       	push   $0x8028cf
  800edc:	e8 37 f3 ff ff       	call   800218 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	68 00 10 00 00       	push   $0x1000
  800eef:	53                   	push   %ebx
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	e8 0e fb ff ff       	call   800a08 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800efa:	e8 3c fd ff ff       	call   800c3b <sys_getenvid>
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	e8 35 fd ff ff       	call   800c3b <sys_getenvid>
  800f06:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0d:	53                   	push   %ebx
  800f0e:	56                   	push   %esi
  800f0f:	68 00 f0 7f 00       	push   $0x7ff000
  800f14:	50                   	push   %eax
  800f15:	e8 a2 fd ff ff       	call   800cbc <sys_page_map>
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 12                	jns    800f33 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800f21:	50                   	push   %eax
  800f22:	68 f3 28 80 00       	push   $0x8028f3
  800f27:	6a 48                	push   $0x48
  800f29:	68 cf 28 80 00       	push   $0x8028cf
  800f2e:	e8 e5 f2 ff ff       	call   800218 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800f33:	e8 03 fd ff ff       	call   800c3b <sys_getenvid>
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	68 00 f0 7f 00       	push   $0x7ff000
  800f40:	50                   	push   %eax
  800f41:	e8 b8 fd ff ff       	call   800cfe <sys_page_unmap>
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	79 12                	jns    800f5f <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 0a 29 80 00       	push   $0x80290a
  800f53:	6a 4c                	push   $0x4c
  800f55:	68 cf 28 80 00       	push   $0x8028cf
  800f5a:	e8 b9 f2 ff ff       	call   800218 <_panic>
	}

	//panic("pgfault not implemented");
}
  800f5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800f6f:	68 6a 0e 80 00       	push   $0x800e6a
  800f74:	e8 68 0f 00 00       	call   801ee1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f79:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7e:	cd 30                	int    $0x30
  800f80:	89 c7                	mov    %eax,%edi
  800f82:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	79 15                	jns    800fa1 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800f8c:	50                   	push   %eax
  800f8d:	68 23 29 80 00       	push   $0x802923
  800f92:	68 a1 00 00 00       	push   $0xa1
  800f97:	68 cf 28 80 00       	push   $0x8028cf
  800f9c:	e8 77 f2 ff ff       	call   800218 <_panic>
  800fa1:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	75 21                	jne    800fcb <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800faa:	e8 8c fc ff ff       	call   800c3b <sys_getenvid>
  800faf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbc:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc6:	e9 c8 01 00 00       	jmp    801193 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	c1 e8 16             	shr    $0x16,%eax
  800fd0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd7:	a8 01                	test   $0x1,%al
  800fd9:	0f 84 23 01 00 00    	je     801102 <fork+0x19c>
  800fdf:	89 d8                	mov    %ebx,%eax
  800fe1:	c1 e8 0c             	shr    $0xc,%eax
  800fe4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800feb:	f6 c2 01             	test   $0x1,%dl
  800fee:	0f 84 0e 01 00 00    	je     801102 <fork+0x19c>
  800ff4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffb:	f6 c2 04             	test   $0x4,%dl
  800ffe:	0f 84 fe 00 00 00    	je     801102 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  801004:	89 c6                	mov    %eax,%esi
  801006:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  801009:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801010:	f6 c6 04             	test   $0x4,%dh
  801013:	74 3f                	je     801054 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	25 07 0e 00 00       	and    $0xe07,%eax
  801024:	50                   	push   %eax
  801025:	56                   	push   %esi
  801026:	ff 75 e4             	pushl  -0x1c(%ebp)
  801029:	56                   	push   %esi
  80102a:	6a 00                	push   $0x0
  80102c:	e8 8b fc ff ff       	call   800cbc <sys_page_map>
  801031:	83 c4 20             	add    $0x20,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	0f 89 c6 00 00 00    	jns    801102 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	50                   	push   %eax
  801040:	57                   	push   %edi
  801041:	6a 00                	push   $0x0
  801043:	68 60 28 80 00       	push   $0x802860
  801048:	6a 6c                	push   $0x6c
  80104a:	68 cf 28 80 00       	push   $0x8028cf
  80104f:	e8 c4 f1 ff ff       	call   800218 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801054:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105b:	f6 c2 02             	test   $0x2,%dl
  80105e:	75 0c                	jne    80106c <fork+0x106>
  801060:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801067:	f6 c4 08             	test   $0x8,%ah
  80106a:	74 66                	je     8010d2 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	68 05 08 00 00       	push   $0x805
  801074:	56                   	push   %esi
  801075:	ff 75 e4             	pushl  -0x1c(%ebp)
  801078:	56                   	push   %esi
  801079:	6a 00                	push   $0x0
  80107b:	e8 3c fc ff ff       	call   800cbc <sys_page_map>
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	79 18                	jns    80109f <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	50                   	push   %eax
  80108b:	57                   	push   %edi
  80108c:	6a 00                	push   $0x0
  80108e:	68 60 28 80 00       	push   $0x802860
  801093:	6a 74                	push   $0x74
  801095:	68 cf 28 80 00       	push   $0x8028cf
  80109a:	e8 79 f1 ff ff       	call   800218 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	68 05 08 00 00       	push   $0x805
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	56                   	push   %esi
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 0a fc ff ff       	call   800cbc <sys_page_map>
  8010b2:	83 c4 20             	add    $0x20,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	79 49                	jns    801102 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	50                   	push   %eax
  8010bd:	6a 00                	push   $0x0
  8010bf:	6a 00                	push   $0x0
  8010c1:	68 60 28 80 00       	push   $0x802860
  8010c6:	6a 77                	push   $0x77
  8010c8:	68 cf 28 80 00       	push   $0x8028cf
  8010cd:	e8 46 f1 ff ff       	call   800218 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	6a 05                	push   $0x5
  8010d7:	56                   	push   %esi
  8010d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010db:	56                   	push   %esi
  8010dc:	6a 00                	push   $0x0
  8010de:	e8 d9 fb ff ff       	call   800cbc <sys_page_map>
  8010e3:	83 c4 20             	add    $0x20,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	79 18                	jns    801102 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	50                   	push   %eax
  8010ee:	57                   	push   %edi
  8010ef:	6a 00                	push   $0x0
  8010f1:	68 60 28 80 00       	push   $0x802860
  8010f6:	6a 7d                	push   $0x7d
  8010f8:	68 cf 28 80 00       	push   $0x8028cf
  8010fd:	e8 16 f1 ff ff       	call   800218 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801102:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801108:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80110e:	0f 85 b7 fe ff ff    	jne    800fcb <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801114:	83 ec 04             	sub    $0x4,%esp
  801117:	6a 07                	push   $0x7
  801119:	68 00 f0 bf ee       	push   $0xeebff000
  80111e:	57                   	push   %edi
  80111f:	e8 55 fb ff ff       	call   800c79 <sys_page_alloc>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 15                	jns    801140 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  80112b:	50                   	push   %eax
  80112c:	68 8c 28 80 00       	push   $0x80288c
  801131:	68 b4 00 00 00       	push   $0xb4
  801136:	68 cf 28 80 00       	push   $0x8028cf
  80113b:	e8 d8 f0 ff ff       	call   800218 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	68 55 1f 80 00       	push   $0x801f55
  801148:	57                   	push   %edi
  801149:	e8 76 fc ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	79 15                	jns    80116a <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801155:	50                   	push   %eax
  801156:	68 39 29 80 00       	push   $0x802939
  80115b:	68 ba 00 00 00       	push   $0xba
  801160:	68 cf 28 80 00       	push   $0x8028cf
  801165:	e8 ae f0 ff ff       	call   800218 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	6a 02                	push   $0x2
  80116f:	57                   	push   %edi
  801170:	e8 cb fb ff ff       	call   800d40 <sys_env_set_status>
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	79 15                	jns    801191 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  80117c:	50                   	push   %eax
  80117d:	68 56 29 80 00       	push   $0x802956
  801182:	68 bf 00 00 00       	push   $0xbf
  801187:	68 cf 28 80 00       	push   $0x8028cf
  80118c:	e8 87 f0 ff ff       	call   800218 <_panic>
	}
	return eid;
  801191:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <sfork>:

// Challenge!
int
sfork(void)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a1:	68 73 29 80 00       	push   $0x802973
  8011a6:	68 ca 00 00 00       	push   $0xca
  8011ab:	68 cf 28 80 00       	push   $0x8028cf
  8011b0:	e8 63 f0 ff ff       	call   800218 <_panic>

008011b5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c0:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cb:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 16             	shr    $0x16,%edx
  8011ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 11                	je     801209 <fd_alloc+0x2d>
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 0c             	shr    $0xc,%edx
  8011fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	75 09                	jne    801212 <fd_alloc+0x36>
			*fd_store = fd;
  801209:	89 01                	mov    %eax,(%ecx)
			return 0;
  80120b:	b8 00 00 00 00       	mov    $0x0,%eax
  801210:	eb 17                	jmp    801229 <fd_alloc+0x4d>
  801212:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801217:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80121c:	75 c9                	jne    8011e7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80121e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801224:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801231:	83 f8 1f             	cmp    $0x1f,%eax
  801234:	77 36                	ja     80126c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801236:	c1 e0 0c             	shl    $0xc,%eax
  801239:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123e:	89 c2                	mov    %eax,%edx
  801240:	c1 ea 16             	shr    $0x16,%edx
  801243:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124a:	f6 c2 01             	test   $0x1,%dl
  80124d:	74 24                	je     801273 <fd_lookup+0x48>
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 ea 0c             	shr    $0xc,%edx
  801254:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125b:	f6 c2 01             	test   $0x1,%dl
  80125e:	74 1a                	je     80127a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801260:	8b 55 0c             	mov    0xc(%ebp),%edx
  801263:	89 02                	mov    %eax,(%edx)
	return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	eb 13                	jmp    80127f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801271:	eb 0c                	jmp    80127f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb 05                	jmp    80127f <fd_lookup+0x54>
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128a:	ba 08 2a 80 00       	mov    $0x802a08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80128f:	eb 13                	jmp    8012a4 <dev_lookup+0x23>
  801291:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801294:	39 08                	cmp    %ecx,(%eax)
  801296:	75 0c                	jne    8012a4 <dev_lookup+0x23>
			*dev = devtab[i];
  801298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a2:	eb 2e                	jmp    8012d2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a4:	8b 02                	mov    (%edx),%eax
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	75 e7                	jne    801291 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012aa:	a1 20 44 80 00       	mov    0x804420,%eax
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	51                   	push   %ecx
  8012b6:	50                   	push   %eax
  8012b7:	68 8c 29 80 00       	push   $0x80298c
  8012bc:	e8 30 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8012c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 10             	sub    $0x10,%esp
  8012dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ec:	c1 e8 0c             	shr    $0xc,%eax
  8012ef:	50                   	push   %eax
  8012f0:	e8 36 ff ff ff       	call   80122b <fd_lookup>
  8012f5:	83 c4 08             	add    $0x8,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 05                	js     801301 <fd_close+0x2d>
	    || fd != fd2)
  8012fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ff:	74 0c                	je     80130d <fd_close+0x39>
		return (must_exist ? r : 0);
  801301:	84 db                	test   %bl,%bl
  801303:	ba 00 00 00 00       	mov    $0x0,%edx
  801308:	0f 44 c2             	cmove  %edx,%eax
  80130b:	eb 41                	jmp    80134e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	ff 36                	pushl  (%esi)
  801316:	e8 66 ff ff ff       	call   801281 <dev_lookup>
  80131b:	89 c3                	mov    %eax,%ebx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 1a                	js     80133e <fd_close+0x6a>
		if (dev->dev_close)
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80132a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80132f:	85 c0                	test   %eax,%eax
  801331:	74 0b                	je     80133e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	56                   	push   %esi
  801337:	ff d0                	call   *%eax
  801339:	89 c3                	mov    %eax,%ebx
  80133b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	56                   	push   %esi
  801342:	6a 00                	push   $0x0
  801344:	e8 b5 f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	89 d8                	mov    %ebx,%eax
}
  80134e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135e:	50                   	push   %eax
  80135f:	ff 75 08             	pushl  0x8(%ebp)
  801362:	e8 c4 fe ff ff       	call   80122b <fd_lookup>
  801367:	83 c4 08             	add    $0x8,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 10                	js     80137e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	6a 01                	push   $0x1
  801373:	ff 75 f4             	pushl  -0xc(%ebp)
  801376:	e8 59 ff ff ff       	call   8012d4 <fd_close>
  80137b:	83 c4 10             	add    $0x10,%esp
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <close_all>:

void
close_all(void)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801387:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	53                   	push   %ebx
  801390:	e8 c0 ff ff ff       	call   801355 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801395:	83 c3 01             	add    $0x1,%ebx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	83 fb 20             	cmp    $0x20,%ebx
  80139e:	75 ec                	jne    80138c <close_all+0xc>
		close(i);
}
  8013a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 2c             	sub    $0x2c,%esp
  8013ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	ff 75 08             	pushl  0x8(%ebp)
  8013b8:	e8 6e fe ff ff       	call   80122b <fd_lookup>
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	0f 88 c1 00 00 00    	js     801489 <dup+0xe4>
		return r;
	close(newfdnum);
  8013c8:	83 ec 0c             	sub    $0xc,%esp
  8013cb:	56                   	push   %esi
  8013cc:	e8 84 ff ff ff       	call   801355 <close>

	newfd = INDEX2FD(newfdnum);
  8013d1:	89 f3                	mov    %esi,%ebx
  8013d3:	c1 e3 0c             	shl    $0xc,%ebx
  8013d6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013dc:	83 c4 04             	add    $0x4,%esp
  8013df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e2:	e8 de fd ff ff       	call   8011c5 <fd2data>
  8013e7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e9:	89 1c 24             	mov    %ebx,(%esp)
  8013ec:	e8 d4 fd ff ff       	call   8011c5 <fd2data>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f7:	89 f8                	mov    %edi,%eax
  8013f9:	c1 e8 16             	shr    $0x16,%eax
  8013fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801403:	a8 01                	test   $0x1,%al
  801405:	74 37                	je     80143e <dup+0x99>
  801407:	89 f8                	mov    %edi,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
  80140c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801413:	f6 c2 01             	test   $0x1,%dl
  801416:	74 26                	je     80143e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801418:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	25 07 0e 00 00       	and    $0xe07,%eax
  801427:	50                   	push   %eax
  801428:	ff 75 d4             	pushl  -0x2c(%ebp)
  80142b:	6a 00                	push   $0x0
  80142d:	57                   	push   %edi
  80142e:	6a 00                	push   $0x0
  801430:	e8 87 f8 ff ff       	call   800cbc <sys_page_map>
  801435:	89 c7                	mov    %eax,%edi
  801437:	83 c4 20             	add    $0x20,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 2e                	js     80146c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801441:	89 d0                	mov    %edx,%eax
  801443:	c1 e8 0c             	shr    $0xc,%eax
  801446:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	25 07 0e 00 00       	and    $0xe07,%eax
  801455:	50                   	push   %eax
  801456:	53                   	push   %ebx
  801457:	6a 00                	push   $0x0
  801459:	52                   	push   %edx
  80145a:	6a 00                	push   $0x0
  80145c:	e8 5b f8 ff ff       	call   800cbc <sys_page_map>
  801461:	89 c7                	mov    %eax,%edi
  801463:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801466:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801468:	85 ff                	test   %edi,%edi
  80146a:	79 1d                	jns    801489 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	53                   	push   %ebx
  801470:	6a 00                	push   $0x0
  801472:	e8 87 f8 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801477:	83 c4 08             	add    $0x8,%esp
  80147a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147d:	6a 00                	push   $0x0
  80147f:	e8 7a f8 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	89 f8                	mov    %edi,%eax
}
  801489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148c:	5b                   	pop    %ebx
  80148d:	5e                   	pop    %esi
  80148e:	5f                   	pop    %edi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	83 ec 14             	sub    $0x14,%esp
  801498:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	53                   	push   %ebx
  8014a0:	e8 86 fd ff ff       	call   80122b <fd_lookup>
  8014a5:	83 c4 08             	add    $0x8,%esp
  8014a8:	89 c2                	mov    %eax,%edx
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 6d                	js     80151b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b8:	ff 30                	pushl  (%eax)
  8014ba:	e8 c2 fd ff ff       	call   801281 <dev_lookup>
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 4c                	js     801512 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c9:	8b 42 08             	mov    0x8(%edx),%eax
  8014cc:	83 e0 03             	and    $0x3,%eax
  8014cf:	83 f8 01             	cmp    $0x1,%eax
  8014d2:	75 21                	jne    8014f5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d4:	a1 20 44 80 00       	mov    0x804420,%eax
  8014d9:	8b 40 48             	mov    0x48(%eax),%eax
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	53                   	push   %ebx
  8014e0:	50                   	push   %eax
  8014e1:	68 cd 29 80 00       	push   $0x8029cd
  8014e6:	e8 06 ee ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f3:	eb 26                	jmp    80151b <read+0x8a>
	}
	if (!dev->dev_read)
  8014f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f8:	8b 40 08             	mov    0x8(%eax),%eax
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	74 17                	je     801516 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	ff 75 10             	pushl  0x10(%ebp)
  801505:	ff 75 0c             	pushl  0xc(%ebp)
  801508:	52                   	push   %edx
  801509:	ff d0                	call   *%eax
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	eb 09                	jmp    80151b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801512:	89 c2                	mov    %eax,%edx
  801514:	eb 05                	jmp    80151b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801516:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80151b:	89 d0                	mov    %edx,%eax
  80151d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	57                   	push   %edi
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801531:	bb 00 00 00 00       	mov    $0x0,%ebx
  801536:	eb 21                	jmp    801559 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	89 f0                	mov    %esi,%eax
  80153d:	29 d8                	sub    %ebx,%eax
  80153f:	50                   	push   %eax
  801540:	89 d8                	mov    %ebx,%eax
  801542:	03 45 0c             	add    0xc(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	57                   	push   %edi
  801547:	e8 45 ff ff ff       	call   801491 <read>
		if (m < 0)
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 10                	js     801563 <readn+0x41>
			return m;
		if (m == 0)
  801553:	85 c0                	test   %eax,%eax
  801555:	74 0a                	je     801561 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801557:	01 c3                	add    %eax,%ebx
  801559:	39 f3                	cmp    %esi,%ebx
  80155b:	72 db                	jb     801538 <readn+0x16>
  80155d:	89 d8                	mov    %ebx,%eax
  80155f:	eb 02                	jmp    801563 <readn+0x41>
  801561:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801563:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 14             	sub    $0x14,%esp
  801572:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801575:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	53                   	push   %ebx
  80157a:	e8 ac fc ff ff       	call   80122b <fd_lookup>
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	89 c2                	mov    %eax,%edx
  801584:	85 c0                	test   %eax,%eax
  801586:	78 68                	js     8015f0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158e:	50                   	push   %eax
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	ff 30                	pushl  (%eax)
  801594:	e8 e8 fc ff ff       	call   801281 <dev_lookup>
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 47                	js     8015e7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a7:	75 21                	jne    8015ca <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a9:	a1 20 44 80 00       	mov    0x804420,%eax
  8015ae:	8b 40 48             	mov    0x48(%eax),%eax
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	50                   	push   %eax
  8015b6:	68 e9 29 80 00       	push   $0x8029e9
  8015bb:	e8 31 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c8:	eb 26                	jmp    8015f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d0:	85 d2                	test   %edx,%edx
  8015d2:	74 17                	je     8015eb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d4:	83 ec 04             	sub    $0x4,%esp
  8015d7:	ff 75 10             	pushl  0x10(%ebp)
  8015da:	ff 75 0c             	pushl  0xc(%ebp)
  8015dd:	50                   	push   %eax
  8015de:	ff d2                	call   *%edx
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	eb 09                	jmp    8015f0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	eb 05                	jmp    8015f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f0:	89 d0                	mov    %edx,%eax
  8015f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	ff 75 08             	pushl  0x8(%ebp)
  801604:	e8 22 fc ff ff       	call   80122b <fd_lookup>
  801609:	83 c4 08             	add    $0x8,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 0e                	js     80161e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801610:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801613:	8b 55 0c             	mov    0xc(%ebp),%edx
  801616:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801619:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 14             	sub    $0x14,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	53                   	push   %ebx
  80162f:	e8 f7 fb ff ff       	call   80122b <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	89 c2                	mov    %eax,%edx
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 65                	js     8016a2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801647:	ff 30                	pushl  (%eax)
  801649:	e8 33 fc ff ff       	call   801281 <dev_lookup>
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	78 44                	js     801699 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165c:	75 21                	jne    80167f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80165e:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801663:	8b 40 48             	mov    0x48(%eax),%eax
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	53                   	push   %ebx
  80166a:	50                   	push   %eax
  80166b:	68 ac 29 80 00       	push   $0x8029ac
  801670:	e8 7c ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167d:	eb 23                	jmp    8016a2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80167f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801682:	8b 52 18             	mov    0x18(%edx),%edx
  801685:	85 d2                	test   %edx,%edx
  801687:	74 14                	je     80169d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	ff 75 0c             	pushl  0xc(%ebp)
  80168f:	50                   	push   %eax
  801690:	ff d2                	call   *%edx
  801692:	89 c2                	mov    %eax,%edx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	eb 09                	jmp    8016a2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801699:	89 c2                	mov    %eax,%edx
  80169b:	eb 05                	jmp    8016a2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80169d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a2:	89 d0                	mov    %edx,%eax
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 14             	sub    $0x14,%esp
  8016b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	ff 75 08             	pushl  0x8(%ebp)
  8016ba:	e8 6c fb ff ff       	call   80122b <fd_lookup>
  8016bf:	83 c4 08             	add    $0x8,%esp
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 58                	js     801720 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d2:	ff 30                	pushl  (%eax)
  8016d4:	e8 a8 fb ff ff       	call   801281 <dev_lookup>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 37                	js     801717 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e7:	74 32                	je     80171b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f3:	00 00 00 
	stat->st_isdir = 0;
  8016f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016fd:	00 00 00 
	stat->st_dev = dev;
  801700:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	53                   	push   %ebx
  80170a:	ff 75 f0             	pushl  -0x10(%ebp)
  80170d:	ff 50 14             	call   *0x14(%eax)
  801710:	89 c2                	mov    %eax,%edx
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	eb 09                	jmp    801720 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801717:	89 c2                	mov    %eax,%edx
  801719:	eb 05                	jmp    801720 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80171b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801720:	89 d0                	mov    %edx,%eax
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	6a 00                	push   $0x0
  801731:	ff 75 08             	pushl  0x8(%ebp)
  801734:	e8 d6 01 00 00       	call   80190f <open>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 1b                	js     80175d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	50                   	push   %eax
  801749:	e8 5b ff ff ff       	call   8016a9 <fstat>
  80174e:	89 c6                	mov    %eax,%esi
	close(fd);
  801750:	89 1c 24             	mov    %ebx,(%esp)
  801753:	e8 fd fb ff ff       	call   801355 <close>
	return r;
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	89 f0                	mov    %esi,%eax
}
  80175d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5d                   	pop    %ebp
  801763:	c3                   	ret    

00801764 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	89 c6                	mov    %eax,%esi
  80176b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80176d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801774:	75 12                	jne    801788 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	6a 01                	push   $0x1
  80177b:	e8 e5 08 00 00       	call   802065 <ipc_find_env>
  801780:	a3 00 40 80 00       	mov    %eax,0x804000
  801785:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801788:	6a 07                	push   $0x7
  80178a:	68 00 50 80 00       	push   $0x805000
  80178f:	56                   	push   %esi
  801790:	ff 35 00 40 80 00    	pushl  0x804000
  801796:	e8 76 08 00 00       	call   802011 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179b:	83 c4 0c             	add    $0xc,%esp
  80179e:	6a 00                	push   $0x0
  8017a0:	53                   	push   %ebx
  8017a1:	6a 00                	push   $0x0
  8017a3:	e8 d1 07 00 00       	call   801f79 <ipc_recv>
}
  8017a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d2:	e8 8d ff ff ff       	call   801764 <fsipc>
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f4:	e8 6b ff ff ff       	call   801764 <fsipc>
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 05 00 00 00       	mov    $0x5,%eax
  80181a:	e8 45 ff ff ff       	call   801764 <fsipc>
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 2c                	js     80184f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	68 00 50 80 00       	push   $0x805000
  80182b:	53                   	push   %ebx
  80182c:	e8 45 f0 ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801831:	a1 80 50 80 00       	mov    0x805080,%eax
  801836:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80183c:	a1 84 50 80 00       	mov    0x805084,%eax
  801841:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185d:	8b 55 08             	mov    0x8(%ebp),%edx
  801860:	8b 52 0c             	mov    0xc(%edx),%edx
  801863:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801869:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  80186e:	50                   	push   %eax
  80186f:	ff 75 0c             	pushl  0xc(%ebp)
  801872:	68 08 50 80 00       	push   $0x805008
  801877:	e8 8c f1 ff ff       	call   800a08 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 04 00 00 00       	mov    $0x4,%eax
  801886:	e8 d9 fe ff ff       	call   801764 <fsipc>
	//panic("devfile_write not implemented");
}
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
  801892:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801895:	8b 45 08             	mov    0x8(%ebp),%eax
  801898:	8b 40 0c             	mov    0xc(%eax),%eax
  80189b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b0:	e8 af fe ff ff       	call   801764 <fsipc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 4b                	js     801906 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018bb:	39 c6                	cmp    %eax,%esi
  8018bd:	73 16                	jae    8018d5 <devfile_read+0x48>
  8018bf:	68 18 2a 80 00       	push   $0x802a18
  8018c4:	68 1f 2a 80 00       	push   $0x802a1f
  8018c9:	6a 7c                	push   $0x7c
  8018cb:	68 34 2a 80 00       	push   $0x802a34
  8018d0:	e8 43 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  8018d5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018da:	7e 16                	jle    8018f2 <devfile_read+0x65>
  8018dc:	68 3f 2a 80 00       	push   $0x802a3f
  8018e1:	68 1f 2a 80 00       	push   $0x802a1f
  8018e6:	6a 7d                	push   $0x7d
  8018e8:	68 34 2a 80 00       	push   $0x802a34
  8018ed:	e8 26 e9 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f2:	83 ec 04             	sub    $0x4,%esp
  8018f5:	50                   	push   %eax
  8018f6:	68 00 50 80 00       	push   $0x805000
  8018fb:	ff 75 0c             	pushl  0xc(%ebp)
  8018fe:	e8 05 f1 ff ff       	call   800a08 <memmove>
	return r;
  801903:	83 c4 10             	add    $0x10,%esp
}
  801906:	89 d8                	mov    %ebx,%eax
  801908:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	83 ec 20             	sub    $0x20,%esp
  801916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801919:	53                   	push   %ebx
  80191a:	e8 1e ef ff ff       	call   80083d <strlen>
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801927:	7f 67                	jg     801990 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801929:	83 ec 0c             	sub    $0xc,%esp
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	e8 a7 f8 ff ff       	call   8011dc <fd_alloc>
  801935:	83 c4 10             	add    $0x10,%esp
		return r;
  801938:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 57                	js     801995 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	53                   	push   %ebx
  801942:	68 00 50 80 00       	push   $0x805000
  801947:	e8 2a ef ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801954:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801957:	b8 01 00 00 00       	mov    $0x1,%eax
  80195c:	e8 03 fe ff ff       	call   801764 <fsipc>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	79 14                	jns    80197e <open+0x6f>
		fd_close(fd, 0);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	6a 00                	push   $0x0
  80196f:	ff 75 f4             	pushl  -0xc(%ebp)
  801972:	e8 5d f9 ff ff       	call   8012d4 <fd_close>
		return r;
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	89 da                	mov    %ebx,%edx
  80197c:	eb 17                	jmp    801995 <open+0x86>
	}

	return fd2num(fd);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	ff 75 f4             	pushl  -0xc(%ebp)
  801984:	e8 2c f8 ff ff       	call   8011b5 <fd2num>
  801989:	89 c2                	mov    %eax,%edx
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	eb 05                	jmp    801995 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801990:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801995:	89 d0                	mov    %edx,%eax
  801997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a7:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ac:	e8 b3 fd ff ff       	call   801764 <fsipc>
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	ff 75 08             	pushl  0x8(%ebp)
  8019c1:	e8 ff f7 ff ff       	call   8011c5 <fd2data>
  8019c6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019c8:	83 c4 08             	add    $0x8,%esp
  8019cb:	68 4b 2a 80 00       	push   $0x802a4b
  8019d0:	53                   	push   %ebx
  8019d1:	e8 a0 ee ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019d6:	8b 46 04             	mov    0x4(%esi),%eax
  8019d9:	2b 06                	sub    (%esi),%eax
  8019db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019e1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e8:	00 00 00 
	stat->st_dev = &devpipe;
  8019eb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019f2:	30 80 00 
	return 0;
}
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fd:	5b                   	pop    %ebx
  8019fe:	5e                   	pop    %esi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	53                   	push   %ebx
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a0b:	53                   	push   %ebx
  801a0c:	6a 00                	push   $0x0
  801a0e:	e8 eb f2 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a13:	89 1c 24             	mov    %ebx,(%esp)
  801a16:	e8 aa f7 ff ff       	call   8011c5 <fd2data>
  801a1b:	83 c4 08             	add    $0x8,%esp
  801a1e:	50                   	push   %eax
  801a1f:	6a 00                	push   $0x0
  801a21:	e8 d8 f2 ff ff       	call   800cfe <sys_page_unmap>
}
  801a26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	57                   	push   %edi
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	83 ec 1c             	sub    $0x1c,%esp
  801a34:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a37:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a39:	a1 20 44 80 00       	mov    0x804420,%eax
  801a3e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a41:	83 ec 0c             	sub    $0xc,%esp
  801a44:	ff 75 e0             	pushl  -0x20(%ebp)
  801a47:	e8 52 06 00 00       	call   80209e <pageref>
  801a4c:	89 c3                	mov    %eax,%ebx
  801a4e:	89 3c 24             	mov    %edi,(%esp)
  801a51:	e8 48 06 00 00       	call   80209e <pageref>
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	39 c3                	cmp    %eax,%ebx
  801a5b:	0f 94 c1             	sete   %cl
  801a5e:	0f b6 c9             	movzbl %cl,%ecx
  801a61:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a64:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a6a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a6d:	39 ce                	cmp    %ecx,%esi
  801a6f:	74 1b                	je     801a8c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a71:	39 c3                	cmp    %eax,%ebx
  801a73:	75 c4                	jne    801a39 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a75:	8b 42 58             	mov    0x58(%edx),%eax
  801a78:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a7b:	50                   	push   %eax
  801a7c:	56                   	push   %esi
  801a7d:	68 52 2a 80 00       	push   $0x802a52
  801a82:	e8 6a e8 ff ff       	call   8002f1 <cprintf>
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	eb ad                	jmp    801a39 <_pipeisclosed+0xe>
	}
}
  801a8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 28             	sub    $0x28,%esp
  801aa0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa3:	56                   	push   %esi
  801aa4:	e8 1c f7 ff ff       	call   8011c5 <fd2data>
  801aa9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab3:	eb 4b                	jmp    801b00 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab5:	89 da                	mov    %ebx,%edx
  801ab7:	89 f0                	mov    %esi,%eax
  801ab9:	e8 6d ff ff ff       	call   801a2b <_pipeisclosed>
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	75 48                	jne    801b0a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac2:	e8 93 f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac7:	8b 43 04             	mov    0x4(%ebx),%eax
  801aca:	8b 0b                	mov    (%ebx),%ecx
  801acc:	8d 51 20             	lea    0x20(%ecx),%edx
  801acf:	39 d0                	cmp    %edx,%eax
  801ad1:	73 e2                	jae    801ab5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ada:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801add:	89 c2                	mov    %eax,%edx
  801adf:	c1 fa 1f             	sar    $0x1f,%edx
  801ae2:	89 d1                	mov    %edx,%ecx
  801ae4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ae7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aea:	83 e2 1f             	and    $0x1f,%edx
  801aed:	29 ca                	sub    %ecx,%edx
  801aef:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801af3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801af7:	83 c0 01             	add    $0x1,%eax
  801afa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afd:	83 c7 01             	add    $0x1,%edi
  801b00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b03:	75 c2                	jne    801ac7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b05:	8b 45 10             	mov    0x10(%ebp),%eax
  801b08:	eb 05                	jmp    801b0f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5f                   	pop    %edi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	57                   	push   %edi
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 18             	sub    $0x18,%esp
  801b20:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b23:	57                   	push   %edi
  801b24:	e8 9c f6 ff ff       	call   8011c5 <fd2data>
  801b29:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b33:	eb 3d                	jmp    801b72 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b35:	85 db                	test   %ebx,%ebx
  801b37:	74 04                	je     801b3d <devpipe_read+0x26>
				return i;
  801b39:	89 d8                	mov    %ebx,%eax
  801b3b:	eb 44                	jmp    801b81 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b3d:	89 f2                	mov    %esi,%edx
  801b3f:	89 f8                	mov    %edi,%eax
  801b41:	e8 e5 fe ff ff       	call   801a2b <_pipeisclosed>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	75 32                	jne    801b7c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b4a:	e8 0b f1 ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b4f:	8b 06                	mov    (%esi),%eax
  801b51:	3b 46 04             	cmp    0x4(%esi),%eax
  801b54:	74 df                	je     801b35 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b56:	99                   	cltd   
  801b57:	c1 ea 1b             	shr    $0x1b,%edx
  801b5a:	01 d0                	add    %edx,%eax
  801b5c:	83 e0 1f             	and    $0x1f,%eax
  801b5f:	29 d0                	sub    %edx,%eax
  801b61:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b69:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b6c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6f:	83 c3 01             	add    $0x1,%ebx
  801b72:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b75:	75 d8                	jne    801b4f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b77:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7a:	eb 05                	jmp    801b81 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	e8 42 f6 ff ff       	call   8011dc <fd_alloc>
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	89 c2                	mov    %eax,%edx
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	0f 88 2c 01 00 00    	js     801cd3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	68 07 04 00 00       	push   $0x407
  801baf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 c0 f0 ff ff       	call   800c79 <sys_page_alloc>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	89 c2                	mov    %eax,%edx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 0d 01 00 00    	js     801cd3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bcc:	50                   	push   %eax
  801bcd:	e8 0a f6 ff ff       	call   8011dc <fd_alloc>
  801bd2:	89 c3                	mov    %eax,%ebx
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	0f 88 e2 00 00 00    	js     801cc1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdf:	83 ec 04             	sub    $0x4,%esp
  801be2:	68 07 04 00 00       	push   $0x407
  801be7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bea:	6a 00                	push   $0x0
  801bec:	e8 88 f0 ff ff       	call   800c79 <sys_page_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	0f 88 c3 00 00 00    	js     801cc1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	ff 75 f4             	pushl  -0xc(%ebp)
  801c04:	e8 bc f5 ff ff       	call   8011c5 <fd2data>
  801c09:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0b:	83 c4 0c             	add    $0xc,%esp
  801c0e:	68 07 04 00 00       	push   $0x407
  801c13:	50                   	push   %eax
  801c14:	6a 00                	push   $0x0
  801c16:	e8 5e f0 ff ff       	call   800c79 <sys_page_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 89 00 00 00    	js     801cb1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2e:	e8 92 f5 ff ff       	call   8011c5 <fd2data>
  801c33:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c3a:	50                   	push   %eax
  801c3b:	6a 00                	push   $0x0
  801c3d:	56                   	push   %esi
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 77 f0 ff ff       	call   800cbc <sys_page_map>
  801c45:	89 c3                	mov    %eax,%ebx
  801c47:	83 c4 20             	add    $0x20,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 55                	js     801ca3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c57:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c63:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c71:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7e:	e8 32 f5 ff ff       	call   8011b5 <fd2num>
  801c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c86:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c88:	83 c4 04             	add    $0x4,%esp
  801c8b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8e:	e8 22 f5 ff ff       	call   8011b5 <fd2num>
  801c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c96:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca1:	eb 30                	jmp    801cd3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	56                   	push   %esi
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 50 f0 ff ff       	call   800cfe <sys_page_unmap>
  801cae:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 40 f0 ff ff       	call   800cfe <sys_page_unmap>
  801cbe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cc1:	83 ec 08             	sub    $0x8,%esp
  801cc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 30 f0 ff ff       	call   800cfe <sys_page_unmap>
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cd3:	89 d0                	mov    %edx,%eax
  801cd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd8:	5b                   	pop    %ebx
  801cd9:	5e                   	pop    %esi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    

00801cdc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce5:	50                   	push   %eax
  801ce6:	ff 75 08             	pushl  0x8(%ebp)
  801ce9:	e8 3d f5 ff ff       	call   80122b <fd_lookup>
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	78 18                	js     801d0d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfb:	e8 c5 f4 ff ff       	call   8011c5 <fd2data>
	return _pipeisclosed(fd, p);
  801d00:	89 c2                	mov    %eax,%edx
  801d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d05:	e8 21 fd ff ff       	call   801a2b <_pipeisclosed>
  801d0a:	83 c4 10             	add    $0x10,%esp
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d17:	85 f6                	test   %esi,%esi
  801d19:	75 16                	jne    801d31 <wait+0x22>
  801d1b:	68 6a 2a 80 00       	push   $0x802a6a
  801d20:	68 1f 2a 80 00       	push   $0x802a1f
  801d25:	6a 09                	push   $0x9
  801d27:	68 75 2a 80 00       	push   $0x802a75
  801d2c:	e8 e7 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d39:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d3c:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d42:	eb 05                	jmp    801d49 <wait+0x3a>
		sys_yield();
  801d44:	e8 11 ef ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d49:	8b 43 48             	mov    0x48(%ebx),%eax
  801d4c:	39 c6                	cmp    %eax,%esi
  801d4e:	75 07                	jne    801d57 <wait+0x48>
  801d50:	8b 43 54             	mov    0x54(%ebx),%eax
  801d53:	85 c0                	test   %eax,%eax
  801d55:	75 ed                	jne    801d44 <wait+0x35>
		sys_yield();
}
  801d57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d61:	b8 00 00 00 00       	mov    $0x0,%eax
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d6e:	68 80 2a 80 00       	push   $0x802a80
  801d73:	ff 75 0c             	pushl  0xc(%ebp)
  801d76:	e8 fb ea ff ff       	call   800876 <strcpy>
	return 0;
}
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d93:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d99:	eb 2d                	jmp    801dc8 <devcons_write+0x46>
		m = n - tot;
  801d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d9e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801da0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801da3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dab:	83 ec 04             	sub    $0x4,%esp
  801dae:	53                   	push   %ebx
  801daf:	03 45 0c             	add    0xc(%ebp),%eax
  801db2:	50                   	push   %eax
  801db3:	57                   	push   %edi
  801db4:	e8 4f ec ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  801db9:	83 c4 08             	add    $0x8,%esp
  801dbc:	53                   	push   %ebx
  801dbd:	57                   	push   %edi
  801dbe:	e8 fa ed ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc3:	01 de                	add    %ebx,%esi
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	89 f0                	mov    %esi,%eax
  801dca:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dcd:	72 cc                	jb     801d9b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 08             	sub    $0x8,%esp
  801ddd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801de2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de6:	74 2a                	je     801e12 <devcons_read+0x3b>
  801de8:	eb 05                	jmp    801def <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dea:	e8 6b ee ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801def:	e8 e7 ed ff ff       	call   800bdb <sys_cgetc>
  801df4:	85 c0                	test   %eax,%eax
  801df6:	74 f2                	je     801dea <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 16                	js     801e12 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dfc:	83 f8 04             	cmp    $0x4,%eax
  801dff:	74 0c                	je     801e0d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e04:	88 02                	mov    %al,(%edx)
	return 1;
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	eb 05                	jmp    801e12 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e20:	6a 01                	push   $0x1
  801e22:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	e8 92 ed ff ff       	call   800bbd <sys_cputs>
}
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <getchar>:

int
getchar(void)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e36:	6a 01                	push   $0x1
  801e38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	6a 00                	push   $0x0
  801e3e:	e8 4e f6 ff ff       	call   801491 <read>
	if (r < 0)
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 0f                	js     801e59 <getchar+0x29>
		return r;
	if (r < 1)
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	7e 06                	jle    801e54 <getchar+0x24>
		return -E_EOF;
	return c;
  801e4e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e52:	eb 05                	jmp    801e59 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e54:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e59:	c9                   	leave  
  801e5a:	c3                   	ret    

00801e5b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e64:	50                   	push   %eax
  801e65:	ff 75 08             	pushl  0x8(%ebp)
  801e68:	e8 be f3 ff ff       	call   80122b <fd_lookup>
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	85 c0                	test   %eax,%eax
  801e72:	78 11                	js     801e85 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e77:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7d:	39 10                	cmp    %edx,(%eax)
  801e7f:	0f 94 c0             	sete   %al
  801e82:	0f b6 c0             	movzbl %al,%eax
}
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <opencons>:

int
opencons(void)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e90:	50                   	push   %eax
  801e91:	e8 46 f3 ff ff       	call   8011dc <fd_alloc>
  801e96:	83 c4 10             	add    $0x10,%esp
		return r;
  801e99:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 3e                	js     801edd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9f:	83 ec 04             	sub    $0x4,%esp
  801ea2:	68 07 04 00 00       	push   $0x407
  801ea7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eaa:	6a 00                	push   $0x0
  801eac:	e8 c8 ed ff ff       	call   800c79 <sys_page_alloc>
  801eb1:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 23                	js     801edd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ecf:	83 ec 0c             	sub    $0xc,%esp
  801ed2:	50                   	push   %eax
  801ed3:	e8 dd f2 ff ff       	call   8011b5 <fd2num>
  801ed8:	89 c2                	mov    %eax,%edx
  801eda:	83 c4 10             	add    $0x10,%esp
}
  801edd:	89 d0                	mov    %edx,%eax
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ee8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eef:	75 57                	jne    801f48 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801ef1:	e8 45 ed ff ff       	call   800c3b <sys_getenvid>
  801ef6:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801ef8:	83 ec 04             	sub    $0x4,%esp
  801efb:	6a 07                	push   $0x7
  801efd:	68 00 f0 bf ee       	push   $0xeebff000
  801f02:	50                   	push   %eax
  801f03:	e8 71 ed ff ff       	call   800c79 <sys_page_alloc>
		if (r) {
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	74 12                	je     801f21 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801f0f:	50                   	push   %eax
  801f10:	68 da 28 80 00       	push   $0x8028da
  801f15:	6a 25                	push   $0x25
  801f17:	68 8c 2a 80 00       	push   $0x802a8c
  801f1c:	e8 f7 e2 ff ff       	call   800218 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801f21:	83 ec 08             	sub    $0x8,%esp
  801f24:	68 55 1f 80 00       	push   $0x801f55
  801f29:	53                   	push   %ebx
  801f2a:	e8 95 ee ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
		if (r) {
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	74 12                	je     801f48 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801f36:	50                   	push   %eax
  801f37:	68 9c 2a 80 00       	push   $0x802a9c
  801f3c:	6a 2b                	push   $0x2b
  801f3e:	68 8c 2a 80 00       	push   $0x802a8c
  801f43:	e8 d0 e2 ff ff       	call   800218 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f48:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4b:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f55:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f56:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f5b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f5d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801f60:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801f64:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801f69:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801f6d:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801f6f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801f72:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801f73:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801f76:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801f77:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801f78:	c3                   	ret    

00801f79 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801f87:	85 c0                	test   %eax,%eax
  801f89:	74 3e                	je     801fc9 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801f8b:	83 ec 0c             	sub    $0xc,%esp
  801f8e:	50                   	push   %eax
  801f8f:	e8 95 ee ff ff       	call   800e29 <sys_ipc_recv>
  801f94:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	85 f6                	test   %esi,%esi
  801f9b:	74 13                	je     801fb0 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa2:	85 d2                	test   %edx,%edx
  801fa4:	75 08                	jne    801fae <ipc_recv+0x35>
  801fa6:	a1 20 44 80 00       	mov    0x804420,%eax
  801fab:	8b 40 74             	mov    0x74(%eax),%eax
  801fae:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801fb0:	85 db                	test   %ebx,%ebx
  801fb2:	74 48                	je     801ffc <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb9:	85 d2                	test   %edx,%edx
  801fbb:	75 08                	jne    801fc5 <ipc_recv+0x4c>
  801fbd:	a1 20 44 80 00       	mov    0x804420,%eax
  801fc2:	8b 40 78             	mov    0x78(%eax),%eax
  801fc5:	89 03                	mov    %eax,(%ebx)
  801fc7:	eb 33                	jmp    801ffc <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	68 00 00 c0 ee       	push   $0xeec00000
  801fd1:	e8 53 ee ff ff       	call   800e29 <sys_ipc_recv>
  801fd6:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 f6                	test   %esi,%esi
  801fdd:	74 13                	je     801ff2 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe4:	85 d2                	test   %edx,%edx
  801fe6:	75 08                	jne    801ff0 <ipc_recv+0x77>
  801fe8:	a1 20 44 80 00       	mov    0x804420,%eax
  801fed:	8b 40 74             	mov    0x74(%eax),%eax
  801ff0:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ff2:	85 db                	test   %ebx,%ebx
  801ff4:	74 06                	je     801ffc <ipc_recv+0x83>
			*perm_store = 0;
  801ff6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801ffc:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801ffe:	85 d2                	test   %edx,%edx
  802000:	75 08                	jne    80200a <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  802002:	a1 20 44 80 00       	mov    0x804420,%eax
  802007:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	57                   	push   %edi
  802015:	56                   	push   %esi
  802016:	53                   	push   %ebx
  802017:	83 ec 0c             	sub    $0xc,%esp
  80201a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802020:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  802023:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  802025:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80202a:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80202d:	eb 1c                	jmp    80204b <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  80202f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802032:	74 12                	je     802046 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  802034:	50                   	push   %eax
  802035:	68 c4 2a 80 00       	push   $0x802ac4
  80203a:	6a 4f                	push   $0x4f
  80203c:	68 df 2a 80 00       	push   $0x802adf
  802041:	e8 d2 e1 ff ff       	call   800218 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802046:	e8 0f ec ff ff       	call   800c5a <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80204b:	ff 75 14             	pushl  0x14(%ebp)
  80204e:	53                   	push   %ebx
  80204f:	56                   	push   %esi
  802050:	57                   	push   %edi
  802051:	e8 b0 ed ff ff       	call   800e06 <sys_ipc_try_send>
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 d2                	js     80202f <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80205d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    

00802065 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80206b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802070:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802079:	8b 52 50             	mov    0x50(%edx),%edx
  80207c:	39 ca                	cmp    %ecx,%edx
  80207e:	75 0d                	jne    80208d <ipc_find_env+0x28>
			return envs[i].env_id;
  802080:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802083:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802088:	8b 40 48             	mov    0x48(%eax),%eax
  80208b:	eb 0f                	jmp    80209c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80208d:	83 c0 01             	add    $0x1,%eax
  802090:	3d 00 04 00 00       	cmp    $0x400,%eax
  802095:	75 d9                	jne    802070 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802097:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    

0080209e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a4:	89 d0                	mov    %edx,%eax
  8020a6:	c1 e8 16             	shr    $0x16,%eax
  8020a9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020b0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b5:	f6 c1 01             	test   $0x1,%cl
  8020b8:	74 1d                	je     8020d7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ba:	c1 ea 0c             	shr    $0xc,%edx
  8020bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020c4:	f6 c2 01             	test   $0x1,%dl
  8020c7:	74 0e                	je     8020d7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c9:	c1 ea 0c             	shr    $0xc,%edx
  8020cc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020d3:	ef 
  8020d4:	0f b7 c0             	movzwl %ax,%eax
}
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	66 90                	xchg   %ax,%ax
  8020db:	66 90                	xchg   %ax,%ax
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
