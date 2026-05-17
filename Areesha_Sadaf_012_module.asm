MEMBER 3: AREESHA SADAF (01-135232-012)
Module: Data Management & Game Initialization
Complete Separate Code File (Areesha_Sadaf_012_module.asm):; 
; MODULE: Data Management & Game Initialization
; DEVELOPER: Areesha Sadaf (01-135232-012)
; LAST MODIFIED: May 17, 2026

; This module handles:
; 1. Word bank and data storage
; 2. Random word selection using system time
; 3. Game state initialization
; 4. Memory buffer management
; ===========================================================

include 'emu8086.inc'
org 100h

jmp start

; ============================================================
; DATA SEGMENT - WORD BANK (10 Computer Science Terms)
; ============================================================
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

; Word lengths array (parallel to word bank)
word_lengths db 8, 8, 7, 8, 8, 9, 6, 7, 8, 8

; ============================================================
; GAME STATE VARIABLES (Shared Buffers)
; ============================================================
secret_word     db 20 dup(0)    ; Buffer for chosen word
display_word    db 20 dup(0)    ; Buffer for displayed word (_ _ _)
word_len        dw 0            ; Length of current secret word
lives           db 6            ; Remaining lives
max_lives       db 6            ; Starting lives (constant)
guessed_letters db 26 dup(0)    ; Flags for A-Z (0=not guessed, 1=guessed)
current_index   db 0            ; Selected word index (0-9)

; ============================================================
; MENU AND INSTRUCTION MESSAGES
; ============================================================
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

; ============================================================
; PROGRAM ENTRY POINT
; ============================================================
start:
    call main_menu
    
    cmp al, '3'
    je exit_program
    
    cmp al, '2'
    jne skip_instructions
    call show_instructions
    jmp start
    
skip_instructions:
    ; Initialize new game
    call pick_random_word
    call init_display_word
    call clear_guessed_letters
    mov al, max_lives
    mov lives, al
    
    ; Hand control to Amber's game loop
    ; call game_loop     ; Amber's procedure
    
    ret

exit_program:
    call clear_screen
    gotoxy 10, 10
    lea si, msg_goodbye
    call print_string
    mov ah, 0
    int 16h
    ret

; ============================================================
; MAIN MENU PROCEDURE
; LAB CONCEPTS: Lab 10 (I/O), Lab 11 (Procedures)
; ============================================================
; Purpose: Display and handle main menu selection
; Output: AL = user choice ('1', '2', or '3')
; Registers Modified: AX, SI
; ============================================================
main_menu proc
menu_start:
    call clear_screen
    
    ; Display title
    gotoxy 5, 2
    lea si, msg_welcome
    call print_string
    
    ; Display menu options
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
    
    ; Get user choice
    printn ""
    printn ""
    gotoxy 10, 9
    lea si, msg_choice
    call print_string
    
    mov ah, 01h        ; Read character with echo
    int 21h
    
    ; Validate input
    cmp al, '1'
    je menu_valid
    cmp al, '2'
    je menu_valid
    cmp al, '3'
    je menu_valid
    
    ; Invalid choice handling
    printn ""
    gotoxy 10, 11
    lea si, msg_invalid
    call print_string
    mov ah, 0
    int 16h            ; Wait for keypress
    jmp menu_start
    
menu_valid:
    ret
main_menu endp

; ============================================================
; SHOW INSTRUCTIONS PROCEDURE
; LAB CONCEPTS: Lab 10 (Formatted Text Output)
; ============================================================
; Purpose: Displays game instructions to player
; Registers Modified: AX, SI
; ============================================================
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
    mov ah, 0           ; Wait for keypress
    int 16h             ; BIOS keyboard interrupt
    ret
show_instructions endp

; ============================================================
; PICK RANDOM WORD PROCEDURE
; LAB CONCEPTS: Lab 8 (String Copy), INT 21h/2Ch (System Time)
; ============================================================
; Purpose: Selects random word using system time as seed
; Algorithm:
;   1. Get system time (1/100 seconds) via INT 21h/2Ch
;   2. Divide by 10 to get remainder 0-9
;   3. Use remainder as index into word bank
;   4. Copy selected word to secret_word buffer
; Registers Modified: AX, BX, CX, DX, SI, DI
; ============================================================
pick_random_word proc
    ; Step 1: Get pseudo-random number from system clock
    mov ah, 2Ch         ; DOS function: get system time
    int 21h             ; Returns: CH=hour, CL=min, DH=sec, DL=1/100 sec
    
    ; Step 2: Convert to 0-9 range
    mov al, dl          ; Use 1/100 seconds (0-99)
    mov ah, 0
    mov bl, 10
    div bl              ; AH = AL % 10 (remainder 0-9)
    mov current_index, ah
    
    ; Step 3: Get word length from parallel array
    mov al, current_index
    mov ah, 0
    mov si, ax
    lea bx, word_lengths
    add bl, al          ; BX points to correct length
    mov al, [bx]        ; Load length
    mov word_len, ax    ; Store in word_len
    
    ; Step 4: Select word pointer using index
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
    ; Step 5: Copy word to buffer using string operations
    lea di, secret_word ; Destination buffer
    mov cx, word_len    ; Number of bytes to copy
    cld                 ; Clear direction flag (SI++, DI++)
    rep movsb           ; Repeat: [DI] = [SI], SI++, DI++, CX--
    mov byte ptr [di], 0 ; Null terminate
    
    ret
pick_random_word endp

; ============================================================
; INITIALIZE DISPLAY WORD PROCEDURE
; LAB CONCEPTS: Lab 8 (Array Initialization)
; ============================================================
; Purpose: Fills display_word with underscores
; Example: "PROGRAM" becomes "_ _ _ _ _ _ _"
; Registers Modified: CX, DI
; ============================================================
init_display_word proc
    lea di, display_word ; Destination buffer
    mov cx, word_len    ; Word length counter
    mov al, '_'         ; Fill character
    
fill_loop:
    stosb               ; Store AL at [DI], DI++
    loop fill_loop      ; Repeat CX times
    
    mov byte ptr [di], 0 ; Null terminate string
    ret
init_display_word endp

; ============================================================
; CLEAR GUESSED LETTERS ARRAY PROCEDURE
; LAB CONCEPTS: Lab 8 (Array Clearing)
; ============================================================
; Purpose: Resets all 26 guessed letter flags to 0
; Registers Modified: CX, DI
; ============================================================
clear_guessed_letters proc
    lea di, guessed_letters ; Start of array
    mov cx, 26          ; 26 letters
    mov al, 0           ; Clear value
    cld                 ; Auto-increment DI
    rep stosb           ; Fill 26 bytes with 0
    ret
clear_guessed_letters endp

; ============================================================
; CLEAR SCREEN PROCEDURE (Duplicated for standalone testing)
; ============================================================
clear_screen proc
    push ax
    mov ah, 0
    mov al, 3
    int 10h
    pop ax
    ret
clear_screen endp

DEFINE_PRINT_STRING
ENDSteps for Areesha to Complete:
Save code as Areesha_Sadaf_012_module.asm

Test word bank:

Verify all 10 words display correctly

Check word lengths array matches

Test random selection:

Run multiple times to see different words

Track which words appear (should be random)

Test initialization:

init_display_word should fill buffer with underscores

clear_guessed_letters should reset all flags to 0

Test menu system:

All 3 options should workInvalid input should show error

Take screenshots:

Main menu

Instructions screen

Different random words selected
