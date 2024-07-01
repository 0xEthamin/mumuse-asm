; Requires linking with: kernel32.lib

global _start

extern _GetCommandLineA@0
extern _GetStdHandle@4
extern _WriteConsoleA@20
extern _ExitProcess@4

STD_OUTPUT_HANDLE equ -11
ERROR_LEN equ 25

section .data
    error_str db 'Une erreur est survenue !', 0

section .bss
    result_ascii: resb 12   ; 1 sign - 10 digits - null char -> 12 bytes for a 32-bit number
    written: resd 1         ; 32bits required by WriteConsoleA
    hash: resb 16           ; 128 bits required by MD5
    hash_hex: resb 32       ; hex string type - 2x larger

section .text
    global _start

%include 'rewolf_md5.inc'
    

strlen:
;----------------------------------------------------------------------------
;|   Calculate the length of a string -> EAX                                |
;----------------------------------------------------------------------------
;|   Usage:                                                                 |
;|   ======                                                                 |
;|                                                                          |
;|   String pointer in ESI                                                  |
;|   The return value is stored in EAX                                      |
;|                                                                          |
;|   Calling convention:                                                    |
;|                                                                          |
;|       mov     esi, string_address                                        |
;|       call    strlen                                                     |
;|                                                                          |
;|   Modified registers: eax                                                |
;|   Stack is automatically cleared                                         |
;----------------------------------------------------------------------------

    push ebp
    mov ebp, esp

    push edi
    push esi
    push ecx
    
    mov edi, esi
    mov ecx, -1
    xor al, al
    cld
    repne scasb ;SCASB compares al to [edi] then inc/dec edi with DF
                ;REPNE repeats as long as NE or ECX!=0, dec ecx
    test ecx, ecx
    jz error
    not ecx
    dec ecx
    mov eax, ecx 

    pop ecx
    pop esi
    pop edi

    mov esp, ebp
    pop ebp

    ret



itoa:
;----------------------------------------------------------------------------
;|   Convert a number to an ASCII string -> EAX                             |
;----------------------------------------------------------------------------
;|   Usage:                                                                 |
;|   ======                                                                 |
;|                                                                          |
;|   Number in EAX                                                          |
;|   Result buffer pointer in EDI (12 bytes is enough)                      |
;|   The length of the result string will be stored in EAX without final 0  |
;|                                                                          |
;|   Calling convention:                                                    |
;|                                                                          |
;|       mov     eax, nombre                                                |
;|       mov     edi, result_buffer_address                                 |
;|       call    itoa                                                       |
;|                                                                          |
;|   Modified registers: eax                                                |
;|   Stack is automatically cleared                                         |
;----------------------------------------------------------------------------

    push ebp
    mov ebp, esp

    push esi
    push ebx
    push edx
    push ecx
    push edi

    xor esi, esi
    test eax, eax   ;check if the number is negative
    jns .positive
    neg eax
    mov byte [edi], '-'
    inc esi         ;ESI is 0 or 1 depending on sign

    .positive:
        mov ebx, 10
        xor ecx, ecx
        .divide_loop:
            xor edx, edx
            div ebx     ; divide EAX by EBX, result in EAX, remainder in EDX
            add dl, '0'
            push edx
            inc ecx ; ecx contains the number of characters of the number 
            test eax, eax
            jnz .divide_loop
        
        mov eax, esi
        add eax, ecx ; eax contains string size (sign)+number 
        
        add edi, esi
        .store_loop:
            pop edx
            mov [edi], edx
            inc edi
            loop .store_loop
            mov byte [edi+eax+1], 0

    pop edi
    pop ecx
    pop edx
    pop ebx
    pop esi

    mov esp, ebp
    pop ebp    
    ret

