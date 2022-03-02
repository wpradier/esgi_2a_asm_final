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
extern printf
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

x1:		resd	1
y1:		resd	1
x2:		resd	1
y2:		resd	1

pointsX:	resd	12
pointsY:	resd	12

cosinus:	resd	360
sinus:		resd	360

section .data

formatAffiche:	db 	"val %d: %f",10,0
formatTest:	db	"VAL: %d",10,0

Xoff:		dd	200.0
Yoff:		dd	200.0
Zoff:		dd	200.0

distanceFocale:	dd	100.0

indexPoints:	dd	0
indexFaces:	dd	0
indexLignes:	dd	0

event:		times	24 dq 0

angle:		dd	0
demiangle:	dd	180

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

calculs_trigo:

	boucle_trigo:
		fldpi
		fimul dword[angle]
		fidiv dword[demiangle]
		fsincos
		mov ecx,dword[angle]
		fstp dword[cosinus+ecx*DWORD]
		fstp dword[sinus+ecx*DWORD]
		inc dword[angle]
		cmp dword[angle],360
		jbe boucle_trigo

ret


;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:

;call calculs_trigo

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


;mov rcx, 0
;boucleAffiche:
;	mov rdi,formattest
;	mov rsi,0
;	mov esi, ecx
;	cvtss2sd xmm0, dword[dodec+ecx*DWORD]
;	mov rax,1
;	call printf
;
;	mov rdi,formattest
;	mov rsi,0
;	inc ecx
;	mov esi, ecx
;	cvtss2sd xmm0, dword[dodec+ecx*DWORD]
;	mov rax,1
;	call printf
;	cmp ecx,4

;	jne boucleAffiche


mov dword[indexPoints],0
boucleCalcul:
	mov	ecx,dword[indexPoints] ; ecx a l'index des points
	
	imul	ebx, ecx, 3
	add	ebx, 2 ; contient l'index du point Z
	
	movss	xmm1,dword[dodec + ebx * DWORD] ; points Z
	addss	xmm1,dword[Zoff]; partie (Z+Zoff) du calcul dans xmm1

	imul	ebx, ecx, 3; contient l'index du point X


	movss	xmm0,dword[dodec + ebx * DWORD] ; points X
	mulss	xmm0,dword[distanceFocale]
	
	divss	xmm0,xmm1
	addss	xmm0,dword[Xoff]

	movss	dword[pointsX + ecx * DWORD],xmm0 ; fin du calcul du point X et stockage dans le tableau pointsX

	imul	ebx, ecx, 3
	add	ebx, 1 ; contient l'index du point Z

	movss	xmm0,dword[dodec + ebx * DWORD] ; points Y
	mulss	xmm0,dword[distanceFocale]
	
	divss	xmm0,xmm1
	addss	xmm0,dword[Yoff]

	movss	dword[pointsY + ecx * DWORD],xmm0 ; fin du calcul du point X et stockage dans le tableau pointsY


	inc	dword[indexPoints]

	cmp	dword[indexPoints],12 ; 12 points à boucler
	jb	boucleCalcul
	
	


mov dword[indexFaces],0

boucleFaces:
	mov	r14d,dword[indexFaces] ; r14d a l'index des faces


	mov	dword[indexLignes],0

	boucleLignes:
		mov 		r11d,dword[indexLignes] ; r11d a l'index des lignes

		imul		r12d, r14d, 4
		add		r12d, r11d ; contient l'index du premier point

		mov		eax,dword[faces + r12d * DWORD]

		cvtss2si	ebx,dword[pointsX + eax * DWORD] ; x1
		mov		dword[x1], ebx
		cvtss2si	ebx,dword[pointsY + eax * DWORD] ; y1
		mov		dword[y1], ebx


		add		r12d, 1 ; contient l'index du premier point

		mov		eax,dword[faces + r12d * DWORD] ; eax contient l'index du deuxième point

		cvtss2si	ebx,dword[pointsX + eax * DWORD] ; x2
		mov		dword[x2], ebx
		cvtss2si	ebx,dword[pointsY + eax * DWORD] ; y2
		mov		dword[y2], ebx





		mov rdi,qword[display_name]
		mov rsi,qword[window]
		mov rdx,qword[gc]
		mov ecx,dword[x1]
		mov r8d,dword[y1]
		mov r9d,dword[x2]
		push qword[y2]
		call XDrawLine

		inc		dword[indexLignes]

		cmp		dword[indexLignes],3 ; 3 lignes à tracer
		jb		boucleLignes
	


	inc	dword[indexFaces]

	cmp	dword[indexFaces],20 ; 20 faces à boucler
	jb	boucleFaces


;mov dword[x1],50
;mov dword[y1],50
;mov dword[x2],200
;mov dword[y2],350
;
;mov rdi,qword[display_name]
;mov rsi,qword[window]
;mov rdx,qword[gc]
;mov ecx,dword[x1]
;mov r8d,dword[y1]
;mov r9d,dword[x2]
;push qword[y2]
;call XDrawLine

;##############################################
;##	Ici se termine VOTRE programme principal ##
;##############################################
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

	
