.data
s: .space 100           # String input (up to 100 characters)
b1: .word 0             # Base `b1`
b2: .word 0             # Base `b2`
res: .word 0            # Result of conversion to decimal
newline: .asciiz "\n"   # Newline character
prompt_number: .asciiz "Enter your number: "  # Prompt for the number
prompt_base: .asciiz "Enter the current base: " # Prompt for base
prompt_new_base: .asciiz "Enter the new base: " # Prompt for new base
result_msg: .asciiz "The number in the new base: "
buffer: .space 33       # Buffer for converted number

.text
.globl main

main:
    # Print prompt for number
    li $v0, 4
    la $a0, prompt_number
    syscall

    # Read string input
    li $v0, 8
    la $a0, s
    li $a1, 32
    syscall

    # Print prompt for base
    li $v0, 4
    la $a0, prompt_base
    syscall

    # Read base `b1`
    li $v0, 5
    syscall
    sw $v0, b1

    # Validate the input number
    la $a0, s
    lw $a1, b1
    jal isValid
    beqz $v0, invalid_input

    # Convert to decimal
    la $a0, s
    lw $a1, b1
    jal otherToDec
    sw $v0, res

    # Print prompt for new base
    li $v0, 4
    la $a0, prompt_new_base
    syscall

    # Read base `b2`
    li $v0, 5
    syscall
    sw $v0, b2

    # Convert decimal to new base
    lw $a0, res
    lw $a1, b2
    la $a2, buffer
    jal decimal_to_other

    # Print result message
    li $v0, 4
    la $a0, result_msg
    syscall

    # Print the converted number
    li $v0, 4
    la $a0, buffer
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Exit program
    li $v0, 10
    syscall

invalid_input:
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 10
    syscall

# Function: otherToDec
# Arguments: $a0 = address of string, $a1 = base
# Returns: $v0 = result in decimal
otherToDec:
    li $v0, 0
    li $t0, 0

convert_loop:
    lb $t1, 0($a0)
    beq $t1, 10, end_loop

    li $t2, 'A'
    li $t3, 'Z'
    bge $t1, $t2, check_upper_bound  # If s[i] >= 'A', check upper bound
    j process_digit                  # Otherwise, process as a digit
 
    j multiply_accumulate	 # Proceed to multiplication and accumulation
 
 
check_upper_bound:
    ble $t1, $t3, handle_alpha       # If s[i] <= 'Z', handle as alpha
    j process_digit                  # Otherwise, process as a digit
 
handle_alpha:
    li $t4, '9'         # Offset for '9'
    sub $t1, $t1, $t2   # s[i] - 'A'
    addi $t1, $t1, 1    # + 1
    add $t1, $t1, $t4   # '9' + (s[i] - 'A' + 1)
 
 
process_digit:
    sub $t1, $t1, '0'   # Convert character to numeric value
 
multiply_accumulate:
    mul $v0, $v0, $a1   # res = res * base
    add $v0, $v0, $t1   # res += s[i]
 
    addi $a0, $a0, 1    # Move to next character
    j convert_loop

end_loop:
    jr $ra

# Function: isValid
# Inputs: $a0 = address of string, $a1 = base
# Output: $v0 = 1 (valid), 0 (invalid)
isValid:
    move $t0, $a0
    move $t1, $a1
    li $t2, 0

validate_loop:
    lb $t3, 0($t0)
    beq $t3, 10, end_check

    blt $t3, '0', alpha_check
    ble $t3, '9', digit_check

alpha_check:
    blt $t3, 'A', invalid_character
    ble $t3, 'Z', uppercase_check

    blt $t3, 'a', invalid_character
    ble $t3, 'z', lowercase_check
    b invalid_character

uppercase_check:
    sub $t4, $t3, 'A'
    addi $t4, $t4, 10
    b validate_base

lowercase_check:
    sub $t4, $t3, 'a'
    addi $t4, $t4, 10
    b validate_base

digit_check:
    sub $t4, $t3, '0'
    b validate_base

validate_base:
    blt $t4, $t1, continue_loop
    b invalid_character

continue_loop:
    addi $t0, $t0, 1
    j validate_loop

invalid_character:
    li $t2, 1
    j end_check

end_check:
    move $v0, $t2
    xori $v0, $v0, 1
    jr $ra

# Function: decimal_to_other
# Arguments: $a0 = decimal number, $a1 = base, $a2 = buffer
decimal_to_other:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    move $t0, $a0
    move $t1, $a1
    move $t2, $a2

    beq $t0, $zero, handle_zero

    li $t3, 0

conversion_loop:
    beq $t0, 0, end_conversion

    div $t0, $t1
    mfhi $t4

    addi $sp, $sp, -4
    sw $t4, 0($sp)

    addi $t3, $t3, 1

    mflo $t0
    j conversion_loop

handle_zero:
    li $t6, 48
    sb $t6, buffer($zero)
    j end_decimal_to_other

end_conversion:
    move $t5, $zero
    sub $t3, $t3, 1

retrieve_loop:
    blt $t3, 0, end_retrieve

    lw $t6, 0($sp)
    addi $sp, $sp, 4

    slti $t7, $t6, 10
    beq $t7, 1, is_digit

    addi $t6, $t6, 55
    j store_char

is_digit:
    addi $t6, $t6, 48

store_char:
    sb $t6, buffer($t5)
    addi $t5, $t5, 1
    addi $t3, $t3, -1
    j retrieve_loop

end_retrieve:
    sb $zero, buffer($t5)

end_decimal_to_other:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
