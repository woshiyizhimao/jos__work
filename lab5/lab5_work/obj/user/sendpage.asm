
obj/user/sendpage.debug：     文件格式 elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 c3 0e 00 00       	call   800f01 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 f4 10 00 00       	call   801150 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 00 23 80 00       	push   $0x802300
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 59 07 00 00       	call   8007d8 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 4e 08 00 00       	call   8008e1 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 14 23 80 00       	push   $0x802314
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 20 07 00 00       	call   8007d8 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 3c 09 00 00       	call   800a0b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 08 11 00 00       	call   8011e8 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 14 0b 00 00       	call   800c14 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ca 06 00 00       	call   8007d8 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 e6 08 00 00       	call   800a0b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 b2 10 00 00       	call   8011e8 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 07 10 00 00       	call   801150 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 00 23 80 00       	push   $0x802300
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 6c 06 00 00       	call   8007d8 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 61 07 00 00       	call   8008e1 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 34 23 80 00       	push   $0x802334
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 2d 0a 00 00       	call   800bd6 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 56 12 00 00       	call   801440 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 a1 09 00 00       	call   800b95 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 2f 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 d4 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 7c 1d 00 00       	call   802070 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 69 1e 00 00       	call   8021a0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 ac 23 80 00 	movsbl 0x8023ac(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 89 03 00 00    	je     800768 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 1a 03 00 00    	ja     80074d <vprintfmt+0x38a>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800454:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800458:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 39                	ja     80049c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 27                	jmp    8004a2 <vprintfmt+0xdf>
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	b9 00 00 00 00       	mov    $0x0,%ecx
  800485:	0f 49 c8             	cmovns %eax,%ecx
  800488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	eb 8c                	jmp    80041c <vprintfmt+0x59>
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	eb 80                	jmp    80041c <vprintfmt+0x59>
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 89 70 ff ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b9:	e9 5e ff ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 30                	pushl  (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 04 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	99                   	cltd   
  8004f1:	31 d0                	xor    %edx,%eax
  8004f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 0f             	cmp    $0xf,%eax
  8004f8:	7f 0b                	jg     800505 <vprintfmt+0x142>
  8004fa:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 c4 23 80 00       	push   $0x8023c4
  80050b:	53                   	push   %ebx
  80050c:	56                   	push   %esi
  80050d:	e8 94 fe ff ff       	call   8003a6 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 cc fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	52                   	push   %edx
  80051e:	68 15 29 80 00       	push   $0x802915
  800523:	53                   	push   %ebx
  800524:	56                   	push   %esi
  800525:	e8 7c fe ff ff       	call   8003a6 <printfmt>
  80052a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800530:	e9 b4 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800540:	85 ff                	test   %edi,%edi
  800542:	b8 bd 23 80 00       	mov    $0x8023bd,%eax
  800547:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054e:	0f 8e 94 00 00 00    	jle    8005e8 <vprintfmt+0x225>
  800554:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800558:	0f 84 98 00 00 00    	je     8005f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d0             	pushl  -0x30(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 86 02 00 00       	call   8007f0 <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 75 e0             	pushl  -0x20(%ebp)
  80058a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1c0>
  800596:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	89 cb                	mov    %ecx,%ebx
  8005b3:	eb 4d                	jmp    800602 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	74 1b                	je     8005d6 <vprintfmt+0x213>
  8005bb:	0f be c0             	movsbl %al,%eax
  8005be:	83 e8 20             	sub    $0x20,%eax
  8005c1:	83 f8 5e             	cmp    $0x5e,%eax
  8005c4:	76 10                	jbe    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	6a 3f                	push   $0x3f
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	52                   	push   %edx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	eb 1a                	jmp    800602 <vprintfmt+0x23f>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 0c                	jmp    800602 <vprintfmt+0x23f>
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 23                	je     800633 <vprintfmt+0x270>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 a1                	js     8005b5 <vprintfmt+0x1f2>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 9c                	jns    8005b5 <vprintfmt+0x1f2>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 18                	jmp    80063b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 20                	push   $0x20
  800629:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 08                	jmp    80063b <vprintfmt+0x278>
  800633:	89 df                	mov    %ebx,%edi
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	85 ff                	test   %edi,%edi
  80063d:	7f e4                	jg     800623 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800647:	83 fa 01             	cmp    $0x1,%edx
  80064a:	7e 16                	jle    800662 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 08             	lea    0x8(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	eb 32                	jmp    800694 <vprintfmt+0x2d1>
	else if (lflag)
  800662:	85 d2                	test   %edx,%edx
  800664:	74 18                	je     80067e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 c1                	mov    %eax,%ecx
  800676:	c1 f9 1f             	sar    $0x1f,%ecx
  800679:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 c1                	mov    %eax,%ecx
  80068e:	c1 f9 1f             	sar    $0x1f,%ecx
  800691:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a3:	79 74                	jns    800719 <vprintfmt+0x356>
				putch('-', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 2d                	push   $0x2d
  8006ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b3:	f7 d8                	neg    %eax
  8006b5:	83 d2 00             	adc    $0x0,%edx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c2:	eb 55                	jmp    800719 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 83 fc ff ff       	call   80034f <getuint>
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d1:	eb 46                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 74 fc ff ff       	call   80034f <getuint>
			base=8;
  8006db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006e0:	eb 37                	jmp    800719 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 78                	push   $0x78
  8006f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800702:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800705:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070a:	eb 0d                	jmp    800719 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 3b fc ff ff       	call   80034f <getuint>
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800720:	57                   	push   %edi
  800721:	ff 75 e0             	pushl  -0x20(%ebp)
  800724:	51                   	push   %ecx
  800725:	52                   	push   %edx
  800726:	50                   	push   %eax
  800727:	89 da                	mov    %ebx,%edx
  800729:	89 f0                	mov    %esi,%eax
  80072b:	e8 70 fb ff ff       	call   8002a0 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800736:	e9 ae fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	51                   	push   %ecx
  800740:	ff d6                	call   *%esi
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 9c fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 03                	jmp    80075d <vprintfmt+0x39a>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800761:	75 f7                	jne    80075a <vprintfmt+0x397>
  800763:	e9 81 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 89 03 80 00       	push   $0x800389
  8007a4:	e8 1a fc ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 05                	jmp    8007bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 08                	je     80080f <strnlen+0x1f>
  800807:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
  80080d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ef                	jne    80081d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800838:	53                   	push   %ebx
  800839:	e8 9a ff ff ff       	call   8007d8 <strlen>
  80083e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	01 d8                	add    %ebx,%eax
  800846:	50                   	push   %eax
  800847:	e8 c5 ff ff ff       	call   800811 <strcpy>
	return dst;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	89 f3                	mov    %esi,%ebx
  800860:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 0f                	jmp    800876 <strncpy+0x23>
		*dst++ = *src;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	0f b6 01             	movzbl (%ecx),%eax
  80086d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800870:	80 39 01             	cmpb   $0x1,(%ecx)
  800873:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	39 da                	cmp    %ebx,%edx
  800878:	75 ed                	jne    800867 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
  80088e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 d2                	test   %edx,%edx
  800892:	74 21                	je     8008b5 <strlcpy+0x35>
  800894:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800898:	89 f2                	mov    %esi,%edx
  80089a:	eb 09                	jmp    8008a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	39 c2                	cmp    %eax,%edx
  8008a7:	74 09                	je     8008b2 <strlcpy+0x32>
  8008a9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ec                	jne    80089c <strlcpy+0x1c>
  8008b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b5:	29 f0                	sub    %esi,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strcmp+0x11>
		p++, q++;
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strcmp+0x1c>
  8008d3:	3a 02                	cmp    (%edx),%al
  8008d5:	74 ef                	je     8008c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 06                	jmp    8008f8 <strncmp+0x17>
		n--, p++, q++;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f8:	39 d8                	cmp    %ebx,%eax
  8008fa:	74 15                	je     800911 <strncmp+0x30>
  8008fc:	0f b6 08             	movzbl (%eax),%ecx
  8008ff:	84 c9                	test   %cl,%cl
  800901:	74 04                	je     800907 <strncmp+0x26>
  800903:	3a 0a                	cmp    (%edx),%cl
  800905:	74 eb                	je     8008f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb 05                	jmp    800916 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 07                	jmp    80092c <strchr+0x13>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0f                	je     800938 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f2                	jne    800925 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 03                	jmp    800949 <strfind+0xf>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 04                	je     800954 <strfind+0x1a>
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strfind+0xc>
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 36                	je     80099c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800966:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096c:	75 28                	jne    800996 <memset+0x40>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 23                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800973:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800977:	89 d3                	mov    %edx,%ebx
  800979:	c1 e3 08             	shl    $0x8,%ebx
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	c1 e6 18             	shl    $0x18,%esi
  800981:	89 d0                	mov    %edx,%eax
  800983:	c1 e0 10             	shl    $0x10,%eax
  800986:	09 f0                	or     %esi,%eax
  800988:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	09 d0                	or     %edx,%eax
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 06                	jmp    80099c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	fc                   	cld    
  80099a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b1:	39 c6                	cmp    %eax,%esi
  8009b3:	73 35                	jae    8009ea <memmove+0x47>
  8009b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	73 2e                	jae    8009ea <memmove+0x47>
		s += n;
		d += n;
  8009bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	09 fe                	or     %edi,%esi
  8009c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c9:	75 13                	jne    8009de <memmove+0x3b>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0e                	jne    8009de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d0:	83 ef 04             	sub    $0x4,%edi
  8009d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fd                   	std    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dc:	eb 09                	jmp    8009e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009de:	83 ef 01             	sub    $0x1,%edi
  8009e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e4:	fd                   	std    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e7:	fc                   	cld    
  8009e8:	eb 1d                	jmp    800a07 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	09 c2                	or     %eax,%edx
  8009ee:	f6 c2 03             	test   $0x3,%dl
  8009f1:	75 0f                	jne    800a02 <memmove+0x5f>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0a                	jne    800a02 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 05                	jmp    800a07 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <memmove>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	eb 1a                	jmp    800a4a <memcmp+0x2c>
		if (*s1 != *s2)
  800a30:	0f b6 08             	movzbl (%eax),%ecx
  800a33:	0f b6 1a             	movzbl (%edx),%ebx
  800a36:	38 d9                	cmp    %bl,%cl
  800a38:	74 0a                	je     800a44 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3a:	0f b6 c1             	movzbl %cl,%eax
  800a3d:	0f b6 db             	movzbl %bl,%ebx
  800a40:	29 d8                	sub    %ebx,%eax
  800a42:	eb 0f                	jmp    800a53 <memcmp+0x35>
		s1++, s2++;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	75 e2                	jne    800a30 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5e:	89 c1                	mov    %eax,%ecx
  800a60:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	eb 0a                	jmp    800a73 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	39 da                	cmp    %ebx,%edx
  800a6e:	74 07                	je     800a77 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	39 c8                	cmp    %ecx,%eax
  800a75:	72 f2                	jb     800a69 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 03                	jmp    800a8b <strtol+0x11>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	3c 20                	cmp    $0x20,%al
  800a90:	74 f6                	je     800a88 <strtol+0xe>
  800a92:	3c 09                	cmp    $0x9,%al
  800a94:	74 f2                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a96:	3c 2b                	cmp    $0x2b,%al
  800a98:	75 0a                	jne    800aa4 <strtol+0x2a>
		s++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa2:	eb 11                	jmp    800ab5 <strtol+0x3b>
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	75 08                	jne    800ab5 <strtol+0x3b>
		s++, neg = 1;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 15                	jne    800ad2 <strtol+0x58>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 10                	jne    800ad2 <strtol+0x58>
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	75 7c                	jne    800b44 <strtol+0xca>
		s += 2, base = 16;
  800ac8:	83 c1 02             	add    $0x2,%ecx
  800acb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad0:	eb 16                	jmp    800ae8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	75 12                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 08                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	0f b6 11             	movzbl (%ecx),%edx
  800af3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 09             	cmp    $0x9,%bl
  800afb:	77 08                	ja     800b05 <strtol+0x8b>
			dig = *s - '0';
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 30             	sub    $0x30,%edx
  800b03:	eb 22                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 19             	cmp    $0x19,%bl
  800b0d:	77 08                	ja     800b17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0f:	0f be d2             	movsbl %dl,%edx
  800b12:	83 ea 57             	sub    $0x57,%edx
  800b15:	eb 10                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 19             	cmp    $0x19,%bl
  800b1f:	77 16                	ja     800b37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 0b                	jge    800b37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b35:	eb b9                	jmp    800af0 <strtol+0x76>

	if (endptr)
  800b37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3b:	74 0d                	je     800b4a <strtol+0xd0>
		*endptr = (char *) s;
  800b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b40:	89 0e                	mov    %ecx,(%esi)
  800b42:	eb 06                	jmp    800b4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 98                	je     800ae0 <strtol+0x66>
  800b48:	eb 9e                	jmp    800ae8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	f7 da                	neg    %edx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	0f 45 c2             	cmovne %edx,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	68 9f 26 80 00       	push   $0x80269f
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 bc 26 80 00       	push   $0x8026bc
  800bc9:	e8 84 13 00 00       	call   801f52 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_yield>:

void
sys_yield(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	b8 04 00 00 00       	mov    $0x4,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 04                	push   $0x4
  800c3e:	68 9f 26 80 00       	push   $0x80269f
  800c43:	6a 23                	push   $0x23
  800c45:	68 bc 26 80 00       	push   $0x8026bc
  800c4a:	e8 03 13 00 00       	call   801f52 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 05                	push   $0x5
  800c80:	68 9f 26 80 00       	push   $0x80269f
  800c85:	6a 23                	push   $0x23
  800c87:	68 bc 26 80 00       	push   $0x8026bc
  800c8c:	e8 c1 12 00 00       	call   801f52 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 06                	push   $0x6
  800cc2:	68 9f 26 80 00       	push   $0x80269f
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 bc 26 80 00       	push   $0x8026bc
  800cce:	e8 7f 12 00 00       	call   801f52 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 08                	push   $0x8
  800d04:	68 9f 26 80 00       	push   $0x80269f
  800d09:	6a 23                	push   $0x23
  800d0b:	68 bc 26 80 00       	push   $0x8026bc
  800d10:	e8 3d 12 00 00       	call   801f52 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 9f 26 80 00       	push   $0x80269f
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 bc 26 80 00       	push   $0x8026bc
  800d52:	e8 fb 11 00 00       	call   801f52 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0a                	push   $0xa
  800d88:	68 9f 26 80 00       	push   $0x80269f
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 bc 26 80 00       	push   $0x8026bc
  800d94:	e8 b9 11 00 00       	call   801f52 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 0d                	push   $0xd
  800dec:	68 9f 26 80 00       	push   $0x80269f
  800df1:	6a 23                	push   $0x23
  800df3:	68 bc 26 80 00       	push   $0x8026bc
  800df8:	e8 55 11 00 00       	call   801f52 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e0d:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800e0f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e13:	75 14                	jne    800e29 <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 cc 26 80 00       	push   $0x8026cc
  800e1d:	6a 23                	push   $0x23
  800e1f:	68 8f 27 80 00       	push   $0x80278f
  800e24:	e8 29 11 00 00       	call   801f52 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	c1 e8 0c             	shr    $0xc,%eax
  800e2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e35:	f6 c4 08             	test   $0x8,%ah
  800e38:	75 14                	jne    800e4e <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800e3a:	83 ec 04             	sub    $0x4,%esp
  800e3d:	68 f0 26 80 00       	push   $0x8026f0
  800e42:	6a 2d                	push   $0x2d
  800e44:	68 8f 27 80 00       	push   $0x80278f
  800e49:	e8 04 11 00 00       	call   801f52 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800e4e:	e8 83 fd ff ff       	call   800bd6 <sys_getenvid>
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	6a 07                	push   $0x7
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	50                   	push   %eax
  800e5e:	e8 b1 fd ff ff       	call   800c14 <sys_page_alloc>
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	79 12                	jns    800e7c <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800e6a:	50                   	push   %eax
  800e6b:	68 9a 27 80 00       	push   $0x80279a
  800e70:	6a 3b                	push   $0x3b
  800e72:	68 8f 27 80 00       	push   $0x80278f
  800e77:	e8 d6 10 00 00       	call   801f52 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800e7c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800e82:	83 ec 04             	sub    $0x4,%esp
  800e85:	68 00 10 00 00       	push   $0x1000
  800e8a:	53                   	push   %ebx
  800e8b:	68 00 f0 7f 00       	push   $0x7ff000
  800e90:	e8 0e fb ff ff       	call   8009a3 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800e95:	e8 3c fd ff ff       	call   800bd6 <sys_getenvid>
  800e9a:	89 c6                	mov    %eax,%esi
  800e9c:	e8 35 fd ff ff       	call   800bd6 <sys_getenvid>
  800ea1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea8:	53                   	push   %ebx
  800ea9:	56                   	push   %esi
  800eaa:	68 00 f0 7f 00       	push   $0x7ff000
  800eaf:	50                   	push   %eax
  800eb0:	e8 a2 fd ff ff       	call   800c57 <sys_page_map>
  800eb5:	83 c4 20             	add    $0x20,%esp
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	79 12                	jns    800ece <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800ebc:	50                   	push   %eax
  800ebd:	68 b3 27 80 00       	push   $0x8027b3
  800ec2:	6a 48                	push   $0x48
  800ec4:	68 8f 27 80 00       	push   $0x80278f
  800ec9:	e8 84 10 00 00       	call   801f52 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800ece:	e8 03 fd ff ff       	call   800bd6 <sys_getenvid>
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	68 00 f0 7f 00       	push   $0x7ff000
  800edb:	50                   	push   %eax
  800edc:	e8 b8 fd ff ff       	call   800c99 <sys_page_unmap>
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	79 12                	jns    800efa <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800ee8:	50                   	push   %eax
  800ee9:	68 ca 27 80 00       	push   $0x8027ca
  800eee:	6a 4c                	push   $0x4c
  800ef0:	68 8f 27 80 00       	push   $0x80278f
  800ef5:	e8 58 10 00 00       	call   801f52 <_panic>
	}

	//panic("pgfault not implemented");
}
  800efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800f0a:	68 05 0e 80 00       	push   $0x800e05
  800f0f:	e8 84 10 00 00       	call   801f98 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f14:	b8 07 00 00 00       	mov    $0x7,%eax
  800f19:	cd 30                	int    $0x30
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 15                	jns    800f3c <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800f27:	50                   	push   %eax
  800f28:	68 e3 27 80 00       	push   $0x8027e3
  800f2d:	68 a1 00 00 00       	push   $0xa1
  800f32:	68 8f 27 80 00       	push   $0x80278f
  800f37:	e8 16 10 00 00       	call   801f52 <_panic>
  800f3c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800f41:	85 c0                	test   %eax,%eax
  800f43:	75 21                	jne    800f66 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800f45:	e8 8c fc ff ff       	call   800bd6 <sys_getenvid>
  800f4a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f4f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f52:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f57:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	e9 c8 01 00 00       	jmp    80112e <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	c1 e8 16             	shr    $0x16,%eax
  800f6b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f72:	a8 01                	test   $0x1,%al
  800f74:	0f 84 23 01 00 00    	je     80109d <fork+0x19c>
  800f7a:	89 d8                	mov    %ebx,%eax
  800f7c:	c1 e8 0c             	shr    $0xc,%eax
  800f7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	0f 84 0e 01 00 00    	je     80109d <fork+0x19c>
  800f8f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f96:	f6 c2 04             	test   $0x4,%dl
  800f99:	0f 84 fe 00 00 00    	je     80109d <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800fa4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fab:	f6 c6 04             	test   $0x4,%dh
  800fae:	74 3f                	je     800fef <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800fb0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbf:	50                   	push   %eax
  800fc0:	56                   	push   %esi
  800fc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc4:	56                   	push   %esi
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 8b fc ff ff       	call   800c57 <sys_page_map>
  800fcc:	83 c4 20             	add    $0x20,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	0f 89 c6 00 00 00    	jns    80109d <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	50                   	push   %eax
  800fdb:	57                   	push   %edi
  800fdc:	6a 00                	push   $0x0
  800fde:	68 20 27 80 00       	push   $0x802720
  800fe3:	6a 6c                	push   $0x6c
  800fe5:	68 8f 27 80 00       	push   $0x80278f
  800fea:	e8 63 0f 00 00       	call   801f52 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff6:	f6 c2 02             	test   $0x2,%dl
  800ff9:	75 0c                	jne    801007 <fork+0x106>
  800ffb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801002:	f6 c4 08             	test   $0x8,%ah
  801005:	74 66                	je     80106d <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	68 05 08 00 00       	push   $0x805
  80100f:	56                   	push   %esi
  801010:	ff 75 e4             	pushl  -0x1c(%ebp)
  801013:	56                   	push   %esi
  801014:	6a 00                	push   $0x0
  801016:	e8 3c fc ff ff       	call   800c57 <sys_page_map>
  80101b:	83 c4 20             	add    $0x20,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	79 18                	jns    80103a <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	50                   	push   %eax
  801026:	57                   	push   %edi
  801027:	6a 00                	push   $0x0
  801029:	68 20 27 80 00       	push   $0x802720
  80102e:	6a 74                	push   $0x74
  801030:	68 8f 27 80 00       	push   $0x80278f
  801035:	e8 18 0f 00 00       	call   801f52 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	68 05 08 00 00       	push   $0x805
  801042:	56                   	push   %esi
  801043:	6a 00                	push   $0x0
  801045:	56                   	push   %esi
  801046:	6a 00                	push   $0x0
  801048:	e8 0a fc ff ff       	call   800c57 <sys_page_map>
  80104d:	83 c4 20             	add    $0x20,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	79 49                	jns    80109d <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	50                   	push   %eax
  801058:	6a 00                	push   $0x0
  80105a:	6a 00                	push   $0x0
  80105c:	68 20 27 80 00       	push   $0x802720
  801061:	6a 77                	push   $0x77
  801063:	68 8f 27 80 00       	push   $0x80278f
  801068:	e8 e5 0e 00 00       	call   801f52 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	6a 05                	push   $0x5
  801072:	56                   	push   %esi
  801073:	ff 75 e4             	pushl  -0x1c(%ebp)
  801076:	56                   	push   %esi
  801077:	6a 00                	push   $0x0
  801079:	e8 d9 fb ff ff       	call   800c57 <sys_page_map>
  80107e:	83 c4 20             	add    $0x20,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 18                	jns    80109d <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801085:	83 ec 08             	sub    $0x8,%esp
  801088:	50                   	push   %eax
  801089:	57                   	push   %edi
  80108a:	6a 00                	push   $0x0
  80108c:	68 20 27 80 00       	push   $0x802720
  801091:	6a 7d                	push   $0x7d
  801093:	68 8f 27 80 00       	push   $0x80278f
  801098:	e8 b5 0e 00 00       	call   801f52 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  80109d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010a9:	0f 85 b7 fe ff ff    	jne    800f66 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	6a 07                	push   $0x7
  8010b4:	68 00 f0 bf ee       	push   $0xeebff000
  8010b9:	57                   	push   %edi
  8010ba:	e8 55 fb ff ff       	call   800c14 <sys_page_alloc>
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	79 15                	jns    8010db <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  8010c6:	50                   	push   %eax
  8010c7:	68 4c 27 80 00       	push   $0x80274c
  8010cc:	68 b4 00 00 00       	push   $0xb4
  8010d1:	68 8f 27 80 00       	push   $0x80278f
  8010d6:	e8 77 0e 00 00       	call   801f52 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	68 0c 20 80 00       	push   $0x80200c
  8010e3:	57                   	push   %edi
  8010e4:	e8 76 fc ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	79 15                	jns    801105 <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  8010f0:	50                   	push   %eax
  8010f1:	68 f9 27 80 00       	push   $0x8027f9
  8010f6:	68 ba 00 00 00       	push   $0xba
  8010fb:	68 8f 27 80 00       	push   $0x80278f
  801100:	e8 4d 0e 00 00       	call   801f52 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801105:	83 ec 08             	sub    $0x8,%esp
  801108:	6a 02                	push   $0x2
  80110a:	57                   	push   %edi
  80110b:	e8 cb fb ff ff       	call   800cdb <sys_env_set_status>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	79 15                	jns    80112c <fork+0x22b>
		panic("Sys env set status error: %e", r);
  801117:	50                   	push   %eax
  801118:	68 16 28 80 00       	push   $0x802816
  80111d:	68 bf 00 00 00       	push   $0xbf
  801122:	68 8f 27 80 00       	push   $0x80278f
  801127:	e8 26 0e 00 00       	call   801f52 <_panic>
	}
	return eid;
  80112c:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sfork>:

// Challenge!
int
sfork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80113c:	68 33 28 80 00       	push   $0x802833
  801141:	68 ca 00 00 00       	push   $0xca
  801146:	68 8f 27 80 00       	push   $0x80278f
  80114b:	e8 02 0e 00 00       	call   801f52 <_panic>

00801150 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	8b 75 08             	mov    0x8(%ebp),%esi
  801158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  80115e:	85 c0                	test   %eax,%eax
  801160:	74 3e                	je     8011a0 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	50                   	push   %eax
  801166:	e8 59 fc ff ff       	call   800dc4 <sys_ipc_recv>
  80116b:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	85 f6                	test   %esi,%esi
  801172:	74 13                	je     801187 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	85 d2                	test   %edx,%edx
  80117b:	75 08                	jne    801185 <ipc_recv+0x35>
  80117d:	a1 04 40 80 00       	mov    0x804004,%eax
  801182:	8b 40 74             	mov    0x74(%eax),%eax
  801185:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801187:	85 db                	test   %ebx,%ebx
  801189:	74 48                	je     8011d3 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
  801190:	85 d2                	test   %edx,%edx
  801192:	75 08                	jne    80119c <ipc_recv+0x4c>
  801194:	a1 04 40 80 00       	mov    0x804004,%eax
  801199:	8b 40 78             	mov    0x78(%eax),%eax
  80119c:	89 03                	mov    %eax,(%ebx)
  80119e:	eb 33                	jmp    8011d3 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	68 00 00 c0 ee       	push   $0xeec00000
  8011a8:	e8 17 fc ff ff       	call   800dc4 <sys_ipc_recv>
  8011ad:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 f6                	test   %esi,%esi
  8011b4:	74 13                	je     8011c9 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bb:	85 d2                	test   %edx,%edx
  8011bd:	75 08                	jne    8011c7 <ipc_recv+0x77>
  8011bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c4:	8b 40 74             	mov    0x74(%eax),%eax
  8011c7:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8011c9:	85 db                	test   %ebx,%ebx
  8011cb:	74 06                	je     8011d3 <ipc_recv+0x83>
			*perm_store = 0;
  8011cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  8011d3:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  8011d5:	85 d2                	test   %edx,%edx
  8011d7:	75 08                	jne    8011e1 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  8011d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011de:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  8011e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	57                   	push   %edi
  8011ec:	56                   	push   %esi
  8011ed:	53                   	push   %ebx
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  8011fa:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  8011fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801201:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801204:	eb 1c                	jmp    801222 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801206:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801209:	74 12                	je     80121d <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  80120b:	50                   	push   %eax
  80120c:	68 49 28 80 00       	push   $0x802849
  801211:	6a 4f                	push   $0x4f
  801213:	68 64 28 80 00       	push   $0x802864
  801218:	e8 35 0d 00 00       	call   801f52 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  80121d:	e8 d3 f9 ff ff       	call   800bf5 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801222:	ff 75 14             	pushl  0x14(%ebp)
  801225:	53                   	push   %ebx
  801226:	56                   	push   %esi
  801227:	57                   	push   %edi
  801228:	e8 74 fb ff ff       	call   800da1 <sys_ipc_try_send>
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 d2                	js     801206 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801247:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80124a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801250:	8b 52 50             	mov    0x50(%edx),%edx
  801253:	39 ca                	cmp    %ecx,%edx
  801255:	75 0d                	jne    801264 <ipc_find_env+0x28>
			return envs[i].env_id;
  801257:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80125a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80125f:	8b 40 48             	mov    0x48(%eax),%eax
  801262:	eb 0f                	jmp    801273 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801264:	83 c0 01             	add    $0x1,%eax
  801267:	3d 00 04 00 00       	cmp    $0x400,%eax
  80126c:	75 d9                	jne    801247 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801278:	8b 45 08             	mov    0x8(%ebp),%eax
  80127b:	05 00 00 00 30       	add    $0x30000000,%eax
  801280:	c1 e8 0c             	shr    $0xc,%eax
}
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801288:	8b 45 08             	mov    0x8(%ebp),%eax
  80128b:	05 00 00 00 30       	add    $0x30000000,%eax
  801290:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801295:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	c1 ea 16             	shr    $0x16,%edx
  8012ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b3:	f6 c2 01             	test   $0x1,%dl
  8012b6:	74 11                	je     8012c9 <fd_alloc+0x2d>
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	c1 ea 0c             	shr    $0xc,%edx
  8012bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c4:	f6 c2 01             	test   $0x1,%dl
  8012c7:	75 09                	jne    8012d2 <fd_alloc+0x36>
			*fd_store = fd;
  8012c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d0:	eb 17                	jmp    8012e9 <fd_alloc+0x4d>
  8012d2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012d7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012dc:	75 c9                	jne    8012a7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012de:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012e4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f1:	83 f8 1f             	cmp    $0x1f,%eax
  8012f4:	77 36                	ja     80132c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012f6:	c1 e0 0c             	shl    $0xc,%eax
  8012f9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 16             	shr    $0x16,%edx
  801303:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	74 24                	je     801333 <fd_lookup+0x48>
  80130f:	89 c2                	mov    %eax,%edx
  801311:	c1 ea 0c             	shr    $0xc,%edx
  801314:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131b:	f6 c2 01             	test   $0x1,%dl
  80131e:	74 1a                	je     80133a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801320:	8b 55 0c             	mov    0xc(%ebp),%edx
  801323:	89 02                	mov    %eax,(%edx)
	return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb 13                	jmp    80133f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801331:	eb 0c                	jmp    80133f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801333:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801338:	eb 05                	jmp    80133f <fd_lookup+0x54>
  80133a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134a:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80134f:	eb 13                	jmp    801364 <dev_lookup+0x23>
  801351:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801354:	39 08                	cmp    %ecx,(%eax)
  801356:	75 0c                	jne    801364 <dev_lookup+0x23>
			*dev = devtab[i];
  801358:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80135d:	b8 00 00 00 00       	mov    $0x0,%eax
  801362:	eb 2e                	jmp    801392 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801364:	8b 02                	mov    (%edx),%eax
  801366:	85 c0                	test   %eax,%eax
  801368:	75 e7                	jne    801351 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80136a:	a1 04 40 80 00       	mov    0x804004,%eax
  80136f:	8b 40 48             	mov    0x48(%eax),%eax
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	51                   	push   %ecx
  801376:	50                   	push   %eax
  801377:	68 70 28 80 00       	push   $0x802870
  80137c:	e8 0b ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  801381:	8b 45 0c             	mov    0xc(%ebp),%eax
  801384:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
  801399:	83 ec 10             	sub    $0x10,%esp
  80139c:	8b 75 08             	mov    0x8(%ebp),%esi
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ac:	c1 e8 0c             	shr    $0xc,%eax
  8013af:	50                   	push   %eax
  8013b0:	e8 36 ff ff ff       	call   8012eb <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 05                	js     8013c1 <fd_close+0x2d>
	    || fd != fd2)
  8013bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013bf:	74 0c                	je     8013cd <fd_close+0x39>
		return (must_exist ? r : 0);
  8013c1:	84 db                	test   %bl,%bl
  8013c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c8:	0f 44 c2             	cmove  %edx,%eax
  8013cb:	eb 41                	jmp    80140e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 36                	pushl  (%esi)
  8013d6:	e8 66 ff ff ff       	call   801341 <dev_lookup>
  8013db:	89 c3                	mov    %eax,%ebx
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 1a                	js     8013fe <fd_close+0x6a>
		if (dev->dev_close)
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	74 0b                	je     8013fe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	56                   	push   %esi
  8013f7:	ff d0                	call   *%eax
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	56                   	push   %esi
  801402:	6a 00                	push   $0x0
  801404:	e8 90 f8 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 d8                	mov    %ebx,%eax
}
  80140e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 c4 fe ff ff       	call   8012eb <fd_lookup>
  801427:	83 c4 08             	add    $0x8,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 10                	js     80143e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	6a 01                	push   $0x1
  801433:	ff 75 f4             	pushl  -0xc(%ebp)
  801436:	e8 59 ff ff ff       	call   801394 <fd_close>
  80143b:	83 c4 10             	add    $0x10,%esp
}
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <close_all>:

void
close_all(void)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801447:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	53                   	push   %ebx
  801450:	e8 c0 ff ff ff       	call   801415 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801455:	83 c3 01             	add    $0x1,%ebx
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	83 fb 20             	cmp    $0x20,%ebx
  80145e:	75 ec                	jne    80144c <close_all+0xc>
		close(i);
}
  801460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	57                   	push   %edi
  801469:	56                   	push   %esi
  80146a:	53                   	push   %ebx
  80146b:	83 ec 2c             	sub    $0x2c,%esp
  80146e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801471:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	ff 75 08             	pushl  0x8(%ebp)
  801478:	e8 6e fe ff ff       	call   8012eb <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	0f 88 c1 00 00 00    	js     801549 <dup+0xe4>
		return r;
	close(newfdnum);
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	56                   	push   %esi
  80148c:	e8 84 ff ff ff       	call   801415 <close>

	newfd = INDEX2FD(newfdnum);
  801491:	89 f3                	mov    %esi,%ebx
  801493:	c1 e3 0c             	shl    $0xc,%ebx
  801496:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80149c:	83 c4 04             	add    $0x4,%esp
  80149f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a2:	e8 de fd ff ff       	call   801285 <fd2data>
  8014a7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	e8 d4 fd ff ff       	call   801285 <fd2data>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b7:	89 f8                	mov    %edi,%eax
  8014b9:	c1 e8 16             	shr    $0x16,%eax
  8014bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c3:	a8 01                	test   $0x1,%al
  8014c5:	74 37                	je     8014fe <dup+0x99>
  8014c7:	89 f8                	mov    %edi,%eax
  8014c9:	c1 e8 0c             	shr    $0xc,%eax
  8014cc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d3:	f6 c2 01             	test   $0x1,%dl
  8014d6:	74 26                	je     8014fe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014df:	83 ec 0c             	sub    $0xc,%esp
  8014e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e7:	50                   	push   %eax
  8014e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014eb:	6a 00                	push   $0x0
  8014ed:	57                   	push   %edi
  8014ee:	6a 00                	push   $0x0
  8014f0:	e8 62 f7 ff ff       	call   800c57 <sys_page_map>
  8014f5:	89 c7                	mov    %eax,%edi
  8014f7:	83 c4 20             	add    $0x20,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 2e                	js     80152c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801501:	89 d0                	mov    %edx,%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
  801506:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	25 07 0e 00 00       	and    $0xe07,%eax
  801515:	50                   	push   %eax
  801516:	53                   	push   %ebx
  801517:	6a 00                	push   $0x0
  801519:	52                   	push   %edx
  80151a:	6a 00                	push   $0x0
  80151c:	e8 36 f7 ff ff       	call   800c57 <sys_page_map>
  801521:	89 c7                	mov    %eax,%edi
  801523:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801526:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801528:	85 ff                	test   %edi,%edi
  80152a:	79 1d                	jns    801549 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	53                   	push   %ebx
  801530:	6a 00                	push   $0x0
  801532:	e8 62 f7 ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80153d:	6a 00                	push   $0x0
  80153f:	e8 55 f7 ff ff       	call   800c99 <sys_page_unmap>
	return r;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	89 f8                	mov    %edi,%eax
}
  801549:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 14             	sub    $0x14,%esp
  801558:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	53                   	push   %ebx
  801560:	e8 86 fd ff ff       	call   8012eb <fd_lookup>
  801565:	83 c4 08             	add    $0x8,%esp
  801568:	89 c2                	mov    %eax,%edx
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 6d                	js     8015db <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	ff 30                	pushl  (%eax)
  80157a:	e8 c2 fd ff ff       	call   801341 <dev_lookup>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 4c                	js     8015d2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801586:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801589:	8b 42 08             	mov    0x8(%edx),%eax
  80158c:	83 e0 03             	and    $0x3,%eax
  80158f:	83 f8 01             	cmp    $0x1,%eax
  801592:	75 21                	jne    8015b5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801594:	a1 04 40 80 00       	mov    0x804004,%eax
  801599:	8b 40 48             	mov    0x48(%eax),%eax
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	53                   	push   %ebx
  8015a0:	50                   	push   %eax
  8015a1:	68 b1 28 80 00       	push   $0x8028b1
  8015a6:	e8 e1 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b3:	eb 26                	jmp    8015db <read+0x8a>
	}
	if (!dev->dev_read)
  8015b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b8:	8b 40 08             	mov    0x8(%eax),%eax
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	74 17                	je     8015d6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	ff 75 10             	pushl  0x10(%ebp)
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	52                   	push   %edx
  8015c9:	ff d0                	call   *%eax
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	eb 09                	jmp    8015db <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	eb 05                	jmp    8015db <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	57                   	push   %edi
  8015e6:	56                   	push   %esi
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f6:	eb 21                	jmp    801619 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	89 f0                	mov    %esi,%eax
  8015fd:	29 d8                	sub    %ebx,%eax
  8015ff:	50                   	push   %eax
  801600:	89 d8                	mov    %ebx,%eax
  801602:	03 45 0c             	add    0xc(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	57                   	push   %edi
  801607:	e8 45 ff ff ff       	call   801551 <read>
		if (m < 0)
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 10                	js     801623 <readn+0x41>
			return m;
		if (m == 0)
  801613:	85 c0                	test   %eax,%eax
  801615:	74 0a                	je     801621 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801617:	01 c3                	add    %eax,%ebx
  801619:	39 f3                	cmp    %esi,%ebx
  80161b:	72 db                	jb     8015f8 <readn+0x16>
  80161d:	89 d8                	mov    %ebx,%eax
  80161f:	eb 02                	jmp    801623 <readn+0x41>
  801621:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5f                   	pop    %edi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	53                   	push   %ebx
  80163a:	e8 ac fc ff ff       	call   8012eb <fd_lookup>
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 68                	js     8016b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 e8 fc ff ff       	call   801341 <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 47                	js     8016a7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801667:	75 21                	jne    80168a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801669:	a1 04 40 80 00       	mov    0x804004,%eax
  80166e:	8b 40 48             	mov    0x48(%eax),%eax
  801671:	83 ec 04             	sub    $0x4,%esp
  801674:	53                   	push   %ebx
  801675:	50                   	push   %eax
  801676:	68 cd 28 80 00       	push   $0x8028cd
  80167b:	e8 0c ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801688:	eb 26                	jmp    8016b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 0c             	mov    0xc(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 17                	je     8016ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801694:	83 ec 04             	sub    $0x4,%esp
  801697:	ff 75 10             	pushl  0x10(%ebp)
  80169a:	ff 75 0c             	pushl  0xc(%ebp)
  80169d:	50                   	push   %eax
  80169e:	ff d2                	call   *%edx
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	eb 09                	jmp    8016b0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	eb 05                	jmp    8016b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b0:	89 d0                	mov    %edx,%eax
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c0:	50                   	push   %eax
  8016c1:	ff 75 08             	pushl  0x8(%ebp)
  8016c4:	e8 22 fc ff ff       	call   8012eb <fd_lookup>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 0e                	js     8016de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 14             	sub    $0x14,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	53                   	push   %ebx
  8016ef:	e8 f7 fb ff ff       	call   8012eb <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 65                	js     801762 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	ff 30                	pushl  (%eax)
  801709:	e8 33 fc ff ff       	call   801341 <dev_lookup>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 44                	js     801759 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801718:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171c:	75 21                	jne    80173f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80171e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801723:	8b 40 48             	mov    0x48(%eax),%eax
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	53                   	push   %ebx
  80172a:	50                   	push   %eax
  80172b:	68 90 28 80 00       	push   $0x802890
  801730:	e8 57 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80173d:	eb 23                	jmp    801762 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80173f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801742:	8b 52 18             	mov    0x18(%edx),%edx
  801745:	85 d2                	test   %edx,%edx
  801747:	74 14                	je     80175d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	50                   	push   %eax
  801750:	ff d2                	call   *%edx
  801752:	89 c2                	mov    %eax,%edx
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	eb 09                	jmp    801762 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801759:	89 c2                	mov    %eax,%edx
  80175b:	eb 05                	jmp    801762 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80175d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801762:	89 d0                	mov    %edx,%eax
  801764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	53                   	push   %ebx
  80176d:	83 ec 14             	sub    $0x14,%esp
  801770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801773:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	ff 75 08             	pushl  0x8(%ebp)
  80177a:	e8 6c fb ff ff       	call   8012eb <fd_lookup>
  80177f:	83 c4 08             	add    $0x8,%esp
  801782:	89 c2                	mov    %eax,%edx
  801784:	85 c0                	test   %eax,%eax
  801786:	78 58                	js     8017e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801792:	ff 30                	pushl  (%eax)
  801794:	e8 a8 fb ff ff       	call   801341 <dev_lookup>
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 37                	js     8017d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a7:	74 32                	je     8017db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b3:	00 00 00 
	stat->st_isdir = 0;
  8017b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017bd:	00 00 00 
	stat->st_dev = dev;
  8017c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	53                   	push   %ebx
  8017ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cd:	ff 50 14             	call   *0x14(%eax)
  8017d0:	89 c2                	mov    %eax,%edx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	eb 09                	jmp    8017e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	eb 05                	jmp    8017e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	6a 00                	push   $0x0
  8017f1:	ff 75 08             	pushl  0x8(%ebp)
  8017f4:	e8 d6 01 00 00       	call   8019cf <open>
  8017f9:	89 c3                	mov    %eax,%ebx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 1b                	js     80181d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	ff 75 0c             	pushl  0xc(%ebp)
  801808:	50                   	push   %eax
  801809:	e8 5b ff ff ff       	call   801769 <fstat>
  80180e:	89 c6                	mov    %eax,%esi
	close(fd);
  801810:	89 1c 24             	mov    %ebx,(%esp)
  801813:	e8 fd fb ff ff       	call   801415 <close>
	return r;
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	89 f0                	mov    %esi,%eax
}
  80181d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	89 c6                	mov    %eax,%esi
  80182b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80182d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801834:	75 12                	jne    801848 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	6a 01                	push   $0x1
  80183b:	e8 fc f9 ff ff       	call   80123c <ipc_find_env>
  801840:	a3 00 40 80 00       	mov    %eax,0x804000
  801845:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801848:	6a 07                	push   $0x7
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	56                   	push   %esi
  801850:	ff 35 00 40 80 00    	pushl  0x804000
  801856:	e8 8d f9 ff ff       	call   8011e8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80185b:	83 c4 0c             	add    $0xc,%esp
  80185e:	6a 00                	push   $0x0
  801860:	53                   	push   %ebx
  801861:	6a 00                	push   $0x0
  801863:	e8 e8 f8 ff ff       	call   801150 <ipc_recv>
}
  801868:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186b:	5b                   	pop    %ebx
  80186c:	5e                   	pop    %esi
  80186d:	5d                   	pop    %ebp
  80186e:	c3                   	ret    

