
obj/user/faultread.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 e0 1d 80 00       	push   $0x801de0
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 2d 0a 00 00       	call   800a8b <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 e6 0d 00 00       	call   800e85 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 a1 09 00 00       	call   800a4a <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 2f 09 00 00       	call   800a0d <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 54 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 d4 08 00 00       	call   800a0d <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 97 19 00 00       	call   801b40 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 84 1a 00 00       	call   801c70 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 08 1e 80 00 	movsbl 0x801e08(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800207:	83 fa 01             	cmp    $0x1,%edx
  80020a:	7e 0e                	jle    80021a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020c:	8b 10                	mov    (%eax),%edx
  80020e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800211:	89 08                	mov    %ecx,(%eax)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	8b 52 04             	mov    0x4(%edx),%edx
  800218:	eb 22                	jmp    80023c <getuint+0x38>
	else if (lflag)
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 10                	je     80022e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 04             	lea    0x4(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	ba 00 00 00 00       	mov    $0x0,%edx
  80022c:	eb 0e                	jmp    80023c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	3b 50 04             	cmp    0x4(%eax),%edx
  80024d:	73 0a                	jae    800259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	88 02                	mov    %al,(%edx)
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 05 00 00 00       	call   800278 <vprintfmt>
	va_end(ap);
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	eb 12                	jmp    80029e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028c:	85 c0                	test   %eax,%eax
  80028e:	0f 84 89 03 00 00    	je     80061d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	53                   	push   %ebx
  800298:	50                   	push   %eax
  800299:	ff d6                	call   *%esi
  80029b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029e:	83 c7 01             	add    $0x1,%edi
  8002a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 e2                	jne    80028c <vprintfmt+0x14>
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	eb 07                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002cd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8d 47 01             	lea    0x1(%edi),%eax
  8002d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d7:	0f b6 07             	movzbl (%edi),%eax
  8002da:	0f b6 c8             	movzbl %al,%ecx
  8002dd:	83 e8 23             	sub    $0x23,%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 1a 03 00 00    	ja     800602 <vprintfmt+0x38a>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f9:	eb d6                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800310:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800313:	83 fa 09             	cmp    $0x9,%edx
  800316:	77 39                	ja     800351 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 48 04             	lea    0x4(%eax),%ecx
  800323:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800326:	8b 00                	mov    (%eax),%eax
  800328:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032e:	eb 27                	jmp    800357 <vprintfmt+0xdf>
  800330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800333:	85 c0                	test   %eax,%eax
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	0f 49 c8             	cmovns %eax,%ecx
  80033d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800343:	eb 8c                	jmp    8002d1 <vprintfmt+0x59>
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800348:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034f:	eb 80                	jmp    8002d1 <vprintfmt+0x59>
  800351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800354:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	0f 89 70 ff ff ff    	jns    8002d1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800361:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800364:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800367:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036e:	e9 5e ff ff ff       	jmp    8002d1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800373:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800379:	e9 53 ff ff ff       	jmp    8002d1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 50 04             	lea    0x4(%eax),%edx
  800384:	89 55 14             	mov    %edx,0x14(%ebp)
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	ff 30                	pushl  (%eax)
  80038d:	ff d6                	call   *%esi
			break;
  80038f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800395:	e9 04 ff ff ff       	jmp    80029e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 50 04             	lea    0x4(%eax),%edx
  8003a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	99                   	cltd   
  8003a6:	31 d0                	xor    %edx,%eax
  8003a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003aa:	83 f8 0f             	cmp    $0xf,%eax
  8003ad:	7f 0b                	jg     8003ba <vprintfmt+0x142>
  8003af:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	75 18                	jne    8003d2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 20 1e 80 00       	push   $0x801e20
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 94 fe ff ff       	call   80025b <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cd:	e9 cc fe ff ff       	jmp    80029e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d2:	52                   	push   %edx
  8003d3:	68 d1 21 80 00       	push   $0x8021d1
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 7c fe ff ff       	call   80025b <printfmt>
  8003df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e5:	e9 b4 fe ff ff       	jmp    80029e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	b8 19 1e 80 00       	mov    $0x801e19,%eax
  8003fc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 8e 94 00 00 00    	jle    80049d <vprintfmt+0x225>
  800409:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040d:	0f 84 98 00 00 00    	je     8004ab <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	ff 75 d0             	pushl  -0x30(%ebp)
  800419:	57                   	push   %edi
  80041a:	e8 86 02 00 00       	call   8006a5 <strnlen>
  80041f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800422:	29 c1                	sub    %eax,%ecx
  800424:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800431:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800434:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	eb 0f                	jmp    800447 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 75 e0             	pushl  -0x20(%ebp)
  80043f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ef 01             	sub    $0x1,%edi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 ff                	test   %edi,%edi
  800449:	7f ed                	jg     800438 <vprintfmt+0x1c0>
  80044b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800451:	85 c9                	test   %ecx,%ecx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c1             	cmovns %ecx,%eax
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 75 08             	mov    %esi,0x8(%ebp)
  800460:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800463:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800466:	89 cb                	mov    %ecx,%ebx
  800468:	eb 4d                	jmp    8004b7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046e:	74 1b                	je     80048b <vprintfmt+0x213>
  800470:	0f be c0             	movsbl %al,%eax
  800473:	83 e8 20             	sub    $0x20,%eax
  800476:	83 f8 5e             	cmp    $0x5e,%eax
  800479:	76 10                	jbe    80048b <vprintfmt+0x213>
					putch('?', putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	6a 3f                	push   $0x3f
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	eb 0d                	jmp    800498 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	52                   	push   %edx
  800492:	ff 55 08             	call   *0x8(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	eb 1a                	jmp    8004b7 <vprintfmt+0x23f>
  80049d:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a9:	eb 0c                	jmp    8004b7 <vprintfmt+0x23f>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	83 c7 01             	add    $0x1,%edi
  8004ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004be:	0f be d0             	movsbl %al,%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 23                	je     8004e8 <vprintfmt+0x270>
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	78 a1                	js     80046a <vprintfmt+0x1f2>
  8004c9:	83 ee 01             	sub    $0x1,%esi
  8004cc:	79 9c                	jns    80046a <vprintfmt+0x1f2>
  8004ce:	89 df                	mov    %ebx,%edi
  8004d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d6:	eb 18                	jmp    8004f0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	6a 20                	push   $0x20
  8004de:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e0:	83 ef 01             	sub    $0x1,%edi
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 08                	jmp    8004f0 <vprintfmt+0x278>
  8004e8:	89 df                	mov    %ebx,%edi
  8004ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f e4                	jg     8004d8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f7:	e9 a2 fd ff ff       	jmp    80029e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fc:	83 fa 01             	cmp    $0x1,%edx
  8004ff:	7e 16                	jle    800517 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 08             	lea    0x8(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	8b 50 04             	mov    0x4(%eax),%edx
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800512:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800515:	eb 32                	jmp    800549 <vprintfmt+0x2d1>
	else if (lflag)
  800517:	85 d2                	test   %edx,%edx
  800519:	74 18                	je     800533 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	eb 16                	jmp    800549 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800541:	89 c1                	mov    %eax,%ecx
  800543:	c1 f9 1f             	sar    $0x1f,%ecx
  800546:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800549:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800554:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800558:	79 74                	jns    8005ce <vprintfmt+0x356>
				putch('-', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	6a 2d                	push   $0x2d
  800560:	ff d6                	call   *%esi
				num = -(long long) num;
  800562:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800565:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800568:	f7 d8                	neg    %eax
  80056a:	83 d2 00             	adc    $0x0,%edx
  80056d:	f7 da                	neg    %edx
  80056f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800572:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800577:	eb 55                	jmp    8005ce <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800579:	8d 45 14             	lea    0x14(%ebp),%eax
  80057c:	e8 83 fc ff ff       	call   800204 <getuint>
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800586:	eb 46                	jmp    8005ce <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800588:	8d 45 14             	lea    0x14(%ebp),%eax
  80058b:	e8 74 fc ff ff       	call   800204 <getuint>
			base=8;
  800590:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800595:	eb 37                	jmp    8005ce <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 30                	push   $0x30
  80059d:	ff d6                	call   *%esi
			putch('x', putdat);
  80059f:	83 c4 08             	add    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 78                	push   $0x78
  8005a5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 50 04             	lea    0x4(%eax),%edx
  8005ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ba:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005bf:	eb 0d                	jmp    8005ce <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c4:	e8 3b fc ff ff       	call   800204 <getuint>
			base = 16;
  8005c9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ce:	83 ec 0c             	sub    $0xc,%esp
  8005d1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d5:	57                   	push   %edi
  8005d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d9:	51                   	push   %ecx
  8005da:	52                   	push   %edx
  8005db:	50                   	push   %eax
  8005dc:	89 da                	mov    %ebx,%edx
  8005de:	89 f0                	mov    %esi,%eax
  8005e0:	e8 70 fb ff ff       	call   800155 <printnum>
			break;
  8005e5:	83 c4 20             	add    $0x20,%esp
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005eb:	e9 ae fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	51                   	push   %ecx
  8005f5:	ff d6                	call   *%esi
			break;
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8005fd:	e9 9c fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 25                	push   $0x25
  800608:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	eb 03                	jmp    800612 <vprintfmt+0x39a>
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800616:	75 f7                	jne    80060f <vprintfmt+0x397>
  800618:	e9 81 fc ff ff       	jmp    80029e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80061d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800620:	5b                   	pop    %ebx
  800621:	5e                   	pop    %esi
  800622:	5f                   	pop    %edi
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 18             	sub    $0x18,%esp
  80062b:	8b 45 08             	mov    0x8(%ebp),%eax
  80062e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800634:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800638:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80063b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800642:	85 c0                	test   %eax,%eax
  800644:	74 26                	je     80066c <vsnprintf+0x47>
  800646:	85 d2                	test   %edx,%edx
  800648:	7e 22                	jle    80066c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80064a:	ff 75 14             	pushl  0x14(%ebp)
  80064d:	ff 75 10             	pushl  0x10(%ebp)
  800650:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	68 3e 02 80 00       	push   $0x80023e
  800659:	e8 1a fc ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800661:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800664:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	eb 05                	jmp    800671 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80066c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800671:	c9                   	leave  
  800672:	c3                   	ret    

00800673 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80067c:	50                   	push   %eax
  80067d:	ff 75 10             	pushl  0x10(%ebp)
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	ff 75 08             	pushl  0x8(%ebp)
  800686:	e8 9a ff ff ff       	call   800625 <vsnprintf>
	va_end(ap);

	return rc;
}
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    

0080068d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800693:	b8 00 00 00 00       	mov    $0x0,%eax
  800698:	eb 03                	jmp    80069d <strlen+0x10>
		n++;
  80069a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80069d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a1:	75 f7                	jne    80069a <strlen+0xd>
		n++;
	return n;
}
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b3:	eb 03                	jmp    8006b8 <strnlen+0x13>
		n++;
  8006b5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b8:	39 c2                	cmp    %eax,%edx
  8006ba:	74 08                	je     8006c4 <strnlen+0x1f>
  8006bc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006c0:	75 f3                	jne    8006b5 <strnlen+0x10>
  8006c2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	53                   	push   %ebx
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	83 c2 01             	add    $0x1,%edx
  8006d5:	83 c1 01             	add    $0x1,%ecx
  8006d8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006df:	84 db                	test   %bl,%bl
  8006e1:	75 ef                	jne    8006d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006e3:	5b                   	pop    %ebx
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	53                   	push   %ebx
  8006ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ed:	53                   	push   %ebx
  8006ee:	e8 9a ff ff ff       	call   80068d <strlen>
  8006f3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	01 d8                	add    %ebx,%eax
  8006fb:	50                   	push   %eax
  8006fc:	e8 c5 ff ff ff       	call   8006c6 <strcpy>
	return dst;
}
  800701:	89 d8                	mov    %ebx,%eax
  800703:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	8b 75 08             	mov    0x8(%ebp),%esi
  800710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800713:	89 f3                	mov    %esi,%ebx
  800715:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800718:	89 f2                	mov    %esi,%edx
  80071a:	eb 0f                	jmp    80072b <strncpy+0x23>
		*dst++ = *src;
  80071c:	83 c2 01             	add    $0x1,%edx
  80071f:	0f b6 01             	movzbl (%ecx),%eax
  800722:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800725:	80 39 01             	cmpb   $0x1,(%ecx)
  800728:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072b:	39 da                	cmp    %ebx,%edx
  80072d:	75 ed                	jne    80071c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80072f:	89 f0                	mov    %esi,%eax
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	56                   	push   %esi
  800739:	53                   	push   %ebx
  80073a:	8b 75 08             	mov    0x8(%ebp),%esi
  80073d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800740:	8b 55 10             	mov    0x10(%ebp),%edx
  800743:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800745:	85 d2                	test   %edx,%edx
  800747:	74 21                	je     80076a <strlcpy+0x35>
  800749:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80074d:	89 f2                	mov    %esi,%edx
  80074f:	eb 09                	jmp    80075a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80075a:	39 c2                	cmp    %eax,%edx
  80075c:	74 09                	je     800767 <strlcpy+0x32>
  80075e:	0f b6 19             	movzbl (%ecx),%ebx
  800761:	84 db                	test   %bl,%bl
  800763:	75 ec                	jne    800751 <strlcpy+0x1c>
  800765:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800767:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80076a:	29 f0                	sub    %esi,%eax
}
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800779:	eb 06                	jmp    800781 <strcmp+0x11>
		p++, q++;
  80077b:	83 c1 01             	add    $0x1,%ecx
  80077e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800781:	0f b6 01             	movzbl (%ecx),%eax
  800784:	84 c0                	test   %al,%al
  800786:	74 04                	je     80078c <strcmp+0x1c>
  800788:	3a 02                	cmp    (%edx),%al
  80078a:	74 ef                	je     80077b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80078c:	0f b6 c0             	movzbl %al,%eax
  80078f:	0f b6 12             	movzbl (%edx),%edx
  800792:	29 d0                	sub    %edx,%eax
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a0:	89 c3                	mov    %eax,%ebx
  8007a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a5:	eb 06                	jmp    8007ad <strncmp+0x17>
		n--, p++, q++;
  8007a7:	83 c0 01             	add    $0x1,%eax
  8007aa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ad:	39 d8                	cmp    %ebx,%eax
  8007af:	74 15                	je     8007c6 <strncmp+0x30>
  8007b1:	0f b6 08             	movzbl (%eax),%ecx
  8007b4:	84 c9                	test   %cl,%cl
  8007b6:	74 04                	je     8007bc <strncmp+0x26>
  8007b8:	3a 0a                	cmp    (%edx),%cl
  8007ba:	74 eb                	je     8007a7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bc:	0f b6 00             	movzbl (%eax),%eax
  8007bf:	0f b6 12             	movzbl (%edx),%edx
  8007c2:	29 d0                	sub    %edx,%eax
  8007c4:	eb 05                	jmp    8007cb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d8:	eb 07                	jmp    8007e1 <strchr+0x13>
		if (*s == c)
  8007da:	38 ca                	cmp    %cl,%dl
  8007dc:	74 0f                	je     8007ed <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007de:	83 c0 01             	add    $0x1,%eax
  8007e1:	0f b6 10             	movzbl (%eax),%edx
  8007e4:	84 d2                	test   %dl,%dl
  8007e6:	75 f2                	jne    8007da <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f9:	eb 03                	jmp    8007fe <strfind+0xf>
  8007fb:	83 c0 01             	add    $0x1,%eax
  8007fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800801:	38 ca                	cmp    %cl,%dl
  800803:	74 04                	je     800809 <strfind+0x1a>
  800805:	84 d2                	test   %dl,%dl
  800807:	75 f2                	jne    8007fb <strfind+0xc>
			break;
	return (char *) s;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	57                   	push   %edi
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 7d 08             	mov    0x8(%ebp),%edi
  800814:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800817:	85 c9                	test   %ecx,%ecx
  800819:	74 36                	je     800851 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80081b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800821:	75 28                	jne    80084b <memset+0x40>
  800823:	f6 c1 03             	test   $0x3,%cl
  800826:	75 23                	jne    80084b <memset+0x40>
		c &= 0xFF;
  800828:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80082c:	89 d3                	mov    %edx,%ebx
  80082e:	c1 e3 08             	shl    $0x8,%ebx
  800831:	89 d6                	mov    %edx,%esi
  800833:	c1 e6 18             	shl    $0x18,%esi
  800836:	89 d0                	mov    %edx,%eax
  800838:	c1 e0 10             	shl    $0x10,%eax
  80083b:	09 f0                	or     %esi,%eax
  80083d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80083f:	89 d8                	mov    %ebx,%eax
  800841:	09 d0                	or     %edx,%eax
  800843:	c1 e9 02             	shr    $0x2,%ecx
  800846:	fc                   	cld    
  800847:	f3 ab                	rep stos %eax,%es:(%edi)
  800849:	eb 06                	jmp    800851 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	fc                   	cld    
  80084f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800851:	89 f8                	mov    %edi,%eax
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5f                   	pop    %edi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	57                   	push   %edi
  80085c:	56                   	push   %esi
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 75 0c             	mov    0xc(%ebp),%esi
  800863:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800866:	39 c6                	cmp    %eax,%esi
  800868:	73 35                	jae    80089f <memmove+0x47>
  80086a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80086d:	39 d0                	cmp    %edx,%eax
  80086f:	73 2e                	jae    80089f <memmove+0x47>
		s += n;
		d += n;
  800871:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800874:	89 d6                	mov    %edx,%esi
  800876:	09 fe                	or     %edi,%esi
  800878:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087e:	75 13                	jne    800893 <memmove+0x3b>
  800880:	f6 c1 03             	test   $0x3,%cl
  800883:	75 0e                	jne    800893 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800885:	83 ef 04             	sub    $0x4,%edi
  800888:	8d 72 fc             	lea    -0x4(%edx),%esi
  80088b:	c1 e9 02             	shr    $0x2,%ecx
  80088e:	fd                   	std    
  80088f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800891:	eb 09                	jmp    80089c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800893:	83 ef 01             	sub    $0x1,%edi
  800896:	8d 72 ff             	lea    -0x1(%edx),%esi
  800899:	fd                   	std    
  80089a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80089c:	fc                   	cld    
  80089d:	eb 1d                	jmp    8008bc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089f:	89 f2                	mov    %esi,%edx
  8008a1:	09 c2                	or     %eax,%edx
  8008a3:	f6 c2 03             	test   $0x3,%dl
  8008a6:	75 0f                	jne    8008b7 <memmove+0x5f>
  8008a8:	f6 c1 03             	test   $0x3,%cl
  8008ab:	75 0a                	jne    8008b7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ad:	c1 e9 02             	shr    $0x2,%ecx
  8008b0:	89 c7                	mov    %eax,%edi
  8008b2:	fc                   	cld    
  8008b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b5:	eb 05                	jmp    8008bc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b7:	89 c7                	mov    %eax,%edi
  8008b9:	fc                   	cld    
  8008ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	ff 75 0c             	pushl  0xc(%ebp)
  8008c9:	ff 75 08             	pushl  0x8(%ebp)
  8008cc:	e8 87 ff ff ff       	call   800858 <memmove>
}
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	89 c6                	mov    %eax,%esi
  8008e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e3:	eb 1a                	jmp    8008ff <memcmp+0x2c>
		if (*s1 != *s2)
  8008e5:	0f b6 08             	movzbl (%eax),%ecx
  8008e8:	0f b6 1a             	movzbl (%edx),%ebx
  8008eb:	38 d9                	cmp    %bl,%cl
  8008ed:	74 0a                	je     8008f9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008ef:	0f b6 c1             	movzbl %cl,%eax
  8008f2:	0f b6 db             	movzbl %bl,%ebx
  8008f5:	29 d8                	sub    %ebx,%eax
  8008f7:	eb 0f                	jmp    800908 <memcmp+0x35>
		s1++, s2++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ff:	39 f0                	cmp    %esi,%eax
  800901:	75 e2                	jne    8008e5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800913:	89 c1                	mov    %eax,%ecx
  800915:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800918:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091c:	eb 0a                	jmp    800928 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	39 da                	cmp    %ebx,%edx
  800923:	74 07                	je     80092c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	39 c8                	cmp    %ecx,%eax
  80092a:	72 f2                	jb     80091e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80092c:	5b                   	pop    %ebx
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800938:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80093b:	eb 03                	jmp    800940 <strtol+0x11>
		s++;
  80093d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800940:	0f b6 01             	movzbl (%ecx),%eax
  800943:	3c 20                	cmp    $0x20,%al
  800945:	74 f6                	je     80093d <strtol+0xe>
  800947:	3c 09                	cmp    $0x9,%al
  800949:	74 f2                	je     80093d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80094b:	3c 2b                	cmp    $0x2b,%al
  80094d:	75 0a                	jne    800959 <strtol+0x2a>
		s++;
  80094f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800952:	bf 00 00 00 00       	mov    $0x0,%edi
  800957:	eb 11                	jmp    80096a <strtol+0x3b>
  800959:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80095e:	3c 2d                	cmp    $0x2d,%al
  800960:	75 08                	jne    80096a <strtol+0x3b>
		s++, neg = 1;
  800962:	83 c1 01             	add    $0x1,%ecx
  800965:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80096a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800970:	75 15                	jne    800987 <strtol+0x58>
  800972:	80 39 30             	cmpb   $0x30,(%ecx)
  800975:	75 10                	jne    800987 <strtol+0x58>
  800977:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80097b:	75 7c                	jne    8009f9 <strtol+0xca>
		s += 2, base = 16;
  80097d:	83 c1 02             	add    $0x2,%ecx
  800980:	bb 10 00 00 00       	mov    $0x10,%ebx
  800985:	eb 16                	jmp    80099d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800987:	85 db                	test   %ebx,%ebx
  800989:	75 12                	jne    80099d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80098b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800990:	80 39 30             	cmpb   $0x30,(%ecx)
  800993:	75 08                	jne    80099d <strtol+0x6e>
		s++, base = 8;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a5:	0f b6 11             	movzbl (%ecx),%edx
  8009a8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ab:	89 f3                	mov    %esi,%ebx
  8009ad:	80 fb 09             	cmp    $0x9,%bl
  8009b0:	77 08                	ja     8009ba <strtol+0x8b>
			dig = *s - '0';
  8009b2:	0f be d2             	movsbl %dl,%edx
  8009b5:	83 ea 30             	sub    $0x30,%edx
  8009b8:	eb 22                	jmp    8009dc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ba:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	80 fb 19             	cmp    $0x19,%bl
  8009c2:	77 08                	ja     8009cc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009c4:	0f be d2             	movsbl %dl,%edx
  8009c7:	83 ea 57             	sub    $0x57,%edx
  8009ca:	eb 10                	jmp    8009dc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009cc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	80 fb 19             	cmp    $0x19,%bl
  8009d4:	77 16                	ja     8009ec <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009d6:	0f be d2             	movsbl %dl,%edx
  8009d9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009dc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009df:	7d 0b                	jge    8009ec <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009ea:	eb b9                	jmp    8009a5 <strtol+0x76>

	if (endptr)
  8009ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f0:	74 0d                	je     8009ff <strtol+0xd0>
		*endptr = (char *) s;
  8009f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f5:	89 0e                	mov    %ecx,(%esi)
  8009f7:	eb 06                	jmp    8009ff <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	74 98                	je     800995 <strtol+0x66>
  8009fd:	eb 9e                	jmp    80099d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	f7 da                	neg    %edx
  800a03:	85 ff                	test   %edi,%edi
  800a05:	0f 45 c2             	cmovne %edx,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3b:	89 d1                	mov    %edx,%ecx
  800a3d:	89 d3                	mov    %edx,%ebx
  800a3f:	89 d7                	mov    %edx,%edi
  800a41:	89 d6                	mov    %edx,%esi
  800a43:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a58:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	89 cb                	mov    %ecx,%ebx
  800a62:	89 cf                	mov    %ecx,%edi
  800a64:	89 ce                	mov    %ecx,%esi
  800a66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	7e 17                	jle    800a83 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	50                   	push   %eax
  800a70:	6a 03                	push   $0x3
  800a72:	68 ff 20 80 00       	push   $0x8020ff
  800a77:	6a 23                	push   $0x23
  800a79:	68 1c 21 80 00       	push   $0x80211c
  800a7e:	e8 14 0f 00 00       	call   801997 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9b:	89 d1                	mov    %edx,%ecx
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_yield>:

void
sys_yield(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	be 00 00 00 00       	mov    $0x0,%esi
  800ad7:	b8 04 00 00 00       	mov    $0x4,%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ae5:	89 f7                	mov    %esi,%edi
  800ae7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	7e 17                	jle    800b04 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aed:	83 ec 0c             	sub    $0xc,%esp
  800af0:	50                   	push   %eax
  800af1:	6a 04                	push   $0x4
  800af3:	68 ff 20 80 00       	push   $0x8020ff
  800af8:	6a 23                	push   $0x23
  800afa:	68 1c 21 80 00       	push   $0x80211c
  800aff:	e8 93 0e 00 00       	call   801997 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b15:	b8 05 00 00 00       	mov    $0x5,%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b26:	8b 75 18             	mov    0x18(%ebp),%esi
  800b29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 17                	jle    800b46 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	6a 05                	push   $0x5
  800b35:	68 ff 20 80 00       	push   $0x8020ff
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 1c 21 80 00       	push   $0x80211c
  800b41:	e8 51 0e 00 00       	call   801997 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b5c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 df                	mov    %ebx,%edi
  800b69:	89 de                	mov    %ebx,%esi
  800b6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 17                	jle    800b88 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 06                	push   $0x6
  800b77:	68 ff 20 80 00       	push   $0x8020ff
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 1c 21 80 00       	push   $0x80211c
  800b83:	e8 0f 0e 00 00       	call   801997 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 df                	mov    %ebx,%edi
  800bab:	89 de                	mov    %ebx,%esi
  800bad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7e 17                	jle    800bca <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 08                	push   $0x8
  800bb9:	68 ff 20 80 00       	push   $0x8020ff
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 1c 21 80 00       	push   $0x80211c
  800bc5:	e8 cd 0d 00 00       	call   801997 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be0:	b8 09 00 00 00       	mov    $0x9,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 df                	mov    %ebx,%edi
  800bed:	89 de                	mov    %ebx,%esi
  800bef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7e 17                	jle    800c0c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 09                	push   $0x9
  800bfb:	68 ff 20 80 00       	push   $0x8020ff
  800c00:	6a 23                	push   $0x23
  800c02:	68 1c 21 80 00       	push   $0x80211c
  800c07:	e8 8b 0d 00 00       	call   801997 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 0a                	push   $0xa
  800c3d:	68 ff 20 80 00       	push   $0x8020ff
  800c42:	6a 23                	push   $0x23
  800c44:	68 1c 21 80 00       	push   $0x80211c
  800c49:	e8 49 0d 00 00       	call   801997 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 0d                	push   $0xd
  800ca1:	68 ff 20 80 00       	push   $0x8020ff
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 1c 21 80 00       	push   $0x80211c
  800cad:	e8 e5 0c 00 00       	call   801997 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	05 00 00 00 30       	add    $0x30000000,%eax
  800cc5:	c1 e8 0c             	shr    $0xc,%eax
}
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	05 00 00 00 30       	add    $0x30000000,%eax
  800cd5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800cda:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cec:	89 c2                	mov    %eax,%edx
  800cee:	c1 ea 16             	shr    $0x16,%edx
  800cf1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800cf8:	f6 c2 01             	test   $0x1,%dl
  800cfb:	74 11                	je     800d0e <fd_alloc+0x2d>
  800cfd:	89 c2                	mov    %eax,%edx
  800cff:	c1 ea 0c             	shr    $0xc,%edx
  800d02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d09:	f6 c2 01             	test   $0x1,%dl
  800d0c:	75 09                	jne    800d17 <fd_alloc+0x36>
			*fd_store = fd;
  800d0e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d10:	b8 00 00 00 00       	mov    $0x0,%eax
  800d15:	eb 17                	jmp    800d2e <fd_alloc+0x4d>
  800d17:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d1c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d21:	75 c9                	jne    800cec <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d23:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d29:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d36:	83 f8 1f             	cmp    $0x1f,%eax
  800d39:	77 36                	ja     800d71 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d3b:	c1 e0 0c             	shl    $0xc,%eax
  800d3e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	c1 ea 16             	shr    $0x16,%edx
  800d48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d4f:	f6 c2 01             	test   $0x1,%dl
  800d52:	74 24                	je     800d78 <fd_lookup+0x48>
  800d54:	89 c2                	mov    %eax,%edx
  800d56:	c1 ea 0c             	shr    $0xc,%edx
  800d59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d60:	f6 c2 01             	test   $0x1,%dl
  800d63:	74 1a                	je     800d7f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d68:	89 02                	mov    %eax,(%edx)
	return 0;
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	eb 13                	jmp    800d84 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d76:	eb 0c                	jmp    800d84 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800d78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d7d:	eb 05                	jmp    800d84 <fd_lookup+0x54>
  800d7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8f:	ba a8 21 80 00       	mov    $0x8021a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800d94:	eb 13                	jmp    800da9 <dev_lookup+0x23>
  800d96:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800d99:	39 08                	cmp    %ecx,(%eax)
  800d9b:	75 0c                	jne    800da9 <dev_lookup+0x23>
			*dev = devtab[i];
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da2:	b8 00 00 00 00       	mov    $0x0,%eax
  800da7:	eb 2e                	jmp    800dd7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800da9:	8b 02                	mov    (%edx),%eax
  800dab:	85 c0                	test   %eax,%eax
  800dad:	75 e7                	jne    800d96 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800daf:	a1 04 40 80 00       	mov    0x804004,%eax
  800db4:	8b 40 48             	mov    0x48(%eax),%eax
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	51                   	push   %ecx
  800dbb:	50                   	push   %eax
  800dbc:	68 2c 21 80 00       	push   $0x80212c
  800dc1:	e8 7b f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 10             	sub    $0x10,%esp
  800de1:	8b 75 08             	mov    0x8(%ebp),%esi
  800de4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800de7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dea:	50                   	push   %eax
  800deb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800df1:	c1 e8 0c             	shr    $0xc,%eax
  800df4:	50                   	push   %eax
  800df5:	e8 36 ff ff ff       	call   800d30 <fd_lookup>
  800dfa:	83 c4 08             	add    $0x8,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	78 05                	js     800e06 <fd_close+0x2d>
	    || fd != fd2)
  800e01:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e04:	74 0c                	je     800e12 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e06:	84 db                	test   %bl,%bl
  800e08:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0d:	0f 44 c2             	cmove  %edx,%eax
  800e10:	eb 41                	jmp    800e53 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e18:	50                   	push   %eax
  800e19:	ff 36                	pushl  (%esi)
  800e1b:	e8 66 ff ff ff       	call   800d86 <dev_lookup>
  800e20:	89 c3                	mov    %eax,%ebx
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	78 1a                	js     800e43 <fd_close+0x6a>
		if (dev->dev_close)
  800e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	74 0b                	je     800e43 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	56                   	push   %esi
  800e3c:	ff d0                	call   *%eax
  800e3e:	89 c3                	mov    %eax,%ebx
  800e40:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	56                   	push   %esi
  800e47:	6a 00                	push   $0x0
  800e49:	e8 00 fd ff ff       	call   800b4e <sys_page_unmap>
	return r;
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	89 d8                	mov    %ebx,%eax
}
  800e53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e63:	50                   	push   %eax
  800e64:	ff 75 08             	pushl  0x8(%ebp)
  800e67:	e8 c4 fe ff ff       	call   800d30 <fd_lookup>
  800e6c:	83 c4 08             	add    $0x8,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 10                	js     800e83 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	6a 01                	push   $0x1
  800e78:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7b:	e8 59 ff ff ff       	call   800dd9 <fd_close>
  800e80:	83 c4 10             	add    $0x10,%esp
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <close_all>:

void
close_all(void)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	53                   	push   %ebx
  800e89:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800e91:	83 ec 0c             	sub    $0xc,%esp
  800e94:	53                   	push   %ebx
  800e95:	e8 c0 ff ff ff       	call   800e5a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800e9a:	83 c3 01             	add    $0x1,%ebx
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	83 fb 20             	cmp    $0x20,%ebx
  800ea3:	75 ec                	jne    800e91 <close_all+0xc>
		close(i);
}
  800ea5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 2c             	sub    $0x2c,%esp
  800eb3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800eb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eb9:	50                   	push   %eax
  800eba:	ff 75 08             	pushl  0x8(%ebp)
  800ebd:	e8 6e fe ff ff       	call   800d30 <fd_lookup>
  800ec2:	83 c4 08             	add    $0x8,%esp
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	0f 88 c1 00 00 00    	js     800f8e <dup+0xe4>
		return r;
	close(newfdnum);
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	56                   	push   %esi
  800ed1:	e8 84 ff ff ff       	call   800e5a <close>

	newfd = INDEX2FD(newfdnum);
  800ed6:	89 f3                	mov    %esi,%ebx
  800ed8:	c1 e3 0c             	shl    $0xc,%ebx
  800edb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ee1:	83 c4 04             	add    $0x4,%esp
  800ee4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ee7:	e8 de fd ff ff       	call   800cca <fd2data>
  800eec:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800eee:	89 1c 24             	mov    %ebx,(%esp)
  800ef1:	e8 d4 fd ff ff       	call   800cca <fd2data>
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800efc:	89 f8                	mov    %edi,%eax
  800efe:	c1 e8 16             	shr    $0x16,%eax
  800f01:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f08:	a8 01                	test   $0x1,%al
  800f0a:	74 37                	je     800f43 <dup+0x99>
  800f0c:	89 f8                	mov    %edi,%eax
  800f0e:	c1 e8 0c             	shr    $0xc,%eax
  800f11:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f18:	f6 c2 01             	test   $0x1,%dl
  800f1b:	74 26                	je     800f43 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f1d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f24:	83 ec 0c             	sub    $0xc,%esp
  800f27:	25 07 0e 00 00       	and    $0xe07,%eax
  800f2c:	50                   	push   %eax
  800f2d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f30:	6a 00                	push   $0x0
  800f32:	57                   	push   %edi
  800f33:	6a 00                	push   $0x0
  800f35:	e8 d2 fb ff ff       	call   800b0c <sys_page_map>
  800f3a:	89 c7                	mov    %eax,%edi
  800f3c:	83 c4 20             	add    $0x20,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 2e                	js     800f71 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f46:	89 d0                	mov    %edx,%eax
  800f48:	c1 e8 0c             	shr    $0xc,%eax
  800f4b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5a:	50                   	push   %eax
  800f5b:	53                   	push   %ebx
  800f5c:	6a 00                	push   $0x0
  800f5e:	52                   	push   %edx
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 a6 fb ff ff       	call   800b0c <sys_page_map>
  800f66:	89 c7                	mov    %eax,%edi
  800f68:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800f6b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f6d:	85 ff                	test   %edi,%edi
  800f6f:	79 1d                	jns    800f8e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	53                   	push   %ebx
  800f75:	6a 00                	push   $0x0
  800f77:	e8 d2 fb ff ff       	call   800b4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f82:	6a 00                	push   $0x0
  800f84:	e8 c5 fb ff ff       	call   800b4e <sys_page_unmap>
	return r;
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	89 f8                	mov    %edi,%eax
}
  800f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 14             	sub    $0x14,%esp
  800f9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	53                   	push   %ebx
  800fa5:	e8 86 fd ff ff       	call   800d30 <fd_lookup>
  800faa:	83 c4 08             	add    $0x8,%esp
  800fad:	89 c2                	mov    %eax,%edx
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 6d                	js     801020 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbd:	ff 30                	pushl  (%eax)
  800fbf:	e8 c2 fd ff ff       	call   800d86 <dev_lookup>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 4c                	js     801017 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fce:	8b 42 08             	mov    0x8(%edx),%eax
  800fd1:	83 e0 03             	and    $0x3,%eax
  800fd4:	83 f8 01             	cmp    $0x1,%eax
  800fd7:	75 21                	jne    800ffa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800fd9:	a1 04 40 80 00       	mov    0x804004,%eax
  800fde:	8b 40 48             	mov    0x48(%eax),%eax
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	53                   	push   %ebx
  800fe5:	50                   	push   %eax
  800fe6:	68 6d 21 80 00       	push   $0x80216d
  800feb:	e8 51 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ff8:	eb 26                	jmp    801020 <read+0x8a>
	}
	if (!dev->dev_read)
  800ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffd:	8b 40 08             	mov    0x8(%eax),%eax
  801000:	85 c0                	test   %eax,%eax
  801002:	74 17                	je     80101b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	ff 75 10             	pushl  0x10(%ebp)
  80100a:	ff 75 0c             	pushl  0xc(%ebp)
  80100d:	52                   	push   %edx
  80100e:	ff d0                	call   *%eax
  801010:	89 c2                	mov    %eax,%edx
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	eb 09                	jmp    801020 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801017:	89 c2                	mov    %eax,%edx
  801019:	eb 05                	jmp    801020 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80101b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801020:	89 d0                	mov    %edx,%eax
  801022:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	8b 7d 08             	mov    0x8(%ebp),%edi
  801033:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103b:	eb 21                	jmp    80105e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	89 f0                	mov    %esi,%eax
  801042:	29 d8                	sub    %ebx,%eax
  801044:	50                   	push   %eax
  801045:	89 d8                	mov    %ebx,%eax
  801047:	03 45 0c             	add    0xc(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	57                   	push   %edi
  80104c:	e8 45 ff ff ff       	call   800f96 <read>
		if (m < 0)
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 10                	js     801068 <readn+0x41>
			return m;
		if (m == 0)
  801058:	85 c0                	test   %eax,%eax
  80105a:	74 0a                	je     801066 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80105c:	01 c3                	add    %eax,%ebx
  80105e:	39 f3                	cmp    %esi,%ebx
  801060:	72 db                	jb     80103d <readn+0x16>
  801062:	89 d8                	mov    %ebx,%eax
  801064:	eb 02                	jmp    801068 <readn+0x41>
  801066:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801068:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	53                   	push   %ebx
  801074:	83 ec 14             	sub    $0x14,%esp
  801077:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	53                   	push   %ebx
  80107f:	e8 ac fc ff ff       	call   800d30 <fd_lookup>
  801084:	83 c4 08             	add    $0x8,%esp
  801087:	89 c2                	mov    %eax,%edx
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 68                	js     8010f5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801093:	50                   	push   %eax
  801094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801097:	ff 30                	pushl  (%eax)
  801099:	e8 e8 fc ff ff       	call   800d86 <dev_lookup>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 47                	js     8010ec <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010ac:	75 21                	jne    8010cf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b3:	8b 40 48             	mov    0x48(%eax),%eax
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	53                   	push   %ebx
  8010ba:	50                   	push   %eax
  8010bb:	68 89 21 80 00       	push   $0x802189
  8010c0:	e8 7c f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010cd:	eb 26                	jmp    8010f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8010d5:	85 d2                	test   %edx,%edx
  8010d7:	74 17                	je     8010f0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010d9:	83 ec 04             	sub    $0x4,%esp
  8010dc:	ff 75 10             	pushl  0x10(%ebp)
  8010df:	ff 75 0c             	pushl  0xc(%ebp)
  8010e2:	50                   	push   %eax
  8010e3:	ff d2                	call   *%edx
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	eb 09                	jmp    8010f5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	eb 05                	jmp    8010f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8010f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <seek>:

int
seek(int fdnum, off_t offset)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801102:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	ff 75 08             	pushl  0x8(%ebp)
  801109:	e8 22 fc ff ff       	call   800d30 <fd_lookup>
  80110e:	83 c4 08             	add    $0x8,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 0e                	js     801123 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801115:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801118:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80111e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801123:	c9                   	leave  
  801124:	c3                   	ret    

00801125 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	53                   	push   %ebx
  801129:	83 ec 14             	sub    $0x14,%esp
  80112c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	53                   	push   %ebx
  801134:	e8 f7 fb ff ff       	call   800d30 <fd_lookup>
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 65                	js     8011a7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114c:	ff 30                	pushl  (%eax)
  80114e:	e8 33 fc ff ff       	call   800d86 <dev_lookup>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 44                	js     80119e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80115a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801161:	75 21                	jne    801184 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801163:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801168:	8b 40 48             	mov    0x48(%eax),%eax
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	53                   	push   %ebx
  80116f:	50                   	push   %eax
  801170:	68 4c 21 80 00       	push   $0x80214c
  801175:	e8 c7 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801182:	eb 23                	jmp    8011a7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801184:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801187:	8b 52 18             	mov    0x18(%edx),%edx
  80118a:	85 d2                	test   %edx,%edx
  80118c:	74 14                	je     8011a2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	ff 75 0c             	pushl  0xc(%ebp)
  801194:	50                   	push   %eax
  801195:	ff d2                	call   *%edx
  801197:	89 c2                	mov    %eax,%edx
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	eb 09                	jmp    8011a7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	eb 05                	jmp    8011a7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011a7:	89 d0                	mov    %edx,%eax
  8011a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	53                   	push   %ebx
  8011b2:	83 ec 14             	sub    $0x14,%esp
  8011b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	ff 75 08             	pushl  0x8(%ebp)
  8011bf:	e8 6c fb ff ff       	call   800d30 <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 58                	js     801225 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d7:	ff 30                	pushl  (%eax)
  8011d9:	e8 a8 fb ff ff       	call   800d86 <dev_lookup>
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 37                	js     80121c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8011e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011ec:	74 32                	je     801220 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011ee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011f1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011f8:	00 00 00 
	stat->st_isdir = 0;
  8011fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801202:	00 00 00 
	stat->st_dev = dev;
  801205:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	53                   	push   %ebx
  80120f:	ff 75 f0             	pushl  -0x10(%ebp)
  801212:	ff 50 14             	call   *0x14(%eax)
  801215:	89 c2                	mov    %eax,%edx
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	eb 09                	jmp    801225 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	eb 05                	jmp    801225 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801220:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801225:	89 d0                	mov    %edx,%eax
  801227:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	6a 00                	push   $0x0
  801236:	ff 75 08             	pushl  0x8(%ebp)
  801239:	e8 d6 01 00 00       	call   801414 <open>
  80123e:	89 c3                	mov    %eax,%ebx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 1b                	js     801262 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801247:	83 ec 08             	sub    $0x8,%esp
  80124a:	ff 75 0c             	pushl  0xc(%ebp)
  80124d:	50                   	push   %eax
  80124e:	e8 5b ff ff ff       	call   8011ae <fstat>
  801253:	89 c6                	mov    %eax,%esi
	close(fd);
  801255:	89 1c 24             	mov    %ebx,(%esp)
  801258:	e8 fd fb ff ff       	call   800e5a <close>
	return r;
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	89 f0                	mov    %esi,%eax
}
  801262:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	89 c6                	mov    %eax,%esi
  801270:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801272:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801279:	75 12                	jne    80128d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	6a 01                	push   $0x1
  801280:	e8 44 08 00 00       	call   801ac9 <ipc_find_env>
  801285:	a3 00 40 80 00       	mov    %eax,0x804000
  80128a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80128d:	6a 07                	push   $0x7
  80128f:	68 00 50 80 00       	push   $0x805000
  801294:	56                   	push   %esi
  801295:	ff 35 00 40 80 00    	pushl  0x804000
  80129b:	e8 d5 07 00 00       	call   801a75 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012a0:	83 c4 0c             	add    $0xc,%esp
  8012a3:	6a 00                	push   $0x0
  8012a5:	53                   	push   %ebx
  8012a6:	6a 00                	push   $0x0
  8012a8:	e8 30 07 00 00       	call   8019dd <ipc_recv>
}
  8012ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8012c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8012d7:	e8 8d ff ff ff       	call   801269 <fsipc>
}
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ea:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8012ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8012f9:	e8 6b ff ff ff       	call   801269 <fsipc>
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	53                   	push   %ebx
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80130a:	8b 45 08             	mov    0x8(%ebp),%eax
  80130d:	8b 40 0c             	mov    0xc(%eax),%eax
  801310:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	b8 05 00 00 00       	mov    $0x5,%eax
  80131f:	e8 45 ff ff ff       	call   801269 <fsipc>
  801324:	85 c0                	test   %eax,%eax
  801326:	78 2c                	js     801354 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	68 00 50 80 00       	push   $0x805000
  801330:	53                   	push   %ebx
  801331:	e8 90 f3 ff ff       	call   8006c6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801336:	a1 80 50 80 00       	mov    0x805080,%eax
  80133b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801341:	a1 84 50 80 00       	mov    0x805084,%eax
  801346:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801362:	8b 55 08             	mov    0x8(%ebp),%edx
  801365:	8b 52 0c             	mov    0xc(%edx),%edx
  801368:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80136e:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801373:	50                   	push   %eax
  801374:	ff 75 0c             	pushl  0xc(%ebp)
  801377:	68 08 50 80 00       	push   $0x805008
  80137c:	e8 d7 f4 ff ff       	call   800858 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	b8 04 00 00 00       	mov    $0x4,%eax
  80138b:	e8 d9 fe ff ff       	call   801269 <fsipc>
	//panic("devfile_write not implemented");
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80139a:	8b 45 08             	mov    0x8(%ebp),%eax
  80139d:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8013b5:	e8 af fe ff ff       	call   801269 <fsipc>
  8013ba:	89 c3                	mov    %eax,%ebx
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 4b                	js     80140b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013c0:	39 c6                	cmp    %eax,%esi
  8013c2:	73 16                	jae    8013da <devfile_read+0x48>
  8013c4:	68 b8 21 80 00       	push   $0x8021b8
  8013c9:	68 bf 21 80 00       	push   $0x8021bf
  8013ce:	6a 7c                	push   $0x7c
  8013d0:	68 d4 21 80 00       	push   $0x8021d4
  8013d5:	e8 bd 05 00 00       	call   801997 <_panic>
	assert(r <= PGSIZE);
  8013da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013df:	7e 16                	jle    8013f7 <devfile_read+0x65>
  8013e1:	68 df 21 80 00       	push   $0x8021df
  8013e6:	68 bf 21 80 00       	push   $0x8021bf
  8013eb:	6a 7d                	push   $0x7d
  8013ed:	68 d4 21 80 00       	push   $0x8021d4
  8013f2:	e8 a0 05 00 00       	call   801997 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8013f7:	83 ec 04             	sub    $0x4,%esp
  8013fa:	50                   	push   %eax
  8013fb:	68 00 50 80 00       	push   $0x805000
  801400:	ff 75 0c             	pushl  0xc(%ebp)
  801403:	e8 50 f4 ff ff       	call   800858 <memmove>
	return r;
  801408:	83 c4 10             	add    $0x10,%esp
}
  80140b:	89 d8                	mov    %ebx,%eax
  80140d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	53                   	push   %ebx
  801418:	83 ec 20             	sub    $0x20,%esp
  80141b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80141e:	53                   	push   %ebx
  80141f:	e8 69 f2 ff ff       	call   80068d <strlen>
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80142c:	7f 67                	jg     801495 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	e8 a7 f8 ff ff       	call   800ce1 <fd_alloc>
  80143a:	83 c4 10             	add    $0x10,%esp
		return r;
  80143d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 57                	js     80149a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	53                   	push   %ebx
  801447:	68 00 50 80 00       	push   $0x805000
  80144c:	e8 75 f2 ff ff       	call   8006c6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801451:	8b 45 0c             	mov    0xc(%ebp),%eax
  801454:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801459:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145c:	b8 01 00 00 00       	mov    $0x1,%eax
  801461:	e8 03 fe ff ff       	call   801269 <fsipc>
  801466:	89 c3                	mov    %eax,%ebx
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	79 14                	jns    801483 <open+0x6f>
		fd_close(fd, 0);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	6a 00                	push   $0x0
  801474:	ff 75 f4             	pushl  -0xc(%ebp)
  801477:	e8 5d f9 ff ff       	call   800dd9 <fd_close>
		return r;
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	89 da                	mov    %ebx,%edx
  801481:	eb 17                	jmp    80149a <open+0x86>
	}

	return fd2num(fd);
  801483:	83 ec 0c             	sub    $0xc,%esp
  801486:	ff 75 f4             	pushl  -0xc(%ebp)
  801489:	e8 2c f8 ff ff       	call   800cba <fd2num>
  80148e:	89 c2                	mov    %eax,%edx
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	eb 05                	jmp    80149a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801495:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80149a:	89 d0                	mov    %edx,%eax
  80149c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149f:	c9                   	leave  
  8014a0:	c3                   	ret    

