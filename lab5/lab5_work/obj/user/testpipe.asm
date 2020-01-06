
obj/user/testpipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 80 	movl   $0x802480,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 35 1c 00 00       	call   801c83 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 8c 24 80 00       	push   $0x80248c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 95 24 80 00       	push   $0x802495
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 f2 0f 00 00       	call   801060 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 a5 24 80 00       	push   $0x8024a5
  80007a:	6a 11                	push   $0x11
  80007c:	68 95 24 80 00       	push   $0x802495
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ae 24 80 00       	push   $0x8024ae
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 9d 13 00 00       	call   80144f <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 cb 24 80 00       	push   $0x8024cb
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 40 15 00 00       	call   80161c <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 e8 24 80 00       	push   $0x8024e8
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 95 24 80 00       	push   $0x802495
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 0c 09 00 00       	call   800a1a <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 f1 24 80 00       	push   $0x8024f1
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 0d 25 80 00       	push   $0x80250d
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ae 24 80 00       	push   $0x8024ae
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 e5 12 00 00       	call   80144f <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 20 25 80 00       	push   $0x802520
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 a6 07 00 00       	call   800937 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 c2 14 00 00       	call   801665 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 84 07 00 00       	call   800937 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 3d 25 80 00       	push   $0x80253d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 95 24 80 00       	push   $0x802495
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 78 12 00 00       	call   80144f <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 26 1c 00 00       	call   801e09 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 47 	movl   $0x802547,0x803004
  8001ea:	25 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 8b 1a 00 00       	call   801c83 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 8c 24 80 00       	push   $0x80248c
  800207:	6a 2c                	push   $0x2c
  800209:	68 95 24 80 00       	push   $0x802495
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 48 0e 00 00       	call   801060 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 a5 24 80 00       	push   $0x8024a5
  800224:	6a 2f                	push   $0x2f
  800226:	68 95 24 80 00       	push   $0x802495
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 10 12 00 00       	call   80144f <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 54 25 80 00       	push   $0x802554
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 56 25 80 00       	push   $0x802556
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 04 14 00 00       	call   801665 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 58 25 80 00       	push   $0x802558
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 c6 11 00 00       	call   80144f <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 bb 11 00 00       	call   80144f <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 6d 1b 00 00       	call   801e09 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 75 25 80 00 	movl   $0x802575,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 73 0a 00 00       	call   800d35 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 77 11 00 00       	call   80147a <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 e7 09 00 00       	call   800cf4 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 10 0a 00 00       	call   800d35 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 d8 25 80 00       	push   $0x8025d8
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 c9 24 80 00 	movl   $0x8024c9,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 2f 09 00 00       	call   800cb7 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 54 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 d4 08 00 00       	call   800cb7 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 8d 1d 00 00       	call   8021e0 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 7a 1e 00 00       	call   802310 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 fb 25 80 00 	movsbl 0x8025fb(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b1:	83 fa 01             	cmp    $0x1,%edx
  8004b4:	7e 0e                	jle    8004c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b6:	8b 10                	mov    (%eax),%edx
  8004b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bb:	89 08                	mov    %ecx,(%eax)
  8004bd:	8b 02                	mov    (%edx),%eax
  8004bf:	8b 52 04             	mov    0x4(%edx),%edx
  8004c2:	eb 22                	jmp    8004e6 <getuint+0x38>
	else if (lflag)
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 10                	je     8004d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	eb 0e                	jmp    8004e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d8:	8b 10                	mov    (%eax),%edx
  8004da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dd:	89 08                	mov    %ecx,(%eax)
  8004df:	8b 02                	mov    (%edx),%eax
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
	va_end(ap);
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 2c             	sub    $0x2c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	eb 12                	jmp    800548 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800536:	85 c0                	test   %eax,%eax
  800538:	0f 84 89 03 00 00    	je     8008c7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	50                   	push   %eax
  800543:	ff d6                	call   *%esi
  800545:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800548:	83 c7 01             	add    $0x1,%edi
  80054b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e2                	jne    800536 <vprintfmt+0x14>
  800554:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800566:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 07                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800577:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8d 47 01             	lea    0x1(%edi),%eax
  80057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800581:	0f b6 07             	movzbl (%edi),%eax
  800584:	0f b6 c8             	movzbl %al,%ecx
  800587:	83 e8 23             	sub    $0x23,%eax
  80058a:	3c 55                	cmp    $0x55,%al
  80058c:	0f 87 1a 03 00 00    	ja     8008ac <vprintfmt+0x38a>
  800592:	0f b6 c0             	movzbl %al,%eax
  800595:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a3:	eb d6                	jmp    80057b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bd:	83 fa 09             	cmp    $0x9,%edx
  8005c0:	77 39                	ja     8005fb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c5:	eb e9                	jmp    8005b0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d8:	eb 27                	jmp    800601 <vprintfmt+0xdf>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	0f 49 c8             	cmovns %eax,%ecx
  8005e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ed:	eb 8c                	jmp    80057b <vprintfmt+0x59>
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f9:	eb 80                	jmp    80057b <vprintfmt+0x59>
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 89 70 ff ff ff    	jns    80057b <vprintfmt+0x59>
				width = precision, precision = -1;
  80060b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800611:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800618:	e9 5e ff ff ff       	jmp    80057b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800623:	e9 53 ff ff ff       	jmp    80057b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	ff 30                	pushl  (%eax)
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063f:	e9 04 ff ff ff       	jmp    800548 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	99                   	cltd   
  800650:	31 d0                	xor    %edx,%eax
  800652:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800654:	83 f8 0f             	cmp    $0xf,%eax
  800657:	7f 0b                	jg     800664 <vprintfmt+0x142>
  800659:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800660:	85 d2                	test   %edx,%edx
  800662:	75 18                	jne    80067c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800664:	50                   	push   %eax
  800665:	68 13 26 80 00       	push   $0x802613
  80066a:	53                   	push   %ebx
  80066b:	56                   	push   %esi
  80066c:	e8 94 fe ff ff       	call   800505 <printfmt>
  800671:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800677:	e9 cc fe ff ff       	jmp    800548 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067c:	52                   	push   %edx
  80067d:	68 51 2b 80 00       	push   $0x802b51
  800682:	53                   	push   %ebx
  800683:	56                   	push   %esi
  800684:	e8 7c fe ff ff       	call   800505 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	e9 b4 fe ff ff       	jmp    800548 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069f:	85 ff                	test   %edi,%edi
  8006a1:	b8 0c 26 80 00       	mov    $0x80260c,%eax
  8006a6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	0f 8e 94 00 00 00    	jle    800747 <vprintfmt+0x225>
  8006b3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b7:	0f 84 98 00 00 00    	je     800755 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c3:	57                   	push   %edi
  8006c4:	e8 86 02 00 00       	call   80094f <strnlen>
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 c1                	sub    %eax,%ecx
  8006ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006de:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	eb 0f                	jmp    8006f1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 ff                	test   %edi,%edi
  8006f3:	7f ed                	jg     8006e2 <vprintfmt+0x1c0>
  8006f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800702:	0f 49 c1             	cmovns %ecx,%eax
  800705:	29 c1                	sub    %eax,%ecx
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	89 cb                	mov    %ecx,%ebx
  800712:	eb 4d                	jmp    800761 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	74 1b                	je     800735 <vprintfmt+0x213>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 10                	jbe    800735 <vprintfmt+0x213>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff 55 08             	call   *0x8(%ebp)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 0d                	jmp    800742 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	52                   	push   %edx
  80073c:	ff 55 08             	call   *0x8(%ebp)
  80073f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	83 eb 01             	sub    $0x1,%ebx
  800745:	eb 1a                	jmp    800761 <vprintfmt+0x23f>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb 0c                	jmp    800761 <vprintfmt+0x23f>
  800755:	89 75 08             	mov    %esi,0x8(%ebp)
  800758:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	0f be d0             	movsbl %al,%edx
  80076b:	85 d2                	test   %edx,%edx
  80076d:	74 23                	je     800792 <vprintfmt+0x270>
  80076f:	85 f6                	test   %esi,%esi
  800771:	78 a1                	js     800714 <vprintfmt+0x1f2>
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	79 9c                	jns    800714 <vprintfmt+0x1f2>
  800778:	89 df                	mov    %ebx,%edi
  80077a:	8b 75 08             	mov    0x8(%ebp),%esi
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	eb 18                	jmp    80079a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 20                	push   $0x20
  800788:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078a:	83 ef 01             	sub    $0x1,%edi
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 08                	jmp    80079a <vprintfmt+0x278>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	85 ff                	test   %edi,%edi
  80079c:	7f e4                	jg     800782 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a1:	e9 a2 fd ff ff       	jmp    800548 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	7e 16                	jle    8007c1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 08             	lea    0x8(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 50 04             	mov    0x4(%eax),%edx
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bf:	eb 32                	jmp    8007f3 <vprintfmt+0x2d1>
	else if (lflag)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 18                	je     8007dd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 04             	lea    0x4(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d3:	89 c1                	mov    %eax,%ecx
  8007d5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007db:	eb 16                	jmp    8007f3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800802:	79 74                	jns    800878 <vprintfmt+0x356>
				putch('-', putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	53                   	push   %ebx
  800808:	6a 2d                	push   $0x2d
  80080a:	ff d6                	call   *%esi
				num = -(long long) num;
  80080c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800812:	f7 d8                	neg    %eax
  800814:	83 d2 00             	adc    $0x0,%edx
  800817:	f7 da                	neg    %edx
  800819:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800821:	eb 55                	jmp    800878 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	e8 83 fc ff ff       	call   8004ae <getuint>
			base = 10;
  80082b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800830:	eb 46                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 74 fc ff ff       	call   8004ae <getuint>
			base=8;
  80083a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083f:	eb 37                	jmp    800878 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 30                	push   $0x30
  800847:	ff d6                	call   *%esi
			putch('x', putdat);
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	53                   	push   %ebx
  80084d:	6a 78                	push   $0x78
  80084f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800861:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800864:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800869:	eb 0d                	jmp    800878 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 3b fc ff ff       	call   8004ae <getuint>
			base = 16;
  800873:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800878:	83 ec 0c             	sub    $0xc,%esp
  80087b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087f:	57                   	push   %edi
  800880:	ff 75 e0             	pushl  -0x20(%ebp)
  800883:	51                   	push   %ecx
  800884:	52                   	push   %edx
  800885:	50                   	push   %eax
  800886:	89 da                	mov    %ebx,%edx
  800888:	89 f0                	mov    %esi,%eax
  80088a:	e8 70 fb ff ff       	call   8003ff <printnum>
			break;
  80088f:	83 c4 20             	add    $0x20,%esp
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	e9 ae fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	51                   	push   %ecx
  80089f:	ff d6                	call   *%esi
			break;
  8008a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a7:	e9 9c fc ff ff       	jmp    800548 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	6a 25                	push   $0x25
  8008b2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 03                	jmp    8008bc <vprintfmt+0x39a>
  8008b9:	83 ef 01             	sub    $0x1,%edi
  8008bc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c0:	75 f7                	jne    8008b9 <vprintfmt+0x397>
  8008c2:	e9 81 fc ff ff       	jmp    800548 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 18             	sub    $0x18,%esp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	74 26                	je     800916 <vsnprintf+0x47>
  8008f0:	85 d2                	test   %edx,%edx
  8008f2:	7e 22                	jle    800916 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f4:	ff 75 14             	pushl  0x14(%ebp)
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	50                   	push   %eax
  8008fe:	68 e8 04 80 00       	push   $0x8004e8
  800903:	e8 1a fc ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb 05                	jmp    80091b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800926:	50                   	push   %eax
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 9a ff ff ff       	call   8008cf <vsnprintf>
	va_end(ap);

	return rc;
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb 03                	jmp    800947 <strlen+0x10>
		n++;
  800944:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800947:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094b:	75 f7                	jne    800944 <strlen+0xd>
		n++;
	return n;
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800958:	ba 00 00 00 00       	mov    $0x0,%edx
  80095d:	eb 03                	jmp    800962 <strnlen+0x13>
		n++;
  80095f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800962:	39 c2                	cmp    %eax,%edx
  800964:	74 08                	je     80096e <strnlen+0x1f>
  800966:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096a:	75 f3                	jne    80095f <strnlen+0x10>
  80096c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
  800989:	84 db                	test   %bl,%bl
  80098b:	75 ef                	jne    80097c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800997:	53                   	push   %ebx
  800998:	e8 9a ff ff ff       	call   800937 <strlen>
  80099d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a0:	ff 75 0c             	pushl  0xc(%ebp)
  8009a3:	01 d8                	add    %ebx,%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 c5 ff ff ff       	call   800970 <strcpy>
	return dst;
}
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bd:	89 f3                	mov    %esi,%ebx
  8009bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	eb 0f                	jmp    8009d5 <strncpy+0x23>
		*dst++ = *src;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	0f b6 01             	movzbl (%ecx),%eax
  8009cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	75 ed                	jne    8009c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d9:	89 f0                	mov    %esi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ea:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	74 21                	je     800a14 <strlcpy+0x35>
  8009f3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f7:	89 f2                	mov    %esi,%edx
  8009f9:	eb 09                	jmp    800a04 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a04:	39 c2                	cmp    %eax,%edx
  800a06:	74 09                	je     800a11 <strlcpy+0x32>
  800a08:	0f b6 19             	movzbl (%ecx),%ebx
  800a0b:	84 db                	test   %bl,%bl
  800a0d:	75 ec                	jne    8009fb <strlcpy+0x1c>
  800a0f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a14:	29 f0                	sub    %esi,%eax
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strcmp+0x11>
		p++, q++;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	84 c0                	test   %al,%al
  800a30:	74 04                	je     800a36 <strcmp+0x1c>
  800a32:	3a 02                	cmp    (%edx),%al
  800a34:	74 ef                	je     800a25 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 c0             	movzbl %al,%eax
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	29 d0                	sub    %edx,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4a:	89 c3                	mov    %eax,%ebx
  800a4c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4f:	eb 06                	jmp    800a57 <strncmp+0x17>
		n--, p++, q++;
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a57:	39 d8                	cmp    %ebx,%eax
  800a59:	74 15                	je     800a70 <strncmp+0x30>
  800a5b:	0f b6 08             	movzbl (%eax),%ecx
  800a5e:	84 c9                	test   %cl,%cl
  800a60:	74 04                	je     800a66 <strncmp+0x26>
  800a62:	3a 0a                	cmp    (%edx),%cl
  800a64:	74 eb                	je     800a51 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 00             	movzbl (%eax),%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
  800a6e:	eb 05                	jmp    800a75 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a82:	eb 07                	jmp    800a8b <strchr+0x13>
		if (*s == c)
  800a84:	38 ca                	cmp    %cl,%dl
  800a86:	74 0f                	je     800a97 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a88:	83 c0 01             	add    $0x1,%eax
  800a8b:	0f b6 10             	movzbl (%eax),%edx
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	75 f2                	jne    800a84 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa3:	eb 03                	jmp    800aa8 <strfind+0xf>
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aab:	38 ca                	cmp    %cl,%dl
  800aad:	74 04                	je     800ab3 <strfind+0x1a>
  800aaf:	84 d2                	test   %dl,%dl
  800ab1:	75 f2                	jne    800aa5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	74 36                	je     800afb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800acb:	75 28                	jne    800af5 <memset+0x40>
  800acd:	f6 c1 03             	test   $0x3,%cl
  800ad0:	75 23                	jne    800af5 <memset+0x40>
		c &= 0xFF;
  800ad2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad6:	89 d3                	mov    %edx,%ebx
  800ad8:	c1 e3 08             	shl    $0x8,%ebx
  800adb:	89 d6                	mov    %edx,%esi
  800add:	c1 e6 18             	shl    $0x18,%esi
  800ae0:	89 d0                	mov    %edx,%eax
  800ae2:	c1 e0 10             	shl    $0x10,%eax
  800ae5:	09 f0                	or     %esi,%eax
  800ae7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	09 d0                	or     %edx,%eax
  800aed:	c1 e9 02             	shr    $0x2,%ecx
  800af0:	fc                   	cld    
  800af1:	f3 ab                	rep stos %eax,%es:(%edi)
  800af3:	eb 06                	jmp    800afb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	fc                   	cld    
  800af9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b10:	39 c6                	cmp    %eax,%esi
  800b12:	73 35                	jae    800b49 <memmove+0x47>
  800b14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	73 2e                	jae    800b49 <memmove+0x47>
		s += n;
		d += n;
  800b1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	09 fe                	or     %edi,%esi
  800b22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b28:	75 13                	jne    800b3d <memmove+0x3b>
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 0e                	jne    800b3d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b2f:	83 ef 04             	sub    $0x4,%edi
  800b32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b35:	c1 e9 02             	shr    $0x2,%ecx
  800b38:	fd                   	std    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 09                	jmp    800b46 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3d:	83 ef 01             	sub    $0x1,%edi
  800b40:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b43:	fd                   	std    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b46:	fc                   	cld    
  800b47:	eb 1d                	jmp    800b66 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b49:	89 f2                	mov    %esi,%edx
  800b4b:	09 c2                	or     %eax,%edx
  800b4d:	f6 c2 03             	test   $0x3,%dl
  800b50:	75 0f                	jne    800b61 <memmove+0x5f>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 0a                	jne    800b61 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b57:	c1 e9 02             	shr    $0x2,%ecx
  800b5a:	89 c7                	mov    %eax,%edi
  800b5c:	fc                   	cld    
  800b5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5f:	eb 05                	jmp    800b66 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	fc                   	cld    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6d:	ff 75 10             	pushl  0x10(%ebp)
  800b70:	ff 75 0c             	pushl  0xc(%ebp)
  800b73:	ff 75 08             	pushl  0x8(%ebp)
  800b76:	e8 87 ff ff ff       	call   800b02 <memmove>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b88:	89 c6                	mov    %eax,%esi
  800b8a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8d:	eb 1a                	jmp    800ba9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8f:	0f b6 08             	movzbl (%eax),%ecx
  800b92:	0f b6 1a             	movzbl (%edx),%ebx
  800b95:	38 d9                	cmp    %bl,%cl
  800b97:	74 0a                	je     800ba3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b99:	0f b6 c1             	movzbl %cl,%eax
  800b9c:	0f b6 db             	movzbl %bl,%ebx
  800b9f:	29 d8                	sub    %ebx,%eax
  800ba1:	eb 0f                	jmp    800bb2 <memcmp+0x35>
		s1++, s2++;
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	39 f0                	cmp    %esi,%eax
  800bab:	75 e2                	jne    800b8f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	53                   	push   %ebx
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbd:	89 c1                	mov    %eax,%ecx
  800bbf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc6:	eb 0a                	jmp    800bd2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc8:	0f b6 10             	movzbl (%eax),%edx
  800bcb:	39 da                	cmp    %ebx,%edx
  800bcd:	74 07                	je     800bd6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	39 c8                	cmp    %ecx,%eax
  800bd4:	72 f2                	jb     800bc8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be5:	eb 03                	jmp    800bea <strtol+0x11>
		s++;
  800be7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 01             	movzbl (%ecx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 f6                	je     800be7 <strtol+0xe>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	74 f2                	je     800be7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf5:	3c 2b                	cmp    $0x2b,%al
  800bf7:	75 0a                	jne    800c03 <strtol+0x2a>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	eb 11                	jmp    800c14 <strtol+0x3b>
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c08:	3c 2d                	cmp    $0x2d,%al
  800c0a:	75 08                	jne    800c14 <strtol+0x3b>
		s++, neg = 1;
  800c0c:	83 c1 01             	add    $0x1,%ecx
  800c0f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1a:	75 15                	jne    800c31 <strtol+0x58>
  800c1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1f:	75 10                	jne    800c31 <strtol+0x58>
  800c21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c25:	75 7c                	jne    800ca3 <strtol+0xca>
		s += 2, base = 16;
  800c27:	83 c1 02             	add    $0x2,%ecx
  800c2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2f:	eb 16                	jmp    800c47 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c31:	85 db                	test   %ebx,%ebx
  800c33:	75 12                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c35:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3d:	75 08                	jne    800c47 <strtol+0x6e>
		s++, base = 8;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4f:	0f b6 11             	movzbl (%ecx),%edx
  800c52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c55:	89 f3                	mov    %esi,%ebx
  800c57:	80 fb 09             	cmp    $0x9,%bl
  800c5a:	77 08                	ja     800c64 <strtol+0x8b>
			dig = *s - '0';
  800c5c:	0f be d2             	movsbl %dl,%edx
  800c5f:	83 ea 30             	sub    $0x30,%edx
  800c62:	eb 22                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c64:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 19             	cmp    $0x19,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 57             	sub    $0x57,%edx
  800c74:	eb 10                	jmp    800c86 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c76:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 16                	ja     800c96 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c89:	7d 0b                	jge    800c96 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c92:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c94:	eb b9                	jmp    800c4f <strtol+0x76>

	if (endptr)
  800c96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9a:	74 0d                	je     800ca9 <strtol+0xd0>
		*endptr = (char *) s;
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	89 0e                	mov    %ecx,(%esi)
  800ca1:	eb 06                	jmp    800ca9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	74 98                	je     800c3f <strtol+0x66>
  800ca7:	eb 9e                	jmp    800c47 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	f7 da                	neg    %edx
  800cad:	85 ff                	test   %edi,%edi
  800caf:	0f 45 c2             	cmovne %edx,%eax
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 c3                	mov    %eax,%ebx
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	89 c6                	mov    %eax,%esi
  800cce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 03 00 00 00       	mov    $0x3,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 17                	jle    800d2d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 03                	push   $0x3
  800d1c:	68 ff 28 80 00       	push   $0x8028ff
  800d21:	6a 23                	push   $0x23
  800d23:	68 1c 29 80 00       	push   $0x80291c
  800d28:	e8 e5 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	be 00 00 00 00       	mov    $0x0,%esi
  800d81:	b8 04 00 00 00       	mov    $0x4,%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	89 f7                	mov    %esi,%edi
  800d91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d93:	85 c0                	test   %eax,%eax
  800d95:	7e 17                	jle    800dae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	50                   	push   %eax
  800d9b:	6a 04                	push   $0x4
  800d9d:	68 ff 28 80 00       	push   $0x8028ff
  800da2:	6a 23                	push   $0x23
  800da4:	68 1c 29 80 00       	push   $0x80291c
  800da9:	e8 64 f5 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd0:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 17                	jle    800df0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	50                   	push   %eax
  800ddd:	6a 05                	push   $0x5
  800ddf:	68 ff 28 80 00       	push   $0x8028ff
  800de4:	6a 23                	push   $0x23
  800de6:	68 1c 29 80 00       	push   $0x80291c
  800deb:	e8 22 f5 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 17                	jle    800e32 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	50                   	push   %eax
  800e1f:	6a 06                	push   $0x6
  800e21:	68 ff 28 80 00       	push   $0x8028ff
  800e26:	6a 23                	push   $0x23
  800e28:	68 1c 29 80 00       	push   $0x80291c
  800e2d:	e8 e0 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 17                	jle    800e74 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	50                   	push   %eax
  800e61:	6a 08                	push   $0x8
  800e63:	68 ff 28 80 00       	push   $0x8028ff
  800e68:	6a 23                	push   $0x23
  800e6a:	68 1c 29 80 00       	push   $0x80291c
  800e6f:	e8 9e f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	89 de                	mov    %ebx,%esi
  800e99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	7e 17                	jle    800eb6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	50                   	push   %eax
  800ea3:	6a 09                	push   $0x9
  800ea5:	68 ff 28 80 00       	push   $0x8028ff
  800eaa:	6a 23                	push   $0x23
  800eac:	68 1c 29 80 00       	push   $0x80291c
  800eb1:	e8 5c f4 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edd:	85 c0                	test   %eax,%eax
  800edf:	7e 17                	jle    800ef8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee1:	83 ec 0c             	sub    $0xc,%esp
  800ee4:	50                   	push   %eax
  800ee5:	6a 0a                	push   $0xa
  800ee7:	68 ff 28 80 00       	push   $0x8028ff
  800eec:	6a 23                	push   $0x23
  800eee:	68 1c 29 80 00       	push   $0x80291c
  800ef3:	e8 1a f4 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 cb                	mov    %ecx,%ebx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	89 ce                	mov    %ecx,%esi
  800f3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 17                	jle    800f5c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	83 ec 0c             	sub    $0xc,%esp
  800f48:	50                   	push   %eax
  800f49:	6a 0d                	push   $0xd
  800f4b:	68 ff 28 80 00       	push   $0x8028ff
  800f50:	6a 23                	push   $0x23
  800f52:	68 1c 29 80 00       	push   $0x80291c
  800f57:	e8 b6 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f6c:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800f6e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f72:	75 14                	jne    800f88 <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 2c 29 80 00       	push   $0x80292c
  800f7c:	6a 23                	push   $0x23
  800f7e:	68 ef 29 80 00       	push   $0x8029ef
  800f83:	e8 8a f3 ff ff       	call   800312 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	c1 e8 0c             	shr    $0xc,%eax
  800f8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f94:	f6 c4 08             	test   $0x8,%ah
  800f97:	75 14                	jne    800fad <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 50 29 80 00       	push   $0x802950
  800fa1:	6a 2d                	push   $0x2d
  800fa3:	68 ef 29 80 00       	push   $0x8029ef
  800fa8:	e8 65 f3 ff ff       	call   800312 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800fad:	e8 83 fd ff ff       	call   800d35 <sys_getenvid>
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	6a 07                	push   $0x7
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	50                   	push   %eax
  800fbd:	e8 b1 fd ff ff       	call   800d73 <sys_page_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 12                	jns    800fdb <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800fc9:	50                   	push   %eax
  800fca:	68 fa 29 80 00       	push   $0x8029fa
  800fcf:	6a 3b                	push   $0x3b
  800fd1:	68 ef 29 80 00       	push   $0x8029ef
  800fd6:	e8 37 f3 ff ff       	call   800312 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800fdb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	68 00 10 00 00       	push   $0x1000
  800fe9:	53                   	push   %ebx
  800fea:	68 00 f0 7f 00       	push   $0x7ff000
  800fef:	e8 0e fb ff ff       	call   800b02 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800ff4:	e8 3c fd ff ff       	call   800d35 <sys_getenvid>
  800ff9:	89 c6                	mov    %eax,%esi
  800ffb:	e8 35 fd ff ff       	call   800d35 <sys_getenvid>
  801000:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801007:	53                   	push   %ebx
  801008:	56                   	push   %esi
  801009:	68 00 f0 7f 00       	push   $0x7ff000
  80100e:	50                   	push   %eax
  80100f:	e8 a2 fd ff ff       	call   800db6 <sys_page_map>
  801014:	83 c4 20             	add    $0x20,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	79 12                	jns    80102d <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  80101b:	50                   	push   %eax
  80101c:	68 13 2a 80 00       	push   $0x802a13
  801021:	6a 48                	push   $0x48
  801023:	68 ef 29 80 00       	push   $0x8029ef
  801028:	e8 e5 f2 ff ff       	call   800312 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  80102d:	e8 03 fd ff ff       	call   800d35 <sys_getenvid>
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	68 00 f0 7f 00       	push   $0x7ff000
  80103a:	50                   	push   %eax
  80103b:	e8 b8 fd ff ff       	call   800df8 <sys_page_unmap>
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 12                	jns    801059 <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  801047:	50                   	push   %eax
  801048:	68 2a 2a 80 00       	push   $0x802a2a
  80104d:	6a 4c                	push   $0x4c
  80104f:	68 ef 29 80 00       	push   $0x8029ef
  801054:	e8 b9 f2 ff ff       	call   800312 <_panic>
	}

	//panic("pgfault not implemented");
}
  801059:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  801069:	68 64 0f 80 00       	push   $0x800f64
  80106e:	e8 68 0f 00 00       	call   801fdb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801073:	b8 07 00 00 00       	mov    $0x7,%eax
  801078:	cd 30                	int    $0x30
  80107a:	89 c7                	mov    %eax,%edi
  80107c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	79 15                	jns    80109b <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  801086:	50                   	push   %eax
  801087:	68 43 2a 80 00       	push   $0x802a43
  80108c:	68 a1 00 00 00       	push   $0xa1
  801091:	68 ef 29 80 00       	push   $0x8029ef
  801096:	e8 77 f2 ff ff       	call   800312 <_panic>
  80109b:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	75 21                	jne    8010c5 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  8010a4:	e8 8c fc ff ff       	call   800d35 <sys_getenvid>
  8010a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b6:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c0:	e9 c8 01 00 00       	jmp    80128d <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8010c5:	89 d8                	mov    %ebx,%eax
  8010c7:	c1 e8 16             	shr    $0x16,%eax
  8010ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d1:	a8 01                	test   $0x1,%al
  8010d3:	0f 84 23 01 00 00    	je     8011fc <fork+0x19c>
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	c1 e8 0c             	shr    $0xc,%eax
  8010de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e5:	f6 c2 01             	test   $0x1,%dl
  8010e8:	0f 84 0e 01 00 00    	je     8011fc <fork+0x19c>
  8010ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f5:	f6 c2 04             	test   $0x4,%dl
  8010f8:	0f 84 fe 00 00 00    	je     8011fc <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  8010fe:	89 c6                	mov    %eax,%esi
  801100:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  801103:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110a:	f6 c6 04             	test   $0x4,%dh
  80110d:	74 3f                	je     80114e <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  80110f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	25 07 0e 00 00       	and    $0xe07,%eax
  80111e:	50                   	push   %eax
  80111f:	56                   	push   %esi
  801120:	ff 75 e4             	pushl  -0x1c(%ebp)
  801123:	56                   	push   %esi
  801124:	6a 00                	push   $0x0
  801126:	e8 8b fc ff ff       	call   800db6 <sys_page_map>
  80112b:	83 c4 20             	add    $0x20,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	0f 89 c6 00 00 00    	jns    8011fc <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	50                   	push   %eax
  80113a:	57                   	push   %edi
  80113b:	6a 00                	push   $0x0
  80113d:	68 80 29 80 00       	push   $0x802980
  801142:	6a 6c                	push   $0x6c
  801144:	68 ef 29 80 00       	push   $0x8029ef
  801149:	e8 c4 f1 ff ff       	call   800312 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80114e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801155:	f6 c2 02             	test   $0x2,%dl
  801158:	75 0c                	jne    801166 <fork+0x106>
  80115a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801161:	f6 c4 08             	test   $0x8,%ah
  801164:	74 66                	je     8011cc <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	68 05 08 00 00       	push   $0x805
  80116e:	56                   	push   %esi
  80116f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801172:	56                   	push   %esi
  801173:	6a 00                	push   $0x0
  801175:	e8 3c fc ff ff       	call   800db6 <sys_page_map>
  80117a:	83 c4 20             	add    $0x20,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 18                	jns    801199 <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	50                   	push   %eax
  801185:	57                   	push   %edi
  801186:	6a 00                	push   $0x0
  801188:	68 80 29 80 00       	push   $0x802980
  80118d:	6a 74                	push   $0x74
  80118f:	68 ef 29 80 00       	push   $0x8029ef
  801194:	e8 79 f1 ff ff       	call   800312 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	68 05 08 00 00       	push   $0x805
  8011a1:	56                   	push   %esi
  8011a2:	6a 00                	push   $0x0
  8011a4:	56                   	push   %esi
  8011a5:	6a 00                	push   $0x0
  8011a7:	e8 0a fc ff ff       	call   800db6 <sys_page_map>
  8011ac:	83 c4 20             	add    $0x20,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	79 49                	jns    8011fc <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	50                   	push   %eax
  8011b7:	6a 00                	push   $0x0
  8011b9:	6a 00                	push   $0x0
  8011bb:	68 80 29 80 00       	push   $0x802980
  8011c0:	6a 77                	push   $0x77
  8011c2:	68 ef 29 80 00       	push   $0x8029ef
  8011c7:	e8 46 f1 ff ff       	call   800312 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	6a 05                	push   $0x5
  8011d1:	56                   	push   %esi
  8011d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d5:	56                   	push   %esi
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 d9 fb ff ff       	call   800db6 <sys_page_map>
  8011dd:	83 c4 20             	add    $0x20,%esp
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	79 18                	jns    8011fc <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	50                   	push   %eax
  8011e8:	57                   	push   %edi
  8011e9:	6a 00                	push   $0x0
  8011eb:	68 80 29 80 00       	push   $0x802980
  8011f0:	6a 7d                	push   $0x7d
  8011f2:	68 ef 29 80 00       	push   $0x8029ef
  8011f7:	e8 16 f1 ff ff       	call   800312 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8011fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801202:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801208:	0f 85 b7 fe ff ff    	jne    8010c5 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	6a 07                	push   $0x7
  801213:	68 00 f0 bf ee       	push   $0xeebff000
  801218:	57                   	push   %edi
  801219:	e8 55 fb ff ff       	call   800d73 <sys_page_alloc>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	79 15                	jns    80123a <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  801225:	50                   	push   %eax
  801226:	68 ac 29 80 00       	push   $0x8029ac
  80122b:	68 b4 00 00 00       	push   $0xb4
  801230:	68 ef 29 80 00       	push   $0x8029ef
  801235:	e8 d8 f0 ff ff       	call   800312 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	68 4f 20 80 00       	push   $0x80204f
  801242:	57                   	push   %edi
  801243:	e8 76 fc ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	79 15                	jns    801264 <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  80124f:	50                   	push   %eax
  801250:	68 59 2a 80 00       	push   $0x802a59
  801255:	68 ba 00 00 00       	push   $0xba
  80125a:	68 ef 29 80 00       	push   $0x8029ef
  80125f:	e8 ae f0 ff ff       	call   800312 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	6a 02                	push   $0x2
  801269:	57                   	push   %edi
  80126a:	e8 cb fb ff ff       	call   800e3a <sys_env_set_status>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	79 15                	jns    80128b <fork+0x22b>
		panic("Sys env set status error: %e", r);
  801276:	50                   	push   %eax
  801277:	68 76 2a 80 00       	push   $0x802a76
  80127c:	68 bf 00 00 00       	push   $0xbf
  801281:	68 ef 29 80 00       	push   $0x8029ef
  801286:	e8 87 f0 ff ff       	call   800312 <_panic>
	}
	return eid;
  80128b:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  80128d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <sfork>:

// Challenge!
int
sfork(void)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80129b:	68 93 2a 80 00       	push   $0x802a93
  8012a0:	68 ca 00 00 00       	push   $0xca
  8012a5:	68 ef 29 80 00       	push   $0x8029ef
  8012aa:	e8 63 f0 ff ff       	call   800312 <_panic>

008012af <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ba:	c1 e8 0c             	shr    $0xc,%eax
}
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c5:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012cf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012dc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	c1 ea 16             	shr    $0x16,%edx
  8012e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 11                	je     801303 <fd_alloc+0x2d>
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 0c             	shr    $0xc,%edx
  8012f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fe:	f6 c2 01             	test   $0x1,%dl
  801301:	75 09                	jne    80130c <fd_alloc+0x36>
			*fd_store = fd;
  801303:	89 01                	mov    %eax,(%ecx)
			return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	eb 17                	jmp    801323 <fd_alloc+0x4d>
  80130c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801311:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801316:	75 c9                	jne    8012e1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801318:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80131e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80132b:	83 f8 1f             	cmp    $0x1f,%eax
  80132e:	77 36                	ja     801366 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801330:	c1 e0 0c             	shl    $0xc,%eax
  801333:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801338:	89 c2                	mov    %eax,%edx
  80133a:	c1 ea 16             	shr    $0x16,%edx
  80133d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801344:	f6 c2 01             	test   $0x1,%dl
  801347:	74 24                	je     80136d <fd_lookup+0x48>
  801349:	89 c2                	mov    %eax,%edx
  80134b:	c1 ea 0c             	shr    $0xc,%edx
  80134e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801355:	f6 c2 01             	test   $0x1,%dl
  801358:	74 1a                	je     801374 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80135a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135d:	89 02                	mov    %eax,(%edx)
	return 0;
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
  801364:	eb 13                	jmp    801379 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801366:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136b:	eb 0c                	jmp    801379 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801372:	eb 05                	jmp    801379 <fd_lookup+0x54>
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801384:	ba 28 2b 80 00       	mov    $0x802b28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801389:	eb 13                	jmp    80139e <dev_lookup+0x23>
  80138b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80138e:	39 08                	cmp    %ecx,(%eax)
  801390:	75 0c                	jne    80139e <dev_lookup+0x23>
			*dev = devtab[i];
  801392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801395:	89 01                	mov    %eax,(%ecx)
			return 0;
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
  80139c:	eb 2e                	jmp    8013cc <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80139e:	8b 02                	mov    (%edx),%eax
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	75 e7                	jne    80138b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a9:	8b 40 48             	mov    0x48(%eax),%eax
  8013ac:	83 ec 04             	sub    $0x4,%esp
  8013af:	51                   	push   %ecx
  8013b0:	50                   	push   %eax
  8013b1:	68 ac 2a 80 00       	push   $0x802aac
  8013b6:	e8 30 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  8013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 10             	sub    $0x10,%esp
  8013d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013e6:	c1 e8 0c             	shr    $0xc,%eax
  8013e9:	50                   	push   %eax
  8013ea:	e8 36 ff ff ff       	call   801325 <fd_lookup>
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 05                	js     8013fb <fd_close+0x2d>
	    || fd != fd2)
  8013f6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f9:	74 0c                	je     801407 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013fb:	84 db                	test   %bl,%bl
  8013fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801402:	0f 44 c2             	cmove  %edx,%eax
  801405:	eb 41                	jmp    801448 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 36                	pushl  (%esi)
  801410:	e8 66 ff ff ff       	call   80137b <dev_lookup>
  801415:	89 c3                	mov    %eax,%ebx
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 1a                	js     801438 <fd_close+0x6a>
		if (dev->dev_close)
  80141e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801421:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801424:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801429:	85 c0                	test   %eax,%eax
  80142b:	74 0b                	je     801438 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	56                   	push   %esi
  801431:	ff d0                	call   *%eax
  801433:	89 c3                	mov    %eax,%ebx
  801435:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	56                   	push   %esi
  80143c:	6a 00                	push   $0x0
  80143e:	e8 b5 f9 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	89 d8                	mov    %ebx,%eax
}
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	e8 c4 fe ff ff       	call   801325 <fd_lookup>
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 10                	js     801478 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	6a 01                	push   $0x1
  80146d:	ff 75 f4             	pushl  -0xc(%ebp)
  801470:	e8 59 ff ff ff       	call   8013ce <fd_close>
  801475:	83 c4 10             	add    $0x10,%esp
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <close_all>:

void
close_all(void)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	53                   	push   %ebx
  80147e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801481:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	53                   	push   %ebx
  80148a:	e8 c0 ff ff ff       	call   80144f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80148f:	83 c3 01             	add    $0x1,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	83 fb 20             	cmp    $0x20,%ebx
  801498:	75 ec                	jne    801486 <close_all+0xc>
		close(i);
}
  80149a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	57                   	push   %edi
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 2c             	sub    $0x2c,%esp
  8014a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	ff 75 08             	pushl  0x8(%ebp)
  8014b2:	e8 6e fe ff ff       	call   801325 <fd_lookup>
  8014b7:	83 c4 08             	add    $0x8,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	0f 88 c1 00 00 00    	js     801583 <dup+0xe4>
		return r;
	close(newfdnum);
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	56                   	push   %esi
  8014c6:	e8 84 ff ff ff       	call   80144f <close>

	newfd = INDEX2FD(newfdnum);
  8014cb:	89 f3                	mov    %esi,%ebx
  8014cd:	c1 e3 0c             	shl    $0xc,%ebx
  8014d0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014d6:	83 c4 04             	add    $0x4,%esp
  8014d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014dc:	e8 de fd ff ff       	call   8012bf <fd2data>
  8014e1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014e3:	89 1c 24             	mov    %ebx,(%esp)
  8014e6:	e8 d4 fd ff ff       	call   8012bf <fd2data>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f1:	89 f8                	mov    %edi,%eax
  8014f3:	c1 e8 16             	shr    $0x16,%eax
  8014f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014fd:	a8 01                	test   $0x1,%al
  8014ff:	74 37                	je     801538 <dup+0x99>
  801501:	89 f8                	mov    %edi,%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
  801506:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150d:	f6 c2 01             	test   $0x1,%dl
  801510:	74 26                	je     801538 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801512:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801519:	83 ec 0c             	sub    $0xc,%esp
  80151c:	25 07 0e 00 00       	and    $0xe07,%eax
  801521:	50                   	push   %eax
  801522:	ff 75 d4             	pushl  -0x2c(%ebp)
  801525:	6a 00                	push   $0x0
  801527:	57                   	push   %edi
  801528:	6a 00                	push   $0x0
  80152a:	e8 87 f8 ff ff       	call   800db6 <sys_page_map>
  80152f:	89 c7                	mov    %eax,%edi
  801531:	83 c4 20             	add    $0x20,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 2e                	js     801566 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801538:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	c1 e8 0c             	shr    $0xc,%eax
  801540:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	25 07 0e 00 00       	and    $0xe07,%eax
  80154f:	50                   	push   %eax
  801550:	53                   	push   %ebx
  801551:	6a 00                	push   $0x0
  801553:	52                   	push   %edx
  801554:	6a 00                	push   $0x0
  801556:	e8 5b f8 ff ff       	call   800db6 <sys_page_map>
  80155b:	89 c7                	mov    %eax,%edi
  80155d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801560:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801562:	85 ff                	test   %edi,%edi
  801564:	79 1d                	jns    801583 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	53                   	push   %ebx
  80156a:	6a 00                	push   $0x0
  80156c:	e8 87 f8 ff ff       	call   800df8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	ff 75 d4             	pushl  -0x2c(%ebp)
  801577:	6a 00                	push   $0x0
  801579:	e8 7a f8 ff ff       	call   800df8 <sys_page_unmap>
	return r;
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	89 f8                	mov    %edi,%eax
}
  801583:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 14             	sub    $0x14,%esp
  801592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801595:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	53                   	push   %ebx
  80159a:	e8 86 fd ff ff       	call   801325 <fd_lookup>
  80159f:	83 c4 08             	add    $0x8,%esp
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 6d                	js     801615 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b2:	ff 30                	pushl  (%eax)
  8015b4:	e8 c2 fd ff ff       	call   80137b <dev_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 4c                	js     80160c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015c3:	8b 42 08             	mov    0x8(%edx),%eax
  8015c6:	83 e0 03             	and    $0x3,%eax
  8015c9:	83 f8 01             	cmp    $0x1,%eax
  8015cc:	75 21                	jne    8015ef <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d3:	8b 40 48             	mov    0x48(%eax),%eax
  8015d6:	83 ec 04             	sub    $0x4,%esp
  8015d9:	53                   	push   %ebx
  8015da:	50                   	push   %eax
  8015db:	68 ed 2a 80 00       	push   $0x802aed
  8015e0:	e8 06 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ed:	eb 26                	jmp    801615 <read+0x8a>
	}
	if (!dev->dev_read)
  8015ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f2:	8b 40 08             	mov    0x8(%eax),%eax
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	74 17                	je     801610 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	ff 75 10             	pushl  0x10(%ebp)
  8015ff:	ff 75 0c             	pushl  0xc(%ebp)
  801602:	52                   	push   %edx
  801603:	ff d0                	call   *%eax
  801605:	89 c2                	mov    %eax,%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 09                	jmp    801615 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	eb 05                	jmp    801615 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801610:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801615:	89 d0                	mov    %edx,%eax
  801617:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161a:	c9                   	leave  
  80161b:	c3                   	ret    

