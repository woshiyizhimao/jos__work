
obj/user/primes.debug：     文件格式 elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 a9 10 00 00       	call   8010f5 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 60 22 80 00       	push   $0x802260
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 3c 0e 00 00       	call   800ea6 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 6c 22 80 00       	push   $0x80226c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 75 22 80 00       	push   $0x802275
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 5c 10 00 00       	call   8010f5 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 dd 10 00 00       	call   80118d <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 e7 0d 00 00       	call   800ea6 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 6c 22 80 00       	push   $0x80226c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 75 22 80 00       	push   $0x802275
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 9d 10 00 00       	call   80118d <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 73 0a 00 00       	call   800b7b <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 9c 12 00 00       	call   8013e5 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 e7 09 00 00       	call   800b3a <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 10 0a 00 00       	call   800b7b <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 90 22 80 00       	push   $0x802290
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 2f 09 00 00       	call   800afd <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 d4 08 00 00       	call   800afd <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 37 1d 00 00       	call   801fd0 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 24 1e 00 00       	call   802100 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 b3 22 80 00 	movsbl 0x8022b3(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 89 03 00 00    	je     80070d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 1a 03 00 00    	ja     8006f2 <vprintfmt+0x38a>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 cb 22 80 00       	push   $0x8022cb
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 35 28 80 00       	push   $0x802835
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 c4 22 80 00       	mov    $0x8022c4,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 86 02 00 00       	call   800795 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 74                	jns    8006be <vprintfmt+0x356>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 2d                	push   $0x2d
  800650:	ff d6                	call   *%esi
				num = -(long long) num;
  800652:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800655:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800662:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800667:	eb 55                	jmp    8006be <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 83 fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800671:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800676:	eb 46                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 74 fc ff ff       	call   8002f4 <getuint>
			base=8;
  800680:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800685:	eb 37                	jmp    8006be <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 30                	push   $0x30
  80068d:	ff d6                	call   *%esi
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 78                	push   $0x78
  800695:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 50 04             	lea    0x4(%eax),%edx
  80069d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006af:	eb 0d                	jmp    8006be <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 3b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006b9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	50                   	push   %eax
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 70 fb ff ff       	call   800245 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006db:	e9 ae fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	51                   	push   %ecx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ed:	e9 9c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x39a>
  8006ff:	83 ef 01             	sub    $0x1,%edi
  800702:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800706:	75 f7                	jne    8006ff <vprintfmt+0x397>
  800708:	e9 81 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800728:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 26                	je     80075c <vsnprintf+0x47>
  800736:	85 d2                	test   %edx,%edx
  800738:	7e 22                	jle    80075c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	ff 75 14             	pushl  0x14(%ebp)
  80073d:	ff 75 10             	pushl  0x10(%ebp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	68 2e 03 80 00       	push   $0x80032e
  800749:	e8 1a fc ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800751:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	eb 05                	jmp    800761 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076c:	50                   	push   %eax
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 9a ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 03                	jmp    80078d <strlen+0x10>
		n++;
  80078a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800791:	75 f7                	jne    80078a <strlen+0xd>
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	eb 03                	jmp    8007a8 <strnlen+0x13>
		n++;
  8007a5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 c2                	cmp    %eax,%edx
  8007aa:	74 08                	je     8007b4 <strnlen+0x1f>
  8007ac:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b0:	75 f3                	jne    8007a5 <strnlen+0x10>
  8007b2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cf:	84 db                	test   %bl,%bl
  8007d1:	75 ef                	jne    8007c2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dd:	53                   	push   %ebx
  8007de:	e8 9a ff ff ff       	call   80077d <strlen>
  8007e3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	01 d8                	add    %ebx,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 c5 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	56                   	push   %esi
  8007fc:	53                   	push   %ebx
  8007fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800803:	89 f3                	mov    %esi,%ebx
  800805:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 0f                	jmp    80081b <strncpy+0x23>
		*dst++ = *src;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800815:	80 39 01             	cmpb   $0x1,(%ecx)
  800818:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	39 da                	cmp    %ebx,%edx
  80081d:	75 ed                	jne    80080c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081f:	89 f0                	mov    %esi,%eax
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 55 10             	mov    0x10(%ebp),%edx
  800833:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800835:	85 d2                	test   %edx,%edx
  800837:	74 21                	je     80085a <strlcpy+0x35>
  800839:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 09                	jmp    80084a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084a:	39 c2                	cmp    %eax,%edx
  80084c:	74 09                	je     800857 <strlcpy+0x32>
  80084e:	0f b6 19             	movzbl (%ecx),%ebx
  800851:	84 db                	test   %bl,%bl
  800853:	75 ec                	jne    800841 <strlcpy+0x1c>
  800855:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800857:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085a:	29 f0                	sub    %esi,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800869:	eb 06                	jmp    800871 <strcmp+0x11>
		p++, q++;
  80086b:	83 c1 01             	add    $0x1,%ecx
  80086e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800871:	0f b6 01             	movzbl (%ecx),%eax
  800874:	84 c0                	test   %al,%al
  800876:	74 04                	je     80087c <strcmp+0x1c>
  800878:	3a 02                	cmp    (%edx),%al
  80087a:	74 ef                	je     80086b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087c:	0f b6 c0             	movzbl %al,%eax
  80087f:	0f b6 12             	movzbl (%edx),%edx
  800882:	29 d0                	sub    %edx,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 c3                	mov    %eax,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800895:	eb 06                	jmp    80089d <strncmp+0x17>
		n--, p++, q++;
  800897:	83 c0 01             	add    $0x1,%eax
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	39 d8                	cmp    %ebx,%eax
  80089f:	74 15                	je     8008b6 <strncmp+0x30>
  8008a1:	0f b6 08             	movzbl (%eax),%ecx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	74 04                	je     8008ac <strncmp+0x26>
  8008a8:	3a 0a                	cmp    (%edx),%cl
  8008aa:	74 eb                	je     800897 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ac:	0f b6 00             	movzbl (%eax),%eax
  8008af:	0f b6 12             	movzbl (%edx),%edx
  8008b2:	29 d0                	sub    %edx,%eax
  8008b4:	eb 05                	jmp    8008bb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 07                	jmp    8008d1 <strchr+0x13>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0f                	je     8008dd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 03                	jmp    8008ee <strfind+0xf>
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 04                	je     8008f9 <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strfind+0xc>
			break;
	return (char *) s;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	57                   	push   %edi
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 7d 08             	mov    0x8(%ebp),%edi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 36                	je     800941 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 28                	jne    80093b <memset+0x40>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 23                	jne    80093b <memset+0x40>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092f:	89 d8                	mov    %ebx,%eax
  800931:	09 d0                	or     %edx,%eax
  800933:	c1 e9 02             	shr    $0x2,%ecx
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 35                	jae    80098f <memmove+0x47>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 d0                	cmp    %edx,%eax
  80095f:	73 2e                	jae    80098f <memmove+0x47>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 13                	jne    800983 <memmove+0x3b>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 0e                	jne    800983 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1d                	jmp    8009ac <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 0f                	jne    8009a7 <memmove+0x5f>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0a                	jne    8009a7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	fc                   	cld    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 05                	jmp    8009ac <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	pushl  0x10(%ebp)
  8009b6:	ff 75 0c             	pushl  0xc(%ebp)
  8009b9:	ff 75 08             	pushl  0x8(%ebp)
  8009bc:	e8 87 ff ff ff       	call   800948 <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 1a                	jmp    8009ef <memcmp+0x2c>
		if (*s1 != *s2)
  8009d5:	0f b6 08             	movzbl (%eax),%ecx
  8009d8:	0f b6 1a             	movzbl (%edx),%ebx
  8009db:	38 d9                	cmp    %bl,%cl
  8009dd:	74 0a                	je     8009e9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c1             	movzbl %cl,%eax
  8009e2:	0f b6 db             	movzbl %bl,%ebx
  8009e5:	29 d8                	sub    %ebx,%eax
  8009e7:	eb 0f                	jmp    8009f8 <memcmp+0x35>
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	39 f0                	cmp    %esi,%eax
  8009f1:	75 e2                	jne    8009d5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a03:	89 c1                	mov    %eax,%ecx
  800a05:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0c:	eb 0a                	jmp    800a18 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	39 da                	cmp    %ebx,%edx
  800a13:	74 07                	je     800a1c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	39 c8                	cmp    %ecx,%eax
  800a1a:	72 f2                	jb     800a0e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 03                	jmp    800a30 <strtol+0x11>
		s++;
  800a2d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f6                	je     800a2d <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f2                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x2a>
		s++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 11                	jmp    800a5a <strtol+0x3b>
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	75 08                	jne    800a5a <strtol+0x3b>
		s++, neg = 1;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a60:	75 15                	jne    800a77 <strtol+0x58>
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 10                	jne    800a77 <strtol+0x58>
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	75 7c                	jne    800ae9 <strtol+0xca>
		s += 2, base = 16;
  800a6d:	83 c1 02             	add    $0x2,%ecx
  800a70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a75:	eb 16                	jmp    800a8d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	75 12                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	75 08                	jne    800a8d <strtol+0x6e>
		s++, base = 8;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a92:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 11             	movzbl (%ecx),%edx
  800a98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	80 fb 09             	cmp    $0x9,%bl
  800aa0:	77 08                	ja     800aaa <strtol+0x8b>
			dig = *s - '0';
  800aa2:	0f be d2             	movsbl %dl,%edx
  800aa5:	83 ea 30             	sub    $0x30,%edx
  800aa8:	eb 22                	jmp    800acc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aad:	89 f3                	mov    %esi,%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 08                	ja     800abc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	83 ea 57             	sub    $0x57,%edx
  800aba:	eb 10                	jmp    800acc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 16                	ja     800adc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be d2             	movsbl %dl,%edx
  800ac9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acf:	7d 0b                	jge    800adc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ada:	eb b9                	jmp    800a95 <strtol+0x76>

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 0d                	je     800aef <strtol+0xd0>
		*endptr = (char *) s;
  800ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae5:	89 0e                	mov    %ecx,(%esi)
  800ae7:	eb 06                	jmp    800aef <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	74 98                	je     800a85 <strtol+0x66>
  800aed:	eb 9e                	jmp    800a8d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	f7 da                	neg    %edx
  800af3:	85 ff                	test   %edi,%edi
  800af5:	0f 45 c2             	cmovne %edx,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	89 c7                	mov    %eax,%edi
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7e 17                	jle    800b73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 bf 25 80 00       	push   $0x8025bf
  800b67:	6a 23                	push   $0x23
  800b69:	68 dc 25 80 00       	push   $0x8025dc
  800b6e:	e8 e5 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 bf 25 80 00       	push   $0x8025bf
  800be8:	6a 23                	push   $0x23
  800bea:	68 dc 25 80 00       	push   $0x8025dc
  800bef:	e8 64 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c16:	8b 75 18             	mov    0x18(%ebp),%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 bf 25 80 00       	push   $0x8025bf
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 dc 25 80 00       	push   $0x8025dc
  800c31:	e8 22 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 bf 25 80 00       	push   $0x8025bf
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 dc 25 80 00       	push   $0x8025dc
  800c73:	e8 e0 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 bf 25 80 00       	push   $0x8025bf
  800cae:	6a 23                	push   $0x23
  800cb0:	68 dc 25 80 00       	push   $0x8025dc
  800cb5:	e8 9e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 bf 25 80 00       	push   $0x8025bf
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 dc 25 80 00       	push   $0x8025dc
  800cf7:	e8 5c f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 bf 25 80 00       	push   $0x8025bf
  800d32:	6a 23                	push   $0x23
  800d34:	68 dc 25 80 00       	push   $0x8025dc
  800d39:	e8 1a f4 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 bf 25 80 00       	push   $0x8025bf
  800d96:	6a 23                	push   $0x23
  800d98:	68 dc 25 80 00       	push   $0x8025dc
  800d9d:	e8 b6 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db2:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800db4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800db8:	75 14                	jne    800dce <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	68 ec 25 80 00       	push   $0x8025ec
  800dc2:	6a 23                	push   $0x23
  800dc4:	68 af 26 80 00       	push   $0x8026af
  800dc9:	e8 8a f3 ff ff       	call   800158 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800dce:	89 d8                	mov    %ebx,%eax
  800dd0:	c1 e8 0c             	shr    $0xc,%eax
  800dd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dda:	f6 c4 08             	test   $0x8,%ah
  800ddd:	75 14                	jne    800df3 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 10 26 80 00       	push   $0x802610
  800de7:	6a 2d                	push   $0x2d
  800de9:	68 af 26 80 00       	push   $0x8026af
  800dee:	e8 65 f3 ff ff       	call   800158 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800df3:	e8 83 fd ff ff       	call   800b7b <sys_getenvid>
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	6a 07                	push   $0x7
  800dfd:	68 00 f0 7f 00       	push   $0x7ff000
  800e02:	50                   	push   %eax
  800e03:	e8 b1 fd ff ff       	call   800bb9 <sys_page_alloc>
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 12                	jns    800e21 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800e0f:	50                   	push   %eax
  800e10:	68 ba 26 80 00       	push   $0x8026ba
  800e15:	6a 3b                	push   $0x3b
  800e17:	68 af 26 80 00       	push   $0x8026af
  800e1c:	e8 37 f3 ff ff       	call   800158 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800e21:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 00 10 00 00       	push   $0x1000
  800e2f:	53                   	push   %ebx
  800e30:	68 00 f0 7f 00       	push   $0x7ff000
  800e35:	e8 0e fb ff ff       	call   800948 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800e3a:	e8 3c fd ff ff       	call   800b7b <sys_getenvid>
  800e3f:	89 c6                	mov    %eax,%esi
  800e41:	e8 35 fd ff ff       	call   800b7b <sys_getenvid>
  800e46:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4d:	53                   	push   %ebx
  800e4e:	56                   	push   %esi
  800e4f:	68 00 f0 7f 00       	push   $0x7ff000
  800e54:	50                   	push   %eax
  800e55:	e8 a2 fd ff ff       	call   800bfc <sys_page_map>
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	79 12                	jns    800e73 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800e61:	50                   	push   %eax
  800e62:	68 d3 26 80 00       	push   $0x8026d3
  800e67:	6a 48                	push   $0x48
  800e69:	68 af 26 80 00       	push   $0x8026af
  800e6e:	e8 e5 f2 ff ff       	call   800158 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800e73:	e8 03 fd ff ff       	call   800b7b <sys_getenvid>
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	68 00 f0 7f 00       	push   $0x7ff000
  800e80:	50                   	push   %eax
  800e81:	e8 b8 fd ff ff       	call   800c3e <sys_page_unmap>
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	79 12                	jns    800e9f <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800e8d:	50                   	push   %eax
  800e8e:	68 ea 26 80 00       	push   $0x8026ea
  800e93:	6a 4c                	push   $0x4c
  800e95:	68 af 26 80 00       	push   $0x8026af
  800e9a:	e8 b9 f2 ff ff       	call   800158 <_panic>
	}

	//panic("pgfault not implemented");
}
  800e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800eaf:	68 aa 0d 80 00       	push   $0x800daa
  800eb4:	e8 3e 10 00 00       	call   801ef7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebe:	cd 30                	int    $0x30
  800ec0:	89 c7                	mov    %eax,%edi
  800ec2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	79 15                	jns    800ee1 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800ecc:	50                   	push   %eax
  800ecd:	68 03 27 80 00       	push   $0x802703
  800ed2:	68 a1 00 00 00       	push   $0xa1
  800ed7:	68 af 26 80 00       	push   $0x8026af
  800edc:	e8 77 f2 ff ff       	call   800158 <_panic>
  800ee1:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	75 21                	jne    800f0b <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800eea:	e8 8c fc ff ff       	call   800b7b <sys_getenvid>
  800eef:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	e9 c8 01 00 00       	jmp    8010d3 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	c1 e8 16             	shr    $0x16,%eax
  800f10:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f17:	a8 01                	test   $0x1,%al
  800f19:	0f 84 23 01 00 00    	je     801042 <fork+0x19c>
  800f1f:	89 d8                	mov    %ebx,%eax
  800f21:	c1 e8 0c             	shr    $0xc,%eax
  800f24:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2b:	f6 c2 01             	test   $0x1,%dl
  800f2e:	0f 84 0e 01 00 00    	je     801042 <fork+0x19c>
  800f34:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3b:	f6 c2 04             	test   $0x4,%dl
  800f3e:	0f 84 fe 00 00 00    	je     801042 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800f44:	89 c6                	mov    %eax,%esi
  800f46:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800f49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f50:	f6 c6 04             	test   $0x4,%dh
  800f53:	74 3f                	je     800f94 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800f55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f64:	50                   	push   %eax
  800f65:	56                   	push   %esi
  800f66:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	e8 8b fc ff ff       	call   800bfc <sys_page_map>
  800f71:	83 c4 20             	add    $0x20,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	0f 89 c6 00 00 00    	jns    801042 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	50                   	push   %eax
  800f80:	57                   	push   %edi
  800f81:	6a 00                	push   $0x0
  800f83:	68 40 26 80 00       	push   $0x802640
  800f88:	6a 6c                	push   $0x6c
  800f8a:	68 af 26 80 00       	push   $0x8026af
  800f8f:	e8 c4 f1 ff ff       	call   800158 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9b:	f6 c2 02             	test   $0x2,%dl
  800f9e:	75 0c                	jne    800fac <fork+0x106>
  800fa0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa7:	f6 c4 08             	test   $0x8,%ah
  800faa:	74 66                	je     801012 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	68 05 08 00 00       	push   $0x805
  800fb4:	56                   	push   %esi
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	56                   	push   %esi
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 3c fc ff ff       	call   800bfc <sys_page_map>
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	79 18                	jns    800fdf <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	50                   	push   %eax
  800fcb:	57                   	push   %edi
  800fcc:	6a 00                	push   $0x0
  800fce:	68 40 26 80 00       	push   $0x802640
  800fd3:	6a 74                	push   $0x74
  800fd5:	68 af 26 80 00       	push   $0x8026af
  800fda:	e8 79 f1 ff ff       	call   800158 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	68 05 08 00 00       	push   $0x805
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	56                   	push   %esi
  800feb:	6a 00                	push   $0x0
  800fed:	e8 0a fc ff ff       	call   800bfc <sys_page_map>
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 49                	jns    801042 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	50                   	push   %eax
  800ffd:	6a 00                	push   $0x0
  800fff:	6a 00                	push   $0x0
  801001:	68 40 26 80 00       	push   $0x802640
  801006:	6a 77                	push   $0x77
  801008:	68 af 26 80 00       	push   $0x8026af
  80100d:	e8 46 f1 ff ff       	call   800158 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	6a 05                	push   $0x5
  801017:	56                   	push   %esi
  801018:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101b:	56                   	push   %esi
  80101c:	6a 00                	push   $0x0
  80101e:	e8 d9 fb ff ff       	call   800bfc <sys_page_map>
  801023:	83 c4 20             	add    $0x20,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	79 18                	jns    801042 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	50                   	push   %eax
  80102e:	57                   	push   %edi
  80102f:	6a 00                	push   $0x0
  801031:	68 40 26 80 00       	push   $0x802640
  801036:	6a 7d                	push   $0x7d
  801038:	68 af 26 80 00       	push   $0x8026af
  80103d:	e8 16 f1 ff ff       	call   800158 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801042:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801048:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80104e:	0f 85 b7 fe ff ff    	jne    800f0b <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801054:	83 ec 04             	sub    $0x4,%esp
  801057:	6a 07                	push   $0x7
  801059:	68 00 f0 bf ee       	push   $0xeebff000
  80105e:	57                   	push   %edi
  80105f:	e8 55 fb ff ff       	call   800bb9 <sys_page_alloc>
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	79 15                	jns    801080 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  80106b:	50                   	push   %eax
  80106c:	68 6c 26 80 00       	push   $0x80266c
  801071:	68 b4 00 00 00       	push   $0xb4
  801076:	68 af 26 80 00       	push   $0x8026af
  80107b:	e8 d8 f0 ff ff       	call   800158 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	68 6b 1f 80 00       	push   $0x801f6b
  801088:	57                   	push   %edi
  801089:	e8 76 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 15                	jns    8010aa <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801095:	50                   	push   %eax
  801096:	68 19 27 80 00       	push   $0x802719
  80109b:	68 ba 00 00 00       	push   $0xba
  8010a0:	68 af 26 80 00       	push   $0x8026af
  8010a5:	e8 ae f0 ff ff       	call   800158 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	6a 02                	push   $0x2
  8010af:	57                   	push   %edi
  8010b0:	e8 cb fb ff ff       	call   800c80 <sys_env_set_status>
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 15                	jns    8010d1 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  8010bc:	50                   	push   %eax
  8010bd:	68 36 27 80 00       	push   $0x802736
  8010c2:	68 bf 00 00 00       	push   $0xbf
  8010c7:	68 af 26 80 00       	push   $0x8026af
  8010cc:	e8 87 f0 ff ff       	call   800158 <_panic>
	}
	return eid;
  8010d1:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  8010d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <sfork>:

// Challenge!
int
sfork(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e1:	68 53 27 80 00       	push   $0x802753
  8010e6:	68 ca 00 00 00       	push   $0xca
  8010eb:	68 af 26 80 00       	push   $0x8026af
  8010f0:	e8 63 f0 ff ff       	call   800158 <_panic>

008010f5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
  8010fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801100:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801103:	85 c0                	test   %eax,%eax
  801105:	74 3e                	je     801145 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801107:	83 ec 0c             	sub    $0xc,%esp
  80110a:	50                   	push   %eax
  80110b:	e8 59 fc ff ff       	call   800d69 <sys_ipc_recv>
  801110:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 f6                	test   %esi,%esi
  801117:	74 13                	je     80112c <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
  80111e:	85 d2                	test   %edx,%edx
  801120:	75 08                	jne    80112a <ipc_recv+0x35>
  801122:	a1 04 40 80 00       	mov    0x804004,%eax
  801127:	8b 40 74             	mov    0x74(%eax),%eax
  80112a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80112c:	85 db                	test   %ebx,%ebx
  80112e:	74 48                	je     801178 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801130:	b8 00 00 00 00       	mov    $0x0,%eax
  801135:	85 d2                	test   %edx,%edx
  801137:	75 08                	jne    801141 <ipc_recv+0x4c>
  801139:	a1 04 40 80 00       	mov    0x804004,%eax
  80113e:	8b 40 78             	mov    0x78(%eax),%eax
  801141:	89 03                	mov    %eax,(%ebx)
  801143:	eb 33                	jmp    801178 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	68 00 00 c0 ee       	push   $0xeec00000
  80114d:	e8 17 fc ff ff       	call   800d69 <sys_ipc_recv>
  801152:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 f6                	test   %esi,%esi
  801159:	74 13                	je     80116e <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
  801160:	85 d2                	test   %edx,%edx
  801162:	75 08                	jne    80116c <ipc_recv+0x77>
  801164:	a1 04 40 80 00       	mov    0x804004,%eax
  801169:	8b 40 74             	mov    0x74(%eax),%eax
  80116c:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80116e:	85 db                	test   %ebx,%ebx
  801170:	74 06                	je     801178 <ipc_recv+0x83>
			*perm_store = 0;
  801172:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801178:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  80117a:	85 d2                	test   %edx,%edx
  80117c:	75 08                	jne    801186 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  80117e:	a1 04 40 80 00       	mov    0x804004,%eax
  801183:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	8b 7d 08             	mov    0x8(%ebp),%edi
  801199:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80119f:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  8011a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011a6:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011a9:	eb 1c                	jmp    8011c7 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  8011ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ae:	74 12                	je     8011c2 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  8011b0:	50                   	push   %eax
  8011b1:	68 69 27 80 00       	push   $0x802769
  8011b6:	6a 4f                	push   $0x4f
  8011b8:	68 84 27 80 00       	push   $0x802784
  8011bd:	e8 96 ef ff ff       	call   800158 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  8011c2:	e8 d3 f9 ff ff       	call   800b9a <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011c7:	ff 75 14             	pushl  0x14(%ebp)
  8011ca:	53                   	push   %ebx
  8011cb:	56                   	push   %esi
  8011cc:	57                   	push   %edi
  8011cd:	e8 74 fb ff ff       	call   800d46 <sys_ipc_try_send>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 d2                	js     8011ab <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011ec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011ef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f5:	8b 52 50             	mov    0x50(%edx),%edx
  8011f8:	39 ca                	cmp    %ecx,%edx
  8011fa:	75 0d                	jne    801209 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011fc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801204:	8b 40 48             	mov    0x48(%eax),%eax
  801207:	eb 0f                	jmp    801218 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801209:	83 c0 01             	add    $0x1,%eax
  80120c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801211:	75 d9                	jne    8011ec <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
  801220:	05 00 00 00 30       	add    $0x30000000,%eax
  801225:	c1 e8 0c             	shr    $0xc,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	05 00 00 00 30       	add    $0x30000000,%eax
  801235:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801247:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 ea 16             	shr    $0x16,%edx
  801251:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801258:	f6 c2 01             	test   $0x1,%dl
  80125b:	74 11                	je     80126e <fd_alloc+0x2d>
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 0c             	shr    $0xc,%edx
  801262:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	75 09                	jne    801277 <fd_alloc+0x36>
			*fd_store = fd;
  80126e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	eb 17                	jmp    80128e <fd_alloc+0x4d>
  801277:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801281:	75 c9                	jne    80124c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801283:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801289:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801296:	83 f8 1f             	cmp    $0x1f,%eax
  801299:	77 36                	ja     8012d1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129b:	c1 e0 0c             	shl    $0xc,%eax
  80129e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	c1 ea 16             	shr    $0x16,%edx
  8012a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012af:	f6 c2 01             	test   $0x1,%dl
  8012b2:	74 24                	je     8012d8 <fd_lookup+0x48>
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	c1 ea 0c             	shr    $0xc,%edx
  8012b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c0:	f6 c2 01             	test   $0x1,%dl
  8012c3:	74 1a                	je     8012df <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c8:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cf:	eb 13                	jmp    8012e4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d6:	eb 0c                	jmp    8012e4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dd:	eb 05                	jmp    8012e4 <fd_lookup+0x54>
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ef:	ba 0c 28 80 00       	mov    $0x80280c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f4:	eb 13                	jmp    801309 <dev_lookup+0x23>
  8012f6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f9:	39 08                	cmp    %ecx,(%eax)
  8012fb:	75 0c                	jne    801309 <dev_lookup+0x23>
			*dev = devtab[i];
  8012fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801300:	89 01                	mov    %eax,(%ecx)
			return 0;
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	eb 2e                	jmp    801337 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801309:	8b 02                	mov    (%edx),%eax
  80130b:	85 c0                	test   %eax,%eax
  80130d:	75 e7                	jne    8012f6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130f:	a1 04 40 80 00       	mov    0x804004,%eax
  801314:	8b 40 48             	mov    0x48(%eax),%eax
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	51                   	push   %ecx
  80131b:	50                   	push   %eax
  80131c:	68 90 27 80 00       	push   $0x802790
  801321:	e8 0b ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  801326:	8b 45 0c             	mov    0xc(%ebp),%eax
  801329:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801337:	c9                   	leave  
  801338:	c3                   	ret    

00801339 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 10             	sub    $0x10,%esp
  801341:	8b 75 08             	mov    0x8(%ebp),%esi
  801344:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801351:	c1 e8 0c             	shr    $0xc,%eax
  801354:	50                   	push   %eax
  801355:	e8 36 ff ff ff       	call   801290 <fd_lookup>
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 05                	js     801366 <fd_close+0x2d>
	    || fd != fd2)
  801361:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801364:	74 0c                	je     801372 <fd_close+0x39>
		return (must_exist ? r : 0);
  801366:	84 db                	test   %bl,%bl
  801368:	ba 00 00 00 00       	mov    $0x0,%edx
  80136d:	0f 44 c2             	cmove  %edx,%eax
  801370:	eb 41                	jmp    8013b3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	ff 36                	pushl  (%esi)
  80137b:	e8 66 ff ff ff       	call   8012e6 <dev_lookup>
  801380:	89 c3                	mov    %eax,%ebx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 1a                	js     8013a3 <fd_close+0x6a>
		if (dev->dev_close)
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80138f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801394:	85 c0                	test   %eax,%eax
  801396:	74 0b                	je     8013a3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	56                   	push   %esi
  80139c:	ff d0                	call   *%eax
  80139e:	89 c3                	mov    %eax,%ebx
  8013a0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	56                   	push   %esi
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 90 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	89 d8                	mov    %ebx,%eax
}
  8013b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b6:	5b                   	pop    %ebx
  8013b7:	5e                   	pop    %esi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	ff 75 08             	pushl  0x8(%ebp)
  8013c7:	e8 c4 fe ff ff       	call   801290 <fd_lookup>
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	78 10                	js     8013e3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	6a 01                	push   $0x1
  8013d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013db:	e8 59 ff ff ff       	call   801339 <fd_close>
  8013e0:	83 c4 10             	add    $0x10,%esp
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <close_all>:

void
close_all(void)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	53                   	push   %ebx
  8013f5:	e8 c0 ff ff ff       	call   8013ba <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fa:	83 c3 01             	add    $0x1,%ebx
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	83 fb 20             	cmp    $0x20,%ebx
  801403:	75 ec                	jne    8013f1 <close_all+0xc>
		close(i);
}
  801405:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	57                   	push   %edi
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	83 ec 2c             	sub    $0x2c,%esp
  801413:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801416:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	ff 75 08             	pushl  0x8(%ebp)
  80141d:	e8 6e fe ff ff       	call   801290 <fd_lookup>
  801422:	83 c4 08             	add    $0x8,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	0f 88 c1 00 00 00    	js     8014ee <dup+0xe4>
		return r;
	close(newfdnum);
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	56                   	push   %esi
  801431:	e8 84 ff ff ff       	call   8013ba <close>

	newfd = INDEX2FD(newfdnum);
  801436:	89 f3                	mov    %esi,%ebx
  801438:	c1 e3 0c             	shl    $0xc,%ebx
  80143b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801441:	83 c4 04             	add    $0x4,%esp
  801444:	ff 75 e4             	pushl  -0x1c(%ebp)
  801447:	e8 de fd ff ff       	call   80122a <fd2data>
  80144c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80144e:	89 1c 24             	mov    %ebx,(%esp)
  801451:	e8 d4 fd ff ff       	call   80122a <fd2data>
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145c:	89 f8                	mov    %edi,%eax
  80145e:	c1 e8 16             	shr    $0x16,%eax
  801461:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801468:	a8 01                	test   $0x1,%al
  80146a:	74 37                	je     8014a3 <dup+0x99>
  80146c:	89 f8                	mov    %edi,%eax
  80146e:	c1 e8 0c             	shr    $0xc,%eax
  801471:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801478:	f6 c2 01             	test   $0x1,%dl
  80147b:	74 26                	je     8014a3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801484:	83 ec 0c             	sub    $0xc,%esp
  801487:	25 07 0e 00 00       	and    $0xe07,%eax
  80148c:	50                   	push   %eax
  80148d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801490:	6a 00                	push   $0x0
  801492:	57                   	push   %edi
  801493:	6a 00                	push   $0x0
  801495:	e8 62 f7 ff ff       	call   800bfc <sys_page_map>
  80149a:	89 c7                	mov    %eax,%edi
  80149c:	83 c4 20             	add    $0x20,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 2e                	js     8014d1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014a6:	89 d0                	mov    %edx,%eax
  8014a8:	c1 e8 0c             	shr    $0xc,%eax
  8014ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ba:	50                   	push   %eax
  8014bb:	53                   	push   %ebx
  8014bc:	6a 00                	push   $0x0
  8014be:	52                   	push   %edx
  8014bf:	6a 00                	push   $0x0
  8014c1:	e8 36 f7 ff ff       	call   800bfc <sys_page_map>
  8014c6:	89 c7                	mov    %eax,%edi
  8014c8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014cb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014cd:	85 ff                	test   %edi,%edi
  8014cf:	79 1d                	jns    8014ee <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	6a 00                	push   $0x0
  8014d7:	e8 62 f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e2:	6a 00                	push   $0x0
  8014e4:	e8 55 f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	89 f8                	mov    %edi,%eax
}
  8014ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5f                   	pop    %edi
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 14             	sub    $0x14,%esp
  8014fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801500:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	53                   	push   %ebx
  801505:	e8 86 fd ff ff       	call   801290 <fd_lookup>
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 6d                	js     801580 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	ff 30                	pushl  (%eax)
  80151f:	e8 c2 fd ff ff       	call   8012e6 <dev_lookup>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 4c                	js     801577 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152e:	8b 42 08             	mov    0x8(%edx),%eax
  801531:	83 e0 03             	and    $0x3,%eax
  801534:	83 f8 01             	cmp    $0x1,%eax
  801537:	75 21                	jne    80155a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801539:	a1 04 40 80 00       	mov    0x804004,%eax
  80153e:	8b 40 48             	mov    0x48(%eax),%eax
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	53                   	push   %ebx
  801545:	50                   	push   %eax
  801546:	68 d1 27 80 00       	push   $0x8027d1
  80154b:	e8 e1 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801558:	eb 26                	jmp    801580 <read+0x8a>
	}
	if (!dev->dev_read)
  80155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155d:	8b 40 08             	mov    0x8(%eax),%eax
  801560:	85 c0                	test   %eax,%eax
  801562:	74 17                	je     80157b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	ff 75 10             	pushl  0x10(%ebp)
  80156a:	ff 75 0c             	pushl  0xc(%ebp)
  80156d:	52                   	push   %edx
  80156e:	ff d0                	call   *%eax
  801570:	89 c2                	mov    %eax,%edx
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	eb 09                	jmp    801580 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	89 c2                	mov    %eax,%edx
  801579:	eb 05                	jmp    801580 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801580:	89 d0                	mov    %edx,%eax
  801582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	8b 7d 08             	mov    0x8(%ebp),%edi
  801593:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801596:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159b:	eb 21                	jmp    8015be <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	89 f0                	mov    %esi,%eax
  8015a2:	29 d8                	sub    %ebx,%eax
  8015a4:	50                   	push   %eax
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	03 45 0c             	add    0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	57                   	push   %edi
  8015ac:	e8 45 ff ff ff       	call   8014f6 <read>
		if (m < 0)
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 10                	js     8015c8 <readn+0x41>
			return m;
		if (m == 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 0a                	je     8015c6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bc:	01 c3                	add    %eax,%ebx
  8015be:	39 f3                	cmp    %esi,%ebx
  8015c0:	72 db                	jb     80159d <readn+0x16>
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	eb 02                	jmp    8015c8 <readn+0x41>
  8015c6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 14             	sub    $0x14,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	53                   	push   %ebx
  8015df:	e8 ac fc ff ff       	call   801290 <fd_lookup>
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 68                	js     801655 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f7:	ff 30                	pushl  (%eax)
  8015f9:	e8 e8 fc ff ff       	call   8012e6 <dev_lookup>
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 47                	js     80164c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801608:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160c:	75 21                	jne    80162f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80160e:	a1 04 40 80 00       	mov    0x804004,%eax
  801613:	8b 40 48             	mov    0x48(%eax),%eax
  801616:	83 ec 04             	sub    $0x4,%esp
  801619:	53                   	push   %ebx
  80161a:	50                   	push   %eax
  80161b:	68 ed 27 80 00       	push   $0x8027ed
  801620:	e8 0c ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162d:	eb 26                	jmp    801655 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80162f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801632:	8b 52 0c             	mov    0xc(%edx),%edx
  801635:	85 d2                	test   %edx,%edx
  801637:	74 17                	je     801650 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	ff 75 10             	pushl  0x10(%ebp)
  80163f:	ff 75 0c             	pushl  0xc(%ebp)
  801642:	50                   	push   %eax
  801643:	ff d2                	call   *%edx
  801645:	89 c2                	mov    %eax,%edx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 09                	jmp    801655 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	eb 05                	jmp    801655 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801650:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801655:	89 d0                	mov    %edx,%eax
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <seek>:

int
seek(int fdnum, off_t offset)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801662:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	e8 22 fc ff ff       	call   801290 <fd_lookup>
  80166e:	83 c4 08             	add    $0x8,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 0e                	js     801683 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801675:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801678:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 14             	sub    $0x14,%esp
  80168c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	53                   	push   %ebx
  801694:	e8 f7 fb ff ff       	call   801290 <fd_lookup>
  801699:	83 c4 08             	add    $0x8,%esp
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 65                	js     801707 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 33 fc ff ff       	call   8012e6 <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 44                	js     8016fe <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c1:	75 21                	jne    8016e4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c8:	8b 40 48             	mov    0x48(%eax),%eax
  8016cb:	83 ec 04             	sub    $0x4,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	50                   	push   %eax
  8016d0:	68 b0 27 80 00       	push   $0x8027b0
  8016d5:	e8 57 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e2:	eb 23                	jmp    801707 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 14                	je     801702 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	50                   	push   %eax
  8016f5:	ff d2                	call   *%edx
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	eb 09                	jmp    801707 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	eb 05                	jmp    801707 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801702:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801707:	89 d0                	mov    %edx,%eax
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 14             	sub    $0x14,%esp
  801715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801718:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	ff 75 08             	pushl  0x8(%ebp)
  80171f:	e8 6c fb ff ff       	call   801290 <fd_lookup>
  801724:	83 c4 08             	add    $0x8,%esp
  801727:	89 c2                	mov    %eax,%edx
  801729:	85 c0                	test   %eax,%eax
  80172b:	78 58                	js     801785 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801737:	ff 30                	pushl  (%eax)
  801739:	e8 a8 fb ff ff       	call   8012e6 <dev_lookup>
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	78 37                	js     80177c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801748:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80174c:	74 32                	je     801780 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80174e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801751:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801758:	00 00 00 
	stat->st_isdir = 0;
  80175b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801762:	00 00 00 
	stat->st_dev = dev;
  801765:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	53                   	push   %ebx
  80176f:	ff 75 f0             	pushl  -0x10(%ebp)
  801772:	ff 50 14             	call   *0x14(%eax)
  801775:	89 c2                	mov    %eax,%edx
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	eb 09                	jmp    801785 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	eb 05                	jmp    801785 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801780:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801785:	89 d0                	mov    %edx,%eax
  801787:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	6a 00                	push   $0x0
  801796:	ff 75 08             	pushl  0x8(%ebp)
  801799:	e8 d6 01 00 00       	call   801974 <open>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 1b                	js     8017c2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	50                   	push   %eax
  8017ae:	e8 5b ff ff ff       	call   80170e <fstat>
  8017b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017b5:	89 1c 24             	mov    %ebx,(%esp)
  8017b8:	e8 fd fb ff ff       	call   8013ba <close>
	return r;
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	89 f0                	mov    %esi,%eax
}
  8017c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5e                   	pop    %esi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	89 c6                	mov    %eax,%esi
  8017d0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017d2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d9:	75 12                	jne    8017ed <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017db:	83 ec 0c             	sub    $0xc,%esp
  8017de:	6a 01                	push   $0x1
  8017e0:	e8 fc f9 ff ff       	call   8011e1 <ipc_find_env>
  8017e5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ea:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017ed:	6a 07                	push   $0x7
  8017ef:	68 00 50 80 00       	push   $0x805000
  8017f4:	56                   	push   %esi
  8017f5:	ff 35 00 40 80 00    	pushl  0x804000
  8017fb:	e8 8d f9 ff ff       	call   80118d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801800:	83 c4 0c             	add    $0xc,%esp
  801803:	6a 00                	push   $0x0
  801805:	53                   	push   %ebx
  801806:	6a 00                	push   $0x0
  801808:	e8 e8 f8 ff ff       	call   8010f5 <ipc_recv>
}
  80180d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	8b 40 0c             	mov    0xc(%eax),%eax
  801820:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801825:	8b 45 0c             	mov    0xc(%ebp),%eax
  801828:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 02 00 00 00       	mov    $0x2,%eax
  801837:	e8 8d ff ff ff       	call   8017c9 <fsipc>
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 06 00 00 00       	mov    $0x6,%eax
  801859:	e8 6b ff ff ff       	call   8017c9 <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 04             	sub    $0x4,%esp
  801867:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 05 00 00 00       	mov    $0x5,%eax
  80187f:	e8 45 ff ff ff       	call   8017c9 <fsipc>
  801884:	85 c0                	test   %eax,%eax
  801886:	78 2c                	js     8018b4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	68 00 50 80 00       	push   $0x805000
  801890:	53                   	push   %ebx
  801891:	e8 20 ef ff ff       	call   8007b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801896:	a1 80 50 80 00       	mov    0x805080,%eax
  80189b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ce:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8018d3:	50                   	push   %eax
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	68 08 50 80 00       	push   $0x805008
  8018dc:	e8 67 f0 ff ff       	call   800948 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018eb:	e8 d9 fe ff ff       	call   8017c9 <fsipc>
	//panic("devfile_write not implemented");
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801900:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801905:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 03 00 00 00       	mov    $0x3,%eax
  801915:	e8 af fe ff ff       	call   8017c9 <fsipc>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 4b                	js     80196b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801920:	39 c6                	cmp    %eax,%esi
  801922:	73 16                	jae    80193a <devfile_read+0x48>
  801924:	68 1c 28 80 00       	push   $0x80281c
  801929:	68 23 28 80 00       	push   $0x802823
  80192e:	6a 7c                	push   $0x7c
  801930:	68 38 28 80 00       	push   $0x802838
  801935:	e8 1e e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80193a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80193f:	7e 16                	jle    801957 <devfile_read+0x65>
  801941:	68 43 28 80 00       	push   $0x802843
  801946:	68 23 28 80 00       	push   $0x802823
  80194b:	6a 7d                	push   $0x7d
  80194d:	68 38 28 80 00       	push   $0x802838
  801952:	e8 01 e8 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	50                   	push   %eax
  80195b:	68 00 50 80 00       	push   $0x805000
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	e8 e0 ef ff ff       	call   800948 <memmove>
	return r;
  801968:	83 c4 10             	add    $0x10,%esp
}
  80196b:	89 d8                	mov    %ebx,%eax
  80196d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	53                   	push   %ebx
  801978:	83 ec 20             	sub    $0x20,%esp
  80197b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80197e:	53                   	push   %ebx
  80197f:	e8 f9 ed ff ff       	call   80077d <strlen>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80198c:	7f 67                	jg     8019f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801994:	50                   	push   %eax
  801995:	e8 a7 f8 ff ff       	call   801241 <fd_alloc>
  80199a:	83 c4 10             	add    $0x10,%esp
		return r;
  80199d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 57                	js     8019fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	53                   	push   %ebx
  8019a7:	68 00 50 80 00       	push   $0x805000
  8019ac:	e8 05 ee ff ff       	call   8007b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c1:	e8 03 fe ff ff       	call   8017c9 <fsipc>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	79 14                	jns    8019e3 <open+0x6f>
		fd_close(fd, 0);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	6a 00                	push   $0x0
  8019d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d7:	e8 5d f9 ff ff       	call   801339 <fd_close>
		return r;
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	89 da                	mov    %ebx,%edx
  8019e1:	eb 17                	jmp    8019fa <open+0x86>
	}

	return fd2num(fd);
  8019e3:	83 ec 0c             	sub    $0xc,%esp
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	e8 2c f8 ff ff       	call   80121a <fd2num>
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	eb 05                	jmp    8019fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019fa:	89 d0                	mov    %edx,%eax
  8019fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a07:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0c:	b8 08 00 00 00       	mov    $0x8,%eax
  801a11:	e8 b3 fd ff ff       	call   8017c9 <fsipc>
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	e8 ff f7 ff ff       	call   80122a <fd2data>
  801a2b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	68 4f 28 80 00       	push   $0x80284f
  801a35:	53                   	push   %ebx
  801a36:	e8 7b ed ff ff       	call   8007b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a3b:	8b 46 04             	mov    0x4(%esi),%eax
  801a3e:	2b 06                	sub    (%esi),%eax
  801a40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a4d:	00 00 00 
	stat->st_dev = &devpipe;
  801a50:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a57:	30 80 00 
	return 0;
}
  801a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a70:	53                   	push   %ebx
  801a71:	6a 00                	push   $0x0
  801a73:	e8 c6 f1 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a78:	89 1c 24             	mov    %ebx,(%esp)
  801a7b:	e8 aa f7 ff ff       	call   80122a <fd2data>
  801a80:	83 c4 08             	add    $0x8,%esp
  801a83:	50                   	push   %eax
  801a84:	6a 00                	push   $0x0
  801a86:	e8 b3 f1 ff ff       	call   800c3e <sys_page_unmap>
}
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 1c             	sub    $0x1c,%esp
  801a99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a9c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	ff 75 e0             	pushl  -0x20(%ebp)
  801aac:	e8 de 04 00 00       	call   801f8f <pageref>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	89 3c 24             	mov    %edi,(%esp)
  801ab6:	e8 d4 04 00 00       	call   801f8f <pageref>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	39 c3                	cmp    %eax,%ebx
  801ac0:	0f 94 c1             	sete   %cl
  801ac3:	0f b6 c9             	movzbl %cl,%ecx
  801ac6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ac9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801acf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad2:	39 ce                	cmp    %ecx,%esi
  801ad4:	74 1b                	je     801af1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ad6:	39 c3                	cmp    %eax,%ebx
  801ad8:	75 c4                	jne    801a9e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ada:	8b 42 58             	mov    0x58(%edx),%eax
  801add:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae0:	50                   	push   %eax
  801ae1:	56                   	push   %esi
  801ae2:	68 56 28 80 00       	push   $0x802856
  801ae7:	e8 45 e7 ff ff       	call   800231 <cprintf>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	eb ad                	jmp    801a9e <_pipeisclosed+0xe>
	}
}
  801af1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5f                   	pop    %edi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 28             	sub    $0x28,%esp
  801b05:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b08:	56                   	push   %esi
  801b09:	e8 1c f7 ff ff       	call   80122a <fd2data>
  801b0e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	bf 00 00 00 00       	mov    $0x0,%edi
  801b18:	eb 4b                	jmp    801b65 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1a:	89 da                	mov    %ebx,%edx
  801b1c:	89 f0                	mov    %esi,%eax
  801b1e:	e8 6d ff ff ff       	call   801a90 <_pipeisclosed>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	75 48                	jne    801b6f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b27:	e8 6e f0 ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b2f:	8b 0b                	mov    (%ebx),%ecx
  801b31:	8d 51 20             	lea    0x20(%ecx),%edx
  801b34:	39 d0                	cmp    %edx,%eax
  801b36:	73 e2                	jae    801b1a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b3f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	c1 fa 1f             	sar    $0x1f,%edx
  801b47:	89 d1                	mov    %edx,%ecx
  801b49:	c1 e9 1b             	shr    $0x1b,%ecx
  801b4c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b4f:	83 e2 1f             	and    $0x1f,%edx
  801b52:	29 ca                	sub    %ecx,%edx
  801b54:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b58:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5c:	83 c0 01             	add    $0x1,%eax
  801b5f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c7 01             	add    $0x1,%edi
  801b65:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b68:	75 c2                	jne    801b2c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	eb 05                	jmp    801b74 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5e                   	pop    %esi
  801b79:	5f                   	pop    %edi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	83 ec 18             	sub    $0x18,%esp
  801b85:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b88:	57                   	push   %edi
  801b89:	e8 9c f6 ff ff       	call   80122a <fd2data>
  801b8e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b98:	eb 3d                	jmp    801bd7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9a:	85 db                	test   %ebx,%ebx
  801b9c:	74 04                	je     801ba2 <devpipe_read+0x26>
				return i;
  801b9e:	89 d8                	mov    %ebx,%eax
  801ba0:	eb 44                	jmp    801be6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba2:	89 f2                	mov    %esi,%edx
  801ba4:	89 f8                	mov    %edi,%eax
  801ba6:	e8 e5 fe ff ff       	call   801a90 <_pipeisclosed>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	75 32                	jne    801be1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801baf:	e8 e6 ef ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb4:	8b 06                	mov    (%esi),%eax
  801bb6:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb9:	74 df                	je     801b9a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bbb:	99                   	cltd   
  801bbc:	c1 ea 1b             	shr    $0x1b,%edx
  801bbf:	01 d0                	add    %edx,%eax
  801bc1:	83 e0 1f             	and    $0x1f,%eax
  801bc4:	29 d0                	sub    %edx,%eax
  801bc6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd4:	83 c3 01             	add    $0x1,%ebx
  801bd7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bda:	75 d8                	jne    801bb4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdf:	eb 05                	jmp    801be6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	e8 42 f6 ff ff       	call   801241 <fd_alloc>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	89 c2                	mov    %eax,%edx
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 2c 01 00 00    	js     801d38 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 9b ef ff ff       	call   800bb9 <sys_page_alloc>
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 c2                	mov    %eax,%edx
  801c23:	85 c0                	test   %eax,%eax
  801c25:	0f 88 0d 01 00 00    	js     801d38 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c2b:	83 ec 0c             	sub    $0xc,%esp
  801c2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c31:	50                   	push   %eax
  801c32:	e8 0a f6 ff ff       	call   801241 <fd_alloc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	0f 88 e2 00 00 00    	js     801d26 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	83 ec 04             	sub    $0x4,%esp
  801c47:	68 07 04 00 00       	push   $0x407
  801c4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 63 ef ff ff       	call   800bb9 <sys_page_alloc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 c3 00 00 00    	js     801d26 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	ff 75 f4             	pushl  -0xc(%ebp)
  801c69:	e8 bc f5 ff ff       	call   80122a <fd2data>
  801c6e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c70:	83 c4 0c             	add    $0xc,%esp
  801c73:	68 07 04 00 00       	push   $0x407
  801c78:	50                   	push   %eax
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 39 ef ff ff       	call   800bb9 <sys_page_alloc>
  801c80:	89 c3                	mov    %eax,%ebx
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	0f 88 89 00 00 00    	js     801d16 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff 75 f0             	pushl  -0x10(%ebp)
  801c93:	e8 92 f5 ff ff       	call   80122a <fd2data>
  801c98:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c9f:	50                   	push   %eax
  801ca0:	6a 00                	push   $0x0
  801ca2:	56                   	push   %esi
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 52 ef ff ff       	call   800bfc <sys_page_map>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 20             	add    $0x20,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 55                	js     801d08 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cdd:	83 ec 0c             	sub    $0xc,%esp
  801ce0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce3:	e8 32 f5 ff ff       	call   80121a <fd2num>
  801ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ceb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ced:	83 c4 04             	add    $0x4,%esp
  801cf0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf3:	e8 22 f5 ff ff       	call   80121a <fd2num>
  801cf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	ba 00 00 00 00       	mov    $0x0,%edx
  801d06:	eb 30                	jmp    801d38 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	56                   	push   %esi
  801d0c:	6a 00                	push   $0x0
  801d0e:	e8 2b ef ff ff       	call   800c3e <sys_page_unmap>
  801d13:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1c:	6a 00                	push   $0x0
  801d1e:	e8 1b ef ff ff       	call   800c3e <sys_page_unmap>
  801d23:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 0b ef ff ff       	call   800c3e <sys_page_unmap>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d38:	89 d0                	mov    %edx,%eax
  801d3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 3d f5 ff ff       	call   801290 <fd_lookup>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 18                	js     801d72 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d60:	e8 c5 f4 ff ff       	call   80122a <fd2data>
	return _pipeisclosed(fd, p);
  801d65:	89 c2                	mov    %eax,%edx
  801d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6a:	e8 21 fd ff ff       	call   801a90 <_pipeisclosed>
  801d6f:	83 c4 10             	add    $0x10,%esp
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d84:	68 6e 28 80 00       	push   $0x80286e
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	e8 25 ea ff ff       	call   8007b6 <strcpy>
	return 0;
}
  801d91:	b8 00 00 00 00       	mov    $0x0,%eax
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	57                   	push   %edi
  801d9c:	56                   	push   %esi
  801d9d:	53                   	push   %ebx
  801d9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801daf:	eb 2d                	jmp    801dde <devcons_write+0x46>
		m = n - tot;
  801db1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801db6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801db9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dbe:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc1:	83 ec 04             	sub    $0x4,%esp
  801dc4:	53                   	push   %ebx
  801dc5:	03 45 0c             	add    0xc(%ebp),%eax
  801dc8:	50                   	push   %eax
  801dc9:	57                   	push   %edi
  801dca:	e8 79 eb ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801dcf:	83 c4 08             	add    $0x8,%esp
  801dd2:	53                   	push   %ebx
  801dd3:	57                   	push   %edi
  801dd4:	e8 24 ed ff ff       	call   800afd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd9:	01 de                	add    %ebx,%esi
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	89 f0                	mov    %esi,%eax
  801de0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de3:	72 cc                	jb     801db1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    

00801ded <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 08             	sub    $0x8,%esp
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801df8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfc:	74 2a                	je     801e28 <devcons_read+0x3b>
  801dfe:	eb 05                	jmp    801e05 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e00:	e8 95 ed ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e05:	e8 11 ed ff ff       	call   800b1b <sys_cgetc>
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	74 f2                	je     801e00 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 16                	js     801e28 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e12:	83 f8 04             	cmp    $0x4,%eax
  801e15:	74 0c                	je     801e23 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1a:	88 02                	mov    %al,(%edx)
	return 1;
  801e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e21:	eb 05                	jmp    801e28 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e36:	6a 01                	push   $0x1
  801e38:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e3b:	50                   	push   %eax
  801e3c:	e8 bc ec ff ff       	call   800afd <sys_cputs>
}
  801e41:	83 c4 10             	add    $0x10,%esp
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <getchar>:

int
getchar(void)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e4c:	6a 01                	push   $0x1
  801e4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e51:	50                   	push   %eax
  801e52:	6a 00                	push   $0x0
  801e54:	e8 9d f6 ff ff       	call   8014f6 <read>
	if (r < 0)
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 0f                	js     801e6f <getchar+0x29>
		return r;
	if (r < 1)
  801e60:	85 c0                	test   %eax,%eax
  801e62:	7e 06                	jle    801e6a <getchar+0x24>
		return -E_EOF;
	return c;
  801e64:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e68:	eb 05                	jmp    801e6f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7a:	50                   	push   %eax
  801e7b:	ff 75 08             	pushl  0x8(%ebp)
  801e7e:	e8 0d f4 ff ff       	call   801290 <fd_lookup>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 11                	js     801e9b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e93:	39 10                	cmp    %edx,(%eax)
  801e95:	0f 94 c0             	sete   %al
  801e98:	0f b6 c0             	movzbl %al,%eax
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <opencons>:

int
opencons(void)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	e8 95 f3 ff ff       	call   801241 <fd_alloc>
  801eac:	83 c4 10             	add    $0x10,%esp
		return r;
  801eaf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 3e                	js     801ef3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	68 07 04 00 00       	push   $0x407
  801ebd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 f2 ec ff ff       	call   800bb9 <sys_page_alloc>
  801ec7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 23                	js     801ef3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ee5:	83 ec 0c             	sub    $0xc,%esp
  801ee8:	50                   	push   %eax
  801ee9:	e8 2c f3 ff ff       	call   80121a <fd2num>
  801eee:	89 c2                	mov    %eax,%edx
  801ef0:	83 c4 10             	add    $0x10,%esp
}
  801ef3:	89 d0                	mov    %edx,%eax
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	53                   	push   %ebx
  801efb:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801efe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f05:	75 57                	jne    801f5e <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801f07:	e8 6f ec ff ff       	call   800b7b <sys_getenvid>
  801f0c:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801f0e:	83 ec 04             	sub    $0x4,%esp
  801f11:	6a 07                	push   $0x7
  801f13:	68 00 f0 bf ee       	push   $0xeebff000
  801f18:	50                   	push   %eax
  801f19:	e8 9b ec ff ff       	call   800bb9 <sys_page_alloc>
		if (r) {
  801f1e:	83 c4 10             	add    $0x10,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	74 12                	je     801f37 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801f25:	50                   	push   %eax
  801f26:	68 ba 26 80 00       	push   $0x8026ba
  801f2b:	6a 25                	push   $0x25
  801f2d:	68 7a 28 80 00       	push   $0x80287a
  801f32:	e8 21 e2 ff ff       	call   800158 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801f37:	83 ec 08             	sub    $0x8,%esp
  801f3a:	68 6b 1f 80 00       	push   $0x801f6b
  801f3f:	53                   	push   %ebx
  801f40:	e8 bf ed ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
		if (r) {
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	74 12                	je     801f5e <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801f4c:	50                   	push   %eax
  801f4d:	68 88 28 80 00       	push   $0x802888
  801f52:	6a 2b                	push   $0x2b
  801f54:	68 7a 28 80 00       	push   $0x80287a
  801f59:	e8 fa e1 ff ff       	call   800158 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f69:	c9                   	leave  
  801f6a:	c3                   	ret    

00801f6b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f6c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f71:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f73:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801f76:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801f7a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801f7f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801f83:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801f85:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801f88:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801f89:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801f8c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801f8d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801f8e:	c3                   	ret    

00801f8f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f95:	89 d0                	mov    %edx,%eax
  801f97:	c1 e8 16             	shr    $0x16,%eax
  801f9a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa6:	f6 c1 01             	test   $0x1,%cl
  801fa9:	74 1d                	je     801fc8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fab:	c1 ea 0c             	shr    $0xc,%edx
  801fae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb5:	f6 c2 01             	test   $0x1,%dl
  801fb8:	74 0e                	je     801fc8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fba:	c1 ea 0c             	shr    $0xc,%edx
  801fbd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc4:	ef 
  801fc5:	0f b7 c0             	movzwl %ax,%eax
}
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

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
