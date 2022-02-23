; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main


section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

section .data

event:		times	24 dq 0

; Un point par ligne sous la forme X,Y,Z
dodec:	dd	0.0,50.0,80.901699		; point 0
		dd 	0.0,-50.0,80.901699		; point 1
		dd 	80.901699,0.0,50.0		; point 2
		dd 	80.901699,0.0,-50.0		; point 3
		dd 	0.0,50.0,-80.901699		; point 4
		dd 	0.0,-50.0,-80.901699	; point 5
		dd 	-80.901699,0.0,-50.0	; point 6
		dd 	-80.901699,0.0,50.0		; point 7
		dd 	50.0,80.901699,0.0		; point 8
		dd 	-50.0,80.901699,0.0		; point 9
		dd 	-50.0,-80.901699,0.0	; point 10
		dd	50.0,-80.901699,0.0		; point 11

; Une face par ligne, chaque face est composée de 3 points tels que numérotés dans le tableau dodec ci-dessus
; Les points sont donnés dans le bon ordre pour le calcul des normales.
; Exemples :
; pour la première face (0,8,9), on fera le produit vectoriel des vecteurs 80 (vecteur des points 8 et 0) et 89 (vecteur des points 8 et 9)	
; pour la deuxième face (0,2,8), on fera le produit vectoriel des vecteurs 20 (vecteur des points 2 et 0) et 28 (vecteur des points 2 et 8)
; etc...
faces:	dd	0,8,9,0
		dd	0,2,8,0
		dd	2,3,8,2
		dd	3,4,8,3
		dd	4,9,8,4
		dd	6,9,4,6
		dd	7,9,6,7
		dd	7,0,9,7
		dd	1,10,11,1
		dd	1,11,2,1
		dd	11,3,2,11
		dd	11,5,3,11
		dd	11,10,5,11
		dd	10,6,5,10
		dd	10,7,6,10
		dd	10,1,7,10
		dd	0,7,1,0
		dd	0,1,2,0
		dd	3,5,4,3
		dd	5,6,4,5


section .text


;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:

;####################################
;## Code de création de la fenêtre ##
;####################################
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

; boucle de gestion des évènements
boucle: 
	mov rdi,qword[display_name]
	mov rsi,event
	call XNextEvent

	cmp dword[event],ConfigureNotify
	je prog_principal
	cmp dword[event],KeyPress
	je closeDisplay
jmp boucle

;###########################################
;## Fin du code de création de la fenêtre ##
;###########################################

;############################################
;##	Ici commence VOTRE programme principal ##
;############################################ 
prog_principal:


;##############################################
;##	Ici se termine VOTRE programme principal ##
;##############################################																																																																																																																																	     		     		jb boucle
jmp flush



flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit

	