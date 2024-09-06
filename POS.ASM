.MODEL SMALL
.STACK 64

.DATA
 MenuOptions DB '1) Purchase$'
            DB '2) Edit Product Price$'
            DB '3) Add Coupon$'
            DB '4) Logout$', 0

 SelectPrompt DB 'Select product number to edit (1-4): $'
 FileName DB 'product.txt', 0
 ProductBuffer DB 100 DUP(0)       ; Buffer to store product data
 InputBuffer DB 5, 0, 5 DUP(0)     ; Input buffer: max 3 digits + Enter key
 EnterNewPricePrompt DB 'Enter new price (up to 3 digits): $'
 ErrorMsg DB 'Error opening or writing file!$', 0

; ------ LOGIN  ------ ;
 Divider            DB  79 DUP ("="),"$"
 NewLine            DB  13,10,"$"
 StartPageMessage_1 DB  13,10,"WELCOME TO TECH GENIUS SOLUTIONS SYSTEM. "
                    DB  13,10,"This is our company Point-of-Sales System. "
                    DB  13,10,"Please login or register your acccount before process to next step. $"
 StartPageMessage_2 DB  13,10,"Are you a staff member?"
                    DB  13,10,"1 - Yes, I'm a staff. "
                    DB  13,10,"2 - No, I'm not a staff. "
                    DB  13,10,"Please choose (1 or 2): $"
 LoginOrRegister    DB  0

 ErrorChoiceMessage DB  13,10,"[ERROR] Invalid Input Parameter! $"
 
 LoginMessage       DB  13,10,"Please enter your User Name and Password. $"
 UsernameMessage    DB  13,10,"User Name: $" 
 PasswordMessage    DB  13,10,"Password: $"
 Username_ADATA     DB      5 DUP(?)
 Password_ADATA     DB      10 DUP(?)

 CorrectUsername    DB  "Admin"
 CorrectPassword    DB  "admin!1234"

 ValidMessage       DB  13,10,"Access Granted! Welcome back. $"
 InvalidMessage     DB  13,10,"[ERROR] Invalid Credentials! Please try again. $"
 ChanceMessage_P1   DB  13,10,"You still have $"
 ChanceMessage_P2   DB  " more chance(s). $"
 LoginCount         DB  3

 AskForRegister     DB  13,10,13,10,"Do you want to register as a staff? "
                    DB  13,10,"1 - Yes "
                    DB  13,10,"2 - No"
                    DB  13,10,"Please choose (1 or 2): $"
 RegisterChoice     DB  0
 
 SetUsernameMessage DB  13,10,"Set your user account in 5 value. Eg. Carol "
                    DB  13,10,"User Name: $"
 SetPasswordMessage DB  13,10,"Set your password in 10 value. "
                    DB  13,10,"Password: $"
 ConfirmPasswordMSG DB  13,10,"Please enter your password again to confirm to create new account. "
                    DB  13,10,"Password: $"
 
 RegisterConfirmMSG DB  13,10,"Account Created! "
                    DB  13,10,"Will go back to login page. Please press any key to continue. "
                    DB  13,10,"$"
 RegisterCount      DB  0
 RegisterErrorMSG   DB  13,10,"[ERROR] This 2 passwords are not same! Please try again. $"
 RegisterExitMSG    DB  13,10,"Account fail to create. "
                    DB  13,10,"Will go back to login page. Please press any key to continue. "
                    DB  13,10,"$"

 RegisterUsername   DB      5 DUP(?)
 RegisterPassword   DB      10 DUP(?)
 ConfirmPassword    DB      10 DUP(?)
 ConfirmCount       DB  3

 WelcomeMessage     DB  13,10,"Welcome back. $"

 ExitProgramMessage DB  13,10,"Exiting Program. Goodbye. $"
  
