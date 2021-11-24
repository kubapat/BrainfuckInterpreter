.data
	array: .skip 240000

.text
.global brainfuck

brainfuck:
	push %rbp
	mov %rsp, %rbp		#Subroutine prologue

	push %rbx
	push %r12
	push %r13
	push %r14
	push %r15		#Push all calee-saved regs onto stack in order to use them freely


	mov $array, %rbx	#Copy array address into rbx
	mov %rdi, %r12		#Copy instruction address into r12
	mov $0, %r13		#i=0
	mov $0, %r14		#k=0


	programLoop:
		movb (%r12, %r13), %al

		cmpb $62, %al	#if command == '>'
			je rightDashInstr

		cmpb $60, %al   #if command == '<'
			je leftDashInstr

		cmpb $43, %al   #if command == '+'
			je plusInstr

		cmpb $45, %al   #if command == '-'
			je minusInstr

		cmpb $46, %al   #if command == '.'
			je dotInstr

		cmpb $44, %al	#if command == ','
			je commaInstr

		cmpb $91, %al   #if command == '['
			je leftBracketInstr

		cmpb $93, %al	#if command == ']'
			je rightBracketInstr

		cmpb $0, %al	#if command is empty
			je end

		rightDashInstr:
			inc %r14	#k++
			inc %r13	#i++
			jmp programLoop

		leftDashInstr:
			dec %r14	#k--
			inc %r13	#i++
			jmp programLoop

		plusInstr:
			movq (%rbx, %r14, 8), %r15 	#r15 = array[k]
			incq %r15	           	#r15++
			movq %r15, (%rbx, %r14, 8) 	#array[k] = r15
			inc %r13		   	#i++
			jmp programLoop

		minusInstr:
			movq (%rbx, %r14, 8), %r15 	#r15 = array[k]
			decq %r15		   	#r15--
			movq %r15, (%rbx, %r14, 8) 	#array[k] = r15
			inc %r13		   	#i++
			jmp programLoop

		dotInstr:
			movq (%rbx, %r14, 8), %rdi	#Copy value of array[k] into rdi
			call putchar			#Display it
			inc %r13			#i++
			jmp programLoop			

		commaInstr:
			call getchar			#Get char into %rax
			movq %rax, (%rbx, %r14, 8)	#array[k] = %rax
			inc %r13			#i++
			jmp programLoop

		leftBracketInstr:
			cmp $0, (%rbx, %r14, 8)		#Continue only if array[k]==0
				jne leftBracketEnd

			mov $1, %r15			#Loop variable = 1

			leftBracketLoop:		#while loop > 0
				cmp $0, %r15
					jle leftBracketEnd

				inc %r13		#i++
				movb (%r12, %r13), %al	#Get next character
				cmpb $91, %al		#if next character == '['
					jne leftBracketNextCondition
				inc %r15		#loop++
				jmp leftBracketLoop

				leftBracketNextCondition:

				cmpb $93, %al		#if next character == ']'
					jne leftBracketLoop

				dec %r15		#loop--
				jmp leftBracketLoop
				
							
			

			leftBracketEnd:
			inc %r13			#i++
			jmp programLoop


		rightBracketInstr:
			cmp $0, (%rbx, %r14, 8)		#Continue only if array[k]!=0
				je rightBracketEnd

			mov $1, %r15			#loop variable = 1
			rightBracketLoop:
				cmp $0, %r15		#while loop > 0
					jle rightBracketEnd

				dec %r13		#i--
				movb (%r12, %r13), %al	#Get next character
				cmpb $91, %al		#if next character == '['
					jne rightBracketNextCondition

				dec %r15		#loop--
				jmp rightBracketLoop

				rightBracketNextCondition:

				cmpb $93, %al		#if next character == ']'
					jne rightBracketLoop

				inc %r15		#loop++
				jmp rightBracketLoop

			rightBracketEnd:
			inc %r13			#i++
			jmp programLoop


	end:

	pop %r15		#Pop values of all calee-saved regs
	pop %r14
	pop %r13
	pop %r12
	pop %rbx

	mov %rbp, %rsp		#Subroutine epilogue
	pop %rbp
	ret			#Subroutine return
