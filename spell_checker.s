
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"

#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!
tokens:         .space  411849        
dictionary2D:       .space  210021
result:         .space  411849
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)               
        lb   $t1, dictionary($t0)               
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

start: 
    li  $s1, 201
    li  $t9, 0          # int i = 0 (in tokens_tokens)
    li  $t8, 0
    li  $t4, 0          # tokens_number = 0
    move    $t0, $0         # c_idx = 0
    la  $a0, content        # address of buffer from which to read
    lb  $t1, content($t0)   # c = content[c_idx]
    j   tokenizer
     
tokenizer:
    beqz    $t1, start2     # if(c == '\0'){do}
    move    $t3, $0         # token_c_idx = 0
    li  $v0, 65
    bge $t1, $v0, isAlpha1   # if c > A in ascii
    li  $v0, 46
    beq $t1, $v0, isChar     # if(c == ',' || c == '.' || c == '!' || c == '?')
    li  $v0, 44
    beq $t1, $v0, isChar
    li  $v0, 33
    beq $t1, $v0, isChar
    li  $v0, 63
    beq $t1, $v0, isChar
    li  $v0, 32
    beq $t1, $v0, isSpace    # if (c == ' ')

isSpace:
    mult    $t4, $s1
    mflo    $s7
    add $s5, $t3, $s7
    sb  $t1, tokens($s5)    # tokens[tokens_number][token_c_idx]
    addi    $t3, $t3, 1     # token_c_idx += 1
    addi    $t0, $t0, 1     # c_idx += 1
    lb  $t1, content($t0)   # c = content[c_idx]

whileSpace:
    li  $v0, 32
    beq $t1, $v0, isSpace    # if (c == ' ')
    mult    $t4, $s1
    mflo    $s7
    add $s5, $t3, $s7
    sb  $0, tokens($s5)     # tokens[tokens_number][token_c_idx] = '\0'
    addi    $t4, $t4, 1     # tokens_nmber += 1
    j   tokenizer       
    
isChar:
    mult    $t4, $s1
    mflo    $s7
    add $s5, $t3, $s7
    sb  $t1, tokens($s5)    # tokens[tokens_number][token_c_idx]
    addi    $t3, $t3, 1     # token_c_idx += 1
    addi    $t0, $t0, 1     # c_idx += 1
    lb  $t1, content($t0)   # c = content[c_idx]

whileChar:
    li  $v0, 46
    beq $t1, $v0, isChar     # if(c == ',' || c == '.' || c == '!' || c == '?')
    li  $v0, 44
    beq $t1, $v0, isChar
    li  $v0, 33
    beq $t1, $v0, isChar
    li  $v0, 63
    beq $t1, $v0, isChar
    mult    $t4, $s1
    mflo    $s7
    add $s5, $t3, $s7
    sb  $0, tokens($s5)     # tokens[tokens_number][token_c_idx] = '\0'
    addi    $t4, $t4, 1     # tokens_nmber += 1
    j   tokenizer       
    
isAlpha1:
    li $v0, 122
    ble $t1, $v0, isAlpha2
    
isAlpha2:
    mult    $t4, $s1        # row * 2049
    mflo    $s7
    add $s5, $t3, $s7       # column + (row * 2049)
    sb  $t1, tokens($s5)    # tokens[tokens_number][token_c_idx]
    addi    $t3, $t3, 1     # token_c_idx += 1
    addi    $t0, $t0, 1     # c_idx += 1
    lb  $t1, content($t0)   # c = content[c_idx]
    
whileAlpha:
    li  $v0, 65
    bge $t1, $v0, isAlpha1   # if c > A in ascii
    mult    $t4, $s1
    mflo    $s7
    add $s5, $t3, $s7
    sb  $0, tokens($s5)     # tokens[tokens_number][token_c_idx] = '\0'
    addi    $t4, $t4, 1     # tokens_nmber += 1
    j   tokenizer       


start2:
    li  $t0, 0          # idx = 0
    li  $t1, 0          # d_idx = 0
    li  $t2, 0
    li  $t5, 0
    li  $s2, 21     #s1 = MAX_DICTIONARY_WORDS
    li  $s5, 0
    li  $s6, 0
    li  $t8, 0          # index of columns in 2D dictionary array
    li  $t9, 0          # i = 0 (this is the i in spell_checker)
    j dictionaryToArray
    
dictionaryToArray:
    li  $v0, 200001
    beq $t2, $v0, start3     # for (i = 0; i < MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1; i++)
    lb  $t3, dictionary($t2)    # c = dictionary[i]
    li  $v0, 10
    beq $t3, $v0, nextStep   # moves to the next word in the dictionary
    beq $t3, $0, start3     # if end of file, go to start3
    mult    $t0, $s2
    mflo    $s7
    add $s5, $t1, $s7
    sb  $t3, dictionary2D($s5)  # dictionary2D[idx][d_idx]
    addi    $t1, $t1, 1     # d_idx += 1
    addi    $t2, $t2, 1     # i += 1
    j dictionaryToArray
    
nextStep:
    mult    $t0, $s2
    mflo    $s7
    add $s5, $t1, $s7
    sb  $0, dictionary2D($s5)   #store \0 in dictionary
    addi    $t0, $t0, 1     #idx += 1
    li  $t1, 0          #d_idx += 1
    addi    $t2, $t2, 1     #i += 1
    addi    $t5, $t5, 1     #length of dictionary
    j dictionaryToArray

start3:
    li  $t0, 0          # initialize all registers to 0 for next step of the program
    li  $t1, 0          
    li  $t2, 0
    li  $t3, 0
    li  $s5, 0
    li  $s2, 21
    j spell_checker         # jump to spellchecker


