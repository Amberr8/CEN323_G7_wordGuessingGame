; Module: Data Management & Game Initialization
; Name: Areesha Sadaf
; Reg No: 01-135232-012
; Date: May 17, 2026

include 'emu8086.inc'
org 100h

jmp start

; words for the game
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

; length of each word
word_lengths db 8, 8, 7, 8, 8, 9, 6, 7, 8, 8

; game variables
secret_word     db 20 dup(0)
display_word    db 20 dup(0)
word_len        dw 0
lives           db 6
max_lives       db 6
guessed_letters db 26 dup(0)
current_index   db 0

; messages
msg_welcome     db '=== WELCOME TO WORD GUESSING GAME ===', 0
msg_menu1       db '1. Play Game', 0
msg_menu2       db '2. Instructions', 0
msg_menu3       db '3. Exit', 0
msg_choice      db 'Enter your choice: ', 0
msg_invalid     db 'Invalid choice! Try again.', 0
msg_instruction1 db 'Guess the hidden word one letter at a time.', 0
msg_instruction2 db 'You have 6 lives. Each wrong guess costs 1 life.', 0
msg_instruction3 db 'Duplicate guesses do not cost lives.', 0
msg_instruction4 db 'Enter only UPPERCASE letters (A-Z).', 0
msg_press_key   db 'Press any key to continue...', 0
msg_goodbye     db 'Thanks for playing! Goodbye.', 0

start:
    call main_menu
    
    cmp al, '3'
    je exit_program
    
    cmp al, '2'
    jne skip_instructions
    call show_instructions
    jmp start
    
skip_instructions:
    call pick_random_word
    call init_display_word
    call clear_guessed_letters
    mov al, max_lives
    mov lives, al
    ret

exit_program:
    call clear_screen
    gotoxy 10, 10
    lea si, msg_goodbye
    call print_string
    mov ah, 0
    int 16h
    ret

; shows the main menu and gets player choice
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
    
    ; if wrong key pressed show error
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

; shows how to play the game
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

; picks a random word using system time
pick_random_word proc
    mov ah, 2Ch
    int 21h             ; get current time
    
    mov al, dl          ; use milliseconds part
    mov ah, 0
    mov bl, 10
    div bl              ; remainder gives 0-9
    mov current_index, ah
    
    mov al, current_index
    mov ah, 0
    mov si, ax
    lea bx, word_lengths
    add bl, al
    mov al, [bx]
    mov word_len, ax
    
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
    ; copy selected word into buffer
    lea di, secret_word
    mov cx, word_len
    cld
    rep movsb
    mov byte ptr [di], 0
    ret
pick_random_word endp

; fills display word with underscores at start
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

; resets all guessed letters back to zero
clear_guessed_letters proc
    lea di, guessed_letters
    mov cx, 26
    mov al, 0
    cld
    rep stosb
    ret
clear_guessed_letters endp

; clears the screen
clear_screen proc
    push ax
    mov ah, 0
    mov al, 3
    int 10h
    pop ax
    ret
clear_screen endp

DEFINE_PRINT_STRING
END
