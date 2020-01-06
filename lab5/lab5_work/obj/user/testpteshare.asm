
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 ed 07 00 00       	call   800836 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 c0 0b 00 00       	call   800c39 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 ec 28 80 00       	push   $0x8028ec
  800086:	6a 13                	push   $0x13
  800088:	68 ff 28 80 00       	push   $0x8028ff
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 8f 0e 00 00       	call   800f26 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 13 29 80 00       	push   $0x802913
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 ff 28 80 00       	push   $0x8028ff
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 70 07 00 00       	call   800836 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 a2 21 00 00       	call   802279 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 f6 07 00 00       	call   8008e0 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba e6 28 80 00       	mov    $0x8028e6,%edx
  8000f4:	b8 e0 28 80 00       	mov    $0x8028e0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 1c 29 80 00       	push   $0x80291c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 37 29 80 00       	push   $0x802937
  80010e:	68 3c 29 80 00       	push   $0x80293c
  800113:	68 3b 29 80 00       	push   $0x80293b
  800118:	e8 8d 1d 00 00       	call   801eaa <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 49 29 80 00       	push   $0x802949
  80012a:	6a 21                	push   $0x21
  80012c:	68 ff 28 80 00       	push   $0x8028ff
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 3a 21 00 00       	call   802279 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 8e 07 00 00       	call   8008e0 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba e6 28 80 00       	mov    $0x8028e6,%edx
  80015c:	b8 e0 28 80 00       	mov    $0x8028e0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 53 29 80 00       	push   $0x802953
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 73 0a 00 00       	call   800bfb <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 77 11 00 00       	call   801340 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 e7 09 00 00       	call   800bba <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 10 0a 00 00       	call   800bfb <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 98 29 80 00       	push   $0x802998
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 de 2f 80 00 	movl   $0x802fde,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 2f 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 d4 08 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 37 23 00 00       	call   802650 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 24 24 00 00       	call   802780 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 bb 29 80 00 	movsbl 0x8029bb(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 89 03 00 00    	je     80078d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 07                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	0f b6 c8             	movzbl %al,%ecx
  80044d:	83 e8 23             	sub    $0x23,%eax
  800450:	3c 55                	cmp    $0x55,%al
  800452:	0f 87 1a 03 00 00    	ja     800772 <vprintfmt+0x38a>
  800458:	0f b6 c0             	movzbl %al,%eax
  80045b:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800469:	eb d6                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 39                	ja     8004c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 27                	jmp    8004c7 <vprintfmt+0xdf>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	eb 8c                	jmp    800441 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	eb 80                	jmp    800441 <vprintfmt+0x59>
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cb:	0f 89 70 ff ff ff    	jns    800441 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004de:	e9 5e ff ff ff       	jmp    800441 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e9:	e9 53 ff ff ff       	jmp    800441 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 04 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x142>
  80051f:	8b 14 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 d3 29 80 00       	push   $0x8029d3
  800530:	53                   	push   %ebx
  800531:	56                   	push   %esi
  800532:	e8 94 fe ff ff       	call   8003cb <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053d:	e9 cc fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800542:	52                   	push   %edx
  800543:	68 11 2f 80 00       	push   $0x802f11
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 7c fe ff ff       	call   8003cb <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	e9 b4 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 cc 29 80 00       	mov    $0x8029cc,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e 94 00 00 00    	jle    80060d <vprintfmt+0x225>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	0f 84 98 00 00 00    	je     80061b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 d0             	pushl  -0x30(%ebp)
  800589:	57                   	push   %edi
  80058a:	e8 86 02 00 00       	call   800815 <strnlen>
  80058f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	eb 0f                	jmp    8005b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ed                	jg     8005a8 <vprintfmt+0x1c0>
  8005bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c1             	cmovns %ecx,%eax
  8005cb:	29 c1                	sub    %eax,%ecx
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	89 cb                	mov    %ecx,%ebx
  8005d8:	eb 4d                	jmp    800627 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x213>
  8005e0:	0f be c0             	movsbl %al,%eax
  8005e3:	83 e8 20             	sub    $0x20,%eax
  8005e6:	83 f8 5e             	cmp    $0x5e,%eax
  8005e9:	76 10                	jbe    8005fb <vprintfmt+0x213>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 3f                	push   $0x3f
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	eb 1a                	jmp    800627 <vprintfmt+0x23f>
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800619:	eb 0c                	jmp    800627 <vprintfmt+0x23f>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800621:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800624:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800627:	83 c7 01             	add    $0x1,%edi
  80062a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062e:	0f be d0             	movsbl %al,%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	74 23                	je     800658 <vprintfmt+0x270>
  800635:	85 f6                	test   %esi,%esi
  800637:	78 a1                	js     8005da <vprintfmt+0x1f2>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 9c                	jns    8005da <vprintfmt+0x1f2>
  80063e:	89 df                	mov    %ebx,%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	eb 18                	jmp    800660 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 08                	jmp    800660 <vprintfmt+0x278>
  800658:	89 df                	mov    %ebx,%edi
  80065a:	8b 75 08             	mov    0x8(%ebp),%esi
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800660:	85 ff                	test   %edi,%edi
  800662:	7f e4                	jg     800648 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 a2 fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x2d1>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c8:	79 74                	jns    80073e <vprintfmt+0x356>
				putch('-', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 2d                	push   $0x2d
  8006d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d8:	f7 d8                	neg    %eax
  8006da:	83 d2 00             	adc    $0x0,%edx
  8006dd:	f7 da                	neg    %edx
  8006df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e7:	eb 55                	jmp    80073e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	e8 83 fc ff ff       	call   800374 <getuint>
			base = 10;
  8006f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f6:	eb 46                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 74 fc ff ff       	call   800374 <getuint>
			base=8;
  800700:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800705:	eb 37                	jmp    80073e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 30                	push   $0x30
  80070d:	ff d6                	call   *%esi
			putch('x', putdat);
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 78                	push   $0x78
  800715:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800720:	8b 00                	mov    (%eax),%eax
  800722:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800727:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072f:	eb 0d                	jmp    80073e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	e8 3b fc ff ff       	call   800374 <getuint>
			base = 16;
  800739:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800745:	57                   	push   %edi
  800746:	ff 75 e0             	pushl  -0x20(%ebp)
  800749:	51                   	push   %ecx
  80074a:	52                   	push   %edx
  80074b:	50                   	push   %eax
  80074c:	89 da                	mov    %ebx,%edx
  80074e:	89 f0                	mov    %esi,%eax
  800750:	e8 70 fb ff ff       	call   8002c5 <printnum>
			break;
  800755:	83 c4 20             	add    $0x20,%esp
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 ae fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	53                   	push   %ebx
  800764:	51                   	push   %ecx
  800765:	ff d6                	call   *%esi
			break;
  800767:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076d:	e9 9c fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	eb 03                	jmp    800782 <vprintfmt+0x39a>
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800786:	75 f7                	jne    80077f <vprintfmt+0x397>
  800788:	e9 81 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5f                   	pop    %edi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	74 26                	je     8007dc <vsnprintf+0x47>
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	7e 22                	jle    8007dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ba:	ff 75 14             	pushl  0x14(%ebp)
  8007bd:	ff 75 10             	pushl  0x10(%ebp)
  8007c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	68 ae 03 80 00       	push   $0x8003ae
  8007c9:	e8 1a fc ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	eb 05                	jmp    8007e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 9a ff ff ff       	call   800795 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	eb 03                	jmp    80080d <strlen+0x10>
		n++;
  80080a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800811:	75 f7                	jne    80080a <strlen+0xd>
		n++;
	return n;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081e:	ba 00 00 00 00       	mov    $0x0,%edx
  800823:	eb 03                	jmp    800828 <strnlen+0x13>
		n++;
  800825:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800828:	39 c2                	cmp    %eax,%edx
  80082a:	74 08                	je     800834 <strnlen+0x1f>
  80082c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800830:	75 f3                	jne    800825 <strnlen+0x10>
  800832:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	89 c2                	mov    %eax,%edx
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ef                	jne    800842 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085d:	53                   	push   %ebx
  80085e:	e8 9a ff ff ff       	call   8007fd <strlen>
  800863:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	01 d8                	add    %ebx,%eax
  80086b:	50                   	push   %eax
  80086c:	e8 c5 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  800871:	89 d8                	mov    %ebx,%eax
  800873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	89 f3                	mov    %esi,%ebx
  800885:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	89 f2                	mov    %esi,%edx
  80088a:	eb 0f                	jmp    80089b <strncpy+0x23>
		*dst++ = *src;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800895:	80 39 01             	cmpb   $0x1,(%ecx)
  800898:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089b:	39 da                	cmp    %ebx,%edx
  80089d:	75 ed                	jne    80088c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 21                	je     8008da <strlcpy+0x35>
  8008b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bd:	89 f2                	mov    %esi,%edx
  8008bf:	eb 09                	jmp    8008ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	74 09                	je     8008d7 <strlcpy+0x32>
  8008ce:	0f b6 19             	movzbl (%ecx),%ebx
  8008d1:	84 db                	test   %bl,%bl
  8008d3:	75 ec                	jne    8008c1 <strlcpy+0x1c>
  8008d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f0                	sub    %esi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strcmp+0x11>
		p++, q++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 04                	je     8008fc <strcmp+0x1c>
  8008f8:	3a 02                	cmp    (%edx),%al
  8008fa:	74 ef                	je     8008eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 c0             	movzbl %al,%eax
  8008ff:	0f b6 12             	movzbl (%edx),%edx
  800902:	29 d0                	sub    %edx,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c3                	mov    %eax,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800915:	eb 06                	jmp    80091d <strncmp+0x17>
		n--, p++, q++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 15                	je     800936 <strncmp+0x30>
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	84 c9                	test   %cl,%cl
  800926:	74 04                	je     80092c <strncmp+0x26>
  800928:	3a 0a                	cmp    (%edx),%cl
  80092a:	74 eb                	je     800917 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
  800934:	eb 05                	jmp    80093b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093b:	5b                   	pop    %ebx
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	eb 07                	jmp    800951 <strchr+0x13>
		if (*s == c)
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 0f                	je     80095d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	0f b6 10             	movzbl (%eax),%edx
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	eb 03                	jmp    80096e <strfind+0xf>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 04                	je     800979 <strfind+0x1a>
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f2                	jne    80096b <strfind+0xc>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 36                	je     8009c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 28                	jne    8009bb <memset+0x40>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 23                	jne    8009bb <memset+0x40>
		c &= 0xFF;
  800998:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099c:	89 d3                	mov    %edx,%ebx
  80099e:	c1 e3 08             	shl    $0x8,%ebx
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	c1 e6 18             	shl    $0x18,%esi
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	c1 e0 10             	shl    $0x10,%eax
  8009ab:	09 f0                	or     %esi,%eax
  8009ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009af:	89 d8                	mov    %ebx,%eax
  8009b1:	09 d0                	or     %edx,%eax
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
  8009b6:	fc                   	cld    
  8009b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b9:	eb 06                	jmp    8009c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	fc                   	cld    
  8009bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c1:	89 f8                	mov    %edi,%eax
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5f                   	pop    %edi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 35                	jae    800a0f <memmove+0x47>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 d0                	cmp    %edx,%eax
  8009df:	73 2e                	jae    800a0f <memmove+0x47>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	09 fe                	or     %edi,%esi
  8009e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ee:	75 13                	jne    800a03 <memmove+0x3b>
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 0e                	jne    800a03 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 09                	jmp    800a0c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a03:	83 ef 01             	sub    $0x1,%edi
  800a06:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a09:	fd                   	std    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0c:	fc                   	cld    
  800a0d:	eb 1d                	jmp    800a2c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	09 c2                	or     %eax,%edx
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 0f                	jne    800a27 <memmove+0x5f>
  800a18:	f6 c1 03             	test   $0x3,%cl
  800a1b:	75 0a                	jne    800a27 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 05                	jmp    800a2c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a27:	89 c7                	mov    %eax,%edi
  800a29:	fc                   	cld    
  800a2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 87 ff ff ff       	call   8009c8 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	eb 1a                	jmp    800a6f <memcmp+0x2c>
		if (*s1 != *s2)
  800a55:	0f b6 08             	movzbl (%eax),%ecx
  800a58:	0f b6 1a             	movzbl (%edx),%ebx
  800a5b:	38 d9                	cmp    %bl,%cl
  800a5d:	74 0a                	je     800a69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 0f                	jmp    800a78 <memcmp+0x35>
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	39 f0                	cmp    %esi,%eax
  800a71:	75 e2                	jne    800a55 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a83:	89 c1                	mov    %eax,%ecx
  800a85:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8c:	eb 0a                	jmp    800a98 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	0f b6 10             	movzbl (%eax),%edx
  800a91:	39 da                	cmp    %ebx,%edx
  800a93:	74 07                	je     800a9c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	39 c8                	cmp    %ecx,%eax
  800a9a:	72 f2                	jb     800a8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	eb 03                	jmp    800ab0 <strtol+0x11>
		s++;
  800aad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab0:	0f b6 01             	movzbl (%ecx),%eax
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f6                	je     800aad <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f2                	je     800aad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 0a                	jne    800ac9 <strtol+0x2a>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac7:	eb 11                	jmp    800ada <strtol+0x3b>
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	75 08                	jne    800ada <strtol+0x3b>
		s++, neg = 1;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 15                	jne    800af7 <strtol+0x58>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	75 10                	jne    800af7 <strtol+0x58>
  800ae7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aeb:	75 7c                	jne    800b69 <strtol+0xca>
		s += 2, base = 16;
  800aed:	83 c1 02             	add    $0x2,%ecx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb 16                	jmp    800b0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	75 12                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b00:	80 39 30             	cmpb   $0x30,(%ecx)
  800b03:	75 08                	jne    800b0d <strtol+0x6e>
		s++, base = 8;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b15:	0f b6 11             	movzbl (%ecx),%edx
  800b18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 09             	cmp    $0x9,%bl
  800b20:	77 08                	ja     800b2a <strtol+0x8b>
			dig = *s - '0';
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 30             	sub    $0x30,%edx
  800b28:	eb 22                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb 10                	jmp    800b4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 16                	ja     800b5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4f:	7d 0b                	jge    800b5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b5a:	eb b9                	jmp    800b15 <strtol+0x76>

	if (endptr)
  800b5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b60:	74 0d                	je     800b6f <strtol+0xd0>
		*endptr = (char *) s;
  800b62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b65:	89 0e                	mov    %ecx,(%esi)
  800b67:	eb 06                	jmp    800b6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b69:	85 db                	test   %ebx,%ebx
  800b6b:	74 98                	je     800b05 <strtol+0x66>
  800b6d:	eb 9e                	jmp    800b0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	f7 da                	neg    %edx
  800b73:	85 ff                	test   %edi,%edi
  800b75:	0f 45 c2             	cmovne %edx,%eax
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 c3                	mov    %eax,%ebx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 03                	push   $0x3
  800be2:	68 bf 2c 80 00       	push   $0x802cbf
  800be7:	6a 23                	push   $0x23
  800be9:	68 dc 2c 80 00       	push   $0x802cdc
  800bee:	e8 e5 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_yield>:

void
sys_yield(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	be 00 00 00 00       	mov    $0x0,%esi
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	89 f7                	mov    %esi,%edi
  800c57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 bf 2c 80 00       	push   $0x802cbf
  800c68:	6a 23                	push   $0x23
  800c6a:	68 dc 2c 80 00       	push   $0x802cdc
  800c6f:	e8 64 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c96:	8b 75 18             	mov    0x18(%ebp),%esi
  800c99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 05                	push   $0x5
  800ca5:	68 bf 2c 80 00       	push   $0x802cbf
  800caa:	6a 23                	push   $0x23
  800cac:	68 dc 2c 80 00       	push   $0x802cdc
  800cb1:	e8 22 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 06                	push   $0x6
  800ce7:	68 bf 2c 80 00       	push   $0x802cbf
  800cec:	6a 23                	push   $0x23
  800cee:	68 dc 2c 80 00       	push   $0x802cdc
  800cf3:	e8 e0 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 08                	push   $0x8
  800d29:	68 bf 2c 80 00       	push   $0x802cbf
  800d2e:	6a 23                	push   $0x23
  800d30:	68 dc 2c 80 00       	push   $0x802cdc
  800d35:	e8 9e f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 df                	mov    %ebx,%edi
  800d5d:	89 de                	mov    %ebx,%esi
  800d5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7e 17                	jle    800d7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	50                   	push   %eax
  800d69:	6a 09                	push   $0x9
  800d6b:	68 bf 2c 80 00       	push   $0x802cbf
  800d70:	6a 23                	push   $0x23
  800d72:	68 dc 2c 80 00       	push   $0x802cdc
  800d77:	e8 5c f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
  800d8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 df                	mov    %ebx,%edi
  800d9f:	89 de                	mov    %ebx,%esi
  800da1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 17                	jle    800dbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0a                	push   $0xa
  800dad:	68 bf 2c 80 00       	push   $0x802cbf
  800db2:	6a 23                	push   $0x23
  800db4:	68 dc 2c 80 00       	push   $0x802cdc
  800db9:	e8 1a f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	be 00 00 00 00       	mov    $0x0,%esi
  800dd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	89 cb                	mov    %ecx,%ebx
  800e01:	89 cf                	mov    %ecx,%edi
  800e03:	89 ce                	mov    %ecx,%esi
  800e05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 0d                	push   $0xd
  800e11:	68 bf 2c 80 00       	push   $0x802cbf
  800e16:	6a 23                	push   $0x23
  800e18:	68 dc 2c 80 00       	push   $0x802cdc
  800e1d:	e8 b6 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e32:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800e34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e38:	75 14                	jne    800e4e <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800e3a:	83 ec 04             	sub    $0x4,%esp
  800e3d:	68 ec 2c 80 00       	push   $0x802cec
  800e42:	6a 23                	push   $0x23
  800e44:	68 af 2d 80 00       	push   $0x802daf
  800e49:	e8 8a f3 ff ff       	call   8001d8 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800e4e:	89 d8                	mov    %ebx,%eax
  800e50:	c1 e8 0c             	shr    $0xc,%eax
  800e53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e5a:	f6 c4 08             	test   $0x8,%ah
  800e5d:	75 14                	jne    800e73 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	68 10 2d 80 00       	push   $0x802d10
  800e67:	6a 2d                	push   $0x2d
  800e69:	68 af 2d 80 00       	push   $0x802daf
  800e6e:	e8 65 f3 ff ff       	call   8001d8 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800e73:	e8 83 fd ff ff       	call   800bfb <sys_getenvid>
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	6a 07                	push   $0x7
  800e7d:	68 00 f0 7f 00       	push   $0x7ff000
  800e82:	50                   	push   %eax
  800e83:	e8 b1 fd ff ff       	call   800c39 <sys_page_alloc>
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 12                	jns    800ea1 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800e8f:	50                   	push   %eax
  800e90:	68 ba 2d 80 00       	push   $0x802dba
  800e95:	6a 3b                	push   $0x3b
  800e97:	68 af 2d 80 00       	push   $0x802daf
  800e9c:	e8 37 f3 ff ff       	call   8001d8 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 00 10 00 00       	push   $0x1000
  800eaf:	53                   	push   %ebx
  800eb0:	68 00 f0 7f 00       	push   $0x7ff000
  800eb5:	e8 0e fb ff ff       	call   8009c8 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800eba:	e8 3c fd ff ff       	call   800bfb <sys_getenvid>
  800ebf:	89 c6                	mov    %eax,%esi
  800ec1:	e8 35 fd ff ff       	call   800bfb <sys_getenvid>
  800ec6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ecd:	53                   	push   %ebx
  800ece:	56                   	push   %esi
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	50                   	push   %eax
  800ed5:	e8 a2 fd ff ff       	call   800c7c <sys_page_map>
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 12                	jns    800ef3 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800ee1:	50                   	push   %eax
  800ee2:	68 d3 2d 80 00       	push   $0x802dd3
  800ee7:	6a 48                	push   $0x48
  800ee9:	68 af 2d 80 00       	push   $0x802daf
  800eee:	e8 e5 f2 ff ff       	call   8001d8 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800ef3:	e8 03 fd ff ff       	call   800bfb <sys_getenvid>
  800ef8:	83 ec 08             	sub    $0x8,%esp
  800efb:	68 00 f0 7f 00       	push   $0x7ff000
  800f00:	50                   	push   %eax
  800f01:	e8 b8 fd ff ff       	call   800cbe <sys_page_unmap>
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	79 12                	jns    800f1f <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800f0d:	50                   	push   %eax
  800f0e:	68 ea 2d 80 00       	push   $0x802dea
  800f13:	6a 4c                	push   $0x4c
  800f15:	68 af 2d 80 00       	push   $0x802daf
  800f1a:	e8 b9 f2 ff ff       	call   8001d8 <_panic>
	}

	//panic("pgfault not implemented");
}
  800f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800f2f:	68 2a 0e 80 00       	push   $0x800e2a
  800f34:	e8 12 15 00 00       	call   80244b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f39:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3e:	cd 30                	int    $0x30
  800f40:	89 c7                	mov    %eax,%edi
  800f42:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 15                	jns    800f61 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800f4c:	50                   	push   %eax
  800f4d:	68 03 2e 80 00       	push   $0x802e03
  800f52:	68 a1 00 00 00       	push   $0xa1
  800f57:	68 af 2d 80 00       	push   $0x802daf
  800f5c:	e8 77 f2 ff ff       	call   8001d8 <_panic>
  800f61:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800f66:	85 c0                	test   %eax,%eax
  800f68:	75 21                	jne    800f8b <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800f6a:	e8 8c fc ff ff       	call   800bfb <sys_getenvid>
  800f6f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f7c:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	e9 c8 01 00 00       	jmp    801153 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	c1 e8 16             	shr    $0x16,%eax
  800f90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f97:	a8 01                	test   $0x1,%al
  800f99:	0f 84 23 01 00 00    	je     8010c2 <fork+0x19c>
  800f9f:	89 d8                	mov    %ebx,%eax
  800fa1:	c1 e8 0c             	shr    $0xc,%eax
  800fa4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fab:	f6 c2 01             	test   $0x1,%dl
  800fae:	0f 84 0e 01 00 00    	je     8010c2 <fork+0x19c>
  800fb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbb:	f6 c2 04             	test   $0x4,%dl
  800fbe:	0f 84 fe 00 00 00    	je     8010c2 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800fc4:	89 c6                	mov    %eax,%esi
  800fc6:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800fc9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd0:	f6 c6 04             	test   $0x4,%dh
  800fd3:	74 3f                	je     801014 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800fd5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe4:	50                   	push   %eax
  800fe5:	56                   	push   %esi
  800fe6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe9:	56                   	push   %esi
  800fea:	6a 00                	push   $0x0
  800fec:	e8 8b fc ff ff       	call   800c7c <sys_page_map>
  800ff1:	83 c4 20             	add    $0x20,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	0f 89 c6 00 00 00    	jns    8010c2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	50                   	push   %eax
  801000:	57                   	push   %edi
  801001:	6a 00                	push   $0x0
  801003:	68 40 2d 80 00       	push   $0x802d40
  801008:	6a 6c                	push   $0x6c
  80100a:	68 af 2d 80 00       	push   $0x802daf
  80100f:	e8 c4 f1 ff ff       	call   8001d8 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801014:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101b:	f6 c2 02             	test   $0x2,%dl
  80101e:	75 0c                	jne    80102c <fork+0x106>
  801020:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801027:	f6 c4 08             	test   $0x8,%ah
  80102a:	74 66                	je     801092 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	68 05 08 00 00       	push   $0x805
  801034:	56                   	push   %esi
  801035:	ff 75 e4             	pushl  -0x1c(%ebp)
  801038:	56                   	push   %esi
  801039:	6a 00                	push   $0x0
  80103b:	e8 3c fc ff ff       	call   800c7c <sys_page_map>
  801040:	83 c4 20             	add    $0x20,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 18                	jns    80105f <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	50                   	push   %eax
  80104b:	57                   	push   %edi
  80104c:	6a 00                	push   $0x0
  80104e:	68 40 2d 80 00       	push   $0x802d40
  801053:	6a 74                	push   $0x74
  801055:	68 af 2d 80 00       	push   $0x802daf
  80105a:	e8 79 f1 ff ff       	call   8001d8 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	68 05 08 00 00       	push   $0x805
  801067:	56                   	push   %esi
  801068:	6a 00                	push   $0x0
  80106a:	56                   	push   %esi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 0a fc ff ff       	call   800c7c <sys_page_map>
  801072:	83 c4 20             	add    $0x20,%esp
  801075:	85 c0                	test   %eax,%eax
  801077:	79 49                	jns    8010c2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  801079:	83 ec 08             	sub    $0x8,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 00                	push   $0x0
  80107f:	6a 00                	push   $0x0
  801081:	68 40 2d 80 00       	push   $0x802d40
  801086:	6a 77                	push   $0x77
  801088:	68 af 2d 80 00       	push   $0x802daf
  80108d:	e8 46 f1 ff ff       	call   8001d8 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	6a 05                	push   $0x5
  801097:	56                   	push   %esi
  801098:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109b:	56                   	push   %esi
  80109c:	6a 00                	push   $0x0
  80109e:	e8 d9 fb ff ff       	call   800c7c <sys_page_map>
  8010a3:	83 c4 20             	add    $0x20,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 18                	jns    8010c2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	50                   	push   %eax
  8010ae:	57                   	push   %edi
  8010af:	6a 00                	push   $0x0
  8010b1:	68 40 2d 80 00       	push   $0x802d40
  8010b6:	6a 7d                	push   $0x7d
  8010b8:	68 af 2d 80 00       	push   $0x802daf
  8010bd:	e8 16 f1 ff ff       	call   8001d8 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8010c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010ce:	0f 85 b7 fe ff ff    	jne    800f8b <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	6a 07                	push   $0x7
  8010d9:	68 00 f0 bf ee       	push   $0xeebff000
  8010de:	57                   	push   %edi
  8010df:	e8 55 fb ff ff       	call   800c39 <sys_page_alloc>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 15                	jns    801100 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  8010eb:	50                   	push   %eax
  8010ec:	68 6c 2d 80 00       	push   $0x802d6c
  8010f1:	68 b4 00 00 00       	push   $0xb4
  8010f6:	68 af 2d 80 00       	push   $0x802daf
  8010fb:	e8 d8 f0 ff ff       	call   8001d8 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	68 bf 24 80 00       	push   $0x8024bf
  801108:	57                   	push   %edi
  801109:	e8 76 fc ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 15                	jns    80112a <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801115:	50                   	push   %eax
  801116:	68 19 2e 80 00       	push   $0x802e19
  80111b:	68 ba 00 00 00       	push   $0xba
  801120:	68 af 2d 80 00       	push   $0x802daf
  801125:	e8 ae f0 ff ff       	call   8001d8 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	6a 02                	push   $0x2
  80112f:	57                   	push   %edi
  801130:	e8 cb fb ff ff       	call   800d00 <sys_env_set_status>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	79 15                	jns    801151 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  80113c:	50                   	push   %eax
  80113d:	68 36 2e 80 00       	push   $0x802e36
  801142:	68 bf 00 00 00       	push   $0xbf
  801147:	68 af 2d 80 00       	push   $0x802daf
  80114c:	e8 87 f0 ff ff       	call   8001d8 <_panic>
	}
	return eid;
  801151:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <sfork>:

// Challenge!
int
sfork(void)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801161:	68 53 2e 80 00       	push   $0x802e53
  801166:	68 ca 00 00 00       	push   $0xca
  80116b:	68 af 2d 80 00       	push   $0x802daf
  801170:	e8 63 f0 ff ff       	call   8001d8 <_panic>

00801175 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	05 00 00 00 30       	add    $0x30000000,%eax
  801180:	c1 e8 0c             	shr    $0xc,%eax
}
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	05 00 00 00 30       	add    $0x30000000,%eax
  801190:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801195:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	c1 ea 16             	shr    $0x16,%edx
  8011ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b3:	f6 c2 01             	test   $0x1,%dl
  8011b6:	74 11                	je     8011c9 <fd_alloc+0x2d>
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 ea 0c             	shr    $0xc,%edx
  8011bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c4:	f6 c2 01             	test   $0x1,%dl
  8011c7:	75 09                	jne    8011d2 <fd_alloc+0x36>
			*fd_store = fd;
  8011c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	eb 17                	jmp    8011e9 <fd_alloc+0x4d>
  8011d2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011dc:	75 c9                	jne    8011a7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011de:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011e4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f1:	83 f8 1f             	cmp    $0x1f,%eax
  8011f4:	77 36                	ja     80122c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f6:	c1 e0 0c             	shl    $0xc,%eax
  8011f9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 16             	shr    $0x16,%edx
  801203:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	74 24                	je     801233 <fd_lookup+0x48>
  80120f:	89 c2                	mov    %eax,%edx
  801211:	c1 ea 0c             	shr    $0xc,%edx
  801214:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121b:	f6 c2 01             	test   $0x1,%dl
  80121e:	74 1a                	je     80123a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801220:	8b 55 0c             	mov    0xc(%ebp),%edx
  801223:	89 02                	mov    %eax,(%edx)
	return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	eb 13                	jmp    80123f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801231:	eb 0c                	jmp    80123f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb 05                	jmp    80123f <fd_lookup+0x54>
  80123a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 08             	sub    $0x8,%esp
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124a:	ba e8 2e 80 00       	mov    $0x802ee8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80124f:	eb 13                	jmp    801264 <dev_lookup+0x23>
  801251:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801254:	39 08                	cmp    %ecx,(%eax)
  801256:	75 0c                	jne    801264 <dev_lookup+0x23>
			*dev = devtab[i];
  801258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
  801262:	eb 2e                	jmp    801292 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801264:	8b 02                	mov    (%edx),%eax
  801266:	85 c0                	test   %eax,%eax
  801268:	75 e7                	jne    801251 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126a:	a1 04 50 80 00       	mov    0x805004,%eax
  80126f:	8b 40 48             	mov    0x48(%eax),%eax
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	51                   	push   %ecx
  801276:	50                   	push   %eax
  801277:	68 6c 2e 80 00       	push   $0x802e6c
  80127c:	e8 30 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  801281:	8b 45 0c             	mov    0xc(%ebp),%eax
  801284:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 10             	sub    $0x10,%esp
  80129c:	8b 75 08             	mov    0x8(%ebp),%esi
  80129f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ac:	c1 e8 0c             	shr    $0xc,%eax
  8012af:	50                   	push   %eax
  8012b0:	e8 36 ff ff ff       	call   8011eb <fd_lookup>
  8012b5:	83 c4 08             	add    $0x8,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 05                	js     8012c1 <fd_close+0x2d>
	    || fd != fd2)
  8012bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012bf:	74 0c                	je     8012cd <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c1:	84 db                	test   %bl,%bl
  8012c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c8:	0f 44 c2             	cmove  %edx,%eax
  8012cb:	eb 41                	jmp    80130e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	ff 36                	pushl  (%esi)
  8012d6:	e8 66 ff ff ff       	call   801241 <dev_lookup>
  8012db:	89 c3                	mov    %eax,%ebx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 1a                	js     8012fe <fd_close+0x6a>
		if (dev->dev_close)
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	74 0b                	je     8012fe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012f3:	83 ec 0c             	sub    $0xc,%esp
  8012f6:	56                   	push   %esi
  8012f7:	ff d0                	call   *%eax
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	56                   	push   %esi
  801302:	6a 00                	push   $0x0
  801304:	e8 b5 f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	89 d8                	mov    %ebx,%eax
}
  80130e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	ff 75 08             	pushl  0x8(%ebp)
  801322:	e8 c4 fe ff ff       	call   8011eb <fd_lookup>
  801327:	83 c4 08             	add    $0x8,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 10                	js     80133e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	6a 01                	push   $0x1
  801333:	ff 75 f4             	pushl  -0xc(%ebp)
  801336:	e8 59 ff ff ff       	call   801294 <fd_close>
  80133b:	83 c4 10             	add    $0x10,%esp
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <close_all>:

void
close_all(void)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	53                   	push   %ebx
  801344:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	53                   	push   %ebx
  801350:	e8 c0 ff ff ff       	call   801315 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801355:	83 c3 01             	add    $0x1,%ebx
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	83 fb 20             	cmp    $0x20,%ebx
  80135e:	75 ec                	jne    80134c <close_all+0xc>
		close(i);
}
  801360:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	57                   	push   %edi
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	83 ec 2c             	sub    $0x2c,%esp
  80136e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801371:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801374:	50                   	push   %eax
  801375:	ff 75 08             	pushl  0x8(%ebp)
  801378:	e8 6e fe ff ff       	call   8011eb <fd_lookup>
  80137d:	83 c4 08             	add    $0x8,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	0f 88 c1 00 00 00    	js     801449 <dup+0xe4>
		return r;
	close(newfdnum);
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	56                   	push   %esi
  80138c:	e8 84 ff ff ff       	call   801315 <close>

	newfd = INDEX2FD(newfdnum);
  801391:	89 f3                	mov    %esi,%ebx
  801393:	c1 e3 0c             	shl    $0xc,%ebx
  801396:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80139c:	83 c4 04             	add    $0x4,%esp
  80139f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a2:	e8 de fd ff ff       	call   801185 <fd2data>
  8013a7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013a9:	89 1c 24             	mov    %ebx,(%esp)
  8013ac:	e8 d4 fd ff ff       	call   801185 <fd2data>
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013b7:	89 f8                	mov    %edi,%eax
  8013b9:	c1 e8 16             	shr    $0x16,%eax
  8013bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c3:	a8 01                	test   $0x1,%al
  8013c5:	74 37                	je     8013fe <dup+0x99>
  8013c7:	89 f8                	mov    %edi,%eax
  8013c9:	c1 e8 0c             	shr    $0xc,%eax
  8013cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d3:	f6 c2 01             	test   $0x1,%dl
  8013d6:	74 26                	je     8013fe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e7:	50                   	push   %eax
  8013e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013eb:	6a 00                	push   $0x0
  8013ed:	57                   	push   %edi
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 87 f8 ff ff       	call   800c7c <sys_page_map>
  8013f5:	89 c7                	mov    %eax,%edi
  8013f7:	83 c4 20             	add    $0x20,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 2e                	js     80142c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801401:	89 d0                	mov    %edx,%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
  801406:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	25 07 0e 00 00       	and    $0xe07,%eax
  801415:	50                   	push   %eax
  801416:	53                   	push   %ebx
  801417:	6a 00                	push   $0x0
  801419:	52                   	push   %edx
  80141a:	6a 00                	push   $0x0
  80141c:	e8 5b f8 ff ff       	call   800c7c <sys_page_map>
  801421:	89 c7                	mov    %eax,%edi
  801423:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801426:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801428:	85 ff                	test   %edi,%edi
  80142a:	79 1d                	jns    801449 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	53                   	push   %ebx
  801430:	6a 00                	push   $0x0
  801432:	e8 87 f8 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  801437:	83 c4 08             	add    $0x8,%esp
  80143a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80143d:	6a 00                	push   $0x0
  80143f:	e8 7a f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 f8                	mov    %edi,%eax
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 14             	sub    $0x14,%esp
  801458:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145e:	50                   	push   %eax
  80145f:	53                   	push   %ebx
  801460:	e8 86 fd ff ff       	call   8011eb <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	89 c2                	mov    %eax,%edx
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 6d                	js     8014db <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	83 ec 08             	sub    $0x8,%esp
  801471:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801478:	ff 30                	pushl  (%eax)
  80147a:	e8 c2 fd ff ff       	call   801241 <dev_lookup>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 4c                	js     8014d2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801486:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801489:	8b 42 08             	mov    0x8(%edx),%eax
  80148c:	83 e0 03             	and    $0x3,%eax
  80148f:	83 f8 01             	cmp    $0x1,%eax
  801492:	75 21                	jne    8014b5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801494:	a1 04 50 80 00       	mov    0x805004,%eax
  801499:	8b 40 48             	mov    0x48(%eax),%eax
  80149c:	83 ec 04             	sub    $0x4,%esp
  80149f:	53                   	push   %ebx
  8014a0:	50                   	push   %eax
  8014a1:	68 ad 2e 80 00       	push   $0x802ead
  8014a6:	e8 06 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b3:	eb 26                	jmp    8014db <read+0x8a>
	}
	if (!dev->dev_read)
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	8b 40 08             	mov    0x8(%eax),%eax
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	74 17                	je     8014d6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	ff 75 10             	pushl  0x10(%ebp)
  8014c5:	ff 75 0c             	pushl  0xc(%ebp)
  8014c8:	52                   	push   %edx
  8014c9:	ff d0                	call   *%eax
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	eb 09                	jmp    8014db <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	eb 05                	jmp    8014db <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f6:	eb 21                	jmp    801519 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	89 f0                	mov    %esi,%eax
  8014fd:	29 d8                	sub    %ebx,%eax
  8014ff:	50                   	push   %eax
  801500:	89 d8                	mov    %ebx,%eax
  801502:	03 45 0c             	add    0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	57                   	push   %edi
  801507:	e8 45 ff ff ff       	call   801451 <read>
		if (m < 0)
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 10                	js     801523 <readn+0x41>
			return m;
		if (m == 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	74 0a                	je     801521 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801517:	01 c3                	add    %eax,%ebx
  801519:	39 f3                	cmp    %esi,%ebx
  80151b:	72 db                	jb     8014f8 <readn+0x16>
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	eb 02                	jmp    801523 <readn+0x41>
  801521:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 14             	sub    $0x14,%esp
  801532:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801535:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	53                   	push   %ebx
  80153a:	e8 ac fc ff ff       	call   8011eb <fd_lookup>
  80153f:	83 c4 08             	add    $0x8,%esp
  801542:	89 c2                	mov    %eax,%edx
  801544:	85 c0                	test   %eax,%eax
  801546:	78 68                	js     8015b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801552:	ff 30                	pushl  (%eax)
  801554:	e8 e8 fc ff ff       	call   801241 <dev_lookup>
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 47                	js     8015a7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801563:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801567:	75 21                	jne    80158a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801569:	a1 04 50 80 00       	mov    0x805004,%eax
  80156e:	8b 40 48             	mov    0x48(%eax),%eax
  801571:	83 ec 04             	sub    $0x4,%esp
  801574:	53                   	push   %ebx
  801575:	50                   	push   %eax
  801576:	68 c9 2e 80 00       	push   $0x802ec9
  80157b:	e8 31 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801588:	eb 26                	jmp    8015b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158d:	8b 52 0c             	mov    0xc(%edx),%edx
  801590:	85 d2                	test   %edx,%edx
  801592:	74 17                	je     8015ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	ff 75 10             	pushl  0x10(%ebp)
  80159a:	ff 75 0c             	pushl  0xc(%ebp)
  80159d:	50                   	push   %eax
  80159e:	ff d2                	call   *%edx
  8015a0:	89 c2                	mov    %eax,%edx
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	eb 09                	jmp    8015b0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	eb 05                	jmp    8015b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b0:	89 d0                	mov    %edx,%eax
  8015b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	ff 75 08             	pushl  0x8(%ebp)
  8015c4:	e8 22 fc ff ff       	call   8011eb <fd_lookup>
  8015c9:	83 c4 08             	add    $0x8,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 0e                	js     8015de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015de:	c9                   	leave  
  8015df:	c3                   	ret    

008015e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 14             	sub    $0x14,%esp
  8015e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	53                   	push   %ebx
  8015ef:	e8 f7 fb ff ff       	call   8011eb <fd_lookup>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	89 c2                	mov    %eax,%edx
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 65                	js     801662 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801607:	ff 30                	pushl  (%eax)
  801609:	e8 33 fc ff ff       	call   801241 <dev_lookup>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 44                	js     801659 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801618:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161c:	75 21                	jne    80163f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80161e:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801623:	8b 40 48             	mov    0x48(%eax),%eax
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	53                   	push   %ebx
  80162a:	50                   	push   %eax
  80162b:	68 8c 2e 80 00       	push   $0x802e8c
  801630:	e8 7c ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163d:	eb 23                	jmp    801662 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801642:	8b 52 18             	mov    0x18(%edx),%edx
  801645:	85 d2                	test   %edx,%edx
  801647:	74 14                	je     80165d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	ff 75 0c             	pushl  0xc(%ebp)
  80164f:	50                   	push   %eax
  801650:	ff d2                	call   *%edx
  801652:	89 c2                	mov    %eax,%edx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	eb 09                	jmp    801662 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801659:	89 c2                	mov    %eax,%edx
  80165b:	eb 05                	jmp    801662 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80165d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801662:	89 d0                	mov    %edx,%eax
  801664:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	53                   	push   %ebx
  80166d:	83 ec 14             	sub    $0x14,%esp
  801670:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801673:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801676:	50                   	push   %eax
  801677:	ff 75 08             	pushl  0x8(%ebp)
  80167a:	e8 6c fb ff ff       	call   8011eb <fd_lookup>
  80167f:	83 c4 08             	add    $0x8,%esp
  801682:	89 c2                	mov    %eax,%edx
  801684:	85 c0                	test   %eax,%eax
  801686:	78 58                	js     8016e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801692:	ff 30                	pushl  (%eax)
  801694:	e8 a8 fb ff ff       	call   801241 <dev_lookup>
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 37                	js     8016d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a7:	74 32                	je     8016db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b3:	00 00 00 
	stat->st_isdir = 0;
  8016b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016bd:	00 00 00 
	stat->st_dev = dev;
  8016c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	53                   	push   %ebx
  8016ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8016cd:	ff 50 14             	call   *0x14(%eax)
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	eb 09                	jmp    8016e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	eb 05                	jmp    8016e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e0:	89 d0                	mov    %edx,%eax
  8016e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	6a 00                	push   $0x0
  8016f1:	ff 75 08             	pushl  0x8(%ebp)
  8016f4:	e8 d6 01 00 00       	call   8018cf <open>
  8016f9:	89 c3                	mov    %eax,%ebx
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 1b                	js     80171d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801702:	83 ec 08             	sub    $0x8,%esp
  801705:	ff 75 0c             	pushl  0xc(%ebp)
  801708:	50                   	push   %eax
  801709:	e8 5b ff ff ff       	call   801669 <fstat>
  80170e:	89 c6                	mov    %eax,%esi
	close(fd);
  801710:	89 1c 24             	mov    %ebx,(%esp)
  801713:	e8 fd fb ff ff       	call   801315 <close>
	return r;
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	89 f0                	mov    %esi,%eax
}
  80171d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801720:	5b                   	pop    %ebx
  801721:	5e                   	pop    %esi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	89 c6                	mov    %eax,%esi
  80172b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80172d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801734:	75 12                	jne    801748 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801736:	83 ec 0c             	sub    $0xc,%esp
  801739:	6a 01                	push   $0x1
  80173b:	e8 8f 0e 00 00       	call   8025cf <ipc_find_env>
  801740:	a3 00 50 80 00       	mov    %eax,0x805000
  801745:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801748:	6a 07                	push   $0x7
  80174a:	68 00 60 80 00       	push   $0x806000
  80174f:	56                   	push   %esi
  801750:	ff 35 00 50 80 00    	pushl  0x805000
  801756:	e8 20 0e 00 00       	call   80257b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175b:	83 c4 0c             	add    $0xc,%esp
  80175e:	6a 00                	push   $0x0
  801760:	53                   	push   %ebx
  801761:	6a 00                	push   $0x0
  801763:	e8 7b 0d 00 00       	call   8024e3 <ipc_recv>
}
  801768:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801775:	8b 45 08             	mov    0x8(%ebp),%eax
  801778:	8b 40 0c             	mov    0xc(%eax),%eax
  80177b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801780:	8b 45 0c             	mov    0xc(%ebp),%eax
  801783:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
  80178d:	b8 02 00 00 00       	mov    $0x2,%eax
  801792:	e8 8d ff ff ff       	call   801724 <fsipc>
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a5:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017af:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b4:	e8 6b ff ff ff       	call   801724 <fsipc>
}
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    

