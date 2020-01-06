
obj/user/pingpongs.debug：     文件格式 elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 5a 10 00 00       	call   80109b <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 e8 0a 00 00       	call   800b3b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 22 80 00       	push   $0x802260
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 d1 0a 00 00       	call   800b3b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 22 80 00       	push   $0x80227a
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 c6 10 00 00       	call   80114d <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 1b 10 00 00       	call   8010b5 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 88 0a 00 00       	call   800b3b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 90 22 80 00       	push   $0x802290
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 63 10 00 00       	call   80114d <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 2d 0a 00 00       	call   800b3b <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 56 12 00 00       	call   8013a5 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 a1 09 00 00       	call   800afa <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 2f 09 00 00       	call   800abd <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 d4 08 00 00       	call   800abd <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 77 1d 00 00       	call   801fd0 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 64 1e 00 00       	call   802100 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 c0 22 80 00 	movsbl 0x8022c0(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 89 03 00 00    	je     8006cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 1a 03 00 00    	ja     8006b2 <vprintfmt+0x38a>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xdf>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x59>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x59>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  800411:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x142>
  80045f:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 d8 22 80 00       	push   $0x8022d8
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 94 fe ff ff       	call   80030b <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 35 28 80 00       	push   $0x802835
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7c fe ff ff       	call   80030b <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 d1 22 80 00       	mov    $0x8022d1,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x225>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 86 02 00 00       	call   800755 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c0>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x213>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x213>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x23f>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x270>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f2>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f2>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x278>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2d1>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	79 74                	jns    80067e <vprintfmt+0x356>
				putch('-', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 2d                	push   $0x2d
  800610:	ff d6                	call   *%esi
				num = -(long long) num;
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800627:	eb 55                	jmp    80067e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 83 fc ff ff       	call   8002b4 <getuint>
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800636:	eb 46                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 74 fc ff ff       	call   8002b4 <getuint>
			base=8;
  800640:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800645:	eb 37                	jmp    80067e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 3b fc ff ff       	call   8002b4 <getuint>
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	50                   	push   %eax
  80068c:	89 da                	mov    %ebx,%edx
  80068e:	89 f0                	mov    %esi,%eax
  800690:	e8 70 fb ff ff       	call   800205 <printnum>
			break;
  800695:	83 c4 20             	add    $0x20,%esp
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 ae fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	51                   	push   %ecx
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ad:	e9 9c fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 25                	push   $0x25
  8006b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb 03                	jmp    8006c2 <vprintfmt+0x39a>
  8006bf:	83 ef 01             	sub    $0x1,%edi
  8006c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c6:	75 f7                	jne    8006bf <vprintfmt+0x397>
  8006c8:	e9 81 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 26                	je     80071c <vsnprintf+0x47>
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	7e 22                	jle    80071c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fa:	ff 75 14             	pushl  0x14(%ebp)
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	68 ee 02 80 00       	push   $0x8002ee
  800709:	e8 1a fc ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800711:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 05                	jmp    800721 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072c:	50                   	push   %eax
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 9a ff ff ff       	call   8006d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 03                	jmp    80074d <strlen+0x10>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800751:	75 f7                	jne    80074a <strlen+0xd>
		n++;
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	ba 00 00 00 00       	mov    $0x0,%edx
  800763:	eb 03                	jmp    800768 <strnlen+0x13>
		n++;
  800765:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	39 c2                	cmp    %eax,%edx
  80076a:	74 08                	je     800774 <strnlen+0x1f>
  80076c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800770:	75 f3                	jne    800765 <strnlen+0x10>
  800772:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800780:	89 c2                	mov    %eax,%edx
  800782:	83 c2 01             	add    $0x1,%edx
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078f:	84 db                	test   %bl,%bl
  800791:	75 ef                	jne    800782 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079d:	53                   	push   %ebx
  80079e:	e8 9a ff ff ff       	call   80073d <strlen>
  8007a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a6:	ff 75 0c             	pushl  0xc(%ebp)
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	50                   	push   %eax
  8007ac:	e8 c5 ff ff ff       	call   800776 <strcpy>
	return dst;
}
  8007b1:	89 d8                	mov    %ebx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	89 f2                	mov    %esi,%edx
  8007ca:	eb 0f                	jmp    8007db <strncpy+0x23>
		*dst++ = *src;
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	0f b6 01             	movzbl (%ecx),%eax
  8007d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007db:	39 da                	cmp    %ebx,%edx
  8007dd:	75 ed                	jne    8007cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007df:	89 f0                	mov    %esi,%eax
  8007e1:	5b                   	pop    %ebx
  8007e2:	5e                   	pop    %esi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 21                	je     80081a <strlcpy+0x35>
  8007f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 09                	jmp    80080a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080a:	39 c2                	cmp    %eax,%edx
  80080c:	74 09                	je     800817 <strlcpy+0x32>
  80080e:	0f b6 19             	movzbl (%ecx),%ebx
  800811:	84 db                	test   %bl,%bl
  800813:	75 ec                	jne    800801 <strlcpy+0x1c>
  800815:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800817:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081a:	29 f0                	sub    %esi,%eax
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800829:	eb 06                	jmp    800831 <strcmp+0x11>
		p++, q++;
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	84 c0                	test   %al,%al
  800836:	74 04                	je     80083c <strcmp+0x1c>
  800838:	3a 02                	cmp    (%edx),%al
  80083a:	74 ef                	je     80082b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083c:	0f b6 c0             	movzbl %al,%eax
  80083f:	0f b6 12             	movzbl (%edx),%edx
  800842:	29 d0                	sub    %edx,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 c3                	mov    %eax,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800855:	eb 06                	jmp    80085d <strncmp+0x17>
		n--, p++, q++;
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	39 d8                	cmp    %ebx,%eax
  80085f:	74 15                	je     800876 <strncmp+0x30>
  800861:	0f b6 08             	movzbl (%eax),%ecx
  800864:	84 c9                	test   %cl,%cl
  800866:	74 04                	je     80086c <strncmp+0x26>
  800868:	3a 0a                	cmp    (%edx),%cl
  80086a:	74 eb                	je     800857 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	0f b6 00             	movzbl (%eax),%eax
  80086f:	0f b6 12             	movzbl (%edx),%edx
  800872:	29 d0                	sub    %edx,%eax
  800874:	eb 05                	jmp    80087b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 07                	jmp    800891 <strchr+0x13>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 0f                	je     80089d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 03                	jmp    8008ae <strfind+0xf>
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 04                	je     8008b9 <strfind+0x1a>
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strfind+0xc>
			break;
	return (char *) s;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	57                   	push   %edi
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 36                	je     800901 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d1:	75 28                	jne    8008fb <memset+0x40>
  8008d3:	f6 c1 03             	test   $0x3,%cl
  8008d6:	75 23                	jne    8008fb <memset+0x40>
		c &= 0xFF;
  8008d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dc:	89 d3                	mov    %edx,%ebx
  8008de:	c1 e3 08             	shl    $0x8,%ebx
  8008e1:	89 d6                	mov    %edx,%esi
  8008e3:	c1 e6 18             	shl    $0x18,%esi
  8008e6:	89 d0                	mov    %edx,%eax
  8008e8:	c1 e0 10             	shl    $0x10,%eax
  8008eb:	09 f0                	or     %esi,%eax
  8008ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
  8008f6:	fc                   	cld    
  8008f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f9:	eb 06                	jmp    800901 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	fc                   	cld    
  8008ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800901:	89 f8                	mov    %edi,%eax
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	57                   	push   %edi
  80090c:	56                   	push   %esi
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 75 0c             	mov    0xc(%ebp),%esi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800916:	39 c6                	cmp    %eax,%esi
  800918:	73 35                	jae    80094f <memmove+0x47>
  80091a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091d:	39 d0                	cmp    %edx,%eax
  80091f:	73 2e                	jae    80094f <memmove+0x47>
		s += n;
		d += n;
  800921:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	89 d6                	mov    %edx,%esi
  800926:	09 fe                	or     %edi,%esi
  800928:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092e:	75 13                	jne    800943 <memmove+0x3b>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 0e                	jne    800943 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800935:	83 ef 04             	sub    $0x4,%edi
  800938:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fd                   	std    
  80093f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800941:	eb 09                	jmp    80094c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800943:	83 ef 01             	sub    $0x1,%edi
  800946:	8d 72 ff             	lea    -0x1(%edx),%esi
  800949:	fd                   	std    
  80094a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094c:	fc                   	cld    
  80094d:	eb 1d                	jmp    80096c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	89 f2                	mov    %esi,%edx
  800951:	09 c2                	or     %eax,%edx
  800953:	f6 c2 03             	test   $0x3,%dl
  800956:	75 0f                	jne    800967 <memmove+0x5f>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 0a                	jne    800967 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 05                	jmp    80096c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800973:	ff 75 10             	pushl  0x10(%ebp)
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	ff 75 08             	pushl  0x8(%ebp)
  80097c:	e8 87 ff ff ff       	call   800908 <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 c6                	mov    %eax,%esi
  800990:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	eb 1a                	jmp    8009af <memcmp+0x2c>
		if (*s1 != *s2)
  800995:	0f b6 08             	movzbl (%eax),%ecx
  800998:	0f b6 1a             	movzbl (%edx),%ebx
  80099b:	38 d9                	cmp    %bl,%cl
  80099d:	74 0a                	je     8009a9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099f:	0f b6 c1             	movzbl %cl,%eax
  8009a2:	0f b6 db             	movzbl %bl,%ebx
  8009a5:	29 d8                	sub    %ebx,%eax
  8009a7:	eb 0f                	jmp    8009b8 <memcmp+0x35>
		s1++, s2++;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009af:	39 f0                	cmp    %esi,%eax
  8009b1:	75 e2                	jne    800995 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c3:	89 c1                	mov    %eax,%ecx
  8009c5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	eb 0a                	jmp    8009d8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	39 da                	cmp    %ebx,%edx
  8009d3:	74 07                	je     8009dc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	39 c8                	cmp    %ecx,%eax
  8009da:	72 f2                	jb     8009ce <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	eb 03                	jmp    8009f0 <strtol+0x11>
		s++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	0f b6 01             	movzbl (%ecx),%eax
  8009f3:	3c 20                	cmp    $0x20,%al
  8009f5:	74 f6                	je     8009ed <strtol+0xe>
  8009f7:	3c 09                	cmp    $0x9,%al
  8009f9:	74 f2                	je     8009ed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fb:	3c 2b                	cmp    $0x2b,%al
  8009fd:	75 0a                	jne    800a09 <strtol+0x2a>
		s++;
  8009ff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 11                	jmp    800a1a <strtol+0x3b>
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0e:	3c 2d                	cmp    $0x2d,%al
  800a10:	75 08                	jne    800a1a <strtol+0x3b>
		s++, neg = 1;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a20:	75 15                	jne    800a37 <strtol+0x58>
  800a22:	80 39 30             	cmpb   $0x30,(%ecx)
  800a25:	75 10                	jne    800a37 <strtol+0x58>
  800a27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2b:	75 7c                	jne    800aa9 <strtol+0xca>
		s += 2, base = 16;
  800a2d:	83 c1 02             	add    $0x2,%ecx
  800a30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a35:	eb 16                	jmp    800a4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	75 12                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a40:	80 39 30             	cmpb   $0x30,(%ecx)
  800a43:	75 08                	jne    800a4d <strtol+0x6e>
		s++, base = 8;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a55:	0f b6 11             	movzbl (%ecx),%edx
  800a58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 09             	cmp    $0x9,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x8b>
			dig = *s - '0';
  800a62:	0f be d2             	movsbl %dl,%edx
  800a65:	83 ea 30             	sub    $0x30,%edx
  800a68:	eb 22                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 57             	sub    $0x57,%edx
  800a7a:	eb 10                	jmp    800a8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 16                	ja     800a9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8f:	7d 0b                	jge    800a9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9a:	eb b9                	jmp    800a55 <strtol+0x76>

	if (endptr)
  800a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa0:	74 0d                	je     800aaf <strtol+0xd0>
		*endptr = (char *) s;
  800aa2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa5:	89 0e                	mov    %ecx,(%esi)
  800aa7:	eb 06                	jmp    800aaf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	74 98                	je     800a45 <strtol+0x66>
  800aad:	eb 9e                	jmp    800a4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	f7 da                	neg    %edx
  800ab3:	85 ff                	test   %edi,%edi
  800ab5:	0f 45 c2             	cmovne %edx,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	89 c3                	mov    %eax,%ebx
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	89 c6                	mov    %eax,%esi
  800ad4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_cgetc>:

int
sys_cgetc(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b08:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 cb                	mov    %ecx,%ebx
  800b12:	89 cf                	mov    %ecx,%edi
  800b14:	89 ce                	mov    %ecx,%esi
  800b16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	7e 17                	jle    800b33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	6a 03                	push   $0x3
  800b22:	68 bf 25 80 00       	push   $0x8025bf
  800b27:	6a 23                	push   $0x23
  800b29:	68 dc 25 80 00       	push   $0x8025dc
  800b2e:	e8 84 13 00 00       	call   801eb7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	be 00 00 00 00       	mov    $0x0,%esi
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	89 f7                	mov    %esi,%edi
  800b97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 04                	push   $0x4
  800ba3:	68 bf 25 80 00       	push   $0x8025bf
  800ba8:	6a 23                	push   $0x23
  800baa:	68 dc 25 80 00       	push   $0x8025dc
  800baf:	e8 03 13 00 00       	call   801eb7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 05                	push   $0x5
  800be5:	68 bf 25 80 00       	push   $0x8025bf
  800bea:	6a 23                	push   $0x23
  800bec:	68 dc 25 80 00       	push   $0x8025dc
  800bf1:	e8 c1 12 00 00       	call   801eb7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 df                	mov    %ebx,%edi
  800c19:	89 de                	mov    %ebx,%esi
  800c1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 06                	push   $0x6
  800c27:	68 bf 25 80 00       	push   $0x8025bf
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 dc 25 80 00       	push   $0x8025dc
  800c33:	e8 7f 12 00 00       	call   801eb7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 08                	push   $0x8
  800c69:	68 bf 25 80 00       	push   $0x8025bf
  800c6e:	6a 23                	push   $0x23
  800c70:	68 dc 25 80 00       	push   $0x8025dc
  800c75:	e8 3d 12 00 00       	call   801eb7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 09 00 00 00       	mov    $0x9,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 09                	push   $0x9
  800cab:	68 bf 25 80 00       	push   $0x8025bf
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 dc 25 80 00       	push   $0x8025dc
  800cb7:	e8 fb 11 00 00       	call   801eb7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0a                	push   $0xa
  800ced:	68 bf 25 80 00       	push   $0x8025bf
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 dc 25 80 00       	push   $0x8025dc
  800cf9:	e8 b9 11 00 00       	call   801eb7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 0d                	push   $0xd
  800d51:	68 bf 25 80 00       	push   $0x8025bf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 25 80 00       	push   $0x8025dc
  800d5d:	e8 55 11 00 00       	call   801eb7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d72:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800d74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d78:	75 14                	jne    800d8e <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800d7a:	83 ec 04             	sub    $0x4,%esp
  800d7d:	68 ec 25 80 00       	push   $0x8025ec
  800d82:	6a 23                	push   $0x23
  800d84:	68 af 26 80 00       	push   $0x8026af
  800d89:	e8 29 11 00 00       	call   801eb7 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	c1 e8 0c             	shr    $0xc,%eax
  800d93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d9a:	f6 c4 08             	test   $0x8,%ah
  800d9d:	75 14                	jne    800db3 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 10 26 80 00       	push   $0x802610
  800da7:	6a 2d                	push   $0x2d
  800da9:	68 af 26 80 00       	push   $0x8026af
  800dae:	e8 04 11 00 00       	call   801eb7 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800db3:	e8 83 fd ff ff       	call   800b3b <sys_getenvid>
  800db8:	83 ec 04             	sub    $0x4,%esp
  800dbb:	6a 07                	push   $0x7
  800dbd:	68 00 f0 7f 00       	push   $0x7ff000
  800dc2:	50                   	push   %eax
  800dc3:	e8 b1 fd ff ff       	call   800b79 <sys_page_alloc>
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	79 12                	jns    800de1 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800dcf:	50                   	push   %eax
  800dd0:	68 ba 26 80 00       	push   $0x8026ba
  800dd5:	6a 3b                	push   $0x3b
  800dd7:	68 af 26 80 00       	push   $0x8026af
  800ddc:	e8 d6 10 00 00       	call   801eb7 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800de1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	68 00 10 00 00       	push   $0x1000
  800def:	53                   	push   %ebx
  800df0:	68 00 f0 7f 00       	push   $0x7ff000
  800df5:	e8 0e fb ff ff       	call   800908 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800dfa:	e8 3c fd ff ff       	call   800b3b <sys_getenvid>
  800dff:	89 c6                	mov    %eax,%esi
  800e01:	e8 35 fd ff ff       	call   800b3b <sys_getenvid>
  800e06:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e0d:	53                   	push   %ebx
  800e0e:	56                   	push   %esi
  800e0f:	68 00 f0 7f 00       	push   $0x7ff000
  800e14:	50                   	push   %eax
  800e15:	e8 a2 fd ff ff       	call   800bbc <sys_page_map>
  800e1a:	83 c4 20             	add    $0x20,%esp
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	79 12                	jns    800e33 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800e21:	50                   	push   %eax
  800e22:	68 d3 26 80 00       	push   $0x8026d3
  800e27:	6a 48                	push   $0x48
  800e29:	68 af 26 80 00       	push   $0x8026af
  800e2e:	e8 84 10 00 00       	call   801eb7 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800e33:	e8 03 fd ff ff       	call   800b3b <sys_getenvid>
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	68 00 f0 7f 00       	push   $0x7ff000
  800e40:	50                   	push   %eax
  800e41:	e8 b8 fd ff ff       	call   800bfe <sys_page_unmap>
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	79 12                	jns    800e5f <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800e4d:	50                   	push   %eax
  800e4e:	68 ea 26 80 00       	push   $0x8026ea
  800e53:	6a 4c                	push   $0x4c
  800e55:	68 af 26 80 00       	push   $0x8026af
  800e5a:	e8 58 10 00 00       	call   801eb7 <_panic>
	}

	//panic("pgfault not implemented");
}
  800e5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800e6f:	68 6a 0d 80 00       	push   $0x800d6a
  800e74:	e8 84 10 00 00       	call   801efd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e79:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7e:	cd 30                	int    $0x30
  800e80:	89 c7                	mov    %eax,%edi
  800e82:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 15                	jns    800ea1 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800e8c:	50                   	push   %eax
  800e8d:	68 03 27 80 00       	push   $0x802703
  800e92:	68 a1 00 00 00       	push   $0xa1
  800e97:	68 af 26 80 00       	push   $0x8026af
  800e9c:	e8 16 10 00 00       	call   801eb7 <_panic>
  800ea1:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	75 21                	jne    800ecb <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800eaa:	e8 8c fc ff ff       	call   800b3b <sys_getenvid>
  800eaf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebc:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	e9 c8 01 00 00       	jmp    801093 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	c1 e8 16             	shr    $0x16,%eax
  800ed0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed7:	a8 01                	test   $0x1,%al
  800ed9:	0f 84 23 01 00 00    	je     801002 <fork+0x19c>
  800edf:	89 d8                	mov    %ebx,%eax
  800ee1:	c1 e8 0c             	shr    $0xc,%eax
  800ee4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eeb:	f6 c2 01             	test   $0x1,%dl
  800eee:	0f 84 0e 01 00 00    	je     801002 <fork+0x19c>
  800ef4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efb:	f6 c2 04             	test   $0x4,%dl
  800efe:	0f 84 fe 00 00 00    	je     801002 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800f04:	89 c6                	mov    %eax,%esi
  800f06:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800f09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f10:	f6 c6 04             	test   $0x4,%dh
  800f13:	74 3f                	je     800f54 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800f15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f24:	50                   	push   %eax
  800f25:	56                   	push   %esi
  800f26:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f29:	56                   	push   %esi
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 8b fc ff ff       	call   800bbc <sys_page_map>
  800f31:	83 c4 20             	add    $0x20,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	0f 89 c6 00 00 00    	jns    801002 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	50                   	push   %eax
  800f40:	57                   	push   %edi
  800f41:	6a 00                	push   $0x0
  800f43:	68 40 26 80 00       	push   $0x802640
  800f48:	6a 6c                	push   $0x6c
  800f4a:	68 af 26 80 00       	push   $0x8026af
  800f4f:	e8 63 0f 00 00       	call   801eb7 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f54:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5b:	f6 c2 02             	test   $0x2,%dl
  800f5e:	75 0c                	jne    800f6c <fork+0x106>
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	f6 c4 08             	test   $0x8,%ah
  800f6a:	74 66                	je     800fd2 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	68 05 08 00 00       	push   $0x805
  800f74:	56                   	push   %esi
  800f75:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f78:	56                   	push   %esi
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 3c fc ff ff       	call   800bbc <sys_page_map>
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	79 18                	jns    800f9f <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f87:	83 ec 08             	sub    $0x8,%esp
  800f8a:	50                   	push   %eax
  800f8b:	57                   	push   %edi
  800f8c:	6a 00                	push   $0x0
  800f8e:	68 40 26 80 00       	push   $0x802640
  800f93:	6a 74                	push   $0x74
  800f95:	68 af 26 80 00       	push   $0x8026af
  800f9a:	e8 18 0f 00 00       	call   801eb7 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	68 05 08 00 00       	push   $0x805
  800fa7:	56                   	push   %esi
  800fa8:	6a 00                	push   $0x0
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 0a fc ff ff       	call   800bbc <sys_page_map>
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 49                	jns    801002 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	50                   	push   %eax
  800fbd:	6a 00                	push   $0x0
  800fbf:	6a 00                	push   $0x0
  800fc1:	68 40 26 80 00       	push   $0x802640
  800fc6:	6a 77                	push   $0x77
  800fc8:	68 af 26 80 00       	push   $0x8026af
  800fcd:	e8 e5 0e 00 00       	call   801eb7 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	6a 05                	push   $0x5
  800fd7:	56                   	push   %esi
  800fd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdb:	56                   	push   %esi
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 d9 fb ff ff       	call   800bbc <sys_page_map>
  800fe3:	83 c4 20             	add    $0x20,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	79 18                	jns    801002 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	50                   	push   %eax
  800fee:	57                   	push   %edi
  800fef:	6a 00                	push   $0x0
  800ff1:	68 40 26 80 00       	push   $0x802640
  800ff6:	6a 7d                	push   $0x7d
  800ff8:	68 af 26 80 00       	push   $0x8026af
  800ffd:	e8 b5 0e 00 00       	call   801eb7 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801002:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801008:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80100e:	0f 85 b7 fe ff ff    	jne    800ecb <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	6a 07                	push   $0x7
  801019:	68 00 f0 bf ee       	push   $0xeebff000
  80101e:	57                   	push   %edi
  80101f:	e8 55 fb ff ff       	call   800b79 <sys_page_alloc>
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	79 15                	jns    801040 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  80102b:	50                   	push   %eax
  80102c:	68 6c 26 80 00       	push   $0x80266c
  801031:	68 b4 00 00 00       	push   $0xb4
  801036:	68 af 26 80 00       	push   $0x8026af
  80103b:	e8 77 0e 00 00       	call   801eb7 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801040:	83 ec 08             	sub    $0x8,%esp
  801043:	68 71 1f 80 00       	push   $0x801f71
  801048:	57                   	push   %edi
  801049:	e8 76 fc ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	79 15                	jns    80106a <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801055:	50                   	push   %eax
  801056:	68 19 27 80 00       	push   $0x802719
  80105b:	68 ba 00 00 00       	push   $0xba
  801060:	68 af 26 80 00       	push   $0x8026af
  801065:	e8 4d 0e 00 00       	call   801eb7 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	6a 02                	push   $0x2
  80106f:	57                   	push   %edi
  801070:	e8 cb fb ff ff       	call   800c40 <sys_env_set_status>
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 15                	jns    801091 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  80107c:	50                   	push   %eax
  80107d:	68 36 27 80 00       	push   $0x802736
  801082:	68 bf 00 00 00       	push   $0xbf
  801087:	68 af 26 80 00       	push   $0x8026af
  80108c:	e8 26 0e 00 00       	call   801eb7 <_panic>
	}
	return eid;
  801091:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <sfork>:

// Challenge!
int
sfork(void)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a1:	68 53 27 80 00       	push   $0x802753
  8010a6:	68 ca 00 00 00       	push   $0xca
  8010ab:	68 af 26 80 00       	push   $0x8026af
  8010b0:	e8 02 0e 00 00       	call   801eb7 <_panic>

008010b5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8010bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	74 3e                	je     801105 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	50                   	push   %eax
  8010cb:	e8 59 fc ff ff       	call   800d29 <sys_ipc_recv>
  8010d0:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 f6                	test   %esi,%esi
  8010d7:	74 13                	je     8010ec <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010de:	85 d2                	test   %edx,%edx
  8010e0:	75 08                	jne    8010ea <ipc_recv+0x35>
  8010e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e7:	8b 40 74             	mov    0x74(%eax),%eax
  8010ea:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8010ec:	85 db                	test   %ebx,%ebx
  8010ee:	74 48                	je     801138 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  8010f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f5:	85 d2                	test   %edx,%edx
  8010f7:	75 08                	jne    801101 <ipc_recv+0x4c>
  8010f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010fe:	8b 40 78             	mov    0x78(%eax),%eax
  801101:	89 03                	mov    %eax,(%ebx)
  801103:	eb 33                	jmp    801138 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	68 00 00 c0 ee       	push   $0xeec00000
  80110d:	e8 17 fc ff ff       	call   800d29 <sys_ipc_recv>
  801112:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 f6                	test   %esi,%esi
  801119:	74 13                	je     80112e <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  80111b:	b8 00 00 00 00       	mov    $0x0,%eax
  801120:	85 d2                	test   %edx,%edx
  801122:	75 08                	jne    80112c <ipc_recv+0x77>
  801124:	a1 08 40 80 00       	mov    0x804008,%eax
  801129:	8b 40 74             	mov    0x74(%eax),%eax
  80112c:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80112e:	85 db                	test   %ebx,%ebx
  801130:	74 06                	je     801138 <ipc_recv+0x83>
			*perm_store = 0;
  801132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801138:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  80113a:	85 d2                	test   %edx,%edx
  80113c:	75 08                	jne    801146 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  80113e:	a1 08 40 80 00       	mov    0x804008,%eax
  801143:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801146:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801149:	5b                   	pop    %ebx
  80114a:	5e                   	pop    %esi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	57                   	push   %edi
  801151:	56                   	push   %esi
  801152:	53                   	push   %ebx
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	8b 7d 08             	mov    0x8(%ebp),%edi
  801159:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80115f:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801161:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801166:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801169:	eb 1c                	jmp    801187 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  80116b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80116e:	74 12                	je     801182 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801170:	50                   	push   %eax
  801171:	68 69 27 80 00       	push   $0x802769
  801176:	6a 4f                	push   $0x4f
  801178:	68 84 27 80 00       	push   $0x802784
  80117d:	e8 35 0d 00 00       	call   801eb7 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801182:	e8 d3 f9 ff ff       	call   800b5a <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801187:	ff 75 14             	pushl  0x14(%ebp)
  80118a:	53                   	push   %ebx
  80118b:	56                   	push   %esi
  80118c:	57                   	push   %edi
  80118d:	e8 74 fb ff ff       	call   800d06 <sys_ipc_try_send>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 d2                	js     80116b <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b5:	8b 52 50             	mov    0x50(%edx),%edx
  8011b8:	39 ca                	cmp    %ecx,%edx
  8011ba:	75 0d                	jne    8011c9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	eb 0f                	jmp    8011d8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c9:	83 c0 01             	add    $0x1,%eax
  8011cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d1:	75 d9                	jne    8011ac <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801207:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	c1 ea 16             	shr    $0x16,%edx
  801211:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801218:	f6 c2 01             	test   $0x1,%dl
  80121b:	74 11                	je     80122e <fd_alloc+0x2d>
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	c1 ea 0c             	shr    $0xc,%edx
  801222:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801229:	f6 c2 01             	test   $0x1,%dl
  80122c:	75 09                	jne    801237 <fd_alloc+0x36>
			*fd_store = fd;
  80122e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 17                	jmp    80124e <fd_alloc+0x4d>
  801237:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801241:	75 c9                	jne    80120c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801243:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801249:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801256:	83 f8 1f             	cmp    $0x1f,%eax
  801259:	77 36                	ja     801291 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125b:	c1 e0 0c             	shl    $0xc,%eax
  80125e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801263:	89 c2                	mov    %eax,%edx
  801265:	c1 ea 16             	shr    $0x16,%edx
  801268:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 24                	je     801298 <fd_lookup+0x48>
  801274:	89 c2                	mov    %eax,%edx
  801276:	c1 ea 0c             	shr    $0xc,%edx
  801279:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801280:	f6 c2 01             	test   $0x1,%dl
  801283:	74 1a                	je     80129f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801285:	8b 55 0c             	mov    0xc(%ebp),%edx
  801288:	89 02                	mov    %eax,(%edx)
	return 0;
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
  80128f:	eb 13                	jmp    8012a4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801296:	eb 0c                	jmp    8012a4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb 05                	jmp    8012a4 <fd_lookup+0x54>
  80129f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012af:	ba 0c 28 80 00       	mov    $0x80280c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b4:	eb 13                	jmp    8012c9 <dev_lookup+0x23>
  8012b6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b9:	39 08                	cmp    %ecx,(%eax)
  8012bb:	75 0c                	jne    8012c9 <dev_lookup+0x23>
			*dev = devtab[i];
  8012bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb 2e                	jmp    8012f7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c9:	8b 02                	mov    (%edx),%eax
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	75 e7                	jne    8012b6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012cf:	a1 08 40 80 00       	mov    0x804008,%eax
  8012d4:	8b 40 48             	mov    0x48(%eax),%eax
  8012d7:	83 ec 04             	sub    $0x4,%esp
  8012da:	51                   	push   %ecx
  8012db:	50                   	push   %eax
  8012dc:	68 90 27 80 00       	push   $0x802790
  8012e1:	e8 0b ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	56                   	push   %esi
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 10             	sub    $0x10,%esp
  801301:	8b 75 08             	mov    0x8(%ebp),%esi
  801304:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801311:	c1 e8 0c             	shr    $0xc,%eax
  801314:	50                   	push   %eax
  801315:	e8 36 ff ff ff       	call   801250 <fd_lookup>
  80131a:	83 c4 08             	add    $0x8,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 05                	js     801326 <fd_close+0x2d>
	    || fd != fd2)
  801321:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801324:	74 0c                	je     801332 <fd_close+0x39>
		return (must_exist ? r : 0);
  801326:	84 db                	test   %bl,%bl
  801328:	ba 00 00 00 00       	mov    $0x0,%edx
  80132d:	0f 44 c2             	cmove  %edx,%eax
  801330:	eb 41                	jmp    801373 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 36                	pushl  (%esi)
  80133b:	e8 66 ff ff ff       	call   8012a6 <dev_lookup>
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 1a                	js     801363 <fd_close+0x6a>
		if (dev->dev_close)
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801354:	85 c0                	test   %eax,%eax
  801356:	74 0b                	je     801363 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	56                   	push   %esi
  80135c:	ff d0                	call   *%eax
  80135e:	89 c3                	mov    %eax,%ebx
  801360:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	56                   	push   %esi
  801367:	6a 00                	push   $0x0
  801369:	e8 90 f8 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	89 d8                	mov    %ebx,%eax
}
  801373:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 75 08             	pushl  0x8(%ebp)
  801387:	e8 c4 fe ff ff       	call   801250 <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 10                	js     8013a3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	6a 01                	push   $0x1
  801398:	ff 75 f4             	pushl  -0xc(%ebp)
  80139b:	e8 59 ff ff ff       	call   8012f9 <fd_close>
  8013a0:	83 c4 10             	add    $0x10,%esp
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <close_all>:

void
close_all(void)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	e8 c0 ff ff ff       	call   80137a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ba:	83 c3 01             	add    $0x1,%ebx
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	83 fb 20             	cmp    $0x20,%ebx
  8013c3:	75 ec                	jne    8013b1 <close_all+0xc>
		close(i);
}
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 2c             	sub    $0x2c,%esp
  8013d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 75 08             	pushl  0x8(%ebp)
  8013dd:	e8 6e fe ff ff       	call   801250 <fd_lookup>
  8013e2:	83 c4 08             	add    $0x8,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	0f 88 c1 00 00 00    	js     8014ae <dup+0xe4>
		return r;
	close(newfdnum);
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	56                   	push   %esi
  8013f1:	e8 84 ff ff ff       	call   80137a <close>

	newfd = INDEX2FD(newfdnum);
  8013f6:	89 f3                	mov    %esi,%ebx
  8013f8:	c1 e3 0c             	shl    $0xc,%ebx
  8013fb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801401:	83 c4 04             	add    $0x4,%esp
  801404:	ff 75 e4             	pushl  -0x1c(%ebp)
  801407:	e8 de fd ff ff       	call   8011ea <fd2data>
  80140c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80140e:	89 1c 24             	mov    %ebx,(%esp)
  801411:	e8 d4 fd ff ff       	call   8011ea <fd2data>
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141c:	89 f8                	mov    %edi,%eax
  80141e:	c1 e8 16             	shr    $0x16,%eax
  801421:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801428:	a8 01                	test   $0x1,%al
  80142a:	74 37                	je     801463 <dup+0x99>
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	c1 e8 0c             	shr    $0xc,%eax
  801431:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	74 26                	je     801463 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801444:	83 ec 0c             	sub    $0xc,%esp
  801447:	25 07 0e 00 00       	and    $0xe07,%eax
  80144c:	50                   	push   %eax
  80144d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801450:	6a 00                	push   $0x0
  801452:	57                   	push   %edi
  801453:	6a 00                	push   $0x0
  801455:	e8 62 f7 ff ff       	call   800bbc <sys_page_map>
  80145a:	89 c7                	mov    %eax,%edi
  80145c:	83 c4 20             	add    $0x20,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 2e                	js     801491 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801463:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801466:	89 d0                	mov    %edx,%eax
  801468:	c1 e8 0c             	shr    $0xc,%eax
  80146b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	25 07 0e 00 00       	and    $0xe07,%eax
  80147a:	50                   	push   %eax
  80147b:	53                   	push   %ebx
  80147c:	6a 00                	push   $0x0
  80147e:	52                   	push   %edx
  80147f:	6a 00                	push   $0x0
  801481:	e8 36 f7 ff ff       	call   800bbc <sys_page_map>
  801486:	89 c7                	mov    %eax,%edi
  801488:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148d:	85 ff                	test   %edi,%edi
  80148f:	79 1d                	jns    8014ae <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	53                   	push   %ebx
  801495:	6a 00                	push   $0x0
  801497:	e8 62 f7 ff ff       	call   800bfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149c:	83 c4 08             	add    $0x8,%esp
  80149f:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 55 f7 ff ff       	call   800bfe <sys_page_unmap>
	return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	89 f8                	mov    %edi,%eax
}
  8014ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5f                   	pop    %edi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 14             	sub    $0x14,%esp
  8014bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	53                   	push   %ebx
  8014c5:	e8 86 fd ff ff       	call   801250 <fd_lookup>
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 6d                	js     801540 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	ff 30                	pushl  (%eax)
  8014df:	e8 c2 fd ff ff       	call   8012a6 <dev_lookup>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 4c                	js     801537 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ee:	8b 42 08             	mov    0x8(%edx),%eax
  8014f1:	83 e0 03             	and    $0x3,%eax
  8014f4:	83 f8 01             	cmp    $0x1,%eax
  8014f7:	75 21                	jne    80151a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8014fe:	8b 40 48             	mov    0x48(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 d1 27 80 00       	push   $0x8027d1
  80150b:	e8 e1 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801518:	eb 26                	jmp    801540 <read+0x8a>
	}
	if (!dev->dev_read)
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	8b 40 08             	mov    0x8(%eax),%eax
  801520:	85 c0                	test   %eax,%eax
  801522:	74 17                	je     80153b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	ff 75 10             	pushl  0x10(%ebp)
  80152a:	ff 75 0c             	pushl  0xc(%ebp)
  80152d:	52                   	push   %edx
  80152e:	ff d0                	call   *%eax
  801530:	89 c2                	mov    %eax,%edx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	eb 09                	jmp    801540 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801537:	89 c2                	mov    %eax,%edx
  801539:	eb 05                	jmp    801540 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801540:	89 d0                	mov    %edx,%eax
  801542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	57                   	push   %edi
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	8b 7d 08             	mov    0x8(%ebp),%edi
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155b:	eb 21                	jmp    80157e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	89 f0                	mov    %esi,%eax
  801562:	29 d8                	sub    %ebx,%eax
  801564:	50                   	push   %eax
  801565:	89 d8                	mov    %ebx,%eax
  801567:	03 45 0c             	add    0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	57                   	push   %edi
  80156c:	e8 45 ff ff ff       	call   8014b6 <read>
		if (m < 0)
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 10                	js     801588 <readn+0x41>
			return m;
		if (m == 0)
  801578:	85 c0                	test   %eax,%eax
  80157a:	74 0a                	je     801586 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157c:	01 c3                	add    %eax,%ebx
  80157e:	39 f3                	cmp    %esi,%ebx
  801580:	72 db                	jb     80155d <readn+0x16>
  801582:	89 d8                	mov    %ebx,%eax
  801584:	eb 02                	jmp    801588 <readn+0x41>
  801586:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801588:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5f                   	pop    %edi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 14             	sub    $0x14,%esp
  801597:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	53                   	push   %ebx
  80159f:	e8 ac fc ff ff       	call   801250 <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	89 c2                	mov    %eax,%edx
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 68                	js     801615 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b7:	ff 30                	pushl  (%eax)
  8015b9:	e8 e8 fc ff ff       	call   8012a6 <dev_lookup>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 47                	js     80160c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cc:	75 21                	jne    8015ef <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ce:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d3:	8b 40 48             	mov    0x48(%eax),%eax
  8015d6:	83 ec 04             	sub    $0x4,%esp
  8015d9:	53                   	push   %ebx
  8015da:	50                   	push   %eax
  8015db:	68 ed 27 80 00       	push   $0x8027ed
  8015e0:	e8 0c ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ed:	eb 26                	jmp    801615 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f5:	85 d2                	test   %edx,%edx
  8015f7:	74 17                	je     801610 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	ff 75 10             	pushl  0x10(%ebp)
  8015ff:	ff 75 0c             	pushl  0xc(%ebp)
  801602:	50                   	push   %eax
  801603:	ff d2                	call   *%edx
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 09                	jmp    801615 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	eb 05                	jmp    801615 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801610:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <seek>:

int
seek(int fdnum, off_t offset)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801622:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	ff 75 08             	pushl  0x8(%ebp)
  801629:	e8 22 fc ff ff       	call   801250 <fd_lookup>
  80162e:	83 c4 08             	add    $0x8,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 0e                	js     801643 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801635:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	53                   	push   %ebx
  801649:	83 ec 14             	sub    $0x14,%esp
  80164c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801652:	50                   	push   %eax
  801653:	53                   	push   %ebx
  801654:	e8 f7 fb ff ff       	call   801250 <fd_lookup>
  801659:	83 c4 08             	add    $0x8,%esp
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 65                	js     8016c7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166c:	ff 30                	pushl  (%eax)
  80166e:	e8 33 fc ff ff       	call   8012a6 <dev_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 44                	js     8016be <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801681:	75 21                	jne    8016a4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801683:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801688:	8b 40 48             	mov    0x48(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	53                   	push   %ebx
  80168f:	50                   	push   %eax
  801690:	68 b0 27 80 00       	push   $0x8027b0
  801695:	e8 57 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a2:	eb 23                	jmp    8016c7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a7:	8b 52 18             	mov    0x18(%edx),%edx
  8016aa:	85 d2                	test   %edx,%edx
  8016ac:	74 14                	je     8016c2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	50                   	push   %eax
  8016b5:	ff d2                	call   *%edx
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	eb 09                	jmp    8016c7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	eb 05                	jmp    8016c7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c7:	89 d0                	mov    %edx,%eax
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 14             	sub    $0x14,%esp
  8016d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	ff 75 08             	pushl  0x8(%ebp)
  8016df:	e8 6c fb ff ff       	call   801250 <fd_lookup>
  8016e4:	83 c4 08             	add    $0x8,%esp
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 58                	js     801745 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	ff 30                	pushl  (%eax)
  8016f9:	e8 a8 fb ff ff       	call   8012a6 <dev_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 37                	js     80173c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170c:	74 32                	je     801740 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801711:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801718:	00 00 00 
	stat->st_isdir = 0;
  80171b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801722:	00 00 00 
	stat->st_dev = dev;
  801725:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	53                   	push   %ebx
  80172f:	ff 75 f0             	pushl  -0x10(%ebp)
  801732:	ff 50 14             	call   *0x14(%eax)
  801735:	89 c2                	mov    %eax,%edx
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	eb 09                	jmp    801745 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	eb 05                	jmp    801745 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801740:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801745:	89 d0                	mov    %edx,%eax
  801747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    

0080174c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	6a 00                	push   $0x0
  801756:	ff 75 08             	pushl  0x8(%ebp)
  801759:	e8 d6 01 00 00       	call   801934 <open>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 1b                	js     801782 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	ff 75 0c             	pushl  0xc(%ebp)
  80176d:	50                   	push   %eax
  80176e:	e8 5b ff ff ff       	call   8016ce <fstat>
  801773:	89 c6                	mov    %eax,%esi
	close(fd);
  801775:	89 1c 24             	mov    %ebx,(%esp)
  801778:	e8 fd fb ff ff       	call   80137a <close>
	return r;
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	89 f0                	mov    %esi,%eax
}
  801782:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	89 c6                	mov    %eax,%esi
  801790:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801792:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801799:	75 12                	jne    8017ad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	6a 01                	push   $0x1
  8017a0:	e8 fc f9 ff ff       	call   8011a1 <ipc_find_env>
  8017a5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017aa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ad:	6a 07                	push   $0x7
  8017af:	68 00 50 80 00       	push   $0x805000
  8017b4:	56                   	push   %esi
  8017b5:	ff 35 00 40 80 00    	pushl  0x804000
  8017bb:	e8 8d f9 ff ff       	call   80114d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c0:	83 c4 0c             	add    $0xc,%esp
  8017c3:	6a 00                	push   $0x0
  8017c5:	53                   	push   %ebx
  8017c6:	6a 00                	push   $0x0
  8017c8:	e8 e8 f8 ff ff       	call   8010b5 <ipc_recv>
}
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f7:	e8 8d ff ff ff       	call   801789 <fsipc>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8b 40 0c             	mov    0xc(%eax),%eax
  80180a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 06 00 00 00       	mov    $0x6,%eax
  801819:	e8 6b ff ff ff       	call   801789 <fsipc>
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 05 00 00 00       	mov    $0x5,%eax
  80183f:	e8 45 ff ff ff       	call   801789 <fsipc>
  801844:	85 c0                	test   %eax,%eax
  801846:	78 2c                	js     801874 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	68 00 50 80 00       	push   $0x805000
  801850:	53                   	push   %ebx
  801851:	e8 20 ef ff ff       	call   800776 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801856:	a1 80 50 80 00       	mov    0x805080,%eax
  80185b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801861:	a1 84 50 80 00       	mov    0x805084,%eax
  801866:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801882:	8b 55 08             	mov    0x8(%ebp),%edx
  801885:	8b 52 0c             	mov    0xc(%edx),%edx
  801888:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80188e:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801893:	50                   	push   %eax
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	68 08 50 80 00       	push   $0x805008
  80189c:	e8 67 f0 ff ff       	call   800908 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ab:	e8 d9 fe ff ff       	call   801789 <fsipc>
	//panic("devfile_write not implemented");
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d5:	e8 af fe ff ff       	call   801789 <fsipc>
  8018da:	89 c3                	mov    %eax,%ebx
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 4b                	js     80192b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e0:	39 c6                	cmp    %eax,%esi
  8018e2:	73 16                	jae    8018fa <devfile_read+0x48>
  8018e4:	68 1c 28 80 00       	push   $0x80281c
  8018e9:	68 23 28 80 00       	push   $0x802823
  8018ee:	6a 7c                	push   $0x7c
  8018f0:	68 38 28 80 00       	push   $0x802838
  8018f5:	e8 bd 05 00 00       	call   801eb7 <_panic>
	assert(r <= PGSIZE);
  8018fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ff:	7e 16                	jle    801917 <devfile_read+0x65>
  801901:	68 43 28 80 00       	push   $0x802843
  801906:	68 23 28 80 00       	push   $0x802823
  80190b:	6a 7d                	push   $0x7d
  80190d:	68 38 28 80 00       	push   $0x802838
  801912:	e8 a0 05 00 00       	call   801eb7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	50                   	push   %eax
  80191b:	68 00 50 80 00       	push   $0x805000
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	e8 e0 ef ff ff       	call   800908 <memmove>
	return r;
  801928:	83 c4 10             	add    $0x10,%esp
}
  80192b:	89 d8                	mov    %ebx,%eax
  80192d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801930:	5b                   	pop    %ebx
  801931:	5e                   	pop    %esi
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	53                   	push   %ebx
  801938:	83 ec 20             	sub    $0x20,%esp
  80193b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80193e:	53                   	push   %ebx
  80193f:	e8 f9 ed ff ff       	call   80073d <strlen>
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80194c:	7f 67                	jg     8019b5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801954:	50                   	push   %eax
  801955:	e8 a7 f8 ff ff       	call   801201 <fd_alloc>
  80195a:	83 c4 10             	add    $0x10,%esp
		return r;
  80195d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 57                	js     8019ba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	53                   	push   %ebx
  801967:	68 00 50 80 00       	push   $0x805000
  80196c:	e8 05 ee ff ff       	call   800776 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801971:	8b 45 0c             	mov    0xc(%ebp),%eax
  801974:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801979:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197c:	b8 01 00 00 00       	mov    $0x1,%eax
  801981:	e8 03 fe ff ff       	call   801789 <fsipc>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	79 14                	jns    8019a3 <open+0x6f>
		fd_close(fd, 0);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	6a 00                	push   $0x0
  801994:	ff 75 f4             	pushl  -0xc(%ebp)
  801997:	e8 5d f9 ff ff       	call   8012f9 <fd_close>
		return r;
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	89 da                	mov    %ebx,%edx
  8019a1:	eb 17                	jmp    8019ba <open+0x86>
	}

	return fd2num(fd);
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a9:	e8 2c f8 ff ff       	call   8011da <fd2num>
  8019ae:	89 c2                	mov    %eax,%edx
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	eb 05                	jmp    8019ba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ba:	89 d0                	mov    %edx,%eax
  8019bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d1:	e8 b3 fd ff ff       	call   801789 <fsipc>
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 75 08             	pushl  0x8(%ebp)
  8019e6:	e8 ff f7 ff ff       	call   8011ea <fd2data>
  8019eb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ed:	83 c4 08             	add    $0x8,%esp
  8019f0:	68 4f 28 80 00       	push   $0x80284f
  8019f5:	53                   	push   %ebx
  8019f6:	e8 7b ed ff ff       	call   800776 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019fb:	8b 46 04             	mov    0x4(%esi),%eax
  8019fe:	2b 06                	sub    (%esi),%eax
  801a00:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a06:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a0d:	00 00 00 
	stat->st_dev = &devpipe;
  801a10:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a17:	30 80 00 
	return 0;
}
  801a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a22:	5b                   	pop    %ebx
  801a23:	5e                   	pop    %esi
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 0c             	sub    $0xc,%esp
  801a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a30:	53                   	push   %ebx
  801a31:	6a 00                	push   $0x0
  801a33:	e8 c6 f1 ff ff       	call   800bfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a38:	89 1c 24             	mov    %ebx,(%esp)
  801a3b:	e8 aa f7 ff ff       	call   8011ea <fd2data>
  801a40:	83 c4 08             	add    $0x8,%esp
  801a43:	50                   	push   %eax
  801a44:	6a 00                	push   $0x0
  801a46:	e8 b3 f1 ff ff       	call   800bfe <sys_page_unmap>
}
  801a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	57                   	push   %edi
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 1c             	sub    $0x1c,%esp
  801a59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a5c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a5e:	a1 08 40 80 00       	mov    0x804008,%eax
  801a63:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6c:	e8 24 05 00 00       	call   801f95 <pageref>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	89 3c 24             	mov    %edi,(%esp)
  801a76:	e8 1a 05 00 00       	call   801f95 <pageref>
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	39 c3                	cmp    %eax,%ebx
  801a80:	0f 94 c1             	sete   %cl
  801a83:	0f b6 c9             	movzbl %cl,%ecx
  801a86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a89:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a8f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a92:	39 ce                	cmp    %ecx,%esi
  801a94:	74 1b                	je     801ab1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a96:	39 c3                	cmp    %eax,%ebx
  801a98:	75 c4                	jne    801a5e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a9a:	8b 42 58             	mov    0x58(%edx),%eax
  801a9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aa0:	50                   	push   %eax
  801aa1:	56                   	push   %esi
  801aa2:	68 56 28 80 00       	push   $0x802856
  801aa7:	e8 45 e7 ff ff       	call   8001f1 <cprintf>
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	eb ad                	jmp    801a5e <_pipeisclosed+0xe>
	}
}
  801ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	57                   	push   %edi
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 28             	sub    $0x28,%esp
  801ac5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ac8:	56                   	push   %esi
  801ac9:	e8 1c f7 ff ff       	call   8011ea <fd2data>
  801ace:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad8:	eb 4b                	jmp    801b25 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ada:	89 da                	mov    %ebx,%edx
  801adc:	89 f0                	mov    %esi,%eax
  801ade:	e8 6d ff ff ff       	call   801a50 <_pipeisclosed>
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	75 48                	jne    801b2f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae7:	e8 6e f0 ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aec:	8b 43 04             	mov    0x4(%ebx),%eax
  801aef:	8b 0b                	mov    (%ebx),%ecx
  801af1:	8d 51 20             	lea    0x20(%ecx),%edx
  801af4:	39 d0                	cmp    %edx,%eax
  801af6:	73 e2                	jae    801ada <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	c1 fa 1f             	sar    $0x1f,%edx
  801b07:	89 d1                	mov    %edx,%ecx
  801b09:	c1 e9 1b             	shr    $0x1b,%ecx
  801b0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b0f:	83 e2 1f             	and    $0x1f,%edx
  801b12:	29 ca                	sub    %ecx,%edx
  801b14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b1c:	83 c0 01             	add    $0x1,%eax
  801b1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	83 c7 01             	add    $0x1,%edi
  801b25:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b28:	75 c2                	jne    801aec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2d:	eb 05                	jmp    801b34 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b37:	5b                   	pop    %ebx
  801b38:	5e                   	pop    %esi
  801b39:	5f                   	pop    %edi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	83 ec 18             	sub    $0x18,%esp
  801b45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b48:	57                   	push   %edi
  801b49:	e8 9c f6 ff ff       	call   8011ea <fd2data>
  801b4e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b58:	eb 3d                	jmp    801b97 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b5a:	85 db                	test   %ebx,%ebx
  801b5c:	74 04                	je     801b62 <devpipe_read+0x26>
				return i;
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	eb 44                	jmp    801ba6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b62:	89 f2                	mov    %esi,%edx
  801b64:	89 f8                	mov    %edi,%eax
  801b66:	e8 e5 fe ff ff       	call   801a50 <_pipeisclosed>
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	75 32                	jne    801ba1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b6f:	e8 e6 ef ff ff       	call   800b5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b74:	8b 06                	mov    (%esi),%eax
  801b76:	3b 46 04             	cmp    0x4(%esi),%eax
  801b79:	74 df                	je     801b5a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7b:	99                   	cltd   
  801b7c:	c1 ea 1b             	shr    $0x1b,%edx
  801b7f:	01 d0                	add    %edx,%eax
  801b81:	83 e0 1f             	and    $0x1f,%eax
  801b84:	29 d0                	sub    %edx,%eax
  801b86:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b91:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b94:	83 c3 01             	add    $0x1,%ebx
  801b97:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b9a:	75 d8                	jne    801b74 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9f:	eb 05                	jmp    801ba6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb9:	50                   	push   %eax
  801bba:	e8 42 f6 ff ff       	call   801201 <fd_alloc>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	89 c2                	mov    %eax,%edx
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	0f 88 2c 01 00 00    	js     801cf8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcc:	83 ec 04             	sub    $0x4,%esp
  801bcf:	68 07 04 00 00       	push   $0x407
  801bd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 9b ef ff ff       	call   800b79 <sys_page_alloc>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	89 c2                	mov    %eax,%edx
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 0d 01 00 00    	js     801cf8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 0a f6 ff ff       	call   801201 <fd_alloc>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 e2 00 00 00    	js     801ce6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 63 ef ff ff       	call   800b79 <sys_page_alloc>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 c3 00 00 00    	js     801ce6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	ff 75 f4             	pushl  -0xc(%ebp)
  801c29:	e8 bc f5 ff ff       	call   8011ea <fd2data>
  801c2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 c4 0c             	add    $0xc,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	50                   	push   %eax
  801c39:	6a 00                	push   $0x0
  801c3b:	e8 39 ef ff ff       	call   800b79 <sys_page_alloc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	0f 88 89 00 00 00    	js     801cd6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 f0             	pushl  -0x10(%ebp)
  801c53:	e8 92 f5 ff ff       	call   8011ea <fd2data>
  801c58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c5f:	50                   	push   %eax
  801c60:	6a 00                	push   $0x0
  801c62:	56                   	push   %esi
  801c63:	6a 00                	push   $0x0
  801c65:	e8 52 ef ff ff       	call   800bbc <sys_page_map>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 20             	add    $0x20,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 55                	js     801cc8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c9d:	83 ec 0c             	sub    $0xc,%esp
  801ca0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca3:	e8 32 f5 ff ff       	call   8011da <fd2num>
  801ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cad:	83 c4 04             	add    $0x4,%esp
  801cb0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb3:	e8 22 f5 ff ff       	call   8011da <fd2num>
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc6:	eb 30                	jmp    801cf8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	56                   	push   %esi
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 2b ef ff ff       	call   800bfe <sys_page_unmap>
  801cd3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 1b ef ff ff       	call   800bfe <sys_page_unmap>
  801ce3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 0b ef ff ff       	call   800bfe <sys_page_unmap>
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cf8:	89 d0                	mov    %edx,%eax
  801cfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0a:	50                   	push   %eax
  801d0b:	ff 75 08             	pushl  0x8(%ebp)
  801d0e:	e8 3d f5 ff ff       	call   801250 <fd_lookup>
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 18                	js     801d32 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d20:	e8 c5 f4 ff ff       	call   8011ea <fd2data>
	return _pipeisclosed(fd, p);
  801d25:	89 c2                	mov    %eax,%edx
  801d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2a:	e8 21 fd ff ff       	call   801a50 <_pipeisclosed>
  801d2f:	83 c4 10             	add    $0x10,%esp
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d37:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d44:	68 6e 28 80 00       	push   $0x80286e
  801d49:	ff 75 0c             	pushl  0xc(%ebp)
  801d4c:	e8 25 ea ff ff       	call   800776 <strcpy>
	return 0;
}
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d64:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d69:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d6f:	eb 2d                	jmp    801d9e <devcons_write+0x46>
		m = n - tot;
  801d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d74:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d76:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d79:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d7e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d81:	83 ec 04             	sub    $0x4,%esp
  801d84:	53                   	push   %ebx
  801d85:	03 45 0c             	add    0xc(%ebp),%eax
  801d88:	50                   	push   %eax
  801d89:	57                   	push   %edi
  801d8a:	e8 79 eb ff ff       	call   800908 <memmove>
		sys_cputs(buf, m);
  801d8f:	83 c4 08             	add    $0x8,%esp
  801d92:	53                   	push   %ebx
  801d93:	57                   	push   %edi
  801d94:	e8 24 ed ff ff       	call   800abd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d99:	01 de                	add    %ebx,%esi
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801da3:	72 cc                	jb     801d71 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801db8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dbc:	74 2a                	je     801de8 <devcons_read+0x3b>
  801dbe:	eb 05                	jmp    801dc5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc0:	e8 95 ed ff ff       	call   800b5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dc5:	e8 11 ed ff ff       	call   800adb <sys_cgetc>
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	74 f2                	je     801dc0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 16                	js     801de8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dd2:	83 f8 04             	cmp    $0x4,%eax
  801dd5:	74 0c                	je     801de3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dda:	88 02                	mov    %al,(%edx)
	return 1;
  801ddc:	b8 01 00 00 00       	mov    $0x1,%eax
  801de1:	eb 05                	jmp    801de8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df6:	6a 01                	push   $0x1
  801df8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	e8 bc ec ff ff       	call   800abd <sys_cputs>
}
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <getchar>:

int
getchar(void)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e0c:	6a 01                	push   $0x1
  801e0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e11:	50                   	push   %eax
  801e12:	6a 00                	push   $0x0
  801e14:	e8 9d f6 ff ff       	call   8014b6 <read>
	if (r < 0)
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 0f                	js     801e2f <getchar+0x29>
		return r;
	if (r < 1)
  801e20:	85 c0                	test   %eax,%eax
  801e22:	7e 06                	jle    801e2a <getchar+0x24>
		return -E_EOF;
	return c;
  801e24:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e28:	eb 05                	jmp    801e2f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e2a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	ff 75 08             	pushl  0x8(%ebp)
  801e3e:	e8 0d f4 ff ff       	call   801250 <fd_lookup>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	78 11                	js     801e5b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e53:	39 10                	cmp    %edx,(%eax)
  801e55:	0f 94 c0             	sete   %al
  801e58:	0f b6 c0             	movzbl %al,%eax
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <opencons>:

int
opencons(void)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e66:	50                   	push   %eax
  801e67:	e8 95 f3 ff ff       	call   801201 <fd_alloc>
  801e6c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e6f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 3e                	js     801eb3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e75:	83 ec 04             	sub    $0x4,%esp
  801e78:	68 07 04 00 00       	push   $0x407
  801e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e80:	6a 00                	push   $0x0
  801e82:	e8 f2 ec ff ff       	call   800b79 <sys_page_alloc>
  801e87:	83 c4 10             	add    $0x10,%esp
		return r;
  801e8a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 23                	js     801eb3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e90:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	50                   	push   %eax
  801ea9:	e8 2c f3 ff ff       	call   8011da <fd2num>
  801eae:	89 c2                	mov    %eax,%edx
  801eb0:	83 c4 10             	add    $0x10,%esp
}
  801eb3:	89 d0                	mov    %edx,%eax
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	56                   	push   %esi
  801ebb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ebc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ebf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ec5:	e8 71 ec ff ff       	call   800b3b <sys_getenvid>
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	ff 75 0c             	pushl  0xc(%ebp)
  801ed0:	ff 75 08             	pushl  0x8(%ebp)
  801ed3:	56                   	push   %esi
  801ed4:	50                   	push   %eax
  801ed5:	68 7c 28 80 00       	push   $0x80287c
  801eda:	e8 12 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801edf:	83 c4 18             	add    $0x18,%esp
  801ee2:	53                   	push   %ebx
  801ee3:	ff 75 10             	pushl  0x10(%ebp)
  801ee6:	e8 b5 e2 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801eeb:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  801ef2:	e8 fa e2 ff ff       	call   8001f1 <cprintf>
  801ef7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801efa:	cc                   	int3   
  801efb:	eb fd                	jmp    801efa <_panic+0x43>