008014a1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8014b1:	e8 b3 fd ff ff       	call   801269 <fsipc>
}
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	56                   	push   %esi
  8014bc:	53                   	push   %ebx
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	ff 75 08             	pushl  0x8(%ebp)
  8014c6:	e8 ff f7 ff ff       	call   800cca <fd2data>
  8014cb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014cd:	83 c4 08             	add    $0x8,%esp
  8014d0:	68 eb 21 80 00       	push   $0x8021eb
  8014d5:	53                   	push   %ebx
  8014d6:	e8 eb f1 ff ff       	call   8006c6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014db:	8b 46 04             	mov    0x4(%esi),%eax
  8014de:	2b 06                	sub    (%esi),%eax
  8014e0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8014e6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014ed:	00 00 00 
	stat->st_dev = &devpipe;
  8014f0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8014f7:	30 80 00 
	return 0;
}
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 0c             	sub    $0xc,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801510:	53                   	push   %ebx
  801511:	6a 00                	push   $0x0
  801513:	e8 36 f6 ff ff       	call   800b4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801518:	89 1c 24             	mov    %ebx,(%esp)
  80151b:	e8 aa f7 ff ff       	call   800cca <fd2data>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	50                   	push   %eax
  801524:	6a 00                	push   $0x0
  801526:	e8 23 f6 ff ff       	call   800b4e <sys_page_unmap>
}
  80152b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	83 ec 1c             	sub    $0x1c,%esp
  801539:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80153c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80153e:	a1 04 40 80 00       	mov    0x804004,%eax
  801543:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	ff 75 e0             	pushl  -0x20(%ebp)
  80154c:	e8 b1 05 00 00       	call   801b02 <pageref>
  801551:	89 c3                	mov    %eax,%ebx
  801553:	89 3c 24             	mov    %edi,(%esp)
  801556:	e8 a7 05 00 00       	call   801b02 <pageref>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	39 c3                	cmp    %eax,%ebx
  801560:	0f 94 c1             	sete   %cl
  801563:	0f b6 c9             	movzbl %cl,%ecx
  801566:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801569:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80156f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801572:	39 ce                	cmp    %ecx,%esi
  801574:	74 1b                	je     801591 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801576:	39 c3                	cmp    %eax,%ebx
  801578:	75 c4                	jne    80153e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80157a:	8b 42 58             	mov    0x58(%edx),%eax
  80157d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801580:	50                   	push   %eax
  801581:	56                   	push   %esi
  801582:	68 f2 21 80 00       	push   $0x8021f2
  801587:	e8 b5 eb ff ff       	call   800141 <cprintf>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	eb ad                	jmp    80153e <_pipeisclosed+0xe>
	}
}
  801591:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801594:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	57                   	push   %edi
  8015a0:	56                   	push   %esi
  8015a1:	53                   	push   %ebx
  8015a2:	83 ec 28             	sub    $0x28,%esp
  8015a5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015a8:	56                   	push   %esi
  8015a9:	e8 1c f7 ff ff       	call   800cca <fd2data>
  8015ae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8015b8:	eb 4b                	jmp    801605 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015ba:	89 da                	mov    %ebx,%edx
  8015bc:	89 f0                	mov    %esi,%eax
  8015be:	e8 6d ff ff ff       	call   801530 <_pipeisclosed>
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	75 48                	jne    80160f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015c7:	e8 de f4 ff ff       	call   800aaa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8015cf:	8b 0b                	mov    (%ebx),%ecx
  8015d1:	8d 51 20             	lea    0x20(%ecx),%edx
  8015d4:	39 d0                	cmp    %edx,%eax
  8015d6:	73 e2                	jae    8015ba <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015db:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8015df:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	c1 fa 1f             	sar    $0x1f,%edx
  8015e7:	89 d1                	mov    %edx,%ecx
  8015e9:	c1 e9 1b             	shr    $0x1b,%ecx
  8015ec:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8015ef:	83 e2 1f             	and    $0x1f,%edx
  8015f2:	29 ca                	sub    %ecx,%edx
  8015f4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8015f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015fc:	83 c0 01             	add    $0x1,%eax
  8015ff:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801602:	83 c7 01             	add    $0x1,%edi
  801605:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801608:	75 c2                	jne    8015cc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80160a:	8b 45 10             	mov    0x10(%ebp),%eax
  80160d:	eb 05                	jmp    801614 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80160f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5f                   	pop    %edi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	57                   	push   %edi
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 18             	sub    $0x18,%esp
  801625:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801628:	57                   	push   %edi
  801629:	e8 9c f6 ff ff       	call   800cca <fd2data>
  80162e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	bb 00 00 00 00       	mov    $0x0,%ebx
  801638:	eb 3d                	jmp    801677 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80163a:	85 db                	test   %ebx,%ebx
  80163c:	74 04                	je     801642 <devpipe_read+0x26>
				return i;
  80163e:	89 d8                	mov    %ebx,%eax
  801640:	eb 44                	jmp    801686 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801642:	89 f2                	mov    %esi,%edx
  801644:	89 f8                	mov    %edi,%eax
  801646:	e8 e5 fe ff ff       	call   801530 <_pipeisclosed>
  80164b:	85 c0                	test   %eax,%eax
  80164d:	75 32                	jne    801681 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80164f:	e8 56 f4 ff ff       	call   800aaa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801654:	8b 06                	mov    (%esi),%eax
  801656:	3b 46 04             	cmp    0x4(%esi),%eax
  801659:	74 df                	je     80163a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80165b:	99                   	cltd   
  80165c:	c1 ea 1b             	shr    $0x1b,%edx
  80165f:	01 d0                	add    %edx,%eax
  801661:	83 e0 1f             	and    $0x1f,%eax
  801664:	29 d0                	sub    %edx,%eax
  801666:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80166b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801671:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801674:	83 c3 01             	add    $0x1,%ebx
  801677:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80167a:	75 d8                	jne    801654 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80167c:	8b 45 10             	mov    0x10(%ebp),%eax
  80167f:	eb 05                	jmp    801686 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801686:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	56                   	push   %esi
  801692:	53                   	push   %ebx
  801693:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	e8 42 f6 ff ff       	call   800ce1 <fd_alloc>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	0f 88 2c 01 00 00    	js     8017d8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	68 07 04 00 00       	push   $0x407
  8016b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b7:	6a 00                	push   $0x0
  8016b9:	e8 0b f4 ff ff       	call   800ac9 <sys_page_alloc>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	0f 88 0d 01 00 00    	js     8017d8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	e8 0a f6 ff ff       	call   800ce1 <fd_alloc>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	0f 88 e2 00 00 00    	js     8017c6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	68 07 04 00 00       	push   $0x407
  8016ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 d3 f3 ff ff       	call   800ac9 <sys_page_alloc>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	0f 88 c3 00 00 00    	js     8017c6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	ff 75 f4             	pushl  -0xc(%ebp)
  801709:	e8 bc f5 ff ff       	call   800cca <fd2data>
  80170e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801710:	83 c4 0c             	add    $0xc,%esp
  801713:	68 07 04 00 00       	push   $0x407
  801718:	50                   	push   %eax
  801719:	6a 00                	push   $0x0
  80171b:	e8 a9 f3 ff ff       	call   800ac9 <sys_page_alloc>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 89 00 00 00    	js     8017b6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	ff 75 f0             	pushl  -0x10(%ebp)
  801733:	e8 92 f5 ff ff       	call   800cca <fd2data>
  801738:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80173f:	50                   	push   %eax
  801740:	6a 00                	push   $0x0
  801742:	56                   	push   %esi
  801743:	6a 00                	push   $0x0
  801745:	e8 c2 f3 ff ff       	call   800b0c <sys_page_map>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 20             	add    $0x20,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 55                	js     8017a8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801753:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801761:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801768:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801773:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801776:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	ff 75 f4             	pushl  -0xc(%ebp)
  801783:	e8 32 f5 ff ff       	call   800cba <fd2num>
  801788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80178d:	83 c4 04             	add    $0x4,%esp
  801790:	ff 75 f0             	pushl  -0x10(%ebp)
  801793:	e8 22 f5 ff ff       	call   800cba <fd2num>
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	eb 30                	jmp    8017d8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	56                   	push   %esi
  8017ac:	6a 00                	push   $0x0
  8017ae:	e8 9b f3 ff ff       	call   800b4e <sys_page_unmap>
  8017b3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 8b f3 ff ff       	call   800b4e <sys_page_unmap>
  8017c3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 7b f3 ff ff       	call   800b4e <sys_page_unmap>
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8017d8:	89 d0                	mov    %edx,%eax
  8017da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 08             	pushl  0x8(%ebp)
  8017ee:	e8 3d f5 ff ff       	call   800d30 <fd_lookup>
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 18                	js     801812 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8017fa:	83 ec 0c             	sub    $0xc,%esp
  8017fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801800:	e8 c5 f4 ff ff       	call   800cca <fd2data>
	return _pipeisclosed(fd, p);
  801805:	89 c2                	mov    %eax,%edx
  801807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180a:	e8 21 fd ff ff       	call   801530 <_pipeisclosed>
  80180f:	83 c4 10             	add    $0x10,%esp
}
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801817:	b8 00 00 00 00       	mov    $0x0,%eax
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801824:	68 0a 22 80 00       	push   $0x80220a
  801829:	ff 75 0c             	pushl  0xc(%ebp)
  80182c:	e8 95 ee ff ff       	call   8006c6 <strcpy>
	return 0;
}
  801831:	b8 00 00 00 00       	mov    $0x0,%eax
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	57                   	push   %edi
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801844:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801849:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80184f:	eb 2d                	jmp    80187e <devcons_write+0x46>
		m = n - tot;
  801851:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801854:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801856:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801859:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80185e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801861:	83 ec 04             	sub    $0x4,%esp
  801864:	53                   	push   %ebx
  801865:	03 45 0c             	add    0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	57                   	push   %edi
  80186a:	e8 e9 ef ff ff       	call   800858 <memmove>
		sys_cputs(buf, m);
  80186f:	83 c4 08             	add    $0x8,%esp
  801872:	53                   	push   %ebx
  801873:	57                   	push   %edi
  801874:	e8 94 f1 ff ff       	call   800a0d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801879:	01 de                	add    %ebx,%esi
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	89 f0                	mov    %esi,%eax
  801880:	3b 75 10             	cmp    0x10(%ebp),%esi
  801883:	72 cc                	jb     801851 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801885:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5f                   	pop    %edi
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801898:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80189c:	74 2a                	je     8018c8 <devcons_read+0x3b>
  80189e:	eb 05                	jmp    8018a5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018a0:	e8 05 f2 ff ff       	call   800aaa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018a5:	e8 81 f1 ff ff       	call   800a2b <sys_cgetc>
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	74 f2                	je     8018a0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 16                	js     8018c8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018b2:	83 f8 04             	cmp    $0x4,%eax
  8018b5:	74 0c                	je     8018c3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ba:	88 02                	mov    %al,(%edx)
	return 1;
  8018bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c1:	eb 05                	jmp    8018c8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018d6:	6a 01                	push   $0x1
  8018d8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018db:	50                   	push   %eax
  8018dc:	e8 2c f1 ff ff       	call   800a0d <sys_cputs>
}
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <getchar>:

int
getchar(void)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8018ec:	6a 01                	push   $0x1
  8018ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	6a 00                	push   $0x0
  8018f4:	e8 9d f6 ff ff       	call   800f96 <read>
	if (r < 0)
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 0f                	js     80190f <getchar+0x29>
		return r;
	if (r < 1)
  801900:	85 c0                	test   %eax,%eax
  801902:	7e 06                	jle    80190a <getchar+0x24>
		return -E_EOF;
	return c;
  801904:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801908:	eb 05                	jmp    80190f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80190a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 0d f4 ff ff       	call   800d30 <fd_lookup>
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 11                	js     80193b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801933:	39 10                	cmp    %edx,(%eax)
  801935:	0f 94 c0             	sete   %al
  801938:	0f b6 c0             	movzbl %al,%eax
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <opencons>:

int
opencons(void)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	e8 95 f3 ff ff       	call   800ce1 <fd_alloc>
  80194c:	83 c4 10             	add    $0x10,%esp
		return r;
  80194f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801951:	85 c0                	test   %eax,%eax
  801953:	78 3e                	js     801993 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	68 07 04 00 00       	push   $0x407
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	6a 00                	push   $0x0
  801962:	e8 62 f1 ff ff       	call   800ac9 <sys_page_alloc>
  801967:	83 c4 10             	add    $0x10,%esp
		return r;
  80196a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 23                	js     801993 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801970:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801979:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	50                   	push   %eax
  801989:	e8 2c f3 ff ff       	call   800cba <fd2num>
  80198e:	89 c2                	mov    %eax,%edx
  801990:	83 c4 10             	add    $0x10,%esp
}
  801993:	89 d0                	mov    %edx,%eax
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80199c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80199f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019a5:	e8 e1 f0 ff ff       	call   800a8b <sys_getenvid>
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 0c             	pushl  0xc(%ebp)
  8019b0:	ff 75 08             	pushl  0x8(%ebp)
  8019b3:	56                   	push   %esi
  8019b4:	50                   	push   %eax
  8019b5:	68 18 22 80 00       	push   $0x802218
  8019ba:	e8 82 e7 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019bf:	83 c4 18             	add    $0x18,%esp
  8019c2:	53                   	push   %ebx
  8019c3:	ff 75 10             	pushl  0x10(%ebp)
  8019c6:	e8 25 e7 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  8019cb:	c7 04 24 fc 1d 80 00 	movl   $0x801dfc,(%esp)
  8019d2:	e8 6a e7 ff ff       	call   800141 <cprintf>
  8019d7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019da:	cc                   	int3   
  8019db:	eb fd                	jmp    8019da <_panic+0x43>

008019dd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	74 3e                	je     801a2d <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	50                   	push   %eax
  8019f3:	e8 81 f2 ff ff       	call   800c79 <sys_ipc_recv>
  8019f8:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 f6                	test   %esi,%esi
  8019ff:	74 13                	je     801a14 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801a01:	b8 00 00 00 00       	mov    $0x0,%eax
  801a06:	85 d2                	test   %edx,%edx
  801a08:	75 08                	jne    801a12 <ipc_recv+0x35>
  801a0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a0f:	8b 40 74             	mov    0x74(%eax),%eax
  801a12:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801a14:	85 db                	test   %ebx,%ebx
  801a16:	74 48                	je     801a60 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1d:	85 d2                	test   %edx,%edx
  801a1f:	75 08                	jne    801a29 <ipc_recv+0x4c>
  801a21:	a1 04 40 80 00       	mov    0x804004,%eax
  801a26:	8b 40 78             	mov    0x78(%eax),%eax
  801a29:	89 03                	mov    %eax,(%ebx)
  801a2b:	eb 33                	jmp    801a60 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	68 00 00 c0 ee       	push   $0xeec00000
  801a35:	e8 3f f2 ff ff       	call   800c79 <sys_ipc_recv>
  801a3a:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 f6                	test   %esi,%esi
  801a41:	74 13                	je     801a56 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801a43:	b8 00 00 00 00       	mov    $0x0,%eax
  801a48:	85 d2                	test   %edx,%edx
  801a4a:	75 08                	jne    801a54 <ipc_recv+0x77>
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 40 74             	mov    0x74(%eax),%eax
  801a54:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801a56:	85 db                	test   %ebx,%ebx
  801a58:	74 06                	je     801a60 <ipc_recv+0x83>
			*perm_store = 0;
  801a5a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801a60:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801a62:	85 d2                	test   %edx,%edx
  801a64:	75 08                	jne    801a6e <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801a6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	57                   	push   %edi
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801a87:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801a89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a8e:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801a91:	eb 1c                	jmp    801aaf <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801a93:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a96:	74 12                	je     801aaa <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801a98:	50                   	push   %eax
  801a99:	68 3c 22 80 00       	push   $0x80223c
  801a9e:	6a 4f                	push   $0x4f
  801aa0:	68 57 22 80 00       	push   $0x802257
  801aa5:	e8 ed fe ff ff       	call   801997 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801aaa:	e8 fb ef ff ff       	call   800aaa <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801aaf:	ff 75 14             	pushl  0x14(%ebp)
  801ab2:	53                   	push   %ebx
  801ab3:	56                   	push   %esi
  801ab4:	57                   	push   %edi
  801ab5:	e8 9c f1 ff ff       	call   800c56 <sys_ipc_try_send>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 d2                	js     801a93 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5f                   	pop    %edi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801add:	8b 52 50             	mov    0x50(%edx),%edx
  801ae0:	39 ca                	cmp    %ecx,%edx
  801ae2:	75 0d                	jne    801af1 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aec:	8b 40 48             	mov    0x48(%eax),%eax
  801aef:	eb 0f                	jmp    801b00 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af1:	83 c0 01             	add    $0x1,%eax
  801af4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af9:	75 d9                	jne    801ad4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b08:	89 d0                	mov    %edx,%eax
  801b0a:	c1 e8 16             	shr    $0x16,%eax
  801b0d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b19:	f6 c1 01             	test   $0x1,%cl
  801b1c:	74 1d                	je     801b3b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1e:	c1 ea 0c             	shr    $0xc,%edx
  801b21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b28:	f6 c2 01             	test   $0x1,%dl
  801b2b:	74 0e                	je     801b3b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2d:	c1 ea 0c             	shr    $0xc,%edx
  801b30:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b37:	ef 
  801b38:	0f b7 c0             	movzwl %ax,%eax
}
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