008017bb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	53                   	push   %ebx
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cb:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017da:	e8 45 ff ff ff       	call   801724 <fsipc>
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 2c                	js     80180f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	68 00 60 80 00       	push   $0x806000
  8017eb:	53                   	push   %ebx
  8017ec:	e8 45 f0 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f1:	a1 80 60 80 00       	mov    0x806080,%eax
  8017f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fc:	a1 84 60 80 00       	mov    0x806084,%eax
  801801:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 0c             	sub    $0xc,%esp
  80181a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80181d:	8b 55 08             	mov    0x8(%ebp),%edx
  801820:	8b 52 0c             	mov    0xc(%edx),%edx
  801823:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801829:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  80182e:	50                   	push   %eax
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	68 08 60 80 00       	push   $0x806008
  801837:	e8 8c f1 ff ff       	call   8009c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 04 00 00 00       	mov    $0x4,%eax
  801846:	e8 d9 fe ff ff       	call   801724 <fsipc>
	//panic("devfile_write not implemented");
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
  801852:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	8b 40 0c             	mov    0xc(%eax),%eax
  80185b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801860:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801866:	ba 00 00 00 00       	mov    $0x0,%edx
  80186b:	b8 03 00 00 00       	mov    $0x3,%eax
  801870:	e8 af fe ff ff       	call   801724 <fsipc>
  801875:	89 c3                	mov    %eax,%ebx
  801877:	85 c0                	test   %eax,%eax
  801879:	78 4b                	js     8018c6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80187b:	39 c6                	cmp    %eax,%esi
  80187d:	73 16                	jae    801895 <devfile_read+0x48>
  80187f:	68 f8 2e 80 00       	push   $0x802ef8
  801884:	68 ff 2e 80 00       	push   $0x802eff
  801889:	6a 7c                	push   $0x7c
  80188b:	68 14 2f 80 00       	push   $0x802f14
  801890:	e8 43 e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801895:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80189a:	7e 16                	jle    8018b2 <devfile_read+0x65>
  80189c:	68 1f 2f 80 00       	push   $0x802f1f
  8018a1:	68 ff 2e 80 00       	push   $0x802eff
  8018a6:	6a 7d                	push   $0x7d
  8018a8:	68 14 2f 80 00       	push   $0x802f14
  8018ad:	e8 26 e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	50                   	push   %eax
  8018b6:	68 00 60 80 00       	push   $0x806000
  8018bb:	ff 75 0c             	pushl  0xc(%ebp)
  8018be:	e8 05 f1 ff ff       	call   8009c8 <memmove>
	return r;
  8018c3:	83 c4 10             	add    $0x10,%esp
}
  8018c6:	89 d8                	mov    %ebx,%eax
  8018c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 20             	sub    $0x20,%esp
  8018d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d9:	53                   	push   %ebx
  8018da:	e8 1e ef ff ff       	call   8007fd <strlen>
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e7:	7f 67                	jg     801950 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ef:	50                   	push   %eax
  8018f0:	e8 a7 f8 ff ff       	call   80119c <fd_alloc>
  8018f5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 57                	js     801955 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	53                   	push   %ebx
  801902:	68 00 60 80 00       	push   $0x806000
  801907:	e8 2a ef ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80190c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801914:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801917:	b8 01 00 00 00       	mov    $0x1,%eax
  80191c:	e8 03 fe ff ff       	call   801724 <fsipc>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	79 14                	jns    80193e <open+0x6f>
		fd_close(fd, 0);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	6a 00                	push   $0x0
  80192f:	ff 75 f4             	pushl  -0xc(%ebp)
  801932:	e8 5d f9 ff ff       	call   801294 <fd_close>
		return r;
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	89 da                	mov    %ebx,%edx
  80193c:	eb 17                	jmp    801955 <open+0x86>
	}

	return fd2num(fd);
  80193e:	83 ec 0c             	sub    $0xc,%esp
  801941:	ff 75 f4             	pushl  -0xc(%ebp)
  801944:	e8 2c f8 ff ff       	call   801175 <fd2num>
  801949:	89 c2                	mov    %eax,%edx
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	eb 05                	jmp    801955 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801950:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801955:	89 d0                	mov    %edx,%eax
  801957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801962:	ba 00 00 00 00       	mov    $0x0,%edx
  801967:	b8 08 00 00 00       	mov    $0x8,%eax
  80196c:	e8 b3 fd ff ff       	call   801724 <fsipc>
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	57                   	push   %edi
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80197f:	6a 00                	push   $0x0
  801981:	ff 75 08             	pushl  0x8(%ebp)
  801984:	e8 46 ff ff ff       	call   8018cf <open>
  801989:	89 c7                	mov    %eax,%edi
  80198b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 c0                	test   %eax,%eax
  801996:	0f 88 a4 04 00 00    	js     801e40 <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80199c:	83 ec 04             	sub    $0x4,%esp
  80199f:	68 00 02 00 00       	push   $0x200
  8019a4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	57                   	push   %edi
  8019ac:	e8 31 fb ff ff       	call   8014e2 <readn>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019b9:	75 0c                	jne    8019c7 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019bb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019c2:	45 4c 46 
  8019c5:	74 33                	je     8019fa <spawn+0x87>
		close(fd);
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019d0:	e8 40 f9 ff ff       	call   801315 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019d5:	83 c4 0c             	add    $0xc,%esp
  8019d8:	68 7f 45 4c 46       	push   $0x464c457f
  8019dd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8019e3:	68 2b 2f 80 00       	push   $0x802f2b
  8019e8:	e8 c4 e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8019f5:	e9 a6 04 00 00       	jmp    801ea0 <spawn+0x52d>
  8019fa:	b8 07 00 00 00       	mov    $0x7,%eax
  8019ff:	cd 30                	int    $0x30
  801a01:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a07:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	0f 88 33 04 00 00    	js     801e48 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a15:	89 c6                	mov    %eax,%esi
  801a17:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a1d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a20:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a26:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a2c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a33:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a39:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a3f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a44:	be 00 00 00 00       	mov    $0x0,%esi
  801a49:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a4c:	eb 13                	jmp    801a61 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	50                   	push   %eax
  801a52:	e8 a6 ed ff ff       	call   8007fd <strlen>
  801a57:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a5b:	83 c3 01             	add    $0x1,%ebx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a68:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	75 df                	jne    801a4e <spawn+0xdb>
  801a6f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a75:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a7b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a80:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a82:	89 fa                	mov    %edi,%edx
  801a84:	83 e2 fc             	and    $0xfffffffc,%edx
  801a87:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a8e:	29 c2                	sub    %eax,%edx
  801a90:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a96:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a99:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a9e:	0f 86 b4 03 00 00    	jbe    801e58 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aa4:	83 ec 04             	sub    $0x4,%esp
  801aa7:	6a 07                	push   $0x7
  801aa9:	68 00 00 40 00       	push   $0x400000
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 84 f1 ff ff       	call   800c39 <sys_page_alloc>
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	0f 88 9f 03 00 00    	js     801e5f <spawn+0x4ec>
  801ac0:	be 00 00 00 00       	mov    $0x0,%esi
  801ac5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801acb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ace:	eb 30                	jmp    801b00 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ad0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ad6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801adc:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ae5:	57                   	push   %edi
  801ae6:	e8 4b ed ff ff       	call   800836 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801aeb:	83 c4 04             	add    $0x4,%esp
  801aee:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801af1:	e8 07 ed ff ff       	call   8007fd <strlen>
  801af6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801afa:	83 c6 01             	add    $0x1,%esi
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b06:	7f c8                	jg     801ad0 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b08:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b0e:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b14:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b1b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b21:	74 19                	je     801b3c <spawn+0x1c9>
  801b23:	68 a0 2f 80 00       	push   $0x802fa0
  801b28:	68 ff 2e 80 00       	push   $0x802eff
  801b2d:	68 f1 00 00 00       	push   $0xf1
  801b32:	68 45 2f 80 00       	push   $0x802f45
  801b37:	e8 9c e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b3c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b42:	89 f8                	mov    %edi,%eax
  801b44:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b49:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b4c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b52:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b55:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b5b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	6a 07                	push   $0x7
  801b66:	68 00 d0 bf ee       	push   $0xeebfd000
  801b6b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b71:	68 00 00 40 00       	push   $0x400000
  801b76:	6a 00                	push   $0x0
  801b78:	e8 ff f0 ff ff       	call   800c7c <sys_page_map>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	83 c4 20             	add    $0x20,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	0f 88 04 03 00 00    	js     801e8e <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b8a:	83 ec 08             	sub    $0x8,%esp
  801b8d:	68 00 00 40 00       	push   $0x400000
  801b92:	6a 00                	push   $0x0
  801b94:	e8 25 f1 ff ff       	call   800cbe <sys_page_unmap>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 e8 02 00 00    	js     801e8e <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ba6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bac:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bb3:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bb9:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bc0:	00 00 00 
  801bc3:	e9 88 01 00 00       	jmp    801d50 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801bc8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801bce:	83 38 01             	cmpl   $0x1,(%eax)
  801bd1:	0f 85 6b 01 00 00    	jne    801d42 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bd7:	89 c7                	mov    %eax,%edi
  801bd9:	8b 40 18             	mov    0x18(%eax),%eax
  801bdc:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801be2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801be5:	83 f8 01             	cmp    $0x1,%eax
  801be8:	19 c0                	sbb    %eax,%eax
  801bea:	83 e0 fe             	and    $0xfffffffe,%eax
  801bed:	83 c0 07             	add    $0x7,%eax
  801bf0:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bf6:	89 f8                	mov    %edi,%eax
  801bf8:	8b 7f 04             	mov    0x4(%edi),%edi
  801bfb:	89 f9                	mov    %edi,%ecx
  801bfd:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c03:	8b 78 10             	mov    0x10(%eax),%edi
  801c06:	8b 50 14             	mov    0x14(%eax),%edx
  801c09:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801c0f:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c12:	89 f0                	mov    %esi,%eax
  801c14:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c19:	74 14                	je     801c2f <spawn+0x2bc>
		va -= i;
  801c1b:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c1d:	01 c2                	add    %eax,%edx
  801c1f:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c25:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c27:	29 c1                	sub    %eax,%ecx
  801c29:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c34:	e9 f7 00 00 00       	jmp    801d30 <spawn+0x3bd>
		if (i >= filesz) {
  801c39:	39 df                	cmp    %ebx,%edi
  801c3b:	77 27                	ja     801c64 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c3d:	83 ec 04             	sub    $0x4,%esp
  801c40:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c46:	56                   	push   %esi
  801c47:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c4d:	e8 e7 ef ff ff       	call   800c39 <sys_page_alloc>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	0f 89 c7 00 00 00    	jns    801d24 <spawn+0x3b1>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	e9 09 02 00 00       	jmp    801e6d <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c64:	83 ec 04             	sub    $0x4,%esp
  801c67:	6a 07                	push   $0x7
  801c69:	68 00 00 40 00       	push   $0x400000
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 c4 ef ff ff       	call   800c39 <sys_page_alloc>
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	0f 88 e3 01 00 00    	js     801e63 <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c80:	83 ec 08             	sub    $0x8,%esp
  801c83:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c89:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c96:	e8 1c f9 ff ff       	call   8015b7 <seek>
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	0f 88 c1 01 00 00    	js     801e67 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	89 f8                	mov    %edi,%eax
  801cab:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cb1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cb6:	ba 00 10 00 00       	mov    $0x1000,%edx
  801cbb:	0f 47 c2             	cmova  %edx,%eax
  801cbe:	50                   	push   %eax
  801cbf:	68 00 00 40 00       	push   $0x400000
  801cc4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cca:	e8 13 f8 ff ff       	call   8014e2 <readn>
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 91 01 00 00    	js     801e6b <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ce3:	56                   	push   %esi
  801ce4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cea:	68 00 00 40 00       	push   $0x400000
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 86 ef ff ff       	call   800c7c <sys_page_map>
  801cf6:	83 c4 20             	add    $0x20,%esp
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	79 15                	jns    801d12 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801cfd:	50                   	push   %eax
  801cfe:	68 51 2f 80 00       	push   $0x802f51
  801d03:	68 24 01 00 00       	push   $0x124
  801d08:	68 45 2f 80 00       	push   $0x802f45
  801d0d:	e8 c6 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801d12:	83 ec 08             	sub    $0x8,%esp
  801d15:	68 00 00 40 00       	push   $0x400000
  801d1a:	6a 00                	push   $0x0
  801d1c:	e8 9d ef ff ff       	call   800cbe <sys_page_unmap>
  801d21:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d24:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d2a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d30:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d36:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d3c:	0f 87 f7 fe ff ff    	ja     801c39 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d42:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d49:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d50:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d57:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d5d:	0f 8c 65 fe ff ff    	jl     801bc8 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d6c:	e8 a4 f5 ff ff       	call   801315 <close>
  801d71:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d79:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801d7f:	89 d8                	mov    %ebx,%eax
  801d81:	c1 e8 16             	shr    $0x16,%eax
  801d84:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d8b:	a8 01                	test   $0x1,%al
  801d8d:	74 46                	je     801dd5 <spawn+0x462>
  801d8f:	89 d8                	mov    %ebx,%eax
  801d91:	c1 e8 0c             	shr    $0xc,%eax
  801d94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d9b:	f6 c2 01             	test   $0x1,%dl
  801d9e:	74 35                	je     801dd5 <spawn+0x462>
			(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801da0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801da7:	f6 c2 04             	test   $0x4,%dl
  801daa:	74 29                	je     801dd5 <spawn+0x462>
			(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801dac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801db3:	f6 c6 04             	test   $0x4,%dh
  801db6:	74 1d                	je     801dd5 <spawn+0x462>
			sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801db8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	25 07 0e 00 00       	and    $0xe07,%eax
  801dc7:	50                   	push   %eax
  801dc8:	53                   	push   %ebx
  801dc9:	56                   	push   %esi
  801dca:	53                   	push   %ebx
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 aa ee ff ff       	call   800c7c <sys_page_map>
  801dd2:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801dd5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ddb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801de1:	75 9c                	jne    801d7f <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dec:	50                   	push   %eax
  801ded:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801df3:	e8 4a ef ff ff       	call   800d42 <sys_env_set_trapframe>
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	79 15                	jns    801e14 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  801dff:	50                   	push   %eax
  801e00:	68 6e 2f 80 00       	push   $0x802f6e
  801e05:	68 85 00 00 00       	push   $0x85
  801e0a:	68 45 2f 80 00       	push   $0x802f45
  801e0f:	e8 c4 e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e14:	83 ec 08             	sub    $0x8,%esp
  801e17:	6a 02                	push   $0x2
  801e19:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e1f:	e8 dc ee ff ff       	call   800d00 <sys_env_set_status>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	79 25                	jns    801e50 <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  801e2b:	50                   	push   %eax
  801e2c:	68 88 2f 80 00       	push   $0x802f88
  801e31:	68 88 00 00 00       	push   $0x88
  801e36:	68 45 2f 80 00       	push   $0x802f45
  801e3b:	e8 98 e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e40:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e46:	eb 58                	jmp    801ea0 <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e48:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e4e:	eb 50                	jmp    801ea0 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e50:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e56:	eb 48                	jmp    801ea0 <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e58:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e5d:	eb 41                	jmp    801ea0 <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	eb 3d                	jmp    801ea0 <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	eb 06                	jmp    801e6d <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	eb 02                	jmp    801e6d <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e6b:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e6d:	83 ec 0c             	sub    $0xc,%esp
  801e70:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e76:	e8 3f ed ff ff       	call   800bba <sys_env_destroy>
	close(fd);
  801e7b:	83 c4 04             	add    $0x4,%esp
  801e7e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e84:	e8 8c f4 ff ff       	call   801315 <close>
	return r;
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	eb 12                	jmp    801ea0 <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e8e:	83 ec 08             	sub    $0x8,%esp
  801e91:	68 00 00 40 00       	push   $0x400000
  801e96:	6a 00                	push   $0x0
  801e98:	e8 21 ee ff ff       	call   800cbe <sys_page_unmap>
  801e9d:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ea0:	89 d8                	mov    %ebx,%eax
  801ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	56                   	push   %esi
  801eae:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eaf:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801eb7:	eb 03                	jmp    801ebc <spawnl+0x12>
		argc++;
  801eb9:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ebc:	83 c2 04             	add    $0x4,%edx
  801ebf:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ec3:	75 f4                	jne    801eb9 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ec5:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ecc:	83 e2 f0             	and    $0xfffffff0,%edx
  801ecf:	29 d4                	sub    %edx,%esp
  801ed1:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ed5:	c1 ea 02             	shr    $0x2,%edx
  801ed8:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801edf:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ee1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee4:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801eeb:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ef2:	00 
  801ef3:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  801efa:	eb 0a                	jmp    801f06 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801efc:	83 c0 01             	add    $0x1,%eax
  801eff:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f03:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f06:	39 d0                	cmp    %edx,%eax
  801f08:	75 f2                	jne    801efc <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f0a:	83 ec 08             	sub    $0x8,%esp
  801f0d:	56                   	push   %esi
  801f0e:	ff 75 08             	pushl  0x8(%ebp)
  801f11:	e8 5d fa ff ff       	call   801973 <spawn>
}
  801f16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
  801f22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	ff 75 08             	pushl  0x8(%ebp)
  801f2b:	e8 55 f2 ff ff       	call   801185 <fd2data>
  801f30:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f32:	83 c4 08             	add    $0x8,%esp
  801f35:	68 c6 2f 80 00       	push   $0x802fc6
  801f3a:	53                   	push   %ebx
  801f3b:	e8 f6 e8 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f40:	8b 46 04             	mov    0x4(%esi),%eax
  801f43:	2b 06                	sub    (%esi),%eax
  801f45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f4b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f52:	00 00 00 
	stat->st_dev = &devpipe;
  801f55:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  801f5c:	40 80 00 
	return 0;
}
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    

00801f6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	53                   	push   %ebx
  801f6f:	83 ec 0c             	sub    $0xc,%esp
  801f72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f75:	53                   	push   %ebx
  801f76:	6a 00                	push   $0x0
  801f78:	e8 41 ed ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f7d:	89 1c 24             	mov    %ebx,(%esp)
  801f80:	e8 00 f2 ff ff       	call   801185 <fd2data>
  801f85:	83 c4 08             	add    $0x8,%esp
  801f88:	50                   	push   %eax
  801f89:	6a 00                	push   $0x0
  801f8b:	e8 2e ed ff ff       	call   800cbe <sys_page_unmap>
}
  801f90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 1c             	sub    $0x1c,%esp
  801f9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fa1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fa3:	a1 04 50 80 00       	mov    0x805004,%eax
  801fa8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	ff 75 e0             	pushl  -0x20(%ebp)
  801fb1:	e8 52 06 00 00       	call   802608 <pageref>
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	89 3c 24             	mov    %edi,(%esp)
  801fbb:	e8 48 06 00 00       	call   802608 <pageref>
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	39 c3                	cmp    %eax,%ebx
  801fc5:	0f 94 c1             	sete   %cl
  801fc8:	0f b6 c9             	movzbl %cl,%ecx
  801fcb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fce:	8b 15 04 50 80 00    	mov    0x805004,%edx
  801fd4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fd7:	39 ce                	cmp    %ecx,%esi
  801fd9:	74 1b                	je     801ff6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fdb:	39 c3                	cmp    %eax,%ebx
  801fdd:	75 c4                	jne    801fa3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fdf:	8b 42 58             	mov    0x58(%edx),%eax
  801fe2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fe5:	50                   	push   %eax
  801fe6:	56                   	push   %esi
  801fe7:	68 cd 2f 80 00       	push   $0x802fcd
  801fec:	e8 c0 e2 ff ff       	call   8002b1 <cprintf>
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	eb ad                	jmp    801fa3 <_pipeisclosed+0xe>
	}
}
  801ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5e                   	pop    %esi
  801ffe:	5f                   	pop    %edi
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    

00802001 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	57                   	push   %edi
  802005:	56                   	push   %esi
  802006:	53                   	push   %ebx
  802007:	83 ec 28             	sub    $0x28,%esp
  80200a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80200d:	56                   	push   %esi
  80200e:	e8 72 f1 ff ff       	call   801185 <fd2data>
  802013:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	bf 00 00 00 00       	mov    $0x0,%edi
  80201d:	eb 4b                	jmp    80206a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80201f:	89 da                	mov    %ebx,%edx
  802021:	89 f0                	mov    %esi,%eax
  802023:	e8 6d ff ff ff       	call   801f95 <_pipeisclosed>
  802028:	85 c0                	test   %eax,%eax
  80202a:	75 48                	jne    802074 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80202c:	e8 e9 eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802031:	8b 43 04             	mov    0x4(%ebx),%eax
  802034:	8b 0b                	mov    (%ebx),%ecx
  802036:	8d 51 20             	lea    0x20(%ecx),%edx
  802039:	39 d0                	cmp    %edx,%eax
  80203b:	73 e2                	jae    80201f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80203d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802040:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802044:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802047:	89 c2                	mov    %eax,%edx
  802049:	c1 fa 1f             	sar    $0x1f,%edx
  80204c:	89 d1                	mov    %edx,%ecx
  80204e:	c1 e9 1b             	shr    $0x1b,%ecx
  802051:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802054:	83 e2 1f             	and    $0x1f,%edx
  802057:	29 ca                	sub    %ecx,%edx
  802059:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80205d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802061:	83 c0 01             	add    $0x1,%eax
  802064:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802067:	83 c7 01             	add    $0x1,%edi
  80206a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80206d:	75 c2                	jne    802031 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80206f:	8b 45 10             	mov    0x10(%ebp),%eax
  802072:	eb 05                	jmp    802079 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5e                   	pop    %esi
  80207e:	5f                   	pop    %edi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    

00802081 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	57                   	push   %edi
  802085:	56                   	push   %esi
  802086:	53                   	push   %ebx
  802087:	83 ec 18             	sub    $0x18,%esp
  80208a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80208d:	57                   	push   %edi
  80208e:	e8 f2 f0 ff ff       	call   801185 <fd2data>
  802093:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	bb 00 00 00 00       	mov    $0x0,%ebx
  80209d:	eb 3d                	jmp    8020dc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80209f:	85 db                	test   %ebx,%ebx
  8020a1:	74 04                	je     8020a7 <devpipe_read+0x26>
				return i;
  8020a3:	89 d8                	mov    %ebx,%eax
  8020a5:	eb 44                	jmp    8020eb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020a7:	89 f2                	mov    %esi,%edx
  8020a9:	89 f8                	mov    %edi,%eax
  8020ab:	e8 e5 fe ff ff       	call   801f95 <_pipeisclosed>
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	75 32                	jne    8020e6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020b4:	e8 61 eb ff ff       	call   800c1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020b9:	8b 06                	mov    (%esi),%eax
  8020bb:	3b 46 04             	cmp    0x4(%esi),%eax
  8020be:	74 df                	je     80209f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020c0:	99                   	cltd   
  8020c1:	c1 ea 1b             	shr    $0x1b,%edx
  8020c4:	01 d0                	add    %edx,%eax
  8020c6:	83 e0 1f             	and    $0x1f,%eax
  8020c9:	29 d0                	sub    %edx,%eax
  8020cb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020d6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d9:	83 c3 01             	add    $0x1,%ebx
  8020dc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020df:	75 d8                	jne    8020b9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e4:	eb 05                	jmp    8020eb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ee:	5b                   	pop    %ebx
  8020ef:	5e                   	pop    %esi
  8020f0:	5f                   	pop    %edi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fe:	50                   	push   %eax
  8020ff:	e8 98 f0 ff ff       	call   80119c <fd_alloc>
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	89 c2                	mov    %eax,%edx
  802109:	85 c0                	test   %eax,%eax
  80210b:	0f 88 2c 01 00 00    	js     80223d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802111:	83 ec 04             	sub    $0x4,%esp
  802114:	68 07 04 00 00       	push   $0x407
  802119:	ff 75 f4             	pushl  -0xc(%ebp)
  80211c:	6a 00                	push   $0x0
  80211e:	e8 16 eb ff ff       	call   800c39 <sys_page_alloc>
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	89 c2                	mov    %eax,%edx
  802128:	85 c0                	test   %eax,%eax
  80212a:	0f 88 0d 01 00 00    	js     80223d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802130:	83 ec 0c             	sub    $0xc,%esp
  802133:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802136:	50                   	push   %eax
  802137:	e8 60 f0 ff ff       	call   80119c <fd_alloc>
  80213c:	89 c3                	mov    %eax,%ebx
  80213e:	83 c4 10             	add    $0x10,%esp
  802141:	85 c0                	test   %eax,%eax
  802143:	0f 88 e2 00 00 00    	js     80222b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802149:	83 ec 04             	sub    $0x4,%esp
  80214c:	68 07 04 00 00       	push   $0x407
  802151:	ff 75 f0             	pushl  -0x10(%ebp)
  802154:	6a 00                	push   $0x0
  802156:	e8 de ea ff ff       	call   800c39 <sys_page_alloc>
  80215b:	89 c3                	mov    %eax,%ebx
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	85 c0                	test   %eax,%eax
  802162:	0f 88 c3 00 00 00    	js     80222b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802168:	83 ec 0c             	sub    $0xc,%esp
  80216b:	ff 75 f4             	pushl  -0xc(%ebp)
  80216e:	e8 12 f0 ff ff       	call   801185 <fd2data>
  802173:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802175:	83 c4 0c             	add    $0xc,%esp
  802178:	68 07 04 00 00       	push   $0x407
  80217d:	50                   	push   %eax
  80217e:	6a 00                	push   $0x0
  802180:	e8 b4 ea ff ff       	call   800c39 <sys_page_alloc>
  802185:	89 c3                	mov    %eax,%ebx
  802187:	83 c4 10             	add    $0x10,%esp
  80218a:	85 c0                	test   %eax,%eax
  80218c:	0f 88 89 00 00 00    	js     80221b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802192:	83 ec 0c             	sub    $0xc,%esp
  802195:	ff 75 f0             	pushl  -0x10(%ebp)
  802198:	e8 e8 ef ff ff       	call   801185 <fd2data>
  80219d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021a4:	50                   	push   %eax
  8021a5:	6a 00                	push   $0x0
  8021a7:	56                   	push   %esi
  8021a8:	6a 00                	push   $0x0
  8021aa:	e8 cd ea ff ff       	call   800c7c <sys_page_map>
  8021af:	89 c3                	mov    %eax,%ebx
  8021b1:	83 c4 20             	add    $0x20,%esp
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	78 55                	js     80220d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021b8:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8021be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021cd:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8021d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021db:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e8:	e8 88 ef ff ff       	call   801175 <fd2num>
  8021ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021f2:	83 c4 04             	add    $0x4,%esp
  8021f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f8:	e8 78 ef ff ff       	call   801175 <fd2num>
  8021fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802200:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	ba 00 00 00 00       	mov    $0x0,%edx
  80220b:	eb 30                	jmp    80223d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80220d:	83 ec 08             	sub    $0x8,%esp
  802210:	56                   	push   %esi
  802211:	6a 00                	push   $0x0
  802213:	e8 a6 ea ff ff       	call   800cbe <sys_page_unmap>
  802218:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80221b:	83 ec 08             	sub    $0x8,%esp
  80221e:	ff 75 f0             	pushl  -0x10(%ebp)
  802221:	6a 00                	push   $0x0
  802223:	e8 96 ea ff ff       	call   800cbe <sys_page_unmap>
  802228:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80222b:	83 ec 08             	sub    $0x8,%esp
  80222e:	ff 75 f4             	pushl  -0xc(%ebp)
  802231:	6a 00                	push   $0x0
  802233:	e8 86 ea ff ff       	call   800cbe <sys_page_unmap>
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80223d:	89 d0                	mov    %edx,%eax
  80223f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802242:	5b                   	pop    %ebx
  802243:	5e                   	pop    %esi
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    

00802246 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224f:	50                   	push   %eax
  802250:	ff 75 08             	pushl  0x8(%ebp)
  802253:	e8 93 ef ff ff       	call   8011eb <fd_lookup>
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 18                	js     802277 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80225f:	83 ec 0c             	sub    $0xc,%esp
  802262:	ff 75 f4             	pushl  -0xc(%ebp)
  802265:	e8 1b ef ff ff       	call   801185 <fd2data>
	return _pipeisclosed(fd, p);
  80226a:	89 c2                	mov    %eax,%edx
  80226c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226f:	e8 21 fd ff ff       	call   801f95 <_pipeisclosed>
  802274:	83 c4 10             	add    $0x10,%esp
}
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	56                   	push   %esi
  80227d:	53                   	push   %ebx
  80227e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802281:	85 f6                	test   %esi,%esi
  802283:	75 16                	jne    80229b <wait+0x22>
  802285:	68 e5 2f 80 00       	push   $0x802fe5
  80228a:	68 ff 2e 80 00       	push   $0x802eff
  80228f:	6a 09                	push   $0x9
  802291:	68 f0 2f 80 00       	push   $0x802ff0
  802296:	e8 3d df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  80229b:	89 f3                	mov    %esi,%ebx
  80229d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022a3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022a6:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022ac:	eb 05                	jmp    8022b3 <wait+0x3a>
		sys_yield();
  8022ae:	e8 67 e9 ff ff       	call   800c1a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022b3:	8b 43 48             	mov    0x48(%ebx),%eax
  8022b6:	39 c6                	cmp    %eax,%esi
  8022b8:	75 07                	jne    8022c1 <wait+0x48>
  8022ba:	8b 43 54             	mov    0x54(%ebx),%eax
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	75 ed                	jne    8022ae <wait+0x35>
		sys_yield();
}
  8022c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    

