
obj/user/testpiperace2.debug：     文件格式 elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
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
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 40 23 80 00       	push   $0x802340
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 56 1b 00 00       	call   801ba7 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 23 80 00       	push   $0x80238e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 23 80 00       	push   $0x802397
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 15 0f 00 00       	call   800f84 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ac 23 80 00       	push   $0x8023ac
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 23 80 00       	push   $0x802397
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 dd 12 00 00       	call   801373 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 b5 23 80 00       	push   $0x8023b5
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 eb 12 00 00       	call   8013c3 <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 8a 12 00 00       	call   801373 <close>
			sys_yield();
  8000e9:	e8 8a 0b 00 00       	call   800c78 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 d8 1b 00 00       	call   801cfa <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b9 23 80 00       	push   $0x8023b9
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 da 0a 00 00       	call   800c18 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 d5 23 80 00       	push   $0x8023d5
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 89 1b 00 00       	call   801cfa <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 23 80 00       	push   $0x802364
  800180:	6a 40                	push   $0x40
  800182:	68 97 23 80 00       	push   $0x802397
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 ae 10 00 00       	call   801249 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 eb 23 80 00       	push   $0x8023eb
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 23 80 00       	push   $0x802397
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 24 10 00 00       	call   8011e3 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 73 0a 00 00       	call   800c59 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 77 11 00 00       	call   80139e <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 e7 09 00 00       	call   800c18 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 10 0a 00 00       	call   800c59 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 24 24 80 00       	push   $0x802424
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 c3 29 80 00 	movl   $0x8029c3,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 2f 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 d4 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 39 1d 00 00       	call   8020b0 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 26 1e 00 00       	call   8021e0 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 89 03 00 00    	je     8007eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 1a 03 00 00    	ja     8007d0 <vprintfmt+0x38a>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 5f 24 80 00       	push   $0x80245f
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 91 29 80 00       	push   $0x802991
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 58 24 80 00       	mov    $0x802458,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 86 02 00 00       	call   800873 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	79 74                	jns    80079c <vprintfmt+0x356>
				putch('-', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff d6                	call   *%esi
				num = -(long long) num;
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
  80073d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800745:	eb 55                	jmp    80079c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 83 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 74 fc ff ff       	call   8003d2 <getuint>
			base=8;
  80075e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800763:	eb 37                	jmp    80079c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 30                	push   $0x30
  80076b:	ff d6                	call   *%esi
			putch('x', putdat);
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 78                	push   $0x78
  800773:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800785:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800788:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 3b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 70 fb ff ff       	call   800323 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 ae fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	51                   	push   %ecx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 9c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x39a>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x397>
  8007e6:	e9 81 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 0c 04 80 00       	push   $0x80040c
  800827:	e8 1a fc ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 3f 27 80 00       	push   $0x80273f
  800c45:	6a 23                	push   $0x23
  800c47:	68 5c 27 80 00       	push   $0x80275c
  800c4c:	e8 e5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 3f 27 80 00       	push   $0x80273f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 5c 27 80 00       	push   $0x80275c
  800ccd:	e8 64 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 3f 27 80 00       	push   $0x80273f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 5c 27 80 00       	push   $0x80275c
  800d0f:	e8 22 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 3f 27 80 00       	push   $0x80273f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 5c 27 80 00       	push   $0x80275c
  800d51:	e8 e0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 3f 27 80 00       	push   $0x80273f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 5c 27 80 00       	push   $0x80275c
  800d93:	e8 9e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 3f 27 80 00       	push   $0x80273f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 5c 27 80 00       	push   $0x80275c
  800dd5:	e8 5c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 3f 27 80 00       	push   $0x80273f
  800e10:	6a 23                	push   $0x23
  800e12:	68 5c 27 80 00       	push   $0x80275c
  800e17:	e8 1a f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 3f 27 80 00       	push   $0x80273f
  800e74:	6a 23                	push   $0x23
  800e76:	68 5c 27 80 00       	push   $0x80275c
  800e7b:	e8 b6 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e90:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800e92:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e96:	75 14                	jne    800eac <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	68 6c 27 80 00       	push   $0x80276c
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 2f 28 80 00       	push   $0x80282f
  800ea7:	e8 8a f3 ff ff       	call   800236 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
  800eb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb8:	f6 c4 08             	test   $0x8,%ah
  800ebb:	75 14                	jne    800ed1 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800ebd:	83 ec 04             	sub    $0x4,%esp
  800ec0:	68 90 27 80 00       	push   $0x802790
  800ec5:	6a 2d                	push   $0x2d
  800ec7:	68 2f 28 80 00       	push   $0x80282f
  800ecc:	e8 65 f3 ff ff       	call   800236 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800ed1:	e8 83 fd ff ff       	call   800c59 <sys_getenvid>
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	6a 07                	push   $0x7
  800edb:	68 00 f0 7f 00       	push   $0x7ff000
  800ee0:	50                   	push   %eax
  800ee1:	e8 b1 fd ff ff       	call   800c97 <sys_page_alloc>
  800ee6:	83 c4 10             	add    $0x10,%esp
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	79 12                	jns    800eff <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800eed:	50                   	push   %eax
  800eee:	68 3a 28 80 00       	push   $0x80283a
  800ef3:	6a 3b                	push   $0x3b
  800ef5:	68 2f 28 80 00       	push   $0x80282f
  800efa:	e8 37 f3 ff ff       	call   800236 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800eff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	68 00 10 00 00       	push   $0x1000
  800f0d:	53                   	push   %ebx
  800f0e:	68 00 f0 7f 00       	push   $0x7ff000
  800f13:	e8 0e fb ff ff       	call   800a26 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800f18:	e8 3c fd ff ff       	call   800c59 <sys_getenvid>
  800f1d:	89 c6                	mov    %eax,%esi
  800f1f:	e8 35 fd ff ff       	call   800c59 <sys_getenvid>
  800f24:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f2b:	53                   	push   %ebx
  800f2c:	56                   	push   %esi
  800f2d:	68 00 f0 7f 00       	push   $0x7ff000
  800f32:	50                   	push   %eax
  800f33:	e8 a2 fd ff ff       	call   800cda <sys_page_map>
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 12                	jns    800f51 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800f3f:	50                   	push   %eax
  800f40:	68 53 28 80 00       	push   $0x802853
  800f45:	6a 48                	push   $0x48
  800f47:	68 2f 28 80 00       	push   $0x80282f
  800f4c:	e8 e5 f2 ff ff       	call   800236 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800f51:	e8 03 fd ff ff       	call   800c59 <sys_getenvid>
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	68 00 f0 7f 00       	push   $0x7ff000
  800f5e:	50                   	push   %eax
  800f5f:	e8 b8 fd ff ff       	call   800d1c <sys_page_unmap>
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 12                	jns    800f7d <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800f6b:	50                   	push   %eax
  800f6c:	68 6a 28 80 00       	push   $0x80286a
  800f71:	6a 4c                	push   $0x4c
  800f73:	68 2f 28 80 00       	push   $0x80282f
  800f78:	e8 b9 f2 ff ff       	call   800236 <_panic>
	}

	//panic("pgfault not implemented");
}
  800f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800f8d:	68 88 0e 80 00       	push   $0x800e88
  800f92:	e8 19 0f 00 00       	call   801eb0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f97:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9c:	cd 30                	int    $0x30
  800f9e:	89 c7                	mov    %eax,%edi
  800fa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 15                	jns    800fbf <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800faa:	50                   	push   %eax
  800fab:	68 83 28 80 00       	push   $0x802883
  800fb0:	68 a1 00 00 00       	push   $0xa1
  800fb5:	68 2f 28 80 00       	push   $0x80282f
  800fba:	e8 77 f2 ff ff       	call   800236 <_panic>
  800fbf:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	75 21                	jne    800fe9 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc8:	e8 8c fc ff ff       	call   800c59 <sys_getenvid>
  800fcd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fda:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe4:	e9 c8 01 00 00       	jmp    8011b1 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	c1 e8 16             	shr    $0x16,%eax
  800fee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff5:	a8 01                	test   $0x1,%al
  800ff7:	0f 84 23 01 00 00    	je     801120 <fork+0x19c>
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	c1 e8 0c             	shr    $0xc,%eax
  801002:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801009:	f6 c2 01             	test   $0x1,%dl
  80100c:	0f 84 0e 01 00 00    	je     801120 <fork+0x19c>
  801012:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801019:	f6 c2 04             	test   $0x4,%dl
  80101c:	0f 84 fe 00 00 00    	je     801120 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  801022:	89 c6                	mov    %eax,%esi
  801024:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  801027:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102e:	f6 c6 04             	test   $0x4,%dh
  801031:	74 3f                	je     801072 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  801033:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	25 07 0e 00 00       	and    $0xe07,%eax
  801042:	50                   	push   %eax
  801043:	56                   	push   %esi
  801044:	ff 75 e4             	pushl  -0x1c(%ebp)
  801047:	56                   	push   %esi
  801048:	6a 00                	push   $0x0
  80104a:	e8 8b fc ff ff       	call   800cda <sys_page_map>
  80104f:	83 c4 20             	add    $0x20,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	0f 89 c6 00 00 00    	jns    801120 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	50                   	push   %eax
  80105e:	57                   	push   %edi
  80105f:	6a 00                	push   $0x0
  801061:	68 c0 27 80 00       	push   $0x8027c0
  801066:	6a 6c                	push   $0x6c
  801068:	68 2f 28 80 00       	push   $0x80282f
  80106d:	e8 c4 f1 ff ff       	call   800236 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801072:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801079:	f6 c2 02             	test   $0x2,%dl
  80107c:	75 0c                	jne    80108a <fork+0x106>
  80107e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801085:	f6 c4 08             	test   $0x8,%ah
  801088:	74 66                	je     8010f0 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	68 05 08 00 00       	push   $0x805
  801092:	56                   	push   %esi
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	56                   	push   %esi
  801097:	6a 00                	push   $0x0
  801099:	e8 3c fc ff ff       	call   800cda <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 18                	jns    8010bd <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	50                   	push   %eax
  8010a9:	57                   	push   %edi
  8010aa:	6a 00                	push   $0x0
  8010ac:	68 c0 27 80 00       	push   $0x8027c0
  8010b1:	6a 74                	push   $0x74
  8010b3:	68 2f 28 80 00       	push   $0x80282f
  8010b8:	e8 79 f1 ff ff       	call   800236 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	68 05 08 00 00       	push   $0x805
  8010c5:	56                   	push   %esi
  8010c6:	6a 00                	push   $0x0
  8010c8:	56                   	push   %esi
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 0a fc ff ff       	call   800cda <sys_page_map>
  8010d0:	83 c4 20             	add    $0x20,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	79 49                	jns    801120 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	50                   	push   %eax
  8010db:	6a 00                	push   $0x0
  8010dd:	6a 00                	push   $0x0
  8010df:	68 c0 27 80 00       	push   $0x8027c0
  8010e4:	6a 77                	push   $0x77
  8010e6:	68 2f 28 80 00       	push   $0x80282f
  8010eb:	e8 46 f1 ff ff       	call   800236 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	6a 05                	push   $0x5
  8010f5:	56                   	push   %esi
  8010f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f9:	56                   	push   %esi
  8010fa:	6a 00                	push   $0x0
  8010fc:	e8 d9 fb ff ff       	call   800cda <sys_page_map>
  801101:	83 c4 20             	add    $0x20,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	79 18                	jns    801120 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	50                   	push   %eax
  80110c:	57                   	push   %edi
  80110d:	6a 00                	push   $0x0
  80110f:	68 c0 27 80 00       	push   $0x8027c0
  801114:	6a 7d                	push   $0x7d
  801116:	68 2f 28 80 00       	push   $0x80282f
  80111b:	e8 16 f1 ff ff       	call   800236 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801120:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801126:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80112c:	0f 85 b7 fe ff ff    	jne    800fe9 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	6a 07                	push   $0x7
  801137:	68 00 f0 bf ee       	push   $0xeebff000
  80113c:	57                   	push   %edi
  80113d:	e8 55 fb ff ff       	call   800c97 <sys_page_alloc>
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	85 c0                	test   %eax,%eax
  801147:	79 15                	jns    80115e <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  801149:	50                   	push   %eax
  80114a:	68 ec 27 80 00       	push   $0x8027ec
  80114f:	68 b4 00 00 00       	push   $0xb4
  801154:	68 2f 28 80 00       	push   $0x80282f
  801159:	e8 d8 f0 ff ff       	call   800236 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	68 24 1f 80 00       	push   $0x801f24
  801166:	57                   	push   %edi
  801167:	e8 76 fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	79 15                	jns    801188 <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801173:	50                   	push   %eax
  801174:	68 99 28 80 00       	push   $0x802899
  801179:	68 ba 00 00 00       	push   $0xba
  80117e:	68 2f 28 80 00       	push   $0x80282f
  801183:	e8 ae f0 ff ff       	call   800236 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	6a 02                	push   $0x2
  80118d:	57                   	push   %edi
  80118e:	e8 cb fb ff ff       	call   800d5e <sys_env_set_status>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	79 15                	jns    8011af <fork+0x22b>
		panic("Sys env set status error: %e", r);
  80119a:	50                   	push   %eax
  80119b:	68 b6 28 80 00       	push   $0x8028b6
  8011a0:	68 bf 00 00 00       	push   $0xbf
  8011a5:	68 2f 28 80 00       	push   $0x80282f
  8011aa:	e8 87 f0 ff ff       	call   800236 <_panic>
	}
	return eid;
  8011af:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011bf:	68 d3 28 80 00       	push   $0x8028d3
  8011c4:	68 ca 00 00 00       	push   $0xca
  8011c9:	68 2f 28 80 00       	push   $0x80282f
  8011ce:	e8 63 f0 ff ff       	call   800236 <_panic>

