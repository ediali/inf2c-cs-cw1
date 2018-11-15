
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
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
newline:                .asciiz  "\n"

        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
tokens:         .space  411849


# You can add your data here!
        
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
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
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
    beqz    $t1, end     # if(c == '\0'){do}
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
    li $v0, 32
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
    beq $t1, $v0, isChar     # do{} while(c == ',' || c == '.' || c == '!' || c == '?')
    li $v0, 44
    beq $t1, $v0, isChar
    li $v0, 33
    beq $t1, $v0, isChar
    li $v0, 63
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


end:
    beq     $t9, $t4, main_end  # i = 0; i < tokens_number; ++i. is i == t4? if so go to main_end
    lb  $a0, tokens($t8)    
    beqz    $a0, print      # is the char the end of the token? If so -> print
    li  $v0, 11 
    syscall             # print current character
    addi    $t8, $t8, 1     # i += 1
    j end
    
print:
    addi    $t9, $t9, 1     
    beq     $t9, $t4, main_end  # i = 0; i < tokens_number; ++i. is i == t4? if so go to main_end. This step is so that a new line is not printed at the end.
    addi    $t9, $t9, -1
    li  $v0, 4          
    la  $a0, newline    
    syscall             # print new line
    li  $t8, 0          
    addi    $t9, $t9, 1
    mult    $t9, $s1
    mflo    $s7
    add $t8, $t8, $s7       # address of next token
    j end               # back to end
      
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
