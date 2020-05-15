# File Name: connect4.asm
#
# Author: Joshua McFadden
#
# Description:
#
#
#
#

#
# Name: Constant definitions
#
# Description:	These consts define values used for system calls,
#					and some other misc values
#

# Constants for system calls and other things

PRINT_INT		= 1		# code for syscall to print an int
PRINT_STRING	= 4		# code for syscall to print a string
READ_INT		= 5		# code for syscall to read an int
A_FRAMESIZE		= 48	# Stack size


#
# Name: Data Area
#
# Description:	A large prtion of the data for the program is stored here
#					each area or item has a specific lable attached to it.
#					For many in this area they are strings to be printed
#					just by loading it as some may need to be called multiple
#					times. There are ints stored here and those are explained
#					below.

.data
.align 2

#------------Welcome Message------------#
welcome:
.ascii "   ************************\n"
.ascii "   **    Connect Four    **\n"
.asciiz "   ************************\n\n"

#-------------Initial Board-------------#
board:
.ascii  "   0   1   2   3   4   5   6\n"
.ascii  "+-----------------------------+\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "||   |   |   |   |   |   |   ||\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "||   |   |   |   |   |   |   ||\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "||   |   |   |   |   |   |   ||\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "||   |   |   |   |   |   |   ||\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "||   |   |   |   |   |   |   ||\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "||   |   |   |   |   |   |   ||\n"
.ascii  "|+---+---+---+---+---+---+---+|\n"
.ascii  "+-----------------------------+\n"
.asciiz "   0   1   2   3   4   5   6"

space:
.asciiz "\n"

#-----------Player 1 Movemen--t---------#
player1:
.asciiz "Player 1: select a row to place your coin (0-6 or -1 to quit):"

#-----------Player 2 Movement-----------#
player2:
.asciiz "Player 2: select a row to place your coin (0-6 or -1 to quit):"

#----------------Token------------------#
token_1:
.ascii "X"

token_2:
.ascii "O"

token_3:
.ascii " "

#------------Illegal Movement-----------#
illegal_num:
.asciiz "Illegal column number."
illegal_total:
.asciiz "Illegal move, no more room in that column."

#----------------Victory----------------#
victory_1:
.asciiz "\nPlayer 1 wins!\n"
victory_2:
.asciiz "\nPlayer 2 wins!\n"
victory_t:
.asciiz "\nThe game ends in a tie.\n"

#----------------Exit-------------------#
quit_1:
.asciiz "Player 1 quit.\n"
quit_2:
.asciiz "Player 2 quit.\n"

#----------------Place------------------#
# These are the locations in memeory where
#	each row and column starts. To find a
#	specific row you multiply the input by 4
#	and add it to the location in memeory of
#	the row label. Simmiar thing is done for 
#	the columns, each is the start of the line.

.align 2

column:
.word 4, 8, 12, 16, 20, 24, 28
row:
.word 412, 348, 284, 220, 156, 92
loop_count:
.word 4, 5, 6, 6, 5, 4

.text

# End of general values that need to be used. Beginning of code.


#
# Name:		Main
#
# Description:
#

main:

	li	$v0, PRINT_STRING		# Prints the welcoming message to the user
	la	$a0, welcome
	syscall

	li	$v0, PRINT_STRING		# Prints a clean board to the user
	la	$a0, board
	syscall

	li	$v0, PRINT_STRING
	la	$a0, space
	syscall

game_loop:

	li	$a1, 1					# Set player 1
	jal	input					# Get player 1's input

	li	$a1, 1					# Make sure a1 is still 1
	jal	win_h					# Check win for horizontal
	li	$a1, 1
	jal	win_v					# Check win for vertical
	li	$a1, 1
	jal win_d					# Check win for diagonal
	li	$a1, 1
	jal	win_t

	li	$a1, 2					# Set player 2
	jal	input					# Get player2's input

	li	$a1, 2					# See above
	jal	win_h
	li	$a1, 2
	jal	win_v
	li	$a1, 2
	jal	win_d
	li	$a1, 2
	jal	win_t

	j	game_loop				# Loop until user quits or wins

	j	exit					# just incase


