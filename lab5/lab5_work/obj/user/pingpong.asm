
obj/user/pingpong.debug：     文件格式 elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 e5 0d 00 00       	call   800e26 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ac 0a 00 00       	call   800afb <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 22 80 00       	push   $0x802220
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 a1 10 00 00       	call   80110d <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 f6 0f 00 00       	call   801075 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 72 0a 00 00       	call   800afb <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 22 80 00       	push   $0x802236
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 5f 10 00 00       	call   80110d <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 2d 0a 00 00       	call   800afb <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 56 12 00 00       	call   801365 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 a1 09 00 00       	call   800aba <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 2f 09 00 00       	call   800a7d <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 d4 08 00 00       	call   800a7d <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 77 1d 00 00       	call   801f90 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 64 1e 00 00       	call   8020c0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 89 03 00 00    	je     80068d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 1a 03 00 00    	ja     800672 <vprintfmt+0x38a>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 6b 22 80 00       	push   $0x80226b
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 d5 27 80 00       	push   $0x8027d5
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 64 22 80 00       	mov    $0x802264,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 86 02 00 00       	call   800715 <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	79 74                	jns    80063e <vprintfmt+0x356>
				putch('-', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d8:	f7 d8                	neg    %eax
  8005da:	83 d2 00             	adc    $0x0,%edx
  8005dd:	f7 da                	neg    %edx
  8005df:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e7:	eb 55                	jmp    80063e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 83 fc ff ff       	call   800274 <getuint>
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f6:	eb 46                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 74 fc ff ff       	call   800274 <getuint>
			base=8;
  800600:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800605:	eb 37                	jmp    80063e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800627:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062f:	eb 0d                	jmp    80063e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 3b fc ff ff       	call   800274 <getuint>
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800645:	57                   	push   %edi
  800646:	ff 75 e0             	pushl  -0x20(%ebp)
  800649:	51                   	push   %ecx
  80064a:	52                   	push   %edx
  80064b:	50                   	push   %eax
  80064c:	89 da                	mov    %ebx,%edx
  80064e:	89 f0                	mov    %esi,%eax
  800650:	e8 70 fb ff ff       	call   8001c5 <printnum>
			break;
  800655:	83 c4 20             	add    $0x20,%esp
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 ae fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	51                   	push   %ecx
  800665:	ff d6                	call   *%esi
			break;
  800667:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066d:	e9 9c fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 25                	push   $0x25
  800678:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 03                	jmp    800682 <vprintfmt+0x39a>
  80067f:	83 ef 01             	sub    $0x1,%edi
  800682:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800686:	75 f7                	jne    80067f <vprintfmt+0x397>
  800688:	e9 81 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800690:	5b                   	pop    %ebx
  800691:	5e                   	pop    %esi
  800692:	5f                   	pop    %edi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 18             	sub    $0x18,%esp
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	74 26                	je     8006dc <vsnprintf+0x47>
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	7e 22                	jle    8006dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ba:	ff 75 14             	pushl  0x14(%ebp)
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	68 ae 02 80 00       	push   $0x8002ae
  8006c9:	e8 1a fc ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 05                	jmp    8006e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ec:	50                   	push   %eax
  8006ed:	ff 75 10             	pushl  0x10(%ebp)
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	ff 75 08             	pushl  0x8(%ebp)
  8006f6:	e8 9a ff ff ff       	call   800695 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 03                	jmp    80070d <strlen+0x10>
		n++;
  80070a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800711:	75 f7                	jne    80070a <strlen+0xd>
		n++;
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071e:	ba 00 00 00 00       	mov    $0x0,%edx
  800723:	eb 03                	jmp    800728 <strnlen+0x13>
		n++;
  800725:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800728:	39 c2                	cmp    %eax,%edx
  80072a:	74 08                	je     800734 <strnlen+0x1f>
  80072c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800730:	75 f3                	jne    800725 <strnlen+0x10>
  800732:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 45 08             	mov    0x8(%ebp),%eax
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800740:	89 c2                	mov    %eax,%edx
  800742:	83 c2 01             	add    $0x1,%edx
  800745:	83 c1 01             	add    $0x1,%ecx
  800748:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074f:	84 db                	test   %bl,%bl
  800751:	75 ef                	jne    800742 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800753:	5b                   	pop    %ebx
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075d:	53                   	push   %ebx
  80075e:	e8 9a ff ff ff       	call   8006fd <strlen>
  800763:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	01 d8                	add    %ebx,%eax
  80076b:	50                   	push   %eax
  80076c:	e8 c5 ff ff ff       	call   800736 <strcpy>
	return dst;
}
  800771:	89 d8                	mov    %ebx,%eax
  800773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	56                   	push   %esi
  80077c:	53                   	push   %ebx
  80077d:	8b 75 08             	mov    0x8(%ebp),%esi
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	89 f3                	mov    %esi,%ebx
  800785:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800788:	89 f2                	mov    %esi,%edx
  80078a:	eb 0f                	jmp    80079b <strncpy+0x23>
		*dst++ = *src;
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	0f b6 01             	movzbl (%ecx),%eax
  800792:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800795:	80 39 01             	cmpb   $0x1,(%ecx)
  800798:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079b:	39 da                	cmp    %ebx,%edx
  80079d:	75 ed                	jne    80078c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079f:	89 f0                	mov    %esi,%eax
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 21                	je     8007da <strlcpy+0x35>
  8007b9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 09                	jmp    8007ca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 09                	je     8007d7 <strlcpy+0x32>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ec                	jne    8007c1 <strlcpy+0x1c>
  8007d5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007da:	29 f0                	sub    %esi,%eax
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strcmp+0x11>
		p++, q++;
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	84 c0                	test   %al,%al
  8007f6:	74 04                	je     8007fc <strcmp+0x1c>
  8007f8:	3a 02                	cmp    (%edx),%al
  8007fa:	74 ef                	je     8007eb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fc:	0f b6 c0             	movzbl %al,%eax
  8007ff:	0f b6 12             	movzbl (%edx),%edx
  800802:	29 d0                	sub    %edx,%eax
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800810:	89 c3                	mov    %eax,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800815:	eb 06                	jmp    80081d <strncmp+0x17>
		n--, p++, q++;
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	39 d8                	cmp    %ebx,%eax
  80081f:	74 15                	je     800836 <strncmp+0x30>
  800821:	0f b6 08             	movzbl (%eax),%ecx
  800824:	84 c9                	test   %cl,%cl
  800826:	74 04                	je     80082c <strncmp+0x26>
  800828:	3a 0a                	cmp    (%edx),%cl
  80082a:	74 eb                	je     800817 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 00             	movzbl (%eax),%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
  800834:	eb 05                	jmp    80083b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083b:	5b                   	pop    %ebx
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 07                	jmp    800851 <strchr+0x13>
		if (*s == c)
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 0f                	je     80085d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 03                	jmp    80086e <strfind+0xf>
  80086b:	83 c0 01             	add    $0x1,%eax
  80086e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 04                	je     800879 <strfind+0x1a>
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strfind+0xc>
			break;
	return (char *) s;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 36                	je     8008c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800891:	75 28                	jne    8008bb <memset+0x40>
  800893:	f6 c1 03             	test   $0x3,%cl
  800896:	75 23                	jne    8008bb <memset+0x40>
		c &= 0xFF;
  800898:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089c:	89 d3                	mov    %edx,%ebx
  80089e:	c1 e3 08             	shl    $0x8,%ebx
  8008a1:	89 d6                	mov    %edx,%esi
  8008a3:	c1 e6 18             	shl    $0x18,%esi
  8008a6:	89 d0                	mov    %edx,%eax
  8008a8:	c1 e0 10             	shl    $0x10,%eax
  8008ab:	09 f0                	or     %esi,%eax
  8008ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	09 d0                	or     %edx,%eax
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
  8008b6:	fc                   	cld    
  8008b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b9:	eb 06                	jmp    8008c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	fc                   	cld    
  8008bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c1:	89 f8                	mov    %edi,%eax
  8008c3:	5b                   	pop    %ebx
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d6:	39 c6                	cmp    %eax,%esi
  8008d8:	73 35                	jae    80090f <memmove+0x47>
  8008da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	73 2e                	jae    80090f <memmove+0x47>
		s += n;
		d += n;
  8008e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	09 fe                	or     %edi,%esi
  8008e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ee:	75 13                	jne    800903 <memmove+0x3b>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 0e                	jne    800903 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f5:	83 ef 04             	sub    $0x4,%edi
  8008f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fd                   	std    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 09                	jmp    80090c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800903:	83 ef 01             	sub    $0x1,%edi
  800906:	8d 72 ff             	lea    -0x1(%edx),%esi
  800909:	fd                   	std    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090c:	fc                   	cld    
  80090d:	eb 1d                	jmp    80092c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 f2                	mov    %esi,%edx
  800911:	09 c2                	or     %eax,%edx
  800913:	f6 c2 03             	test   $0x3,%dl
  800916:	75 0f                	jne    800927 <memmove+0x5f>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 0a                	jne    800927 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80091d:	c1 e9 02             	shr    $0x2,%ecx
  800920:	89 c7                	mov    %eax,%edi
  800922:	fc                   	cld    
  800923:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800925:	eb 05                	jmp    80092c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800933:	ff 75 10             	pushl  0x10(%ebp)
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 87 ff ff ff       	call   8008c8 <memmove>
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 c6                	mov    %eax,%esi
  800950:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	eb 1a                	jmp    80096f <memcmp+0x2c>
		if (*s1 != *s2)
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	0f b6 1a             	movzbl (%edx),%ebx
  80095b:	38 d9                	cmp    %bl,%cl
  80095d:	74 0a                	je     800969 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095f:	0f b6 c1             	movzbl %cl,%eax
  800962:	0f b6 db             	movzbl %bl,%ebx
  800965:	29 d8                	sub    %ebx,%eax
  800967:	eb 0f                	jmp    800978 <memcmp+0x35>
		s1++, s2++;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 f0                	cmp    %esi,%eax
  800971:	75 e2                	jne    800955 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800983:	89 c1                	mov    %eax,%ecx
  800985:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800988:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	eb 0a                	jmp    800998 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 10             	movzbl (%eax),%edx
  800991:	39 da                	cmp    %ebx,%edx
  800993:	74 07                	je     80099c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	39 c8                	cmp    %ecx,%eax
  80099a:	72 f2                	jb     80098e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	5b                   	pop    %ebx
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ab:	eb 03                	jmp    8009b0 <strtol+0x11>
		s++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	3c 20                	cmp    $0x20,%al
  8009b5:	74 f6                	je     8009ad <strtol+0xe>
  8009b7:	3c 09                	cmp    $0x9,%al
  8009b9:	74 f2                	je     8009ad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bb:	3c 2b                	cmp    $0x2b,%al
  8009bd:	75 0a                	jne    8009c9 <strtol+0x2a>
		s++;
  8009bf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c7:	eb 11                	jmp    8009da <strtol+0x3b>
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ce:	3c 2d                	cmp    $0x2d,%al
  8009d0:	75 08                	jne    8009da <strtol+0x3b>
		s++, neg = 1;
  8009d2:	83 c1 01             	add    $0x1,%ecx
  8009d5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009da:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e0:	75 15                	jne    8009f7 <strtol+0x58>
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 10                	jne    8009f7 <strtol+0x58>
  8009e7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009eb:	75 7c                	jne    800a69 <strtol+0xca>
		s += 2, base = 16;
  8009ed:	83 c1 02             	add    $0x2,%ecx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 16                	jmp    800a0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 12                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 08                	jne    800a0d <strtol+0x6e>
		s++, base = 8;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a15:	0f b6 11             	movzbl (%ecx),%edx
  800a18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 09             	cmp    $0x9,%bl
  800a20:	77 08                	ja     800a2a <strtol+0x8b>
			dig = *s - '0';
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 30             	sub    $0x30,%edx
  800a28:	eb 22                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a2d:	89 f3                	mov    %esi,%ebx
  800a2f:	80 fb 19             	cmp    $0x19,%bl
  800a32:	77 08                	ja     800a3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a34:	0f be d2             	movsbl %dl,%edx
  800a37:	83 ea 57             	sub    $0x57,%edx
  800a3a:	eb 10                	jmp    800a4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3f:	89 f3                	mov    %esi,%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 16                	ja     800a5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a46:	0f be d2             	movsbl %dl,%edx
  800a49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4f:	7d 0b                	jge    800a5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5a:	eb b9                	jmp    800a15 <strtol+0x76>

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 0d                	je     800a6f <strtol+0xd0>
		*endptr = (char *) s;
  800a62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a65:	89 0e                	mov    %ecx,(%esi)
  800a67:	eb 06                	jmp    800a6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	74 98                	je     800a05 <strtol+0x66>
  800a6d:	eb 9e                	jmp    800a0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	f7 da                	neg    %edx
  800a73:	85 ff                	test   %edi,%edi
  800a75:	0f 45 c2             	cmovne %edx,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	89 c7                	mov    %eax,%edi
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aab:	89 d1                	mov    %edx,%ecx
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	89 d7                	mov    %edx,%edi
  800ab1:	89 d6                	mov    %edx,%esi
  800ab3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac8:	b8 03 00 00 00       	mov    $0x3,%eax
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 cb                	mov    %ecx,%ebx
  800ad2:	89 cf                	mov    %ecx,%edi
  800ad4:	89 ce                	mov    %ecx,%esi
  800ad6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 03                	push   $0x3
  800ae2:	68 5f 25 80 00       	push   $0x80255f
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 7c 25 80 00       	push   $0x80257c
  800aee:	e8 84 13 00 00       	call   801e77 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 04                	push   $0x4
  800b63:	68 5f 25 80 00       	push   $0x80255f
  800b68:	6a 23                	push   $0x23
  800b6a:	68 7c 25 80 00       	push   $0x80257c
  800b6f:	e8 03 13 00 00       	call   801e77 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b96:	8b 75 18             	mov    0x18(%ebp),%esi
  800b99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 05                	push   $0x5
  800ba5:	68 5f 25 80 00       	push   $0x80255f
  800baa:	6a 23                	push   $0x23
  800bac:	68 7c 25 80 00       	push   $0x80257c
  800bb1:	e8 c1 12 00 00       	call   801e77 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcc:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	89 df                	mov    %ebx,%edi
  800bd9:	89 de                	mov    %ebx,%esi
  800bdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 06                	push   $0x6
  800be7:	68 5f 25 80 00       	push   $0x80255f
  800bec:	6a 23                	push   $0x23
  800bee:	68 7c 25 80 00       	push   $0x80257c
  800bf3:	e8 7f 12 00 00       	call   801e77 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 08                	push   $0x8
  800c29:	68 5f 25 80 00       	push   $0x80255f
  800c2e:	6a 23                	push   $0x23
  800c30:	68 7c 25 80 00       	push   $0x80257c
  800c35:	e8 3d 12 00 00       	call   801e77 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 09                	push   $0x9
  800c6b:	68 5f 25 80 00       	push   $0x80255f
  800c70:	6a 23                	push   $0x23
  800c72:	68 7c 25 80 00       	push   $0x80257c
  800c77:	e8 fb 11 00 00       	call   801e77 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 0a                	push   $0xa
  800cad:	68 5f 25 80 00       	push   $0x80255f
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 7c 25 80 00       	push   $0x80257c
  800cb9:	e8 b9 11 00 00       	call   801e77 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0d                	push   $0xd
  800d11:	68 5f 25 80 00       	push   $0x80255f
  800d16:	6a 23                	push   $0x23
  800d18:	68 7c 25 80 00       	push   $0x80257c
  800d1d:	e8 55 11 00 00       	call   801e77 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d32:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800d34:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d38:	75 14                	jne    800d4e <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	68 8c 25 80 00       	push   $0x80258c
  800d42:	6a 23                	push   $0x23
  800d44:	68 4f 26 80 00       	push   $0x80264f
  800d49:	e8 29 11 00 00       	call   801e77 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800d4e:	89 d8                	mov    %ebx,%eax
  800d50:	c1 e8 0c             	shr    $0xc,%eax
  800d53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d5a:	f6 c4 08             	test   $0x8,%ah
  800d5d:	75 14                	jne    800d73 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	68 b0 25 80 00       	push   $0x8025b0
  800d67:	6a 2d                	push   $0x2d
  800d69:	68 4f 26 80 00       	push   $0x80264f
  800d6e:	e8 04 11 00 00       	call   801e77 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800d73:	e8 83 fd ff ff       	call   800afb <sys_getenvid>
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	6a 07                	push   $0x7
  800d7d:	68 00 f0 7f 00       	push   $0x7ff000
  800d82:	50                   	push   %eax
  800d83:	e8 b1 fd ff ff       	call   800b39 <sys_page_alloc>
  800d88:	83 c4 10             	add    $0x10,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	79 12                	jns    800da1 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800d8f:	50                   	push   %eax
  800d90:	68 5a 26 80 00       	push   $0x80265a
  800d95:	6a 3b                	push   $0x3b
  800d97:	68 4f 26 80 00       	push   $0x80264f
  800d9c:	e8 d6 10 00 00       	call   801e77 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800da1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800da7:	83 ec 04             	sub    $0x4,%esp
  800daa:	68 00 10 00 00       	push   $0x1000
  800daf:	53                   	push   %ebx
  800db0:	68 00 f0 7f 00       	push   $0x7ff000
  800db5:	e8 0e fb ff ff       	call   8008c8 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800dba:	e8 3c fd ff ff       	call   800afb <sys_getenvid>
  800dbf:	89 c6                	mov    %eax,%esi
  800dc1:	e8 35 fd ff ff       	call   800afb <sys_getenvid>
  800dc6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dcd:	53                   	push   %ebx
  800dce:	56                   	push   %esi
  800dcf:	68 00 f0 7f 00       	push   $0x7ff000
  800dd4:	50                   	push   %eax
  800dd5:	e8 a2 fd ff ff       	call   800b7c <sys_page_map>
  800dda:	83 c4 20             	add    $0x20,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	79 12                	jns    800df3 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800de1:	50                   	push   %eax
  800de2:	68 73 26 80 00       	push   $0x802673
  800de7:	6a 48                	push   $0x48
  800de9:	68 4f 26 80 00       	push   $0x80264f
  800dee:	e8 84 10 00 00       	call   801e77 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800df3:	e8 03 fd ff ff       	call   800afb <sys_getenvid>
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	68 00 f0 7f 00       	push   $0x7ff000
  800e00:	50                   	push   %eax
  800e01:	e8 b8 fd ff ff       	call   800bbe <sys_page_unmap>
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	79 12                	jns    800e1f <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800e0d:	50                   	push   %eax
  800e0e:	68 8a 26 80 00       	push   $0x80268a
  800e13:	6a 4c                	push   $0x4c
  800e15:	68 4f 26 80 00       	push   $0x80264f
  800e1a:	e8 58 10 00 00       	call   801e77 <_panic>
	}

	//panic("pgfault not implemented");
}
  800e1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800e2f:	68 2a 0d 80 00       	push   $0x800d2a
  800e34:	e8 84 10 00 00       	call   801ebd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e39:	b8 07 00 00 00       	mov    $0x7,%eax
  800e3e:	cd 30                	int    $0x30
  800e40:	89 c7                	mov    %eax,%edi
  800e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	79 15                	jns    800e61 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800e4c:	50                   	push   %eax
  800e4d:	68 a3 26 80 00       	push   $0x8026a3
  800e52:	68 a1 00 00 00       	push   $0xa1
  800e57:	68 4f 26 80 00       	push   $0x80264f
  800e5c:	e8 16 10 00 00       	call   801e77 <_panic>
  800e61:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800e66:	85 c0                	test   %eax,%eax
  800e68:	75 21                	jne    800e8b <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800e6a:	e8 8c fc ff ff       	call   800afb <sys_getenvid>
  800e6f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e7c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	e9 c8 01 00 00       	jmp    801053 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800e8b:	89 d8                	mov    %ebx,%eax
  800e8d:	c1 e8 16             	shr    $0x16,%eax
  800e90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e97:	a8 01                	test   $0x1,%al
  800e99:	0f 84 23 01 00 00    	je     800fc2 <fork+0x19c>
  800e9f:	89 d8                	mov    %ebx,%eax
  800ea1:	c1 e8 0c             	shr    $0xc,%eax
  800ea4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	0f 84 0e 01 00 00    	je     800fc2 <fork+0x19c>
  800eb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ebb:	f6 c2 04             	test   $0x4,%dl
  800ebe:	0f 84 fe 00 00 00    	je     800fc2 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800ec4:	89 c6                	mov    %eax,%esi
  800ec6:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800ec9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ed0:	f6 c6 04             	test   $0x4,%dh
  800ed3:	74 3f                	je     800f14 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800ed5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	25 07 0e 00 00       	and    $0xe07,%eax
  800ee4:	50                   	push   %eax
  800ee5:	56                   	push   %esi
  800ee6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ee9:	56                   	push   %esi
  800eea:	6a 00                	push   $0x0
  800eec:	e8 8b fc ff ff       	call   800b7c <sys_page_map>
  800ef1:	83 c4 20             	add    $0x20,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	0f 89 c6 00 00 00    	jns    800fc2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800efc:	83 ec 08             	sub    $0x8,%esp
  800eff:	50                   	push   %eax
  800f00:	57                   	push   %edi
  800f01:	6a 00                	push   $0x0
  800f03:	68 e0 25 80 00       	push   $0x8025e0
  800f08:	6a 6c                	push   $0x6c
  800f0a:	68 4f 26 80 00       	push   $0x80264f
  800f0f:	e8 63 0f 00 00       	call   801e77 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1b:	f6 c2 02             	test   $0x2,%dl
  800f1e:	75 0c                	jne    800f2c <fork+0x106>
  800f20:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f27:	f6 c4 08             	test   $0x8,%ah
  800f2a:	74 66                	je     800f92 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	68 05 08 00 00       	push   $0x805
  800f34:	56                   	push   %esi
  800f35:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f38:	56                   	push   %esi
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 3c fc ff ff       	call   800b7c <sys_page_map>
  800f40:	83 c4 20             	add    $0x20,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	79 18                	jns    800f5f <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	50                   	push   %eax
  800f4b:	57                   	push   %edi
  800f4c:	6a 00                	push   $0x0
  800f4e:	68 e0 25 80 00       	push   $0x8025e0
  800f53:	6a 74                	push   $0x74
  800f55:	68 4f 26 80 00       	push   $0x80264f
  800f5a:	e8 18 0f 00 00       	call   801e77 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	68 05 08 00 00       	push   $0x805
  800f67:	56                   	push   %esi
  800f68:	6a 00                	push   $0x0
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 0a fc ff ff       	call   800b7c <sys_page_map>
  800f72:	83 c4 20             	add    $0x20,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 49                	jns    800fc2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	50                   	push   %eax
  800f7d:	6a 00                	push   $0x0
  800f7f:	6a 00                	push   $0x0
  800f81:	68 e0 25 80 00       	push   $0x8025e0
  800f86:	6a 77                	push   $0x77
  800f88:	68 4f 26 80 00       	push   $0x80264f
  800f8d:	e8 e5 0e 00 00       	call   801e77 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	6a 05                	push   $0x5
  800f97:	56                   	push   %esi
  800f98:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9b:	56                   	push   %esi
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 d9 fb ff ff       	call   800b7c <sys_page_map>
  800fa3:	83 c4 20             	add    $0x20,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 18                	jns    800fc2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800faa:	83 ec 08             	sub    $0x8,%esp
  800fad:	50                   	push   %eax
  800fae:	57                   	push   %edi
  800faf:	6a 00                	push   $0x0
  800fb1:	68 e0 25 80 00       	push   $0x8025e0
  800fb6:	6a 7d                	push   $0x7d
  800fb8:	68 4f 26 80 00       	push   $0x80264f
  800fbd:	e8 b5 0e 00 00       	call   801e77 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800fc2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fce:	0f 85 b7 fe ff ff    	jne    800e8b <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	6a 07                	push   $0x7
  800fd9:	68 00 f0 bf ee       	push   $0xeebff000
  800fde:	57                   	push   %edi
  800fdf:	e8 55 fb ff ff       	call   800b39 <sys_page_alloc>
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 15                	jns    801000 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  800feb:	50                   	push   %eax
  800fec:	68 0c 26 80 00       	push   $0x80260c
  800ff1:	68 b4 00 00 00       	push   $0xb4
  800ff6:	68 4f 26 80 00       	push   $0x80264f
  800ffb:	e8 77 0e 00 00       	call   801e77 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	68 31 1f 80 00       	push   $0x801f31
  801008:	57                   	push   %edi
  801009:	e8 76 fc ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	79 15                	jns    80102a <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801015:	50                   	push   %eax
  801016:	68 b9 26 80 00       	push   $0x8026b9
  80101b:	68 ba 00 00 00       	push   $0xba
  801020:	68 4f 26 80 00       	push   $0x80264f
  801025:	e8 4d 0e 00 00       	call   801e77 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	6a 02                	push   $0x2
  80102f:	57                   	push   %edi
  801030:	e8 cb fb ff ff       	call   800c00 <sys_env_set_status>
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	79 15                	jns    801051 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  80103c:	50                   	push   %eax
  80103d:	68 d6 26 80 00       	push   $0x8026d6
  801042:	68 bf 00 00 00       	push   $0xbf
  801047:	68 4f 26 80 00       	push   $0x80264f
  80104c:	e8 26 0e 00 00       	call   801e77 <_panic>
	}
	return eid;
  801051:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801053:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5f                   	pop    %edi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <sfork>:

// Challenge!
int
sfork(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801061:	68 f3 26 80 00       	push   $0x8026f3
  801066:	68 ca 00 00 00       	push   $0xca
  80106b:	68 4f 26 80 00       	push   $0x80264f
  801070:	e8 02 0e 00 00       	call   801e77 <_panic>

00801075 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	8b 75 08             	mov    0x8(%ebp),%esi
  80107d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801080:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801083:	85 c0                	test   %eax,%eax
  801085:	74 3e                	je     8010c5 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	50                   	push   %eax
  80108b:	e8 59 fc ff ff       	call   800ce9 <sys_ipc_recv>
  801090:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 f6                	test   %esi,%esi
  801097:	74 13                	je     8010ac <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
  80109e:	85 d2                	test   %edx,%edx
  8010a0:	75 08                	jne    8010aa <ipc_recv+0x35>
  8010a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a7:	8b 40 74             	mov    0x74(%eax),%eax
  8010aa:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8010ac:	85 db                	test   %ebx,%ebx
  8010ae:	74 48                	je     8010f8 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  8010b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b5:	85 d2                	test   %edx,%edx
  8010b7:	75 08                	jne    8010c1 <ipc_recv+0x4c>
  8010b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010be:	8b 40 78             	mov    0x78(%eax),%eax
  8010c1:	89 03                	mov    %eax,(%ebx)
  8010c3:	eb 33                	jmp    8010f8 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	68 00 00 c0 ee       	push   $0xeec00000
  8010cd:	e8 17 fc ff ff       	call   800ce9 <sys_ipc_recv>
  8010d2:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 f6                	test   %esi,%esi
  8010d9:	74 13                	je     8010ee <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e0:	85 d2                	test   %edx,%edx
  8010e2:	75 08                	jne    8010ec <ipc_recv+0x77>
  8010e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e9:	8b 40 74             	mov    0x74(%eax),%eax
  8010ec:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8010ee:	85 db                	test   %ebx,%ebx
  8010f0:	74 06                	je     8010f8 <ipc_recv+0x83>
			*perm_store = 0;
  8010f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  8010f8:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  8010fa:	85 d2                	test   %edx,%edx
  8010fc:	75 08                	jne    801106 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  8010fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801103:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801106:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	8b 7d 08             	mov    0x8(%ebp),%edi
  801119:	8b 75 0c             	mov    0xc(%ebp),%esi
  80111c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80111f:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801121:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801126:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801129:	eb 1c                	jmp    801147 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  80112b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80112e:	74 12                	je     801142 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801130:	50                   	push   %eax
  801131:	68 09 27 80 00       	push   $0x802709
  801136:	6a 4f                	push   $0x4f
  801138:	68 24 27 80 00       	push   $0x802724
  80113d:	e8 35 0d 00 00       	call   801e77 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801142:	e8 d3 f9 ff ff       	call   800b1a <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801147:	ff 75 14             	pushl  0x14(%ebp)
  80114a:	53                   	push   %ebx
  80114b:	56                   	push   %esi
  80114c:	57                   	push   %edi
  80114d:	e8 74 fb ff ff       	call   800cc6 <sys_ipc_try_send>
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	78 d2                	js     80112b <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801167:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80116c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80116f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801175:	8b 52 50             	mov    0x50(%edx),%edx
  801178:	39 ca                	cmp    %ecx,%edx
  80117a:	75 0d                	jne    801189 <ipc_find_env+0x28>
			return envs[i].env_id;
  80117c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80117f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801184:	8b 40 48             	mov    0x48(%eax),%eax
  801187:	eb 0f                	jmp    801198 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801189:	83 c0 01             	add    $0x1,%eax
  80118c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801191:	75 d9                	jne    80116c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801193:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ba:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	c1 ea 16             	shr    $0x16,%edx
  8011d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d8:	f6 c2 01             	test   $0x1,%dl
  8011db:	74 11                	je     8011ee <fd_alloc+0x2d>
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 ea 0c             	shr    $0xc,%edx
  8011e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	75 09                	jne    8011f7 <fd_alloc+0x36>
			*fd_store = fd;
  8011ee:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f5:	eb 17                	jmp    80120e <fd_alloc+0x4d>
  8011f7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011fc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801201:	75 c9                	jne    8011cc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801203:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801209:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801216:	83 f8 1f             	cmp    $0x1f,%eax
  801219:	77 36                	ja     801251 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80121b:	c1 e0 0c             	shl    $0xc,%eax
  80121e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801223:	89 c2                	mov    %eax,%edx
  801225:	c1 ea 16             	shr    $0x16,%edx
  801228:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122f:	f6 c2 01             	test   $0x1,%dl
  801232:	74 24                	je     801258 <fd_lookup+0x48>
  801234:	89 c2                	mov    %eax,%edx
  801236:	c1 ea 0c             	shr    $0xc,%edx
  801239:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801240:	f6 c2 01             	test   $0x1,%dl
  801243:	74 1a                	je     80125f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801245:	8b 55 0c             	mov    0xc(%ebp),%edx
  801248:	89 02                	mov    %eax,(%edx)
	return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
  80124f:	eb 13                	jmp    801264 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801251:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801256:	eb 0c                	jmp    801264 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801258:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125d:	eb 05                	jmp    801264 <fd_lookup+0x54>
  80125f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126f:	ba ac 27 80 00       	mov    $0x8027ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801274:	eb 13                	jmp    801289 <dev_lookup+0x23>
  801276:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801279:	39 08                	cmp    %ecx,(%eax)
  80127b:	75 0c                	jne    801289 <dev_lookup+0x23>
			*dev = devtab[i];
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	89 01                	mov    %eax,(%ecx)
			return 0;
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	eb 2e                	jmp    8012b7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801289:	8b 02                	mov    (%edx),%eax
  80128b:	85 c0                	test   %eax,%eax
  80128d:	75 e7                	jne    801276 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128f:	a1 04 40 80 00       	mov    0x804004,%eax
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	51                   	push   %ecx
  80129b:	50                   	push   %eax
  80129c:	68 30 27 80 00       	push   $0x802730
  8012a1:	e8 0b ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8012a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 10             	sub    $0x10,%esp
  8012c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d1:	c1 e8 0c             	shr    $0xc,%eax
  8012d4:	50                   	push   %eax
  8012d5:	e8 36 ff ff ff       	call   801210 <fd_lookup>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 05                	js     8012e6 <fd_close+0x2d>
	    || fd != fd2)
  8012e1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e4:	74 0c                	je     8012f2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e6:	84 db                	test   %bl,%bl
  8012e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ed:	0f 44 c2             	cmove  %edx,%eax
  8012f0:	eb 41                	jmp    801333 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	ff 36                	pushl  (%esi)
  8012fb:	e8 66 ff ff ff       	call   801266 <dev_lookup>
  801300:	89 c3                	mov    %eax,%ebx
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 1a                	js     801323 <fd_close+0x6a>
		if (dev->dev_close)
  801309:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801314:	85 c0                	test   %eax,%eax
  801316:	74 0b                	je     801323 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	56                   	push   %esi
  80131c:	ff d0                	call   *%eax
  80131e:	89 c3                	mov    %eax,%ebx
  801320:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	56                   	push   %esi
  801327:	6a 00                	push   $0x0
  801329:	e8 90 f8 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	89 d8                	mov    %ebx,%eax
}
  801333:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	ff 75 08             	pushl  0x8(%ebp)
  801347:	e8 c4 fe ff ff       	call   801210 <fd_lookup>
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 10                	js     801363 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	6a 01                	push   $0x1
  801358:	ff 75 f4             	pushl  -0xc(%ebp)
  80135b:	e8 59 ff ff ff       	call   8012b9 <fd_close>
  801360:	83 c4 10             	add    $0x10,%esp
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <close_all>:

void
close_all(void)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	53                   	push   %ebx
  801375:	e8 c0 ff ff ff       	call   80133a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80137a:	83 c3 01             	add    $0x1,%ebx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	83 fb 20             	cmp    $0x20,%ebx
  801383:	75 ec                	jne    801371 <close_all+0xc>
		close(i);
}
  801385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	57                   	push   %edi
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
  801390:	83 ec 2c             	sub    $0x2c,%esp
  801393:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801396:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 08             	pushl  0x8(%ebp)
  80139d:	e8 6e fe ff ff       	call   801210 <fd_lookup>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	0f 88 c1 00 00 00    	js     80146e <dup+0xe4>
		return r;
	close(newfdnum);
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	56                   	push   %esi
  8013b1:	e8 84 ff ff ff       	call   80133a <close>

	newfd = INDEX2FD(newfdnum);
  8013b6:	89 f3                	mov    %esi,%ebx
  8013b8:	c1 e3 0c             	shl    $0xc,%ebx
  8013bb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c1:	83 c4 04             	add    $0x4,%esp
  8013c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c7:	e8 de fd ff ff       	call   8011aa <fd2data>
  8013cc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ce:	89 1c 24             	mov    %ebx,(%esp)
  8013d1:	e8 d4 fd ff ff       	call   8011aa <fd2data>
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013dc:	89 f8                	mov    %edi,%eax
  8013de:	c1 e8 16             	shr    $0x16,%eax
  8013e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e8:	a8 01                	test   $0x1,%al
  8013ea:	74 37                	je     801423 <dup+0x99>
  8013ec:	89 f8                	mov    %edi,%eax
  8013ee:	c1 e8 0c             	shr    $0xc,%eax
  8013f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f8:	f6 c2 01             	test   $0x1,%dl
  8013fb:	74 26                	je     801423 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801404:	83 ec 0c             	sub    $0xc,%esp
  801407:	25 07 0e 00 00       	and    $0xe07,%eax
  80140c:	50                   	push   %eax
  80140d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801410:	6a 00                	push   $0x0
  801412:	57                   	push   %edi
  801413:	6a 00                	push   $0x0
  801415:	e8 62 f7 ff ff       	call   800b7c <sys_page_map>
  80141a:	89 c7                	mov    %eax,%edi
  80141c:	83 c4 20             	add    $0x20,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 2e                	js     801451 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801426:	89 d0                	mov    %edx,%eax
  801428:	c1 e8 0c             	shr    $0xc,%eax
  80142b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	25 07 0e 00 00       	and    $0xe07,%eax
  80143a:	50                   	push   %eax
  80143b:	53                   	push   %ebx
  80143c:	6a 00                	push   $0x0
  80143e:	52                   	push   %edx
  80143f:	6a 00                	push   $0x0
  801441:	e8 36 f7 ff ff       	call   800b7c <sys_page_map>
  801446:	89 c7                	mov    %eax,%edi
  801448:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80144b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144d:	85 ff                	test   %edi,%edi
  80144f:	79 1d                	jns    80146e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	53                   	push   %ebx
  801455:	6a 00                	push   $0x0
  801457:	e8 62 f7 ff ff       	call   800bbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801462:	6a 00                	push   $0x0
  801464:	e8 55 f7 ff ff       	call   800bbe <sys_page_unmap>
	return r;
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	89 f8                	mov    %edi,%eax
}
  80146e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 14             	sub    $0x14,%esp
  80147d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801480:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	53                   	push   %ebx
  801485:	e8 86 fd ff ff       	call   801210 <fd_lookup>
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	89 c2                	mov    %eax,%edx
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 6d                	js     801500 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149d:	ff 30                	pushl  (%eax)
  80149f:	e8 c2 fd ff ff       	call   801266 <dev_lookup>
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 4c                	js     8014f7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ae:	8b 42 08             	mov    0x8(%edx),%eax
  8014b1:	83 e0 03             	and    $0x3,%eax
  8014b4:	83 f8 01             	cmp    $0x1,%eax
  8014b7:	75 21                	jne    8014da <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014be:	8b 40 48             	mov    0x48(%eax),%eax
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	50                   	push   %eax
  8014c6:	68 71 27 80 00       	push   $0x802771
  8014cb:	e8 e1 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d8:	eb 26                	jmp    801500 <read+0x8a>
	}
	if (!dev->dev_read)
  8014da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dd:	8b 40 08             	mov    0x8(%eax),%eax
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	74 17                	je     8014fb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	ff 75 10             	pushl  0x10(%ebp)
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	52                   	push   %edx
  8014ee:	ff d0                	call   *%eax
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 09                	jmp    801500 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	eb 05                	jmp    801500 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801500:	89 d0                	mov    %edx,%eax
  801502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	57                   	push   %edi
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	8b 7d 08             	mov    0x8(%ebp),%edi
  801513:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801516:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151b:	eb 21                	jmp    80153e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	89 f0                	mov    %esi,%eax
  801522:	29 d8                	sub    %ebx,%eax
  801524:	50                   	push   %eax
  801525:	89 d8                	mov    %ebx,%eax
  801527:	03 45 0c             	add    0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	57                   	push   %edi
  80152c:	e8 45 ff ff ff       	call   801476 <read>
		if (m < 0)
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 10                	js     801548 <readn+0x41>
			return m;
		if (m == 0)
  801538:	85 c0                	test   %eax,%eax
  80153a:	74 0a                	je     801546 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153c:	01 c3                	add    %eax,%ebx
  80153e:	39 f3                	cmp    %esi,%ebx
  801540:	72 db                	jb     80151d <readn+0x16>
  801542:	89 d8                	mov    %ebx,%eax
  801544:	eb 02                	jmp    801548 <readn+0x41>
  801546:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    

