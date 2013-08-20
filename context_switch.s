GIC0: .word 0x1E000000
TASK_READY: .word 0

.type activate, %function
.global activate
activate:
	mov ip, sp
	push {r4,r5,r6,r7,r8,r9,r10,fp,ip,lr}

	add r0, #4 /* skip STATE */
	ldmfd r0!, {ip,lr}
	msr SPSR, ip

	msr CPSR_c, #0xDF /* System mode */
	mov sp, r0
	pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,fp,ip,lr}
	msr CPSR_c, #0xD3 /* Supervisor mode */

	movs pc, lr

.global svc_entry
svc_entry:
	msr CPSR_c, #0xDF /* System mode */
	push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,fp,ip,lr}
	mov r0, r7
	mov r1, sp
	msr CPSR_c, #0xD3 /* Supervisor mode */

	mrs ip, SPSR
	ldr r4, TASK_READY
	stmfd r1!, {r4,ip,lr}

	push {r1}
	bl handle_svc
	pop {r0}

	pop {r4-r12,lr}
	mov sp, ip
	bx lr

.global irq_entry
irq_entry:
	push {r0-r5,ip}
	mrs ip, SPSR
	sub lr, lr, #0x4
	push {ip,lr}

	msr CPSR_c, #0xD3 /* Supervisor mode */

	ldr r0, GIC0
	ldr r0, [r0, #0x00C]

	ldr r5, =irq_level
	ldr r4, [r5]
	add r4, r4, #1
	str r4, [r5]

	cpsie i

	bl handle_irq

	cpsid i

	sub r4, r4, #1
	str r4, [r5]
	cmp r4, #0
	bne back

	ldr r5, =flags
	ldr r5, [r5]
	ands r5, r5, #1 /* NEED_RESCHED */
	beq back

	/* Resave state on user stack */
	msr CPSR_c, #0xD2
	pop {ip, lr}
	msr SPSR, ip
	pop {r0-r5,ip}

	push {r0}
	msr CPSR_c, #0xDF
	push {r1-r12,lr}
	mov r0, sp
	msr CPSR_c, #0xD2
	pop {r1}
	stmfd r0!, {r1}
	mrs ip, SPSR
	ldr r4, TASK_READY
	stmfd r0!, {r4,ip,lr}

	msr CPSR_c, #0xD3

	pop {r4-r12,lr}
	mov sp, ip
	bx lr

back:
	msr CPSR_c, #0xD2 /* IRQ mode */
	pop {ip, lr}
	msr SPSR, ip
	pop {r0-r5,ip}
	bx lr
