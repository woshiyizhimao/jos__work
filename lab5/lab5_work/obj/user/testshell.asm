
obj/user/testshell.debug：     文件格式 elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 74 18 00 00       	call   8018c3 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 6a 18 00 00       	call   8018c3 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 cb 2a 80 00 	movl   $0x802acb,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 cb 16 00 00       	call   80175d <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 da 2a 80 00       	push   $0x802ada
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 96 16 00 00       	call   80175d <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 d5 2a 80 00       	push   $0x802ad5
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 26 15 00 00       	call   801621 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 1a 15 00 00       	call   801621 <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 e8 2a 80 00       	push   $0x802ae8
  80011b:	e8 bb 1a 00 00       	call   801bdb <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 f5 2a 80 00       	push   $0x802af5
  80012f:	6a 13                	push   $0x13
  800131:	68 0b 2b 80 00       	push   $0x802b0b
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 b8 22 00 00       	call   8023ff <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 1c 2b 80 00       	push   $0x802b1c
  800154:	6a 15                	push   $0x15
  800156:	68 0b 2b 80 00       	push   $0x802b0b
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 84 2a 80 00       	push   $0x802a84
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 bd 10 00 00       	call   801232 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 25 2b 80 00       	push   $0x802b25
  800182:	6a 1a                	push   $0x1a
  800184:	68 0b 2b 80 00       	push   $0x802b0b
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 d4 14 00 00       	call   801671 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 c9 14 00 00       	call   801671 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 71 14 00 00       	call   801621 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 69 14 00 00       	call   801621 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 2e 2b 80 00       	push   $0x802b2e
  8001bf:	68 f2 2a 80 00       	push   $0x802af2
  8001c4:	68 31 2b 80 00       	push   $0x802b31
  8001c9:	e8 e8 1f 00 00       	call   8021b6 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 35 2b 80 00       	push   $0x802b35
  8001dd:	6a 21                	push   $0x21
  8001df:	68 0b 2b 80 00       	push   $0x802b0b
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 2e 14 00 00       	call   801621 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 22 14 00 00       	call   801621 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 7e 23 00 00       	call   802585 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 09 14 00 00       	call   801621 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 01 14 00 00       	call   801621 <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 3f 2b 80 00       	push   $0x802b3f
  800230:	e8 a6 19 00 00       	call   801bdb <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 a8 2a 80 00       	push   $0x802aa8
  800245:	6a 2c                	push   $0x2c
  800247:	68 0b 2b 80 00       	push   $0x802b0b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 f1 14 00 00       	call   80175d <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 de 14 00 00       	call   80175d <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 4d 2b 80 00       	push   $0x802b4d
  80028c:	6a 33                	push   $0x33
  80028e:	68 0b 2b 80 00       	push   $0x802b0b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 67 2b 80 00       	push   $0x802b67
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 0b 2b 80 00       	push   $0x802b0b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 81 2b 80 00       	push   $0x802b81
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 96 2b 80 00       	push   $0x802b96
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 77 13 00 00       	call   80175d <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 e7 10 00 00       	call   8014f7 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 6f 10 00 00       	call   8014a8 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 06 10 00 00       	call   801481 <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 77 11 00 00       	call   80164c <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 ac 2b 80 00       	push   $0x802bac
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 d8 2a 80 00 	movl   $0x802ad8,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 ab 21 00 00       	call   8027d0 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 98 22 00 00       	call   802900 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 cf 2b 80 00 	movsbl 0x802bcf(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 20 2d 80 00 	jmp    *0x802d20(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 e7 2b 80 00       	push   $0x802be7
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 31 31 80 00       	push   $0x803131
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 e0 2b 80 00       	mov    $0x802be0,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
			base=8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 df 2e 80 00       	push   $0x802edf
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 fc 2e 80 00       	push   $0x802efc
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 df 2e 80 00       	push   $0x802edf
  800f74:	6a 23                	push   $0x23
  800f76:	68 fc 2e 80 00       	push   $0x802efc
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 df 2e 80 00       	push   $0x802edf
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 fc 2e 80 00       	push   $0x802efc
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 df 2e 80 00       	push   $0x802edf
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 fc 2e 80 00       	push   $0x802efc
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 df 2e 80 00       	push   $0x802edf
  80103a:	6a 23                	push   $0x23
  80103c:	68 fc 2e 80 00       	push   $0x802efc
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 df 2e 80 00       	push   $0x802edf
  80107c:	6a 23                	push   $0x23
  80107e:	68 fc 2e 80 00       	push   $0x802efc
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 df 2e 80 00       	push   $0x802edf
  8010be:	6a 23                	push   $0x23
  8010c0:	68 fc 2e 80 00       	push   $0x802efc
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 df 2e 80 00       	push   $0x802edf
  801122:	6a 23                	push   $0x23
  801124:	68 fc 2e 80 00       	push   $0x802efc
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80113e:	8b 18                	mov    (%eax),%ebx
	// edited by Lethe 2018/12/7

	// firstly, check the faulting access was a write
	// Page fault error codes (defined in inc/mmu.h)
	// #define FEC_WR		0x2	// Page fault caused by a write
	if ((err&FEC_WR) == 0) {
  801140:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801144:	75 14                	jne    80115a <pgfault+0x24>
		panic("Not a page fault caused by write!");
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	68 0c 2f 80 00       	push   $0x802f0c
  80114e:	6a 23                	push   $0x23
  801150:	68 cf 2f 80 00       	push   $0x802fcf
  801155:	e8 8a f3 ff ff       	call   8004e4 <_panic>
	// according to the hint, use uvpt which is introduced in 
	// "clever mapping trick"
	// use marco PGNUM(inc/mmu.n)
	// page number field of address
	// #define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)
	if (((uvpt[PGNUM(addr)])& PTE_COW) == 0) {
  80115a:	89 d8                	mov    %ebx,%eax
  80115c:	c1 e8 0c             	shr    $0xc,%eax
  80115f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801166:	f6 c4 08             	test   $0x8,%ah
  801169:	75 14                	jne    80117f <pgfault+0x49>
		panic("Not a page fault access a copy-on-write page!");
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	68 30 2f 80 00       	push   $0x802f30
  801173:	6a 2d                	push   $0x2d
  801175:	68 cf 2f 80 00       	push   $0x802fcf
  80117a:	e8 65 f3 ff ff       	call   8004e4 <_panic>

	// LAB 4: Your code here.

	// edited by Lethe 
	// allocate a new page, map it at PFTEMP
	if ((r = sys_page_alloc(sys_getenvid(), (void *)PFTEMP, PTE_U | PTE_P | PTE_W)) < 0) {
  80117f:	e8 83 fd ff ff       	call   800f07 <sys_getenvid>
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	6a 07                	push   $0x7
  801189:	68 00 f0 7f 00       	push   $0x7ff000
  80118e:	50                   	push   %eax
  80118f:	e8 b1 fd ff ff       	call   800f45 <sys_page_alloc>
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	79 12                	jns    8011ad <pgfault+0x77>
		panic("Sys page alloc error: %e", r);
  80119b:	50                   	push   %eax
  80119c:	68 da 2f 80 00       	push   $0x802fda
  8011a1:	6a 3b                	push   $0x3b
  8011a3:	68 cf 2f 80 00       	push   $0x802fcf
  8011a8:	e8 37 f3 ff ff       	call   8004e4 <_panic>
	}

	// make addr page alligned here
	addr = ROUNDDOWN(addr, PGSIZE);
  8011ad:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// copy the date from the old page to the new page
	memmove((void *)PFTEMP, addr, PGSIZE);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	68 00 10 00 00       	push   $0x1000
  8011bb:	53                   	push   %ebx
  8011bc:	68 00 f0 7f 00       	push   $0x7ff000
  8011c1:	e8 0e fb ff ff       	call   800cd4 <memmove>

	// move the new page to the old page's address
	// static int sys_page_map(envid_t srcenvid, void *srcva, envid_t dstenvid, void *dstva, int perm)
	// static int sys_page_unmap(envid_t envid, void *va)
	// addr is page alligned now!
	if ((r = sys_page_map(sys_getenvid(), (void *)PFTEMP, sys_getenvid(), addr, PTE_U | PTE_P | PTE_W)) < 0) {
  8011c6:	e8 3c fd ff ff       	call   800f07 <sys_getenvid>
  8011cb:	89 c6                	mov    %eax,%esi
  8011cd:	e8 35 fd ff ff       	call   800f07 <sys_getenvid>
  8011d2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8011d9:	53                   	push   %ebx
  8011da:	56                   	push   %esi
  8011db:	68 00 f0 7f 00       	push   $0x7ff000
  8011e0:	50                   	push   %eax
  8011e1:	e8 a2 fd ff ff       	call   800f88 <sys_page_map>
  8011e6:	83 c4 20             	add    $0x20,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	79 12                	jns    8011ff <pgfault+0xc9>
		panic("Sys page map error: %e", r);
  8011ed:	50                   	push   %eax
  8011ee:	68 f3 2f 80 00       	push   $0x802ff3
  8011f3:	6a 48                	push   $0x48
  8011f5:	68 cf 2f 80 00       	push   $0x802fcf
  8011fa:	e8 e5 f2 ff ff       	call   8004e4 <_panic>
	}
	// unmap PFTEMP now
	if ((r = sys_page_unmap(sys_getenvid(), (void *)PFTEMP)) < 0) {
  8011ff:	e8 03 fd ff ff       	call   800f07 <sys_getenvid>
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	68 00 f0 7f 00       	push   $0x7ff000
  80120c:	50                   	push   %eax
  80120d:	e8 b8 fd ff ff       	call   800fca <sys_page_unmap>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	79 12                	jns    80122b <pgfault+0xf5>
		panic("Sys page unmap error: %e", r);
  801219:	50                   	push   %eax
  80121a:	68 0a 30 80 00       	push   $0x80300a
  80121f:	6a 4c                	push   $0x4c
  801221:	68 cf 2f 80 00       	push   $0x802fcf
  801226:	e8 b9 f2 ff ff       	call   8004e4 <_panic>
	}

	//panic("pgfault not implemented");
}
  80122b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122e:	5b                   	pop    %ebx
  80122f:	5e                   	pop    %esi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    

00801232 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	57                   	push   %edi
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	
	// edited by Lethe  
	// firstly, set up our page fault handler appropriately.
	set_pgfault_handler(pgfault);
  80123b:	68 36 11 80 00       	push   $0x801136
  801240:	e8 8f 13 00 00       	call   8025d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801245:	b8 07 00 00 00       	mov    $0x7,%eax
  80124a:	cd 30                	int    $0x30
  80124c:	89 c7                	mov    %eax,%edi
  80124e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// secondly, create a child
	envid_t eid = sys_exofork();
	if (eid < 0) {
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	79 15                	jns    80126d <fork+0x3b>
		panic("Sys exofork error: %e", eid);
  801258:	50                   	push   %eax
  801259:	68 23 30 80 00       	push   $0x803023
  80125e:	68 a1 00 00 00       	push   $0xa1
  801263:	68 cf 2f 80 00       	push   $0x802fcf
  801268:	e8 77 f2 ff ff       	call   8004e4 <_panic>
  80126d:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	if (eid == 0) {
  801272:	85 c0                	test   %eax,%eax
  801274:	75 21                	jne    801297 <fork+0x65>
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
  801276:	e8 8c fc ff ff       	call   800f07 <sys_getenvid>
  80127b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801280:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801283:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801288:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	e9 c8 01 00 00       	jmp    80145f <fork+0x22d>
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  801297:	89 d8                	mov    %ebx,%eax
  801299:	c1 e8 16             	shr    $0x16,%eax
  80129c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a3:	a8 01                	test   $0x1,%al
  8012a5:	0f 84 23 01 00 00    	je     8013ce <fork+0x19c>
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	c1 e8 0c             	shr    $0xc,%eax
  8012b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	0f 84 0e 01 00 00    	je     8013ce <fork+0x19c>
  8012c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012c7:	f6 c2 04             	test   $0x4,%dl
  8012ca:	0f 84 fe 00 00 00    	je     8013ce <fork+0x19c>
{
	int r;

	// LAB 4: Your code here.
	// edited by Lethe  2018/12/7
	void * va = (void *)(pn * PGSIZE);
  8012d0:	89 c6                	mov    %eax,%esi
  8012d2:	c1 e6 0c             	shl    $0xc,%esi

	// pay attention to the comment in inc/env.h
	// "The envid_t == 0 is special, and stands for the current environment."
	// modified for exercise8,lab5
	// edited by LETHE 2018/12/14
	if (uvpt[pn] & PTE_SHARE) {
  8012d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012dc:	f6 c6 04             	test   $0x4,%dh
  8012df:	74 3f                	je     801320 <fork+0xee>
		if ((r = sys_page_map(0, va, envid, va, uvpt[pn] & PTE_SYSCALL)) < 0) {
  8012e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f0:	50                   	push   %eax
  8012f1:	56                   	push   %esi
  8012f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012f5:	56                   	push   %esi
  8012f6:	6a 00                	push   $0x0
  8012f8:	e8 8b fc ff ff       	call   800f88 <sys_page_map>
  8012fd:	83 c4 20             	add    $0x20,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	0f 89 c6 00 00 00    	jns    8013ce <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	50                   	push   %eax
  80130c:	57                   	push   %edi
  80130d:	6a 00                	push   $0x0
  80130f:	68 60 2f 80 00       	push   $0x802f60
  801314:	6a 6c                	push   $0x6c
  801316:	68 cf 2f 80 00       	push   $0x802fcf
  80131b:	e8 c4 f1 ff ff       	call   8004e4 <_panic>
		}
	}
	else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801320:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801327:	f6 c2 02             	test   $0x2,%dl
  80132a:	75 0c                	jne    801338 <fork+0x106>
  80132c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801333:	f6 c4 08             	test   $0x8,%ah
  801336:	74 66                	je     80139e <fork+0x16c>
		// If the page is writable or copy-on-write, the new mapping must 
		// be created copy-on-write, and then our mapping must be marked 
		// copy-on-write as well.
		if ((r=sys_page_map(0, va, envid, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	68 05 08 00 00       	push   $0x805
  801340:	56                   	push   %esi
  801341:	ff 75 e4             	pushl  -0x1c(%ebp)
  801344:	56                   	push   %esi
  801345:	6a 00                	push   $0x0
  801347:	e8 3c fc ff ff       	call   800f88 <sys_page_map>
  80134c:	83 c4 20             	add    $0x20,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	79 18                	jns    80136b <fork+0x139>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	50                   	push   %eax
  801357:	57                   	push   %edi
  801358:	6a 00                	push   $0x0
  80135a:	68 60 2f 80 00       	push   $0x802f60
  80135f:	6a 74                	push   $0x74
  801361:	68 cf 2f 80 00       	push   $0x802fcf
  801366:	e8 79 f1 ff ff       	call   8004e4 <_panic>
		}
		if ((r = sys_page_map(0, va, 0, va, PTE_P | PTE_U | PTE_COW)) < 0) {
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	68 05 08 00 00       	push   $0x805
  801373:	56                   	push   %esi
  801374:	6a 00                	push   $0x0
  801376:	56                   	push   %esi
  801377:	6a 00                	push   $0x0
  801379:	e8 0a fc ff ff       	call   800f88 <sys_page_map>
  80137e:	83 c4 20             	add    $0x20,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	79 49                	jns    8013ce <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, 0, r);
  801385:	83 ec 08             	sub    $0x8,%esp
  801388:	50                   	push   %eax
  801389:	6a 00                	push   $0x0
  80138b:	6a 00                	push   $0x0
  80138d:	68 60 2f 80 00       	push   $0x802f60
  801392:	6a 77                	push   $0x77
  801394:	68 cf 2f 80 00       	push   $0x802fcf
  801399:	e8 46 f1 ff ff       	call   8004e4 <_panic>
		}
	}
	else {
		// how to handle pages with other type of perm?
		if ((r = sys_page_map(0, va, envid, va, PTE_P | PTE_U)) < 0) {
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	6a 05                	push   $0x5
  8013a3:	56                   	push   %esi
  8013a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a7:	56                   	push   %esi
  8013a8:	6a 00                	push   $0x0
  8013aa:	e8 d9 fb ff ff       	call   800f88 <sys_page_map>
  8013af:	83 c4 20             	add    $0x20,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	79 18                	jns    8013ce <fork+0x19c>
			panic("Sys page map from env%d to env%d error: %e", 0, envid, r);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	50                   	push   %eax
  8013ba:	57                   	push   %edi
  8013bb:	6a 00                	push   $0x0
  8013bd:	68 60 2f 80 00       	push   $0x802f60
  8013c2:	6a 7d                	push   $0x7d
  8013c4:	68 cf 2f 80 00       	push   $0x802fcf
  8013c9:	e8 16 f1 ff ff       	call   8004e4 <_panic>
		return 0;
	}

	// thirdly, copy our address space
	uintptr_t addr = 0;
	for (addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8013ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013d4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8013da:	0f 85 b7 fe ff ff    	jne    801297 <fork+0x65>
		}
	}

	// fourthly, allocate a new page for the child's user exception stack
	int r = 0;
	if ((r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	6a 07                	push   $0x7
  8013e5:	68 00 f0 bf ee       	push   $0xeebff000
  8013ea:	57                   	push   %edi
  8013eb:	e8 55 fb ff ff       	call   800f45 <sys_page_alloc>
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	79 15                	jns    80140c <fork+0x1da>
		panic("Allocate a new page for the child's user exception stack error: %e", r);
  8013f7:	50                   	push   %eax
  8013f8:	68 8c 2f 80 00       	push   $0x802f8c
  8013fd:	68 b4 00 00 00       	push   $0xb4
  801402:	68 cf 2f 80 00       	push   $0x802fcf
  801407:	e8 d8 f0 ff ff       	call   8004e4 <_panic>
	}

	// fifthly, setup page fault handler setup for the child
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall)) < 0) {
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	68 48 26 80 00       	push   $0x802648
  801414:	57                   	push   %edi
  801415:	e8 76 fc ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	79 15                	jns    801436 <fork+0x204>
		panic("Set pgfault upcall error: %e", r);
  801421:	50                   	push   %eax
  801422:	68 39 30 80 00       	push   $0x803039
  801427:	68 ba 00 00 00       	push   $0xba
  80142c:	68 cf 2f 80 00       	push   $0x802fcf
  801431:	e8 ae f0 ff ff       	call   8004e4 <_panic>
	}

	// sixthly, mark the child as runnable and return.
	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0) {
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	6a 02                	push   $0x2
  80143b:	57                   	push   %edi
  80143c:	e8 cb fb ff ff       	call   80100c <sys_env_set_status>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	79 15                	jns    80145d <fork+0x22b>
		panic("Sys env set status error: %e", r);
  801448:	50                   	push   %eax
  801449:	68 56 30 80 00       	push   $0x803056
  80144e:	68 bf 00 00 00       	push   $0xbf
  801453:	68 cf 2f 80 00       	push   $0x802fcf
  801458:	e8 87 f0 ff ff       	call   8004e4 <_panic>
	}
	return eid;
  80145d:	89 f8                	mov    %edi,%eax

	//panic("fork not implemented");
}
  80145f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801462:	5b                   	pop    %ebx
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    

00801467 <sfork>:

// Challenge!
int
sfork(void)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80146d:	68 73 30 80 00       	push   $0x803073
  801472:	68 ca 00 00 00       	push   $0xca
  801477:	68 cf 2f 80 00       	push   $0x802fcf
  80147c:	e8 63 f0 ff ff       	call   8004e4 <_panic>

00801481 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	05 00 00 00 30       	add    $0x30000000,%eax
  80148c:	c1 e8 0c             	shr    $0xc,%eax
}
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	05 00 00 00 30       	add    $0x30000000,%eax
  80149c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014a1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b3:	89 c2                	mov    %eax,%edx
  8014b5:	c1 ea 16             	shr    $0x16,%edx
  8014b8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	74 11                	je     8014d5 <fd_alloc+0x2d>
  8014c4:	89 c2                	mov    %eax,%edx
  8014c6:	c1 ea 0c             	shr    $0xc,%edx
  8014c9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d0:	f6 c2 01             	test   $0x1,%dl
  8014d3:	75 09                	jne    8014de <fd_alloc+0x36>
			*fd_store = fd;
  8014d5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014dc:	eb 17                	jmp    8014f5 <fd_alloc+0x4d>
  8014de:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014e3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014e8:	75 c9                	jne    8014b3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ea:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014f0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014fd:	83 f8 1f             	cmp    $0x1f,%eax
  801500:	77 36                	ja     801538 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801502:	c1 e0 0c             	shl    $0xc,%eax
  801505:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80150a:	89 c2                	mov    %eax,%edx
  80150c:	c1 ea 16             	shr    $0x16,%edx
  80150f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801516:	f6 c2 01             	test   $0x1,%dl
  801519:	74 24                	je     80153f <fd_lookup+0x48>
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	c1 ea 0c             	shr    $0xc,%edx
  801520:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801527:	f6 c2 01             	test   $0x1,%dl
  80152a:	74 1a                	je     801546 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80152c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152f:	89 02                	mov    %eax,(%edx)
	return 0;
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
  801536:	eb 13                	jmp    80154b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801538:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153d:	eb 0c                	jmp    80154b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801544:	eb 05                	jmp    80154b <fd_lookup+0x54>
  801546:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801556:	ba 08 31 80 00       	mov    $0x803108,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80155b:	eb 13                	jmp    801570 <dev_lookup+0x23>
  80155d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801560:	39 08                	cmp    %ecx,(%eax)
  801562:	75 0c                	jne    801570 <dev_lookup+0x23>
			*dev = devtab[i];
  801564:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801567:	89 01                	mov    %eax,(%ecx)
			return 0;
  801569:	b8 00 00 00 00       	mov    $0x0,%eax
  80156e:	eb 2e                	jmp    80159e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801570:	8b 02                	mov    (%edx),%eax
  801572:	85 c0                	test   %eax,%eax
  801574:	75 e7                	jne    80155d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801576:	a1 04 50 80 00       	mov    0x805004,%eax
  80157b:	8b 40 48             	mov    0x48(%eax),%eax
  80157e:	83 ec 04             	sub    $0x4,%esp
  801581:	51                   	push   %ecx
  801582:	50                   	push   %eax
  801583:	68 8c 30 80 00       	push   $0x80308c
  801588:	e8 30 f0 ff ff       	call   8005bd <cprintf>
	*dev = 0;
  80158d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801590:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 10             	sub    $0x10,%esp
  8015a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015b8:	c1 e8 0c             	shr    $0xc,%eax
  8015bb:	50                   	push   %eax
  8015bc:	e8 36 ff ff ff       	call   8014f7 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 05                	js     8015cd <fd_close+0x2d>
	    || fd != fd2)
  8015c8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015cb:	74 0c                	je     8015d9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015cd:	84 db                	test   %bl,%bl
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	0f 44 c2             	cmove  %edx,%eax
  8015d7:	eb 41                	jmp    80161a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	ff 36                	pushl  (%esi)
  8015e2:	e8 66 ff ff ff       	call   80154d <dev_lookup>
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 1a                	js     80160a <fd_close+0x6a>
		if (dev->dev_close)
  8015f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015f6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	74 0b                	je     80160a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	56                   	push   %esi
  801603:	ff d0                	call   *%eax
  801605:	89 c3                	mov    %eax,%ebx
  801607:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	6a 00                	push   $0x0
  801610:	e8 b5 f9 ff ff       	call   800fca <sys_page_unmap>
	return r;
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	89 d8                	mov    %ebx,%eax
}
  80161a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161d:	5b                   	pop    %ebx
  80161e:	5e                   	pop    %esi
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801627:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	ff 75 08             	pushl  0x8(%ebp)
  80162e:	e8 c4 fe ff ff       	call   8014f7 <fd_lookup>
  801633:	83 c4 08             	add    $0x8,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 10                	js     80164a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	6a 01                	push   $0x1
  80163f:	ff 75 f4             	pushl  -0xc(%ebp)
  801642:	e8 59 ff ff ff       	call   8015a0 <fd_close>
  801647:	83 c4 10             	add    $0x10,%esp
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <close_all>:

void
close_all(void)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	53                   	push   %ebx
  801650:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801653:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	53                   	push   %ebx
  80165c:	e8 c0 ff ff ff       	call   801621 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801661:	83 c3 01             	add    $0x1,%ebx
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	83 fb 20             	cmp    $0x20,%ebx
  80166a:	75 ec                	jne    801658 <close_all+0xc>
		close(i);
}
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	57                   	push   %edi
  801675:	56                   	push   %esi
  801676:	53                   	push   %ebx
  801677:	83 ec 2c             	sub    $0x2c,%esp
  80167a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80167d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 6e fe ff ff       	call   8014f7 <fd_lookup>
  801689:	83 c4 08             	add    $0x8,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	0f 88 c1 00 00 00    	js     801755 <dup+0xe4>
		return r;
	close(newfdnum);
  801694:	83 ec 0c             	sub    $0xc,%esp
  801697:	56                   	push   %esi
  801698:	e8 84 ff ff ff       	call   801621 <close>

	newfd = INDEX2FD(newfdnum);
  80169d:	89 f3                	mov    %esi,%ebx
  80169f:	c1 e3 0c             	shl    $0xc,%ebx
  8016a2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016a8:	83 c4 04             	add    $0x4,%esp
  8016ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ae:	e8 de fd ff ff       	call   801491 <fd2data>
  8016b3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016b5:	89 1c 24             	mov    %ebx,(%esp)
  8016b8:	e8 d4 fd ff ff       	call   801491 <fd2data>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016c3:	89 f8                	mov    %edi,%eax
  8016c5:	c1 e8 16             	shr    $0x16,%eax
  8016c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016cf:	a8 01                	test   $0x1,%al
  8016d1:	74 37                	je     80170a <dup+0x99>
  8016d3:	89 f8                	mov    %edi,%eax
  8016d5:	c1 e8 0c             	shr    $0xc,%eax
  8016d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016df:	f6 c2 01             	test   $0x1,%dl
  8016e2:	74 26                	je     80170a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f7:	6a 00                	push   $0x0
  8016f9:	57                   	push   %edi
  8016fa:	6a 00                	push   $0x0
  8016fc:	e8 87 f8 ff ff       	call   800f88 <sys_page_map>
  801701:	89 c7                	mov    %eax,%edi
  801703:	83 c4 20             	add    $0x20,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 2e                	js     801738 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170d:	89 d0                	mov    %edx,%eax
  80170f:	c1 e8 0c             	shr    $0xc,%eax
  801712:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801719:	83 ec 0c             	sub    $0xc,%esp
  80171c:	25 07 0e 00 00       	and    $0xe07,%eax
  801721:	50                   	push   %eax
  801722:	53                   	push   %ebx
  801723:	6a 00                	push   $0x0
  801725:	52                   	push   %edx
  801726:	6a 00                	push   $0x0
  801728:	e8 5b f8 ff ff       	call   800f88 <sys_page_map>
  80172d:	89 c7                	mov    %eax,%edi
  80172f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801732:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801734:	85 ff                	test   %edi,%edi
  801736:	79 1d                	jns    801755 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	53                   	push   %ebx
  80173c:	6a 00                	push   $0x0
  80173e:	e8 87 f8 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801743:	83 c4 08             	add    $0x8,%esp
  801746:	ff 75 d4             	pushl  -0x2c(%ebp)
  801749:	6a 00                	push   $0x0
  80174b:	e8 7a f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	89 f8                	mov    %edi,%eax
}
  801755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801758:	5b                   	pop    %ebx
  801759:	5e                   	pop    %esi
  80175a:	5f                   	pop    %edi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	53                   	push   %ebx
  801761:	83 ec 14             	sub    $0x14,%esp
  801764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	53                   	push   %ebx
  80176c:	e8 86 fd ff ff       	call   8014f7 <fd_lookup>
  801771:	83 c4 08             	add    $0x8,%esp
  801774:	89 c2                	mov    %eax,%edx
  801776:	85 c0                	test   %eax,%eax
  801778:	78 6d                	js     8017e7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	ff 30                	pushl  (%eax)
  801786:	e8 c2 fd ff ff       	call   80154d <dev_lookup>
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 4c                	js     8017de <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801792:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801795:	8b 42 08             	mov    0x8(%edx),%eax
  801798:	83 e0 03             	and    $0x3,%eax
  80179b:	83 f8 01             	cmp    $0x1,%eax
  80179e:	75 21                	jne    8017c1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a0:	a1 04 50 80 00       	mov    0x805004,%eax
  8017a5:	8b 40 48             	mov    0x48(%eax),%eax
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	53                   	push   %ebx
  8017ac:	50                   	push   %eax
  8017ad:	68 cd 30 80 00       	push   $0x8030cd
  8017b2:	e8 06 ee ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017bf:	eb 26                	jmp    8017e7 <read+0x8a>
	}
	if (!dev->dev_read)
  8017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c4:	8b 40 08             	mov    0x8(%eax),%eax
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	74 17                	je     8017e2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	ff 75 10             	pushl  0x10(%ebp)
  8017d1:	ff 75 0c             	pushl  0xc(%ebp)
  8017d4:	52                   	push   %edx
  8017d5:	ff d0                	call   *%eax
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	eb 09                	jmp    8017e7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017de:	89 c2                	mov    %eax,%edx
  8017e0:	eb 05                	jmp    8017e7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017e7:	89 d0                	mov    %edx,%eax
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	57                   	push   %edi
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 0c             	sub    $0xc,%esp
  8017f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801802:	eb 21                	jmp    801825 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	89 f0                	mov    %esi,%eax
  801809:	29 d8                	sub    %ebx,%eax
  80180b:	50                   	push   %eax
  80180c:	89 d8                	mov    %ebx,%eax
  80180e:	03 45 0c             	add    0xc(%ebp),%eax
  801811:	50                   	push   %eax
  801812:	57                   	push   %edi
  801813:	e8 45 ff ff ff       	call   80175d <read>
		if (m < 0)
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 10                	js     80182f <readn+0x41>
			return m;
		if (m == 0)
  80181f:	85 c0                	test   %eax,%eax
  801821:	74 0a                	je     80182d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801823:	01 c3                	add    %eax,%ebx
  801825:	39 f3                	cmp    %esi,%ebx
  801827:	72 db                	jb     801804 <readn+0x16>
  801829:	89 d8                	mov    %ebx,%eax
  80182b:	eb 02                	jmp    80182f <readn+0x41>
  80182d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80182f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5f                   	pop    %edi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	53                   	push   %ebx
  80183b:	83 ec 14             	sub    $0x14,%esp
  80183e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801841:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801844:	50                   	push   %eax
  801845:	53                   	push   %ebx
  801846:	e8 ac fc ff ff       	call   8014f7 <fd_lookup>
  80184b:	83 c4 08             	add    $0x8,%esp
  80184e:	89 c2                	mov    %eax,%edx
  801850:	85 c0                	test   %eax,%eax
  801852:	78 68                	js     8018bc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185a:	50                   	push   %eax
  80185b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185e:	ff 30                	pushl  (%eax)
  801860:	e8 e8 fc ff ff       	call   80154d <dev_lookup>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 47                	js     8018b3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80186c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801873:	75 21                	jne    801896 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801875:	a1 04 50 80 00       	mov    0x805004,%eax
  80187a:	8b 40 48             	mov    0x48(%eax),%eax
  80187d:	83 ec 04             	sub    $0x4,%esp
  801880:	53                   	push   %ebx
  801881:	50                   	push   %eax
  801882:	68 e9 30 80 00       	push   $0x8030e9
  801887:	e8 31 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801894:	eb 26                	jmp    8018bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801896:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801899:	8b 52 0c             	mov    0xc(%edx),%edx
  80189c:	85 d2                	test   %edx,%edx
  80189e:	74 17                	je     8018b7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018a0:	83 ec 04             	sub    $0x4,%esp
  8018a3:	ff 75 10             	pushl  0x10(%ebp)
  8018a6:	ff 75 0c             	pushl  0xc(%ebp)
  8018a9:	50                   	push   %eax
  8018aa:	ff d2                	call   *%edx
  8018ac:	89 c2                	mov    %eax,%edx
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	eb 09                	jmp    8018bc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	eb 05                	jmp    8018bc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018bc:	89 d0                	mov    %edx,%eax
  8018be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	ff 75 08             	pushl  0x8(%ebp)
  8018d0:	e8 22 fc ff ff       	call   8014f7 <fd_lookup>
  8018d5:	83 c4 08             	add    $0x8,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 0e                	js     8018ea <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 14             	sub    $0x14,%esp
  8018f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	53                   	push   %ebx
  8018fb:	e8 f7 fb ff ff       	call   8014f7 <fd_lookup>
  801900:	83 c4 08             	add    $0x8,%esp
  801903:	89 c2                	mov    %eax,%edx
  801905:	85 c0                	test   %eax,%eax
  801907:	78 65                	js     80196e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190f:	50                   	push   %eax
  801910:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801913:	ff 30                	pushl  (%eax)
  801915:	e8 33 fc ff ff       	call   80154d <dev_lookup>
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 44                	js     801965 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801921:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801924:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801928:	75 21                	jne    80194b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80192a:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80192f:	8b 40 48             	mov    0x48(%eax),%eax
  801932:	83 ec 04             	sub    $0x4,%esp
  801935:	53                   	push   %ebx
  801936:	50                   	push   %eax
  801937:	68 ac 30 80 00       	push   $0x8030ac
  80193c:	e8 7c ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801949:	eb 23                	jmp    80196e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80194b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194e:	8b 52 18             	mov    0x18(%edx),%edx
  801951:	85 d2                	test   %edx,%edx
  801953:	74 14                	je     801969 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	50                   	push   %eax
  80195c:	ff d2                	call   *%edx
  80195e:	89 c2                	mov    %eax,%edx
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb 09                	jmp    80196e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801965:	89 c2                	mov    %eax,%edx
  801967:	eb 05                	jmp    80196e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801969:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80196e:	89 d0                	mov    %edx,%eax
  801970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	53                   	push   %ebx
  801979:	83 ec 14             	sub    $0x14,%esp
  80197c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80197f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	ff 75 08             	pushl  0x8(%ebp)
  801986:	e8 6c fb ff ff       	call   8014f7 <fd_lookup>
  80198b:	83 c4 08             	add    $0x8,%esp
  80198e:	89 c2                	mov    %eax,%edx
  801990:	85 c0                	test   %eax,%eax
  801992:	78 58                	js     8019ec <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199e:	ff 30                	pushl  (%eax)
  8019a0:	e8 a8 fb ff ff       	call   80154d <dev_lookup>
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 37                	js     8019e3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019b3:	74 32                	je     8019e7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019bf:	00 00 00 
	stat->st_isdir = 0;
  8019c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019c9:	00 00 00 
	stat->st_dev = dev;
  8019cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	53                   	push   %ebx
  8019d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d9:	ff 50 14             	call   *0x14(%eax)
  8019dc:	89 c2                	mov    %eax,%edx
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	eb 09                	jmp    8019ec <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	eb 05                	jmp    8019ec <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019ec:	89 d0                	mov    %edx,%eax
  8019ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 08             	pushl  0x8(%ebp)
  801a00:	e8 d6 01 00 00       	call   801bdb <open>
  801a05:	89 c3                	mov    %eax,%ebx
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 1b                	js     801a29 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	ff 75 0c             	pushl  0xc(%ebp)
  801a14:	50                   	push   %eax
  801a15:	e8 5b ff ff ff       	call   801975 <fstat>
  801a1a:	89 c6                	mov    %eax,%esi
	close(fd);
  801a1c:	89 1c 24             	mov    %ebx,(%esp)
  801a1f:	e8 fd fb ff ff       	call   801621 <close>
	return r;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	89 f0                	mov    %esi,%eax
}
  801a29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	89 c6                	mov    %eax,%esi
  801a37:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a39:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a40:	75 12                	jne    801a54 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	6a 01                	push   $0x1
  801a47:	e8 0c 0d 00 00       	call   802758 <ipc_find_env>
  801a4c:	a3 00 50 80 00       	mov    %eax,0x805000
  801a51:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a54:	6a 07                	push   $0x7
  801a56:	68 00 60 80 00       	push   $0x806000
  801a5b:	56                   	push   %esi
  801a5c:	ff 35 00 50 80 00    	pushl  0x805000
  801a62:	e8 9d 0c 00 00       	call   802704 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a67:	83 c4 0c             	add    $0xc,%esp
  801a6a:	6a 00                	push   $0x0
  801a6c:	53                   	push   %ebx
  801a6d:	6a 00                	push   $0x0
  801a6f:	e8 f8 0b 00 00       	call   80266c <ipc_recv>
}
  801a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	8b 40 0c             	mov    0xc(%eax),%eax
  801a87:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a94:	ba 00 00 00 00       	mov    $0x0,%edx
  801a99:	b8 02 00 00 00       	mov    $0x2,%eax
  801a9e:	e8 8d ff ff ff       	call   801a30 <fsipc>
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab1:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  801abb:	b8 06 00 00 00       	mov    $0x6,%eax
  801ac0:	e8 6b ff ff ff       	call   801a30 <fsipc>
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	53                   	push   %ebx
  801acb:	83 ec 04             	sub    $0x4,%esp
  801ace:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801adc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ae6:	e8 45 ff ff ff       	call   801a30 <fsipc>
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 2c                	js     801b1b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aef:	83 ec 08             	sub    $0x8,%esp
  801af2:	68 00 60 80 00       	push   $0x806000
  801af7:	53                   	push   %ebx
  801af8:	e8 45 f0 ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801afd:	a1 80 60 80 00       	mov    0x806080,%eax
  801b02:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b08:	a1 84 60 80 00       	mov    0x806084,%eax
  801b0d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b29:	8b 55 08             	mov    0x8(%ebp),%edx
  801b2c:	8b 52 0c             	mov    0xc(%edx),%edx
  801b2f:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b35:	a3 04 60 80 00       	mov    %eax,0x806004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801b3a:	50                   	push   %eax
  801b3b:	ff 75 0c             	pushl  0xc(%ebp)
  801b3e:	68 08 60 80 00       	push   $0x806008
  801b43:	e8 8c f1 ff ff       	call   800cd4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b48:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b52:	e8 d9 fe ff ff       	call   801a30 <fsipc>
	//panic("devfile_write not implemented");
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	56                   	push   %esi
  801b5d:	53                   	push   %ebx
  801b5e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b61:	8b 45 08             	mov    0x8(%ebp),%eax
  801b64:	8b 40 0c             	mov    0xc(%eax),%eax
  801b67:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b6c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b72:	ba 00 00 00 00       	mov    $0x0,%edx
  801b77:	b8 03 00 00 00       	mov    $0x3,%eax
  801b7c:	e8 af fe ff ff       	call   801a30 <fsipc>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 4b                	js     801bd2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b87:	39 c6                	cmp    %eax,%esi
  801b89:	73 16                	jae    801ba1 <devfile_read+0x48>
  801b8b:	68 18 31 80 00       	push   $0x803118
  801b90:	68 1f 31 80 00       	push   $0x80311f
  801b95:	6a 7c                	push   $0x7c
  801b97:	68 34 31 80 00       	push   $0x803134
  801b9c:	e8 43 e9 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801ba1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba6:	7e 16                	jle    801bbe <devfile_read+0x65>
  801ba8:	68 3f 31 80 00       	push   $0x80313f
  801bad:	68 1f 31 80 00       	push   $0x80311f
  801bb2:	6a 7d                	push   $0x7d
  801bb4:	68 34 31 80 00       	push   $0x803134
  801bb9:	e8 26 e9 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bbe:	83 ec 04             	sub    $0x4,%esp
  801bc1:	50                   	push   %eax
  801bc2:	68 00 60 80 00       	push   $0x806000
  801bc7:	ff 75 0c             	pushl  0xc(%ebp)
  801bca:	e8 05 f1 ff ff       	call   800cd4 <memmove>
	return r;
  801bcf:	83 c4 10             	add    $0x10,%esp
}
  801bd2:	89 d8                	mov    %ebx,%eax
  801bd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 20             	sub    $0x20,%esp
  801be2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801be5:	53                   	push   %ebx
  801be6:	e8 1e ef ff ff       	call   800b09 <strlen>
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bf3:	7f 67                	jg     801c5c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf5:	83 ec 0c             	sub    $0xc,%esp
  801bf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfb:	50                   	push   %eax
  801bfc:	e8 a7 f8 ff ff       	call   8014a8 <fd_alloc>
  801c01:	83 c4 10             	add    $0x10,%esp
		return r;
  801c04:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 57                	js     801c61 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c0a:	83 ec 08             	sub    $0x8,%esp
  801c0d:	53                   	push   %ebx
  801c0e:	68 00 60 80 00       	push   $0x806000
  801c13:	e8 2a ef ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c23:	b8 01 00 00 00       	mov    $0x1,%eax
  801c28:	e8 03 fe ff ff       	call   801a30 <fsipc>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	79 14                	jns    801c4a <open+0x6f>
		fd_close(fd, 0);
  801c36:	83 ec 08             	sub    $0x8,%esp
  801c39:	6a 00                	push   $0x0
  801c3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3e:	e8 5d f9 ff ff       	call   8015a0 <fd_close>
		return r;
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	89 da                	mov    %ebx,%edx
  801c48:	eb 17                	jmp    801c61 <open+0x86>
	}

	return fd2num(fd);
  801c4a:	83 ec 0c             	sub    $0xc,%esp
  801c4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c50:	e8 2c f8 ff ff       	call   801481 <fd2num>
  801c55:	89 c2                	mov    %eax,%edx
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	eb 05                	jmp    801c61 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c5c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c61:	89 d0                	mov    %edx,%eax
  801c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c73:	b8 08 00 00 00       	mov    $0x8,%eax
  801c78:	e8 b3 fd ff ff       	call   801a30 <fsipc>
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	57                   	push   %edi
  801c83:	56                   	push   %esi
  801c84:	53                   	push   %ebx
  801c85:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c8b:	6a 00                	push   $0x0
  801c8d:	ff 75 08             	pushl  0x8(%ebp)
  801c90:	e8 46 ff ff ff       	call   801bdb <open>
  801c95:	89 c7                	mov    %eax,%edi
  801c97:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	0f 88 a4 04 00 00    	js     80214c <spawn+0x4cd>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ca8:	83 ec 04             	sub    $0x4,%esp
  801cab:	68 00 02 00 00       	push   $0x200
  801cb0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cb6:	50                   	push   %eax
  801cb7:	57                   	push   %edi
  801cb8:	e8 31 fb ff ff       	call   8017ee <readn>
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cc5:	75 0c                	jne    801cd3 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801cc7:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cce:	45 4c 46 
  801cd1:	74 33                	je     801d06 <spawn+0x87>
		close(fd);
  801cd3:	83 ec 0c             	sub    $0xc,%esp
  801cd6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cdc:	e8 40 f9 ff ff       	call   801621 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ce1:	83 c4 0c             	add    $0xc,%esp
  801ce4:	68 7f 45 4c 46       	push   $0x464c457f
  801ce9:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801cef:	68 4b 31 80 00       	push   $0x80314b
  801cf4:	e8 c4 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d01:	e9 a6 04 00 00       	jmp    8021ac <spawn+0x52d>
  801d06:	b8 07 00 00 00       	mov    $0x7,%eax
  801d0b:	cd 30                	int    $0x30
  801d0d:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d13:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	0f 88 33 04 00 00    	js     802154 <spawn+0x4d5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d21:	89 c6                	mov    %eax,%esi
  801d23:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d29:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801d2c:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d32:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d38:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d3f:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d45:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801d50:	be 00 00 00 00       	mov    $0x0,%esi
  801d55:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d58:	eb 13                	jmp    801d6d <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	50                   	push   %eax
  801d5e:	e8 a6 ed ff ff       	call   800b09 <strlen>
  801d63:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d67:	83 c3 01             	add    $0x1,%ebx
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d74:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d77:	85 c0                	test   %eax,%eax
  801d79:	75 df                	jne    801d5a <spawn+0xdb>
  801d7b:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801d81:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d87:	bf 00 10 40 00       	mov    $0x401000,%edi
  801d8c:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d8e:	89 fa                	mov    %edi,%edx
  801d90:	83 e2 fc             	and    $0xfffffffc,%edx
  801d93:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d9a:	29 c2                	sub    %eax,%edx
  801d9c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801da2:	8d 42 f8             	lea    -0x8(%edx),%eax
  801da5:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801daa:	0f 86 b4 03 00 00    	jbe    802164 <spawn+0x4e5>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801db0:	83 ec 04             	sub    $0x4,%esp
  801db3:	6a 07                	push   $0x7
  801db5:	68 00 00 40 00       	push   $0x400000
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 84 f1 ff ff       	call   800f45 <sys_page_alloc>
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 88 9f 03 00 00    	js     80216b <spawn+0x4ec>
  801dcc:	be 00 00 00 00       	mov    $0x0,%esi
  801dd1:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dda:	eb 30                	jmp    801e0c <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ddc:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801de2:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801de8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801deb:	83 ec 08             	sub    $0x8,%esp
  801dee:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801df1:	57                   	push   %edi
  801df2:	e8 4b ed ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801df7:	83 c4 04             	add    $0x4,%esp
  801dfa:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801dfd:	e8 07 ed ff ff       	call   800b09 <strlen>
  801e02:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e06:	83 c6 01             	add    $0x1,%esi
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e12:	7f c8                	jg     801ddc <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e14:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e1a:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e20:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e27:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e2d:	74 19                	je     801e48 <spawn+0x1c9>
  801e2f:	68 c0 31 80 00       	push   $0x8031c0
  801e34:	68 1f 31 80 00       	push   $0x80311f
  801e39:	68 f1 00 00 00       	push   $0xf1
  801e3e:	68 65 31 80 00       	push   $0x803165
  801e43:	e8 9c e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e48:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e4e:	89 f8                	mov    %edi,%eax
  801e50:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e55:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e58:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e5e:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e61:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801e67:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e6d:	83 ec 0c             	sub    $0xc,%esp
  801e70:	6a 07                	push   $0x7
  801e72:	68 00 d0 bf ee       	push   $0xeebfd000
  801e77:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e7d:	68 00 00 40 00       	push   $0x400000
  801e82:	6a 00                	push   $0x0
  801e84:	e8 ff f0 ff ff       	call   800f88 <sys_page_map>
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	83 c4 20             	add    $0x20,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	0f 88 04 03 00 00    	js     80219a <spawn+0x51b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e96:	83 ec 08             	sub    $0x8,%esp
  801e99:	68 00 00 40 00       	push   $0x400000
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 25 f1 ff ff       	call   800fca <sys_page_unmap>
  801ea5:	89 c3                	mov    %eax,%ebx
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	0f 88 e8 02 00 00    	js     80219a <spawn+0x51b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801eb2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801eb8:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ebf:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ec5:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ecc:	00 00 00 
  801ecf:	e9 88 01 00 00       	jmp    80205c <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801ed4:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801eda:	83 38 01             	cmpl   $0x1,(%eax)
  801edd:	0f 85 6b 01 00 00    	jne    80204e <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ee3:	89 c7                	mov    %eax,%edi
  801ee5:	8b 40 18             	mov    0x18(%eax),%eax
  801ee8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801eee:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801ef1:	83 f8 01             	cmp    $0x1,%eax
  801ef4:	19 c0                	sbb    %eax,%eax
  801ef6:	83 e0 fe             	and    $0xfffffffe,%eax
  801ef9:	83 c0 07             	add    $0x7,%eax
  801efc:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f02:	89 f8                	mov    %edi,%eax
  801f04:	8b 7f 04             	mov    0x4(%edi),%edi
  801f07:	89 f9                	mov    %edi,%ecx
  801f09:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801f0f:	8b 78 10             	mov    0x10(%eax),%edi
  801f12:	8b 50 14             	mov    0x14(%eax),%edx
  801f15:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801f1b:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f1e:	89 f0                	mov    %esi,%eax
  801f20:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f25:	74 14                	je     801f3b <spawn+0x2bc>
		va -= i;
  801f27:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f29:	01 c2                	add    %eax,%edx
  801f2b:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801f31:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801f33:	29 c1                	sub    %eax,%ecx
  801f35:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f40:	e9 f7 00 00 00       	jmp    80203c <spawn+0x3bd>
		if (i >= filesz) {
  801f45:	39 df                	cmp    %ebx,%edi
  801f47:	77 27                	ja     801f70 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f49:	83 ec 04             	sub    $0x4,%esp
  801f4c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801f52:	56                   	push   %esi
  801f53:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f59:	e8 e7 ef ff ff       	call   800f45 <sys_page_alloc>
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	0f 89 c7 00 00 00    	jns    802030 <spawn+0x3b1>
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	e9 09 02 00 00       	jmp    802179 <spawn+0x4fa>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f70:	83 ec 04             	sub    $0x4,%esp
  801f73:	6a 07                	push   $0x7
  801f75:	68 00 00 40 00       	push   $0x400000
  801f7a:	6a 00                	push   $0x0
  801f7c:	e8 c4 ef ff ff       	call   800f45 <sys_page_alloc>
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	85 c0                	test   %eax,%eax
  801f86:	0f 88 e3 01 00 00    	js     80216f <spawn+0x4f0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f8c:	83 ec 08             	sub    $0x8,%esp
  801f8f:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f95:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fa2:	e8 1c f9 ff ff       	call   8018c3 <seek>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	85 c0                	test   %eax,%eax
  801fac:	0f 88 c1 01 00 00    	js     802173 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801fb2:	83 ec 04             	sub    $0x4,%esp
  801fb5:	89 f8                	mov    %edi,%eax
  801fb7:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801fbd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801fc2:	ba 00 10 00 00       	mov    $0x1000,%edx
  801fc7:	0f 47 c2             	cmova  %edx,%eax
  801fca:	50                   	push   %eax
  801fcb:	68 00 00 40 00       	push   $0x400000
  801fd0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fd6:	e8 13 f8 ff ff       	call   8017ee <readn>
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	0f 88 91 01 00 00    	js     802177 <spawn+0x4f8>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fef:	56                   	push   %esi
  801ff0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ff6:	68 00 00 40 00       	push   $0x400000
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 86 ef ff ff       	call   800f88 <sys_page_map>
  802002:	83 c4 20             	add    $0x20,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	79 15                	jns    80201e <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802009:	50                   	push   %eax
  80200a:	68 71 31 80 00       	push   $0x803171
  80200f:	68 24 01 00 00       	push   $0x124
  802014:	68 65 31 80 00       	push   $0x803165
  802019:	e8 c6 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  80201e:	83 ec 08             	sub    $0x8,%esp
  802021:	68 00 00 40 00       	push   $0x400000
  802026:	6a 00                	push   $0x0
  802028:	e8 9d ef ff ff       	call   800fca <sys_page_unmap>
  80202d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802030:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802036:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80203c:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802042:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802048:	0f 87 f7 fe ff ff    	ja     801f45 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80204e:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802055:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80205c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802063:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802069:	0f 8c 65 fe ff ff    	jl     801ed4 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80206f:	83 ec 0c             	sub    $0xc,%esp
  802072:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802078:	e8 a4 f5 ff ff       	call   801621 <close>
  80207d:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  802080:	bb 00 00 00 00       	mov    $0x0,%ebx
  802085:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  80208b:	89 d8                	mov    %ebx,%eax
  80208d:	c1 e8 16             	shr    $0x16,%eax
  802090:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802097:	a8 01                	test   $0x1,%al
  802099:	74 46                	je     8020e1 <spawn+0x462>
  80209b:	89 d8                	mov    %ebx,%eax
  80209d:	c1 e8 0c             	shr    $0xc,%eax
  8020a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020a7:	f6 c2 01             	test   $0x1,%dl
  8020aa:	74 35                	je     8020e1 <spawn+0x462>
			(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8020ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  8020b3:	f6 c2 04             	test   $0x4,%dl
  8020b6:	74 29                	je     8020e1 <spawn+0x462>
			(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8020b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020bf:	f6 c6 04             	test   $0x4,%dh
  8020c2:	74 1d                	je     8020e1 <spawn+0x462>
			sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8020c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020cb:	83 ec 0c             	sub    $0xc,%esp
  8020ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8020d3:	50                   	push   %eax
  8020d4:	53                   	push   %ebx
  8020d5:	56                   	push   %esi
  8020d6:	53                   	push   %ebx
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 aa ee ff ff       	call   800f88 <sys_page_map>
  8020de:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	//EDIT BY Lethe 2018/12/14
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8020e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020e7:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020ed:	75 9c                	jne    80208b <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020ef:	83 ec 08             	sub    $0x8,%esp
  8020f2:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020f8:	50                   	push   %eax
  8020f9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020ff:	e8 4a ef ff ff       	call   80104e <sys_env_set_trapframe>
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	85 c0                	test   %eax,%eax
  802109:	79 15                	jns    802120 <spawn+0x4a1>
		panic("sys_env_set_trapframe: %e", r);
  80210b:	50                   	push   %eax
  80210c:	68 8e 31 80 00       	push   $0x80318e
  802111:	68 85 00 00 00       	push   $0x85
  802116:	68 65 31 80 00       	push   $0x803165
  80211b:	e8 c4 e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802120:	83 ec 08             	sub    $0x8,%esp
  802123:	6a 02                	push   $0x2
  802125:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80212b:	e8 dc ee ff ff       	call   80100c <sys_env_set_status>
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	85 c0                	test   %eax,%eax
  802135:	79 25                	jns    80215c <spawn+0x4dd>
		panic("sys_env_set_status: %e", r);
  802137:	50                   	push   %eax
  802138:	68 a8 31 80 00       	push   $0x8031a8
  80213d:	68 88 00 00 00       	push   $0x88
  802142:	68 65 31 80 00       	push   $0x803165
  802147:	e8 98 e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80214c:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802152:	eb 58                	jmp    8021ac <spawn+0x52d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802154:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80215a:	eb 50                	jmp    8021ac <spawn+0x52d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80215c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802162:	eb 48                	jmp    8021ac <spawn+0x52d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802164:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802169:	eb 41                	jmp    8021ac <spawn+0x52d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80216b:	89 c3                	mov    %eax,%ebx
  80216d:	eb 3d                	jmp    8021ac <spawn+0x52d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80216f:	89 c3                	mov    %eax,%ebx
  802171:	eb 06                	jmp    802179 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802173:	89 c3                	mov    %eax,%ebx
  802175:	eb 02                	jmp    802179 <spawn+0x4fa>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802177:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802179:	83 ec 0c             	sub    $0xc,%esp
  80217c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802182:	e8 3f ed ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  802187:	83 c4 04             	add    $0x4,%esp
  80218a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802190:	e8 8c f4 ff ff       	call   801621 <close>
	return r;
  802195:	83 c4 10             	add    $0x10,%esp
  802198:	eb 12                	jmp    8021ac <spawn+0x52d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80219a:	83 ec 08             	sub    $0x8,%esp
  80219d:	68 00 00 40 00       	push   $0x400000
  8021a2:	6a 00                	push   $0x0
  8021a4:	e8 21 ee ff ff       	call   800fca <sys_page_unmap>
  8021a9:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5f                   	pop    %edi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    

008021b6 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8021b6:	55                   	push   %ebp
  8021b7:	89 e5                	mov    %esp,%ebp
  8021b9:	56                   	push   %esi
  8021ba:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021bb:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8021be:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c3:	eb 03                	jmp    8021c8 <spawnl+0x12>
		argc++;
  8021c5:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021c8:	83 c2 04             	add    $0x4,%edx
  8021cb:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8021cf:	75 f4                	jne    8021c5 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021d1:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8021d8:	83 e2 f0             	and    $0xfffffff0,%edx
  8021db:	29 d4                	sub    %edx,%esp
  8021dd:	8d 54 24 03          	lea    0x3(%esp),%edx
  8021e1:	c1 ea 02             	shr    $0x2,%edx
  8021e4:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8021eb:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f0:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8021f7:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8021fe:	00 
  8021ff:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
  802206:	eb 0a                	jmp    802212 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802208:	83 c0 01             	add    $0x1,%eax
  80220b:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  80220f:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802212:	39 d0                	cmp    %edx,%eax
  802214:	75 f2                	jne    802208 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802216:	83 ec 08             	sub    $0x8,%esp
  802219:	56                   	push   %esi
  80221a:	ff 75 08             	pushl  0x8(%ebp)
  80221d:	e8 5d fa ff ff       	call   801c7f <spawn>
}
  802222:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802225:	5b                   	pop    %ebx
  802226:	5e                   	pop    %esi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    

00802229 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	56                   	push   %esi
  80222d:	53                   	push   %ebx
  80222e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802231:	83 ec 0c             	sub    $0xc,%esp
  802234:	ff 75 08             	pushl  0x8(%ebp)
  802237:	e8 55 f2 ff ff       	call   801491 <fd2data>
  80223c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80223e:	83 c4 08             	add    $0x8,%esp
  802241:	68 e6 31 80 00       	push   $0x8031e6
  802246:	53                   	push   %ebx
  802247:	e8 f6 e8 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80224c:	8b 46 04             	mov    0x4(%esi),%eax
  80224f:	2b 06                	sub    (%esi),%eax
  802251:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802257:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80225e:	00 00 00 
	stat->st_dev = &devpipe;
  802261:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802268:	40 80 00 
	return 0;
}
  80226b:	b8 00 00 00 00       	mov    $0x0,%eax
  802270:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	53                   	push   %ebx
  80227b:	83 ec 0c             	sub    $0xc,%esp
  80227e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802281:	53                   	push   %ebx
  802282:	6a 00                	push   $0x0
  802284:	e8 41 ed ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802289:	89 1c 24             	mov    %ebx,(%esp)
  80228c:	e8 00 f2 ff ff       	call   801491 <fd2data>
  802291:	83 c4 08             	add    $0x8,%esp
  802294:	50                   	push   %eax
  802295:	6a 00                	push   $0x0
  802297:	e8 2e ed ff ff       	call   800fca <sys_page_unmap>
}
  80229c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229f:	c9                   	leave  
  8022a0:	c3                   	ret    

008022a1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	57                   	push   %edi
  8022a5:	56                   	push   %esi
  8022a6:	53                   	push   %ebx
  8022a7:	83 ec 1c             	sub    $0x1c,%esp
  8022aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022ad:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022af:	a1 04 50 80 00       	mov    0x805004,%eax
  8022b4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022b7:	83 ec 0c             	sub    $0xc,%esp
  8022ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8022bd:	e8 cf 04 00 00       	call   802791 <pageref>
  8022c2:	89 c3                	mov    %eax,%ebx
  8022c4:	89 3c 24             	mov    %edi,(%esp)
  8022c7:	e8 c5 04 00 00       	call   802791 <pageref>
  8022cc:	83 c4 10             	add    $0x10,%esp
  8022cf:	39 c3                	cmp    %eax,%ebx
  8022d1:	0f 94 c1             	sete   %cl
  8022d4:	0f b6 c9             	movzbl %cl,%ecx
  8022d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022da:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022e0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022e3:	39 ce                	cmp    %ecx,%esi
  8022e5:	74 1b                	je     802302 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022e7:	39 c3                	cmp    %eax,%ebx
  8022e9:	75 c4                	jne    8022af <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022eb:	8b 42 58             	mov    0x58(%edx),%eax
  8022ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022f1:	50                   	push   %eax
  8022f2:	56                   	push   %esi
  8022f3:	68 ed 31 80 00       	push   $0x8031ed
  8022f8:	e8 c0 e2 ff ff       	call   8005bd <cprintf>
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	eb ad                	jmp    8022af <_pipeisclosed+0xe>
	}
}
  802302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	57                   	push   %edi
  802311:	56                   	push   %esi
  802312:	53                   	push   %ebx
  802313:	83 ec 28             	sub    $0x28,%esp
  802316:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802319:	56                   	push   %esi
  80231a:	e8 72 f1 ff ff       	call   801491 <fd2data>
  80231f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802321:	83 c4 10             	add    $0x10,%esp
  802324:	bf 00 00 00 00       	mov    $0x0,%edi
  802329:	eb 4b                	jmp    802376 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80232b:	89 da                	mov    %ebx,%edx
  80232d:	89 f0                	mov    %esi,%eax
  80232f:	e8 6d ff ff ff       	call   8022a1 <_pipeisclosed>
  802334:	85 c0                	test   %eax,%eax
  802336:	75 48                	jne    802380 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802338:	e8 e9 eb ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80233d:	8b 43 04             	mov    0x4(%ebx),%eax
  802340:	8b 0b                	mov    (%ebx),%ecx
  802342:	8d 51 20             	lea    0x20(%ecx),%edx
  802345:	39 d0                	cmp    %edx,%eax
  802347:	73 e2                	jae    80232b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802349:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80234c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802350:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802353:	89 c2                	mov    %eax,%edx
  802355:	c1 fa 1f             	sar    $0x1f,%edx
  802358:	89 d1                	mov    %edx,%ecx
  80235a:	c1 e9 1b             	shr    $0x1b,%ecx
  80235d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802360:	83 e2 1f             	and    $0x1f,%edx
  802363:	29 ca                	sub    %ecx,%edx
  802365:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802369:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80236d:	83 c0 01             	add    $0x1,%eax
  802370:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802373:	83 c7 01             	add    $0x1,%edi
  802376:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802379:	75 c2                	jne    80233d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80237b:	8b 45 10             	mov    0x10(%ebp),%eax
  80237e:	eb 05                	jmp    802385 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802380:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802385:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    