#
# Name: exit
#
# Description: Closes the program
#

exit:

	li	$v0, 10
	syscall


#
# Name:		input
#
# Description: This takes the input from the players as well as checking user
#					input. It calls top_error to check the top row. It also
#					upadtes the baord bassed off of user input.
#

input:
#
# Save registers ra and s0 - s7 on the stack.
#
	li	$t0, -A_FRAMESIZE
    add $sp, $sp, $t0
    sw  $ra, -4+A_FRAMESIZE($sp)
    sw  $s7, 40($sp)
    sw  $s6, 36($sp)
    sw  $s5, 32($sp)
    sw  $a0, 28($sp)
    sw  $a1, 24($sp)
    sw  $a2, 20($sp)
    sw  $s4, 16($sp)
    sw  $s3, 12($sp)
	sw  $s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)


	move $s7, $a1				# User provides what player is being used
								# 1 == Player 1 2 == Player 2

input_restart:					# This is here becasue I don't want that^ to
								# change. Because the register are restored s7
								# should return to its state

	li	$t0, 2
	beq	$s7, $t0, input_2

input_1:

	li	$v0, PRINT_STRING
	la	$a0, space
	syscall

	li	$v0, PRINT_STRING		# Prints Player 1's select 
	la	$a0, player1
	syscall

	la	$t0, token_1			# Sets the player's token
	lb	$s6, 0($t0)

	j	read_in

input_2:

	li	$v0, PRINT_STRING
	la	$a0, space
	syscall

	li	$v0, PRINT_STRING		# Prints Player 2's select
	la	$a0, player2
	syscall

	la	$t0, token_2			# Sets the players token
	lb	$s6, 0($t0)

read_in:

	li	$v0, READ_INT			# Get the users input
	syscall

	move $s0, $v0				# Save user input

	move $s1, $zero				# Gets the left most spot to test
	li	$s3, -1
	li	$s2, 7					# Farthest edge of game	+1 to make sure that it
								#	is on the board 6 < 7 retruns true

	slt	$t0, $s0, $s1			# if negative then its a 1. 0 if greater than 0
	slt	$t1, $s0, $s2			# if less than 7 then a 1. 0 if greater than 7

	move $a0, $s7

	beq	$s0, $s3, exit_quit			# -1 detected. Go to exit statement.
	bne	$t0, $zero, error_in	# if negative go to error
	beq	$t1, $zero, error_in	# if 7 or larger go to error

	move $a0, $s0				# Clears this check. Now it has to check the
	li	$a1, 1					#	top row to make sure that it can palce a
	jal top_error				#	token there.

								# Legal move now change token

	mul $t1, $s0, 4				# s0 is the user input Mul it by word = 4 bits
	la	$t0, column				# Find the column possiton on the board
	add	$t0, $t1, $t0
	lw	$s1, 0($t0)

	la	$t0, token_3			# Sets s2 to be " " to find the first empty
	lb	$s2, 0($t0)				#	space in that column

	move $s3, $zero				# a counter

loop_in:

	mul	$t1, $s3, 4
	la	$t0, row				# Gets the right row starting possition
	add	$t0, $t0, $t1
	lw	$s4, 0($t0)

	add	$s5, $s1, $s4			# Shift over on the row to the correct column

	la	$t0, board				# Loads the space on the board.
	add	$t0, $t0, $s5
	lb	$s4, 0($t0)

	beq	$s4, $s2, done_in		# If the board space == " " then we can adjust
								#	the token.

	li	$t0, 1
	add	$s3, $s3, $t0			# increment the counter

	j	loop_in					# loop.

error_in:

	li	$v0, PRINT_STRING		# Prints the illegal movement 
	la	$a0, illegal_num
	syscall

	j input_restart

done_in:						# Token space has been found
								# s6 is the players token set from above
								# s5 is the bords place to change in memory

	la	$t0, board
	add	$t0, $t0, $s5			# Get the memory address

	sb	$s6, 0($t0)				# Store the token in memory

	li	$v0, PRINT_STRING
	la	$a0, space
	syscall

	li	$v0, PRINT_STRING
	la	$a0, board
	syscall

	li	$v0, PRINT_STRING
	la	$a0, space
	syscall

