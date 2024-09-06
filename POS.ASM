.MODEL SMALL
.STACK 64

.DATA
; ------ Purchase  ------ ;
    MenuOptions DB 13,10,'1) Purchase'
                DB 13,10,'2) Edit Product Price'
                DB 13,10,'3) Add Coupon'
                DB 13,10,'4) Logout$'

    ItemPrompt DB 13,10,'Items:'
                DB 13,10,'1)VS Pro' 
                DB 13,10,'2)Win10'
                DB 13,10,'3)Win11'
                DB 13,10,'4)Adobe'
                DB 13,10,'5)Back: $'

    QuantityPrompt DB 13,10,'Quantity (1-9): $'
    ContinuePrompt DB 13,10,'Continue? (Y/N): $'
    CouponPrompt DB 13,10,'Coupon? (Y/N): $'
    SubtotalMsg DB 13,10,'Subtotal: $'
    DiscountMsg DB 13,10,'After Discount, Total: $'
    TotalMsg DB 13,10,'Total: $'
    InvalidMsg DB 13,10,'Invalid choice!$'
    FileName DB 'product.txt', 0

    SelectPrompt DB 13,10,'Select product number to edit (1-4): $'
    ProductBuffer DB 100 DUP(0)       ; Buffer to store product data
    InputBuffer DB 5, 0, 5 DUP(0)     ; Input buffer: max 3 digits + Enter key
    EnterNewPricePrompt DB 13,10,'Enter new price (up to 3 digits): $'
    ErrorMsg DB 13,10,'Error opening or writing file!$', 0

    Prices DW 500, 120, 150, 300   ; Prices for the items
    Subtotal DW 0                  ; Subtotal for the current purchase
    Total DW 0                     ; Total across all purchases
    CouponDiscount DW 10           ; Discount percentage

; ------ Purchase  ------ ;

; ---------Payment --------;
    CashPrompt DB 'Enter cash amount: $'
    ChangeMsg DB 'Change: $'
    InsufficientCashMsg DB '[ERROR] Insufficient cash! Please try again.$'
    InputBuffer DB 5, 0, 5 DUP(0)  ; Input buffer: max 5 digits + Enter key

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

;----------------------------------------------------------------------- main menu
MAIN_MENU PROC
    ; Display menu options
    MOV DX, OFFSET MenuOptions ; Load the offset of the menu options string
    MOV AH, 09H                ; DOS function to display a string
    INT 21H                    ; Call DOS interrupt

    MOV AH,09H
    LEA DX, NewLine
    INT 21H

    ; Get user input
    MOV AH, 01H                ; DOS function to read a character from the keyboard
    INT 21H                    ; Call DOS interrupt
    SUB AL, '0'                ; Convert ASCII to numeric value (0-9)

    ; Handle user selection
    CMP AL, 1                  ; Compare input with 1
    JE PURCHASE_S              ; Jump to PURCHASE if input is 1
    CMP AL, 2                  ; Compare input with 2
    JE EDIT_PRODUCT_PRICE_S      ; Jump to EDIT_PRODUCT_PRICE if input is 2
    CMP AL, 3                  ; Compare input with 3
    JE ADD_COUPON_S              ; Jump to ADD_COUPON if input is 3
    CMP AL, 4                  ; Compare input with 4
    JE LOGOUT_S                  ; Jump to LOGOUT if input is 4

    JMP MAIN_MENU              ; Repeat menu if input is invalid

    PURCHASE_S:
        CALL Purchase
    EDIT_PRODUCT_PRICE_S:
        CALL EDIT_PRODUCT_PRICE
    ADD_COUPON_S:
        CALL ADD_COUPON
    LOGOUT_S:
        CALL LOGOUT

MAIN_MENU ENDP
;----------------------------------------------------------------------- main menu

;----------------------------------------------------------------------- purchase subroutine
ContinuePurchaseConditionally PROC
    JE Purchase
    RET
ContinuePurchaseConditionally ENDP

