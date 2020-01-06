
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 a0 1e 80 00       	push   $0x801ea0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 69 0a 00 00       	call   800abd <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 20 0a 00 00       	call   800a7c <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 7b 0c 00 00       	call   800cec <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 2d 0a 00 00       	call   800abd <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 7e 0e 00 00       	call   800f4f <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a1 09 00 00       	call   800a7c <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 2f 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 d4 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 35 1a 00 00       	call   801c10 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 22 1b 00 00       	call   801d40 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 c6 1e 80 00 	movsbl 0x801ec6(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 89 03 00 00    	je     80064f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 1a 03 00 00    	ja     800634 <vprintfmt+0x38a>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800342:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800345:	83 fa 09             	cmp    $0x9,%edx
  800348:	77 39                	ja     800383 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034d:	eb e9                	jmp    800338 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800360:	eb 27                	jmp    800389 <vprintfmt+0xdf>
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	85 c0                	test   %eax,%eax
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	0f 49 c8             	cmovns %eax,%ecx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	eb 8c                	jmp    800303 <vprintfmt+0x59>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	eb 80                	jmp    800303 <vprintfmt+0x59>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	0f 89 70 ff ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	e9 5e ff ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	e9 53 ff ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c7:	e9 04 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 0f             	cmp    $0xf,%eax
  8003df:	7f 0b                	jg     8003ec <vprintfmt+0x142>
  8003e1:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 de 1e 80 00       	push   $0x801ede
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 94 fe ff ff       	call   80028d <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 cc fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 e1 22 80 00       	push   $0x8022e1
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 7c fe ff ff       	call   80028d <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	e9 b4 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800427:	85 ff                	test   %edi,%edi
  800429:	b8 d7 1e 80 00       	mov    $0x801ed7,%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 94 00 00 00    	jle    8004cf <vprintfmt+0x225>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	0f 84 98 00 00 00    	je     8004dd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d0             	pushl  -0x30(%ebp)
  80044b:	57                   	push   %edi
  80044c:	e8 86 02 00 00       	call   8006d7 <strnlen>
  800451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c0>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	85 c9                	test   %ecx,%ecx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c1             	cmovns %ecx,%eax
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 4d                	jmp    8004e9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x213>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x213>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x23f>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 23                	je     80051a <vprintfmt+0x270>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 a1                	js     80049c <vprintfmt+0x1f2>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 9c                	jns    80049c <vprintfmt+0x1f2>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 18                	jmp    800522 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 20                	push   $0x20
  800510:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	eb 08                	jmp    800522 <vprintfmt+0x278>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	85 ff                	test   %edi,%edi
  800524:	7f e4                	jg     80050a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	e9 a2 fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 fa 01             	cmp    $0x1,%edx
  800531:	7e 16                	jle    800549 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 08             	lea    0x8(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	eb 32                	jmp    80057b <vprintfmt+0x2d1>
	else if (lflag)
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 18                	je     800565 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	eb 16                	jmp    80057b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 c1                	mov    %eax,%ecx
  800575:	c1 f9 1f             	sar    $0x1f,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	79 74                	jns    800600 <vprintfmt+0x356>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	f7 d8                	neg    %eax
  80059c:	83 d2 00             	adc    $0x0,%edx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a9:	eb 55                	jmp    800600 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 83 fc ff ff       	call   800236 <getuint>
			base = 10;
  8005b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 74 fc ff ff       	call   800236 <getuint>
			base=8;
  8005c2:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005c7:	eb 37                	jmp    800600 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 3b fc ff ff       	call   800236 <getuint>
			base = 16;
  8005fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800607:	57                   	push   %edi
  800608:	ff 75 e0             	pushl  -0x20(%ebp)
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	50                   	push   %eax
  80060e:	89 da                	mov    %ebx,%edx
  800610:	89 f0                	mov    %esi,%eax
  800612:	e8 70 fb ff ff       	call   800187 <printnum>
			break;
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061d:	e9 ae fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	51                   	push   %ecx
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062f:	e9 9c fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 25                	push   $0x25
  80063a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x39a>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800648:	75 f7                	jne    800641 <vprintfmt+0x397>
  80064a:	e9 81 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800666:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800674:	85 c0                	test   %eax,%eax
  800676:	74 26                	je     80069e <vsnprintf+0x47>
  800678:	85 d2                	test   %edx,%edx
  80067a:	7e 22                	jle    80069e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067c:	ff 75 14             	pushl  0x14(%ebp)
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	68 70 02 80 00       	push   $0x800270
  80068b:	e8 1a fc ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	50                   	push   %eax
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	ff 75 08             	pushl  0x8(%ebp)
  8006b8:	e8 9a ff ff ff       	call   800657 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb 03                	jmp    8006cf <strlen+0x10>
		n++;
  8006cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d3:	75 f7                	jne    8006cc <strlen+0xd>
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	eb 03                	jmp    8006ea <strnlen+0x13>
		n++;
  8006e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	39 c2                	cmp    %eax,%edx
  8006ec:	74 08                	je     8006f6 <strnlen+0x1f>
  8006ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f2:	75 f3                	jne    8006e7 <strnlen+0x10>
  8006f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800702:	89 c2                	mov    %eax,%edx
  800704:	83 c2 01             	add    $0x1,%edx
  800707:	83 c1 01             	add    $0x1,%ecx
  80070a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800711:	84 db                	test   %bl,%bl
  800713:	75 ef                	jne    800704 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071f:	53                   	push   %ebx
  800720:	e8 9a ff ff ff       	call   8006bf <strlen>
  800725:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	01 d8                	add    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c5 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800745:	89 f3                	mov    %esi,%ebx
  800747:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 0f                	jmp    80075d <strncpy+0x23>
		*dst++ = *src;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	0f b6 01             	movzbl (%ecx),%eax
  800754:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800757:	80 39 01             	cmpb   $0x1,(%ecx)
  80075a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	39 da                	cmp    %ebx,%edx
  80075f:	75 ed                	jne    80074e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	89 f0                	mov    %esi,%eax
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	8b 55 10             	mov    0x10(%ebp),%edx
  800775:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	74 21                	je     80079c <strlcpy+0x35>
  80077b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 09                	jmp    80078c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 09                	je     800799 <strlcpy+0x32>
  800790:	0f b6 19             	movzbl (%ecx),%ebx
  800793:	84 db                	test   %bl,%bl
  800795:	75 ec                	jne    800783 <strlcpy+0x1c>
  800797:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 06                	jmp    8007b3 <strcmp+0x11>
		p++, q++;
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 04                	je     8007be <strcmp+0x1c>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	74 ef                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 c0             	movzbl %al,%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 c3                	mov    %eax,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strncmp+0x17>
		n--, p++, q++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 15                	je     8007f8 <strncmp+0x30>
  8007e3:	0f b6 08             	movzbl (%eax),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 04                	je     8007ee <strncmp+0x26>
  8007ea:	3a 0a                	cmp    (%edx),%cl
  8007ec:	74 eb                	je     8007d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
  8007f6:	eb 05                	jmp    8007fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 07                	jmp    800813 <strchr+0x13>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0f                	je     80081f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	0f b6 10             	movzbl (%eax),%edx
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strfind+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 04                	je     80083b <strfind+0x1a>
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strfind+0xc>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 36                	je     800883 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 28                	jne    80087d <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 23                	jne    80087d <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085e:	89 d3                	mov    %edx,%ebx
  800860:	c1 e3 08             	shl    $0x8,%ebx
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 18             	shl    $0x18,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 10             	shl    $0x10,%eax
  80086d:	09 f0                	or     %esi,%eax
  80086f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800871:	89 d8                	mov    %ebx,%eax
  800873:	09 d0                	or     %edx,%eax
  800875:	c1 e9 02             	shr    $0x2,%ecx
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 f8                	mov    %edi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 75 0c             	mov    0xc(%ebp),%esi
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 35                	jae    8008d1 <memmove+0x47>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	73 2e                	jae    8008d1 <memmove+0x47>
		s += n;
		d += n;
  8008a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	09 fe                	or     %edi,%esi
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x3b>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0e                	jne    8008c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b7:	83 ef 04             	sub    $0x4,%edi
  8008ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fd                   	std    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 09                	jmp    8008ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	83 ef 01             	sub    $0x1,%edi
  8008c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cb:	fd                   	std    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ce:	fc                   	cld    
  8008cf:	eb 1d                	jmp    8008ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 f2                	mov    %esi,%edx
  8008d3:	09 c2                	or     %eax,%edx
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 0f                	jne    8008e9 <memmove+0x5f>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 87 ff ff ff       	call   80088a <memmove>
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c6                	mov    %eax,%esi
  800912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800915:	eb 1a                	jmp    800931 <memcmp+0x2c>
		if (*s1 != *s2)
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	0f b6 1a             	movzbl (%edx),%ebx
  80091d:	38 d9                	cmp    %bl,%cl
  80091f:	74 0a                	je     80092b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c1             	movzbl %cl,%eax
  800924:	0f b6 db             	movzbl %bl,%ebx
  800927:	29 d8                	sub    %ebx,%eax
  800929:	eb 0f                	jmp    80093a <memcmp+0x35>
		s1++, s2++;
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	39 f0                	cmp    %esi,%eax
  800933:	75 e2                	jne    800917 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800945:	89 c1                	mov    %eax,%ecx
  800947:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094e:	eb 0a                	jmp    80095a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	39 da                	cmp    %ebx,%edx
  800955:	74 07                	je     80095e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	39 c8                	cmp    %ecx,%eax
  80095c:	72 f2                	jb     800950 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096d:	eb 03                	jmp    800972 <strtol+0x11>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f6                	je     80096f <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f2                	je     80096f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 0a                	jne    80098b <strtol+0x2a>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
  800989:	eb 11                	jmp    80099c <strtol+0x3b>
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800990:	3c 2d                	cmp    $0x2d,%al
  800992:	75 08                	jne    80099c <strtol+0x3b>
		s++, neg = 1;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 15                	jne    8009b9 <strtol+0x58>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 10                	jne    8009b9 <strtol+0x58>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	75 7c                	jne    800a2b <strtol+0xca>
		s += 2, base = 16;
  8009af:	83 c1 02             	add    $0x2,%ecx
  8009b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b7:	eb 16                	jmp    8009cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 12                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 08                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x8b>
			dig = *s - '0';
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 30             	sub    $0x30,%edx
  8009ea:	eb 22                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 57             	sub    $0x57,%edx
  8009fc:	eb 10                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 16                	ja     800a1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a11:	7d 0b                	jge    800a1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1c:	eb b9                	jmp    8009d7 <strtol+0x76>

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 0d                	je     800a31 <strtol+0xd0>
		*endptr = (char *) s;
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	89 0e                	mov    %ecx,(%esi)
  800a29:	eb 06                	jmp    800a31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	74 98                	je     8009c7 <strtol+0x66>
  800a2f:	eb 9e                	jmp    8009cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 bf 21 80 00       	push   $0x8021bf
  800aa9:	6a 23                	push   $0x23
  800aab:	68 dc 21 80 00       	push   $0x8021dc
  800ab0:	e8 ac 0f 00 00       	call   801a61 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 bf 21 80 00       	push   $0x8021bf
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 dc 21 80 00       	push   $0x8021dc
  800b31:	e8 2b 0f 00 00       	call   801a61 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 bf 21 80 00       	push   $0x8021bf
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 dc 21 80 00       	push   $0x8021dc
  800b73:	e8 e9 0e 00 00       	call   801a61 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 bf 21 80 00       	push   $0x8021bf
  800bae:	6a 23                	push   $0x23
  800bb0:	68 dc 21 80 00       	push   $0x8021dc
  800bb5:	e8 a7 0e 00 00       	call   801a61 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 bf 21 80 00       	push   $0x8021bf
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 dc 21 80 00       	push   $0x8021dc
  800bf7:	e8 65 0e 00 00       	call   801a61 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 bf 21 80 00       	push   $0x8021bf
  800c32:	6a 23                	push   $0x23
  800c34:	68 dc 21 80 00       	push   $0x8021dc
  800c39:	e8 23 0e 00 00       	call   801a61 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0a                	push   $0xa
  800c6f:	68 bf 21 80 00       	push   $0x8021bf
  800c74:	6a 23                	push   $0x23
  800c76:	68 dc 21 80 00       	push   $0x8021dc
  800c7b:	e8 e1 0d 00 00       	call   801a61 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0d                	push   $0xd
  800cd3:	68 bf 21 80 00       	push   $0x8021bf
  800cd8:	6a 23                	push   $0x23
  800cda:	68 dc 21 80 00       	push   $0x8021dc
  800cdf:	e8 7d 0d 00 00       	call   801a61 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cf3:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800cfa:	75 57                	jne    800d53 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  800cfc:	e8 bc fd ff ff       	call   800abd <sys_getenvid>
  800d01:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  800d03:	83 ec 04             	sub    $0x4,%esp
  800d06:	6a 07                	push   $0x7
  800d08:	68 00 f0 bf ee       	push   $0xeebff000
  800d0d:	50                   	push   %eax
  800d0e:	e8 e8 fd ff ff       	call   800afb <sys_page_alloc>
		if (r) {
  800d13:	83 c4 10             	add    $0x10,%esp
  800d16:	85 c0                	test   %eax,%eax
  800d18:	74 12                	je     800d2c <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  800d1a:	50                   	push   %eax
  800d1b:	68 ea 21 80 00       	push   $0x8021ea
  800d20:	6a 25                	push   $0x25
  800d22:	68 03 22 80 00       	push   $0x802203
  800d27:	e8 35 0d 00 00       	call   801a61 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  800d2c:	83 ec 08             	sub    $0x8,%esp
  800d2f:	68 60 0d 80 00       	push   $0x800d60
  800d34:	53                   	push   %ebx
  800d35:	e8 0c ff ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
		if (r) {
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	74 12                	je     800d53 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  800d41:	50                   	push   %eax
  800d42:	68 14 22 80 00       	push   $0x802214
  800d47:	6a 2b                	push   $0x2b
  800d49:	68 03 22 80 00       	push   $0x802203
  800d4e:	e8 0e 0d 00 00       	call   801a61 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d60:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d61:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d66:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d68:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  800d6b:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  800d6f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  800d74:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  800d78:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  800d7a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  800d7d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  800d7e:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  800d81:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  800d82:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  800d83:	c3                   	ret    

00800d84 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	c1 ea 16             	shr    $0x16,%edx
  800dbb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc2:	f6 c2 01             	test   $0x1,%dl
  800dc5:	74 11                	je     800dd8 <fd_alloc+0x2d>
  800dc7:	89 c2                	mov    %eax,%edx
  800dc9:	c1 ea 0c             	shr    $0xc,%edx
  800dcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd3:	f6 c2 01             	test   $0x1,%dl
  800dd6:	75 09                	jne    800de1 <fd_alloc+0x36>
			*fd_store = fd;
  800dd8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddf:	eb 17                	jmp    800df8 <fd_alloc+0x4d>
  800de1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800deb:	75 c9                	jne    800db6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ded:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e00:	83 f8 1f             	cmp    $0x1f,%eax
  800e03:	77 36                	ja     800e3b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e05:	c1 e0 0c             	shl    $0xc,%eax
  800e08:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 16             	shr    $0x16,%edx
  800e12:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e19:	f6 c2 01             	test   $0x1,%dl
  800e1c:	74 24                	je     800e42 <fd_lookup+0x48>
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	c1 ea 0c             	shr    $0xc,%edx
  800e23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2a:	f6 c2 01             	test   $0x1,%dl
  800e2d:	74 1a                	je     800e49 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e32:	89 02                	mov    %eax,(%edx)
	return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	eb 13                	jmp    800e4e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e40:	eb 0c                	jmp    800e4e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e47:	eb 05                	jmp    800e4e <fd_lookup+0x54>
  800e49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	ba b8 22 80 00       	mov    $0x8022b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e5e:	eb 13                	jmp    800e73 <dev_lookup+0x23>
  800e60:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e63:	39 08                	cmp    %ecx,(%eax)
  800e65:	75 0c                	jne    800e73 <dev_lookup+0x23>
			*dev = devtab[i];
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e71:	eb 2e                	jmp    800ea1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e73:	8b 02                	mov    (%edx),%eax
  800e75:	85 c0                	test   %eax,%eax
  800e77:	75 e7                	jne    800e60 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e79:	a1 04 40 80 00       	mov    0x804004,%eax
  800e7e:	8b 40 48             	mov    0x48(%eax),%eax
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	51                   	push   %ecx
  800e85:	50                   	push   %eax
  800e86:	68 3c 22 80 00       	push   $0x80223c
  800e8b:	e8 e3 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 10             	sub    $0x10,%esp
  800eab:	8b 75 08             	mov    0x8(%ebp),%esi
  800eae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb4:	50                   	push   %eax
  800eb5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ebb:	c1 e8 0c             	shr    $0xc,%eax
  800ebe:	50                   	push   %eax
  800ebf:	e8 36 ff ff ff       	call   800dfa <fd_lookup>
  800ec4:	83 c4 08             	add    $0x8,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 05                	js     800ed0 <fd_close+0x2d>
	    || fd != fd2)
  800ecb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ece:	74 0c                	je     800edc <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed0:	84 db                	test   %bl,%bl
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	0f 44 c2             	cmove  %edx,%eax
  800eda:	eb 41                	jmp    800f1d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee2:	50                   	push   %eax
  800ee3:	ff 36                	pushl  (%esi)
  800ee5:	e8 66 ff ff ff       	call   800e50 <dev_lookup>
  800eea:	89 c3                	mov    %eax,%ebx
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 1a                	js     800f0d <fd_close+0x6a>
		if (dev->dev_close)
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800efe:	85 c0                	test   %eax,%eax
  800f00:	74 0b                	je     800f0d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	56                   	push   %esi
  800f06:	ff d0                	call   *%eax
  800f08:	89 c3                	mov    %eax,%ebx
  800f0a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f0d:	83 ec 08             	sub    $0x8,%esp
  800f10:	56                   	push   %esi
  800f11:	6a 00                	push   $0x0
  800f13:	e8 68 fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	89 d8                	mov    %ebx,%eax
}
  800f1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 75 08             	pushl  0x8(%ebp)
  800f31:	e8 c4 fe ff ff       	call   800dfa <fd_lookup>
  800f36:	83 c4 08             	add    $0x8,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 10                	js     800f4d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	6a 01                	push   $0x1
  800f42:	ff 75 f4             	pushl  -0xc(%ebp)
  800f45:	e8 59 ff ff ff       	call   800ea3 <fd_close>
  800f4a:	83 c4 10             	add    $0x10,%esp
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <close_all>:

void
close_all(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	53                   	push   %ebx
  800f53:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f56:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	53                   	push   %ebx
  800f5f:	e8 c0 ff ff ff       	call   800f24 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f64:	83 c3 01             	add    $0x1,%ebx
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	83 fb 20             	cmp    $0x20,%ebx
  800f6d:	75 ec                	jne    800f5b <close_all+0xc>
		close(i);
}
  800f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 2c             	sub    $0x2c,%esp
  800f7d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f80:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	ff 75 08             	pushl  0x8(%ebp)
  800f87:	e8 6e fe ff ff       	call   800dfa <fd_lookup>
  800f8c:	83 c4 08             	add    $0x8,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	0f 88 c1 00 00 00    	js     801058 <dup+0xe4>
		return r;
	close(newfdnum);
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	56                   	push   %esi
  800f9b:	e8 84 ff ff ff       	call   800f24 <close>

	newfd = INDEX2FD(newfdnum);
  800fa0:	89 f3                	mov    %esi,%ebx
  800fa2:	c1 e3 0c             	shl    $0xc,%ebx
  800fa5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fab:	83 c4 04             	add    $0x4,%esp
  800fae:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb1:	e8 de fd ff ff       	call   800d94 <fd2data>
  800fb6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fb8:	89 1c 24             	mov    %ebx,(%esp)
  800fbb:	e8 d4 fd ff ff       	call   800d94 <fd2data>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fc6:	89 f8                	mov    %edi,%eax
  800fc8:	c1 e8 16             	shr    $0x16,%eax
  800fcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	74 37                	je     80100d <dup+0x99>
  800fd6:	89 f8                	mov    %edi,%eax
  800fd8:	c1 e8 0c             	shr    $0xc,%eax
  800fdb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe2:	f6 c2 01             	test   $0x1,%dl
  800fe5:	74 26                	je     80100d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fe7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff6:	50                   	push   %eax
  800ff7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffa:	6a 00                	push   $0x0
  800ffc:	57                   	push   %edi
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 3a fb ff ff       	call   800b3e <sys_page_map>
  801004:	89 c7                	mov    %eax,%edi
  801006:	83 c4 20             	add    $0x20,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 2e                	js     80103b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801010:	89 d0                	mov    %edx,%eax
  801012:	c1 e8 0c             	shr    $0xc,%eax
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	25 07 0e 00 00       	and    $0xe07,%eax
  801024:	50                   	push   %eax
  801025:	53                   	push   %ebx
  801026:	6a 00                	push   $0x0
  801028:	52                   	push   %edx
  801029:	6a 00                	push   $0x0
  80102b:	e8 0e fb ff ff       	call   800b3e <sys_page_map>
  801030:	89 c7                	mov    %eax,%edi
  801032:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801035:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801037:	85 ff                	test   %edi,%edi
  801039:	79 1d                	jns    801058 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	53                   	push   %ebx
  80103f:	6a 00                	push   $0x0
  801041:	e8 3a fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801046:	83 c4 08             	add    $0x8,%esp
  801049:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104c:	6a 00                	push   $0x0
  80104e:	e8 2d fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	89 f8                	mov    %edi,%eax
}
  801058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	53                   	push   %ebx
  801064:	83 ec 14             	sub    $0x14,%esp
  801067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80106a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106d:	50                   	push   %eax
  80106e:	53                   	push   %ebx
  80106f:	e8 86 fd ff ff       	call   800dfa <fd_lookup>
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	89 c2                	mov    %eax,%edx
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 6d                	js     8010ea <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80107d:	83 ec 08             	sub    $0x8,%esp
  801080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801083:	50                   	push   %eax
  801084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801087:	ff 30                	pushl  (%eax)
  801089:	e8 c2 fd ff ff       	call   800e50 <dev_lookup>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	78 4c                	js     8010e1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801095:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801098:	8b 42 08             	mov    0x8(%edx),%eax
  80109b:	83 e0 03             	and    $0x3,%eax
  80109e:	83 f8 01             	cmp    $0x1,%eax
  8010a1:	75 21                	jne    8010c4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a8:	8b 40 48             	mov    0x48(%eax),%eax
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	53                   	push   %ebx
  8010af:	50                   	push   %eax
  8010b0:	68 7d 22 80 00       	push   $0x80227d
  8010b5:	e8 b9 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c2:	eb 26                	jmp    8010ea <read+0x8a>
	}
	if (!dev->dev_read)
  8010c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c7:	8b 40 08             	mov    0x8(%eax),%eax
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	74 17                	je     8010e5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	ff 75 10             	pushl  0x10(%ebp)
  8010d4:	ff 75 0c             	pushl  0xc(%ebp)
  8010d7:	52                   	push   %edx
  8010d8:	ff d0                	call   *%eax
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	eb 09                	jmp    8010ea <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e1:	89 c2                	mov    %eax,%edx
  8010e3:	eb 05                	jmp    8010ea <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010ea:	89 d0                	mov    %edx,%eax
  8010ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
  801105:	eb 21                	jmp    801128 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	29 d8                	sub    %ebx,%eax
  80110e:	50                   	push   %eax
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	03 45 0c             	add    0xc(%ebp),%eax
  801114:	50                   	push   %eax
  801115:	57                   	push   %edi
  801116:	e8 45 ff ff ff       	call   801060 <read>
		if (m < 0)
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 10                	js     801132 <readn+0x41>
			return m;
		if (m == 0)
  801122:	85 c0                	test   %eax,%eax
  801124:	74 0a                	je     801130 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801126:	01 c3                	add    %eax,%ebx
  801128:	39 f3                	cmp    %esi,%ebx
  80112a:	72 db                	jb     801107 <readn+0x16>
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	eb 02                	jmp    801132 <readn+0x41>
  801130:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	53                   	push   %ebx
  80113e:	83 ec 14             	sub    $0x14,%esp
  801141:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801144:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	53                   	push   %ebx
  801149:	e8 ac fc ff ff       	call   800dfa <fd_lookup>
  80114e:	83 c4 08             	add    $0x8,%esp
  801151:	89 c2                	mov    %eax,%edx
  801153:	85 c0                	test   %eax,%eax
  801155:	78 68                	js     8011bf <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801161:	ff 30                	pushl  (%eax)
  801163:	e8 e8 fc ff ff       	call   800e50 <dev_lookup>
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 47                	js     8011b6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80116f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801172:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801176:	75 21                	jne    801199 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801178:	a1 04 40 80 00       	mov    0x804004,%eax
  80117d:	8b 40 48             	mov    0x48(%eax),%eax
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	53                   	push   %ebx
  801184:	50                   	push   %eax
  801185:	68 99 22 80 00       	push   $0x802299
  80118a:	e8 e4 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801197:	eb 26                	jmp    8011bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801199:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119c:	8b 52 0c             	mov    0xc(%edx),%edx
  80119f:	85 d2                	test   %edx,%edx
  8011a1:	74 17                	je     8011ba <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	ff 75 10             	pushl  0x10(%ebp)
  8011a9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ac:	50                   	push   %eax
  8011ad:	ff d2                	call   *%edx
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	eb 09                	jmp    8011bf <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	eb 05                	jmp    8011bf <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011bf:	89 d0                	mov    %edx,%eax
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 75 08             	pushl  0x8(%ebp)
  8011d3:	e8 22 fc ff ff       	call   800dfa <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 0e                	js     8011ed <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 14             	sub    $0x14,%esp
  8011f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fc:	50                   	push   %eax
  8011fd:	53                   	push   %ebx
  8011fe:	e8 f7 fb ff ff       	call   800dfa <fd_lookup>
  801203:	83 c4 08             	add    $0x8,%esp
  801206:	89 c2                	mov    %eax,%edx
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 65                	js     801271 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	ff 30                	pushl  (%eax)
  801218:	e8 33 fc ff ff       	call   800e50 <dev_lookup>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 44                	js     801268 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801224:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801227:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122b:	75 21                	jne    80124e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80122d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801232:	8b 40 48             	mov    0x48(%eax),%eax
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	53                   	push   %ebx
  801239:	50                   	push   %eax
  80123a:	68 5c 22 80 00       	push   $0x80225c
  80123f:	e8 2f ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124c:	eb 23                	jmp    801271 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80124e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801251:	8b 52 18             	mov    0x18(%edx),%edx
  801254:	85 d2                	test   %edx,%edx
  801256:	74 14                	je     80126c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	ff 75 0c             	pushl  0xc(%ebp)
  80125e:	50                   	push   %eax
  80125f:	ff d2                	call   *%edx
  801261:	89 c2                	mov    %eax,%edx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb 09                	jmp    801271 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801268:	89 c2                	mov    %eax,%edx
  80126a:	eb 05                	jmp    801271 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80126c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801271:	89 d0                	mov    %edx,%eax
  801273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 14             	sub    $0x14,%esp
  80127f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 75 08             	pushl  0x8(%ebp)
  801289:	e8 6c fb ff ff       	call   800dfa <fd_lookup>
  80128e:	83 c4 08             	add    $0x8,%esp
  801291:	89 c2                	mov    %eax,%edx
  801293:	85 c0                	test   %eax,%eax
  801295:	78 58                	js     8012ef <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	ff 30                	pushl  (%eax)
  8012a3:	e8 a8 fb ff ff       	call   800e50 <dev_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 37                	js     8012e6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b6:	74 32                	je     8012ea <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c2:	00 00 00 
	stat->st_isdir = 0;
  8012c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012cc:	00 00 00 
	stat->st_dev = dev;
  8012cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	53                   	push   %ebx
  8012d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012dc:	ff 50 14             	call   *0x14(%eax)
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	eb 09                	jmp    8012ef <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	eb 05                	jmp    8012ef <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012ef:	89 d0                	mov    %edx,%eax
  8012f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	6a 00                	push   $0x0
  801300:	ff 75 08             	pushl  0x8(%ebp)
  801303:	e8 d6 01 00 00       	call   8014de <open>
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 1b                	js     80132c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	ff 75 0c             	pushl  0xc(%ebp)
  801317:	50                   	push   %eax
  801318:	e8 5b ff ff ff       	call   801278 <fstat>
  80131d:	89 c6                	mov    %eax,%esi
	close(fd);
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 fd fb ff ff       	call   800f24 <close>
	return r;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 f0                	mov    %esi,%eax
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	89 c6                	mov    %eax,%esi
  80133a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80133c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801343:	75 12                	jne    801357 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	6a 01                	push   $0x1
  80134a:	e8 44 08 00 00       	call   801b93 <ipc_find_env>
  80134f:	a3 00 40 80 00       	mov    %eax,0x804000
  801354:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801357:	6a 07                	push   $0x7
  801359:	68 00 50 80 00       	push   $0x805000
  80135e:	56                   	push   %esi
  80135f:	ff 35 00 40 80 00    	pushl  0x804000
  801365:	e8 d5 07 00 00       	call   801b3f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136a:	83 c4 0c             	add    $0xc,%esp
  80136d:	6a 00                	push   $0x0
  80136f:	53                   	push   %ebx
  801370:	6a 00                	push   $0x0
  801372:	e8 30 07 00 00       	call   801aa7 <ipc_recv>
}
  801377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801384:	8b 45 08             	mov    0x8(%ebp),%eax
  801387:	8b 40 0c             	mov    0xc(%eax),%eax
  80138a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80138f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801392:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801397:	ba 00 00 00 00       	mov    $0x0,%edx
  80139c:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a1:	e8 8d ff ff ff       	call   801333 <fsipc>
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013be:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c3:	e8 6b ff ff ff       	call   801333 <fsipc>
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013da:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013df:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e9:	e8 45 ff ff ff       	call   801333 <fsipc>
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 2c                	js     80141e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	68 00 50 80 00       	push   $0x805000
  8013fa:	53                   	push   %ebx
  8013fb:	e8 f8 f2 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801400:	a1 80 50 80 00       	mov    0x805080,%eax
  801405:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80140b:	a1 84 50 80 00       	mov    0x805084,%eax
  801410:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80142c:	8b 55 08             	mov    0x8(%ebp),%edx
  80142f:	8b 52 0c             	mov    0xc(%edx),%edx
  801432:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801438:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  80143d:	50                   	push   %eax
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	68 08 50 80 00       	push   $0x805008
  801446:	e8 3f f4 ff ff       	call   80088a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80144b:	ba 00 00 00 00       	mov    $0x0,%edx
  801450:	b8 04 00 00 00       	mov    $0x4,%eax
  801455:	e8 d9 fe ff ff       	call   801333 <fsipc>
	//panic("devfile_write not implemented");
}
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    

