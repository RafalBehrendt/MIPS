.data 
	MatrixContainer: .space 880176
	.eqv DATA_SIZE 8
	#PositionOfPointerInMatrix: .word 0
	.eqv positionOfResultMatrix 800160
	NumberOfSavedMatrixes: .word 0
	TableOfPointers: .space 44
	DoubleMinus1: .double -1.0

numberOfMatrixesExp: .asciiz "How many matrixes would you like to save: "

numberOfMatrixesWrongExp: .asciiz "Wrong number of matrixes (min 0 max 10)\n"

rowsExp: .asciiz "Number of rows: "
colExp: .asciiz "Number of columns: "

spaceExp: .asciiz " "
newLine: .asciiz "\n"

errorExp: .asciiz "Given matrix does not exist\n"

nmbOfMatrixes: .asciiz "Number of saved matrixes: "
nmbOfMatrixesCnt: .asciiz "/10"

chooseOptionExp: .asciiz "Choose operation: "
saveMatrixExp: .asciiz "1. Add matrix\n"
printMatrixExp: .asciiz "2. Print chosen matrix\n"
addMatrixExp: .asciiz "3. Add two matrixes\n"
subMatrixExp: .asciiz "4. Substract two matrixes\n"
scalMatrixExp: .asciiz "5. Multiply matrixes by scalar\n"
transMatrixExp: .asciiz "6. Transposition of matrix\n"
mulMatrixExp: .asciiz "7. Multiply two matrixes\n"
detMatrixExp: .asciiz "8. Find determinant of matrix\n"
exitExp: .asciiz "0. Exit program\n"

idOfMatrixExp: .asciiz "Provide id of matrix (the order of entering): "
provScalarExp: .asciiz "Provide a scalar: "

TooManyMx: .asciiz "There is not enough space to add another matrix"

matrixesNotSame: .asciiz "Provided matrixes are not of the same size\n "

matrixesNotCorrect: .asciiz "Provided matrixes have wrong sizes\n "

matrixNotSquare: .asciiz "Provided matrix is not 3x3 square\n "

wrongSize: .asciiz "Wrong size!\n"



#######################################################
.macro empty_all_registers()

addi $t0, $zero, 0
addi $t1, $zero, 0
addi $t2, $zero, 0
addi $t3, $zero, 0
addi $t4, $zero, 0
addi $t5, $zero, 0
addi $t6, $zero, 0
addi $t7, $zero, 0
addi $t8, $zero, 0
addi $t9, $zero, 0

.end_macro



#######################################################
.macro empty_all_fpu()

add.d $f0, $f30, $f30
add.d $f2, $f30, $f30
add.d $f4, $f30, $f30
add.d $f6, $f30, $f30
add.d $f8, $f30, $f30
add.d $f10, $f30, $f30
add.d $f12, $f30, $f30

.end_macro

#######################################################
.macro save_matrix(%rows, %columns)

#t0 i t1 zarezerwowane
# f10 = 0.0

blez %rows, wrongSizeOfMatrix
bgt %rows, 100, wrongSizeOfMatrix

blez %columns, wrongSizeOfMatrix
bgt %columns, 100, wrongSizeOfMatrix

lw $t4, NumberOfSavedMatrixes

bge $t4, 10, TooManyMatrixes

bnez $t4, AddingMatrix

sw $t4, TableOfPointers($zero)

AddingMatrix:

mul $t4, $t4, 4
lw $t3, TableOfPointers($t4)
div $t4, $t4, 4

sw %rows, MatrixContainer($t3)
addi $t3, $t3, DATA_SIZE
sw %columns, MatrixContainer($t3)
addi $t3, $t3, DATA_SIZE

mul $t2, %rows, %columns
mul $t2, $t2, DATA_SIZE
add $t2, $t2, $t3

addi $t4, $t4, 1
sw $t4, NumberOfSavedMatrixes

bge $t4, 10, InsertionLoop

mul $t4, $t4, 4
sw $t2, TableOfPointers($t4)

InsertionLoop:

li $v0, 7
syscall

sdc1 $f0, MatrixContainer($t3)

addi $t3, $t3, DATA_SIZE