0080238d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	57                   	push   %edi
  802391:	56                   	push   %esi
  802392:	53                   	push   %ebx
  802393:	83 ec 18             	sub    $0x18,%esp
  802396:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802399:	57                   	push   %edi
  80239a:	e8 f2 f0 ff ff       	call   801491 <fd2data>
  80239f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023a1:	83 c4 10             	add    $0x10,%esp
  8023a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023a9:	eb 3d                	jmp    8023e8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023ab:	85 db                	test   %ebx,%ebx
  8023ad:	74 04                	je     8023b3 <devpipe_read+0x26>
				return i;
  8023af:	89 d8                	mov    %ebx,%eax
  8023b1:	eb 44                	jmp    8023f7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023b3:	89 f2                	mov    %esi,%edx
  8023b5:	89 f8                	mov    %edi,%eax
  8023b7:	e8 e5 fe ff ff       	call   8022a1 <_pipeisclosed>
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	75 32                	jne    8023f2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023c0:	e8 61 eb ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023c5:	8b 06                	mov    (%esi),%eax
  8023c7:	3b 46 04             	cmp    0x4(%esi),%eax
  8023ca:	74 df                	je     8023ab <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023cc:	99                   	cltd   
  8023cd:	c1 ea 1b             	shr    $0x1b,%edx
  8023d0:	01 d0                	add    %edx,%eax
  8023d2:	83 e0 1f             	and    $0x1f,%eax
  8023d5:	29 d0                	sub    %edx,%eax
  8023d7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8023dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023df:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8023e2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023e5:	83 c3 01             	add    $0x1,%ebx
  8023e8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023eb:	75 d8                	jne    8023c5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f0:	eb 05                	jmp    8023f7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023fa:	5b                   	pop    %ebx
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	56                   	push   %esi
  802403:	53                   	push   %ebx
  802404:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240a:	50                   	push   %eax
  80240b:	e8 98 f0 ff ff       	call   8014a8 <fd_alloc>
  802410:	83 c4 10             	add    $0x10,%esp
  802413:	89 c2                	mov    %eax,%edx
  802415:	85 c0                	test   %eax,%eax
  802417:	0f 88 2c 01 00 00    	js     802549 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80241d:	83 ec 04             	sub    $0x4,%esp
  802420:	68 07 04 00 00       	push   $0x407
  802425:	ff 75 f4             	pushl  -0xc(%ebp)
  802428:	6a 00                	push   $0x0
  80242a:	e8 16 eb ff ff       	call   800f45 <sys_page_alloc>
  80242f:	83 c4 10             	add    $0x10,%esp
  802432:	89 c2                	mov    %eax,%edx
  802434:	85 c0                	test   %eax,%eax
  802436:	0f 88 0d 01 00 00    	js     802549 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80243c:	83 ec 0c             	sub    $0xc,%esp
  80243f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802442:	50                   	push   %eax
  802443:	e8 60 f0 ff ff       	call   8014a8 <fd_alloc>
  802448:	89 c3                	mov    %eax,%ebx
  80244a:	83 c4 10             	add    $0x10,%esp
  80244d:	85 c0                	test   %eax,%eax
  80244f:	0f 88 e2 00 00 00    	js     802537 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802455:	83 ec 04             	sub    $0x4,%esp
  802458:	68 07 04 00 00       	push   $0x407
  80245d:	ff 75 f0             	pushl  -0x10(%ebp)
  802460:	6a 00                	push   $0x0
  802462:	e8 de ea ff ff       	call   800f45 <sys_page_alloc>
  802467:	89 c3                	mov    %eax,%ebx
  802469:	83 c4 10             	add    $0x10,%esp
  80246c:	85 c0                	test   %eax,%eax
  80246e:	0f 88 c3 00 00 00    	js     802537 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802474:	83 ec 0c             	sub    $0xc,%esp
  802477:	ff 75 f4             	pushl  -0xc(%ebp)
  80247a:	e8 12 f0 ff ff       	call   801491 <fd2data>
  80247f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802481:	83 c4 0c             	add    $0xc,%esp
  802484:	68 07 04 00 00       	push   $0x407
  802489:	50                   	push   %eax
  80248a:	6a 00                	push   $0x0
  80248c:	e8 b4 ea ff ff       	call   800f45 <sys_page_alloc>
  802491:	89 c3                	mov    %eax,%ebx
  802493:	83 c4 10             	add    $0x10,%esp
  802496:	85 c0                	test   %eax,%eax
  802498:	0f 88 89 00 00 00    	js     802527 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80249e:	83 ec 0c             	sub    $0xc,%esp
  8024a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8024a4:	e8 e8 ef ff ff       	call   801491 <fd2data>
  8024a9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024b0:	50                   	push   %eax
  8024b1:	6a 00                	push   $0x0
  8024b3:	56                   	push   %esi
  8024b4:	6a 00                	push   $0x0
  8024b6:	e8 cd ea ff ff       	call   800f88 <sys_page_map>
  8024bb:	89 c3                	mov    %eax,%ebx
  8024bd:	83 c4 20             	add    $0x20,%esp
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	78 55                	js     802519 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024c4:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024d9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024ee:	83 ec 0c             	sub    $0xc,%esp
  8024f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f4:	e8 88 ef ff ff       	call   801481 <fd2num>
  8024f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024fc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024fe:	83 c4 04             	add    $0x4,%esp
  802501:	ff 75 f0             	pushl  -0x10(%ebp)
  802504:	e8 78 ef ff ff       	call   801481 <fd2num>
  802509:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80250c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80250f:	83 c4 10             	add    $0x10,%esp
  802512:	ba 00 00 00 00       	mov    $0x0,%edx
  802517:	eb 30                	jmp    802549 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802519:	83 ec 08             	sub    $0x8,%esp
  80251c:	56                   	push   %esi
  80251d:	6a 00                	push   $0x0
  80251f:	e8 a6 ea ff ff       	call   800fca <sys_page_unmap>
  802524:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802527:	83 ec 08             	sub    $0x8,%esp
  80252a:	ff 75 f0             	pushl  -0x10(%ebp)
  80252d:	6a 00                	push   $0x0
  80252f:	e8 96 ea ff ff       	call   800fca <sys_page_unmap>
  802534:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802537:	83 ec 08             	sub    $0x8,%esp
  80253a:	ff 75 f4             	pushl  -0xc(%ebp)
  80253d:	6a 00                	push   $0x0
  80253f:	e8 86 ea ff ff       	call   800fca <sys_page_unmap>
  802544:	83 c4 10             	add    $0x10,%esp
  802547:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802549:	89 d0                	mov    %edx,%eax
  80254b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80254e:	5b                   	pop    %ebx
  80254f:	5e                   	pop    %esi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    