0080186f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801880:	8b 45 0c             	mov    0xc(%ebp),%eax
  801883:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801888:	ba 00 00 00 00       	mov    $0x0,%edx
  80188d:	b8 02 00 00 00       	mov    $0x2,%eax
  801892:	e8 8d ff ff ff       	call   801824 <fsipc>
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b4:	e8 6b ff ff ff       	call   801824 <fsipc>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	53                   	push   %ebx
  8018bf:	83 ec 04             	sub    $0x4,%esp
  8018c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018da:	e8 45 ff ff ff       	call   801824 <fsipc>
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 2c                	js     80190f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	68 00 50 80 00       	push   $0x805000
  8018eb:	53                   	push   %ebx
  8018ec:	e8 20 ef ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801901:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80191d:	8b 55 08             	mov    0x8(%ebp),%edx
  801920:	8b 52 0c             	mov    0xc(%edx),%edx
  801923:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801929:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  80192e:	50                   	push   %eax
  80192f:	ff 75 0c             	pushl  0xc(%ebp)
  801932:	68 08 50 80 00       	push   $0x805008
  801937:	e8 67 f0 ff ff       	call   8009a3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80193c:	ba 00 00 00 00       	mov    $0x0,%edx
  801941:	b8 04 00 00 00       	mov    $0x4,%eax
  801946:	e8 d9 fe ff ff       	call   801824 <fsipc>
	//panic("devfile_write not implemented");
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	8b 40 0c             	mov    0xc(%eax),%eax
  80195b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801960:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801966:	ba 00 00 00 00       	mov    $0x0,%edx
  80196b:	b8 03 00 00 00       	mov    $0x3,%eax
  801970:	e8 af fe ff ff       	call   801824 <fsipc>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	85 c0                	test   %eax,%eax
  801979:	78 4b                	js     8019c6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80197b:	39 c6                	cmp    %eax,%esi
  80197d:	73 16                	jae    801995 <devfile_read+0x48>
  80197f:	68 fc 28 80 00       	push   $0x8028fc
  801984:	68 03 29 80 00       	push   $0x802903
  801989:	6a 7c                	push   $0x7c
  80198b:	68 18 29 80 00       	push   $0x802918
  801990:	e8 bd 05 00 00       	call   801f52 <_panic>
	assert(r <= PGSIZE);
  801995:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199a:	7e 16                	jle    8019b2 <devfile_read+0x65>
  80199c:	68 23 29 80 00       	push   $0x802923
  8019a1:	68 03 29 80 00       	push   $0x802903
  8019a6:	6a 7d                	push   $0x7d
  8019a8:	68 18 29 80 00       	push   $0x802918
  8019ad:	e8 a0 05 00 00       	call   801f52 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	50                   	push   %eax
  8019b6:	68 00 50 80 00       	push   $0x805000
  8019bb:	ff 75 0c             	pushl  0xc(%ebp)
  8019be:	e8 e0 ef ff ff       	call   8009a3 <memmove>
	return r;
  8019c3:	83 c4 10             	add    $0x10,%esp
}
  8019c6:	89 d8                	mov    %ebx,%eax
  8019c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5e                   	pop    %esi
  8019cd:	5d                   	pop    %ebp
  8019ce:	c3                   	ret    

