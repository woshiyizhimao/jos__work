// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
//<<<<<<< HEAD
#include <kern/trap.h>

#include <kern/pmap.h>
//>>>>>>> lab2

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};
int mon_showmappings(int argc, char **argv,struct Trapframe *tf);

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
{ "backtrace", "Display information about the stack frames", mon_backtrace },
{ "showmappings", "Display in a useful and easy-to-read format all of the physical page mappings (or lack thereof) that apply to a particular range of virtual/linear addresses in the currently ", mon_showmappings },
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	//added by Lethe
	cprintf("Stack backtrace:\n");
	uint32_t ebp,eip,*p;
	ebp=read_ebp();
	p=(uint32_t*)ebp;
	do{
		eip=*(p+1);
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,eip,*(p+2),*(p+3),*(p+4),*(p+5),*(p+6));
		struct Eipdebuginfo  info;
		debuginfo_eip(eip,&info);
		cprintf ("\t%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,eip-info.eip_fn_addr);
		ebp=*p;
		p=(uint32_t*)ebp;
	}while(ebp);

	return 0;
}

//edit by Lethe 2018/10/31
int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
    // 参数检查
    if (argc != 3) {
        cprintf("Requir 2 virtual address as arguments.\n");
        return -1;
    }
    char *errChar;
    uintptr_t start_addr = strtol(argv[1], &errChar, 16);
    if (*errChar) {
        cprintf("Invalid virtual address: %s.\n", argv[1]);
        return -1;
    }
    uintptr_t end_addr = strtol(argv[2], &errChar, 16);
    if (*errChar) {
        cprintf("Invalid virtual address: %s.\n", argv[2]);
        return -1;
    }
    if (start_addr > end_addr) {
        cprintf("Address 1 must be lower than address 2\n");
        return -1;
    }
    
    // 按页对齐
    start_addr = ROUNDDOWN(start_addr, PGSIZE);
    end_addr = ROUNDUP(end_addr, PGSIZE);

    // 开始循环
    uintptr_t cur_addr = start_addr;
    while (cur_addr <= end_addr) {
        pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
        // 记录自己一个错误
        // if ( !cur_pte) {
        if ( !cur_pte || !(*cur_pte & PTE_P)) {
            cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
        } else {
            cprintf( "Virtual address [%08x] - physical address [%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
            char perm_PS = (*cur_pte & PTE_PS) ? 'S':'-';
            char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
            char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
            // 进入 else 分支说明 PTE_P 肯定为真了
            cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
        }
        cur_addr += PGSIZE;
    }
    return 0;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");
	int x = 1, y = 3, z = 4;

	cprintf("x %d, y %x, z %d\n", x, y, z);
	
	unsigned int i = 0x00646c72;

	cprintf("H%x Wo%s", 57616, &i);
	

	cprintf("x=%d y=%d\n", 3);

	//test color
	//cprintf("%agrnCan you see my color?\n");
	//cprintf("%awhtYes,I can!\n");
	//cprintf("%aredSo what is my color?\n");
	//cprintf("%apurOh,you are red.\n");
	//cprintf("%aorgI think I am the best.\n");
	//cprintf("%abluI think I am better than you.\n");

	/*cprintf("%agrn求求操作系统对我好点吧！\n");
	cprintf("%awht求求操作系统对我好点吧！\n");
	cprintf("%ared求求操作系统对我好点吧！\n");
	cprintf("%apur求求操作系统对我好点吧！\n");
	cprintf("%aorg求求操作系统对我好点吧！\n");*/


	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}