0080161c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	57                   	push   %edi
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	8b 7d 08             	mov    0x8(%ebp),%edi
  801628:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801630:	eb 21                	jmp    801653 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	89 f0                	mov    %esi,%eax
  801637:	29 d8                	sub    %ebx,%eax
  801639:	50                   	push   %eax
  80163a:	89 d8                	mov    %ebx,%eax
  80163c:	03 45 0c             	add    0xc(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	57                   	push   %edi
  801641:	e8 45 ff ff ff       	call   80158b <read>
		if (m < 0)
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 10                	js     80165d <readn+0x41>
			return m;
		if (m == 0)
  80164d:	85 c0                	test   %eax,%eax
  80164f:	74 0a                	je     80165b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801651:	01 c3                	add    %eax,%ebx
  801653:	39 f3                	cmp    %esi,%ebx
  801655:	72 db                	jb     801632 <readn+0x16>
  801657:	89 d8                	mov    %ebx,%eax
  801659:	eb 02                	jmp    80165d <readn+0x41>
  80165b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80165d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5f                   	pop    %edi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    

00801665 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	53                   	push   %ebx
  801669:	83 ec 14             	sub    $0x14,%esp
  80166c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	53                   	push   %ebx
  801674:	e8 ac fc ff ff       	call   801325 <fd_lookup>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 68                	js     8016ea <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168c:	ff 30                	pushl  (%eax)
  80168e:	e8 e8 fc ff ff       	call   80137b <dev_lookup>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 47                	js     8016e1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a1:	75 21                	jne    8016c4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a8:	8b 40 48             	mov    0x48(%eax),%eax
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	53                   	push   %ebx
  8016af:	50                   	push   %eax
  8016b0:	68 09 2b 80 00       	push   $0x802b09
  8016b5:	e8 31 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c2:	eb 26                	jmp    8016ea <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ca:	85 d2                	test   %edx,%edx
  8016cc:	74 17                	je     8016e5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ce:	83 ec 04             	sub    $0x4,%esp
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	50                   	push   %eax
  8016d8:	ff d2                	call   *%edx
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	eb 09                	jmp    8016ea <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	eb 05                	jmp    8016ea <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016e5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016ea:	89 d0                	mov    %edx,%eax
  8016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016f7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	ff 75 08             	pushl  0x8(%ebp)
  8016fe:	e8 22 fc ff ff       	call   801325 <fd_lookup>
  801703:	83 c4 08             	add    $0x8,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 0e                	js     801718 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80170a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80170d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801710:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801713:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	83 ec 14             	sub    $0x14,%esp
  801721:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801724:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801727:	50                   	push   %eax
  801728:	53                   	push   %ebx
  801729:	e8 f7 fb ff ff       	call   801325 <fd_lookup>
  80172e:	83 c4 08             	add    $0x8,%esp
  801731:	89 c2                	mov    %eax,%edx
  801733:	85 c0                	test   %eax,%eax
  801735:	78 65                	js     80179c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801741:	ff 30                	pushl  (%eax)
  801743:	e8 33 fc ff ff       	call   80137b <dev_lookup>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 44                	js     801793 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801752:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801756:	75 21                	jne    801779 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801758:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80175d:	8b 40 48             	mov    0x48(%eax),%eax
  801760:	83 ec 04             	sub    $0x4,%esp
  801763:	53                   	push   %ebx
  801764:	50                   	push   %eax
  801765:	68 cc 2a 80 00       	push   $0x802acc
  80176a:	e8 7c ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801777:	eb 23                	jmp    80179c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801779:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177c:	8b 52 18             	mov    0x18(%edx),%edx
  80177f:	85 d2                	test   %edx,%edx
  801781:	74 14                	je     801797 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	ff 75 0c             	pushl  0xc(%ebp)
  801789:	50                   	push   %eax
  80178a:	ff d2                	call   *%edx
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	eb 09                	jmp    80179c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801793:	89 c2                	mov    %eax,%edx
  801795:	eb 05                	jmp    80179c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801797:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80179c:	89 d0                	mov    %edx,%eax
  80179e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a1:	c9                   	leave  
  8017a2:	c3                   	ret    

008017a3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 14             	sub    $0x14,%esp
  8017aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	ff 75 08             	pushl  0x8(%ebp)
  8017b4:	e8 6c fb ff ff       	call   801325 <fd_lookup>
  8017b9:	83 c4 08             	add    $0x8,%esp
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 58                	js     80181a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c8:	50                   	push   %eax
  8017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cc:	ff 30                	pushl  (%eax)
  8017ce:	e8 a8 fb ff ff       	call   80137b <dev_lookup>
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 37                	js     801811 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017e1:	74 32                	je     801815 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017e3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017e6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ed:	00 00 00 
	stat->st_isdir = 0;
  8017f0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017f7:	00 00 00 
	stat->st_dev = dev;
  8017fa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	53                   	push   %ebx
  801804:	ff 75 f0             	pushl  -0x10(%ebp)
  801807:	ff 50 14             	call   *0x14(%eax)
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	eb 09                	jmp    80181a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	89 c2                	mov    %eax,%edx
  801813:	eb 05                	jmp    80181a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801815:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80181a:	89 d0                	mov    %edx,%eax
  80181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	6a 00                	push   $0x0
  80182b:	ff 75 08             	pushl  0x8(%ebp)
  80182e:	e8 d6 01 00 00       	call   801a09 <open>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 1b                	js     801857 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	ff 75 0c             	pushl  0xc(%ebp)
  801842:	50                   	push   %eax
  801843:	e8 5b ff ff ff       	call   8017a3 <fstat>
  801848:	89 c6                	mov    %eax,%esi
	close(fd);
  80184a:	89 1c 24             	mov    %ebx,(%esp)
  80184d:	e8 fd fb ff ff       	call   80144f <close>
	return r;
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	89 f0                	mov    %esi,%eax
}
  801857:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185a:	5b                   	pop    %ebx
  80185b:	5e                   	pop    %esi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	89 c6                	mov    %eax,%esi
  801865:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801867:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80186e:	75 12                	jne    801882 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	6a 01                	push   $0x1
  801875:	e8 e5 08 00 00       	call   80215f <ipc_find_env>
  80187a:	a3 00 40 80 00       	mov    %eax,0x804000
  80187f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801882:	6a 07                	push   $0x7
  801884:	68 00 50 80 00       	push   $0x805000
  801889:	56                   	push   %esi
  80188a:	ff 35 00 40 80 00    	pushl  0x804000
  801890:	e8 76 08 00 00       	call   80210b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801895:	83 c4 0c             	add    $0xc,%esp
  801898:	6a 00                	push   $0x0
  80189a:	53                   	push   %ebx
  80189b:	6a 00                	push   $0x0
  80189d:	e8 d1 07 00 00       	call   802073 <ipc_recv>
}
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8018cc:	e8 8d ff ff ff       	call   80185e <fsipc>
}
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018df:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ee:	e8 6b ff ff ff       	call   80185e <fsipc>
}
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 04             	sub    $0x4,%esp
  8018fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 40 0c             	mov    0xc(%eax),%eax
  801905:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80190a:	ba 00 00 00 00       	mov    $0x0,%edx
  80190f:	b8 05 00 00 00       	mov    $0x5,%eax
  801914:	e8 45 ff ff ff       	call   80185e <fsipc>
  801919:	85 c0                	test   %eax,%eax
  80191b:	78 2c                	js     801949 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	68 00 50 80 00       	push   $0x805000
  801925:	53                   	push   %ebx
  801926:	e8 45 f0 ff ff       	call   800970 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80192b:	a1 80 50 80 00       	mov    0x805080,%eax
  801930:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801936:	a1 84 50 80 00       	mov    0x805084,%eax
  80193b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801949:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801957:	8b 55 08             	mov    0x8(%ebp),%edx
  80195a:	8b 52 0c             	mov    0xc(%edx),%edx
  80195d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801963:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801968:	50                   	push   %eax
  801969:	ff 75 0c             	pushl  0xc(%ebp)
  80196c:	68 08 50 80 00       	push   $0x805008
  801971:	e8 8c f1 ff ff       	call   800b02 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	b8 04 00 00 00       	mov    $0x4,%eax
  801980:	e8 d9 fe ff ff       	call   80185e <fsipc>
	//panic("devfile_write not implemented");
}
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
  80198c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80198f:	8b 45 08             	mov    0x8(%ebp),%eax
  801992:	8b 40 0c             	mov    0xc(%eax),%eax
  801995:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80199a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8019aa:	e8 af fe ff ff       	call   80185e <fsipc>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 4b                	js     801a00 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019b5:	39 c6                	cmp    %eax,%esi
  8019b7:	73 16                	jae    8019cf <devfile_read+0x48>
  8019b9:	68 38 2b 80 00       	push   $0x802b38
  8019be:	68 3f 2b 80 00       	push   $0x802b3f
  8019c3:	6a 7c                	push   $0x7c
  8019c5:	68 54 2b 80 00       	push   $0x802b54
  8019ca:	e8 43 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  8019cf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019d4:	7e 16                	jle    8019ec <devfile_read+0x65>
  8019d6:	68 5f 2b 80 00       	push   $0x802b5f
  8019db:	68 3f 2b 80 00       	push   $0x802b3f
  8019e0:	6a 7d                	push   $0x7d
  8019e2:	68 54 2b 80 00       	push   $0x802b54
  8019e7:	e8 26 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ec:	83 ec 04             	sub    $0x4,%esp
  8019ef:	50                   	push   %eax
  8019f0:	68 00 50 80 00       	push   $0x805000
  8019f5:	ff 75 0c             	pushl  0xc(%ebp)
  8019f8:	e8 05 f1 ff ff       	call   800b02 <memmove>
	return r;
  8019fd:	83 c4 10             	add    $0x10,%esp
}
  801a00:	89 d8                	mov    %ebx,%eax
  801a02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 20             	sub    $0x20,%esp
  801a10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a13:	53                   	push   %ebx
  801a14:	e8 1e ef ff ff       	call   800937 <strlen>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a21:	7f 67                	jg     801a8a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a29:	50                   	push   %eax
  801a2a:	e8 a7 f8 ff ff       	call   8012d6 <fd_alloc>
  801a2f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a32:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 57                	js     801a8f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	68 00 50 80 00       	push   $0x805000
  801a41:	e8 2a ef ff ff       	call   800970 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a49:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a51:	b8 01 00 00 00       	mov    $0x1,%eax
  801a56:	e8 03 fe ff ff       	call   80185e <fsipc>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	79 14                	jns    801a78 <open+0x6f>
		fd_close(fd, 0);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	6a 00                	push   $0x0
  801a69:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6c:	e8 5d f9 ff ff       	call   8013ce <fd_close>
		return r;
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	89 da                	mov    %ebx,%edx
  801a76:	eb 17                	jmp    801a8f <open+0x86>
	}

	return fd2num(fd);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7e:	e8 2c f8 ff ff       	call   8012af <fd2num>
  801a83:	89 c2                	mov    %eax,%edx
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb 05                	jmp    801a8f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a8a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a8f:	89 d0                	mov    %edx,%eax
  801a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa1:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa6:	e8 b3 fd ff ff       	call   80185e <fsipc>
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 08             	pushl  0x8(%ebp)
  801abb:	e8 ff f7 ff ff       	call   8012bf <fd2data>
  801ac0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ac2:	83 c4 08             	add    $0x8,%esp
  801ac5:	68 6b 2b 80 00       	push   $0x802b6b
  801aca:	53                   	push   %ebx
  801acb:	e8 a0 ee ff ff       	call   800970 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ad0:	8b 46 04             	mov    0x4(%esi),%eax
  801ad3:	2b 06                	sub    (%esi),%eax
  801ad5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801adb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae2:	00 00 00 
	stat->st_dev = &devpipe;
  801ae5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801aec:	30 80 00 
	return 0;
}
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
  801af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	53                   	push   %ebx
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b05:	53                   	push   %ebx
  801b06:	6a 00                	push   $0x0
  801b08:	e8 eb f2 ff ff       	call   800df8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b0d:	89 1c 24             	mov    %ebx,(%esp)
  801b10:	e8 aa f7 ff ff       	call   8012bf <fd2data>
  801b15:	83 c4 08             	add    $0x8,%esp
  801b18:	50                   	push   %eax
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 d8 f2 ff ff       	call   800df8 <sys_page_unmap>
}
  801b20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 1c             	sub    $0x1c,%esp
  801b2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b31:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b33:	a1 04 40 80 00       	mov    0x804004,%eax
  801b38:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	ff 75 e0             	pushl  -0x20(%ebp)
  801b41:	e8 52 06 00 00       	call   802198 <pageref>
  801b46:	89 c3                	mov    %eax,%ebx
  801b48:	89 3c 24             	mov    %edi,(%esp)
  801b4b:	e8 48 06 00 00       	call   802198 <pageref>
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	39 c3                	cmp    %eax,%ebx
  801b55:	0f 94 c1             	sete   %cl
  801b58:	0f b6 c9             	movzbl %cl,%ecx
  801b5b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b5e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b64:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b67:	39 ce                	cmp    %ecx,%esi
  801b69:	74 1b                	je     801b86 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b6b:	39 c3                	cmp    %eax,%ebx
  801b6d:	75 c4                	jne    801b33 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b6f:	8b 42 58             	mov    0x58(%edx),%eax
  801b72:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b75:	50                   	push   %eax
  801b76:	56                   	push   %esi
  801b77:	68 72 2b 80 00       	push   $0x802b72
  801b7c:	e8 6a e8 ff ff       	call   8003eb <cprintf>
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	eb ad                	jmp    801b33 <_pipeisclosed+0xe>
	}
}
  801b86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 28             	sub    $0x28,%esp
  801b9a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b9d:	56                   	push   %esi
  801b9e:	e8 1c f7 ff ff       	call   8012bf <fd2data>
  801ba3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	bf 00 00 00 00       	mov    $0x0,%edi
  801bad:	eb 4b                	jmp    801bfa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801baf:	89 da                	mov    %ebx,%edx
  801bb1:	89 f0                	mov    %esi,%eax
  801bb3:	e8 6d ff ff ff       	call   801b25 <_pipeisclosed>
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	75 48                	jne    801c04 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bbc:	e8 93 f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc1:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc4:	8b 0b                	mov    (%ebx),%ecx
  801bc6:	8d 51 20             	lea    0x20(%ecx),%edx
  801bc9:	39 d0                	cmp    %edx,%eax
  801bcb:	73 e2                	jae    801baf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bd4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd7:	89 c2                	mov    %eax,%edx
  801bd9:	c1 fa 1f             	sar    $0x1f,%edx
  801bdc:	89 d1                	mov    %edx,%ecx
  801bde:	c1 e9 1b             	shr    $0x1b,%ecx
  801be1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801be4:	83 e2 1f             	and    $0x1f,%edx
  801be7:	29 ca                	sub    %ecx,%edx
  801be9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf1:	83 c0 01             	add    $0x1,%eax
  801bf4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf7:	83 c7 01             	add    $0x1,%edi
  801bfa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bfd:	75 c2                	jne    801bc1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bff:	8b 45 10             	mov    0x10(%ebp),%eax
  801c02:	eb 05                	jmp    801c09 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c04:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 18             	sub    $0x18,%esp
  801c1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c1d:	57                   	push   %edi
  801c1e:	e8 9c f6 ff ff       	call   8012bf <fd2data>
  801c23:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c2d:	eb 3d                	jmp    801c6c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c2f:	85 db                	test   %ebx,%ebx
  801c31:	74 04                	je     801c37 <devpipe_read+0x26>
				return i;
  801c33:	89 d8                	mov    %ebx,%eax
  801c35:	eb 44                	jmp    801c7b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c37:	89 f2                	mov    %esi,%edx
  801c39:	89 f8                	mov    %edi,%eax
  801c3b:	e8 e5 fe ff ff       	call   801b25 <_pipeisclosed>
  801c40:	85 c0                	test   %eax,%eax
  801c42:	75 32                	jne    801c76 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c44:	e8 0b f1 ff ff       	call   800d54 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c49:	8b 06                	mov    (%esi),%eax
  801c4b:	3b 46 04             	cmp    0x4(%esi),%eax
  801c4e:	74 df                	je     801c2f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c50:	99                   	cltd   
  801c51:	c1 ea 1b             	shr    $0x1b,%edx
  801c54:	01 d0                	add    %edx,%eax
  801c56:	83 e0 1f             	and    $0x1f,%eax
  801c59:	29 d0                	sub    %edx,%eax
  801c5b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c63:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c66:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c69:	83 c3 01             	add    $0x1,%ebx
  801c6c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c6f:	75 d8                	jne    801c49 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c71:	8b 45 10             	mov    0x10(%ebp),%eax
  801c74:	eb 05                	jmp    801c7b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5f                   	pop    %edi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8e:	50                   	push   %eax
  801c8f:	e8 42 f6 ff ff       	call   8012d6 <fd_alloc>
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	89 c2                	mov    %eax,%edx
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	0f 88 2c 01 00 00    	js     801dcd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	68 07 04 00 00       	push   $0x407
  801ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cac:	6a 00                	push   $0x0
  801cae:	e8 c0 f0 ff ff       	call   800d73 <sys_page_alloc>
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	89 c2                	mov    %eax,%edx
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	0f 88 0d 01 00 00    	js     801dcd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cc0:	83 ec 0c             	sub    $0xc,%esp
  801cc3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc6:	50                   	push   %eax
  801cc7:	e8 0a f6 ff ff       	call   8012d6 <fd_alloc>
  801ccc:	89 c3                	mov    %eax,%ebx
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	0f 88 e2 00 00 00    	js     801dbb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd9:	83 ec 04             	sub    $0x4,%esp
  801cdc:	68 07 04 00 00       	push   $0x407
  801ce1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 88 f0 ff ff       	call   800d73 <sys_page_alloc>
  801ceb:	89 c3                	mov    %eax,%ebx
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	0f 88 c3 00 00 00    	js     801dbb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfe:	e8 bc f5 ff ff       	call   8012bf <fd2data>
  801d03:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d05:	83 c4 0c             	add    $0xc,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	50                   	push   %eax
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 5e f0 ff ff       	call   800d73 <sys_page_alloc>
  801d15:	89 c3                	mov    %eax,%ebx
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	0f 88 89 00 00 00    	js     801dab <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	ff 75 f0             	pushl  -0x10(%ebp)
  801d28:	e8 92 f5 ff ff       	call   8012bf <fd2data>
  801d2d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d34:	50                   	push   %eax
  801d35:	6a 00                	push   $0x0
  801d37:	56                   	push   %esi
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 77 f0 ff ff       	call   800db6 <sys_page_map>
  801d3f:	89 c3                	mov    %eax,%ebx
  801d41:	83 c4 20             	add    $0x20,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 55                	js     801d9d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d48:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d5d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d72:	83 ec 0c             	sub    $0xc,%esp
  801d75:	ff 75 f4             	pushl  -0xc(%ebp)
  801d78:	e8 32 f5 ff ff       	call   8012af <fd2num>
  801d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d82:	83 c4 04             	add    $0x4,%esp
  801d85:	ff 75 f0             	pushl  -0x10(%ebp)
  801d88:	e8 22 f5 ff ff       	call   8012af <fd2num>
  801d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d90:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9b:	eb 30                	jmp    801dcd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d9d:	83 ec 08             	sub    $0x8,%esp
  801da0:	56                   	push   %esi
  801da1:	6a 00                	push   $0x0
  801da3:	e8 50 f0 ff ff       	call   800df8 <sys_page_unmap>
  801da8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dab:	83 ec 08             	sub    $0x8,%esp
  801dae:	ff 75 f0             	pushl  -0x10(%ebp)
  801db1:	6a 00                	push   $0x0
  801db3:	e8 40 f0 ff ff       	call   800df8 <sys_page_unmap>
  801db8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 30 f0 ff ff       	call   800df8 <sys_page_unmap>
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dcd:	89 d0                	mov    %edx,%eax
  801dcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	ff 75 08             	pushl  0x8(%ebp)
  801de3:	e8 3d f5 ff ff       	call   801325 <fd_lookup>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 18                	js     801e07 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	ff 75 f4             	pushl  -0xc(%ebp)
  801df5:	e8 c5 f4 ff ff       	call   8012bf <fd2data>
	return _pipeisclosed(fd, p);
  801dfa:	89 c2                	mov    %eax,%edx
  801dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dff:	e8 21 fd ff ff       	call   801b25 <_pipeisclosed>
  801e04:	83 c4 10             	add    $0x10,%esp
}
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    

00801e09 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e11:	85 f6                	test   %esi,%esi
  801e13:	75 16                	jne    801e2b <wait+0x22>
  801e15:	68 8a 2b 80 00       	push   $0x802b8a
  801e1a:	68 3f 2b 80 00       	push   $0x802b3f
  801e1f:	6a 09                	push   $0x9
  801e21:	68 95 2b 80 00       	push   $0x802b95
  801e26:	e8 e7 e4 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e2b:	89 f3                	mov    %esi,%ebx
  801e2d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e33:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e36:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e3c:	eb 05                	jmp    801e43 <wait+0x3a>
		sys_yield();
  801e3e:	e8 11 ef ff ff       	call   800d54 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e43:	8b 43 48             	mov    0x48(%ebx),%eax
  801e46:	39 c6                	cmp    %eax,%esi
  801e48:	75 07                	jne    801e51 <wait+0x48>
  801e4a:	8b 43 54             	mov    0x54(%ebx),%eax
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	75 ed                	jne    801e3e <wait+0x35>
		sys_yield();
}
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e60:	5d                   	pop    %ebp
  801e61:	c3                   	ret    

00801e62 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e68:	68 a0 2b 80 00       	push   $0x802ba0
  801e6d:	ff 75 0c             	pushl  0xc(%ebp)
  801e70:	e8 fb ea ff ff       	call   800970 <strcpy>
	return 0;
}
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	57                   	push   %edi
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e88:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e8d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e93:	eb 2d                	jmp    801ec2 <devcons_write+0x46>
		m = n - tot;
  801e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e98:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e9a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e9d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ea2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ea5:	83 ec 04             	sub    $0x4,%esp
  801ea8:	53                   	push   %ebx
  801ea9:	03 45 0c             	add    0xc(%ebp),%eax
  801eac:	50                   	push   %eax
  801ead:	57                   	push   %edi
  801eae:	e8 4f ec ff ff       	call   800b02 <memmove>
		sys_cputs(buf, m);
  801eb3:	83 c4 08             	add    $0x8,%esp
  801eb6:	53                   	push   %ebx
  801eb7:	57                   	push   %edi
  801eb8:	e8 fa ed ff ff       	call   800cb7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebd:	01 de                	add    %ebx,%esi
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	89 f0                	mov    %esi,%eax
  801ec4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec7:	72 cc                	jb     801e95 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 08             	sub    $0x8,%esp
  801ed7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801edc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee0:	74 2a                	je     801f0c <devcons_read+0x3b>
  801ee2:	eb 05                	jmp    801ee9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ee4:	e8 6b ee ff ff       	call   800d54 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ee9:	e8 e7 ed ff ff       	call   800cd5 <sys_cgetc>
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	74 f2                	je     801ee4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 16                	js     801f0c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ef6:	83 f8 04             	cmp    $0x4,%eax
  801ef9:	74 0c                	je     801f07 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801efe:	88 02                	mov    %al,(%edx)
	return 1;
  801f00:	b8 01 00 00 00       	mov    $0x1,%eax
  801f05:	eb 05                	jmp    801f0c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f14:	8b 45 08             	mov    0x8(%ebp),%eax
  801f17:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f1a:	6a 01                	push   $0x1
  801f1c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f1f:	50                   	push   %eax
  801f20:	e8 92 ed ff ff       	call   800cb7 <sys_cputs>
}
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <getchar>:

int
getchar(void)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f30:	6a 01                	push   $0x1
  801f32:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f35:	50                   	push   %eax
  801f36:	6a 00                	push   $0x0
  801f38:	e8 4e f6 ff ff       	call   80158b <read>
	if (r < 0)
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 0f                	js     801f53 <getchar+0x29>
		return r;
	if (r < 1)
  801f44:	85 c0                	test   %eax,%eax
  801f46:	7e 06                	jle    801f4e <getchar+0x24>
		return -E_EOF;
	return c;
  801f48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f4c:	eb 05                	jmp    801f53 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f4e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5e:	50                   	push   %eax
  801f5f:	ff 75 08             	pushl  0x8(%ebp)
  801f62:	e8 be f3 ff ff       	call   801325 <fd_lookup>
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 11                	js     801f7f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f71:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f77:	39 10                	cmp    %edx,(%eax)
  801f79:	0f 94 c0             	sete   %al
  801f7c:	0f b6 c0             	movzbl %al,%eax
}
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <opencons>:

int
opencons(void)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8a:	50                   	push   %eax
  801f8b:	e8 46 f3 ff ff       	call   8012d6 <fd_alloc>
  801f90:	83 c4 10             	add    $0x10,%esp
		return r;
  801f93:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f95:	85 c0                	test   %eax,%eax
  801f97:	78 3e                	js     801fd7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f99:	83 ec 04             	sub    $0x4,%esp
  801f9c:	68 07 04 00 00       	push   $0x407
  801fa1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa4:	6a 00                	push   $0x0
  801fa6:	e8 c8 ed ff ff       	call   800d73 <sys_page_alloc>
  801fab:	83 c4 10             	add    $0x10,%esp
		return r;
  801fae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 23                	js     801fd7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fb4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	50                   	push   %eax
  801fcd:	e8 dd f2 ff ff       	call   8012af <fd2num>
  801fd2:	89 c2                	mov    %eax,%edx
  801fd4:	83 c4 10             	add    $0x10,%esp
}
  801fd7:	89 d0                	mov    %edx,%eax
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fe2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fe9:	75 57                	jne    802042 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801feb:	e8 45 ed ff ff       	call   800d35 <sys_getenvid>
  801ff0:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801ff2:	83 ec 04             	sub    $0x4,%esp
  801ff5:	6a 07                	push   $0x7
  801ff7:	68 00 f0 bf ee       	push   $0xeebff000
  801ffc:	50                   	push   %eax
  801ffd:	e8 71 ed ff ff       	call   800d73 <sys_page_alloc>
		if (r) {
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	74 12                	je     80201b <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  802009:	50                   	push   %eax
  80200a:	68 fa 29 80 00       	push   $0x8029fa
  80200f:	6a 25                	push   $0x25
  802011:	68 ac 2b 80 00       	push   $0x802bac
  802016:	e8 f7 e2 ff ff       	call   800312 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  80201b:	83 ec 08             	sub    $0x8,%esp
  80201e:	68 4f 20 80 00       	push   $0x80204f
  802023:	53                   	push   %ebx
  802024:	e8 95 ee ff ff       	call   800ebe <sys_env_set_pgfault_upcall>
		if (r) {
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	85 c0                	test   %eax,%eax
  80202e:	74 12                	je     802042 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  802030:	50                   	push   %eax
  802031:	68 bc 2b 80 00       	push   $0x802bbc
  802036:	6a 2b                	push   $0x2b
  802038:	68 ac 2b 80 00       	push   $0x802bac
  80203d:	e8 d0 e2 ff ff       	call   800312 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80204a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    

0080204f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80204f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802050:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802055:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802057:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  80205a:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  80205e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  802063:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  802067:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  802069:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  80206c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  80206d:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  802070:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  802071:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  802072:	c3                   	ret    

00802073 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	56                   	push   %esi
  802077:	53                   	push   %ebx
  802078:	8b 75 08             	mov    0x8(%ebp),%esi
  80207b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  802081:	85 c0                	test   %eax,%eax
  802083:	74 3e                	je     8020c3 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	50                   	push   %eax
  802089:	e8 95 ee ff ff       	call   800f23 <sys_ipc_recv>
  80208e:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	85 f6                	test   %esi,%esi
  802095:	74 13                	je     8020aa <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802097:	b8 00 00 00 00       	mov    $0x0,%eax
  80209c:	85 d2                	test   %edx,%edx
  80209e:	75 08                	jne    8020a8 <ipc_recv+0x35>
  8020a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a5:	8b 40 74             	mov    0x74(%eax),%eax
  8020a8:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8020aa:	85 db                	test   %ebx,%ebx
  8020ac:	74 48                	je     8020f6 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b3:	85 d2                	test   %edx,%edx
  8020b5:	75 08                	jne    8020bf <ipc_recv+0x4c>
  8020b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020bc:	8b 40 78             	mov    0x78(%eax),%eax
  8020bf:	89 03                	mov    %eax,(%ebx)
  8020c1:	eb 33                	jmp    8020f6 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	68 00 00 c0 ee       	push   $0xeec00000
  8020cb:	e8 53 ee ff ff       	call   800f23 <sys_ipc_recv>
  8020d0:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  8020d2:	83 c4 10             	add    $0x10,%esp
  8020d5:	85 f6                	test   %esi,%esi
  8020d7:	74 13                	je     8020ec <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020de:	85 d2                	test   %edx,%edx
  8020e0:	75 08                	jne    8020ea <ipc_recv+0x77>
  8020e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e7:	8b 40 74             	mov    0x74(%eax),%eax
  8020ea:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8020ec:	85 db                	test   %ebx,%ebx
  8020ee:	74 06                	je     8020f6 <ipc_recv+0x83>
			*perm_store = 0;
  8020f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  8020f6:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  8020f8:	85 d2                	test   %edx,%edx
  8020fa:	75 08                	jne    802104 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  8020fc:	a1 04 40 80 00       	mov    0x804004,%eax
  802101:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  802104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    

0080210b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	57                   	push   %edi
  80210f:	56                   	push   %esi
  802110:	53                   	push   %ebx
  802111:	83 ec 0c             	sub    $0xc,%esp
  802114:	8b 7d 08             	mov    0x8(%ebp),%edi
  802117:	8b 75 0c             	mov    0xc(%ebp),%esi
  80211a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  80211d:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  80211f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802124:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802127:	eb 1c                	jmp    802145 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  802129:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80212c:	74 12                	je     802140 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  80212e:	50                   	push   %eax
  80212f:	68 e4 2b 80 00       	push   $0x802be4
  802134:	6a 4f                	push   $0x4f
  802136:	68 ff 2b 80 00       	push   $0x802bff
  80213b:	e8 d2 e1 ff ff       	call   800312 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802140:	e8 0f ec ff ff       	call   800d54 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802145:	ff 75 14             	pushl  0x14(%ebp)
  802148:	53                   	push   %ebx
  802149:	56                   	push   %esi
  80214a:	57                   	push   %edi
  80214b:	e8 b0 ed ff ff       	call   800f00 <sys_ipc_try_send>
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	85 c0                	test   %eax,%eax
  802155:	78 d2                	js     802129 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215a:	5b                   	pop    %ebx
  80215b:	5e                   	pop    %esi
  80215c:	5f                   	pop    %edi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802165:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80216a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80216d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802173:	8b 52 50             	mov    0x50(%edx),%edx
  802176:	39 ca                	cmp    %ecx,%edx
  802178:	75 0d                	jne    802187 <ipc_find_env+0x28>
			return envs[i].env_id;
  80217a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80217d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802182:	8b 40 48             	mov    0x48(%eax),%eax
  802185:	eb 0f                	jmp    802196 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802187:	83 c0 01             	add    $0x1,%eax
  80218a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218f:	75 d9                	jne    80216a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802191:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219e:	89 d0                	mov    %edx,%eax
  8021a0:	c1 e8 16             	shr    $0x16,%eax
  8021a3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021af:	f6 c1 01             	test   $0x1,%cl
  8021b2:	74 1d                	je     8021d1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b4:	c1 ea 0c             	shr    $0xc,%edx
  8021b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021be:	f6 c2 01             	test   $0x1,%dl
  8021c1:	74 0e                	je     8021d1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c3:	c1 ea 0c             	shr    $0xc,%edx
  8021c6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021cd:	ef 
  8021ce:	0f b7 c0             	movzwl %ax,%eax
}
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
  8021d3:	66 90                	xchg   %ax,%ax
  8021d5:	66 90                	xchg   %ax,%ax
  8021d7:	66 90                	xchg   %ax,%ax
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
