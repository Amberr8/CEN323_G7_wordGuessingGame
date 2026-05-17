
;MEMBER 2: SADAF NAZARI (01-135232-084)
;Module: UI/Display & Hangman Graphics

include 'emu8086.inc'
org 100h

display_word  db 20 dup(0)


       lives  db 6            

; Stores guessed letters flags (A-Z)
guessed_letters db 26 dup(0)    

; Clears the screen and resets display mode
clear_screen proc
    push ax
    mov ah, 0        
    mov al, 3           
    int 10h            
    pop ax
    ret
clear_screen endp

; Draws the basic gallows structure
; This visible during the game
draw_gallows_base proc
  
    gotoxy 0, 0
    print '  +---+'
    
    gotoxy 0, 1
    print '  |   |'
    
    gotoxy 0, 2      ; empty hanging space 
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
    
    gotoxy 0, 9       ; basic platform 
    print '======='
    ret
draw_gallows_base endp

; Updates hangman procedure 
; Each wrong guess adds a body part
update_hangman proc
   
    mov al, 6
    sub al, lives   ;al number of wrong guesses    
    
   
    cmp al, 0
    je hangman_0    ; no parts  
    cmp al, 1
    je hangman_1     ;head  
    cmp al, 2
    je hangman_2     ;head and body    
    cmp al, 3
    je hangman_3     ;left arm  
    cmp al, 4
    je hangman_4      ;right 
    cmp al, 5
    je hangman_5       ;left 
    cmp al, 6
    je hangman_6       ;complete  
    ret

hangman_0:
    ; No wrong guesses yet
    ret                

hangman_1:
    ; Draw head circle 
    gotoxy 6, 2
    putc 'O'            
    ret

hangman_2:
    ; Draw body virtical line 
    gotoxy 6, 2
    putc 'O'            
    gotoxy 6, 3
    putc '|'           
    ret

hangman_3:
             
    gotoxy 6, 2
    putc 'O'           
    gotoxy 5, 3  ;left arm
    putc '/'            
    gotoxy 6, 3   ;body 
    putc '|'          
    ret

hangman_4:
 
    gotoxy 6, 2
    putc 'O'           
    gotoxy 5, 3
    putc '/'           
    gotoxy 6, 3
    putc '|'            
    gotoxy 7, 3   ;right arm
    putc 92           
    ret

hangman_5:
   
    gotoxy 6, 2
    putc 'O'            ; Head
    gotoxy 5, 3
    putc '/'            ; Left arm
    gotoxy 6, 3
    putc '|'            ; Body
    gotoxy 7, 3
    putc 92             ; Right arm
    gotoxy 5, 4
    putc '/'            ; Left leg
    ret

hangman_6:         ; Final stage
   
    gotoxy 6, 2
    putc 'O'            ; Head
    gotoxy 5, 3
    putc '/'            ; Left arm
    gotoxy 6, 3
    putc '|'            ; Body
    gotoxy 7, 3
    putc 92             ; Right arm
    gotoxy 5, 4
    putc '/'            ; Left leg
    gotoxy 7, 4
    putc 92             ; Right leg
    ret

update_hangman endp

; Displays game information 
display_status proc ;display hidden word and space
   
    gotoxy 15, 2      
    print "Word: "
    lea si, display_word
    call print_string_with_spaces
    
    ; Show remaining lives
    gotoxy 15, 4
    print "Lives remaining: "
    mov al, lives
    mov ah, 0
    call print_num_uns
    
    ; Show guessed letters list
    gotoxy 15, 6
    print "Guessed: "
    call display_guessed_letters
    
    ret
display_status endp


; Prints word characters with spaces

print_string_with_spaces proc
    push si             ; Save original pointer
    
psws_loop:
    lodsb               ; Load next character
    cmp al, 0         
    je psws_done        ; Stop at null character
    
    ; Print character and space
    putc al             
    putc ' '            
    jmp psws_loop
    
psws_done:
    pop si     ;restore pointer         
    ret
print_string_with_spaces endp


; Displays  guessed letters from A-Z

display_guessed_letters proc
    lea si, guessed_letters
    mov cx, 26          ; Totalletters
    mov bl, 'A'          ; Startfrom A
    
dgl_loop:
    mov al, [si]         ; Load guessed flag
    cmp al, 1          
    jne dgl_skip        ; Skipifnotguessed
    
    ; Print guessed letter
    putc bl             
    putc ' '            
    
dgl_skip:
    inc si               ; Move to next array element 
    inc bl              ; Move to next letter
    loop dgl_loop       
    
    ret
display_guessed_letters endp

DEFINE_PRINT_NUM_UNS
