
obj/user/faultallocbad.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 e0 1e 80 00       	push   $0x801ee0
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 18 0b 00 00       	call   800b76 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 00 1f 80 00       	push   $0x801f00
  80006f:	6a 0f                	push   $0xf
  800071:	68 ea 1e 80 00       	push   $0x801eea
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 2c 1f 80 00       	push   $0x801f2c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 97 06 00 00       	call   800720 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 c6 0c 00 00       	call   800d67 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 0a 0a 00 00       	call   800aba <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 73 0a 00 00       	call   800b38 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 c4 0e 00 00       	call   800fca <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 e7 09 00 00       	call   800af7 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 10 0a 00 00       	call   800b38 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 58 1f 80 00       	push   $0x801f58
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 2f 09 00 00       	call   800aba <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 d4 08 00 00       	call   800aba <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 ea 19 00 00       	call   801c40 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 d7 1a 00 00       	call   801d70 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 89 03 00 00    	je     8006ca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 1a 03 00 00    	ja     8006af <vprintfmt+0x38a>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 93 1f 80 00       	push   $0x801f93
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 a5 23 80 00       	push   $0x8023a5
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 86 02 00 00       	call   800752 <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	79 74                	jns    80067b <vprintfmt+0x356>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800624:	eb 55                	jmp    80067b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 83 fc ff ff       	call   8002b1 <getuint>
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800633:	eb 46                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 74 fc ff ff       	call   8002b1 <getuint>
			base=8;
  80063d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800642:	eb 37                	jmp    80067b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800664:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800667:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066c:	eb 0d                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 3b fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800676:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067b:	83 ec 0c             	sub    $0xc,%esp
  80067e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800682:	57                   	push   %edi
  800683:	ff 75 e0             	pushl  -0x20(%ebp)
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	50                   	push   %eax
  800689:	89 da                	mov    %ebx,%edx
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	e8 70 fb ff ff       	call   800202 <printnum>
			break;
  800692:	83 c4 20             	add    $0x20,%esp
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 ae fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	51                   	push   %ecx
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006aa:	e9 9c fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x39a>
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x397>
  8006c5:	e9 81 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 18             	sub    $0x18,%esp
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 26                	je     800719 <vsnprintf+0x47>
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e 22                	jle    800719 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f7:	ff 75 14             	pushl  0x14(%ebp)
  8006fa:	ff 75 10             	pushl  0x10(%ebp)
  8006fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	68 eb 02 80 00       	push   $0x8002eb
  800706:	e8 1a fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 05                	jmp    80071e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 9a ff ff ff       	call   8006d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	eb 03                	jmp    80074a <strlen+0x10>
		n++;
  800747:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f7                	jne    800747 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
  800760:	eb 03                	jmp    800765 <strnlen+0x13>
		n++;
  800762:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	39 c2                	cmp    %eax,%edx
  800767:	74 08                	je     800771 <strnlen+0x1f>
  800769:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076d:	75 f3                	jne    800762 <strnlen+0x10>
  80076f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	83 c2 01             	add    $0x1,%edx
  800782:	83 c1 01             	add    $0x1,%ecx
  800785:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 ef                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 9a ff ff ff       	call   80073a <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 c5 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d8:	39 da                	cmp    %ebx,%edx
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 21                	je     800817 <strlcpy+0x35>
  8007f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 09                	jmp    800807 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 09                	je     800814 <strlcpy+0x32>
  80080b:	0f b6 19             	movzbl (%ecx),%ebx
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1c>
  800812:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800814:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800817:	29 f0                	sub    %esi,%eax
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800826:	eb 06                	jmp    80082e <strcmp+0x11>
		p++, q++;
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x1c>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 ef                	je     800828 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 06                	jmp    80085a <strncmp+0x17>
		n--, p++, q++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 15                	je     800873 <strncmp+0x30>
  80085e:	0f b6 08             	movzbl (%eax),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 04                	je     800869 <strncmp+0x26>
  800865:	3a 0a                	cmp    (%edx),%cl
  800867:	74 eb                	je     800854 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
  800871:	eb 05                	jmp    800878 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800885:	eb 07                	jmp    80088e <strchr+0x13>
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 0f                	je     80089a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f2                	jne    800887 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 03                	jmp    8008ab <strfind+0xf>
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 04                	je     8008b6 <strfind+0x1a>
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 36                	je     8008fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ce:	75 28                	jne    8008f8 <memset+0x40>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 23                	jne    8008f8 <memset+0x40>
		c &= 0xFF;
  8008d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 18             	shl    $0x18,%esi
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	c1 e0 10             	shl    $0x10,%eax
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 06                	jmp    8008fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fe:	89 f8                	mov    %edi,%eax
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 35                	jae    80094c <memmove+0x47>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 2e                	jae    80094c <memmove+0x47>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x3b>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 09                	jmp    800949 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	83 ef 01             	sub    $0x1,%edi
  800943:	8d 72 ff             	lea    -0x1(%edx),%esi
  800946:	fd                   	std    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800949:	fc                   	cld    
  80094a:	eb 1d                	jmp    800969 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 f2                	mov    %esi,%edx
  80094e:	09 c2                	or     %eax,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 0f                	jne    800964 <memmove+0x5f>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0a                	jne    800964 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 05                	jmp    800969 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 87 ff ff ff       	call   800905 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	eb 1a                	jmp    8009ac <memcmp+0x2c>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	74 0a                	je     8009a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 c1             	movzbl %cl,%eax
  80099f:	0f b6 db             	movzbl %bl,%ebx
  8009a2:	29 d8                	sub    %ebx,%eax
  8009a4:	eb 0f                	jmp    8009b5 <memcmp+0x35>
		s1++, s2++;
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	75 e2                	jne    800992 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c0:	89 c1                	mov    %eax,%ecx
  8009c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	eb 0a                	jmp    8009d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	39 da                	cmp    %ebx,%edx
  8009d0:	74 07                	je     8009d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	39 c8                	cmp    %ecx,%eax
  8009d7:	72 f2                	jb     8009cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 03                	jmp    8009ed <strtol+0x11>
		s++;
  8009ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f6                	je     8009ea <strtol+0xe>
  8009f4:	3c 09                	cmp    $0x9,%al
  8009f6:	74 f2                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f8:	3c 2b                	cmp    $0x2b,%al
  8009fa:	75 0a                	jne    800a06 <strtol+0x2a>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb 11                	jmp    800a17 <strtol+0x3b>
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0b:	3c 2d                	cmp    $0x2d,%al
  800a0d:	75 08                	jne    800a17 <strtol+0x3b>
		s++, neg = 1;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 15                	jne    800a34 <strtol+0x58>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 10                	jne    800a34 <strtol+0x58>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	75 7c                	jne    800aa6 <strtol+0xca>
		s += 2, base = 16;
  800a2a:	83 c1 02             	add    $0x2,%ecx
  800a2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a32:	eb 16                	jmp    800a4a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	75 12                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 08                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	80 fb 09             	cmp    $0x9,%bl
  800a5d:	77 08                	ja     800a67 <strtol+0x8b>
			dig = *s - '0';
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 30             	sub    $0x30,%edx
  800a65:	eb 22                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 19             	cmp    $0x19,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 57             	sub    $0x57,%edx
  800a77:	eb 10                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 16                	ja     800a99 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8c:	7d 0b                	jge    800a99 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a97:	eb b9                	jmp    800a52 <strtol+0x76>

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 0d                	je     800aac <strtol+0xd0>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 0e                	mov    %ecx,(%esi)
  800aa4:	eb 06                	jmp    800aac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 98                	je     800a42 <strtol+0x66>
  800aaa:	eb 9e                	jmp    800a4a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	f7 da                	neg    %edx
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c2             	cmovne %edx,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b05:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 cb                	mov    %ecx,%ebx
  800b0f:	89 cf                	mov    %ecx,%edi
  800b11:	89 ce                	mov    %ecx,%esi
  800b13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 7f 22 80 00       	push   $0x80227f
  800b24:	6a 23                	push   $0x23
  800b26:	68 9c 22 80 00       	push   $0x80229c
  800b2b:	e8 e5 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_yield>:

void
sys_yield(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	be 00 00 00 00       	mov    $0x0,%esi
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 7f 22 80 00       	push   $0x80227f
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 9c 22 80 00       	push   $0x80229c
  800bac:	e8 64 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 7f 22 80 00       	push   $0x80227f
  800be7:	6a 23                	push   $0x23
  800be9:	68 9c 22 80 00       	push   $0x80229c
  800bee:	e8 22 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 7f 22 80 00       	push   $0x80227f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 9c 22 80 00       	push   $0x80229c
  800c30:	e8 e0 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 7f 22 80 00       	push   $0x80227f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 9c 22 80 00       	push   $0x80229c
  800c72:	e8 9e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 7f 22 80 00       	push   $0x80227f
  800cad:	6a 23                	push   $0x23
  800caf:	68 9c 22 80 00       	push   $0x80229c
  800cb4:	e8 5c f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 0a                	push   $0xa
  800cea:	68 7f 22 80 00       	push   $0x80227f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 9c 22 80 00       	push   $0x80229c
  800cf6:	e8 1a f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0d                	push   $0xd
  800d4e:	68 7f 22 80 00       	push   $0x80227f
  800d53:	6a 23                	push   $0x23
  800d55:	68 9c 22 80 00       	push   $0x80229c
  800d5a:	e8 b6 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d6e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d75:	75 57                	jne    800dce <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  800d77:	e8 bc fd ff ff       	call   800b38 <sys_getenvid>
  800d7c:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	6a 07                	push   $0x7
  800d83:	68 00 f0 bf ee       	push   $0xeebff000
  800d88:	50                   	push   %eax
  800d89:	e8 e8 fd ff ff       	call   800b76 <sys_page_alloc>
		if (r) {
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	85 c0                	test   %eax,%eax
  800d93:	74 12                	je     800da7 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  800d95:	50                   	push   %eax
  800d96:	68 aa 22 80 00       	push   $0x8022aa
  800d9b:	6a 25                	push   $0x25
  800d9d:	68 c3 22 80 00       	push   $0x8022c3
  800da2:	e8 6e f3 ff ff       	call   800115 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  800da7:	83 ec 08             	sub    $0x8,%esp
  800daa:	68 db 0d 80 00       	push   $0x800ddb
  800daf:	53                   	push   %ebx
  800db0:	e8 0c ff ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
		if (r) {
  800db5:	83 c4 10             	add    $0x10,%esp
  800db8:	85 c0                	test   %eax,%eax
  800dba:	74 12                	je     800dce <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  800dbc:	50                   	push   %eax
  800dbd:	68 d4 22 80 00       	push   $0x8022d4
  800dc2:	6a 2b                	push   $0x2b
  800dc4:	68 c3 22 80 00       	push   $0x8022c3
  800dc9:	e8 47 f3 ff ff       	call   800115 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ddb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ddc:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800de1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de3:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  800de6:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  800dea:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  800def:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  800df3:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  800df5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  800df8:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  800df9:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  800dfc:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  800dfd:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  800dfe:	c3                   	ret    

00800dff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0a:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	c1 ea 16             	shr    $0x16,%edx
  800e36:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3d:	f6 c2 01             	test   $0x1,%dl
  800e40:	74 11                	je     800e53 <fd_alloc+0x2d>
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	c1 ea 0c             	shr    $0xc,%edx
  800e47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4e:	f6 c2 01             	test   $0x1,%dl
  800e51:	75 09                	jne    800e5c <fd_alloc+0x36>
			*fd_store = fd;
  800e53:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	eb 17                	jmp    800e73 <fd_alloc+0x4d>
  800e5c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e61:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e66:	75 c9                	jne    800e31 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e68:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e6e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e7b:	83 f8 1f             	cmp    $0x1f,%eax
  800e7e:	77 36                	ja     800eb6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e80:	c1 e0 0c             	shl    $0xc,%eax
  800e83:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e88:	89 c2                	mov    %eax,%edx
  800e8a:	c1 ea 16             	shr    $0x16,%edx
  800e8d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e94:	f6 c2 01             	test   $0x1,%dl
  800e97:	74 24                	je     800ebd <fd_lookup+0x48>
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	c1 ea 0c             	shr    $0xc,%edx
  800e9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea5:	f6 c2 01             	test   $0x1,%dl
  800ea8:	74 1a                	je     800ec4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ead:	89 02                	mov    %eax,(%edx)
	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	eb 13                	jmp    800ec9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebb:	eb 0c                	jmp    800ec9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec2:	eb 05                	jmp    800ec9 <fd_lookup+0x54>
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed4:	ba 7c 23 80 00       	mov    $0x80237c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed9:	eb 13                	jmp    800eee <dev_lookup+0x23>
  800edb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ede:	39 08                	cmp    %ecx,(%eax)
  800ee0:	75 0c                	jne    800eee <dev_lookup+0x23>
			*dev = devtab[i];
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eec:	eb 2e                	jmp    800f1c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eee:	8b 02                	mov    (%edx),%eax
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	75 e7                	jne    800edb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef4:	a1 04 40 80 00       	mov    0x804004,%eax
  800ef9:	8b 40 48             	mov    0x48(%eax),%eax
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	51                   	push   %ecx
  800f00:	50                   	push   %eax
  800f01:	68 fc 22 80 00       	push   $0x8022fc
  800f06:	e8 e3 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	83 ec 10             	sub    $0x10,%esp
  800f26:	8b 75 08             	mov    0x8(%ebp),%esi
  800f29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2f:	50                   	push   %eax
  800f30:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f36:	c1 e8 0c             	shr    $0xc,%eax
  800f39:	50                   	push   %eax
  800f3a:	e8 36 ff ff ff       	call   800e75 <fd_lookup>
  800f3f:	83 c4 08             	add    $0x8,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 05                	js     800f4b <fd_close+0x2d>
	    || fd != fd2)
  800f46:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f49:	74 0c                	je     800f57 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f4b:	84 db                	test   %bl,%bl
  800f4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f52:	0f 44 c2             	cmove  %edx,%eax
  800f55:	eb 41                	jmp    800f98 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f57:	83 ec 08             	sub    $0x8,%esp
  800f5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f5d:	50                   	push   %eax
  800f5e:	ff 36                	pushl  (%esi)
  800f60:	e8 66 ff ff ff       	call   800ecb <dev_lookup>
  800f65:	89 c3                	mov    %eax,%ebx
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 1a                	js     800f88 <fd_close+0x6a>
		if (dev->dev_close)
  800f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f71:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	74 0b                	je     800f88 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	56                   	push   %esi
  800f81:	ff d0                	call   *%eax
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 68 fc ff ff       	call   800bfb <sys_page_unmap>
	return r;
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	89 d8                	mov    %ebx,%eax
}
  800f98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    

00800f9f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 08             	pushl  0x8(%ebp)
  800fac:	e8 c4 fe ff ff       	call   800e75 <fd_lookup>
  800fb1:	83 c4 08             	add    $0x8,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 10                	js     800fc8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	6a 01                	push   $0x1
  800fbd:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc0:	e8 59 ff ff ff       	call   800f1e <fd_close>
  800fc5:	83 c4 10             	add    $0x10,%esp
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <close_all>:

void
close_all(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	53                   	push   %ebx
  800fda:	e8 c0 ff ff ff       	call   800f9f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdf:	83 c3 01             	add    $0x1,%ebx
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	83 fb 20             	cmp    $0x20,%ebx
  800fe8:	75 ec                	jne    800fd6 <close_all+0xc>
		close(i);
}
  800fea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	57                   	push   %edi
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 2c             	sub    $0x2c,%esp
  800ff8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ffb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	ff 75 08             	pushl  0x8(%ebp)
  801002:	e8 6e fe ff ff       	call   800e75 <fd_lookup>
  801007:	83 c4 08             	add    $0x8,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	0f 88 c1 00 00 00    	js     8010d3 <dup+0xe4>
		return r;
	close(newfdnum);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	56                   	push   %esi
  801016:	e8 84 ff ff ff       	call   800f9f <close>

	newfd = INDEX2FD(newfdnum);
  80101b:	89 f3                	mov    %esi,%ebx
  80101d:	c1 e3 0c             	shl    $0xc,%ebx
  801020:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801026:	83 c4 04             	add    $0x4,%esp
  801029:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102c:	e8 de fd ff ff       	call   800e0f <fd2data>
  801031:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801033:	89 1c 24             	mov    %ebx,(%esp)
  801036:	e8 d4 fd ff ff       	call   800e0f <fd2data>
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801041:	89 f8                	mov    %edi,%eax
  801043:	c1 e8 16             	shr    $0x16,%eax
  801046:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104d:	a8 01                	test   $0x1,%al
  80104f:	74 37                	je     801088 <dup+0x99>
  801051:	89 f8                	mov    %edi,%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
  801056:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105d:	f6 c2 01             	test   $0x1,%dl
  801060:	74 26                	je     801088 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	25 07 0e 00 00       	and    $0xe07,%eax
  801071:	50                   	push   %eax
  801072:	ff 75 d4             	pushl  -0x2c(%ebp)
  801075:	6a 00                	push   $0x0
  801077:	57                   	push   %edi
  801078:	6a 00                	push   $0x0
  80107a:	e8 3a fb ff ff       	call   800bb9 <sys_page_map>
  80107f:	89 c7                	mov    %eax,%edi
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 2e                	js     8010b6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801088:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	c1 e8 0c             	shr    $0xc,%eax
  801090:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	25 07 0e 00 00       	and    $0xe07,%eax
  80109f:	50                   	push   %eax
  8010a0:	53                   	push   %ebx
  8010a1:	6a 00                	push   $0x0
  8010a3:	52                   	push   %edx
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 0e fb ff ff       	call   800bb9 <sys_page_map>
  8010ab:	89 c7                	mov    %eax,%edi
  8010ad:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b2:	85 ff                	test   %edi,%edi
  8010b4:	79 1d                	jns    8010d3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	53                   	push   %ebx
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 3a fb ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c7:	6a 00                	push   $0x0
  8010c9:	e8 2d fb ff ff       	call   800bfb <sys_page_unmap>
	return r;
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	89 f8                	mov    %edi,%eax
}
  8010d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	53                   	push   %ebx
  8010df:	83 ec 14             	sub    $0x14,%esp
  8010e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	53                   	push   %ebx
  8010ea:	e8 86 fd ff ff       	call   800e75 <fd_lookup>
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 6d                	js     801165 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	ff 30                	pushl  (%eax)
  801104:	e8 c2 fd ff ff       	call   800ecb <dev_lookup>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 4c                	js     80115c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801110:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801113:	8b 42 08             	mov    0x8(%edx),%eax
  801116:	83 e0 03             	and    $0x3,%eax
  801119:	83 f8 01             	cmp    $0x1,%eax
  80111c:	75 21                	jne    80113f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111e:	a1 04 40 80 00       	mov    0x804004,%eax
  801123:	8b 40 48             	mov    0x48(%eax),%eax
  801126:	83 ec 04             	sub    $0x4,%esp
  801129:	53                   	push   %ebx
  80112a:	50                   	push   %eax
  80112b:	68 40 23 80 00       	push   $0x802340
  801130:	e8 b9 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113d:	eb 26                	jmp    801165 <read+0x8a>
	}
	if (!dev->dev_read)
  80113f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801142:	8b 40 08             	mov    0x8(%eax),%eax
  801145:	85 c0                	test   %eax,%eax
  801147:	74 17                	je     801160 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	ff 75 10             	pushl  0x10(%ebp)
  80114f:	ff 75 0c             	pushl  0xc(%ebp)
  801152:	52                   	push   %edx
  801153:	ff d0                	call   *%eax
  801155:	89 c2                	mov    %eax,%edx
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	eb 09                	jmp    801165 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	eb 05                	jmp    801165 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801160:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801165:	89 d0                	mov    %edx,%eax
  801167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	8b 7d 08             	mov    0x8(%ebp),%edi
  801178:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801180:	eb 21                	jmp    8011a3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	89 f0                	mov    %esi,%eax
  801187:	29 d8                	sub    %ebx,%eax
  801189:	50                   	push   %eax
  80118a:	89 d8                	mov    %ebx,%eax
  80118c:	03 45 0c             	add    0xc(%ebp),%eax
  80118f:	50                   	push   %eax
  801190:	57                   	push   %edi
  801191:	e8 45 ff ff ff       	call   8010db <read>
		if (m < 0)
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 10                	js     8011ad <readn+0x41>
			return m;
		if (m == 0)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	74 0a                	je     8011ab <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a1:	01 c3                	add    %eax,%ebx
  8011a3:	39 f3                	cmp    %esi,%ebx
  8011a5:	72 db                	jb     801182 <readn+0x16>
  8011a7:	89 d8                	mov    %ebx,%eax
  8011a9:	eb 02                	jmp    8011ad <readn+0x41>
  8011ab:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 14             	sub    $0x14,%esp
  8011bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	53                   	push   %ebx
  8011c4:	e8 ac fc ff ff       	call   800e75 <fd_lookup>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 68                	js     80123a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dc:	ff 30                	pushl  (%eax)
  8011de:	e8 e8 fc ff ff       	call   800ecb <dev_lookup>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 47                	js     801231 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f1:	75 21                	jne    801214 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f8:	8b 40 48             	mov    0x48(%eax),%eax
  8011fb:	83 ec 04             	sub    $0x4,%esp
  8011fe:	53                   	push   %ebx
  8011ff:	50                   	push   %eax
  801200:	68 5c 23 80 00       	push   $0x80235c
  801205:	e8 e4 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801212:	eb 26                	jmp    80123a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801214:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801217:	8b 52 0c             	mov    0xc(%edx),%edx
  80121a:	85 d2                	test   %edx,%edx
  80121c:	74 17                	je     801235 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	ff 75 10             	pushl  0x10(%ebp)
  801224:	ff 75 0c             	pushl  0xc(%ebp)
  801227:	50                   	push   %eax
  801228:	ff d2                	call   *%edx
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	eb 09                	jmp    80123a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801231:	89 c2                	mov    %eax,%edx
  801233:	eb 05                	jmp    80123a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801235:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80123a:	89 d0                	mov    %edx,%eax
  80123c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <seek>:

int
seek(int fdnum, off_t offset)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801247:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 22 fc ff ff       	call   800e75 <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 0e                	js     801268 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801260:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	53                   	push   %ebx
  801279:	e8 f7 fb ff ff       	call   800e75 <fd_lookup>
  80127e:	83 c4 08             	add    $0x8,%esp
  801281:	89 c2                	mov    %eax,%edx
  801283:	85 c0                	test   %eax,%eax
  801285:	78 65                	js     8012ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	ff 30                	pushl  (%eax)
  801293:	e8 33 fc ff ff       	call   800ecb <dev_lookup>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 44                	js     8012e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a6:	75 21                	jne    8012c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ad:	8b 40 48             	mov    0x48(%eax),%eax
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	53                   	push   %ebx
  8012b4:	50                   	push   %eax
  8012b5:	68 1c 23 80 00       	push   $0x80231c
  8012ba:	e8 2f ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c7:	eb 23                	jmp    8012ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cc:	8b 52 18             	mov    0x18(%edx),%edx
  8012cf:	85 d2                	test   %edx,%edx
  8012d1:	74 14                	je     8012e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	ff 75 0c             	pushl  0xc(%ebp)
  8012d9:	50                   	push   %eax
  8012da:	ff d2                	call   *%edx
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	eb 09                	jmp    8012ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	eb 05                	jmp    8012ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ec:	89 d0                	mov    %edx,%eax
  8012ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 14             	sub    $0x14,%esp
  8012fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 6c fb ff ff       	call   800e75 <fd_lookup>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 58                	js     80136a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	ff 30                	pushl  (%eax)
  80131e:	e8 a8 fb ff ff       	call   800ecb <dev_lookup>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 37                	js     801361 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801331:	74 32                	je     801365 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801333:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801336:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133d:	00 00 00 
	stat->st_isdir = 0;
  801340:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801347:	00 00 00 
	stat->st_dev = dev;
  80134a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	ff 75 f0             	pushl  -0x10(%ebp)
  801357:	ff 50 14             	call   *0x14(%eax)
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	eb 09                	jmp    80136a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801361:	89 c2                	mov    %eax,%edx
  801363:	eb 05                	jmp    80136a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801365:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136a:	89 d0                	mov    %edx,%eax
  80136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	56                   	push   %esi
  801375:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	6a 00                	push   $0x0
  80137b:	ff 75 08             	pushl  0x8(%ebp)
  80137e:	e8 d6 01 00 00       	call   801559 <open>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 1b                	js     8013a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	ff 75 0c             	pushl  0xc(%ebp)
  801392:	50                   	push   %eax
  801393:	e8 5b ff ff ff       	call   8012f3 <fstat>
  801398:	89 c6                	mov    %eax,%esi
	close(fd);
  80139a:	89 1c 24             	mov    %ebx,(%esp)
  80139d:	e8 fd fb ff ff       	call   800f9f <close>
	return r;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	89 f0                	mov    %esi,%eax
}
  8013a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5d                   	pop    %ebp
  8013ad:	c3                   	ret    

008013ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	89 c6                	mov    %eax,%esi
  8013b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013be:	75 12                	jne    8013d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	6a 01                	push   $0x1
  8013c5:	e8 fe 07 00 00       	call   801bc8 <ipc_find_env>
  8013ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8013cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d2:	6a 07                	push   $0x7
  8013d4:	68 00 50 80 00       	push   $0x805000
  8013d9:	56                   	push   %esi
  8013da:	ff 35 00 40 80 00    	pushl  0x804000
  8013e0:	e8 8f 07 00 00       	call   801b74 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e5:	83 c4 0c             	add    $0xc,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 ea 06 00 00       	call   801adc <ipc_recv>
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801402:	8b 40 0c             	mov    0xc(%eax),%eax
  801405:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	b8 02 00 00 00       	mov    $0x2,%eax
  80141c:	e8 8d ff ff ff       	call   8013ae <fsipc>
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
  80142c:	8b 40 0c             	mov    0xc(%eax),%eax
  80142f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801434:	ba 00 00 00 00       	mov    $0x0,%edx
  801439:	b8 06 00 00 00       	mov    $0x6,%eax
  80143e:	e8 6b ff ff ff       	call   8013ae <fsipc>
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	53                   	push   %ebx
  801449:	83 ec 04             	sub    $0x4,%esp
  80144c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	8b 40 0c             	mov    0xc(%eax),%eax
  801455:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 05 00 00 00       	mov    $0x5,%eax
  801464:	e8 45 ff ff ff       	call   8013ae <fsipc>
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 2c                	js     801499 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	68 00 50 80 00       	push   $0x805000
  801475:	53                   	push   %ebx
  801476:	e8 f8 f2 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80147b:	a1 80 50 80 00       	mov    0x805080,%eax
  801480:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801486:	a1 84 50 80 00       	mov    0x805084,%eax
  80148b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801499:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ad:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014b3:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b8:	50                   	push   %eax
  8014b9:	ff 75 0c             	pushl  0xc(%ebp)
  8014bc:	68 08 50 80 00       	push   $0x805008
  8014c1:	e8 3f f4 ff ff       	call   800905 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d0:	e8 d9 fe ff ff       	call   8013ae <fsipc>
	//panic("devfile_write not implemented");
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
  8014dc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014df:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fa:	e8 af fe ff ff       	call   8013ae <fsipc>
  8014ff:	89 c3                	mov    %eax,%ebx
  801501:	85 c0                	test   %eax,%eax
  801503:	78 4b                	js     801550 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801505:	39 c6                	cmp    %eax,%esi
  801507:	73 16                	jae    80151f <devfile_read+0x48>
  801509:	68 8c 23 80 00       	push   $0x80238c
  80150e:	68 93 23 80 00       	push   $0x802393
  801513:	6a 7c                	push   $0x7c
  801515:	68 a8 23 80 00       	push   $0x8023a8
  80151a:	e8 f6 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80151f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801524:	7e 16                	jle    80153c <devfile_read+0x65>
  801526:	68 b3 23 80 00       	push   $0x8023b3
  80152b:	68 93 23 80 00       	push   $0x802393
  801530:	6a 7d                	push   $0x7d
  801532:	68 a8 23 80 00       	push   $0x8023a8
  801537:	e8 d9 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	50                   	push   %eax
  801540:	68 00 50 80 00       	push   $0x805000
  801545:	ff 75 0c             	pushl  0xc(%ebp)
  801548:	e8 b8 f3 ff ff       	call   800905 <memmove>
	return r;
  80154d:	83 c4 10             	add    $0x10,%esp
}
  801550:	89 d8                	mov    %ebx,%eax
  801552:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 20             	sub    $0x20,%esp
  801560:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801563:	53                   	push   %ebx
  801564:	e8 d1 f1 ff ff       	call   80073a <strlen>
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801571:	7f 67                	jg     8015da <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	e8 a7 f8 ff ff       	call   800e26 <fd_alloc>
  80157f:	83 c4 10             	add    $0x10,%esp
		return r;
  801582:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801584:	85 c0                	test   %eax,%eax
  801586:	78 57                	js     8015df <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	68 00 50 80 00       	push   $0x805000
  801591:	e8 dd f1 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801596:	8b 45 0c             	mov    0xc(%ebp),%eax
  801599:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80159e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a6:	e8 03 fe ff ff       	call   8013ae <fsipc>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	79 14                	jns    8015c8 <open+0x6f>
		fd_close(fd, 0);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	6a 00                	push   $0x0
  8015b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bc:	e8 5d f9 ff ff       	call   800f1e <fd_close>
		return r;
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	89 da                	mov    %ebx,%edx
  8015c6:	eb 17                	jmp    8015df <open+0x86>
	}

	return fd2num(fd);
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ce:	e8 2c f8 ff ff       	call   800dff <fd2num>
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb 05                	jmp    8015df <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015da:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f6:	e8 b3 fd ff ff       	call   8013ae <fsipc>
}
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 ff f7 ff ff       	call   800e0f <fd2data>
  801610:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801612:	83 c4 08             	add    $0x8,%esp
  801615:	68 bf 23 80 00       	push   $0x8023bf
  80161a:	53                   	push   %ebx
  80161b:	e8 53 f1 ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801620:	8b 46 04             	mov    0x4(%esi),%eax
  801623:	2b 06                	sub    (%esi),%eax
  801625:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80162b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801632:	00 00 00 
	stat->st_dev = &devpipe;
  801635:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80163c:	30 80 00 
	return 0;
}
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801655:	53                   	push   %ebx
  801656:	6a 00                	push   $0x0
  801658:	e8 9e f5 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80165d:	89 1c 24             	mov    %ebx,(%esp)
  801660:	e8 aa f7 ff ff       	call   800e0f <fd2data>
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	50                   	push   %eax
  801669:	6a 00                	push   $0x0
  80166b:	e8 8b f5 ff ff       	call   800bfb <sys_page_unmap>
}
  801670:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	57                   	push   %edi
  801679:	56                   	push   %esi
  80167a:	53                   	push   %ebx
  80167b:	83 ec 1c             	sub    $0x1c,%esp
  80167e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801681:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801683:	a1 04 40 80 00       	mov    0x804004,%eax
  801688:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	ff 75 e0             	pushl  -0x20(%ebp)
  801691:	e8 6b 05 00 00       	call   801c01 <pageref>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	89 3c 24             	mov    %edi,(%esp)
  80169b:	e8 61 05 00 00       	call   801c01 <pageref>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	39 c3                	cmp    %eax,%ebx
  8016a5:	0f 94 c1             	sete   %cl
  8016a8:	0f b6 c9             	movzbl %cl,%ecx
  8016ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016ae:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016b7:	39 ce                	cmp    %ecx,%esi
  8016b9:	74 1b                	je     8016d6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016bb:	39 c3                	cmp    %eax,%ebx
  8016bd:	75 c4                	jne    801683 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016bf:	8b 42 58             	mov    0x58(%edx),%eax
  8016c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016c5:	50                   	push   %eax
  8016c6:	56                   	push   %esi
  8016c7:	68 c6 23 80 00       	push   $0x8023c6
  8016cc:	e8 1d eb ff ff       	call   8001ee <cprintf>
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	eb ad                	jmp    801683 <_pipeisclosed+0xe>
	}
}
  8016d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5f                   	pop    %edi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	57                   	push   %edi
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 28             	sub    $0x28,%esp
  8016ea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016ed:	56                   	push   %esi
  8016ee:	e8 1c f7 ff ff       	call   800e0f <fd2data>
  8016f3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8016fd:	eb 4b                	jmp    80174a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016ff:	89 da                	mov    %ebx,%edx
  801701:	89 f0                	mov    %esi,%eax
  801703:	e8 6d ff ff ff       	call   801675 <_pipeisclosed>
  801708:	85 c0                	test   %eax,%eax
  80170a:	75 48                	jne    801754 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80170c:	e8 46 f4 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801711:	8b 43 04             	mov    0x4(%ebx),%eax
  801714:	8b 0b                	mov    (%ebx),%ecx
  801716:	8d 51 20             	lea    0x20(%ecx),%edx
  801719:	39 d0                	cmp    %edx,%eax
  80171b:	73 e2                	jae    8016ff <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801720:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801724:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801727:	89 c2                	mov    %eax,%edx
  801729:	c1 fa 1f             	sar    $0x1f,%edx
  80172c:	89 d1                	mov    %edx,%ecx
  80172e:	c1 e9 1b             	shr    $0x1b,%ecx
  801731:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801734:	83 e2 1f             	and    $0x1f,%edx
  801737:	29 ca                	sub    %ecx,%edx
  801739:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80173d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801741:	83 c0 01             	add    $0x1,%eax
  801744:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801747:	83 c7 01             	add    $0x1,%edi
  80174a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80174d:	75 c2                	jne    801711 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80174f:	8b 45 10             	mov    0x10(%ebp),%eax
  801752:	eb 05                	jmp    801759 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801754:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801759:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175c:	5b                   	pop    %ebx
  80175d:	5e                   	pop    %esi
  80175e:	5f                   	pop    %edi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	57                   	push   %edi
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	83 ec 18             	sub    $0x18,%esp
  80176a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80176d:	57                   	push   %edi
  80176e:	e8 9c f6 ff ff       	call   800e0f <fd2data>
  801773:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177d:	eb 3d                	jmp    8017bc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80177f:	85 db                	test   %ebx,%ebx
  801781:	74 04                	je     801787 <devpipe_read+0x26>
				return i;
  801783:	89 d8                	mov    %ebx,%eax
  801785:	eb 44                	jmp    8017cb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801787:	89 f2                	mov    %esi,%edx
  801789:	89 f8                	mov    %edi,%eax
  80178b:	e8 e5 fe ff ff       	call   801675 <_pipeisclosed>
  801790:	85 c0                	test   %eax,%eax
  801792:	75 32                	jne    8017c6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801794:	e8 be f3 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801799:	8b 06                	mov    (%esi),%eax
  80179b:	3b 46 04             	cmp    0x4(%esi),%eax
  80179e:	74 df                	je     80177f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a0:	99                   	cltd   
  8017a1:	c1 ea 1b             	shr    $0x1b,%edx
  8017a4:	01 d0                	add    %edx,%eax
  8017a6:	83 e0 1f             	and    $0x1f,%eax
  8017a9:	29 d0                	sub    %edx,%eax
  8017ab:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017b6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b9:	83 c3 01             	add    $0x1,%ebx
  8017bc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017bf:	75 d8                	jne    801799 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c4:	eb 05                	jmp    8017cb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5f                   	pop    %edi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017de:	50                   	push   %eax
  8017df:	e8 42 f6 ff ff       	call   800e26 <fd_alloc>
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	0f 88 2c 01 00 00    	js     80191d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f1:	83 ec 04             	sub    $0x4,%esp
  8017f4:	68 07 04 00 00       	push   $0x407
  8017f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fc:	6a 00                	push   $0x0
  8017fe:	e8 73 f3 ff ff       	call   800b76 <sys_page_alloc>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	89 c2                	mov    %eax,%edx
  801808:	85 c0                	test   %eax,%eax
  80180a:	0f 88 0d 01 00 00    	js     80191d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	e8 0a f6 ff ff       	call   800e26 <fd_alloc>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	0f 88 e2 00 00 00    	js     80190b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801829:	83 ec 04             	sub    $0x4,%esp
  80182c:	68 07 04 00 00       	push   $0x407
  801831:	ff 75 f0             	pushl  -0x10(%ebp)
  801834:	6a 00                	push   $0x0
  801836:	e8 3b f3 ff ff       	call   800b76 <sys_page_alloc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	0f 88 c3 00 00 00    	js     80190b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801848:	83 ec 0c             	sub    $0xc,%esp
  80184b:	ff 75 f4             	pushl  -0xc(%ebp)
  80184e:	e8 bc f5 ff ff       	call   800e0f <fd2data>
  801853:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801855:	83 c4 0c             	add    $0xc,%esp
  801858:	68 07 04 00 00       	push   $0x407
  80185d:	50                   	push   %eax
  80185e:	6a 00                	push   $0x0
  801860:	e8 11 f3 ff ff       	call   800b76 <sys_page_alloc>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	0f 88 89 00 00 00    	js     8018fb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	ff 75 f0             	pushl  -0x10(%ebp)
  801878:	e8 92 f5 ff ff       	call   800e0f <fd2data>
  80187d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801884:	50                   	push   %eax
  801885:	6a 00                	push   $0x0
  801887:	56                   	push   %esi
  801888:	6a 00                	push   $0x0
  80188a:	e8 2a f3 ff ff       	call   800bb9 <sys_page_map>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	83 c4 20             	add    $0x20,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	78 55                	js     8018ed <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801898:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ad:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c8:	e8 32 f5 ff ff       	call   800dff <fd2num>
  8018cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018d2:	83 c4 04             	add    $0x4,%esp
  8018d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d8:	e8 22 f5 ff ff       	call   800dff <fd2num>
  8018dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	eb 30                	jmp    80191d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	56                   	push   %esi
  8018f1:	6a 00                	push   $0x0
  8018f3:	e8 03 f3 ff ff       	call   800bfb <sys_page_unmap>
  8018f8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801901:	6a 00                	push   $0x0
  801903:	e8 f3 f2 ff ff       	call   800bfb <sys_page_unmap>
  801908:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	ff 75 f4             	pushl  -0xc(%ebp)
  801911:	6a 00                	push   $0x0
  801913:	e8 e3 f2 ff ff       	call   800bfb <sys_page_unmap>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80191d:	89 d0                	mov    %edx,%eax
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	ff 75 08             	pushl  0x8(%ebp)
  801933:	e8 3d f5 ff ff       	call   800e75 <fd_lookup>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 18                	js     801957 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	e8 c5 f4 ff ff       	call   800e0f <fd2data>
	return _pipeisclosed(fd, p);
  80194a:	89 c2                	mov    %eax,%edx
  80194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194f:	e8 21 fd ff ff       	call   801675 <_pipeisclosed>
  801954:	83 c4 10             	add    $0x10,%esp
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801969:	68 de 23 80 00       	push   $0x8023de
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	e8 fd ed ff ff       	call   800773 <strcpy>
	return 0;
}
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	57                   	push   %edi
  801981:	56                   	push   %esi
  801982:	53                   	push   %ebx
  801983:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801989:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801994:	eb 2d                	jmp    8019c3 <devcons_write+0x46>
		m = n - tot;
  801996:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801999:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80199b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80199e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019a3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	53                   	push   %ebx
  8019aa:	03 45 0c             	add    0xc(%ebp),%eax
  8019ad:	50                   	push   %eax
  8019ae:	57                   	push   %edi
  8019af:	e8 51 ef ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  8019b4:	83 c4 08             	add    $0x8,%esp
  8019b7:	53                   	push   %ebx
  8019b8:	57                   	push   %edi
  8019b9:	e8 fc f0 ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019be:	01 de                	add    %ebx,%esi
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	89 f0                	mov    %esi,%eax
  8019c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019c8:	72 cc                	jb     801996 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5f                   	pop    %edi
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e1:	74 2a                	je     801a0d <devcons_read+0x3b>
  8019e3:	eb 05                	jmp    8019ea <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019e5:	e8 6d f1 ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ea:	e8 e9 f0 ff ff       	call   800ad8 <sys_cgetc>
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	74 f2                	je     8019e5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 16                	js     801a0d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019f7:	83 f8 04             	cmp    $0x4,%eax
  8019fa:	74 0c                	je     801a08 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ff:	88 02                	mov    %al,(%edx)
	return 1;
  801a01:	b8 01 00 00 00       	mov    $0x1,%eax
  801a06:	eb 05                	jmp    801a0d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a1b:	6a 01                	push   $0x1
  801a1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a20:	50                   	push   %eax
  801a21:	e8 94 f0 ff ff       	call   800aba <sys_cputs>
}
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <getchar>:

int
getchar(void)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a31:	6a 01                	push   $0x1
  801a33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	6a 00                	push   $0x0
  801a39:	e8 9d f6 ff ff       	call   8010db <read>
	if (r < 0)
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 0f                	js     801a54 <getchar+0x29>
		return r;
	if (r < 1)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	7e 06                	jle    801a4f <getchar+0x24>
		return -E_EOF;
	return c;
  801a49:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a4d:	eb 05                	jmp    801a54 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a4f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5f:	50                   	push   %eax
  801a60:	ff 75 08             	pushl  0x8(%ebp)
  801a63:	e8 0d f4 ff ff       	call   800e75 <fd_lookup>
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 11                	js     801a80 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a78:	39 10                	cmp    %edx,(%eax)
  801a7a:	0f 94 c0             	sete   %al
  801a7d:	0f b6 c0             	movzbl %al,%eax
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <opencons>:

int
opencons(void)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8b:	50                   	push   %eax
  801a8c:	e8 95 f3 ff ff       	call   800e26 <fd_alloc>
  801a91:	83 c4 10             	add    $0x10,%esp
		return r;
  801a94:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 3e                	js     801ad8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a9a:	83 ec 04             	sub    $0x4,%esp
  801a9d:	68 07 04 00 00       	push   $0x407
  801aa2:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 ca f0 ff ff       	call   800b76 <sys_page_alloc>
  801aac:	83 c4 10             	add    $0x10,%esp
		return r;
  801aaf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 23                	js     801ad8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ab5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	50                   	push   %eax
  801ace:	e8 2c f3 ff ff       	call   800dff <fd2num>
  801ad3:	89 c2                	mov    %eax,%edx
  801ad5:	83 c4 10             	add    $0x10,%esp
}
  801ad8:	89 d0                	mov    %edx,%eax
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801aea:	85 c0                	test   %eax,%eax
  801aec:	74 3e                	je     801b2c <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	50                   	push   %eax
  801af2:	e8 2f f2 ff ff       	call   800d26 <sys_ipc_recv>
  801af7:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	85 f6                	test   %esi,%esi
  801afe:	74 13                	je     801b13 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
  801b05:	85 d2                	test   %edx,%edx
  801b07:	75 08                	jne    801b11 <ipc_recv+0x35>
  801b09:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0e:	8b 40 74             	mov    0x74(%eax),%eax
  801b11:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b13:	85 db                	test   %ebx,%ebx
  801b15:	74 48                	je     801b5f <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1c:	85 d2                	test   %edx,%edx
  801b1e:	75 08                	jne    801b28 <ipc_recv+0x4c>
  801b20:	a1 04 40 80 00       	mov    0x804004,%eax
  801b25:	8b 40 78             	mov    0x78(%eax),%eax
  801b28:	89 03                	mov    %eax,(%ebx)
  801b2a:	eb 33                	jmp    801b5f <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	68 00 00 c0 ee       	push   $0xeec00000
  801b34:	e8 ed f1 ff ff       	call   800d26 <sys_ipc_recv>
  801b39:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 f6                	test   %esi,%esi
  801b40:	74 13                	je     801b55 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	85 d2                	test   %edx,%edx
  801b49:	75 08                	jne    801b53 <ipc_recv+0x77>
  801b4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b50:	8b 40 74             	mov    0x74(%eax),%eax
  801b53:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b55:	85 db                	test   %ebx,%ebx
  801b57:	74 06                	je     801b5f <ipc_recv+0x83>
			*perm_store = 0;
  801b59:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  801b5f:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  801b61:	85 d2                	test   %edx,%edx
  801b63:	75 08                	jne    801b6d <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  801b65:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6a:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  801b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 0c             	sub    $0xc,%esp
  801b7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b80:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  801b86:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  801b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b8d:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b90:	eb 1c                	jmp    801bae <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  801b92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b95:	74 12                	je     801ba9 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  801b97:	50                   	push   %eax
  801b98:	68 ea 23 80 00       	push   $0x8023ea
  801b9d:	6a 4f                	push   $0x4f
  801b9f:	68 05 24 80 00       	push   $0x802405
  801ba4:	e8 6c e5 ff ff       	call   800115 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  801ba9:	e8 a9 ef ff ff       	call   800b57 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bae:	ff 75 14             	pushl  0x14(%ebp)
  801bb1:	53                   	push   %ebx
  801bb2:	56                   	push   %esi
  801bb3:	57                   	push   %edi
  801bb4:	e8 4a f1 ff ff       	call   800d03 <sys_ipc_try_send>
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	78 d2                	js     801b92 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bd6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bdc:	8b 52 50             	mov    0x50(%edx),%edx
  801bdf:	39 ca                	cmp    %ecx,%edx
  801be1:	75 0d                	jne    801bf0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801be3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801be6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801beb:	8b 40 48             	mov    0x48(%eax),%eax
  801bee:	eb 0f                	jmp    801bff <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bf0:	83 c0 01             	add    $0x1,%eax
  801bf3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf8:	75 d9                	jne    801bd3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c07:	89 d0                	mov    %edx,%eax
  801c09:	c1 e8 16             	shr    $0x16,%eax
  801c0c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c13:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c18:	f6 c1 01             	test   $0x1,%cl
  801c1b:	74 1d                	je     801c3a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c1d:	c1 ea 0c             	shr    $0xc,%edx
  801c20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c27:	f6 c2 01             	test   $0x1,%dl
  801c2a:	74 0e                	je     801c3a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c2c:	c1 ea 0c             	shr    $0xc,%edx
  801c2f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c36:	ef 
  801c37:	0f b7 c0             	movzwl %ax,%eax
}
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 f6                	test   %esi,%esi
  801c59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5d:	89 ca                	mov    %ecx,%edx
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	75 3d                	jne    801ca0 <__udivdi3+0x60>
  801c63:	39 cf                	cmp    %ecx,%edi
  801c65:	0f 87 c5 00 00 00    	ja     801d30 <__udivdi3+0xf0>
  801c6b:	85 ff                	test   %edi,%edi
  801c6d:	89 fd                	mov    %edi,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f7                	div    %edi
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 c8                	mov    %ecx,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c1                	mov    %eax,%ecx
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	89 cf                	mov    %ecx,%edi
  801c88:	f7 f5                	div    %ebp
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	39 ce                	cmp    %ecx,%esi
  801ca2:	77 74                	ja     801d18 <__udivdi3+0xd8>
  801ca4:	0f bd fe             	bsr    %esi,%edi
  801ca7:	83 f7 1f             	xor    $0x1f,%edi
  801caa:	0f 84 98 00 00 00    	je     801d48 <__udivdi3+0x108>
  801cb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	89 c5                	mov    %eax,%ebp
  801cb9:	29 fb                	sub    %edi,%ebx
  801cbb:	d3 e6                	shl    %cl,%esi
  801cbd:	89 d9                	mov    %ebx,%ecx
  801cbf:	d3 ed                	shr    %cl,%ebp
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	09 ee                	or     %ebp,%esi
  801cc7:	89 d9                	mov    %ebx,%ecx
  801cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccd:	89 d5                	mov    %edx,%ebp
  801ccf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cd3:	d3 ed                	shr    %cl,%ebp
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e2                	shl    %cl,%edx
  801cd9:	89 d9                	mov    %ebx,%ecx
  801cdb:	d3 e8                	shr    %cl,%eax
  801cdd:	09 c2                	or     %eax,%edx
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	89 ea                	mov    %ebp,%edx
  801ce3:	f7 f6                	div    %esi
  801ce5:	89 d5                	mov    %edx,%ebp
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	f7 64 24 0c          	mull   0xc(%esp)
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	72 10                	jb     801d01 <__udivdi3+0xc1>
  801cf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e6                	shl    %cl,%esi
  801cf9:	39 c6                	cmp    %eax,%esi
  801cfb:	73 07                	jae    801d04 <__udivdi3+0xc4>
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	75 03                	jne    801d04 <__udivdi3+0xc4>
  801d01:	83 eb 01             	sub    $0x1,%ebx
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 d8                	mov    %ebx,%eax
  801d08:	89 fa                	mov    %edi,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	31 ff                	xor    %edi,%edi
  801d1a:	31 db                	xor    %ebx,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	f7 f7                	div    %edi
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 1c             	add    $0x1c,%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	39 ce                	cmp    %ecx,%esi
  801d4a:	72 0c                	jb     801d58 <__udivdi3+0x118>
  801d4c:	31 db                	xor    %ebx,%ebx
  801d4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d52:	0f 87 34 ff ff ff    	ja     801c8c <__udivdi3+0x4c>
  801d58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d5d:	e9 2a ff ff ff       	jmp    801c8c <__udivdi3+0x4c>
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 d2                	test   %edx,%edx
  801d89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d91:	89 f3                	mov    %esi,%ebx
  801d93:	89 3c 24             	mov    %edi,(%esp)
  801d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9a:	75 1c                	jne    801db8 <__umoddi3+0x48>
  801d9c:	39 f7                	cmp    %esi,%edi
  801d9e:	76 50                	jbe    801df0 <__umoddi3+0x80>
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	f7 f7                	div    %edi
  801da6:	89 d0                	mov    %edx,%eax
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	77 52                	ja     801e10 <__umoddi3+0xa0>
  801dbe:	0f bd ea             	bsr    %edx,%ebp
  801dc1:	83 f5 1f             	xor    $0x1f,%ebp
  801dc4:	75 5a                	jne    801e20 <__umoddi3+0xb0>
  801dc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	39 0c 24             	cmp    %ecx,(%esp)
  801dd3:	0f 86 d7 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ddd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	85 ff                	test   %edi,%edi
  801df2:	89 fd                	mov    %edi,%ebp
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 c8                	mov    %ecx,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	eb 99                	jmp    801da8 <__umoddi3+0x38>
  801e0f:	90                   	nop
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	83 c4 1c             	add    $0x1c,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5f                   	pop    %edi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	8b 34 24             	mov    (%esp),%esi
  801e23:	bf 20 00 00 00       	mov    $0x20,%edi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	29 ef                	sub    %ebp,%edi
  801e2c:	d3 e0                	shl    %cl,%eax
  801e2e:	89 f9                	mov    %edi,%ecx
  801e30:	89 f2                	mov    %esi,%edx
  801e32:	d3 ea                	shr    %cl,%edx
  801e34:	89 e9                	mov    %ebp,%ecx
  801e36:	09 c2                	or     %eax,%edx
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	89 14 24             	mov    %edx,(%esp)
  801e3d:	89 f2                	mov    %esi,%edx
  801e3f:	d3 e2                	shl    %cl,%edx
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	89 c6                	mov    %eax,%esi
  801e51:	d3 e3                	shl    %cl,%ebx
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 d0                	mov    %edx,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	09 d8                	or     %ebx,%eax
  801e5d:	89 d3                	mov    %edx,%ebx
  801e5f:	89 f2                	mov    %esi,%edx
  801e61:	f7 34 24             	divl   (%esp)
  801e64:	89 d6                	mov    %edx,%esi
  801e66:	d3 e3                	shl    %cl,%ebx
  801e68:	f7 64 24 04          	mull   0x4(%esp)
  801e6c:	39 d6                	cmp    %edx,%esi
  801e6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e72:	89 d1                	mov    %edx,%ecx
  801e74:	89 c3                	mov    %eax,%ebx
  801e76:	72 08                	jb     801e80 <__umoddi3+0x110>
  801e78:	75 11                	jne    801e8b <__umoddi3+0x11b>
  801e7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e7e:	73 0b                	jae    801e8b <__umoddi3+0x11b>
  801e80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e84:	1b 14 24             	sbb    (%esp),%edx
  801e87:	89 d1                	mov    %edx,%ecx
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e8f:	29 da                	sub    %ebx,%edx
  801e91:	19 ce                	sbb    %ecx,%esi
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e0                	shl    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	d3 ee                	shr    %cl,%esi
  801ea1:	09 d0                	or     %edx,%eax
  801ea3:	89 f2                	mov    %esi,%edx
  801ea5:	83 c4 1c             	add    $0x1c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 f9                	sub    %edi,%ecx
  801eb2:	19 d6                	sbb    %edx,%esi
  801eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebc:	e9 18 ff ff ff       	jmp    801dd9 <__umoddi3+0x69>