008019cf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	53                   	push   %ebx
  8019d3:	83 ec 20             	sub    $0x20,%esp
  8019d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019d9:	53                   	push   %ebx
  8019da:	e8 f9 ed ff ff       	call   8007d8 <strlen>
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019e7:	7f 67                	jg     801a50 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ef:	50                   	push   %eax
  8019f0:	e8 a7 f8 ff ff       	call   80129c <fd_alloc>
  8019f5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 57                	js     801a55 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	53                   	push   %ebx
  801a02:	68 00 50 80 00       	push   $0x805000
  801a07:	e8 05 ee ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a17:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1c:	e8 03 fe ff ff       	call   801824 <fsipc>
  801a21:	89 c3                	mov    %eax,%ebx
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	79 14                	jns    801a3e <open+0x6f>
		fd_close(fd, 0);
  801a2a:	83 ec 08             	sub    $0x8,%esp
  801a2d:	6a 00                	push   $0x0
  801a2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a32:	e8 5d f9 ff ff       	call   801394 <fd_close>
		return r;
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	89 da                	mov    %ebx,%edx
  801a3c:	eb 17                	jmp    801a55 <open+0x86>
	}

	return fd2num(fd);
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	ff 75 f4             	pushl  -0xc(%ebp)
  801a44:	e8 2c f8 ff ff       	call   801275 <fd2num>
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	eb 05                	jmp    801a55 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a50:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a55:	89 d0                	mov    %edx,%eax
  801a57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6c:	e8 b3 fd ff ff       	call   801824 <fsipc>
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 08             	pushl  0x8(%ebp)
  801a81:	e8 ff f7 ff ff       	call   801285 <fd2data>
  801a86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a88:	83 c4 08             	add    $0x8,%esp
  801a8b:	68 2f 29 80 00       	push   $0x80292f
  801a90:	53                   	push   %ebx
  801a91:	e8 7b ed ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a96:	8b 46 04             	mov    0x4(%esi),%eax
  801a99:	2b 06                	sub    (%esi),%eax
  801a9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aa1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa8:	00 00 00 
	stat->st_dev = &devpipe;
  801aab:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ab2:	30 80 00 
	return 0;
}
  801ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 0c             	sub    $0xc,%esp
  801ac8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801acb:	53                   	push   %ebx
  801acc:	6a 00                	push   $0x0
  801ace:	e8 c6 f1 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ad3:	89 1c 24             	mov    %ebx,(%esp)
  801ad6:	e8 aa f7 ff ff       	call   801285 <fd2data>
  801adb:	83 c4 08             	add    $0x8,%esp
  801ade:	50                   	push   %eax
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 b3 f1 ff ff       	call   800c99 <sys_page_unmap>
}
  801ae6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	57                   	push   %edi
  801aef:	56                   	push   %esi
  801af0:	53                   	push   %ebx
  801af1:	83 ec 1c             	sub    $0x1c,%esp
  801af4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801af7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801af9:	a1 04 40 80 00       	mov    0x804004,%eax
  801afe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	ff 75 e0             	pushl  -0x20(%ebp)
  801b07:	e8 24 05 00 00       	call   802030 <pageref>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	89 3c 24             	mov    %edi,(%esp)
  801b11:	e8 1a 05 00 00       	call   802030 <pageref>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	39 c3                	cmp    %eax,%ebx
  801b1b:	0f 94 c1             	sete   %cl
  801b1e:	0f b6 c9             	movzbl %cl,%ecx
  801b21:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b24:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b2a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b2d:	39 ce                	cmp    %ecx,%esi
  801b2f:	74 1b                	je     801b4c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b31:	39 c3                	cmp    %eax,%ebx
  801b33:	75 c4                	jne    801af9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b35:	8b 42 58             	mov    0x58(%edx),%eax
  801b38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3b:	50                   	push   %eax
  801b3c:	56                   	push   %esi
  801b3d:	68 36 29 80 00       	push   $0x802936
  801b42:	e8 45 e7 ff ff       	call   80028c <cprintf>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	eb ad                	jmp    801af9 <_pipeisclosed+0xe>
	}
}
  801b4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b52:	5b                   	pop    %ebx
  801b53:	5e                   	pop    %esi
  801b54:	5f                   	pop    %edi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	57                   	push   %edi
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	83 ec 28             	sub    $0x28,%esp
  801b60:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b63:	56                   	push   %esi
  801b64:	e8 1c f7 ff ff       	call   801285 <fd2data>
  801b69:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b73:	eb 4b                	jmp    801bc0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b75:	89 da                	mov    %ebx,%edx
  801b77:	89 f0                	mov    %esi,%eax
  801b79:	e8 6d ff ff ff       	call   801aeb <_pipeisclosed>
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	75 48                	jne    801bca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b82:	e8 6e f0 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b87:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8a:	8b 0b                	mov    (%ebx),%ecx
  801b8c:	8d 51 20             	lea    0x20(%ecx),%edx
  801b8f:	39 d0                	cmp    %edx,%eax
  801b91:	73 e2                	jae    801b75 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b96:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b9a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b9d:	89 c2                	mov    %eax,%edx
  801b9f:	c1 fa 1f             	sar    $0x1f,%edx
  801ba2:	89 d1                	mov    %edx,%ecx
  801ba4:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801baa:	83 e2 1f             	and    $0x1f,%edx
  801bad:	29 ca                	sub    %ecx,%edx
  801baf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bb3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb7:	83 c0 01             	add    $0x1,%eax
  801bba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbd:	83 c7 01             	add    $0x1,%edi
  801bc0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc3:	75 c2                	jne    801b87 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc8:	eb 05                	jmp    801bcf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 18             	sub    $0x18,%esp
  801be0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801be3:	57                   	push   %edi
  801be4:	e8 9c f6 ff ff       	call   801285 <fd2data>
  801be9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf3:	eb 3d                	jmp    801c32 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bf5:	85 db                	test   %ebx,%ebx
  801bf7:	74 04                	je     801bfd <devpipe_read+0x26>
				return i;
  801bf9:	89 d8                	mov    %ebx,%eax
  801bfb:	eb 44                	jmp    801c41 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bfd:	89 f2                	mov    %esi,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	e8 e5 fe ff ff       	call   801aeb <_pipeisclosed>
  801c06:	85 c0                	test   %eax,%eax
  801c08:	75 32                	jne    801c3c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c0a:	e8 e6 ef ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c0f:	8b 06                	mov    (%esi),%eax
  801c11:	3b 46 04             	cmp    0x4(%esi),%eax
  801c14:	74 df                	je     801bf5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c16:	99                   	cltd   
  801c17:	c1 ea 1b             	shr    $0x1b,%edx
  801c1a:	01 d0                	add    %edx,%eax
  801c1c:	83 e0 1f             	and    $0x1f,%eax
  801c1f:	29 d0                	sub    %edx,%eax
  801c21:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c29:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c2c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2f:	83 c3 01             	add    $0x1,%ebx
  801c32:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c35:	75 d8                	jne    801c0f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c37:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3a:	eb 05                	jmp    801c41 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	56                   	push   %esi
  801c4d:	53                   	push   %ebx
  801c4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c54:	50                   	push   %eax
  801c55:	e8 42 f6 ff ff       	call   80129c <fd_alloc>
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	89 c2                	mov    %eax,%edx
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 2c 01 00 00    	js     801d93 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c67:	83 ec 04             	sub    $0x4,%esp
  801c6a:	68 07 04 00 00       	push   $0x407
  801c6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c72:	6a 00                	push   $0x0
  801c74:	e8 9b ef ff ff       	call   800c14 <sys_page_alloc>
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	0f 88 0d 01 00 00    	js     801d93 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8c:	50                   	push   %eax
  801c8d:	e8 0a f6 ff ff       	call   80129c <fd_alloc>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 88 e2 00 00 00    	js     801d81 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9f:	83 ec 04             	sub    $0x4,%esp
  801ca2:	68 07 04 00 00       	push   $0x407
  801ca7:	ff 75 f0             	pushl  -0x10(%ebp)
  801caa:	6a 00                	push   $0x0
  801cac:	e8 63 ef ff ff       	call   800c14 <sys_page_alloc>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	0f 88 c3 00 00 00    	js     801d81 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc4:	e8 bc f5 ff ff       	call   801285 <fd2data>
  801cc9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccb:	83 c4 0c             	add    $0xc,%esp
  801cce:	68 07 04 00 00       	push   $0x407
  801cd3:	50                   	push   %eax
  801cd4:	6a 00                	push   $0x0
  801cd6:	e8 39 ef ff ff       	call   800c14 <sys_page_alloc>
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	0f 88 89 00 00 00    	js     801d71 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cee:	e8 92 f5 ff ff       	call   801285 <fd2data>
  801cf3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cfa:	50                   	push   %eax
  801cfb:	6a 00                	push   $0x0
  801cfd:	56                   	push   %esi
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 52 ef ff ff       	call   800c57 <sys_page_map>
  801d05:	89 c3                	mov    %eax,%ebx
  801d07:	83 c4 20             	add    $0x20,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 55                	js     801d63 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d0e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d17:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d23:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d31:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d38:	83 ec 0c             	sub    $0xc,%esp
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	e8 32 f5 ff ff       	call   801275 <fd2num>
  801d43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d46:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d48:	83 c4 04             	add    $0x4,%esp
  801d4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4e:	e8 22 f5 ff ff       	call   801275 <fd2num>
  801d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d56:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d61:	eb 30                	jmp    801d93 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	56                   	push   %esi
  801d67:	6a 00                	push   $0x0
  801d69:	e8 2b ef ff ff       	call   800c99 <sys_page_unmap>
  801d6e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d71:	83 ec 08             	sub    $0x8,%esp
  801d74:	ff 75 f0             	pushl  -0x10(%ebp)
  801d77:	6a 00                	push   $0x0
  801d79:	e8 1b ef ff ff       	call   800c99 <sys_page_unmap>
  801d7e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d81:	83 ec 08             	sub    $0x8,%esp
  801d84:	ff 75 f4             	pushl  -0xc(%ebp)
  801d87:	6a 00                	push   $0x0
  801d89:	e8 0b ef ff ff       	call   800c99 <sys_page_unmap>
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d93:	89 d0                	mov    %edx,%eax
  801d95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	ff 75 08             	pushl  0x8(%ebp)
  801da9:	e8 3d f5 ff ff       	call   8012eb <fd_lookup>
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	85 c0                	test   %eax,%eax
  801db3:	78 18                	js     801dcd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801db5:	83 ec 0c             	sub    $0xc,%esp
  801db8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbb:	e8 c5 f4 ff ff       	call   801285 <fd2data>
	return _pipeisclosed(fd, p);
  801dc0:	89 c2                	mov    %eax,%edx
  801dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc5:	e8 21 fd ff ff       	call   801aeb <_pipeisclosed>
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ddf:	68 4e 29 80 00       	push   $0x80294e
  801de4:	ff 75 0c             	pushl  0xc(%ebp)
  801de7:	e8 25 ea ff ff       	call   800811 <strcpy>
	return 0;
}
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	57                   	push   %edi
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e04:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0a:	eb 2d                	jmp    801e39 <devcons_write+0x46>
		m = n - tot;
  801e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e11:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e14:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e19:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e1c:	83 ec 04             	sub    $0x4,%esp
  801e1f:	53                   	push   %ebx
  801e20:	03 45 0c             	add    0xc(%ebp),%eax
  801e23:	50                   	push   %eax
  801e24:	57                   	push   %edi
  801e25:	e8 79 eb ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  801e2a:	83 c4 08             	add    $0x8,%esp
  801e2d:	53                   	push   %ebx
  801e2e:	57                   	push   %edi
  801e2f:	e8 24 ed ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e34:	01 de                	add    %ebx,%esi
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	89 f0                	mov    %esi,%eax
  801e3b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3e:	72 cc                	jb     801e0c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5f                   	pop    %edi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e57:	74 2a                	je     801e83 <devcons_read+0x3b>
  801e59:	eb 05                	jmp    801e60 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e5b:	e8 95 ed ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e60:	e8 11 ed ff ff       	call   800b76 <sys_cgetc>
  801e65:	85 c0                	test   %eax,%eax
  801e67:	74 f2                	je     801e5b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 16                	js     801e83 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e6d:	83 f8 04             	cmp    $0x4,%eax
  801e70:	74 0c                	je     801e7e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e75:	88 02                	mov    %al,(%edx)
	return 1;
  801e77:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7c:	eb 05                	jmp    801e83 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e83:	c9                   	leave  
  801e84:	c3                   	ret    

00801e85 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e91:	6a 01                	push   $0x1
  801e93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e96:	50                   	push   %eax
  801e97:	e8 bc ec ff ff       	call   800b58 <sys_cputs>
}
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <getchar>:

int
getchar(void)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ea7:	6a 01                	push   $0x1
  801ea9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eac:	50                   	push   %eax
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 9d f6 ff ff       	call   801551 <read>
	if (r < 0)
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	78 0f                	js     801eca <getchar+0x29>
		return r;
	if (r < 1)
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	7e 06                	jle    801ec5 <getchar+0x24>
		return -E_EOF;
	return c;
  801ebf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ec3:	eb 05                	jmp    801eca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ec5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed5:	50                   	push   %eax
  801ed6:	ff 75 08             	pushl  0x8(%ebp)
  801ed9:	e8 0d f4 ff ff       	call   8012eb <fd_lookup>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	78 11                	js     801ef6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee8:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801eee:	39 10                	cmp    %edx,(%eax)
  801ef0:	0f 94 c0             	sete   %al
  801ef3:	0f b6 c0             	movzbl %al,%eax
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <opencons>:

int
opencons(void)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801efe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f01:	50                   	push   %eax
  801f02:	e8 95 f3 ff ff       	call   80129c <fd_alloc>
  801f07:	83 c4 10             	add    $0x10,%esp
		return r;
  801f0a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 3e                	js     801f4e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 04 00 00       	push   $0x407
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 f2 ec ff ff       	call   800c14 <sys_page_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
		return r;
  801f25:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 23                	js     801f4e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f2b:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f34:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f39:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	50                   	push   %eax
  801f44:	e8 2c f3 ff ff       	call   801275 <fd2num>
  801f49:	89 c2                	mov    %eax,%edx
  801f4b:	83 c4 10             	add    $0x10,%esp
}
  801f4e:	89 d0                	mov    %edx,%eax
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	56                   	push   %esi
  801f56:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f57:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f5a:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f60:	e8 71 ec ff ff       	call   800bd6 <sys_getenvid>
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	ff 75 0c             	pushl  0xc(%ebp)
  801f6b:	ff 75 08             	pushl  0x8(%ebp)
  801f6e:	56                   	push   %esi
  801f6f:	50                   	push   %eax
  801f70:	68 5c 29 80 00       	push   $0x80295c
  801f75:	e8 12 e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f7a:	83 c4 18             	add    $0x18,%esp
  801f7d:	53                   	push   %ebx
  801f7e:	ff 75 10             	pushl  0x10(%ebp)
  801f81:	e8 b5 e2 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801f86:	c7 04 24 47 29 80 00 	movl   $0x802947,(%esp)
  801f8d:	e8 fa e2 ff ff       	call   80028c <cprintf>
  801f92:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f95:	cc                   	int3   
  801f96:	eb fd                	jmp    801f95 <_panic+0x43>

