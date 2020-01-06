
obj/user/primespipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 51 15 00 00       	call   8015a2 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 a0 23 80 00       	push   $0x8023a0
  80006d:	6a 15                	push   $0x15
  80006f:	68 cf 23 80 00       	push   $0x8023cf
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 e1 23 80 00       	push   $0x8023e1
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 78 1b 00 00       	call   801c09 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 e5 23 80 00       	push   $0x8023e5
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 cf 23 80 00       	push   $0x8023cf
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 34 0f 00 00       	call   800fe6 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 ee 23 80 00       	push   $0x8023ee
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 cf 23 80 00       	push   $0x8023cf
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 00 13 00 00       	call   8013d5 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 f5 12 00 00       	call   8013d5 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 df 12 00 00       	call   8013d5 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 97 14 00 00       	call   8015a2 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 f7 23 80 00       	push   $0x8023f7
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 cf 23 80 00       	push   $0x8023cf
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 9d 14 00 00       	call   8015eb <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 13 24 80 00       	push   $0x802413
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 cf 23 80 00       	push   $0x8023cf
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 2d 	movl   $0x80242d,0x803000
  800187:	24 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 76 1a 00 00       	call   801c09 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 e5 23 80 00       	push   $0x8023e5
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 cf 23 80 00       	push   $0x8023cf
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 32 0e 00 00       	call   800fe6 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 ee 23 80 00       	push   $0x8023ee
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 cf 23 80 00       	push   $0x8023cf
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 fc 11 00 00       	call   8013d5 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 e6 11 00 00       	call   8013d5 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 e1 13 00 00       	call   8015eb <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 38 24 80 00       	push   $0x802438
  800226:	6a 4a                	push   $0x4a
  800228:	68 cf 23 80 00       	push   $0x8023cf
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 73 0a 00 00       	call   800cbb <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 77 11 00 00       	call   801400 <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 e7 09 00 00       	call   800c7a <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 10 0a 00 00       	call   800cbb <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 5c 24 80 00       	push   $0x80245c
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 2f 09 00 00       	call   800c3d <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 d4 08 00 00       	call   800c3d <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 37 1d 00 00       	call   802110 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 24 1e 00 00       	call   802240 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 7f 24 80 00 	movsbl 0x80247f(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 89 03 00 00    	je     80084d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 1a 03 00 00    	ja     800832 <vprintfmt+0x38a>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 97 24 80 00       	push   $0x802497
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 d1 29 80 00       	push   $0x8029d1
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 90 24 80 00       	mov    $0x802490,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 86 02 00 00       	call   8008d5 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	79 74                	jns    8007fe <vprintfmt+0x356>
				putch('-', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 2d                	push   $0x2d
  800790:	ff d6                	call   *%esi
				num = -(long long) num;
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800798:	f7 d8                	neg    %eax
  80079a:	83 d2 00             	adc    $0x0,%edx
  80079d:	f7 da                	neg    %edx
  80079f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a7:	eb 55                	jmp    8007fe <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ac:	e8 83 fc ff ff       	call   800434 <getuint>
			base = 10;
  8007b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b6:	eb 46                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bb:	e8 74 fc ff ff       	call   800434 <getuint>
			base=8;
  8007c0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007c5:	eb 37                	jmp    8007fe <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 78                	push   $0x78
  8007d5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ef:	eb 0d                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 3b fc ff ff       	call   800434 <getuint>
			base = 16;
  8007f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fe:	83 ec 0c             	sub    $0xc,%esp
  800801:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800805:	57                   	push   %edi
  800806:	ff 75 e0             	pushl  -0x20(%ebp)
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	50                   	push   %eax
  80080c:	89 da                	mov    %ebx,%edx
  80080e:	89 f0                	mov    %esi,%eax
  800810:	e8 70 fb ff ff       	call   800385 <printnum>
			break;
  800815:	83 c4 20             	add    $0x20,%esp
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081b:	e9 ae fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	51                   	push   %ecx
  800825:	ff d6                	call   *%esi
			break;
  800827:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082d:	e9 9c fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 25                	push   $0x25
  800838:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 03                	jmp    800842 <vprintfmt+0x39a>
  80083f:	83 ef 01             	sub    $0x1,%edi
  800842:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800846:	75 f7                	jne    80083f <vprintfmt+0x397>
  800848:	e9 81 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800864:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800868:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800872:	85 c0                	test   %eax,%eax
  800874:	74 26                	je     80089c <vsnprintf+0x47>
  800876:	85 d2                	test   %edx,%edx
  800878:	7e 22                	jle    80089c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087a:	ff 75 14             	pushl  0x14(%ebp)
  80087d:	ff 75 10             	pushl  0x10(%ebp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	68 6e 04 80 00       	push   $0x80046e
  800889:	e8 1a fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800891:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	eb 05                	jmp    8008a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ac:	50                   	push   %eax
  8008ad:	ff 75 10             	pushl  0x10(%ebp)
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 9a ff ff ff       	call   800855 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 03                	jmp    8008cd <strlen+0x10>
		n++;
  8008ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f7                	jne    8008ca <strlen+0xd>
		n++;
	return n;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e3:	eb 03                	jmp    8008e8 <strnlen+0x13>
		n++;
  8008e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	39 c2                	cmp    %eax,%edx
  8008ea:	74 08                	je     8008f4 <strnlen+0x1f>
  8008ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f0:	75 f3                	jne    8008e5 <strnlen+0x10>
  8008f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800900:	89 c2                	mov    %eax,%edx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091d:	53                   	push   %ebx
  80091e:	e8 9a ff ff ff       	call   8008bd <strlen>
  800923:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	50                   	push   %eax
  80092c:	e8 c5 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  800931:	89 d8                	mov    %ebx,%eax
  800933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800943:	89 f3                	mov    %esi,%ebx
  800945:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 0f                	jmp    80095b <strncpy+0x23>
		*dst++ = *src;
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 39 01             	cmpb   $0x1,(%ecx)
  800958:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	75 ed                	jne    80094c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095f:	89 f0                	mov    %esi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 75 08             	mov    0x8(%ebp),%esi
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	8b 55 10             	mov    0x10(%ebp),%edx
  800973:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	85 d2                	test   %edx,%edx
  800977:	74 21                	je     80099a <strlcpy+0x35>
  800979:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	eb 09                	jmp    80098a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	74 09                	je     800997 <strlcpy+0x32>
  80098e:	0f b6 19             	movzbl (%ecx),%ebx
  800991:	84 db                	test   %bl,%bl
  800993:	75 ec                	jne    800981 <strlcpy+0x1c>
  800995:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f0                	sub    %esi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a9:	eb 06                	jmp    8009b1 <strcmp+0x11>
		p++, q++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 04                	je     8009bc <strcmp+0x1c>
  8009b8:	3a 02                	cmp    (%edx),%al
  8009ba:	74 ef                	je     8009ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 c0             	movzbl %al,%eax
  8009bf:	0f b6 12             	movzbl (%edx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strncmp+0x17>
		n--, p++, q++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dd:	39 d8                	cmp    %ebx,%eax
  8009df:	74 15                	je     8009f6 <strncmp+0x30>
  8009e1:	0f b6 08             	movzbl (%eax),%ecx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	74 04                	je     8009ec <strncmp+0x26>
  8009e8:	3a 0a                	cmp    (%edx),%cl
  8009ea:	74 eb                	je     8009d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	eb 05                	jmp    8009fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 07                	jmp    800a11 <strchr+0x13>
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 0f                	je     800a1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f2                	jne    800a0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	eb 03                	jmp    800a2e <strfind+0xf>
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 04                	je     800a39 <strfind+0x1a>
  800a35:	84 d2                	test   %dl,%dl
  800a37:	75 f2                	jne    800a2b <strfind+0xc>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 36                	je     800a81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 28                	jne    800a7b <memset+0x40>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 23                	jne    800a7b <memset+0x40>
		c &= 0xFF;
  800a58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	c1 e3 08             	shl    $0x8,%ebx
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 18             	shl    $0x18,%esi
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 10             	shl    $0x10,%eax
  800a6b:	09 f0                	or     %esi,%eax
  800a6d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	09 d0                	or     %edx,%eax
  800a73:	c1 e9 02             	shr    $0x2,%ecx
  800a76:	fc                   	cld    
  800a77:	f3 ab                	rep stos %eax,%es:(%edi)
  800a79:	eb 06                	jmp    800a81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	fc                   	cld    
  800a7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a81:	89 f8                	mov    %edi,%eax
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 35                	jae    800acf <memmove+0x47>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2e                	jae    800acf <memmove+0x47>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	09 fe                	or     %edi,%esi
  800aa8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aae:	75 13                	jne    800ac3 <memmove+0x3b>
  800ab0:	f6 c1 03             	test   $0x3,%cl
  800ab3:	75 0e                	jne    800ac3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab5:	83 ef 04             	sub    $0x4,%edi
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac3:	83 ef 01             	sub    $0x1,%edi
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1d                	jmp    800aec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	09 c2                	or     %eax,%edx
  800ad3:	f6 c2 03             	test   $0x3,%dl
  800ad6:	75 0f                	jne    800ae7 <memmove+0x5f>
  800ad8:	f6 c1 03             	test   $0x3,%cl
  800adb:	75 0a                	jne    800ae7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae5:	eb 05                	jmp    800aec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	fc                   	cld    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 87 ff ff ff       	call   800a88 <memmove>
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c6                	mov    %eax,%esi
  800b10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	eb 1a                	jmp    800b2f <memcmp+0x2c>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	74 0a                	je     800b29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 0f                	jmp    800b38 <memcmp+0x35>
		s1++, s2++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	39 f0                	cmp    %esi,%eax
  800b31:	75 e2                	jne    800b15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4c:	eb 0a                	jmp    800b58 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	0f b6 10             	movzbl (%eax),%edx
  800b51:	39 da                	cmp    %ebx,%edx
  800b53:	74 07                	je     800b5c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	39 c8                	cmp    %ecx,%eax
  800b5a:	72 f2                	jb     800b4e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	75 0a                	jne    800b89 <strtol+0x2a>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb 11                	jmp    800b9a <strtol+0x3b>
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	75 08                	jne    800b9a <strtol+0x3b>
		s++, neg = 1;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 15                	jne    800bb7 <strtol+0x58>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	75 10                	jne    800bb7 <strtol+0x58>
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	75 7c                	jne    800c29 <strtol+0xca>
		s += 2, base = 16;
  800bad:	83 c1 02             	add    $0x2,%ecx
  800bb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb5:	eb 16                	jmp    800bcd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 12                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc3:	75 08                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 11             	movzbl (%ecx),%edx
  800bd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 08                	ja     800bea <strtol+0x8b>
			dig = *s - '0';
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 30             	sub    $0x30,%edx
  800be8:	eb 22                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf4:	0f be d2             	movsbl %dl,%edx
  800bf7:	83 ea 57             	sub    $0x57,%edx
  800bfa:	eb 10                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 16                	ja     800c1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	7d 0b                	jge    800c1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c1a:	eb b9                	jmp    800bd5 <strtol+0x76>

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 0d                	je     800c2f <strtol+0xd0>
		*endptr = (char *) s;
  800c22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c25:	89 0e                	mov    %ecx,(%esi)
  800c27:	eb 06                	jmp    800c2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	85 db                	test   %ebx,%ebx
  800c2b:	74 98                	je     800bc5 <strtol+0x66>
  800c2d:	eb 9e                	jmp    800bcd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	f7 da                	neg    %edx
  800c33:	85 ff                	test   %edi,%edi
  800c35:	0f 45 c2             	cmovne %edx,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 cb                	mov    %ecx,%ebx
  800c92:	89 cf                	mov    %ecx,%edi
  800c94:	89 ce                	mov    %ecx,%esi
  800c96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 03                	push   $0x3
  800ca2:	68 7f 27 80 00       	push   $0x80277f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 9c 27 80 00       	push   $0x80279c
  800cae:	e8 e5 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 04                	push   $0x4
  800d23:	68 7f 27 80 00       	push   $0x80277f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 9c 27 80 00       	push   $0x80279c
  800d2f:	e8 64 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d56:	8b 75 18             	mov    0x18(%ebp),%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 05                	push   $0x5
  800d65:	68 7f 27 80 00       	push   $0x80277f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 9c 27 80 00       	push   $0x80279c
  800d71:	e8 22 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 06                	push   $0x6
  800da7:	68 7f 27 80 00       	push   $0x80277f
  800dac:	6a 23                	push   $0x23
  800dae:	68 9c 27 80 00       	push   $0x80279c
  800db3:	e8 e0 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 08                	push   $0x8
  800de9:	68 7f 27 80 00       	push   $0x80277f
  800dee:	6a 23                	push   $0x23
  800df0:	68 9c 27 80 00       	push   $0x80279c
  800df5:	e8 9e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 09 00 00 00       	mov    $0x9,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 09                	push   $0x9
  800e2b:	68 7f 27 80 00       	push   $0x80277f
  800e30:	6a 23                	push   $0x23
  800e32:	68 9c 27 80 00       	push   $0x80279c
  800e37:	e8 5c f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 df                	mov    %ebx,%edi
  800e5f:	89 de                	mov    %ebx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 0a                	push   $0xa
  800e6d:	68 7f 27 80 00       	push   $0x80277f
  800e72:	6a 23                	push   $0x23
  800e74:	68 9c 27 80 00       	push   $0x80279c
  800e79:	e8 1a f4 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 17                	jle    800ee2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 0d                	push   $0xd
  800ed1:	68 7f 27 80 00       	push   $0x80277f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 9c 27 80 00       	push   $0x80279c
  800edd:	e8 b6 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef2:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800ef4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef8:	75 14                	jne    800f0e <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800efa:	83 ec 04             	sub    $0x4,%esp
  800efd:	68 ac 27 80 00       	push   $0x8027ac
  800f02:	6a 23                	push   $0x23
  800f04:	68 6f 28 80 00       	push   $0x80286f
  800f09:	e8 8a f3 ff ff       	call   800298 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800f0e:	89 d8                	mov    %ebx,%eax
  800f10:	c1 e8 0c             	shr    $0xc,%eax
  800f13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1a:	f6 c4 08             	test   $0x8,%ah
  800f1d:	75 14                	jne    800f33 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	68 d0 27 80 00       	push   $0x8027d0
  800f27:	6a 2d                	push   $0x2d
  800f29:	68 6f 28 80 00       	push   $0x80286f
  800f2e:	e8 65 f3 ff ff       	call   800298 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800f33:	e8 83 fd ff ff       	call   800cbb <sys_getenvid>
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	6a 07                	push   $0x7
  800f3d:	68 00 f0 7f 00       	push   $0x7ff000
  800f42:	50                   	push   %eax
  800f43:	e8 b1 fd ff ff       	call   800cf9 <sys_page_alloc>
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	79 12                	jns    800f61 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800f4f:	50                   	push   %eax
  800f50:	68 7a 28 80 00       	push   $0x80287a
  800f55:	6a 3b                	push   $0x3b
  800f57:	68 6f 28 80 00       	push   $0x80286f
  800f5c:	e8 37 f3 ff ff       	call   800298 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800f61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800f67:	83 ec 04             	sub    $0x4,%esp
  800f6a:	68 00 10 00 00       	push   $0x1000
  800f6f:	53                   	push   %ebx
  800f70:	68 00 f0 7f 00       	push   $0x7ff000
  800f75:	e8 0e fb ff ff       	call   800a88 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800f7a:	e8 3c fd ff ff       	call   800cbb <sys_getenvid>
  800f7f:	89 c6                	mov    %eax,%esi
  800f81:	e8 35 fd ff ff       	call   800cbb <sys_getenvid>
  800f86:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f8d:	53                   	push   %ebx
  800f8e:	56                   	push   %esi
  800f8f:	68 00 f0 7f 00       	push   $0x7ff000
  800f94:	50                   	push   %eax
  800f95:	e8 a2 fd ff ff       	call   800d3c <sys_page_map>
  800f9a:	83 c4 20             	add    $0x20,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	79 12                	jns    800fb3 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800fa1:	50                   	push   %eax
  800fa2:	68 93 28 80 00       	push   $0x802893
  800fa7:	6a 48                	push   $0x48
  800fa9:	68 6f 28 80 00       	push   $0x80286f
  800fae:	e8 e5 f2 ff ff       	call   800298 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800fb3:	e8 03 fd ff ff       	call   800cbb <sys_getenvid>
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	68 00 f0 7f 00       	push   $0x7ff000
  800fc0:	50                   	push   %eax
  800fc1:	e8 b8 fd ff ff       	call   800d7e <sys_page_unmap>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	79 12                	jns    800fdf <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800fcd:	50                   	push   %eax
  800fce:	68 aa 28 80 00       	push   $0x8028aa
  800fd3:	6a 4c                	push   $0x4c
  800fd5:	68 6f 28 80 00       	push   $0x80286f
  800fda:	e8 b9 f2 ff ff       	call   800298 <_panic>
	}

	//panic("pgfault not implemented");
}
  800fdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    

00800fe6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	57                   	push   %edi
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
  800fec:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800fef:	68 ea 0e 80 00       	push   $0x800eea
  800ff4:	e8 19 0f 00 00       	call   801f12 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ff9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffe:	cd 30                	int    $0x30
  801000:	89 c7                	mov    %eax,%edi
  801002:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 15                	jns    801021 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  80100c:	50                   	push   %eax
  80100d:	68 c3 28 80 00       	push   $0x8028c3
  801012:	68 a1 00 00 00       	push   $0xa1
  801017:	68 6f 28 80 00       	push   $0x80286f
  80101c:	e8 77 f2 ff ff       	call   800298 <_panic>
  801021:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  801026:	85 c0                	test   %eax,%eax
  801028:	75 21                	jne    80104b <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  80102a:	e8 8c fc ff ff       	call   800cbb <sys_getenvid>
  80102f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801034:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801037:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801041:	b8 00 00 00 00       	mov    $0x0,%eax
  801046:	e9 c8 01 00 00       	jmp    801213 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	c1 e8 16             	shr    $0x16,%eax
  801050:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801057:	a8 01                	test   $0x1,%al
  801059:	0f 84 23 01 00 00    	je     801182 <fork+0x19c>
  80105f:	89 d8                	mov    %ebx,%eax
  801061:	c1 e8 0c             	shr    $0xc,%eax
  801064:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106b:	f6 c2 01             	test   $0x1,%dl
  80106e:	0f 84 0e 01 00 00    	je     801182 <fork+0x19c>
  801074:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107b:	f6 c2 04             	test   $0x4,%dl
  80107e:	0f 84 fe 00 00 00    	je     801182 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  801084:	89 c6                	mov    %eax,%esi
  801086:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  801089:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801090:	f6 c6 04             	test   $0x4,%dh
  801093:	74 3f                	je     8010d4 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  801095:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a4:	50                   	push   %eax
  8010a5:	56                   	push   %esi
  8010a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a9:	56                   	push   %esi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 8b fc ff ff       	call   800d3c <sys_page_map>
  8010b1:	83 c4 20             	add    $0x20,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	0f 89 c6 00 00 00    	jns    801182 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	50                   	push   %eax
  8010c0:	57                   	push   %edi
  8010c1:	6a 00                	push   $0x0
  8010c3:	68 00 28 80 00       	push   $0x802800
  8010c8:	6a 6c                	push   $0x6c
  8010ca:	68 6f 28 80 00       	push   $0x80286f
  8010cf:	e8 c4 f1 ff ff       	call   800298 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010db:	f6 c2 02             	test   $0x2,%dl
  8010de:	75 0c                	jne    8010ec <fork+0x106>
  8010e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e7:	f6 c4 08             	test   $0x8,%ah
  8010ea:	74 66                	je     801152 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	68 05 08 00 00       	push   $0x805
  8010f4:	56                   	push   %esi
  8010f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f8:	56                   	push   %esi
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 3c fc ff ff       	call   800d3c <sys_page_map>
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 18                	jns    80111f <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	50                   	push   %eax
  80110b:	57                   	push   %edi
  80110c:	6a 00                	push   $0x0
  80110e:	68 00 28 80 00       	push   $0x802800
  801113:	6a 74                	push   $0x74
  801115:	68 6f 28 80 00       	push   $0x80286f
  80111a:	e8 79 f1 ff ff       	call   800298 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	68 05 08 00 00       	push   $0x805
  801127:	56                   	push   %esi
  801128:	6a 00                	push   $0x0
  80112a:	56                   	push   %esi
  80112b:	6a 00                	push   $0x0
  80112d:	e8 0a fc ff ff       	call   800d3c <sys_page_map>
  801132:	83 c4 20             	add    $0x20,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	79 49                	jns    801182 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	50                   	push   %eax
  80113d:	6a 00                	push   $0x0
  80113f:	6a 00                	push   $0x0
  801141:	68 00 28 80 00       	push   $0x802800
  801146:	6a 77                	push   $0x77
  801148:	68 6f 28 80 00       	push   $0x80286f
  80114d:	e8 46 f1 ff ff       	call   800298 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	6a 05                	push   $0x5
  801157:	56                   	push   %esi
  801158:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115b:	56                   	push   %esi
  80115c:	6a 00                	push   $0x0
  80115e:	e8 d9 fb ff ff       	call   800d3c <sys_page_map>
  801163:	83 c4 20             	add    $0x20,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	79 18                	jns    801182 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	50                   	push   %eax
  80116e:	57                   	push   %edi
  80116f:	6a 00                	push   $0x0
  801171:	68 00 28 80 00       	push   $0x802800
  801176:	6a 7d                	push   $0x7d
  801178:	68 6f 28 80 00       	push   $0x80286f
  80117d:	e8 16 f1 ff ff       	call   800298 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801182:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801188:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80118e:	0f 85 b7 fe ff ff    	jne    80104b <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	6a 07                	push   $0x7
  801199:	68 00 f0 bf ee       	push   $0xeebff000
  80119e:	57                   	push   %edi
  80119f:	e8 55 fb ff ff       	call   800cf9 <sys_page_alloc>
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	79 15                	jns    8011c0 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  8011ab:	50                   	push   %eax
  8011ac:	68 2c 28 80 00       	push   $0x80282c
  8011b1:	68 b4 00 00 00       	push   $0xb4
  8011b6:	68 6f 28 80 00       	push   $0x80286f
  8011bb:	e8 d8 f0 ff ff       	call   800298 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	68 86 1f 80 00       	push   $0x801f86
  8011c8:	57                   	push   %edi
  8011c9:	e8 76 fc ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 15                	jns    8011ea <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  8011d5:	50                   	push   %eax
  8011d6:	68 d9 28 80 00       	push   $0x8028d9
  8011db:	68 ba 00 00 00       	push   $0xba
  8011e0:	68 6f 28 80 00       	push   $0x80286f
  8011e5:	e8 ae f0 ff ff       	call   800298 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	6a 02                	push   $0x2
  8011ef:	57                   	push   %edi
  8011f0:	e8 cb fb ff ff       	call   800dc0 <sys_env_set_status>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	79 15                	jns    801211 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  8011fc:	50                   	push   %eax
  8011fd:	68 f6 28 80 00       	push   $0x8028f6
  801202:	68 bf 00 00 00       	push   $0xbf
  801207:	68 6f 28 80 00       	push   $0x80286f
  80120c:	e8 87 f0 ff ff       	call   800298 <_panic>
	}
	return eid;
  801211:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sfork>:

// Challenge!
int
sfork(void)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801221:	68 13 29 80 00       	push   $0x802913
  801226:	68 ca 00 00 00       	push   $0xca
  80122b:	68 6f 28 80 00       	push   $0x80286f
  801230:	e8 63 f0 ff ff       	call   800298 <_panic>

00801235 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	05 00 00 00 30       	add    $0x30000000,%eax
  801240:	c1 e8 0c             	shr    $0xc,%eax
}
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801248:	8b 45 08             	mov    0x8(%ebp),%eax
  80124b:	05 00 00 00 30       	add    $0x30000000,%eax
  801250:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801255:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801262:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 16             	shr    $0x16,%edx
  80126c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801273:	f6 c2 01             	test   $0x1,%dl
  801276:	74 11                	je     801289 <fd_alloc+0x2d>
  801278:	89 c2                	mov    %eax,%edx
  80127a:	c1 ea 0c             	shr    $0xc,%edx
  80127d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801284:	f6 c2 01             	test   $0x1,%dl
  801287:	75 09                	jne    801292 <fd_alloc+0x36>
			*fd_store = fd;
  801289:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
  801290:	eb 17                	jmp    8012a9 <fd_alloc+0x4d>
  801292:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801297:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129c:	75 c9                	jne    801267 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80129e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012a4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b1:	83 f8 1f             	cmp    $0x1f,%eax
  8012b4:	77 36                	ja     8012ec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b6:	c1 e0 0c             	shl    $0xc,%eax
  8012b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	c1 ea 16             	shr    $0x16,%edx
  8012c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	74 24                	je     8012f3 <fd_lookup+0x48>
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	c1 ea 0c             	shr    $0xc,%edx
  8012d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012db:	f6 c2 01             	test   $0x1,%dl
  8012de:	74 1a                	je     8012fa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e3:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	eb 13                	jmp    8012ff <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f1:	eb 0c                	jmp    8012ff <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb 05                	jmp    8012ff <fd_lookup+0x54>
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130a:	ba a8 29 80 00       	mov    $0x8029a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80130f:	eb 13                	jmp    801324 <dev_lookup+0x23>
  801311:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801314:	39 08                	cmp    %ecx,(%eax)
  801316:	75 0c                	jne    801324 <dev_lookup+0x23>
			*dev = devtab[i];
  801318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	eb 2e                	jmp    801352 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801324:	8b 02                	mov    (%edx),%eax
  801326:	85 c0                	test   %eax,%eax
  801328:	75 e7                	jne    801311 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80132a:	a1 04 40 80 00       	mov    0x804004,%eax
  80132f:	8b 40 48             	mov    0x48(%eax),%eax
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	51                   	push   %ecx
  801336:	50                   	push   %eax
  801337:	68 2c 29 80 00       	push   $0x80292c
  80133c:	e8 30 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  801341:	8b 45 0c             	mov    0xc(%ebp),%eax
  801344:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	56                   	push   %esi
  801358:	53                   	push   %ebx
  801359:	83 ec 10             	sub    $0x10,%esp
  80135c:	8b 75 08             	mov    0x8(%ebp),%esi
  80135f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80136c:	c1 e8 0c             	shr    $0xc,%eax
  80136f:	50                   	push   %eax
  801370:	e8 36 ff ff ff       	call   8012ab <fd_lookup>
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 05                	js     801381 <fd_close+0x2d>
	    || fd != fd2)
  80137c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80137f:	74 0c                	je     80138d <fd_close+0x39>
		return (must_exist ? r : 0);
  801381:	84 db                	test   %bl,%bl
  801383:	ba 00 00 00 00       	mov    $0x0,%edx
  801388:	0f 44 c2             	cmove  %edx,%eax
  80138b:	eb 41                	jmp    8013ce <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	ff 36                	pushl  (%esi)
  801396:	e8 66 ff ff ff       	call   801301 <dev_lookup>
  80139b:	89 c3                	mov    %eax,%ebx
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 1a                	js     8013be <fd_close+0x6a>
		if (dev->dev_close)
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	74 0b                	je     8013be <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	56                   	push   %esi
  8013b7:	ff d0                	call   *%eax
  8013b9:	89 c3                	mov    %eax,%ebx
  8013bb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	56                   	push   %esi
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 b5 f9 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 d8                	mov    %ebx,%eax
}
  8013ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013de:	50                   	push   %eax
  8013df:	ff 75 08             	pushl  0x8(%ebp)
  8013e2:	e8 c4 fe ff ff       	call   8012ab <fd_lookup>
  8013e7:	83 c4 08             	add    $0x8,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 10                	js     8013fe <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	6a 01                	push   $0x1
  8013f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f6:	e8 59 ff ff ff       	call   801354 <fd_close>
  8013fb:	83 c4 10             	add    $0x10,%esp
}
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <close_all>:

void
close_all(void)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801407:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	53                   	push   %ebx
  801410:	e8 c0 ff ff ff       	call   8013d5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801415:	83 c3 01             	add    $0x1,%ebx
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	83 fb 20             	cmp    $0x20,%ebx
  80141e:	75 ec                	jne    80140c <close_all+0xc>
		close(i);
}
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 2c             	sub    $0x2c,%esp
  80142e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801431:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 6e fe ff ff       	call   8012ab <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	0f 88 c1 00 00 00    	js     801509 <dup+0xe4>
		return r;
	close(newfdnum);
  801448:	83 ec 0c             	sub    $0xc,%esp
  80144b:	56                   	push   %esi
  80144c:	e8 84 ff ff ff       	call   8013d5 <close>

	newfd = INDEX2FD(newfdnum);
  801451:	89 f3                	mov    %esi,%ebx
  801453:	c1 e3 0c             	shl    $0xc,%ebx
  801456:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80145c:	83 c4 04             	add    $0x4,%esp
  80145f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801462:	e8 de fd ff ff       	call   801245 <fd2data>
  801467:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801469:	89 1c 24             	mov    %ebx,(%esp)
  80146c:	e8 d4 fd ff ff       	call   801245 <fd2data>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801477:	89 f8                	mov    %edi,%eax
  801479:	c1 e8 16             	shr    $0x16,%eax
  80147c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801483:	a8 01                	test   $0x1,%al
  801485:	74 37                	je     8014be <dup+0x99>
  801487:	89 f8                	mov    %edi,%eax
  801489:	c1 e8 0c             	shr    $0xc,%eax
  80148c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 26                	je     8014be <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801498:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149f:	83 ec 0c             	sub    $0xc,%esp
  8014a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ab:	6a 00                	push   $0x0
  8014ad:	57                   	push   %edi
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 87 f8 ff ff       	call   800d3c <sys_page_map>
  8014b5:	89 c7                	mov    %eax,%edi
  8014b7:	83 c4 20             	add    $0x20,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 2e                	js     8014ec <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c1:	89 d0                	mov    %edx,%eax
  8014c3:	c1 e8 0c             	shr    $0xc,%eax
  8014c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d5:	50                   	push   %eax
  8014d6:	53                   	push   %ebx
  8014d7:	6a 00                	push   $0x0
  8014d9:	52                   	push   %edx
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 5b f8 ff ff       	call   800d3c <sys_page_map>
  8014e1:	89 c7                	mov    %eax,%edi
  8014e3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014e6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e8:	85 ff                	test   %edi,%edi
  8014ea:	79 1d                	jns    801509 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	53                   	push   %ebx
  8014f0:	6a 00                	push   $0x0
  8014f2:	e8 87 f8 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 7a f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	89 f8                	mov    %edi,%eax
}
  801509:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	53                   	push   %ebx
  801515:	83 ec 14             	sub    $0x14,%esp
  801518:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	53                   	push   %ebx
  801520:	e8 86 fd ff ff       	call   8012ab <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	89 c2                	mov    %eax,%edx
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 6d                	js     80159b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	ff 30                	pushl  (%eax)
  80153a:	e8 c2 fd ff ff       	call   801301 <dev_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 4c                	js     801592 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801546:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801549:	8b 42 08             	mov    0x8(%edx),%eax
  80154c:	83 e0 03             	and    $0x3,%eax
  80154f:	83 f8 01             	cmp    $0x1,%eax
  801552:	75 21                	jne    801575 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801554:	a1 04 40 80 00       	mov    0x804004,%eax
  801559:	8b 40 48             	mov    0x48(%eax),%eax
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	53                   	push   %ebx
  801560:	50                   	push   %eax
  801561:	68 6d 29 80 00       	push   $0x80296d
  801566:	e8 06 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801573:	eb 26                	jmp    80159b <read+0x8a>
	}
	if (!dev->dev_read)
  801575:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801578:	8b 40 08             	mov    0x8(%eax),%eax
  80157b:	85 c0                	test   %eax,%eax
  80157d:	74 17                	je     801596 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	ff 75 10             	pushl  0x10(%ebp)
  801585:	ff 75 0c             	pushl  0xc(%ebp)
  801588:	52                   	push   %edx
  801589:	ff d0                	call   *%eax
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 09                	jmp    80159b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	89 c2                	mov    %eax,%edx
  801594:	eb 05                	jmp    80159b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801596:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	57                   	push   %edi
  8015a6:	56                   	push   %esi
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 0c             	sub    $0xc,%esp
  8015ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b6:	eb 21                	jmp    8015d9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	89 f0                	mov    %esi,%eax
  8015bd:	29 d8                	sub    %ebx,%eax
  8015bf:	50                   	push   %eax
  8015c0:	89 d8                	mov    %ebx,%eax
  8015c2:	03 45 0c             	add    0xc(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	57                   	push   %edi
  8015c7:	e8 45 ff ff ff       	call   801511 <read>
		if (m < 0)
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 10                	js     8015e3 <readn+0x41>
			return m;
		if (m == 0)
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	74 0a                	je     8015e1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d7:	01 c3                	add    %eax,%ebx
  8015d9:	39 f3                	cmp    %esi,%ebx
  8015db:	72 db                	jb     8015b8 <readn+0x16>
  8015dd:	89 d8                	mov    %ebx,%eax
  8015df:	eb 02                	jmp    8015e3 <readn+0x41>
  8015e1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e6:	5b                   	pop    %ebx
  8015e7:	5e                   	pop    %esi
  8015e8:	5f                   	pop    %edi
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    

008015eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 14             	sub    $0x14,%esp
  8015f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	53                   	push   %ebx
  8015fa:	e8 ac fc ff ff       	call   8012ab <fd_lookup>
  8015ff:	83 c4 08             	add    $0x8,%esp
  801602:	89 c2                	mov    %eax,%edx
  801604:	85 c0                	test   %eax,%eax
  801606:	78 68                	js     801670 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	ff 30                	pushl  (%eax)
  801614:	e8 e8 fc ff ff       	call   801301 <dev_lookup>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 47                	js     801667 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801627:	75 21                	jne    80164a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801629:	a1 04 40 80 00       	mov    0x804004,%eax
  80162e:	8b 40 48             	mov    0x48(%eax),%eax
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	53                   	push   %ebx
  801635:	50                   	push   %eax
  801636:	68 89 29 80 00       	push   $0x802989
  80163b:	e8 31 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801648:	eb 26                	jmp    801670 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164d:	8b 52 0c             	mov    0xc(%edx),%edx
  801650:	85 d2                	test   %edx,%edx
  801652:	74 17                	je     80166b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	ff 75 10             	pushl  0x10(%ebp)
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	50                   	push   %eax
  80165e:	ff d2                	call   *%edx
  801660:	89 c2                	mov    %eax,%edx
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 09                	jmp    801670 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801667:	89 c2                	mov    %eax,%edx
  801669:	eb 05                	jmp    801670 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80166b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801670:	89 d0                	mov    %edx,%eax
  801672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <seek>:

int
seek(int fdnum, off_t offset)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 22 fc ff ff       	call   8012ab <fd_lookup>
  801689:	83 c4 08             	add    $0x8,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 0e                	js     80169e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801690:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801693:	8b 55 0c             	mov    0xc(%ebp),%edx
  801696:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 14             	sub    $0x14,%esp
  8016a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	53                   	push   %ebx
  8016af:	e8 f7 fb ff ff       	call   8012ab <fd_lookup>
  8016b4:	83 c4 08             	add    $0x8,%esp
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 65                	js     801722 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c7:	ff 30                	pushl  (%eax)
  8016c9:	e8 33 fc ff ff       	call   801301 <dev_lookup>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 44                	js     801719 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016dc:	75 21                	jne    8016ff <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016de:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e3:	8b 40 48             	mov    0x48(%eax),%eax
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	50                   	push   %eax
  8016eb:	68 4c 29 80 00       	push   $0x80294c
  8016f0:	e8 7c ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016fd:	eb 23                	jmp    801722 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801702:	8b 52 18             	mov    0x18(%edx),%edx
  801705:	85 d2                	test   %edx,%edx
  801707:	74 14                	je     80171d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	ff d2                	call   *%edx
  801712:	89 c2                	mov    %eax,%edx
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	eb 09                	jmp    801722 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	89 c2                	mov    %eax,%edx
  80171b:	eb 05                	jmp    801722 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80171d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801722:	89 d0                	mov    %edx,%eax
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	83 ec 14             	sub    $0x14,%esp
  801730:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	ff 75 08             	pushl  0x8(%ebp)
  80173a:	e8 6c fb ff ff       	call   8012ab <fd_lookup>
  80173f:	83 c4 08             	add    $0x8,%esp
  801742:	89 c2                	mov    %eax,%edx
  801744:	85 c0                	test   %eax,%eax
  801746:	78 58                	js     8017a0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801752:	ff 30                	pushl  (%eax)
  801754:	e8 a8 fb ff ff       	call   801301 <dev_lookup>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 37                	js     801797 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801760:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801763:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801767:	74 32                	je     80179b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801769:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80176c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801773:	00 00 00 
	stat->st_isdir = 0;
  801776:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80177d:	00 00 00 
	stat->st_dev = dev;
  801780:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	53                   	push   %ebx
  80178a:	ff 75 f0             	pushl  -0x10(%ebp)
  80178d:	ff 50 14             	call   *0x14(%eax)
  801790:	89 c2                	mov    %eax,%edx
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	eb 09                	jmp    8017a0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801797:	89 c2                	mov    %eax,%edx
  801799:	eb 05                	jmp    8017a0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80179b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a0:	89 d0                	mov    %edx,%eax
  8017a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	56                   	push   %esi
  8017ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	6a 00                	push   $0x0
  8017b1:	ff 75 08             	pushl  0x8(%ebp)
  8017b4:	e8 d6 01 00 00       	call   80198f <open>
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 1b                	js     8017dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	ff 75 0c             	pushl  0xc(%ebp)
  8017c8:	50                   	push   %eax
  8017c9:	e8 5b ff ff ff       	call   801729 <fstat>
  8017ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d0:	89 1c 24             	mov    %ebx,(%esp)
  8017d3:	e8 fd fb ff ff       	call   8013d5 <close>
	return r;
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	89 f0                	mov    %esi,%eax
}
  8017dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	89 c6                	mov    %eax,%esi
  8017eb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ed:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f4:	75 12                	jne    801808 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	6a 01                	push   $0x1
  8017fb:	e8 96 08 00 00       	call   802096 <ipc_find_env>
  801800:	a3 00 40 80 00       	mov    %eax,0x804000
  801805:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801808:	6a 07                	push   $0x7
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	56                   	push   %esi
  801810:	ff 35 00 40 80 00    	pushl  0x804000
  801816:	e8 27 08 00 00       	call   802042 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181b:	83 c4 0c             	add    $0xc,%esp
  80181e:	6a 00                	push   $0x0
  801820:	53                   	push   %ebx
  801821:	6a 00                	push   $0x0
  801823:	e8 82 07 00 00       	call   801faa <ipc_recv>
}
  801828:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	8b 40 0c             	mov    0xc(%eax),%eax
  80183b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801840:	8b 45 0c             	mov    0xc(%ebp),%eax
  801843:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801848:	ba 00 00 00 00       	mov    $0x0,%edx
  80184d:	b8 02 00 00 00       	mov    $0x2,%eax
  801852:	e8 8d ff ff ff       	call   8017e4 <fsipc>
}
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 40 0c             	mov    0xc(%eax),%eax
  801865:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186a:	ba 00 00 00 00       	mov    $0x0,%edx
  80186f:	b8 06 00 00 00       	mov    $0x6,%eax
  801874:	e8 6b ff ff ff       	call   8017e4 <fsipc>
}
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	8b 40 0c             	mov    0xc(%eax),%eax
  80188b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801890:	ba 00 00 00 00       	mov    $0x0,%edx
  801895:	b8 05 00 00 00       	mov    $0x5,%eax
  80189a:	e8 45 ff ff ff       	call   8017e4 <fsipc>
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	78 2c                	js     8018cf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	68 00 50 80 00       	push   $0x805000
  8018ab:	53                   	push   %ebx
  8018ac:	e8 45 f0 ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018e9:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ee:	50                   	push   %eax
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	68 08 50 80 00       	push   $0x805008
  8018f7:	e8 8c f1 ff ff       	call   800a88 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801901:	b8 04 00 00 00       	mov    $0x4,%eax
  801906:	e8 d9 fe ff ff       	call   8017e4 <fsipc>
	//panic("devfile_write not implemented");
}
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801920:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801926:	ba 00 00 00 00       	mov    $0x0,%edx
  80192b:	b8 03 00 00 00       	mov    $0x3,%eax
  801930:	e8 af fe ff ff       	call   8017e4 <fsipc>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	85 c0                	test   %eax,%eax
  801939:	78 4b                	js     801986 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193b:	39 c6                	cmp    %eax,%esi
  80193d:	73 16                	jae    801955 <devfile_read+0x48>
  80193f:	68 b8 29 80 00       	push   $0x8029b8
  801944:	68 bf 29 80 00       	push   $0x8029bf
  801949:	6a 7c                	push   $0x7c
  80194b:	68 d4 29 80 00       	push   $0x8029d4
  801950:	e8 43 e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801955:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195a:	7e 16                	jle    801972 <devfile_read+0x65>
  80195c:	68 df 29 80 00       	push   $0x8029df
  801961:	68 bf 29 80 00       	push   $0x8029bf
  801966:	6a 7d                	push   $0x7d
  801968:	68 d4 29 80 00       	push   $0x8029d4
  80196d:	e8 26 e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801972:	83 ec 04             	sub    $0x4,%esp
  801975:	50                   	push   %eax
  801976:	68 00 50 80 00       	push   $0x805000
  80197b:	ff 75 0c             	pushl  0xc(%ebp)
  80197e:	e8 05 f1 ff ff       	call   800a88 <memmove>
	return r;
  801983:	83 c4 10             	add    $0x10,%esp
}
  801986:	89 d8                	mov    %ebx,%eax
  801988:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	53                   	push   %ebx
  801993:	83 ec 20             	sub    $0x20,%esp
  801996:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801999:	53                   	push   %ebx
  80199a:	e8 1e ef ff ff       	call   8008bd <strlen>
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a7:	7f 67                	jg     801a10 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a9:	83 ec 0c             	sub    $0xc,%esp
  8019ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	e8 a7 f8 ff ff       	call   80125c <fd_alloc>
  8019b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 57                	js     801a15 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	53                   	push   %ebx
  8019c2:	68 00 50 80 00       	push   $0x805000
  8019c7:	e8 2a ef ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019dc:	e8 03 fe ff ff       	call   8017e4 <fsipc>
  8019e1:	89 c3                	mov    %eax,%ebx
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	79 14                	jns    8019fe <open+0x6f>
		fd_close(fd, 0);
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	6a 00                	push   $0x0
  8019ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f2:	e8 5d f9 ff ff       	call   801354 <fd_close>
		return r;
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	89 da                	mov    %ebx,%edx
  8019fc:	eb 17                	jmp    801a15 <open+0x86>
	}

	return fd2num(fd);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	ff 75 f4             	pushl  -0xc(%ebp)
  801a04:	e8 2c f8 ff ff       	call   801235 <fd2num>
  801a09:	89 c2                	mov    %eax,%edx
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	eb 05                	jmp    801a15 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a10:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a15:	89 d0                	mov    %edx,%eax
  801a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
  801a27:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2c:	e8 b3 fd ff ff       	call   8017e4 <fsipc>
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	ff 75 08             	pushl  0x8(%ebp)
  801a41:	e8 ff f7 ff ff       	call   801245 <fd2data>
  801a46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a48:	83 c4 08             	add    $0x8,%esp
  801a4b:	68 eb 29 80 00       	push   $0x8029eb
  801a50:	53                   	push   %ebx
  801a51:	e8 a0 ee ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a56:	8b 46 04             	mov    0x4(%esi),%eax
  801a59:	2b 06                	sub    (%esi),%eax
  801a5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a68:	00 00 00 
	stat->st_dev = &devpipe;
  801a6b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a72:	30 80 00 
	return 0;
}
  801a75:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	53                   	push   %ebx
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8b:	53                   	push   %ebx
  801a8c:	6a 00                	push   $0x0
  801a8e:	e8 eb f2 ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a93:	89 1c 24             	mov    %ebx,(%esp)
  801a96:	e8 aa f7 ff ff       	call   801245 <fd2data>
  801a9b:	83 c4 08             	add    $0x8,%esp
  801a9e:	50                   	push   %eax
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 d8 f2 ff ff       	call   800d7e <sys_page_unmap>
}
  801aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 1c             	sub    $0x1c,%esp
  801ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab9:	a1 04 40 80 00       	mov    0x804004,%eax
  801abe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac7:	e8 03 06 00 00       	call   8020cf <pageref>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	89 3c 24             	mov    %edi,(%esp)
  801ad1:	e8 f9 05 00 00       	call   8020cf <pageref>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	39 c3                	cmp    %eax,%ebx
  801adb:	0f 94 c1             	sete   %cl
  801ade:	0f b6 c9             	movzbl %cl,%ecx
  801ae1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aed:	39 ce                	cmp    %ecx,%esi
  801aef:	74 1b                	je     801b0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801af1:	39 c3                	cmp    %eax,%ebx
  801af3:	75 c4                	jne    801ab9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af5:	8b 42 58             	mov    0x58(%edx),%eax
  801af8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afb:	50                   	push   %eax
  801afc:	56                   	push   %esi
  801afd:	68 f2 29 80 00       	push   $0x8029f2
  801b02:	e8 6a e8 ff ff       	call   800371 <cprintf>
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	eb ad                	jmp    801ab9 <_pipeisclosed+0xe>
	}
}
  801b0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5f                   	pop    %edi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	57                   	push   %edi
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 28             	sub    $0x28,%esp
  801b20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b23:	56                   	push   %esi
  801b24:	e8 1c f7 ff ff       	call   801245 <fd2data>
  801b29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b33:	eb 4b                	jmp    801b80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b35:	89 da                	mov    %ebx,%edx
  801b37:	89 f0                	mov    %esi,%eax
  801b39:	e8 6d ff ff ff       	call   801aab <_pipeisclosed>
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	75 48                	jne    801b8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b42:	e8 93 f1 ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b47:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4a:	8b 0b                	mov    (%ebx),%ecx
  801b4c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b4f:	39 d0                	cmp    %edx,%eax
  801b51:	73 e2                	jae    801b35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b5d:	89 c2                	mov    %eax,%edx
  801b5f:	c1 fa 1f             	sar    $0x1f,%edx
  801b62:	89 d1                	mov    %edx,%ecx
  801b64:	c1 e9 1b             	shr    $0x1b,%ecx
  801b67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b6a:	83 e2 1f             	and    $0x1f,%edx
  801b6d:	29 ca                	sub    %ecx,%edx
  801b6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b77:	83 c0 01             	add    $0x1,%eax
  801b7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7d:	83 c7 01             	add    $0x1,%edi
  801b80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b83:	75 c2                	jne    801b47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b85:	8b 45 10             	mov    0x10(%ebp),%eax
  801b88:	eb 05                	jmp    801b8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	57                   	push   %edi
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 18             	sub    $0x18,%esp
  801ba0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ba3:	57                   	push   %edi
  801ba4:	e8 9c f6 ff ff       	call   801245 <fd2data>
  801ba9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb3:	eb 3d                	jmp    801bf2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bb5:	85 db                	test   %ebx,%ebx
  801bb7:	74 04                	je     801bbd <devpipe_read+0x26>
				return i;
  801bb9:	89 d8                	mov    %ebx,%eax
  801bbb:	eb 44                	jmp    801c01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bbd:	89 f2                	mov    %esi,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	e8 e5 fe ff ff       	call   801aab <_pipeisclosed>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	75 32                	jne    801bfc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bca:	e8 0b f1 ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bcf:	8b 06                	mov    (%esi),%eax
  801bd1:	3b 46 04             	cmp    0x4(%esi),%eax
  801bd4:	74 df                	je     801bb5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bd6:	99                   	cltd   
  801bd7:	c1 ea 1b             	shr    $0x1b,%edx
  801bda:	01 d0                	add    %edx,%eax
  801bdc:	83 e0 1f             	and    $0x1f,%eax
  801bdf:	29 d0                	sub    %edx,%eax
  801be1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bef:	83 c3 01             	add    $0x1,%ebx
  801bf2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf5:	75 d8                	jne    801bcf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfa:	eb 05                	jmp    801c01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	56                   	push   %esi
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	e8 42 f6 ff ff       	call   80125c <fd_alloc>
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	89 c2                	mov    %eax,%edx
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 2c 01 00 00    	js     801d53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	68 07 04 00 00       	push   $0x407
  801c2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c32:	6a 00                	push   $0x0
  801c34:	e8 c0 f0 ff ff       	call   800cf9 <sys_page_alloc>
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	0f 88 0d 01 00 00    	js     801d53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4c:	50                   	push   %eax
  801c4d:	e8 0a f6 ff ff       	call   80125c <fd_alloc>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	0f 88 e2 00 00 00    	js     801d41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	68 07 04 00 00       	push   $0x407
  801c67:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 88 f0 ff ff       	call   800cf9 <sys_page_alloc>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	0f 88 c3 00 00 00    	js     801d41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	ff 75 f4             	pushl  -0xc(%ebp)
  801c84:	e8 bc f5 ff ff       	call   801245 <fd2data>
  801c89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8b:	83 c4 0c             	add    $0xc,%esp
  801c8e:	68 07 04 00 00       	push   $0x407
  801c93:	50                   	push   %eax
  801c94:	6a 00                	push   $0x0
  801c96:	e8 5e f0 ff ff       	call   800cf9 <sys_page_alloc>
  801c9b:	89 c3                	mov    %eax,%ebx
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	0f 88 89 00 00 00    	js     801d31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca8:	83 ec 0c             	sub    $0xc,%esp
  801cab:	ff 75 f0             	pushl  -0x10(%ebp)
  801cae:	e8 92 f5 ff ff       	call   801245 <fd2data>
  801cb3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cba:	50                   	push   %eax
  801cbb:	6a 00                	push   $0x0
  801cbd:	56                   	push   %esi
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 77 f0 ff ff       	call   800d3c <sys_page_map>
  801cc5:	89 c3                	mov    %eax,%ebx
  801cc7:	83 c4 20             	add    $0x20,%esp
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 55                	js     801d23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ce3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfe:	e8 32 f5 ff ff       	call   801235 <fd2num>
  801d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d08:	83 c4 04             	add    $0x4,%esp
  801d0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0e:	e8 22 f5 ff ff       	call   801235 <fd2num>
  801d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d21:	eb 30                	jmp    801d53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	56                   	push   %esi
  801d27:	6a 00                	push   $0x0
  801d29:	e8 50 f0 ff ff       	call   800d7e <sys_page_unmap>
  801d2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	ff 75 f0             	pushl  -0x10(%ebp)
  801d37:	6a 00                	push   $0x0
  801d39:	e8 40 f0 ff ff       	call   800d7e <sys_page_unmap>
  801d3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d41:	83 ec 08             	sub    $0x8,%esp
  801d44:	ff 75 f4             	pushl  -0xc(%ebp)
  801d47:	6a 00                	push   $0x0
  801d49:	e8 30 f0 ff ff       	call   800d7e <sys_page_unmap>
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d53:	89 d0                	mov    %edx,%eax
  801d55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d65:	50                   	push   %eax
  801d66:	ff 75 08             	pushl  0x8(%ebp)
  801d69:	e8 3d f5 ff ff       	call   8012ab <fd_lookup>
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	78 18                	js     801d8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d75:	83 ec 0c             	sub    $0xc,%esp
  801d78:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7b:	e8 c5 f4 ff ff       	call   801245 <fd2data>
	return _pipeisclosed(fd, p);
  801d80:	89 c2                	mov    %eax,%edx
  801d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d85:	e8 21 fd ff ff       	call   801aab <_pipeisclosed>
  801d8a:	83 c4 10             	add    $0x10,%esp
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d9f:	68 05 2a 80 00       	push   $0x802a05
  801da4:	ff 75 0c             	pushl  0xc(%ebp)
  801da7:	e8 4a eb ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	57                   	push   %edi
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dca:	eb 2d                	jmp    801df9 <devcons_write+0x46>
		m = n - tot;
  801dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dcf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dd1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dd4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dd9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddc:	83 ec 04             	sub    $0x4,%esp
  801ddf:	53                   	push   %ebx
  801de0:	03 45 0c             	add    0xc(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	57                   	push   %edi
  801de5:	e8 9e ec ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  801dea:	83 c4 08             	add    $0x8,%esp
  801ded:	53                   	push   %ebx
  801dee:	57                   	push   %edi
  801def:	e8 49 ee ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df4:	01 de                	add    %ebx,%esi
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	89 f0                	mov    %esi,%eax
  801dfb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dfe:	72 cc                	jb     801dcc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    

00801e08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 08             	sub    $0x8,%esp
  801e0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e17:	74 2a                	je     801e43 <devcons_read+0x3b>
  801e19:	eb 05                	jmp    801e20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e1b:	e8 ba ee ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e20:	e8 36 ee ff ff       	call   800c5b <sys_cgetc>
  801e25:	85 c0                	test   %eax,%eax
  801e27:	74 f2                	je     801e1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	78 16                	js     801e43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e2d:	83 f8 04             	cmp    $0x4,%eax
  801e30:	74 0c                	je     801e3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e35:	88 02                	mov    %al,(%edx)
	return 1;
  801e37:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3c:	eb 05                	jmp    801e43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e51:	6a 01                	push   $0x1
  801e53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	e8 e1 ed ff ff       	call   800c3d <sys_cputs>
}
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <getchar>:

int
getchar(void)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e67:	6a 01                	push   $0x1
  801e69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6c:	50                   	push   %eax
  801e6d:	6a 00                	push   $0x0
  801e6f:	e8 9d f6 ff ff       	call   801511 <read>
	if (r < 0)
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 0f                	js     801e8a <getchar+0x29>
		return r;
	if (r < 1)
  801e7b:	85 c0                	test   %eax,%eax
  801e7d:	7e 06                	jle    801e85 <getchar+0x24>
		return -E_EOF;
	return c;
  801e7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e83:	eb 05                	jmp    801e8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	ff 75 08             	pushl  0x8(%ebp)
  801e99:	e8 0d f4 ff ff       	call   8012ab <fd_lookup>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 11                	js     801eb6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eae:	39 10                	cmp    %edx,(%eax)
  801eb0:	0f 94 c0             	sete   %al
  801eb3:	0f b6 c0             	movzbl %al,%eax
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <opencons>:

int
opencons(void)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ebe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec1:	50                   	push   %eax
  801ec2:	e8 95 f3 ff ff       	call   80125c <fd_alloc>
  801ec7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 3e                	js     801f0e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed0:	83 ec 04             	sub    $0x4,%esp
  801ed3:	68 07 04 00 00       	push   $0x407
  801ed8:	ff 75 f4             	pushl  -0xc(%ebp)
  801edb:	6a 00                	push   $0x0
  801edd:	e8 17 ee ff ff       	call   800cf9 <sys_page_alloc>
  801ee2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 23                	js     801f0e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eeb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f00:	83 ec 0c             	sub    $0xc,%esp
  801f03:	50                   	push   %eax
  801f04:	e8 2c f3 ff ff       	call   801235 <fd2num>
  801f09:	89 c2                	mov    %eax,%edx
  801f0b:	83 c4 10             	add    $0x10,%esp
}
  801f0e:	89 d0                	mov    %edx,%eax
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	53                   	push   %ebx
  801f16:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f19:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f20:	75 57                	jne    801f79 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801f22:	e8 94 ed ff ff       	call   800cbb <sys_getenvid>
  801f27:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801f29:	83 ec 04             	sub    $0x4,%esp
  801f2c:	6a 07                	push   $0x7
  801f2e:	68 00 f0 bf ee       	push   $0xeebff000
  801f33:	50                   	push   %eax
  801f34:	e8 c0 ed ff ff       	call   800cf9 <sys_page_alloc>
		if (r) {
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	74 12                	je     801f52 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801f40:	50                   	push   %eax
  801f41:	68 7a 28 80 00       	push   $0x80287a
  801f46:	6a 25                	push   $0x25
  801f48:	68 11 2a 80 00       	push   $0x802a11
  801f4d:	e8 46 e3 ff ff       	call   800298 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801f52:	83 ec 08             	sub    $0x8,%esp
  801f55:	68 86 1f 80 00       	push   $0x801f86
  801f5a:	53                   	push   %ebx
  801f5b:	e8 e4 ee ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
		if (r) {
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	85 c0                	test   %eax,%eax
  801f65:	74 12                	je     801f79 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801f67:	50                   	push   %eax
  801f68:	68 20 2a 80 00       	push   $0x802a20
  801f6d:	6a 2b                	push   $0x2b
  801f6f:	68 11 2a 80 00       	push   $0x802a11
  801f74:	e8 1f e3 ff ff       	call   800298 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f79:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f86:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f87:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8e:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801f91:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801f95:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801f9a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801f9e:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801fa0:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801fa3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801fa4:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801fa7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801fa8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801fa9:	c3                   	ret    

00801faa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	56                   	push   %esi
  801fae:	53                   	push   %ebx
  801faf:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	74 3e                	je     801ffa <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	50                   	push   %eax
  801fc0:	e8 e4 ee ff ff       	call   800ea9 <sys_ipc_recv>
  801fc5:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801fc7:	83 c4 10             	add    $0x10,%esp
  801fca:	85 f6                	test   %esi,%esi
  801fcc:	74 13                	je     801fe1 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801fce:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd3:	85 d2                	test   %edx,%edx
  801fd5:	75 08                	jne    801fdf <ipc_recv+0x35>
  801fd7:	a1 04 40 80 00       	mov    0x804004,%eax
  801fdc:	8b 40 74             	mov    0x74(%eax),%eax
  801fdf:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801fe1:	85 db                	test   %ebx,%ebx
  801fe3:	74 48                	je     80202d <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801fe5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fea:	85 d2                	test   %edx,%edx
  801fec:	75 08                	jne    801ff6 <ipc_recv+0x4c>
  801fee:	a1 04 40 80 00       	mov    0x804004,%eax
  801ff3:	8b 40 78             	mov    0x78(%eax),%eax
  801ff6:	89 03                	mov    %eax,(%ebx)
  801ff8:	eb 33                	jmp    80202d <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801ffa:	83 ec 0c             	sub    $0xc,%esp
  801ffd:	68 00 00 c0 ee       	push   $0xeec00000
  802002:	e8 a2 ee ff ff       	call   800ea9 <sys_ipc_recv>
  802007:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	85 f6                	test   %esi,%esi
  80200e:	74 13                	je     802023 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
  802015:	85 d2                	test   %edx,%edx
  802017:	75 08                	jne    802021 <ipc_recv+0x77>
  802019:	a1 04 40 80 00       	mov    0x804004,%eax
  80201e:	8b 40 74             	mov    0x74(%eax),%eax
  802021:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802023:	85 db                	test   %ebx,%ebx
  802025:	74 06                	je     80202d <ipc_recv+0x83>
			*perm_store = 0;
  802027:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  80202d:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  80202f:	85 d2                	test   %edx,%edx
  802031:	75 08                	jne    80203b <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  802033:	a1 04 40 80 00       	mov    0x804004,%eax
  802038:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  80203b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203e:	5b                   	pop    %ebx
  80203f:	5e                   	pop    %esi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    

00802042 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	57                   	push   %edi
  802046:	56                   	push   %esi
  802047:	53                   	push   %ebx
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80204e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802051:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  802054:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  802056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80205b:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80205e:	eb 1c                	jmp    80207c <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  802060:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802063:	74 12                	je     802077 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  802065:	50                   	push   %eax
  802066:	68 48 2a 80 00       	push   $0x802a48
  80206b:	6a 4f                	push   $0x4f
  80206d:	68 63 2a 80 00       	push   $0x802a63
  802072:	e8 21 e2 ff ff       	call   800298 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802077:	e8 5e ec ff ff       	call   800cda <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80207c:	ff 75 14             	pushl  0x14(%ebp)
  80207f:	53                   	push   %ebx
  802080:	56                   	push   %esi
  802081:	57                   	push   %edi
  802082:	e8 ff ed ff ff       	call   800e86 <sys_ipc_try_send>
  802087:	83 c4 10             	add    $0x10,%esp
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 d2                	js     802060 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80208e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802091:	5b                   	pop    %ebx
  802092:	5e                   	pop    %esi
  802093:	5f                   	pop    %edi
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    

00802096 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80209c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020aa:	8b 52 50             	mov    0x50(%edx),%edx
  8020ad:	39 ca                	cmp    %ecx,%edx
  8020af:	75 0d                	jne    8020be <ipc_find_env+0x28>
			return envs[i].env_id;
  8020b1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b9:	8b 40 48             	mov    0x48(%eax),%eax
  8020bc:	eb 0f                	jmp    8020cd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020be:	83 c0 01             	add    $0x1,%eax
  8020c1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c6:	75 d9                	jne    8020a1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    

008020cf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d5:	89 d0                	mov    %edx,%eax
  8020d7:	c1 e8 16             	shr    $0x16,%eax
  8020da:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020e1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e6:	f6 c1 01             	test   $0x1,%cl
  8020e9:	74 1d                	je     802108 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020eb:	c1 ea 0c             	shr    $0xc,%edx
  8020ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f5:	f6 c2 01             	test   $0x1,%dl
  8020f8:	74 0e                	je     802108 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fa:	c1 ea 0c             	shr    $0xc,%edx
  8020fd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802104:	ef 
  802105:	0f b7 c0             	movzwl %ax,%eax
}
  802108:	5d                   	pop    %ebp
  802109:	c3                   	ret    
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