00802552 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802552:	55                   	push   %ebp
  802553:	89 e5                	mov    %esp,%ebp
  802555:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802558:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80255b:	50                   	push   %eax
  80255c:	ff 75 08             	pushl  0x8(%ebp)
  80255f:	e8 93 ef ff ff       	call   8014f7 <fd_lookup>
  802564:	83 c4 10             	add    $0x10,%esp
  802567:	85 c0                	test   %eax,%eax
  802569:	78 18                	js     802583 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80256b:	83 ec 0c             	sub    $0xc,%esp
  80256e:	ff 75 f4             	pushl  -0xc(%ebp)
  802571:	e8 1b ef ff ff       	call   801491 <fd2data>
	return _pipeisclosed(fd, p);
  802576:	89 c2                	mov    %eax,%edx
  802578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257b:	e8 21 fd ff ff       	call   8022a1 <_pipeisclosed>
  802580:	83 c4 10             	add    $0x10,%esp
}
  802583:	c9                   	leave  
  802584:	c3                   	ret    

00802585 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802585:	55                   	push   %ebp
  802586:	89 e5                	mov    %esp,%ebp
  802588:	56                   	push   %esi
  802589:	53                   	push   %ebx
  80258a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80258d:	85 f6                	test   %esi,%esi
  80258f:	75 16                	jne    8025a7 <wait+0x22>
  802591:	68 05 32 80 00       	push   $0x803205
  802596:	68 1f 31 80 00       	push   $0x80311f
  80259b:	6a 09                	push   $0x9
  80259d:	68 10 32 80 00       	push   $0x803210
  8025a2:	e8 3d df ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8025a7:	89 f3                	mov    %esi,%ebx
  8025a9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025af:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8025b2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025b8:	eb 05                	jmp    8025bf <wait+0x3a>
		sys_yield();
  8025ba:	e8 67 e9 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025bf:	8b 43 48             	mov    0x48(%ebx),%eax
  8025c2:	39 c6                	cmp    %eax,%esi
  8025c4:	75 07                	jne    8025cd <wait+0x48>
  8025c6:	8b 43 54             	mov    0x54(%ebx),%eax
  8025c9:	85 c0                	test   %eax,%eax
  8025cb:	75 ed                	jne    8025ba <wait+0x35>
		sys_yield();
}
  8025cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5d                   	pop    %ebp
  8025d3:	c3                   	ret    