; ------ END OF DATA DEFINITION ------ ;
.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    ; ------ START OF CODE ------ ;
    CALL LOGIN      ; call the LOGIN program (done)
    MOV     AH,09H
    LEA     DX,WelcomeMessage
    INT     21H


    CALL MAIN_MENU  ; Call the MAIN_MENU procedure
    ; Further processing can be done here after returning from MAIN_MENU
    ; (e.g., exit the program or perform other actions)
    

    EXIT_PROGRAM: 
    ; ------ END OF CODE ------ ;
    MOV AH, 4CH     ; DOS function to exit program
    INT 21H         ; Call DOS interrupt to terminate the program
MAIN ENDP

LOGIN PROC
    MOV     AX,3    ; clear screen
    INT     10H     ; call interrupt service

    XOR     AX,AX    ; clear AX

    MOV     AH,09H      ; request display string
    LEA     DX,Divider  ; display the divider
    INT     21H         ; call interrupt service

    MOV     AH,09H
    LEA     DX,StartPageMessage_1       ; welcome message
    INT     21H

    CHOICE_AGAIN:
    MOV     AH,09H
    LEA     DX,NewLine
    INT     21H
    LEA     DX,StartPageMessage_2       ; ask user is a staff or new user 
    INT     21H

    MOV     AH,01H      ; user input 1 or 2 to login or register
    INT     21H
    MOV     LoginOrRegister, AL    ; move user input into LoginOrRegister
    ;-----------------------------------------------------------------------
    CMP     LoginOrRegister,'1'
    JE      STAFF_LOGIN     ; done
    CMP     LoginOrRegister,'2'
    JE      REGISTER        ; 
    JNE     ERROR_CHOICE    ; done 
    ;-----------------------------------------------------------------------
    ERROR_CHOICE:
        MOV     AH,09H
        LEA     DX,ErrorChoiceMessage
        INT     21H
        JMP     CHOICE_AGAIN
    ;-----------------------------------------------------------------------
    REGISTER:
        MOV     AH,09H
        LEA     DX,AskForRegister   ; display message to ask user want to register or not
        INT     21H

        MOV     AH,01H      ; user input 1=yes, 2=no
        INT     21H         ; will store the input into AL

        MOV     RegisterChoice,AL   ; move to RegisterChoice
        CMP     RegisterChoice,'2'  ; compare the input =2 or not
        JE      CHOICE_AGAIN        ; if yes, JMP to login page    
        CMP     RegisterChoice,'1'  ; if user key-in "1", after compare it will continue to the next step
        JE      START_REGISTER
        JNE     REGISTER_ERROR      ; if input other key, will go to Register_Error     
                                    ; to display error message and JMP back here
    ;-----------------------------------------------------------------------
    REGISTER_ERROR:
        MOV     AH,09H
        LEA     DX,ErrorChoiceMessage
        INT     21H
        LEA     DX,NewLine
        INT     21H
        JMP     REGISTER
    ;-----------------------------------------------------------------------
    STAFF_LOGIN:
        MOV     AH,09H              ; request display string
        LEA     DX,LoginMessage     ; ask user to input userName and password
        INT     21H
        LEA     DX,ChanceMessage_P1 ; display how many chance(s) message
        INT     21H

        MOV     AH,02H
        MOV     DL,LoginCount
        ADD     DL,30H
        INT     21H

        MOV     AH,09H
        LEA     DX,ChanceMessage_P2
        INT     21H

        LOGIN_AGAIN: 
        MOV     AH,09H
        LEA     DX,NewLine
        INT     21H

        MOV     AH,09H              ; request display string
        LEA     DX,UsernameMessage  ; display "User Name: " message
        INT     21H

        XOR     CX,CX   ; clear CX
        MOV     CX,5    ; set CX=5 to loop five time
        MOV     SI,0
        GET_NAME:           ; using loop to get user name
            MOV     AH,01H
            INT     21H
            MOV     Username_ADATA[SI],AL
            INC     SI
            LOOP    GET_NAME

        MOV     AH,09H              ; request display string
        LEA     DX,PasswordMessage  ; display "password: " message
        INT     21H

        XOR     CX,CX           ; clear CX
        MOV     CX,10           ; set CX=10 to loop ans get the user input password
        MOV     SI,0
        GET_PASSWORD:       ; using loop to get user password
            MOV     AH,07H
            INT     21H
            MOV     Password_ADATA[SI],AL
            INC     SI
            MOV     AH,02H  
            MOV     DL,"*"  ; to display the user input into * 
            INT     21H
            LOOP    GET_PASSWORD
        JMP     CHECK_LOGIN
    ;-----------------------------------------------------------------------
    ; ------- START TO REGISTER ------ ;
        START_REGISTER:
        MOV     AH,09H
        LEA     DX,SetUsernameMessage   ; display the message to let user input username
        INT     21H
        
        XOR     CX,CX   ; clear CX
        MOV     CX,5    ; set CX=5 to loop five time
        MOV     SI,0
        GET_REGISTER_NAME:       ; using loop to enter new user name
            MOV     AH,01H
            INT     21H
            MOV     RegisterUsername[SI],AL
            INC     SI
            LOOP    GET_REGISTER_NAME

        MOV     AH,09H
        LEA     DX,SetPasswordMessage
        INT     21H

        XOR     CX,CX   ; clear CX
        MOV     CX,10   ; set CX=10 to loop ten time
        MOV     SI,0
        GET_REGISTER_PASSWORD: 
            MOV     AH,07H
            INT     21H
            MOV     RegisterPassword[SI],AL
            INC     SI
            MOV     AH,02H
            MOV     DL,"*"
            INT     21H
            LOOP    GET_REGISTER_PASSWORD

        CONFIRM_AGAIN:
        MOV     AH,09H
        LEA     DX,ConfirmPasswordMSG   ; display a message to let user input password
        INT     21H                     ; again to confirm to create a new account 

        XOR     CX,CX   ; clear CX
        MOV     CX,10   ; set CX=10 to loop ten time
        MOV     SI,0
        GET_CONFIRM_PASSWORD: 
            MOV     AH,07H
            INT     21H
            MOV     ConfirmPassword[SI],AL
            INC     SI
            MOV     AH,02H
            MOV     DL,"*"
            INT     21H
            LOOP    GET_CONFIRM_PASSWORD
        JMP     CHECK_REGISTER_CORRECT_OR_NOT
    ;-----------------------------------------------------------------------
        CHECK_LOGIN:
        CMP     RegisterCount,1         ; if user register new account (Register != 0)
        JE      CHECK_LOGIN_REGISTER    ;  will jmp to other checking first
        MOV     SI,0    ;use for loop to checK the user name 
        MOV     DI,0    ;use for loop to check the user password

        CHK_NAME:
            CMP     SI,5
            JE      CHK_PSW
            MOV     AL,CorrectUsername[SI]
            CMP     AL,Username_ADATA[SI]
            JE      NNAME
            JNE     LOGIN_ERROR     ; ERROR: Jmup out of range
        NNAME:
            INC     SI
            JMP     CHK_NAME
    ;-----------------------------------------------------------------------
        CHK_PSW:
            CMP     DI,10
            JE      LOGIN_SUCCESSFUL        
            MOV     AL,CorrectPassword[DI]
            CMP     AL,Password_ADATA[DI]
            JE      NPSW
            JNE     LOGIN_ERROR     ; ERROR: Jmup out of range
        NPSW:
            INC     DI
            JMP     CHK_PSW
    ;-----------------------------------------------------------------------
    CHECK_REGISTER_CORRECT_OR_NOT:
        MOV     DI,0    ;use for loop to check the password
        CHK_REGISTER_PSW:
            CMP     DI,10
            JE      REGISTER_SUCCESSFUL     ; DONE
            MOV     AL,ConfirmPassword[DI]
            CMP     AL,RegisterPassword[DI]
            JE      NEXT_REGISTER_PSW
            JNE     REGISTER_NEWUSER_ERROR  ; DONE
        NEXT_REGISTER_PSW:
            INC     DI
            JMP     CHK_REGISTER_PSW
    ;-----------------------------------------------------------------------
    CHECK_LOGIN_REGISTER:
        MOV     RegisterCount,0     ; turn off the register count
        MOV     SI,0
        MOV     DI,0

        CHK_REGISTER_NAME:
            CMP     SI,5
            JE      CHK_REGISTER_PASSWORD
            MOV     AL,RegisterUsername[SI]
            CMP     AL,Username_ADATA[SI]
            JE      NR_NAME
            JNE     CHECK_LOGIN
        NR_NAME:
            INC     SI
            JMP     CHK_REGISTER_NAME
        ;-----------------------------------------------------------------------
        CHK_REGISTER_PASSWORD:
            CMP     DI,10
            JE      LOGIN_SUCCESSFUL
            MOV     AL,RegisterPassword[DI]
            CMP     AL,Password_ADATA[DI]
            JE      NR_PSW
            JNE     CHECK_LOGIN     ; may be same user name but different password

        NR_PSW:
            INC     DI 
            JMP     CHK_REGISTER_PASSWORD
    ;-----------------------------------------------------------------------
    REGISTER_SUCCESSFUL: 
        MOV     AH,09H
        LEA     DX,RegisterConfirmMSG   ; display create successful message
        INT     21H

        MOV     AH,01H      ; have a break to let user see about message, 
        INT     21H         ; then user input any key will jump back to login screen
        MOV     RegisterCount,1 ; to turn on the register checking  

        JMP     JMP_TO_LOGIN_PAGE
    ;-----------------------------------------------------------------------
    LOGIN_SUCCESSFUL:
        RET
    ;-----------------------------------------------------------------------
        LOGIN_ERROR:
        DEC     LoginCount              ; login chance - 1
        CMP     LoginCount,0
        JE      EXIT_LOGIN

        MOV     AH,09H
        LEA     DX,InvalidMessage       ; display error message
        INT     21H
        LEA     DX,ChanceMessage_P1    ; display how many chances left
        INT     21H

        MOV     AH,02H
        MOV     DL,LoginCount           ; DL=chances left 
        ADD     DL,30H                  ; add 30H to display as "2" in ASCII code
        INT     21H

        MOV     AH,09H
        LEA     DX,ChanceMessage_P2
        INT     21H

        JMP     LOGIN_AGAIN
    ;-----------------------------------------------------------------------
    REGISTER_NEWUSER_ERROR: 
        DEC     ConfirmCount    ; confirm count (chance) - 1
        CMP     ConfirmCount,0
        JE      EXIT_REGISTER

        MOV     AH,09H
        LEA     DX,RegisterErrorMSG ; display message that 2 password are not same
        INT     21H

        MOV     AH,09H
        LEA     DX,ChanceMessage_P1 ; display how many chance left 
        INT     21H

        MOV     AH,02H
        MOV     DL,ConfirmCount
        ADD     DL,30H
        INT     21H

        MOV     AH,09H
        LEA     DX,ChanceMessage_P2
        INT     21H

        JMP     CONFIRM_AGAIN
    ;-----------------------------------------------------------------------

    EXIT_LOGIN:
        MOV     AH,09H
        LEA     DX,ExitProgramMessage
        INT     21H
        JMP     EXIT_PROGRAM
    ;-----------------------------------------------------------------------
    EXIT_REGISTER:
        MOV     AH,09H
        LEA     DX,RegisterExitMSG  ; display fail to create new account message
        INT     21H
        MOV     AH,01H      ; have a break to let user see about message, 
        INT     21H         ; then user input any key will jump back to login screen
        XOR     AL,AL       ; clear AL
        
        XOR     CX,CX
        MOV     CX,5
        MOV     SI,0
        CLEAR_REGISTER_NAME:
            MOV     AL,RegisterUsername[SI]
            XOR     RegisterUsername[SI],AL
            INC     SI
            LOOP    CLEAR_REGISTER_NAME
        
        XOR     CX,CX
        MOV     CX,10
        MOV     SI,0
        CLEAR_REGISTER_PASSWORD:
            MOV     AL,RegisterPassword[SI]
            XOR     RegisterPassword[SI],AL
            INC     SI
            LOOP    CLEAR_REGISTER_PASSWORD
        
        XOR     CX,CX
        MOV     CX,10
        MOV     SI,0
        CLEAR_CONFIRM_PASSWORD:
            MOV     AL,ConfirmPassword[SI]
            XOR     ConfirmPassword[SI],AL
            INC     SI
            LOOP    CLEAR_CONFIRM_PASSWORD

        JMP     JMP_TO_LOGIN_PAGE

    JMP_TO_LOGIN_PAGE:
        XOR     AL,AL       ; clear AL
        MOV     AX,3    ; clear screen
        INT     10H     ; call interrupt service
        
        MOV     AH,09H      ; request display string
        LEA     DX,Divider  ; display the divider
        INT     21H         ; call interrupt service

        MOV     AH,09H
        LEA     DX,StartPageMessage_1       ; welcome message
        INT     21H

        JMP     CHOICE_AGAIN
