
obj/user/sh.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 00 33 80 00       	push   $0x803300
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 0f 33 80 00       	push   $0x80330f
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 1d 33 80 00       	push   $0x80331d
  8000b0:	e8 b9 11 00 00       	call   80126e <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 22 33 80 00       	push   $0x803322
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 33 33 80 00       	push   $0x803333
  8000fb:	e8 6e 11 00 00       	call   80126e <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 27 33 80 00       	push   $0x803327
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 2f 33 80 00       	push   $0x80332f
  800151:	e8 18 11 00 00       	call   80126e <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 3b 33 80 00       	push   $0x80333b
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 45 33 80 00       	push   $0x803345
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 84 34 80 00       	push   $0x803484
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			//edit by Lethe 2018/12/14
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 8d 20 00 00       	call   802353 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
                                cprintf("open %s for write: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 59 33 80 00       	push   $0x803359
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
                                exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
                        }
                        if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
                                dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 ec 1a 00 00       	call   801de9 <dup>
                                close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 94 1a 00 00       	call   801d99 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			//panic("< redirection not implemented");
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 ac 34 80 00       	push   $0x8034ac
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 0e 20 00 00       	call   802353 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 59 33 80 00       	push   $0x803359
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 6e 1a 00 00       	call   801de9 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 16 1a 00 00       	call   801d99 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 ed 28 00 00       	call   802c87 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 6f 33 80 00       	push   $0x80336f
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 78 33 80 00       	push   $0x803378
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 75 14 00 00       	call   801856 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 85 33 80 00       	push   $0x803385
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 d3 19 00 00       	call   801de9 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 75 19 00 00       	call   801d99 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 64 19 00 00       	call   801d99 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 96 19 00 00       	call   801de9 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 38 19 00 00       	call   801d99 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 27 19 00 00       	call   801d99 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 8e 33 80 00       	push   $0x80338e
  80047d:	6a 7a                	push   $0x7a
  80047f:	68 aa 33 80 00       	push   $0x8033aa
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 b4 33 80 00       	push   $0x8033b4
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 8d 0c 00 00       	call   801166 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 c3 33 80 00       	push   $0x8033c3
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 4b 34 80 00       	push   $0x80344b
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 20 33 80 00       	push   $0x803320
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 bf 1f 00 00       	call   802507 <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 d1 33 80 00       	push   $0x8033d1
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 59 18 00 00       	call   801dc4 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 df 33 80 00       	push   $0x8033df
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 7a 28 00 00       	call   802e0d <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 f4 33 80 00       	push   $0x8033f4
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 0a 34 80 00       	push   $0x80340a
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 21 28 00 00       	call   802e0d <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 f4 33 80 00       	push   $0x8033f4
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 a7 17 00 00       	call   801dc4 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 d4 34 80 00       	push   $0x8034d4
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 34 14 00 00       	call   801aa5 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 18 14 00 00       	call   801ad5 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 ba 16 00 00       	call   801d99 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 67 1c 00 00       	call   802353 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 27 34 80 00       	push   $0x803427
  8006ff:	68 2a 01 00 00       	push   $0x12a
  800704:	68 aa 33 80 00       	push   $0x8033aa
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 33 34 80 00       	push   $0x803433
  800717:	68 3a 34 80 00       	push   $0x80343a
  80071c:	68 2b 01 00 00       	push   $0x12b
  800721:	68 aa 33 80 00       	push   $0x8033aa
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf 4f 34 80 00       	mov    $0x80344f,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 e3 08 00 00       	call   80103a <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 52 34 80 00       	push   $0x803452
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 5b 34 80 00       	push   $0x80345b
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 65 34 80 00       	push   $0x803465
  8007ac:	e8 40 1d 00 00       	call   8024f1 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 6b 34 80 00       	push   $0x80346b
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 84 10 00 00       	call   801856 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 85 33 80 00       	push   $0x803385
  8007de:	68 42 01 00 00       	push   $0x142
  8007e3:	68 aa 33 80 00       	push   $0x8033aa
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 78 34 80 00       	push   $0x803478
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 e3 25 00 00       	call   802e0d <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 f5 34 80 00       	push   $0x8034f5
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 17 09 00 00       	call   801166 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 6b 0a 00 00       	call   8012f8 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 16 0c 00 00       	call   8014ad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 87 0c 00 00       	call   80154a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 03 0c 00 00       	call   8014cb <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 ae 0b 00 00       	call   8014ad <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 be 15 00 00       	call   801ed5 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 2e 13 00 00       	call   801c6f <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 b6 12 00 00       	call   801c20 <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 e4 0b 00 00       	call   801569 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 4d 12 00 00       	call   801bf9 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 66 0b 00 00       	call   80152b <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 be 13 00 00       	call   801dc4 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 da 0a 00 00       	call   8014ea <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 03 0b 00 00       	call   80152b <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 0c 35 80 00       	push   $0x80350c
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 20 33 80 00 	movl   $0x803320,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 22 0a 00 00       	call   8014ad <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 54 01 00 00       	call   800c25 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 c7 09 00 00       	call   8014ad <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 0a 25 00 00       	call   803060 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 f7 25 00 00       	call   803190 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 2f 35 80 00 	movsbl 0x80352f(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb4:	83 fa 01             	cmp    $0x1,%edx
  800bb7:	7e 0e                	jle    800bc7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 10                	mov    (%eax),%edx
  800bbb:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbe:	89 08                	mov    %ecx,(%eax)
  800bc0:	8b 02                	mov    (%edx),%eax
  800bc2:	8b 52 04             	mov    0x4(%edx),%edx
  800bc5:	eb 22                	jmp    800be9 <getuint+0x38>
	else if (lflag)
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	74 10                	je     800bdb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd0:	89 08                	mov    %ecx,(%eax)
  800bd2:	8b 02                	mov    (%edx),%eax
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	eb 0e                	jmp    800be9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be0:	89 08                	mov    %ecx,(%eax)
  800be2:	8b 02                	mov    (%edx),%eax
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	3b 50 04             	cmp    0x4(%eax),%edx
  800bfa:	73 0a                	jae    800c06 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 08                	mov    %ecx,(%eax)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	88 02                	mov    %al,(%edx)
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c11:	50                   	push   %eax
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 05 00 00 00       	call   800c25 <vprintfmt>
	va_end(ap);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c37:	eb 12                	jmp    800c4b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	0f 84 89 03 00 00    	je     800fca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	ff d6                	call   *%esi
  800c48:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4b:	83 c7 01             	add    $0x1,%edi
  800c4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c52:	83 f8 25             	cmp    $0x25,%eax
  800c55:	75 e2                	jne    800c39 <vprintfmt+0x14>
  800c57:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c69:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	eb 07                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c77:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c7a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7e:	8d 47 01             	lea    0x1(%edi),%eax
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c84:	0f b6 07             	movzbl (%edi),%eax
  800c87:	0f b6 c8             	movzbl %al,%ecx
  800c8a:	83 e8 23             	sub    $0x23,%eax
  800c8d:	3c 55                	cmp    $0x55,%al
  800c8f:	0f 87 1a 03 00 00    	ja     800faf <vprintfmt+0x38a>
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	ff 24 85 80 36 80 00 	jmp    *0x803680(,%eax,4)
  800c9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca6:	eb d6                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cb3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cbd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cc0:	83 fa 09             	cmp    $0x9,%edx
  800cc3:	77 39                	ja     800cfe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc8:	eb e9                	jmp    800cb3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cca:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccd:	8d 48 04             	lea    0x4(%eax),%ecx
  800cd0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cd3:	8b 00                	mov    (%eax),%eax
  800cd5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cdb:	eb 27                	jmp    800d04 <vprintfmt+0xdf>
  800cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	0f 49 c8             	cmovns %eax,%ecx
  800cea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ced:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf0:	eb 8c                	jmp    800c7e <vprintfmt+0x59>
  800cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cfc:	eb 80                	jmp    800c7e <vprintfmt+0x59>
  800cfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d01:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d08:	0f 89 70 ff ff ff    	jns    800c7e <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d14:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d1b:	e9 5e ff ff ff       	jmp    800c7e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d20:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d26:	e9 53 ff ff ff       	jmp    800c7e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2e:	8d 50 04             	lea    0x4(%eax),%edx
  800d31:	89 55 14             	mov    %edx,0x14(%ebp)
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	53                   	push   %ebx
  800d38:	ff 30                	pushl  (%eax)
  800d3a:	ff d6                	call   *%esi
			break;
  800d3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d42:	e9 04 ff ff ff       	jmp    800c4b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d47:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4a:	8d 50 04             	lea    0x4(%eax),%edx
  800d4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d50:	8b 00                	mov    (%eax),%eax
  800d52:	99                   	cltd   
  800d53:	31 d0                	xor    %edx,%eax
  800d55:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d57:	83 f8 0f             	cmp    $0xf,%eax
  800d5a:	7f 0b                	jg     800d67 <vprintfmt+0x142>
  800d5c:	8b 14 85 e0 37 80 00 	mov    0x8037e0(,%eax,4),%edx
  800d63:	85 d2                	test   %edx,%edx
  800d65:	75 18                	jne    800d7f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d67:	50                   	push   %eax
  800d68:	68 47 35 80 00       	push   $0x803547
  800d6d:	53                   	push   %ebx
  800d6e:	56                   	push   %esi
  800d6f:	e8 94 fe ff ff       	call   800c08 <printfmt>
  800d74:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d7a:	e9 cc fe ff ff       	jmp    800c4b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7f:	52                   	push   %edx
  800d80:	68 4c 34 80 00       	push   $0x80344c
  800d85:	53                   	push   %ebx
  800d86:	56                   	push   %esi
  800d87:	e8 7c fe ff ff       	call   800c08 <printfmt>
  800d8c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d92:	e9 b4 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d97:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9a:	8d 50 04             	lea    0x4(%eax),%edx
  800d9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800da0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800da2:	85 ff                	test   %edi,%edi
  800da4:	b8 40 35 80 00       	mov    $0x803540,%eax
  800da9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800db0:	0f 8e 94 00 00 00    	jle    800e4a <vprintfmt+0x225>
  800db6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dba:	0f 84 98 00 00 00    	je     800e58 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	ff 75 d0             	pushl  -0x30(%ebp)
  800dc6:	57                   	push   %edi
  800dc7:	e8 79 03 00 00       	call   801145 <strnlen>
  800dcc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dcf:	29 c1                	sub    %eax,%ecx
  800dd1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dd4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dd7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dde:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de3:	eb 0f                	jmp    800df4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	53                   	push   %ebx
  800de9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dee:	83 ef 01             	sub    $0x1,%edi
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 ff                	test   %edi,%edi
  800df6:	7f ed                	jg     800de5 <vprintfmt+0x1c0>
  800df8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dfb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dfe:	85 c9                	test   %ecx,%ecx
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	0f 49 c1             	cmovns %ecx,%eax
  800e08:	29 c1                	sub    %eax,%ecx
  800e0a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e0d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e10:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e13:	89 cb                	mov    %ecx,%ebx
  800e15:	eb 4d                	jmp    800e64 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e17:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e1b:	74 1b                	je     800e38 <vprintfmt+0x213>
  800e1d:	0f be c0             	movsbl %al,%eax
  800e20:	83 e8 20             	sub    $0x20,%eax
  800e23:	83 f8 5e             	cmp    $0x5e,%eax
  800e26:	76 10                	jbe    800e38 <vprintfmt+0x213>
					putch('?', putdat);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 0c             	pushl  0xc(%ebp)
  800e2e:	6a 3f                	push   $0x3f
  800e30:	ff 55 08             	call   *0x8(%ebp)
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	eb 0d                	jmp    800e45 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 0c             	pushl  0xc(%ebp)
  800e3e:	52                   	push   %edx
  800e3f:	ff 55 08             	call   *0x8(%ebp)
  800e42:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e45:	83 eb 01             	sub    $0x1,%ebx
  800e48:	eb 1a                	jmp    800e64 <vprintfmt+0x23f>
  800e4a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e50:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e53:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e56:	eb 0c                	jmp    800e64 <vprintfmt+0x23f>
  800e58:	89 75 08             	mov    %esi,0x8(%ebp)
  800e5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e61:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e64:	83 c7 01             	add    $0x1,%edi
  800e67:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e6b:	0f be d0             	movsbl %al,%edx
  800e6e:	85 d2                	test   %edx,%edx
  800e70:	74 23                	je     800e95 <vprintfmt+0x270>
  800e72:	85 f6                	test   %esi,%esi
  800e74:	78 a1                	js     800e17 <vprintfmt+0x1f2>
  800e76:	83 ee 01             	sub    $0x1,%esi
  800e79:	79 9c                	jns    800e17 <vprintfmt+0x1f2>
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e83:	eb 18                	jmp    800e9d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	53                   	push   %ebx
  800e89:	6a 20                	push   $0x20
  800e8b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e8d:	83 ef 01             	sub    $0x1,%edi
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	eb 08                	jmp    800e9d <vprintfmt+0x278>
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9d:	85 ff                	test   %edi,%edi
  800e9f:	7f e4                	jg     800e85 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea4:	e9 a2 fd ff ff       	jmp    800c4b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ea9:	83 fa 01             	cmp    $0x1,%edx
  800eac:	7e 16                	jle    800ec4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800eae:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb1:	8d 50 08             	lea    0x8(%eax),%edx
  800eb4:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb7:	8b 50 04             	mov    0x4(%eax),%edx
  800eba:	8b 00                	mov    (%eax),%eax
  800ebc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ebf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec2:	eb 32                	jmp    800ef6 <vprintfmt+0x2d1>
	else if (lflag)
  800ec4:	85 d2                	test   %edx,%edx
  800ec6:	74 18                	je     800ee0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecb:	8d 50 04             	lea    0x4(%eax),%edx
  800ece:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed1:	8b 00                	mov    (%eax),%eax
  800ed3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ed6:	89 c1                	mov    %eax,%ecx
  800ed8:	c1 f9 1f             	sar    $0x1f,%ecx
  800edb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ede:	eb 16                	jmp    800ef6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ee0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee3:	8d 50 04             	lea    0x4(%eax),%edx
  800ee6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee9:	8b 00                	mov    (%eax),%eax
  800eeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ef6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ef9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800efc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f05:	79 74                	jns    800f7b <vprintfmt+0x356>
				putch('-', putdat);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	6a 2d                	push   $0x2d
  800f0d:	ff d6                	call   *%esi
				num = -(long long) num;
  800f0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f12:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f15:	f7 d8                	neg    %eax
  800f17:	83 d2 00             	adc    $0x0,%edx
  800f1a:	f7 da                	neg    %edx
  800f1c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f1f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f24:	eb 55                	jmp    800f7b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f26:	8d 45 14             	lea    0x14(%ebp),%eax
  800f29:	e8 83 fc ff ff       	call   800bb1 <getuint>
			base = 10;
  800f2e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f33:	eb 46                	jmp    800f7b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800f35:	8d 45 14             	lea    0x14(%ebp),%eax
  800f38:	e8 74 fc ff ff       	call   800bb1 <getuint>
			base=8;
  800f3d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f42:	eb 37                	jmp    800f7b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	53                   	push   %ebx
  800f48:	6a 30                	push   $0x30
  800f4a:	ff d6                	call   *%esi
			putch('x', putdat);
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	53                   	push   %ebx
  800f50:	6a 78                	push   $0x78
  800f52:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f54:	8b 45 14             	mov    0x14(%ebp),%eax
  800f57:	8d 50 04             	lea    0x4(%eax),%edx
  800f5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f5d:	8b 00                	mov    (%eax),%eax
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f64:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f67:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f6c:	eb 0d                	jmp    800f7b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f71:	e8 3b fc ff ff       	call   800bb1 <getuint>
			base = 16;
  800f76:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f82:	57                   	push   %edi
  800f83:	ff 75 e0             	pushl  -0x20(%ebp)
  800f86:	51                   	push   %ecx
  800f87:	52                   	push   %edx
  800f88:	50                   	push   %eax
  800f89:	89 da                	mov    %ebx,%edx
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	e8 70 fb ff ff       	call   800b02 <printnum>
			break;
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f98:	e9 ae fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	53                   	push   %ebx
  800fa1:	51                   	push   %ecx
  800fa2:	ff d6                	call   *%esi
			break;
  800fa4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800faa:	e9 9c fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	53                   	push   %ebx
  800fb3:	6a 25                	push   $0x25
  800fb5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	eb 03                	jmp    800fbf <vprintfmt+0x39a>
  800fbc:	83 ef 01             	sub    $0x1,%edi
  800fbf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fc3:	75 f7                	jne    800fbc <vprintfmt+0x397>
  800fc5:	e9 81 fc ff ff       	jmp    800c4b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 18             	sub    $0x18,%esp
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fe5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fe8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	74 26                	je     801019 <vsnprintf+0x47>
  800ff3:	85 d2                	test   %edx,%edx
  800ff5:	7e 22                	jle    801019 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ff7:	ff 75 14             	pushl  0x14(%ebp)
  800ffa:	ff 75 10             	pushl  0x10(%ebp)
  800ffd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	68 eb 0b 80 00       	push   $0x800beb
  801006:	e8 1a fc ff ff       	call   800c25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80100b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80100e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	eb 05                	jmp    80101e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801019:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801026:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801029:	50                   	push   %eax
  80102a:	ff 75 10             	pushl  0x10(%ebp)
  80102d:	ff 75 0c             	pushl  0xc(%ebp)
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 9a ff ff ff       	call   800fd2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801046:	85 c0                	test   %eax,%eax
  801048:	74 13                	je     80105d <readline+0x23>
		fprintf(1, "%s", prompt);
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	50                   	push   %eax
  80104e:	68 4c 34 80 00       	push   $0x80344c
  801053:	6a 01                	push   $0x1
  801055:	e8 80 14 00 00       	call   8024da <fprintf>
  80105a:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	6a 00                	push   $0x0
  801062:	e8 c8 f8 ff ff       	call   80092f <iscons>
  801067:	89 c7                	mov    %eax,%edi
  801069:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80106c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801071:	e8 8e f8 ff ff       	call   800904 <getchar>
  801076:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 29                	jns    8010a5 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801081:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801084:	0f 84 9b 00 00 00    	je     801125 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	53                   	push   %ebx
  80108e:	68 3f 38 80 00       	push   $0x80383f
  801093:	e8 56 fa ff ff       	call   800aee <cprintf>
  801098:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	e9 80 00 00 00       	jmp    801125 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010a5:	83 f8 08             	cmp    $0x8,%eax
  8010a8:	0f 94 c2             	sete   %dl
  8010ab:	83 f8 7f             	cmp    $0x7f,%eax
  8010ae:	0f 94 c0             	sete   %al
  8010b1:	08 c2                	or     %al,%dl
  8010b3:	74 1a                	je     8010cf <readline+0x95>
  8010b5:	85 f6                	test   %esi,%esi
  8010b7:	7e 16                	jle    8010cf <readline+0x95>
			if (echoing)
  8010b9:	85 ff                	test   %edi,%edi
  8010bb:	74 0d                	je     8010ca <readline+0x90>
				cputchar('\b');
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	6a 08                	push   $0x8
  8010c2:	e8 21 f8 ff ff       	call   8008e8 <cputchar>
  8010c7:	83 c4 10             	add    $0x10,%esp
			i--;
  8010ca:	83 ee 01             	sub    $0x1,%esi
  8010cd:	eb a2                	jmp    801071 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010cf:	83 fb 1f             	cmp    $0x1f,%ebx
  8010d2:	7e 26                	jle    8010fa <readline+0xc0>
  8010d4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010da:	7f 1e                	jg     8010fa <readline+0xc0>
			if (echoing)
  8010dc:	85 ff                	test   %edi,%edi
  8010de:	74 0c                	je     8010ec <readline+0xb2>
				cputchar(c);
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	53                   	push   %ebx
  8010e4:	e8 ff f7 ff ff       	call   8008e8 <cputchar>
  8010e9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010ec:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010f2:	8d 76 01             	lea    0x1(%esi),%esi
  8010f5:	e9 77 ff ff ff       	jmp    801071 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8010fa:	83 fb 0a             	cmp    $0xa,%ebx
  8010fd:	74 09                	je     801108 <readline+0xce>
  8010ff:	83 fb 0d             	cmp    $0xd,%ebx
  801102:	0f 85 69 ff ff ff    	jne    801071 <readline+0x37>
			if (echoing)
  801108:	85 ff                	test   %edi,%edi
  80110a:	74 0d                	je     801119 <readline+0xdf>
				cputchar('\n');
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	6a 0a                	push   $0xa
  801111:	e8 d2 f7 ff ff       	call   8008e8 <cputchar>
  801116:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801119:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801120:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801133:	b8 00 00 00 00       	mov    $0x0,%eax
  801138:	eb 03                	jmp    80113d <strlen+0x10>
		n++;
  80113a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80113d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801141:	75 f7                	jne    80113a <strlen+0xd>
		n++;
	return n;
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80114e:	ba 00 00 00 00       	mov    $0x0,%edx
  801153:	eb 03                	jmp    801158 <strnlen+0x13>
		n++;
  801155:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801158:	39 c2                	cmp    %eax,%edx
  80115a:	74 08                	je     801164 <strnlen+0x1f>
  80115c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801160:	75 f3                	jne    801155 <strnlen+0x10>
  801162:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801170:	89 c2                	mov    %eax,%edx
  801172:	83 c2 01             	add    $0x1,%edx
  801175:	83 c1 01             	add    $0x1,%ecx
  801178:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80117c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80117f:	84 db                	test   %bl,%bl
  801181:	75 ef                	jne    801172 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801183:	5b                   	pop    %ebx
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80118d:	53                   	push   %ebx
  80118e:	e8 9a ff ff ff       	call   80112d <strlen>
  801193:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	01 d8                	add    %ebx,%eax
  80119b:	50                   	push   %eax
  80119c:	e8 c5 ff ff ff       	call   801166 <strcpy>
	return dst;
}
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	89 f3                	mov    %esi,%ebx
  8011b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011b8:	89 f2                	mov    %esi,%edx
  8011ba:	eb 0f                	jmp    8011cb <strncpy+0x23>
		*dst++ = *src;
  8011bc:	83 c2 01             	add    $0x1,%edx
  8011bf:	0f b6 01             	movzbl (%ecx),%eax
  8011c2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011c5:	80 39 01             	cmpb   $0x1,(%ecx)
  8011c8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011cb:	39 da                	cmp    %ebx,%edx
  8011cd:	75 ed                	jne    8011bc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011cf:	89 f0                	mov    %esi,%eax
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8011e3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011e5:	85 d2                	test   %edx,%edx
  8011e7:	74 21                	je     80120a <strlcpy+0x35>
  8011e9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011ed:	89 f2                	mov    %esi,%edx
  8011ef:	eb 09                	jmp    8011fa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011f1:	83 c2 01             	add    $0x1,%edx
  8011f4:	83 c1 01             	add    $0x1,%ecx
  8011f7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011fa:	39 c2                	cmp    %eax,%edx
  8011fc:	74 09                	je     801207 <strlcpy+0x32>
  8011fe:	0f b6 19             	movzbl (%ecx),%ebx
  801201:	84 db                	test   %bl,%bl
  801203:	75 ec                	jne    8011f1 <strlcpy+0x1c>
  801205:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801207:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80120a:	29 f0                	sub    %esi,%eax
}
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801216:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801219:	eb 06                	jmp    801221 <strcmp+0x11>
		p++, q++;
  80121b:	83 c1 01             	add    $0x1,%ecx
  80121e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801221:	0f b6 01             	movzbl (%ecx),%eax
  801224:	84 c0                	test   %al,%al
  801226:	74 04                	je     80122c <strcmp+0x1c>
  801228:	3a 02                	cmp    (%edx),%al
  80122a:	74 ef                	je     80121b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80122c:	0f b6 c0             	movzbl %al,%eax
  80122f:	0f b6 12             	movzbl (%edx),%edx
  801232:	29 d0                	sub    %edx,%eax
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801240:	89 c3                	mov    %eax,%ebx
  801242:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801245:	eb 06                	jmp    80124d <strncmp+0x17>
		n--, p++, q++;
  801247:	83 c0 01             	add    $0x1,%eax
  80124a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80124d:	39 d8                	cmp    %ebx,%eax
  80124f:	74 15                	je     801266 <strncmp+0x30>
  801251:	0f b6 08             	movzbl (%eax),%ecx
  801254:	84 c9                	test   %cl,%cl
  801256:	74 04                	je     80125c <strncmp+0x26>
  801258:	3a 0a                	cmp    (%edx),%cl
  80125a:	74 eb                	je     801247 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80125c:	0f b6 00             	movzbl (%eax),%eax
  80125f:	0f b6 12             	movzbl (%edx),%edx
  801262:	29 d0                	sub    %edx,%eax
  801264:	eb 05                	jmp    80126b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80126b:	5b                   	pop    %ebx
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801278:	eb 07                	jmp    801281 <strchr+0x13>
		if (*s == c)
  80127a:	38 ca                	cmp    %cl,%dl
  80127c:	74 0f                	je     80128d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80127e:	83 c0 01             	add    $0x1,%eax
  801281:	0f b6 10             	movzbl (%eax),%edx
  801284:	84 d2                	test   %dl,%dl
  801286:	75 f2                	jne    80127a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801299:	eb 03                	jmp    80129e <strfind+0xf>
  80129b:	83 c0 01             	add    $0x1,%eax
  80129e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012a1:	38 ca                	cmp    %cl,%dl
  8012a3:	74 04                	je     8012a9 <strfind+0x1a>
  8012a5:	84 d2                	test   %dl,%dl
  8012a7:	75 f2                	jne    80129b <strfind+0xc>
			break;
	return (char *) s;
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	57                   	push   %edi
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012b7:	85 c9                	test   %ecx,%ecx
  8012b9:	74 36                	je     8012f1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012c1:	75 28                	jne    8012eb <memset+0x40>
  8012c3:	f6 c1 03             	test   $0x3,%cl
  8012c6:	75 23                	jne    8012eb <memset+0x40>
		c &= 0xFF;
  8012c8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012cc:	89 d3                	mov    %edx,%ebx
  8012ce:	c1 e3 08             	shl    $0x8,%ebx
  8012d1:	89 d6                	mov    %edx,%esi
  8012d3:	c1 e6 18             	shl    $0x18,%esi
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	c1 e0 10             	shl    $0x10,%eax
  8012db:	09 f0                	or     %esi,%eax
  8012dd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012df:	89 d8                	mov    %ebx,%eax
  8012e1:	09 d0                	or     %edx,%eax
  8012e3:	c1 e9 02             	shr    $0x2,%ecx
  8012e6:	fc                   	cld    
  8012e7:	f3 ab                	rep stos %eax,%es:(%edi)
  8012e9:	eb 06                	jmp    8012f1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ee:	fc                   	cld    
  8012ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012f1:	89 f8                	mov    %edi,%eax
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	57                   	push   %edi
  8012fc:	56                   	push   %esi
  8012fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801300:	8b 75 0c             	mov    0xc(%ebp),%esi
  801303:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801306:	39 c6                	cmp    %eax,%esi
  801308:	73 35                	jae    80133f <memmove+0x47>
  80130a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80130d:	39 d0                	cmp    %edx,%eax
  80130f:	73 2e                	jae    80133f <memmove+0x47>
		s += n;
		d += n;
  801311:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801314:	89 d6                	mov    %edx,%esi
  801316:	09 fe                	or     %edi,%esi
  801318:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80131e:	75 13                	jne    801333 <memmove+0x3b>
  801320:	f6 c1 03             	test   $0x3,%cl
  801323:	75 0e                	jne    801333 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801325:	83 ef 04             	sub    $0x4,%edi
  801328:	8d 72 fc             	lea    -0x4(%edx),%esi
  80132b:	c1 e9 02             	shr    $0x2,%ecx
  80132e:	fd                   	std    
  80132f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801331:	eb 09                	jmp    80133c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801333:	83 ef 01             	sub    $0x1,%edi
  801336:	8d 72 ff             	lea    -0x1(%edx),%esi
  801339:	fd                   	std    
  80133a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80133c:	fc                   	cld    
  80133d:	eb 1d                	jmp    80135c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80133f:	89 f2                	mov    %esi,%edx
  801341:	09 c2                	or     %eax,%edx
  801343:	f6 c2 03             	test   $0x3,%dl
  801346:	75 0f                	jne    801357 <memmove+0x5f>
  801348:	f6 c1 03             	test   $0x3,%cl
  80134b:	75 0a                	jne    801357 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80134d:	c1 e9 02             	shr    $0x2,%ecx
  801350:	89 c7                	mov    %eax,%edi
  801352:	fc                   	cld    
  801353:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801355:	eb 05                	jmp    80135c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801357:	89 c7                	mov    %eax,%edi
  801359:	fc                   	cld    
  80135a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801363:	ff 75 10             	pushl  0x10(%ebp)
  801366:	ff 75 0c             	pushl  0xc(%ebp)
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 87 ff ff ff       	call   8012f8 <memmove>
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 c6                	mov    %eax,%esi
  801380:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801383:	eb 1a                	jmp    80139f <memcmp+0x2c>
		if (*s1 != *s2)
  801385:	0f b6 08             	movzbl (%eax),%ecx
  801388:	0f b6 1a             	movzbl (%edx),%ebx
  80138b:	38 d9                	cmp    %bl,%cl
  80138d:	74 0a                	je     801399 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80138f:	0f b6 c1             	movzbl %cl,%eax
  801392:	0f b6 db             	movzbl %bl,%ebx
  801395:	29 d8                	sub    %ebx,%eax
  801397:	eb 0f                	jmp    8013a8 <memcmp+0x35>
		s1++, s2++;
  801399:	83 c0 01             	add    $0x1,%eax
  80139c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80139f:	39 f0                	cmp    %esi,%eax
  8013a1:	75 e2                	jne    801385 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013b3:	89 c1                	mov    %eax,%ecx
  8013b5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013b8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013bc:	eb 0a                	jmp    8013c8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013be:	0f b6 10             	movzbl (%eax),%edx
  8013c1:	39 da                	cmp    %ebx,%edx
  8013c3:	74 07                	je     8013cc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c5:	83 c0 01             	add    $0x1,%eax
  8013c8:	39 c8                	cmp    %ecx,%eax
  8013ca:	72 f2                	jb     8013be <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013cc:	5b                   	pop    %ebx
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	57                   	push   %edi
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013db:	eb 03                	jmp    8013e0 <strtol+0x11>
		s++;
  8013dd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e0:	0f b6 01             	movzbl (%ecx),%eax
  8013e3:	3c 20                	cmp    $0x20,%al
  8013e5:	74 f6                	je     8013dd <strtol+0xe>
  8013e7:	3c 09                	cmp    $0x9,%al
  8013e9:	74 f2                	je     8013dd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013eb:	3c 2b                	cmp    $0x2b,%al
  8013ed:	75 0a                	jne    8013f9 <strtol+0x2a>
		s++;
  8013ef:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f7:	eb 11                	jmp    80140a <strtol+0x3b>
  8013f9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013fe:	3c 2d                	cmp    $0x2d,%al
  801400:	75 08                	jne    80140a <strtol+0x3b>
		s++, neg = 1;
  801402:	83 c1 01             	add    $0x1,%ecx
  801405:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80140a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801410:	75 15                	jne    801427 <strtol+0x58>
  801412:	80 39 30             	cmpb   $0x30,(%ecx)
  801415:	75 10                	jne    801427 <strtol+0x58>
  801417:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80141b:	75 7c                	jne    801499 <strtol+0xca>
		s += 2, base = 16;
  80141d:	83 c1 02             	add    $0x2,%ecx
  801420:	bb 10 00 00 00       	mov    $0x10,%ebx
  801425:	eb 16                	jmp    80143d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801427:	85 db                	test   %ebx,%ebx
  801429:	75 12                	jne    80143d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80142b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801430:	80 39 30             	cmpb   $0x30,(%ecx)
  801433:	75 08                	jne    80143d <strtol+0x6e>
		s++, base = 8;
  801435:	83 c1 01             	add    $0x1,%ecx
  801438:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801445:	0f b6 11             	movzbl (%ecx),%edx
  801448:	8d 72 d0             	lea    -0x30(%edx),%esi
  80144b:	89 f3                	mov    %esi,%ebx
  80144d:	80 fb 09             	cmp    $0x9,%bl
  801450:	77 08                	ja     80145a <strtol+0x8b>
			dig = *s - '0';
  801452:	0f be d2             	movsbl %dl,%edx
  801455:	83 ea 30             	sub    $0x30,%edx
  801458:	eb 22                	jmp    80147c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80145a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80145d:	89 f3                	mov    %esi,%ebx
  80145f:	80 fb 19             	cmp    $0x19,%bl
  801462:	77 08                	ja     80146c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801464:	0f be d2             	movsbl %dl,%edx
  801467:	83 ea 57             	sub    $0x57,%edx
  80146a:	eb 10                	jmp    80147c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80146c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80146f:	89 f3                	mov    %esi,%ebx
  801471:	80 fb 19             	cmp    $0x19,%bl
  801474:	77 16                	ja     80148c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801476:	0f be d2             	movsbl %dl,%edx
  801479:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80147c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80147f:	7d 0b                	jge    80148c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801481:	83 c1 01             	add    $0x1,%ecx
  801484:	0f af 45 10          	imul   0x10(%ebp),%eax
  801488:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80148a:	eb b9                	jmp    801445 <strtol+0x76>

	if (endptr)
  80148c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801490:	74 0d                	je     80149f <strtol+0xd0>
		*endptr = (char *) s;
  801492:	8b 75 0c             	mov    0xc(%ebp),%esi
  801495:	89 0e                	mov    %ecx,(%esi)
  801497:	eb 06                	jmp    80149f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801499:	85 db                	test   %ebx,%ebx
  80149b:	74 98                	je     801435 <strtol+0x66>
  80149d:	eb 9e                	jmp    80143d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	f7 da                	neg    %edx
  8014a3:	85 ff                	test   %edi,%edi
  8014a5:	0f 45 c2             	cmovne %edx,%eax
}
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 c7                	mov    %eax,%edi
  8014c2:	89 c6                	mov    %eax,%esi
  8014c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <sys_cgetc>:

int
sys_cgetc(void)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	89 d1                	mov    %edx,%ecx
  8014dd:	89 d3                	mov    %edx,%ebx
  8014df:	89 d7                	mov    %edx,%edi
  8014e1:	89 d6                	mov    %edx,%esi
  8014e3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801500:	89 cb                	mov    %ecx,%ebx
  801502:	89 cf                	mov    %ecx,%edi
  801504:	89 ce                	mov    %ecx,%esi
  801506:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801508:	85 c0                	test   %eax,%eax
  80150a:	7e 17                	jle    801523 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	50                   	push   %eax
  801510:	6a 03                	push   $0x3
  801512:	68 4f 38 80 00       	push   $0x80384f
  801517:	6a 23                	push   $0x23
  801519:	68 6c 38 80 00       	push   $0x80386c
  80151e:	e8 f2 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 02 00 00 00       	mov    $0x2,%eax
  80153b:	89 d1                	mov    %edx,%ecx
  80153d:	89 d3                	mov    %edx,%ebx
  80153f:	89 d7                	mov    %edx,%edi
  801541:	89 d6                	mov    %edx,%esi
  801543:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sys_yield>:

void
sys_yield(void)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 0b 00 00 00       	mov    $0xb,%eax
  80155a:	89 d1                	mov    %edx,%ecx
  80155c:	89 d3                	mov    %edx,%ebx
  80155e:	89 d7                	mov    %edx,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	57                   	push   %edi
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801572:	be 00 00 00 00       	mov    $0x0,%esi
  801577:	b8 04 00 00 00       	mov    $0x4,%eax
  80157c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157f:	8b 55 08             	mov    0x8(%ebp),%edx
  801582:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801585:	89 f7                	mov    %esi,%edi
  801587:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801589:	85 c0                	test   %eax,%eax
  80158b:	7e 17                	jle    8015a4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	50                   	push   %eax
  801591:	6a 04                	push   $0x4
  801593:	68 4f 38 80 00       	push   $0x80384f
  801598:	6a 23                	push   $0x23
  80159a:	68 6c 38 80 00       	push   $0x80386c
  80159f:	e8 71 f4 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	57                   	push   %edi
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015c6:	8b 75 18             	mov    0x18(%ebp),%esi
  8015c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	7e 17                	jle    8015e6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	50                   	push   %eax
  8015d3:	6a 05                	push   $0x5
  8015d5:	68 4f 38 80 00       	push   $0x80384f
  8015da:	6a 23                	push   $0x23
  8015dc:	68 6c 38 80 00       	push   $0x80386c
  8015e1:	e8 2f f4 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801601:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801604:	8b 55 08             	mov    0x8(%ebp),%edx
  801607:	89 df                	mov    %ebx,%edi
  801609:	89 de                	mov    %ebx,%esi
  80160b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	7e 17                	jle    801628 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	50                   	push   %eax
  801615:	6a 06                	push   $0x6
  801617:	68 4f 38 80 00       	push   $0x80384f
  80161c:	6a 23                	push   $0x23
  80161e:	68 6c 38 80 00       	push   $0x80386c
  801623:	e8 ed f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	57                   	push   %edi
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163e:	b8 08 00 00 00       	mov    $0x8,%eax
  801643:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801646:	8b 55 08             	mov    0x8(%ebp),%edx
  801649:	89 df                	mov    %ebx,%edi
  80164b:	89 de                	mov    %ebx,%esi
  80164d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80164f:	85 c0                	test   %eax,%eax
  801651:	7e 17                	jle    80166a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	50                   	push   %eax
  801657:	6a 08                	push   $0x8
  801659:	68 4f 38 80 00       	push   $0x80384f
  80165e:	6a 23                	push   $0x23
  801660:	68 6c 38 80 00       	push   $0x80386c
  801665:	e8 ab f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80166a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	57                   	push   %edi
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801680:	b8 09 00 00 00       	mov    $0x9,%eax
  801685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801688:	8b 55 08             	mov    0x8(%ebp),%edx
  80168b:	89 df                	mov    %ebx,%edi
  80168d:	89 de                	mov    %ebx,%esi
  80168f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801691:	85 c0                	test   %eax,%eax
  801693:	7e 17                	jle    8016ac <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	50                   	push   %eax
  801699:	6a 09                	push   $0x9
  80169b:	68 4f 38 80 00       	push   $0x80384f
  8016a0:	6a 23                	push   $0x23
  8016a2:	68 6c 38 80 00       	push   $0x80386c
  8016a7:	e8 69 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	57                   	push   %edi
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cd:	89 df                	mov    %ebx,%edi
  8016cf:	89 de                	mov    %ebx,%esi
  8016d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	7e 17                	jle    8016ee <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	50                   	push   %eax
  8016db:	6a 0a                	push   $0xa
  8016dd:	68 4f 38 80 00       	push   $0x80384f
  8016e2:	6a 23                	push   $0x23
  8016e4:	68 6c 38 80 00       	push   $0x80386c
  8016e9:	e8 27 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5f                   	pop    %edi
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016fc:	be 00 00 00 00       	mov    $0x0,%esi
  801701:	b8 0c 00 00 00       	mov    $0xc,%eax
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	8b 55 08             	mov    0x8(%ebp),%edx
  80170c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80170f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801712:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801722:	b9 00 00 00 00       	mov    $0x0,%ecx
  801727:	b8 0d 00 00 00       	mov    $0xd,%eax
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	89 cb                	mov    %ecx,%ebx
  801731:	89 cf                	mov    %ecx,%edi
  801733:	89 ce                	mov    %ecx,%esi
  801735:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801737:	85 c0                	test   %eax,%eax
  801739:	7e 17                	jle    801752 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	50                   	push   %eax
  80173f:	6a 0d                	push   $0xd
  801741:	68 4f 38 80 00       	push   $0x80384f
  801746:	6a 23                	push   $0x23
  801748:	68 6c 38 80 00       	push   $0x80386c
  80174d:	e8 c3 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5f                   	pop    %edi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801762:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  801764:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801768:	75 14                	jne    80177e <pgfault+0x24>
		panic("Not a page fault caused by write!");
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	68 7c 38 80 00       	push   $0x80387c
  801772:	6a 23                	push   $0x23
  801774:	68 3f 39 80 00       	push   $0x80393f
  801779:	e8 97 f2 ff ff       	call   800a15 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  80177e:	89 d8                	mov    %ebx,%eax
  801780:	c1 e8 0c             	shr    $0xc,%eax
  801783:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80178a:	f6 c4 08             	test   $0x8,%ah
  80178d:	75 14                	jne    8017a3 <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	68 a0 38 80 00       	push   $0x8038a0
  801797:	6a 2d                	push   $0x2d
  801799:	68 3f 39 80 00       	push   $0x80393f
  80179e:	e8 72 f2 ff ff       	call   800a15 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  8017a3:	e8 83 fd ff ff       	call   80152b <sys_getenvid>
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	6a 07                	push   $0x7
  8017ad:	68 00 f0 7f 00       	push   $0x7ff000
  8017b2:	50                   	push   %eax
  8017b3:	e8 b1 fd ff ff       	call   801569 <sys_page_alloc>
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	79 12                	jns    8017d1 <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  8017bf:	50                   	push   %eax
  8017c0:	68 4a 39 80 00       	push   $0x80394a
  8017c5:	6a 3b                	push   $0x3b
  8017c7:	68 3f 39 80 00       	push   $0x80393f
  8017cc:	e8 44 f2 ff ff       	call   800a15 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  8017d1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	68 00 10 00 00       	push   $0x1000
  8017df:	53                   	push   %ebx
  8017e0:	68 00 f0 7f 00       	push   $0x7ff000
  8017e5:	e8 0e fb ff ff       	call   8012f8 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  8017ea:	e8 3c fd ff ff       	call   80152b <sys_getenvid>
  8017ef:	89 c6                	mov    %eax,%esi
  8017f1:	e8 35 fd ff ff       	call   80152b <sys_getenvid>
  8017f6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8017fd:	53                   	push   %ebx
  8017fe:	56                   	push   %esi
  8017ff:	68 00 f0 7f 00       	push   $0x7ff000
  801804:	50                   	push   %eax
  801805:	e8 a2 fd ff ff       	call   8015ac <sys_page_map>
  80180a:	83 c4 20             	add    $0x20,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	79 12                	jns    801823 <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  801811:	50                   	push   %eax
  801812:	68 63 39 80 00       	push   $0x803963
  801817:	6a 48                	push   $0x48
  801819:	68 3f 39 80 00       	push   $0x80393f
  80181e:	e8 f2 f1 ff ff       	call   800a15 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  801823:	e8 03 fd ff ff       	call   80152b <sys_getenvid>
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	68 00 f0 7f 00       	push   $0x7ff000
  801830:	50                   	push   %eax
  801831:	e8 b8 fd ff ff       	call   8015ee <sys_page_unmap>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	79 12                	jns    80184f <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  80183d:	50                   	push   %eax
  80183e:	68 7a 39 80 00       	push   $0x80397a
  801843:	6a 4c                	push   $0x4c
  801845:	68 3f 39 80 00       	push   $0x80393f
  80184a:	e8 c6 f1 ff ff       	call   800a15 <_panic>
	}

	//panic("pgfault not implemented");
}
  80184f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	57                   	push   %edi
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  80185f:	68 5a 17 80 00       	push   $0x80175a
  801864:	e8 f3 15 00 00       	call   802e5c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801869:	b8 07 00 00 00       	mov    $0x7,%eax
  80186e:	cd 30                	int    $0x30
  801870:	89 c7                	mov    %eax,%edi
  801872:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	79 15                	jns    801891 <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  80187c:	50                   	push   %eax
  80187d:	68 93 39 80 00       	push   $0x803993
  801882:	68 a1 00 00 00       	push   $0xa1
  801887:	68 3f 39 80 00       	push   $0x80393f
  80188c:	e8 84 f1 ff ff       	call   800a15 <_panic>
  801891:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  801896:	85 c0                	test   %eax,%eax
  801898:	75 21                	jne    8018bb <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  80189a:	e8 8c fc ff ff       	call   80152b <sys_getenvid>
  80189f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018ac:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b6:	e9 c8 01 00 00       	jmp    801a83 <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8018bb:	89 d8                	mov    %ebx,%eax
  8018bd:	c1 e8 16             	shr    $0x16,%eax
  8018c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018c7:	a8 01                	test   $0x1,%al
  8018c9:	0f 84 23 01 00 00    	je     8019f2 <fork+0x19c>
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	c1 e8 0c             	shr    $0xc,%eax
  8018d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018db:	f6 c2 01             	test   $0x1,%dl
  8018de:	0f 84 0e 01 00 00    	je     8019f2 <fork+0x19c>
  8018e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018eb:	f6 c2 04             	test   $0x4,%dl
  8018ee:	0f 84 fe 00 00 00    	je     8019f2 <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  8018f4:	89 c6                	mov    %eax,%esi
  8018f6:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  8018f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801900:	f6 c6 04             	test   $0x4,%dh
  801903:	74 3f                	je     801944 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  801905:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80190c:	83 ec 0c             	sub    $0xc,%esp
  80190f:	25 07 0e 00 00       	and    $0xe07,%eax
  801914:	50                   	push   %eax
  801915:	56                   	push   %esi
  801916:	ff 75 e4             	pushl  -0x1c(%ebp)
  801919:	56                   	push   %esi
  80191a:	6a 00                	push   $0x0
  80191c:	e8 8b fc ff ff       	call   8015ac <sys_page_map>
  801921:	83 c4 20             	add    $0x20,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	0f 89 c6 00 00 00    	jns    8019f2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	50                   	push   %eax
  801930:	57                   	push   %edi
  801931:	6a 00                	push   $0x0
  801933:	68 d0 38 80 00       	push   $0x8038d0
  801938:	6a 6c                	push   $0x6c
  80193a:	68 3f 39 80 00       	push   $0x80393f
  80193f:	e8 d1 f0 ff ff       	call   800a15 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801944:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80194b:	f6 c2 02             	test   $0x2,%dl
  80194e:	75 0c                	jne    80195c <fork+0x106>
  801950:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801957:	f6 c4 08             	test   $0x8,%ah
  80195a:	74 66                	je     8019c2 <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	68 05 08 00 00       	push   $0x805
  801964:	56                   	push   %esi
  801965:	ff 75 e4             	pushl  -0x1c(%ebp)
  801968:	56                   	push   %esi
  801969:	6a 00                	push   $0x0
  80196b:	e8 3c fc ff ff       	call   8015ac <sys_page_map>
  801970:	83 c4 20             	add    $0x20,%esp
  801973:	85 c0                	test   %eax,%eax
  801975:	79 18                	jns    80198f <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801977:	83 ec 08             	sub    $0x8,%esp
  80197a:	50                   	push   %eax
  80197b:	57                   	push   %edi
  80197c:	6a 00                	push   $0x0
  80197e:	68 d0 38 80 00       	push   $0x8038d0
  801983:	6a 74                	push   $0x74
  801985:	68 3f 39 80 00       	push   $0x80393f
  80198a:	e8 86 f0 ff ff       	call   800a15 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	68 05 08 00 00       	push   $0x805
  801997:	56                   	push   %esi
  801998:	6a 00                	push   $0x0
  80199a:	56                   	push   %esi
  80199b:	6a 00                	push   $0x0
  80199d:	e8 0a fc ff ff       	call   8015ac <sys_page_map>
  8019a2:	83 c4 20             	add    $0x20,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	79 49                	jns    8019f2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	50                   	push   %eax
  8019ad:	6a 00                	push   $0x0
  8019af:	6a 00                	push   $0x0
  8019b1:	68 d0 38 80 00       	push   $0x8038d0
  8019b6:	6a 77                	push   $0x77
  8019b8:	68 3f 39 80 00       	push   $0x80393f
  8019bd:	e8 53 f0 ff ff       	call   800a15 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	6a 05                	push   $0x5
  8019c7:	56                   	push   %esi
  8019c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019cb:	56                   	push   %esi
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 d9 fb ff ff       	call   8015ac <sys_page_map>
  8019d3:	83 c4 20             	add    $0x20,%esp
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	79 18                	jns    8019f2 <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	50                   	push   %eax
  8019de:	57                   	push   %edi
  8019df:	6a 00                	push   $0x0
  8019e1:	68 d0 38 80 00       	push   $0x8038d0
  8019e6:	6a 7d                	push   $0x7d
  8019e8:	68 3f 39 80 00       	push   $0x80393f
  8019ed:	e8 23 f0 ff ff       	call   800a15 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8019f2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019fe:	0f 85 b7 fe ff ff    	jne    8018bb <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	6a 07                	push   $0x7
  801a09:	68 00 f0 bf ee       	push   $0xeebff000
  801a0e:	57                   	push   %edi
  801a0f:	e8 55 fb ff ff       	call   801569 <sys_page_alloc>
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	79 15                	jns    801a30 <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  801a1b:	50                   	push   %eax
  801a1c:	68 fc 38 80 00       	push   $0x8038fc
  801a21:	68 b4 00 00 00       	push   $0xb4
  801a26:	68 3f 39 80 00       	push   $0x80393f
  801a2b:	e8 e5 ef ff ff       	call   800a15 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	68 d0 2e 80 00       	push   $0x802ed0
  801a38:	57                   	push   %edi
  801a39:	e8 76 fc ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	79 15                	jns    801a5a <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801a45:	50                   	push   %eax
  801a46:	68 a9 39 80 00       	push   $0x8039a9
  801a4b:	68 ba 00 00 00       	push   $0xba
  801a50:	68 3f 39 80 00       	push   $0x80393f
  801a55:	e8 bb ef ff ff       	call   800a15 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	6a 02                	push   $0x2
  801a5f:	57                   	push   %edi
  801a60:	e8 cb fb ff ff       	call   801630 <sys_env_set_status>
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	79 15                	jns    801a81 <fork+0x22b>
		panic("Sys env set status error: %e", r);
  801a6c:	50                   	push   %eax
  801a6d:	68 c6 39 80 00       	push   $0x8039c6
  801a72:	68 bf 00 00 00       	push   $0xbf
  801a77:	68 3f 39 80 00       	push   $0x80393f
  801a7c:	e8 94 ef ff ff       	call   800a15 <_panic>
	}
	return eid;
  801a81:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  801a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5f                   	pop    %edi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <sfork>:

