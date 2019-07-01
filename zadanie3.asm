.data
polynomialLevelExp: .asciiz "Enter polynomial level: "
xpart1_Exp: .asciiz "\nEnter coefficient of x^"
xpart2_Exp: .asciiz " term: "
resultExp: .asciiz "The result is:\n\n"

xSign: .asciiz "x"
powerSign: .asciiz "^"
addSign: .asciiz " + "
subSign: .asciiz " - "
mulSign: .asciiz "*"
equalsSign: .asciiz " = "

xCoefficent: .asciiz "\nEnter coefficient of x: "

WrongExp: .asciiz "\nThe expression is not a polynomial\n"

# t0 - zmienna pêtli nadrzêdnej
# t1 - zmienna pomocnicza
# t2 - zmienna pomocnicza
# t3 - wartoœæ x
# t4 - wynik cz¹stkowy
# t5 - wartoœæ pobrana ze stosu
# t6 - wynik ostateczny
# t9 - stopien wielomianu
# s0 - adres pocz¹tkowy stosu

.text

#############################################
Main:

la $a0, polynomialLevelExp
li $v0, 4
syscall

li $v0, 5
syscall

ble $v0, 1, Main

addi $t9, $v0, 0
addi $t0, $v0, 0
add $s0, $zero, $sp

addi $t2, $zero, 0

PolynomialLoop:

subi $t0, $t0, 1

jal EnterCoefficent

bnez $t0, PolynomialLoop

jal CheckExpression

jal EnterXCoefficent

j Compute


#############################################
EnterCoefficent:

la $a0, xpart1_Exp
li $v0, 4
syscall

addi $a0, $t0, 0
li, $v0, 1
syscall

la $a0, xpart2_Exp
li $v0, 4
syscall

li $v0, 5
syscall

addi $t1, $v0, 0

bnez $t1, continue	#je¿eli wpisujemy zero, to zwiêkszamy licznik zer w wielomianie

addi $t2, $t2, 1	

continue:

addi $sp, $sp, -4
sw $t1, 0($sp)

jr $ra

#############################################
EnterXCoefficent:

la $a0, xCoefficent
li $v0, 4
syscall

li $v0, 5
syscall

addi $t3, $v0, 0

jr $ra

#############################################
Compute:

add $sp, $s0, $zero
addi $t6, $zero, 0
subi $t0, $t9, 0

ComputeLoop:

subi $t0, $t0, 1

jal Power

addi $sp, $sp, -4
lw $t2, ($sp)

mul $t4, $t4, $t2
add $t6, $t6, $t4

bnez $t0, ComputeLoop

j Result

#############################################
Power:

addi $t1, $t0, 0
addi $t4, $zero, 1

blez $t1, Return

PowerLoop:

mul $t4, $t4, $t3

subi $t1, $t1, 1

bnez $t1, PowerLoop

Return:

jr $ra

#############################################
Result:

add $sp, $s0, $zero
add $t0, $t9, $zero

la $a0, resultExp
li $v0, 4
syscall

addi $s1, $sp, -4

ResultLoop:

addi $t0, $t0, -1

addi $sp, $sp, -4
lw $t5, 0($sp) 			#t5 - liczba pobrana ze stosu

beqz $t5, AZero 		#je¿eli pobrana ze stosu liczba = 0 to nie musimy z ni¹ nic robiæ

beq $sp, $s1, PositiveOnly	 #je¿eli jest to pierwsza wypisywana liczba

bgtz $t5, AdditionCase		#sprawdzamy czy liczba jest dodatnia, czy ujemna

la $a0, subSign
li $v0, 4
syscall

j WritePartOfResult

AdditionCase:

la $a0, addSign
li $v0, 4
syscall

WritePartOfResult:

bgtz $t5, PositiveOnly		#je¿eli liczba jest mniejsza ni¿ 0, to zamieniamy j¹ na liczbê dodatni¹

mul $t5, $t5, -1

PositiveOnly:

beqz $t0, writeAbsoluteTerm	# je¿eli jesteœmy w ostatniej iteracji, to wypisujemy wyraz wolny i wynik
beq $t5, 1, skipNumber		#je¿eli wspó³czynnik równy jest 1, to mo¿emy pomin¹æ jego wypisywanie

addi $a0, $t5, 0

li $v0, 1
syscall

skipNumber:

la $a0, xSign
li $v0, 4
syscall

beq $t0, 1, ResultLoop 		# je¿eli potêga jest równa 1, to nie wypisujemy jej

la $a0, powerSign
li $v0, 4
syscall

addi $a0, $t0, 0
li $v0, 1
syscall

j ResultLoop

writeAbsoluteTerm:

addi $a0, $t5, 0
li $v0, 1
syscall

endOfEquation:

la $a0, equalsSign
li $v0, 4
syscall

addi $a0, $t6, 0
li $v0, 1
syscall

li $v0, 10
syscall

AZero:

beqz $t0, endOfEquation		# je¿eli zerem jest wyraz wolny, to wypisujemy wynik

addi $s1, $s1, -4		# w innym przypadku zmniejszamy pozycjê S1, w razi gdyby okaza³o siê, ¿e jest to pierwsza wypisywana liczba

j ResultLoop


######################################
CheckExpression:

addi $t1, $t9, -2
add $sp, $s0, $zero

ble $t2, $t1 FinishCheck	#je¿eli liczba zer w wielomianie jest mniejsza lub równa równa stopniowi wielomianu - 2 to na pewno jest to wielomian
				# w innym przypadku s¹ tam dwa lub jeden wyraz, sprawdzamy czy nie zawiera on tylko wyrazu wolnego
addi $t1, $t1, 1

bgt $t2, $t1 Wrong		# je¿eli liczba zer w wielomianie jeest wiêksza ni¿ stopieñ wielomianu - 1, to na pewno nie ma tam ani jednego wyrazu, w innym przypadku jest tam
				# dok³adnie jeden wyraz
mul $t3, $t9, -4

add $sp, $sp, $t3
lw $t3, ($sp)

beqz $t3, FinishCheck		# je¿eli wyraz wolny = 0, to znaczy ¿e jest tam jeden inny wyraz, w innym przypadku jest to tylko wyraz wolny

Wrong:

la $a0, WrongExp
li $v0, 4
syscall

add $sp, $s0, $zero

j Main

FinishCheck:

jr $ra