blt $t3, $t2, InsertionLoop

j endOfSaving

wrongSizeOfMatrix:

la $a0, wrongSize
li $v0, 4
syscall

j saveMatrixesLoop

TooManyMatrixes:

la $a0, TooManyMx
li $v0, 4
syscall

j menu

endOfSaving:


.end_macro

#######################################################
.macro does_exist(%index)

bltz %index, matrixDoesntExist

lw $s6, NumberOfSavedMatrixes

bne %index, 10, notAResultMatrix

addi $s4, $zero, positionOfResultMatrix
lw $s5, MatrixContainer($s4)

bgtz $s5, exists

j matrixDoesntExist

notAResultMatrix:

blt %index, $s6, exists

matrixDoesntExist:

la $a0, errorExp
li $v0, 4
syscall

j menu

exists:

.end_macro

#######################################################
.macro get_matrix_element(%row, %column, %index)

#t9 = index

addi $t9, %index, -1

#does_exist($t9)

mul $t9, $t9, 4

lw $t9, TableOfPointers($t9)

lw $t2, MatrixContainer($t9)
addi $t9, $t9, DATA_SIZE
lw $t1, MatrixContainer($t9)
addi $t9, $t9, DATA_SIZE

#mul $t3, $t1, $t2
#mul $t3, $t3, DATA_SIZE

add $t4, $zero, %column
mul $t4, $t4, DATA_SIZE

mul $t5, $t1, %row
mul $t5, $t5, DATA_SIZE

add $t5, $t5, $t9

add $t5, $t5, $t4

ldc1 $f2, MatrixContainer($t5)

.end_macro


#######################################################
.macro print_all_elements(%matrix)

addi $t9, %matrix, -1

does_exist($t9)

mul $t9, $t9, 4

lw $t9, TableOfPointers($t9)

la $a0, newLine
li $v0, 4
syscall

lw $t0, MatrixContainer($t9)
addi $t9, $t9, DATA_SIZE
lw $t1, MatrixContainer($t9)
addi $t9, $t9, DATA_SIZE

mul $t2, $t0, $t1
mul $t2, $t2, DATA_SIZE

MatrixPrintingLoop:

addi $t3, $t1, 0

MatrixPrintingInnerLoop:

ldc1 $f12, MatrixContainer($t9)
li $v0, 3
syscall

la $a0, spaceExp
li $v0, 4
syscall

addi $t9, $t9, DATA_SIZE
subi $t3, $t3, 1
subi $t2, $t2, DATA_SIZE

bnez $t3, MatrixPrintingInnerLoop

la $a0, newLine
li $v0, 4
syscall

bnez $t2, MatrixPrintingLoop

la $a0, newLine
li $v0, 4
syscall

.end_macro



#######################################################
.macro add_sub_matrixes(%matrix1, %matrix2, %subadd)
#t0 and t1 reserved

subi %matrix1, %matrix1, 1
subi %matrix2, %matrix2, 1

does_exist(%matrix1)
does_exist(%matrix2)

mul %matrix1, %matrix1, 4
mul %matrix2, %matrix2, 4

lw %matrix1, TableOfPointers(%matrix1)
lw %matrix2, TableOfPointers(%matrix2)

lw $t3, MatrixContainer(%matrix1)
lw $t4, MatrixContainer(%matrix2)

bne $t3, $t4, notSameMatrixes 

addi %matrix1, %matrix1, DATA_SIZE
addi %matrix2, %matrix2, DATA_SIZE

lw $t4, MatrixContainer(%matrix1)
lw $t5, MatrixContainer(%matrix2)

bne $t4, $t5, notSameMatrixes 

addi %matrix1, %matrix1, DATA_SIZE
addi %matrix2, %matrix2, DATA_SIZE

addi $t6, $zero, positionOfResultMatrix

mul $t5, $t3, $t4

sw $t3, MatrixContainer($t6)
addi $t6, $t6, DATA_SIZE
sw $t4, MatrixContainer($t6)
addi $t6, $t6, DATA_SIZE


AddMatrixesLoop:

ldc1 $f2, MatrixContainer(%matrix1)
ldc1 $f4, MatrixContainer(%matrix2)

addi $t8, $zero, %subadd

beq $t8, 1, addition

ldc1 $f8, DoubleMinus1
mul.d $f4, $f4, $f8

addition:

add.d $f6, $f2, $f4

sdc1 $f6, MatrixContainer($t6)

addi %matrix1, %matrix1, DATA_SIZE
addi %matrix2, %matrix2, DATA_SIZE
addi $t6, $t6, DATA_SIZE

subi $t5, $t5, 1

bnez $t5, AddMatrixesLoop


addi $t9, $zero, 11
print_all_elements($t9)
j menu

notSameMatrixes:

la $a0, matrixesNotSame
li $v0, 4
syscall

.end_macro

#######################################################
.macro scalar(%matrix1, %number)
#t0 and f4 reserved

subi %matrix1, %matrix1, 1

does_exist(%matrix1)

mul %matrix1, %matrix1, 4

lw %matrix1, TableOfPointers(%matrix1)

lw $t3, MatrixContainer(%matrix1)
addi %matrix1, %matrix1, DATA_SIZE
lw $t4, MatrixContainer(%matrix1)
addi %matrix1, %matrix1, DATA_SIZE

addi $t6, $zero, positionOfResultMatrix

mul $t5, $t3, $t4

sw $t3, MatrixContainer($t6)
addi $t6, $t6, DATA_SIZE
sw $t4, MatrixContainer($t6)
addi $t6, $t6, DATA_SIZE


MulLoop:

ldc1 $f2, MatrixContainer(%matrix1)

mul.d $f6, $f2, %number

sdc1 $f6, MatrixContainer($t6)

addi %matrix1, %matrix1, DATA_SIZE
addi $t6, $t6, DATA_SIZE

subi $t5, $t5, 1

bnez $t5, MulLoop


addi $t9, $zero, 11
print_all_elements($t9)
j menu

.end_macro

#######################################################
.macro trans(%matrix)
#t0 reserved

addi $t6, %matrix, 0

subi %matrix, %matrix, 1

does_exist(%matrix)

addi $t9, $t6, -1
mul %matrix, $t9, 4

lw $t8, TableOfPointers(%matrix)

lw $s1, MatrixContainer($t8)
addi $t8, $t8, DATA_SIZE
lw $s2, MatrixContainer($t8)
addi $t8, $t8, DATA_SIZE

addi $s4, $zero, positionOfResultMatrix

sw $s2, MatrixContainer($s4)
addi $s4, $s4, DATA_SIZE

sw $s1, MatrixContainer($s4)
addi $s4, $s4, DATA_SIZE

addi $s5, $zero, 0
addi $s6, $zero, 0

MatrixTransLoop:

get_matrix_element($s5, $s6, $t6) #stores in $f2
sdc1 $f2, MatrixContainer($s4)
addi $s4, $s4, DATA_SIZE

addi $s5, $s5, 1

blt $s5, $s1, MatrixTransLoop

addi $s5, $zero, 0
addi $s6, $s6, 1

blt $s6, $s2, MatrixTransLoop

addi $t9, $zero, 11

print_all_elements($t9)

.end_macro


#######################################################
.macro MatrixMultiplication(%matrix1, %matrix2)
#s3, s4 reserved

addi $t0, %matrix1, -1
addi $s2, %matrix2, -1

does_exist($t0)
does_exist($s2)

mul $t0, $t0, 4
mul $s2, $s2, 4

lw $t0, TableOfPointers($t0)
lw $s2, TableOfPointers($s2)


lw $s0, MatrixContainer($t0)
addi $t0, $t0, DATA_SIZE
lw $s1, MatrixContainer($t0)
addi $t0, $t0, DATA_SIZE

lw $s5, MatrixContainer($s2)
addi $s2, $s2, DATA_SIZE
lw $s6, MatrixContainer($s2)
addi $s2, $s2, DATA_SIZE

beq $s1, $s5, correctSizeOfMatrixes

la $a0, matrixesNotCorrect
li $v0, 4
syscall

j end

correctSizeOfMatrixes:

addi $t8, $zero, positionOfResultMatrix

