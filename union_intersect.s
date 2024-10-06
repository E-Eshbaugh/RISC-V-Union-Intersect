.data
	message1: .asciz "Enter the length of your first array: "
	message2: .asciz "Enter your numbers below:\n"
	message3: .asciz "Enter the length of your second array: "
	intersect_msg: .asciz "Intersection: ["
	union_msg: .asciz "\nUnion: ["
	comma: .asciz ", "
	right_bracket: .asciz "] "
	new_line: .asciz "\n"
.align 2
	temp: .space 80
	intersect_array: .space 80
	union_array: .space 80
.text
#get an int from user and store in a t array
.macro GET_INT %store_reg
	addi a7, zero, 4
	la a0, message2
	ecall
	
	addi a7, zero, 5
	ecall
	
	addi %store_reg, a0, 0
.end_macro

#macro for dynamically allocating an int array of size %length (stored in reg) and stores the address in %reg
.macro ALLOCATE_ARRAY %length %reg
	addi a7, zero, 9
	addi a0, zero, 4
	mul a0, a0, %length
	ecall
	addi %reg, a0, 0
.end_macro

main:
	la s3, union_array
	addi s3, s3, -8
	#---GET ARRAY1--#
	#print message1
	addi a7, zero, 4
	la a0, message1
	ecall
	 
	 #get array1 length
	 addi a7, zero, 5
	 ecall
	 addi s0, a0, 0
	 addi t0, a0, 0
	 
	 #allocate array1
	 ALLOCATE_ARRAY s0 s0
	 
	 #print message2 (get ints)
	 addi a7, zero, 4
	 la a0, message2
	 ecall
	 
	 #get ints for array1
	 addi t2, zero, 0
	 jal loop1

insert_point_1:
	addi t3, zero, 4
	mul t3, t3, t2
	sub s0, s0, t3
	 
	  #--GET ARRAY2--#
	 #messsage3 (array2 length)
	 addi a7, zero, 4
	 la a0, message3
	 ecall
	 
	 #get array2 length
	 addi a7, zero, 5
	 ecall
	 addi s1, a0, 0
	 addi t1, a0, 0
	 
	 #allocate array2
	 ALLOCATE_ARRAY s1 s1
	 
	 addi s1, s1, 20
	 
	 #print message2 (get ints)
	 addi a7, zero, 4
	 la a0, message2
	 ecall
	 
	 #get ints for array2
	 addi t2, zero, 0
	 jal loop2	

loop1:
	#if index >= array size, break
	bge t2, t0, insert_point_1
	
	#get next num
	addi a7, zero, 5
	ecall
	
	#offset
	addi t3, zero, 4
	mul t3, t2, t3
	sw a0, 0(s0)
	sw a0, 0(s3)
	addi s10 , s10, 1
	
	addi t2, t2, 1
	addi s0, s0, 4
	addi s3, s3, 4
	jal loop1

loop2:
	#if index >= array size, break
	bge t2, t1, insert_point_2
	
	#get next num
	addi a7, zero, 5
	ecall
	
	#offset
	addi t3, zero, 4
	mul t3, t2, t3
	sw a0, 0(s1)
	
	addi t2, t2, 1
	addi s1, s1, 4
	jal loop2

insert_point_2:
	addi t3, zero, 4
	mul t3, t3, t2
	sub s1, s1, t3
	
	addi t3, zero, 1
	addi t2, zero, 0
	la s4, temp

loop4:
	#t4 = 1 for changing number in temp
	bge t2, t0, end4
	lw t5, 0(s0)
	#a0 = int in array1 (index to change to 1 in temp)
	addi t4, zero, 4
	mul t5, t5, t4
	add s4, s4, t5
	#store 1 in temp at temp[a1]
	sw t3, 0(s4)
	#return temp pointer back to start
	la s4, temp
	#increment s0 pointer
	addi s0, s0, 4
	#increment counter
	addi t2, t2, 1
	
	#restart loop with next num in array1
	jal loop4
	
end4:
	#return s0 back to start
	mul t4, t4, t0
	sub s0, s0, t4
	
intersect:	
	#take 0(s1) and find the value at temp[0(s1)], if 1 -> add 0(s1) to intersect, else increment s1, reset temp to 0, repeat. Break when length of s1 (t1) < t2
	la s4, temp
	la s2, intersect_array
	addi t2, zero, 0
	#s11 = numer of values added to intersect 
	addi s11, zero, 0
	addi t3, zero, 4
	addi t6, zero, 1
loop5:
	bge t2, t1, end5 
	#load value from array2 > t4
	lw t4, 0(s1)
	mul t4, t3, t4
	#move temp poiter to index 4*t5
	add s4, s4, t4
	#load the value in temp into t5
	lw t5, 0(s4)
	#if its one, add 0(s1) to intersect
	beq t6, t5, add_to_intersect
	#else add to union
	lw t5, 0(s1)
	sw t5, 0(s3)
	addi s3, s3, 4
	addi s10 , s10, 1
return:
	#increment looper
	addi t2, t2, 1
	#increment array ptr
	addi s1, s1, 4
	#reset temp to statr
	la s4, temp
	
	jal loop5
add_to_intersect:
	#intersect array = s2
	#to add to intersect = 0(s1)
	addi s11, s11, 1
	lw t5, 0(s1)
	sw t5, 0(s2)
	addi s2, s2, 4
	
	jal return

end5:	
	#return s2 pointer to start
	addi t3, zero, 4
	mul t3, t3, s11
	sub s2, s2, t3
	
	#return s1 pointer to start
	addi t3, zero, 4
	mul t3, t3, t1
	sub s1, s1, t3
	
	#print intersect
	addi a7, zero, 4
	la a0, intersect_msg
	ecall
	
	addi t2, zero, 0
print_intersect:
	bge t2, s11, end_p_intersect
	#print value at intersect[i]
	addi a7, zero, 1
	lw a0, 0(s2)
	ecall
	
	#print comma if not last number
	addi t2, t2, 1
	bge t2, s11, end_p_intersect
	addi a7, zero, 4
	la a0, comma
	ecall
	
	#increment array index
	addi s2, s2, 4
	
	jal print_intersect
	
	
end_p_intersect:
	#print right bracket
	addi a7, zero, 4
	la a0, right_bracket
	ecall

union:
	addi t2, zero, 0
	addi t3, zero, 4
	mul t3, t3, s10
	sub s3, s3, t3
	
	addi a7, zero, 4
	la a0, union_msg
	ecall
	
	beq s10, zero, end_p_union
print_union:
	bge t2, s10, end_p_intersect
	#print value at intersect[i]
	addi a7, zero, 1
	lw a0, 0(s3)
	ecall
	
	#print comma if not last number
	addi t2, t2, 1
	bge t2, s10, end_p_union
	addi a7, zero, 4
	la a0, comma
	ecall
	
	#increment array index
	addi s3, s3, 4
	
	jal print_union

end_p_union:
	#print right bracket
	addi a7, zero, 4
	la a0, right_bracket
	ecall
	
	#ending newling
	addi a7, zero, 4
	la a0, new_line
	ecall
	 
exit:
	addi a7, zero, 10
	ecall
	 
