
obj/user/forktree.debug：     文件格式 elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 dc 0a 00 00       	call   800b1e <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 22 80 00       	push   $0x802260
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 9d 06 00 00       	call   800720 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 71 22 80 00       	push   $0x802271
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 61 06 00 00       	call   800706 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 9c 0d 00 00       	call   800e49 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 70 22 80 00       	push   $0x802270
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 2d 0a 00 00       	call   800b1e <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 31 11 00 00       	call   801263 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 a1 09 00 00       	call   800add <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 2f 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 54 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 d4 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 84 1d 00 00       	call   801fc0 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 71 1e 00 00       	call   8020f0 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
  8002ab:	eb 22                	jmp    8002cf <getuint+0x38>
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	74 10                	je     8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb 0e                	jmp    8002cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 89 03 00 00    	je     8006b0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	eb 07                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 07             	movzbl (%edi),%eax
  80036d:	0f b6 c8             	movzbl %al,%ecx
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 1a 03 00 00    	ja     800695 <vprintfmt+0x38a>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
  800396:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800399:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a6:	83 fa 09             	cmp    $0x9,%edx
  8003a9:	77 39                	ja     8003e4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ae:	eb e9                	jmp    800399 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c1:	eb 27                	jmp    8003ea <vprintfmt+0xdf>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cd:	0f 49 c8             	cmovns %eax,%ecx
  8003d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	eb 8c                	jmp    800364 <vprintfmt+0x59>
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e2:	eb 80                	jmp    800364 <vprintfmt+0x59>
  8003e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ee:	0f 89 70 ff ff ff    	jns    800364 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800401:	e9 5e ff ff ff       	jmp    800364 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800406:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040c:	e9 53 ff ff ff       	jmp    800364 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 30                	pushl  (%eax)
  800420:	ff d6                	call   *%esi
			break;
  800422:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800428:	e9 04 ff ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 0f             	cmp    $0xf,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x142>
  800442:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 98 22 80 00       	push   $0x802298
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	e8 94 fe ff ff       	call   8002ee <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800460:	e9 cc fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800465:	52                   	push   %edx
  800466:	68 d1 27 80 00       	push   $0x8027d1
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 7c fe ff ff       	call   8002ee <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800478:	e9 b4 fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800488:	85 ff                	test   %edi,%edi
  80048a:	b8 91 22 80 00       	mov    $0x802291,%eax
  80048f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800492:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800496:	0f 8e 94 00 00 00    	jle    800530 <vprintfmt+0x225>
  80049c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a0:	0f 84 98 00 00 00    	je     80053e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ac:	57                   	push   %edi
  8004ad:	e8 86 02 00 00       	call   800738 <strnlen>
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0f                	jmp    8004da <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ed                	jg     8004cb <vprintfmt+0x1c0>
  8004de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	0f 49 c1             	cmovns %ecx,%eax
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	89 cb                	mov    %ecx,%ebx
  8004fb:	eb 4d                	jmp    80054a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800501:	74 1b                	je     80051e <vprintfmt+0x213>
  800503:	0f be c0             	movsbl %al,%eax
  800506:	83 e8 20             	sub    $0x20,%eax
  800509:	83 f8 5e             	cmp    $0x5e,%eax
  80050c:	76 10                	jbe    80051e <vprintfmt+0x213>
					putch('?', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	6a 3f                	push   $0x3f
  800516:	ff 55 08             	call   *0x8(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 0d                	jmp    80052b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	52                   	push   %edx
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 eb 01             	sub    $0x1,%ebx
  80052e:	eb 1a                	jmp    80054a <vprintfmt+0x23f>
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053c:	eb 0c                	jmp    80054a <vprintfmt+0x23f>
  80053e:	89 75 08             	mov    %esi,0x8(%ebp)
  800541:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800547:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054a:	83 c7 01             	add    $0x1,%edi
  80054d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800551:	0f be d0             	movsbl %al,%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	74 23                	je     80057b <vprintfmt+0x270>
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 a1                	js     8004fd <vprintfmt+0x1f2>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 9c                	jns    8004fd <vprintfmt+0x1f2>
  800561:	89 df                	mov    %ebx,%edi
  800563:	8b 75 08             	mov    0x8(%ebp),%esi
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	eb 18                	jmp    800583 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	53                   	push   %ebx
  80056f:	6a 20                	push   $0x20
  800571:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800573:	83 ef 01             	sub    $0x1,%edi
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 08                	jmp    800583 <vprintfmt+0x278>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	85 ff                	test   %edi,%edi
  800585:	7f e4                	jg     80056b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058a:	e9 a2 fd ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058f:	83 fa 01             	cmp    $0x1,%edx
  800592:	7e 16                	jle    8005aa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 08             	lea    0x8(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	eb 32                	jmp    8005dc <vprintfmt+0x2d1>
	else if (lflag)
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	74 18                	je     8005c6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 c1                	mov    %eax,%ecx
  8005be:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c4:	eb 16                	jmp    8005dc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005eb:	79 74                	jns    800661 <vprintfmt+0x356>
				putch('-', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 2d                	push   $0x2d
  8005f3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fb:	f7 d8                	neg    %eax
  8005fd:	83 d2 00             	adc    $0x0,%edx
  800600:	f7 da                	neg    %edx
  800602:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800605:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060a:	eb 55                	jmp    800661 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 83 fc ff ff       	call   800297 <getuint>
			base = 10;
  800614:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800619:	eb 46                	jmp    800661 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 74 fc ff ff       	call   800297 <getuint>
			base=8;
  800623:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800628:	eb 37                	jmp    800661 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 30                	push   $0x30
  800630:	ff d6                	call   *%esi
			putch('x', putdat);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 78                	push   $0x78
  800638:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800652:	eb 0d                	jmp    800661 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 3b fc ff ff       	call   800297 <getuint>
			base = 16;
  80065c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	51                   	push   %ecx
  80066d:	52                   	push   %edx
  80066e:	50                   	push   %eax
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 70 fb ff ff       	call   8001e8 <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 ae fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	51                   	push   %ecx
  800688:	ff d6                	call   *%esi
			break;
  80068a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800690:	e9 9c fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 25                	push   $0x25
  80069b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 03                	jmp    8006a5 <vprintfmt+0x39a>
  8006a2:	83 ef 01             	sub    $0x1,%edi
  8006a5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a9:	75 f7                	jne    8006a2 <vprintfmt+0x397>
  8006ab:	e9 81 fc ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 18             	sub    $0x18,%esp
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 26                	je     8006ff <vsnprintf+0x47>
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	7e 22                	jle    8006ff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dd:	ff 75 14             	pushl  0x14(%ebp)
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	68 d1 02 80 00       	push   $0x8002d1
  8006ec:	e8 1a fc ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 05                	jmp    800704 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070f:	50                   	push   %eax
  800710:	ff 75 10             	pushl  0x10(%ebp)
  800713:	ff 75 0c             	pushl  0xc(%ebp)
  800716:	ff 75 08             	pushl  0x8(%ebp)
  800719:	e8 9a ff ff ff       	call   8006b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	eb 03                	jmp    800730 <strlen+0x10>
		n++;
  80072d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800734:	75 f7                	jne    80072d <strlen+0xd>
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 03                	jmp    80074b <strnlen+0x13>
		n++;
  800748:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	39 c2                	cmp    %eax,%edx
  80074d:	74 08                	je     800757 <strnlen+0x1f>
  80074f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800753:	75 f3                	jne    800748 <strnlen+0x10>
  800755:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800763:	89 c2                	mov    %eax,%edx
  800765:	83 c2 01             	add    $0x1,%edx
  800768:	83 c1 01             	add    $0x1,%ecx
  80076b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800772:	84 db                	test   %bl,%bl
  800774:	75 ef                	jne    800765 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800776:	5b                   	pop    %ebx
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800780:	53                   	push   %ebx
  800781:	e8 9a ff ff ff       	call   800720 <strlen>
  800786:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	01 d8                	add    %ebx,%eax
  80078e:	50                   	push   %eax
  80078f:	e8 c5 ff ff ff       	call   800759 <strcpy>
	return dst;
}
  800794:	89 d8                	mov    %ebx,%eax
  800796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	89 f3                	mov    %esi,%ebx
  8007a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	eb 0f                	jmp    8007be <strncpy+0x23>
		*dst++ = *src;
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	0f b6 01             	movzbl (%ecx),%eax
  8007b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007be:	39 da                	cmp    %ebx,%edx
  8007c0:	75 ed                	jne    8007af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 21                	je     8007fd <strlcpy+0x35>
  8007dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	eb 09                	jmp    8007ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 09                	je     8007fa <strlcpy+0x32>
  8007f1:	0f b6 19             	movzbl (%ecx),%ebx
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ec                	jne    8007e4 <strlcpy+0x1c>
  8007f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fd:	29 f0                	sub    %esi,%eax
}
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strcmp+0x11>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	84 c0                	test   %al,%al
  800819:	74 04                	je     80081f <strcmp+0x1c>
  80081b:	3a 02                	cmp    (%edx),%al
  80081d:	74 ef                	je     80080e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 c0             	movzbl %al,%eax
  800822:	0f b6 12             	movzbl (%edx),%edx
  800825:	29 d0                	sub    %edx,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 c3                	mov    %eax,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800838:	eb 06                	jmp    800840 <strncmp+0x17>
		n--, p++, q++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 15                	je     800859 <strncmp+0x30>
  800844:	0f b6 08             	movzbl (%eax),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	74 04                	je     80084f <strncmp+0x26>
  80084b:	3a 0a                	cmp    (%edx),%cl
  80084d:	74 eb                	je     80083a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	0f b6 12             	movzbl (%edx),%edx
  800855:	29 d0                	sub    %edx,%eax
  800857:	eb 05                	jmp    80085e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 07                	jmp    800874 <strchr+0x13>
		if (*s == c)
  80086d:	38 ca                	cmp    %cl,%dl
  80086f:	74 0f                	je     800880 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f2                	jne    80086d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088c:	eb 03                	jmp    800891 <strfind+0xf>
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 04                	je     80089c <strfind+0x1a>
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f2                	jne    80088e <strfind+0xc>
			break;
	return (char *) s;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 36                	je     8008e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b4:	75 28                	jne    8008de <memset+0x40>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 23                	jne    8008de <memset+0x40>
		c &= 0xFF;
  8008bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bf:	89 d3                	mov    %edx,%ebx
  8008c1:	c1 e3 08             	shl    $0x8,%ebx
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	c1 e6 18             	shl    $0x18,%esi
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	c1 e0 10             	shl    $0x10,%eax
  8008ce:	09 f0                	or     %esi,%eax
  8008d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	09 d0                	or     %edx,%eax
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	fc                   	cld    
  8008da:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dc:	eb 06                	jmp    8008e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	fc                   	cld    
  8008e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f9:	39 c6                	cmp    %eax,%esi
  8008fb:	73 35                	jae    800932 <memmove+0x47>
  8008fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800900:	39 d0                	cmp    %edx,%eax
  800902:	73 2e                	jae    800932 <memmove+0x47>
		s += n;
		d += n;
  800904:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800907:	89 d6                	mov    %edx,%esi
  800909:	09 fe                	or     %edi,%esi
  80090b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800911:	75 13                	jne    800926 <memmove+0x3b>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 0e                	jne    800926 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800918:	83 ef 04             	sub    $0x4,%edi
  80091b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	fd                   	std    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 09                	jmp    80092f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092c:	fd                   	std    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092f:	fc                   	cld    
  800930:	eb 1d                	jmp    80094f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800932:	89 f2                	mov    %esi,%edx
  800934:	09 c2                	or     %eax,%edx
  800936:	f6 c2 03             	test   $0x3,%dl
  800939:	75 0f                	jne    80094a <memmove+0x5f>
  80093b:	f6 c1 03             	test   $0x3,%cl
  80093e:	75 0a                	jne    80094a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	89 c7                	mov    %eax,%edi
  800945:	fc                   	cld    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 05                	jmp    80094f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800956:	ff 75 10             	pushl  0x10(%ebp)
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	ff 75 08             	pushl  0x8(%ebp)
  80095f:	e8 87 ff ff ff       	call   8008eb <memmove>
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	89 c6                	mov    %eax,%esi
  800973:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	eb 1a                	jmp    800992 <memcmp+0x2c>
		if (*s1 != *s2)
  800978:	0f b6 08             	movzbl (%eax),%ecx
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	38 d9                	cmp    %bl,%cl
  800980:	74 0a                	je     80098c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800982:	0f b6 c1             	movzbl %cl,%eax
  800985:	0f b6 db             	movzbl %bl,%ebx
  800988:	29 d8                	sub    %ebx,%eax
  80098a:	eb 0f                	jmp    80099b <memcmp+0x35>
		s1++, s2++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	39 f0                	cmp    %esi,%eax
  800994:	75 e2                	jne    800978 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a6:	89 c1                	mov    %eax,%ecx
  8009a8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009af:	eb 0a                	jmp    8009bb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	39 da                	cmp    %ebx,%edx
  8009b6:	74 07                	je     8009bf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	39 c8                	cmp    %ecx,%eax
  8009bd:	72 f2                	jb     8009b1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	eb 03                	jmp    8009d3 <strtol+0x11>
		s++;
  8009d0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	3c 20                	cmp    $0x20,%al
  8009d8:	74 f6                	je     8009d0 <strtol+0xe>
  8009da:	3c 09                	cmp    $0x9,%al
  8009dc:	74 f2                	je     8009d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009de:	3c 2b                	cmp    $0x2b,%al
  8009e0:	75 0a                	jne    8009ec <strtol+0x2a>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ea:	eb 11                	jmp    8009fd <strtol+0x3b>
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f1:	3c 2d                	cmp    $0x2d,%al
  8009f3:	75 08                	jne    8009fd <strtol+0x3b>
		s++, neg = 1;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 15                	jne    800a1a <strtol+0x58>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	75 10                	jne    800a1a <strtol+0x58>
  800a0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0e:	75 7c                	jne    800a8c <strtol+0xca>
		s += 2, base = 16;
  800a10:	83 c1 02             	add    $0x2,%ecx
  800a13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a18:	eb 16                	jmp    800a30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	75 12                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 08                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a38:	0f b6 11             	movzbl (%ecx),%edx
  800a3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	80 fb 09             	cmp    $0x9,%bl
  800a43:	77 08                	ja     800a4d <strtol+0x8b>
			dig = *s - '0';
  800a45:	0f be d2             	movsbl %dl,%edx
  800a48:	83 ea 30             	sub    $0x30,%edx
  800a4b:	eb 22                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 19             	cmp    $0x19,%bl
  800a55:	77 08                	ja     800a5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a57:	0f be d2             	movsbl %dl,%edx
  800a5a:	83 ea 57             	sub    $0x57,%edx
  800a5d:	eb 10                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 19             	cmp    $0x19,%bl
  800a67:	77 16                	ja     800a7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a72:	7d 0b                	jge    800a7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7d:	eb b9                	jmp    800a38 <strtol+0x76>

	if (endptr)
  800a7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a83:	74 0d                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	89 0e                	mov    %ecx,(%esi)
  800a8a:	eb 06                	jmp    800a92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 98                	je     800a28 <strtol+0x66>
  800a90:	eb 9e                	jmp    800a30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 03                	push   $0x3
  800b05:	68 7f 25 80 00       	push   $0x80257f
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 9c 25 80 00       	push   $0x80259c
  800b11:	e8 5f 12 00 00       	call   801d75 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 04                	push   $0x4
  800b86:	68 7f 25 80 00       	push   $0x80257f
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 9c 25 80 00       	push   $0x80259c
  800b92:	e8 de 11 00 00       	call   801d75 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 05                	push   $0x5
  800bc8:	68 7f 25 80 00       	push   $0x80257f
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 9c 25 80 00       	push   $0x80259c
  800bd4:	e8 9c 11 00 00       	call   801d75 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 06                	push   $0x6
  800c0a:	68 7f 25 80 00       	push   $0x80257f
  800c0f:	6a 23                	push   $0x23
  800c11:	68 9c 25 80 00       	push   $0x80259c
  800c16:	e8 5a 11 00 00       	call   801d75 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 08 00 00 00       	mov    $0x8,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 08                	push   $0x8
  800c4c:	68 7f 25 80 00       	push   $0x80257f
  800c51:	6a 23                	push   $0x23
  800c53:	68 9c 25 80 00       	push   $0x80259c
  800c58:	e8 18 11 00 00       	call   801d75 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 09 00 00 00       	mov    $0x9,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 09                	push   $0x9
  800c8e:	68 7f 25 80 00       	push   $0x80257f
  800c93:	6a 23                	push   $0x23
  800c95:	68 9c 25 80 00       	push   $0x80259c
  800c9a:	e8 d6 10 00 00       	call   801d75 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 0a                	push   $0xa
  800cd0:	68 7f 25 80 00       	push   $0x80257f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 9c 25 80 00       	push   $0x80259c
  800cdc:	e8 94 10 00 00       	call   801d75 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0d                	push   $0xd
  800d34:	68 7f 25 80 00       	push   $0x80257f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 9c 25 80 00       	push   $0x80259c
  800d40:	e8 30 10 00 00       	call   801d75 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d55:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  800d57:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d5b:	75 14                	jne    800d71 <pgfault+0x24>
		panic("Not a page fault caused by write!");
  800d5d:	83 ec 04             	sub    $0x4,%esp
  800d60:	68 ac 25 80 00       	push   $0x8025ac
  800d65:	6a 23                	push   $0x23
  800d67:	68 6f 26 80 00       	push   $0x80266f
  800d6c:	e8 04 10 00 00       	call   801d75 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  800d71:	89 d8                	mov    %ebx,%eax
  800d73:	c1 e8 0c             	shr    $0xc,%eax
  800d76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d7d:	f6 c4 08             	test   $0x8,%ah
  800d80:	75 14                	jne    800d96 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	68 d0 25 80 00       	push   $0x8025d0
  800d8a:	6a 2d                	push   $0x2d
  800d8c:	68 6f 26 80 00       	push   $0x80266f
  800d91:	e8 df 0f 00 00       	call   801d75 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  800d96:	e8 83 fd ff ff       	call   800b1e <sys_getenvid>
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	6a 07                	push   $0x7
  800da0:	68 00 f0 7f 00       	push   $0x7ff000
  800da5:	50                   	push   %eax
  800da6:	e8 b1 fd ff ff       	call   800b5c <sys_page_alloc>
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	85 c0                	test   %eax,%eax
  800db0:	79 12                	jns    800dc4 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  800db2:	50                   	push   %eax
  800db3:	68 7a 26 80 00       	push   $0x80267a
  800db8:	6a 3b                	push   $0x3b
  800dba:	68 6f 26 80 00       	push   $0x80266f
  800dbf:	e8 b1 0f 00 00       	call   801d75 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  800dc4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 00 10 00 00       	push   $0x1000
  800dd2:	53                   	push   %ebx
  800dd3:	68 00 f0 7f 00       	push   $0x7ff000
  800dd8:	e8 0e fb ff ff       	call   8008eb <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  800ddd:	e8 3c fd ff ff       	call   800b1e <sys_getenvid>
  800de2:	89 c6                	mov    %eax,%esi
  800de4:	e8 35 fd ff ff       	call   800b1e <sys_getenvid>
  800de9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df0:	53                   	push   %ebx
  800df1:	56                   	push   %esi
  800df2:	68 00 f0 7f 00       	push   $0x7ff000
  800df7:	50                   	push   %eax
  800df8:	e8 a2 fd ff ff       	call   800b9f <sys_page_map>
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	79 12                	jns    800e16 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  800e04:	50                   	push   %eax
  800e05:	68 93 26 80 00       	push   $0x802693
  800e0a:	6a 48                	push   $0x48
  800e0c:	68 6f 26 80 00       	push   $0x80266f
  800e11:	e8 5f 0f 00 00       	call   801d75 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  800e16:	e8 03 fd ff ff       	call   800b1e <sys_getenvid>
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	68 00 f0 7f 00       	push   $0x7ff000
  800e23:	50                   	push   %eax
  800e24:	e8 b8 fd ff ff       	call   800be1 <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	79 12                	jns    800e42 <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  800e30:	50                   	push   %eax
  800e31:	68 aa 26 80 00       	push   $0x8026aa
  800e36:	6a 4c                	push   $0x4c
  800e38:	68 6f 26 80 00       	push   $0x80266f
  800e3d:	e8 33 0f 00 00       	call   801d75 <_panic>
	}

	//panic("pgfault not implemented");
}
  800e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  800e52:	68 4d 0d 80 00       	push   $0x800d4d
  800e57:	e8 5f 0f 00 00       	call   801dbb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e5c:	b8 07 00 00 00       	mov    $0x7,%eax
  800e61:	cd 30                	int    $0x30
  800e63:	89 c7                	mov    %eax,%edi
  800e65:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	79 15                	jns    800e84 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  800e6f:	50                   	push   %eax
  800e70:	68 c3 26 80 00       	push   $0x8026c3
  800e75:	68 a1 00 00 00       	push   $0xa1
  800e7a:	68 6f 26 80 00       	push   $0x80266f
  800e7f:	e8 f1 0e 00 00       	call   801d75 <_panic>
  800e84:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	75 21                	jne    800eae <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  800e8d:	e8 8c fc ff ff       	call   800b1e <sys_getenvid>
  800e92:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e97:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e9a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e9f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	e9 c8 01 00 00       	jmp    801076 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800eae:	89 d8                	mov    %ebx,%eax
  800eb0:	c1 e8 16             	shr    $0x16,%eax
  800eb3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eba:	a8 01                	test   $0x1,%al
  800ebc:	0f 84 23 01 00 00    	je     800fe5 <fork+0x19c>
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	c1 e8 0c             	shr    $0xc,%eax
  800ec7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ece:	f6 c2 01             	test   $0x1,%dl
  800ed1:	0f 84 0e 01 00 00    	je     800fe5 <fork+0x19c>
  800ed7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ede:	f6 c2 04             	test   $0x4,%dl
  800ee1:	0f 84 fe 00 00 00    	je     800fe5 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  800ee7:	89 c6                	mov    %eax,%esi
  800ee9:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  800eec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef3:	f6 c6 04             	test   $0x4,%dh
  800ef6:	74 3f                	je     800f37 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  800ef8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	25 07 0e 00 00       	and    $0xe07,%eax
  800f07:	50                   	push   %eax
  800f08:	56                   	push   %esi
  800f09:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f0c:	56                   	push   %esi
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 8b fc ff ff       	call   800b9f <sys_page_map>
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	0f 89 c6 00 00 00    	jns    800fe5 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	50                   	push   %eax
  800f23:	57                   	push   %edi
  800f24:	6a 00                	push   $0x0
  800f26:	68 00 26 80 00       	push   $0x802600
  800f2b:	6a 6c                	push   $0x6c
  800f2d:	68 6f 26 80 00       	push   $0x80266f
  800f32:	e8 3e 0e 00 00       	call   801d75 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f37:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3e:	f6 c2 02             	test   $0x2,%dl
  800f41:	75 0c                	jne    800f4f <fork+0x106>
  800f43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4a:	f6 c4 08             	test   $0x8,%ah
  800f4d:	74 66                	je     800fb5 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	68 05 08 00 00       	push   $0x805
  800f57:	56                   	push   %esi
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	56                   	push   %esi
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 3c fc ff ff       	call   800b9f <sys_page_map>
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	79 18                	jns    800f82 <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	50                   	push   %eax
  800f6e:	57                   	push   %edi
  800f6f:	6a 00                	push   $0x0
  800f71:	68 00 26 80 00       	push   $0x802600
  800f76:	6a 74                	push   $0x74
  800f78:	68 6f 26 80 00       	push   $0x80266f
  800f7d:	e8 f3 0d 00 00       	call   801d75 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	68 05 08 00 00       	push   $0x805
  800f8a:	56                   	push   %esi
  800f8b:	6a 00                	push   $0x0
  800f8d:	56                   	push   %esi
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 0a fc ff ff       	call   800b9f <sys_page_map>
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	79 49                	jns    800fe5 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	50                   	push   %eax
  800fa0:	6a 00                	push   $0x0
  800fa2:	6a 00                	push   $0x0
  800fa4:	68 00 26 80 00       	push   $0x802600
  800fa9:	6a 77                	push   $0x77
  800fab:	68 6f 26 80 00       	push   $0x80266f
  800fb0:	e8 c0 0d 00 00       	call   801d75 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	6a 05                	push   $0x5
  800fba:	56                   	push   %esi
  800fbb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fbe:	56                   	push   %esi
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 d9 fb ff ff       	call   800b9f <sys_page_map>
  800fc6:	83 c4 20             	add    $0x20,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	79 18                	jns    800fe5 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	50                   	push   %eax
  800fd1:	57                   	push   %edi
  800fd2:	6a 00                	push   $0x0
  800fd4:	68 00 26 80 00       	push   $0x802600
  800fd9:	6a 7d                	push   $0x7d
  800fdb:	68 6f 26 80 00       	push   $0x80266f
  800fe0:	e8 90 0d 00 00       	call   801d75 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800fe5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800feb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ff1:	0f 85 b7 fe ff ff    	jne    800eae <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	6a 07                	push   $0x7
  800ffc:	68 00 f0 bf ee       	push   $0xeebff000
  801001:	57                   	push   %edi
  801002:	e8 55 fb ff ff       	call   800b5c <sys_page_alloc>
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 15                	jns    801023 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  80100e:	50                   	push   %eax
  80100f:	68 2c 26 80 00       	push   $0x80262c
  801014:	68 b4 00 00 00       	push   $0xb4
  801019:	68 6f 26 80 00       	push   $0x80266f
  80101e:	e8 52 0d 00 00       	call   801d75 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	68 2f 1e 80 00       	push   $0x801e2f
  80102b:	57                   	push   %edi
  80102c:	e8 76 fc ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	79 15                	jns    80104d <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801038:	50                   	push   %eax
  801039:	68 d9 26 80 00       	push   $0x8026d9
  80103e:	68 ba 00 00 00       	push   $0xba
  801043:	68 6f 26 80 00       	push   $0x80266f
  801048:	e8 28 0d 00 00       	call   801d75 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	6a 02                	push   $0x2
  801052:	57                   	push   %edi
  801053:	e8 cb fb ff ff       	call   800c23 <sys_env_set_status>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	79 15                	jns    801074 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  80105f:	50                   	push   %eax
  801060:	68 f6 26 80 00       	push   $0x8026f6
  801065:	68 bf 00 00 00       	push   $0xbf
  80106a:	68 6f 26 80 00       	push   $0x80266f
  80106f:	e8 01 0d 00 00       	call   801d75 <_panic>
	}
	return eid;
  801074:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sfork>:

// Challenge!
int
sfork(void)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801084:	68 13 27 80 00       	push   $0x802713
  801089:	68 ca 00 00 00       	push   $0xca
  80108e:	68 6f 26 80 00       	push   $0x80266f
  801093:	e8 dd 0c 00 00       	call   801d75 <_panic>

00801098 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 16             	shr    $0x16,%edx
  8010cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 11                	je     8010ec <fd_alloc+0x2d>
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 0c             	shr    $0xc,%edx
  8010e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	75 09                	jne    8010f5 <fd_alloc+0x36>
			*fd_store = fd;
  8010ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f3:	eb 17                	jmp    80110c <fd_alloc+0x4d>
  8010f5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ff:	75 c9                	jne    8010ca <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801101:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801107:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801114:	83 f8 1f             	cmp    $0x1f,%eax
  801117:	77 36                	ja     80114f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801119:	c1 e0 0c             	shl    $0xc,%eax
  80111c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 16             	shr    $0x16,%edx
  801126:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 24                	je     801156 <fd_lookup+0x48>
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 0c             	shr    $0xc,%edx
  801137:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	74 1a                	je     80115d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	89 02                	mov    %eax,(%edx)
	return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	eb 13                	jmp    801162 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801154:	eb 0c                	jmp    801162 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801156:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115b:	eb 05                	jmp    801162 <fd_lookup+0x54>
  80115d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116d:	ba a8 27 80 00       	mov    $0x8027a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801172:	eb 13                	jmp    801187 <dev_lookup+0x23>
  801174:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801177:	39 08                	cmp    %ecx,(%eax)
  801179:	75 0c                	jne    801187 <dev_lookup+0x23>
			*dev = devtab[i];
  80117b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801180:	b8 00 00 00 00       	mov    $0x0,%eax
  801185:	eb 2e                	jmp    8011b5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801187:	8b 02                	mov    (%edx),%eax
  801189:	85 c0                	test   %eax,%eax
  80118b:	75 e7                	jne    801174 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80118d:	a1 04 40 80 00       	mov    0x804004,%eax
  801192:	8b 40 48             	mov    0x48(%eax),%eax
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	51                   	push   %ecx
  801199:	50                   	push   %eax
  80119a:	68 2c 27 80 00       	push   $0x80272c
  80119f:	e8 30 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8011a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 10             	sub    $0x10,%esp
  8011bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011cf:	c1 e8 0c             	shr    $0xc,%eax
  8011d2:	50                   	push   %eax
  8011d3:	e8 36 ff ff ff       	call   80110e <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 05                	js     8011e4 <fd_close+0x2d>
	    || fd != fd2)
  8011df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011e2:	74 0c                	je     8011f0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011e4:	84 db                	test   %bl,%bl
  8011e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011eb:	0f 44 c2             	cmove  %edx,%eax
  8011ee:	eb 41                	jmp    801231 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	ff 36                	pushl  (%esi)
  8011f9:	e8 66 ff ff ff       	call   801164 <dev_lookup>
  8011fe:	89 c3                	mov    %eax,%ebx
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 1a                	js     801221 <fd_close+0x6a>
		if (dev->dev_close)
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80120d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801212:	85 c0                	test   %eax,%eax
  801214:	74 0b                	je     801221 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	56                   	push   %esi
  80121a:	ff d0                	call   *%eax
  80121c:	89 c3                	mov    %eax,%ebx
  80121e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	56                   	push   %esi
  801225:	6a 00                	push   $0x0
  801227:	e8 b5 f9 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	89 d8                	mov    %ebx,%eax
}
  801231:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	ff 75 08             	pushl  0x8(%ebp)
  801245:	e8 c4 fe ff ff       	call   80110e <fd_lookup>
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 10                	js     801261 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	6a 01                	push   $0x1
  801256:	ff 75 f4             	pushl  -0xc(%ebp)
  801259:	e8 59 ff ff ff       	call   8011b7 <fd_close>
  80125e:	83 c4 10             	add    $0x10,%esp
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <close_all>:

void
close_all(void)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	53                   	push   %ebx
  801267:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	53                   	push   %ebx
  801273:	e8 c0 ff ff ff       	call   801238 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801278:	83 c3 01             	add    $0x1,%ebx
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	83 fb 20             	cmp    $0x20,%ebx
  801281:	75 ec                	jne    80126f <close_all+0xc>
		close(i);
}
  801283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 2c             	sub    $0x2c,%esp
  801291:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801294:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 75 08             	pushl  0x8(%ebp)
  80129b:	e8 6e fe ff ff       	call   80110e <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	0f 88 c1 00 00 00    	js     80136c <dup+0xe4>
		return r;
	close(newfdnum);
  8012ab:	83 ec 0c             	sub    $0xc,%esp
  8012ae:	56                   	push   %esi
  8012af:	e8 84 ff ff ff       	call   801238 <close>

	newfd = INDEX2FD(newfdnum);
  8012b4:	89 f3                	mov    %esi,%ebx
  8012b6:	c1 e3 0c             	shl    $0xc,%ebx
  8012b9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012bf:	83 c4 04             	add    $0x4,%esp
  8012c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c5:	e8 de fd ff ff       	call   8010a8 <fd2data>
  8012ca:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012cc:	89 1c 24             	mov    %ebx,(%esp)
  8012cf:	e8 d4 fd ff ff       	call   8010a8 <fd2data>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012da:	89 f8                	mov    %edi,%eax
  8012dc:	c1 e8 16             	shr    $0x16,%eax
  8012df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e6:	a8 01                	test   $0x1,%al
  8012e8:	74 37                	je     801321 <dup+0x99>
  8012ea:	89 f8                	mov    %edi,%eax
  8012ec:	c1 e8 0c             	shr    $0xc,%eax
  8012ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 26                	je     801321 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	25 07 0e 00 00       	and    $0xe07,%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80130e:	6a 00                	push   $0x0
  801310:	57                   	push   %edi
  801311:	6a 00                	push   $0x0
  801313:	e8 87 f8 ff ff       	call   800b9f <sys_page_map>
  801318:	89 c7                	mov    %eax,%edi
  80131a:	83 c4 20             	add    $0x20,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 2e                	js     80134f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801321:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801324:	89 d0                	mov    %edx,%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
  801329:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	25 07 0e 00 00       	and    $0xe07,%eax
  801338:	50                   	push   %eax
  801339:	53                   	push   %ebx
  80133a:	6a 00                	push   $0x0
  80133c:	52                   	push   %edx
  80133d:	6a 00                	push   $0x0
  80133f:	e8 5b f8 ff ff       	call   800b9f <sys_page_map>
  801344:	89 c7                	mov    %eax,%edi
  801346:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801349:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134b:	85 ff                	test   %edi,%edi
  80134d:	79 1d                	jns    80136c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	53                   	push   %ebx
  801353:	6a 00                	push   $0x0
  801355:	e8 87 f8 ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801360:	6a 00                	push   $0x0
  801362:	e8 7a f8 ff ff       	call   800be1 <sys_page_unmap>
	return r;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 f8                	mov    %edi,%eax
}
  80136c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 14             	sub    $0x14,%esp
  80137b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801381:	50                   	push   %eax
  801382:	53                   	push   %ebx
  801383:	e8 86 fd ff ff       	call   80110e <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 6d                	js     8013fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139b:	ff 30                	pushl  (%eax)
  80139d:	e8 c2 fd ff ff       	call   801164 <dev_lookup>
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 4c                	js     8013f5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ac:	8b 42 08             	mov    0x8(%edx),%eax
  8013af:	83 e0 03             	and    $0x3,%eax
  8013b2:	83 f8 01             	cmp    $0x1,%eax
  8013b5:	75 21                	jne    8013d8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013bc:	8b 40 48             	mov    0x48(%eax),%eax
  8013bf:	83 ec 04             	sub    $0x4,%esp
  8013c2:	53                   	push   %ebx
  8013c3:	50                   	push   %eax
  8013c4:	68 6d 27 80 00       	push   $0x80276d
  8013c9:	e8 06 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d6:	eb 26                	jmp    8013fe <read+0x8a>
	}
	if (!dev->dev_read)
  8013d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013db:	8b 40 08             	mov    0x8(%eax),%eax
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	74 17                	je     8013f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e2:	83 ec 04             	sub    $0x4,%esp
  8013e5:	ff 75 10             	pushl  0x10(%ebp)
  8013e8:	ff 75 0c             	pushl  0xc(%ebp)
  8013eb:	52                   	push   %edx
  8013ec:	ff d0                	call   *%eax
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	eb 09                	jmp    8013fe <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	eb 05                	jmp    8013fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013fe:	89 d0                	mov    %edx,%eax
  801400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	57                   	push   %edi
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
  80140b:	83 ec 0c             	sub    $0xc,%esp
  80140e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801411:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801414:	bb 00 00 00 00       	mov    $0x0,%ebx
  801419:	eb 21                	jmp    80143c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	89 f0                	mov    %esi,%eax
  801420:	29 d8                	sub    %ebx,%eax
  801422:	50                   	push   %eax
  801423:	89 d8                	mov    %ebx,%eax
  801425:	03 45 0c             	add    0xc(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	57                   	push   %edi
  80142a:	e8 45 ff ff ff       	call   801374 <read>
		if (m < 0)
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 10                	js     801446 <readn+0x41>
			return m;
		if (m == 0)
  801436:	85 c0                	test   %eax,%eax
  801438:	74 0a                	je     801444 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143a:	01 c3                	add    %eax,%ebx
  80143c:	39 f3                	cmp    %esi,%ebx
  80143e:	72 db                	jb     80141b <readn+0x16>
  801440:	89 d8                	mov    %ebx,%eax
  801442:	eb 02                	jmp    801446 <readn+0x41>
  801444:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	53                   	push   %ebx
  801452:	83 ec 14             	sub    $0x14,%esp
  801455:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801458:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	53                   	push   %ebx
  80145d:	e8 ac fc ff ff       	call   80110e <fd_lookup>
  801462:	83 c4 08             	add    $0x8,%esp
  801465:	89 c2                	mov    %eax,%edx
  801467:	85 c0                	test   %eax,%eax
  801469:	78 68                	js     8014d3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801475:	ff 30                	pushl  (%eax)
  801477:	e8 e8 fc ff ff       	call   801164 <dev_lookup>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 47                	js     8014ca <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148a:	75 21                	jne    8014ad <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80148c:	a1 04 40 80 00       	mov    0x804004,%eax
  801491:	8b 40 48             	mov    0x48(%eax),%eax
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	53                   	push   %ebx
  801498:	50                   	push   %eax
  801499:	68 89 27 80 00       	push   $0x802789
  80149e:	e8 31 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ab:	eb 26                	jmp    8014d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b3:	85 d2                	test   %edx,%edx
  8014b5:	74 17                	je     8014ce <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	ff 75 10             	pushl  0x10(%ebp)
  8014bd:	ff 75 0c             	pushl  0xc(%ebp)
  8014c0:	50                   	push   %eax
  8014c1:	ff d2                	call   *%edx
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb 09                	jmp    8014d3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	eb 05                	jmp    8014d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <seek>:

int
seek(int fdnum, off_t offset)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	ff 75 08             	pushl  0x8(%ebp)
  8014e7:	e8 22 fc ff ff       	call   80110e <fd_lookup>
  8014ec:	83 c4 08             	add    $0x8,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 0e                	js     801501 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 14             	sub    $0x14,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	53                   	push   %ebx
  801512:	e8 f7 fb ff ff       	call   80110e <fd_lookup>
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 65                	js     801585 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 33 fc ff ff       	call   801164 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 44                	js     80157c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	75 21                	jne    801562 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801541:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	53                   	push   %ebx
  80154d:	50                   	push   %eax
  80154e:	68 4c 27 80 00       	push   $0x80274c
  801553:	e8 7c ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801560:	eb 23                	jmp    801585 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 18             	mov    0x18(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 14                	je     801580 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	ff 75 0c             	pushl  0xc(%ebp)
  801572:	50                   	push   %eax
  801573:	ff d2                	call   *%edx
  801575:	89 c2                	mov    %eax,%edx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	eb 09                	jmp    801585 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	eb 05                	jmp    801585 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801580:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801585:	89 d0                	mov    %edx,%eax
  801587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 14             	sub    $0x14,%esp
  801593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	ff 75 08             	pushl  0x8(%ebp)
  80159d:	e8 6c fb ff ff       	call   80110e <fd_lookup>
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 58                	js     801603 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	ff 30                	pushl  (%eax)
  8015b7:	e8 a8 fb ff ff       	call   801164 <dev_lookup>
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 37                	js     8015fa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ca:	74 32                	je     8015fe <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d6:	00 00 00 
	stat->st_isdir = 0;
  8015d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e0:	00 00 00 
	stat->st_dev = dev;
  8015e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f0:	ff 50 14             	call   *0x14(%eax)
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	eb 09                	jmp    801603 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	eb 05                	jmp    801603 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801603:	89 d0                	mov    %edx,%eax
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	6a 00                	push   $0x0
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 d6 01 00 00       	call   8017f2 <open>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 1b                	js     801640 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	50                   	push   %eax
  80162c:	e8 5b ff ff ff       	call   80158c <fstat>
  801631:	89 c6                	mov    %eax,%esi
	close(fd);
  801633:	89 1c 24             	mov    %ebx,(%esp)
  801636:	e8 fd fb ff ff       	call   801238 <close>
	return r;
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	89 f0                	mov    %esi,%eax
}
  801640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	89 c6                	mov    %eax,%esi
  80164e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801650:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801657:	75 12                	jne    80166b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	6a 01                	push   $0x1
  80165e:	e8 dc 08 00 00       	call   801f3f <ipc_find_env>
  801663:	a3 00 40 80 00       	mov    %eax,0x804000
  801668:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166b:	6a 07                	push   $0x7
  80166d:	68 00 50 80 00       	push   $0x805000
  801672:	56                   	push   %esi
  801673:	ff 35 00 40 80 00    	pushl  0x804000
  801679:	e8 6d 08 00 00       	call   801eeb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80167e:	83 c4 0c             	add    $0xc,%esp
  801681:	6a 00                	push   $0x0
  801683:	53                   	push   %ebx
  801684:	6a 00                	push   $0x0
  801686:	e8 c8 07 00 00       	call   801e53 <ipc_recv>
}
  80168b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	8b 40 0c             	mov    0xc(%eax),%eax
  80169e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b5:	e8 8d ff ff ff       	call   801647 <fsipc>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d7:	e8 6b ff ff ff       	call   801647 <fsipc>
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 04             	sub    $0x4,%esp
  8016e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016fd:	e8 45 ff ff ff       	call   801647 <fsipc>
  801702:	85 c0                	test   %eax,%eax
  801704:	78 2c                	js     801732 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	68 00 50 80 00       	push   $0x805000
  80170e:	53                   	push   %ebx
  80170f:	e8 45 f0 ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801714:	a1 80 50 80 00       	mov    0x805080,%eax
  801719:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80171f:	a1 84 50 80 00       	mov    0x805084,%eax
  801724:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801740:	8b 55 08             	mov    0x8(%ebp),%edx
  801743:	8b 52 0c             	mov    0xc(%edx),%edx
  801746:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80174c:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801751:	50                   	push   %eax
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	68 08 50 80 00       	push   $0x805008
  80175a:	e8 8c f1 ff ff       	call   8008eb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80175f:	ba 00 00 00 00       	mov    $0x0,%edx
  801764:	b8 04 00 00 00       	mov    $0x4,%eax
  801769:	e8 d9 fe ff ff       	call   801647 <fsipc>
	//panic("devfile_write not implemented");
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 40 0c             	mov    0xc(%eax),%eax
  80177e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801783:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 03 00 00 00       	mov    $0x3,%eax
  801793:	e8 af fe ff ff       	call   801647 <fsipc>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 4b                	js     8017e9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80179e:	39 c6                	cmp    %eax,%esi
  8017a0:	73 16                	jae    8017b8 <devfile_read+0x48>
  8017a2:	68 b8 27 80 00       	push   $0x8027b8
  8017a7:	68 bf 27 80 00       	push   $0x8027bf
  8017ac:	6a 7c                	push   $0x7c
  8017ae:	68 d4 27 80 00       	push   $0x8027d4
  8017b3:	e8 bd 05 00 00       	call   801d75 <_panic>
	assert(r <= PGSIZE);
  8017b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017bd:	7e 16                	jle    8017d5 <devfile_read+0x65>
  8017bf:	68 df 27 80 00       	push   $0x8027df
  8017c4:	68 bf 27 80 00       	push   $0x8027bf
  8017c9:	6a 7d                	push   $0x7d
  8017cb:	68 d4 27 80 00       	push   $0x8027d4
  8017d0:	e8 a0 05 00 00       	call   801d75 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	50                   	push   %eax
  8017d9:	68 00 50 80 00       	push   $0x805000
  8017de:	ff 75 0c             	pushl  0xc(%ebp)
  8017e1:	e8 05 f1 ff ff       	call   8008eb <memmove>
	return r;
  8017e6:	83 c4 10             	add    $0x10,%esp
}
  8017e9:	89 d8                	mov    %ebx,%eax
  8017eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 20             	sub    $0x20,%esp
  8017f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017fc:	53                   	push   %ebx
  8017fd:	e8 1e ef ff ff       	call   800720 <strlen>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80180a:	7f 67                	jg     801873 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801812:	50                   	push   %eax
  801813:	e8 a7 f8 ff ff       	call   8010bf <fd_alloc>
  801818:	83 c4 10             	add    $0x10,%esp
		return r;
  80181b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 57                	js     801878 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	53                   	push   %ebx
  801825:	68 00 50 80 00       	push   $0x805000
  80182a:	e8 2a ef ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80182f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801832:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801837:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183a:	b8 01 00 00 00       	mov    $0x1,%eax
  80183f:	e8 03 fe ff ff       	call   801647 <fsipc>
  801844:	89 c3                	mov    %eax,%ebx
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	79 14                	jns    801861 <open+0x6f>
		fd_close(fd, 0);
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	6a 00                	push   $0x0
  801852:	ff 75 f4             	pushl  -0xc(%ebp)
  801855:	e8 5d f9 ff ff       	call   8011b7 <fd_close>
		return r;
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	89 da                	mov    %ebx,%edx
  80185f:	eb 17                	jmp    801878 <open+0x86>
	}

	return fd2num(fd);
  801861:	83 ec 0c             	sub    $0xc,%esp
  801864:	ff 75 f4             	pushl  -0xc(%ebp)
  801867:	e8 2c f8 ff ff       	call   801098 <fd2num>
  80186c:	89 c2                	mov    %eax,%edx
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	eb 05                	jmp    801878 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801873:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801878:	89 d0                	mov    %edx,%eax
  80187a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 08 00 00 00       	mov    $0x8,%eax
  80188f:	e8 b3 fd ff ff       	call   801647 <fsipc>
}
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	ff 75 08             	pushl  0x8(%ebp)
  8018a4:	e8 ff f7 ff ff       	call   8010a8 <fd2data>
  8018a9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018ab:	83 c4 08             	add    $0x8,%esp
  8018ae:	68 eb 27 80 00       	push   $0x8027eb
  8018b3:	53                   	push   %ebx
  8018b4:	e8 a0 ee ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018b9:	8b 46 04             	mov    0x4(%esi),%eax
  8018bc:	2b 06                	sub    (%esi),%eax
  8018be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018cb:	00 00 00 
	stat->st_dev = &devpipe;
  8018ce:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018d5:	30 80 00 
	return 0;
}
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018ee:	53                   	push   %ebx
  8018ef:	6a 00                	push   $0x0
  8018f1:	e8 eb f2 ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018f6:	89 1c 24             	mov    %ebx,(%esp)
  8018f9:	e8 aa f7 ff ff       	call   8010a8 <fd2data>
  8018fe:	83 c4 08             	add    $0x8,%esp
  801901:	50                   	push   %eax
  801902:	6a 00                	push   $0x0
  801904:	e8 d8 f2 ff ff       	call   800be1 <sys_page_unmap>
}
  801909:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	83 ec 1c             	sub    $0x1c,%esp
  801917:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80191a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80191c:	a1 04 40 80 00       	mov    0x804004,%eax
  801921:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 e0             	pushl  -0x20(%ebp)
  80192a:	e8 49 06 00 00       	call   801f78 <pageref>
  80192f:	89 c3                	mov    %eax,%ebx
  801931:	89 3c 24             	mov    %edi,(%esp)
  801934:	e8 3f 06 00 00       	call   801f78 <pageref>
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	39 c3                	cmp    %eax,%ebx
  80193e:	0f 94 c1             	sete   %cl
  801941:	0f b6 c9             	movzbl %cl,%ecx
  801944:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801947:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80194d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801950:	39 ce                	cmp    %ecx,%esi
  801952:	74 1b                	je     80196f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801954:	39 c3                	cmp    %eax,%ebx
  801956:	75 c4                	jne    80191c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801958:	8b 42 58             	mov    0x58(%edx),%eax
  80195b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80195e:	50                   	push   %eax
  80195f:	56                   	push   %esi
  801960:	68 f2 27 80 00       	push   $0x8027f2
  801965:	e8 6a e8 ff ff       	call   8001d4 <cprintf>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb ad                	jmp    80191c <_pipeisclosed+0xe>
	}
}
  80196f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5f                   	pop    %edi
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	57                   	push   %edi
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	83 ec 28             	sub    $0x28,%esp
  801983:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801986:	56                   	push   %esi
  801987:	e8 1c f7 ff ff       	call   8010a8 <fd2data>
  80198c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	bf 00 00 00 00       	mov    $0x0,%edi
  801996:	eb 4b                	jmp    8019e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801998:	89 da                	mov    %ebx,%edx
  80199a:	89 f0                	mov    %esi,%eax
  80199c:	e8 6d ff ff ff       	call   80190e <_pipeisclosed>
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	75 48                	jne    8019ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019a5:	e8 93 f1 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ad:	8b 0b                	mov    (%ebx),%ecx
  8019af:	8d 51 20             	lea    0x20(%ecx),%edx
  8019b2:	39 d0                	cmp    %edx,%eax
  8019b4:	73 e2                	jae    801998 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	c1 fa 1f             	sar    $0x1f,%edx
  8019c5:	89 d1                	mov    %edx,%ecx
  8019c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8019ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019cd:	83 e2 1f             	and    $0x1f,%edx
  8019d0:	29 ca                	sub    %ecx,%edx
  8019d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019da:	83 c0 01             	add    $0x1,%eax
  8019dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e0:	83 c7 01             	add    $0x1,%edi
  8019e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019e6:	75 c2                	jne    8019aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019eb:	eb 05                	jmp    8019f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	57                   	push   %edi
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 18             	sub    $0x18,%esp
  801a03:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a06:	57                   	push   %edi
  801a07:	e8 9c f6 ff ff       	call   8010a8 <fd2data>
  801a0c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a16:	eb 3d                	jmp    801a55 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a18:	85 db                	test   %ebx,%ebx
  801a1a:	74 04                	je     801a20 <devpipe_read+0x26>
				return i;
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	eb 44                	jmp    801a64 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a20:	89 f2                	mov    %esi,%edx
  801a22:	89 f8                	mov    %edi,%eax
  801a24:	e8 e5 fe ff ff       	call   80190e <_pipeisclosed>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	75 32                	jne    801a5f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a2d:	e8 0b f1 ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a32:	8b 06                	mov    (%esi),%eax
  801a34:	3b 46 04             	cmp    0x4(%esi),%eax
  801a37:	74 df                	je     801a18 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a39:	99                   	cltd   
  801a3a:	c1 ea 1b             	shr    $0x1b,%edx
  801a3d:	01 d0                	add    %edx,%eax
  801a3f:	83 e0 1f             	and    $0x1f,%eax
  801a42:	29 d0                	sub    %edx,%eax
  801a44:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a4f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a52:	83 c3 01             	add    $0x1,%ebx
  801a55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a58:	75 d8                	jne    801a32 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5d:	eb 05                	jmp    801a64 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	e8 42 f6 ff ff       	call   8010bf <fd_alloc>
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	89 c2                	mov    %eax,%edx
  801a82:	85 c0                	test   %eax,%eax
  801a84:	0f 88 2c 01 00 00    	js     801bb6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8a:	83 ec 04             	sub    $0x4,%esp
  801a8d:	68 07 04 00 00       	push   $0x407
  801a92:	ff 75 f4             	pushl  -0xc(%ebp)
  801a95:	6a 00                	push   $0x0
  801a97:	e8 c0 f0 ff ff       	call   800b5c <sys_page_alloc>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	89 c2                	mov    %eax,%edx
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	0f 88 0d 01 00 00    	js     801bb6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	e8 0a f6 ff ff       	call   8010bf <fd_alloc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	0f 88 e2 00 00 00    	js     801ba4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	68 07 04 00 00       	push   $0x407
  801aca:	ff 75 f0             	pushl  -0x10(%ebp)
  801acd:	6a 00                	push   $0x0
  801acf:	e8 88 f0 ff ff       	call   800b5c <sys_page_alloc>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	0f 88 c3 00 00 00    	js     801ba4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	e8 bc f5 ff ff       	call   8010a8 <fd2data>
  801aec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aee:	83 c4 0c             	add    $0xc,%esp
  801af1:	68 07 04 00 00       	push   $0x407
  801af6:	50                   	push   %eax
  801af7:	6a 00                	push   $0x0
  801af9:	e8 5e f0 ff ff       	call   800b5c <sys_page_alloc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 89 00 00 00    	js     801b94 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b11:	e8 92 f5 ff ff       	call   8010a8 <fd2data>
  801b16:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b1d:	50                   	push   %eax
  801b1e:	6a 00                	push   $0x0
  801b20:	56                   	push   %esi
  801b21:	6a 00                	push   $0x0
  801b23:	e8 77 f0 ff ff       	call   800b9f <sys_page_map>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	83 c4 20             	add    $0x20,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 55                	js     801b86 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b46:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b54:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b61:	e8 32 f5 ff ff       	call   801098 <fd2num>
  801b66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b69:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b6b:	83 c4 04             	add    $0x4,%esp
  801b6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b71:	e8 22 f5 ff ff       	call   801098 <fd2num>
  801b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b79:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b84:	eb 30                	jmp    801bb6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	56                   	push   %esi
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 50 f0 ff ff       	call   800be1 <sys_page_unmap>
  801b91:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b94:	83 ec 08             	sub    $0x8,%esp
  801b97:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 40 f0 ff ff       	call   800be1 <sys_page_unmap>
  801ba1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ba4:	83 ec 08             	sub    $0x8,%esp
  801ba7:	ff 75 f4             	pushl  -0xc(%ebp)
  801baa:	6a 00                	push   $0x0
  801bac:	e8 30 f0 ff ff       	call   800be1 <sys_page_unmap>
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bb6:	89 d0                	mov    %edx,%eax
  801bb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc8:	50                   	push   %eax
  801bc9:	ff 75 08             	pushl  0x8(%ebp)
  801bcc:	e8 3d f5 ff ff       	call   80110e <fd_lookup>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 18                	js     801bf0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bde:	e8 c5 f4 ff ff       	call   8010a8 <fd2data>
	return _pipeisclosed(fd, p);
  801be3:	89 c2                	mov    %eax,%edx
  801be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be8:	e8 21 fd ff ff       	call   80190e <_pipeisclosed>
  801bed:	83 c4 10             	add    $0x10,%esp
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c02:	68 0a 28 80 00       	push   $0x80280a
  801c07:	ff 75 0c             	pushl  0xc(%ebp)
  801c0a:	e8 4a eb ff ff       	call   800759 <strcpy>
	return 0;
}
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	57                   	push   %edi
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c2d:	eb 2d                	jmp    801c5c <devcons_write+0x46>
		m = n - tot;
  801c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	53                   	push   %ebx
  801c43:	03 45 0c             	add    0xc(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	57                   	push   %edi
  801c48:	e8 9e ec ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  801c4d:	83 c4 08             	add    $0x8,%esp
  801c50:	53                   	push   %ebx
  801c51:	57                   	push   %edi
  801c52:	e8 49 ee ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c57:	01 de                	add    %ebx,%esi
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	89 f0                	mov    %esi,%eax
  801c5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c61:	72 cc                	jb     801c2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5f                   	pop    %edi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c7a:	74 2a                	je     801ca6 <devcons_read+0x3b>
  801c7c:	eb 05                	jmp    801c83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c7e:	e8 ba ee ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c83:	e8 36 ee ff ff       	call   800abe <sys_cgetc>
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	74 f2                	je     801c7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 16                	js     801ca6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c90:	83 f8 04             	cmp    $0x4,%eax
  801c93:	74 0c                	je     801ca1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c98:	88 02                	mov    %al,(%edx)
	return 1;
  801c9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9f:	eb 05                	jmp    801ca6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cb4:	6a 01                	push   $0x1
  801cb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cb9:	50                   	push   %eax
  801cba:	e8 e1 ed ff ff       	call   800aa0 <sys_cputs>
}
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <getchar>:

int
getchar(void)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cca:	6a 01                	push   $0x1
  801ccc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 9d f6 ff ff       	call   801374 <read>
	if (r < 0)
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 0f                	js     801ced <getchar+0x29>
		return r;
	if (r < 1)
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	7e 06                	jle    801ce8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ce2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ce6:	eb 05                	jmp    801ced <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ce8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf8:	50                   	push   %eax
  801cf9:	ff 75 08             	pushl  0x8(%ebp)
  801cfc:	e8 0d f4 ff ff       	call   80110e <fd_lookup>
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 11                	js     801d19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d11:	39 10                	cmp    %edx,(%eax)
  801d13:	0f 94 c0             	sete   %al
  801d16:	0f b6 c0             	movzbl %al,%eax
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <opencons>:

int
opencons(void)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	e8 95 f3 ff ff       	call   8010bf <fd_alloc>
  801d2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 3e                	js     801d71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	68 07 04 00 00       	push   $0x407
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 17 ee ff ff       	call   800b5c <sys_page_alloc>
  801d45:	83 c4 10             	add    $0x10,%esp
		return r;
  801d48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 23                	js     801d71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	50                   	push   %eax
  801d67:	e8 2c f3 ff ff       	call   801098 <fd2num>
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	83 c4 10             	add    $0x10,%esp
}
  801d71:	89 d0                	mov    %edx,%eax
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d7a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d7d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d83:	e8 96 ed ff ff       	call   800b1e <sys_getenvid>
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	ff 75 0c             	pushl  0xc(%ebp)
  801d8e:	ff 75 08             	pushl  0x8(%ebp)
  801d91:	56                   	push   %esi
  801d92:	50                   	push   %eax
  801d93:	68 18 28 80 00       	push   $0x802818
  801d98:	e8 37 e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d9d:	83 c4 18             	add    $0x18,%esp
  801da0:	53                   	push   %ebx
  801da1:	ff 75 10             	pushl  0x10(%ebp)
  801da4:	e8 da e3 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801da9:	c7 04 24 6f 22 80 00 	movl   $0x80226f,(%esp)
  801db0:	e8 1f e4 ff ff       	call   8001d4 <cprintf>
  801db5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801db8:	cc                   	int3   
  801db9:	eb fd                	jmp    801db8 <_panic+0x43>

