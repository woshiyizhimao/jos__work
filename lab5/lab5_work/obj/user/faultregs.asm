
obj/user/faultregs.debug：     文件格式 elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 23 80 00       	push   $0x8023f1
  800049:	68 c0 23 80 00       	push   $0x8023c0
  80004e:	e8 77 06 00 00       	call   8006ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 23 80 00       	push   $0x8023d0
  80005c:	68 d4 23 80 00       	push   $0x8023d4
  800061:	e8 64 06 00 00       	call   8006ca <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 e4 23 80 00       	push   $0x8023e4
  800077:	e8 4e 06 00 00       	call   8006ca <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 e8 23 80 00       	push   $0x8023e8
  80008e:	e8 37 06 00 00       	call   8006ca <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 f2 23 80 00       	push   $0x8023f2
  8000a6:	68 d4 23 80 00       	push   $0x8023d4
  8000ab:	e8 1a 06 00 00       	call   8006ca <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 e4 23 80 00       	push   $0x8023e4
  8000c3:	e8 02 06 00 00       	call   8006ca <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 e8 23 80 00       	push   $0x8023e8
  8000d5:	e8 f0 05 00 00       	call   8006ca <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 f6 23 80 00       	push   $0x8023f6
  8000ed:	68 d4 23 80 00       	push   $0x8023d4
  8000f2:	e8 d3 05 00 00       	call   8006ca <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 e4 23 80 00       	push   $0x8023e4
  80010a:	e8 bb 05 00 00       	call   8006ca <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 e8 23 80 00       	push   $0x8023e8
  80011c:	e8 a9 05 00 00       	call   8006ca <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 fa 23 80 00       	push   $0x8023fa
  800134:	68 d4 23 80 00       	push   $0x8023d4
  800139:	e8 8c 05 00 00       	call   8006ca <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 e4 23 80 00       	push   $0x8023e4
  800151:	e8 74 05 00 00       	call   8006ca <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 e8 23 80 00       	push   $0x8023e8
  800163:	e8 62 05 00 00       	call   8006ca <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 fe 23 80 00       	push   $0x8023fe
  80017b:	68 d4 23 80 00       	push   $0x8023d4
  800180:	e8 45 05 00 00       	call   8006ca <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e4 23 80 00       	push   $0x8023e4
  800198:	e8 2d 05 00 00       	call   8006ca <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 e8 23 80 00       	push   $0x8023e8
  8001aa:	e8 1b 05 00 00       	call   8006ca <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 02 24 80 00       	push   $0x802402
  8001c2:	68 d4 23 80 00       	push   $0x8023d4
  8001c7:	e8 fe 04 00 00       	call   8006ca <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 e4 23 80 00       	push   $0x8023e4
  8001df:	e8 e6 04 00 00       	call   8006ca <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 e8 23 80 00       	push   $0x8023e8
  8001f1:	e8 d4 04 00 00       	call   8006ca <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 06 24 80 00       	push   $0x802406
  800209:	68 d4 23 80 00       	push   $0x8023d4
  80020e:	e8 b7 04 00 00       	call   8006ca <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 e4 23 80 00       	push   $0x8023e4
  800226:	e8 9f 04 00 00       	call   8006ca <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 e8 23 80 00       	push   $0x8023e8
  800238:	e8 8d 04 00 00       	call   8006ca <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 0a 24 80 00       	push   $0x80240a
  800250:	68 d4 23 80 00       	push   $0x8023d4
  800255:	e8 70 04 00 00       	call   8006ca <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 e4 23 80 00       	push   $0x8023e4
  80026d:	e8 58 04 00 00       	call   8006ca <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 e8 23 80 00       	push   $0x8023e8
  80027f:	e8 46 04 00 00       	call   8006ca <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 0e 24 80 00       	push   $0x80240e
  800297:	68 d4 23 80 00       	push   $0x8023d4
  80029c:	e8 29 04 00 00       	call   8006ca <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 e4 23 80 00       	push   $0x8023e4
  8002b4:	e8 11 04 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 15 24 80 00       	push   $0x802415
  8002c4:	68 d4 23 80 00       	push   $0x8023d4
  8002c9:	e8 fc 03 00 00       	call   8006ca <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 e8 23 80 00       	push   $0x8023e8
  8002e3:	e8 e2 03 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 15 24 80 00       	push   $0x802415
  8002f3:	68 d4 23 80 00       	push   $0x8023d4
  8002f8:	e8 cd 03 00 00       	call   8006ca <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 e4 23 80 00       	push   $0x8023e4
  800312:	e8 b3 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 19 24 80 00       	push   $0x802419
  800322:	e8 a3 03 00 00       	call   8006ca <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 e8 23 80 00       	push   $0x8023e8
  800338:	e8 8d 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 19 24 80 00       	push   $0x802419
  800348:	e8 7d 03 00 00       	call   8006ca <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 e4 23 80 00       	push   $0x8023e4
  80035a:	e8 6b 03 00 00       	call   8006ca <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 e8 23 80 00       	push   $0x8023e8
  80036c:	e8 59 03 00 00       	call   8006ca <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 e4 23 80 00       	push   $0x8023e4
  80037e:	e8 47 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 19 24 80 00       	push   $0x802419
  80038e:	e8 37 03 00 00       	call   8006ca <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 80 24 80 00       	push   $0x802480
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 27 24 80 00       	push   $0x802427
  8003c6:	e8 26 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 3f 24 80 00       	push   $0x80243f
  800435:	68 4d 24 80 00       	push   $0x80244d
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba 38 24 80 00       	mov    $0x802438,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 f3 0b 00 00       	call   801052 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 54 24 80 00       	push   $0x802454
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 27 24 80 00       	push   $0x802427
  800473:	e8 79 01 00 00       	call   8005f1 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 b9 0d 00 00       	call   801243 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 b4 24 80 00       	push   $0x8024b4
  800559:	e8 6c 01 00 00       	call   8006ca <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 67 24 80 00       	push   $0x802467
  800573:	68 78 24 80 00       	push   $0x802478
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba 38 24 80 00       	mov    $0x802438,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80059c:	e8 73 0a 00 00       	call   801014 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005dd:	e8 c4 0e 00 00       	call   8014a6 <close_all>
	sys_env_destroy(0);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 e7 09 00 00       	call   800fd3 <sys_env_destroy>
}
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005ff:	e8 10 0a 00 00       	call   801014 <sys_getenvid>
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	ff 75 08             	pushl  0x8(%ebp)
  80060d:	56                   	push   %esi
  80060e:	50                   	push   %eax
  80060f:	68 e0 24 80 00       	push   $0x8024e0
  800614:	e8 b1 00 00 00       	call   8006ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	83 c4 18             	add    $0x18,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	e8 54 00 00 00       	call   800679 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  80062c:	e8 99 00 00 00       	call   8006ca <cprintf>
  800631:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x43>

