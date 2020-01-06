
obj/user/testpiperace.debug：     文件格式 elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 60 23 80 00       	push   $0x802360
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 c5 1c 00 00       	call   801d15 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 79 23 80 00       	push   $0x802379
  80005d:	6a 0d                	push   $0xd
  80005f:	68 82 23 80 00       	push   $0x802382
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 24 0f 00 00       	call   800f92 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 96 23 80 00       	push   $0x802396
  80007a:	6a 10                	push   $0x10
  80007c:	68 82 23 80 00       	push   $0x802382
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 11 14 00 00       	call   8014a6 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 c0 1d 00 00       	call   801e68 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 9f 23 80 00       	push   $0x80239f
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 bd 0b 00 00       	call   800c86 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 05 11 00 00       	call   8011e1 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 ba 23 80 00       	push   $0x8023ba
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 c5 23 80 00       	push   $0x8023c5
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 dc 13 00 00       	call   8014f6 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 c1 13 00 00       	call   8014f6 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 d0 23 80 00       	push   $0x8023d0
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 10 1d 00 00       	call   801e68 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 2c 24 80 00       	push   $0x80242c
  800167:	6a 3a                	push   $0x3a
  800169:	68 82 23 80 00       	push   $0x802382
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 fa 11 00 00       	call   80137c <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 e6 23 80 00       	push   $0x8023e6
  80018f:	6a 3c                	push   $0x3c
  800191:	68 82 23 80 00       	push   $0x802382
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 70 11 00 00       	call   801316 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 56 19 00 00       	call   801b04 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 fe 23 80 00       	push   $0x8023fe
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 14 24 80 00       	push   $0x802414
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 73 0a 00 00       	call   800c67 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 9c 12 00 00       	call   8014d1 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 e7 09 00 00       	call   800c26 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 10 0a 00 00       	call   800c67 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 60 24 80 00       	push   $0x802460
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 77 23 80 00 	movl   $0x802377,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 2f 09 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 d4 08 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 3b 1d 00 00       	call   8020c0 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 28 1e 00 00       	call   8021f0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 89 03 00 00    	je     8007f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 1a 03 00 00    	ja     8007de <vprintfmt+0x38a>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 9b 24 80 00       	push   $0x80249b
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 f5 29 80 00       	push   $0x8029f5
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 94 24 80 00       	mov    $0x802494,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 86 02 00 00       	call   800881 <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800728:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	79 74                	jns    8007aa <vprintfmt+0x356>
				putch('-', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 2d                	push   $0x2d
  80073c:	ff d6                	call   *%esi
				num = -(long long) num;
  80073e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800741:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800744:	f7 d8                	neg    %eax
  800746:	83 d2 00             	adc    $0x0,%edx
  800749:	f7 da                	neg    %edx
  80074b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800753:	eb 55                	jmp    8007aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 83 fc ff ff       	call   8003e0 <getuint>
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800762:	eb 46                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 74 fc ff ff       	call   8003e0 <getuint>
			base=8;
  80076c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800771:	eb 37                	jmp    8007aa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 30                	push   $0x30
  800779:	ff d6                	call   *%esi
			putch('x', putdat);
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 78                	push   $0x78
  800781:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 04             	lea    0x4(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800793:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079b:	eb 0d                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 3b fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b1:	57                   	push   %edi
  8007b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b5:	51                   	push   %ecx
  8007b6:	52                   	push   %edx
  8007b7:	50                   	push   %eax
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	e8 70 fb ff ff       	call   800331 <printnum>
			break;
  8007c1:	83 c4 20             	add    $0x20,%esp
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	e9 ae fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	51                   	push   %ecx
  8007d1:	ff d6                	call   *%esi
			break;
  8007d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 9c fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 25                	push   $0x25
  8007e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 03                	jmp    8007ee <vprintfmt+0x39a>
  8007eb:	83 ef 01             	sub    $0x1,%edi
  8007ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f2:	75 f7                	jne    8007eb <vprintfmt+0x397>
  8007f4:	e9 81 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800810:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800814:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	85 c0                	test   %eax,%eax
  800820:	74 26                	je     800848 <vsnprintf+0x47>
  800822:	85 d2                	test   %edx,%edx
  800824:	7e 22                	jle    800848 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800826:	ff 75 14             	pushl  0x14(%ebp)
  800829:	ff 75 10             	pushl  0x10(%ebp)
  80082c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	68 1a 04 80 00       	push   $0x80041a
  800835:	e8 1a fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 05                	jmp    80084d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 9a ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb 03                	jmp    800879 <strlen+0x10>
		n++;
  800876:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087d:	75 f7                	jne    800876 <strlen+0xd>
		n++;
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
  80088f:	eb 03                	jmp    800894 <strnlen+0x13>
		n++;
  800891:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 08                	je     8008a0 <strnlen+0x1f>
  800898:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089c:	75 f3                	jne    800891 <strnlen+0x10>
  80089e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c9:	53                   	push   %ebx
  8008ca:	e8 9a ff ff ff       	call   800869 <strlen>
  8008cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 c5 ff ff ff       	call   8008a2 <strcpy>
	return dst;
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	eb 0f                	jmp    800907 <strncpy+0x23>
		*dst++ = *src;
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 39 01             	cmpb   $0x1,(%ecx)
  800904:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	39 da                	cmp    %ebx,%edx
  800909:	75 ed                	jne    8008f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091c:	8b 55 10             	mov    0x10(%ebp),%edx
  80091f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	85 d2                	test   %edx,%edx
  800923:	74 21                	je     800946 <strlcpy+0x35>
  800925:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800929:	89 f2                	mov    %esi,%edx
  80092b:	eb 09                	jmp    800936 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 09                	je     800943 <strlcpy+0x32>
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	84 db                	test   %bl,%bl
  80093f:	75 ec                	jne    80092d <strlcpy+0x1c>
  800941:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 03                	jmp    8009da <strfind+0xf>
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 04                	je     8009e5 <strfind+0x1a>
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	09 d0                	or     %edx,%eax
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a89:	c1 e9 02             	shr    $0x2,%ecx
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	ff 75 08             	pushl  0x8(%ebp)
  800aa8:	e8 87 ff ff ff       	call   800a34 <memmove>
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	eb 1a                	jmp    800adb <memcmp+0x2c>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	74 0a                	je     800ad5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acb:	0f b6 c1             	movzbl %cl,%eax
  800ace:	0f b6 db             	movzbl %bl,%ebx
  800ad1:	29 d8                	sub    %ebx,%eax
  800ad3:	eb 0f                	jmp    800ae4 <memcmp+0x35>
		s1++, s2++;
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	39 f0                	cmp    %esi,%eax
  800add:	75 e2                	jne    800ac1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	eb 0a                	jmp    800b04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afa:	0f b6 10             	movzbl (%eax),%edx
  800afd:	39 da                	cmp    %ebx,%edx
  800aff:	74 07                	je     800b08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	39 c8                	cmp    %ecx,%eax
  800b06:	72 f2                	jb     800afa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	75 0a                	jne    800b35 <strtol+0x2a>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb 11                	jmp    800b46 <strtol+0x3b>
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 08                	jne    800b46 <strtol+0x3b>
		s++, neg = 1;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 15                	jne    800b63 <strtol+0x58>
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	75 10                	jne    800b63 <strtol+0x58>
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	75 7c                	jne    800bd5 <strtol+0xca>
		s += 2, base = 16;
  800b59:	83 c1 02             	add    $0x2,%ecx
  800b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b61:	eb 16                	jmp    800b79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 12                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 08                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b81:	0f b6 11             	movzbl (%ecx),%edx
  800b84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x8b>
			dig = *s - '0';
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 30             	sub    $0x30,%edx
  800b94:	eb 22                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb 10                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 16                	ja     800bc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbb:	7d 0b                	jge    800bc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc6:	eb b9                	jmp    800b81 <strtol+0x76>

	if (endptr)
  800bc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcc:	74 0d                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd1:	89 0e                	mov    %ecx,(%esi)
  800bd3:	eb 06                	jmp    800bdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	74 98                	je     800b71 <strtol+0x66>
  800bd9:	eb 9e                	jmp    800b79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 01 00 00 00       	mov    $0x1,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	b8 03 00 00 00       	mov    $0x3,%eax
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 cb                	mov    %ecx,%ebx
  800c3e:	89 cf                	mov    %ecx,%edi
  800c40:	89 ce                	mov    %ecx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 03                	push   $0x3
  800c4e:	68 7f 27 80 00       	push   $0x80277f
  800c53:	6a 23                	push   $0x23
  800c55:	68 9c 27 80 00       	push   $0x80279c
  800c5a:	e8 e5 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 04                	push   $0x4
  800ccf:	68 7f 27 80 00       	push   $0x80277f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 9c 27 80 00       	push   $0x80279c
  800cdb:	e8 64 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	8b 75 18             	mov    0x18(%ebp),%esi
  800d05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 05                	push   $0x5
  800d11:	68 7f 27 80 00       	push   $0x80277f
  800d16:	6a 23                	push   $0x23
  800d18:	68 9c 27 80 00       	push   $0x80279c
  800d1d:	e8 22 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 06                	push   $0x6
  800d53:	68 7f 27 80 00       	push   $0x80277f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 9c 27 80 00       	push   $0x80279c
  800d5f:	e8 e0 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 08                	push   $0x8
  800d95:	68 7f 27 80 00       	push   $0x80277f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 9c 27 80 00       	push   $0x80279c
  800da1:	e8 9e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 09                	push   $0x9
  800dd7:	68 7f 27 80 00       	push   $0x80277f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 9c 27 80 00       	push   $0x80279c
  800de3:	e8 5c f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 0a                	push   $0xa
  800e19:	68 7f 27 80 00       	push   $0x80277f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 9c 27 80 00       	push   $0x80279c
  800e25:	e8 1a f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	be 00 00 00 00       	mov    $0x0,%esi
  800e3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 0d                	push   $0xd
  800e7d:	68 7f 27 80 00       	push   $0x80277f
  800e82:	6a 23                	push   $0x23
  800e84:	68 9c 27 80 00       	push   $0x80279c
  800e89:	e8 b6 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e9e:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800ea0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea4:	75 14                	jne    800eba <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800ea6:	83 ec 04             	sub    $0x4,%esp
  800ea9:	68 ac 27 80 00       	push   $0x8027ac
  800eae:	6a 23                	push   $0x23
  800eb0:	68 6f 28 80 00       	push   $0x80286f
  800eb5:	e8 8a f3 ff ff       	call   800244 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800eba:	89 d8                	mov    %ebx,%eax
  800ebc:	c1 e8 0c             	shr    $0xc,%eax
  800ebf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec6:	f6 c4 08             	test   $0x8,%ah
  800ec9:	75 14                	jne    800edf <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	68 d0 27 80 00       	push   $0x8027d0
  800ed3:	6a 2d                	push   $0x2d
  800ed5:	68 6f 28 80 00       	push   $0x80286f
  800eda:	e8 65 f3 ff ff       	call   800244 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800edf:	e8 83 fd ff ff       	call   800c67 <sys_getenvid>
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	6a 07                	push   $0x7
  800ee9:	68 00 f0 7f 00       	push   $0x7ff000
  800eee:	50                   	push   %eax
  800eef:	e8 b1 fd ff ff       	call   800ca5 <sys_page_alloc>
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	79 12                	jns    800f0d <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800efb:	50                   	push   %eax
  800efc:	68 7a 28 80 00       	push   $0x80287a
  800f01:	6a 3b                	push   $0x3b
  800f03:	68 6f 28 80 00       	push   $0x80286f
  800f08:	e8 37 f3 ff ff       	call   800244 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800f0d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	68 00 10 00 00       	push   $0x1000
  800f1b:	53                   	push   %ebx
  800f1c:	68 00 f0 7f 00       	push   $0x7ff000
  800f21:	e8 0e fb ff ff       	call   800a34 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800f26:	e8 3c fd ff ff       	call   800c67 <sys_getenvid>
  800f2b:	89 c6                	mov    %eax,%esi
  800f2d:	e8 35 fd ff ff       	call   800c67 <sys_getenvid>
  800f32:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f39:	53                   	push   %ebx
  800f3a:	56                   	push   %esi
  800f3b:	68 00 f0 7f 00       	push   $0x7ff000
  800f40:	50                   	push   %eax
  800f41:	e8 a2 fd ff ff       	call   800ce8 <sys_page_map>
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	79 12                	jns    800f5f <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 93 28 80 00       	push   $0x802893
  800f53:	6a 48                	push   $0x48
  800f55:	68 6f 28 80 00       	push   $0x80286f
  800f5a:	e8 e5 f2 ff ff       	call   800244 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800f5f:	e8 03 fd ff ff       	call   800c67 <sys_getenvid>
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	68 00 f0 7f 00       	push   $0x7ff000
  800f6c:	50                   	push   %eax
  800f6d:	e8 b8 fd ff ff       	call   800d2a <sys_page_unmap>
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	79 12                	jns    800f8b <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800f79:	50                   	push   %eax
  800f7a:	68 aa 28 80 00       	push   $0x8028aa
  800f7f:	6a 4c                	push   $0x4c
  800f81:	68 6f 28 80 00       	push   $0x80286f
  800f86:	e8 b9 f2 ff ff       	call   800244 <_panic>
	}

	//panic("pgfault not implemented");
}
  800f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800f9b:	68 96 0e 80 00       	push   $0x800e96
  800fa0:	e8 79 10 00 00       	call   80201e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fa5:	b8 07 00 00 00       	mov    $0x7,%eax
  800faa:	cd 30                	int    $0x30
  800fac:	89 c7                	mov    %eax,%edi
  800fae:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	79 15                	jns    800fcd <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800fb8:	50                   	push   %eax
  800fb9:	68 c3 28 80 00       	push   $0x8028c3
  800fbe:	68 a1 00 00 00       	push   $0xa1
  800fc3:	68 6f 28 80 00       	push   $0x80286f
  800fc8:	e8 77 f2 ff ff       	call   800244 <_panic>
  800fcd:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	75 21                	jne    800ff7 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd6:	e8 8c fc ff ff       	call   800c67 <sys_getenvid>
  800fdb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff2:	e9 c8 01 00 00       	jmp    8011bf <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e8 16             	shr    $0x16,%eax
  800ffc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801003:	a8 01                	test   $0x1,%al
  801005:	0f 84 23 01 00 00    	je     80112e <fork+0x19c>
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	c1 e8 0c             	shr    $0xc,%eax
  801010:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801017:	f6 c2 01             	test   $0x1,%dl
  80101a:	0f 84 0e 01 00 00    	je     80112e <fork+0x19c>
  801020:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801027:	f6 c2 04             	test   $0x4,%dl
  80102a:	0f 84 fe 00 00 00    	je     80112e <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  801030:	89 c6                	mov    %eax,%esi
  801032:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  801035:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103c:	f6 c6 04             	test   $0x4,%dh
  80103f:	74 3f                	je     801080 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  801041:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	25 07 0e 00 00       	and    $0xe07,%eax
  801050:	50                   	push   %eax
  801051:	56                   	push   %esi
  801052:	ff 75 e4             	pushl  -0x1c(%ebp)
  801055:	56                   	push   %esi
  801056:	6a 00                	push   $0x0
  801058:	e8 8b fc ff ff       	call   800ce8 <sys_page_map>
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	0f 89 c6 00 00 00    	jns    80112e <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801068:	83 ec 08             	sub    $0x8,%esp
  80106b:	50                   	push   %eax
  80106c:	57                   	push   %edi
  80106d:	6a 00                	push   $0x0
  80106f:	68 00 28 80 00       	push   $0x802800
  801074:	6a 6c                	push   $0x6c
  801076:	68 6f 28 80 00       	push   $0x80286f
  80107b:	e8 c4 f1 ff ff       	call   800244 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801080:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801087:	f6 c2 02             	test   $0x2,%dl
  80108a:	75 0c                	jne    801098 <fork+0x106>
  80108c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801093:	f6 c4 08             	test   $0x8,%ah
  801096:	74 66                	je     8010fe <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	68 05 08 00 00       	push   $0x805
  8010a0:	56                   	push   %esi
  8010a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a4:	56                   	push   %esi
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 3c fc ff ff       	call   800ce8 <sys_page_map>
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 18                	jns    8010cb <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8010b3:	83 ec 08             	sub    $0x8,%esp
  8010b6:	50                   	push   %eax
  8010b7:	57                   	push   %edi
  8010b8:	6a 00                	push   $0x0
  8010ba:	68 00 28 80 00       	push   $0x802800
  8010bf:	6a 74                	push   $0x74
  8010c1:	68 6f 28 80 00       	push   $0x80286f
  8010c6:	e8 79 f1 ff ff       	call   800244 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	68 05 08 00 00       	push   $0x805
  8010d3:	56                   	push   %esi
  8010d4:	6a 00                	push   $0x0
  8010d6:	56                   	push   %esi
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 0a fc ff ff       	call   800ce8 <sys_page_map>
  8010de:	83 c4 20             	add    $0x20,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	79 49                	jns    80112e <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	50                   	push   %eax
  8010e9:	6a 00                	push   $0x0
  8010eb:	6a 00                	push   $0x0
  8010ed:	68 00 28 80 00       	push   $0x802800
  8010f2:	6a 77                	push   $0x77
  8010f4:	68 6f 28 80 00       	push   $0x80286f
  8010f9:	e8 46 f1 ff ff       	call   800244 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	6a 05                	push   $0x5
  801103:	56                   	push   %esi
  801104:	ff 75 e4             	pushl  -0x1c(%ebp)
  801107:	56                   	push   %esi
  801108:	6a 00                	push   $0x0
  80110a:	e8 d9 fb ff ff       	call   800ce8 <sys_page_map>
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	79 18                	jns    80112e <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	50                   	push   %eax
  80111a:	57                   	push   %edi
  80111b:	6a 00                	push   $0x0
  80111d:	68 00 28 80 00       	push   $0x802800
  801122:	6a 7d                	push   $0x7d
  801124:	68 6f 28 80 00       	push   $0x80286f
  801129:	e8 16 f1 ff ff       	call   800244 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  80112e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801134:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80113a:	0f 85 b7 fe ff ff    	jne    800ff7 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	6a 07                	push   $0x7
  801145:	68 00 f0 bf ee       	push   $0xeebff000
  80114a:	57                   	push   %edi
  80114b:	e8 55 fb ff ff       	call   800ca5 <sys_page_alloc>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	79 15                	jns    80116c <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  801157:	50                   	push   %eax
  801158:	68 2c 28 80 00       	push   $0x80282c
  80115d:	68 b4 00 00 00       	push   $0xb4
  801162:	68 6f 28 80 00       	push   $0x80286f
  801167:	e8 d8 f0 ff ff       	call   800244 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	68 92 20 80 00       	push   $0x802092
  801174:	57                   	push   %edi
  801175:	e8 76 fc ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 15                	jns    801196 <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801181:	50                   	push   %eax
  801182:	68 d9 28 80 00       	push   $0x8028d9
  801187:	68 ba 00 00 00       	push   $0xba
  80118c:	68 6f 28 80 00       	push   $0x80286f
  801191:	e8 ae f0 ff ff       	call   800244 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	6a 02                	push   $0x2
  80119b:	57                   	push   %edi
  80119c:	e8 cb fb ff ff       	call   800d6c <sys_env_set_status>
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	79 15                	jns    8011bd <fork+0x22b>
		panic("Sys env set status error: %e", r);
  8011a8:	50                   	push   %eax
  8011a9:	68 f6 28 80 00       	push   $0x8028f6
  8011ae:	68 bf 00 00 00       	push   $0xbf
  8011b3:	68 6f 28 80 00       	push   $0x80286f
  8011b8:	e8 87 f0 ff ff       	call   800244 <_panic>
	}
	return eid;
  8011bd:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011cd:	68 13 29 80 00       	push   $0x802913
  8011d2:	68 ca 00 00 00       	push   $0xca
  8011d7:	68 6f 28 80 00       	push   $0x80286f
  8011dc:	e8 63 f0 ff ff       	call   800244 <_panic>

008011e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	74 3e                	je     801231 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	50                   	push   %eax
  8011f7:	e8 59 fc ff ff       	call   800e55 <sys_ipc_recv>
  8011fc:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 f6                	test   %esi,%esi
  801203:	74 13                	je     801218 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801205:	b8 00 00 00 00       	mov    $0x0,%eax
  80120a:	85 d2                	test   %edx,%edx
  80120c:	75 08                	jne    801216 <ipc_recv+0x35>
  80120e:	a1 04 40 80 00       	mov    0x804004,%eax
  801213:	8b 40 74             	mov    0x74(%eax),%eax
  801216:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801218:	85 db                	test   %ebx,%ebx
  80121a:	74 48                	je     801264 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  80121c:	b8 00 00 00 00       	mov    $0x0,%eax
  801221:	85 d2                	test   %edx,%edx
  801223:	75 08                	jne    80122d <ipc_recv+0x4c>
  801225:	a1 04 40 80 00       	mov    0x804004,%eax
  80122a:	8b 40 78             	mov    0x78(%eax),%eax
  80122d:	89 03                	mov    %eax,(%ebx)
  80122f:	eb 33                	jmp    801264 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801231:	83 ec 0c             	sub    $0xc,%esp
  801234:	68 00 00 c0 ee       	push   $0xeec00000
  801239:	e8 17 fc ff ff       	call   800e55 <sys_ipc_recv>
  80123e:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 f6                	test   %esi,%esi
  801245:	74 13                	je     80125a <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
  80124c:	85 d2                	test   %edx,%edx
  80124e:	75 08                	jne    801258 <ipc_recv+0x77>
  801250:	a1 04 40 80 00       	mov    0x804004,%eax
  801255:	8b 40 74             	mov    0x74(%eax),%eax
  801258:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80125a:	85 db                	test   %ebx,%ebx
  80125c:	74 06                	je     801264 <ipc_recv+0x83>
			*perm_store = 0;
  80125e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801264:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801266:	85 d2                	test   %edx,%edx
  801268:	75 08                	jne    801272 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  80126a:	a1 04 40 80 00       	mov    0x804004,%eax
  80126f:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801272:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	8b 7d 08             	mov    0x8(%ebp),%edi
  801285:	8b 75 0c             	mov    0xc(%ebp),%esi
  801288:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80128b:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  80128d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801292:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801295:	eb 1c                	jmp    8012b3 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801297:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80129a:	74 12                	je     8012ae <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  80129c:	50                   	push   %eax
  80129d:	68 29 29 80 00       	push   $0x802929
  8012a2:	6a 4f                	push   $0x4f
  8012a4:	68 44 29 80 00       	push   $0x802944
  8012a9:	e8 96 ef ff ff       	call   800244 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  8012ae:	e8 d3 f9 ff ff       	call   800c86 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8012b3:	ff 75 14             	pushl  0x14(%ebp)
  8012b6:	53                   	push   %ebx
  8012b7:	56                   	push   %esi
  8012b8:	57                   	push   %edi
  8012b9:	e8 74 fb ff ff       	call   800e32 <sys_ipc_try_send>
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 d2                	js     801297 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8012c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012d8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012db:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012e1:	8b 52 50             	mov    0x50(%edx),%edx
  8012e4:	39 ca                	cmp    %ecx,%edx
  8012e6:	75 0d                	jne    8012f5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8012e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012f0:	8b 40 48             	mov    0x48(%eax),%eax
  8012f3:	eb 0f                	jmp    801304 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012f5:	83 c0 01             	add    $0x1,%eax
  8012f8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012fd:	75 d9                	jne    8012d8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
  80130c:	05 00 00 00 30       	add    $0x30000000,%eax
  801311:	c1 e8 0c             	shr    $0xc,%eax
}
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	05 00 00 00 30       	add    $0x30000000,%eax
  801321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801326:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801333:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801338:	89 c2                	mov    %eax,%edx
  80133a:	c1 ea 16             	shr    $0x16,%edx
  80133d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801344:	f6 c2 01             	test   $0x1,%dl
  801347:	74 11                	je     80135a <fd_alloc+0x2d>
  801349:	89 c2                	mov    %eax,%edx
  80134b:	c1 ea 0c             	shr    $0xc,%edx
  80134e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801355:	f6 c2 01             	test   $0x1,%dl
  801358:	75 09                	jne    801363 <fd_alloc+0x36>
			*fd_store = fd;
  80135a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80135c:	b8 00 00 00 00       	mov    $0x0,%eax
  801361:	eb 17                	jmp    80137a <fd_alloc+0x4d>
  801363:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801368:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80136d:	75 c9                	jne    801338 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80136f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801375:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801382:	83 f8 1f             	cmp    $0x1f,%eax
  801385:	77 36                	ja     8013bd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801387:	c1 e0 0c             	shl    $0xc,%eax
  80138a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80138f:	89 c2                	mov    %eax,%edx
  801391:	c1 ea 16             	shr    $0x16,%edx
  801394:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80139b:	f6 c2 01             	test   $0x1,%dl
  80139e:	74 24                	je     8013c4 <fd_lookup+0x48>
  8013a0:	89 c2                	mov    %eax,%edx
  8013a2:	c1 ea 0c             	shr    $0xc,%edx
  8013a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ac:	f6 c2 01             	test   $0x1,%dl
  8013af:	74 1a                	je     8013cb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bb:	eb 13                	jmp    8013d0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c2:	eb 0c                	jmp    8013d0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c9:	eb 05                	jmp    8013d0 <fd_lookup+0x54>
  8013cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    