#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	jr	$ra

#
# Name:		top error check
#
# Description:	This function checks to make sure that there are no tokens in
#				the top column of a given row. If there is one it will propt
#				the user to input a new number.
#

top_error:

#
# Save registers ra and s0 - s7 on the stack.
#
	li	$t0, -A_FRAMESIZE
    add $sp, $sp, $t0
    sw  $ra, -4+A_FRAMESIZE($sp)
    sw  $s7, 40($sp)
    sw  $s6, 36($sp)
    sw  $s5, 32($sp)
    sw  $a0, 28($sp)
    sw  $a1, 24($sp)
    sw  $a2, 20($sp)
    sw  $s4, 16($sp)
    sw  $s3, 12($sp)
	sw  $s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)


	#if top column == " " then continue else error

	move $s0, $a0				# Moves the column into a useable register

	la	$t0, column
	mul	$t1, $s0, 4
	add	$t0, $t0, $t1
	lw	$s1, 0($t0)				# Load column possiton in the table

	li	$t1, 20
	la	$t0, row				# Load the top row
	add	$t0, $t0, $t1
	lw	$s2, 0($t0)

	add	$s1, $s1, $s2			# Gets the char space for the top pos of the
								# column

	la	$t1, token_3
	lb	$s3, 0($t1)				# Set s3 to be a " "

	la	$t0, board
	add	$t0, $t0, $s1
	lb	$s5, 0($t0)				# Load the char on the board.

	bne	$s5, $s3, error2		# If it doesn't equal a " " then branch

#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	jr	$ra						# No problem found continue.

error2:

#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	li	$v0, PRINT_STRING		# Prints the error
	la	$a0, illegal_total
	syscall

	j	input_restart

#
# Name:		Win Horizontal
#
# Description:	This is a test that after a player inputs their column to test
#					for a win horizontally.
#

win_h:

#
# Save registers ra and s0 - s7 on the stack.
#
	li	$t0, -A_FRAMESIZE
    add $sp, $sp, $t0
    sw  $ra, -4+A_FRAMESIZE($sp)
    sw  $s7, 40($sp)
    sw  $s6, 36($sp)
    sw  $s5, 32($sp)
    sw  $a0, 28($sp)
    sw  $a1, 24($sp)
    sw  $a2, 20($sp)
    sw  $s4, 16($sp)
    sw  $s3, 12($sp)
	sw  $s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	# if counter of players token == 4 in a row then win

	move $s7, $a1					# Stores what player to check

	li	$t0, 2
	beq	$t0, $s7, win_h_2			# Figures out what token to load

win_h_1:

	la	$t0, token_1				# Loads player 1's token
	lb	$s0, 0($t0)

	j	win_h_test

win_h_2:

	la	$t0, token_2				# Loads player 2's token
	lb	$s0, 0($t0)

win_h_test:

	move $s1, $zero					# Counter for X token in a row
	move $s2, $zero					# Counter for column
	move $s3, $zero					# Counter for row

	li	$s4, 96						# gets the top left corner of the board

loop_h:

	li	$t0, 4
	beq	$t0, $s1, win_h_win

	li	$t0, 6
	beq	$t0, $s3, win_h_exit		# out of rows

	li	$t0, 7
	bne	$t0, $s2, loop_h_cont		# move to next row

	li	$t0, 1
	add	$s3, $s3, $t0				# increment to row count

	li	$t0, 36
	add	$s4, $s4, $t0				# go to next row start
	move $s2, $zero

loop_h_cont:

	move $s6, $zero

	la	$t0, board
	add	$t0, $t0, $s4				# get the token pos on the board
	lb	$s6, 0($t0)

	bne	$s0, $s6, loop_h_clear		# if not equal move on

	li	$t0, 1
	add	$s1, $s1, $t0				# found an equal so increment by 1

	j	loop_h_end

loop_h_clear:

	move $s1, $zero					# clear the counter

loop_h_end:

	li	$t0, 1
	add $s2, $s2, $t0				# increment the column

	li	$t0, 4
	add $s4, $s4, $t0				# move the counter over

	j	loop_h						# go back to start