00800637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800641:	8b 13                	mov    (%ebx),%edx
  800643:	8d 42 01             	lea    0x1(%edx),%eax
  800646:	89 03                	mov    %eax,(%ebx)
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800654:	75 1a                	jne    800670 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	68 ff 00 00 00       	push   $0xff
  80065e:	8d 43 08             	lea    0x8(%ebx),%eax
  800661:	50                   	push   %eax
  800662:	e8 2f 09 00 00       	call   800f96 <sys_cputs>
		b->idx = 0;
  800667:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800670:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800682:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800689:	00 00 00 
	b.cnt = 0;
  80068c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800693:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	ff 75 08             	pushl  0x8(%ebp)
  80069c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 37 06 80 00       	push   $0x800637
  8006a8:	e8 54 01 00 00       	call   800801 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	e8 d4 08 00 00       	call   800f96 <sys_cputs>

	return b.cnt;
}
  8006c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9d ff ff ff       	call   800679 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	89 d6                	mov    %edx,%esi
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800702:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800705:	39 d3                	cmp    %edx,%ebx
  800707:	72 05                	jb     80070e <printnum+0x30>
  800709:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070c:	77 45                	ja     800753 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	ff 75 18             	pushl  0x18(%ebp)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80071a:	53                   	push   %ebx
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 e4             	pushl  -0x1c(%ebp)
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	e8 ee 19 00 00       	call   802120 <__udivdi3>
  800732:	83 c4 18             	add    $0x18,%esp
  800735:	52                   	push   %edx
  800736:	50                   	push   %eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	89 f8                	mov    %edi,%eax
  80073b:	e8 9e ff ff ff       	call   8006de <printnum>
  800740:	83 c4 20             	add    $0x20,%esp
  800743:	eb 18                	jmp    80075d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	ff 75 18             	pushl  0x18(%ebp)
  80074c:	ff d7                	call   *%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 03                	jmp    800756 <printnum+0x78>
  800753:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	85 db                	test   %ebx,%ebx
  80075b:	7f e8                	jg     800745 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	56                   	push   %esi
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	ff 75 e4             	pushl  -0x1c(%ebp)
  800767:	ff 75 e0             	pushl  -0x20(%ebp)
  80076a:	ff 75 dc             	pushl  -0x24(%ebp)
  80076d:	ff 75 d8             	pushl  -0x28(%ebp)
  800770:	e8 db 1a 00 00       	call   802250 <__umoddi3>
  800775:	83 c4 14             	add    $0x14,%esp
  800778:	0f be 80 03 25 80 00 	movsbl 0x802503(%eax),%eax
  80077f:	50                   	push   %eax
  800780:	ff d7                	call   *%edi
}
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800790:	83 fa 01             	cmp    $0x1,%edx
  800793:	7e 0e                	jle    8007a3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8d 4a 08             	lea    0x8(%edx),%ecx
  80079a:	89 08                	mov    %ecx,(%eax)
  80079c:	8b 02                	mov    (%edx),%eax
  80079e:	8b 52 04             	mov    0x4(%edx),%edx
  8007a1:	eb 22                	jmp    8007c5 <getuint+0x38>
	else if (lflag)
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	74 10                	je     8007b7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ac:	89 08                	mov    %ecx,(%eax)
  8007ae:	8b 02                	mov    (%edx),%eax
  8007b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b5:	eb 0e                	jmp    8007c5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 02                	mov    (%edx),%eax
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d6:	73 0a                	jae    8007e2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007db:	89 08                	mov    %ecx,(%eax)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	88 02                	mov    %al,(%edx)
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 05 00 00 00       	call   800801 <vprintfmt>
	va_end(ap);
}
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	57                   	push   %edi
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	83 ec 2c             	sub    $0x2c,%esp
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800810:	8b 7d 10             	mov    0x10(%ebp),%edi
  800813:	eb 12                	jmp    800827 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800815:	85 c0                	test   %eax,%eax
  800817:	0f 84 89 03 00 00    	je     800ba6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	53                   	push   %ebx
  800821:	50                   	push   %eax
  800822:	ff d6                	call   *%esi
  800824:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800827:	83 c7 01             	add    $0x1,%edi
  80082a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082e:	83 f8 25             	cmp    $0x25,%eax
  800831:	75 e2                	jne    800815 <vprintfmt+0x14>
  800833:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800837:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800845:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084c:	ba 00 00 00 00       	mov    $0x0,%edx
  800851:	eb 07                	jmp    80085a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800853:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800856:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8d 47 01             	lea    0x1(%edi),%eax
  80085d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800860:	0f b6 07             	movzbl (%edi),%eax
  800863:	0f b6 c8             	movzbl %al,%ecx
  800866:	83 e8 23             	sub    $0x23,%eax
  800869:	3c 55                	cmp    $0x55,%al
  80086b:	0f 87 1a 03 00 00    	ja     800b8b <vprintfmt+0x38a>
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80087e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800882:	eb d6                	jmp    80085a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800892:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800896:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800899:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089c:	83 fa 09             	cmp    $0x9,%edx
  80089f:	77 39                	ja     8008da <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a4:	eb e9                	jmp    80088f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8008ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008af:	8b 00                	mov    (%eax),%eax
  8008b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b7:	eb 27                	jmp    8008e0 <vprintfmt+0xdf>
  8008b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c3:	0f 49 c8             	cmovns %eax,%ecx
  8008c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cc:	eb 8c                	jmp    80085a <vprintfmt+0x59>
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d8:	eb 80                	jmp    80085a <vprintfmt+0x59>
  8008da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008dd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e4:	0f 89 70 ff ff ff    	jns    80085a <vprintfmt+0x59>
				width = precision, precision = -1;
  8008ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f7:	e9 5e ff ff ff       	jmp    80085a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800902:	e9 53 ff ff ff       	jmp    80085a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 50 04             	lea    0x4(%eax),%edx
  80090d:	89 55 14             	mov    %edx,0x14(%ebp)
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	ff 30                	pushl  (%eax)
  800916:	ff d6                	call   *%esi
			break;
  800918:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80091e:	e9 04 ff ff ff       	jmp    800827 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 50 04             	lea    0x4(%eax),%edx
  800929:	89 55 14             	mov    %edx,0x14(%ebp)
  80092c:	8b 00                	mov    (%eax),%eax
  80092e:	99                   	cltd   
  80092f:	31 d0                	xor    %edx,%eax
  800931:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800933:	83 f8 0f             	cmp    $0xf,%eax
  800936:	7f 0b                	jg     800943 <vprintfmt+0x142>
  800938:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	75 18                	jne    80095b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800943:	50                   	push   %eax
  800944:	68 1b 25 80 00       	push   $0x80251b
  800949:	53                   	push   %ebx
  80094a:	56                   	push   %esi
  80094b:	e8 94 fe ff ff       	call   8007e4 <printfmt>
  800950:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800956:	e9 cc fe ff ff       	jmp    800827 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80095b:	52                   	push   %edx
  80095c:	68 25 29 80 00       	push   $0x802925
  800961:	53                   	push   %ebx
  800962:	56                   	push   %esi
  800963:	e8 7c fe ff ff       	call   8007e4 <printfmt>
  800968:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096e:	e9 b4 fe ff ff       	jmp    800827 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8d 50 04             	lea    0x4(%eax),%edx
  800979:	89 55 14             	mov    %edx,0x14(%ebp)
  80097c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097e:	85 ff                	test   %edi,%edi
  800980:	b8 14 25 80 00       	mov    $0x802514,%eax
  800985:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800988:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098c:	0f 8e 94 00 00 00    	jle    800a26 <vprintfmt+0x225>
  800992:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800996:	0f 84 98 00 00 00    	je     800a34 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a2:	57                   	push   %edi
  8009a3:	e8 86 02 00 00       	call   800c2e <strnlen>
  8009a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009ab:	29 c1                	sub    %eax,%ecx
  8009ad:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bf:	eb 0f                	jmp    8009d0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	53                   	push   %ebx
  8009c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	83 c4 10             	add    $0x10,%esp
  8009d0:	85 ff                	test   %edi,%edi
  8009d2:	7f ed                	jg     8009c1 <vprintfmt+0x1c0>
  8009d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	0f 49 c1             	cmovns %ecx,%eax
  8009e4:	29 c1                	sub    %eax,%ecx
  8009e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ef:	89 cb                	mov    %ecx,%ebx
  8009f1:	eb 4d                	jmp    800a40 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f7:	74 1b                	je     800a14 <vprintfmt+0x213>
  8009f9:	0f be c0             	movsbl %al,%eax
  8009fc:	83 e8 20             	sub    $0x20,%eax
  8009ff:	83 f8 5e             	cmp    $0x5e,%eax
  800a02:	76 10                	jbe    800a14 <vprintfmt+0x213>
					putch('?', putdat);
  800a04:	83 ec 08             	sub    $0x8,%esp
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	6a 3f                	push   $0x3f
  800a0c:	ff 55 08             	call   *0x8(%ebp)
  800a0f:	83 c4 10             	add    $0x10,%esp
  800a12:	eb 0d                	jmp    800a21 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a14:	83 ec 08             	sub    $0x8,%esp
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	52                   	push   %edx
  800a1b:	ff 55 08             	call   *0x8(%ebp)
  800a1e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a21:	83 eb 01             	sub    $0x1,%ebx
  800a24:	eb 1a                	jmp    800a40 <vprintfmt+0x23f>
  800a26:	89 75 08             	mov    %esi,0x8(%ebp)
  800a29:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a32:	eb 0c                	jmp    800a40 <vprintfmt+0x23f>
  800a34:	89 75 08             	mov    %esi,0x8(%ebp)
  800a37:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a40:	83 c7 01             	add    $0x1,%edi
  800a43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a47:	0f be d0             	movsbl %al,%edx
  800a4a:	85 d2                	test   %edx,%edx
  800a4c:	74 23                	je     800a71 <vprintfmt+0x270>
  800a4e:	85 f6                	test   %esi,%esi
  800a50:	78 a1                	js     8009f3 <vprintfmt+0x1f2>
  800a52:	83 ee 01             	sub    $0x1,%esi
  800a55:	79 9c                	jns    8009f3 <vprintfmt+0x1f2>
  800a57:	89 df                	mov    %ebx,%edi
  800a59:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5f:	eb 18                	jmp    800a79 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	53                   	push   %ebx
  800a65:	6a 20                	push   $0x20
  800a67:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	83 c4 10             	add    $0x10,%esp
  800a6f:	eb 08                	jmp    800a79 <vprintfmt+0x278>
  800a71:	89 df                	mov    %ebx,%edi
  800a73:	8b 75 08             	mov    0x8(%ebp),%esi
  800a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	7f e4                	jg     800a61 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a80:	e9 a2 fd ff ff       	jmp    800827 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a85:	83 fa 01             	cmp    $0x1,%edx
  800a88:	7e 16                	jle    800aa0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 50 08             	lea    0x8(%eax),%edx
  800a90:	89 55 14             	mov    %edx,0x14(%ebp)
  800a93:	8b 50 04             	mov    0x4(%eax),%edx
  800a96:	8b 00                	mov    (%eax),%eax
  800a98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a9e:	eb 32                	jmp    800ad2 <vprintfmt+0x2d1>
	else if (lflag)
  800aa0:	85 d2                	test   %edx,%edx
  800aa2:	74 18                	je     800abc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 04             	lea    0x4(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)
  800aad:	8b 00                	mov    (%eax),%eax
  800aaf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab2:	89 c1                	mov    %eax,%ecx
  800ab4:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800aba:	eb 16                	jmp    800ad2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800abc:	8b 45 14             	mov    0x14(%ebp),%eax
  800abf:	8d 50 04             	lea    0x4(%eax),%edx
  800ac2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac5:	8b 00                	mov    (%eax),%eax
  800ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aca:	89 c1                	mov    %eax,%ecx
  800acc:	c1 f9 1f             	sar    $0x1f,%ecx
  800acf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800add:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae1:	79 74                	jns    800b57 <vprintfmt+0x356>
				putch('-', putdat);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	53                   	push   %ebx
  800ae7:	6a 2d                	push   $0x2d
  800ae9:	ff d6                	call   *%esi
				num = -(long long) num;
  800aeb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aee:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af1:	f7 d8                	neg    %eax
  800af3:	83 d2 00             	adc    $0x0,%edx
  800af6:	f7 da                	neg    %edx
  800af8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800afb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b00:	eb 55                	jmp    800b57 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b02:	8d 45 14             	lea    0x14(%ebp),%eax
  800b05:	e8 83 fc ff ff       	call   80078d <getuint>
			base = 10;
  800b0a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0f:	eb 46                	jmp    800b57 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			//edited by Lethe 
			num = getuint(&ap,lflag);
  800b11:	8d 45 14             	lea    0x14(%ebp),%eax
  800b14:	e8 74 fc ff ff       	call   80078d <getuint>
			base=8;
  800b19:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b1e:	eb 37                	jmp    800b57 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b20:	83 ec 08             	sub    $0x8,%esp
  800b23:	53                   	push   %ebx
  800b24:	6a 30                	push   $0x30
  800b26:	ff d6                	call   *%esi
			putch('x', putdat);
  800b28:	83 c4 08             	add    $0x8,%esp
  800b2b:	53                   	push   %ebx
  800b2c:	6a 78                	push   $0x78
  800b2e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b30:	8b 45 14             	mov    0x14(%ebp),%eax
  800b33:	8d 50 04             	lea    0x4(%eax),%edx
  800b36:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b39:	8b 00                	mov    (%eax),%eax
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b40:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b43:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b48:	eb 0d                	jmp    800b57 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4d:	e8 3b fc ff ff       	call   80078d <getuint>
			base = 16;
  800b52:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b5e:	57                   	push   %edi
  800b5f:	ff 75 e0             	pushl  -0x20(%ebp)
  800b62:	51                   	push   %ecx
  800b63:	52                   	push   %edx
  800b64:	50                   	push   %eax
  800b65:	89 da                	mov    %ebx,%edx
  800b67:	89 f0                	mov    %esi,%eax
  800b69:	e8 70 fb ff ff       	call   8006de <printnum>
			break;
  800b6e:	83 c4 20             	add    $0x20,%esp
  800b71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b74:	e9 ae fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	53                   	push   %ebx
  800b7d:	51                   	push   %ecx
  800b7e:	ff d6                	call   *%esi
			break;
  800b80:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b86:	e9 9c fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	53                   	push   %ebx
  800b8f:	6a 25                	push   $0x25
  800b91:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	eb 03                	jmp    800b9b <vprintfmt+0x39a>
  800b98:	83 ef 01             	sub    $0x1,%edi
  800b9b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b9f:	75 f7                	jne    800b98 <vprintfmt+0x397>
  800ba1:	e9 81 fc ff ff       	jmp    800827 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 18             	sub    $0x18,%esp
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	74 26                	je     800bf5 <vsnprintf+0x47>
  800bcf:	85 d2                	test   %edx,%edx
  800bd1:	7e 22                	jle    800bf5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd3:	ff 75 14             	pushl  0x14(%ebp)
  800bd6:	ff 75 10             	pushl  0x10(%ebp)
  800bd9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bdc:	50                   	push   %eax
  800bdd:	68 c7 07 80 00       	push   $0x8007c7
  800be2:	e8 1a fc ff ff       	call   800801 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	eb 05                	jmp    800bfa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c02:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c05:	50                   	push   %eax
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	ff 75 08             	pushl  0x8(%ebp)
  800c0f:	e8 9a ff ff ff       	call   800bae <vsnprintf>
	va_end(ap);

	return rc;
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	eb 03                	jmp    800c26 <strlen+0x10>
		n++;
  800c23:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c26:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c2a:	75 f7                	jne    800c23 <strlen+0xd>
		n++;
	return n;
}
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	eb 03                	jmp    800c41 <strnlen+0x13>
		n++;
  800c3e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c41:	39 c2                	cmp    %eax,%edx
  800c43:	74 08                	je     800c4d <strnlen+0x1f>
  800c45:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c49:	75 f3                	jne    800c3e <strnlen+0x10>
  800c4b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	53                   	push   %ebx
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c59:	89 c2                	mov    %eax,%edx
  800c5b:	83 c2 01             	add    $0x1,%edx
  800c5e:	83 c1 01             	add    $0x1,%ecx
  800c61:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c65:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c68:	84 db                	test   %bl,%bl
  800c6a:	75 ef                	jne    800c5b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c76:	53                   	push   %ebx
  800c77:	e8 9a ff ff ff       	call   800c16 <strlen>
  800c7c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	01 d8                	add    %ebx,%eax
  800c84:	50                   	push   %eax
  800c85:	e8 c5 ff ff ff       	call   800c4f <strcpy>
	return dst;
}
  800c8a:	89 d8                	mov    %ebx,%eax
  800c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	8b 75 08             	mov    0x8(%ebp),%esi
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca1:	89 f2                	mov    %esi,%edx
  800ca3:	eb 0f                	jmp    800cb4 <strncpy+0x23>
		*dst++ = *src;
  800ca5:	83 c2 01             	add    $0x1,%edx
  800ca8:	0f b6 01             	movzbl (%ecx),%eax
  800cab:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cae:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb4:	39 da                	cmp    %ebx,%edx
  800cb6:	75 ed                	jne    800ca5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb8:	89 f0                	mov    %esi,%eax
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 10             	mov    0x10(%ebp),%edx
  800ccc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cce:	85 d2                	test   %edx,%edx
  800cd0:	74 21                	je     800cf3 <strlcpy+0x35>
  800cd2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd6:	89 f2                	mov    %esi,%edx
  800cd8:	eb 09                	jmp    800ce3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cda:	83 c2 01             	add    $0x1,%edx
  800cdd:	83 c1 01             	add    $0x1,%ecx
  800ce0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce3:	39 c2                	cmp    %eax,%edx
  800ce5:	74 09                	je     800cf0 <strlcpy+0x32>
  800ce7:	0f b6 19             	movzbl (%ecx),%ebx
  800cea:	84 db                	test   %bl,%bl
  800cec:	75 ec                	jne    800cda <strlcpy+0x1c>
  800cee:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cf0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf3:	29 f0                	sub    %esi,%eax
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d02:	eb 06                	jmp    800d0a <strcmp+0x11>
		p++, q++;
  800d04:	83 c1 01             	add    $0x1,%ecx
  800d07:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d0a:	0f b6 01             	movzbl (%ecx),%eax
  800d0d:	84 c0                	test   %al,%al
  800d0f:	74 04                	je     800d15 <strcmp+0x1c>
  800d11:	3a 02                	cmp    (%edx),%al
  800d13:	74 ef                	je     800d04 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 12             	movzbl (%edx),%edx
  800d1b:	29 d0                	sub    %edx,%eax
}
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	53                   	push   %ebx
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d29:	89 c3                	mov    %eax,%ebx
  800d2b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d2e:	eb 06                	jmp    800d36 <strncmp+0x17>
		n--, p++, q++;
  800d30:	83 c0 01             	add    $0x1,%eax
  800d33:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d36:	39 d8                	cmp    %ebx,%eax
  800d38:	74 15                	je     800d4f <strncmp+0x30>
  800d3a:	0f b6 08             	movzbl (%eax),%ecx
  800d3d:	84 c9                	test   %cl,%cl
  800d3f:	74 04                	je     800d45 <strncmp+0x26>
  800d41:	3a 0a                	cmp    (%edx),%cl
  800d43:	74 eb                	je     800d30 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d45:	0f b6 00             	movzbl (%eax),%eax
  800d48:	0f b6 12             	movzbl (%edx),%edx
  800d4b:	29 d0                	sub    %edx,%eax
  800d4d:	eb 05                	jmp    800d54 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d61:	eb 07                	jmp    800d6a <strchr+0x13>
		if (*s == c)
  800d63:	38 ca                	cmp    %cl,%dl
  800d65:	74 0f                	je     800d76 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d67:	83 c0 01             	add    $0x1,%eax
  800d6a:	0f b6 10             	movzbl (%eax),%edx
  800d6d:	84 d2                	test   %dl,%dl
  800d6f:	75 f2                	jne    800d63 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d82:	eb 03                	jmp    800d87 <strfind+0xf>
  800d84:	83 c0 01             	add    $0x1,%eax
  800d87:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d8a:	38 ca                	cmp    %cl,%dl
  800d8c:	74 04                	je     800d92 <strfind+0x1a>
  800d8e:	84 d2                	test   %dl,%dl
  800d90:	75 f2                	jne    800d84 <strfind+0xc>
			break;
	return (char *) s;
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	74 36                	je     800dda <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daa:	75 28                	jne    800dd4 <memset+0x40>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 23                	jne    800dd4 <memset+0x40>
		c &= 0xFF;
  800db1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db5:	89 d3                	mov    %edx,%ebx
  800db7:	c1 e3 08             	shl    $0x8,%ebx
  800dba:	89 d6                	mov    %edx,%esi
  800dbc:	c1 e6 18             	shl    $0x18,%esi
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	c1 e0 10             	shl    $0x10,%eax
  800dc4:	09 f0                	or     %esi,%eax
  800dc6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	09 d0                	or     %edx,%eax
  800dcc:	c1 e9 02             	shr    $0x2,%ecx
  800dcf:	fc                   	cld    
  800dd0:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd2:	eb 06                	jmp    800dda <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd7:	fc                   	cld    
  800dd8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dda:	89 f8                	mov    %edi,%eax
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800def:	39 c6                	cmp    %eax,%esi
  800df1:	73 35                	jae    800e28 <memmove+0x47>
  800df3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df6:	39 d0                	cmp    %edx,%eax
  800df8:	73 2e                	jae    800e28 <memmove+0x47>
		s += n;
		d += n;
  800dfa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfd:	89 d6                	mov    %edx,%esi
  800dff:	09 fe                	or     %edi,%esi
  800e01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e07:	75 13                	jne    800e1c <memmove+0x3b>
  800e09:	f6 c1 03             	test   $0x3,%cl
  800e0c:	75 0e                	jne    800e1c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e0e:	83 ef 04             	sub    $0x4,%edi
  800e11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e14:	c1 e9 02             	shr    $0x2,%ecx
  800e17:	fd                   	std    
  800e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1a:	eb 09                	jmp    800e25 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1c:	83 ef 01             	sub    $0x1,%edi
  800e1f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e22:	fd                   	std    
  800e23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e25:	fc                   	cld    
  800e26:	eb 1d                	jmp    800e45 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e28:	89 f2                	mov    %esi,%edx
  800e2a:	09 c2                	or     %eax,%edx
  800e2c:	f6 c2 03             	test   $0x3,%dl
  800e2f:	75 0f                	jne    800e40 <memmove+0x5f>
  800e31:	f6 c1 03             	test   $0x3,%cl
  800e34:	75 0a                	jne    800e40 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e36:	c1 e9 02             	shr    $0x2,%ecx
  800e39:	89 c7                	mov    %eax,%edi
  800e3b:	fc                   	cld    
  800e3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3e:	eb 05                	jmp    800e45 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e40:	89 c7                	mov    %eax,%edi
  800e42:	fc                   	cld    
  800e43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e4c:	ff 75 10             	pushl  0x10(%ebp)
  800e4f:	ff 75 0c             	pushl  0xc(%ebp)
  800e52:	ff 75 08             	pushl  0x8(%ebp)
  800e55:	e8 87 ff ff ff       	call   800de1 <memmove>
}
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e67:	89 c6                	mov    %eax,%esi
  800e69:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6c:	eb 1a                	jmp    800e88 <memcmp+0x2c>
		if (*s1 != *s2)
  800e6e:	0f b6 08             	movzbl (%eax),%ecx
  800e71:	0f b6 1a             	movzbl (%edx),%ebx
  800e74:	38 d9                	cmp    %bl,%cl
  800e76:	74 0a                	je     800e82 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e78:	0f b6 c1             	movzbl %cl,%eax
  800e7b:	0f b6 db             	movzbl %bl,%ebx
  800e7e:	29 d8                	sub    %ebx,%eax
  800e80:	eb 0f                	jmp    800e91 <memcmp+0x35>
		s1++, s2++;
  800e82:	83 c0 01             	add    $0x1,%eax
  800e85:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e88:	39 f0                	cmp    %esi,%eax
  800e8a:	75 e2                	jne    800e6e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9c:	89 c1                	mov    %eax,%ecx
  800e9e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea5:	eb 0a                	jmp    800eb1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea7:	0f b6 10             	movzbl (%eax),%edx
  800eaa:	39 da                	cmp    %ebx,%edx
  800eac:	74 07                	je     800eb5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eae:	83 c0 01             	add    $0x1,%eax
  800eb1:	39 c8                	cmp    %ecx,%eax
  800eb3:	72 f2                	jb     800ea7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec4:	eb 03                	jmp    800ec9 <strtol+0x11>
		s++;
  800ec6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec9:	0f b6 01             	movzbl (%ecx),%eax
  800ecc:	3c 20                	cmp    $0x20,%al
  800ece:	74 f6                	je     800ec6 <strtol+0xe>
  800ed0:	3c 09                	cmp    $0x9,%al
  800ed2:	74 f2                	je     800ec6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed4:	3c 2b                	cmp    $0x2b,%al
  800ed6:	75 0a                	jne    800ee2 <strtol+0x2a>
		s++;
  800ed8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800edb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee0:	eb 11                	jmp    800ef3 <strtol+0x3b>
  800ee2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee7:	3c 2d                	cmp    $0x2d,%al
  800ee9:	75 08                	jne    800ef3 <strtol+0x3b>
		s++, neg = 1;
  800eeb:	83 c1 01             	add    $0x1,%ecx
  800eee:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef9:	75 15                	jne    800f10 <strtol+0x58>
  800efb:	80 39 30             	cmpb   $0x30,(%ecx)
  800efe:	75 10                	jne    800f10 <strtol+0x58>
  800f00:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f04:	75 7c                	jne    800f82 <strtol+0xca>
		s += 2, base = 16;
  800f06:	83 c1 02             	add    $0x2,%ecx
  800f09:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0e:	eb 16                	jmp    800f26 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f10:	85 db                	test   %ebx,%ebx
  800f12:	75 12                	jne    800f26 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f14:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f19:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1c:	75 08                	jne    800f26 <strtol+0x6e>
		s++, base = 8;
  800f1e:	83 c1 01             	add    $0x1,%ecx
  800f21:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f2e:	0f b6 11             	movzbl (%ecx),%edx
  800f31:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f34:	89 f3                	mov    %esi,%ebx
  800f36:	80 fb 09             	cmp    $0x9,%bl
  800f39:	77 08                	ja     800f43 <strtol+0x8b>
			dig = *s - '0';
  800f3b:	0f be d2             	movsbl %dl,%edx
  800f3e:	83 ea 30             	sub    $0x30,%edx
  800f41:	eb 22                	jmp    800f65 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f43:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f46:	89 f3                	mov    %esi,%ebx
  800f48:	80 fb 19             	cmp    $0x19,%bl
  800f4b:	77 08                	ja     800f55 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f4d:	0f be d2             	movsbl %dl,%edx
  800f50:	83 ea 57             	sub    $0x57,%edx
  800f53:	eb 10                	jmp    800f65 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f55:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f58:	89 f3                	mov    %esi,%ebx
  800f5a:	80 fb 19             	cmp    $0x19,%bl
  800f5d:	77 16                	ja     800f75 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f5f:	0f be d2             	movsbl %dl,%edx
  800f62:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f65:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f68:	7d 0b                	jge    800f75 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f6a:	83 c1 01             	add    $0x1,%ecx
  800f6d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f71:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f73:	eb b9                	jmp    800f2e <strtol+0x76>

	if (endptr)
  800f75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f79:	74 0d                	je     800f88 <strtol+0xd0>
		*endptr = (char *) s;
  800f7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f7e:	89 0e                	mov    %ecx,(%esi)
  800f80:	eb 06                	jmp    800f88 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f82:	85 db                	test   %ebx,%ebx
  800f84:	74 98                	je     800f1e <strtol+0x66>
  800f86:	eb 9e                	jmp    800f26 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f88:	89 c2                	mov    %eax,%edx
  800f8a:	f7 da                	neg    %edx
  800f8c:	85 ff                	test   %edi,%edi
  800f8e:	0f 45 c2             	cmovne %edx,%eax
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	89 c7                	mov    %eax,%edi
  800fab:	89 c6                	mov    %eax,%esi
  800fad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc4:	89 d1                	mov    %edx,%ecx
  800fc6:	89 d3                	mov    %edx,%ebx
  800fc8:	89 d7                	mov    %edx,%edi
  800fca:	89 d6                	mov    %edx,%esi
  800fcc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe1:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	89 cb                	mov    %ecx,%ebx
  800feb:	89 cf                	mov    %ecx,%edi
  800fed:	89 ce                	mov    %ecx,%esi
  800fef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 17                	jle    80100c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	50                   	push   %eax
  800ff9:	6a 03                	push   $0x3
  800ffb:	68 ff 27 80 00       	push   $0x8027ff
  801000:	6a 23                	push   $0x23
  801002:	68 1c 28 80 00       	push   $0x80281c
  801007:	e8 e5 f5 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 02 00 00 00       	mov    $0x2,%eax
  801024:	89 d1                	mov    %edx,%ecx
  801026:	89 d3                	mov    %edx,%ebx
  801028:	89 d7                	mov    %edx,%edi
  80102a:	89 d6                	mov    %edx,%esi
  80102c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_yield>:

void
sys_yield(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
  80103e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801043:	89 d1                	mov    %edx,%ecx
  801045:	89 d3                	mov    %edx,%ebx
  801047:	89 d7                	mov    %edx,%edi
  801049:	89 d6                	mov    %edx,%esi
  80104b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	be 00 00 00 00       	mov    $0x0,%esi
  801060:	b8 04 00 00 00       	mov    $0x4,%eax
  801065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106e:	89 f7                	mov    %esi,%edi
  801070:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 17                	jle    80108d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	50                   	push   %eax
  80107a:	6a 04                	push   $0x4
  80107c:	68 ff 27 80 00       	push   $0x8027ff
  801081:	6a 23                	push   $0x23
  801083:	68 1c 28 80 00       	push   $0x80281c
  801088:	e8 64 f5 ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109e:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010af:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	7e 17                	jle    8010cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	50                   	push   %eax
  8010bc:	6a 05                	push   $0x5
  8010be:	68 ff 27 80 00       	push   $0x8027ff
  8010c3:	6a 23                	push   $0x23
  8010c5:	68 1c 28 80 00       	push   $0x80281c
  8010ca:	e8 22 f5 ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	89 df                	mov    %ebx,%edi
  8010f2:	89 de                	mov    %ebx,%esi
  8010f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	7e 17                	jle    801111 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	50                   	push   %eax
  8010fe:	6a 06                	push   $0x6
  801100:	68 ff 27 80 00       	push   $0x8027ff
  801105:	6a 23                	push   $0x23
  801107:	68 1c 28 80 00       	push   $0x80281c
  80110c:	e8 e0 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
  801127:	b8 08 00 00 00       	mov    $0x8,%eax
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	89 df                	mov    %ebx,%edi
  801134:	89 de                	mov    %ebx,%esi
  801136:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801138:	85 c0                	test   %eax,%eax
  80113a:	7e 17                	jle    801153 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	50                   	push   %eax
  801140:	6a 08                	push   $0x8
  801142:	68 ff 27 80 00       	push   $0x8027ff
  801147:	6a 23                	push   $0x23
  801149:	68 1c 28 80 00       	push   $0x80281c
  80114e:	e8 9e f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	b8 09 00 00 00       	mov    $0x9,%eax
  80116e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
  801174:	89 df                	mov    %ebx,%edi
  801176:	89 de                	mov    %ebx,%esi
  801178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117a:	85 c0                	test   %eax,%eax
  80117c:	7e 17                	jle    801195 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	50                   	push   %eax
  801182:	6a 09                	push   $0x9
  801184:	68 ff 27 80 00       	push   $0x8027ff
  801189:	6a 23                	push   $0x23
  80118b:	68 1c 28 80 00       	push   $0x80281c
  801190:	e8 5c f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 df                	mov    %ebx,%edi
  8011b8:	89 de                	mov    %ebx,%esi
  8011ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	7e 17                	jle    8011d7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c0:	83 ec 0c             	sub    $0xc,%esp
  8011c3:	50                   	push   %eax
  8011c4:	6a 0a                	push   $0xa
  8011c6:	68 ff 27 80 00       	push   $0x8027ff
  8011cb:	6a 23                	push   $0x23
  8011cd:	68 1c 28 80 00       	push   $0x80281c
  8011d2:	e8 1a f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	57                   	push   %edi
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e5:	be 00 00 00 00       	mov    $0x0,%esi
  8011ea:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011fb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801210:	b8 0d 00 00 00       	mov    $0xd,%eax
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	89 cb                	mov    %ecx,%ebx
  80121a:	89 cf                	mov    %ecx,%edi
  80121c:	89 ce                	mov    %ecx,%esi
  80121e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801220:	85 c0                	test   %eax,%eax
  801222:	7e 17                	jle    80123b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	50                   	push   %eax
  801228:	6a 0d                	push   $0xd
  80122a:	68 ff 27 80 00       	push   $0x8027ff
  80122f:	6a 23                	push   $0x23
  801231:	68 1c 28 80 00       	push   $0x80281c
  801236:	e8 b6 f3 ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80123b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  80124a:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801251:	75 57                	jne    8012aa <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// edited by Lethe 2018/12/7
		envid_t eid = sys_getenvid();
  801253:	e8 bc fd ff ff       	call   801014 <sys_getenvid>
  801258:	89 c3                	mov    %eax,%ebx

		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	6a 07                	push   $0x7
  80125f:	68 00 f0 bf ee       	push   $0xeebff000
  801264:	50                   	push   %eax
  801265:	e8 e8 fd ff ff       	call   801052 <sys_page_alloc>
		if (r) {
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	74 12                	je     801283 <set_pgfault_handler+0x40>
			panic("Sys page alloc error: %e", r);
  801271:	50                   	push   %eax
  801272:	68 2a 28 80 00       	push   $0x80282a
  801277:	6a 25                	push   $0x25
  801279:	68 43 28 80 00       	push   $0x802843
  80127e:	e8 6e f3 ff ff       	call   8005f1 <_panic>
		}

		// _pgfault_upcall is a global variable definited in lib/pfentry.S
		r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	68 b7 12 80 00       	push   $0x8012b7
  80128b:	53                   	push   %ebx
  80128c:	e8 0c ff ff ff       	call   80119d <sys_env_set_pgfault_upcall>
		if (r) {
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	74 12                	je     8012aa <set_pgfault_handler+0x67>
			panic("Sys env set pgfault upcall error: %e", r);
  801298:	50                   	push   %eax
  801299:	68 54 28 80 00       	push   $0x802854
  80129e:	6a 2b                	push   $0x2b
  8012a0:	68 43 28 80 00       	push   $0x802843
  8012a5:	e8 47 f3 ff ff       	call   8005f1 <_panic>
		}
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  8012b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012b7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012b8:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012bd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012bf:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	movl 0x28(%esp),%edx	# get trap-time eip
  8012c2:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)	# subl now because we can't do it afrer popfl
  8012c6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax	# get trap-time esp - 4
  8012cb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)	# use the reserved 4 bytes to store trap-time eip
  8012cf:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp		# skip fault-va and err
  8012d1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popal			# regs is designated in popal's order
  8012d4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	addl $0x4, %esp		# skip original trap-time eip
  8012d5:	83 c4 04             	add    $0x4,%esp
	popfl			# restore eflags
  8012d8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	popl %esp
  8012d9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/7
	ret			# "ret" is identical to "popl %eip"
  8012da:	c3                   	ret    

