
; TEAM MEMBERS:
;   Amber Waseem    (01-135232-008) - Game Logic & Input Processing
;   Sadaf Nazari    (01-135232-084) - UI/Display & Hangman Graphics  
;   Areesha Sadaf   (01-135232-012) - Data Management & Initialization


include 'emu8086.inc'
org 100h

jmp start

;Word Bank


word1   db 'ASSEMBLY', 0
word2   db 'COMPUTER', 0
word3   db 'PROGRAM', 0
word4   db 'REGISTER', 0
word5   db 'KEYBOARD', 0
word6   db 'PROCESSOR', 0
word7   db 'MEMORY', 0
word8   db 'MONITOR', 0
word9   db 'SOFTWARE', 0
word10  db 'HARDWARE', 0

word_lengths db 8, 8, 7, 8, 8, 9, 6, 7, 8, 8
;variables
secret_word     db 20 dup(0)
display_word    db 20 dup(0)
word_len        dw 0
lives           db 6
max_lives       db 6
found_flag      db 0
guessed_letters db 26 dup(0)
score           dw 0
current_index   db 0

;messages
msg_welcome     db '=== WELCOME TO WORD GUESSING GAME ===', 0
msg_menu1       db '1. Play Game', 0
msg_menu2       db '2. Instructions', 0
msg_menu3       db '3. Exit', 0
msg_choice      db 'Enter your choice: ', 0
msg_invalid     db 'Invalid choice! Try again.', 0
msg_prompt      db 'Enter a letter (A-Z): ', 0
msg_win         db 'CONGRATULATIONS! You guessed the word: ', 0
msg_lose        db 'GAME OVER! The word was: ', 0
msg_lives       db 'Lives remaining: ', 0
msg_used        db 'You already guessed that letter!', 0
msg_not_alpha   db 'Please enter a valid letter (A-Z)!', 0
msg_score       db 'Your score: ', 0
msg_play_again  db 'Play again? (Y/N): ', 0
msg_instruction1 db 'Guess the hidden word one letter at a time.', 0
msg_instruction2 db 'You have 6 lives. Each wrong guess costs 1 life.', 0
msg_instruction3 db 'Duplicate guesses do not cost lives.', 0
msg_instruction4 db 'Enter only UPPERCASE letters (A-Z).', 0
msg_press_key   db 'Press any key to continue...', 0
msg_goodbye     db 'Thanks for playing! Goodbye.', 0

;main entry point

start:
    call main_menu
    
    cmp al, '3'
    je exit_program
    
    cmp al, '2'
    jne skip_instructions
    call show_instructions
    jmp start
    
skip_instructions:
    ; Initialize new game session
    call pick_random_word
    call init_display_word
    call clear_guessed_letters
    mov al, max_lives
    mov lives, al
    mov score, 0
    
    ; Setup display
    call clear_screen
    call draw_gallows_base
    
    ; Start game loop
    jmp game_loop
          
                                                         
; Main Menu Procedure

main_menu proc
menu_start:
    call clear_screen
    gotoxy 5, 2
    lea si, msg_welcome
    call print_string
    
    printn ""
    printn ""
    gotoxy 10, 5
    lea si, msg_menu1
    call print_string
    
    printn ""
    gotoxy 10, 6
    lea si, msg_menu2
    call print_string
    
    printn ""
    gotoxy 10, 7
    lea si, msg_menu3
    call print_string
    
    printn ""
    printn ""
    gotoxy 10, 9
    lea si, msg_choice
    call print_string
    
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je menu_valid
    cmp al, '2'
    je menu_valid
    cmp al, '3'
    je menu_valid
    
    printn ""
    gotoxy 10, 11
    lea si, msg_invalid
    call print_string
    
    mov ah, 0
    int 16h
    jmp menu_start
    
menu_valid:
    ret
main_menu endp

;show instruction proc
show_instructions proc
    call clear_screen
    gotoxy 5, 2
    lea si, msg_welcome
    call print_string
    
    printn ""
    printn ""
    print "================================="
    printn ""
    lea si, msg_instruction1
    call print_string
    printn ""
    lea si, msg_instruction2
    call print_string
    printn ""
    lea si, msg_instruction3
    call print_string
    printn ""
    lea si, msg_instruction4
    call print_string
    printn ""
    print "================================="
    
    printn ""
    printn ""
    lea si, msg_press_key
    call print_string
    mov ah, 0
    int 16h
    ret
show_instructions endp

;Pick Random Word
pick_random_word proc
    ; Get system time for randomness
    mov ah, 2Ch
    int 21h
    
    mov al, dl
    mov ah, 0
    mov bl, 10
    div bl
    mov current_index, ah
    
    ; Get word length
    mov al, current_index
    mov ah, 0
    lea bx, word_lengths
    add bl, al
    mov al, [bx]
    mov word_len, ax
    
    ; Select word based on index
    cmp current_index, 0
    jne check_word2
    lea si, word1
    jmp copy_word
    