0080145c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	8b 40 0c             	mov    0xc(%eax),%eax
  80146a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80146f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	b8 03 00 00 00       	mov    $0x3,%eax
  80147f:	e8 af fe ff ff       	call   801333 <fsipc>
  801484:	89 c3                	mov    %eax,%ebx
  801486:	85 c0                	test   %eax,%eax
  801488:	78 4b                	js     8014d5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80148a:	39 c6                	cmp    %eax,%esi
  80148c:	73 16                	jae    8014a4 <devfile_read+0x48>
  80148e:	68 c8 22 80 00       	push   $0x8022c8
  801493:	68 cf 22 80 00       	push   $0x8022cf
  801498:	6a 7c                	push   $0x7c
  80149a:	68 e4 22 80 00       	push   $0x8022e4
  80149f:	e8 bd 05 00 00       	call   801a61 <_panic>
	assert(r <= PGSIZE);
  8014a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a9:	7e 16                	jle    8014c1 <devfile_read+0x65>
  8014ab:	68 ef 22 80 00       	push   $0x8022ef
  8014b0:	68 cf 22 80 00       	push   $0x8022cf
  8014b5:	6a 7d                	push   $0x7d
  8014b7:	68 e4 22 80 00       	push   $0x8022e4
  8014bc:	e8 a0 05 00 00       	call   801a61 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	50                   	push   %eax
  8014c5:	68 00 50 80 00       	push   $0x805000
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	e8 b8 f3 ff ff       	call   80088a <memmove>
	return r;
  8014d2:	83 c4 10             	add    $0x10,%esp
}
  8014d5:	89 d8                	mov    %ebx,%eax
  8014d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 20             	sub    $0x20,%esp
  8014e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e8:	53                   	push   %ebx
  8014e9:	e8 d1 f1 ff ff       	call   8006bf <strlen>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f6:	7f 67                	jg     80155f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	e8 a7 f8 ff ff       	call   800dab <fd_alloc>
  801504:	83 c4 10             	add    $0x10,%esp
		return r;
  801507:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 57                	js     801564 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	53                   	push   %ebx
  801511:	68 00 50 80 00       	push   $0x805000
  801516:	e8 dd f1 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80151b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801523:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801526:	b8 01 00 00 00       	mov    $0x1,%eax
  80152b:	e8 03 fe ff ff       	call   801333 <fsipc>
  801530:	89 c3                	mov    %eax,%ebx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	79 14                	jns    80154d <open+0x6f>
		fd_close(fd, 0);
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	6a 00                	push   $0x0
  80153e:	ff 75 f4             	pushl  -0xc(%ebp)
  801541:	e8 5d f9 ff ff       	call   800ea3 <fd_close>
		return r;
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	89 da                	mov    %ebx,%edx
  80154b:	eb 17                	jmp    801564 <open+0x86>
	}

	return fd2num(fd);
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	ff 75 f4             	pushl  -0xc(%ebp)
  801553:	e8 2c f8 ff ff       	call   800d84 <fd2num>
  801558:	89 c2                	mov    %eax,%edx
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	eb 05                	jmp    801564 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80155f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801564:	89 d0                	mov    %edx,%eax
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801571:	ba 00 00 00 00       	mov    $0x0,%edx
  801576:	b8 08 00 00 00       	mov    $0x8,%eax
  80157b:	e8 b3 fd ff ff       	call   801333 <fsipc>
}
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	ff 75 08             	pushl  0x8(%ebp)
  801590:	e8 ff f7 ff ff       	call   800d94 <fd2data>
  801595:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	68 fb 22 80 00       	push   $0x8022fb
  80159f:	53                   	push   %ebx
  8015a0:	e8 53 f1 ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015a5:	8b 46 04             	mov    0x4(%esi),%eax
  8015a8:	2b 06                	sub    (%esi),%eax
  8015aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b7:	00 00 00 
	stat->st_dev = &devpipe;
  8015ba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015c1:	30 80 00 
	return 0;
}
  8015c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015da:	53                   	push   %ebx
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 9e f5 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015e2:	89 1c 24             	mov    %ebx,(%esp)
  8015e5:	e8 aa f7 ff ff       	call   800d94 <fd2data>
  8015ea:	83 c4 08             	add    $0x8,%esp
  8015ed:	50                   	push   %eax
  8015ee:	6a 00                	push   $0x0
  8015f0:	e8 8b f5 ff ff       	call   800b80 <sys_page_unmap>
}
  8015f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	57                   	push   %edi
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	83 ec 1c             	sub    $0x1c,%esp
  801603:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801606:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801608:	a1 04 40 80 00       	mov    0x804004,%eax
  80160d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	ff 75 e0             	pushl  -0x20(%ebp)
  801616:	e8 b1 05 00 00       	call   801bcc <pageref>
  80161b:	89 c3                	mov    %eax,%ebx
  80161d:	89 3c 24             	mov    %edi,(%esp)
  801620:	e8 a7 05 00 00       	call   801bcc <pageref>
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	39 c3                	cmp    %eax,%ebx
  80162a:	0f 94 c1             	sete   %cl
  80162d:	0f b6 c9             	movzbl %cl,%ecx
  801630:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801633:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801639:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80163c:	39 ce                	cmp    %ecx,%esi
  80163e:	74 1b                	je     80165b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801640:	39 c3                	cmp    %eax,%ebx
  801642:	75 c4                	jne    801608 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801644:	8b 42 58             	mov    0x58(%edx),%eax
  801647:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164a:	50                   	push   %eax
  80164b:	56                   	push   %esi
  80164c:	68 02 23 80 00       	push   $0x802302
  801651:	e8 1d eb ff ff       	call   800173 <cprintf>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb ad                	jmp    801608 <_pipeisclosed+0xe>
	}
}
  80165b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80165e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	57                   	push   %edi
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	83 ec 28             	sub    $0x28,%esp
  80166f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801672:	56                   	push   %esi
  801673:	e8 1c f7 ff ff       	call   800d94 <fd2data>
  801678:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	bf 00 00 00 00       	mov    $0x0,%edi
  801682:	eb 4b                	jmp    8016cf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801684:	89 da                	mov    %ebx,%edx
  801686:	89 f0                	mov    %esi,%eax
  801688:	e8 6d ff ff ff       	call   8015fa <_pipeisclosed>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	75 48                	jne    8016d9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801691:	e8 46 f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801696:	8b 43 04             	mov    0x4(%ebx),%eax
  801699:	8b 0b                	mov    (%ebx),%ecx
  80169b:	8d 51 20             	lea    0x20(%ecx),%edx
  80169e:	39 d0                	cmp    %edx,%eax
  8016a0:	73 e2                	jae    801684 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016a5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016a9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	c1 fa 1f             	sar    $0x1f,%edx
  8016b1:	89 d1                	mov    %edx,%ecx
  8016b3:	c1 e9 1b             	shr    $0x1b,%ecx
  8016b6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016b9:	83 e2 1f             	and    $0x1f,%edx
  8016bc:	29 ca                	sub    %ecx,%edx
  8016be:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016c6:	83 c0 01             	add    $0x1,%eax
  8016c9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016cc:	83 c7 01             	add    $0x1,%edi
  8016cf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016d2:	75 c2                	jne    801696 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d7:	eb 05                	jmp    8016de <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	57                   	push   %edi
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 18             	sub    $0x18,%esp
  8016ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016f2:	57                   	push   %edi
  8016f3:	e8 9c f6 ff ff       	call   800d94 <fd2data>
  8016f8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801702:	eb 3d                	jmp    801741 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801704:	85 db                	test   %ebx,%ebx
  801706:	74 04                	je     80170c <devpipe_read+0x26>
				return i;
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	eb 44                	jmp    801750 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80170c:	89 f2                	mov    %esi,%edx
  80170e:	89 f8                	mov    %edi,%eax
  801710:	e8 e5 fe ff ff       	call   8015fa <_pipeisclosed>
  801715:	85 c0                	test   %eax,%eax
  801717:	75 32                	jne    80174b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801719:	e8 be f3 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80171e:	8b 06                	mov    (%esi),%eax
  801720:	3b 46 04             	cmp    0x4(%esi),%eax
  801723:	74 df                	je     801704 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801725:	99                   	cltd   
  801726:	c1 ea 1b             	shr    $0x1b,%edx
  801729:	01 d0                	add    %edx,%eax
  80172b:	83 e0 1f             	and    $0x1f,%eax
  80172e:	29 d0                	sub    %edx,%eax
  801730:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801738:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80173b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173e:	83 c3 01             	add    $0x1,%ebx
  801741:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801744:	75 d8                	jne    80171e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801746:	8b 45 10             	mov    0x10(%ebp),%eax
  801749:	eb 05                	jmp    801750 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5f                   	pop    %edi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	e8 42 f6 ff ff       	call   800dab <fd_alloc>
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	89 c2                	mov    %eax,%edx
  80176e:	85 c0                	test   %eax,%eax
  801770:	0f 88 2c 01 00 00    	js     8018a2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	68 07 04 00 00       	push   $0x407
  80177e:	ff 75 f4             	pushl  -0xc(%ebp)
  801781:	6a 00                	push   $0x0
  801783:	e8 73 f3 ff ff       	call   800afb <sys_page_alloc>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	85 c0                	test   %eax,%eax
  80178f:	0f 88 0d 01 00 00    	js     8018a2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179b:	50                   	push   %eax
  80179c:	e8 0a f6 ff ff       	call   800dab <fd_alloc>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	0f 88 e2 00 00 00    	js     801890 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	68 07 04 00 00       	push   $0x407
  8017b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b9:	6a 00                	push   $0x0
  8017bb:	e8 3b f3 ff ff       	call   800afb <sys_page_alloc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	0f 88 c3 00 00 00    	js     801890 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d3:	e8 bc f5 ff ff       	call   800d94 <fd2data>
  8017d8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017da:	83 c4 0c             	add    $0xc,%esp
  8017dd:	68 07 04 00 00       	push   $0x407
  8017e2:	50                   	push   %eax
  8017e3:	6a 00                	push   $0x0
  8017e5:	e8 11 f3 ff ff       	call   800afb <sys_page_alloc>
  8017ea:	89 c3                	mov    %eax,%ebx
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	0f 88 89 00 00 00    	js     801880 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fd:	e8 92 f5 ff ff       	call   800d94 <fd2data>
  801802:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801809:	50                   	push   %eax
  80180a:	6a 00                	push   $0x0
  80180c:	56                   	push   %esi
  80180d:	6a 00                	push   $0x0
  80180f:	e8 2a f3 ff ff       	call   800b3e <sys_page_map>
  801814:	89 c3                	mov    %eax,%ebx
  801816:	83 c4 20             	add    $0x20,%esp
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 55                	js     801872 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80181d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801823:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801826:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801832:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801838:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80183d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801840:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	ff 75 f4             	pushl  -0xc(%ebp)
  80184d:	e8 32 f5 ff ff       	call   800d84 <fd2num>
  801852:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801855:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801857:	83 c4 04             	add    $0x4,%esp
  80185a:	ff 75 f0             	pushl  -0x10(%ebp)
  80185d:	e8 22 f5 ff ff       	call   800d84 <fd2num>
  801862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801865:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	eb 30                	jmp    8018a2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	56                   	push   %esi
  801876:	6a 00                	push   $0x0
  801878:	e8 03 f3 ff ff       	call   800b80 <sys_page_unmap>
  80187d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	ff 75 f0             	pushl  -0x10(%ebp)
  801886:	6a 00                	push   $0x0
  801888:	e8 f3 f2 ff ff       	call   800b80 <sys_page_unmap>
  80188d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	6a 00                	push   $0x0
  801898:	e8 e3 f2 ff ff       	call   800b80 <sys_page_unmap>
  80189d:	83 c4 10             	add    $0x10,%esp
  8018a0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018a2:	89 d0                	mov    %edx,%eax
  8018a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5e                   	pop    %esi
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b4:	50                   	push   %eax
  8018b5:	ff 75 08             	pushl  0x8(%ebp)
  8018b8:	e8 3d f5 ff ff       	call   800dfa <fd_lookup>
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 18                	js     8018dc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	e8 c5 f4 ff ff       	call   800d94 <fd2data>
	return _pipeisclosed(fd, p);
  8018cf:	89 c2                	mov    %eax,%edx
  8018d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d4:	e8 21 fd ff ff       	call   8015fa <_pipeisclosed>
  8018d9:	83 c4 10             	add    $0x10,%esp
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018ee:	68 1a 23 80 00       	push   $0x80231a
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	e8 fd ed ff ff       	call   8006f8 <strcpy>
	return 0;
}
  8018fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	57                   	push   %edi
  801906:	56                   	push   %esi
  801907:	53                   	push   %ebx
  801908:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80190e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801913:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801919:	eb 2d                	jmp    801948 <devcons_write+0x46>
		m = n - tot;
  80191b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80191e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801920:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801923:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801928:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80192b:	83 ec 04             	sub    $0x4,%esp
  80192e:	53                   	push   %ebx
  80192f:	03 45 0c             	add    0xc(%ebp),%eax
  801932:	50                   	push   %eax
  801933:	57                   	push   %edi
  801934:	e8 51 ef ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801939:	83 c4 08             	add    $0x8,%esp
  80193c:	53                   	push   %ebx
  80193d:	57                   	push   %edi
  80193e:	e8 fc f0 ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801943:	01 de                	add    %ebx,%esi
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	89 f0                	mov    %esi,%eax
  80194a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80194d:	72 cc                	jb     80191b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80194f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5f                   	pop    %edi
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801962:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801966:	74 2a                	je     801992 <devcons_read+0x3b>
  801968:	eb 05                	jmp    80196f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80196a:	e8 6d f1 ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80196f:	e8 e9 f0 ff ff       	call   800a5d <sys_cgetc>
  801974:	85 c0                	test   %eax,%eax
  801976:	74 f2                	je     80196a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 16                	js     801992 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80197c:	83 f8 04             	cmp    $0x4,%eax
  80197f:	74 0c                	je     80198d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801981:	8b 55 0c             	mov    0xc(%ebp),%edx
  801984:	88 02                	mov    %al,(%edx)
	return 1;
  801986:	b8 01 00 00 00       	mov    $0x1,%eax
  80198b:	eb 05                	jmp    801992 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019a0:	6a 01                	push   $0x1
  8019a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019a5:	50                   	push   %eax
  8019a6:	e8 94 f0 ff ff       	call   800a3f <sys_cputs>
}
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <getchar>:

