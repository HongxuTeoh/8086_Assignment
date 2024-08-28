prnstr macro s
        mov ah, 09h
        lea dx, s
        int 21h
        endm
prnbt macro b
	mov ah,02h
	mov dl,b
	int 21h
	endm
.MODEL SMALL
.STACK 64
.DATA
   S1 DB "Enter String to be printed(max 50words) : $"
   S2 DB 0dh, 0ah, "I/O Error or Paper out...$"
   S3 DB "String to be printed : $"
   S4 DB 13,10,"Preview Sentence to be printed : $"
   S5 DB 13,10,"Total number of words to be printed: $"
   S6 DB 13,10,"Total number of characters to be printed: $"
   S7 DB 13,10,"Press enter to proceed to print$"
   q DB 0
   r DB 0
   ten DB 10
   SUM DB 0


   ARRAY LABEL BYTE
   MAX DB 50
   ACT DB ?
   ARRAYDATA DB 50 DUP("$")


.CODE
MAIN PROC
  MOV AX,@DATA
  MOV DS,AX




;---GET INPUT
  ;---OUTPUT S1
start:
        prnstr s1
        mov ah, 0ah
        lea dx, array
        int 21h

	cbw

	prnstr s4
	prnstr arraydata
	prnstr s5


mov si,0
mov cl,act
TOTALL:
	inc sum
	loop TOTALL

;---SPLIT SUM
	mov al,sum
	mov ah,0
	div ten

	mov q,al
	mov r,ah
	add q,30h
	add r,30h

	prnbt q
	prnbt r
	
	prnstr s7
	
	mov ah,01h
	int 21h
	
	
	;---initiliaze printer to port lpt1
        mov si, offset array + 2
        mov ch, 00h
        mov cl, byte ptr [si-1]

        mov dx, 0000h


again :
        mov ah, 02h
        int 17h

        test ah, 00101001b
	jz cont

        prnstr s2
  
        jmp again



;---PRINT
cont :	
        mov ah, 00h
        mov dx, 0000h
next :
        mov ah, 00h
        mov al, [si]
        int 17h
        inc si
        loop next

        mov ax, 4c00h
        int 21h

MAIN ENDP
  END MAIN