008012db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801308:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 16             	shr    $0x16,%edx
  801312:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	74 11                	je     80132f <fd_alloc+0x2d>
  80131e:	89 c2                	mov    %eax,%edx
  801320:	c1 ea 0c             	shr    $0xc,%edx
  801323:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132a:	f6 c2 01             	test   $0x1,%dl
  80132d:	75 09                	jne    801338 <fd_alloc+0x36>
			*fd_store = fd;
  80132f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 17                	jmp    80134f <fd_alloc+0x4d>
  801338:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80133d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801342:	75 c9                	jne    80130d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801344:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80134a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801357:	83 f8 1f             	cmp    $0x1f,%eax
  80135a:	77 36                	ja     801392 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80135c:	c1 e0 0c             	shl    $0xc,%eax
  80135f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801364:	89 c2                	mov    %eax,%edx
  801366:	c1 ea 16             	shr    $0x16,%edx
  801369:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801370:	f6 c2 01             	test   $0x1,%dl
  801373:	74 24                	je     801399 <fd_lookup+0x48>
  801375:	89 c2                	mov    %eax,%edx
  801377:	c1 ea 0c             	shr    $0xc,%edx
  80137a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801381:	f6 c2 01             	test   $0x1,%dl
  801384:	74 1a                	je     8013a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801386:	8b 55 0c             	mov    0xc(%ebp),%edx
  801389:	89 02                	mov    %eax,(%edx)
	return 0;
  80138b:	b8 00 00 00 00       	mov    $0x0,%eax
  801390:	eb 13                	jmp    8013a5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801397:	eb 0c                	jmp    8013a5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801399:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139e:	eb 05                	jmp    8013a5 <fd_lookup+0x54>
  8013a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b0:	ba fc 28 80 00       	mov    $0x8028fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b5:	eb 13                	jmp    8013ca <dev_lookup+0x23>
  8013b7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ba:	39 08                	cmp    %ecx,(%eax)
  8013bc:	75 0c                	jne    8013ca <dev_lookup+0x23>
			*dev = devtab[i];
  8013be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c8:	eb 2e                	jmp    8013f8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ca:	8b 02                	mov    (%edx),%eax
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	75 e7                	jne    8013b7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013d0:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013d5:	8b 40 48             	mov    0x48(%eax),%eax
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	51                   	push   %ecx
  8013dc:	50                   	push   %eax
  8013dd:	68 7c 28 80 00       	push   $0x80287c
  8013e2:	e8 e3 f2 ff ff       	call   8006ca <cprintf>
	*dev = 0;
  8013e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 10             	sub    $0x10,%esp
  801402:	8b 75 08             	mov    0x8(%ebp),%esi
  801405:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801408:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140b:	50                   	push   %eax
  80140c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801412:	c1 e8 0c             	shr    $0xc,%eax
  801415:	50                   	push   %eax
  801416:	e8 36 ff ff ff       	call   801351 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 05                	js     801427 <fd_close+0x2d>
	    || fd != fd2)
  801422:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801425:	74 0c                	je     801433 <fd_close+0x39>
		return (must_exist ? r : 0);
  801427:	84 db                	test   %bl,%bl
  801429:	ba 00 00 00 00       	mov    $0x0,%edx
  80142e:	0f 44 c2             	cmove  %edx,%eax
  801431:	eb 41                	jmp    801474 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 36                	pushl  (%esi)
  80143c:	e8 66 ff ff ff       	call   8013a7 <dev_lookup>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 1a                	js     801464 <fd_close+0x6a>
		if (dev->dev_close)
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801450:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801455:	85 c0                	test   %eax,%eax
  801457:	74 0b                	je     801464 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	56                   	push   %esi
  80145d:	ff d0                	call   *%eax
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	56                   	push   %esi
  801468:	6a 00                	push   $0x0
  80146a:	e8 68 fc ff ff       	call   8010d7 <sys_page_unmap>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	89 d8                	mov    %ebx,%eax
}
  801474:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	ff 75 08             	pushl  0x8(%ebp)
  801488:	e8 c4 fe ff ff       	call   801351 <fd_lookup>
  80148d:	83 c4 08             	add    $0x8,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 10                	js     8014a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	6a 01                	push   $0x1
  801499:	ff 75 f4             	pushl  -0xc(%ebp)
  80149c:	e8 59 ff ff ff       	call   8013fa <fd_close>
  8014a1:	83 c4 10             	add    $0x10,%esp
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <close_all>:

void
close_all(void)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	53                   	push   %ebx
  8014b6:	e8 c0 ff ff ff       	call   80147b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bb:	83 c3 01             	add    $0x1,%ebx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	83 fb 20             	cmp    $0x20,%ebx
  8014c4:	75 ec                	jne    8014b2 <close_all+0xc>
		close(i);
}
  8014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 2c             	sub    $0x2c,%esp
  8014d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	ff 75 08             	pushl  0x8(%ebp)
  8014de:	e8 6e fe ff ff       	call   801351 <fd_lookup>
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	0f 88 c1 00 00 00    	js     8015af <dup+0xe4>
		return r;
	close(newfdnum);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	56                   	push   %esi
  8014f2:	e8 84 ff ff ff       	call   80147b <close>

	newfd = INDEX2FD(newfdnum);
  8014f7:	89 f3                	mov    %esi,%ebx
  8014f9:	c1 e3 0c             	shl    $0xc,%ebx
  8014fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801502:	83 c4 04             	add    $0x4,%esp
  801505:	ff 75 e4             	pushl  -0x1c(%ebp)
  801508:	e8 de fd ff ff       	call   8012eb <fd2data>
  80150d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 d4 fd ff ff       	call   8012eb <fd2data>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80151d:	89 f8                	mov    %edi,%eax
  80151f:	c1 e8 16             	shr    $0x16,%eax
  801522:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801529:	a8 01                	test   $0x1,%al
  80152b:	74 37                	je     801564 <dup+0x99>
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	c1 e8 0c             	shr    $0xc,%eax
  801532:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801539:	f6 c2 01             	test   $0x1,%dl
  80153c:	74 26                	je     801564 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80153e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	25 07 0e 00 00       	and    $0xe07,%eax
  80154d:	50                   	push   %eax
  80154e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801551:	6a 00                	push   $0x0
  801553:	57                   	push   %edi
  801554:	6a 00                	push   $0x0
  801556:	e8 3a fb ff ff       	call   801095 <sys_page_map>
  80155b:	89 c7                	mov    %eax,%edi
  80155d:	83 c4 20             	add    $0x20,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 2e                	js     801592 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801564:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801567:	89 d0                	mov    %edx,%eax
  801569:	c1 e8 0c             	shr    $0xc,%eax
  80156c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	25 07 0e 00 00       	and    $0xe07,%eax
  80157b:	50                   	push   %eax
  80157c:	53                   	push   %ebx
  80157d:	6a 00                	push   $0x0
  80157f:	52                   	push   %edx
  801580:	6a 00                	push   $0x0
  801582:	e8 0e fb ff ff       	call   801095 <sys_page_map>
  801587:	89 c7                	mov    %eax,%edi
  801589:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80158c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158e:	85 ff                	test   %edi,%edi
  801590:	79 1d                	jns    8015af <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	6a 00                	push   $0x0
  801598:	e8 3a fb ff ff       	call   8010d7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a3:	6a 00                	push   $0x0
  8015a5:	e8 2d fb ff ff       	call   8010d7 <sys_page_unmap>
	return r;
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	89 f8                	mov    %edi,%eax
}
  8015af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b2:	5b                   	pop    %ebx
  8015b3:	5e                   	pop    %esi
  8015b4:	5f                   	pop    %edi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 14             	sub    $0x14,%esp
  8015be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	53                   	push   %ebx
  8015c6:	e8 86 fd ff ff       	call   801351 <fd_lookup>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 6d                	js     801641 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015de:	ff 30                	pushl  (%eax)
  8015e0:	e8 c2 fd ff ff       	call   8013a7 <dev_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 4c                	js     801638 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ef:	8b 42 08             	mov    0x8(%edx),%eax
  8015f2:	83 e0 03             	and    $0x3,%eax
  8015f5:	83 f8 01             	cmp    $0x1,%eax
  8015f8:	75 21                	jne    80161b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fa:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015ff:	8b 40 48             	mov    0x48(%eax),%eax
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	53                   	push   %ebx
  801606:	50                   	push   %eax
  801607:	68 c0 28 80 00       	push   $0x8028c0
  80160c:	e8 b9 f0 ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801619:	eb 26                	jmp    801641 <read+0x8a>
	}
	if (!dev->dev_read)
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	8b 40 08             	mov    0x8(%eax),%eax
  801621:	85 c0                	test   %eax,%eax
  801623:	74 17                	je     80163c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	ff 75 10             	pushl  0x10(%ebp)
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	52                   	push   %edx
  80162f:	ff d0                	call   *%eax
  801631:	89 c2                	mov    %eax,%edx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 09                	jmp    801641 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801638:	89 c2                	mov    %eax,%edx
  80163a:	eb 05                	jmp    801641 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80163c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801641:	89 d0                	mov    %edx,%eax
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	8b 7d 08             	mov    0x8(%ebp),%edi
  801654:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165c:	eb 21                	jmp    80167f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	89 f0                	mov    %esi,%eax
  801663:	29 d8                	sub    %ebx,%eax
  801665:	50                   	push   %eax
  801666:	89 d8                	mov    %ebx,%eax
  801668:	03 45 0c             	add    0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	57                   	push   %edi
  80166d:	e8 45 ff ff ff       	call   8015b7 <read>
		if (m < 0)
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 10                	js     801689 <readn+0x41>
			return m;
		if (m == 0)
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 0a                	je     801687 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167d:	01 c3                	add    %eax,%ebx
  80167f:	39 f3                	cmp    %esi,%ebx
  801681:	72 db                	jb     80165e <readn+0x16>
  801683:	89 d8                	mov    %ebx,%eax
  801685:	eb 02                	jmp    801689 <readn+0x41>
  801687:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5f                   	pop    %edi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 14             	sub    $0x14,%esp
  801698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	53                   	push   %ebx
  8016a0:	e8 ac fc ff ff       	call   801351 <fd_lookup>
  8016a5:	83 c4 08             	add    $0x8,%esp
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 68                	js     801716 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	ff 30                	pushl  (%eax)
  8016ba:	e8 e8 fc ff ff       	call   8013a7 <dev_lookup>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 47                	js     80170d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cd:	75 21                	jne    8016f0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cf:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016d4:	8b 40 48             	mov    0x48(%eax),%eax
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	53                   	push   %ebx
  8016db:	50                   	push   %eax
  8016dc:	68 dc 28 80 00       	push   $0x8028dc
  8016e1:	e8 e4 ef ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ee:	eb 26                	jmp    801716 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f6:	85 d2                	test   %edx,%edx
  8016f8:	74 17                	je     801711 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	ff 75 10             	pushl  0x10(%ebp)
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	50                   	push   %eax
  801704:	ff d2                	call   *%edx
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 09                	jmp    801716 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	eb 05                	jmp    801716 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801716:	89 d0                	mov    %edx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <seek>:

int
seek(int fdnum, off_t offset)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801723:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 22 fc ff ff       	call   801351 <fd_lookup>
  80172f:	83 c4 08             	add    $0x8,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 0e                	js     801744 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801736:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801739:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 14             	sub    $0x14,%esp
  80174d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	53                   	push   %ebx
  801755:	e8 f7 fb ff ff       	call   801351 <fd_lookup>
  80175a:	83 c4 08             	add    $0x8,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 65                	js     8017c8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801769:	50                   	push   %eax
  80176a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176d:	ff 30                	pushl  (%eax)
  80176f:	e8 33 fc ff ff       	call   8013a7 <dev_lookup>
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 44                	js     8017bf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801782:	75 21                	jne    8017a5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801784:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801789:	8b 40 48             	mov    0x48(%eax),%eax
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	53                   	push   %ebx
  801790:	50                   	push   %eax
  801791:	68 9c 28 80 00       	push   $0x80289c
  801796:	e8 2f ef ff ff       	call   8006ca <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a3:	eb 23                	jmp    8017c8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a8:	8b 52 18             	mov    0x18(%edx),%edx
  8017ab:	85 d2                	test   %edx,%edx
  8017ad:	74 14                	je     8017c3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	ff 75 0c             	pushl  0xc(%ebp)
  8017b5:	50                   	push   %eax
  8017b6:	ff d2                	call   *%edx
  8017b8:	89 c2                	mov    %eax,%edx
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb 09                	jmp    8017c8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	89 c2                	mov    %eax,%edx
  8017c1:	eb 05                	jmp    8017c8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c8:	89 d0                	mov    %edx,%eax
  8017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 14             	sub    $0x14,%esp
  8017d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 6c fb ff ff       	call   801351 <fd_lookup>
  8017e5:	83 c4 08             	add    $0x8,%esp
  8017e8:	89 c2                	mov    %eax,%edx
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 58                	js     801846 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	ff 30                	pushl  (%eax)
  8017fa:	e8 a8 fb ff ff       	call   8013a7 <dev_lookup>
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	85 c0                	test   %eax,%eax
  801804:	78 37                	js     80183d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801809:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180d:	74 32                	je     801841 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801812:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801819:	00 00 00 
	stat->st_isdir = 0;
  80181c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801823:	00 00 00 
	stat->st_dev = dev;
  801826:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	53                   	push   %ebx
  801830:	ff 75 f0             	pushl  -0x10(%ebp)
  801833:	ff 50 14             	call   *0x14(%eax)
  801836:	89 c2                	mov    %eax,%edx
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	eb 09                	jmp    801846 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183d:	89 c2                	mov    %eax,%edx
  80183f:	eb 05                	jmp    801846 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801841:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801846:	89 d0                	mov    %edx,%eax
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	6a 00                	push   $0x0
  801857:	ff 75 08             	pushl  0x8(%ebp)
  80185a:	e8 d6 01 00 00       	call   801a35 <open>
  80185f:	89 c3                	mov    %eax,%ebx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	78 1b                	js     801883 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	50                   	push   %eax
  80186f:	e8 5b ff ff ff       	call   8017cf <fstat>
  801874:	89 c6                	mov    %eax,%esi
	close(fd);
  801876:	89 1c 24             	mov    %ebx,(%esp)
  801879:	e8 fd fb ff ff       	call   80147b <close>
	return r;
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	89 f0                	mov    %esi,%eax
}
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	56                   	push   %esi
  80188e:	53                   	push   %ebx
  80188f:	89 c6                	mov    %eax,%esi
  801891:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801893:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  80189a:	75 12                	jne    8018ae <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	6a 01                	push   $0x1
  8018a1:	e8 fe 07 00 00       	call   8020a4 <ipc_find_env>
  8018a6:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018ab:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ae:	6a 07                	push   $0x7
  8018b0:	68 00 50 80 00       	push   $0x805000
  8018b5:	56                   	push   %esi
  8018b6:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018bc:	e8 8f 07 00 00       	call   802050 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018c1:	83 c4 0c             	add    $0xc,%esp
  8018c4:	6a 00                	push   $0x0
  8018c6:	53                   	push   %ebx
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 ea 06 00 00       	call   801fb8 <ipc_recv>
}
  8018ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f8:	e8 8d ff ff ff       	call   80188a <fsipc>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 40 0c             	mov    0xc(%eax),%eax
  80190b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801910:	ba 00 00 00 00       	mov    $0x0,%edx
  801915:	b8 06 00 00 00       	mov    $0x6,%eax
  80191a:	e8 6b ff ff ff       	call   80188a <fsipc>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	8b 40 0c             	mov    0xc(%eax),%eax
  801931:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 05 00 00 00       	mov    $0x5,%eax
  801940:	e8 45 ff ff ff       	call   80188a <fsipc>
  801945:	85 c0                	test   %eax,%eax
  801947:	78 2c                	js     801975 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	68 00 50 80 00       	push   $0x805000
  801951:	53                   	push   %ebx
  801952:	e8 f8 f2 ff ff       	call   800c4f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801957:	a1 80 50 80 00       	mov    0x805080,%eax
  80195c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801962:	a1 84 50 80 00       	mov    0x805084,%eax
  801967:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	//edit byLethe 2018/12/14
	 int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801983:	8b 55 08             	mov    0x8(%ebp),%edx
  801986:	8b 52 0c             	mov    0xc(%edx),%edx
  801989:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80198f:	a3 04 50 80 00       	mov    %eax,0x805004

	memmove(fsipcbuf.write.req_buf, buf, n);
  801994:	50                   	push   %eax
  801995:	ff 75 0c             	pushl  0xc(%ebp)
  801998:	68 08 50 80 00       	push   $0x805008
  80199d:	e8 3f f4 ff ff       	call   800de1 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ac:	e8 d9 fe ff ff       	call   80188a <fsipc>
	//panic("devfile_write not implemented");
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019c6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d6:	e8 af fe ff ff       	call   80188a <fsipc>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 4b                	js     801a2c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019e1:	39 c6                	cmp    %eax,%esi
  8019e3:	73 16                	jae    8019fb <devfile_read+0x48>
  8019e5:	68 0c 29 80 00       	push   $0x80290c
  8019ea:	68 13 29 80 00       	push   $0x802913
  8019ef:	6a 7c                	push   $0x7c
  8019f1:	68 28 29 80 00       	push   $0x802928
  8019f6:	e8 f6 eb ff ff       	call   8005f1 <_panic>
	assert(r <= PGSIZE);
  8019fb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a00:	7e 16                	jle    801a18 <devfile_read+0x65>
  801a02:	68 33 29 80 00       	push   $0x802933
  801a07:	68 13 29 80 00       	push   $0x802913
  801a0c:	6a 7d                	push   $0x7d
  801a0e:	68 28 29 80 00       	push   $0x802928
  801a13:	e8 d9 eb ff ff       	call   8005f1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	50                   	push   %eax
  801a1c:	68 00 50 80 00       	push   $0x805000
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	e8 b8 f3 ff ff       	call   800de1 <memmove>
	return r;
  801a29:	83 c4 10             	add    $0x10,%esp
}
  801a2c:	89 d8                	mov    %ebx,%eax
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 20             	sub    $0x20,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a3f:	53                   	push   %ebx
  801a40:	e8 d1 f1 ff ff       	call   800c16 <strlen>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4d:	7f 67                	jg     801ab6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a55:	50                   	push   %eax
  801a56:	e8 a7 f8 ff ff       	call   801302 <fd_alloc>
  801a5b:	83 c4 10             	add    $0x10,%esp
		return r;
  801a5e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 57                	js     801abb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	53                   	push   %ebx
  801a68:	68 00 50 80 00       	push   $0x805000
  801a6d:	e8 dd f1 ff ff       	call   800c4f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a75:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a82:	e8 03 fe ff ff       	call   80188a <fsipc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	79 14                	jns    801aa4 <open+0x6f>
		fd_close(fd, 0);
  801a90:	83 ec 08             	sub    $0x8,%esp
  801a93:	6a 00                	push   $0x0
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	e8 5d f9 ff ff       	call   8013fa <fd_close>
		return r;
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	89 da                	mov    %ebx,%edx
  801aa2:	eb 17                	jmp    801abb <open+0x86>
	}

	return fd2num(fd);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aaa:	e8 2c f8 ff ff       	call   8012db <fd2num>
  801aaf:	89 c2                	mov    %eax,%edx
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	eb 05                	jmp    801abb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ab6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  801acd:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad2:	e8 b3 fd ff ff       	call   80188a <fsipc>
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	e8 ff f7 ff ff       	call   8012eb <fd2data>
  801aec:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aee:	83 c4 08             	add    $0x8,%esp
  801af1:	68 3f 29 80 00       	push   $0x80293f
  801af6:	53                   	push   %ebx
  801af7:	e8 53 f1 ff ff       	call   800c4f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801afc:	8b 46 04             	mov    0x4(%esi),%eax
  801aff:	2b 06                	sub    (%esi),%eax
  801b01:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b07:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b0e:	00 00 00 
	stat->st_dev = &devpipe;
  801b11:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b18:	30 80 00 
	return 0;
}
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b31:	53                   	push   %ebx
  801b32:	6a 00                	push   $0x0
  801b34:	e8 9e f5 ff ff       	call   8010d7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b39:	89 1c 24             	mov    %ebx,(%esp)
  801b3c:	e8 aa f7 ff ff       	call   8012eb <fd2data>
  801b41:	83 c4 08             	add    $0x8,%esp
  801b44:	50                   	push   %eax
  801b45:	6a 00                	push   $0x0
  801b47:	e8 8b f5 ff ff       	call   8010d7 <sys_page_unmap>
}
  801b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	57                   	push   %edi
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
  801b57:	83 ec 1c             	sub    $0x1c,%esp
  801b5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b5d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b5f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b64:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 e0             	pushl  -0x20(%ebp)
  801b6d:	e8 6b 05 00 00       	call   8020dd <pageref>
  801b72:	89 c3                	mov    %eax,%ebx
  801b74:	89 3c 24             	mov    %edi,(%esp)
  801b77:	e8 61 05 00 00       	call   8020dd <pageref>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	39 c3                	cmp    %eax,%ebx
  801b81:	0f 94 c1             	sete   %cl
  801b84:	0f b6 c9             	movzbl %cl,%ecx
  801b87:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b8a:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801b90:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b93:	39 ce                	cmp    %ecx,%esi
  801b95:	74 1b                	je     801bb2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b97:	39 c3                	cmp    %eax,%ebx
  801b99:	75 c4                	jne    801b5f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b9b:	8b 42 58             	mov    0x58(%edx),%eax
  801b9e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba1:	50                   	push   %eax
  801ba2:	56                   	push   %esi
  801ba3:	68 46 29 80 00       	push   $0x802946
  801ba8:	e8 1d eb ff ff       	call   8006ca <cprintf>
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	eb ad                	jmp    801b5f <_pipeisclosed+0xe>
	}
}
  801bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 28             	sub    $0x28,%esp
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bc9:	56                   	push   %esi
  801bca:	e8 1c f7 ff ff       	call   8012eb <fd2data>
  801bcf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801bd9:	eb 4b                	jmp    801c26 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bdb:	89 da                	mov    %ebx,%edx
  801bdd:	89 f0                	mov    %esi,%eax
  801bdf:	e8 6d ff ff ff       	call   801b51 <_pipeisclosed>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	75 48                	jne    801c30 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801be8:	e8 46 f4 ff ff       	call   801033 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bed:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf0:	8b 0b                	mov    (%ebx),%ecx
  801bf2:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf5:	39 d0                	cmp    %edx,%eax
  801bf7:	73 e2                	jae    801bdb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	c1 fa 1f             	sar    $0x1f,%edx
  801c08:	89 d1                	mov    %edx,%ecx
  801c0a:	c1 e9 1b             	shr    $0x1b,%ecx
  801c0d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c10:	83 e2 1f             	and    $0x1f,%edx
  801c13:	29 ca                	sub    %ecx,%edx
  801c15:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c1d:	83 c0 01             	add    $0x1,%eax
  801c20:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c23:	83 c7 01             	add    $0x1,%edi
  801c26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c29:	75 c2                	jne    801bed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2e:	eb 05                	jmp    801c35 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c38:	5b                   	pop    %ebx
  801c39:	5e                   	pop    %esi
  801c3a:	5f                   	pop    %edi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	57                   	push   %edi
  801c41:	56                   	push   %esi
  801c42:	53                   	push   %ebx
  801c43:	83 ec 18             	sub    $0x18,%esp
  801c46:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c49:	57                   	push   %edi
  801c4a:	e8 9c f6 ff ff       	call   8012eb <fd2data>
  801c4f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c59:	eb 3d                	jmp    801c98 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c5b:	85 db                	test   %ebx,%ebx
  801c5d:	74 04                	je     801c63 <devpipe_read+0x26>
				return i;
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	eb 44                	jmp    801ca7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c63:	89 f2                	mov    %esi,%edx
  801c65:	89 f8                	mov    %edi,%eax
  801c67:	e8 e5 fe ff ff       	call   801b51 <_pipeisclosed>
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	75 32                	jne    801ca2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c70:	e8 be f3 ff ff       	call   801033 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c75:	8b 06                	mov    (%esi),%eax
  801c77:	3b 46 04             	cmp    0x4(%esi),%eax
  801c7a:	74 df                	je     801c5b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7c:	99                   	cltd   
  801c7d:	c1 ea 1b             	shr    $0x1b,%edx
  801c80:	01 d0                	add    %edx,%eax
  801c82:	83 e0 1f             	and    $0x1f,%eax
  801c85:	29 d0                	sub    %edx,%eax
  801c87:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c92:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c95:	83 c3 01             	add    $0x1,%ebx
  801c98:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c9b:	75 d8                	jne    801c75 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca0:	eb 05                	jmp    801ca7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cba:	50                   	push   %eax
  801cbb:	e8 42 f6 ff ff       	call   801302 <fd_alloc>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	0f 88 2c 01 00 00    	js     801df9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 73 f3 ff ff       	call   801052 <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	0f 88 0d 01 00 00    	js     801df9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cf2:	50                   	push   %eax
  801cf3:	e8 0a f6 ff ff       	call   801302 <fd_alloc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	0f 88 e2 00 00 00    	js     801de7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	68 07 04 00 00       	push   $0x407
  801d0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 3b f3 ff ff       	call   801052 <sys_page_alloc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	0f 88 c3 00 00 00    	js     801de7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	e8 bc f5 ff ff       	call   8012eb <fd2data>
  801d2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d31:	83 c4 0c             	add    $0xc,%esp
  801d34:	68 07 04 00 00       	push   $0x407
  801d39:	50                   	push   %eax
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 11 f3 ff ff       	call   801052 <sys_page_alloc>
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	85 c0                	test   %eax,%eax
  801d48:	0f 88 89 00 00 00    	js     801dd7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4e:	83 ec 0c             	sub    $0xc,%esp
  801d51:	ff 75 f0             	pushl  -0x10(%ebp)
  801d54:	e8 92 f5 ff ff       	call   8012eb <fd2data>
  801d59:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d60:	50                   	push   %eax
  801d61:	6a 00                	push   $0x0
  801d63:	56                   	push   %esi
  801d64:	6a 00                	push   $0x0
  801d66:	e8 2a f3 ff ff       	call   801095 <sys_page_map>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	83 c4 20             	add    $0x20,%esp
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 55                	js     801dc9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d97:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 32 f5 ff ff       	call   8012db <fd2num>
  801da9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dae:	83 c4 04             	add    $0x4,%esp
  801db1:	ff 75 f0             	pushl  -0x10(%ebp)
  801db4:	e8 22 f5 ff ff       	call   8012db <fd2num>
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801dc7:	eb 30                	jmp    801df9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	56                   	push   %esi
  801dcd:	6a 00                	push   $0x0
  801dcf:	e8 03 f3 ff ff       	call   8010d7 <sys_page_unmap>
  801dd4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 f3 f2 ff ff       	call   8010d7 <sys_page_unmap>
  801de4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ded:	6a 00                	push   $0x0
  801def:	e8 e3 f2 ff ff       	call   8010d7 <sys_page_unmap>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801df9:	89 d0                	mov    %edx,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	ff 75 08             	pushl  0x8(%ebp)
  801e0f:	e8 3d f5 ff ff       	call   801351 <fd_lookup>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 18                	js     801e33 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e1b:	83 ec 0c             	sub    $0xc,%esp
  801e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e21:	e8 c5 f4 ff ff       	call   8012eb <fd2data>
	return _pipeisclosed(fd, p);
  801e26:	89 c2                	mov    %eax,%edx
  801e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2b:	e8 21 fd ff ff       	call   801b51 <_pipeisclosed>
  801e30:	83 c4 10             	add    $0x10,%esp
}
  801e33:	c9                   	leave  
  801e34:	c3                   	ret    

