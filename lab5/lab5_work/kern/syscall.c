/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	// edited by Lethe 
	// use function user_mem_assert in kern/pmap.c
	// check whether it has permissions 'perm | PTE_U | PTE_P'
	user_mem_assert(curenv, s, len, 0);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	
	// edited by Lethe 2018/12/7
	

	struct Env * childEnv = NULL;
	struct Env * parentEnv = curenv;

	// env_alloc(struct Env **newenv_store, envid_t parent_id)
	// On success, the new environment is stored in *newenv_store.
	// Returns 0 on success, < 0 on failure.
	int ret;
	ret = env_alloc(&childEnv, parentEnv->env_id);

	if (ret < 0) {
		// return <0 on error
		return ret;
	}

	// set some value of childEnv
	childEnv->env_tf = parentEnv->env_tf;
	childEnv->env_status = ENV_NOT_RUNNABLE;
	childEnv->env_tf.tf_regs.reg_eax = 0;

	// return envid of new environment
	return childEnv->env_id;

	//panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	
	// edited by Lethe 2018/12/7
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
		// return -E_INVAL if status is not a valid status for an environment.
		return -E_INVAL;
	}

	// Converts an envid to an env pointer.
	// int envid2env(envid_t envid, struct Env **env_store, bool checkperm)
	// If checkperm is set, the specified environment must be either the
	// current environment or an immediate child of the current environment.
	struct Env * e;
	if (envid2env(envid, &e, 1) < 0) {
		//	-E_BAD_ENV if environment envid doesn't currently exist,
		//		or the caller doesn't have permission to change envid.
		return -E_BAD_ENV;
	}

	// set status
	e->env_status = status;
	return 0;

	//panic("sys_env_set_status not implemented");
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	//edit by Lethe 2018/12/14
	int r;
	struct Env *e;
	if ((r = envid2env(envid, &e, 1)) < 0) {
		return r;
	}
	tf->tf_eflags = FL_IF;
	tf->tf_eflags &= ~FL_IOPL_MASK;         //普通进程不能有IO权限
	tf->tf_cs = GD_UT | 3;
	e->env_tf = *tf;
	return 0;
	//panic("sys_env_set_trapframe not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	struct Env * e = NULL;
	int ret = 0;
	if ((ret = envid2env(envid, &e, 1)) < 0) {
		return ret;
	}

	e->env_pgfault_upcall = func;
	// return 0 on success
	return 0;

	//panic("sys_env_set_pgfault_upcall not implemented");
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	// check parameters at first
	// check 1
	if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
		// PTE_U | PTE_P must be set
		return -E_INVAL;
	}
	// check 2
	if ((perm & (~PTE_SYSCALL)) != 0) {
		// no other bits may be set
		return -E_INVAL;
	}
	// check 3
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
		// return -E_INVAL if va >= UTOP, or va is not page-aligned
		return -E_INVAL;
	}

	// check envid and caller's permission
	struct Env * e = NULL;
	int ret = 0;
	if ((ret = envid2env(envid, &e, 1)) < 0) {
		// envid2env's return value:
		// 0 on success, -E_BAD_ENV on error
		return ret;
	}

	// alloc a page
	// page_alloc(1) will initialize the returnd page with '\0'
	// Returns NULL if out of free memory.
	struct PageInfo * page = page_alloc(1);
	if (!page) {
		//	-E_NO_MEM if there's no memory to allocate the new page,
		//		or to allocate any necessary page tables.
		return -E_NO_MEM;
	}

	// map it at 'va' with permission 'perm' in the address space of 'envid'.
	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	// return 0 on success; -E_NO_MEM, if page table couldn't be allocated
	ret = page_insert(e->env_pgdir, page, va, perm);
	if (ret < 0) {
		//   If page_insert() fails, remember to free the page you
		//   allocated!
		page_free(page);
		return ret;
	}
	
	// return 0 on success
	return 0;

	//panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	// edited by Lethe 2018/12/7
	// again, check parameters at first
	struct Env *srcE = NULL, *dstE = NULL;
	int ret = 0;

	// check 1
	// return -E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	if ((ret=envid2env(srcenvid,&srcE,1))<0) {
		return -E_BAD_ENV;
	}
	if ((ret = envid2env(dstenvid, &dstE, 1))<0) {
		return -E_BAD_ENV;
	}
	
	// check 2
	// return -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (((uintptr_t)srcva >= UTOP) || (ROUNDDOWN(srcva, PGSIZE) != srcva)) {
		return -E_INVAL;
	}
	if (((uintptr_t)dstva >= UTOP) || (ROUNDDOWN(dstva, PGSIZE) != dstva)) {
		return -E_INVAL;
	}

	// check 3
	// return -E_INVAL is srcva is not mapped in srcenvid's address space.

	// struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
	// Return NULL if there is no page mapped at va.
	pte_t * srcPte = NULL;
	struct PageInfo * page = NULL;
	page = page_lookup(srcE->env_pgdir, srcva, &srcPte);
	if (!page) {
		return -E_INVAL;
	}

	// check 4
	// return -E_INVAL if perm is inappropriate (see sys_page_alloc).
	if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
		// PTE_U | PTE_P must be set
		return -E_INVAL;
	}
	if ((perm & (~PTE_SYSCALL)) != 0) {
		// no other bits may be set
		return -E_INVAL;
	}

	// check 5
	// return -E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's address space.
	if ((perm & PTE_W) && (((*srcPte) & PTE_W) == 0)) {
		return -E_INVAL;
	}

	// check 6
	// return -E_NO_MEM if there's no memory to allocate any necessary page tables.
	// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
	// return 0 on success; -E_NO_MEM, if page table couldn't be allocated
	ret = page_insert(dstE->env_pgdir, page, dstva, perm);
	if (ret < 0) {
		return ret;
	}

	// return 0 on success
	return 0;

	//panic("sys_page_map not implemented");
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	
	// edited by Lethe 2018/12/7
	// this is just a simple call of page_remove(pde_t *pgdir, void *va)
	// it will unmaps the physical page at virtual address 'va'.
	// If there is no physical page at that address, silently does nothing.

	// check parameters at first again and again
	
	// check 1
	// return -E_BAD_ENV if environment envid doesn't currently exist,
	//		or the caller doesn't have permission to change envid.
	struct Env * e;
	if (envid2env(envid, &e, 1) < 0) {
		return -E_BAD_ENV;
	}

	// check 2
	// return -E_INVAL if va >= UTOP, or va is not page-aligned.
	if (((uintptr_t)va >= UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) {
		return -E_INVAL;
	}

	// unmap the page by call page_remove
	page_remove(e->env_pgdir, va);
	
	// return 0 on success
	return 0;

	//panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	struct Env * e = NULL;
	int r = 0;

	// check 1, return -E_BAD_ENV if environment envid doesn't currently exist
	// no need to check permissions, so we set checkperm 0 here
	if ((r = envid2env(envid, &e, 0)) < 0) {
		return r;
	}

	// check 2, return -E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv
	if (((e->env_ipc_recving) == false)) {
		return -E_IPC_NOT_RECV;
	}

	if (srcva < (void *)UTOP) {
		// check 3, return -E_INVAL if srcva < UTOP but srcva is not page-aligned.
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) {
			return -E_INVAL;
		}

		// check 4, return -E_INVAL if srcva < UTOP and perm is inappropriate
		// check 4_1
		if (((perm & PTE_U) == 0) || ((perm & PTE_P) == 0)) {
			// PTE_U | PTE_P must be set
			return -E_INVAL;
		}
		// check 4_2
		if ((perm & (~PTE_SYSCALL)) != 0) {
			// no other bits may be set
			return -E_INVAL;
		}

		// check 5, return -E_INVAL if srcva < UTOP but srcva 
		// is not mapped in the caller's address space.
		pte_t * pte = NULL;
		struct PageInfo * pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) {
			return -E_INVAL;
		}

		// check 6, return -E_INVAL if (perm & PTE_W), but srcva is read-only in the
		// current environment's address space.
		if ((perm & PTE_W) && (!((*pte) & PTE_W))) {
			// perm has the permission of write while srcva doesn't have permission of write
			// check the bit PTE_W of *pte instead of check PTE_R
			return -E_INVAL;
		}

		// check 7, return -E_NO_MEM if there's not enough memory 
		// to map srcva in envid's address space.
		if ((e->env_ipc_dstva) < (void *)UTOP) {
			// int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
			if ((r = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm)) < 0) {
				return -E_NO_MEM;
			}

			// env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
			e->env_ipc_perm = perm;
		}
	}

	// At here, the send succeeds, and the target's ipc fields should be updated
	e->env_ipc_recving = 0;				// env_ipc_recving is set to 0 to block future sends;
	e->env_ipc_from = curenv->env_id;	// env_ipc_from is set to the sending envid;
	e->env_ipc_value = value;			// env_ipc_value is set to the 'value' parameter;

	e->env_status = ENV_RUNNABLE;
	e->env_tf.tf_regs.reg_eax = 0;	
	return 0;

	//panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// edited by Lethe 2018/12/8
	if ((dstva < (void *)UTOP) && (dstva != ROUNDDOWN(dstva, PGSIZE))) {
		return -E_INVAL;
	}

	curenv->env_ipc_recving = 1;
	curenv->env_ipc_dstva = dstva;
	curenv->env_status = ENV_NOT_RUNNABLE;
	sys_yield();

	//panic("sys_ipc_recv not implemented");
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	// edited by Lethe 

	//panic("syscall not implemented");

	switch (syscallno) {
		// look up system call numbers' definitions
		// in inc/syscall.h
	case SYS_cputs:
		// static void sys_cputs(const char *s, size_t len)
		sys_cputs((char *)a1, a2);
		return 0;

	case SYS_cgetc:
		// static int sys_cgetc(void)
		return sys_cgetc();

	case SYS_getenvid:
		// static envid_t sys_getenvid(void)
		return (int)sys_getenvid();

	case SYS_env_destroy:
		// static int sys_env_destroy(envid_t envid)
		return sys_env_destroy(a1);

	// edited by Lethe 
	// exercise 6, lab 4
	case SYS_yield:
		// static void sys_yield(void)
		// sys_yield doesn't have a return value
		// how to handle this problem?
		sys_yield();
		return 0;
		//break;
	
	// edited by Lethe 
	// exercise 7, lab 4
	case SYS_exofork:
		// static envid_t sys_exofork(void)
		return (int)sys_exofork();

	case SYS_env_set_status:
		// static int sys_env_set_status(envid_t envid, int status)
		return sys_env_set_status((envid_t)a1, (int)a2);

	case SYS_page_alloc:
		// static int sys_page_alloc(envid_t envid, void *va, int perm)
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);

	case SYS_page_map:
		// static int sys_page_map(envid_t srcenvid, void *srcva,
		// envid_t dstenvid, void *dstva, int perm)
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, a5);

	case SYS_page_unmap:
		// static int sys_page_unmap(envid_t envid, void *va)
		return sys_page_unmap((envid_t)a1, (void *)a2);

	// edited by Lethe 
	// exercise 11, lab 4
	case SYS_env_set_pgfault_upcall:
		// static int sys_env_set_pgfault_upcall(envid_t envid, void *func)
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
	
	// exercise 15, lab 4
	// edited by Lethe 
	case SYS_ipc_try_send:
		// static int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
		return sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned)a4);
	case SYS_ipc_recv:
		// static int sys_ipc_recv(void *dstva)
		return sys_ipc_recv((void *)a1);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe((envid_t)a1,(struct Trapframe *)a2);

	default:
		return -E_INVAL;
	}
}