008013d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013db:	ba cc 29 80 00       	mov    $0x8029cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e0:	eb 13                	jmp    8013f5 <dev_lookup+0x23>
  8013e2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013e5:	39 08                	cmp    %ecx,(%eax)
  8013e7:	75 0c                	jne    8013f5 <dev_lookup+0x23>
			*dev = devtab[i];
  8013e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f3:	eb 2e                	jmp    801423 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013f5:	8b 02                	mov    (%edx),%eax
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	75 e7                	jne    8013e2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801400:	8b 40 48             	mov    0x48(%eax),%eax
  801403:	83 ec 04             	sub    $0x4,%esp
  801406:	51                   	push   %ecx
  801407:	50                   	push   %eax
  801408:	68 50 29 80 00       	push   $0x802950
  80140d:	e8 0b ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801412:	8b 45 0c             	mov    0xc(%ebp),%eax
  801415:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	83 ec 10             	sub    $0x10,%esp
  80142d:	8b 75 08             	mov    0x8(%ebp),%esi
  801430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80143d:	c1 e8 0c             	shr    $0xc,%eax
  801440:	50                   	push   %eax
  801441:	e8 36 ff ff ff       	call   80137c <fd_lookup>
  801446:	83 c4 08             	add    $0x8,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 05                	js     801452 <fd_close+0x2d>
	    || fd != fd2)
  80144d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801450:	74 0c                	je     80145e <fd_close+0x39>
		return (must_exist ? r : 0);
  801452:	84 db                	test   %bl,%bl
  801454:	ba 00 00 00 00       	mov    $0x0,%edx
  801459:	0f 44 c2             	cmove  %edx,%eax
  80145c:	eb 41                	jmp    80149f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	ff 36                	pushl  (%esi)
  801467:	e8 66 ff ff ff       	call   8013d2 <dev_lookup>
  80146c:	89 c3                	mov    %eax,%ebx
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 1a                	js     80148f <fd_close+0x6a>
		if (dev->dev_close)
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801478:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80147b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801480:	85 c0                	test   %eax,%eax
  801482:	74 0b                	je     80148f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801484:	83 ec 0c             	sub    $0xc,%esp
  801487:	56                   	push   %esi
  801488:	ff d0                	call   *%eax
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	56                   	push   %esi
  801493:	6a 00                	push   $0x0
  801495:	e8 90 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	89 d8                	mov    %ebx,%eax
}
  80149f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	ff 75 08             	pushl  0x8(%ebp)
  8014b3:	e8 c4 fe ff ff       	call   80137c <fd_lookup>
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 10                	js     8014cf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	6a 01                	push   $0x1
  8014c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c7:	e8 59 ff ff ff       	call   801425 <fd_close>
  8014cc:	83 c4 10             	add    $0x10,%esp
}
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <close_all>:

void
close_all(void)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014dd:	83 ec 0c             	sub    $0xc,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	e8 c0 ff ff ff       	call   8014a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e6:	83 c3 01             	add    $0x1,%ebx
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	83 fb 20             	cmp    $0x20,%ebx
  8014ef:	75 ec                	jne    8014dd <close_all+0xc>
		close(i);
}
  8014f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	57                   	push   %edi
  8014fa:	56                   	push   %esi
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 2c             	sub    $0x2c,%esp
  8014ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801502:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	ff 75 08             	pushl  0x8(%ebp)
  801509:	e8 6e fe ff ff       	call   80137c <fd_lookup>
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	0f 88 c1 00 00 00    	js     8015da <dup+0xe4>
		return r;
	close(newfdnum);
  801519:	83 ec 0c             	sub    $0xc,%esp
  80151c:	56                   	push   %esi
  80151d:	e8 84 ff ff ff       	call   8014a6 <close>

	newfd = INDEX2FD(newfdnum);
  801522:	89 f3                	mov    %esi,%ebx
  801524:	c1 e3 0c             	shl    $0xc,%ebx
  801527:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80152d:	83 c4 04             	add    $0x4,%esp
  801530:	ff 75 e4             	pushl  -0x1c(%ebp)
  801533:	e8 de fd ff ff       	call   801316 <fd2data>
  801538:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80153a:	89 1c 24             	mov    %ebx,(%esp)
  80153d:	e8 d4 fd ff ff       	call   801316 <fd2data>
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801548:	89 f8                	mov    %edi,%eax
  80154a:	c1 e8 16             	shr    $0x16,%eax
  80154d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801554:	a8 01                	test   $0x1,%al
  801556:	74 37                	je     80158f <dup+0x99>
  801558:	89 f8                	mov    %edi,%eax
  80155a:	c1 e8 0c             	shr    $0xc,%eax
  80155d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801564:	f6 c2 01             	test   $0x1,%dl
  801567:	74 26                	je     80158f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801569:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801570:	83 ec 0c             	sub    $0xc,%esp
  801573:	25 07 0e 00 00       	and    $0xe07,%eax
  801578:	50                   	push   %eax
  801579:	ff 75 d4             	pushl  -0x2c(%ebp)
  80157c:	6a 00                	push   $0x0
  80157e:	57                   	push   %edi
  80157f:	6a 00                	push   $0x0
  801581:	e8 62 f7 ff ff       	call   800ce8 <sys_page_map>
  801586:	89 c7                	mov    %eax,%edi
  801588:	83 c4 20             	add    $0x20,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 2e                	js     8015bd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801592:	89 d0                	mov    %edx,%eax
  801594:	c1 e8 0c             	shr    $0xc,%eax
  801597:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8015a6:	50                   	push   %eax
  8015a7:	53                   	push   %ebx
  8015a8:	6a 00                	push   $0x0
  8015aa:	52                   	push   %edx
  8015ab:	6a 00                	push   $0x0
  8015ad:	e8 36 f7 ff ff       	call   800ce8 <sys_page_map>
  8015b2:	89 c7                	mov    %eax,%edi
  8015b4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015b7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b9:	85 ff                	test   %edi,%edi
  8015bb:	79 1d                	jns    8015da <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	6a 00                	push   $0x0
  8015c3:	e8 62 f7 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015ce:	6a 00                	push   $0x0
  8015d0:	e8 55 f7 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	89 f8                	mov    %edi,%eax
}
  8015da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dd:	5b                   	pop    %ebx
  8015de:	5e                   	pop    %esi
  8015df:	5f                   	pop    %edi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	e8 86 fd ff ff       	call   80137c <fd_lookup>
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	89 c2                	mov    %eax,%edx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 6d                	js     80166c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801609:	ff 30                	pushl  (%eax)
  80160b:	e8 c2 fd ff ff       	call   8013d2 <dev_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 4c                	js     801663 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801617:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80161a:	8b 42 08             	mov    0x8(%edx),%eax
  80161d:	83 e0 03             	and    $0x3,%eax
  801620:	83 f8 01             	cmp    $0x1,%eax
  801623:	75 21                	jne    801646 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801625:	a1 04 40 80 00       	mov    0x804004,%eax
  80162a:	8b 40 48             	mov    0x48(%eax),%eax
  80162d:	83 ec 04             	sub    $0x4,%esp
  801630:	53                   	push   %ebx
  801631:	50                   	push   %eax
  801632:	68 91 29 80 00       	push   $0x802991
  801637:	e8 e1 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801644:	eb 26                	jmp    80166c <read+0x8a>
	}
	if (!dev->dev_read)
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	8b 40 08             	mov    0x8(%eax),%eax
  80164c:	85 c0                	test   %eax,%eax
  80164e:	74 17                	je     801667 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	ff 75 10             	pushl  0x10(%ebp)
  801656:	ff 75 0c             	pushl  0xc(%ebp)
  801659:	52                   	push   %edx
  80165a:	ff d0                	call   *%eax
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb 09                	jmp    80166c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	89 c2                	mov    %eax,%edx
  801665:	eb 05                	jmp    80166c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801667:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80166c:	89 d0                	mov    %edx,%eax
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	57                   	push   %edi
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80167f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801682:	bb 00 00 00 00       	mov    $0x0,%ebx
  801687:	eb 21                	jmp    8016aa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801689:	83 ec 04             	sub    $0x4,%esp
  80168c:	89 f0                	mov    %esi,%eax
  80168e:	29 d8                	sub    %ebx,%eax
  801690:	50                   	push   %eax
  801691:	89 d8                	mov    %ebx,%eax
  801693:	03 45 0c             	add    0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	57                   	push   %edi
  801698:	e8 45 ff ff ff       	call   8015e2 <read>
		if (m < 0)
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 10                	js     8016b4 <readn+0x41>
			return m;
		if (m == 0)
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	74 0a                	je     8016b2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a8:	01 c3                	add    %eax,%ebx
  8016aa:	39 f3                	cmp    %esi,%ebx
  8016ac:	72 db                	jb     801689 <readn+0x16>
  8016ae:	89 d8                	mov    %ebx,%eax
  8016b0:	eb 02                	jmp    8016b4 <readn+0x41>
  8016b2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5f                   	pop    %edi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 14             	sub    $0x14,%esp
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	53                   	push   %ebx
  8016cb:	e8 ac fc ff ff       	call   80137c <fd_lookup>
  8016d0:	83 c4 08             	add    $0x8,%esp
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 68                	js     801741 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e3:	ff 30                	pushl  (%eax)
  8016e5:	e8 e8 fc ff ff       	call   8013d2 <dev_lookup>
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 47                	js     801738 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f8:	75 21                	jne    80171b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ff:	8b 40 48             	mov    0x48(%eax),%eax
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	53                   	push   %ebx
  801706:	50                   	push   %eax
  801707:	68 ad 29 80 00       	push   $0x8029ad
  80170c:	e8 0c ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801719:	eb 26                	jmp    801741 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80171b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171e:	8b 52 0c             	mov    0xc(%edx),%edx
  801721:	85 d2                	test   %edx,%edx
  801723:	74 17                	je     80173c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	ff 75 10             	pushl  0x10(%ebp)
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	50                   	push   %eax
  80172f:	ff d2                	call   *%edx
  801731:	89 c2                	mov    %eax,%edx
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	eb 09                	jmp    801741 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801738:	89 c2                	mov    %eax,%edx
  80173a:	eb 05                	jmp    801741 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80173c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801741:	89 d0                	mov    %edx,%eax
  801743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <seek>:

int
seek(int fdnum, off_t offset)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80174e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	ff 75 08             	pushl  0x8(%ebp)
  801755:	e8 22 fc ff ff       	call   80137c <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 0e                	js     80176f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801761:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801764:	8b 55 0c             	mov    0xc(%ebp),%edx
  801767:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80176a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	83 ec 14             	sub    $0x14,%esp
  801778:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177e:	50                   	push   %eax
  80177f:	53                   	push   %ebx
  801780:	e8 f7 fb ff ff       	call   80137c <fd_lookup>
  801785:	83 c4 08             	add    $0x8,%esp
  801788:	89 c2                	mov    %eax,%edx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 65                	js     8017f3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801798:	ff 30                	pushl  (%eax)
  80179a:	e8 33 fc ff ff       	call   8013d2 <dev_lookup>
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 44                	js     8017ea <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ad:	75 21                	jne    8017d0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017af:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b4:	8b 40 48             	mov    0x48(%eax),%eax
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	53                   	push   %ebx
  8017bb:	50                   	push   %eax
  8017bc:	68 70 29 80 00       	push   $0x802970
  8017c1:	e8 57 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ce:	eb 23                	jmp    8017f3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d3:	8b 52 18             	mov    0x18(%edx),%edx
  8017d6:	85 d2                	test   %edx,%edx
  8017d8:	74 14                	je     8017ee <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	ff 75 0c             	pushl  0xc(%ebp)
  8017e0:	50                   	push   %eax
  8017e1:	ff d2                	call   *%edx
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	eb 09                	jmp    8017f3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	eb 05                	jmp    8017f3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017f3:	89 d0                	mov    %edx,%eax
  8017f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 14             	sub    $0x14,%esp
  801801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 6c fb ff ff       	call   80137c <fd_lookup>
  801810:	83 c4 08             	add    $0x8,%esp
  801813:	89 c2                	mov    %eax,%edx
  801815:	85 c0                	test   %eax,%eax
  801817:	78 58                	js     801871 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801819:	83 ec 08             	sub    $0x8,%esp
  80181c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801823:	ff 30                	pushl  (%eax)
  801825:	e8 a8 fb ff ff       	call   8013d2 <dev_lookup>
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 37                	js     801868 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801831:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801834:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801838:	74 32                	je     80186c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80183a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801844:	00 00 00 
	stat->st_isdir = 0;
  801847:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184e:	00 00 00 
	stat->st_dev = dev;
  801851:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	53                   	push   %ebx
  80185b:	ff 75 f0             	pushl  -0x10(%ebp)
  80185e:	ff 50 14             	call   *0x14(%eax)
  801861:	89 c2                	mov    %eax,%edx
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	eb 09                	jmp    801871 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801868:	89 c2                	mov    %eax,%edx
  80186a:	eb 05                	jmp    801871 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80186c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801871:	89 d0                	mov    %edx,%eax
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	6a 00                	push   $0x0
  801882:	ff 75 08             	pushl  0x8(%ebp)
  801885:	e8 d6 01 00 00       	call   801a60 <open>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 1b                	js     8018ae <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	ff 75 0c             	pushl  0xc(%ebp)
  801899:	50                   	push   %eax
  80189a:	e8 5b ff ff ff       	call   8017fa <fstat>
  80189f:	89 c6                	mov    %eax,%esi
	close(fd);
  8018a1:	89 1c 24             	mov    %ebx,(%esp)
  8018a4:	e8 fd fb ff ff       	call   8014a6 <close>
	return r;
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	89 f0                	mov    %esi,%eax
}
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	56                   	push   %esi
  8018b9:	53                   	push   %ebx
  8018ba:	89 c6                	mov    %eax,%esi
  8018bc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018be:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018c5:	75 12                	jne    8018d9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	6a 01                	push   $0x1
  8018cc:	e8 fc f9 ff ff       	call   8012cd <ipc_find_env>
  8018d1:	a3 00 40 80 00       	mov    %eax,0x804000
  8018d6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d9:	6a 07                	push   $0x7
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	56                   	push   %esi
  8018e1:	ff 35 00 40 80 00    	pushl  0x804000
  8018e7:	e8 8d f9 ff ff       	call   801279 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ec:	83 c4 0c             	add    $0xc,%esp
  8018ef:	6a 00                	push   $0x0
  8018f1:	53                   	push   %ebx
  8018f2:	6a 00                	push   $0x0
  8018f4:	e8 e8 f8 ff ff       	call   8011e1 <ipc_recv>
}
  8018f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	8b 40 0c             	mov    0xc(%eax),%eax
  80190c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801911:	8b 45 0c             	mov    0xc(%ebp),%eax
  801914:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
  80191e:	b8 02 00 00 00       	mov    $0x2,%eax
  801923:	e8 8d ff ff ff       	call   8018b5 <fsipc>
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8b 40 0c             	mov    0xc(%eax),%eax
  801936:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80193b:	ba 00 00 00 00       	mov    $0x0,%edx
  801940:	b8 06 00 00 00       	mov    $0x6,%eax
  801945:	e8 6b ff ff ff       	call   8018b5 <fsipc>
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	53                   	push   %ebx
  801950:	83 ec 04             	sub    $0x4,%esp
  801953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801956:	8b 45 08             	mov    0x8(%ebp),%eax
  801959:	8b 40 0c             	mov    0xc(%eax),%eax
  80195c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801961:	ba 00 00 00 00       	mov    $0x0,%edx
  801966:	b8 05 00 00 00       	mov    $0x5,%eax
  80196b:	e8 45 ff ff ff       	call   8018b5 <fsipc>
  801970:	85 c0                	test   %eax,%eax
  801972:	78 2c                	js     8019a0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	68 00 50 80 00       	push   $0x805000
  80197c:	53                   	push   %ebx
  80197d:	e8 20 ef ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801982:	a1 80 50 80 00       	mov    0x805080,%eax
  801987:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80198d:	a1 84 50 80 00       	mov    0x805084,%eax
  801992:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8019b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8019b4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019ba:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8019bf:	50                   	push   %eax
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	68 08 50 80 00       	push   $0x805008
  8019c8:	e8 67 f0 ff ff       	call   800a34 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d7:	e8 d9 fe ff ff       	call   8018b5 <fsipc>
	//panic("devfile_write not implemented");
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801a01:	e8 af fe ff ff       	call   8018b5 <fsipc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 4b                	js     801a57 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a0c:	39 c6                	cmp    %eax,%esi
  801a0e:	73 16                	jae    801a26 <devfile_read+0x48>
  801a10:	68 dc 29 80 00       	push   $0x8029dc
  801a15:	68 e3 29 80 00       	push   $0x8029e3
  801a1a:	6a 7c                	push   $0x7c
  801a1c:	68 f8 29 80 00       	push   $0x8029f8
  801a21:	e8 1e e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a2b:	7e 16                	jle    801a43 <devfile_read+0x65>
  801a2d:	68 03 2a 80 00       	push   $0x802a03
  801a32:	68 e3 29 80 00       	push   $0x8029e3
  801a37:	6a 7d                	push   $0x7d
  801a39:	68 f8 29 80 00       	push   $0x8029f8
  801a3e:	e8 01 e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a43:	83 ec 04             	sub    $0x4,%esp
  801a46:	50                   	push   %eax
  801a47:	68 00 50 80 00       	push   $0x805000
  801a4c:	ff 75 0c             	pushl  0xc(%ebp)
  801a4f:	e8 e0 ef ff ff       	call   800a34 <memmove>
	return r;
  801a54:	83 c4 10             	add    $0x10,%esp
}
  801a57:	89 d8                	mov    %ebx,%eax
  801a59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	53                   	push   %ebx
  801a64:	83 ec 20             	sub    $0x20,%esp
  801a67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a6a:	53                   	push   %ebx
  801a6b:	e8 f9 ed ff ff       	call   800869 <strlen>
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a78:	7f 67                	jg     801ae1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a80:	50                   	push   %eax
  801a81:	e8 a7 f8 ff ff       	call   80132d <fd_alloc>
  801a86:	83 c4 10             	add    $0x10,%esp
		return r;
  801a89:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 57                	js     801ae6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	53                   	push   %ebx
  801a93:	68 00 50 80 00       	push   $0x805000
  801a98:	e8 05 ee ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa8:	b8 01 00 00 00       	mov    $0x1,%eax
  801aad:	e8 03 fe ff ff       	call   8018b5 <fsipc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	79 14                	jns    801acf <open+0x6f>
		fd_close(fd, 0);
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	6a 00                	push   $0x0
  801ac0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac3:	e8 5d f9 ff ff       	call   801425 <fd_close>
		return r;
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	89 da                	mov    %ebx,%edx
  801acd:	eb 17                	jmp    801ae6 <open+0x86>
	}

	return fd2num(fd);
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad5:	e8 2c f8 ff ff       	call   801306 <fd2num>
  801ada:	89 c2                	mov    %eax,%edx
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	eb 05                	jmp    801ae6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ae1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ae6:	89 d0                	mov    %edx,%eax
  801ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801af3:	ba 00 00 00 00       	mov    $0x0,%edx
  801af8:	b8 08 00 00 00       	mov    $0x8,%eax
  801afd:	e8 b3 fd ff ff       	call   8018b5 <fsipc>
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0a:	89 d0                	mov    %edx,%eax
  801b0c:	c1 e8 16             	shr    $0x16,%eax
  801b0f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1b:	f6 c1 01             	test   $0x1,%cl
  801b1e:	74 1d                	je     801b3d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b20:	c1 ea 0c             	shr    $0xc,%edx
  801b23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2a:	f6 c2 01             	test   $0x1,%dl
  801b2d:	74 0e                	je     801b3d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2f:	c1 ea 0c             	shr    $0xc,%edx
  801b32:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b39:	ef 
  801b3a:	0f b7 c0             	movzwl %ax,%eax
}
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	ff 75 08             	pushl  0x8(%ebp)
  801b4d:	e8 c4 f7 ff ff       	call   801316 <fd2data>
  801b52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b54:	83 c4 08             	add    $0x8,%esp
  801b57:	68 0f 2a 80 00       	push   $0x802a0f
  801b5c:	53                   	push   %ebx
  801b5d:	e8 40 ed ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b62:	8b 46 04             	mov    0x4(%esi),%eax
  801b65:	2b 06                	sub    (%esi),%eax
  801b67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b74:	00 00 00 
	stat->st_dev = &devpipe;
  801b77:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b7e:	30 80 00 
	return 0;
}
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	53                   	push   %ebx
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b97:	53                   	push   %ebx
  801b98:	6a 00                	push   $0x0
  801b9a:	e8 8b f1 ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9f:	89 1c 24             	mov    %ebx,(%esp)
  801ba2:	e8 6f f7 ff ff       	call   801316 <fd2data>
  801ba7:	83 c4 08             	add    $0x8,%esp
  801baa:	50                   	push   %eax
  801bab:	6a 00                	push   $0x0
  801bad:	e8 78 f1 ff ff       	call   800d2a <sys_page_unmap>
}
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	57                   	push   %edi
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 1c             	sub    $0x1c,%esp
  801bc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bc3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bc5:	a1 04 40 80 00       	mov    0x804004,%eax
  801bca:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bcd:	83 ec 0c             	sub    $0xc,%esp
  801bd0:	ff 75 e0             	pushl  -0x20(%ebp)
  801bd3:	e8 2c ff ff ff       	call   801b04 <pageref>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	89 3c 24             	mov    %edi,(%esp)
  801bdd:	e8 22 ff ff ff       	call   801b04 <pageref>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	39 c3                	cmp    %eax,%ebx
  801be7:	0f 94 c1             	sete   %cl
  801bea:	0f b6 c9             	movzbl %cl,%ecx
  801bed:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bf0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bf6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bf9:	39 ce                	cmp    %ecx,%esi
  801bfb:	74 1b                	je     801c18 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bfd:	39 c3                	cmp    %eax,%ebx
  801bff:	75 c4                	jne    801bc5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c01:	8b 42 58             	mov    0x58(%edx),%eax
  801c04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c07:	50                   	push   %eax
  801c08:	56                   	push   %esi
  801c09:	68 16 2a 80 00       	push   $0x802a16
  801c0e:	e8 0a e7 ff ff       	call   80031d <cprintf>
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	eb ad                	jmp    801bc5 <_pipeisclosed+0xe>
	}
}
  801c18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5f                   	pop    %edi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	57                   	push   %edi
  801c27:	56                   	push   %esi
  801c28:	53                   	push   %ebx
  801c29:	83 ec 28             	sub    $0x28,%esp
  801c2c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c2f:	56                   	push   %esi
  801c30:	e8 e1 f6 ff ff       	call   801316 <fd2data>
  801c35:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c3f:	eb 4b                	jmp    801c8c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c41:	89 da                	mov    %ebx,%edx
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	e8 6d ff ff ff       	call   801bb7 <_pipeisclosed>
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	75 48                	jne    801c96 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c4e:	e8 33 f0 ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c53:	8b 43 04             	mov    0x4(%ebx),%eax
  801c56:	8b 0b                	mov    (%ebx),%ecx
  801c58:	8d 51 20             	lea    0x20(%ecx),%edx
  801c5b:	39 d0                	cmp    %edx,%eax
  801c5d:	73 e2                	jae    801c41 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c62:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c66:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	c1 fa 1f             	sar    $0x1f,%edx
  801c6e:	89 d1                	mov    %edx,%ecx
  801c70:	c1 e9 1b             	shr    $0x1b,%ecx
  801c73:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c76:	83 e2 1f             	and    $0x1f,%edx
  801c79:	29 ca                	sub    %ecx,%edx
  801c7b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c7f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c83:	83 c0 01             	add    $0x1,%eax
  801c86:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c89:	83 c7 01             	add    $0x1,%edi
  801c8c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c8f:	75 c2                	jne    801c53 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c91:	8b 45 10             	mov    0x10(%ebp),%eax
  801c94:	eb 05                	jmp    801c9b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c96:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5f                   	pop    %edi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 18             	sub    $0x18,%esp
  801cac:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801caf:	57                   	push   %edi
  801cb0:	e8 61 f6 ff ff       	call   801316 <fd2data>
  801cb5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cbf:	eb 3d                	jmp    801cfe <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cc1:	85 db                	test   %ebx,%ebx
  801cc3:	74 04                	je     801cc9 <devpipe_read+0x26>
				return i;
  801cc5:	89 d8                	mov    %ebx,%eax
  801cc7:	eb 44                	jmp    801d0d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cc9:	89 f2                	mov    %esi,%edx
  801ccb:	89 f8                	mov    %edi,%eax
  801ccd:	e8 e5 fe ff ff       	call   801bb7 <_pipeisclosed>
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	75 32                	jne    801d08 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cd6:	e8 ab ef ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cdb:	8b 06                	mov    (%esi),%eax
  801cdd:	3b 46 04             	cmp    0x4(%esi),%eax
  801ce0:	74 df                	je     801cc1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce2:	99                   	cltd   
  801ce3:	c1 ea 1b             	shr    $0x1b,%edx
  801ce6:	01 d0                	add    %edx,%eax
  801ce8:	83 e0 1f             	and    $0x1f,%eax
  801ceb:	29 d0                	sub    %edx,%eax
  801ced:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cf8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfb:	83 c3 01             	add    $0x1,%ebx
  801cfe:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d01:	75 d8                	jne    801cdb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d03:	8b 45 10             	mov    0x10(%ebp),%eax
  801d06:	eb 05                	jmp    801d0d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	e8 07 f6 ff ff       	call   80132d <fd_alloc>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	89 c2                	mov    %eax,%edx
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	0f 88 2c 01 00 00    	js     801e5f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	68 07 04 00 00       	push   $0x407
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 60 ef ff ff       	call   800ca5 <sys_page_alloc>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	89 c2                	mov    %eax,%edx
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	0f 88 0d 01 00 00    	js     801e5f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	e8 cf f5 ff ff       	call   80132d <fd_alloc>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	0f 88 e2 00 00 00    	js     801e4d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	68 07 04 00 00       	push   $0x407
  801d73:	ff 75 f0             	pushl  -0x10(%ebp)
  801d76:	6a 00                	push   $0x0
  801d78:	e8 28 ef ff ff       	call   800ca5 <sys_page_alloc>
  801d7d:	89 c3                	mov    %eax,%ebx
  801d7f:	83 c4 10             	add    $0x10,%esp
  801d82:	85 c0                	test   %eax,%eax
  801d84:	0f 88 c3 00 00 00    	js     801e4d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d8a:	83 ec 0c             	sub    $0xc,%esp
  801d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d90:	e8 81 f5 ff ff       	call   801316 <fd2data>
  801d95:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d97:	83 c4 0c             	add    $0xc,%esp
  801d9a:	68 07 04 00 00       	push   $0x407
  801d9f:	50                   	push   %eax
  801da0:	6a 00                	push   $0x0
  801da2:	e8 fe ee ff ff       	call   800ca5 <sys_page_alloc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 89 00 00 00    	js     801e3d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dba:	e8 57 f5 ff ff       	call   801316 <fd2data>
  801dbf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dc6:	50                   	push   %eax
  801dc7:	6a 00                	push   $0x0
  801dc9:	56                   	push   %esi
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 17 ef ff ff       	call   800ce8 <sys_page_map>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 20             	add    $0x20,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 55                	js     801e2f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801def:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	e8 f7 f4 ff ff       	call   801306 <fd2num>
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e12:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e14:	83 c4 04             	add    $0x4,%esp
  801e17:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1a:	e8 e7 f4 ff ff       	call   801306 <fd2num>
  801e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e22:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2d:	eb 30                	jmp    801e5f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	56                   	push   %esi
  801e33:	6a 00                	push   $0x0
  801e35:	e8 f0 ee ff ff       	call   800d2a <sys_page_unmap>
  801e3a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	ff 75 f0             	pushl  -0x10(%ebp)
  801e43:	6a 00                	push   $0x0
  801e45:	e8 e0 ee ff ff       	call   800d2a <sys_page_unmap>
  801e4a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e4d:	83 ec 08             	sub    $0x8,%esp
  801e50:	ff 75 f4             	pushl  -0xc(%ebp)
  801e53:	6a 00                	push   $0x0
  801e55:	e8 d0 ee ff ff       	call   800d2a <sys_page_unmap>
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e5f:	89 d0                	mov    %edx,%eax
  801e61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e71:	50                   	push   %eax
  801e72:	ff 75 08             	pushl  0x8(%ebp)
  801e75:	e8 02 f5 ff ff       	call   80137c <fd_lookup>
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 18                	js     801e99 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	ff 75 f4             	pushl  -0xc(%ebp)
  801e87:	e8 8a f4 ff ff       	call   801316 <fd2data>
	return _pipeisclosed(fd, p);
  801e8c:	89 c2                	mov    %eax,%edx
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	e8 21 fd ff ff       	call   801bb7 <_pipeisclosed>
  801e96:	83 c4 10             	add    $0x10,%esp
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eab:	68 2e 2a 80 00       	push   $0x802a2e
  801eb0:	ff 75 0c             	pushl  0xc(%ebp)
  801eb3:	e8 ea e9 ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	57                   	push   %edi
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ecb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ed6:	eb 2d                	jmp    801f05 <devcons_write+0x46>
		m = n - tot;
  801ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801edb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801edd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ee5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	53                   	push   %ebx
  801eec:	03 45 0c             	add    0xc(%ebp),%eax
  801eef:	50                   	push   %eax
  801ef0:	57                   	push   %edi
  801ef1:	e8 3e eb ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  801ef6:	83 c4 08             	add    $0x8,%esp
  801ef9:	53                   	push   %ebx
  801efa:	57                   	push   %edi
  801efb:	e8 e9 ec ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f00:	01 de                	add    %ebx,%esi
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	89 f0                	mov    %esi,%eax
  801f07:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f0a:	72 cc                	jb     801ed8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 08             	sub    $0x8,%esp
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f23:	74 2a                	je     801f4f <devcons_read+0x3b>
  801f25:	eb 05                	jmp    801f2c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f27:	e8 5a ed ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f2c:	e8 d6 ec ff ff       	call   800c07 <sys_cgetc>
  801f31:	85 c0                	test   %eax,%eax
  801f33:	74 f2                	je     801f27 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f35:	85 c0                	test   %eax,%eax
  801f37:	78 16                	js     801f4f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f39:	83 f8 04             	cmp    $0x4,%eax
  801f3c:	74 0c                	je     801f4a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f41:	88 02                	mov    %al,(%edx)
	return 1;
  801f43:	b8 01 00 00 00       	mov    $0x1,%eax
  801f48:	eb 05                	jmp    801f4f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f5d:	6a 01                	push   $0x1
  801f5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	e8 81 ec ff ff       	call   800be9 <sys_cputs>
}
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    