// Challenge!
int
sfork(void)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a91:	68 e3 39 80 00       	push   $0x8039e3
  801a96:	68 ca 00 00 00       	push   $0xca
  801a9b:	68 3f 39 80 00       	push   $0x80393f
  801aa0:	e8 70 ef ff ff       	call   800a15 <_panic>

00801aa5 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  801aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aae:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ab1:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ab3:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ab6:	83 3a 01             	cmpl   $0x1,(%edx)
  801ab9:	7e 09                	jle    801ac4 <argstart+0x1f>
  801abb:	ba 21 33 80 00       	mov    $0x803321,%edx
  801ac0:	85 c9                	test   %ecx,%ecx
  801ac2:	75 05                	jne    801ac9 <argstart+0x24>
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801acc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <argnext>:

int
argnext(struct Argstate *args)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 04             	sub    $0x4,%esp
  801adc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801adf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801ae6:	8b 43 08             	mov    0x8(%ebx),%eax
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	74 6f                	je     801b5c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801aed:	80 38 00             	cmpb   $0x0,(%eax)
  801af0:	75 4e                	jne    801b40 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801af2:	8b 0b                	mov    (%ebx),%ecx
  801af4:	83 39 01             	cmpl   $0x1,(%ecx)
  801af7:	74 55                	je     801b4e <argnext+0x79>
		    || args->argv[1][0] != '-'
  801af9:	8b 53 04             	mov    0x4(%ebx),%edx
  801afc:	8b 42 04             	mov    0x4(%edx),%eax
  801aff:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b02:	75 4a                	jne    801b4e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b04:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b08:	74 44                	je     801b4e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	8b 01                	mov    (%ecx),%eax
  801b15:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b1c:	50                   	push   %eax
  801b1d:	8d 42 08             	lea    0x8(%edx),%eax
  801b20:	50                   	push   %eax
  801b21:	83 c2 04             	add    $0x4,%edx
  801b24:	52                   	push   %edx
  801b25:	e8 ce f7 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801b2a:	8b 03                	mov    (%ebx),%eax
  801b2c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b2f:	8b 43 08             	mov    0x8(%ebx),%eax
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b38:	75 06                	jne    801b40 <argnext+0x6b>
  801b3a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b3e:	74 0e                	je     801b4e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b40:	8b 53 08             	mov    0x8(%ebx),%edx
  801b43:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b46:	83 c2 01             	add    $0x1,%edx
  801b49:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b4c:	eb 13                	jmp    801b61 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b4e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b5a:	eb 05                	jmp    801b61 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b70:	8b 43 08             	mov    0x8(%ebx),%eax
  801b73:	85 c0                	test   %eax,%eax
  801b75:	74 58                	je     801bcf <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b77:	80 38 00             	cmpb   $0x0,(%eax)
  801b7a:	74 0c                	je     801b88 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b7c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b7f:	c7 43 08 21 33 80 00 	movl   $0x803321,0x8(%ebx)
  801b86:	eb 42                	jmp    801bca <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b88:	8b 13                	mov    (%ebx),%edx
  801b8a:	83 3a 01             	cmpl   $0x1,(%edx)
  801b8d:	7e 2d                	jle    801bbc <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b8f:	8b 43 04             	mov    0x4(%ebx),%eax
  801b92:	8b 48 04             	mov    0x4(%eax),%ecx
  801b95:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b98:	83 ec 04             	sub    $0x4,%esp
  801b9b:	8b 12                	mov    (%edx),%edx
  801b9d:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801ba4:	52                   	push   %edx
  801ba5:	8d 50 08             	lea    0x8(%eax),%edx
  801ba8:	52                   	push   %edx
  801ba9:	83 c0 04             	add    $0x4,%eax
  801bac:	50                   	push   %eax
  801bad:	e8 46 f7 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801bb2:	8b 03                	mov    (%ebx),%eax
  801bb4:	83 28 01             	subl   $0x1,(%eax)
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	eb 0e                	jmp    801bca <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801bbc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801bc3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801bca:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bcd:	eb 05                	jmp    801bd4 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801bcf:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801bd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801be2:	8b 51 0c             	mov    0xc(%ecx),%edx
  801be5:	89 d0                	mov    %edx,%eax
  801be7:	85 d2                	test   %edx,%edx
  801be9:	75 0c                	jne    801bf7 <argvalue+0x1e>
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	51                   	push   %ecx
  801bef:	e8 72 ff ff ff       	call   801b66 <argnextvalue>
  801bf4:	83 c4 10             	add    $0x10,%esp
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bff:	05 00 00 00 30       	add    $0x30000000,%eax
  801c04:	c1 e8 0c             	shr    $0xc,%eax
}
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	05 00 00 00 30       	add    $0x30000000,%eax
  801c14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c19:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c26:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	c1 ea 16             	shr    $0x16,%edx
  801c30:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c37:	f6 c2 01             	test   $0x1,%dl
  801c3a:	74 11                	je     801c4d <fd_alloc+0x2d>
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	c1 ea 0c             	shr    $0xc,%edx
  801c41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c48:	f6 c2 01             	test   $0x1,%dl
  801c4b:	75 09                	jne    801c56 <fd_alloc+0x36>
			*fd_store = fd;
  801c4d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c54:	eb 17                	jmp    801c6d <fd_alloc+0x4d>
  801c56:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c5b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c60:	75 c9                	jne    801c2b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c62:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c68:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c75:	83 f8 1f             	cmp    $0x1f,%eax
  801c78:	77 36                	ja     801cb0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c7a:	c1 e0 0c             	shl    $0xc,%eax
  801c7d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c82:	89 c2                	mov    %eax,%edx
  801c84:	c1 ea 16             	shr    $0x16,%edx
  801c87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c8e:	f6 c2 01             	test   $0x1,%dl
  801c91:	74 24                	je     801cb7 <fd_lookup+0x48>
  801c93:	89 c2                	mov    %eax,%edx
  801c95:	c1 ea 0c             	shr    $0xc,%edx
  801c98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c9f:	f6 c2 01             	test   $0x1,%dl
  801ca2:	74 1a                	je     801cbe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca7:	89 02                	mov    %eax,(%edx)
	return 0;
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cae:	eb 13                	jmp    801cc3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cb5:	eb 0c                	jmp    801cc3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cbc:	eb 05                	jmp    801cc3 <fd_lookup+0x54>
  801cbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cce:	ba 78 3a 80 00       	mov    $0x803a78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801cd3:	eb 13                	jmp    801ce8 <dev_lookup+0x23>
  801cd5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801cd8:	39 08                	cmp    %ecx,(%eax)
  801cda:	75 0c                	jne    801ce8 <dev_lookup+0x23>
			*dev = devtab[i];
  801cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cdf:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce6:	eb 2e                	jmp    801d16 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ce8:	8b 02                	mov    (%edx),%eax
  801cea:	85 c0                	test   %eax,%eax
  801cec:	75 e7                	jne    801cd5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cee:	a1 24 54 80 00       	mov    0x805424,%eax
  801cf3:	8b 40 48             	mov    0x48(%eax),%eax
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	51                   	push   %ecx
  801cfa:	50                   	push   %eax
  801cfb:	68 fc 39 80 00       	push   $0x8039fc
  801d00:	e8 e9 ed ff ff       	call   800aee <cprintf>
	*dev = 0;
  801d05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 10             	sub    $0x10,%esp
  801d20:	8b 75 08             	mov    0x8(%ebp),%esi
  801d23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d30:	c1 e8 0c             	shr    $0xc,%eax
  801d33:	50                   	push   %eax
  801d34:	e8 36 ff ff ff       	call   801c6f <fd_lookup>
  801d39:	83 c4 08             	add    $0x8,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	78 05                	js     801d45 <fd_close+0x2d>
	    || fd != fd2)
  801d40:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d43:	74 0c                	je     801d51 <fd_close+0x39>
		return (must_exist ? r : 0);
  801d45:	84 db                	test   %bl,%bl
  801d47:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4c:	0f 44 c2             	cmove  %edx,%eax
  801d4f:	eb 41                	jmp    801d92 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d51:	83 ec 08             	sub    $0x8,%esp
  801d54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d57:	50                   	push   %eax
  801d58:	ff 36                	pushl  (%esi)
  801d5a:	e8 66 ff ff ff       	call   801cc5 <dev_lookup>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 1a                	js     801d82 <fd_close+0x6a>
		if (dev->dev_close)
  801d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d73:	85 c0                	test   %eax,%eax
  801d75:	74 0b                	je     801d82 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	56                   	push   %esi
  801d7b:	ff d0                	call   *%eax
  801d7d:	89 c3                	mov    %eax,%ebx
  801d7f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d82:	83 ec 08             	sub    $0x8,%esp
  801d85:	56                   	push   %esi
  801d86:	6a 00                	push   $0x0
  801d88:	e8 61 f8 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	89 d8                	mov    %ebx,%eax
}
  801d92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d95:	5b                   	pop    %ebx
  801d96:	5e                   	pop    %esi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	ff 75 08             	pushl  0x8(%ebp)
  801da6:	e8 c4 fe ff ff       	call   801c6f <fd_lookup>
  801dab:	83 c4 08             	add    $0x8,%esp
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 10                	js     801dc2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	6a 01                	push   $0x1
  801db7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dba:	e8 59 ff ff ff       	call   801d18 <fd_close>
  801dbf:	83 c4 10             	add    $0x10,%esp
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <close_all>:

void
close_all(void)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801dcb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801dd0:	83 ec 0c             	sub    $0xc,%esp
  801dd3:	53                   	push   %ebx
  801dd4:	e8 c0 ff ff ff       	call   801d99 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801dd9:	83 c3 01             	add    $0x1,%ebx
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	83 fb 20             	cmp    $0x20,%ebx
  801de2:	75 ec                	jne    801dd0 <close_all+0xc>
		close(i);
}
  801de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	57                   	push   %edi
  801ded:	56                   	push   %esi
  801dee:	53                   	push   %ebx
  801def:	83 ec 2c             	sub    $0x2c,%esp
  801df2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801df5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801df8:	50                   	push   %eax
  801df9:	ff 75 08             	pushl  0x8(%ebp)
  801dfc:	e8 6e fe ff ff       	call   801c6f <fd_lookup>
  801e01:	83 c4 08             	add    $0x8,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	0f 88 c1 00 00 00    	js     801ecd <dup+0xe4>
		return r;
	close(newfdnum);
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	56                   	push   %esi
  801e10:	e8 84 ff ff ff       	call   801d99 <close>

	newfd = INDEX2FD(newfdnum);
  801e15:	89 f3                	mov    %esi,%ebx
  801e17:	c1 e3 0c             	shl    $0xc,%ebx
  801e1a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e20:	83 c4 04             	add    $0x4,%esp
  801e23:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e26:	e8 de fd ff ff       	call   801c09 <fd2data>
  801e2b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e2d:	89 1c 24             	mov    %ebx,(%esp)
  801e30:	e8 d4 fd ff ff       	call   801c09 <fd2data>
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e3b:	89 f8                	mov    %edi,%eax
  801e3d:	c1 e8 16             	shr    $0x16,%eax
  801e40:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e47:	a8 01                	test   $0x1,%al
  801e49:	74 37                	je     801e82 <dup+0x99>
  801e4b:	89 f8                	mov    %edi,%eax
  801e4d:	c1 e8 0c             	shr    $0xc,%eax
  801e50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e57:	f6 c2 01             	test   $0x1,%dl
  801e5a:	74 26                	je     801e82 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e63:	83 ec 0c             	sub    $0xc,%esp
  801e66:	25 07 0e 00 00       	and    $0xe07,%eax
  801e6b:	50                   	push   %eax
  801e6c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e6f:	6a 00                	push   $0x0
  801e71:	57                   	push   %edi
  801e72:	6a 00                	push   $0x0
  801e74:	e8 33 f7 ff ff       	call   8015ac <sys_page_map>
  801e79:	89 c7                	mov    %eax,%edi
  801e7b:	83 c4 20             	add    $0x20,%esp
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 2e                	js     801eb0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e85:	89 d0                	mov    %edx,%eax
  801e87:	c1 e8 0c             	shr    $0xc,%eax
  801e8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e91:	83 ec 0c             	sub    $0xc,%esp
  801e94:	25 07 0e 00 00       	and    $0xe07,%eax
  801e99:	50                   	push   %eax
  801e9a:	53                   	push   %ebx
  801e9b:	6a 00                	push   $0x0
  801e9d:	52                   	push   %edx
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 07 f7 ff ff       	call   8015ac <sys_page_map>
  801ea5:	89 c7                	mov    %eax,%edi
  801ea7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801eaa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801eac:	85 ff                	test   %edi,%edi
  801eae:	79 1d                	jns    801ecd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801eb0:	83 ec 08             	sub    $0x8,%esp
  801eb3:	53                   	push   %ebx
  801eb4:	6a 00                	push   $0x0
  801eb6:	e8 33 f7 ff ff       	call   8015ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ebb:	83 c4 08             	add    $0x8,%esp
  801ebe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 26 f7 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	89 f8                	mov    %edi,%eax
}
  801ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed0:	5b                   	pop    %ebx
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	53                   	push   %ebx
  801ed9:	83 ec 14             	sub    $0x14,%esp
  801edc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801edf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ee2:	50                   	push   %eax
  801ee3:	53                   	push   %ebx
  801ee4:	e8 86 fd ff ff       	call   801c6f <fd_lookup>
  801ee9:	83 c4 08             	add    $0x8,%esp
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 6d                	js     801f5f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ef2:	83 ec 08             	sub    $0x8,%esp
  801ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef8:	50                   	push   %eax
  801ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801efc:	ff 30                	pushl  (%eax)
  801efe:	e8 c2 fd ff ff       	call   801cc5 <dev_lookup>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 4c                	js     801f56 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f0d:	8b 42 08             	mov    0x8(%edx),%eax
  801f10:	83 e0 03             	and    $0x3,%eax
  801f13:	83 f8 01             	cmp    $0x1,%eax
  801f16:	75 21                	jne    801f39 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f18:	a1 24 54 80 00       	mov    0x805424,%eax
  801f1d:	8b 40 48             	mov    0x48(%eax),%eax
  801f20:	83 ec 04             	sub    $0x4,%esp
  801f23:	53                   	push   %ebx
  801f24:	50                   	push   %eax
  801f25:	68 3d 3a 80 00       	push   $0x803a3d
  801f2a:	e8 bf eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f37:	eb 26                	jmp    801f5f <read+0x8a>
	}
	if (!dev->dev_read)
  801f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3c:	8b 40 08             	mov    0x8(%eax),%eax
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	74 17                	je     801f5a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	ff 75 10             	pushl  0x10(%ebp)
  801f49:	ff 75 0c             	pushl  0xc(%ebp)
  801f4c:	52                   	push   %edx
  801f4d:	ff d0                	call   *%eax
  801f4f:	89 c2                	mov    %eax,%edx
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	eb 09                	jmp    801f5f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f56:	89 c2                	mov    %eax,%edx
  801f58:	eb 05                	jmp    801f5f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f5a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f5f:	89 d0                	mov    %edx,%eax
  801f61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f66:	55                   	push   %ebp
  801f67:	89 e5                	mov    %esp,%ebp
  801f69:	57                   	push   %edi
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 0c             	sub    $0xc,%esp
  801f6f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f72:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f7a:	eb 21                	jmp    801f9d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f7c:	83 ec 04             	sub    $0x4,%esp
  801f7f:	89 f0                	mov    %esi,%eax
  801f81:	29 d8                	sub    %ebx,%eax
  801f83:	50                   	push   %eax
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	03 45 0c             	add    0xc(%ebp),%eax
  801f89:	50                   	push   %eax
  801f8a:	57                   	push   %edi
  801f8b:	e8 45 ff ff ff       	call   801ed5 <read>
		if (m < 0)
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	85 c0                	test   %eax,%eax
  801f95:	78 10                	js     801fa7 <readn+0x41>
			return m;
		if (m == 0)
  801f97:	85 c0                	test   %eax,%eax
  801f99:	74 0a                	je     801fa5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f9b:	01 c3                	add    %eax,%ebx
  801f9d:	39 f3                	cmp    %esi,%ebx
  801f9f:	72 db                	jb     801f7c <readn+0x16>
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	eb 02                	jmp    801fa7 <readn+0x41>
  801fa5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801faa:	5b                   	pop    %ebx
  801fab:	5e                   	pop    %esi
  801fac:	5f                   	pop    %edi
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	53                   	push   %ebx
  801fb3:	83 ec 14             	sub    $0x14,%esp
  801fb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fbc:	50                   	push   %eax
  801fbd:	53                   	push   %ebx
  801fbe:	e8 ac fc ff ff       	call   801c6f <fd_lookup>
  801fc3:	83 c4 08             	add    $0x8,%esp
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 68                	js     802034 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fcc:	83 ec 08             	sub    $0x8,%esp
  801fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd2:	50                   	push   %eax
  801fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd6:	ff 30                	pushl  (%eax)
  801fd8:	e8 e8 fc ff ff       	call   801cc5 <dev_lookup>
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 47                	js     80202b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801feb:	75 21                	jne    80200e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fed:	a1 24 54 80 00       	mov    0x805424,%eax
  801ff2:	8b 40 48             	mov    0x48(%eax),%eax
  801ff5:	83 ec 04             	sub    $0x4,%esp
  801ff8:	53                   	push   %ebx
  801ff9:	50                   	push   %eax
  801ffa:	68 59 3a 80 00       	push   $0x803a59
  801fff:	e8 ea ea ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80200c:	eb 26                	jmp    802034 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80200e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802011:	8b 52 0c             	mov    0xc(%edx),%edx
  802014:	85 d2                	test   %edx,%edx
  802016:	74 17                	je     80202f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802018:	83 ec 04             	sub    $0x4,%esp
  80201b:	ff 75 10             	pushl  0x10(%ebp)
  80201e:	ff 75 0c             	pushl  0xc(%ebp)
  802021:	50                   	push   %eax
  802022:	ff d2                	call   *%edx
  802024:	89 c2                	mov    %eax,%edx
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	eb 09                	jmp    802034 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80202b:	89 c2                	mov    %eax,%edx
  80202d:	eb 05                	jmp    802034 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80202f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802034:	89 d0                	mov    %edx,%eax
  802036:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <seek>:

int
seek(int fdnum, off_t offset)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802041:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802044:	50                   	push   %eax
  802045:	ff 75 08             	pushl  0x8(%ebp)
  802048:	e8 22 fc ff ff       	call   801c6f <fd_lookup>
  80204d:	83 c4 08             	add    $0x8,%esp
  802050:	85 c0                	test   %eax,%eax
  802052:	78 0e                	js     802062 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802054:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802057:	8b 55 0c             	mov    0xc(%ebp),%edx
  80205a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80205d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802062:	c9                   	leave  
  802063:	c3                   	ret    

00802064 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	53                   	push   %ebx
  802068:	83 ec 14             	sub    $0x14,%esp
  80206b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80206e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802071:	50                   	push   %eax
  802072:	53                   	push   %ebx
  802073:	e8 f7 fb ff ff       	call   801c6f <fd_lookup>
  802078:	83 c4 08             	add    $0x8,%esp
  80207b:	89 c2                	mov    %eax,%edx
  80207d:	85 c0                	test   %eax,%eax
  80207f:	78 65                	js     8020e6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802081:	83 ec 08             	sub    $0x8,%esp
  802084:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802087:	50                   	push   %eax
  802088:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208b:	ff 30                	pushl  (%eax)
  80208d:	e8 33 fc ff ff       	call   801cc5 <dev_lookup>
  802092:	83 c4 10             	add    $0x10,%esp
  802095:	85 c0                	test   %eax,%eax
  802097:	78 44                	js     8020dd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802099:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80209c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020a0:	75 21                	jne    8020c3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020a2:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020a7:	8b 40 48             	mov    0x48(%eax),%eax
  8020aa:	83 ec 04             	sub    $0x4,%esp
  8020ad:	53                   	push   %ebx
  8020ae:	50                   	push   %eax
  8020af:	68 1c 3a 80 00       	push   $0x803a1c
  8020b4:	e8 35 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8020c1:	eb 23                	jmp    8020e6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8020c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020c6:	8b 52 18             	mov    0x18(%edx),%edx
  8020c9:	85 d2                	test   %edx,%edx
  8020cb:	74 14                	je     8020e1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8020cd:	83 ec 08             	sub    $0x8,%esp
  8020d0:	ff 75 0c             	pushl  0xc(%ebp)
  8020d3:	50                   	push   %eax
  8020d4:	ff d2                	call   *%edx
  8020d6:	89 c2                	mov    %eax,%edx
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	eb 09                	jmp    8020e6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020dd:	89 c2                	mov    %eax,%edx
  8020df:	eb 05                	jmp    8020e6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8020e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020eb:	c9                   	leave  
  8020ec:	c3                   	ret    

