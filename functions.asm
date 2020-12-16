; PURPOSE: Contains common general-purpose functions
; LABELS: (as below)
SECTION "Functions", ROM0


; PURPOSE: Set a memory range to contain all zeros
; IN:
;  - hl: start address (inclusive)
;  - bc: number of bytes to zero out
; OUT:
;  - hl: address after the last byte which was zeroed out
;  - bc: 0
;  - a: 0
;  - flags: Z1 N0 H0 C0
; CYCLES: 12N + 7 (where N is number of bytes to be zeroed out)
ZeroMem:: ; loop: zero out each byte in range
    ld a, b
    or c
    ret z ; return if no bytes remain

    xor a ; (ld a, 0)

    ld [hl+], a ; zero out byte and move to next
    dec bc ; decrease bytes remaining

    jr ZeroMem
; end loop
; end ZeroMem


; PURPOSE: Copy a specified number of bytes
; IN:
;  - hl: source address
;  - de: destination address
;  - bc: number of bytes to be copied
; OUT:
;  - hl: address after the last byte in the source
;  - de: address after the last byte in the destination
;  - bc: 0
;  - a: 0
;  - flags: Z1 N0 H0 C0
; CYCLES: 15N + 7 (where N is number of bytes to be copied)
CopyBytes:: ; loop: copy each byte to destination
    ld a, b
    or c
    ret z ; return if no bytes remain

    ld a, [hl+] ; read byte and move to next

    ld [de], a ; write byte
    inc de ; move to next
    dec bc ; decrease bytes remaining

    jr CopyBytes
; end loop
; end CopyBytes


; PURPOSE: Copy a nul-terminated string (excluding the terminator)
; IN:
;  - hl: source address
;  - de: destination address
; OUT:
;  - hl: address after the nul terminator in the source
;  - de: address after the last character in the destination
;  - a: 0
;  - flags: Z1 N0 H1 C0
; CYCLES: 12N + 8 (where N is the length of the string)
WriteStr:: ; loop: copy each character to destination
    ld a, [hl+] ; read character and move to next

    and a
    ret z ; return if character is terminator

    ld [de], a ; write character
    inc de ; move to next

    jr WriteStr
; end loop
; end WriteStr


; PURPOSE: Copy a nul-terminated string (excluding the terminator) and get
; the length of the string
; IN:
;  - hl: source address
;  - de: destination address
; OUT:
;  - hl: address after the nul character in the source
;  - de: address after the last character in the destination
;  - bc: number of characters written
;  - a: 0
;  - flags: Z1 N0 H1 C0
; CYCLES: 12N + 18 (where N is the length of the string)
WriteStr_GetLen::
; store start position
    ld b, d ; 1
    ld c, e ; 1

.loop: ; loop: copy each character to destination
    ld a, [hl+] ; read character and move to next ; 2

    and a ; 1
    jr z, .exit ; stop if character is terminator ; 3/2

    ld [de], a ; write character ; 2
    inc de ; move to next ; 2

    jr .loop ; 3
; end loop

.exit:
; calculate low byte of character count
    ld a, e ; 1
    sub c ; 1
    ld c, a ; 1

; calculate high byte of character count
    ld a, d ; 1
    sbc b ; 1
    ld b, a ; 1

    ret ; 4
; end WriteStr_GetLen