#token for player is in s0, player number is in s7

win_h_win:

	li	$t0, 1
	beq	$t0, $s7, win_1
	j	win_2


win_h_exit:							# no horizontal win
#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	jr	$ra

#
# Name:		Win vertical
#
# Description:	This test to see that after a user inputs their data if they
#					win vertically.
#

win_v:

#
# Save registers ra and s0 - s7 on the stack.
#
	li	$t0, -A_FRAMESIZE
    add $sp, $sp, $t0
    sw  $ra, -4+A_FRAMESIZE($sp)
    sw  $s7, 40($sp)
    sw  $s6, 36($sp)
    sw  $s5, 32($sp)
    sw  $a0, 28($sp)
    sw  $a1, 24($sp)
    sw  $a2, 20($sp)
    sw  $s4, 16($sp)
    sw  $s3, 12($sp)
	sw  $s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	# if counter of players token == 4 in a row then win

	move $s7, $a1					# Stores what player to check

	li	$t0, 2
	beq	$t0, $s7, win_v_2			# Figures out what token to load

win_v_1:

	la	$t0, token_1				# Loads player 1's token
	lb	$s0, 0($t0)

	j	win_v_test

win_v_2:

	la	$t0, token_2				# Loads player 2's token
	lb	$s0, 0($t0)

win_v_test:

	move $s1, $zero					# Counter for X token in a row
	move $s2, $zero					# Counter for column
	move $s3, $zero					# Counter for row

	la	$t0, row
	la	$t1, column
	lw	$t0, 0($t0)
	lw	$t1, 0($t1)
	add	$s4, $t0, $t1				# gets the top left corner of the board

loop_v:

	li	$t0, 4
	beq	$t0, $s1, win_v_win			# player wins found 4

	li	$t0, 7
	beq	$t0, $s2, win_v_exit		# out of columns

	li	$t0, 6
	bne	$t0, $s3, loop_v_cont		# move to next row

	li	$t0, 1
	add	$s2, $s2, $t0				# increment to column count

	li	$s4, 92
	li	$t1, 4
	mul	$t1, $t1, $s2
	add	$s4, $s4, $t1				# go to next column start

	move $s3, $zero

loop_v_cont:

	move $s6, $zero

	la	$t0, board
	add	$t0, $t0, $s4				# get the token pos on the board
	lb	$s6, 0($t0)

	bne	$s0, $s6, loop_v_clear		# if not equal move on

	li	$t0, 1
	add	$s1, $s1, $t0				# found an equal so increment by 1

	j	loop_v_end

loop_v_clear:

	move $s1, $zero					# clear the counter

loop_v_end:

	li	$t0, 1
	add $s3, $s3, $t0				# increment the row

	li	$t0, 64
	add $s4, $s4, $t0				# move the counter down

	j	loop_v						# go back to start


#token for player is in s0, player number is in s7

win_v_win:

	li	$t0, 1
	beq	$t0, $s7, win_1
	j	win_2

win_v_exit:

#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	jr	$ra

#
# Name:		Win Diagonal test
#
# Description:	This will check all available places for a diagaonal win
#					It starts off with going down to the right then down to
#					the left.
#

win_d:

#
# Save registers ra and s0 - s7 on the stack.
#
	li	$t0, -A_FRAMESIZE
    add $sp, $sp, $t0
    sw  $ra, -4+A_FRAMESIZE($sp)
    sw  $s7, 40($sp)
    sw  $s6, 36($sp)
    sw  $s5, 32($sp)
    sw  $a0, 28($sp)
    sw  $a1, 24($sp)
    sw  $a2, 20($sp)
    sw  $s4, 16($sp)
    sw  $s3, 12($sp)
	sw  $s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)

	# do
	# if counter of players token == 4 in a row then win

	move $s7, $a1					# Stores what player to check

	li	$t0, 2
	beq	$t0, $s7, win_d_2			# Figures out what token to load

win_d_1:

	la	$t0, token_1				# Loads player 1's token
	lb	$s0, 0($t0)

	j	win_d_test

win_d_2:

	la	$t0, token_2				# Loads player 2's token
	lb	$s0, 0($t0)