008020ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	53                   	push   %ebx
  8020f1:	83 ec 14             	sub    $0x14,%esp
  8020f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020fa:	50                   	push   %eax
  8020fb:	ff 75 08             	pushl  0x8(%ebp)
  8020fe:	e8 6c fb ff ff       	call   801c6f <fd_lookup>
  802103:	83 c4 08             	add    $0x8,%esp
  802106:	89 c2                	mov    %eax,%edx
  802108:	85 c0                	test   %eax,%eax
  80210a:	78 58                	js     802164 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80210c:	83 ec 08             	sub    $0x8,%esp
  80210f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802112:	50                   	push   %eax
  802113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802116:	ff 30                	pushl  (%eax)
  802118:	e8 a8 fb ff ff       	call   801cc5 <dev_lookup>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	78 37                	js     80215b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802127:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80212b:	74 32                	je     80215f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80212d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802130:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802137:	00 00 00 
	stat->st_isdir = 0;
  80213a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802141:	00 00 00 
	stat->st_dev = dev;
  802144:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80214a:	83 ec 08             	sub    $0x8,%esp
  80214d:	53                   	push   %ebx
  80214e:	ff 75 f0             	pushl  -0x10(%ebp)
  802151:	ff 50 14             	call   *0x14(%eax)
  802154:	89 c2                	mov    %eax,%edx
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	eb 09                	jmp    802164 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80215b:	89 c2                	mov    %eax,%edx
  80215d:	eb 05                	jmp    802164 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80215f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802164:	89 d0                	mov    %edx,%eax
  802166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	56                   	push   %esi
  80216f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802170:	83 ec 08             	sub    $0x8,%esp
  802173:	6a 00                	push   $0x0
  802175:	ff 75 08             	pushl  0x8(%ebp)
  802178:	e8 d6 01 00 00       	call   802353 <open>
  80217d:	89 c3                	mov    %eax,%ebx
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	85 c0                	test   %eax,%eax
  802184:	78 1b                	js     8021a1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802186:	83 ec 08             	sub    $0x8,%esp
  802189:	ff 75 0c             	pushl  0xc(%ebp)
  80218c:	50                   	push   %eax
  80218d:	e8 5b ff ff ff       	call   8020ed <fstat>
  802192:	89 c6                	mov    %eax,%esi
	close(fd);
  802194:	89 1c 24             	mov    %ebx,(%esp)
  802197:	e8 fd fb ff ff       	call   801d99 <close>
	return r;
  80219c:	83 c4 10             	add    $0x10,%esp
  80219f:	89 f0                	mov    %esi,%eax
}
  8021a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	89 c6                	mov    %eax,%esi
  8021af:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021b1:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8021b8:	75 12                	jne    8021cc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021ba:	83 ec 0c             	sub    $0xc,%esp
  8021bd:	6a 01                	push   $0x1
  8021bf:	e8 1c 0e 00 00       	call   802fe0 <ipc_find_env>
  8021c4:	a3 20 54 80 00       	mov    %eax,0x805420
  8021c9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021cc:	6a 07                	push   $0x7
  8021ce:	68 00 60 80 00       	push   $0x806000
  8021d3:	56                   	push   %esi
  8021d4:	ff 35 20 54 80 00    	pushl  0x805420
  8021da:	e8 ad 0d 00 00       	call   802f8c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8021df:	83 c4 0c             	add    $0xc,%esp
  8021e2:	6a 00                	push   $0x0
  8021e4:	53                   	push   %ebx
  8021e5:	6a 00                	push   $0x0
  8021e7:	e8 08 0d 00 00       	call   802ef4 <ipc_recv>
}
  8021ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    

008021f3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ff:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802204:	8b 45 0c             	mov    0xc(%ebp),%eax
  802207:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80220c:	ba 00 00 00 00       	mov    $0x0,%edx
  802211:	b8 02 00 00 00       	mov    $0x2,%eax
  802216:	e8 8d ff ff ff       	call   8021a8 <fsipc>
}
  80221b:	c9                   	leave  
  80221c:	c3                   	ret    

0080221d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80221d:	55                   	push   %ebp
  80221e:	89 e5                	mov    %esp,%ebp
  802220:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802223:	8b 45 08             	mov    0x8(%ebp),%eax
  802226:	8b 40 0c             	mov    0xc(%eax),%eax
  802229:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80222e:	ba 00 00 00 00       	mov    $0x0,%edx
  802233:	b8 06 00 00 00       	mov    $0x6,%eax
  802238:	e8 6b ff ff ff       	call   8021a8 <fsipc>
}
  80223d:	c9                   	leave  
  80223e:	c3                   	ret    

0080223f <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	53                   	push   %ebx
  802243:	83 ec 04             	sub    $0x4,%esp
  802246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802249:	8b 45 08             	mov    0x8(%ebp),%eax
  80224c:	8b 40 0c             	mov    0xc(%eax),%eax
  80224f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802254:	ba 00 00 00 00       	mov    $0x0,%edx
  802259:	b8 05 00 00 00       	mov    $0x5,%eax
  80225e:	e8 45 ff ff ff       	call   8021a8 <fsipc>
  802263:	85 c0                	test   %eax,%eax
  802265:	78 2c                	js     802293 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802267:	83 ec 08             	sub    $0x8,%esp
  80226a:	68 00 60 80 00       	push   $0x806000
  80226f:	53                   	push   %ebx
  802270:	e8 f1 ee ff ff       	call   801166 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802275:	a1 80 60 80 00       	mov    0x806080,%eax
  80227a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802280:	a1 84 60 80 00       	mov    0x806084,%eax
  802285:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802296:	c9                   	leave  
  802297:	c3                   	ret    

00802298 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	83 ec 0c             	sub    $0xc,%esp
  80229e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8022a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8022a7:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  8022ad:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  8022b2:	50                   	push   %eax
  8022b3:	ff 75 0c             	pushl  0xc(%ebp)
  8022b6:	68 08 60 80 00       	push   $0x806008
  8022bb:	e8 38 f0 ff ff       	call   8012f8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8022c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8022ca:	e8 d9 fe ff ff       	call   8021a8 <fsipc>
	//panic("devfile_write not implemented");
}
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    

008022d1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	56                   	push   %esi
  8022d5:	53                   	push   %ebx
  8022d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8022df:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022e4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8022f4:	e8 af fe ff ff       	call   8021a8 <fsipc>
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	78 4b                	js     80234a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022ff:	39 c6                	cmp    %eax,%esi
  802301:	73 16                	jae    802319 <devfile_read+0x48>
  802303:	68 88 3a 80 00       	push   $0x803a88
  802308:	68 3a 34 80 00       	push   $0x80343a
  80230d:	6a 7c                	push   $0x7c
  80230f:	68 8f 3a 80 00       	push   $0x803a8f
  802314:	e8 fc e6 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  802319:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80231e:	7e 16                	jle    802336 <devfile_read+0x65>
  802320:	68 9a 3a 80 00       	push   $0x803a9a
  802325:	68 3a 34 80 00       	push   $0x80343a
  80232a:	6a 7d                	push   $0x7d
  80232c:	68 8f 3a 80 00       	push   $0x803a8f
  802331:	e8 df e6 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802336:	83 ec 04             	sub    $0x4,%esp
  802339:	50                   	push   %eax
  80233a:	68 00 60 80 00       	push   $0x806000
  80233f:	ff 75 0c             	pushl  0xc(%ebp)
  802342:	e8 b1 ef ff ff       	call   8012f8 <memmove>
	return r;
  802347:	83 c4 10             	add    $0x10,%esp
}
  80234a:	89 d8                	mov    %ebx,%eax
  80234c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80234f:	5b                   	pop    %ebx
  802350:	5e                   	pop    %esi
  802351:	5d                   	pop    %ebp
  802352:	c3                   	ret    

00802353 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	53                   	push   %ebx
  802357:	83 ec 20             	sub    $0x20,%esp
  80235a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80235d:	53                   	push   %ebx
  80235e:	e8 ca ed ff ff       	call   80112d <strlen>
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80236b:	7f 67                	jg     8023d4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80236d:	83 ec 0c             	sub    $0xc,%esp
  802370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802373:	50                   	push   %eax
  802374:	e8 a7 f8 ff ff       	call   801c20 <fd_alloc>
  802379:	83 c4 10             	add    $0x10,%esp
		return r;
  80237c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80237e:	85 c0                	test   %eax,%eax
  802380:	78 57                	js     8023d9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802382:	83 ec 08             	sub    $0x8,%esp
  802385:	53                   	push   %ebx
  802386:	68 00 60 80 00       	push   $0x806000
  80238b:	e8 d6 ed ff ff       	call   801166 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802390:	8b 45 0c             	mov    0xc(%ebp),%eax
  802393:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802398:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80239b:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a0:	e8 03 fe ff ff       	call   8021a8 <fsipc>
  8023a5:	89 c3                	mov    %eax,%ebx
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	79 14                	jns    8023c2 <open+0x6f>
		fd_close(fd, 0);
  8023ae:	83 ec 08             	sub    $0x8,%esp
  8023b1:	6a 00                	push   $0x0
  8023b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023b6:	e8 5d f9 ff ff       	call   801d18 <fd_close>
		return r;
  8023bb:	83 c4 10             	add    $0x10,%esp
  8023be:	89 da                	mov    %ebx,%edx
  8023c0:	eb 17                	jmp    8023d9 <open+0x86>
	}

	return fd2num(fd);
  8023c2:	83 ec 0c             	sub    $0xc,%esp
  8023c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c8:	e8 2c f8 ff ff       	call   801bf9 <fd2num>
  8023cd:	89 c2                	mov    %eax,%edx
  8023cf:	83 c4 10             	add    $0x10,%esp
  8023d2:	eb 05                	jmp    8023d9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023d4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023d9:	89 d0                	mov    %edx,%eax
  8023db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023de:	c9                   	leave  
  8023df:	c3                   	ret    

008023e0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023e0:	55                   	push   %ebp
  8023e1:	89 e5                	mov    %esp,%ebp
  8023e3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8023eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8023f0:	e8 b3 fd ff ff       	call   8021a8 <fsipc>
}
  8023f5:	c9                   	leave  
  8023f6:	c3                   	ret    

008023f7 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023f7:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023fb:	7e 37                	jle    802434 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	53                   	push   %ebx
  802401:	83 ec 08             	sub    $0x8,%esp
  802404:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802406:	ff 70 04             	pushl  0x4(%eax)
  802409:	8d 40 10             	lea    0x10(%eax),%eax
  80240c:	50                   	push   %eax
  80240d:	ff 33                	pushl  (%ebx)
  80240f:	e8 9b fb ff ff       	call   801faf <write>
		if (result > 0)
  802414:	83 c4 10             	add    $0x10,%esp
  802417:	85 c0                	test   %eax,%eax
  802419:	7e 03                	jle    80241e <writebuf+0x27>
			b->result += result;
  80241b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80241e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802421:	74 0d                	je     802430 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802423:	85 c0                	test   %eax,%eax
  802425:	ba 00 00 00 00       	mov    $0x0,%edx
  80242a:	0f 4f c2             	cmovg  %edx,%eax
  80242d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802433:	c9                   	leave  
  802434:	f3 c3                	repz ret 

00802436 <putch>:

static void
putch(int ch, void *thunk)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	53                   	push   %ebx
  80243a:	83 ec 04             	sub    $0x4,%esp
  80243d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802440:	8b 53 04             	mov    0x4(%ebx),%edx
  802443:	8d 42 01             	lea    0x1(%edx),%eax
  802446:	89 43 04             	mov    %eax,0x4(%ebx)
  802449:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80244c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802450:	3d 00 01 00 00       	cmp    $0x100,%eax
  802455:	75 0e                	jne    802465 <putch+0x2f>
		writebuf(b);
  802457:	89 d8                	mov    %ebx,%eax
  802459:	e8 99 ff ff ff       	call   8023f7 <writebuf>
		b->idx = 0;
  80245e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802465:	83 c4 04             	add    $0x4,%esp
  802468:	5b                   	pop    %ebx
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    

0080246b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802474:	8b 45 08             	mov    0x8(%ebp),%eax
  802477:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80247d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802484:	00 00 00 
	b.result = 0;
  802487:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80248e:	00 00 00 
	b.error = 1;
  802491:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802498:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80249b:	ff 75 10             	pushl  0x10(%ebp)
  80249e:	ff 75 0c             	pushl  0xc(%ebp)
  8024a1:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024a7:	50                   	push   %eax
  8024a8:	68 36 24 80 00       	push   $0x802436
  8024ad:	e8 73 e7 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024bc:	7e 0b                	jle    8024c9 <vfprintf+0x5e>
		writebuf(&b);
  8024be:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024c4:	e8 2e ff ff ff       	call   8023f7 <writebuf>

	return (b.result ? b.result : b.error);
  8024c9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024cf:	85 c0                	test   %eax,%eax
  8024d1:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024e0:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024e3:	50                   	push   %eax
  8024e4:	ff 75 0c             	pushl  0xc(%ebp)
  8024e7:	ff 75 08             	pushl  0x8(%ebp)
  8024ea:	e8 7c ff ff ff       	call   80246b <vfprintf>
	va_end(ap);

	return cnt;
}
  8024ef:	c9                   	leave  
  8024f0:	c3                   	ret    

008024f1 <printf>:

int
printf(const char *fmt, ...)
{
  8024f1:	55                   	push   %ebp
  8024f2:	89 e5                	mov    %esp,%ebp
  8024f4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024fa:	50                   	push   %eax
  8024fb:	ff 75 08             	pushl  0x8(%ebp)
  8024fe:	6a 01                	push   $0x1
  802500:	e8 66 ff ff ff       	call   80246b <vfprintf>
	va_end(ap);

	return cnt;
}
  802505:	c9                   	leave  
  802506:	c3                   	ret    

