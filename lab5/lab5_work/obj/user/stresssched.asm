
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 33 0b 00 00       	call   800b70 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 52 0e 00 00       	call   800e9b <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 2e 0b 00 00       	call   800b8f <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 05 0b 00 00       	call   800b8f <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 60 22 80 00       	push   $0x802260
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 88 22 80 00       	push   $0x802288
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 9b 22 80 00       	push   $0x80229b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 73 0a 00 00       	call   800b70 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 77 11 00 00       	call   8012b5 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 e7 09 00 00       	call   800b2f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 10 0a 00 00       	call   800b70 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 c4 22 80 00       	push   $0x8022c4
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 b7 22 80 00 	movl   $0x8022b7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 2f 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 d4 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 32 1d 00 00       	call   801fc0 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 1f 1e 00 00       	call   8020f0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 e7 22 80 00 	movsbl 0x8022e7(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 89 03 00 00    	je     800702 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 1a 03 00 00    	ja     8006e7 <vprintfmt+0x38a>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 ff 22 80 00       	push   $0x8022ff
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 31 28 80 00       	push   $0x802831
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 f8 22 80 00       	mov    $0x8022f8,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 86 02 00 00       	call   80078a <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	79 74                	jns    8006b3 <vprintfmt+0x356>
				putch('-', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 2d                	push   $0x2d
  800645:	ff d6                	call   *%esi
				num = -(long long) num;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064d:	f7 d8                	neg    %eax
  80064f:	83 d2 00             	adc    $0x0,%edx
  800652:	f7 da                	neg    %edx
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065c:	eb 55                	jmp    8006b3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 83 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 74 fc ff ff       	call   8002e9 <getuint>
			base=8;
  800675:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067a:	eb 37                	jmp    8006b3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 3b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ba:	57                   	push   %edi
  8006bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006be:	51                   	push   %ecx
  8006bf:	52                   	push   %edx
  8006c0:	50                   	push   %eax
  8006c1:	89 da                	mov    %ebx,%edx
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	e8 70 fb ff ff       	call   80023a <printnum>
			break;
  8006ca:	83 c4 20             	add    $0x20,%esp
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 ae fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	51                   	push   %ecx
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e2:	e9 9c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 03                	jmp    8006f7 <vprintfmt+0x39a>
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fb:	75 f7                	jne    8006f4 <vprintfmt+0x397>
  8006fd:	e9 81 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 26                	je     800751 <vsnprintf+0x47>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 22                	jle    800751 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	ff 75 14             	pushl  0x14(%ebp)
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 23 03 80 00       	push   $0x800323
  80073e:	e8 1a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 9a ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strlen+0x10>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f7                	jne    80077f <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
  800798:	eb 03                	jmp    80079d <strnlen+0x13>
		n++;
  80079a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 08                	je     8007a9 <strnlen+0x1f>
  8007a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a5:	75 f3                	jne    80079a <strnlen+0x10>
  8007a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	89 f3                	mov    %esi,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 0f                	jmp    800810 <strncpy+0x23>
		*dst++ = *src;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 39 01             	cmpb   $0x1,(%ecx)
  80080d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	39 da                	cmp    %ebx,%edx
  800812:	75 ed                	jne    800801 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
  800828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 21                	je     80084f <strlcpy+0x35>
  80082e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 09                	jmp    80083f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 09                	je     80084c <strlcpy+0x32>
  800843:	0f b6 19             	movzbl (%ecx),%ebx
  800846:	84 db                	test   %bl,%bl
  800848:	75 ec                	jne    800836 <strlcpy+0x1c>
  80084a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x30>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 07                	jmp    8008c6 <strchr+0x13>
		if (*s == c)
  8008bf:	38 ca                	cmp    %cl,%dl
  8008c1:	74 0f                	je     8008d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	0f b6 10             	movzbl (%eax),%edx
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f2                	jne    8008bf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 36                	je     800936 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 28                	jne    800930 <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 23                	jne    800930 <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800924:	89 d8                	mov    %ebx,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 ab                	rep stos %eax,%es:(%edi)
  80092e:	eb 06                	jmp    800936 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2e                	jae    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x3b>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0e                	jne    800978 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1d                	jmp    8009a1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 0f                	jne    80099c <memmove+0x5f>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0a                	jne    80099c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 05                	jmp    8009a1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 1a                	jmp    8009e4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	74 0a                	je     8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 0f                	jmp    8009ed <memcmp+0x35>
		s1++, s2++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	39 f0                	cmp    %esi,%eax
  8009e6:	75 e2                	jne    8009ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f8:	89 c1                	mov    %eax,%ecx
  8009fa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	eb 0a                	jmp    800a0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 10             	movzbl (%eax),%edx
  800a06:	39 da                	cmp    %ebx,%edx
  800a08:	74 07                	je     800a11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 c8                	cmp    %ecx,%eax
  800a0f:	72 f2                	jb     800a03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	75 0a                	jne    800a3e <strtol+0x2a>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	eb 11                	jmp    800a4f <strtol+0x3b>
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 08                	jne    800a4f <strtol+0x3b>
		s++, neg = 1;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 15                	jne    800a6c <strtol+0x58>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 10                	jne    800a6c <strtol+0x58>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	75 7c                	jne    800ade <strtol+0xca>
		s += 2, base = 16;
  800a62:	83 c1 02             	add    $0x2,%ecx
  800a65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6a:	eb 16                	jmp    800a82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	75 12                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 08                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x8b>
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
  800a9d:	eb 22                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb 10                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 16                	ja     800ad1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 0b                	jge    800ad1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb b9                	jmp    800a8a <strtol+0x76>

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 0d                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
  800adc:	eb 06                	jmp    800ae4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	74 98                	je     800a7a <strtol+0x66>
  800ae2:	eb 9e                	jmp    800a82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 df 25 80 00       	push   $0x8025df
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 fc 25 80 00       	push   $0x8025fc
  800b63:	e8 e5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 df 25 80 00       	push   $0x8025df
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 fc 25 80 00       	push   $0x8025fc
  800be4:	e8 64 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 df 25 80 00       	push   $0x8025df
  800c1f:	6a 23                	push   $0x23
  800c21:	68 fc 25 80 00       	push   $0x8025fc
  800c26:	e8 22 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 df 25 80 00       	push   $0x8025df
  800c61:	6a 23                	push   $0x23
  800c63:	68 fc 25 80 00       	push   $0x8025fc
  800c68:	e8 e0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 df 25 80 00       	push   $0x8025df
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 fc 25 80 00       	push   $0x8025fc
  800caa:	e8 9e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 df 25 80 00       	push   $0x8025df
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 fc 25 80 00       	push   $0x8025fc
  800cec:	e8 5c f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 df 25 80 00       	push   $0x8025df
  800d27:	6a 23                	push   $0x23
  800d29:	68 fc 25 80 00       	push   $0x8025fc
  800d2e:	e8 1a f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 df 25 80 00       	push   $0x8025df
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 fc 25 80 00       	push   $0x8025fc
  800d92:	e8 b6 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da7:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800da9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dad:	75 14                	jne    800dc3 <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	68 0c 26 80 00       	push   $0x80260c
  800db7:	6a 23                	push   $0x23
  800db9:	68 cf 26 80 00       	push   $0x8026cf
  800dbe:	e8 8a f3 ff ff       	call   80014d <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800dc3:	89 d8                	mov    %ebx,%eax
  800dc5:	c1 e8 0c             	shr    $0xc,%eax
  800dc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcf:	f6 c4 08             	test   $0x8,%ah
  800dd2:	75 14                	jne    800de8 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 30 26 80 00       	push   $0x802630
  800ddc:	6a 2d                	push   $0x2d
  800dde:	68 cf 26 80 00       	push   $0x8026cf
  800de3:	e8 65 f3 ff ff       	call   80014d <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800de8:	e8 83 fd ff ff       	call   800b70 <sys_getenvid>
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	6a 07                	push   $0x7
  800df2:	68 00 f0 7f 00       	push   $0x7ff000
  800df7:	50                   	push   %eax
  800df8:	e8 b1 fd ff ff       	call   800bae <sys_page_alloc>
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	79 12                	jns    800e16 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800e04:	50                   	push   %eax
  800e05:	68 da 26 80 00       	push   $0x8026da
  800e0a:	6a 3b                	push   $0x3b
  800e0c:	68 cf 26 80 00       	push   $0x8026cf
  800e11:	e8 37 f3 ff ff       	call   80014d <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800e16:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800e1c:	83 ec 04             	sub    $0x4,%esp
  800e1f:	68 00 10 00 00       	push   $0x1000
  800e24:	53                   	push   %ebx
  800e25:	68 00 f0 7f 00       	push   $0x7ff000
  800e2a:	e8 0e fb ff ff       	call   80093d <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800e2f:	e8 3c fd ff ff       	call   800b70 <sys_getenvid>
  800e34:	89 c6                	mov    %eax,%esi
  800e36:	e8 35 fd ff ff       	call   800b70 <sys_getenvid>
  800e3b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e42:	53                   	push   %ebx
  800e43:	56                   	push   %esi
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	50                   	push   %eax
  800e4a:	e8 a2 fd ff ff       	call   800bf1 <sys_page_map>
  800e4f:	83 c4 20             	add    $0x20,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 12                	jns    800e68 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800e56:	50                   	push   %eax
  800e57:	68 f3 26 80 00       	push   $0x8026f3
  800e5c:	6a 48                	push   $0x48
  800e5e:	68 cf 26 80 00       	push   $0x8026cf
  800e63:	e8 e5 f2 ff ff       	call   80014d <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800e68:	e8 03 fd ff ff       	call   800b70 <sys_getenvid>
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	68 00 f0 7f 00       	push   $0x7ff000
  800e75:	50                   	push   %eax
  800e76:	e8 b8 fd ff ff       	call   800c33 <sys_page_unmap>
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	79 12                	jns    800e94 <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800e82:	50                   	push   %eax
  800e83:	68 0a 27 80 00       	push   $0x80270a
  800e88:	6a 4c                	push   $0x4c
  800e8a:	68 cf 26 80 00       	push   $0x8026cf
  800e8f:	e8 b9 f2 ff ff       	call   80014d <_panic>
	}

	//panic("pgfault not implemented");
}
  800e94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800ea4:	68 9f 0d 80 00       	push   $0x800d9f
  800ea9:	e8 19 0f 00 00       	call   801dc7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eae:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb3:	cd 30                	int    $0x30
  800eb5:	89 c7                	mov    %eax,%edi
  800eb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	79 15                	jns    800ed6 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800ec1:	50                   	push   %eax
  800ec2:	68 23 27 80 00       	push   $0x802723
  800ec7:	68 a1 00 00 00       	push   $0xa1
  800ecc:	68 cf 26 80 00       	push   $0x8026cf
  800ed1:	e8 77 f2 ff ff       	call   80014d <_panic>
  800ed6:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800edb:	85 c0                	test   %eax,%eax
  800edd:	75 21                	jne    800f00 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800edf:	e8 8c fc ff ff       	call   800b70 <sys_getenvid>
  800ee4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef1:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	e9 c8 01 00 00       	jmp    8010c8 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	c1 e8 16             	shr    $0x16,%eax
  800f05:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f0c:	a8 01                	test   $0x1,%al
  800f0e:	0f 84 23 01 00 00    	je     801037 <fork+0x19c>
  800f14:	89 d8                	mov    %ebx,%eax
  800f16:	c1 e8 0c             	shr    $0xc,%eax
  800f19:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f20:	f6 c2 01             	test   $0x1,%dl
  800f23:	0f 84 0e 01 00 00    	je     801037 <fork+0x19c>
  800f29:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f30:	f6 c2 04             	test   $0x4,%dl
  800f33:	0f 84 fe 00 00 00    	je     801037 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800f39:	89 c6                	mov    %eax,%esi
  800f3b:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800f3e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f45:	f6 c6 04             	test   $0x4,%dh
  800f48:	74 3f                	je     800f89 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800f4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	25 07 0e 00 00       	and    $0xe07,%eax
  800f59:	50                   	push   %eax
  800f5a:	56                   	push   %esi
  800f5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5e:	56                   	push   %esi
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 8b fc ff ff       	call   800bf1 <sys_page_map>
  800f66:	83 c4 20             	add    $0x20,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	0f 89 c6 00 00 00    	jns    801037 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	50                   	push   %eax
  800f75:	57                   	push   %edi
  800f76:	6a 00                	push   $0x0
  800f78:	68 60 26 80 00       	push   $0x802660
  800f7d:	6a 6c                	push   $0x6c
  800f7f:	68 cf 26 80 00       	push   $0x8026cf
  800f84:	e8 c4 f1 ff ff       	call   80014d <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f89:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f90:	f6 c2 02             	test   $0x2,%dl
  800f93:	75 0c                	jne    800fa1 <fork+0x106>
  800f95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9c:	f6 c4 08             	test   $0x8,%ah
  800f9f:	74 66                	je     801007 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	68 05 08 00 00       	push   $0x805
  800fa9:	56                   	push   %esi
  800faa:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fad:	56                   	push   %esi
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 3c fc ff ff       	call   800bf1 <sys_page_map>
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 18                	jns    800fd4 <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	50                   	push   %eax
  800fc0:	57                   	push   %edi
  800fc1:	6a 00                	push   $0x0
  800fc3:	68 60 26 80 00       	push   $0x802660
  800fc8:	6a 74                	push   $0x74
  800fca:	68 cf 26 80 00       	push   $0x8026cf
  800fcf:	e8 79 f1 ff ff       	call   80014d <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	68 05 08 00 00       	push   $0x805
  800fdc:	56                   	push   %esi
  800fdd:	6a 00                	push   $0x0
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 0a fc ff ff       	call   800bf1 <sys_page_map>
  800fe7:	83 c4 20             	add    $0x20,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	79 49                	jns    801037 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	50                   	push   %eax
  800ff2:	6a 00                	push   $0x0
  800ff4:	6a 00                	push   $0x0
  800ff6:	68 60 26 80 00       	push   $0x802660
  800ffb:	6a 77                	push   $0x77
  800ffd:	68 cf 26 80 00       	push   $0x8026cf
  801002:	e8 46 f1 ff ff       	call   80014d <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	6a 05                	push   $0x5
  80100c:	56                   	push   %esi
  80100d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801010:	56                   	push   %esi
  801011:	6a 00                	push   $0x0
  801013:	e8 d9 fb ff ff       	call   800bf1 <sys_page_map>
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	79 18                	jns    801037 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	50                   	push   %eax
  801023:	57                   	push   %edi
  801024:	6a 00                	push   $0x0
  801026:	68 60 26 80 00       	push   $0x802660
  80102b:	6a 7d                	push   $0x7d
  80102d:	68 cf 26 80 00       	push   $0x8026cf
  801032:	e8 16 f1 ff ff       	call   80014d <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801037:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801043:	0f 85 b7 fe ff ff    	jne    800f00 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	6a 07                	push   $0x7
  80104e:	68 00 f0 bf ee       	push   $0xeebff000
  801053:	57                   	push   %edi
  801054:	e8 55 fb ff ff       	call   800bae <sys_page_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	79 15                	jns    801075 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  801060:	50                   	push   %eax
  801061:	68 8c 26 80 00       	push   $0x80268c
  801066:	68 b4 00 00 00       	push   $0xb4
  80106b:	68 cf 26 80 00       	push   $0x8026cf
  801070:	e8 d8 f0 ff ff       	call   80014d <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	68 3b 1e 80 00       	push   $0x801e3b
  80107d:	57                   	push   %edi
  80107e:	e8 76 fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	79 15                	jns    80109f <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  80108a:	50                   	push   %eax
  80108b:	68 39 27 80 00       	push   $0x802739
  801090:	68 ba 00 00 00       	push   $0xba
  801095:	68 cf 26 80 00       	push   $0x8026cf
  80109a:	e8 ae f0 ff ff       	call   80014d <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	6a 02                	push   $0x2
  8010a4:	57                   	push   %edi
  8010a5:	e8 cb fb ff ff       	call   800c75 <sys_env_set_status>
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	79 15                	jns    8010c6 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  8010b1:	50                   	push   %eax
  8010b2:	68 56 27 80 00       	push   $0x802756
  8010b7:	68 bf 00 00 00       	push   $0xbf
  8010bc:	68 cf 26 80 00       	push   $0x8026cf
  8010c1:	e8 87 f0 ff ff       	call   80014d <_panic>
	}
	return eid;
  8010c6:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  8010c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010d6:	68 73 27 80 00       	push   $0x802773
  8010db:	68 ca 00 00 00       	push   $0xca
  8010e0:	68 cf 26 80 00       	push   $0x8026cf
  8010e5:	e8 63 f0 ff ff       	call   80014d <_panic>

