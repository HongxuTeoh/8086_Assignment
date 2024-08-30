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

.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

    CALL MAIN_MENU  ; Call the MAIN_MENU procedure
    ; Further processing can be done here after returning from MAIN_MENU
    ; (e.g., exit the program or perform other actions)
    MOV AH, 4CH     ; DOS function to exit program
    INT 21H         ; Call DOS interrupt to terminate the program

MAIN ENDP

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