008011d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011de:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801200:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 16             	shr    $0x16,%edx
  80120a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 11                	je     801227 <fd_alloc+0x2d>
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 0c             	shr    $0xc,%edx
  80121b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	75 09                	jne    801230 <fd_alloc+0x36>
			*fd_store = fd;
  801227:	89 01                	mov    %eax,(%ecx)
			return 0;
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
  80122e:	eb 17                	jmp    801247 <fd_alloc+0x4d>
  801230:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801235:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123a:	75 c9                	jne    801205 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801242:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124f:	83 f8 1f             	cmp    $0x1f,%eax
  801252:	77 36                	ja     80128a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801254:	c1 e0 0c             	shl    $0xc,%eax
  801257:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 16             	shr    $0x16,%edx
  801261:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	74 24                	je     801291 <fd_lookup+0x48>
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	c1 ea 0c             	shr    $0xc,%edx
  801272:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	74 1a                	je     801298 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801281:	89 02                	mov    %eax,(%edx)
	return 0;
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
  801288:	eb 13                	jmp    80129d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128f:	eb 0c                	jmp    80129d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801296:	eb 05                	jmp    80129d <fd_lookup+0x54>
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a8:	ba 68 29 80 00       	mov    $0x802968,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ad:	eb 13                	jmp    8012c2 <dev_lookup+0x23>
  8012af:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b2:	39 08                	cmp    %ecx,(%eax)
  8012b4:	75 0c                	jne    8012c2 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c0:	eb 2e                	jmp    8012f0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c2:	8b 02                	mov    (%edx),%eax
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	75 e7                	jne    8012af <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012cd:	8b 40 48             	mov    0x48(%eax),%eax
  8012d0:	83 ec 04             	sub    $0x4,%esp
  8012d3:	51                   	push   %ecx
  8012d4:	50                   	push   %eax
  8012d5:	68 ec 28 80 00       	push   $0x8028ec
  8012da:	e8 30 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	56                   	push   %esi
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 10             	sub    $0x10,%esp
  8012fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130a:	c1 e8 0c             	shr    $0xc,%eax
  80130d:	50                   	push   %eax
  80130e:	e8 36 ff ff ff       	call   801249 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 05                	js     80131f <fd_close+0x2d>
	    || fd != fd2)
  80131a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131d:	74 0c                	je     80132b <fd_close+0x39>
		return (must_exist ? r : 0);
  80131f:	84 db                	test   %bl,%bl
  801321:	ba 00 00 00 00       	mov    $0x0,%edx
  801326:	0f 44 c2             	cmove  %edx,%eax
  801329:	eb 41                	jmp    80136c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 36                	pushl  (%esi)
  801334:	e8 66 ff ff ff       	call   80129f <dev_lookup>
  801339:	89 c3                	mov    %eax,%ebx
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 1a                	js     80135c <fd_close+0x6a>
		if (dev->dev_close)
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801348:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134d:	85 c0                	test   %eax,%eax
  80134f:	74 0b                	je     80135c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	56                   	push   %esi
  801355:	ff d0                	call   *%eax
  801357:	89 c3                	mov    %eax,%ebx
  801359:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	56                   	push   %esi
  801360:	6a 00                	push   $0x0
  801362:	e8 b5 f9 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 d8                	mov    %ebx,%eax
}
  80136c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801379:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 c4 fe ff ff       	call   801249 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 10                	js     80139c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	6a 01                	push   $0x1
  801391:	ff 75 f4             	pushl  -0xc(%ebp)
  801394:	e8 59 ff ff ff       	call   8012f2 <fd_close>
  801399:	83 c4 10             	add    $0x10,%esp
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <close_all>:

void
close_all(void)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	e8 c0 ff ff ff       	call   801373 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	83 c3 01             	add    $0x1,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	83 fb 20             	cmp    $0x20,%ebx
  8013bc:	75 ec                	jne    8013aa <close_all+0xc>
		close(i);
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	57                   	push   %edi
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 2c             	sub    $0x2c,%esp
  8013cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 08             	pushl  0x8(%ebp)
  8013d6:	e8 6e fe ff ff       	call   801249 <fd_lookup>
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	0f 88 c1 00 00 00    	js     8014a7 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	56                   	push   %esi
  8013ea:	e8 84 ff ff ff       	call   801373 <close>

	newfd = INDEX2FD(newfdnum);
  8013ef:	89 f3                	mov    %esi,%ebx
  8013f1:	c1 e3 0c             	shl    $0xc,%ebx
  8013f4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fa:	83 c4 04             	add    $0x4,%esp
  8013fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801400:	e8 de fd ff ff       	call   8011e3 <fd2data>
  801405:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801407:	89 1c 24             	mov    %ebx,(%esp)
  80140a:	e8 d4 fd ff ff       	call   8011e3 <fd2data>
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801415:	89 f8                	mov    %edi,%eax
  801417:	c1 e8 16             	shr    $0x16,%eax
  80141a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801421:	a8 01                	test   $0x1,%al
  801423:	74 37                	je     80145c <dup+0x99>
  801425:	89 f8                	mov    %edi,%eax
  801427:	c1 e8 0c             	shr    $0xc,%eax
  80142a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801431:	f6 c2 01             	test   $0x1,%dl
  801434:	74 26                	je     80145c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801436:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143d:	83 ec 0c             	sub    $0xc,%esp
  801440:	25 07 0e 00 00       	and    $0xe07,%eax
  801445:	50                   	push   %eax
  801446:	ff 75 d4             	pushl  -0x2c(%ebp)
  801449:	6a 00                	push   $0x0
  80144b:	57                   	push   %edi
  80144c:	6a 00                	push   $0x0
  80144e:	e8 87 f8 ff ff       	call   800cda <sys_page_map>
  801453:	89 c7                	mov    %eax,%edi
  801455:	83 c4 20             	add    $0x20,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 2e                	js     80148a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80145f:	89 d0                	mov    %edx,%eax
  801461:	c1 e8 0c             	shr    $0xc,%eax
  801464:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	25 07 0e 00 00       	and    $0xe07,%eax
  801473:	50                   	push   %eax
  801474:	53                   	push   %ebx
  801475:	6a 00                	push   $0x0
  801477:	52                   	push   %edx
  801478:	6a 00                	push   $0x0
  80147a:	e8 5b f8 ff ff       	call   800cda <sys_page_map>
  80147f:	89 c7                	mov    %eax,%edi
  801481:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801484:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801486:	85 ff                	test   %edi,%edi
  801488:	79 1d                	jns    8014a7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	53                   	push   %ebx
  80148e:	6a 00                	push   $0x0
  801490:	e8 87 f8 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801495:	83 c4 08             	add    $0x8,%esp
  801498:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149b:	6a 00                	push   $0x0
  80149d:	e8 7a f8 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	89 f8                	mov    %edi,%eax
}
  8014a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 14             	sub    $0x14,%esp
  8014b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	53                   	push   %ebx
  8014be:	e8 86 fd ff ff       	call   801249 <fd_lookup>
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 6d                	js     801539 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	ff 30                	pushl  (%eax)
  8014d8:	e8 c2 fd ff ff       	call   80129f <dev_lookup>
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 4c                	js     801530 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e7:	8b 42 08             	mov    0x8(%edx),%eax
  8014ea:	83 e0 03             	and    $0x3,%eax
  8014ed:	83 f8 01             	cmp    $0x1,%eax
  8014f0:	75 21                	jne    801513 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f7:	8b 40 48             	mov    0x48(%eax),%eax
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	50                   	push   %eax
  8014ff:	68 2d 29 80 00       	push   $0x80292d
  801504:	e8 06 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801511:	eb 26                	jmp    801539 <read+0x8a>
	}
	if (!dev->dev_read)
  801513:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801516:	8b 40 08             	mov    0x8(%eax),%eax
  801519:	85 c0                	test   %eax,%eax
  80151b:	74 17                	je     801534 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	52                   	push   %edx
  801527:	ff d0                	call   *%eax
  801529:	89 c2                	mov    %eax,%edx
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	eb 09                	jmp    801539 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	89 c2                	mov    %eax,%edx
  801532:	eb 05                	jmp    801539 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801534:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801539:	89 d0                	mov    %edx,%eax
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	57                   	push   %edi
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801554:	eb 21                	jmp    801577 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	89 f0                	mov    %esi,%eax
  80155b:	29 d8                	sub    %ebx,%eax
  80155d:	50                   	push   %eax
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	03 45 0c             	add    0xc(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	57                   	push   %edi
  801565:	e8 45 ff ff ff       	call   8014af <read>
		if (m < 0)
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 10                	js     801581 <readn+0x41>
			return m;
		if (m == 0)
  801571:	85 c0                	test   %eax,%eax
  801573:	74 0a                	je     80157f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801575:	01 c3                	add    %eax,%ebx
  801577:	39 f3                	cmp    %esi,%ebx
  801579:	72 db                	jb     801556 <readn+0x16>
  80157b:	89 d8                	mov    %ebx,%eax
  80157d:	eb 02                	jmp    801581 <readn+0x41>
  80157f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801581:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801584:	5b                   	pop    %ebx
  801585:	5e                   	pop    %esi
  801586:	5f                   	pop    %edi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    

00801589 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	53                   	push   %ebx
  80158d:	83 ec 14             	sub    $0x14,%esp
  801590:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801593:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	53                   	push   %ebx
  801598:	e8 ac fc ff ff       	call   801249 <fd_lookup>
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	89 c2                	mov    %eax,%edx
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 68                	js     80160e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b0:	ff 30                	pushl  (%eax)
  8015b2:	e8 e8 fc ff ff       	call   80129f <dev_lookup>
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 47                	js     801605 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c5:	75 21                	jne    8015e8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015cc:	8b 40 48             	mov    0x48(%eax),%eax
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	50                   	push   %eax
  8015d4:	68 49 29 80 00       	push   $0x802949
  8015d9:	e8 31 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e6:	eb 26                	jmp    80160e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ee:	85 d2                	test   %edx,%edx
  8015f0:	74 17                	je     801609 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	ff 75 10             	pushl  0x10(%ebp)
  8015f8:	ff 75 0c             	pushl  0xc(%ebp)
  8015fb:	50                   	push   %eax
  8015fc:	ff d2                	call   *%edx
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 09                	jmp    80160e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	89 c2                	mov    %eax,%edx
  801607:	eb 05                	jmp    80160e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801609:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160e:	89 d0                	mov    %edx,%eax
  801610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <seek>:

int
seek(int fdnum, off_t offset)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161e:	50                   	push   %eax
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 22 fc ff ff       	call   801249 <fd_lookup>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 0e                	js     80163c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801631:	8b 55 0c             	mov    0xc(%ebp),%edx
  801634:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	53                   	push   %ebx
  80164d:	e8 f7 fb ff ff       	call   801249 <fd_lookup>
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	89 c2                	mov    %eax,%edx
  801657:	85 c0                	test   %eax,%eax
  801659:	78 65                	js     8016c0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 33 fc ff ff       	call   80129f <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 44                	js     8016b7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167a:	75 21                	jne    80169d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801681:	8b 40 48             	mov    0x48(%eax),%eax
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	53                   	push   %ebx
  801688:	50                   	push   %eax
  801689:	68 0c 29 80 00       	push   $0x80290c
  80168e:	e8 7c ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169b:	eb 23                	jmp    8016c0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a0:	8b 52 18             	mov    0x18(%edx),%edx
  8016a3:	85 d2                	test   %edx,%edx
  8016a5:	74 14                	je     8016bb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	50                   	push   %eax
  8016ae:	ff d2                	call   *%edx
  8016b0:	89 c2                	mov    %eax,%edx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	eb 09                	jmp    8016c0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	eb 05                	jmp    8016c0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c0:	89 d0                	mov    %edx,%eax
  8016c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
  8016ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 6c fb ff ff       	call   801249 <fd_lookup>
  8016dd:	83 c4 08             	add    $0x8,%esp
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 58                	js     80173e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 a8 fb ff ff       	call   80129f <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 37                	js     801735 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801701:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801705:	74 32                	je     801739 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801707:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801711:	00 00 00 
	stat->st_isdir = 0;
  801714:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171b:	00 00 00 
	stat->st_dev = dev;
  80171e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	53                   	push   %ebx
  801728:	ff 75 f0             	pushl  -0x10(%ebp)
  80172b:	ff 50 14             	call   *0x14(%eax)
  80172e:	89 c2                	mov    %eax,%edx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb 09                	jmp    80173e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801735:	89 c2                	mov    %eax,%edx
  801737:	eb 05                	jmp    80173e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801739:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173e:	89 d0                	mov    %edx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	6a 00                	push   $0x0
  80174f:	ff 75 08             	pushl  0x8(%ebp)
  801752:	e8 d6 01 00 00       	call   80192d <open>
  801757:	89 c3                	mov    %eax,%ebx
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 1b                	js     80177b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	50                   	push   %eax
  801767:	e8 5b ff ff ff       	call   8016c7 <fstat>
  80176c:	89 c6                	mov    %eax,%esi
	close(fd);
  80176e:	89 1c 24             	mov    %ebx,(%esp)
  801771:	e8 fd fb ff ff       	call   801373 <close>
	return r;
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	89 f0                	mov    %esi,%eax
}
  80177b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	89 c6                	mov    %eax,%esi
  801789:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801792:	75 12                	jne    8017a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801794:	83 ec 0c             	sub    $0xc,%esp
  801797:	6a 01                	push   $0x1
  801799:	e8 96 08 00 00       	call   802034 <ipc_find_env>
  80179e:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a6:	6a 07                	push   $0x7
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	56                   	push   %esi
  8017ae:	ff 35 00 40 80 00    	pushl  0x804000
  8017b4:	e8 27 08 00 00       	call   801fe0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b9:	83 c4 0c             	add    $0xc,%esp
  8017bc:	6a 00                	push   $0x0
  8017be:	53                   	push   %ebx
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 82 07 00 00       	call   801f48 <ipc_recv>
}
  8017c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f0:	e8 8d ff ff ff       	call   801782 <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	b8 06 00 00 00       	mov    $0x6,%eax
  801812:	e8 6b ff ff ff       	call   801782 <fsipc>
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	53                   	push   %ebx
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	b8 05 00 00 00       	mov    $0x5,%eax
  801838:	e8 45 ff ff ff       	call   801782 <fsipc>
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 2c                	js     80186d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	53                   	push   %ebx
  80184a:	e8 45 f0 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184f:	a1 80 50 80 00       	mov    0x805080,%eax
  801854:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185a:	a1 84 50 80 00       	mov    0x805084,%eax
  80185f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 0c             	sub    $0xc,%esp
  801878:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187b:	8b 55 08             	mov    0x8(%ebp),%edx
  80187e:	8b 52 0c             	mov    0xc(%edx),%edx
  801881:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801887:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  80188c:	50                   	push   %eax
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	68 08 50 80 00       	push   $0x805008
  801895:	e8 8c f1 ff ff       	call   800a26 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80189a:	ba 00 00 00 00       	mov    $0x0,%edx
  80189f:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a4:	e8 d9 fe ff ff       	call   801782 <fsipc>
	//panic("devfile_write not implemented");
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ce:	e8 af fe ff ff       	call   801782 <fsipc>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 4b                	js     801924 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d9:	39 c6                	cmp    %eax,%esi
  8018db:	73 16                	jae    8018f3 <devfile_read+0x48>
  8018dd:	68 78 29 80 00       	push   $0x802978
  8018e2:	68 7f 29 80 00       	push   $0x80297f
  8018e7:	6a 7c                	push   $0x7c
  8018e9:	68 94 29 80 00       	push   $0x802994
  8018ee:	e8 43 e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018f3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f8:	7e 16                	jle    801910 <devfile_read+0x65>
  8018fa:	68 9f 29 80 00       	push   $0x80299f
  8018ff:	68 7f 29 80 00       	push   $0x80297f
  801904:	6a 7d                	push   $0x7d
  801906:	68 94 29 80 00       	push   $0x802994
  80190b:	e8 26 e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801910:	83 ec 04             	sub    $0x4,%esp
  801913:	50                   	push   %eax
  801914:	68 00 50 80 00       	push   $0x805000
  801919:	ff 75 0c             	pushl  0xc(%ebp)
  80191c:	e8 05 f1 ff ff       	call   800a26 <memmove>
	return r;
  801921:	83 c4 10             	add    $0x10,%esp
}
  801924:	89 d8                	mov    %ebx,%eax
  801926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	53                   	push   %ebx
  801931:	83 ec 20             	sub    $0x20,%esp
  801934:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801937:	53                   	push   %ebx
  801938:	e8 1e ef ff ff       	call   80085b <strlen>
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801945:	7f 67                	jg     8019ae <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801947:	83 ec 0c             	sub    $0xc,%esp
  80194a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194d:	50                   	push   %eax
  80194e:	e8 a7 f8 ff ff       	call   8011fa <fd_alloc>
  801953:	83 c4 10             	add    $0x10,%esp
		return r;
  801956:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 57                	js     8019b3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	53                   	push   %ebx
  801960:	68 00 50 80 00       	push   $0x805000
  801965:	e8 2a ef ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801972:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801975:	b8 01 00 00 00       	mov    $0x1,%eax
  80197a:	e8 03 fe ff ff       	call   801782 <fsipc>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	79 14                	jns    80199c <open+0x6f>
		fd_close(fd, 0);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	6a 00                	push   $0x0
  80198d:	ff 75 f4             	pushl  -0xc(%ebp)
  801990:	e8 5d f9 ff ff       	call   8012f2 <fd_close>
		return r;
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	89 da                	mov    %ebx,%edx
  80199a:	eb 17                	jmp    8019b3 <open+0x86>
	}

	return fd2num(fd);
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a2:	e8 2c f8 ff ff       	call   8011d3 <fd2num>
  8019a7:	89 c2                	mov    %eax,%edx
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	eb 05                	jmp    8019b3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ae:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b3:	89 d0                	mov    %edx,%eax
  8019b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ca:	e8 b3 fd ff ff       	call   801782 <fsipc>
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d9:	83 ec 0c             	sub    $0xc,%esp
  8019dc:	ff 75 08             	pushl  0x8(%ebp)
  8019df:	e8 ff f7 ff ff       	call   8011e3 <fd2data>
  8019e4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e6:	83 c4 08             	add    $0x8,%esp
  8019e9:	68 ab 29 80 00       	push   $0x8029ab
  8019ee:	53                   	push   %ebx
  8019ef:	e8 a0 ee ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f4:	8b 46 04             	mov    0x4(%esi),%eax
  8019f7:	2b 06                	sub    (%esi),%eax
  8019f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a06:	00 00 00 
	stat->st_dev = &devpipe;
  801a09:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a10:	30 80 00 
	return 0;
}
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
  801a18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1b:	5b                   	pop    %ebx
  801a1c:	5e                   	pop    %esi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	53                   	push   %ebx
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a29:	53                   	push   %ebx
  801a2a:	6a 00                	push   $0x0
  801a2c:	e8 eb f2 ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a31:	89 1c 24             	mov    %ebx,(%esp)
  801a34:	e8 aa f7 ff ff       	call   8011e3 <fd2data>
  801a39:	83 c4 08             	add    $0x8,%esp
  801a3c:	50                   	push   %eax
  801a3d:	6a 00                	push   $0x0
  801a3f:	e8 d8 f2 ff ff       	call   800d1c <sys_page_unmap>
}
  801a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a47:	c9                   	leave  
  801a48:	c3                   	ret    