00801dbb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dc2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc9:	75 57                	jne    801e22 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801dcb:	e8 4e ed ff ff       	call   800b1e <sys_getenvid>
  801dd0:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  801dd2:	83 ec 04             	sub    $0x4,%esp
  801dd5:	6a 07                	push   $0x7
  801dd7:	68 00 f0 bf ee       	push   $0xeebff000
  801ddc:	50                   	push   %eax
  801ddd:	e8 7a ed ff ff       	call   800b5c <sys_page_alloc>
		if (r) {
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	74 12                	je     801dfb <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801de9:	50                   	push   %eax
  801dea:	68 7a 26 80 00       	push   $0x80267a
  801def:	6a 25                	push   $0x25
  801df1:	68 3b 28 80 00       	push   $0x80283b
  801df6:	e8 7a ff ff ff       	call   801d75 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801dfb:	83 ec 08             	sub    $0x8,%esp
  801dfe:	68 2f 1e 80 00       	push   $0x801e2f
  801e03:	53                   	push   %ebx
  801e04:	e8 9e ee ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r) {
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	74 12                	je     801e22 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801e10:	50                   	push   %eax
  801e11:	68 4c 28 80 00       	push   $0x80284c
  801e16:	6a 2b                	push   $0x2b
  801e18:	68 3b 28 80 00       	push   $0x80283b
  801e1d:	e8 53 ff ff ff       	call   801d75 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e2f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e30:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e35:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e37:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  801e3a:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  801e3e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  801e43:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  801e47:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  801e49:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  801e4c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  801e4d:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  801e50:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  801e51:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  801e52:	c3                   	ret    

00801e53 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	8b 75 08             	mov    0x8(%ebp),%esi
  801e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801e61:	85 c0                	test   %eax,%eax
  801e63:	74 3e                	je     801ea3 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	50                   	push   %eax
  801e69:	e8 9e ee ff ff       	call   800d0c <sys_ipc_recv>
  801e6e:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 f6                	test   %esi,%esi
  801e75:	74 13                	je     801e8a <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801e77:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7c:	85 d2                	test   %edx,%edx
  801e7e:	75 08                	jne    801e88 <ipc_recv+0x35>
  801e80:	a1 04 40 80 00       	mov    0x804004,%eax
  801e85:	8b 40 74             	mov    0x74(%eax),%eax
  801e88:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801e8a:	85 db                	test   %ebx,%ebx
  801e8c:	74 48                	je     801ed6 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e93:	85 d2                	test   %edx,%edx
  801e95:	75 08                	jne    801e9f <ipc_recv+0x4c>
  801e97:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9c:	8b 40 78             	mov    0x78(%eax),%eax
  801e9f:	89 03                	mov    %eax,(%ebx)
  801ea1:	eb 33                	jmp    801ed6 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801ea3:	83 ec 0c             	sub    $0xc,%esp
  801ea6:	68 00 00 c0 ee       	push   $0xeec00000
  801eab:	e8 5c ee ff ff       	call   800d0c <sys_ipc_recv>
  801eb0:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801eb2:	83 c4 10             	add    $0x10,%esp
  801eb5:	85 f6                	test   %esi,%esi
  801eb7:	74 13                	je     801ecc <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebe:	85 d2                	test   %edx,%edx
  801ec0:	75 08                	jne    801eca <ipc_recv+0x77>
  801ec2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec7:	8b 40 74             	mov    0x74(%eax),%eax
  801eca:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801ecc:	85 db                	test   %ebx,%ebx
  801ece:	74 06                	je     801ed6 <ipc_recv+0x83>
			*perm_store = 0;
  801ed0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801ed6:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801ed8:	85 d2                	test   %edx,%edx
  801eda:	75 08                	jne    801ee4 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801edc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee1:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	57                   	push   %edi
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801efa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801efd:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f04:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f07:	eb 1c                	jmp    801f25 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801f09:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0c:	74 12                	je     801f20 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801f0e:	50                   	push   %eax
  801f0f:	68 74 28 80 00       	push   $0x802874
  801f14:	6a 4f                	push   $0x4f
  801f16:	68 8f 28 80 00       	push   $0x80288f
  801f1b:	e8 55 fe ff ff       	call   801d75 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801f20:	e8 18 ec ff ff       	call   800b3d <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f25:	ff 75 14             	pushl  0x14(%ebp)
  801f28:	53                   	push   %ebx
  801f29:	56                   	push   %esi
  801f2a:	57                   	push   %edi
  801f2b:	e8 b9 ed ff ff       	call   800ce9 <sys_ipc_try_send>
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 d2                	js     801f09 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5f                   	pop    %edi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    

00801f3f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f4a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f4d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f53:	8b 52 50             	mov    0x50(%edx),%edx
  801f56:	39 ca                	cmp    %ecx,%edx
  801f58:	75 0d                	jne    801f67 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f5a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f5d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f62:	8b 40 48             	mov    0x48(%eax),%eax
  801f65:	eb 0f                	jmp    801f76 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f67:	83 c0 01             	add    $0x1,%eax
  801f6a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6f:	75 d9                	jne    801f4a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7e:	89 d0                	mov    %edx,%eax
  801f80:	c1 e8 16             	shr    $0x16,%eax
  801f83:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8f:	f6 c1 01             	test   $0x1,%cl
  801f92:	74 1d                	je     801fb1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f94:	c1 ea 0c             	shr    $0xc,%edx
  801f97:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9e:	f6 c2 01             	test   $0x1,%dl
  801fa1:	74 0e                	je     801fb1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa3:	c1 ea 0c             	shr    $0xc,%edx
  801fa6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fad:	ef 
  801fae:	0f b7 c0             	movzwl %ax,%eax
}
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    
  801fb3:	66 90                	xchg   %ax,%ax
  801fb5:	66 90                	xchg   %ax,%ax
  801fb7:	66 90                	xchg   %ax,%ax
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
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