win_d_test:

	move $s1, $zero					# Counter for X token in a row
	move $s2, $zero					# Counter for looping
	move $s3, $zero					# poss in the count loop

win_d_move_0:

	li	$t0, 0
	bne	$t0, $s3, win_d_move_1		# if the diagonal count is this

	la	$t0, loop_count
	lw	$s5, 0($t0)					# Gets how many times to loop

	li	$s1, 0						# reset counters
	li	$s2, 0
	li	$s4, 224					# get the starting poss
	li	$t0, 1
	add	$s3, $s3, $t0				# increment the count to move onto the
									# the next one. This is used as a test case

	j	loop_d

win_d_move_1:

	li	$t0, 1
	bne	$t0, $s3, win_d_move_2

	la	$t0, loop_count				# Gets how many times to loop
	lw	$s5, 4($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 160
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d

win_d_move_2:

	li	$t0, 2
	bne	$t0, $s3, win_d_move_3

	la	$t0, loop_count
	lw	$s5, 8($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 96
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d 

win_d_move_3:

	li	$t0, 3
	bne	$t0, $s3, win_d_move_4

	la	$t0, loop_count
	lw	$s5, 12($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 100
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d 

win_d_move_4:

	li	$t0, 4
	bne	$t0, $s3, win_d_move_5

	la	$t0, loop_count
	lw	$s5, 12($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 104
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d 

win_d_move_5:

	li	$t0, 5
	bne	$t0, $s3, win_d_test_2

	la	$t0, loop_count
	lw	$s5, 16($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 108
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d

# s0 == player token
# s1 == how many tokens of the same in a row
# s2 == how many loops made
# s4 == starting poss
# s5 == how many loops needed
# s7 == player num

loop_d:

	li	$t0, 4
	beq	$s1, $t0, win_d_win				# test to see if we win

	beq	$s2, $s5, win_d_move_1			# cant go any farther

	la	$t0, board
	add	$t0, $s4, $t0
	lb	$t0, 0($t0)						# load the board

	bne	$t0, $s0, loop_d_skip			# tokens not the same skip ++

	li	$t0, 1
	add	$s1, $s1, $t0					# found one so ++

	j	loop_d_cont

loop_d_skip:

	move $s1, $zero						# reset
	

loop_d_cont:

	li	$t0, 1
	add	$s2, $s2, $t0					# increment the loop count

	li	$t0, 68							# move to the next spot
	add	$s4, $s4, $t0

	j	loop_d

win_d_test_2:

	move $s1, $zero					# Counter for X token in a row
	move $s2, $zero					# Counter for looping
	move $s3, $zero					# poss in the count loop

win_d_move_6:

	li	$t0, 0
	bne	$t0, $s3, win_d_move_7		# if the diagonal count is this

	la	$t0, loop_count
	lw	$s5, 0($t0)					# Gets how many times to loop

	li	$s1, 0						# reset counters
	li	$s2, 0
	li	$s4, 248					# get the starting poss
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d_2

win_d_move_7:

	li	$t0, 1
	bne	$t0, $s3, win_d_move_8

	la	$t0, loop_count				# Gets how many times to loop
	lw	$s5, 4($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 184
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d_2

win_d_move_8:

	li	$t0, 2
	bne	$t0, $s3, win_d_move_9

	la	$t0, loop_count
	lw	$s5, 8($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 120
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d_2

win_d_move_9:

	li	$t0, 3
	bne	$t0, $s3, win_d_move_10

	la	$t0, loop_count
	lw	$s5, 12($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 116
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d_2

win_d_move_10:

	li	$t0, 4
	bne	$t0, $s3, win_d_move_11

	la	$t0, loop_count
	lw	$s5, 12($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 112
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d_2

win_d_move_11:

	li	$t0, 5
	bne	$t0, $s3, win_d_exit

	la	$t0, loop_count
	lw	$s5, 16($t0)

	li	$s1, 0
	li	$s2, 0
	li	$s4, 108
	li	$t0, 1
	add	$s3, $s3, $t0

	j	loop_d_2

# s0 == player token
# s1 == how many tokens of the same in a row
# s2 == how many loops made
# s4 == starting poss
# s5 == how many loops needed
# s7 == player num

loop_d_2:

	li	$t0, 4
	beq	$s1, $t0, win_d_win				# test to see if we win

	beq	$s2, $s5, win_d_move_6			# cant go any farther

	la	$t0, board
	add	$t0, $s4, $t0
	lb	$t0, 0($t0)						# load the board

	bne	$t0, $s0, loop_d_skip_2			# tokens not the same skip ++

	li	$t0, 1
	add	$s1, $s1, $t0					# found one so ++

	j	loop_d_cont_2

loop_d_skip_2:

	move $s1, $zero						# reset
	

loop_d_cont_2:

	li	$t0, 1
	add	$s2, $s2, $t0					# increment the loop count

	li	$t0, 60							# move to the next spot
	add	$s4, $s4, $t0

	j	loop_d_2


win_d_exit:							# no diagonal win
#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	jr	$ra

win_d_win:

	li	$t0, 1
	beq	$t0, $s7, win_1
	j	win_2

#
# Name:		Wint Tie test
#
# Description:		This is the test to see if there was a tie game made
#
#

win_t:

#
# Save registers ra and s0 - s7 on the stack.
#
	li	$t0, -A_FRAMESIZE
    add $sp, $sp, $t0
    sw  $ra, -4+A_FRAMESIZE($sp)
    sw  $s7, 40($sp)
    sw  $s6, 36($sp)
    sw  $s5, 32($sp)
    sw  $a0, 28($sp)
    sw  $a1, 24($sp)
    sw  $a2, 20($sp)
    sw  $s4, 16($sp)
    sw  $s3, 12($sp)
	sw  $s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)



	la	$s3, token_3
	lb	$s3, 0($s3)

	la	$t0, row					# load all the correct spots
	lw	$s1, 20($t0)
	li	$s2, 4
	add	$s1, $s1, $s2
	li	$s4, 124


# s2 == current space on the board
# s3 == token to break on
# s4 == the break point

loop_t:

	beq	$s2, $s4, win_t_print		# if the counter goes beyone the last
									# line break bc there is a tie game

	la	$t0, board
	add	$t0, $t0, $s2
	lb	$t0, 0($t0)

	bne	$t0, $s3, loop_cont

	j	win_t_exit

loop_cont:

	li	$t0, 4						# move to the next tile
	add	$s2, $s2, $t0
	j	loop_t

win_t_exit:

#
# Restore registers ra and s0 - s7 from the stack.
#
    lw  $ra, -4+A_FRAMESIZE($sp)
    lw  $s7, 40($sp)
    lw  $s6, 36($sp)
    lw  $s5, 32($sp)
    lw  $a0, 28($sp)
    lw  $a1, 24($sp)
    lw  $a2, 20($sp)
    lw  $s4, 16($sp)
    lw  $s3, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
	li	$t0, A_FRAMESIZE
    add $sp, $sp, $t0

	jr	$ra

#
# Name:		Player 1's win statement
#
# Description: This prints out the input needed for a player 1 win. It also
#					ends the game.
#

win_1:

	li	$v0, PRINT_STRING
	la	$a0, victory_1
	syscall

	j	exit


#
# Name:		Player 2's win statement
#
# Description: This prints out the input needed for a player 2 win. It also
#					ends the game.
#

win_2:

	li	$v0, PRINT_STRING
	la	$a0, victory_2
	syscall

	j	exit


#
# Name:		Tie game print
#
# Description:	The board is full and neither can win
#


win_t_print:

	li	$v0, PRINT_STRING			# Print ends in tie
	la	$a0, victory_t
	syscall

	j	exit

#
# Name:		Player Quit
#
# Description:	Deals with printing the correct player print
#				They quit why would anyone want to quit weird?
#

exit_quit:

	move $s7, $a0
	li	$s0, 1
	bne	$s0, $s7, exit_quit_2

	li	$v0, PRINT_STRING			# Print player 1 quit
	la	$a0, quit_1
	syscall

	j	exit

exit_quit_2:

	li	$v0, PRINT_STRING			# Print player 2 quit
	la	$a0, quit_2
	syscall

	j	exit