00802507 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	57                   	push   %edi
  80250b:	56                   	push   %esi
  80250c:	53                   	push   %ebx
  80250d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802513:	6a 00                	push   $0x0
  802515:	ff 75 08             	pushl  0x8(%ebp)
  802518:	e8 36 fe ff ff       	call   802353 <open>
  80251d:	89 c7                	mov    %eax,%edi
  80251f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802525:	83 c4 10             	add    $0x10,%esp
  802528:	85 c0                	test   %eax,%eax
  80252a:	0f 88 a4 04 00 00    	js     8029d4 <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802530:	83 ec 04             	sub    $0x4,%esp
  802533:	68 00 02 00 00       	push   $0x200
  802538:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80253e:	50                   	push   %eax
  80253f:	57                   	push   %edi
  802540:	e8 21 fa ff ff       	call   801f66 <readn>
  802545:	83 c4 10             	add    $0x10,%esp
  802548:	3d 00 02 00 00       	cmp    $0x200,%eax
  80254d:	75 0c                	jne    80255b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80254f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802556:	45 4c 46 
  802559:	74 33                	je     80258e <spawn+0x87>
		close(fd);
  80255b:	83 ec 0c             	sub    $0xc,%esp
  80255e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802564:	e8 30 f8 ff ff       	call   801d99 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802569:	83 c4 0c             	add    $0xc,%esp
  80256c:	68 7f 45 4c 46       	push   $0x464c457f
  802571:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802577:	68 a6 3a 80 00       	push   $0x803aa6
  80257c:	e8 6d e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  802581:	83 c4 10             	add    $0x10,%esp
  802584:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  802589:	e9 a6 04 00 00       	jmp    802a34 <spawn+0x52d>
  80258e:	b8 07 00 00 00       	mov    $0x7,%eax
  802593:	cd 30                	int    $0x30
  802595:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80259b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025a1:	85 c0                	test   %eax,%eax
  8025a3:	0f 88 33 04 00 00    	js     8029dc <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025a9:	89 c6                	mov    %eax,%esi
  8025ab:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025b1:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8025b4:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025ba:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8025c0:	b9 11 00 00 00       	mov    $0x11,%ecx
  8025c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8025c7:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025cd:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025d3:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025d8:	be 00 00 00 00       	mov    $0x0,%esi
  8025dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025e0:	eb 13                	jmp    8025f5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025e2:	83 ec 0c             	sub    $0xc,%esp
  8025e5:	50                   	push   %eax
  8025e6:	e8 42 eb ff ff       	call   80112d <strlen>
  8025eb:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025ef:	83 c3 01             	add    $0x1,%ebx
  8025f2:	83 c4 10             	add    $0x10,%esp
  8025f5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025fc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025ff:	85 c0                	test   %eax,%eax
  802601:	75 df                	jne    8025e2 <spawn+0xdb>
  802603:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802609:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80260f:	bf 00 10 40 00       	mov    $0x401000,%edi
  802614:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802616:	89 fa                	mov    %edi,%edx
  802618:	83 e2 fc             	and    $0xfffffffc,%edx
  80261b:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802622:	29 c2                	sub    %eax,%edx
  802624:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80262a:	8d 42 f8             	lea    -0x8(%edx),%eax
  80262d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802632:	0f 86 b4 03 00 00    	jbe    8029ec <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802638:	83 ec 04             	sub    $0x4,%esp
  80263b:	6a 07                	push   $0x7
  80263d:	68 00 00 40 00       	push   $0x400000
  802642:	6a 00                	push   $0x0
  802644:	e8 20 ef ff ff       	call   801569 <sys_page_alloc>
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	85 c0                	test   %eax,%eax
  80264e:	0f 88 9f 03 00 00    	js     8029f3 <spawn+0x4ec>
  802654:	be 00 00 00 00       	mov    $0x0,%esi
  802659:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80265f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802662:	eb 30                	jmp    802694 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802664:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80266a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802670:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802673:	83 ec 08             	sub    $0x8,%esp
  802676:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802679:	57                   	push   %edi
  80267a:	e8 e7 ea ff ff       	call   801166 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80267f:	83 c4 04             	add    $0x4,%esp
  802682:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802685:	e8 a3 ea ff ff       	call   80112d <strlen>
  80268a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80268e:	83 c6 01             	add    $0x1,%esi
  802691:	83 c4 10             	add    $0x10,%esp
  802694:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80269a:	7f c8                	jg     802664 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80269c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8026a2:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8026a8:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8026af:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8026b5:	74 19                	je     8026d0 <spawn+0x1c9>
  8026b7:	68 1c 3b 80 00       	push   $0x803b1c
  8026bc:	68 3a 34 80 00       	push   $0x80343a
  8026c1:	68 f1 00 00 00       	push   $0xf1
  8026c6:	68 c0 3a 80 00       	push   $0x803ac0
  8026cb:	e8 45 e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026d0:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026d6:	89 f8                	mov    %edi,%eax
  8026d8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8026dd:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026e0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026e6:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026e9:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8026ef:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026f5:	83 ec 0c             	sub    $0xc,%esp
  8026f8:	6a 07                	push   $0x7
  8026fa:	68 00 d0 bf ee       	push   $0xeebfd000
  8026ff:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802705:	68 00 00 40 00       	push   $0x400000
  80270a:	6a 00                	push   $0x0
  80270c:	e8 9b ee ff ff       	call   8015ac <sys_page_map>
  802711:	89 c3                	mov    %eax,%ebx
  802713:	83 c4 20             	add    $0x20,%esp
  802716:	85 c0                	test   %eax,%eax
  802718:	0f 88 04 03 00 00    	js     802a22 <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80271e:	83 ec 08             	sub    $0x8,%esp
  802721:	68 00 00 40 00       	push   $0x400000
  802726:	6a 00                	push   $0x0
  802728:	e8 c1 ee ff ff       	call   8015ee <sys_page_unmap>
  80272d:	89 c3                	mov    %eax,%ebx
  80272f:	83 c4 10             	add    $0x10,%esp
  802732:	85 c0                	test   %eax,%eax
  802734:	0f 88 e8 02 00 00    	js     802a22 <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80273a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802740:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  802747:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80274d:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802754:	00 00 00 
  802757:	e9 88 01 00 00       	jmp    8028e4 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80275c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802762:	83 38 01             	cmpl   $0x1,(%eax)
  802765:	0f 85 6b 01 00 00    	jne    8028d6 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80276b:	89 c7                	mov    %eax,%edi
  80276d:	8b 40 18             	mov    0x18(%eax),%eax
  802770:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802776:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802779:	83 f8 01             	cmp    $0x1,%eax
  80277c:	19 c0                	sbb    %eax,%eax
  80277e:	83 e0 fe             	and    $0xfffffffe,%eax
  802781:	83 c0 07             	add    $0x7,%eax
  802784:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80278a:	89 f8                	mov    %edi,%eax
  80278c:	8b 7f 04             	mov    0x4(%edi),%edi
  80278f:	89 f9                	mov    %edi,%ecx
  802791:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  802797:	8b 78 10             	mov    0x10(%eax),%edi
  80279a:	8b 50 14             	mov    0x14(%eax),%edx
  80279d:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8027a3:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8027a6:	89 f0                	mov    %esi,%eax
  8027a8:	25 ff 0f 00 00       	and    $0xfff,%eax
  8027ad:	74 14                	je     8027c3 <spawn+0x2bc>
		va -= i;
  8027af:	29 c6                	sub    %eax,%esi
		memsz += i;
  8027b1:	01 c2                	add    %eax,%edx
  8027b3:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8027b9:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8027bb:	29 c1                	sub    %eax,%ecx
  8027bd:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027c8:	e9 f7 00 00 00       	jmp    8028c4 <spawn+0x3bd>
		if (i >= filesz) {
  8027cd:	39 df                	cmp    %ebx,%edi
  8027cf:	77 27                	ja     8027f8 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8027d1:	83 ec 04             	sub    $0x4,%esp
  8027d4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027da:	56                   	push   %esi
  8027db:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027e1:	e8 83 ed ff ff       	call   801569 <sys_page_alloc>
  8027e6:	83 c4 10             	add    $0x10,%esp
  8027e9:	85 c0                	test   %eax,%eax
  8027eb:	0f 89 c7 00 00 00    	jns    8028b8 <spawn+0x3b1>
  8027f1:	89 c3                	mov    %eax,%ebx
  8027f3:	e9 09 02 00 00       	jmp    802a01 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027f8:	83 ec 04             	sub    $0x4,%esp
  8027fb:	6a 07                	push   $0x7
  8027fd:	68 00 00 40 00       	push   $0x400000
  802802:	6a 00                	push   $0x0
  802804:	e8 60 ed ff ff       	call   801569 <sys_page_alloc>
  802809:	83 c4 10             	add    $0x10,%esp
  80280c:	85 c0                	test   %eax,%eax
  80280e:	0f 88 e3 01 00 00    	js     8029f7 <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802814:	83 ec 08             	sub    $0x8,%esp
  802817:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80281d:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802823:	50                   	push   %eax
  802824:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80282a:	e8 0c f8 ff ff       	call   80203b <seek>
  80282f:	83 c4 10             	add    $0x10,%esp
  802832:	85 c0                	test   %eax,%eax
  802834:	0f 88 c1 01 00 00    	js     8029fb <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80283a:	83 ec 04             	sub    $0x4,%esp
  80283d:	89 f8                	mov    %edi,%eax
  80283f:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802845:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80284a:	ba 00 10 00 00       	mov    $0x1000,%edx
  80284f:	0f 47 c2             	cmova  %edx,%eax
  802852:	50                   	push   %eax
  802853:	68 00 00 40 00       	push   $0x400000
  802858:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80285e:	e8 03 f7 ff ff       	call   801f66 <readn>
  802863:	83 c4 10             	add    $0x10,%esp
  802866:	85 c0                	test   %eax,%eax
  802868:	0f 88 91 01 00 00    	js     8029ff <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80286e:	83 ec 0c             	sub    $0xc,%esp
  802871:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802877:	56                   	push   %esi
  802878:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80287e:	68 00 00 40 00       	push   $0x400000
  802883:	6a 00                	push   $0x0
  802885:	e8 22 ed ff ff       	call   8015ac <sys_page_map>
  80288a:	83 c4 20             	add    $0x20,%esp
  80288d:	85 c0                	test   %eax,%eax
  80288f:	79 15                	jns    8028a6 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802891:	50                   	push   %eax
  802892:	68 cc 3a 80 00       	push   $0x803acc
  802897:	68 24 01 00 00       	push   $0x124
  80289c:	68 c0 3a 80 00       	push   $0x803ac0
  8028a1:	e8 6f e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  8028a6:	83 ec 08             	sub    $0x8,%esp
  8028a9:	68 00 00 40 00       	push   $0x400000
  8028ae:	6a 00                	push   $0x0
  8028b0:	e8 39 ed ff ff       	call   8015ee <sys_page_unmap>
  8028b5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8028b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028be:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8028c4:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8028ca:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8028d0:	0f 87 f7 fe ff ff    	ja     8027cd <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028d6:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028dd:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028e4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028eb:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028f1:	0f 8c 65 fe ff ff    	jl     80275c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028f7:	83 ec 0c             	sub    $0xc,%esp
  8028fa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802900:	e8 94 f4 ff ff       	call   801d99 <close>
  802905:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802908:	bb 00 00 00 00       	mov    $0x0,%ebx
  80290d:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  802913:	89 d8                	mov    %ebx,%eax
  802915:	c1 e8 16             	shr    $0x16,%eax
  802918:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80291f:	a8 01                	test   $0x1,%al
  802921:	74 46                	je     802969 <spawn+0x462>
  802923:	89 d8                	mov    %ebx,%eax
  802925:	c1 e8 0c             	shr    $0xc,%eax
  802928:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80292f:	f6 c2 01             	test   $0x1,%dl
  802932:	74 35                	je     802969 <spawn+0x462>
			(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  802934:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  80293b:	f6 c2 04             	test   $0x4,%dl
  80293e:	74 29                	je     802969 <spawn+0x462>
			(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  802940:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802947:	f6 c6 04             	test   $0x4,%dh
  80294a:	74 1d                	je     802969 <spawn+0x462>
			sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80294c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802953:	83 ec 0c             	sub    $0xc,%esp
  802956:	25 07 0e 00 00       	and    $0xe07,%eax
  80295b:	50                   	push   %eax
  80295c:	53                   	push   %ebx
  80295d:	56                   	push   %esi
  80295e:	53                   	push   %ebx
  80295f:	6a 00                	push   $0x0
  802961:	e8 46 ec ff ff       	call   8015ac <sys_page_map>
  802966:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802969:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80296f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802975:	75 9c                	jne    802913 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802977:	83 ec 08             	sub    $0x8,%esp
  80297a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802980:	50                   	push   %eax
  802981:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802987:	e8 e6 ec ff ff       	call   801672 <sys_env_set_trapframe>
  80298c:	83 c4 10             	add    $0x10,%esp
  80298f:	85 c0                	test   %eax,%eax
  802991:	79 15                	jns    8029a8 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  802993:	50                   	push   %eax
  802994:	68 e9 3a 80 00       	push   $0x803ae9
  802999:	68 85 00 00 00       	push   $0x85
  80299e:	68 c0 3a 80 00       	push   $0x803ac0
  8029a3:	e8 6d e0 ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029a8:	83 ec 08             	sub    $0x8,%esp
  8029ab:	6a 02                	push   $0x2
  8029ad:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029b3:	e8 78 ec ff ff       	call   801630 <sys_env_set_status>
  8029b8:	83 c4 10             	add    $0x10,%esp
  8029bb:	85 c0                	test   %eax,%eax
  8029bd:	79 25                	jns    8029e4 <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  8029bf:	50                   	push   %eax
  8029c0:	68 03 3b 80 00       	push   $0x803b03
  8029c5:	68 88 00 00 00       	push   $0x88
  8029ca:	68 c0 3a 80 00       	push   $0x803ac0
  8029cf:	e8 41 e0 ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029d4:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029da:	eb 58                	jmp    802a34 <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029dc:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029e2:	eb 50                	jmp    802a34 <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029e4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029ea:	eb 48                	jmp    802a34 <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029ec:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029f1:	eb 41                	jmp    802a34 <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029f3:	89 c3                	mov    %eax,%ebx
  8029f5:	eb 3d                	jmp    802a34 <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029f7:	89 c3                	mov    %eax,%ebx
  8029f9:	eb 06                	jmp    802a01 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029fb:	89 c3                	mov    %eax,%ebx
  8029fd:	eb 02                	jmp    802a01 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8029ff:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a01:	83 ec 0c             	sub    $0xc,%esp
  802a04:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a0a:	e8 db ea ff ff       	call   8014ea <sys_env_destroy>
	close(fd);
  802a0f:	83 c4 04             	add    $0x4,%esp
  802a12:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a18:	e8 7c f3 ff ff       	call   801d99 <close>
	return r;
  802a1d:	83 c4 10             	add    $0x10,%esp
  802a20:	eb 12                	jmp    802a34 <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a22:	83 ec 08             	sub    $0x8,%esp
  802a25:	68 00 00 40 00       	push   $0x400000
  802a2a:	6a 00                	push   $0x0
  802a2c:	e8 bd eb ff ff       	call   8015ee <sys_page_unmap>
  802a31:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a34:	89 d8                	mov    %ebx,%eax
  802a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a39:	5b                   	pop    %ebx
  802a3a:	5e                   	pop    %esi
  802a3b:	5f                   	pop    %edi
  802a3c:	5d                   	pop    %ebp
  802a3d:	c3                   	ret    

00802a3e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a3e:	55                   	push   %ebp
  802a3f:	89 e5                	mov    %esp,%ebp
  802a41:	56                   	push   %esi
  802a42:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a43:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a46:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a4b:	eb 03                	jmp    802a50 <spawnl+0x12>
		argc++;
  802a4d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a50:	83 c2 04             	add    $0x4,%edx
  802a53:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a57:	75 f4                	jne    802a4d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a59:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a60:	83 e2 f0             	and    $0xfffffff0,%edx
  802a63:	29 d4                	sub    %edx,%esp
  802a65:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a69:	c1 ea 02             	shr    $0x2,%edx
  802a6c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a73:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a78:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a7f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a86:	00 
  802a87:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a89:	b8 00 00 00 00       	mov    $0x0,%eax
  802a8e:	eb 0a                	jmp    802a9a <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a90:	83 c0 01             	add    $0x1,%eax
  802a93:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a97:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a9a:	39 d0                	cmp    %edx,%eax
  802a9c:	75 f2                	jne    802a90 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a9e:	83 ec 08             	sub    $0x8,%esp
  802aa1:	56                   	push   %esi
  802aa2:	ff 75 08             	pushl  0x8(%ebp)
  802aa5:	e8 5d fa ff ff       	call   802507 <spawn>
}
  802aaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aad:	5b                   	pop    %ebx
  802aae:	5e                   	pop    %esi
  802aaf:	5d                   	pop    %ebp
  802ab0:	c3                   	ret    

00802ab1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ab1:	55                   	push   %ebp
  802ab2:	89 e5                	mov    %esp,%ebp
  802ab4:	56                   	push   %esi
  802ab5:	53                   	push   %ebx
  802ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ab9:	83 ec 0c             	sub    $0xc,%esp
  802abc:	ff 75 08             	pushl  0x8(%ebp)
  802abf:	e8 45 f1 ff ff       	call   801c09 <fd2data>
  802ac4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ac6:	83 c4 08             	add    $0x8,%esp
  802ac9:	68 42 3b 80 00       	push   $0x803b42
  802ace:	53                   	push   %ebx
  802acf:	e8 92 e6 ff ff       	call   801166 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ad4:	8b 46 04             	mov    0x4(%esi),%eax
  802ad7:	2b 06                	sub    (%esi),%eax
  802ad9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802adf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ae6:	00 00 00 
	stat->st_dev = &devpipe;
  802ae9:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802af0:	40 80 00 
	return 0;
}
  802af3:	b8 00 00 00 00       	mov    $0x0,%eax
  802af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802afb:	5b                   	pop    %ebx
  802afc:	5e                   	pop    %esi
  802afd:	5d                   	pop    %ebp
  802afe:	c3                   	ret    

00802aff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802aff:	55                   	push   %ebp
  802b00:	89 e5                	mov    %esp,%ebp
  802b02:	53                   	push   %ebx
  802b03:	83 ec 0c             	sub    $0xc,%esp
  802b06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b09:	53                   	push   %ebx
  802b0a:	6a 00                	push   $0x0
  802b0c:	e8 dd ea ff ff       	call   8015ee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b11:	89 1c 24             	mov    %ebx,(%esp)
  802b14:	e8 f0 f0 ff ff       	call   801c09 <fd2data>
  802b19:	83 c4 08             	add    $0x8,%esp
  802b1c:	50                   	push   %eax
  802b1d:	6a 00                	push   $0x0
  802b1f:	e8 ca ea ff ff       	call   8015ee <sys_page_unmap>
}
  802b24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b27:	c9                   	leave  
  802b28:	c3                   	ret    

00802b29 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b29:	55                   	push   %ebp
  802b2a:	89 e5                	mov    %esp,%ebp
  802b2c:	57                   	push   %edi
  802b2d:	56                   	push   %esi
  802b2e:	53                   	push   %ebx
  802b2f:	83 ec 1c             	sub    $0x1c,%esp
  802b32:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b35:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b37:	a1 24 54 80 00       	mov    0x805424,%eax
  802b3c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b3f:	83 ec 0c             	sub    $0xc,%esp
  802b42:	ff 75 e0             	pushl  -0x20(%ebp)
  802b45:	e8 cf 04 00 00       	call   803019 <pageref>
  802b4a:	89 c3                	mov    %eax,%ebx
  802b4c:	89 3c 24             	mov    %edi,(%esp)
  802b4f:	e8 c5 04 00 00       	call   803019 <pageref>
  802b54:	83 c4 10             	add    $0x10,%esp
  802b57:	39 c3                	cmp    %eax,%ebx
  802b59:	0f 94 c1             	sete   %cl
  802b5c:	0f b6 c9             	movzbl %cl,%ecx
  802b5f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b62:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b68:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b6b:	39 ce                	cmp    %ecx,%esi
  802b6d:	74 1b                	je     802b8a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b6f:	39 c3                	cmp    %eax,%ebx
  802b71:	75 c4                	jne    802b37 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b73:	8b 42 58             	mov    0x58(%edx),%eax
  802b76:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b79:	50                   	push   %eax
  802b7a:	56                   	push   %esi
  802b7b:	68 49 3b 80 00       	push   $0x803b49
  802b80:	e8 69 df ff ff       	call   800aee <cprintf>
  802b85:	83 c4 10             	add    $0x10,%esp
  802b88:	eb ad                	jmp    802b37 <_pipeisclosed+0xe>
	}
}
  802b8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b90:	5b                   	pop    %ebx
  802b91:	5e                   	pop    %esi
  802b92:	5f                   	pop    %edi
  802b93:	5d                   	pop    %ebp
  802b94:	c3                   	ret    