check_word2:
    cmp current_index, 1
    jne check_word3
    lea si, word2
    jmp copy_word
    
check_word3:
    cmp current_index, 2
    jne check_word4
    lea si, word3
    jmp copy_word
    
check_word4:
    cmp current_index, 3
    jne check_word5
    lea si, word4
    jmp copy_word
    
check_word5:
    cmp current_index, 4
    jne check_word6
    lea si, word5
    jmp copy_word
    
check_word6:
    cmp current_index, 5
    jne check_word7
    lea si, word6
    jmp copy_word
    
check_word7:
    cmp current_index, 6
    jne check_word8
    lea si, word7
    jmp copy_word
    
check_word8:
    cmp current_index, 7
    jne check_word9
    lea si, word8
    jmp copy_word
    
check_word9:
    cmp current_index, 8
    jne copy_word10
    lea si, word9
    jmp copy_word
    
copy_word10:
    lea si, word10
    
copy_word:
    lea di, secret_word
    mov cx, word_len
    cld
    rep movsb
    mov byte ptr [di], 0
    ret
pick_random_word endp


init_display_word proc
    lea di, display_word
    mov cx, word_len
    mov al, '_'
fill_loop:
    stosb
    loop fill_loop
    mov byte ptr [di], 0
    ret
init_display_word endp
; clear guessed letter
clear_guessed_letters proc
    lea di, guessed_letters
    mov cx, 26
    mov al, 0
    cld
    rep stosb
    ret
clear_guessed_letters endp

                                                             
;       PROCEDURES: UI & HANGMAN GRAPHICS             
;      Sadaf Nazari (01-135232-084)                
                                                             

clear_screen proc
    push ax
    mov ah, 0
    mov al, 3
    int 10h
    pop ax
    ret
clear_screen endp

draw_gallows_base proc
    gotoxy 0, 0
    print '  +---+'
    gotoxy 0, 1
    print '  |   |'
    gotoxy 0, 2
    print '      |'
    gotoxy 0, 3
    print '      |'
    gotoxy 0, 4
    print '      |'
    gotoxy 0, 5
    print '      |'
    gotoxy 0, 6
    print '      |'
    gotoxy 0, 7
    print '      |'
    gotoxy 0, 8
    print '      |'
    gotoxy 0, 9
    print '======='
    ret
draw_gallows_base endp


; UPDATE HANGMAN PROCEDURE


update_hangman proc
    mov al, 6
    sub al, lives
    
    cmp al, 0
    je hangman_0
    cmp al, 1
    je hangman_1
    cmp al, 2
    je hangman_2
    cmp al, 3
    je hangman_3
    cmp al, 4
    je hangman_4
    cmp al, 5
    je hangman_5
    cmp al, 6
    je hangman_6
    ret

hangman_0:
    ret

hangman_1:
    gotoxy 6, 2
    putc 'O'
    ret

hangman_2:
    gotoxy 6, 2
    putc 'O'
    gotoxy 6, 3
    putc '|'
    ret

hangman_3:
    gotoxy 6, 2
    putc 'O'
    gotoxy 5, 3
    putc '/'
    gotoxy 6, 3
    putc '|'
    ret

hangman_4:
    gotoxy 6, 2
    putc 'O'
    gotoxy 5, 3
    putc '/'
    gotoxy 6, 3
    putc '|'
    gotoxy 7, 3
    putc 92
    ret

hangman_5:
    gotoxy 6, 2
    putc 'O'
    gotoxy 5, 3
    putc '/'
    gotoxy 6, 3
    putc '|'
    gotoxy 7, 3
    putc 92
    gotoxy 5, 4
    putc '/'
    ret

hangman_6:
    gotoxy 6, 2
    putc 'O'
    gotoxy 5, 3
    putc '/'
    gotoxy 6, 3
    putc '|'
    gotoxy 7, 3
    putc 92
    gotoxy 5, 4
    putc '/'
    gotoxy 7, 4
    putc 92
    ret
update_hangman endp


display_status proc
    gotoxy 15, 2
    print "Word: "
    lea si, display_word
    call print_string_with_spaces
    
    gotoxy 15, 4
    lea si, msg_lives
    call print_string
    mov al, lives
    mov ah, 0
    call print_num_uns
    
    gotoxy 15, 6
    print "Guessed: "
    call display_guessed_letters
    
    ret
display_status endp


print_string_with_spaces proc
    push si
psws_loop:
    lodsb
    cmp al, 0
    je psws_done
    putc al
    putc ' '
    jmp psws_loop