00801550 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	53                   	push   %ebx
  801554:	83 ec 14             	sub    $0x14,%esp
  801557:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	53                   	push   %ebx
  80155f:	e8 ac fc ff ff       	call   801210 <fd_lookup>
  801564:	83 c4 08             	add    $0x8,%esp
  801567:	89 c2                	mov    %eax,%edx
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 68                	js     8015d5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801577:	ff 30                	pushl  (%eax)
  801579:	e8 e8 fc ff ff       	call   801266 <dev_lookup>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 47                	js     8015cc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801585:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801588:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158c:	75 21                	jne    8015af <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80158e:	a1 04 40 80 00       	mov    0x804004,%eax
  801593:	8b 40 48             	mov    0x48(%eax),%eax
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	53                   	push   %ebx
  80159a:	50                   	push   %eax
  80159b:	68 8d 27 80 00       	push   $0x80278d
  8015a0:	e8 0c ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ad:	eb 26                	jmp    8015d5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b5:	85 d2                	test   %edx,%edx
  8015b7:	74 17                	je     8015d0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	ff 75 10             	pushl  0x10(%ebp)
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	50                   	push   %eax
  8015c3:	ff d2                	call   *%edx
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 09                	jmp    8015d5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	eb 05                	jmp    8015d5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d5:	89 d0                	mov    %edx,%eax
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	ff 75 08             	pushl  0x8(%ebp)
  8015e9:	e8 22 fc ff ff       	call   801210 <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 0e                	js     801603 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	53                   	push   %ebx
  801609:	83 ec 14             	sub    $0x14,%esp
  80160c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	53                   	push   %ebx
  801614:	e8 f7 fb ff ff       	call   801210 <fd_lookup>
  801619:	83 c4 08             	add    $0x8,%esp
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 65                	js     801687 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	ff 30                	pushl  (%eax)
  80162e:	e8 33 fc ff ff       	call   801266 <dev_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 44                	js     80167e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801641:	75 21                	jne    801664 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801643:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801648:	8b 40 48             	mov    0x48(%eax),%eax
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	53                   	push   %ebx
  80164f:	50                   	push   %eax
  801650:	68 50 27 80 00       	push   $0x802750
  801655:	e8 57 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801662:	eb 23                	jmp    801687 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801664:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801667:	8b 52 18             	mov    0x18(%edx),%edx
  80166a:	85 d2                	test   %edx,%edx
  80166c:	74 14                	je     801682 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	50                   	push   %eax
  801675:	ff d2                	call   *%edx
  801677:	89 c2                	mov    %eax,%edx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	eb 09                	jmp    801687 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167e:	89 c2                	mov    %eax,%edx
  801680:	eb 05                	jmp    801687 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801682:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801687:	89 d0                	mov    %edx,%eax
  801689:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 14             	sub    $0x14,%esp
  801695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 6c fb ff ff       	call   801210 <fd_lookup>
  8016a4:	83 c4 08             	add    $0x8,%esp
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 58                	js     801705 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b7:	ff 30                	pushl  (%eax)
  8016b9:	e8 a8 fb ff ff       	call   801266 <dev_lookup>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 37                	js     8016fc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016cc:	74 32                	je     801700 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d8:	00 00 00 
	stat->st_isdir = 0;
  8016db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e2:	00 00 00 
	stat->st_dev = dev;
  8016e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f2:	ff 50 14             	call   *0x14(%eax)
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	eb 09                	jmp    801705 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	eb 05                	jmp    801705 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801700:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801705:	89 d0                	mov    %edx,%eax
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	6a 00                	push   $0x0
  801716:	ff 75 08             	pushl  0x8(%ebp)
  801719:	e8 d6 01 00 00       	call   8018f4 <open>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 1b                	js     801742 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	ff 75 0c             	pushl  0xc(%ebp)
  80172d:	50                   	push   %eax
  80172e:	e8 5b ff ff ff       	call   80168e <fstat>
  801733:	89 c6                	mov    %eax,%esi
	close(fd);
  801735:	89 1c 24             	mov    %ebx,(%esp)
  801738:	e8 fd fb ff ff       	call   80133a <close>
	return r;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	89 f0                	mov    %esi,%eax
}
  801742:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
  80174e:	89 c6                	mov    %eax,%esi
  801750:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801752:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801759:	75 12                	jne    80176d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80175b:	83 ec 0c             	sub    $0xc,%esp
  80175e:	6a 01                	push   $0x1
  801760:	e8 fc f9 ff ff       	call   801161 <ipc_find_env>
  801765:	a3 00 40 80 00       	mov    %eax,0x804000
  80176a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176d:	6a 07                	push   $0x7
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	56                   	push   %esi
  801775:	ff 35 00 40 80 00    	pushl  0x804000
  80177b:	e8 8d f9 ff ff       	call   80110d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801780:	83 c4 0c             	add    $0xc,%esp
  801783:	6a 00                	push   $0x0
  801785:	53                   	push   %ebx
  801786:	6a 00                	push   $0x0
  801788:	e8 e8 f8 ff ff       	call   801075 <ipc_recv>
}
  80178d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b7:	e8 8d ff ff ff       	call   801749 <fsipc>
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d9:	e8 6b ff ff ff       	call   801749 <fsipc>
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	53                   	push   %ebx
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ff:	e8 45 ff ff ff       	call   801749 <fsipc>
  801804:	85 c0                	test   %eax,%eax
  801806:	78 2c                	js     801834 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	68 00 50 80 00       	push   $0x805000
  801810:	53                   	push   %ebx
  801811:	e8 20 ef ff ff       	call   800736 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801816:	a1 80 50 80 00       	mov    0x805080,%eax
  80181b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801821:	a1 84 50 80 00       	mov    0x805084,%eax
  801826:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 0c             	sub    $0xc,%esp
  80183f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801842:	8b 55 08             	mov    0x8(%ebp),%edx
  801845:	8b 52 0c             	mov    0xc(%edx),%edx
  801848:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801853:	50                   	push   %eax
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	68 08 50 80 00       	push   $0x805008
  80185c:	e8 67 f0 ff ff       	call   8008c8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 04 00 00 00       	mov    $0x4,%eax
  80186b:	e8 d9 fe ff ff       	call   801749 <fsipc>
	//panic("devfile_write not implemented");
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801885:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 03 00 00 00       	mov    $0x3,%eax
  801895:	e8 af fe ff ff       	call   801749 <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 4b                	js     8018eb <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a0:	39 c6                	cmp    %eax,%esi
  8018a2:	73 16                	jae    8018ba <devfile_read+0x48>
  8018a4:	68 bc 27 80 00       	push   $0x8027bc
  8018a9:	68 c3 27 80 00       	push   $0x8027c3
  8018ae:	6a 7c                	push   $0x7c
  8018b0:	68 d8 27 80 00       	push   $0x8027d8
  8018b5:	e8 bd 05 00 00       	call   801e77 <_panic>
	assert(r <= PGSIZE);
  8018ba:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018bf:	7e 16                	jle    8018d7 <devfile_read+0x65>
  8018c1:	68 e3 27 80 00       	push   $0x8027e3
  8018c6:	68 c3 27 80 00       	push   $0x8027c3
  8018cb:	6a 7d                	push   $0x7d
  8018cd:	68 d8 27 80 00       	push   $0x8027d8
  8018d2:	e8 a0 05 00 00       	call   801e77 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	50                   	push   %eax
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	e8 e0 ef ff ff       	call   8008c8 <memmove>
	return r;
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	89 d8                	mov    %ebx,%eax
  8018ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 20             	sub    $0x20,%esp
  8018fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018fe:	53                   	push   %ebx
  8018ff:	e8 f9 ed ff ff       	call   8006fd <strlen>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190c:	7f 67                	jg     801975 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	e8 a7 f8 ff ff       	call   8011c1 <fd_alloc>
  80191a:	83 c4 10             	add    $0x10,%esp
		return r;
  80191d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 57                	js     80197a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	53                   	push   %ebx
  801927:	68 00 50 80 00       	push   $0x805000
  80192c:	e8 05 ee ff ff       	call   800736 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801931:	8b 45 0c             	mov    0xc(%ebp),%eax
  801934:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193c:	b8 01 00 00 00       	mov    $0x1,%eax
  801941:	e8 03 fe ff ff       	call   801749 <fsipc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	79 14                	jns    801963 <open+0x6f>
		fd_close(fd, 0);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	6a 00                	push   $0x0
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	e8 5d f9 ff ff       	call   8012b9 <fd_close>
		return r;
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	89 da                	mov    %ebx,%edx
  801961:	eb 17                	jmp    80197a <open+0x86>
	}

	return fd2num(fd);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 f4             	pushl  -0xc(%ebp)
  801969:	e8 2c f8 ff ff       	call   80119a <fd2num>
  80196e:	89 c2                	mov    %eax,%edx
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb 05                	jmp    80197a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801975:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197a:	89 d0                	mov    %edx,%eax
  80197c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 08 00 00 00       	mov    $0x8,%eax
  801991:	e8 b3 fd ff ff       	call   801749 <fsipc>
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff 75 08             	pushl  0x8(%ebp)
  8019a6:	e8 ff f7 ff ff       	call   8011aa <fd2data>
  8019ab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ad:	83 c4 08             	add    $0x8,%esp
  8019b0:	68 ef 27 80 00       	push   $0x8027ef
  8019b5:	53                   	push   %ebx
  8019b6:	e8 7b ed ff ff       	call   800736 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019bb:	8b 46 04             	mov    0x4(%esi),%eax
  8019be:	2b 06                	sub    (%esi),%eax
  8019c0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019cd:	00 00 00 
	stat->st_dev = &devpipe;
  8019d0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d7:	30 80 00 
	return 0;
}
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019f0:	53                   	push   %ebx
  8019f1:	6a 00                	push   $0x0
  8019f3:	e8 c6 f1 ff ff       	call   800bbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f8:	89 1c 24             	mov    %ebx,(%esp)
  8019fb:	e8 aa f7 ff ff       	call   8011aa <fd2data>
  801a00:	83 c4 08             	add    $0x8,%esp
  801a03:	50                   	push   %eax
  801a04:	6a 00                	push   $0x0
  801a06:	e8 b3 f1 ff ff       	call   800bbe <sys_page_unmap>
}
  801a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 1c             	sub    $0x1c,%esp
  801a19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a1c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a1e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a23:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	ff 75 e0             	pushl  -0x20(%ebp)
  801a2c:	e8 24 05 00 00       	call   801f55 <pageref>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	89 3c 24             	mov    %edi,(%esp)
  801a36:	e8 1a 05 00 00       	call   801f55 <pageref>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	39 c3                	cmp    %eax,%ebx
  801a40:	0f 94 c1             	sete   %cl
  801a43:	0f b6 c9             	movzbl %cl,%ecx
  801a46:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a49:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a4f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a52:	39 ce                	cmp    %ecx,%esi
  801a54:	74 1b                	je     801a71 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a56:	39 c3                	cmp    %eax,%ebx
  801a58:	75 c4                	jne    801a1e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a5a:	8b 42 58             	mov    0x58(%edx),%eax
  801a5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a60:	50                   	push   %eax
  801a61:	56                   	push   %esi
  801a62:	68 f6 27 80 00       	push   $0x8027f6
  801a67:	e8 45 e7 ff ff       	call   8001b1 <cprintf>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	eb ad                	jmp    801a1e <_pipeisclosed+0xe>
	}
}
  801a71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5f                   	pop    %edi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	83 ec 28             	sub    $0x28,%esp
  801a85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a88:	56                   	push   %esi
  801a89:	e8 1c f7 ff ff       	call   8011aa <fd2data>
  801a8e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	bf 00 00 00 00       	mov    $0x0,%edi
  801a98:	eb 4b                	jmp    801ae5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a9a:	89 da                	mov    %ebx,%edx
  801a9c:	89 f0                	mov    %esi,%eax
  801a9e:	e8 6d ff ff ff       	call   801a10 <_pipeisclosed>
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	75 48                	jne    801aef <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa7:	e8 6e f0 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aac:	8b 43 04             	mov    0x4(%ebx),%eax
  801aaf:	8b 0b                	mov    (%ebx),%ecx
  801ab1:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab4:	39 d0                	cmp    %edx,%eax
  801ab6:	73 e2                	jae    801a9a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801abf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac2:	89 c2                	mov    %eax,%edx
  801ac4:	c1 fa 1f             	sar    $0x1f,%edx
  801ac7:	89 d1                	mov    %edx,%ecx
  801ac9:	c1 e9 1b             	shr    $0x1b,%ecx
  801acc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801acf:	83 e2 1f             	and    $0x1f,%edx
  801ad2:	29 ca                	sub    %ecx,%edx
  801ad4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801adc:	83 c0 01             	add    $0x1,%eax
  801adf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	83 c7 01             	add    $0x1,%edi
  801ae5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae8:	75 c2                	jne    801aac <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aea:	8b 45 10             	mov    0x10(%ebp),%eax
  801aed:	eb 05                	jmp    801af4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5f                   	pop    %edi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 18             	sub    $0x18,%esp
  801b05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b08:	57                   	push   %edi
  801b09:	e8 9c f6 ff ff       	call   8011aa <fd2data>
  801b0e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b18:	eb 3d                	jmp    801b57 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b1a:	85 db                	test   %ebx,%ebx
  801b1c:	74 04                	je     801b22 <devpipe_read+0x26>
				return i;
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	eb 44                	jmp    801b66 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b22:	89 f2                	mov    %esi,%edx
  801b24:	89 f8                	mov    %edi,%eax
  801b26:	e8 e5 fe ff ff       	call   801a10 <_pipeisclosed>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 32                	jne    801b61 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2f:	e8 e6 ef ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b34:	8b 06                	mov    (%esi),%eax
  801b36:	3b 46 04             	cmp    0x4(%esi),%eax
  801b39:	74 df                	je     801b1a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3b:	99                   	cltd   
  801b3c:	c1 ea 1b             	shr    $0x1b,%edx
  801b3f:	01 d0                	add    %edx,%eax
  801b41:	83 e0 1f             	and    $0x1f,%eax
  801b44:	29 d0                	sub    %edx,%eax
  801b46:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b51:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b54:	83 c3 01             	add    $0x1,%ebx
  801b57:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b5a:	75 d8                	jne    801b34 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5f:	eb 05                	jmp    801b66 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	e8 42 f6 ff ff       	call   8011c1 <fd_alloc>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 2c 01 00 00    	js     801cb8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	68 07 04 00 00       	push   $0x407
  801b94:	ff 75 f4             	pushl  -0xc(%ebp)
  801b97:	6a 00                	push   $0x0
  801b99:	e8 9b ef ff ff       	call   800b39 <sys_page_alloc>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	89 c2                	mov    %eax,%edx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 0d 01 00 00    	js     801cb8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb1:	50                   	push   %eax
  801bb2:	e8 0a f6 ff ff       	call   8011c1 <fd_alloc>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	0f 88 e2 00 00 00    	js     801ca6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 63 ef ff ff       	call   800b39 <sys_page_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 88 c3 00 00 00    	js     801ca6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	ff 75 f4             	pushl  -0xc(%ebp)
  801be9:	e8 bc f5 ff ff       	call   8011aa <fd2data>
  801bee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 c4 0c             	add    $0xc,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	50                   	push   %eax
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 39 ef ff ff       	call   800b39 <sys_page_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 89 00 00 00    	js     801c96 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	ff 75 f0             	pushl  -0x10(%ebp)
  801c13:	e8 92 f5 ff ff       	call   8011aa <fd2data>
  801c18:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1f:	50                   	push   %eax
  801c20:	6a 00                	push   $0x0
  801c22:	56                   	push   %esi
  801c23:	6a 00                	push   $0x0
  801c25:	e8 52 ef ff ff       	call   800b7c <sys_page_map>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 20             	add    $0x20,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 55                	js     801c88 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c51:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c56:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5d:	83 ec 0c             	sub    $0xc,%esp
  801c60:	ff 75 f4             	pushl  -0xc(%ebp)
  801c63:	e8 32 f5 ff ff       	call   80119a <fd2num>
  801c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c6d:	83 c4 04             	add    $0x4,%esp
  801c70:	ff 75 f0             	pushl  -0x10(%ebp)
  801c73:	e8 22 f5 ff ff       	call   80119a <fd2num>
  801c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	ba 00 00 00 00       	mov    $0x0,%edx
  801c86:	eb 30                	jmp    801cb8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	56                   	push   %esi
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 2b ef ff ff       	call   800bbe <sys_page_unmap>
  801c93:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 1b ef ff ff       	call   800bbe <sys_page_unmap>
  801ca3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cac:	6a 00                	push   $0x0
  801cae:	e8 0b ef ff ff       	call   800bbe <sys_page_unmap>
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb8:	89 d0                	mov    %edx,%eax
  801cba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cca:	50                   	push   %eax
  801ccb:	ff 75 08             	pushl  0x8(%ebp)
  801cce:	e8 3d f5 ff ff       	call   801210 <fd_lookup>
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 18                	js     801cf2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	e8 c5 f4 ff ff       	call   8011aa <fd2data>
	return _pipeisclosed(fd, p);
  801ce5:	89 c2                	mov    %eax,%edx
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	e8 21 fd ff ff       	call   801a10 <_pipeisclosed>
  801cef:	83 c4 10             	add    $0x10,%esp
}
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d04:	68 0e 28 80 00       	push   $0x80280e
  801d09:	ff 75 0c             	pushl  0xc(%ebp)
  801d0c:	e8 25 ea ff ff       	call   800736 <strcpy>
	return 0;
}
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d24:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d29:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2f:	eb 2d                	jmp    801d5e <devcons_write+0x46>
		m = n - tot;
  801d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d34:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d36:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d39:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d3e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	53                   	push   %ebx
  801d45:	03 45 0c             	add    0xc(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	57                   	push   %edi
  801d4a:	e8 79 eb ff ff       	call   8008c8 <memmove>
		sys_cputs(buf, m);
  801d4f:	83 c4 08             	add    $0x8,%esp
  801d52:	53                   	push   %ebx
  801d53:	57                   	push   %edi
  801d54:	e8 24 ed ff ff       	call   800a7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d59:	01 de                	add    %ebx,%esi
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	89 f0                	mov    %esi,%eax
  801d60:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d63:	72 cc                	jb     801d31 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7c:	74 2a                	je     801da8 <devcons_read+0x3b>
  801d7e:	eb 05                	jmp    801d85 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d80:	e8 95 ed ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d85:	e8 11 ed ff ff       	call   800a9b <sys_cgetc>
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	74 f2                	je     801d80 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 16                	js     801da8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d92:	83 f8 04             	cmp    $0x4,%eax
  801d95:	74 0c                	je     801da3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9a:	88 02                	mov    %al,(%edx)
	return 1;
  801d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801da1:	eb 05                	jmp    801da8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db0:	8b 45 08             	mov    0x8(%ebp),%eax
  801db3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db6:	6a 01                	push   $0x1
  801db8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	e8 bc ec ff ff       	call   800a7d <sys_cputs>
}
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <getchar>:

int
getchar(void)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dcc:	6a 01                	push   $0x1
  801dce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd1:	50                   	push   %eax
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 9d f6 ff ff       	call   801476 <read>
	if (r < 0)
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 0f                	js     801def <getchar+0x29>
		return r;
	if (r < 1)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	7e 06                	jle    801dea <getchar+0x24>
		return -E_EOF;
	return c;
  801de4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de8:	eb 05                	jmp    801def <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfa:	50                   	push   %eax
  801dfb:	ff 75 08             	pushl  0x8(%ebp)
  801dfe:	e8 0d f4 ff ff       	call   801210 <fd_lookup>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 11                	js     801e1b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e13:	39 10                	cmp    %edx,(%eax)
  801e15:	0f 94 c0             	sete   %al
  801e18:	0f b6 c0             	movzbl %al,%eax
}
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <opencons>:

int
opencons(void)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	e8 95 f3 ff ff       	call   8011c1 <fd_alloc>
  801e2c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 3e                	js     801e73 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	68 07 04 00 00       	push   $0x407
  801e3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e40:	6a 00                	push   $0x0
  801e42:	e8 f2 ec ff ff       	call   800b39 <sys_page_alloc>
  801e47:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 23                	js     801e73 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e50:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e59:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	50                   	push   %eax
  801e69:	e8 2c f3 ff ff       	call   80119a <fd2num>
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	83 c4 10             	add    $0x10,%esp
}
  801e73:	89 d0                	mov    %edx,%eax
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	56                   	push   %esi
  801e7b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e7c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e7f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e85:	e8 71 ec ff ff       	call   800afb <sys_getenvid>
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	ff 75 0c             	pushl  0xc(%ebp)
  801e90:	ff 75 08             	pushl  0x8(%ebp)
  801e93:	56                   	push   %esi
  801e94:	50                   	push   %eax
  801e95:	68 1c 28 80 00       	push   $0x80281c
  801e9a:	e8 12 e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e9f:	83 c4 18             	add    $0x18,%esp
  801ea2:	53                   	push   %ebx
  801ea3:	ff 75 10             	pushl  0x10(%ebp)
  801ea6:	e8 b5 e2 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801eab:	c7 04 24 07 28 80 00 	movl   $0x802807,(%esp)
  801eb2:	e8 fa e2 ff ff       	call   8001b1 <cprintf>
  801eb7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eba:	cc                   	int3   
  801ebb:	eb fd                	jmp    801eba <_panic+0x43>

00801ebd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	53                   	push   %ebx
  801ec1:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ec4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ecb:	75 57                	jne    801f24 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801ecd:	e8 29 ec ff ff       	call   800afb <sys_getenvid>
  801ed2:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801ed4:	83 ec 04             	sub    $0x4,%esp
  801ed7:	6a 07                	push   $0x7
  801ed9:	68 00 f0 bf ee       	push   $0xeebff000
  801ede:	50                   	push   %eax
  801edf:	e8 55 ec ff ff       	call   800b39 <sys_page_alloc>
		if (r) {
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	74 12                	je     801efd <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801eeb:	50                   	push   %eax
  801eec:	68 5a 26 80 00       	push   $0x80265a
  801ef1:	6a 25                	push   $0x25
  801ef3:	68 3f 28 80 00       	push   $0x80283f
  801ef8:	e8 7a ff ff ff       	call   801e77 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	68 31 1f 80 00       	push   $0x801f31
  801f05:	53                   	push   %ebx
  801f06:	e8 79 ed ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
		if (r) {
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	74 12                	je     801f24 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801f12:	50                   	push   %eax
  801f13:	68 50 28 80 00       	push   $0x802850
  801f18:	6a 2b                	push   $0x2b
  801f1a:	68 3f 28 80 00       	push   $0x80283f
  801f1f:	e8 53 ff ff ff       	call   801e77 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f24:	8b 45 08             	mov    0x8(%ebp),%eax
  801f27:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f31:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f32:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f37:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f39:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801f3c:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801f40:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801f45:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801f49:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801f4b:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801f4e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801f4f:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801f52:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801f53:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801f54:	c3                   	ret    

00801f55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5b:	89 d0                	mov    %edx,%eax
  801f5d:	c1 e8 16             	shr    $0x16,%eax
  801f60:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6c:	f6 c1 01             	test   $0x1,%cl
  801f6f:	74 1d                	je     801f8e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f71:	c1 ea 0c             	shr    $0xc,%edx
  801f74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f7b:	f6 c2 01             	test   $0x1,%dl
  801f7e:	74 0e                	je     801f8e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f80:	c1 ea 0c             	shr    $0xc,%edx
  801f83:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f8a:	ef 
  801f8b:	0f b7 c0             	movzwl %ax,%eax
}
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