008010ea <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f5:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    

008010fa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	05 00 00 00 30       	add    $0x30000000,%eax
  801105:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80110a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801117:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111c:	89 c2                	mov    %eax,%edx
  80111e:	c1 ea 16             	shr    $0x16,%edx
  801121:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801128:	f6 c2 01             	test   $0x1,%dl
  80112b:	74 11                	je     80113e <fd_alloc+0x2d>
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 ea 0c             	shr    $0xc,%edx
  801132:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801139:	f6 c2 01             	test   $0x1,%dl
  80113c:	75 09                	jne    801147 <fd_alloc+0x36>
			*fd_store = fd;
  80113e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 17                	jmp    80115e <fd_alloc+0x4d>
  801147:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80114c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801151:	75 c9                	jne    80111c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801153:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801159:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801166:	83 f8 1f             	cmp    $0x1f,%eax
  801169:	77 36                	ja     8011a1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80116b:	c1 e0 0c             	shl    $0xc,%eax
  80116e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801173:	89 c2                	mov    %eax,%edx
  801175:	c1 ea 16             	shr    $0x16,%edx
  801178:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117f:	f6 c2 01             	test   $0x1,%dl
  801182:	74 24                	je     8011a8 <fd_lookup+0x48>
  801184:	89 c2                	mov    %eax,%edx
  801186:	c1 ea 0c             	shr    $0xc,%edx
  801189:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801190:	f6 c2 01             	test   $0x1,%dl
  801193:	74 1a                	je     8011af <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801195:	8b 55 0c             	mov    0xc(%ebp),%edx
  801198:	89 02                	mov    %eax,(%edx)
	return 0;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
  80119f:	eb 13                	jmp    8011b4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a6:	eb 0c                	jmp    8011b4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ad:	eb 05                	jmp    8011b4 <fd_lookup+0x54>
  8011af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 08             	sub    $0x8,%esp
  8011bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bf:	ba 08 28 80 00       	mov    $0x802808,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c4:	eb 13                	jmp    8011d9 <dev_lookup+0x23>
  8011c6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c9:	39 08                	cmp    %ecx,(%eax)
  8011cb:	75 0c                	jne    8011d9 <dev_lookup+0x23>
			*dev = devtab[i];
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	eb 2e                	jmp    801207 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d9:	8b 02                	mov    (%edx),%eax
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	75 e7                	jne    8011c6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011df:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e4:	8b 40 48             	mov    0x48(%eax),%eax
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	51                   	push   %ecx
  8011eb:	50                   	push   %eax
  8011ec:	68 8c 27 80 00       	push   $0x80278c
  8011f1:	e8 30 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  8011f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 10             	sub    $0x10,%esp
  801211:	8b 75 08             	mov    0x8(%ebp),%esi
  801214:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801217:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801221:	c1 e8 0c             	shr    $0xc,%eax
  801224:	50                   	push   %eax
  801225:	e8 36 ff ff ff       	call   801160 <fd_lookup>
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 05                	js     801236 <fd_close+0x2d>
	    || fd != fd2)
  801231:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801234:	74 0c                	je     801242 <fd_close+0x39>
		return (must_exist ? r : 0);
  801236:	84 db                	test   %bl,%bl
  801238:	ba 00 00 00 00       	mov    $0x0,%edx
  80123d:	0f 44 c2             	cmove  %edx,%eax
  801240:	eb 41                	jmp    801283 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	ff 36                	pushl  (%esi)
  80124b:	e8 66 ff ff ff       	call   8011b6 <dev_lookup>
  801250:	89 c3                	mov    %eax,%ebx
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 1a                	js     801273 <fd_close+0x6a>
		if (dev->dev_close)
  801259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801264:	85 c0                	test   %eax,%eax
  801266:	74 0b                	je     801273 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	56                   	push   %esi
  80126c:	ff d0                	call   *%eax
  80126e:	89 c3                	mov    %eax,%ebx
  801270:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	56                   	push   %esi
  801277:	6a 00                	push   $0x0
  801279:	e8 b5 f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	89 d8                	mov    %ebx,%eax
}
  801283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	ff 75 08             	pushl  0x8(%ebp)
  801297:	e8 c4 fe ff ff       	call   801160 <fd_lookup>
  80129c:	83 c4 08             	add    $0x8,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 10                	js     8012b3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	6a 01                	push   $0x1
  8012a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ab:	e8 59 ff ff ff       	call   801209 <fd_close>
  8012b0:	83 c4 10             	add    $0x10,%esp
}
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <close_all>:

void
close_all(void)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	53                   	push   %ebx
  8012c5:	e8 c0 ff ff ff       	call   80128a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ca:	83 c3 01             	add    $0x1,%ebx
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	83 fb 20             	cmp    $0x20,%ebx
  8012d3:	75 ec                	jne    8012c1 <close_all+0xc>
		close(i);
}
  8012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 2c             	sub    $0x2c,%esp
  8012e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	ff 75 08             	pushl  0x8(%ebp)
  8012ed:	e8 6e fe ff ff       	call   801160 <fd_lookup>
  8012f2:	83 c4 08             	add    $0x8,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	0f 88 c1 00 00 00    	js     8013be <dup+0xe4>
		return r;
	close(newfdnum);
  8012fd:	83 ec 0c             	sub    $0xc,%esp
  801300:	56                   	push   %esi
  801301:	e8 84 ff ff ff       	call   80128a <close>

	newfd = INDEX2FD(newfdnum);
  801306:	89 f3                	mov    %esi,%ebx
  801308:	c1 e3 0c             	shl    $0xc,%ebx
  80130b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801311:	83 c4 04             	add    $0x4,%esp
  801314:	ff 75 e4             	pushl  -0x1c(%ebp)
  801317:	e8 de fd ff ff       	call   8010fa <fd2data>
  80131c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80131e:	89 1c 24             	mov    %ebx,(%esp)
  801321:	e8 d4 fd ff ff       	call   8010fa <fd2data>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132c:	89 f8                	mov    %edi,%eax
  80132e:	c1 e8 16             	shr    $0x16,%eax
  801331:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801338:	a8 01                	test   $0x1,%al
  80133a:	74 37                	je     801373 <dup+0x99>
  80133c:	89 f8                	mov    %edi,%eax
  80133e:	c1 e8 0c             	shr    $0xc,%eax
  801341:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801348:	f6 c2 01             	test   $0x1,%dl
  80134b:	74 26                	je     801373 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	25 07 0e 00 00       	and    $0xe07,%eax
  80135c:	50                   	push   %eax
  80135d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801360:	6a 00                	push   $0x0
  801362:	57                   	push   %edi
  801363:	6a 00                	push   $0x0
  801365:	e8 87 f8 ff ff       	call   800bf1 <sys_page_map>
  80136a:	89 c7                	mov    %eax,%edi
  80136c:	83 c4 20             	add    $0x20,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 2e                	js     8013a1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801373:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801376:	89 d0                	mov    %edx,%eax
  801378:	c1 e8 0c             	shr    $0xc,%eax
  80137b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	25 07 0e 00 00       	and    $0xe07,%eax
  80138a:	50                   	push   %eax
  80138b:	53                   	push   %ebx
  80138c:	6a 00                	push   $0x0
  80138e:	52                   	push   %edx
  80138f:	6a 00                	push   $0x0
  801391:	e8 5b f8 ff ff       	call   800bf1 <sys_page_map>
  801396:	89 c7                	mov    %eax,%edi
  801398:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80139b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139d:	85 ff                	test   %edi,%edi
  80139f:	79 1d                	jns    8013be <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	6a 00                	push   $0x0
  8013a7:	e8 87 f8 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ac:	83 c4 08             	add    $0x8,%esp
  8013af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b2:	6a 00                	push   $0x0
  8013b4:	e8 7a f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 f8                	mov    %edi,%eax
}
  8013be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 14             	sub    $0x14,%esp
  8013cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	53                   	push   %ebx
  8013d5:	e8 86 fd ff ff       	call   801160 <fd_lookup>
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 6d                	js     801450 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	ff 30                	pushl  (%eax)
  8013ef:	e8 c2 fd ff ff       	call   8011b6 <dev_lookup>
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 4c                	js     801447 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fe:	8b 42 08             	mov    0x8(%edx),%eax
  801401:	83 e0 03             	and    $0x3,%eax
  801404:	83 f8 01             	cmp    $0x1,%eax
  801407:	75 21                	jne    80142a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801409:	a1 08 40 80 00       	mov    0x804008,%eax
  80140e:	8b 40 48             	mov    0x48(%eax),%eax
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	53                   	push   %ebx
  801415:	50                   	push   %eax
  801416:	68 cd 27 80 00       	push   $0x8027cd
  80141b:	e8 06 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801428:	eb 26                	jmp    801450 <read+0x8a>
	}
	if (!dev->dev_read)
  80142a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142d:	8b 40 08             	mov    0x8(%eax),%eax
  801430:	85 c0                	test   %eax,%eax
  801432:	74 17                	je     80144b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	ff 75 10             	pushl  0x10(%ebp)
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	52                   	push   %edx
  80143e:	ff d0                	call   *%eax
  801440:	89 c2                	mov    %eax,%edx
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb 09                	jmp    801450 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801447:	89 c2                	mov    %eax,%edx
  801449:	eb 05                	jmp    801450 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80144b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801450:	89 d0                	mov    %edx,%eax
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	57                   	push   %edi
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	83 ec 0c             	sub    $0xc,%esp
  801460:	8b 7d 08             	mov    0x8(%ebp),%edi
  801463:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801466:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146b:	eb 21                	jmp    80148e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146d:	83 ec 04             	sub    $0x4,%esp
  801470:	89 f0                	mov    %esi,%eax
  801472:	29 d8                	sub    %ebx,%eax
  801474:	50                   	push   %eax
  801475:	89 d8                	mov    %ebx,%eax
  801477:	03 45 0c             	add    0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	57                   	push   %edi
  80147c:	e8 45 ff ff ff       	call   8013c6 <read>
		if (m < 0)
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 10                	js     801498 <readn+0x41>
			return m;
		if (m == 0)
  801488:	85 c0                	test   %eax,%eax
  80148a:	74 0a                	je     801496 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148c:	01 c3                	add    %eax,%ebx
  80148e:	39 f3                	cmp    %esi,%ebx
  801490:	72 db                	jb     80146d <readn+0x16>
  801492:	89 d8                	mov    %ebx,%eax
  801494:	eb 02                	jmp    801498 <readn+0x41>
  801496:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801498:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149b:	5b                   	pop    %ebx
  80149c:	5e                   	pop    %esi
  80149d:	5f                   	pop    %edi
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    