LOGIN ENDP

MAIN_MENU PROC
    ; Display menu options
    MOV DX, OFFSET MenuOptions ; Load the offset of the menu options string
    MOV AH, 09H                ; DOS function to display a string
    INT 21H                    ; Call DOS interrupt

    ; Get user input
    MOV AH, 01H                ; DOS function to read a character from the keyboard
    INT 21H                    ; Call DOS interrupt
    SUB AL, '0'                ; Convert ASCII to numeric value (0-9)

    ; Handle user selection
    CMP AL, 1                  ; Compare input with 1
    JE PURCHASE                ; Jump to PURCHASE if input is 1
    CMP AL, 2                  ; Compare input with 2
    JE EDIT_PRICE              ; Jump to EDIT_PRICE if input is 2
    CMP AL, 3                  ; Compare input with 3
    JE ADD_COUPON              ; Jump to ADD_COUPON if input is 3
    CMP AL, 4                  ; Compare input with 4
    JE LOGOUT                  ; Jump to LOGOUT if input is 4

    JMP MAIN_MENU              ; Repeat menu if input is invalid

MAIN_MENU ENDP

EDIT_PRODUCT_PRICE PROC
        ; Open product.txt file
        MOV DX, OFFSET product.txt    ; Load file name
        MOV AH, 3DH                    ; DOS function: Open file
        MOV AL, 0                      ; Open for read only
        INT 21H                        ; DOS interrupt
        JC FILE_ERROR                  ; Jump if error (Carry Flag set)
        MOV BX, AX                     ; File handle

        ; Read file content into memory
        MOV AH, 3FH                    ; DOS function: Read file
        MOV CX, 100                    ; Read up to 100 bytes
        MOV DX, OFFSET ProductBuffer   ; Buffer to store file data
        INT 21H                        ; DOS interrupt

        ; Close file
        MOV AH, 3EH                    ; DOS function: Close file
        INT 21H                        ; DOS interrupt

        ; Display product list
        MOV DX, OFFSET ProductBuffer   ; Load product buffer
        CALL DISPLAY_PRODUCTS          ; Call function to display products

        ; Edit product price
        CALL GET_USER_SELECTION        ; Get product selection from user
        CMP AL, '1'                    ; Check if user selects product 1
        JE EDIT_PRICE_1                ; Jump if true
        CMP AL, '2'                    ; Check if user selects product 2
        JE EDIT_PRICE_2                ; Jump if true
        CMP AL, '3'                    ; Check if user selects product 3
        JE EDIT_PRICE_3                ; Jump if true
        CMP AL, '4'                    ; Check if user selects product 4
        JE EDIT_PRICE_4                ; Jump if true

        ; Update the selected product price
    EDIT_PRICE_1:
    MOV DX, OFFSET EnterNewPricePrompt  ; Prompt for new price
    MOV AH, 09H                         ; DOS function: Display string
    INT 21H                             ; DOS interrupt

    ; Read new price from user
    MOV AH, 0AH                         ; DOS function: Buffered input
    MOV DX, OFFSET InputBuffer          ; Buffer to store input
    INT 21H                             ; DOS interrupt

    ; Convert ASCII input to a number (3-digit support)
    MOV SI, OFFSET InputBuffer + 2      ; Start after length byte
    XOR BX, BX                          ; Clear BX for number
    XOR CX, CX                          ; Clear CX for digit count

    ReadNextDigit:
        MOV AL, [SI]                        ; Load character from buffer
        CMP AL, 0DH                         ; Check for Enter key (Carriage Return)
        JE StorePrice1                      ; If Enter, store the price

        SUB AL, '0'                         ; Convert ASCII to number
        MOV AH, 0                           ; Clear AH for multiplication
        MOV CX, 10                          ; Base 10 for digit shifting
        MUL CX                              ; Multiply BX (current total) by 10
        ADD BL, AL                          ; Add new digit
        INC SI                              ; Move to next character
        JMP ReadNextDigit                   ; Continue reading digits

    StorePrice1:
        ; Store new price in ProductBuffer
        MOV BYTE PTR ProductBuffer + 32, BL ; Assuming price for product 1 is at offset 32
        JMP SAVE_PRICES                     ; Jump to save prices                    

    EDIT_PRICE_2:
    MOV DX, OFFSET EnterNewPricePrompt  ; Prompt for new price
    MOV AH, 09H                         ; DOS function: Display string
    INT 21H                             ; DOS interrupt

    ; Read new price from user
    MOV AH, 0AH                         ; DOS function: Buffered input
    MOV DX, OFFSET InputBuffer          ; Buffer to store input
    INT 21H                             ; DOS interrupt

    ; Convert ASCII input to a number (3-digit support)
    MOV SI, OFFSET InputBuffer + 2      ; Start after length byte
    XOR BX, BX                          ; Clear BX for number
    XOR CX, CX                          ; Clear CX for digit count

    ReadNextDigit:
        MOV AL, [SI]                        ; Load character from buffer
        CMP AL, 0DH                         ; Check for Enter key (Carriage Return)
        JE StorePrice1                      ; If Enter, store the price

        SUB AL, '0'                         ; Convert ASCII to number
        MOV AH, 0                           ; Clear AH for multiplication
        MOV CX, 10                          ; Base 10 for digit shifting
        MUL CX                              ; Multiply BX (current total) by 10
        ADD BL, AL                          ; Add new digit
        INC SI                              ; Move to next character
        JMP ReadNextDigit                   ; Continue reading digits

    StorePrice2:
        ; Store new price in ProductBuffer
        MOV BYTE PTR ProductBuffer + 32, BL ; Assuming price for product 1 is at offset 32
        JMP SAVE_PRICES                     ; Jump to save prices 

    EDIT_PRICE_3:
    MOV DX, OFFSET EnterNewPricePrompt  ; Prompt for new price
    MOV AH, 09H                         ; DOS function: Display string
    INT 21H                             ; DOS interrupt

    ; Read new price from user
    MOV AH, 0AH                         ; DOS function: Buffered input
    MOV DX, OFFSET InputBuffer          ; Buffer to store input
    INT 21H                             ; DOS interrupt

    ; Convert ASCII input to a number (3-digit support)
    MOV SI, OFFSET InputBuffer + 2      ; Start after length byte
    XOR BX, BX                          ; Clear BX for number
    XOR CX, CX                          ; Clear CX for digit count

    ReadNextDigit:
        MOV AL, [SI]                        ; Load character from buffer
        CMP AL, 0DH                         ; Check for Enter key (Carriage Return)
        JE StorePrice1                      ; If Enter, store the price

        SUB AL, '0'                         ; Convert ASCII to number
        MOV AH, 0                           ; Clear AH for multiplication
        MOV CX, 10                          ; Base 10 for digit shifting
        MUL CX                              ; Multiply BX (current total) by 10
        ADD BL, AL                          ; Add new digit
        INC SI                              ; Move to next character
        JMP ReadNextDigit                   ; Continue reading digits

    StorePrice3:
        ; Store new price in ProductBuffer
        MOV BYTE PTR ProductBuffer + 32, BL ; Assuming price for product 1 is at offset 32
        JMP SAVE_PRICES                     ; Jump to save prices 

    EDIT_PRICE_4:
    MOV DX, OFFSET EnterNewPricePrompt  ; Prompt for new price
    MOV AH, 09H                         ; DOS function: Display string
    INT 21H                             ; DOS interrupt

    ; Read new price from user
    MOV AH, 0AH                         ; DOS function: Buffered input
    MOV DX, OFFSET InputBuffer          ; Buffer to store input
    INT 21H                             ; DOS interrupt

    ; Convert ASCII input to a number (3-digit support)
    MOV SI, OFFSET InputBuffer + 2      ; Start after length byte
    XOR BX, BX                          ; Clear BX for number
    XOR CX, CX                          ; Clear CX for digit count

    ReadNextDigit:
        MOV AL, [SI]                        ; Load character from buffer
        CMP AL, 0DH                         ; Check for Enter key (Carriage Return)
        JE StorePrice1                      ; If Enter, store the price

        SUB AL, '0'                         ; Convert ASCII to number
        MOV AH, 0                           ; Clear AH for multiplication
        MOV CX, 10                          ; Base 10 for digit shifting
        MUL CX                              ; Multiply BX (current total) by 10
        ADD BL, AL                          ; Add new digit
        INC SI                              ; Move to next character
        JMP ReadNextDigit                   ; Continue reading digits

    StorePrice4:
        ; Store new price in ProductBuffer
        MOV BYTE PTR ProductBuffer + 32, BL ; Assuming price for product 1 is at offset 32
        JMP SAVE_PRICES                     ; Jump to save prices 

        JMP MAIN_MENU                  ; Return to main menu