spell_checker:
    li  $t6, 0          # t = 0 (t = false) This register marks if the word is correct(1) or incorre
    li  $t8, 0          # column index of dictionary
    bgt     $t9, $t4, beforeEnd # if first index is equal to t4 (token_nmber)
    lb  $t7, tokens($s6)    # $t7 = current character in tokens
    beqz    $t7, nextItem   # if $t7 is 0, go to next word
    li  $t0, 0
    li  $v0, 46
    beq $t7, $v0, copy       # if(c == ',' || c == '.' || c == '!' || c == '?')
    li  $v0, 44
    beq $t7, $v0, copy
    li  $v0, 33
    beq $t7, $v0, copy
    li  $v0, 63
    beq $t7, $v0, copy
    li  $v0, 32
    beq $t7, $v0, copy       # if (c == ' ')
    jal     startLoop       # jump and link to startLoop. Starts the for loop to check if the token is in the dictionary
    li  $v0, 1
    beq $t6, $v0, copy        # if t = 1 (word is correct), you store it.
    j   wrong           # otherwise, the word is wrong

wrong:
    li  $a0, 95         # loads the underscore character
    sb  $a0, result($s6)
    addi    $s6, $s6, 1
    beqz    $t7, nextItem       
whileWrong:
    beqz    $t7, wrong      # if it's the end of the token, go back to wrong to add an underscore
    addi    $t8, $t8, 1     # c_idx += 1
    mult    $t9, $s1        # row * 201 
    mflo    $s7
    add $s6, $t8, $s7       # column + (row * 2049)
    sb  $t7, result($s6)    
    lb  $t7, tokens($s6)
    addi    $s6, $s6, 1
    j   whileWrong
    
    
    
copy:
    sb  $t7, result($s6)    # result[tokens_number][token_c_idx]
    beqz    $t7, nextItem
    addi    $t8, $t8, 1     # c_idx += 1
    mult    $t9, $s1        # row * 201 
    mflo    $s7
    add $s6, $t8, $s7       # column + (row * 2049)
    lb  $t7, tokens($s6)
    j copy


nextItem:
    sb  $0 result($s6)      # store /0 at the end of that word and move on to next one
    addi    $t9, $t9, 1 
    move    $t8, $0 
    mult    $t9, $s1
    mflo    $s7
    add $s6, $t8, $s7       # point to next item
    j spell_checker

startLoop:
    sw  $ra, 0($sp)
    j loop              # store the current return address and jump to loop
    
false: 
    lw  $ra, 0($sp)
    jr  $ra
loop:   
    li  $t2, 0
    mult    $t0, $s2        # t0 = row_index. s2 = col_size
    mflo    $s7
    add $s5, $s7, $t2       # t2 = col_index
    lb  $t1, dictionary2D($s5)
    bgt $t0, $t5, false     # is the row_index greater than length of dictionary array?
    jal     precompare      # if not, jump and link to precompare
    beqz    $t3, true       # is the difference between chars 0(meaning they're the same?)
    addi    $t6, $t6, 0     # if not, add 0 to t6
    addi    $t0, $t0, 1     # go to next row index of dictionary array
    bnez    $t3, loop       # if the difference isnt equal to 0, you loop again
    lw  $ra, 0($sp)     # jump back to spell_checker function
    jr  $ra
    
true:
    li  $t6, 1          # t6 = 1, means token is correct
    lw  $ra, 0($sp) 
    jr  $ra
    
precompare:
    move    $s4, $s6        # move register so that original ones don't get changed
    move    $s3, $t7
    j compare

compare:
    beqz    $s3, difference     # is s3 == \0 (end of token)? if so you take the difference
    li      $s0, 90
    ble     $s3, $s0, toLower    # is the token uppercase? if so you make it lowercase
    beq     $s3, $t1, compareWhile  # if the chars are equal, go to compare loop
    bne $s3, $t1, difference    # if they're not equal, go to difference
    

compareWhile:
    beqz    $s3, difference     # if end of token, you take the difference
    addi    $t8, $t8, 1     # else you move to next character of both the token and the dictionary word
    addi    $t2, $t2, 1
    
    mult    $t0, $s2
    mflo    $s7
    add $s5, $s7, $t2
    
    mult    $t9, $s1        # row * 201 
    mflo    $s7
    add $s4, $t8, $s7       # column + (row * 201)
    
    lb  $t1, dictionary2D($s5)
    lb  $s3, tokens($s4)
    
    j   compare
    
difference:
    sub $t3, $s3, $t1       # take difference between characters. If it's 0, then the chars are equal
    li  $t8, 0
    jr  $ra         # back to loop
    
toLower:
    addi    $s3, $s3, 32    # add 32 to make letter lowercase
    j compare

beforeEnd:              # make pointers point back to 0
    li  $t9, 0
    li  $t8, 0
    j endResult         # jump to endResult

endResult:
    beq     $t9, $t4, main_end  # i = 0; i < tokens_number; ++i
    lb  $a0, result($t8)
    beqz    $a0, printResult    # is the char the end of the token? If so -> printResult
    li  $v0, 11
    syscall             # print current character
    addi    $t8, $t8, 1     # i += 1
    j endResult
    
printResult:
    addi    $t9, $t9, 1     
    beq     $t9, $t4, main_end  # i = 0; i < tokens_number; ++i. is i == t4? if so go to main_end. This step is so that a new line is not printed at the end.
    addi    $t9, $t9, -1
    li  $t8, 0
    addi    $t9, $t9, 1     # load next item of result
    mult    $t9, $s1
    mflo    $s7
    add $t8, $t8, $s7
    j endResult
    
    
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE