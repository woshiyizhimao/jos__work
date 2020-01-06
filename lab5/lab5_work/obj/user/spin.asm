
obj/user/spin.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 20 22 80 00       	push   $0x802220
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 d4 0d 00 00       	call   800e1d <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 98 22 80 00       	push   $0x802298
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 48 22 80 00       	push   $0x802248
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 9b 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800076:	e8 96 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80007b:	e8 91 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800080:	e8 8c 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800085:	e8 87 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008a:	e8 82 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  80008f:	e8 7d 0a 00 00       	call   800b11 <sys_yield>
	sys_yield();
  800094:	e8 78 0a 00 00       	call   800b11 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 70 22 80 00 	movl   $0x802270,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 04 0a 00 00       	call   800ab1 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 2d 0a 00 00       	call   800af2 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 31 11 00 00       	call   801237 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 a1 09 00 00       	call   800ab1 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 2f 09 00 00       	call   800a74 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 d4 08 00 00       	call   800a74 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 80 1d 00 00       	call   801f90 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 6d 1e 00 00       	call   8020c0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 89 03 00 00    	je     800684 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	eb 07                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 07             	movzbl (%edi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 1a 03 00 00    	ja     800669 <vprintfmt+0x38a>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800374:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800377:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037a:	83 fa 09             	cmp    $0x9,%edx
  80037d:	77 39                	ja     8003b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb e9                	jmp    80036d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 48 04             	lea    0x4(%eax),%ecx
  80038a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 27                	jmp    8003be <vprintfmt+0xdf>
  800397:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039a:	85 c0                	test   %eax,%eax
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	0f 49 c8             	cmovns %eax,%ecx
  8003a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	eb 8c                	jmp    800338 <vprintfmt+0x59>
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b6:	eb 80                	jmp    800338 <vprintfmt+0x59>
  8003b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	0f 89 70 ff ff ff    	jns    800338 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d5:	e9 5e ff ff ff       	jmp    800338 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 30                	pushl  (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fc:	e9 04 ff ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
  80040d:	31 d0                	xor    %edx,%eax
  80040f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x142>
  800416:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 d8 22 80 00       	push   $0x8022d8
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 94 fe ff ff       	call   8002c2 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800434:	e9 cc fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 11 28 80 00       	push   $0x802811
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 7c fe ff ff       	call   8002c2 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	e9 b4 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045c:	85 ff                	test   %edi,%edi
  80045e:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
  800463:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	0f 8e 94 00 00 00    	jle    800504 <vprintfmt+0x225>
  800470:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800474:	0f 84 98 00 00 00    	je     800512 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d0             	pushl  -0x30(%ebp)
  800480:	57                   	push   %edi
  800481:	e8 86 02 00 00       	call   80070c <strnlen>
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800491:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	eb 0f                	jmp    8004ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	7f ed                	jg     80049f <vprintfmt+0x1c0>
  8004b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c1             	cmovns %ecx,%eax
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	89 cb                	mov    %ecx,%ebx
  8004cf:	eb 4d                	jmp    80051e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d5:	74 1b                	je     8004f2 <vprintfmt+0x213>
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	83 e8 20             	sub    $0x20,%eax
  8004dd:	83 f8 5e             	cmp    $0x5e,%eax
  8004e0:	76 10                	jbe    8004f2 <vprintfmt+0x213>
					putch('?', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 0c             	pushl  0xc(%ebp)
  8004e8:	6a 3f                	push   $0x3f
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 0d                	jmp    8004ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	52                   	push   %edx
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	eb 1a                	jmp    80051e <vprintfmt+0x23f>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	eb 0c                	jmp    80051e <vprintfmt+0x23f>
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	83 c7 01             	add    $0x1,%edi
  800521:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 23                	je     80054f <vprintfmt+0x270>
  80052c:	85 f6                	test   %esi,%esi
  80052e:	78 a1                	js     8004d1 <vprintfmt+0x1f2>
  800530:	83 ee 01             	sub    $0x1,%esi
  800533:	79 9c                	jns    8004d1 <vprintfmt+0x1f2>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	eb 18                	jmp    800557 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 20                	push   $0x20
  800545:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 08                	jmp    800557 <vprintfmt+0x278>
  80054f:	89 df                	mov    %ebx,%edi
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800557:	85 ff                	test   %edi,%edi
  800559:	7f e4                	jg     80053f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	e9 a2 fd ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800563:	83 fa 01             	cmp    $0x1,%edx
  800566:	7e 16                	jle    80057e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 08             	lea    0x8(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	eb 32                	jmp    8005b0 <vprintfmt+0x2d1>
	else if (lflag)
  80057e:	85 d2                	test   %edx,%edx
  800580:	74 18                	je     80059a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	eb 16                	jmp    8005b0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005bf:	79 74                	jns    800635 <vprintfmt+0x356>
				putch('-', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 2d                	push   $0x2d
  8005c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005cf:	f7 d8                	neg    %eax
  8005d1:	83 d2 00             	adc    $0x0,%edx
  8005d4:	f7 da                	neg    %edx
  8005d6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005de:	eb 55                	jmp    800635 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	e8 83 fc ff ff       	call   80026b <getuint>
			base = 10;
  8005e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ed:	eb 46                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8005ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f2:	e8 74 fc ff ff       	call   80026b <getuint>
			base=8;
  8005f7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fc:	eb 37                	jmp    800635 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 30                	push   $0x30
  800604:	ff d6                	call   *%esi
			putch('x', putdat);
  800606:	83 c4 08             	add    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 78                	push   $0x78
  80060c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800621:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800626:	eb 0d                	jmp    800635 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 3b fc ff ff       	call   80026b <getuint>
			base = 16;
  800630:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063c:	57                   	push   %edi
  80063d:	ff 75 e0             	pushl  -0x20(%ebp)
  800640:	51                   	push   %ecx
  800641:	52                   	push   %edx
  800642:	50                   	push   %eax
  800643:	89 da                	mov    %ebx,%edx
  800645:	89 f0                	mov    %esi,%eax
  800647:	e8 70 fb ff ff       	call   8001bc <printnum>
			break;
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800652:	e9 ae fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	51                   	push   %ecx
  80065c:	ff d6                	call   *%esi
			break;
  80065e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800664:	e9 9c fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	6a 25                	push   $0x25
  80066f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 03                	jmp    800679 <vprintfmt+0x39a>
  800676:	83 ef 01             	sub    $0x1,%edi
  800679:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067d:	75 f7                	jne    800676 <vprintfmt+0x397>
  80067f:	e9 81 fc ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800687:	5b                   	pop    %ebx
  800688:	5e                   	pop    %esi
  800689:	5f                   	pop    %edi
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	83 ec 18             	sub    $0x18,%esp
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	74 26                	je     8006d3 <vsnprintf+0x47>
  8006ad:	85 d2                	test   %edx,%edx
  8006af:	7e 22                	jle    8006d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b1:	ff 75 14             	pushl  0x14(%ebp)
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	68 a5 02 80 00       	push   $0x8002a5
  8006c0:	e8 1a fc ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 05                	jmp    8006d8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 9a ff ff ff       	call   80068c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	eb 03                	jmp    800704 <strlen+0x10>
		n++;
  800701:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800704:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800708:	75 f7                	jne    800701 <strlen+0xd>
		n++;
	return n;
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	eb 03                	jmp    80071f <strnlen+0x13>
		n++;
  80071c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 c2                	cmp    %eax,%edx
  800721:	74 08                	je     80072b <strnlen+0x1f>
  800723:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800727:	75 f3                	jne    80071c <strnlen+0x10>
  800729:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800737:	89 c2                	mov    %eax,%edx
  800739:	83 c2 01             	add    $0x1,%edx
  80073c:	83 c1 01             	add    $0x1,%ecx
  80073f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800743:	88 5a ff             	mov    %bl,-0x1(%edx)
  800746:	84 db                	test   %bl,%bl
  800748:	75 ef                	jne    800739 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074a:	5b                   	pop    %ebx
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800754:	53                   	push   %ebx
  800755:	e8 9a ff ff ff       	call   8006f4 <strlen>
  80075a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	01 d8                	add    %ebx,%eax
  800762:	50                   	push   %eax
  800763:	e8 c5 ff ff ff       	call   80072d <strcpy>
	return dst;
}
  800768:	89 d8                	mov    %ebx,%eax
  80076a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077a:	89 f3                	mov    %esi,%ebx
  80077c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 0f                	jmp    800792 <strncpy+0x23>
		*dst++ = *src;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	0f b6 01             	movzbl (%ecx),%eax
  800789:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078c:	80 39 01             	cmpb   $0x1,(%ecx)
  80078f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800792:	39 da                	cmp    %ebx,%edx
  800794:	75 ed                	jne    800783 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800796:	89 f0                	mov    %esi,%eax
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 21                	je     8007d1 <strlcpy+0x35>
  8007b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	eb 09                	jmp    8007c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c1:	39 c2                	cmp    %eax,%edx
  8007c3:	74 09                	je     8007ce <strlcpy+0x32>
  8007c5:	0f b6 19             	movzbl (%ecx),%ebx
  8007c8:	84 db                	test   %bl,%bl
  8007ca:	75 ec                	jne    8007b8 <strlcpy+0x1c>
  8007cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d1:	29 f0                	sub    %esi,%eax
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e0:	eb 06                	jmp    8007e8 <strcmp+0x11>
		p++, q++;
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e8:	0f b6 01             	movzbl (%ecx),%eax
  8007eb:	84 c0                	test   %al,%al
  8007ed:	74 04                	je     8007f3 <strcmp+0x1c>
  8007ef:	3a 02                	cmp    (%edx),%al
  8007f1:	74 ef                	je     8007e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 c0             	movzbl %al,%eax
  8007f6:	0f b6 12             	movzbl (%edx),%edx
  8007f9:	29 d0                	sub    %edx,%eax
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 c3                	mov    %eax,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strncmp+0x17>
		n--, p++, q++;
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800814:	39 d8                	cmp    %ebx,%eax
  800816:	74 15                	je     80082d <strncmp+0x30>
  800818:	0f b6 08             	movzbl (%eax),%ecx
  80081b:	84 c9                	test   %cl,%cl
  80081d:	74 04                	je     800823 <strncmp+0x26>
  80081f:	3a 0a                	cmp    (%edx),%cl
  800821:	74 eb                	je     80080e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 00             	movzbl (%eax),%eax
  800826:	0f b6 12             	movzbl (%edx),%edx
  800829:	29 d0                	sub    %edx,%eax
  80082b:	eb 05                	jmp    800832 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800832:	5b                   	pop    %ebx
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083f:	eb 07                	jmp    800848 <strchr+0x13>
		if (*s == c)
  800841:	38 ca                	cmp    %cl,%dl
  800843:	74 0f                	je     800854 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 10             	movzbl (%eax),%edx
  80084b:	84 d2                	test   %dl,%dl
  80084d:	75 f2                	jne    800841 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800860:	eb 03                	jmp    800865 <strfind+0xf>
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 04                	je     800870 <strfind+0x1a>
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f2                	jne    800862 <strfind+0xc>
			break;
	return (char *) s;
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	57                   	push   %edi
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 36                	je     8008b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800882:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800888:	75 28                	jne    8008b2 <memset+0x40>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 23                	jne    8008b2 <memset+0x40>
		c &= 0xFF;
  80088f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800893:	89 d3                	mov    %edx,%ebx
  800895:	c1 e3 08             	shl    $0x8,%ebx
  800898:	89 d6                	mov    %edx,%esi
  80089a:	c1 e6 18             	shl    $0x18,%esi
  80089d:	89 d0                	mov    %edx,%eax
  80089f:	c1 e0 10             	shl    $0x10,%eax
  8008a2:	09 f0                	or     %esi,%eax
  8008a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a6:	89 d8                	mov    %ebx,%eax
  8008a8:	09 d0                	or     %edx,%eax
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fc                   	cld    
  8008ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b0:	eb 06                	jmp    8008b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b5:	fc                   	cld    
  8008b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b8:	89 f8                	mov    %edi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5f                   	pop    %edi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cd:	39 c6                	cmp    %eax,%esi
  8008cf:	73 35                	jae    800906 <memmove+0x47>
  8008d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d4:	39 d0                	cmp    %edx,%eax
  8008d6:	73 2e                	jae    800906 <memmove+0x47>
		s += n;
		d += n;
  8008d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	09 fe                	or     %edi,%esi
  8008df:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e5:	75 13                	jne    8008fa <memmove+0x3b>
  8008e7:	f6 c1 03             	test   $0x3,%cl
  8008ea:	75 0e                	jne    8008fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ec:	83 ef 04             	sub    $0x4,%edi
  8008ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
  8008f5:	fd                   	std    
  8008f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f8:	eb 09                	jmp    800903 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fa:	83 ef 01             	sub    $0x1,%edi
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 1d                	jmp    800923 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	89 f2                	mov    %esi,%edx
  800908:	09 c2                	or     %eax,%edx
  80090a:	f6 c2 03             	test   $0x3,%dl
  80090d:	75 0f                	jne    80091e <memmove+0x5f>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 0a                	jne    80091e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	89 c7                	mov    %eax,%edi
  800919:	fc                   	cld    
  80091a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091c:	eb 05                	jmp    800923 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091e:	89 c7                	mov    %eax,%edi
  800920:	fc                   	cld    
  800921:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 87 ff ff ff       	call   8008bf <memmove>
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 55 0c             	mov    0xc(%ebp),%edx
  800945:	89 c6                	mov    %eax,%esi
  800947:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	eb 1a                	jmp    800966 <memcmp+0x2c>
		if (*s1 != *s2)
  80094c:	0f b6 08             	movzbl (%eax),%ecx
  80094f:	0f b6 1a             	movzbl (%edx),%ebx
  800952:	38 d9                	cmp    %bl,%cl
  800954:	74 0a                	je     800960 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800956:	0f b6 c1             	movzbl %cl,%eax
  800959:	0f b6 db             	movzbl %bl,%ebx
  80095c:	29 d8                	sub    %ebx,%eax
  80095e:	eb 0f                	jmp    80096f <memcmp+0x35>
		s1++, s2++;
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800966:	39 f0                	cmp    %esi,%eax
  800968:	75 e2                	jne    80094c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80097f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800983:	eb 0a                	jmp    80098f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	39 da                	cmp    %ebx,%edx
  80098a:	74 07                	je     800993 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	39 c8                	cmp    %ecx,%eax
  800991:	72 f2                	jb     800985 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a2:	eb 03                	jmp    8009a7 <strtol+0x11>
		s++;
  8009a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	3c 20                	cmp    $0x20,%al
  8009ac:	74 f6                	je     8009a4 <strtol+0xe>
  8009ae:	3c 09                	cmp    $0x9,%al
  8009b0:	74 f2                	je     8009a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b2:	3c 2b                	cmp    $0x2b,%al
  8009b4:	75 0a                	jne    8009c0 <strtol+0x2a>
		s++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009be:	eb 11                	jmp    8009d1 <strtol+0x3b>
  8009c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c5:	3c 2d                	cmp    $0x2d,%al
  8009c7:	75 08                	jne    8009d1 <strtol+0x3b>
		s++, neg = 1;
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d7:	75 15                	jne    8009ee <strtol+0x58>
  8009d9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dc:	75 10                	jne    8009ee <strtol+0x58>
  8009de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e2:	75 7c                	jne    800a60 <strtol+0xca>
		s += 2, base = 16;
  8009e4:	83 c1 02             	add    $0x2,%ecx
  8009e7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ec:	eb 16                	jmp    800a04 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ee:	85 db                	test   %ebx,%ebx
  8009f0:	75 12                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	75 08                	jne    800a04 <strtol+0x6e>
		s++, base = 8;
  8009fc:	83 c1 01             	add    $0x1,%ecx
  8009ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	0f b6 11             	movzbl (%ecx),%edx
  800a0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a12:	89 f3                	mov    %esi,%ebx
  800a14:	80 fb 09             	cmp    $0x9,%bl
  800a17:	77 08                	ja     800a21 <strtol+0x8b>
			dig = *s - '0';
  800a19:	0f be d2             	movsbl %dl,%edx
  800a1c:	83 ea 30             	sub    $0x30,%edx
  800a1f:	eb 22                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a24:	89 f3                	mov    %esi,%ebx
  800a26:	80 fb 19             	cmp    $0x19,%bl
  800a29:	77 08                	ja     800a33 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2b:	0f be d2             	movsbl %dl,%edx
  800a2e:	83 ea 57             	sub    $0x57,%edx
  800a31:	eb 10                	jmp    800a43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a33:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a36:	89 f3                	mov    %esi,%ebx
  800a38:	80 fb 19             	cmp    $0x19,%bl
  800a3b:	77 16                	ja     800a53 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3d:	0f be d2             	movsbl %dl,%edx
  800a40:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a46:	7d 0b                	jge    800a53 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a51:	eb b9                	jmp    800a0c <strtol+0x76>

	if (endptr)
  800a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a57:	74 0d                	je     800a66 <strtol+0xd0>
		*endptr = (char *) s;
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	89 0e                	mov    %ecx,(%esi)
  800a5e:	eb 06                	jmp    800a66 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	74 98                	je     8009fc <strtol+0x66>
  800a64:	eb 9e                	jmp    800a04 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a66:	89 c2                	mov    %eax,%edx
  800a68:	f7 da                	neg    %edx
  800a6a:	85 ff                	test   %edi,%edi
  800a6c:	0f 45 c2             	cmovne %edx,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	89 c6                	mov    %eax,%esi
  800a8b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa2:	89 d1                	mov    %edx,%ecx
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	89 d7                	mov    %edx,%edi
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 cb                	mov    %ecx,%ebx
  800ac9:	89 cf                	mov    %ecx,%edi
  800acb:	89 ce                	mov    %ecx,%esi
  800acd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	7e 17                	jle    800aea <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	50                   	push   %eax
  800ad7:	6a 03                	push   $0x3
  800ad9:	68 bf 25 80 00       	push   $0x8025bf
  800ade:	6a 23                	push   $0x23
  800ae0:	68 dc 25 80 00       	push   $0x8025dc
  800ae5:	e8 5f 12 00 00       	call   801d49 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 02 00 00 00       	mov    $0x2,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_yield>:

void
sys_yield(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	be 00 00 00 00       	mov    $0x0,%esi
  800b3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4c:	89 f7                	mov    %esi,%edi
  800b4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 04                	push   $0x4
  800b5a:	68 bf 25 80 00       	push   $0x8025bf
  800b5f:	6a 23                	push   $0x23
  800b61:	68 dc 25 80 00       	push   $0x8025dc
  800b66:	e8 de 11 00 00       	call   801d49 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 05                	push   $0x5
  800b9c:	68 bf 25 80 00       	push   $0x8025bf
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 dc 25 80 00       	push   $0x8025dc
  800ba8:	e8 9c 11 00 00       	call   801d49 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 df                	mov    %ebx,%edi
  800bd0:	89 de                	mov    %ebx,%esi
  800bd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 06                	push   $0x6
  800bde:	68 bf 25 80 00       	push   $0x8025bf
  800be3:	6a 23                	push   $0x23
  800be5:	68 dc 25 80 00       	push   $0x8025dc
  800bea:	e8 5a 11 00 00       	call   801d49 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 08                	push   $0x8
  800c20:	68 bf 25 80 00       	push   $0x8025bf
  800c25:	6a 23                	push   $0x23
  800c27:	68 dc 25 80 00       	push   $0x8025dc
  800c2c:	e8 18 11 00 00       	call   801d49 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 09                	push   $0x9
  800c62:	68 bf 25 80 00       	push   $0x8025bf
  800c67:	6a 23                	push   $0x23
  800c69:	68 dc 25 80 00       	push   $0x8025dc
  800c6e:	e8 d6 10 00 00       	call   801d49 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 0a                	push   $0xa
  800ca4:	68 bf 25 80 00       	push   $0x8025bf
  800ca9:	6a 23                	push   $0x23
  800cab:	68 dc 25 80 00       	push   $0x8025dc
  800cb0:	e8 94 10 00 00       	call   801d49 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0d                	push   $0xd
  800d08:	68 bf 25 80 00       	push   $0x8025bf
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 dc 25 80 00       	push   $0x8025dc
  800d14:	e8 30 10 00 00       	call   801d49 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d29:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800d2b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d2f:	75 14                	jne    800d45 <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800d31:	83 ec 04             	sub    $0x4,%esp
  800d34:	68 ec 25 80 00       	push   $0x8025ec
  800d39:	6a 23                	push   $0x23
  800d3b:	68 af 26 80 00       	push   $0x8026af
  800d40:	e8 04 10 00 00       	call   801d49 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800d45:	89 d8                	mov    %ebx,%eax
  800d47:	c1 e8 0c             	shr    $0xc,%eax
  800d4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d51:	f6 c4 08             	test   $0x8,%ah
  800d54:	75 14                	jne    800d6a <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 10 26 80 00       	push   $0x802610
  800d5e:	6a 2d                	push   $0x2d
  800d60:	68 af 26 80 00       	push   $0x8026af
  800d65:	e8 df 0f 00 00       	call   801d49 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800d6a:	e8 83 fd ff ff       	call   800af2 <sys_getenvid>
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	6a 07                	push   $0x7
  800d74:	68 00 f0 7f 00       	push   $0x7ff000
  800d79:	50                   	push   %eax
  800d7a:	e8 b1 fd ff ff       	call   800b30 <sys_page_alloc>
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	85 c0                	test   %eax,%eax
  800d84:	79 12                	jns    800d98 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800d86:	50                   	push   %eax
  800d87:	68 ba 26 80 00       	push   $0x8026ba
  800d8c:	6a 3b                	push   $0x3b
  800d8e:	68 af 26 80 00       	push   $0x8026af
  800d93:	e8 b1 0f 00 00       	call   801d49 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800d98:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 00 10 00 00       	push   $0x1000
  800da6:	53                   	push   %ebx
  800da7:	68 00 f0 7f 00       	push   $0x7ff000
  800dac:	e8 0e fb ff ff       	call   8008bf <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800db1:	e8 3c fd ff ff       	call   800af2 <sys_getenvid>
  800db6:	89 c6                	mov    %eax,%esi
  800db8:	e8 35 fd ff ff       	call   800af2 <sys_getenvid>
  800dbd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dc4:	53                   	push   %ebx
  800dc5:	56                   	push   %esi
  800dc6:	68 00 f0 7f 00       	push   $0x7ff000
  800dcb:	50                   	push   %eax
  800dcc:	e8 a2 fd ff ff       	call   800b73 <sys_page_map>
  800dd1:	83 c4 20             	add    $0x20,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	79 12                	jns    800dea <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800dd8:	50                   	push   %eax
  800dd9:	68 d3 26 80 00       	push   $0x8026d3
  800dde:	6a 48                	push   $0x48
  800de0:	68 af 26 80 00       	push   $0x8026af
  800de5:	e8 5f 0f 00 00       	call   801d49 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800dea:	e8 03 fd ff ff       	call   800af2 <sys_getenvid>
  800def:	83 ec 08             	sub    $0x8,%esp
  800df2:	68 00 f0 7f 00       	push   $0x7ff000
  800df7:	50                   	push   %eax
  800df8:	e8 b8 fd ff ff       	call   800bb5 <sys_page_unmap>
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	79 12                	jns    800e16 <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800e04:	50                   	push   %eax
  800e05:	68 ea 26 80 00       	push   $0x8026ea
  800e0a:	6a 4c                	push   $0x4c
  800e0c:	68 af 26 80 00       	push   $0x8026af
  800e11:	e8 33 0f 00 00       	call   801d49 <_panic>
	}

	//panic("pgfault not implemented");
}
  800e16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800e26:	68 21 0d 80 00       	push   $0x800d21
  800e2b:	e8 5f 0f 00 00       	call   801d8f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e30:	b8 07 00 00 00       	mov    $0x7,%eax
  800e35:	cd 30                	int    $0x30
  800e37:	89 c7                	mov    %eax,%edi
  800e39:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	79 15                	jns    800e58 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800e43:	50                   	push   %eax
  800e44:	68 03 27 80 00       	push   $0x802703
  800e49:	68 a1 00 00 00       	push   $0xa1
  800e4e:	68 af 26 80 00       	push   $0x8026af
  800e53:	e8 f1 0e 00 00       	call   801d49 <_panic>
  800e58:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	75 21                	jne    800e82 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800e61:	e8 8c fc ff ff       	call   800af2 <sys_getenvid>
  800e66:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e6b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e6e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e73:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	e9 c8 01 00 00       	jmp    80104a <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800e82:	89 d8                	mov    %ebx,%eax
  800e84:	c1 e8 16             	shr    $0x16,%eax
  800e87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e8e:	a8 01                	test   $0x1,%al
  800e90:	0f 84 23 01 00 00    	je     800fb9 <fork+0x19c>
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	c1 e8 0c             	shr    $0xc,%eax
  800e9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	0f 84 0e 01 00 00    	je     800fb9 <fork+0x19c>
  800eab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb2:	f6 c2 04             	test   $0x4,%dl
  800eb5:	0f 84 fe 00 00 00    	je     800fb9 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800ebb:	89 c6                	mov    %eax,%esi
  800ebd:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800ec0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec7:	f6 c6 04             	test   $0x4,%dh
  800eca:	74 3f                	je     800f0b <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800ecc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	25 07 0e 00 00       	and    $0xe07,%eax
  800edb:	50                   	push   %eax
  800edc:	56                   	push   %esi
  800edd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ee0:	56                   	push   %esi
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 8b fc ff ff       	call   800b73 <sys_page_map>
  800ee8:	83 c4 20             	add    $0x20,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	0f 89 c6 00 00 00    	jns    800fb9 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	50                   	push   %eax
  800ef7:	57                   	push   %edi
  800ef8:	6a 00                	push   $0x0
  800efa:	68 40 26 80 00       	push   $0x802640
  800eff:	6a 6c                	push   $0x6c
  800f01:	68 af 26 80 00       	push   $0x8026af
  800f06:	e8 3e 0e 00 00       	call   801d49 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f0b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f12:	f6 c2 02             	test   $0x2,%dl
  800f15:	75 0c                	jne    800f23 <fork+0x106>
  800f17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1e:	f6 c4 08             	test   $0x8,%ah
  800f21:	74 66                	je     800f89 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	68 05 08 00 00       	push   $0x805
  800f2b:	56                   	push   %esi
  800f2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2f:	56                   	push   %esi
  800f30:	6a 00                	push   $0x0
  800f32:	e8 3c fc ff ff       	call   800b73 <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 18                	jns    800f56 <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	50                   	push   %eax
  800f42:	57                   	push   %edi
  800f43:	6a 00                	push   $0x0
  800f45:	68 40 26 80 00       	push   $0x802640
  800f4a:	6a 74                	push   $0x74
  800f4c:	68 af 26 80 00       	push   $0x8026af
  800f51:	e8 f3 0d 00 00       	call   801d49 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f56:	83 ec 0c             	sub    $0xc,%esp
  800f59:	68 05 08 00 00       	push   $0x805
  800f5e:	56                   	push   %esi
  800f5f:	6a 00                	push   $0x0
  800f61:	56                   	push   %esi
  800f62:	6a 00                	push   $0x0
  800f64:	e8 0a fc ff ff       	call   800b73 <sys_page_map>
  800f69:	83 c4 20             	add    $0x20,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 49                	jns    800fb9 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	50                   	push   %eax
  800f74:	6a 00                	push   $0x0
  800f76:	6a 00                	push   $0x0
  800f78:	68 40 26 80 00       	push   $0x802640
  800f7d:	6a 77                	push   $0x77
  800f7f:	68 af 26 80 00       	push   $0x8026af
  800f84:	e8 c0 0d 00 00       	call   801d49 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	6a 05                	push   $0x5
  800f8e:	56                   	push   %esi
  800f8f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f92:	56                   	push   %esi
  800f93:	6a 00                	push   $0x0
  800f95:	e8 d9 fb ff ff       	call   800b73 <sys_page_map>
  800f9a:	83 c4 20             	add    $0x20,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	79 18                	jns    800fb9 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	50                   	push   %eax
  800fa5:	57                   	push   %edi
  800fa6:	6a 00                	push   $0x0
  800fa8:	68 40 26 80 00       	push   $0x802640
  800fad:	6a 7d                	push   $0x7d
  800faf:	68 af 26 80 00       	push   $0x8026af
  800fb4:	e8 90 0d 00 00       	call   801d49 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800fb9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fc5:	0f 85 b7 fe ff ff    	jne    800e82 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	6a 07                	push   $0x7
  800fd0:	68 00 f0 bf ee       	push   $0xeebff000
  800fd5:	57                   	push   %edi
  800fd6:	e8 55 fb ff ff       	call   800b30 <sys_page_alloc>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 15                	jns    800ff7 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  800fe2:	50                   	push   %eax
  800fe3:	68 6c 26 80 00       	push   $0x80266c
  800fe8:	68 b4 00 00 00       	push   $0xb4
  800fed:	68 af 26 80 00       	push   $0x8026af
  800ff2:	e8 52 0d 00 00       	call   801d49 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	68 03 1e 80 00       	push   $0x801e03
  800fff:	57                   	push   %edi
  801000:	e8 76 fc ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 15                	jns    801021 <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  80100c:	50                   	push   %eax
  80100d:	68 19 27 80 00       	push   $0x802719
  801012:	68 ba 00 00 00       	push   $0xba
  801017:	68 af 26 80 00       	push   $0x8026af
  80101c:	e8 28 0d 00 00       	call   801d49 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801021:	83 ec 08             	sub    $0x8,%esp
  801024:	6a 02                	push   $0x2
  801026:	57                   	push   %edi
  801027:	e8 cb fb ff ff       	call   800bf7 <sys_env_set_status>
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	79 15                	jns    801048 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  801033:	50                   	push   %eax
  801034:	68 36 27 80 00       	push   $0x802736
  801039:	68 bf 00 00 00       	push   $0xbf
  80103e:	68 af 26 80 00       	push   $0x8026af
  801043:	e8 01 0d 00 00       	call   801d49 <_panic>
	}
	return eid;
  801048:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sfork>:

// Challenge!
int
sfork(void)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801058:	68 53 27 80 00       	push   $0x802753
  80105d:	68 ca 00 00 00       	push   $0xca
  801062:	68 af 26 80 00       	push   $0x8026af
  801067:	e8 dd 0c 00 00       	call   801d49 <_panic>

0080106c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	05 00 00 00 30       	add    $0x30000000,%eax
  801077:	c1 e8 0c             	shr    $0xc,%eax
}
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	05 00 00 00 30       	add    $0x30000000,%eax
  801087:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80108c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801099:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	c1 ea 16             	shr    $0x16,%edx
  8010a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010aa:	f6 c2 01             	test   $0x1,%dl
  8010ad:	74 11                	je     8010c0 <fd_alloc+0x2d>
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	c1 ea 0c             	shr    $0xc,%edx
  8010b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bb:	f6 c2 01             	test   $0x1,%dl
  8010be:	75 09                	jne    8010c9 <fd_alloc+0x36>
			*fd_store = fd;
  8010c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c7:	eb 17                	jmp    8010e0 <fd_alloc+0x4d>
  8010c9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d3:	75 c9                	jne    80109e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e8:	83 f8 1f             	cmp    $0x1f,%eax
  8010eb:	77 36                	ja     801123 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ed:	c1 e0 0c             	shl    $0xc,%eax
  8010f0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f5:	89 c2                	mov    %eax,%edx
  8010f7:	c1 ea 16             	shr    $0x16,%edx
  8010fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801101:	f6 c2 01             	test   $0x1,%dl
  801104:	74 24                	je     80112a <fd_lookup+0x48>
  801106:	89 c2                	mov    %eax,%edx
  801108:	c1 ea 0c             	shr    $0xc,%edx
  80110b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801112:	f6 c2 01             	test   $0x1,%dl
  801115:	74 1a                	je     801131 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801117:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111a:	89 02                	mov    %eax,(%edx)
	return 0;
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
  801121:	eb 13                	jmp    801136 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801123:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801128:	eb 0c                	jmp    801136 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112f:	eb 05                	jmp    801136 <fd_lookup+0x54>
  801131:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 08             	sub    $0x8,%esp
  80113e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801141:	ba e8 27 80 00       	mov    $0x8027e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801146:	eb 13                	jmp    80115b <dev_lookup+0x23>
  801148:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80114b:	39 08                	cmp    %ecx,(%eax)
  80114d:	75 0c                	jne    80115b <dev_lookup+0x23>
			*dev = devtab[i];
  80114f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801152:	89 01                	mov    %eax,(%ecx)
			return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	eb 2e                	jmp    801189 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80115b:	8b 02                	mov    (%edx),%eax
  80115d:	85 c0                	test   %eax,%eax
  80115f:	75 e7                	jne    801148 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801161:	a1 04 40 80 00       	mov    0x804004,%eax
  801166:	8b 40 48             	mov    0x48(%eax),%eax
  801169:	83 ec 04             	sub    $0x4,%esp
  80116c:	51                   	push   %ecx
  80116d:	50                   	push   %eax
  80116e:	68 6c 27 80 00       	push   $0x80276c
  801173:	e8 30 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
  801190:	83 ec 10             	sub    $0x10,%esp
  801193:	8b 75 08             	mov    0x8(%ebp),%esi
  801196:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011a3:	c1 e8 0c             	shr    $0xc,%eax
  8011a6:	50                   	push   %eax
  8011a7:	e8 36 ff ff ff       	call   8010e2 <fd_lookup>
  8011ac:	83 c4 08             	add    $0x8,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 05                	js     8011b8 <fd_close+0x2d>
	    || fd != fd2)
  8011b3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011b6:	74 0c                	je     8011c4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011b8:	84 db                	test   %bl,%bl
  8011ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bf:	0f 44 c2             	cmove  %edx,%eax
  8011c2:	eb 41                	jmp    801205 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ca:	50                   	push   %eax
  8011cb:	ff 36                	pushl  (%esi)
  8011cd:	e8 66 ff ff ff       	call   801138 <dev_lookup>
  8011d2:	89 c3                	mov    %eax,%ebx
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 1a                	js     8011f5 <fd_close+0x6a>
		if (dev->dev_close)
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011e1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	74 0b                	je     8011f5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	56                   	push   %esi
  8011ee:	ff d0                	call   *%eax
  8011f0:	89 c3                	mov    %eax,%ebx
  8011f2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	56                   	push   %esi
  8011f9:	6a 00                	push   $0x0
  8011fb:	e8 b5 f9 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	89 d8                	mov    %ebx,%eax
}
  801205:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 75 08             	pushl  0x8(%ebp)
  801219:	e8 c4 fe ff ff       	call   8010e2 <fd_lookup>
  80121e:	83 c4 08             	add    $0x8,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 10                	js     801235 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801225:	83 ec 08             	sub    $0x8,%esp
  801228:	6a 01                	push   $0x1
  80122a:	ff 75 f4             	pushl  -0xc(%ebp)
  80122d:	e8 59 ff ff ff       	call   80118b <fd_close>
  801232:	83 c4 10             	add    $0x10,%esp
}
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <close_all>:

void
close_all(void)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	53                   	push   %ebx
  80123b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80123e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	53                   	push   %ebx
  801247:	e8 c0 ff ff ff       	call   80120c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80124c:	83 c3 01             	add    $0x1,%ebx
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	83 fb 20             	cmp    $0x20,%ebx
  801255:	75 ec                	jne    801243 <close_all+0xc>
		close(i);
}
  801257:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 2c             	sub    $0x2c,%esp
  801265:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801268:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	ff 75 08             	pushl  0x8(%ebp)
  80126f:	e8 6e fe ff ff       	call   8010e2 <fd_lookup>
  801274:	83 c4 08             	add    $0x8,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	0f 88 c1 00 00 00    	js     801340 <dup+0xe4>
		return r;
	close(newfdnum);
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	56                   	push   %esi
  801283:	e8 84 ff ff ff       	call   80120c <close>

	newfd = INDEX2FD(newfdnum);
  801288:	89 f3                	mov    %esi,%ebx
  80128a:	c1 e3 0c             	shl    $0xc,%ebx
  80128d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801293:	83 c4 04             	add    $0x4,%esp
  801296:	ff 75 e4             	pushl  -0x1c(%ebp)
  801299:	e8 de fd ff ff       	call   80107c <fd2data>
  80129e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012a0:	89 1c 24             	mov    %ebx,(%esp)
  8012a3:	e8 d4 fd ff ff       	call   80107c <fd2data>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ae:	89 f8                	mov    %edi,%eax
  8012b0:	c1 e8 16             	shr    $0x16,%eax
  8012b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ba:	a8 01                	test   $0x1,%al
  8012bc:	74 37                	je     8012f5 <dup+0x99>
  8012be:	89 f8                	mov    %edi,%eax
  8012c0:	c1 e8 0c             	shr    $0xc,%eax
  8012c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	74 26                	je     8012f5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012e2:	6a 00                	push   $0x0
  8012e4:	57                   	push   %edi
  8012e5:	6a 00                	push   $0x0
  8012e7:	e8 87 f8 ff ff       	call   800b73 <sys_page_map>
  8012ec:	89 c7                	mov    %eax,%edi
  8012ee:	83 c4 20             	add    $0x20,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 2e                	js     801323 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012f8:	89 d0                	mov    %edx,%eax
  8012fa:	c1 e8 0c             	shr    $0xc,%eax
  8012fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	25 07 0e 00 00       	and    $0xe07,%eax
  80130c:	50                   	push   %eax
  80130d:	53                   	push   %ebx
  80130e:	6a 00                	push   $0x0
  801310:	52                   	push   %edx
  801311:	6a 00                	push   $0x0
  801313:	e8 5b f8 ff ff       	call   800b73 <sys_page_map>
  801318:	89 c7                	mov    %eax,%edi
  80131a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80131d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80131f:	85 ff                	test   %edi,%edi
  801321:	79 1d                	jns    801340 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	53                   	push   %ebx
  801327:	6a 00                	push   $0x0
  801329:	e8 87 f8 ff ff       	call   800bb5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	ff 75 d4             	pushl  -0x2c(%ebp)
  801334:	6a 00                	push   $0x0
  801336:	e8 7a f8 ff ff       	call   800bb5 <sys_page_unmap>
	return r;
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	89 f8                	mov    %edi,%eax
}
  801340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 14             	sub    $0x14,%esp
  80134f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801352:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	53                   	push   %ebx
  801357:	e8 86 fd ff ff       	call   8010e2 <fd_lookup>
  80135c:	83 c4 08             	add    $0x8,%esp
  80135f:	89 c2                	mov    %eax,%edx
  801361:	85 c0                	test   %eax,%eax
  801363:	78 6d                	js     8013d2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136b:	50                   	push   %eax
  80136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136f:	ff 30                	pushl  (%eax)
  801371:	e8 c2 fd ff ff       	call   801138 <dev_lookup>
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 4c                	js     8013c9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80137d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801380:	8b 42 08             	mov    0x8(%edx),%eax
  801383:	83 e0 03             	and    $0x3,%eax
  801386:	83 f8 01             	cmp    $0x1,%eax
  801389:	75 21                	jne    8013ac <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80138b:	a1 04 40 80 00       	mov    0x804004,%eax
  801390:	8b 40 48             	mov    0x48(%eax),%eax
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	53                   	push   %ebx
  801397:	50                   	push   %eax
  801398:	68 ad 27 80 00       	push   $0x8027ad
  80139d:	e8 06 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013aa:	eb 26                	jmp    8013d2 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013af:	8b 40 08             	mov    0x8(%eax),%eax
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	74 17                	je     8013cd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b6:	83 ec 04             	sub    $0x4,%esp
  8013b9:	ff 75 10             	pushl  0x10(%ebp)
  8013bc:	ff 75 0c             	pushl  0xc(%ebp)
  8013bf:	52                   	push   %edx
  8013c0:	ff d0                	call   *%eax
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	eb 09                	jmp    8013d2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	eb 05                	jmp    8013d2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013d2:	89 d0                	mov    %edx,%eax
  8013d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	57                   	push   %edi
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ed:	eb 21                	jmp    801410 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ef:	83 ec 04             	sub    $0x4,%esp
  8013f2:	89 f0                	mov    %esi,%eax
  8013f4:	29 d8                	sub    %ebx,%eax
  8013f6:	50                   	push   %eax
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	03 45 0c             	add    0xc(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	57                   	push   %edi
  8013fe:	e8 45 ff ff ff       	call   801348 <read>
		if (m < 0)
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 10                	js     80141a <readn+0x41>
			return m;
		if (m == 0)
  80140a:	85 c0                	test   %eax,%eax
  80140c:	74 0a                	je     801418 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80140e:	01 c3                	add    %eax,%ebx
  801410:	39 f3                	cmp    %esi,%ebx
  801412:	72 db                	jb     8013ef <readn+0x16>
  801414:	89 d8                	mov    %ebx,%eax
  801416:	eb 02                	jmp    80141a <readn+0x41>
  801418:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80141a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5e                   	pop    %esi
  80141f:	5f                   	pop    %edi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	53                   	push   %ebx
  801426:	83 ec 14             	sub    $0x14,%esp
  801429:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	53                   	push   %ebx
  801431:	e8 ac fc ff ff       	call   8010e2 <fd_lookup>
  801436:	83 c4 08             	add    $0x8,%esp
  801439:	89 c2                	mov    %eax,%edx
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 68                	js     8014a7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143f:	83 ec 08             	sub    $0x8,%esp
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801449:	ff 30                	pushl  (%eax)
  80144b:	e8 e8 fc ff ff       	call   801138 <dev_lookup>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 47                	js     80149e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145e:	75 21                	jne    801481 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801460:	a1 04 40 80 00       	mov    0x804004,%eax
  801465:	8b 40 48             	mov    0x48(%eax),%eax
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	53                   	push   %ebx
  80146c:	50                   	push   %eax
  80146d:	68 c9 27 80 00       	push   $0x8027c9
  801472:	e8 31 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147f:	eb 26                	jmp    8014a7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801481:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801484:	8b 52 0c             	mov    0xc(%edx),%edx
  801487:	85 d2                	test   %edx,%edx
  801489:	74 17                	je     8014a2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80148b:	83 ec 04             	sub    $0x4,%esp
  80148e:	ff 75 10             	pushl  0x10(%ebp)
  801491:	ff 75 0c             	pushl  0xc(%ebp)
  801494:	50                   	push   %eax
  801495:	ff d2                	call   *%edx
  801497:	89 c2                	mov    %eax,%edx
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	eb 09                	jmp    8014a7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	eb 05                	jmp    8014a7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014a7:	89 d0                	mov    %edx,%eax
  8014a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	ff 75 08             	pushl  0x8(%ebp)
  8014bb:	e8 22 fc ff ff       	call   8010e2 <fd_lookup>
  8014c0:	83 c4 08             	add    $0x8,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 0e                	js     8014d5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	53                   	push   %ebx
  8014db:	83 ec 14             	sub    $0x14,%esp
  8014de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e4:	50                   	push   %eax
  8014e5:	53                   	push   %ebx
  8014e6:	e8 f7 fb ff ff       	call   8010e2 <fd_lookup>
  8014eb:	83 c4 08             	add    $0x8,%esp
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 65                	js     801559 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fa:	50                   	push   %eax
  8014fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fe:	ff 30                	pushl  (%eax)
  801500:	e8 33 fc ff ff       	call   801138 <dev_lookup>
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 44                	js     801550 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801513:	75 21                	jne    801536 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801515:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80151a:	8b 40 48             	mov    0x48(%eax),%eax
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	53                   	push   %ebx
  801521:	50                   	push   %eax
  801522:	68 8c 27 80 00       	push   $0x80278c
  801527:	e8 7c ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801534:	eb 23                	jmp    801559 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801536:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801539:	8b 52 18             	mov    0x18(%edx),%edx
  80153c:	85 d2                	test   %edx,%edx
  80153e:	74 14                	je     801554 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	50                   	push   %eax
  801547:	ff d2                	call   *%edx
  801549:	89 c2                	mov    %eax,%edx
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	eb 09                	jmp    801559 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	89 c2                	mov    %eax,%edx
  801552:	eb 05                	jmp    801559 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801554:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801559:	89 d0                	mov    %edx,%eax
  80155b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	53                   	push   %ebx
  801564:	83 ec 14             	sub    $0x14,%esp
  801567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	ff 75 08             	pushl  0x8(%ebp)
  801571:	e8 6c fb ff ff       	call   8010e2 <fd_lookup>
  801576:	83 c4 08             	add    $0x8,%esp
  801579:	89 c2                	mov    %eax,%edx
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 58                	js     8015d7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	ff 30                	pushl  (%eax)
  80158b:	e8 a8 fb ff ff       	call   801138 <dev_lookup>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 37                	js     8015ce <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80159e:	74 32                	je     8015d2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015aa:	00 00 00 
	stat->st_isdir = 0;
  8015ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b4:	00 00 00 
	stat->st_dev = dev;
  8015b7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c4:	ff 50 14             	call   *0x14(%eax)
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	eb 09                	jmp    8015d7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	eb 05                	jmp    8015d7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015d7:	89 d0                	mov    %edx,%eax
  8015d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	6a 00                	push   $0x0
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	e8 d6 01 00 00       	call   8017c6 <open>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 1b                	js     801614 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	ff 75 0c             	pushl  0xc(%ebp)
  8015ff:	50                   	push   %eax
  801600:	e8 5b ff ff ff       	call   801560 <fstat>
  801605:	89 c6                	mov    %eax,%esi
	close(fd);
  801607:	89 1c 24             	mov    %ebx,(%esp)
  80160a:	e8 fd fb ff ff       	call   80120c <close>
	return r;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	89 f0                	mov    %esi,%eax
}
  801614:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	89 c6                	mov    %eax,%esi
  801622:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801624:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80162b:	75 12                	jne    80163f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80162d:	83 ec 0c             	sub    $0xc,%esp
  801630:	6a 01                	push   $0x1
  801632:	e8 dc 08 00 00       	call   801f13 <ipc_find_env>
  801637:	a3 00 40 80 00       	mov    %eax,0x804000
  80163c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163f:	6a 07                	push   $0x7
  801641:	68 00 50 80 00       	push   $0x805000
  801646:	56                   	push   %esi
  801647:	ff 35 00 40 80 00    	pushl  0x804000
  80164d:	e8 6d 08 00 00       	call   801ebf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801652:	83 c4 0c             	add    $0xc,%esp
  801655:	6a 00                	push   $0x0
  801657:	53                   	push   %ebx
  801658:	6a 00                	push   $0x0
  80165a:	e8 c8 07 00 00       	call   801e27 <ipc_recv>
}
  80165f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166c:	8b 45 08             	mov    0x8(%ebp),%eax
  80166f:	8b 40 0c             	mov    0xc(%eax),%eax
  801672:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801677:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167f:	ba 00 00 00 00       	mov    $0x0,%edx
  801684:	b8 02 00 00 00       	mov    $0x2,%eax
  801689:	e8 8d ff ff ff       	call   80161b <fsipc>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	8b 40 0c             	mov    0xc(%eax),%eax
  80169c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ab:	e8 6b ff ff ff       	call   80161b <fsipc>
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 04             	sub    $0x4,%esp
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d1:	e8 45 ff ff ff       	call   80161b <fsipc>
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 2c                	js     801706 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	68 00 50 80 00       	push   $0x805000
  8016e2:	53                   	push   %ebx
  8016e3:	e8 45 f0 ff ff       	call   80072d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016e8:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016f3:	a1 84 50 80 00       	mov    0x805084,%eax
  8016f8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801714:	8b 55 08             	mov    0x8(%ebp),%edx
  801717:	8b 52 0c             	mov    0xc(%edx),%edx
  80171a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801720:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801725:	50                   	push   %eax
  801726:	ff 75 0c             	pushl  0xc(%ebp)
  801729:	68 08 50 80 00       	push   $0x805008
  80172e:	e8 8c f1 ff ff       	call   8008bf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801733:	ba 00 00 00 00       	mov    $0x0,%edx
  801738:	b8 04 00 00 00       	mov    $0x4,%eax
  80173d:	e8 d9 fe ff ff       	call   80161b <fsipc>
	//panic("devfile_write not implemented");
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	8b 40 0c             	mov    0xc(%eax),%eax
  801752:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801757:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 03 00 00 00       	mov    $0x3,%eax
  801767:	e8 af fe ff ff       	call   80161b <fsipc>
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 4b                	js     8017bd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801772:	39 c6                	cmp    %eax,%esi
  801774:	73 16                	jae    80178c <devfile_read+0x48>
  801776:	68 f8 27 80 00       	push   $0x8027f8
  80177b:	68 ff 27 80 00       	push   $0x8027ff
  801780:	6a 7c                	push   $0x7c
  801782:	68 14 28 80 00       	push   $0x802814
  801787:	e8 bd 05 00 00       	call   801d49 <_panic>
	assert(r <= PGSIZE);
  80178c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801791:	7e 16                	jle    8017a9 <devfile_read+0x65>
  801793:	68 1f 28 80 00       	push   $0x80281f
  801798:	68 ff 27 80 00       	push   $0x8027ff
  80179d:	6a 7d                	push   $0x7d
  80179f:	68 14 28 80 00       	push   $0x802814
  8017a4:	e8 a0 05 00 00       	call   801d49 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017a9:	83 ec 04             	sub    $0x4,%esp
  8017ac:	50                   	push   %eax
  8017ad:	68 00 50 80 00       	push   $0x805000
  8017b2:	ff 75 0c             	pushl  0xc(%ebp)
  8017b5:	e8 05 f1 ff ff       	call   8008bf <memmove>
	return r;
  8017ba:	83 c4 10             	add    $0x10,%esp
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 20             	sub    $0x20,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017d0:	53                   	push   %ebx
  8017d1:	e8 1e ef ff ff       	call   8006f4 <strlen>
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017de:	7f 67                	jg     801847 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	50                   	push   %eax
  8017e7:	e8 a7 f8 ff ff       	call   801093 <fd_alloc>
  8017ec:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ef:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 57                	js     80184c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	53                   	push   %ebx
  8017f9:	68 00 50 80 00       	push   $0x805000
  8017fe:	e8 2a ef ff ff       	call   80072d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801803:	8b 45 0c             	mov    0xc(%ebp),%eax
  801806:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80180b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180e:	b8 01 00 00 00       	mov    $0x1,%eax
  801813:	e8 03 fe ff ff       	call   80161b <fsipc>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	79 14                	jns    801835 <open+0x6f>
		fd_close(fd, 0);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	6a 00                	push   $0x0
  801826:	ff 75 f4             	pushl  -0xc(%ebp)
  801829:	e8 5d f9 ff ff       	call   80118b <fd_close>
		return r;
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	89 da                	mov    %ebx,%edx
  801833:	eb 17                	jmp    80184c <open+0x86>
	}

	return fd2num(fd);
  801835:	83 ec 0c             	sub    $0xc,%esp
  801838:	ff 75 f4             	pushl  -0xc(%ebp)
  80183b:	e8 2c f8 ff ff       	call   80106c <fd2num>
  801840:	89 c2                	mov    %eax,%edx
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	eb 05                	jmp    80184c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801847:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 08 00 00 00       	mov    $0x8,%eax
  801863:	e8 b3 fd ff ff       	call   80161b <fsipc>
}
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	ff 75 08             	pushl  0x8(%ebp)
  801878:	e8 ff f7 ff ff       	call   80107c <fd2data>
  80187d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80187f:	83 c4 08             	add    $0x8,%esp
  801882:	68 2b 28 80 00       	push   $0x80282b
  801887:	53                   	push   %ebx
  801888:	e8 a0 ee ff ff       	call   80072d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80188d:	8b 46 04             	mov    0x4(%esi),%eax
  801890:	2b 06                	sub    (%esi),%eax
  801892:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80189f:	00 00 00 
	stat->st_dev = &devpipe;
  8018a2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018a9:	30 80 00 
	return 0;
}
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018c2:	53                   	push   %ebx
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 eb f2 ff ff       	call   800bb5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018ca:	89 1c 24             	mov    %ebx,(%esp)
  8018cd:	e8 aa f7 ff ff       	call   80107c <fd2data>
  8018d2:	83 c4 08             	add    $0x8,%esp
  8018d5:	50                   	push   %eax
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 d8 f2 ff ff       	call   800bb5 <sys_page_unmap>
}
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	57                   	push   %edi
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 1c             	sub    $0x1c,%esp
  8018eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ee:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018fe:	e8 49 06 00 00       	call   801f4c <pageref>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	89 3c 24             	mov    %edi,(%esp)
  801908:	e8 3f 06 00 00       	call   801f4c <pageref>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	39 c3                	cmp    %eax,%ebx
  801912:	0f 94 c1             	sete   %cl
  801915:	0f b6 c9             	movzbl %cl,%ecx
  801918:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80191b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801921:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801924:	39 ce                	cmp    %ecx,%esi
  801926:	74 1b                	je     801943 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801928:	39 c3                	cmp    %eax,%ebx
  80192a:	75 c4                	jne    8018f0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80192c:	8b 42 58             	mov    0x58(%edx),%eax
  80192f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801932:	50                   	push   %eax
  801933:	56                   	push   %esi
  801934:	68 32 28 80 00       	push   $0x802832
  801939:	e8 6a e8 ff ff       	call   8001a8 <cprintf>
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	eb ad                	jmp    8018f0 <_pipeisclosed+0xe>
	}
}
  801943:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801946:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5f                   	pop    %edi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	83 ec 28             	sub    $0x28,%esp
  801957:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80195a:	56                   	push   %esi
  80195b:	e8 1c f7 ff ff       	call   80107c <fd2data>
  801960:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	bf 00 00 00 00       	mov    $0x0,%edi
  80196a:	eb 4b                	jmp    8019b7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80196c:	89 da                	mov    %ebx,%edx
  80196e:	89 f0                	mov    %esi,%eax
  801970:	e8 6d ff ff ff       	call   8018e2 <_pipeisclosed>
  801975:	85 c0                	test   %eax,%eax
  801977:	75 48                	jne    8019c1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801979:	e8 93 f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80197e:	8b 43 04             	mov    0x4(%ebx),%eax
  801981:	8b 0b                	mov    (%ebx),%ecx
  801983:	8d 51 20             	lea    0x20(%ecx),%edx
  801986:	39 d0                	cmp    %edx,%eax
  801988:	73 e2                	jae    80196c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80198a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801991:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801994:	89 c2                	mov    %eax,%edx
  801996:	c1 fa 1f             	sar    $0x1f,%edx
  801999:	89 d1                	mov    %edx,%ecx
  80199b:	c1 e9 1b             	shr    $0x1b,%ecx
  80199e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019a1:	83 e2 1f             	and    $0x1f,%edx
  8019a4:	29 ca                	sub    %ecx,%edx
  8019a6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ae:	83 c0 01             	add    $0x1,%eax
  8019b1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b4:	83 c7 01             	add    $0x1,%edi
  8019b7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ba:	75 c2                	jne    80197e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bf:	eb 05                	jmp    8019c6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019c1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c9:	5b                   	pop    %ebx
  8019ca:	5e                   	pop    %esi
  8019cb:	5f                   	pop    %edi
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	57                   	push   %edi
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 18             	sub    $0x18,%esp
  8019d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019da:	57                   	push   %edi
  8019db:	e8 9c f6 ff ff       	call   80107c <fd2data>
  8019e0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ea:	eb 3d                	jmp    801a29 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ec:	85 db                	test   %ebx,%ebx
  8019ee:	74 04                	je     8019f4 <devpipe_read+0x26>
				return i;
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	eb 44                	jmp    801a38 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019f4:	89 f2                	mov    %esi,%edx
  8019f6:	89 f8                	mov    %edi,%eax
  8019f8:	e8 e5 fe ff ff       	call   8018e2 <_pipeisclosed>
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	75 32                	jne    801a33 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a01:	e8 0b f1 ff ff       	call   800b11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a06:	8b 06                	mov    (%esi),%eax
  801a08:	3b 46 04             	cmp    0x4(%esi),%eax
  801a0b:	74 df                	je     8019ec <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a0d:	99                   	cltd   
  801a0e:	c1 ea 1b             	shr    $0x1b,%edx
  801a11:	01 d0                	add    %edx,%eax
  801a13:	83 e0 1f             	and    $0x1f,%eax
  801a16:	29 d0                	sub    %edx,%eax
  801a18:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a20:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a23:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a26:	83 c3 01             	add    $0x1,%ebx
  801a29:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a2c:	75 d8                	jne    801a06 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a2e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a31:	eb 05                	jmp    801a38 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5f                   	pop    %edi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4b:	50                   	push   %eax
  801a4c:	e8 42 f6 ff ff       	call   801093 <fd_alloc>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	89 c2                	mov    %eax,%edx
  801a56:	85 c0                	test   %eax,%eax
  801a58:	0f 88 2c 01 00 00    	js     801b8a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5e:	83 ec 04             	sub    $0x4,%esp
  801a61:	68 07 04 00 00       	push   $0x407
  801a66:	ff 75 f4             	pushl  -0xc(%ebp)
  801a69:	6a 00                	push   $0x0
  801a6b:	e8 c0 f0 ff ff       	call   800b30 <sys_page_alloc>
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	89 c2                	mov    %eax,%edx
  801a75:	85 c0                	test   %eax,%eax
  801a77:	0f 88 0d 01 00 00    	js     801b8a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a83:	50                   	push   %eax
  801a84:	e8 0a f6 ff ff       	call   801093 <fd_alloc>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	0f 88 e2 00 00 00    	js     801b78 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a96:	83 ec 04             	sub    $0x4,%esp
  801a99:	68 07 04 00 00       	push   $0x407
  801a9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 88 f0 ff ff       	call   800b30 <sys_page_alloc>
  801aa8:	89 c3                	mov    %eax,%ebx
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	0f 88 c3 00 00 00    	js     801b78 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 f4             	pushl  -0xc(%ebp)
  801abb:	e8 bc f5 ff ff       	call   80107c <fd2data>
  801ac0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac2:	83 c4 0c             	add    $0xc,%esp
  801ac5:	68 07 04 00 00       	push   $0x407
  801aca:	50                   	push   %eax
  801acb:	6a 00                	push   $0x0
  801acd:	e8 5e f0 ff ff       	call   800b30 <sys_page_alloc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	0f 88 89 00 00 00    	js     801b68 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae5:	e8 92 f5 ff ff       	call   80107c <fd2data>
  801aea:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801af1:	50                   	push   %eax
  801af2:	6a 00                	push   $0x0
  801af4:	56                   	push   %esi
  801af5:	6a 00                	push   $0x0
  801af7:	e8 77 f0 ff ff       	call   800b73 <sys_page_map>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	83 c4 20             	add    $0x20,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 55                	js     801b5a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b1a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b23:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b2f:	83 ec 0c             	sub    $0xc,%esp
  801b32:	ff 75 f4             	pushl  -0xc(%ebp)
  801b35:	e8 32 f5 ff ff       	call   80106c <fd2num>
  801b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b3f:	83 c4 04             	add    $0x4,%esp
  801b42:	ff 75 f0             	pushl  -0x10(%ebp)
  801b45:	e8 22 f5 ff ff       	call   80106c <fd2num>
  801b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	ba 00 00 00 00       	mov    $0x0,%edx
  801b58:	eb 30                	jmp    801b8a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b5a:	83 ec 08             	sub    $0x8,%esp
  801b5d:	56                   	push   %esi
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 50 f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b65:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b68:	83 ec 08             	sub    $0x8,%esp
  801b6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 40 f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b75:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b78:	83 ec 08             	sub    $0x8,%esp
  801b7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 30 f0 ff ff       	call   800bb5 <sys_page_unmap>
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b8a:	89 d0                	mov    %edx,%eax
  801b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9c:	50                   	push   %eax
  801b9d:	ff 75 08             	pushl  0x8(%ebp)
  801ba0:	e8 3d f5 ff ff       	call   8010e2 <fd_lookup>
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 18                	js     801bc4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bac:	83 ec 0c             	sub    $0xc,%esp
  801baf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb2:	e8 c5 f4 ff ff       	call   80107c <fd2data>
	return _pipeisclosed(fd, p);
  801bb7:	89 c2                	mov    %eax,%edx
  801bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbc:	e8 21 fd ff ff       	call   8018e2 <_pipeisclosed>
  801bc1:	83 c4 10             	add    $0x10,%esp
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bd6:	68 4a 28 80 00       	push   $0x80284a
  801bdb:	ff 75 0c             	pushl  0xc(%ebp)
  801bde:	e8 4a eb ff ff       	call   80072d <strcpy>
	return 0;
}
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	57                   	push   %edi
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bfb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c01:	eb 2d                	jmp    801c30 <devcons_write+0x46>
		m = n - tot;
  801c03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c06:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c08:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c0b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c10:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	53                   	push   %ebx
  801c17:	03 45 0c             	add    0xc(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	57                   	push   %edi
  801c1c:	e8 9e ec ff ff       	call   8008bf <memmove>
		sys_cputs(buf, m);
  801c21:	83 c4 08             	add    $0x8,%esp
  801c24:	53                   	push   %ebx
  801c25:	57                   	push   %edi
  801c26:	e8 49 ee ff ff       	call   800a74 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2b:	01 de                	add    %ebx,%esi
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	89 f0                	mov    %esi,%eax
  801c32:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c35:	72 cc                	jb     801c03 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5f                   	pop    %edi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4e:	74 2a                	je     801c7a <devcons_read+0x3b>
  801c50:	eb 05                	jmp    801c57 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c52:	e8 ba ee ff ff       	call   800b11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c57:	e8 36 ee ff ff       	call   800a92 <sys_cgetc>
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	74 f2                	je     801c52 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 16                	js     801c7a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c64:	83 f8 04             	cmp    $0x4,%eax
  801c67:	74 0c                	je     801c75 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6c:	88 02                	mov    %al,(%edx)
	return 1;
  801c6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c73:	eb 05                	jmp    801c7a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c88:	6a 01                	push   $0x1
  801c8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8d:	50                   	push   %eax
  801c8e:	e8 e1 ed ff ff       	call   800a74 <sys_cputs>
}
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <getchar>:

int
getchar(void)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c9e:	6a 01                	push   $0x1
  801ca0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca3:	50                   	push   %eax
  801ca4:	6a 00                	push   $0x0
  801ca6:	e8 9d f6 ff ff       	call   801348 <read>
	if (r < 0)
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 0f                	js     801cc1 <getchar+0x29>
		return r;
	if (r < 1)
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	7e 06                	jle    801cbc <getchar+0x24>
		return -E_EOF;
	return c;
  801cb6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cba:	eb 05                	jmp    801cc1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cbc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cc1:	c9                   	leave  
  801cc2:	c3                   	ret    

00801cc3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	ff 75 08             	pushl  0x8(%ebp)
  801cd0:	e8 0d f4 ff ff       	call   8010e2 <fd_lookup>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 11                	js     801ced <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce5:	39 10                	cmp    %edx,(%eax)
  801ce7:	0f 94 c0             	sete   %al
  801cea:	0f b6 c0             	movzbl %al,%eax
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <opencons>:

int
opencons(void)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf8:	50                   	push   %eax
  801cf9:	e8 95 f3 ff ff       	call   801093 <fd_alloc>
  801cfe:	83 c4 10             	add    $0x10,%esp
		return r;
  801d01:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 3e                	js     801d45 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d07:	83 ec 04             	sub    $0x4,%esp
  801d0a:	68 07 04 00 00       	push   $0x407
  801d0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d12:	6a 00                	push   $0x0
  801d14:	e8 17 ee ff ff       	call   800b30 <sys_page_alloc>
  801d19:	83 c4 10             	add    $0x10,%esp
		return r;
  801d1c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 23                	js     801d45 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d22:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d30:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	50                   	push   %eax
  801d3b:	e8 2c f3 ff ff       	call   80106c <fd2num>
  801d40:	89 c2                	mov    %eax,%edx
  801d42:	83 c4 10             	add    $0x10,%esp
}
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	56                   	push   %esi
  801d4d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d4e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d51:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d57:	e8 96 ed ff ff       	call   800af2 <sys_getenvid>
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 0c             	pushl  0xc(%ebp)
  801d62:	ff 75 08             	pushl  0x8(%ebp)
  801d65:	56                   	push   %esi
  801d66:	50                   	push   %eax
  801d67:	68 58 28 80 00       	push   $0x802858
  801d6c:	e8 37 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d71:	83 c4 18             	add    $0x18,%esp
  801d74:	53                   	push   %ebx
  801d75:	ff 75 10             	pushl  0x10(%ebp)
  801d78:	e8 da e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d7d:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  801d84:	e8 1f e4 ff ff       	call   8001a8 <cprintf>
  801d89:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d8c:	cc                   	int3   
  801d8d:	eb fd                	jmp    801d8c <_panic+0x43>