008022c8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    

008022d2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022d8:	68 fb 2f 80 00       	push   $0x802ffb
  8022dd:	ff 75 0c             	pushl  0xc(%ebp)
  8022e0:	e8 51 e5 ff ff       	call   800836 <strcpy>
	return 0;
}
  8022e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	57                   	push   %edi
  8022f0:	56                   	push   %esi
  8022f1:	53                   	push   %ebx
  8022f2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022fd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802303:	eb 2d                	jmp    802332 <devcons_write+0x46>
		m = n - tot;
  802305:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802308:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80230a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80230d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802312:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802315:	83 ec 04             	sub    $0x4,%esp
  802318:	53                   	push   %ebx
  802319:	03 45 0c             	add    0xc(%ebp),%eax
  80231c:	50                   	push   %eax
  80231d:	57                   	push   %edi
  80231e:	e8 a5 e6 ff ff       	call   8009c8 <memmove>
		sys_cputs(buf, m);
  802323:	83 c4 08             	add    $0x8,%esp
  802326:	53                   	push   %ebx
  802327:	57                   	push   %edi
  802328:	e8 50 e8 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80232d:	01 de                	add    %ebx,%esi
  80232f:	83 c4 10             	add    $0x10,%esp
  802332:	89 f0                	mov    %esi,%eax
  802334:	3b 75 10             	cmp    0x10(%ebp),%esi
  802337:	72 cc                	jb     802305 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802339:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80233c:	5b                   	pop    %ebx
  80233d:	5e                   	pop    %esi
  80233e:	5f                   	pop    %edi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	83 ec 08             	sub    $0x8,%esp
  802347:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80234c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802350:	74 2a                	je     80237c <devcons_read+0x3b>
  802352:	eb 05                	jmp    802359 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802354:	e8 c1 e8 ff ff       	call   800c1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802359:	e8 3d e8 ff ff       	call   800b9b <sys_cgetc>
  80235e:	85 c0                	test   %eax,%eax
  802360:	74 f2                	je     802354 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802362:	85 c0                	test   %eax,%eax
  802364:	78 16                	js     80237c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802366:	83 f8 04             	cmp    $0x4,%eax
  802369:	74 0c                	je     802377 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80236b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80236e:	88 02                	mov    %al,(%edx)
	return 1;
  802370:	b8 01 00 00 00       	mov    $0x1,%eax
  802375:	eb 05                	jmp    80237c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802377:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80237c:	c9                   	leave  
  80237d:	c3                   	ret    

0080237e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802384:	8b 45 08             	mov    0x8(%ebp),%eax
  802387:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80238a:	6a 01                	push   $0x1
  80238c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80238f:	50                   	push   %eax
  802390:	e8 e8 e7 ff ff       	call   800b7d <sys_cputs>
}
  802395:	83 c4 10             	add    $0x10,%esp
  802398:	c9                   	leave  
  802399:	c3                   	ret    

0080239a <getchar>:

int
getchar(void)
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023a0:	6a 01                	push   $0x1
  8023a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023a5:	50                   	push   %eax
  8023a6:	6a 00                	push   $0x0
  8023a8:	e8 a4 f0 ff ff       	call   801451 <read>
	if (r < 0)
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	78 0f                	js     8023c3 <getchar+0x29>
		return r;
	if (r < 1)
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	7e 06                	jle    8023be <getchar+0x24>
		return -E_EOF;
	return c;
  8023b8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023bc:	eb 05                	jmp    8023c3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023be:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    

008023c5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ce:	50                   	push   %eax
  8023cf:	ff 75 08             	pushl  0x8(%ebp)
  8023d2:	e8 14 ee ff ff       	call   8011eb <fd_lookup>
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 11                	js     8023ef <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e1:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8023e7:	39 10                	cmp    %edx,(%eax)
  8023e9:	0f 94 c0             	sete   %al
  8023ec:	0f b6 c0             	movzbl %al,%eax
}
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <opencons>:

int
opencons(void)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023fa:	50                   	push   %eax
  8023fb:	e8 9c ed ff ff       	call   80119c <fd_alloc>
  802400:	83 c4 10             	add    $0x10,%esp
		return r;
  802403:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802405:	85 c0                	test   %eax,%eax
  802407:	78 3e                	js     802447 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802409:	83 ec 04             	sub    $0x4,%esp
  80240c:	68 07 04 00 00       	push   $0x407
  802411:	ff 75 f4             	pushl  -0xc(%ebp)
  802414:	6a 00                	push   $0x0
  802416:	e8 1e e8 ff ff       	call   800c39 <sys_page_alloc>
  80241b:	83 c4 10             	add    $0x10,%esp
		return r;
  80241e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802420:	85 c0                	test   %eax,%eax
  802422:	78 23                	js     802447 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802424:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80242f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802432:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802439:	83 ec 0c             	sub    $0xc,%esp
  80243c:	50                   	push   %eax
  80243d:	e8 33 ed ff ff       	call   801175 <fd2num>
  802442:	89 c2                	mov    %eax,%edx
  802444:	83 c4 10             	add    $0x10,%esp
}
  802447:	89 d0                	mov    %edx,%eax
  802449:	c9                   	leave  
  80244a:	c3                   	ret    

0080244b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	53                   	push   %ebx
  80244f:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802452:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802459:	75 57                	jne    8024b2 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  80245b:	e8 9b e7 ff ff       	call   800bfb <sys_getenvid>
  802460:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  802462:	83 ec 04             	sub    $0x4,%esp
  802465:	6a 07                	push   $0x7
  802467:	68 00 f0 bf ee       	push   $0xeebff000
  80246c:	50                   	push   %eax
  80246d:	e8 c7 e7 ff ff       	call   800c39 <sys_page_alloc>
		if (r) {
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	85 c0                	test   %eax,%eax
  802477:	74 12                	je     80248b <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  802479:	50                   	push   %eax
  80247a:	68 ba 2d 80 00       	push   $0x802dba
  80247f:	6a 25                	push   $0x25
  802481:	68 07 30 80 00       	push   $0x803007
  802486:	e8 4d dd ff ff       	call   8001d8 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  80248b:	83 ec 08             	sub    $0x8,%esp
  80248e:	68 bf 24 80 00       	push   $0x8024bf
  802493:	53                   	push   %ebx
  802494:	e8 eb e8 ff ff       	call   800d84 <sys_env_set_pgfault_upcall>
		if (r) {
  802499:	83 c4 10             	add    $0x10,%esp
  80249c:	85 c0                	test   %eax,%eax
  80249e:	74 12                	je     8024b2 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  8024a0:	50                   	push   %eax
  8024a1:	68 18 30 80 00       	push   $0x803018
  8024a6:	6a 2b                	push   $0x2b
  8024a8:	68 07 30 80 00       	push   $0x803007
  8024ad:	e8 26 dd ff ff       	call   8001d8 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b5:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8024ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024bd:	c9                   	leave  
  8024be:	c3                   	ret    

008024bf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024bf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024c0:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8024c5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024c7:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  8024ca:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  8024ce:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  8024d3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  8024d7:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  8024d9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  8024dc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  8024dd:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  8024e0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  8024e1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  8024e2:	c3                   	ret    

008024e3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024e3:	55                   	push   %ebp
  8024e4:	89 e5                	mov    %esp,%ebp
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8024eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	74 3e                	je     802533 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  8024f5:	83 ec 0c             	sub    $0xc,%esp
  8024f8:	50                   	push   %eax
  8024f9:	e8 eb e8 ff ff       	call   800de9 <sys_ipc_recv>
  8024fe:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  802500:	83 c4 10             	add    $0x10,%esp
  802503:	85 f6                	test   %esi,%esi
  802505:	74 13                	je     80251a <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
  80250c:	85 d2                	test   %edx,%edx
  80250e:	75 08                	jne    802518 <ipc_recv+0x35>
  802510:	a1 04 50 80 00       	mov    0x805004,%eax
  802515:	8b 40 74             	mov    0x74(%eax),%eax
  802518:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80251a:	85 db                	test   %ebx,%ebx
  80251c:	74 48                	je     802566 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  80251e:	b8 00 00 00 00       	mov    $0x0,%eax
  802523:	85 d2                	test   %edx,%edx
  802525:	75 08                	jne    80252f <ipc_recv+0x4c>
  802527:	a1 04 50 80 00       	mov    0x805004,%eax
  80252c:	8b 40 78             	mov    0x78(%eax),%eax
  80252f:	89 03                	mov    %eax,(%ebx)
  802531:	eb 33                	jmp    802566 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  802533:	83 ec 0c             	sub    $0xc,%esp
  802536:	68 00 00 c0 ee       	push   $0xeec00000
  80253b:	e8 a9 e8 ff ff       	call   800de9 <sys_ipc_recv>
  802540:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  802542:	83 c4 10             	add    $0x10,%esp
  802545:	85 f6                	test   %esi,%esi
  802547:	74 13                	je     80255c <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802549:	b8 00 00 00 00       	mov    $0x0,%eax
  80254e:	85 d2                	test   %edx,%edx
  802550:	75 08                	jne    80255a <ipc_recv+0x77>
  802552:	a1 04 50 80 00       	mov    0x805004,%eax
  802557:	8b 40 74             	mov    0x74(%eax),%eax
  80255a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80255c:	85 db                	test   %ebx,%ebx
  80255e:	74 06                	je     802566 <ipc_recv+0x83>
			*perm_store = 0;
  802560:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  802566:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  802568:	85 d2                	test   %edx,%edx
  80256a:	75 08                	jne    802574 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  80256c:	a1 04 50 80 00       	mov    0x805004,%eax
  802571:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  802574:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802577:	5b                   	pop    %ebx
  802578:	5e                   	pop    %esi
  802579:	5d                   	pop    %ebp
  80257a:	c3                   	ret    

0080257b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80257b:	55                   	push   %ebp
  80257c:	89 e5                	mov    %esp,%ebp
  80257e:	57                   	push   %edi
  80257f:	56                   	push   %esi
  802580:	53                   	push   %ebx
  802581:	83 ec 0c             	sub    $0xc,%esp
  802584:	8b 7d 08             	mov    0x8(%ebp),%edi
  802587:	8b 75 0c             	mov    0xc(%ebp),%esi
  80258a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80258d:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  80258f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802594:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802597:	eb 1c                	jmp    8025b5 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  802599:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80259c:	74 12                	je     8025b0 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  80259e:	50                   	push   %eax
  80259f:	68 40 30 80 00       	push   $0x803040
  8025a4:	6a 4f                	push   $0x4f
  8025a6:	68 5b 30 80 00       	push   $0x80305b
  8025ab:	e8 28 dc ff ff       	call   8001d8 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  8025b0:	e8 65 e6 ff ff       	call   800c1a <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8025b5:	ff 75 14             	pushl  0x14(%ebp)
  8025b8:	53                   	push   %ebx
  8025b9:	56                   	push   %esi
  8025ba:	57                   	push   %edi
  8025bb:	e8 06 e8 ff ff       	call   800dc6 <sys_ipc_try_send>
  8025c0:	83 c4 10             	add    $0x10,%esp
  8025c3:	85 c0                	test   %eax,%eax
  8025c5:	78 d2                	js     802599 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8025c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ca:	5b                   	pop    %ebx
  8025cb:	5e                   	pop    %esi
  8025cc:	5f                   	pop    %edi
  8025cd:	5d                   	pop    %ebp
  8025ce:	c3                   	ret    

008025cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025cf:	55                   	push   %ebp
  8025d0:	89 e5                	mov    %esp,%ebp
  8025d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025da:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025dd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025e3:	8b 52 50             	mov    0x50(%edx),%edx
  8025e6:	39 ca                	cmp    %ecx,%edx
  8025e8:	75 0d                	jne    8025f7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025f2:	8b 40 48             	mov    0x48(%eax),%eax
  8025f5:	eb 0f                	jmp    802606 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025f7:	83 c0 01             	add    $0x1,%eax
  8025fa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025ff:	75 d9                	jne    8025da <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802601:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    

00802608 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802608:	55                   	push   %ebp
  802609:	89 e5                	mov    %esp,%ebp
  80260b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80260e:	89 d0                	mov    %edx,%eax
  802610:	c1 e8 16             	shr    $0x16,%eax
  802613:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80261a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80261f:	f6 c1 01             	test   $0x1,%cl
  802622:	74 1d                	je     802641 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802624:	c1 ea 0c             	shr    $0xc,%edx
  802627:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80262e:	f6 c2 01             	test   $0x1,%dl
  802631:	74 0e                	je     802641 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802633:	c1 ea 0c             	shr    $0xc,%edx
  802636:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80263d:	ef 
  80263e:	0f b7 c0             	movzwl %ax,%eax
}
  802641:	5d                   	pop    %ebp
  802642:	c3                   	ret    
  802643:	66 90                	xchg   %ax,%ax
  802645:	66 90                	xchg   %ax,%ax
  802647:	66 90                	xchg   %ax,%ax
  802649:	66 90                	xchg   %ax,%ax
  80264b:	66 90                	xchg   %ax,%ax
  80264d:	66 90                	xchg   %ax,%ax
  80264f:	90                   	nop

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80265b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80265f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 f6                	test   %esi,%esi
  802669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80266d:	89 ca                	mov    %ecx,%edx
  80266f:	89 f8                	mov    %edi,%eax
  802671:	75 3d                	jne    8026b0 <__udivdi3+0x60>
  802673:	39 cf                	cmp    %ecx,%edi
  802675:	0f 87 c5 00 00 00    	ja     802740 <__udivdi3+0xf0>
  80267b:	85 ff                	test   %edi,%edi
  80267d:	89 fd                	mov    %edi,%ebp
  80267f:	75 0b                	jne    80268c <__udivdi3+0x3c>
  802681:	b8 01 00 00 00       	mov    $0x1,%eax
  802686:	31 d2                	xor    %edx,%edx
  802688:	f7 f7                	div    %edi
  80268a:	89 c5                	mov    %eax,%ebp
  80268c:	89 c8                	mov    %ecx,%eax
  80268e:	31 d2                	xor    %edx,%edx
  802690:	f7 f5                	div    %ebp
  802692:	89 c1                	mov    %eax,%ecx
  802694:	89 d8                	mov    %ebx,%eax
  802696:	89 cf                	mov    %ecx,%edi
  802698:	f7 f5                	div    %ebp
  80269a:	89 c3                	mov    %eax,%ebx
  80269c:	89 d8                	mov    %ebx,%eax
  80269e:	89 fa                	mov    %edi,%edx
  8026a0:	83 c4 1c             	add    $0x1c,%esp
  8026a3:	5b                   	pop    %ebx
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	90                   	nop
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	39 ce                	cmp    %ecx,%esi
  8026b2:	77 74                	ja     802728 <__udivdi3+0xd8>
  8026b4:	0f bd fe             	bsr    %esi,%edi
  8026b7:	83 f7 1f             	xor    $0x1f,%edi
  8026ba:	0f 84 98 00 00 00    	je     802758 <__udivdi3+0x108>
  8026c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	89 c5                	mov    %eax,%ebp
  8026c9:	29 fb                	sub    %edi,%ebx
  8026cb:	d3 e6                	shl    %cl,%esi
  8026cd:	89 d9                	mov    %ebx,%ecx
  8026cf:	d3 ed                	shr    %cl,%ebp
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	d3 e0                	shl    %cl,%eax
  8026d5:	09 ee                	or     %ebp,%esi
  8026d7:	89 d9                	mov    %ebx,%ecx
  8026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026dd:	89 d5                	mov    %edx,%ebp
  8026df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026e3:	d3 ed                	shr    %cl,%ebp
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e2                	shl    %cl,%edx
  8026e9:	89 d9                	mov    %ebx,%ecx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	09 c2                	or     %eax,%edx
  8026ef:	89 d0                	mov    %edx,%eax
  8026f1:	89 ea                	mov    %ebp,%edx
  8026f3:	f7 f6                	div    %esi
  8026f5:	89 d5                	mov    %edx,%ebp
  8026f7:	89 c3                	mov    %eax,%ebx
  8026f9:	f7 64 24 0c          	mull   0xc(%esp)
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	72 10                	jb     802711 <__udivdi3+0xc1>
  802701:	8b 74 24 08          	mov    0x8(%esp),%esi
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e6                	shl    %cl,%esi
  802709:	39 c6                	cmp    %eax,%esi
  80270b:	73 07                	jae    802714 <__udivdi3+0xc4>
  80270d:	39 d5                	cmp    %edx,%ebp
  80270f:	75 03                	jne    802714 <__udivdi3+0xc4>
  802711:	83 eb 01             	sub    $0x1,%ebx
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 d8                	mov    %ebx,%eax
  802718:	89 fa                	mov    %edi,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	31 db                	xor    %ebx,%ebx
  80272c:	89 d8                	mov    %ebx,%eax
  80272e:	89 fa                	mov    %edi,%edx
  802730:	83 c4 1c             	add    $0x1c,%esp
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	90                   	nop
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 d8                	mov    %ebx,%eax
  802742:	f7 f7                	div    %edi
  802744:	31 ff                	xor    %edi,%edi
  802746:	89 c3                	mov    %eax,%ebx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 fa                	mov    %edi,%edx
  80274c:	83 c4 1c             	add    $0x1c,%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	39 ce                	cmp    %ecx,%esi
  80275a:	72 0c                	jb     802768 <__udivdi3+0x118>
  80275c:	31 db                	xor    %ebx,%ebx
  80275e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802762:	0f 87 34 ff ff ff    	ja     80269c <__udivdi3+0x4c>
  802768:	bb 01 00 00 00       	mov    $0x1,%ebx
  80276d:	e9 2a ff ff ff       	jmp    80269c <__udivdi3+0x4c>
  802772:	66 90                	xchg   %ax,%ax
  802774:	66 90                	xchg   %ax,%ax
  802776:	66 90                	xchg   %ax,%ax
  802778:	66 90                	xchg   %ax,%ax
  80277a:	66 90                	xchg   %ax,%ax
  80277c:	66 90                	xchg   %ax,%ax
  80277e:	66 90                	xchg   %ax,%ax

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80278b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80278f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 d2                	test   %edx,%edx
  802799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80279d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027a1:	89 f3                	mov    %esi,%ebx
  8027a3:	89 3c 24             	mov    %edi,(%esp)
  8027a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027aa:	75 1c                	jne    8027c8 <__umoddi3+0x48>
  8027ac:	39 f7                	cmp    %esi,%edi
  8027ae:	76 50                	jbe    802800 <__umoddi3+0x80>
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	f7 f7                	div    %edi
  8027b6:	89 d0                	mov    %edx,%eax
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	39 f2                	cmp    %esi,%edx
  8027ca:	89 d0                	mov    %edx,%eax
  8027cc:	77 52                	ja     802820 <__umoddi3+0xa0>
  8027ce:	0f bd ea             	bsr    %edx,%ebp
  8027d1:	83 f5 1f             	xor    $0x1f,%ebp
  8027d4:	75 5a                	jne    802830 <__umoddi3+0xb0>
  8027d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027da:	0f 82 e0 00 00 00    	jb     8028c0 <__umoddi3+0x140>
  8027e0:	39 0c 24             	cmp    %ecx,(%esp)
  8027e3:	0f 86 d7 00 00 00    	jbe    8028c0 <__umoddi3+0x140>
  8027e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	5b                   	pop    %ebx
  8027f5:	5e                   	pop    %esi
  8027f6:	5f                   	pop    %edi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	85 ff                	test   %edi,%edi
  802802:	89 fd                	mov    %edi,%ebp
  802804:	75 0b                	jne    802811 <__umoddi3+0x91>
  802806:	b8 01 00 00 00       	mov    $0x1,%eax
  80280b:	31 d2                	xor    %edx,%edx
  80280d:	f7 f7                	div    %edi
  80280f:	89 c5                	mov    %eax,%ebp
  802811:	89 f0                	mov    %esi,%eax
  802813:	31 d2                	xor    %edx,%edx
  802815:	f7 f5                	div    %ebp
  802817:	89 c8                	mov    %ecx,%eax
  802819:	f7 f5                	div    %ebp
  80281b:	89 d0                	mov    %edx,%eax
  80281d:	eb 99                	jmp    8027b8 <__umoddi3+0x38>
  80281f:	90                   	nop
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	83 c4 1c             	add    $0x1c,%esp
  802827:	5b                   	pop    %ebx
  802828:	5e                   	pop    %esi
  802829:	5f                   	pop    %edi
  80282a:	5d                   	pop    %ebp
  80282b:	c3                   	ret    
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	8b 34 24             	mov    (%esp),%esi
  802833:	bf 20 00 00 00       	mov    $0x20,%edi
  802838:	89 e9                	mov    %ebp,%ecx
  80283a:	29 ef                	sub    %ebp,%edi
  80283c:	d3 e0                	shl    %cl,%eax
  80283e:	89 f9                	mov    %edi,%ecx
  802840:	89 f2                	mov    %esi,%edx
  802842:	d3 ea                	shr    %cl,%edx
  802844:	89 e9                	mov    %ebp,%ecx
  802846:	09 c2                	or     %eax,%edx
  802848:	89 d8                	mov    %ebx,%eax
  80284a:	89 14 24             	mov    %edx,(%esp)
  80284d:	89 f2                	mov    %esi,%edx
  80284f:	d3 e2                	shl    %cl,%edx
  802851:	89 f9                	mov    %edi,%ecx
  802853:	89 54 24 04          	mov    %edx,0x4(%esp)
  802857:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80285b:	d3 e8                	shr    %cl,%eax
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	89 c6                	mov    %eax,%esi
  802861:	d3 e3                	shl    %cl,%ebx
  802863:	89 f9                	mov    %edi,%ecx
  802865:	89 d0                	mov    %edx,%eax
  802867:	d3 e8                	shr    %cl,%eax
  802869:	89 e9                	mov    %ebp,%ecx
  80286b:	09 d8                	or     %ebx,%eax
  80286d:	89 d3                	mov    %edx,%ebx
  80286f:	89 f2                	mov    %esi,%edx
  802871:	f7 34 24             	divl   (%esp)
  802874:	89 d6                	mov    %edx,%esi
  802876:	d3 e3                	shl    %cl,%ebx
  802878:	f7 64 24 04          	mull   0x4(%esp)
  80287c:	39 d6                	cmp    %edx,%esi
  80287e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802882:	89 d1                	mov    %edx,%ecx
  802884:	89 c3                	mov    %eax,%ebx
  802886:	72 08                	jb     802890 <__umoddi3+0x110>
  802888:	75 11                	jne    80289b <__umoddi3+0x11b>
  80288a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80288e:	73 0b                	jae    80289b <__umoddi3+0x11b>
  802890:	2b 44 24 04          	sub    0x4(%esp),%eax
  802894:	1b 14 24             	sbb    (%esp),%edx
  802897:	89 d1                	mov    %edx,%ecx
  802899:	89 c3                	mov    %eax,%ebx
  80289b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80289f:	29 da                	sub    %ebx,%edx
  8028a1:	19 ce                	sbb    %ecx,%esi
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 f0                	mov    %esi,%eax
  8028a7:	d3 e0                	shl    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	d3 ea                	shr    %cl,%edx
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	d3 ee                	shr    %cl,%esi
  8028b1:	09 d0                	or     %edx,%eax
  8028b3:	89 f2                	mov    %esi,%edx
  8028b5:	83 c4 1c             	add    $0x1c,%esp
  8028b8:	5b                   	pop    %ebx
  8028b9:	5e                   	pop    %esi
  8028ba:	5f                   	pop    %edi
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    
  8028bd:	8d 76 00             	lea    0x0(%esi),%esi
  8028c0:	29 f9                	sub    %edi,%ecx
  8028c2:	19 d6                	sbb    %edx,%esi
  8028c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028cc:	e9 18 ff ff ff       	jmp    8027e9 <__umoddi3+0x69>
