# mumuse-asm
x86 32bit windows assembly - quelques fonctions utiles et l'implementation d'une lib md5

Utilisation de https://github.com/rwfpl/rewolf-md5/blob/master/nasm/rewolf_md5.inc


fonction strlen
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

fonction itoa
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

fonction getArg:
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

fonction byte_to_hex:
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

fonction buffer_to_hex: (necessite byte_to_hex)
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