Purchase PROC
    MOV DX, OFFSET ItemPrompt
    MOV AH, 9
    INT 21h

    MOV AH,09H
    LEA DX, NewLine
    INT 21H

        ; Get item choice (AL will hold the user's item choice)
    MOV AH, 1
    INT 21h
    SUB AL, '0'
    CALL InvalidCondition        ; Check if item choice is valid

    ; If the user selected option 5, exit purchase
    CMP AL, 5
    CALL EndPurchaseConditionally

    ; At this point, AL contains the item choice (1-4).
    ; Calculate the correct index for the price array.
    
    XOR AH, AH            ; Clear AH to ensure AX is clean
    MOV BX, AX            ; Move item choice (in AL, now zero-based index) to BX
    DEC BX                ; Convert to zero-based index for the price array
    SHL BX, 1             ; Multiply by 2 because each price is stored as a word (2 bytes)
                          ; BX now contains the index to access the correct price

    ; Get quantity of the item
    MOV DX, OFFSET QuantityPrompt
    MOV AH, 9
    INT 21h

    MOV AH, 1
    INT 21h
    SUB AL, '0'           ; Convert ASCII to numeric
    XOR AH, AH            ; Ensure AX holds the quantity, clearing AH to avoid issues with larger numbers

    ; Retrieve price for the selected item and calculate subtotal
    MOV CX, Prices[BX]    ; Move the price of the selected item into CX
    MUL CX                ; Multiply quantity (in AX) by the price (in CX)
                          ; AX now holds the result of price * quantity
                          
    ADD [Subtotal], AX     ; Add the result to the running subtotal

    ; Display current subtotal
    MOV DX, OFFSET SubtotalMsg
    MOV AH, 9
    INT 21h
    MOV AX, [Subtotal]
    CALL DisplayNumber
    MOV DL, '$'
    MOV AH, 2
    INT 21h

    ; Ask to continue
    MOV DX, OFFSET ContinuePrompt
    MOV AH, 9
    INT 21h

    MOV AH, 1
    INT 21h
    CALL CheckContinueCondition
    ; Add subtotal to total
    MOV AX, [Subtotal]
    ADD [Total], AX
    MOV WORD PTR [Subtotal], 0  ; Reset subtotal for next purchase

    ; Ask for coupon
    MOV DX, OFFSET CouponPrompt
    MOV AH, 9
    INT 21h

    MOV AH, 1
    INT 21h
    CALL CheckCouponCondition
    JMP DisplayTotal

EndPurchaseConditionally PROC
    CMP AL, 5
    JE EndPurchase
    RET
EndPurchaseConditionally ENDP

CheckContinueCondition PROC
    CMP AL, 'Y'
    CALL ContinuePurchaseConditionally
    CMP AL, 'N'
    CALL InvalidConditionally
    RET
CheckContinueCondition ENDP


InvalidConditionally PROC
    JNE Invalid
    RET
InvalidConditionally ENDP

CheckCouponCondition PROC
    CMP AL, 'Y'
    CALL ApplyCouponConditionally
    RET
CheckCouponCondition ENDP

ApplyCouponConditionally PROC
    JE ApplyCoupon
    RET
ApplyCouponConditionally ENDP

EndPurchase:
    RET
Purchase ENDP
;----------------------------------------------------------------------- purchase subroutine

;----------------------------------------------------------------------- product price
EDIT_PRODUCT_PRICE PROC
        
EDIT_PRODUCT_PRICE ENDP

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

GET_USER_SELECTION ENDP

; Save function
SAVE_PRODUCT_PRICES PROC

SAVE_PRODUCT_PRICES ENDP

; Error handling
FILE_ERROR:
    MOV DX, OFFSET ErrorMsg       ; Load error message
    MOV AH, 09H                   ; DOS function: Display string
    INT 21H                       ; DOS interrupt
    JMP MAIN_MENU                 ; Return to main menu

;----------------------------------------------------------------------- add coupon subroutine
ADD_COUPON PROC
; Coupon application
RET                          ; Return back to the main menu
ADD_COUPON ENDP
ApplyCoupon PROC
    MOV AX, [Total]
    MOV BX, [CouponDiscount]
    MUL BX
    MOV BX, 100
    DIV BX
    SUB [Total], AX

    ; Display total after discount
    MOV DX, OFFSET DiscountMsg
    MOV AH, 9
    INT 21h
    MOV AX, [Total]
    CALL DisplayNumber
    MOV DL, '$'
    MOV AH, 2
    INT 21h
    CALL Payment            ; After applying coupon, display total
ApplyCoupon ENDP

Payment PROC
    ; Prompt for cash input
    MOV DX, OFFSET CashPrompt
    MOV AH, 9
    INT 21h

    ; Get cash input from user
    MOV AH, 0AH                ; Buffered input for cash (in decimal)
    MOV DX, OFFSET InputBuffer  ; Buffer to store input
    INT 21h

    ; Convert ASCII input to a number (AX = cash amount)
    XOR CX, CX                  ; Clear CX (will hold the cash input value)
    MOV SI, OFFSET InputBuffer + 2 ; Start after length byte
    XOR BX, BX                  ; Clear BX (for calculation)

    ReadCashDigit:
        MOV AL, [SI]            ; Load character
        CMP AL, 0DH             ; Check for Enter key (Carriage Return)
        JE CalculateChange      ; If Enter, process the input

        SUB AL, '0'             ; Convert ASCII to digit
        MOV AH, 0               ; Clear AH
        MOV BX, 10              ; Base 10 multiplication
        MUL BX                  ; AX = AL * 10
        ADD CX, AX              ; Accumulate the result in CX (cash input)
        INC SI                  ; Move to next character
        JMP ReadCashDigit       ; Continue reading input

    CalculateChange:
    MOV AX, CX                  ; AX = Cash amount from user
    MOV BX, [Total]             ; BX = Total after discount

    CMP AX, BX                  ; Compare cash amount with total price
    JB InsufficientCash         ; If cash is less than total, show an error

    ; Cash is sufficient, calculate change
    SUB AX, BX                  ; AX = Cash - Total (the change)
    
    ; Display change to the user
    MOV DX, OFFSET ChangeMsg    ; Load the "Change: " message
    MOV AH, 9
    INT 21h
    CALL DisplayNumber          ; Display the change amount
    MOV DL, '$'
    MOV AH, 2
    INT 21h
    RET                         ; End of Payment procedure

InsufficientCash:
    ; Display insufficient cash error
    MOV DX, OFFSET InsufficientCashMsg
    MOV AH, 9
    INT 21h
    JMP Payment                 ; Retry payment if cash is insufficient

Payment ENDP
    

;----------------------------------------------------------------------- add coupon subroutine
;----------------------------------------------------------------------- logout subroutine
LOGOUT PROC
    ; Code for logging out (if needed)
    MOV AH, 4CH                  ; DOS function to terminate program
    INT 21H                      ; Call DOS interrupt to exit
LOGOUT ENDP
;----------------------------------------------------------------------- logout subroutine
; -------------------------------------------------------------------------
; Invalid condition handling
InvalidCondition PROC
    CMP AL, 1
    JB Invalid
    CMP AL, 4
    JA Invalid
    RET
InvalidCondition ENDP

; -------------------------------------------------------------------------
; Invalid input handling
Invalid PROC
    MOV DX, OFFSET InvalidMsg
    MOV AH, 9
    INT 21h
    JMP MAIN_MENU
Invalid ENDP

; -------------------------------------------------------------------------
; Helper routine to display the number in AX
DisplayNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10         ; Prepare to divide by 10 to get digits
    XOR CX, CX         ; CX will count digits

NextDigit:
    XOR DX, DX         ; Clear DX for division
    DIV BX             ; Divide AX by 10, quotient in AX, remainder in DX
    PUSH DX            ; Push remainder (digit) to the stack
    INC CX             ; Count digits
    TEST AX, AX        ; Check if quotient is 0
    JNZ NextDigit      ; If not zero, continue extracting digits

PrintDigits:
    POP DX             ; Get digit
    ADD DL, '0'        ; Convert it to ASCII
    MOV AH, 2          ; DOS print character function
    INT 21h
    LOOP PrintDigits

    POP DX
    POP CX
    POP BX
    POP AX
    RET
DisplayNumber ENDP

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
DisplayTotal PROC
    MOV DX, OFFSET TotalMsg
    MOV AH, 9
    INT 21h
    MOV AX, [Total]
    CALL DisplayNumber
    MOV DL, '$'
    MOV AH, 2
    INT 21h
    CALL PAYMENT    ; After displaying total, go back to change to payment
DisplayTotal ENDP

; -------------------------------------------------------------------------


 END MAIN
;----------------------------------------------------------------------- product price
