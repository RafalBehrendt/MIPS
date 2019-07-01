.data
selectExp: .asciiz "Select operation: "
addExp: .asciiz "\n1. Add"
subExp: .asciiz "\n2. Substract"
mulExp: .asciiz "\n3. Multiply"
divExp: .asciiz "\n4. Divide"

choiceExp: .asciiz "\nChoice: "

firstExp: .asciiz "Enter first number: "
secondExp: .asciiz "Enter second number: "

resultExp: .asciiz "Result: "

divBy0: .asciiz "It is not allowed to divide by 0\n"

.text

main:

la $a0, selectExp
li $v0, 4
syscall

la $a0, addExp
li $v0, 4
syscall

la $a0, subExp
li $v0, 4
syscall

la $a0, mulExp
li $v0, 4
syscall

la $a0, divExp
li $v0, 4
syscall

la $a0, choiceExp
li $v0, 4
syscall

li $v0, 5
syscall

beq $v0, 1, Addition
beq $v0, 2, Substraction
beq $v0, 3, Multiplication
beq $v0, 4, Division


li $v0, 10
syscall

#######################################################
Addition:

jal PickNumbers

add $t2, $t1, $t0

j ShowResult

########################################################
Substraction:

jal PickNumbers

sub $t2, $t1, $t0

j ShowResult

########################################################
Multiplication:

jal PickNumbers

mul $t2, $t1, $t0

j ShowResult

########################################################
Division:

jal PickNumbers

beq $t1, $zero, next 
div $t2, $t0, $t1
j ShowResult

next:

la $a0, divBy0
li $v0, 4
syscall

j Division


#########################################################
ShowResult:

la $a0, resultExp
li $v0, 4
syscall

addi $a0, $t2, 0
li $v0, 1
syscall

li $v0, 10
syscall

#########################################################
PickNumbers:

la $a0, firstExp
li $v0, 4

syscall

li $v0, 5
syscall

addi $t0, $v0, 0

la $a0, secondExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $t1, $v0, 0

jr $ra	