EDIT_PRODUCT_PRICE ENDP

; Data section
FileName DB 'product.txt', 0
ProductBuffer DB 100 DUP(0)       ; Buffer to store product data

; Display function
DISPLAY_PRODUCTS PROC
    MOV DX, OFFSET SelectPrompt   ; Load prompt message
    MOV AH, 09H                   ; DOS function: Display string
    INT 21H                       ; Call DOS interrupt

    MOV AH, 01H                   ; DOS function: Read character from keyboard
    INT 21H                       ; Call DOS interrupt
    SUB AL, '0'                   ; Convert ASCII to numeric value (0-9)
    RET
DISPLAY_PRODUCTS ENDP

; Get user selection function
GET_USER_SELECTION PROC
    MOV DX, OFFSET EditPrompt     ; Load prompt message
    MOV AH, 09H                   ; DOS function: Display string
    INT 21H                       ; Call DOS interrupt

    MOV AH, 01H                   ; DOS function: Read character from keyboard
    INT 21H                       ; Call DOS interrupt
    SUB AL, '0'                   ; Convert ASCII to numeric value (0-9)
    MOV PriceInput, AL            ; Store new price input
    RET
GET_USER_SELECTION ENDP

; Save function
SAVE_PRODUCT_PRICES PROC
    MOV DX, OFFSET FileName       ; Load file name
    MOV AH, 3CH                   ; DOS function: Create or truncate file
    MOV CX, 0                     ; Normal file
    INT 21H                       ; DOS interrupt
    JC FILE_ERROR                 ; Jump if error (Carry Flag set)
    MOV BX, AX                    ; Save file handle

    ; Write updated prices to file
    MOV AH, 40H                   ; DOS function: Write to file
    MOV CX, 100                   ; Number of bytes to write
    MOV DX, OFFSET ProductBuffer  ; Buffer containing data to write
    INT 21H                       ; DOS interrupt

    ; Close file
    MOV AH, 3EH                   ; DOS function: Close file
    MOV BX, AX                    ; Use file handle
    INT 21H                       ; DOS interrupt

    RET
SAVE_PRODUCT_PRICES ENDP

; Error handling
FILE_ERROR:
    MOV DX, OFFSET ErrorMsg       ; Load error message
    MOV AH, 09H                   ; DOS function: Display string
    INT 21H                       ; DOS interrupt
    JMP MAIN_MENU                 ; Return to main menu


 END MAIN