psws_done:
    pop si
    ret
print_string_with_spaces endp


display_guessed_letters proc
    lea si, guessed_letters
    mov cx, 26
    mov bl, 'A'
dgl_loop:
    mov al, [si]
    cmp al, 1
    jne dgl_skip
    putc bl
    putc ' '
dgl_skip:
    inc si
    inc bl
    loop dgl_loop
    ret
display_guessed_letters endp


;                                                             
;       GAME LOGIC & INPUT                
;      Amber Waseem (01-135232-008)                
;                                                           



game_loop:
    ; Display current game status
    call display_status
    
    ; Check if player lost
    mov al, lives
    cmp al, 0
    jle game_over_lose
    
    ; Get player input
    call get_valid_input
    
    ; Process the guess
    call process_guess
    
    ; Check if player won
    call check_win
    cmp al, 1
    je game_over_win
    
    ; Update hangman graphic
    call update_hangman
    
    jmp game_loop


get_valid_input proc
input_retry:
    gotoxy 15, 8
    lea si, msg_prompt
    call print_string
    
    mov ah, 01h
    int 21h
    
    ; Convert to uppercase
    cmp al, 'a'
    jl not_lowercase
    cmp al, 'z'
    jg not_lowercase
    sub al, 32
    
not_lowercase:
    ; Check if valid alphabet
    cmp al, 'A'
    jl input_not_alpha
    cmp al, 'Z'
    jg input_not_alpha
    
    ; Check if already guessed
    push ax
    sub al, 'A'
    mov ah, 0
    lea si, guessed_letters
    add si, ax
    mov al, [si]
    cmp al, 1
    pop ax
    je input_already_used
    
    ret

input_not_alpha:
    gotoxy 15, 10
    lea si, msg_not_alpha
    call print_string
    gotoxy 15, 8
    print "                              "
    jmp input_retry

input_already_used:
    gotoxy 15, 10
    lea si, msg_used
    call print_string
    gotoxy 15, 8
    print "                              "
    jmp input_retry
get_valid_input endp


process_guess proc
    push ax
    push bx
    push si
    
    ; Mark letter as guessed
    mov bl, al
    sub bl, 'A'
    mov bh, 0
    lea si, guessed_letters
    add si, bx
    mov byte ptr [si], 1
    
    ; Check if letter exists in secret word
    mov found_flag, 0
    mov cx, word_len
    lea si, secret_word
    lea di, display_word
    mov bl, al
    
scan_loop:
    mov al, [si]
    cmp al, bl
    jne scan_next
    
    ; Match found - reveal letter
    mov [di], bl
    mov found_flag, 1
    
scan_next:
    inc si
    inc di
    loop scan_loop
    
    ; Decrease lives if wrong guess
    cmp found_flag, 0
    jne pg_done
    dec lives
    
pg_done:
    ; Clear input message area
    gotoxy 15, 8
    print "                              "
    gotoxy 15, 10
    print "                              "
    
    pop si
    pop bx
    pop ax
    ret
process_guess endp

;check win
check_win proc
    mov cx, word_len
    lea si, display_word
    
cw_loop:
    mov al, [si]
    cmp al, '_'
    je not_won
    inc si
    loop cw_loop
    
    mov al, 1       ; Won
    ret
    
not_won:
    mov al, 0       ; Not won yet
    ret
check_win endp

;game over
game_over_win:
    call clear_screen
    gotoxy 10, 5
    lea si, msg_win
    call print_string
    lea si, secret_word
    call print_string
    
    ; Calculate score logic: lives * 100
    mov al, lives
    mov ah, 0
    mov bx, 100
    mul bl
    add score, ax
    
    printn ""
    gotoxy 10, 7
    lea si, msg_score
    call print_string
    mov ax, score
    call print_num_uns
    
    jmp play_again_prompt

game_over_lose:
    call clear_screen
    gotoxy 10, 5
    lea si, msg_lose
    call print_string
    lea si, secret_word
    call print_string
    
    printn ""
    gotoxy 10, 7
    lea si, msg_score
    call print_string
    mov ax, score
    call print_num_uns

play_again_prompt:
    printn ""
    printn ""
    gotoxy 10, 9
    lea si, msg_play_again
    call print_string
    
    mov ah, 01h
    int 21h
    cmp al, 'Y'
    je play_again_yes
    cmp al, 'y'
    je play_again_yes
    
    jmp exit_program
    
play_again_yes:
    jmp start

exit_program:
    call clear_screen
    gotoxy 10, 10
    lea si, msg_goodbye
    call print_string
    printn ""
    printn ""
    lea si, msg_press_key
    call print_string
    mov ah, 0
    int 16h
    ret

;macro definitions
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM_UNS

END