00802b95 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b95:	55                   	push   %ebp
  802b96:	89 e5                	mov    %esp,%ebp
  802b98:	57                   	push   %edi
  802b99:	56                   	push   %esi
  802b9a:	53                   	push   %ebx
  802b9b:	83 ec 28             	sub    $0x28,%esp
  802b9e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ba1:	56                   	push   %esi
  802ba2:	e8 62 f0 ff ff       	call   801c09 <fd2data>
  802ba7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ba9:	83 c4 10             	add    $0x10,%esp
  802bac:	bf 00 00 00 00       	mov    $0x0,%edi
  802bb1:	eb 4b                	jmp    802bfe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bb3:	89 da                	mov    %ebx,%edx
  802bb5:	89 f0                	mov    %esi,%eax
  802bb7:	e8 6d ff ff ff       	call   802b29 <_pipeisclosed>
  802bbc:	85 c0                	test   %eax,%eax
  802bbe:	75 48                	jne    802c08 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bc0:	e8 85 e9 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bc5:	8b 43 04             	mov    0x4(%ebx),%eax
  802bc8:	8b 0b                	mov    (%ebx),%ecx
  802bca:	8d 51 20             	lea    0x20(%ecx),%edx
  802bcd:	39 d0                	cmp    %edx,%eax
  802bcf:	73 e2                	jae    802bb3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bd4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802bd8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802bdb:	89 c2                	mov    %eax,%edx
  802bdd:	c1 fa 1f             	sar    $0x1f,%edx
  802be0:	89 d1                	mov    %edx,%ecx
  802be2:	c1 e9 1b             	shr    $0x1b,%ecx
  802be5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802be8:	83 e2 1f             	and    $0x1f,%edx
  802beb:	29 ca                	sub    %ecx,%edx
  802bed:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802bf1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802bf5:	83 c0 01             	add    $0x1,%eax
  802bf8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bfb:	83 c7 01             	add    $0x1,%edi
  802bfe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c01:	75 c2                	jne    802bc5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c03:	8b 45 10             	mov    0x10(%ebp),%eax
  802c06:	eb 05                	jmp    802c0d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c08:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c10:	5b                   	pop    %ebx
  802c11:	5e                   	pop    %esi
  802c12:	5f                   	pop    %edi
  802c13:	5d                   	pop    %ebp
  802c14:	c3                   	ret    

00802c15 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c15:	55                   	push   %ebp
  802c16:	89 e5                	mov    %esp,%ebp
  802c18:	57                   	push   %edi
  802c19:	56                   	push   %esi
  802c1a:	53                   	push   %ebx
  802c1b:	83 ec 18             	sub    $0x18,%esp
  802c1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c21:	57                   	push   %edi
  802c22:	e8 e2 ef ff ff       	call   801c09 <fd2data>
  802c27:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c29:	83 c4 10             	add    $0x10,%esp
  802c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c31:	eb 3d                	jmp    802c70 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c33:	85 db                	test   %ebx,%ebx
  802c35:	74 04                	je     802c3b <devpipe_read+0x26>
				return i;
  802c37:	89 d8                	mov    %ebx,%eax
  802c39:	eb 44                	jmp    802c7f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c3b:	89 f2                	mov    %esi,%edx
  802c3d:	89 f8                	mov    %edi,%eax
  802c3f:	e8 e5 fe ff ff       	call   802b29 <_pipeisclosed>
  802c44:	85 c0                	test   %eax,%eax
  802c46:	75 32                	jne    802c7a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c48:	e8 fd e8 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c4d:	8b 06                	mov    (%esi),%eax
  802c4f:	3b 46 04             	cmp    0x4(%esi),%eax
  802c52:	74 df                	je     802c33 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c54:	99                   	cltd   
  802c55:	c1 ea 1b             	shr    $0x1b,%edx
  802c58:	01 d0                	add    %edx,%eax
  802c5a:	83 e0 1f             	and    $0x1f,%eax
  802c5d:	29 d0                	sub    %edx,%eax
  802c5f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c67:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c6a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c6d:	83 c3 01             	add    $0x1,%ebx
  802c70:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c73:	75 d8                	jne    802c4d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c75:	8b 45 10             	mov    0x10(%ebp),%eax
  802c78:	eb 05                	jmp    802c7f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c7a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c82:	5b                   	pop    %ebx
  802c83:	5e                   	pop    %esi
  802c84:	5f                   	pop    %edi
  802c85:	5d                   	pop    %ebp
  802c86:	c3                   	ret    

00802c87 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c87:	55                   	push   %ebp
  802c88:	89 e5                	mov    %esp,%ebp
  802c8a:	56                   	push   %esi
  802c8b:	53                   	push   %ebx
  802c8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c92:	50                   	push   %eax
  802c93:	e8 88 ef ff ff       	call   801c20 <fd_alloc>
  802c98:	83 c4 10             	add    $0x10,%esp
  802c9b:	89 c2                	mov    %eax,%edx
  802c9d:	85 c0                	test   %eax,%eax
  802c9f:	0f 88 2c 01 00 00    	js     802dd1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ca5:	83 ec 04             	sub    $0x4,%esp
  802ca8:	68 07 04 00 00       	push   $0x407
  802cad:	ff 75 f4             	pushl  -0xc(%ebp)
  802cb0:	6a 00                	push   $0x0
  802cb2:	e8 b2 e8 ff ff       	call   801569 <sys_page_alloc>
  802cb7:	83 c4 10             	add    $0x10,%esp
  802cba:	89 c2                	mov    %eax,%edx
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	0f 88 0d 01 00 00    	js     802dd1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cc4:	83 ec 0c             	sub    $0xc,%esp
  802cc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cca:	50                   	push   %eax
  802ccb:	e8 50 ef ff ff       	call   801c20 <fd_alloc>
  802cd0:	89 c3                	mov    %eax,%ebx
  802cd2:	83 c4 10             	add    $0x10,%esp
  802cd5:	85 c0                	test   %eax,%eax
  802cd7:	0f 88 e2 00 00 00    	js     802dbf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cdd:	83 ec 04             	sub    $0x4,%esp
  802ce0:	68 07 04 00 00       	push   $0x407
  802ce5:	ff 75 f0             	pushl  -0x10(%ebp)
  802ce8:	6a 00                	push   $0x0
  802cea:	e8 7a e8 ff ff       	call   801569 <sys_page_alloc>
  802cef:	89 c3                	mov    %eax,%ebx
  802cf1:	83 c4 10             	add    $0x10,%esp
  802cf4:	85 c0                	test   %eax,%eax
  802cf6:	0f 88 c3 00 00 00    	js     802dbf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802cfc:	83 ec 0c             	sub    $0xc,%esp
  802cff:	ff 75 f4             	pushl  -0xc(%ebp)
  802d02:	e8 02 ef ff ff       	call   801c09 <fd2data>
  802d07:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d09:	83 c4 0c             	add    $0xc,%esp
  802d0c:	68 07 04 00 00       	push   $0x407
  802d11:	50                   	push   %eax
  802d12:	6a 00                	push   $0x0
  802d14:	e8 50 e8 ff ff       	call   801569 <sys_page_alloc>
  802d19:	89 c3                	mov    %eax,%ebx
  802d1b:	83 c4 10             	add    $0x10,%esp
  802d1e:	85 c0                	test   %eax,%eax
  802d20:	0f 88 89 00 00 00    	js     802daf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d26:	83 ec 0c             	sub    $0xc,%esp
  802d29:	ff 75 f0             	pushl  -0x10(%ebp)
  802d2c:	e8 d8 ee ff ff       	call   801c09 <fd2data>
  802d31:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d38:	50                   	push   %eax
  802d39:	6a 00                	push   $0x0
  802d3b:	56                   	push   %esi
  802d3c:	6a 00                	push   $0x0
  802d3e:	e8 69 e8 ff ff       	call   8015ac <sys_page_map>
  802d43:	89 c3                	mov    %eax,%ebx
  802d45:	83 c4 20             	add    $0x20,%esp
  802d48:	85 c0                	test   %eax,%eax
  802d4a:	78 55                	js     802da1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d4c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d55:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d5a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d61:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d6a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d6f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d76:	83 ec 0c             	sub    $0xc,%esp
  802d79:	ff 75 f4             	pushl  -0xc(%ebp)
  802d7c:	e8 78 ee ff ff       	call   801bf9 <fd2num>
  802d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d84:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d86:	83 c4 04             	add    $0x4,%esp
  802d89:	ff 75 f0             	pushl  -0x10(%ebp)
  802d8c:	e8 68 ee ff ff       	call   801bf9 <fd2num>
  802d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d94:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d97:	83 c4 10             	add    $0x10,%esp
  802d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  802d9f:	eb 30                	jmp    802dd1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802da1:	83 ec 08             	sub    $0x8,%esp
  802da4:	56                   	push   %esi
  802da5:	6a 00                	push   $0x0
  802da7:	e8 42 e8 ff ff       	call   8015ee <sys_page_unmap>
  802dac:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802daf:	83 ec 08             	sub    $0x8,%esp
  802db2:	ff 75 f0             	pushl  -0x10(%ebp)
  802db5:	6a 00                	push   $0x0
  802db7:	e8 32 e8 ff ff       	call   8015ee <sys_page_unmap>
  802dbc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802dbf:	83 ec 08             	sub    $0x8,%esp
  802dc2:	ff 75 f4             	pushl  -0xc(%ebp)
  802dc5:	6a 00                	push   $0x0
  802dc7:	e8 22 e8 ff ff       	call   8015ee <sys_page_unmap>
  802dcc:	83 c4 10             	add    $0x10,%esp
  802dcf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802dd1:	89 d0                	mov    %edx,%eax
  802dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dd6:	5b                   	pop    %ebx
  802dd7:	5e                   	pop    %esi
  802dd8:	5d                   	pop    %ebp
  802dd9:	c3                   	ret    

00802dda <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802dda:	55                   	push   %ebp
  802ddb:	89 e5                	mov    %esp,%ebp
  802ddd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802de3:	50                   	push   %eax
  802de4:	ff 75 08             	pushl  0x8(%ebp)
  802de7:	e8 83 ee ff ff       	call   801c6f <fd_lookup>
  802dec:	83 c4 10             	add    $0x10,%esp
  802def:	85 c0                	test   %eax,%eax
  802df1:	78 18                	js     802e0b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802df3:	83 ec 0c             	sub    $0xc,%esp
  802df6:	ff 75 f4             	pushl  -0xc(%ebp)
  802df9:	e8 0b ee ff ff       	call   801c09 <fd2data>
	return _pipeisclosed(fd, p);
  802dfe:	89 c2                	mov    %eax,%edx
  802e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e03:	e8 21 fd ff ff       	call   802b29 <_pipeisclosed>
  802e08:	83 c4 10             	add    $0x10,%esp
}
  802e0b:	c9                   	leave  
  802e0c:	c3                   	ret    

00802e0d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e0d:	55                   	push   %ebp
  802e0e:	89 e5                	mov    %esp,%ebp
  802e10:	56                   	push   %esi
  802e11:	53                   	push   %ebx
  802e12:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e15:	85 f6                	test   %esi,%esi
  802e17:	75 16                	jne    802e2f <wait+0x22>
  802e19:	68 61 3b 80 00       	push   $0x803b61
  802e1e:	68 3a 34 80 00       	push   $0x80343a
  802e23:	6a 09                	push   $0x9
  802e25:	68 6c 3b 80 00       	push   $0x803b6c
  802e2a:	e8 e6 db ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802e2f:	89 f3                	mov    %esi,%ebx
  802e31:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e37:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802e3a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802e40:	eb 05                	jmp    802e47 <wait+0x3a>
		sys_yield();
  802e42:	e8 03 e7 ff ff       	call   80154a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e47:	8b 43 48             	mov    0x48(%ebx),%eax
  802e4a:	39 c6                	cmp    %eax,%esi
  802e4c:	75 07                	jne    802e55 <wait+0x48>
  802e4e:	8b 43 54             	mov    0x54(%ebx),%eax
  802e51:	85 c0                	test   %eax,%eax
  802e53:	75 ed                	jne    802e42 <wait+0x35>
		sys_yield();
}
  802e55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e58:	5b                   	pop    %ebx
  802e59:	5e                   	pop    %esi
  802e5a:	5d                   	pop    %ebp
  802e5b:	c3                   	ret    

