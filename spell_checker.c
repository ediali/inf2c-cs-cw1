/***********************************************************************
 * File       : <spell_checker.c>
 *
 * Author     : <Siavash Katebzadeh>
 *
 * Description:
 *
 * Date       : 08/10/18
 *
 ***********************************************************************/
// ==========================================================================
// Spell checker
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////
// You can define your global variables here!
char result[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
char dictionary2D[MAX_DICTIONARY_WORDS + 1][MAX_WORD_SIZE + 1];

// Task B

void dictionaryToArray(){
    char c;
    int idx = 0;
    int d_idx = 0;
    int i;
    for (i = 0; i < MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1; i++){
        c = dictionary[i];
        if( c == '\n'){
            idx += 1;
            d_idx = 0;
        }
        else if (c == '\0'){
            break;
        }
        else{
            dictionary2D[idx][d_idx] = c;
            d_idx += 1;
        }
    }
    return;
}

void wrong(int i){
    int j;
    char *c;
    c = tokens[i];
    result[i][0] = '_';
    for (j = 1; j < 2049; ++j){
        if (tokens[i][j-1] == '\0'){
            result[i][j] = '_';
            break;
        }
        else{
            result[i][j] = tokens[i][j-1];
        }
    }
}

int compare (char *c, char *d){
    int t = 0;
    char *a = c;
    char *b = d;
    char c1;
    char c2;
    do{
        c1 = *a++;
        c2 = *b++;
        if (c1 <= 90 && c1 >= 65){
            c1 += 32;
        }
        if (c1 == '\0'){
            return c1 - c2;
        }

    } while (c1 == c2);
    return c1 - c2;
}

char *copy(char *r, const char *t)
{
    char *save = r;
    while(*r++ = *t++);
    return save;
}

// addr = base_addr + (row_index * col_Size + col_index)

// t9 = first index of tokens .......  tokens[i].....    rew_index
// t8 = second index of tokens ......  tokens[][i]....   col_index
// s2 = size of column......                             col_size


void spell_checker() {
    int i = 0;
    int j = 0;
    char *d;
    char *c;
    int t = 0;
    for (i = 0; i < tokens_number; ++i){
        t = 0;
        c = tokens[i];
        if (c[0] == '\0'){
            break;
        }
        if (c[0] == ',' || c[0] == '.' || c[0] == '!' || c[0] == '?' || c[0] == ' '){
            t = 1;
        }
        for (j = 0; j < MAX_DICTIONARY_WORDS + 1; ++j){
            d = dictionary2D[j];
            if(compare(c, d) == 0){
                t = 1;
                break;
            }
            else{
                t = 0 + t;
            }
        }
        if (t == 1){
            copy(result[i], tokens[i]);
        }
        else if (t ==0){
            wrong(i);
        }
        
   }
}

void output_tokens() {
    int i;
    for (i = 0; i < tokens_number; ++i)  {
        output(result[i]);
    }
    printf("\n");
    return;
}


// Task B


//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer(){
    char c;
    
    // index of content
    int c_idx = 0;
    c = content[c_idx];
    do {
        
        // end of content
        if(c == '\0'){
            break;
        }
        
        // if the token starts with an alphabetic character
        if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {
            
            int token_c_idx = 0;
            // copy till see any non-alphabetic character
            do {
                tokens[tokens_number][token_c_idx] = c;
                
                token_c_idx += 1;
                c_idx += 1;
                
                c = content[c_idx];
            } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
            tokens[tokens_number][token_c_idx] = '\0';
            tokens_number += 1;
            
            // if the token starts with one of punctuation marks
        } else if(c == ',' || c == '.' || c == '!' || c == '?') {
            
            int token_c_idx = 0;
            // copy till see any non-punctuation mark character
            do {
                tokens[tokens_number][token_c_idx] = c;
                
                token_c_idx += 1;
                c_idx += 1;
                
                c = content[c_idx];
            } while(c == ',' || c == '.' || c == '!' || c == '?');
            tokens[tokens_number][token_c_idx] = '\0';
            tokens_number += 1;
            
            // if the token starts with space
        } else if(c == ' ') {
            
            int token_c_idx = 0;
            // copy till see any non-space character
            do {
                tokens[tokens_number][token_c_idx] = c;
                
                token_c_idx += 1;
                c_idx += 1;
                
                c = content[c_idx];
            } while(c == ' ');
            tokens[tokens_number][token_c_idx] = '\0';
            tokens_number += 1;
        }
    } while(1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{
    
    
    /////////////Reading dictionary and input files//////////////
    ///////////////Please DO NOT touch this part/////////////////
    int c_input;
    int idx = 0;
    
    // open input file
    FILE *input_file = fopen(input_file_name, "r");
    // open dictionary file
    FILE *dictionary_file = fopen(dictionary_file_name, "r");
    
    // if opening the input file failed
    if(input_file == NULL){
        print_string("Error in opening input file.\n");
        return -1;
    }
    
    // if opening the dictionary file failed
    if(dictionary_file == NULL){
        print_string("Error in opening dictionary file.\n");
        return -1;
    }
    
    // reading the input file
    do {
        c_input = fgetc(input_file);
        // indicates the the of file
        if(feof(input_file)) {
            content[idx] = '\0';
            break;
        }
        
        content[idx] = c_input;
        
        if(c_input == '\n'){
            content[idx] = '\0';
        }
        
        idx += 1;
        
    } while (1);
    
    // closing the input file
    fclose(input_file);
    
    idx = 0;
    
    // reading the dictionary file
    do {
        c_input = fgetc(dictionary_file);
        // indicates the end of file
        if(feof(dictionary_file)) {
            dictionary[idx] = '\0';
            break;
        }
        
        dictionary[idx] = c_input;
        idx += 1;
    } while (1);
    
    // closing the dictionary file
    fclose(dictionary_file);
    //////////////////////////End of reading////////////////////////
    ////////////////////////////////////////////////////////////////
    
    tokenizer();
    dictionaryToArray();
    spell_checker();
    output_tokens();
    
    return 0;
}
