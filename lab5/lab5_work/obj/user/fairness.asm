
obj/user/fairness.debug：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 9e 0a 00 00       	call   800ade <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 af 0c 00 00       	call   800d0d <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 20 1e 80 00       	push   $0x801e20
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 31 1e 80 00       	push   $0x801e31
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 09 0d 00 00       	call   800da5 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 2d 0a 00 00       	call   800ade <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 0b 0f 00 00       	call   800ffd <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 a1 09 00 00       	call   800a9d <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 2f 09 00 00       	call   800a60 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 d4 08 00 00       	call   800a60 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 94 19 00 00       	call   801b90 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 81 1a 00 00       	call   801cc0 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 89 03 00 00    	je     800670 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 1a 03 00 00    	ja     800655 <vprintfmt+0x38a>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800363:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800366:	83 fa 09             	cmp    $0x9,%edx
  800369:	77 39                	ja     8003a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 48 04             	lea    0x4(%eax),%ecx
  800376:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 27                	jmp    8003aa <vprintfmt+0xdf>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	0f 49 c8             	cmovns %eax,%ecx
  800390:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	eb 8c                	jmp    800324 <vprintfmt+0x59>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	eb 80                	jmp    800324 <vprintfmt+0x59>
  8003a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	0f 89 70 ff ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c1:	e9 5e ff ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 53 ff ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e8:	e9 04 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	99                   	cltd   
  8003f9:	31 d0                	xor    %edx,%eax
  8003fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fd:	83 f8 0f             	cmp    $0xf,%eax
  800400:	7f 0b                	jg     80040d <vprintfmt+0x142>
  800402:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 6a 1e 80 00       	push   $0x801e6a
  800413:	53                   	push   %ebx
  800414:	56                   	push   %esi
  800415:	e8 94 fe ff ff       	call   8002ae <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 cc fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 55 22 80 00       	push   $0x802255
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 7c fe ff ff       	call   8002ae <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	e9 b4 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800448:	85 ff                	test   %edi,%edi
  80044a:	b8 63 1e 80 00       	mov    $0x801e63,%eax
  80044f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 94 00 00 00    	jle    8004f0 <vprintfmt+0x225>
  80045c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800460:	0f 84 98 00 00 00    	je     8004fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 d0             	pushl  -0x30(%ebp)
  80046c:	57                   	push   %edi
  80046d:	e8 86 02 00 00       	call   8006f8 <strnlen>
  800472:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c0>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	0f 49 c1             	cmovns %ecx,%eax
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	89 cb                	mov    %ecx,%ebx
  8004bb:	eb 4d                	jmp    80050a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	74 1b                	je     8004de <vprintfmt+0x213>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 10                	jbe    8004de <vprintfmt+0x213>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	6a 3f                	push   $0x3f
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb 0d                	jmp    8004eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	52                   	push   %edx
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	eb 1a                	jmp    80050a <vprintfmt+0x23f>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	eb 0c                	jmp    80050a <vprintfmt+0x23f>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 23                	je     80053b <vprintfmt+0x270>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 a1                	js     8004bd <vprintfmt+0x1f2>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 9c                	jns    8004bd <vprintfmt+0x1f2>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 18                	jmp    800543 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	6a 20                	push   $0x20
  800531:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 08                	jmp    800543 <vprintfmt+0x278>
  80053b:	89 df                	mov    %ebx,%edi
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	85 ff                	test   %edi,%edi
  800545:	7f e4                	jg     80052b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 a2 fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 fa 01             	cmp    $0x1,%edx
  800552:	7e 16                	jle    80056a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	eb 32                	jmp    80059c <vprintfmt+0x2d1>
	else if (lflag)
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 18                	je     800586 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800584:	eb 16                	jmp    80059c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ab:	79 74                	jns    800621 <vprintfmt+0x356>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	53                   	push   %ebx
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bb:	f7 d8                	neg    %eax
  8005bd:	83 d2 00             	adc    $0x0,%edx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ca:	eb 55                	jmp    800621 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 83 fc ff ff       	call   800257 <getuint>
			base = 10;
  8005d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d9:	eb 46                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 74 fc ff ff       	call   800257 <getuint>
			base=8;
  8005e3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e8:	eb 37                	jmp    800621 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 30                	push   $0x30
  8005f0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	53                   	push   %ebx
  8005f6:	6a 78                	push   $0x78
  8005f8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800612:	eb 0d                	jmp    800621 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 3b fc ff ff       	call   800257 <getuint>
			base = 16;
  80061c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800628:	57                   	push   %edi
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	51                   	push   %ecx
  80062d:	52                   	push   %edx
  80062e:	50                   	push   %eax
  80062f:	89 da                	mov    %ebx,%edx
  800631:	89 f0                	mov    %esi,%eax
  800633:	e8 70 fb ff ff       	call   8001a8 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063e:	e9 ae fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	51                   	push   %ecx
  800648:	ff d6                	call   *%esi
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800650:	e9 9c fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 25                	push   $0x25
  80065b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb 03                	jmp    800665 <vprintfmt+0x39a>
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800669:	75 f7                	jne    800662 <vprintfmt+0x397>
  80066b:	e9 81 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 18             	sub    $0x18,%esp
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800684:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800687:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800695:	85 c0                	test   %eax,%eax
  800697:	74 26                	je     8006bf <vsnprintf+0x47>
  800699:	85 d2                	test   %edx,%edx
  80069b:	7e 22                	jle    8006bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069d:	ff 75 14             	pushl  0x14(%ebp)
  8006a0:	ff 75 10             	pushl  0x10(%ebp)
  8006a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	68 91 02 80 00       	push   $0x800291
  8006ac:	e8 1a fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 05                	jmp    8006c4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cf:	50                   	push   %eax
  8006d0:	ff 75 10             	pushl  0x10(%ebp)
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	ff 75 08             	pushl  0x8(%ebp)
  8006d9:	e8 9a ff ff ff       	call   800678 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 03                	jmp    8006f0 <strlen+0x10>
		n++;
  8006ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f4:	75 f7                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
  800706:	eb 03                	jmp    80070b <strnlen+0x13>
		n++;
  800708:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070b:	39 c2                	cmp    %eax,%edx
  80070d:	74 08                	je     800717 <strnlen+0x1f>
  80070f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800713:	75 f3                	jne    800708 <strnlen+0x10>
  800715:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	53                   	push   %ebx
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800723:	89 c2                	mov    %eax,%edx
  800725:	83 c2 01             	add    $0x1,%edx
  800728:	83 c1 01             	add    $0x1,%ecx
  80072b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800732:	84 db                	test   %bl,%bl
  800734:	75 ef                	jne    800725 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800736:	5b                   	pop    %ebx
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800740:	53                   	push   %ebx
  800741:	e8 9a ff ff ff       	call   8006e0 <strlen>
  800746:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	01 d8                	add    %ebx,%eax
  80074e:	50                   	push   %eax
  80074f:	e8 c5 ff ff ff       	call   800719 <strcpy>
	return dst;
}
  800754:	89 d8                	mov    %ebx,%eax
  800756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800766:	89 f3                	mov    %esi,%ebx
  800768:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076b:	89 f2                	mov    %esi,%edx
  80076d:	eb 0f                	jmp    80077e <strncpy+0x23>
		*dst++ = *src;
  80076f:	83 c2 01             	add    $0x1,%edx
  800772:	0f b6 01             	movzbl (%ecx),%eax
  800775:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800778:	80 39 01             	cmpb   $0x1,(%ecx)
  80077b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077e:	39 da                	cmp    %ebx,%edx
  800780:	75 ed                	jne    80076f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800782:	89 f0                	mov    %esi,%eax
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	8b 55 10             	mov    0x10(%ebp),%edx
  800796:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 21                	je     8007bd <strlcpy+0x35>
  80079c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	eb 09                	jmp    8007ad <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ad:	39 c2                	cmp    %eax,%edx
  8007af:	74 09                	je     8007ba <strlcpy+0x32>
  8007b1:	0f b6 19             	movzbl (%ecx),%ebx
  8007b4:	84 db                	test   %bl,%bl
  8007b6:	75 ec                	jne    8007a4 <strlcpy+0x1c>
  8007b8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ba:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bd:	29 f0                	sub    %esi,%eax
}
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cc:	eb 06                	jmp    8007d4 <strcmp+0x11>
		p++, q++;
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d4:	0f b6 01             	movzbl (%ecx),%eax
  8007d7:	84 c0                	test   %al,%al
  8007d9:	74 04                	je     8007df <strcmp+0x1c>
  8007db:	3a 02                	cmp    (%edx),%al
  8007dd:	74 ef                	je     8007ce <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007df:	0f b6 c0             	movzbl %al,%eax
  8007e2:	0f b6 12             	movzbl (%edx),%edx
  8007e5:	29 d0                	sub    %edx,%eax
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	89 c3                	mov    %eax,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strncmp+0x17>
		n--, p++, q++;
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800800:	39 d8                	cmp    %ebx,%eax
  800802:	74 15                	je     800819 <strncmp+0x30>
  800804:	0f b6 08             	movzbl (%eax),%ecx
  800807:	84 c9                	test   %cl,%cl
  800809:	74 04                	je     80080f <strncmp+0x26>
  80080b:	3a 0a                	cmp    (%edx),%cl
  80080d:	74 eb                	je     8007fa <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080f:	0f b6 00             	movzbl (%eax),%eax
  800812:	0f b6 12             	movzbl (%edx),%edx
  800815:	29 d0                	sub    %edx,%eax
  800817:	eb 05                	jmp    80081e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081e:	5b                   	pop    %ebx
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 07                	jmp    800834 <strchr+0x13>
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 0f                	je     800840 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	0f b6 10             	movzbl (%eax),%edx
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084c:	eb 03                	jmp    800851 <strfind+0xf>
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	74 04                	je     80085c <strfind+0x1a>
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f2                	jne    80084e <strfind+0xc>
			break;
	return (char *) s;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
  800867:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086a:	85 c9                	test   %ecx,%ecx
  80086c:	74 36                	je     8008a4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800874:	75 28                	jne    80089e <memset+0x40>
  800876:	f6 c1 03             	test   $0x3,%cl
  800879:	75 23                	jne    80089e <memset+0x40>
		c &= 0xFF;
  80087b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087f:	89 d3                	mov    %edx,%ebx
  800881:	c1 e3 08             	shl    $0x8,%ebx
  800884:	89 d6                	mov    %edx,%esi
  800886:	c1 e6 18             	shl    $0x18,%esi
  800889:	89 d0                	mov    %edx,%eax
  80088b:	c1 e0 10             	shl    $0x10,%eax
  80088e:	09 f0                	or     %esi,%eax
  800890:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800892:	89 d8                	mov    %ebx,%eax
  800894:	09 d0                	or     %edx,%eax
  800896:	c1 e9 02             	shr    $0x2,%ecx
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 06                	jmp    8008a4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	fc                   	cld    
  8008a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a4:	89 f8                	mov    %edi,%eax
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b9:	39 c6                	cmp    %eax,%esi
  8008bb:	73 35                	jae    8008f2 <memmove+0x47>
  8008bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c0:	39 d0                	cmp    %edx,%eax
  8008c2:	73 2e                	jae    8008f2 <memmove+0x47>
		s += n;
		d += n;
  8008c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	09 fe                	or     %edi,%esi
  8008cb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d1:	75 13                	jne    8008e6 <memmove+0x3b>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 0e                	jne    8008e6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d8:	83 ef 04             	sub    $0x4,%edi
  8008db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008de:	c1 e9 02             	shr    $0x2,%ecx
  8008e1:	fd                   	std    
  8008e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e4:	eb 09                	jmp    8008ef <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e6:	83 ef 01             	sub    $0x1,%edi
  8008e9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ec:	fd                   	std    
  8008ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ef:	fc                   	cld    
  8008f0:	eb 1d                	jmp    80090f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	09 c2                	or     %eax,%edx
  8008f6:	f6 c2 03             	test   $0x3,%dl
  8008f9:	75 0f                	jne    80090a <memmove+0x5f>
  8008fb:	f6 c1 03             	test   $0x3,%cl
  8008fe:	75 0a                	jne    80090a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800900:	c1 e9 02             	shr    $0x2,%ecx
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800908:	eb 05                	jmp    80090f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090a:	89 c7                	mov    %eax,%edi
  80090c:	fc                   	cld    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 87 ff ff ff       	call   8008ab <memmove>
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 c6                	mov    %eax,%esi
  800933:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800936:	eb 1a                	jmp    800952 <memcmp+0x2c>
		if (*s1 != *s2)
  800938:	0f b6 08             	movzbl (%eax),%ecx
  80093b:	0f b6 1a             	movzbl (%edx),%ebx
  80093e:	38 d9                	cmp    %bl,%cl
  800940:	74 0a                	je     80094c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800942:	0f b6 c1             	movzbl %cl,%eax
  800945:	0f b6 db             	movzbl %bl,%ebx
  800948:	29 d8                	sub    %ebx,%eax
  80094a:	eb 0f                	jmp    80095b <memcmp+0x35>
		s1++, s2++;
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800952:	39 f0                	cmp    %esi,%eax
  800954:	75 e2                	jne    800938 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800966:	89 c1                	mov    %eax,%ecx
  800968:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096f:	eb 0a                	jmp    80097b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	39 da                	cmp    %ebx,%edx
  800976:	74 07                	je     80097f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	39 c8                	cmp    %ecx,%eax
  80097d:	72 f2                	jb     800971 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097f:	5b                   	pop    %ebx
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098e:	eb 03                	jmp    800993 <strtol+0x11>
		s++;
  800990:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	3c 20                	cmp    $0x20,%al
  800998:	74 f6                	je     800990 <strtol+0xe>
  80099a:	3c 09                	cmp    $0x9,%al
  80099c:	74 f2                	je     800990 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099e:	3c 2b                	cmp    $0x2b,%al
  8009a0:	75 0a                	jne    8009ac <strtol+0x2a>
		s++;
  8009a2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009aa:	eb 11                	jmp    8009bd <strtol+0x3b>
  8009ac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b1:	3c 2d                	cmp    $0x2d,%al
  8009b3:	75 08                	jne    8009bd <strtol+0x3b>
		s++, neg = 1;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c3:	75 15                	jne    8009da <strtol+0x58>
  8009c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c8:	75 10                	jne    8009da <strtol+0x58>
  8009ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ce:	75 7c                	jne    800a4c <strtol+0xca>
		s += 2, base = 16;
  8009d0:	83 c1 02             	add    $0x2,%ecx
  8009d3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d8:	eb 16                	jmp    8009f0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009da:	85 db                	test   %ebx,%ebx
  8009dc:	75 12                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009de:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e6:	75 08                	jne    8009f0 <strtol+0x6e>
		s++, base = 8;
  8009e8:	83 c1 01             	add    $0x1,%ecx
  8009eb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f8:	0f b6 11             	movzbl (%ecx),%edx
  8009fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	80 fb 09             	cmp    $0x9,%bl
  800a03:	77 08                	ja     800a0d <strtol+0x8b>
			dig = *s - '0';
  800a05:	0f be d2             	movsbl %dl,%edx
  800a08:	83 ea 30             	sub    $0x30,%edx
  800a0b:	eb 22                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 19             	cmp    $0x19,%bl
  800a15:	77 08                	ja     800a1f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a17:	0f be d2             	movsbl %dl,%edx
  800a1a:	83 ea 57             	sub    $0x57,%edx
  800a1d:	eb 10                	jmp    800a2f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 19             	cmp    $0x19,%bl
  800a27:	77 16                	ja     800a3f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a29:	0f be d2             	movsbl %dl,%edx
  800a2c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a32:	7d 0b                	jge    800a3f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3d:	eb b9                	jmp    8009f8 <strtol+0x76>

	if (endptr)
  800a3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a43:	74 0d                	je     800a52 <strtol+0xd0>
		*endptr = (char *) s;
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	89 0e                	mov    %ecx,(%esi)
  800a4a:	eb 06                	jmp    800a52 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	74 98                	je     8009e8 <strtol+0x66>
  800a50:	eb 9e                	jmp    8009f0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	f7 da                	neg    %edx
  800a56:	85 ff                	test   %edi,%edi
  800a58:	0f 45 c2             	cmovne %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	89 c7                	mov    %eax,%edi
  800a75:	89 c6                	mov    %eax,%esi
  800a77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8e:	89 d1                	mov    %edx,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aab:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	89 cb                	mov    %ecx,%ebx
  800ab5:	89 cf                	mov    %ecx,%edi
  800ab7:	89 ce                	mov    %ecx,%esi
  800ab9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 17                	jle    800ad6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	6a 03                	push   $0x3
  800ac5:	68 5f 21 80 00       	push   $0x80215f
  800aca:	6a 23                	push   $0x23
  800acc:	68 7c 21 80 00       	push   $0x80217c
  800ad1:	e8 39 10 00 00       	call   801b0f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 02 00 00 00       	mov    $0x2,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_yield>:

void
sys_yield(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	be 00 00 00 00       	mov    $0x0,%esi
  800b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b38:	89 f7                	mov    %esi,%edi
  800b3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 04                	push   $0x4
  800b46:	68 5f 21 80 00       	push   $0x80215f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 7c 21 80 00       	push   $0x80217c
  800b52:	e8 b8 0f 00 00       	call   801b0f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b79:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 05                	push   $0x5
  800b88:	68 5f 21 80 00       	push   $0x80215f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 7c 21 80 00       	push   $0x80217c
  800b94:	e8 76 0f 00 00       	call   801b0f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	89 df                	mov    %ebx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 06                	push   $0x6
  800bca:	68 5f 21 80 00       	push   $0x80215f
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 7c 21 80 00       	push   $0x80217c
  800bd6:	e8 34 0f 00 00       	call   801b0f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf1:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	89 df                	mov    %ebx,%edi
  800bfe:	89 de                	mov    %ebx,%esi
  800c00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 08                	push   $0x8
  800c0c:	68 5f 21 80 00       	push   $0x80215f
  800c11:	6a 23                	push   $0x23
  800c13:	68 7c 21 80 00       	push   $0x80217c
  800c18:	e8 f2 0e 00 00       	call   801b0f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 09 00 00 00       	mov    $0x9,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 09                	push   $0x9
  800c4e:	68 5f 21 80 00       	push   $0x80215f
  800c53:	6a 23                	push   $0x23
  800c55:	68 7c 21 80 00       	push   $0x80217c
  800c5a:	e8 b0 0e 00 00       	call   801b0f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 0a                	push   $0xa
  800c90:	68 5f 21 80 00       	push   $0x80215f
  800c95:	6a 23                	push   $0x23
  800c97:	68 7c 21 80 00       	push   $0x80217c
  800c9c:	e8 6e 0e 00 00       	call   801b0f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0d                	push   $0xd
  800cf4:	68 5f 21 80 00       	push   $0x80215f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 7c 21 80 00       	push   $0x80217c
  800d00:	e8 0a 0e 00 00       	call   801b0f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 75 08             	mov    0x8(%ebp),%esi
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	74 3e                	je     800d5d <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	50                   	push   %eax
  800d23:	e8 a4 ff ff ff       	call   800ccc <sys_ipc_recv>
  800d28:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  800d2a:	83 c4 10             	add    $0x10,%esp
  800d2d:	85 f6                	test   %esi,%esi
  800d2f:	74 13                	je     800d44 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
  800d36:	85 d2                	test   %edx,%edx
  800d38:	75 08                	jne    800d42 <ipc_recv+0x35>
  800d3a:	a1 04 40 80 00       	mov    0x804004,%eax
  800d3f:	8b 40 74             	mov    0x74(%eax),%eax
  800d42:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  800d44:	85 db                	test   %ebx,%ebx
  800d46:	74 48                	je     800d90 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  800d48:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4d:	85 d2                	test   %edx,%edx
  800d4f:	75 08                	jne    800d59 <ipc_recv+0x4c>
  800d51:	a1 04 40 80 00       	mov    0x804004,%eax
  800d56:	8b 40 78             	mov    0x78(%eax),%eax
  800d59:	89 03                	mov    %eax,(%ebx)
  800d5b:	eb 33                	jmp    800d90 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	68 00 00 c0 ee       	push   $0xeec00000
  800d65:	e8 62 ff ff ff       	call   800ccc <sys_ipc_recv>
  800d6a:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	85 f6                	test   %esi,%esi
  800d71:	74 13                	je     800d86 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	85 d2                	test   %edx,%edx
  800d7a:	75 08                	jne    800d84 <ipc_recv+0x77>
  800d7c:	a1 04 40 80 00       	mov    0x804004,%eax
  800d81:	8b 40 74             	mov    0x74(%eax),%eax
  800d84:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  800d86:	85 db                	test   %ebx,%ebx
  800d88:	74 06                	je     800d90 <ipc_recv+0x83>
			*perm_store = 0;
  800d8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  800d90:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  800d92:	85 d2                	test   %edx,%edx
  800d94:	75 08                	jne    800d9e <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  800d96:	a1 04 40 80 00       	mov    0x804004,%eax
  800d9b:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  800d9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  800db7:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  800db9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800dbe:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800dc1:	eb 1c                	jmp    800ddf <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  800dc3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800dc6:	74 12                	je     800dda <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  800dc8:	50                   	push   %eax
  800dc9:	68 8a 21 80 00       	push   $0x80218a
  800dce:	6a 4f                	push   $0x4f
  800dd0:	68 a5 21 80 00       	push   $0x8021a5
  800dd5:	e8 35 0d 00 00       	call   801b0f <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  800dda:	e8 1e fd ff ff       	call   800afd <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  800ddf:	ff 75 14             	pushl  0x14(%ebp)
  800de2:	53                   	push   %ebx
  800de3:	56                   	push   %esi
  800de4:	57                   	push   %edi
  800de5:	e8 bf fe ff ff       	call   800ca9 <sys_ipc_try_send>
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	78 d2                	js     800dc3 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  800df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e04:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e07:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e0d:	8b 52 50             	mov    0x50(%edx),%edx
  800e10:	39 ca                	cmp    %ecx,%edx
  800e12:	75 0d                	jne    800e21 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e14:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e17:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e1c:	8b 40 48             	mov    0x48(%eax),%eax
  800e1f:	eb 0f                	jmp    800e30 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e21:	83 c0 01             	add    $0x1,%eax
  800e24:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e29:	75 d9                	jne    800e04 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e52:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 16             	shr    $0x16,%edx
  800e69:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	74 11                	je     800e86 <fd_alloc+0x2d>
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	c1 ea 0c             	shr    $0xc,%edx
  800e7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e81:	f6 c2 01             	test   $0x1,%dl
  800e84:	75 09                	jne    800e8f <fd_alloc+0x36>
			*fd_store = fd;
  800e86:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	eb 17                	jmp    800ea6 <fd_alloc+0x4d>
  800e8f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e94:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e99:	75 c9                	jne    800e64 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e9b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eae:	83 f8 1f             	cmp    $0x1f,%eax
  800eb1:	77 36                	ja     800ee9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb3:	c1 e0 0c             	shl    $0xc,%eax
  800eb6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	c1 ea 16             	shr    $0x16,%edx
  800ec0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec7:	f6 c2 01             	test   $0x1,%dl
  800eca:	74 24                	je     800ef0 <fd_lookup+0x48>
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	c1 ea 0c             	shr    $0xc,%edx
  800ed1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed8:	f6 c2 01             	test   $0x1,%dl
  800edb:	74 1a                	je     800ef7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee0:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee7:	eb 13                	jmp    800efc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eee:	eb 0c                	jmp    800efc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef5:	eb 05                	jmp    800efc <fd_lookup+0x54>
  800ef7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f07:	ba 2c 22 80 00       	mov    $0x80222c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0c:	eb 13                	jmp    800f21 <dev_lookup+0x23>
  800f0e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f11:	39 08                	cmp    %ecx,(%eax)
  800f13:	75 0c                	jne    800f21 <dev_lookup+0x23>
			*dev = devtab[i];
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1f:	eb 2e                	jmp    800f4f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f21:	8b 02                	mov    (%edx),%eax
  800f23:	85 c0                	test   %eax,%eax
  800f25:	75 e7                	jne    800f0e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f27:	a1 04 40 80 00       	mov    0x804004,%eax
  800f2c:	8b 40 48             	mov    0x48(%eax),%eax
  800f2f:	83 ec 04             	sub    $0x4,%esp
  800f32:	51                   	push   %ecx
  800f33:	50                   	push   %eax
  800f34:	68 b0 21 80 00       	push   $0x8021b0
  800f39:	e8 56 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	83 ec 10             	sub    $0x10,%esp
  800f59:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f62:	50                   	push   %eax
  800f63:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f69:	c1 e8 0c             	shr    $0xc,%eax
  800f6c:	50                   	push   %eax
  800f6d:	e8 36 ff ff ff       	call   800ea8 <fd_lookup>
  800f72:	83 c4 08             	add    $0x8,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 05                	js     800f7e <fd_close+0x2d>
	    || fd != fd2)
  800f79:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7c:	74 0c                	je     800f8a <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7e:	84 db                	test   %bl,%bl
  800f80:	ba 00 00 00 00       	mov    $0x0,%edx
  800f85:	0f 44 c2             	cmove  %edx,%eax
  800f88:	eb 41                	jmp    800fcb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8a:	83 ec 08             	sub    $0x8,%esp
  800f8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f90:	50                   	push   %eax
  800f91:	ff 36                	pushl  (%esi)
  800f93:	e8 66 ff ff ff       	call   800efe <dev_lookup>
  800f98:	89 c3                	mov    %eax,%ebx
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 1a                	js     800fbb <fd_close+0x6a>
		if (dev->dev_close)
  800fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	74 0b                	je     800fbb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	56                   	push   %esi
  800fb4:	ff d0                	call   *%eax
  800fb6:	89 c3                	mov    %eax,%ebx
  800fb8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	56                   	push   %esi
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 db fb ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	89 d8                	mov    %ebx,%eax
}
  800fcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff 75 08             	pushl  0x8(%ebp)
  800fdf:	e8 c4 fe ff ff       	call   800ea8 <fd_lookup>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 10                	js     800ffb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	6a 01                	push   $0x1
  800ff0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff3:	e8 59 ff ff ff       	call   800f51 <fd_close>
  800ff8:	83 c4 10             	add    $0x10,%esp
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <close_all>:

void
close_all(void)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	53                   	push   %ebx
  801001:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801004:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	53                   	push   %ebx
  80100d:	e8 c0 ff ff ff       	call   800fd2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801012:	83 c3 01             	add    $0x1,%ebx
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	83 fb 20             	cmp    $0x20,%ebx
  80101b:	75 ec                	jne    801009 <close_all+0xc>
		close(i);
}
  80101d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	83 ec 2c             	sub    $0x2c,%esp
  80102b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	ff 75 08             	pushl  0x8(%ebp)
  801035:	e8 6e fe ff ff       	call   800ea8 <fd_lookup>
  80103a:	83 c4 08             	add    $0x8,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	0f 88 c1 00 00 00    	js     801106 <dup+0xe4>
		return r;
	close(newfdnum);
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	56                   	push   %esi
  801049:	e8 84 ff ff ff       	call   800fd2 <close>

	newfd = INDEX2FD(newfdnum);
  80104e:	89 f3                	mov    %esi,%ebx
  801050:	c1 e3 0c             	shl    $0xc,%ebx
  801053:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801059:	83 c4 04             	add    $0x4,%esp
  80105c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105f:	e8 de fd ff ff       	call   800e42 <fd2data>
  801064:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801066:	89 1c 24             	mov    %ebx,(%esp)
  801069:	e8 d4 fd ff ff       	call   800e42 <fd2data>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801074:	89 f8                	mov    %edi,%eax
  801076:	c1 e8 16             	shr    $0x16,%eax
  801079:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801080:	a8 01                	test   $0x1,%al
  801082:	74 37                	je     8010bb <dup+0x99>
  801084:	89 f8                	mov    %edi,%eax
  801086:	c1 e8 0c             	shr    $0xc,%eax
  801089:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801090:	f6 c2 01             	test   $0x1,%dl
  801093:	74 26                	je     8010bb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801095:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a4:	50                   	push   %eax
  8010a5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a8:	6a 00                	push   $0x0
  8010aa:	57                   	push   %edi
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 ad fa ff ff       	call   800b5f <sys_page_map>
  8010b2:	89 c7                	mov    %eax,%edi
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 2e                	js     8010e9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010be:	89 d0                	mov    %edx,%eax
  8010c0:	c1 e8 0c             	shr    $0xc,%eax
  8010c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d2:	50                   	push   %eax
  8010d3:	53                   	push   %ebx
  8010d4:	6a 00                	push   $0x0
  8010d6:	52                   	push   %edx
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 81 fa ff ff       	call   800b5f <sys_page_map>
  8010de:	89 c7                	mov    %eax,%edi
  8010e0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e5:	85 ff                	test   %edi,%edi
  8010e7:	79 1d                	jns    801106 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	53                   	push   %ebx
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 ad fa ff ff       	call   800ba1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 a0 fa ff ff       	call   800ba1 <sys_page_unmap>
	return r;
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	89 f8                	mov    %edi,%eax
}
  801106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5f                   	pop    %edi
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	53                   	push   %ebx
  801112:	83 ec 14             	sub    $0x14,%esp
  801115:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801118:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111b:	50                   	push   %eax
  80111c:	53                   	push   %ebx
  80111d:	e8 86 fd ff ff       	call   800ea8 <fd_lookup>
  801122:	83 c4 08             	add    $0x8,%esp
  801125:	89 c2                	mov    %eax,%edx
  801127:	85 c0                	test   %eax,%eax
  801129:	78 6d                	js     801198 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801135:	ff 30                	pushl  (%eax)
  801137:	e8 c2 fd ff ff       	call   800efe <dev_lookup>
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 4c                	js     80118f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801143:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801146:	8b 42 08             	mov    0x8(%edx),%eax
  801149:	83 e0 03             	and    $0x3,%eax
  80114c:	83 f8 01             	cmp    $0x1,%eax
  80114f:	75 21                	jne    801172 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801151:	a1 04 40 80 00       	mov    0x804004,%eax
  801156:	8b 40 48             	mov    0x48(%eax),%eax
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	53                   	push   %ebx
  80115d:	50                   	push   %eax
  80115e:	68 f1 21 80 00       	push   $0x8021f1
  801163:	e8 2c f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801170:	eb 26                	jmp    801198 <read+0x8a>
	}
	if (!dev->dev_read)
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	8b 40 08             	mov    0x8(%eax),%eax
  801178:	85 c0                	test   %eax,%eax
  80117a:	74 17                	je     801193 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	ff 75 10             	pushl  0x10(%ebp)
  801182:	ff 75 0c             	pushl  0xc(%ebp)
  801185:	52                   	push   %edx
  801186:	ff d0                	call   *%eax
  801188:	89 c2                	mov    %eax,%edx
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	eb 09                	jmp    801198 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118f:	89 c2                	mov    %eax,%edx
  801191:	eb 05                	jmp    801198 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801193:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801198:	89 d0                	mov    %edx,%eax
  80119a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b3:	eb 21                	jmp    8011d6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	89 f0                	mov    %esi,%eax
  8011ba:	29 d8                	sub    %ebx,%eax
  8011bc:	50                   	push   %eax
  8011bd:	89 d8                	mov    %ebx,%eax
  8011bf:	03 45 0c             	add    0xc(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	57                   	push   %edi
  8011c4:	e8 45 ff ff ff       	call   80110e <read>
		if (m < 0)
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 10                	js     8011e0 <readn+0x41>
			return m;
		if (m == 0)
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	74 0a                	je     8011de <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d4:	01 c3                	add    %eax,%ebx
  8011d6:	39 f3                	cmp    %esi,%ebx
  8011d8:	72 db                	jb     8011b5 <readn+0x16>
  8011da:	89 d8                	mov    %ebx,%eax
  8011dc:	eb 02                	jmp    8011e0 <readn+0x41>
  8011de:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 14             	sub    $0x14,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	53                   	push   %ebx
  8011f7:	e8 ac fc ff ff       	call   800ea8 <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	78 68                	js     80126d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	ff 30                	pushl  (%eax)
  801211:	e8 e8 fc ff ff       	call   800efe <dev_lookup>
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 47                	js     801264 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801220:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801224:	75 21                	jne    801247 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801226:	a1 04 40 80 00       	mov    0x804004,%eax
  80122b:	8b 40 48             	mov    0x48(%eax),%eax
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	53                   	push   %ebx
  801232:	50                   	push   %eax
  801233:	68 0d 22 80 00       	push   $0x80220d
  801238:	e8 57 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801245:	eb 26                	jmp    80126d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801247:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124a:	8b 52 0c             	mov    0xc(%edx),%edx
  80124d:	85 d2                	test   %edx,%edx
  80124f:	74 17                	je     801268 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	ff 75 10             	pushl  0x10(%ebp)
  801257:	ff 75 0c             	pushl  0xc(%ebp)
  80125a:	50                   	push   %eax
  80125b:	ff d2                	call   *%edx
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	eb 09                	jmp    80126d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801264:	89 c2                	mov    %eax,%edx
  801266:	eb 05                	jmp    80126d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801268:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126d:	89 d0                	mov    %edx,%eax
  80126f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <seek>:

int
seek(int fdnum, off_t offset)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	ff 75 08             	pushl  0x8(%ebp)
  801281:	e8 22 fc ff ff       	call   800ea8 <fd_lookup>
  801286:	83 c4 08             	add    $0x8,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 0e                	js     80129b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801290:	8b 55 0c             	mov    0xc(%ebp),%edx
  801293:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 14             	sub    $0x14,%esp
  8012a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012aa:	50                   	push   %eax
  8012ab:	53                   	push   %ebx
  8012ac:	e8 f7 fb ff ff       	call   800ea8 <fd_lookup>
  8012b1:	83 c4 08             	add    $0x8,%esp
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 65                	js     80131f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	ff 30                	pushl  (%eax)
  8012c6:	e8 33 fc ff ff       	call   800efe <dev_lookup>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 44                	js     801316 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d9:	75 21                	jne    8012fc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012db:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e0:	8b 40 48             	mov    0x48(%eax),%eax
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	53                   	push   %ebx
  8012e7:	50                   	push   %eax
  8012e8:	68 d0 21 80 00       	push   $0x8021d0
  8012ed:	e8 a2 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012fa:	eb 23                	jmp    80131f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ff:	8b 52 18             	mov    0x18(%edx),%edx
  801302:	85 d2                	test   %edx,%edx
  801304:	74 14                	je     80131a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	ff 75 0c             	pushl  0xc(%ebp)
  80130c:	50                   	push   %eax
  80130d:	ff d2                	call   *%edx
  80130f:	89 c2                	mov    %eax,%edx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	eb 09                	jmp    80131f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	89 c2                	mov    %eax,%edx
  801318:	eb 05                	jmp    80131f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80131a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131f:	89 d0                	mov    %edx,%eax
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	83 ec 14             	sub    $0x14,%esp
  80132d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801330:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801333:	50                   	push   %eax
  801334:	ff 75 08             	pushl  0x8(%ebp)
  801337:	e8 6c fb ff ff       	call   800ea8 <fd_lookup>
  80133c:	83 c4 08             	add    $0x8,%esp
  80133f:	89 c2                	mov    %eax,%edx
  801341:	85 c0                	test   %eax,%eax
  801343:	78 58                	js     80139d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	ff 30                	pushl  (%eax)
  801351:	e8 a8 fb ff ff       	call   800efe <dev_lookup>
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 37                	js     801394 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801360:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801364:	74 32                	je     801398 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801366:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801369:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801370:	00 00 00 
	stat->st_isdir = 0;
  801373:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80137a:	00 00 00 
	stat->st_dev = dev;
  80137d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	53                   	push   %ebx
  801387:	ff 75 f0             	pushl  -0x10(%ebp)
  80138a:	ff 50 14             	call   *0x14(%eax)
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	eb 09                	jmp    80139d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	89 c2                	mov    %eax,%edx
  801396:	eb 05                	jmp    80139d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801398:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139d:	89 d0                	mov    %edx,%eax
  80139f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a2:	c9                   	leave  
  8013a3:	c3                   	ret    

008013a4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	6a 00                	push   $0x0
  8013ae:	ff 75 08             	pushl  0x8(%ebp)
  8013b1:	e8 d6 01 00 00       	call   80158c <open>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 1b                	js     8013da <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	ff 75 0c             	pushl  0xc(%ebp)
  8013c5:	50                   	push   %eax
  8013c6:	e8 5b ff ff ff       	call   801326 <fstat>
  8013cb:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cd:	89 1c 24             	mov    %ebx,(%esp)
  8013d0:	e8 fd fb ff ff       	call   800fd2 <close>
	return r;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	89 f0                	mov    %esi,%eax
}
  8013da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	89 c6                	mov    %eax,%esi
  8013e8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013ea:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f1:	75 12                	jne    801405 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	6a 01                	push   $0x1
  8013f8:	e8 fc f9 ff ff       	call   800df9 <ipc_find_env>
  8013fd:	a3 00 40 80 00       	mov    %eax,0x804000
  801402:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801405:	6a 07                	push   $0x7
  801407:	68 00 50 80 00       	push   $0x805000
  80140c:	56                   	push   %esi
  80140d:	ff 35 00 40 80 00    	pushl  0x804000
  801413:	e8 8d f9 ff ff       	call   800da5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801418:	83 c4 0c             	add    $0xc,%esp
  80141b:	6a 00                	push   $0x0
  80141d:	53                   	push   %ebx
  80141e:	6a 00                	push   $0x0
  801420:	e8 e8 f8 ff ff       	call   800d0d <ipc_recv>
}
  801425:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	8b 40 0c             	mov    0xc(%eax),%eax
  801438:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801440:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
  80144a:	b8 02 00 00 00       	mov    $0x2,%eax
  80144f:	e8 8d ff ff ff       	call   8013e1 <fsipc>
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145c:	8b 45 08             	mov    0x8(%ebp),%eax
  80145f:	8b 40 0c             	mov    0xc(%eax),%eax
  801462:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801467:	ba 00 00 00 00       	mov    $0x0,%edx
  80146c:	b8 06 00 00 00       	mov    $0x6,%eax
  801471:	e8 6b ff ff ff       	call   8013e1 <fsipc>
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	53                   	push   %ebx
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	8b 40 0c             	mov    0xc(%eax),%eax
  801488:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148d:	ba 00 00 00 00       	mov    $0x0,%edx
  801492:	b8 05 00 00 00       	mov    $0x5,%eax
  801497:	e8 45 ff ff ff       	call   8013e1 <fsipc>
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 2c                	js     8014cc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	68 00 50 80 00       	push   $0x805000
  8014a8:	53                   	push   %ebx
  8014a9:	e8 6b f2 ff ff       	call   800719 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ae:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b9:	a1 84 50 80 00       	mov    0x805084,%eax
  8014be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014da:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014e6:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8014eb:	50                   	push   %eax
  8014ec:	ff 75 0c             	pushl  0xc(%ebp)
  8014ef:	68 08 50 80 00       	push   $0x805008
  8014f4:	e8 b2 f3 ff ff       	call   8008ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801503:	e8 d9 fe ff ff       	call   8013e1 <fsipc>
	//panic("devfile_write not implemented");
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	56                   	push   %esi
  80150e:	53                   	push   %ebx
  80150f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	8b 40 0c             	mov    0xc(%eax),%eax
  801518:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801523:	ba 00 00 00 00       	mov    $0x0,%edx
  801528:	b8 03 00 00 00       	mov    $0x3,%eax
  80152d:	e8 af fe ff ff       	call   8013e1 <fsipc>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	85 c0                	test   %eax,%eax
  801536:	78 4b                	js     801583 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801538:	39 c6                	cmp    %eax,%esi
  80153a:	73 16                	jae    801552 <devfile_read+0x48>
  80153c:	68 3c 22 80 00       	push   $0x80223c
  801541:	68 43 22 80 00       	push   $0x802243
  801546:	6a 7c                	push   $0x7c
  801548:	68 58 22 80 00       	push   $0x802258
  80154d:	e8 bd 05 00 00       	call   801b0f <_panic>
	assert(r <= PGSIZE);
  801552:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801557:	7e 16                	jle    80156f <devfile_read+0x65>
  801559:	68 63 22 80 00       	push   $0x802263
  80155e:	68 43 22 80 00       	push   $0x802243
  801563:	6a 7d                	push   $0x7d
  801565:	68 58 22 80 00       	push   $0x802258
  80156a:	e8 a0 05 00 00       	call   801b0f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	50                   	push   %eax
  801573:	68 00 50 80 00       	push   $0x805000
  801578:	ff 75 0c             	pushl  0xc(%ebp)
  80157b:	e8 2b f3 ff ff       	call   8008ab <memmove>
	return r;
  801580:	83 c4 10             	add    $0x10,%esp
}
  801583:	89 d8                	mov    %ebx,%eax
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 20             	sub    $0x20,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801596:	53                   	push   %ebx
  801597:	e8 44 f1 ff ff       	call   8006e0 <strlen>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a4:	7f 67                	jg     80160d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a6:	83 ec 0c             	sub    $0xc,%esp
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	e8 a7 f8 ff ff       	call   800e59 <fd_alloc>
  8015b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 57                	js     801612 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	53                   	push   %ebx
  8015bf:	68 00 50 80 00       	push   $0x805000
  8015c4:	e8 50 f1 ff ff       	call   800719 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d9:	e8 03 fe ff ff       	call   8013e1 <fsipc>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	79 14                	jns    8015fb <open+0x6f>
		fd_close(fd, 0);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	6a 00                	push   $0x0
  8015ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ef:	e8 5d f9 ff ff       	call   800f51 <fd_close>
		return r;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	89 da                	mov    %ebx,%edx
  8015f9:	eb 17                	jmp    801612 <open+0x86>
	}

	return fd2num(fd);
  8015fb:	83 ec 0c             	sub    $0xc,%esp
  8015fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801601:	e8 2c f8 ff ff       	call   800e32 <fd2num>
  801606:	89 c2                	mov    %eax,%edx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	eb 05                	jmp    801612 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801612:	89 d0                	mov    %edx,%eax
  801614:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80161f:	ba 00 00 00 00       	mov    $0x0,%edx
  801624:	b8 08 00 00 00       	mov    $0x8,%eax
  801629:	e8 b3 fd ff ff       	call   8013e1 <fsipc>
}
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	56                   	push   %esi
  801634:	53                   	push   %ebx
  801635:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	ff 75 08             	pushl  0x8(%ebp)
  80163e:	e8 ff f7 ff ff       	call   800e42 <fd2data>
  801643:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801645:	83 c4 08             	add    $0x8,%esp
  801648:	68 6f 22 80 00       	push   $0x80226f
  80164d:	53                   	push   %ebx
  80164e:	e8 c6 f0 ff ff       	call   800719 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801653:	8b 46 04             	mov    0x4(%esi),%eax
  801656:	2b 06                	sub    (%esi),%eax
  801658:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80165e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801665:	00 00 00 
	stat->st_dev = &devpipe;
  801668:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80166f:	30 80 00 
	return 0;
}
  801672:	b8 00 00 00 00       	mov    $0x0,%eax
  801677:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 0c             	sub    $0xc,%esp
  801685:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801688:	53                   	push   %ebx
  801689:	6a 00                	push   $0x0
  80168b:	e8 11 f5 ff ff       	call   800ba1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801690:	89 1c 24             	mov    %ebx,(%esp)
  801693:	e8 aa f7 ff ff       	call   800e42 <fd2data>
  801698:	83 c4 08             	add    $0x8,%esp
  80169b:	50                   	push   %eax
  80169c:	6a 00                	push   $0x0
  80169e:	e8 fe f4 ff ff       	call   800ba1 <sys_page_unmap>
}
  8016a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	57                   	push   %edi
  8016ac:	56                   	push   %esi
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 1c             	sub    $0x1c,%esp
  8016b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8016c4:	e8 8c 04 00 00       	call   801b55 <pageref>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	89 3c 24             	mov    %edi,(%esp)
  8016ce:	e8 82 04 00 00       	call   801b55 <pageref>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	39 c3                	cmp    %eax,%ebx
  8016d8:	0f 94 c1             	sete   %cl
  8016db:	0f b6 c9             	movzbl %cl,%ecx
  8016de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016e1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016e7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ea:	39 ce                	cmp    %ecx,%esi
  8016ec:	74 1b                	je     801709 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016ee:	39 c3                	cmp    %eax,%ebx
  8016f0:	75 c4                	jne    8016b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016f2:	8b 42 58             	mov    0x58(%edx),%eax
  8016f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f8:	50                   	push   %eax
  8016f9:	56                   	push   %esi
  8016fa:	68 76 22 80 00       	push   $0x802276
  8016ff:	e8 90 ea ff ff       	call   800194 <cprintf>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	eb ad                	jmp    8016b6 <_pipeisclosed+0xe>
	}
}
  801709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80170c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	5f                   	pop    %edi
  801712:	5d                   	pop    %ebp
  801713:	c3                   	ret    

00801714 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	57                   	push   %edi
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	83 ec 28             	sub    $0x28,%esp
  80171d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801720:	56                   	push   %esi
  801721:	e8 1c f7 ff ff       	call   800e42 <fd2data>
  801726:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	bf 00 00 00 00       	mov    $0x0,%edi
  801730:	eb 4b                	jmp    80177d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801732:	89 da                	mov    %ebx,%edx
  801734:	89 f0                	mov    %esi,%eax
  801736:	e8 6d ff ff ff       	call   8016a8 <_pipeisclosed>
  80173b:	85 c0                	test   %eax,%eax
  80173d:	75 48                	jne    801787 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80173f:	e8 b9 f3 ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801744:	8b 43 04             	mov    0x4(%ebx),%eax
  801747:	8b 0b                	mov    (%ebx),%ecx
  801749:	8d 51 20             	lea    0x20(%ecx),%edx
  80174c:	39 d0                	cmp    %edx,%eax
  80174e:	73 e2                	jae    801732 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801750:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801753:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801757:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	c1 fa 1f             	sar    $0x1f,%edx
  80175f:	89 d1                	mov    %edx,%ecx
  801761:	c1 e9 1b             	shr    $0x1b,%ecx
  801764:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801767:	83 e2 1f             	and    $0x1f,%edx
  80176a:	29 ca                	sub    %ecx,%edx
  80176c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801770:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801774:	83 c0 01             	add    $0x1,%eax
  801777:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177a:	83 c7 01             	add    $0x1,%edi
  80177d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801780:	75 c2                	jne    801744 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801782:	8b 45 10             	mov    0x10(%ebp),%eax
  801785:	eb 05                	jmp    80178c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801787:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80178c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5f                   	pop    %edi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	57                   	push   %edi
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 18             	sub    $0x18,%esp
  80179d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017a0:	57                   	push   %edi
  8017a1:	e8 9c f6 ff ff       	call   800e42 <fd2data>
  8017a6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b0:	eb 3d                	jmp    8017ef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b2:	85 db                	test   %ebx,%ebx
  8017b4:	74 04                	je     8017ba <devpipe_read+0x26>
				return i;
  8017b6:	89 d8                	mov    %ebx,%eax
  8017b8:	eb 44                	jmp    8017fe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017ba:	89 f2                	mov    %esi,%edx
  8017bc:	89 f8                	mov    %edi,%eax
  8017be:	e8 e5 fe ff ff       	call   8016a8 <_pipeisclosed>
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	75 32                	jne    8017f9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017c7:	e8 31 f3 ff ff       	call   800afd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017cc:	8b 06                	mov    (%esi),%eax
  8017ce:	3b 46 04             	cmp    0x4(%esi),%eax
  8017d1:	74 df                	je     8017b2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d3:	99                   	cltd   
  8017d4:	c1 ea 1b             	shr    $0x1b,%edx
  8017d7:	01 d0                	add    %edx,%eax
  8017d9:	83 e0 1f             	and    $0x1f,%eax
  8017dc:	29 d0                	sub    %edx,%eax
  8017de:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017e9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ec:	83 c3 01             	add    $0x1,%ebx
  8017ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017f2:	75 d8                	jne    8017cc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f7:	eb 05                	jmp    8017fe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801801:	5b                   	pop    %ebx
  801802:	5e                   	pop    %esi
  801803:	5f                   	pop    %edi
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
  80180b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80180e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	e8 42 f6 ff ff       	call   800e59 <fd_alloc>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	85 c0                	test   %eax,%eax
  80181e:	0f 88 2c 01 00 00    	js     801950 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	68 07 04 00 00       	push   $0x407
  80182c:	ff 75 f4             	pushl  -0xc(%ebp)
  80182f:	6a 00                	push   $0x0
  801831:	e8 e6 f2 ff ff       	call   800b1c <sys_page_alloc>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	89 c2                	mov    %eax,%edx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	0f 88 0d 01 00 00    	js     801950 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801843:	83 ec 0c             	sub    $0xc,%esp
  801846:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	e8 0a f6 ff ff       	call   800e59 <fd_alloc>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 e2 00 00 00    	js     80193e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185c:	83 ec 04             	sub    $0x4,%esp
  80185f:	68 07 04 00 00       	push   $0x407
  801864:	ff 75 f0             	pushl  -0x10(%ebp)
  801867:	6a 00                	push   $0x0
  801869:	e8 ae f2 ff ff       	call   800b1c <sys_page_alloc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	0f 88 c3 00 00 00    	js     80193e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff 75 f4             	pushl  -0xc(%ebp)
  801881:	e8 bc f5 ff ff       	call   800e42 <fd2data>
  801886:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801888:	83 c4 0c             	add    $0xc,%esp
  80188b:	68 07 04 00 00       	push   $0x407
  801890:	50                   	push   %eax
  801891:	6a 00                	push   $0x0
  801893:	e8 84 f2 ff ff       	call   800b1c <sys_page_alloc>
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	0f 88 89 00 00 00    	js     80192e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ab:	e8 92 f5 ff ff       	call   800e42 <fd2data>
  8018b0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018b7:	50                   	push   %eax
  8018b8:	6a 00                	push   $0x0
  8018ba:	56                   	push   %esi
  8018bb:	6a 00                	push   $0x0
  8018bd:	e8 9d f2 ff ff       	call   800b5f <sys_page_map>
  8018c2:	89 c3                	mov    %eax,%ebx
  8018c4:	83 c4 20             	add    $0x20,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 55                	js     801920 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018cb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018e0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fb:	e8 32 f5 ff ff       	call   800e32 <fd2num>
  801900:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801903:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801905:	83 c4 04             	add    $0x4,%esp
  801908:	ff 75 f0             	pushl  -0x10(%ebp)
  80190b:	e8 22 f5 ff ff       	call   800e32 <fd2num>
  801910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801913:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
  80191e:	eb 30                	jmp    801950 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	56                   	push   %esi
  801924:	6a 00                	push   $0x0
  801926:	e8 76 f2 ff ff       	call   800ba1 <sys_page_unmap>
  80192b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	ff 75 f0             	pushl  -0x10(%ebp)
  801934:	6a 00                	push   $0x0
  801936:	e8 66 f2 ff ff       	call   800ba1 <sys_page_unmap>
  80193b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	ff 75 f4             	pushl  -0xc(%ebp)
  801944:	6a 00                	push   $0x0
  801946:	e8 56 f2 ff ff       	call   800ba1 <sys_page_unmap>
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801950:	89 d0                	mov    %edx,%eax
  801952:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5d                   	pop    %ebp
  801958:	c3                   	ret    