sw $s0, MatrixContainer($t8)
addi $t8, $t8, DATA_SIZE
sw $s6, MatrixContainer($t8)
addi $t8, $t8, DATA_SIZE

addi $t6, $zero, 0
addi $t7, $zero, 0
sw $t8, ($sp)
addi $t8, $zero, 0


MulinMulLoop:

get_matrix_element($t8, $t7, %matrix2)

add.d $f4, $f2, $f4

get_matrix_element($t6, $t8, %matrix1)

mul.d $f4, $f4, $f2
add.d $f6, $f6, $f4

addi $t8, $t8, 1

add.d $f4, $f8, $f8

blt $t8, $s5, MulinMulLoop

lw $t8, ($sp)

sdc1 $f6, MatrixContainer($t8)
addi $t8, $t8, DATA_SIZE

add.d $f6, $f8, $f8
add.d $f4, $f8, $f8

sw $t8, ($sp)

addi $t8, $zero, 0
addi $t7, $t7, 1

blt $t7, $s6, MulinMulLoop

addi $t7, $zero, 0
addi $t6, $t6, 1

blt $t6, $s0, MulinMulLoop

addi $t9, $zero, 11

print_all_elements($t9)

end:

.end_macro


#######################################################
.macro MatrixDeterminant(%matrix)
#s5 reserved


addi $s5, %matrix, 0

subi %matrix, %matrix, 1

does_exist(%matrix)

mul %matrix, %matrix, 4

lw %matrix, TableOfPointers(%matrix)

lw $t0, MatrixContainer(%matrix)
addi %matrix, %matrix, DATA_SIZE
lw $t1, MatrixContainer(%matrix)
addi %matrix, %matrix, DATA_SIZE

bne $t0, $t1 mins
beq $t0, 3, matrixIsSquare

mins:

la $a0, matrixNotSquare
li $v0, 4
syscall

j menu

matrixIsSquare:

addi $t6, $zero, 0
addi $t7, $zero, 0
addi $t8, $zero, 0

ldc1 $f6, DoubleMinus1

mul.d $f4, $f6, $f6

j executeLoop1

determinantLoop1:

blt $t7, $t0, executeLoop1

add.d $f8, $f8, $f4
mul.d $f4, $f6, $f6

addi $t7, $zero, 0
addi $t8, $t8, 1
addi $t6, $t8, 0

beq $t8, $t0, finishLoop1

executeLoop1:

get_matrix_element($t6, $t7, $s5)

mul.d $f4, $f4, $f2

addi $t6, $t6, 1
addi $t7, $t7, 1

blt $t6, $t0, determinantLoop1

addi $t6, $zero, 0

j determinantLoop1


finishLoop1:

addi $t6, $zero, 0
subi $t7, $t0, 1
addi $t8, $zero, 0


determinantLoop2:

bgez $t7, executeLoop2

sub.d $f8, $f8, $f4
mul.d $f4, $f6, $f6

subi $t7, $t0, 1
addi $t8, $t8, 1
addi $t6, $t8, 0

beq $t8, $t0, showResult

executeLoop2:

get_matrix_element($t6, $t7, $s5)

mul.d $f4, $f4, $f2

addi $t6, $t6, 1
subi $t7, $t7, 1

blt $t6, $t0, determinantLoop2

addi $t6, $zero, 0

j determinantLoop2

showResult:

add.d $f12, $f8, $f10

li $v0, 3
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, newLine
li $v0, 4
syscall


.end_macro


#######################################################
.text

main:

addi $t0, $zero, 40
addi $t1, $zero, positionOfResultMatrix

sw $t1, TableOfPointers($t0)

menu:

empty_all_registers()

la $a0, newLine
li $v0, 4
syscall

la $a0, nmbOfMatrixes
li $v0, 4
syscall

lw $a0, NumberOfSavedMatrixes
li $v0, 1
syscall

la $a0, nmbOfMatrixesCnt
li $v0, 4
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, newLine
li $v0, 4
syscall

la $a0, saveMatrixExp
li $v0, 4
syscall

la $a0, printMatrixExp
li $v0, 4
syscall

la $a0, addMatrixExp
li $v0, 4
syscall

la $a0, subMatrixExp
li $v0, 4
syscall