00801e35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e45:	68 5e 29 80 00       	push   $0x80295e
  801e4a:	ff 75 0c             	pushl  0xc(%ebp)
  801e4d:	e8 fd ed ff ff       	call   800c4f <strcpy>
	return 0;
}
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	57                   	push   %edi
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e65:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e70:	eb 2d                	jmp    801e9f <devcons_write+0x46>
		m = n - tot;
  801e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e75:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e77:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e7f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e82:	83 ec 04             	sub    $0x4,%esp
  801e85:	53                   	push   %ebx
  801e86:	03 45 0c             	add    0xc(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	57                   	push   %edi
  801e8b:	e8 51 ef ff ff       	call   800de1 <memmove>
		sys_cputs(buf, m);
  801e90:	83 c4 08             	add    $0x8,%esp
  801e93:	53                   	push   %ebx
  801e94:	57                   	push   %edi
  801e95:	e8 fc f0 ff ff       	call   800f96 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9a:	01 de                	add    %ebx,%esi
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	89 f0                	mov    %esi,%eax
  801ea1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea4:	72 cc                	jb     801e72 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5f                   	pop    %edi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 08             	sub    $0x8,%esp
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebd:	74 2a                	je     801ee9 <devcons_read+0x3b>
  801ebf:	eb 05                	jmp    801ec6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec1:	e8 6d f1 ff ff       	call   801033 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec6:	e8 e9 f0 ff ff       	call   800fb4 <sys_cgetc>
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	74 f2                	je     801ec1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	78 16                	js     801ee9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed3:	83 f8 04             	cmp    $0x4,%eax
  801ed6:	74 0c                	je     801ee4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edb:	88 02                	mov    %al,(%edx)
	return 1;
  801edd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee2:	eb 05                	jmp    801ee9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    

00801eeb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ef7:	6a 01                	push   $0x1
  801ef9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efc:	50                   	push   %eax
  801efd:	e8 94 f0 ff ff       	call   800f96 <sys_cputs>
}
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <getchar>:

int
getchar(void)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f0d:	6a 01                	push   $0x1
  801f0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	6a 00                	push   $0x0
  801f15:	e8 9d f6 ff ff       	call   8015b7 <read>
	if (r < 0)
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 0f                	js     801f30 <getchar+0x29>
		return r;
	if (r < 1)
  801f21:	85 c0                	test   %eax,%eax
  801f23:	7e 06                	jle    801f2b <getchar+0x24>
		return -E_EOF;
	return c;
  801f25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f29:	eb 05                	jmp    801f30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	ff 75 08             	pushl  0x8(%ebp)
  801f3f:	e8 0d f4 ff ff       	call   801351 <fd_lookup>
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	78 11                	js     801f5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f54:	39 10                	cmp    %edx,(%eax)
  801f56:	0f 94 c0             	sete   %al
  801f59:	0f b6 c0             	movzbl %al,%eax
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <opencons>:

int
opencons(void)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	e8 95 f3 ff ff       	call   801302 <fd_alloc>
  801f6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801f70:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 3e                	js     801fb4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	68 07 04 00 00       	push   $0x407
  801f7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f81:	6a 00                	push   $0x0
  801f83:	e8 ca f0 ff ff       	call   801052 <sys_page_alloc>
  801f88:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	78 23                	js     801fb4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	50                   	push   %eax
  801faa:	e8 2c f3 ff ff       	call   8012db <fd2num>
  801faf:	89 c2                	mov    %eax,%edx
  801fb1:	83 c4 10             	add    $0x10,%esp
}
  801fb4:	89 d0                	mov    %edx,%eax
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	int r = 0;
	if (pg) {
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	74 3e                	je     802008 <ipc_recv+0x50>
		r = sys_ipc_recv(pg);
  801fca:	83 ec 0c             	sub    $0xc,%esp
  801fcd:	50                   	push   %eax
  801fce:	e8 2f f2 ff ff       	call   801202 <sys_ipc_recv>
  801fd3:	89 c2                	mov    %eax,%edx

		if (from_env_store) {
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	85 f6                	test   %esi,%esi
  801fda:	74 13                	je     801fef <ipc_recv+0x37>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  801fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe1:	85 d2                	test   %edx,%edx
  801fe3:	75 08                	jne    801fed <ipc_recv+0x35>
  801fe5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801fea:	8b 40 74             	mov    0x74(%eax),%eax
  801fed:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801fef:	85 db                	test   %ebx,%ebx
  801ff1:	74 48                	je     80203b <ipc_recv+0x83>
			*perm_store = (r == 0) ? (thisenv->env_ipc_perm) : 0;
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff8:	85 d2                	test   %edx,%edx
  801ffa:	75 08                	jne    802004 <ipc_recv+0x4c>
  801ffc:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802001:	8b 40 78             	mov    0x78(%eax),%eax
  802004:	89 03                	mov    %eax,(%ebx)
  802006:	eb 33                	jmp    80203b <ipc_recv+0x83>
		}
	}
	else {
		// 'pg' is null , pass sys_ipc_recv "UTOP" which means to "no page"
		r = sys_ipc_recv((void *)UTOP);
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	68 00 00 c0 ee       	push   $0xeec00000
  802010:	e8 ed f1 ff ff       	call   801202 <sys_ipc_recv>
  802015:	89 c2                	mov    %eax,%edx
		if (from_env_store) {
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 f6                	test   %esi,%esi
  80201c:	74 13                	je     802031 <ipc_recv+0x79>
			*from_env_store = (r == 0) ? (thisenv->env_ipc_from) : 0;
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
  802023:	85 d2                	test   %edx,%edx
  802025:	75 08                	jne    80202f <ipc_recv+0x77>
  802027:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80202c:	8b 40 74             	mov    0x74(%eax),%eax
  80202f:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802031:	85 db                	test   %ebx,%ebx
  802033:	74 06                	je     80203b <ipc_recv+0x83>
			*perm_store = 0;
  802035:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
	}

	if (r)
		// system call fails, return the error
		return r;
  80203b:	89 d0                	mov    %edx,%eax
		if (perm_store) {
			*perm_store = 0;
		}
	}

	if (r)
  80203d:	85 d2                	test   %edx,%edx
  80203f:	75 08                	jne    802049 <ipc_recv+0x91>
		// system call fails, return the error
		return r;
	
	// system call success
	return thisenv->env_ipc_value;
  802041:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802046:	8b 40 70             	mov    0x70(%eax),%eax

	/*panic("ipc_recv not implemented");
	return 0;*/
}
  802049:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80204c:	5b                   	pop    %ebx
  80204d:	5e                   	pop    %esi
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

00802050 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	57                   	push   %edi
  802054:	56                   	push   %esi
  802055:	53                   	push   %ebx
  802056:	83 ec 0c             	sub    $0xc,%esp
  802059:	8b 7d 08             	mov    0x8(%ebp),%edi
  80205c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80205f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if (!pg)
  802062:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;
  802064:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802069:	0f 44 d8             	cmove  %eax,%ebx

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80206c:	eb 1c                	jmp    80208a <ipc_send+0x3a>
		if (r != -E_IPC_NOT_RECV) {
  80206e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802071:	74 12                	je     802085 <ipc_send+0x35>
			panic("Sys ipc try send error: %e", r);
  802073:	50                   	push   %eax
  802074:	68 6a 29 80 00       	push   $0x80296a
  802079:	6a 4f                	push   $0x4f
  80207b:	68 85 29 80 00       	push   $0x802985
  802080:	e8 6c e5 ff ff       	call   8005f1 <_panic>
		}

		// to be CPU-friendly
		sys_yield();
  802085:	e8 a9 ef ff ff       	call   801033 <sys_yield>
	// edited by Lethe 2018/12/8
	if (!pg)
		pg = (void *)-1;

	int r = 0;
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80208a:	ff 75 14             	pushl  0x14(%ebp)
  80208d:	53                   	push   %ebx
  80208e:	56                   	push   %esi
  80208f:	57                   	push   %edi
  802090:	e8 4a f1 ff ff       	call   8011df <sys_ipc_try_send>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 d2                	js     80206e <ipc_send+0x1e>

		// to be CPU-friendly
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80209c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020af:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020b2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b8:	8b 52 50             	mov    0x50(%edx),%edx
  8020bb:	39 ca                	cmp    %ecx,%edx
  8020bd:	75 0d                	jne    8020cc <ipc_find_env+0x28>
			return envs[i].env_id;
  8020bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c7:	8b 40 48             	mov    0x48(%eax),%eax
  8020ca:	eb 0f                	jmp    8020db <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020cc:	83 c0 01             	add    $0x1,%eax
  8020cf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d4:	75 d9                	jne    8020af <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    

008020dd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e3:	89 d0                	mov    %edx,%eax
  8020e5:	c1 e8 16             	shr    $0x16,%eax
  8020e8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020ef:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f4:	f6 c1 01             	test   $0x1,%cl
  8020f7:	74 1d                	je     802116 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020f9:	c1 ea 0c             	shr    $0xc,%edx
  8020fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802103:	f6 c2 01             	test   $0x1,%dl
  802106:	74 0e                	je     802116 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802108:	c1 ea 0c             	shr    $0xc,%edx
  80210b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802112:	ef 
  802113:	0f b7 c0             	movzwl %ax,%eax
}
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