008025d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	53                   	push   %ebx
  8025d8:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8025db:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8025e2:	75 57                	jne    80263b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  8025e4:	e8 1e e9 ff ff       	call   800f07 <sys_getenvid>
  8025e9:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  8025eb:	83 ec 04             	sub    $0x4,%esp
  8025ee:	6a 07                	push   $0x7
  8025f0:	68 00 f0 bf ee       	push   $0xeebff000
  8025f5:	50                   	push   %eax
  8025f6:	e8 4a e9 ff ff       	call   800f45 <sys_page_alloc>
		if (r) {
  8025fb:	83 c4 10             	add    $0x10,%esp
  8025fe:	85 c0                	test   %eax,%eax
  802600:	74 12                	je     802614 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  802602:	50                   	push   %eax
  802603:	68 da 2f 80 00       	push   $0x802fda
  802608:	6a 25                	push   $0x25
  80260a:	68 1b 32 80 00       	push   $0x80321b
  80260f:	e8 d0 de ff ff       	call   8004e4 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  802614:	83 ec 08             	sub    $0x8,%esp
  802617:	68 48 26 80 00       	push   $0x802648
  80261c:	53                   	push   %ebx
  80261d:	e8 6e ea ff ff       	call   801090 <sys_env_set_pgfault_upcall>
		if (r) {
  802622:	83 c4 10             	add    $0x10,%esp
  802625:	85 c0                	test   %eax,%eax
  802627:	74 12                	je     80263b <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  802629:	50                   	push   %eax
  80262a:	68 2c 32 80 00       	push   $0x80322c
  80262f:	6a 2b                	push   $0x2b
  802631:	68 1b 32 80 00       	push   $0x80321b
  802636:	e8 a9 de ff ff       	call   8004e4 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80263b:	8b 45 08             	mov    0x8(%ebp),%eax
  80263e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802646:	c9                   	leave  
  802647:	c3                   	ret    

00802648 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802648:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802649:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80264e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802650:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  802653:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  802657:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  80265c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  802660:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  802662:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  802665:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  802666:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  802669:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  80266a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  80266b:	c3                   	ret    

0080266c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80266c:	55                   	push   %ebp
  80266d:	89 e5                	mov    %esp,%ebp
  80266f:	56                   	push   %esi
  802670:	53                   	push   %ebx
  802671:	8b 75 08             	mov    0x8(%ebp),%esi
  802674:	8b 45 0c             	mov    0xc(%ebp),%eax
  802677:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  80267a:	85 c0                	test   %eax,%eax
  80267c:	74 3e                	je     8026bc <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  80267e:	83 ec 0c             	sub    $0xc,%esp
  802681:	50                   	push   %eax
  802682:	e8 6e ea ff ff       	call   8010f5 <sys_ipc_recv>
  802687:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  802689:	83 c4 10             	add    $0x10,%esp
  80268c:	85 f6                	test   %esi,%esi
  80268e:	74 13                	je     8026a3 <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  802690:	b8 00 00 00 00       	mov    $0x0,%eax
  802695:	85 d2                	test   %edx,%edx
  802697:	75 08                	jne    8026a1 <ipc_recv+0x35>
  802699:	a1 04 50 80 00       	mov    0x805004,%eax
  80269e:	8b 40 74             	mov    0x74(%eax),%eax
  8026a1:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8026a3:	85 db                	test   %ebx,%ebx
  8026a5:	74 48                	je     8026ef <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  8026a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8026ac:	85 d2                	test   %edx,%edx
  8026ae:	75 08                	jne    8026b8 <ipc_recv+0x4c>
  8026b0:	a1 04 50 80 00       	mov    0x805004,%eax
  8026b5:	8b 40 78             	mov    0x78(%eax),%eax
  8026b8:	89 03                	mov    %eax,(%ebx)
  8026ba:	eb 33                	jmp    8026ef <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  8026bc:	83 ec 0c             	sub    $0xc,%esp
  8026bf:	68 00 00 c0 ee       	push   $0xeec00000
  8026c4:	e8 2c ea ff ff       	call   8010f5 <sys_ipc_recv>
  8026c9:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  8026cb:	83 c4 10             	add    $0x10,%esp
  8026ce:	85 f6                	test   %esi,%esi
  8026d0:	74 13                	je     8026e5 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  8026d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	75 08                	jne    8026e3 <ipc_recv+0x77>
  8026db:	a1 04 50 80 00       	mov    0x805004,%eax
  8026e0:	8b 40 74             	mov    0x74(%eax),%eax
  8026e3:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8026e5:	85 db                	test   %ebx,%ebx
  8026e7:	74 06                	je     8026ef <ipc_recv+0x83>
			*perm_store = 0;
  8026e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  8026ef:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  8026f1:	85 d2                	test   %edx,%edx
  8026f3:	75 08                	jne    8026fd <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  8026f5:	a1 04 50 80 00       	mov    0x805004,%eax
  8026fa:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  8026fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802700:	5b                   	pop    %ebx
  802701:	5e                   	pop    %esi
  802702:	5d                   	pop    %ebp
  802703:	c3                   	ret    

00802704 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802704:	55                   	push   %ebp
  802705:	89 e5                	mov    %esp,%ebp
  802707:	57                   	push   %edi
  802708:	56                   	push   %esi
  802709:	53                   	push   %ebx
  80270a:	83 ec 0c             	sub    $0xc,%esp
  80270d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802710:	8b 75 0c             	mov    0xc(%ebp),%esi
  802713:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  802716:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  802718:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80271d:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802720:	eb 1c                	jmp    80273e <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  802722:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802725:	74 12                	je     802739 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  802727:	50                   	push   %eax
  802728:	68 54 32 80 00       	push   $0x803254
  80272d:	6a 4f                	push   $0x4f
  80272f:	68 6f 32 80 00       	push   $0x80326f
  802734:	e8 ab dd ff ff       	call   8004e4 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802739:	e8 e8 e7 ff ff       	call   800f26 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80273e:	ff 75 14             	pushl  0x14(%ebp)
  802741:	53                   	push   %ebx
  802742:	56                   	push   %esi
  802743:	57                   	push   %edi
  802744:	e8 89 e9 ff ff       	call   8010d2 <sys_ipc_try_send>
  802749:	83 c4 10             	add    $0x10,%esp
  80274c:	85 c0                	test   %eax,%eax
  80274e:	78 d2                	js     802722 <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802753:	5b                   	pop    %ebx
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    

00802758 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802758:	55                   	push   %ebp
  802759:	89 e5                	mov    %esp,%ebp
  80275b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80275e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802763:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802766:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80276c:	8b 52 50             	mov    0x50(%edx),%edx
  80276f:	39 ca                	cmp    %ecx,%edx
  802771:	75 0d                	jne    802780 <ipc_find_env+0x28>
			return envs[i].env_id;
  802773:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802776:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80277b:	8b 40 48             	mov    0x48(%eax),%eax
  80277e:	eb 0f                	jmp    80278f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802780:	83 c0 01             	add    $0x1,%eax
  802783:	3d 00 04 00 00       	cmp    $0x400,%eax
  802788:	75 d9                	jne    802763 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80278a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80278f:	5d                   	pop    %ebp
  802790:	c3                   	ret    

00802791 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802791:	55                   	push   %ebp
  802792:	89 e5                	mov    %esp,%ebp
  802794:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802797:	89 d0                	mov    %edx,%eax
  802799:	c1 e8 16             	shr    $0x16,%eax
  80279c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027a3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027a8:	f6 c1 01             	test   $0x1,%cl
  8027ab:	74 1d                	je     8027ca <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027ad:	c1 ea 0c             	shr    $0xc,%edx
  8027b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027b7:	f6 c2 01             	test   $0x1,%dl
  8027ba:	74 0e                	je     8027ca <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027bc:	c1 ea 0c             	shr    $0xc,%edx
  8027bf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027c6:	ef 
  8027c7:	0f b7 c0             	movzwl %ax,%eax
}
  8027ca:	5d                   	pop    %ebp
  8027cb:	c3                   	ret    
  8027cc:	66 90                	xchg   %ax,%ax
  8027ce:	66 90                	xchg   %ax,%ax

008027d0 <__udivdi3>:
  8027d0:	55                   	push   %ebp
  8027d1:	57                   	push   %edi
  8027d2:	56                   	push   %esi
  8027d3:	53                   	push   %ebx
  8027d4:	83 ec 1c             	sub    $0x1c,%esp
  8027d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8027db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8027df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8027e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027e7:	85 f6                	test   %esi,%esi
  8027e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027ed:	89 ca                	mov    %ecx,%edx
  8027ef:	89 f8                	mov    %edi,%eax
  8027f1:	75 3d                	jne    802830 <__udivdi3+0x60>
  8027f3:	39 cf                	cmp    %ecx,%edi
  8027f5:	0f 87 c5 00 00 00    	ja     8028c0 <__udivdi3+0xf0>
  8027fb:	85 ff                	test   %edi,%edi
  8027fd:	89 fd                	mov    %edi,%ebp
  8027ff:	75 0b                	jne    80280c <__udivdi3+0x3c>
  802801:	b8 01 00 00 00       	mov    $0x1,%eax
  802806:	31 d2                	xor    %edx,%edx
  802808:	f7 f7                	div    %edi
  80280a:	89 c5                	mov    %eax,%ebp
  80280c:	89 c8                	mov    %ecx,%eax
  80280e:	31 d2                	xor    %edx,%edx
  802810:	f7 f5                	div    %ebp
  802812:	89 c1                	mov    %eax,%ecx
  802814:	89 d8                	mov    %ebx,%eax
  802816:	89 cf                	mov    %ecx,%edi
  802818:	f7 f5                	div    %ebp
  80281a:	89 c3                	mov    %eax,%ebx
  80281c:	89 d8                	mov    %ebx,%eax
  80281e:	89 fa                	mov    %edi,%edx
  802820:	83 c4 1c             	add    $0x1c,%esp
  802823:	5b                   	pop    %ebx
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	90                   	nop
  802829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802830:	39 ce                	cmp    %ecx,%esi
  802832:	77 74                	ja     8028a8 <__udivdi3+0xd8>
  802834:	0f bd fe             	bsr    %esi,%edi
  802837:	83 f7 1f             	xor    $0x1f,%edi
  80283a:	0f 84 98 00 00 00    	je     8028d8 <__udivdi3+0x108>
  802840:	bb 20 00 00 00       	mov    $0x20,%ebx
  802845:	89 f9                	mov    %edi,%ecx
  802847:	89 c5                	mov    %eax,%ebp
  802849:	29 fb                	sub    %edi,%ebx
  80284b:	d3 e6                	shl    %cl,%esi
  80284d:	89 d9                	mov    %ebx,%ecx
  80284f:	d3 ed                	shr    %cl,%ebp
  802851:	89 f9                	mov    %edi,%ecx
  802853:	d3 e0                	shl    %cl,%eax
  802855:	09 ee                	or     %ebp,%esi
  802857:	89 d9                	mov    %ebx,%ecx
  802859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80285d:	89 d5                	mov    %edx,%ebp
  80285f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802863:	d3 ed                	shr    %cl,%ebp
  802865:	89 f9                	mov    %edi,%ecx
  802867:	d3 e2                	shl    %cl,%edx
  802869:	89 d9                	mov    %ebx,%ecx
  80286b:	d3 e8                	shr    %cl,%eax
  80286d:	09 c2                	or     %eax,%edx
  80286f:	89 d0                	mov    %edx,%eax
  802871:	89 ea                	mov    %ebp,%edx
  802873:	f7 f6                	div    %esi
  802875:	89 d5                	mov    %edx,%ebp
  802877:	89 c3                	mov    %eax,%ebx
  802879:	f7 64 24 0c          	mull   0xc(%esp)
  80287d:	39 d5                	cmp    %edx,%ebp
  80287f:	72 10                	jb     802891 <__udivdi3+0xc1>
  802881:	8b 74 24 08          	mov    0x8(%esp),%esi
  802885:	89 f9                	mov    %edi,%ecx
  802887:	d3 e6                	shl    %cl,%esi
  802889:	39 c6                	cmp    %eax,%esi
  80288b:	73 07                	jae    802894 <__udivdi3+0xc4>
  80288d:	39 d5                	cmp    %edx,%ebp
  80288f:	75 03                	jne    802894 <__udivdi3+0xc4>
  802891:	83 eb 01             	sub    $0x1,%ebx
  802894:	31 ff                	xor    %edi,%edi
  802896:	89 d8                	mov    %ebx,%eax
  802898:	89 fa                	mov    %edi,%edx
  80289a:	83 c4 1c             	add    $0x1c,%esp
  80289d:	5b                   	pop    %ebx
  80289e:	5e                   	pop    %esi
  80289f:	5f                   	pop    %edi
  8028a0:	5d                   	pop    %ebp
  8028a1:	c3                   	ret    
  8028a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028a8:	31 ff                	xor    %edi,%edi
  8028aa:	31 db                	xor    %ebx,%ebx
  8028ac:	89 d8                	mov    %ebx,%eax
  8028ae:	89 fa                	mov    %edi,%edx
  8028b0:	83 c4 1c             	add    $0x1c,%esp
  8028b3:	5b                   	pop    %ebx
  8028b4:	5e                   	pop    %esi
  8028b5:	5f                   	pop    %edi
  8028b6:	5d                   	pop    %ebp
  8028b7:	c3                   	ret    
  8028b8:	90                   	nop
  8028b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028c0:	89 d8                	mov    %ebx,%eax
  8028c2:	f7 f7                	div    %edi
  8028c4:	31 ff                	xor    %edi,%edi
  8028c6:	89 c3                	mov    %eax,%ebx
  8028c8:	89 d8                	mov    %ebx,%eax
  8028ca:	89 fa                	mov    %edi,%edx
  8028cc:	83 c4 1c             	add    $0x1c,%esp
  8028cf:	5b                   	pop    %ebx
  8028d0:	5e                   	pop    %esi
  8028d1:	5f                   	pop    %edi
  8028d2:	5d                   	pop    %ebp
  8028d3:	c3                   	ret    
  8028d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028d8:	39 ce                	cmp    %ecx,%esi
  8028da:	72 0c                	jb     8028e8 <__udivdi3+0x118>
  8028dc:	31 db                	xor    %ebx,%ebx
  8028de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8028e2:	0f 87 34 ff ff ff    	ja     80281c <__udivdi3+0x4c>
  8028e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8028ed:	e9 2a ff ff ff       	jmp    80281c <__udivdi3+0x4c>
  8028f2:	66 90                	xchg   %ax,%ax
  8028f4:	66 90                	xchg   %ax,%ax
  8028f6:	66 90                	xchg   %ax,%ax
  8028f8:	66 90                	xchg   %ax,%ax
  8028fa:	66 90                	xchg   %ax,%ax
  8028fc:	66 90                	xchg   %ax,%ax
  8028fe:	66 90                	xchg   %ax,%ax

00802900 <__umoddi3>:
  802900:	55                   	push   %ebp
  802901:	57                   	push   %edi
  802902:	56                   	push   %esi
  802903:	53                   	push   %ebx
  802904:	83 ec 1c             	sub    $0x1c,%esp
  802907:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80290b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80290f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802913:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802917:	85 d2                	test   %edx,%edx
  802919:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80291d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802921:	89 f3                	mov    %esi,%ebx
  802923:	89 3c 24             	mov    %edi,(%esp)
  802926:	89 74 24 04          	mov    %esi,0x4(%esp)
  80292a:	75 1c                	jne    802948 <__umoddi3+0x48>
  80292c:	39 f7                	cmp    %esi,%edi
  80292e:	76 50                	jbe    802980 <__umoddi3+0x80>
  802930:	89 c8                	mov    %ecx,%eax
  802932:	89 f2                	mov    %esi,%edx
  802934:	f7 f7                	div    %edi
  802936:	89 d0                	mov    %edx,%eax
  802938:	31 d2                	xor    %edx,%edx
  80293a:	83 c4 1c             	add    $0x1c,%esp
  80293d:	5b                   	pop    %ebx
  80293e:	5e                   	pop    %esi
  80293f:	5f                   	pop    %edi
  802940:	5d                   	pop    %ebp
  802941:	c3                   	ret    
  802942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802948:	39 f2                	cmp    %esi,%edx
  80294a:	89 d0                	mov    %edx,%eax
  80294c:	77 52                	ja     8029a0 <__umoddi3+0xa0>
  80294e:	0f bd ea             	bsr    %edx,%ebp
  802951:	83 f5 1f             	xor    $0x1f,%ebp
  802954:	75 5a                	jne    8029b0 <__umoddi3+0xb0>
  802956:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80295a:	0f 82 e0 00 00 00    	jb     802a40 <__umoddi3+0x140>
  802960:	39 0c 24             	cmp    %ecx,(%esp)
  802963:	0f 86 d7 00 00 00    	jbe    802a40 <__umoddi3+0x140>
  802969:	8b 44 24 08          	mov    0x8(%esp),%eax
  80296d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802971:	83 c4 1c             	add    $0x1c,%esp
  802974:	5b                   	pop    %ebx
  802975:	5e                   	pop    %esi
  802976:	5f                   	pop    %edi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    
  802979:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802980:	85 ff                	test   %edi,%edi
  802982:	89 fd                	mov    %edi,%ebp
  802984:	75 0b                	jne    802991 <__umoddi3+0x91>
  802986:	b8 01 00 00 00       	mov    $0x1,%eax
  80298b:	31 d2                	xor    %edx,%edx
  80298d:	f7 f7                	div    %edi
  80298f:	89 c5                	mov    %eax,%ebp
  802991:	89 f0                	mov    %esi,%eax
  802993:	31 d2                	xor    %edx,%edx
  802995:	f7 f5                	div    %ebp
  802997:	89 c8                	mov    %ecx,%eax
  802999:	f7 f5                	div    %ebp
  80299b:	89 d0                	mov    %edx,%eax
  80299d:	eb 99                	jmp    802938 <__umoddi3+0x38>
  80299f:	90                   	nop
  8029a0:	89 c8                	mov    %ecx,%eax
  8029a2:	89 f2                	mov    %esi,%edx
  8029a4:	83 c4 1c             	add    $0x1c,%esp
  8029a7:	5b                   	pop    %ebx
  8029a8:	5e                   	pop    %esi
  8029a9:	5f                   	pop    %edi
  8029aa:	5d                   	pop    %ebp
  8029ab:	c3                   	ret    
  8029ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029b0:	8b 34 24             	mov    (%esp),%esi
  8029b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8029b8:	89 e9                	mov    %ebp,%ecx
  8029ba:	29 ef                	sub    %ebp,%edi
  8029bc:	d3 e0                	shl    %cl,%eax
  8029be:	89 f9                	mov    %edi,%ecx
  8029c0:	89 f2                	mov    %esi,%edx
  8029c2:	d3 ea                	shr    %cl,%edx
  8029c4:	89 e9                	mov    %ebp,%ecx
  8029c6:	09 c2                	or     %eax,%edx
  8029c8:	89 d8                	mov    %ebx,%eax
  8029ca:	89 14 24             	mov    %edx,(%esp)
  8029cd:	89 f2                	mov    %esi,%edx
  8029cf:	d3 e2                	shl    %cl,%edx
  8029d1:	89 f9                	mov    %edi,%ecx
  8029d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8029db:	d3 e8                	shr    %cl,%eax
  8029dd:	89 e9                	mov    %ebp,%ecx
  8029df:	89 c6                	mov    %eax,%esi
  8029e1:	d3 e3                	shl    %cl,%ebx
  8029e3:	89 f9                	mov    %edi,%ecx
  8029e5:	89 d0                	mov    %edx,%eax
  8029e7:	d3 e8                	shr    %cl,%eax
  8029e9:	89 e9                	mov    %ebp,%ecx
  8029eb:	09 d8                	or     %ebx,%eax
  8029ed:	89 d3                	mov    %edx,%ebx
  8029ef:	89 f2                	mov    %esi,%edx
  8029f1:	f7 34 24             	divl   (%esp)
  8029f4:	89 d6                	mov    %edx,%esi
  8029f6:	d3 e3                	shl    %cl,%ebx
  8029f8:	f7 64 24 04          	mull   0x4(%esp)
  8029fc:	39 d6                	cmp    %edx,%esi
  8029fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802a02:	89 d1                	mov    %edx,%ecx
  802a04:	89 c3                	mov    %eax,%ebx
  802a06:	72 08                	jb     802a10 <__umoddi3+0x110>
  802a08:	75 11                	jne    802a1b <__umoddi3+0x11b>
  802a0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802a0e:	73 0b                	jae    802a1b <__umoddi3+0x11b>
  802a10:	2b 44 24 04          	sub    0x4(%esp),%eax
  802a14:	1b 14 24             	sbb    (%esp),%edx
  802a17:	89 d1                	mov    %edx,%ecx
  802a19:	89 c3                	mov    %eax,%ebx
  802a1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802a1f:	29 da                	sub    %ebx,%edx
  802a21:	19 ce                	sbb    %ecx,%esi
  802a23:	89 f9                	mov    %edi,%ecx
  802a25:	89 f0                	mov    %esi,%eax
  802a27:	d3 e0                	shl    %cl,%eax
  802a29:	89 e9                	mov    %ebp,%ecx
  802a2b:	d3 ea                	shr    %cl,%edx
  802a2d:	89 e9                	mov    %ebp,%ecx
  802a2f:	d3 ee                	shr    %cl,%esi
  802a31:	09 d0                	or     %edx,%eax
  802a33:	89 f2                	mov    %esi,%edx
  802a35:	83 c4 1c             	add    $0x1c,%esp
  802a38:	5b                   	pop    %ebx
  802a39:	5e                   	pop    %esi
  802a3a:	5f                   	pop    %edi
  802a3b:	5d                   	pop    %ebp
  802a3c:	c3                   	ret    
  802a3d:	8d 76 00             	lea    0x0(%esi),%esi
  802a40:	29 f9                	sub    %edi,%ecx
  802a42:	19 d6                	sbb    %edx,%esi
  802a44:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a4c:	e9 18 ff ff ff       	jmp    802969 <__umoddi3+0x69>