00801f98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	53                   	push   %ebx
  801f9c:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f9f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa6:	75 57                	jne    801fff <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801fa8:	e8 29 ec ff ff       	call   800bd6 <sys_getenvid>
  801fad:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	6a 07                	push   $0x7
  801fb4:	68 00 f0 bf ee       	push   $0xeebff000
  801fb9:	50                   	push   %eax
  801fba:	e8 55 ec ff ff       	call   800c14 <sys_page_alloc>
		if (r) {
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	74 12                	je     801fd8 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801fc6:	50                   	push   %eax
  801fc7:	68 9a 27 80 00       	push   $0x80279a
  801fcc:	6a 25                	push   $0x25
  801fce:	68 7f 29 80 00       	push   $0x80297f
  801fd3:	e8 7a ff ff ff       	call   801f52 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801fd8:	83 ec 08             	sub    $0x8,%esp
  801fdb:	68 0c 20 80 00       	push   $0x80200c
  801fe0:	53                   	push   %ebx
  801fe1:	e8 79 ed ff ff       	call   800d5f <sys_env_set_pgfault_upcall>
		if (r) {
  801fe6:	83 c4 10             	add    $0x10,%esp
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	74 12                	je     801fff <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801fed:	50                   	push   %eax
  801fee:	68 90 29 80 00       	push   $0x802990
  801ff3:	6a 2b                	push   $0x2b
  801ff5:	68 7f 29 80 00       	push   $0x80297f
  801ffa:	e8 53 ff ff ff       	call   801f52 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fff:	8b 45 08             	mov    0x8(%ebp),%eax
  802002:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802007:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80200c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80200d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802012:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802014:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  802017:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  80201b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  802020:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  802024:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  802026:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  802029:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  80202a:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  80202d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  80202e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  80202f:	c3                   	ret    

00802030 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802036:	89 d0                	mov    %edx,%eax
  802038:	c1 e8 16             	shr    $0x16,%eax
  80203b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802047:	f6 c1 01             	test   $0x1,%cl
  80204a:	74 1d                	je     802069 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204c:	c1 ea 0c             	shr    $0xc,%edx
  80204f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802056:	f6 c2 01             	test   $0x1,%dl
  802059:	74 0e                	je     802069 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205b:	c1 ea 0c             	shr    $0xc,%edx
  80205e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802065:	ef 
  802066:	0f b7 c0             	movzwl %ax,%eax
}
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    
  80206b:	66 90                	xchg   %ax,%ax
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