00801959 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	ff 75 08             	pushl  0x8(%ebp)
  801966:	e8 3d f5 ff ff       	call   800ea8 <fd_lookup>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 18                	js     80198a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	ff 75 f4             	pushl  -0xc(%ebp)
  801978:	e8 c5 f4 ff ff       	call   800e42 <fd2data>
	return _pipeisclosed(fd, p);
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	e8 21 fd ff ff       	call   8016a8 <_pipeisclosed>
  801987:	83 c4 10             	add    $0x10,%esp
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80199c:	68 8e 22 80 00       	push   $0x80228e
  8019a1:	ff 75 0c             	pushl  0xc(%ebp)
  8019a4:	e8 70 ed ff ff       	call   800719 <strcpy>
	return 0;
}
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019bc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c7:	eb 2d                	jmp    8019f6 <devcons_write+0x46>
		m = n - tot;
  8019c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019cc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019ce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019d1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019d6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	53                   	push   %ebx
  8019dd:	03 45 0c             	add    0xc(%ebp),%eax
  8019e0:	50                   	push   %eax
  8019e1:	57                   	push   %edi
  8019e2:	e8 c4 ee ff ff       	call   8008ab <memmove>
		sys_cputs(buf, m);
  8019e7:	83 c4 08             	add    $0x8,%esp
  8019ea:	53                   	push   %ebx
  8019eb:	57                   	push   %edi
  8019ec:	e8 6f f0 ff ff       	call   800a60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f1:	01 de                	add    %ebx,%esi
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	89 f0                	mov    %esi,%eax
  8019f8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019fb:	72 cc                	jb     8019c9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 08             	sub    $0x8,%esp
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a14:	74 2a                	je     801a40 <devcons_read+0x3b>
  801a16:	eb 05                	jmp    801a1d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a18:	e8 e0 f0 ff ff       	call   800afd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a1d:	e8 5c f0 ff ff       	call   800a7e <sys_cgetc>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	74 f2                	je     801a18 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 16                	js     801a40 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a2a:	83 f8 04             	cmp    $0x4,%eax
  801a2d:	74 0c                	je     801a3b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a32:	88 02                	mov    %al,(%edx)
	return 1;
  801a34:	b8 01 00 00 00       	mov    $0x1,%eax
  801a39:	eb 05                	jmp    801a40 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a3b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a4e:	6a 01                	push   $0x1
  801a50:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a53:	50                   	push   %eax
  801a54:	e8 07 f0 ff ff       	call   800a60 <sys_cputs>
}
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <getchar>:

int
getchar(void)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a64:	6a 01                	push   $0x1
  801a66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a69:	50                   	push   %eax
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 9d f6 ff ff       	call   80110e <read>
	if (r < 0)
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 0f                	js     801a87 <getchar+0x29>
		return r;
	if (r < 1)
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	7e 06                	jle    801a82 <getchar+0x24>
		return -E_EOF;
	return c;
  801a7c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a80:	eb 05                	jmp    801a87 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a82:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 0d f4 ff ff       	call   800ea8 <fd_lookup>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 11                	js     801ab3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aab:	39 10                	cmp    %edx,(%eax)
  801aad:	0f 94 c0             	sete   %al
  801ab0:	0f b6 c0             	movzbl %al,%eax
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <opencons>:

int
opencons(void)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	e8 95 f3 ff ff       	call   800e59 <fd_alloc>
  801ac4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 3e                	js     801b0b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 07 04 00 00       	push   $0x407
  801ad5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 3d f0 ff ff       	call   800b1c <sys_page_alloc>
  801adf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 23                	js     801b0b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ae8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801afd:	83 ec 0c             	sub    $0xc,%esp
  801b00:	50                   	push   %eax
  801b01:	e8 2c f3 ff ff       	call   800e32 <fd2num>
  801b06:	89 c2                	mov    %eax,%edx
  801b08:	83 c4 10             	add    $0x10,%esp
}
  801b0b:	89 d0                	mov    %edx,%eax
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b14:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b17:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b1d:	e8 bc ef ff ff       	call   800ade <sys_getenvid>
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 0c             	pushl  0xc(%ebp)
  801b28:	ff 75 08             	pushl  0x8(%ebp)
  801b2b:	56                   	push   %esi
  801b2c:	50                   	push   %eax
  801b2d:	68 9c 22 80 00       	push   $0x80229c
  801b32:	e8 5d e6 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b37:	83 c4 18             	add    $0x18,%esp
  801b3a:	53                   	push   %ebx
  801b3b:	ff 75 10             	pushl  0x10(%ebp)
  801b3e:	e8 00 e6 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801b43:	c7 04 24 87 22 80 00 	movl   $0x802287,(%esp)
  801b4a:	e8 45 e6 ff ff       	call   800194 <cprintf>
  801b4f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b52:	cc                   	int3   
  801b53:	eb fd                	jmp    801b52 <_panic+0x43>

00801b55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5b:	89 d0                	mov    %edx,%eax
  801b5d:	c1 e8 16             	shr    $0x16,%eax
  801b60:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6c:	f6 c1 01             	test   $0x1,%cl
  801b6f:	74 1d                	je     801b8e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b71:	c1 ea 0c             	shr    $0xc,%edx
  801b74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7b:	f6 c2 01             	test   $0x1,%dl
  801b7e:	74 0e                	je     801b8e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b80:	c1 ea 0c             	shr    $0xc,%edx
  801b83:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8a:	ef 
  801b8b:	0f b7 c0             	movzwl %ax,%eax
}
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
