
; MODULE: Game Logic & Input Processing
; DEVELOPER: Amber Waseem (01-135232-008)
; LAST MODIFIED: May 17, 2026

; This module handles:
; 1. Main game loop control
; 2. Player input validation and processing
; 3. Win/Lose condition checking
; 4. Score calculation

include 'emu8086.inc'
org 100h

jmp start

; ----shared data and new data ----

secret_word     db 20 dup(0)      
display_word    db 20 dup(0)    
word_len        dw 0           
lives           db 6            
max_lives       db 6            
found_flag      db 0            
guessed_letters db 26 dup(0) 
score           dw 0          

; --- MESSAGES  ---
msg_prompt      db 'Enter a letter (A-Z): ', 0
msg_win         db 'CONGRATULATIONS! You guessed the word: ', 0
msg_lose        db 'GAME OVER! The word was: ', 0
msg_lives       db 'Lives remaining: ', 0
msg_used        db 'You already guessed that letter!', 0
msg_not_alpha   db 'Please enter a valid letter (A-Z)!', 0
msg_score       db 'Your score: ', 0
msg_play_again  db 'Play again? (Y/N): ', 0


start:
  
    ; call init_game_data    ; Areesha's procedure
    
game_loop:
    ; Step 1: Display current game status
    ; call display_status    ; Sadaf's procedure
    
    ; Step 2: Check if player lost
    mov al, lives
    cmp al, 0
    jle game_over_lose
    
    ; Step 3: Get valid player input
    call get_valid_input
    
    ; Step 4: Process the guess
    call process_guess
    
    ; Step 5: Check if player won
    call check_win
    cmp al, 1
    je game_over_win
    
   
    ; call update_hangman    ; Sadaf's procedure
    
    jmp game_loop


get_valid_input proc
input_retry:
    ; Display prompt
    gotoxy 15, 8
    lea si, msg_prompt
    call print_string
    
    ; Read character with echo (INT 21h, AH=01h)
    mov ah, 01h        ; DOS function: read character
    int 21h             ; BIOS interrupt call
    
    ; Step 1: Convert to uppercase if needed
    cmp al, 'a'
    jl not_lowercase
    cmp al, 'z'
    jg not_lowercase
    sub al, 32          ; Convert to uppercase (ASCII math)
    
not_lowercase:
    ; Step 2: Validate is A-Z
    cmp al, 'A'
    jl input_not_alpha
    cmp al, 'Z'
    jg input_not_alpha
    
    ; Step 3: Check if already guessed
    push ax             ; Save validated letter
    sub al, 'A'
    mov ah, 0
    lea si, guessed_letters
    add si, ax          ; SI points to letter's position
    mov al, [si]        ; Load guessed flag
    cmp al, 1           ; Already guessed?
    pop ax              ; Restore letter
    je input_already_used
    
    ret                 ; Return with valid letter in AL

input_not_alpha:
    gotoxy 15, 10
    lea si, msg_not_alpha
    call print_string
    ; Clear input line
    gotoxy 15, 8
    print "                              "
    jmp input_retry

input_already_used:
    gotoxy 15, 10
    lea si, msg_used
    call print_string
    ; Clear input line
    gotoxy 15, 8
    print "                              "
    jmp input_retry
    
get_valid_input endp

; check if word is in secret word

process_guess proc
    push ax
    push bx
    push si
    
    ; Step 1: Mark letter as guessed in array
    mov bl, al
    sub bl, 'A'         ; Convert to 0-25 index
    mov bh, 0
    lea si, guessed_letters
    add si, bx          ; Point to correct index
    mov byte ptr [si], 1 ; Set flag
    
    ; Step 2: Search for letter in secret word
    mov found_flag, 0
    mov cx, word_len    ; Loop counter = word length
    lea si, secret_word ; Source pointer
    lea di, display_word; Destination pointer
    mov bl, al          ; Letter to search for
    
scan_loop:
    mov al, [si]        ; Load character from secret word
    cmp al, bl          ; Match?
    jne scan_next       ; If no, skip to next
    
    ; Match found - reveal letter in display word
    mov [di], bl
    mov found_flag, 1
    
scan_next:
    inc si              ; Next source character
    inc di              ; Next display position
    loop scan_loop      
    
    ; Step 3: Decrease lives if wrong guess
    cmp found_flag, 0
    jne pg_done
    dec lives           ; Lose one life
    
pg_done:
    ; Clear message area
    gotoxy 15, 8
    print "                              "
    gotoxy 15, 10
    print "                              "
    
    pop si
    pop bx
    pop ax
    ret
process_guess endp

   
;check if all letters have been guesses
check_win proc
    mov cx, word_len    ; Check each letter
    lea si, display_word
    
cw_loop:
    mov al, [si]        ; Load current display character
    cmp al, '_'         ; Still hidden?
    je not_won          ; If any underscore, not won yet
    inc si
    loop cw_loop
    
   
    mov al, 1           ; Return 1 won
    ret
    
not_won:
    mov al, 0           ; Return 0 lose
    ret
check_win endp

; Game Over logic
game_over_win:
    ; Display win message
    gotoxy 10, 5
    lea si, msg_win
    call print_string
    lea si, secret_word
    call print_string
    
    ; Calculate score  logic : lives * 100
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
    ; Display lose message
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
    je restart_game
    cmp al, 'y'
    je restart_game
    
    ; Exit to main menu (Areesha's module)
    ; jmp main_menu_start
    ret

restart_game:
    jmp start

; Required macro definitions
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM_UNS
END