00801f6d <getchar>:

int
getchar(void)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f73:	6a 01                	push   $0x1
  801f75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	6a 00                	push   $0x0
  801f7b:	e8 62 f6 ff ff       	call   8015e2 <read>
	if (r < 0)
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 0f                	js     801f96 <getchar+0x29>
		return r;
	if (r < 1)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	7e 06                	jle    801f91 <getchar+0x24>
		return -E_EOF;
	return c;
  801f8b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f8f:	eb 05                	jmp    801f96 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f91:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    

00801f98 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa1:	50                   	push   %eax
  801fa2:	ff 75 08             	pushl  0x8(%ebp)
  801fa5:	e8 d2 f3 ff ff       	call   80137c <fd_lookup>
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 11                	js     801fc2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fba:	39 10                	cmp    %edx,(%eax)
  801fbc:	0f 94 c0             	sete   %al
  801fbf:	0f b6 c0             	movzbl %al,%eax
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <opencons>:

int
opencons(void)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcd:	50                   	push   %eax
  801fce:	e8 5a f3 ff ff       	call   80132d <fd_alloc>
  801fd3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fd6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 3e                	js     80201a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdc:	83 ec 04             	sub    $0x4,%esp
  801fdf:	68 07 04 00 00       	push   $0x407
  801fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 b7 ec ff ff       	call   800ca5 <sys_page_alloc>
  801fee:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 23                	js     80201a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802000:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802005:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	50                   	push   %eax
  802010:	e8 f1 f2 ff ff       	call   801306 <fd2num>
  802015:	89 c2                	mov    %eax,%edx
  802017:	83 c4 10             	add    $0x10,%esp
}
  80201a:	89 d0                	mov    %edx,%eax
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	53                   	push   %ebx
  802022:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802025:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80202c:	75 57                	jne    802085 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  80202e:	e8 34 ec ff ff       	call   800c67 <sys_getenvid>
  802033:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  802035:	83 ec 04             	sub    $0x4,%esp
  802038:	6a 07                	push   $0x7
  80203a:	68 00 f0 bf ee       	push   $0xeebff000
  80203f:	50                   	push   %eax
  802040:	e8 60 ec ff ff       	call   800ca5 <sys_page_alloc>
		if (r) {
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	74 12                	je     80205e <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  80204c:	50                   	push   %eax
  80204d:	68 7a 28 80 00       	push   $0x80287a
  802052:	6a 25                	push   $0x25
  802054:	68 3a 2a 80 00       	push   $0x802a3a
  802059:	e8 e6 e1 ff ff       	call   800244 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  80205e:	83 ec 08             	sub    $0x8,%esp
  802061:	68 92 20 80 00       	push   $0x802092
  802066:	53                   	push   %ebx
  802067:	e8 84 ed ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
		if (r) {
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	85 c0                	test   %eax,%eax
  802071:	74 12                	je     802085 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  802073:	50                   	push   %eax
  802074:	68 48 2a 80 00       	push   $0x802a48
  802079:	6a 2b                	push   $0x2b
  80207b:	68 3a 2a 80 00       	push   $0x802a3a
  802080:	e8 bf e1 ff ff       	call   800244 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802085:	8b 45 08             	mov    0x8(%ebp),%eax
  802088:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80208d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802090:	c9                   	leave  
  802091:	c3                   	ret    

00802092 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802092:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802093:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802098:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80209a:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  80209d:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  8020a1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  8020a6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  8020aa:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  8020ac:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  8020af:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  8020b0:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  8020b3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  8020b4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  8020b5:	c3                   	ret    
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020dd:	89 ca                	mov    %ecx,%edx
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	75 3d                	jne    802120 <__udivdi3+0x60>
  8020e3:	39 cf                	cmp    %ecx,%edi
  8020e5:	0f 87 c5 00 00 00    	ja     8021b0 <__udivdi3+0xf0>
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	89 fd                	mov    %edi,%ebp
  8020ef:	75 0b                	jne    8020fc <__udivdi3+0x3c>
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	31 d2                	xor    %edx,%edx
  8020f8:	f7 f7                	div    %edi
  8020fa:	89 c5                	mov    %eax,%ebp
  8020fc:	89 c8                	mov    %ecx,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f5                	div    %ebp
  802102:	89 c1                	mov    %eax,%ecx
  802104:	89 d8                	mov    %ebx,%eax
  802106:	89 cf                	mov    %ecx,%edi
  802108:	f7 f5                	div    %ebp
  80210a:	89 c3                	mov    %eax,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 ce                	cmp    %ecx,%esi
  802122:	77 74                	ja     802198 <__udivdi3+0xd8>
  802124:	0f bd fe             	bsr    %esi,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0x108>
  802130:	bb 20 00 00 00       	mov    $0x20,%ebx
  802135:	89 f9                	mov    %edi,%ecx
  802137:	89 c5                	mov    %eax,%ebp
  802139:	29 fb                	sub    %edi,%ebx
  80213b:	d3 e6                	shl    %cl,%esi
  80213d:	89 d9                	mov    %ebx,%ecx
  80213f:	d3 ed                	shr    %cl,%ebp
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e0                	shl    %cl,%eax
  802145:	09 ee                	or     %ebp,%esi
  802147:	89 d9                	mov    %ebx,%ecx
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 d5                	mov    %edx,%ebp
  80214f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802153:	d3 ed                	shr    %cl,%ebp
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e2                	shl    %cl,%edx
  802159:	89 d9                	mov    %ebx,%ecx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	09 c2                	or     %eax,%edx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	89 ea                	mov    %ebp,%edx
  802163:	f7 f6                	div    %esi
  802165:	89 d5                	mov    %edx,%ebp
  802167:	89 c3                	mov    %eax,%ebx
  802169:	f7 64 24 0c          	mull   0xc(%esp)
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	72 10                	jb     802181 <__udivdi3+0xc1>
  802171:	8b 74 24 08          	mov    0x8(%esp),%esi
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e6                	shl    %cl,%esi
  802179:	39 c6                	cmp    %eax,%esi
  80217b:	73 07                	jae    802184 <__udivdi3+0xc4>
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	75 03                	jne    802184 <__udivdi3+0xc4>
  802181:	83 eb 01             	sub    $0x1,%ebx
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 d8                	mov    %ebx,%eax
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	31 db                	xor    %ebx,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	f7 f7                	div    %edi
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 c3                	mov    %eax,%ebx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 fa                	mov    %edi,%edx
  8021bc:	83 c4 1c             	add    $0x1c,%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	39 ce                	cmp    %ecx,%esi
  8021ca:	72 0c                	jb     8021d8 <__udivdi3+0x118>
  8021cc:	31 db                	xor    %ebx,%ebx
  8021ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021d2:	0f 87 34 ff ff ff    	ja     80210c <__udivdi3+0x4c>
  8021d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021dd:	e9 2a ff ff ff       	jmp    80210c <__udivdi3+0x4c>
  8021e2:	66 90                	xchg   %ax,%ax
  8021e4:	66 90                	xchg   %ax,%ax
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 d2                	test   %edx,%edx
  802209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f3                	mov    %esi,%ebx
  802213:	89 3c 24             	mov    %edi,(%esp)
  802216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221a:	75 1c                	jne    802238 <__umoddi3+0x48>
  80221c:	39 f7                	cmp    %esi,%edi
  80221e:	76 50                	jbe    802270 <__umoddi3+0x80>
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	f7 f7                	div    %edi
  802226:	89 d0                	mov    %edx,%eax
  802228:	31 d2                	xor    %edx,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	89 d0                	mov    %edx,%eax
  80223c:	77 52                	ja     802290 <__umoddi3+0xa0>
  80223e:	0f bd ea             	bsr    %edx,%ebp
  802241:	83 f5 1f             	xor    $0x1f,%ebp
  802244:	75 5a                	jne    8022a0 <__umoddi3+0xb0>
  802246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	39 0c 24             	cmp    %ecx,(%esp)
  802253:	0f 86 d7 00 00 00    	jbe    802330 <__umoddi3+0x140>
  802259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	85 ff                	test   %edi,%edi
  802272:	89 fd                	mov    %edi,%ebp
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 f0                	mov    %esi,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 c8                	mov    %ecx,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	eb 99                	jmp    802228 <__umoddi3+0x38>
  80228f:	90                   	nop
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 1c             	add    $0x1c,%esp
  802297:	5b                   	pop    %ebx
  802298:	5e                   	pop    %esi
  802299:	5f                   	pop    %edi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	8b 34 24             	mov    (%esp),%esi
  8022a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	29 ef                	sub    %ebp,%edi
  8022ac:	d3 e0                	shl    %cl,%eax
  8022ae:	89 f9                	mov    %edi,%ecx
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	d3 ea                	shr    %cl,%edx
  8022b4:	89 e9                	mov    %ebp,%ecx
  8022b6:	09 c2                	or     %eax,%edx
  8022b8:	89 d8                	mov    %ebx,%eax
  8022ba:	89 14 24             	mov    %edx,(%esp)
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	d3 e2                	shl    %cl,%edx
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	89 c6                	mov    %eax,%esi
  8022d1:	d3 e3                	shl    %cl,%ebx
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	09 d8                	or     %ebx,%eax
  8022dd:	89 d3                	mov    %edx,%ebx
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	f7 34 24             	divl   (%esp)
  8022e4:	89 d6                	mov    %edx,%esi
  8022e6:	d3 e3                	shl    %cl,%ebx
  8022e8:	f7 64 24 04          	mull   0x4(%esp)
  8022ec:	39 d6                	cmp    %edx,%esi
  8022ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022f2:	89 d1                	mov    %edx,%ecx
  8022f4:	89 c3                	mov    %eax,%ebx
  8022f6:	72 08                	jb     802300 <__umoddi3+0x110>
  8022f8:	75 11                	jne    80230b <__umoddi3+0x11b>
  8022fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022fe:	73 0b                	jae    80230b <__umoddi3+0x11b>
  802300:	2b 44 24 04          	sub    0x4(%esp),%eax
  802304:	1b 14 24             	sbb    (%esp),%edx
  802307:	89 d1                	mov    %edx,%ecx
  802309:	89 c3                	mov    %eax,%ebx
  80230b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80230f:	29 da                	sub    %ebx,%edx
  802311:	19 ce                	sbb    %ecx,%esi
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e0                	shl    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	d3 ea                	shr    %cl,%edx
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 ee                	shr    %cl,%esi
  802321:	09 d0                	or     %edx,%eax
  802323:	89 f2                	mov    %esi,%edx
  802325:	83 c4 1c             	add    $0x1c,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5f                   	pop    %edi
  80232b:	5d                   	pop    %ebp
  80232c:	c3                   	ret    
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 f9                	sub    %edi,%ecx
  802332:	19 d6                	sbb    %edx,%esi
  802334:	89 74 24 04          	mov    %esi,0x4(%esp)
  802338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233c:	e9 18 ff ff ff       	jmp    802259 <__umoddi3+0x69>