008014a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 14             	sub    $0x14,%esp
  8014a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	53                   	push   %ebx
  8014af:	e8 ac fc ff ff       	call   801160 <fd_lookup>
  8014b4:	83 c4 08             	add    $0x8,%esp
  8014b7:	89 c2                	mov    %eax,%edx
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 68                	js     801525 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c7:	ff 30                	pushl  (%eax)
  8014c9:	e8 e8 fc ff ff       	call   8011b6 <dev_lookup>
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 47                	js     80151c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014dc:	75 21                	jne    8014ff <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014de:	a1 08 40 80 00       	mov    0x804008,%eax
  8014e3:	8b 40 48             	mov    0x48(%eax),%eax
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	53                   	push   %ebx
  8014ea:	50                   	push   %eax
  8014eb:	68 e9 27 80 00       	push   $0x8027e9
  8014f0:	e8 31 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fd:	eb 26                	jmp    801525 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801502:	8b 52 0c             	mov    0xc(%edx),%edx
  801505:	85 d2                	test   %edx,%edx
  801507:	74 17                	je     801520 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	ff 75 10             	pushl  0x10(%ebp)
  80150f:	ff 75 0c             	pushl  0xc(%ebp)
  801512:	50                   	push   %eax
  801513:	ff d2                	call   *%edx
  801515:	89 c2                	mov    %eax,%edx
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	eb 09                	jmp    801525 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	eb 05                	jmp    801525 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801520:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801525:	89 d0                	mov    %edx,%eax
  801527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <seek>:

int
seek(int fdnum, off_t offset)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801532:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	ff 75 08             	pushl  0x8(%ebp)
  801539:	e8 22 fc ff ff       	call   801160 <fd_lookup>
  80153e:	83 c4 08             	add    $0x8,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 0e                	js     801553 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801545:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801548:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	53                   	push   %ebx
  801559:	83 ec 14             	sub    $0x14,%esp
  80155c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	53                   	push   %ebx
  801564:	e8 f7 fb ff ff       	call   801160 <fd_lookup>
  801569:	83 c4 08             	add    $0x8,%esp
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 65                	js     8015d7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157c:	ff 30                	pushl  (%eax)
  80157e:	e8 33 fc ff ff       	call   8011b6 <dev_lookup>
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 44                	js     8015ce <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801591:	75 21                	jne    8015b4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801593:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801598:	8b 40 48             	mov    0x48(%eax),%eax
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	53                   	push   %ebx
  80159f:	50                   	push   %eax
  8015a0:	68 ac 27 80 00       	push   $0x8027ac
  8015a5:	e8 7c ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b2:	eb 23                	jmp    8015d7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b7:	8b 52 18             	mov    0x18(%edx),%edx
  8015ba:	85 d2                	test   %edx,%edx
  8015bc:	74 14                	je     8015d2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	ff 75 0c             	pushl  0xc(%ebp)
  8015c4:	50                   	push   %eax
  8015c5:	ff d2                	call   *%edx
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	eb 09                	jmp    8015d7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	eb 05                	jmp    8015d7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d7:	89 d0                	mov    %edx,%eax
  8015d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 14             	sub    $0x14,%esp
  8015e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 6c fb ff ff       	call   801160 <fd_lookup>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	89 c2                	mov    %eax,%edx
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 58                	js     801655 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801607:	ff 30                	pushl  (%eax)
  801609:	e8 a8 fb ff ff       	call   8011b6 <dev_lookup>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 37                	js     80164c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801615:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801618:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161c:	74 32                	je     801650 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80161e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801621:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801628:	00 00 00 
	stat->st_isdir = 0;
  80162b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801632:	00 00 00 
	stat->st_dev = dev;
  801635:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	53                   	push   %ebx
  80163f:	ff 75 f0             	pushl  -0x10(%ebp)
  801642:	ff 50 14             	call   *0x14(%eax)
  801645:	89 c2                	mov    %eax,%edx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 09                	jmp    801655 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	eb 05                	jmp    801655 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801650:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801655:	89 d0                	mov    %edx,%eax
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	6a 00                	push   $0x0
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	e8 d6 01 00 00       	call   801844 <open>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 1b                	js     801692 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	50                   	push   %eax
  80167e:	e8 5b ff ff ff       	call   8015de <fstat>
  801683:	89 c6                	mov    %eax,%esi
	close(fd);
  801685:	89 1c 24             	mov    %ebx,(%esp)
  801688:	e8 fd fb ff ff       	call   80128a <close>
	return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	89 f0                	mov    %esi,%eax
}
  801692:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801695:	5b                   	pop    %ebx
  801696:	5e                   	pop    %esi
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	56                   	push   %esi
  80169d:	53                   	push   %ebx
  80169e:	89 c6                	mov    %eax,%esi
  8016a0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a9:	75 12                	jne    8016bd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	6a 01                	push   $0x1
  8016b0:	e8 96 08 00 00       	call   801f4b <ipc_find_env>
  8016b5:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bd:	6a 07                	push   $0x7
  8016bf:	68 00 50 80 00       	push   $0x805000
  8016c4:	56                   	push   %esi
  8016c5:	ff 35 00 40 80 00    	pushl  0x804000
  8016cb:	e8 27 08 00 00       	call   801ef7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d0:	83 c4 0c             	add    $0xc,%esp
  8016d3:	6a 00                	push   $0x0
  8016d5:	53                   	push   %ebx
  8016d6:	6a 00                	push   $0x0
  8016d8:	e8 82 07 00 00       	call   801e5f <ipc_recv>
}
  8016dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	b8 02 00 00 00       	mov    $0x2,%eax
  801707:	e8 8d ff ff ff       	call   801699 <fsipc>
}
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	8b 40 0c             	mov    0xc(%eax),%eax
  80171a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80171f:	ba 00 00 00 00       	mov    $0x0,%edx
  801724:	b8 06 00 00 00       	mov    $0x6,%eax
  801729:	e8 6b ff ff ff       	call   801699 <fsipc>
}
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	8b 40 0c             	mov    0xc(%eax),%eax
  801740:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801745:	ba 00 00 00 00       	mov    $0x0,%edx
  80174a:	b8 05 00 00 00       	mov    $0x5,%eax
  80174f:	e8 45 ff ff ff       	call   801699 <fsipc>
  801754:	85 c0                	test   %eax,%eax
  801756:	78 2c                	js     801784 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	68 00 50 80 00       	push   $0x805000
  801760:	53                   	push   %ebx
  801761:	e8 45 f0 ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801766:	a1 80 50 80 00       	mov    0x805080,%eax
  80176b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801771:	a1 84 50 80 00       	mov    0x805084,%eax
  801776:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	83 ec 0c             	sub    $0xc,%esp
  80178f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801792:	8b 55 08             	mov    0x8(%ebp),%edx
  801795:	8b 52 0c             	mov    0xc(%edx),%edx
  801798:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80179e:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8017a3:	50                   	push   %eax
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	68 08 50 80 00       	push   $0x805008
  8017ac:	e8 8c f1 ff ff       	call   80093d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8017bb:	e8 d9 fe ff ff       	call   801699 <fsipc>
	//panic("devfile_write not implemented");
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017e5:	e8 af fe ff ff       	call   801699 <fsipc>
  8017ea:	89 c3                	mov    %eax,%ebx
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 4b                	js     80183b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017f0:	39 c6                	cmp    %eax,%esi
  8017f2:	73 16                	jae    80180a <devfile_read+0x48>
  8017f4:	68 18 28 80 00       	push   $0x802818
  8017f9:	68 1f 28 80 00       	push   $0x80281f
  8017fe:	6a 7c                	push   $0x7c
  801800:	68 34 28 80 00       	push   $0x802834
  801805:	e8 43 e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  80180a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80180f:	7e 16                	jle    801827 <devfile_read+0x65>
  801811:	68 3f 28 80 00       	push   $0x80283f
  801816:	68 1f 28 80 00       	push   $0x80281f
  80181b:	6a 7d                	push   $0x7d
  80181d:	68 34 28 80 00       	push   $0x802834
  801822:	e8 26 e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801827:	83 ec 04             	sub    $0x4,%esp
  80182a:	50                   	push   %eax
  80182b:	68 00 50 80 00       	push   $0x805000
  801830:	ff 75 0c             	pushl  0xc(%ebp)
  801833:	e8 05 f1 ff ff       	call   80093d <memmove>
	return r;
  801838:	83 c4 10             	add    $0x10,%esp
}
  80183b:	89 d8                	mov    %ebx,%eax
  80183d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801840:	5b                   	pop    %ebx
  801841:	5e                   	pop    %esi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	53                   	push   %ebx
  801848:	83 ec 20             	sub    $0x20,%esp
  80184b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80184e:	53                   	push   %ebx
  80184f:	e8 1e ef ff ff       	call   800772 <strlen>
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80185c:	7f 67                	jg     8018c5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80185e:	83 ec 0c             	sub    $0xc,%esp
  801861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	e8 a7 f8 ff ff       	call   801111 <fd_alloc>
  80186a:	83 c4 10             	add    $0x10,%esp
		return r;
  80186d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 57                	js     8018ca <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	53                   	push   %ebx
  801877:	68 00 50 80 00       	push   $0x805000
  80187c:	e8 2a ef ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801881:	8b 45 0c             	mov    0xc(%ebp),%eax
  801884:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801889:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80188c:	b8 01 00 00 00       	mov    $0x1,%eax
  801891:	e8 03 fe ff ff       	call   801699 <fsipc>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	79 14                	jns    8018b3 <open+0x6f>
		fd_close(fd, 0);
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	6a 00                	push   $0x0
  8018a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a7:	e8 5d f9 ff ff       	call   801209 <fd_close>
		return r;
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	89 da                	mov    %ebx,%edx
  8018b1:	eb 17                	jmp    8018ca <open+0x86>
	}

	return fd2num(fd);
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b9:	e8 2c f8 ff ff       	call   8010ea <fd2num>
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	eb 05                	jmp    8018ca <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018c5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ca:	89 d0                	mov    %edx,%eax
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e1:	e8 b3 fd ff ff       	call   801699 <fsipc>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	ff 75 08             	pushl  0x8(%ebp)
  8018f6:	e8 ff f7 ff ff       	call   8010fa <fd2data>
  8018fb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018fd:	83 c4 08             	add    $0x8,%esp
  801900:	68 4b 28 80 00       	push   $0x80284b
  801905:	53                   	push   %ebx
  801906:	e8 a0 ee ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80190b:	8b 46 04             	mov    0x4(%esi),%eax
  80190e:	2b 06                	sub    (%esi),%eax
  801910:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801916:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80191d:	00 00 00 
	stat->st_dev = &devpipe;
  801920:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801927:	30 80 00 
	return 0;
}
  80192a:	b8 00 00 00 00       	mov    $0x0,%eax
  80192f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801932:	5b                   	pop    %ebx
  801933:	5e                   	pop    %esi
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	53                   	push   %ebx
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801940:	53                   	push   %ebx
  801941:	6a 00                	push   $0x0
  801943:	e8 eb f2 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801948:	89 1c 24             	mov    %ebx,(%esp)
  80194b:	e8 aa f7 ff ff       	call   8010fa <fd2data>
  801950:	83 c4 08             	add    $0x8,%esp
  801953:	50                   	push   %eax
  801954:	6a 00                	push   $0x0
  801956:	e8 d8 f2 ff ff       	call   800c33 <sys_page_unmap>
}
  80195b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	57                   	push   %edi
  801964:	56                   	push   %esi
  801965:	53                   	push   %ebx
  801966:	83 ec 1c             	sub    $0x1c,%esp
  801969:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80196c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80196e:	a1 08 40 80 00       	mov    0x804008,%eax
  801973:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	ff 75 e0             	pushl  -0x20(%ebp)
  80197c:	e8 03 06 00 00       	call   801f84 <pageref>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	89 3c 24             	mov    %edi,(%esp)
  801986:	e8 f9 05 00 00       	call   801f84 <pageref>
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	39 c3                	cmp    %eax,%ebx
  801990:	0f 94 c1             	sete   %cl
  801993:	0f b6 c9             	movzbl %cl,%ecx
  801996:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801999:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80199f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019a2:	39 ce                	cmp    %ecx,%esi
  8019a4:	74 1b                	je     8019c1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019a6:	39 c3                	cmp    %eax,%ebx
  8019a8:	75 c4                	jne    80196e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019aa:	8b 42 58             	mov    0x58(%edx),%eax
  8019ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b0:	50                   	push   %eax
  8019b1:	56                   	push   %esi
  8019b2:	68 52 28 80 00       	push   $0x802852
  8019b7:	e8 6a e8 ff ff       	call   800226 <cprintf>
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	eb ad                	jmp    80196e <_pipeisclosed+0xe>
	}
}
  8019c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5f                   	pop    %edi
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	57                   	push   %edi
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 28             	sub    $0x28,%esp
  8019d5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019d8:	56                   	push   %esi
  8019d9:	e8 1c f7 ff ff       	call   8010fa <fd2data>
  8019de:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e8:	eb 4b                	jmp    801a35 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ea:	89 da                	mov    %ebx,%edx
  8019ec:	89 f0                	mov    %esi,%eax
  8019ee:	e8 6d ff ff ff       	call   801960 <_pipeisclosed>
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	75 48                	jne    801a3f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019f7:	e8 93 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ff:	8b 0b                	mov    (%ebx),%ecx
  801a01:	8d 51 20             	lea    0x20(%ecx),%edx
  801a04:	39 d0                	cmp    %edx,%eax
  801a06:	73 e2                	jae    8019ea <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a0f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	c1 fa 1f             	sar    $0x1f,%edx
  801a17:	89 d1                	mov    %edx,%ecx
  801a19:	c1 e9 1b             	shr    $0x1b,%ecx
  801a1c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a1f:	83 e2 1f             	and    $0x1f,%edx
  801a22:	29 ca                	sub    %ecx,%edx
  801a24:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a28:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a2c:	83 c0 01             	add    $0x1,%eax
  801a2f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a32:	83 c7 01             	add    $0x1,%edi
  801a35:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a38:	75 c2                	jne    8019fc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3d:	eb 05                	jmp    801a44 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a47:	5b                   	pop    %ebx
  801a48:	5e                   	pop    %esi
  801a49:	5f                   	pop    %edi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	83 ec 18             	sub    $0x18,%esp
  801a55:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a58:	57                   	push   %edi
  801a59:	e8 9c f6 ff ff       	call   8010fa <fd2data>
  801a5e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a68:	eb 3d                	jmp    801aa7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	74 04                	je     801a72 <devpipe_read+0x26>
				return i;
  801a6e:	89 d8                	mov    %ebx,%eax
  801a70:	eb 44                	jmp    801ab6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a72:	89 f2                	mov    %esi,%edx
  801a74:	89 f8                	mov    %edi,%eax
  801a76:	e8 e5 fe ff ff       	call   801960 <_pipeisclosed>
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	75 32                	jne    801ab1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a7f:	e8 0b f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a84:	8b 06                	mov    (%esi),%eax
  801a86:	3b 46 04             	cmp    0x4(%esi),%eax
  801a89:	74 df                	je     801a6a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a8b:	99                   	cltd   
  801a8c:	c1 ea 1b             	shr    $0x1b,%edx
  801a8f:	01 d0                	add    %edx,%eax
  801a91:	83 e0 1f             	and    $0x1f,%eax
  801a94:	29 d0                	sub    %edx,%eax
  801a96:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aa1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa4:	83 c3 01             	add    $0x1,%ebx
  801aa7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aaa:	75 d8                	jne    801a84 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aac:	8b 45 10             	mov    0x10(%ebp),%eax
  801aaf:	eb 05                	jmp    801ab6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5f                   	pop    %edi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	56                   	push   %esi
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac9:	50                   	push   %eax
  801aca:	e8 42 f6 ff ff       	call   801111 <fd_alloc>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	0f 88 2c 01 00 00    	js     801c08 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adc:	83 ec 04             	sub    $0x4,%esp
  801adf:	68 07 04 00 00       	push   $0x407
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	6a 00                	push   $0x0
  801ae9:	e8 c0 f0 ff ff       	call   800bae <sys_page_alloc>
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 0d 01 00 00    	js     801c08 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b01:	50                   	push   %eax
  801b02:	e8 0a f6 ff ff       	call   801111 <fd_alloc>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	0f 88 e2 00 00 00    	js     801bf6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b14:	83 ec 04             	sub    $0x4,%esp
  801b17:	68 07 04 00 00       	push   $0x407
  801b1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 88 f0 ff ff       	call   800bae <sys_page_alloc>
  801b26:	89 c3                	mov    %eax,%ebx
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	0f 88 c3 00 00 00    	js     801bf6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	ff 75 f4             	pushl  -0xc(%ebp)
  801b39:	e8 bc f5 ff ff       	call   8010fa <fd2data>
  801b3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b40:	83 c4 0c             	add    $0xc,%esp
  801b43:	68 07 04 00 00       	push   $0x407
  801b48:	50                   	push   %eax
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 5e f0 ff ff       	call   800bae <sys_page_alloc>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 89 00 00 00    	js     801be6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	ff 75 f0             	pushl  -0x10(%ebp)
  801b63:	e8 92 f5 ff ff       	call   8010fa <fd2data>
  801b68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b6f:	50                   	push   %eax
  801b70:	6a 00                	push   $0x0
  801b72:	56                   	push   %esi
  801b73:	6a 00                	push   $0x0
  801b75:	e8 77 f0 ff ff       	call   800bf1 <sys_page_map>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	83 c4 20             	add    $0x20,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	78 55                	js     801bd8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bad:	83 ec 0c             	sub    $0xc,%esp
  801bb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb3:	e8 32 f5 ff ff       	call   8010ea <fd2num>
  801bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bbd:	83 c4 04             	add    $0x4,%esp
  801bc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc3:	e8 22 f5 ff ff       	call   8010ea <fd2num>
  801bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bcb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd6:	eb 30                	jmp    801c08 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	56                   	push   %esi
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 50 f0 ff ff       	call   800c33 <sys_page_unmap>
  801be3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bec:	6a 00                	push   $0x0
  801bee:	e8 40 f0 ff ff       	call   800c33 <sys_page_unmap>
  801bf3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bf6:	83 ec 08             	sub    $0x8,%esp
  801bf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 30 f0 ff ff       	call   800c33 <sys_page_unmap>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c08:	89 d0                	mov    %edx,%eax
  801c0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1a:	50                   	push   %eax
  801c1b:	ff 75 08             	pushl  0x8(%ebp)
  801c1e:	e8 3d f5 ff ff       	call   801160 <fd_lookup>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 18                	js     801c42 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c2a:	83 ec 0c             	sub    $0xc,%esp
  801c2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c30:	e8 c5 f4 ff ff       	call   8010fa <fd2data>
	return _pipeisclosed(fd, p);
  801c35:	89 c2                	mov    %eax,%edx
  801c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3a:	e8 21 fd ff ff       	call   801960 <_pipeisclosed>
  801c3f:	83 c4 10             	add    $0x10,%esp
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c54:	68 6a 28 80 00       	push   $0x80286a
  801c59:	ff 75 0c             	pushl  0xc(%ebp)
  801c5c:	e8 4a eb ff ff       	call   8007ab <strcpy>
	return 0;
}
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c74:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c79:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c7f:	eb 2d                	jmp    801cae <devcons_write+0x46>
		m = n - tot;
  801c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c84:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c86:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c89:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c8e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c91:	83 ec 04             	sub    $0x4,%esp
  801c94:	53                   	push   %ebx
  801c95:	03 45 0c             	add    0xc(%ebp),%eax
  801c98:	50                   	push   %eax
  801c99:	57                   	push   %edi
  801c9a:	e8 9e ec ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801c9f:	83 c4 08             	add    $0x8,%esp
  801ca2:	53                   	push   %ebx
  801ca3:	57                   	push   %edi
  801ca4:	e8 49 ee ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca9:	01 de                	add    %ebx,%esi
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	89 f0                	mov    %esi,%eax
  801cb0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb3:	72 cc                	jb     801c81 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5f                   	pop    %edi
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	83 ec 08             	sub    $0x8,%esp
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ccc:	74 2a                	je     801cf8 <devcons_read+0x3b>
  801cce:	eb 05                	jmp    801cd5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd0:	e8 ba ee ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cd5:	e8 36 ee ff ff       	call   800b10 <sys_cgetc>
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	74 f2                	je     801cd0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 16                	js     801cf8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce2:	83 f8 04             	cmp    $0x4,%eax
  801ce5:	74 0c                	je     801cf3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cea:	88 02                	mov    %al,(%edx)
	return 1;
  801cec:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf1:	eb 05                	jmp    801cf8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d00:	8b 45 08             	mov    0x8(%ebp),%eax
  801d03:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d06:	6a 01                	push   $0x1
  801d08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d0b:	50                   	push   %eax
  801d0c:	e8 e1 ed ff ff       	call   800af2 <sys_cputs>
}
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <getchar>:

int
getchar(void)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d1c:	6a 01                	push   $0x1
  801d1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d21:	50                   	push   %eax
  801d22:	6a 00                	push   $0x0
  801d24:	e8 9d f6 ff ff       	call   8013c6 <read>
	if (r < 0)
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 0f                	js     801d3f <getchar+0x29>
		return r;
	if (r < 1)
  801d30:	85 c0                	test   %eax,%eax
  801d32:	7e 06                	jle    801d3a <getchar+0x24>
		return -E_EOF;
	return c;
  801d34:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d38:	eb 05                	jmp    801d3f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d3a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 0d f4 ff ff       	call   801160 <fd_lookup>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 11                	js     801d6b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d63:	39 10                	cmp    %edx,(%eax)
  801d65:	0f 94 c0             	sete   %al
  801d68:	0f b6 c0             	movzbl %al,%eax
}
  801d6b:	c9                   	leave  
  801d6c:	c3                   	ret    

00801d6d <opencons>:

int
opencons(void)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d76:	50                   	push   %eax
  801d77:	e8 95 f3 ff ff       	call   801111 <fd_alloc>
  801d7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d7f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 3e                	js     801dc3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d85:	83 ec 04             	sub    $0x4,%esp
  801d88:	68 07 04 00 00       	push   $0x407
  801d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d90:	6a 00                	push   $0x0
  801d92:	e8 17 ee ff ff       	call   800bae <sys_page_alloc>
  801d97:	83 c4 10             	add    $0x10,%esp
		return r;
  801d9a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	78 23                	js     801dc3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801da0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801db5:	83 ec 0c             	sub    $0xc,%esp
  801db8:	50                   	push   %eax
  801db9:	e8 2c f3 ff ff       	call   8010ea <fd2num>
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	83 c4 10             	add    $0x10,%esp
}
  801dc3:	89 d0                	mov    %edx,%eax
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dce:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dd5:	75 57                	jne    801e2e <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801dd7:	e8 94 ed ff ff       	call   800b70 <sys_getenvid>
  801ddc:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801dde:	83 ec 04             	sub    $0x4,%esp
  801de1:	6a 07                	push   $0x7
  801de3:	68 00 f0 bf ee       	push   $0xeebff000
  801de8:	50                   	push   %eax
  801de9:	e8 c0 ed ff ff       	call   800bae <sys_page_alloc>
		if (r) {
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	74 12                	je     801e07 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801df5:	50                   	push   %eax
  801df6:	68 da 26 80 00       	push   $0x8026da
  801dfb:	6a 25                	push   $0x25
  801dfd:	68 76 28 80 00       	push   $0x802876
  801e02:	e8 46 e3 ff ff       	call   80014d <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	68 3b 1e 80 00       	push   $0x801e3b
  801e0f:	53                   	push   %ebx
  801e10:	e8 e4 ee ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
		if (r) {
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	74 12                	je     801e2e <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801e1c:	50                   	push   %eax
  801e1d:	68 84 28 80 00       	push   $0x802884
  801e22:	6a 2b                	push   $0x2b
  801e24:	68 76 28 80 00       	push   $0x802876
  801e29:	e8 1f e3 ff ff       	call   80014d <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e31:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e41:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e43:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801e46:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801e4a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801e4f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801e53:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801e55:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801e58:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801e59:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801e5c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801e5d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801e5e:	c3                   	ret    

00801e5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	8b 75 08             	mov    0x8(%ebp),%esi
  801e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	74 3e                	je     801eaf <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	50                   	push   %eax
  801e75:	e8 e4 ee ff ff       	call   800d5e <sys_ipc_recv>
  801e7a:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801e7c:	83 c4 10             	add    $0x10,%esp
  801e7f:	85 f6                	test   %esi,%esi
  801e81:	74 13                	je     801e96 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	85 d2                	test   %edx,%edx
  801e8a:	75 08                	jne    801e94 <ipc_recv+0x35>
  801e8c:	a1 08 40 80 00       	mov    0x804008,%eax
  801e91:	8b 40 74             	mov    0x74(%eax),%eax
  801e94:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801e96:	85 db                	test   %ebx,%ebx
  801e98:	74 48                	je     801ee2 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9f:	85 d2                	test   %edx,%edx
  801ea1:	75 08                	jne    801eab <ipc_recv+0x4c>
  801ea3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ea8:	8b 40 78             	mov    0x78(%eax),%eax
  801eab:	89 03                	mov    %eax,(%ebx)
  801ead:	eb 33                	jmp    801ee2 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801eaf:	83 ec 0c             	sub    $0xc,%esp
  801eb2:	68 00 00 c0 ee       	push   $0xeec00000
  801eb7:	e8 a2 ee ff ff       	call   800d5e <sys_ipc_recv>
  801ebc:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 f6                	test   %esi,%esi
  801ec3:	74 13                	je     801ed8 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eca:	85 d2                	test   %edx,%edx
  801ecc:	75 08                	jne    801ed6 <ipc_recv+0x77>
  801ece:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed3:	8b 40 74             	mov    0x74(%eax),%eax
  801ed6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ed8:	85 db                	test   %ebx,%ebx
  801eda:	74 06                	je     801ee2 <ipc_recv+0x83>
			*perm_store = 0;
  801edc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801ee2:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801ee4:	85 d2                	test   %edx,%edx
  801ee6:	75 08                	jne    801ef0 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801ee8:	a1 08 40 80 00       	mov    0x804008,%eax
  801eed:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	57                   	push   %edi
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801f09:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f10:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f13:	eb 1c                	jmp    801f31 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801f15:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f18:	74 12                	je     801f2c <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801f1a:	50                   	push   %eax
  801f1b:	68 ac 28 80 00       	push   $0x8028ac
  801f20:	6a 4f                	push   $0x4f
  801f22:	68 c7 28 80 00       	push   $0x8028c7
  801f27:	e8 21 e2 ff ff       	call   80014d <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801f2c:	e8 5e ec ff ff       	call   800b8f <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f31:	ff 75 14             	pushl  0x14(%ebp)
  801f34:	53                   	push   %ebx
  801f35:	56                   	push   %esi
  801f36:	57                   	push   %edi
  801f37:	e8 ff ed ff ff       	call   800d3b <sys_ipc_try_send>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	78 d2                	js     801f15 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5f                   	pop    %edi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f56:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f59:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5f:	8b 52 50             	mov    0x50(%edx),%edx
  801f62:	39 ca                	cmp    %ecx,%edx
  801f64:	75 0d                	jne    801f73 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f66:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6e:	8b 40 48             	mov    0x48(%eax),%eax
  801f71:	eb 0f                	jmp    801f82 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f73:	83 c0 01             	add    $0x1,%eax
  801f76:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7b:	75 d9                	jne    801f56 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8a:	89 d0                	mov    %edx,%eax
  801f8c:	c1 e8 16             	shr    $0x16,%eax
  801f8f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9b:	f6 c1 01             	test   $0x1,%cl
  801f9e:	74 1d                	je     801fbd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa0:	c1 ea 0c             	shr    $0xc,%edx
  801fa3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801faa:	f6 c2 01             	test   $0x1,%dl
  801fad:	74 0e                	je     801fbd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801faf:	c1 ea 0c             	shr    $0xc,%edx
  801fb2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb9:	ef 
  801fba:	0f b7 c0             	movzwl %ax,%eax
}
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