00801d8f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	53                   	push   %ebx
  801d93:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d96:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d9d:	75 57                	jne    801df6 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801d9f:	e8 4e ed ff ff       	call   800af2 <sys_getenvid>
  801da4:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	6a 07                	push   $0x7
  801dab:	68 00 f0 bf ee       	push   $0xeebff000
  801db0:	50                   	push   %eax
  801db1:	e8 7a ed ff ff       	call   800b30 <sys_page_alloc>
		if (r) {
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	74 12                	je     801dcf <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801dbd:	50                   	push   %eax
  801dbe:	68 ba 26 80 00       	push   $0x8026ba
  801dc3:	6a 25                	push   $0x25
  801dc5:	68 7b 28 80 00       	push   $0x80287b
  801dca:	e8 7a ff ff ff       	call   801d49 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801dcf:	83 ec 08             	sub    $0x8,%esp
  801dd2:	68 03 1e 80 00       	push   $0x801e03
  801dd7:	53                   	push   %ebx
  801dd8:	e8 9e ee ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
		if (r) {
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	85 c0                	test   %eax,%eax
  801de2:	74 12                	je     801df6 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801de4:	50                   	push   %eax
  801de5:	68 8c 28 80 00       	push   $0x80288c
  801dea:	6a 2b                	push   $0x2b
  801dec:	68 7b 28 80 00       	push   $0x80287b
  801df1:	e8 53 ff ff ff       	call   801d49 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e03:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e04:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e09:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e0b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801e0e:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801e12:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801e17:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801e1b:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801e1d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801e20:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801e21:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801e24:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801e25:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801e26:	c3                   	ret    

00801e27 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801e35:	85 c0                	test   %eax,%eax
  801e37:	74 3e                	je     801e77 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	50                   	push   %eax
  801e3d:	e8 9e ee ff ff       	call   800ce0 <sys_ipc_recv>
  801e42:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 f6                	test   %esi,%esi
  801e49:	74 13                	je     801e5e <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e50:	85 d2                	test   %edx,%edx
  801e52:	75 08                	jne    801e5c <ipc_recv+0x35>
  801e54:	a1 04 40 80 00       	mov    0x804004,%eax
  801e59:	8b 40 74             	mov    0x74(%eax),%eax
  801e5c:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801e5e:	85 db                	test   %ebx,%ebx
  801e60:	74 48                	je     801eaa <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801e62:	b8 00 00 00 00       	mov    $0x0,%eax
  801e67:	85 d2                	test   %edx,%edx
  801e69:	75 08                	jne    801e73 <ipc_recv+0x4c>
  801e6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e70:	8b 40 78             	mov    0x78(%eax),%eax
  801e73:	89 03                	mov    %eax,(%ebx)
  801e75:	eb 33                	jmp    801eaa <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	68 00 00 c0 ee       	push   $0xeec00000
  801e7f:	e8 5c ee ff ff       	call   800ce0 <sys_ipc_recv>
  801e84:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	85 f6                	test   %esi,%esi
  801e8b:	74 13                	je     801ea0 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e92:	85 d2                	test   %edx,%edx
  801e94:	75 08                	jne    801e9e <ipc_recv+0x77>
  801e96:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9b:	8b 40 74             	mov    0x74(%eax),%eax
  801e9e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ea0:	85 db                	test   %ebx,%ebx
  801ea2:	74 06                	je     801eaa <ipc_recv+0x83>
			*perm_store = 0;
  801ea4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801eaa:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801eac:	85 d2                	test   %edx,%edx
  801eae:	75 08                	jne    801eb8 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801eb0:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb5:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801eb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	57                   	push   %edi
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	83 ec 0c             	sub    $0xc,%esp
  801ec8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ecb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801ed1:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ed8:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801edb:	eb 1c                	jmp    801ef9 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801edd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee0:	74 12                	je     801ef4 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801ee2:	50                   	push   %eax
  801ee3:	68 b4 28 80 00       	push   $0x8028b4
  801ee8:	6a 4f                	push   $0x4f
  801eea:	68 cf 28 80 00       	push   $0x8028cf
  801eef:	e8 55 fe ff ff       	call   801d49 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801ef4:	e8 18 ec ff ff       	call   800b11 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ef9:	ff 75 14             	pushl  0x14(%ebp)
  801efc:	53                   	push   %ebx
  801efd:	56                   	push   %esi
  801efe:	57                   	push   %edi
  801eff:	e8 b9 ed ff ff       	call   800cbd <sys_ipc_try_send>
  801f04:	83 c4 10             	add    $0x10,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 d2                	js     801edd <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5f                   	pop    %edi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f19:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f1e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f21:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f27:	8b 52 50             	mov    0x50(%edx),%edx
  801f2a:	39 ca                	cmp    %ecx,%edx
  801f2c:	75 0d                	jne    801f3b <ipc_find_env+0x28>
			return envs[i].env_id;
  801f2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f31:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f36:	8b 40 48             	mov    0x48(%eax),%eax
  801f39:	eb 0f                	jmp    801f4a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3b:	83 c0 01             	add    $0x1,%eax
  801f3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f43:	75 d9                	jne    801f1e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f52:	89 d0                	mov    %edx,%eax
  801f54:	c1 e8 16             	shr    $0x16,%eax
  801f57:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f63:	f6 c1 01             	test   $0x1,%cl
  801f66:	74 1d                	je     801f85 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f68:	c1 ea 0c             	shr    $0xc,%edx
  801f6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f72:	f6 c2 01             	test   $0x1,%dl
  801f75:	74 0e                	je     801f85 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f77:	c1 ea 0c             	shr    $0xc,%edx
  801f7a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f81:	ef 
  801f82:	0f b7 c0             	movzwl %ax,%eax
}
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    
  801f87:	66 90                	xchg   %ax,%ax
  801f89:	66 90                	xchg   %ax,%ax
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

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