00801efd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	53                   	push   %ebx
  801f01:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f04:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f0b:	75 57                	jne    801f64 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801f0d:	e8 29 ec ff ff       	call   800b3b <sys_getenvid>
  801f12:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801f14:	83 ec 04             	sub    $0x4,%esp
  801f17:	6a 07                	push   $0x7
  801f19:	68 00 f0 bf ee       	push   $0xeebff000
  801f1e:	50                   	push   %eax
  801f1f:	e8 55 ec ff ff       	call   800b79 <sys_page_alloc>
		if (r) {
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	74 12                	je     801f3d <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801f2b:	50                   	push   %eax
  801f2c:	68 ba 26 80 00       	push   $0x8026ba
  801f31:	6a 25                	push   $0x25
  801f33:	68 9f 28 80 00       	push   $0x80289f
  801f38:	e8 7a ff ff ff       	call   801eb7 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801f3d:	83 ec 08             	sub    $0x8,%esp
  801f40:	68 71 1f 80 00       	push   $0x801f71
  801f45:	53                   	push   %ebx
  801f46:	e8 79 ed ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
		if (r) {
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	74 12                	je     801f64 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801f52:	50                   	push   %eax
  801f53:	68 b0 28 80 00       	push   $0x8028b0
  801f58:	6a 2b                	push   $0x2b
  801f5a:	68 9f 28 80 00       	push   $0x80289f
  801f5f:	e8 53 ff ff ff       	call   801eb7 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f64:	8b 45 08             	mov    0x8(%ebp),%eax
  801f67:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f71:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f72:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f77:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f79:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801f7c:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801f80:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801f85:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801f89:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801f8b:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801f8e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801f8f:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801f92:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801f93:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801f94:	c3                   	ret    

00801f95 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9b:	89 d0                	mov    %edx,%eax
  801f9d:	c1 e8 16             	shr    $0x16,%eax
  801fa0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fac:	f6 c1 01             	test   $0x1,%cl
  801faf:	74 1d                	je     801fce <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb1:	c1 ea 0c             	shr    $0xc,%edx
  801fb4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbb:	f6 c2 01             	test   $0x1,%dl
  801fbe:	74 0e                	je     801fce <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc0:	c1 ea 0c             	shr    $0xc,%edx
  801fc3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fca:	ef 
  801fcb:	0f b7 c0             	movzwl %ax,%eax
}
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