getArg:
;----------------------------------------------------------------------------
;|   Get the nth argument of the app -> ESI & EAX                           |
;----------------------------------------------------------------------------
;|   Usage:                                                                 |
;|   ======                                                                 |
;|                                                                          |
;|   Argument number in EAX (1 for first argument, 2 for second, etc.)      |
;|   Returns: String pointer in ESI, Arg length in EAX                      |
;|                                                                          |
;|   Calling convention:                                                    |
;|                                                                          |
;|       mov     eax, n  ; where n is the argument number                   |
;|       call    getArg                                                     |
;|                                                                          |
;|   Modified registers: ESI, EAX                                           |
;|   Stack is automatically cleared                                         |
;----------------------------------------------------------------------------

    push ebp
    mov ebp, esp

    push edi
    push ebx
    push ecx

    mov ebx, eax
    mov ecx, -1
    call _GetCommandLineA@0
    test eax, eax
    jz error ; error during GetCommandLineA
    mov esi, eax

    .skip_spaces:
        lodsb
        test al,al
        jz .end_of_string
        cmp al, ' '
        je .skip_spaces

        dec esi
        inc ecx
        cmp ecx, ebx
        je .found_arg
    .find_end:
        lodsb 
        test al, al
        jz .end_of_string
        cmp al, ' '
        jne .find_end
        jmp .skip_spaces
    .found_arg:
        mov edi, esi
        .count:
            lodsb
            test al, al
            jz .found_end
            cmp al, ' '
            je .found_end
            jmp .count
    .end_of_string:
        xor eax, eax
        xor esi, esi
        jmp error

    .found_end:
        dec esi
        sub esi, edi ; esi now contains the length of the argument
        mov eax, esi
        mov esi, edi

    pop ecx
    pop ebx
    pop edi

    mov esp, ebp
    pop ebp    
    ret
    

error:
; print error message and quit
    push STD_OUTPUT_HANDLE
    call _GetStdHandle@4
  
    push 0
    push written
    push ERROR_LEN
    push error_str
    push eax
    call _WriteConsoleA@20
  
    jmp quit

quit:
    push 0
    call _ExitProcess@4


byte_to_hex:
;----------------------------------------------------------------------------
;|   Convert a byte to a 2-char hex string -> AX                            |
;----------------------------------------------------------------------------
;|   Usage:                                                                 |
;|   ======                                                                 |
;|                                                                          |
;|   Byte in AL                                                             |
;|   Result in AH-AL (2bytes)                                               |
;|                                                                          |
;|   Calling convention:                                                    |
;|                                                                          |
;|       mov     al, byte                                                   |
;|       call    byte_to_hex                                                |
;|                                                                          |
;|   Modified registers: ax                                                 |
;|   Stack is automatically cleared                                         |
;----------------------------------------------------------------------------
    mov ah, al
    and ah, 0Fh
    shr al, 4
    
    add al, '0'
    add ah, '0'
    cmp al, '9'
    jle .skip1
    add al, 'A' - '0' - 10
    .skip1:
        cmp ah, '9'
        jle .skip2
        add ah, 'A' - '0' - 10
    .skip2:
        ret

buffer_to_hex:
;----------------------------------------------------------------------------
;|   Convert a buffer to a hex string                                       |
;----------------------------------------------------------------------------
;|   Usage:                                                                 |
;|   ======                                                                 |
;|                                                                          |
;|   source buffer in ESI                                                   |
;|   dest buffer in EDI                                                     |
;|   source size in ecx                                                     |
;|                                                                          |
;|   byte_to_hex function required                                          |
;|   Calling convention:                                                    |
;|                                                                          |
;|       mov     esi, source                                                |
;|       mov     edi, destination                                           |
;|       mov     ecx, source_size                                           |
;|       call    buffer_to_hex                                              |
;|                                                                          |
;|   Modified registers: none                                               |
;|   Direction flag will be set to 0                                        |
;|   Stack is automatically cleared                                         |
;----------------------------------------------------------------------------
    push edi
    push ecx
    push esi
    push eax
    cld
    .convert_loop:
        mov al, [esi]
        call byte_to_hex
        stosw
        inc esi
        loop .convert_loop

    pop eax
    pop esi
    pop edi
    pop ecx
    ret


_start:

    mov eax, 1
    call getArg
    push eax
    push esi
    push hash
    call _rwf_md5
 
    mov esi, hash
    mov edi, hash_hex
    mov ecx, 16
    call buffer_to_hex

    push STD_OUTPUT_HANDLE
    call _GetStdHandle@4
  
    push 0
    push written
    push 32             ; length of the string to write
    push hash_hex       ; the string to write
    push eax            ; handle
    call _WriteConsoleA@20
  
    jmp quit
    