00802e5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e5c:	55                   	push   %ebp
  802e5d:	89 e5                	mov    %esp,%ebp
  802e5f:	53                   	push   %ebx
  802e60:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e63:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e6a:	75 57                	jne    802ec3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  802e6c:	e8 ba e6 ff ff       	call   80152b <sys_getenvid>
  802e71:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  802e73:	83 ec 04             	sub    $0x4,%esp
  802e76:	6a 07                	push   $0x7
  802e78:	68 00 f0 bf ee       	push   $0xeebff000
  802e7d:	50                   	push   %eax
  802e7e:	e8 e6 e6 ff ff       	call   801569 <sys_page_alloc>
		if (r) {
  802e83:	83 c4 10             	add    $0x10,%esp
  802e86:	85 c0                	test   %eax,%eax
  802e88:	74 12                	je     802e9c <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  802e8a:	50                   	push   %eax
  802e8b:	68 4a 39 80 00       	push   $0x80394a
  802e90:	6a 25                	push   $0x25
  802e92:	68 77 3b 80 00       	push   $0x803b77
  802e97:	e8 79 db ff ff       	call   800a15 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  802e9c:	83 ec 08             	sub    $0x8,%esp
  802e9f:	68 d0 2e 80 00       	push   $0x802ed0
  802ea4:	53                   	push   %ebx
  802ea5:	e8 0a e8 ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>
		if (r) {
  802eaa:	83 c4 10             	add    $0x10,%esp
  802ead:	85 c0                	test   %eax,%eax
  802eaf:	74 12                	je     802ec3 <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  802eb1:	50                   	push   %eax
  802eb2:	68 88 3b 80 00       	push   $0x803b88
  802eb7:	6a 2b                	push   $0x2b
  802eb9:	68 77 3b 80 00       	push   $0x803b77
  802ebe:	e8 52 db ff ff       	call   800a15 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  802ec6:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ece:	c9                   	leave  
  802ecf:	c3                   	ret    

00802ed0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ed0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ed1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802ed6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ed8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  802edb:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  802edf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  802ee4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  802ee8:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  802eea:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  802eed:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  802eee:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  802ef1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  802ef2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  802ef3:	c3                   	ret    

00802ef4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ef4:	55                   	push   %ebp
  802ef5:	89 e5                	mov    %esp,%ebp
  802ef7:	56                   	push   %esi
  802ef8:	53                   	push   %ebx
  802ef9:	8b 75 08             	mov    0x8(%ebp),%esi
  802efc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  802f02:	85 c0                	test   %eax,%eax
  802f04:	74 3e                	je     802f44 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  802f06:	83 ec 0c             	sub    $0xc,%esp
  802f09:	50                   	push   %eax
  802f0a:	e8 0a e8 ff ff       	call   801719 <sys_ipc_recv>
  802f0f:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  802f11:	83 c4 10             	add    $0x10,%esp
  802f14:	85 f6                	test   %esi,%esi
  802f16:	74 13                	je     802f2b <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802f18:	b8 00 00 00 00       	mov    $0x0,%eax
  802f1d:	85 d2                	test   %edx,%edx
  802f1f:	75 08                	jne    802f29 <ipc_recv+0x35>
  802f21:	a1 24 54 80 00       	mov    0x805424,%eax
  802f26:	8b 40 74             	mov    0x74(%eax),%eax
  802f29:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802f2b:	85 db                	test   %ebx,%ebx
  802f2d:	74 48                	je     802f77 <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  802f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802f34:	85 d2                	test   %edx,%edx
  802f36:	75 08                	jne    802f40 <ipc_recv+0x4c>
  802f38:	a1 24 54 80 00       	mov    0x805424,%eax
  802f3d:	8b 40 78             	mov    0x78(%eax),%eax
  802f40:	89 03                	mov    %eax,(%ebx)
  802f42:	eb 33                	jmp    802f77 <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  802f44:	83 ec 0c             	sub    $0xc,%esp
  802f47:	68 00 00 c0 ee       	push   $0xeec00000
  802f4c:	e8 c8 e7 ff ff       	call   801719 <sys_ipc_recv>
  802f51:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  802f53:	83 c4 10             	add    $0x10,%esp
  802f56:	85 f6                	test   %esi,%esi
  802f58:	74 13                	je     802f6d <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802f5a:	b8 00 00 00 00       	mov    $0x0,%eax
  802f5f:	85 d2                	test   %edx,%edx
  802f61:	75 08                	jne    802f6b <ipc_recv+0x77>
  802f63:	a1 24 54 80 00       	mov    0x805424,%eax
  802f68:	8b 40 74             	mov    0x74(%eax),%eax
  802f6b:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802f6d:	85 db                	test   %ebx,%ebx
  802f6f:	74 06                	je     802f77 <ipc_recv+0x83>
			*perm_store = 0;
  802f71:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  802f77:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  802f79:	85 d2                	test   %edx,%edx
  802f7b:	75 08                	jne    802f85 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  802f7d:	a1 24 54 80 00       	mov    0x805424,%eax
  802f82:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  802f85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f88:	5b                   	pop    %ebx
  802f89:	5e                   	pop    %esi
  802f8a:	5d                   	pop    %ebp
  802f8b:	c3                   	ret    

00802f8c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f8c:	55                   	push   %ebp
  802f8d:	89 e5                	mov    %esp,%ebp
  802f8f:	57                   	push   %edi
  802f90:	56                   	push   %esi
  802f91:	53                   	push   %ebx
  802f92:	83 ec 0c             	sub    $0xc,%esp
  802f95:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f98:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  802f9e:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  802fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802fa5:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802fa8:	eb 1c                	jmp    802fc6 <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  802faa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802fad:	74 12                	je     802fc1 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  802faf:	50                   	push   %eax
  802fb0:	68 b0 3b 80 00       	push   $0x803bb0
  802fb5:	6a 4f                	push   $0x4f
  802fb7:	68 cb 3b 80 00       	push   $0x803bcb
  802fbc:	e8 54 da ff ff       	call   800a15 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802fc1:	e8 84 e5 ff ff       	call   80154a <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802fc6:	ff 75 14             	pushl  0x14(%ebp)
  802fc9:	53                   	push   %ebx
  802fca:	56                   	push   %esi
  802fcb:	57                   	push   %edi
  802fcc:	e8 25 e7 ff ff       	call   8016f6 <sys_ipc_try_send>
  802fd1:	83 c4 10             	add    $0x10,%esp
  802fd4:	85 c0                	test   %eax,%eax
  802fd6:	78 d2                	js     802faa <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802fdb:	5b                   	pop    %ebx
  802fdc:	5e                   	pop    %esi
  802fdd:	5f                   	pop    %edi
  802fde:	5d                   	pop    %ebp
  802fdf:	c3                   	ret    

00802fe0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802fe0:	55                   	push   %ebp
  802fe1:	89 e5                	mov    %esp,%ebp
  802fe3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802fe6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802feb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802fee:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802ff4:	8b 52 50             	mov    0x50(%edx),%edx
  802ff7:	39 ca                	cmp    %ecx,%edx
  802ff9:	75 0d                	jne    803008 <ipc_find_env+0x28>
			return envs[i].env_id;
  802ffb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ffe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803003:	8b 40 48             	mov    0x48(%eax),%eax
  803006:	eb 0f                	jmp    803017 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803008:	83 c0 01             	add    $0x1,%eax
  80300b:	3d 00 04 00 00       	cmp    $0x400,%eax
  803010:	75 d9                	jne    802feb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803017:	5d                   	pop    %ebp
  803018:	c3                   	ret    

00803019 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803019:	55                   	push   %ebp
  80301a:	89 e5                	mov    %esp,%ebp
  80301c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80301f:	89 d0                	mov    %edx,%eax
  803021:	c1 e8 16             	shr    $0x16,%eax
  803024:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80302b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803030:	f6 c1 01             	test   $0x1,%cl
  803033:	74 1d                	je     803052 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803035:	c1 ea 0c             	shr    $0xc,%edx
  803038:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80303f:	f6 c2 01             	test   $0x1,%dl
  803042:	74 0e                	je     803052 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803044:	c1 ea 0c             	shr    $0xc,%edx
  803047:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80304e:	ef 
  80304f:	0f b7 c0             	movzwl %ax,%eax
}
  803052:	5d                   	pop    %ebp
  803053:	c3                   	ret    
  803054:	66 90                	xchg   %ax,%ax
  803056:	66 90                	xchg   %ax,%ax
  803058:	66 90                	xchg   %ax,%ax
  80305a:	66 90                	xchg   %ax,%ax
  80305c:	66 90                	xchg   %ax,%ax
  80305e:	66 90                	xchg   %ax,%ax

00803060 <__udivdi3>:
  803060:	55                   	push   %ebp
  803061:	57                   	push   %edi
  803062:	56                   	push   %esi
  803063:	53                   	push   %ebx
  803064:	83 ec 1c             	sub    $0x1c,%esp
  803067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80306b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80306f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803077:	85 f6                	test   %esi,%esi
  803079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80307d:	89 ca                	mov    %ecx,%edx
  80307f:	89 f8                	mov    %edi,%eax
  803081:	75 3d                	jne    8030c0 <__udivdi3+0x60>
  803083:	39 cf                	cmp    %ecx,%edi
  803085:	0f 87 c5 00 00 00    	ja     803150 <__udivdi3+0xf0>
  80308b:	85 ff                	test   %edi,%edi
  80308d:	89 fd                	mov    %edi,%ebp
  80308f:	75 0b                	jne    80309c <__udivdi3+0x3c>
  803091:	b8 01 00 00 00       	mov    $0x1,%eax
  803096:	31 d2                	xor    %edx,%edx
  803098:	f7 f7                	div    %edi
  80309a:	89 c5                	mov    %eax,%ebp
  80309c:	89 c8                	mov    %ecx,%eax
  80309e:	31 d2                	xor    %edx,%edx
  8030a0:	f7 f5                	div    %ebp
  8030a2:	89 c1                	mov    %eax,%ecx
  8030a4:	89 d8                	mov    %ebx,%eax
  8030a6:	89 cf                	mov    %ecx,%edi
  8030a8:	f7 f5                	div    %ebp
  8030aa:	89 c3                	mov    %eax,%ebx
  8030ac:	89 d8                	mov    %ebx,%eax
  8030ae:	89 fa                	mov    %edi,%edx
  8030b0:	83 c4 1c             	add    $0x1c,%esp
  8030b3:	5b                   	pop    %ebx
  8030b4:	5e                   	pop    %esi
  8030b5:	5f                   	pop    %edi
  8030b6:	5d                   	pop    %ebp
  8030b7:	c3                   	ret    
  8030b8:	90                   	nop
  8030b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030c0:	39 ce                	cmp    %ecx,%esi
  8030c2:	77 74                	ja     803138 <__udivdi3+0xd8>
  8030c4:	0f bd fe             	bsr    %esi,%edi
  8030c7:	83 f7 1f             	xor    $0x1f,%edi
  8030ca:	0f 84 98 00 00 00    	je     803168 <__udivdi3+0x108>
  8030d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8030d5:	89 f9                	mov    %edi,%ecx
  8030d7:	89 c5                	mov    %eax,%ebp
  8030d9:	29 fb                	sub    %edi,%ebx
  8030db:	d3 e6                	shl    %cl,%esi
  8030dd:	89 d9                	mov    %ebx,%ecx
  8030df:	d3 ed                	shr    %cl,%ebp
  8030e1:	89 f9                	mov    %edi,%ecx
  8030e3:	d3 e0                	shl    %cl,%eax
  8030e5:	09 ee                	or     %ebp,%esi
  8030e7:	89 d9                	mov    %ebx,%ecx
  8030e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030ed:	89 d5                	mov    %edx,%ebp
  8030ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8030f3:	d3 ed                	shr    %cl,%ebp
  8030f5:	89 f9                	mov    %edi,%ecx
  8030f7:	d3 e2                	shl    %cl,%edx
  8030f9:	89 d9                	mov    %ebx,%ecx
  8030fb:	d3 e8                	shr    %cl,%eax
  8030fd:	09 c2                	or     %eax,%edx
  8030ff:	89 d0                	mov    %edx,%eax
  803101:	89 ea                	mov    %ebp,%edx
  803103:	f7 f6                	div    %esi
  803105:	89 d5                	mov    %edx,%ebp
  803107:	89 c3                	mov    %eax,%ebx
  803109:	f7 64 24 0c          	mull   0xc(%esp)
  80310d:	39 d5                	cmp    %edx,%ebp
  80310f:	72 10                	jb     803121 <__udivdi3+0xc1>
  803111:	8b 74 24 08          	mov    0x8(%esp),%esi
  803115:	89 f9                	mov    %edi,%ecx
  803117:	d3 e6                	shl    %cl,%esi
  803119:	39 c6                	cmp    %eax,%esi
  80311b:	73 07                	jae    803124 <__udivdi3+0xc4>
  80311d:	39 d5                	cmp    %edx,%ebp
  80311f:	75 03                	jne    803124 <__udivdi3+0xc4>
  803121:	83 eb 01             	sub    $0x1,%ebx
  803124:	31 ff                	xor    %edi,%edi
  803126:	89 d8                	mov    %ebx,%eax
  803128:	89 fa                	mov    %edi,%edx
  80312a:	83 c4 1c             	add    $0x1c,%esp
  80312d:	5b                   	pop    %ebx
  80312e:	5e                   	pop    %esi
  80312f:	5f                   	pop    %edi
  803130:	5d                   	pop    %ebp
  803131:	c3                   	ret    
  803132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803138:	31 ff                	xor    %edi,%edi
  80313a:	31 db                	xor    %ebx,%ebx
  80313c:	89 d8                	mov    %ebx,%eax
  80313e:	89 fa                	mov    %edi,%edx
  803140:	83 c4 1c             	add    $0x1c,%esp
  803143:	5b                   	pop    %ebx
  803144:	5e                   	pop    %esi
  803145:	5f                   	pop    %edi
  803146:	5d                   	pop    %ebp
  803147:	c3                   	ret    
  803148:	90                   	nop
  803149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803150:	89 d8                	mov    %ebx,%eax
  803152:	f7 f7                	div    %edi
  803154:	31 ff                	xor    %edi,%edi
  803156:	89 c3                	mov    %eax,%ebx
  803158:	89 d8                	mov    %ebx,%eax
  80315a:	89 fa                	mov    %edi,%edx
  80315c:	83 c4 1c             	add    $0x1c,%esp
  80315f:	5b                   	pop    %ebx
  803160:	5e                   	pop    %esi
  803161:	5f                   	pop    %edi
  803162:	5d                   	pop    %ebp
  803163:	c3                   	ret    
  803164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803168:	39 ce                	cmp    %ecx,%esi
  80316a:	72 0c                	jb     803178 <__udivdi3+0x118>
  80316c:	31 db                	xor    %ebx,%ebx
  80316e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803172:	0f 87 34 ff ff ff    	ja     8030ac <__udivdi3+0x4c>
  803178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80317d:	e9 2a ff ff ff       	jmp    8030ac <__udivdi3+0x4c>
  803182:	66 90                	xchg   %ax,%ax
  803184:	66 90                	xchg   %ax,%ax
  803186:	66 90                	xchg   %ax,%ax
  803188:	66 90                	xchg   %ax,%ax
  80318a:	66 90                	xchg   %ax,%ax
  80318c:	66 90                	xchg   %ax,%ax
  80318e:	66 90                	xchg   %ax,%ax

00803190 <__umoddi3>:
  803190:	55                   	push   %ebp
  803191:	57                   	push   %edi
  803192:	56                   	push   %esi
  803193:	53                   	push   %ebx
  803194:	83 ec 1c             	sub    $0x1c,%esp
  803197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80319b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80319f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8031a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031a7:	85 d2                	test   %edx,%edx
  8031a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8031ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031b1:	89 f3                	mov    %esi,%ebx
  8031b3:	89 3c 24             	mov    %edi,(%esp)
  8031b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031ba:	75 1c                	jne    8031d8 <__umoddi3+0x48>
  8031bc:	39 f7                	cmp    %esi,%edi
  8031be:	76 50                	jbe    803210 <__umoddi3+0x80>
  8031c0:	89 c8                	mov    %ecx,%eax
  8031c2:	89 f2                	mov    %esi,%edx
  8031c4:	f7 f7                	div    %edi
  8031c6:	89 d0                	mov    %edx,%eax
  8031c8:	31 d2                	xor    %edx,%edx
  8031ca:	83 c4 1c             	add    $0x1c,%esp
  8031cd:	5b                   	pop    %ebx
  8031ce:	5e                   	pop    %esi
  8031cf:	5f                   	pop    %edi
  8031d0:	5d                   	pop    %ebp
  8031d1:	c3                   	ret    
  8031d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031d8:	39 f2                	cmp    %esi,%edx
  8031da:	89 d0                	mov    %edx,%eax
  8031dc:	77 52                	ja     803230 <__umoddi3+0xa0>
  8031de:	0f bd ea             	bsr    %edx,%ebp
  8031e1:	83 f5 1f             	xor    $0x1f,%ebp
  8031e4:	75 5a                	jne    803240 <__umoddi3+0xb0>
  8031e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8031ea:	0f 82 e0 00 00 00    	jb     8032d0 <__umoddi3+0x140>
  8031f0:	39 0c 24             	cmp    %ecx,(%esp)
  8031f3:	0f 86 d7 00 00 00    	jbe    8032d0 <__umoddi3+0x140>
  8031f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8031fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  803201:	83 c4 1c             	add    $0x1c,%esp
  803204:	5b                   	pop    %ebx
  803205:	5e                   	pop    %esi
  803206:	5f                   	pop    %edi
  803207:	5d                   	pop    %ebp
  803208:	c3                   	ret    
  803209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803210:	85 ff                	test   %edi,%edi
  803212:	89 fd                	mov    %edi,%ebp
  803214:	75 0b                	jne    803221 <__umoddi3+0x91>
  803216:	b8 01 00 00 00       	mov    $0x1,%eax
  80321b:	31 d2                	xor    %edx,%edx
  80321d:	f7 f7                	div    %edi
  80321f:	89 c5                	mov    %eax,%ebp
  803221:	89 f0                	mov    %esi,%eax
  803223:	31 d2                	xor    %edx,%edx
  803225:	f7 f5                	div    %ebp
  803227:	89 c8                	mov    %ecx,%eax
  803229:	f7 f5                	div    %ebp
  80322b:	89 d0                	mov    %edx,%eax
  80322d:	eb 99                	jmp    8031c8 <__umoddi3+0x38>
  80322f:	90                   	nop
  803230:	89 c8                	mov    %ecx,%eax
  803232:	89 f2                	mov    %esi,%edx
  803234:	83 c4 1c             	add    $0x1c,%esp
  803237:	5b                   	pop    %ebx
  803238:	5e                   	pop    %esi
  803239:	5f                   	pop    %edi
  80323a:	5d                   	pop    %ebp
  80323b:	c3                   	ret    
  80323c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803240:	8b 34 24             	mov    (%esp),%esi
  803243:	bf 20 00 00 00       	mov    $0x20,%edi
  803248:	89 e9                	mov    %ebp,%ecx
  80324a:	29 ef                	sub    %ebp,%edi
  80324c:	d3 e0                	shl    %cl,%eax
  80324e:	89 f9                	mov    %edi,%ecx
  803250:	89 f2                	mov    %esi,%edx
  803252:	d3 ea                	shr    %cl,%edx
  803254:	89 e9                	mov    %ebp,%ecx
  803256:	09 c2                	or     %eax,%edx
  803258:	89 d8                	mov    %ebx,%eax
  80325a:	89 14 24             	mov    %edx,(%esp)
  80325d:	89 f2                	mov    %esi,%edx
  80325f:	d3 e2                	shl    %cl,%edx
  803261:	89 f9                	mov    %edi,%ecx
  803263:	89 54 24 04          	mov    %edx,0x4(%esp)
  803267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80326b:	d3 e8                	shr    %cl,%eax
  80326d:	89 e9                	mov    %ebp,%ecx
  80326f:	89 c6                	mov    %eax,%esi
  803271:	d3 e3                	shl    %cl,%ebx
  803273:	89 f9                	mov    %edi,%ecx
  803275:	89 d0                	mov    %edx,%eax
  803277:	d3 e8                	shr    %cl,%eax
  803279:	89 e9                	mov    %ebp,%ecx
  80327b:	09 d8                	or     %ebx,%eax
  80327d:	89 d3                	mov    %edx,%ebx
  80327f:	89 f2                	mov    %esi,%edx
  803281:	f7 34 24             	divl   (%esp)
  803284:	89 d6                	mov    %edx,%esi
  803286:	d3 e3                	shl    %cl,%ebx
  803288:	f7 64 24 04          	mull   0x4(%esp)
  80328c:	39 d6                	cmp    %edx,%esi
  80328e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803292:	89 d1                	mov    %edx,%ecx
  803294:	89 c3                	mov    %eax,%ebx
  803296:	72 08                	jb     8032a0 <__umoddi3+0x110>
  803298:	75 11                	jne    8032ab <__umoddi3+0x11b>
  80329a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80329e:	73 0b                	jae    8032ab <__umoddi3+0x11b>
  8032a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8032a4:	1b 14 24             	sbb    (%esp),%edx
  8032a7:	89 d1                	mov    %edx,%ecx
  8032a9:	89 c3                	mov    %eax,%ebx
  8032ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8032af:	29 da                	sub    %ebx,%edx
  8032b1:	19 ce                	sbb    %ecx,%esi
  8032b3:	89 f9                	mov    %edi,%ecx
  8032b5:	89 f0                	mov    %esi,%eax
  8032b7:	d3 e0                	shl    %cl,%eax
  8032b9:	89 e9                	mov    %ebp,%ecx
  8032bb:	d3 ea                	shr    %cl,%edx
  8032bd:	89 e9                	mov    %ebp,%ecx
  8032bf:	d3 ee                	shr    %cl,%esi
  8032c1:	09 d0                	or     %edx,%eax
  8032c3:	89 f2                	mov    %esi,%edx
  8032c5:	83 c4 1c             	add    $0x1c,%esp
  8032c8:	5b                   	pop    %ebx
  8032c9:	5e                   	pop    %esi
  8032ca:	5f                   	pop    %edi
  8032cb:	5d                   	pop    %ebp
  8032cc:	c3                   	ret    
  8032cd:	8d 76 00             	lea    0x0(%esi),%esi
  8032d0:	29 f9                	sub    %edi,%ecx
  8032d2:	19 d6                	sbb    %edx,%esi
  8032d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8032dc:	e9 18 ff ff ff       	jmp    8031f9 <__umoddi3+0x69>