la $a0, scalMatrixExp
li $v0, 4
syscall

la $a0, transMatrixExp
li $v0, 4
syscall

la $a0, mulMatrixExp
li $v0, 4
syscall

la $a0, detMatrixExp
li $v0, 4
syscall

la $a0, exitExp
li $v0, 4
syscall

la $a0, chooseOptionExp
li $v0, 4
syscall

li $v0, 5
syscall

beq $v0, 1, Save
beq $v0, 2, Print
beq $v0, 3, Add
beq $v0, 4, Sub
beq $v0, 5, Scal
beq $v0, 6, Trans
beq $v0, 7, Mul
beq $v0, 8, Det
bnez $v0, menu

li $v0, 10
syscall


#######################################################
Save:

la $a0, numberOfMatrixesExp
li $v0, 4
syscall

li $v0, 5
syscall

lw $t0, NumberOfSavedMatrixes
addi $t1, $zero, 10
sub $t0, $t1, $t0

bgt $v0, $t0, NumberOfMatrixesWrong

blez $v0, NumberOfMatrixesWrong

addi $t0, $zero, 0
addi $t1, $zero, 0

addi $t7, $v0, 0

saveMatrixesLoop:

la $a0, rowsExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $t0, $v0, 0

la $a0, colExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $t1, $v0, 0

save_matrix($t0, $t1)

subi $t7, $t7, 1

bnez $t7, saveMatrixesLoop

j menu

#######################################################
Print:

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

print_all_elements($v0)

j menu

#######################################################
Add:

jal Add_sub

empty_all_registers()

add_sub_matrixes($s0, $s1, 1)
j menu

#######################################################
Sub:

jal Add_sub

empty_all_registers()

add_sub_matrixes($s0, $s1, -1)
j menu

#######################################################
Add_sub:

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $s0, $v0, 0

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $s1, $v0, 0

jr $ra


#######################################################
Scal:

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $t0, $v0, 0

la $a0, provScalarExp
li $v0, 4
syscall

li $v0, 7
syscall

scalar($t0, $f0)

j menu


#######################################################
Trans:

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

trans($v0)

j menu


#######################################################
Mul:

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $s3, $v0, 0

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

addi $s4, $v0, 0

MatrixMultiplication($s3, $s4)

empty_all_fpu()

j menu


#######################################################
Det:

la $a0, idOfMatrixExp
li $v0, 4
syscall

li $v0, 5
syscall

MatrixDeterminant($v0)

empty_all_fpu()

j menu


#######################################################
NumberOfMatrixesWrong:

la $a0, numberOfMatrixesWrongExp
li $v0, 4
syscall

j menu


.kdata

OVERFLOW_EXCEPTION: 	.asciiz "===>      Arithmetic overflow       <===\n\n" 
UNHANDLED_EXCEPTION:	.asciiz "===>      Unhandled exception       <===\n\n"
ADDRESS_ERROR_EX:	.asciiz "===>      Address Error exception       <===\n\n"
SYSCALL_EXCEPTION:	.asciiz "===>      Syscall Exception       <===\n\n"
TRAP:	.asciiz "===>      Trap       <===\n\n"

.ktext 0x80000180

mfc0 $k0, $13   
andi $k1, $k0, 0x00007c  
srl  $k1, $k1, 2

beq $k1, 12, __overflow_exception
beq $k1, 4, __Address_Error_exception
beq $k1, 5, __Address_Error_exception
beq $k1, 8, __Syscall_Exception
beq $k1, 13, __Trap
	
la $a0, UNHANDLED_EXCEPTION
li $v0, 4
syscall
 
li $v0, 10
syscall
	
__overflow_exception:
	
la $a0, OVERFLOW_EXCEPTION
li $v0, 4
syscall
 
li $v0, 10
syscall

__Address_Error_exception:

la $a0, ADDRESS_ERROR_EX
li $v0, 4
syscall
 
li $v0, 10
syscall

__Syscall_Exception:

la $a0, SYSCALL_EXCEPTION
li $v0, 4
syscall

li $v0, 10
syscall

__Trap:

la $a0, TRAP
li $v0, 4
syscall
 
li $v0, 10
syscall

 	
