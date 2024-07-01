# mumuse-asm
x86 32bit windows assembly - quelques fonctions utiles et l'implementation d'une lib md5

Utilisation de https://github.com/rwfpl/rewolf-md5/blob/master/nasm/rewolf_md5.inc


Fonction strlen
---------------

Calcule la longueur d'une chaîne de caractères.

#### Utilisation

* Adresse de la chaîne de caractères dans ESI
* La valeur de retour est stockée dans EAX

#### Convention d'appel
```assembly
mov     esi, string_address
call    strlen
```
#### Registres modifiés

* EAX

Fonction itoa
-------------

Convertit un nombre en une chaîne de caractères ASCII.

#### Utilisation

* Nombre dans EAX
* Adresse du tampon de résultat dans EDI (12 octets suffisent)
* La longueur de la chaîne de résultat sera stockée dans EAX sans le zéro final

#### Convention d'appel
```assembly
mov     eax, nombre
mov     edi, result_buffer_address
call    itoa
```
#### Registres modifiés

* EAX

Fonction getArg
---------------

Récupère le nième argument de l'application.

#### Utilisation

* Numéro d'argument dans EAX (1 pour le premier argument, 2 pour le deuxième, etc.)
* Retourne : pointeur de chaîne dans ESI, longueur de l'argument dans EAX

#### Convention d'appel
```assembly
mov     eax, n  ; où n est le numéro d'argument
call    getArg
```
#### Registres modifiés

* ESI, EAX

Fonction byte\_to\_hex
-----------------------

Convertit un octet en une chaîne hexadécimale de 2 caractères.

#### Utilisation

* Octet dans AL
* Résultat dans AH-AL (2 octets)

#### Convention d'appel
```assembly
mov     al, byte
call    byte_to_hex
```
#### Registres modifiés

* AX

Fonction buffer\_to\_hex
-------------------------

Convertit un tampon en une chaîne hexadécimale.

#### Utilisation

* Tampon source dans ESI
* Tampon de destination dans EDI
* Taille du tampon source dans ECX
* Fonction byte\_to\_hex requise

#### Convention d'appel
```assembly
mov     esi, source
mov     edi, destination
mov     ecx, source_size
call    buffer_to_hex
```
#### Registres modifiés

* Aucun
* Le drapeau de direction sera défini sur 0

Note
----

Les commentaires dans les fonctions sont en anglais.