00801a49 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	57                   	push   %edi
  801a4d:	56                   	push   %esi
  801a4e:	53                   	push   %ebx
  801a4f:	83 ec 1c             	sub    $0x1c,%esp
  801a52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a55:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a57:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	ff 75 e0             	pushl  -0x20(%ebp)
  801a65:	e8 03 06 00 00       	call   80206d <pageref>
  801a6a:	89 c3                	mov    %eax,%ebx
  801a6c:	89 3c 24             	mov    %edi,(%esp)
  801a6f:	e8 f9 05 00 00       	call   80206d <pageref>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	39 c3                	cmp    %eax,%ebx
  801a79:	0f 94 c1             	sete   %cl
  801a7c:	0f b6 c9             	movzbl %cl,%ecx
  801a7f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a82:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a88:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a8b:	39 ce                	cmp    %ecx,%esi
  801a8d:	74 1b                	je     801aaa <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a8f:	39 c3                	cmp    %eax,%ebx
  801a91:	75 c4                	jne    801a57 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a93:	8b 42 58             	mov    0x58(%edx),%eax
  801a96:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a99:	50                   	push   %eax
  801a9a:	56                   	push   %esi
  801a9b:	68 b2 29 80 00       	push   $0x8029b2
  801aa0:	e8 6a e8 ff ff       	call   80030f <cprintf>
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	eb ad                	jmp    801a57 <_pipeisclosed+0xe>
	}
}
  801aaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5f                   	pop    %edi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	57                   	push   %edi
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	83 ec 28             	sub    $0x28,%esp
  801abe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ac1:	56                   	push   %esi
  801ac2:	e8 1c f7 ff ff       	call   8011e3 <fd2data>
  801ac7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad1:	eb 4b                	jmp    801b1e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad3:	89 da                	mov    %ebx,%edx
  801ad5:	89 f0                	mov    %esi,%eax
  801ad7:	e8 6d ff ff ff       	call   801a49 <_pipeisclosed>
  801adc:	85 c0                	test   %eax,%eax
  801ade:	75 48                	jne    801b28 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae0:	e8 93 f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae8:	8b 0b                	mov    (%ebx),%ecx
  801aea:	8d 51 20             	lea    0x20(%ecx),%edx
  801aed:	39 d0                	cmp    %edx,%eax
  801aef:	73 e2                	jae    801ad3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801afb:	89 c2                	mov    %eax,%edx
  801afd:	c1 fa 1f             	sar    $0x1f,%edx
  801b00:	89 d1                	mov    %edx,%ecx
  801b02:	c1 e9 1b             	shr    $0x1b,%ecx
  801b05:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b08:	83 e2 1f             	and    $0x1f,%edx
  801b0b:	29 ca                	sub    %ecx,%edx
  801b0d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b11:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b15:	83 c0 01             	add    $0x1,%eax
  801b18:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b1b:	83 c7 01             	add    $0x1,%edi
  801b1e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b21:	75 c2                	jne    801ae5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b23:	8b 45 10             	mov    0x10(%ebp),%eax
  801b26:	eb 05                	jmp    801b2d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5f                   	pop    %edi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	57                   	push   %edi
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 18             	sub    $0x18,%esp
  801b3e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b41:	57                   	push   %edi
  801b42:	e8 9c f6 ff ff       	call   8011e3 <fd2data>
  801b47:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b51:	eb 3d                	jmp    801b90 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b53:	85 db                	test   %ebx,%ebx
  801b55:	74 04                	je     801b5b <devpipe_read+0x26>
				return i;
  801b57:	89 d8                	mov    %ebx,%eax
  801b59:	eb 44                	jmp    801b9f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b5b:	89 f2                	mov    %esi,%edx
  801b5d:	89 f8                	mov    %edi,%eax
  801b5f:	e8 e5 fe ff ff       	call   801a49 <_pipeisclosed>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	75 32                	jne    801b9a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b68:	e8 0b f1 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b6d:	8b 06                	mov    (%esi),%eax
  801b6f:	3b 46 04             	cmp    0x4(%esi),%eax
  801b72:	74 df                	je     801b53 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b74:	99                   	cltd   
  801b75:	c1 ea 1b             	shr    $0x1b,%edx
  801b78:	01 d0                	add    %edx,%eax
  801b7a:	83 e0 1f             	and    $0x1f,%eax
  801b7d:	29 d0                	sub    %edx,%eax
  801b7f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b87:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b8a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8d:	83 c3 01             	add    $0x1,%ebx
  801b90:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b93:	75 d8                	jne    801b6d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b95:	8b 45 10             	mov    0x10(%ebp),%eax
  801b98:	eb 05                	jmp    801b9f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba2:	5b                   	pop    %ebx
  801ba3:	5e                   	pop    %esi
  801ba4:	5f                   	pop    %edi
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    

00801ba7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	56                   	push   %esi
  801bab:	53                   	push   %ebx
  801bac:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801baf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb2:	50                   	push   %eax
  801bb3:	e8 42 f6 ff ff       	call   8011fa <fd_alloc>
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	89 c2                	mov    %eax,%edx
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 2c 01 00 00    	js     801cf1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc5:	83 ec 04             	sub    $0x4,%esp
  801bc8:	68 07 04 00 00       	push   $0x407
  801bcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd0:	6a 00                	push   $0x0
  801bd2:	e8 c0 f0 ff ff       	call   800c97 <sys_page_alloc>
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	89 c2                	mov    %eax,%edx
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	0f 88 0d 01 00 00    	js     801cf1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801be4:	83 ec 0c             	sub    $0xc,%esp
  801be7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bea:	50                   	push   %eax
  801beb:	e8 0a f6 ff ff       	call   8011fa <fd_alloc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 e2 00 00 00    	js     801cdf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	68 07 04 00 00       	push   $0x407
  801c05:	ff 75 f0             	pushl  -0x10(%ebp)
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 88 f0 ff ff       	call   800c97 <sys_page_alloc>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	85 c0                	test   %eax,%eax
  801c16:	0f 88 c3 00 00 00    	js     801cdf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	e8 bc f5 ff ff       	call   8011e3 <fd2data>
  801c27:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c29:	83 c4 0c             	add    $0xc,%esp
  801c2c:	68 07 04 00 00       	push   $0x407
  801c31:	50                   	push   %eax
  801c32:	6a 00                	push   $0x0
  801c34:	e8 5e f0 ff ff       	call   800c97 <sys_page_alloc>
  801c39:	89 c3                	mov    %eax,%ebx
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	0f 88 89 00 00 00    	js     801ccf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4c:	e8 92 f5 ff ff       	call   8011e3 <fd2data>
  801c51:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c58:	50                   	push   %eax
  801c59:	6a 00                	push   $0x0
  801c5b:	56                   	push   %esi
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 77 f0 ff ff       	call   800cda <sys_page_map>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	83 c4 20             	add    $0x20,%esp
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 55                	js     801cc1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c6c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c75:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c81:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c96:	83 ec 0c             	sub    $0xc,%esp
  801c99:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9c:	e8 32 f5 ff ff       	call   8011d3 <fd2num>
  801ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca6:	83 c4 04             	add    $0x4,%esp
  801ca9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cac:	e8 22 f5 ff ff       	call   8011d3 <fd2num>
  801cb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbf:	eb 30                	jmp    801cf1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cc1:	83 ec 08             	sub    $0x8,%esp
  801cc4:	56                   	push   %esi
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 50 f0 ff ff       	call   800d1c <sys_page_unmap>
  801ccc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 40 f0 ff ff       	call   800d1c <sys_page_unmap>
  801cdc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cdf:	83 ec 08             	sub    $0x8,%esp
  801ce2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce5:	6a 00                	push   $0x0
  801ce7:	e8 30 f0 ff ff       	call   800d1c <sys_page_unmap>
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cf1:	89 d0                	mov    %edx,%eax
  801cf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d03:	50                   	push   %eax
  801d04:	ff 75 08             	pushl  0x8(%ebp)
  801d07:	e8 3d f5 ff ff       	call   801249 <fd_lookup>
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 18                	js     801d2b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	e8 c5 f4 ff ff       	call   8011e3 <fd2data>
	return _pipeisclosed(fd, p);
  801d1e:	89 c2                	mov    %eax,%edx
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	e8 21 fd ff ff       	call   801a49 <_pipeisclosed>
  801d28:	83 c4 10             	add    $0x10,%esp
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    

00801d2d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d30:	b8 00 00 00 00       	mov    $0x0,%eax
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d3d:	68 ca 29 80 00       	push   $0x8029ca
  801d42:	ff 75 0c             	pushl  0xc(%ebp)
  801d45:	e8 4a eb ff ff       	call   800894 <strcpy>
	return 0;
}
  801d4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	57                   	push   %edi
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d62:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d68:	eb 2d                	jmp    801d97 <devcons_write+0x46>
		m = n - tot;
  801d6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d6d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d6f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d72:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d77:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	53                   	push   %ebx
  801d7e:	03 45 0c             	add    0xc(%ebp),%eax
  801d81:	50                   	push   %eax
  801d82:	57                   	push   %edi
  801d83:	e8 9e ec ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  801d88:	83 c4 08             	add    $0x8,%esp
  801d8b:	53                   	push   %ebx
  801d8c:	57                   	push   %edi
  801d8d:	e8 49 ee ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d92:	01 de                	add    %ebx,%esi
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	89 f0                	mov    %esi,%eax
  801d99:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9c:	72 cc                	jb     801d6a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 08             	sub    $0x8,%esp
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801db1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db5:	74 2a                	je     801de1 <devcons_read+0x3b>
  801db7:	eb 05                	jmp    801dbe <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db9:	e8 ba ee ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dbe:	e8 36 ee ff ff       	call   800bf9 <sys_cgetc>
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	74 f2                	je     801db9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 16                	js     801de1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dcb:	83 f8 04             	cmp    $0x4,%eax
  801dce:	74 0c                	je     801ddc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd3:	88 02                	mov    %al,(%edx)
	return 1;
  801dd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dda:	eb 05                	jmp    801de1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ddc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801def:	6a 01                	push   $0x1
  801df1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	e8 e1 ed ff ff       	call   800bdb <sys_cputs>
}
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <getchar>:

int
getchar(void)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e05:	6a 01                	push   $0x1
  801e07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	6a 00                	push   $0x0
  801e0d:	e8 9d f6 ff ff       	call   8014af <read>
	if (r < 0)
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 0f                	js     801e28 <getchar+0x29>
		return r;
	if (r < 1)
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	7e 06                	jle    801e23 <getchar+0x24>
		return -E_EOF;
	return c;
  801e1d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e21:	eb 05                	jmp    801e28 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e23:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	ff 75 08             	pushl  0x8(%ebp)
  801e37:	e8 0d f4 ff ff       	call   801249 <fd_lookup>
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 11                	js     801e54 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e4c:	39 10                	cmp    %edx,(%eax)
  801e4e:	0f 94 c0             	sete   %al
  801e51:	0f b6 c0             	movzbl %al,%eax
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <opencons>:

int
opencons(void)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	e8 95 f3 ff ff       	call   8011fa <fd_alloc>
  801e65:	83 c4 10             	add    $0x10,%esp
		return r;
  801e68:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 3e                	js     801eac <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6e:	83 ec 04             	sub    $0x4,%esp
  801e71:	68 07 04 00 00       	push   $0x407
  801e76:	ff 75 f4             	pushl  -0xc(%ebp)
  801e79:	6a 00                	push   $0x0
  801e7b:	e8 17 ee ff ff       	call   800c97 <sys_page_alloc>
  801e80:	83 c4 10             	add    $0x10,%esp
		return r;
  801e83:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 23                	js     801eac <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	50                   	push   %eax
  801ea2:	e8 2c f3 ff ff       	call   8011d3 <fd2num>
  801ea7:	89 c2                	mov    %eax,%edx
  801ea9:	83 c4 10             	add    $0x10,%esp
}
  801eac:	89 d0                	mov    %edx,%eax
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ebe:	75 57                	jne    801f17 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801ec0:	e8 94 ed ff ff       	call   800c59 <sys_getenvid>
  801ec5:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801ec7:	83 ec 04             	sub    $0x4,%esp
  801eca:	6a 07                	push   $0x7
  801ecc:	68 00 f0 bf ee       	push   $0xeebff000
  801ed1:	50                   	push   %eax
  801ed2:	e8 c0 ed ff ff       	call   800c97 <sys_page_alloc>
		if (r) {
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	74 12                	je     801ef0 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801ede:	50                   	push   %eax
  801edf:	68 3a 28 80 00       	push   $0x80283a
  801ee4:	6a 25                	push   $0x25
  801ee6:	68 d6 29 80 00       	push   $0x8029d6
  801eeb:	e8 46 e3 ff ff       	call   800236 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801ef0:	83 ec 08             	sub    $0x8,%esp
  801ef3:	68 24 1f 80 00       	push   $0x801f24
  801ef8:	53                   	push   %ebx
  801ef9:	e8 e4 ee ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
		if (r) {
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	85 c0                	test   %eax,%eax
  801f03:	74 12                	je     801f17 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801f05:	50                   	push   %eax
  801f06:	68 e4 29 80 00       	push   $0x8029e4
  801f0b:	6a 2b                	push   $0x2b
  801f0d:	68 d6 29 80 00       	push   $0x8029d6
  801f12:	e8 1f e3 ff ff       	call   800236 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f17:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f24:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f25:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f2a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f2c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801f2f:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801f33:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801f38:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801f3c:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801f3e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801f41:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801f42:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801f45:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801f46:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801f47:	c3                   	ret    

00801f48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801f56:	85 c0                	test   %eax,%eax
  801f58:	74 3e                	je     801f98 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	50                   	push   %eax
  801f5e:	e8 e4 ee ff ff       	call   800e47 <sys_ipc_recv>
  801f63:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	85 f6                	test   %esi,%esi
  801f6a:	74 13                	je     801f7f <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f71:	85 d2                	test   %edx,%edx
  801f73:	75 08                	jne    801f7d <ipc_recv+0x35>
  801f75:	a1 04 40 80 00       	mov    0x804004,%eax
  801f7a:	8b 40 74             	mov    0x74(%eax),%eax
  801f7d:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801f7f:	85 db                	test   %ebx,%ebx
  801f81:	74 48                	je     801fcb <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801f83:	b8 00 00 00 00       	mov    $0x0,%eax
  801f88:	85 d2                	test   %edx,%edx
  801f8a:	75 08                	jne    801f94 <ipc_recv+0x4c>
  801f8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f91:	8b 40 78             	mov    0x78(%eax),%eax
  801f94:	89 03                	mov    %eax,(%ebx)
  801f96:	eb 33                	jmp    801fcb <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801f98:	83 ec 0c             	sub    $0xc,%esp
  801f9b:	68 00 00 c0 ee       	push   $0xeec00000
  801fa0:	e8 a2 ee ff ff       	call   800e47 <sys_ipc_recv>
  801fa5:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	85 f6                	test   %esi,%esi
  801fac:	74 13                	je     801fc1 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb3:	85 d2                	test   %edx,%edx
  801fb5:	75 08                	jne    801fbf <ipc_recv+0x77>
  801fb7:	a1 04 40 80 00       	mov    0x804004,%eax
  801fbc:	8b 40 74             	mov    0x74(%eax),%eax
  801fbf:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801fc1:	85 db                	test   %ebx,%ebx
  801fc3:	74 06                	je     801fcb <ipc_recv+0x83>
			*perm_store = 0;
  801fc5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801fcb:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801fcd:	85 d2                	test   %edx,%edx
  801fcf:	75 08                	jne    801fd9 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801fd1:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd6:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801fd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5e                   	pop    %esi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fec:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801ff2:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ff9:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ffc:	eb 1c                	jmp    80201a <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801ffe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802001:	74 12                	je     802015 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  802003:	50                   	push   %eax
  802004:	68 0c 2a 80 00       	push   $0x802a0c
  802009:	6a 4f                	push   $0x4f
  80200b:	68 27 2a 80 00       	push   $0x802a27
  802010:	e8 21 e2 ff ff       	call   800236 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802015:	e8 5e ec ff ff       	call   800c78 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80201a:	ff 75 14             	pushl  0x14(%ebp)
  80201d:	53                   	push   %ebx
  80201e:	56                   	push   %esi
  80201f:	57                   	push   %edi
  802020:	e8 ff ed ff ff       	call   800e24 <sys_ipc_try_send>
  802025:	83 c4 10             	add    $0x10,%esp
  802028:	85 c0                	test   %eax,%eax
  80202a:	78 d2                	js     801ffe <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80202c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802042:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802048:	8b 52 50             	mov    0x50(%edx),%edx
  80204b:	39 ca                	cmp    %ecx,%edx
  80204d:	75 0d                	jne    80205c <ipc_find_env+0x28>
			return envs[i].env_id;
  80204f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802057:	8b 40 48             	mov    0x48(%eax),%eax
  80205a:	eb 0f                	jmp    80206b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205c:	83 c0 01             	add    $0x1,%eax
  80205f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802064:	75 d9                	jne    80203f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    

0080206d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802073:	89 d0                	mov    %edx,%eax
  802075:	c1 e8 16             	shr    $0x16,%eax
  802078:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802084:	f6 c1 01             	test   $0x1,%cl
  802087:	74 1d                	je     8020a6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802089:	c1 ea 0c             	shr    $0xc,%edx
  80208c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802093:	f6 c2 01             	test   $0x1,%dl
  802096:	74 0e                	je     8020a6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802098:	c1 ea 0c             	shr    $0xc,%edx
  80209b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a2:	ef 
  8020a3:	0f b7 c0             	movzwl %ax,%eax
}
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