int
getchar(void)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019b6:	6a 01                	push   $0x1
  8019b8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019bb:	50                   	push   %eax
  8019bc:	6a 00                	push   $0x0
  8019be:	e8 9d f6 ff ff       	call   801060 <read>
	if (r < 0)
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 0f                	js     8019d9 <getchar+0x29>
		return r;
	if (r < 1)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	7e 06                	jle    8019d4 <getchar+0x24>
		return -E_EOF;
	return c;
  8019ce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019d2:	eb 05                	jmp    8019d9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019d4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e4:	50                   	push   %eax
  8019e5:	ff 75 08             	pushl  0x8(%ebp)
  8019e8:	e8 0d f4 ff ff       	call   800dfa <fd_lookup>
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 11                	js     801a05 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019fd:	39 10                	cmp    %edx,(%eax)
  8019ff:	0f 94 c0             	sete   %al
  801a02:	0f b6 c0             	movzbl %al,%eax
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <opencons>:

int
opencons(void)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	e8 95 f3 ff ff       	call   800dab <fd_alloc>
  801a16:	83 c4 10             	add    $0x10,%esp
		return r;
  801a19:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 3e                	js     801a5d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	68 07 04 00 00       	push   $0x407
  801a27:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 ca f0 ff ff       	call   800afb <sys_page_alloc>
  801a31:	83 c4 10             	add    $0x10,%esp
		return r;
  801a34:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 23                	js     801a5d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a3a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a43:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	50                   	push   %eax
  801a53:	e8 2c f3 ff ff       	call   800d84 <fd2num>
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	83 c4 10             	add    $0x10,%esp
}
  801a5d:	89 d0                	mov    %edx,%eax
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a66:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a69:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a6f:	e8 49 f0 ff ff       	call   800abd <sys_getenvid>
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	ff 75 0c             	pushl  0xc(%ebp)
  801a7a:	ff 75 08             	pushl  0x8(%ebp)
  801a7d:	56                   	push   %esi
  801a7e:	50                   	push   %eax
  801a7f:	68 28 23 80 00       	push   $0x802328
  801a84:	e8 ea e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a89:	83 c4 18             	add    $0x18,%esp
  801a8c:	53                   	push   %ebx
  801a8d:	ff 75 10             	pushl  0x10(%ebp)
  801a90:	e8 8d e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801a95:	c7 04 24 13 23 80 00 	movl   $0x802313,(%esp)
  801a9c:	e8 d2 e6 ff ff       	call   800173 <cprintf>
  801aa1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801aa4:	cc                   	int3   
  801aa5:	eb fd                	jmp    801aa4 <_panic+0x43>

00801aa7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	8b 75 08             	mov    0x8(%ebp),%esi
  801aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	74 3e                	je     801af7 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	50                   	push   %eax
  801abd:	e8 e9 f1 ff ff       	call   800cab <sys_ipc_recv>
  801ac2:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 f6                	test   %esi,%esi
  801ac9:	74 13                	je     801ade <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad0:	85 d2                	test   %edx,%edx
  801ad2:	75 08                	jne    801adc <ipc_recv+0x35>
  801ad4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad9:	8b 40 74             	mov    0x74(%eax),%eax
  801adc:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ade:	85 db                	test   %ebx,%ebx
  801ae0:	74 48                	je     801b2a <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae7:	85 d2                	test   %edx,%edx
  801ae9:	75 08                	jne    801af3 <ipc_recv+0x4c>
  801aeb:	a1 04 40 80 00       	mov    0x804004,%eax
  801af0:	8b 40 78             	mov    0x78(%eax),%eax
  801af3:	89 03                	mov    %eax,(%ebx)
  801af5:	eb 33                	jmp    801b2a <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	68 00 00 c0 ee       	push   $0xeec00000
  801aff:	e8 a7 f1 ff ff       	call   800cab <sys_ipc_recv>
  801b04:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	85 f6                	test   %esi,%esi
  801b0b:	74 13                	je     801b20 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b12:	85 d2                	test   %edx,%edx
  801b14:	75 08                	jne    801b1e <ipc_recv+0x77>
  801b16:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1b:	8b 40 74             	mov    0x74(%eax),%eax
  801b1e:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	74 06                	je     801b2a <ipc_recv+0x83>
			*perm_store = 0;
  801b24:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801b2a:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801b2c:	85 d2                	test   %edx,%edx
  801b2e:	75 08                	jne    801b38 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801b30:	a1 04 40 80 00       	mov    0x804004,%eax
  801b35:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801b38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3b:	5b                   	pop    %ebx
  801b3c:	5e                   	pop    %esi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	57                   	push   %edi
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	83 ec 0c             	sub    $0xc,%esp
  801b48:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801b51:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801b53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b58:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b5b:	eb 1c                	jmp    801b79 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801b5d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b60:	74 12                	je     801b74 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801b62:	50                   	push   %eax
  801b63:	68 4c 23 80 00       	push   $0x80234c
  801b68:	6a 4f                	push   $0x4f
  801b6a:	68 67 23 80 00       	push   $0x802367
  801b6f:	e8 ed fe ff ff       	call   801a61 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801b74:	e8 63 ef ff ff       	call   800adc <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b79:	ff 75 14             	pushl  0x14(%ebp)
  801b7c:	53                   	push   %ebx
  801b7d:	56                   	push   %esi
  801b7e:	57                   	push   %edi
  801b7f:	e8 04 f1 ff ff       	call   800c88 <sys_ipc_try_send>
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 d2                	js     801b5d <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8e:	5b                   	pop    %ebx
  801b8f:	5e                   	pop    %esi
  801b90:	5f                   	pop    %edi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b9e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba7:	8b 52 50             	mov    0x50(%edx),%edx
  801baa:	39 ca                	cmp    %ecx,%edx
  801bac:	75 0d                	jne    801bbb <ipc_find_env+0x28>
			return envs[i].env_id;
  801bae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb6:	8b 40 48             	mov    0x48(%eax),%eax
  801bb9:	eb 0f                	jmp    801bca <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbb:	83 c0 01             	add    $0x1,%eax
  801bbe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc3:	75 d9                	jne    801b9e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd2:	89 d0                	mov    %edx,%eax
  801bd4:	c1 e8 16             	shr    $0x16,%eax
  801bd7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be3:	f6 c1 01             	test   $0x1,%cl
  801be6:	74 1d                	je     801c05 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801be8:	c1 ea 0c             	shr    $0xc,%edx
  801beb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf2:	f6 c2 01             	test   $0x1,%dl
  801bf5:	74 0e                	je     801c05 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf7:	c1 ea 0c             	shr    $0xc,%edx
  801bfa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c01:	ef 
  801c02:	0f b7 c0             	movzwl %ax,%eax
}
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    
  801c07:	66 90                	xchg   %ax,%ax
  801c09:	66 90                	xchg   %ax,%ax
  801c0b:	66 90                	xchg   %ax,%ax
  801c0d:	66 90                	xchg   %ax,%ax
  801c0f:	90                   	nop

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
