;;Credits: http://www.simplecad.com/lisp/files/tb.lsp.txt

(defun c:autobreaktext ( / TEMP FIRST TX ANG TEMPLA TEMPCMD TEMPBLIP TEMPOS TXTST TXTH line1)

	(begincommand)
	
	
	(setq OLDERR *error* 
	*error* TBERROR)
	(setq TEMPCMD (getvar "CMDECHO")
		TEMPLA	(getvar "CLAYER")
		TEMPBLIP (getvar "BLIPMODE")
		TEMPOS (getvar "OSMODE")
		TXTST (getvar "TEXTSTYLE")
	*TXTH (getvar "TEXTSIZE"))
	(setvar "CMDECHO" 0) 
	(setvar "BLIPMODE" 0)
	(setq TXTH (cdr (assoc 40 (tblsearch "style" TXTST)))) 

	(setq TEMP T)
	(setq FIRST T) 
	(while TEMP
		(setvar "OSMODE" 512)		 
		(setq line1 (entsel "\nInsertion point for text: "))
		(setq PT1 (getvar "lastpoint"))
		
		(setvar "OSMODE" 0)
		(cond
			((/= PT1 nil)
				(if FIRST
					(progn

						(if (= TXTH 0)
							(progn
								(prompt "\nHeight <")
								(prompt (as-string *TXTH))
								(prompt ">: ")
								(setq H (getreal)); ">: "))
								(if (= H nil) (setq H *TXTH)(setq *TXTH H))
							) 
						)

						(if (not *ANG)(setq *ANG 0))
;						(prompt "\nRotation angle <")
;						(prompt (as-string (* *ANG (/ 180 3.1415926))))
;						(prompt ">: ")
;						(setq ANG (getangle PT1)); ">: "))
;						(if (not ANG)(setq ANG *ANG)(setq *ANG ANG))
;						(setq ANG (* ANG (/ 180 3.1415926)))	

						(setq ANG (radians-to-degrees (line-angle line1)))
						(print (as-string ANG))
						(if (and (> ANG 90) (<= ANG 270)) (progn (print "subbed 180")(setq ANG (- ANG 180))))
						(print (as-string ANG))
						
						(if (not *TEXT)(setq *TEXT "XXX"))
						(prompt "\nText <")
						(prompt *TEXT)
						(prompt ">: ")
						(setq TX (getstring T)); ">: "))
						(if (= TX "") (setq TX *TEXT)(setq *TEXT TX))
					) ;end progn
				) ;end first

				(if (= TXTH 0)
					(command "text" "j" "mc" PT1 "" ANG TX )
				(command "text" "j" "mc" PT1	ANG TX )) 
				(trimbox (entlast))
			) ;end pt1

			((null PT1)
			(setq TEMP nil))

		);end cond
		(setq FIRST nil)
	);end while

	(setvar "CLAYER" TEMPLA)
	(setvar "BLIPMODE" TEMPBLIP)
	(setvar "OSMODE" TEMPOS)
	(setvar "CMDECHO" TEMPCMD)
	
	(endcommand)
)			

(defun trimbox (text / TEXTENT TRIMFACT TB GAP FGAP LL UR 
	PTB1 PTB2 PTB3 PTB4 PTF1 PTF2 PTF3 PTF4 BX)
	(setq text (entity-ename text))
	(setq TEXTENT text)
	
	(setq TRIMFACT 0.5) ;trim gap and text height ratio	
	(command "ucs" "Entity" TEXTENT)
	(setq TB (textbox (list (cons -1 TEXTENT)))
		LL (car TB)
		UR (cadr TB)
	)
	(setq GAP (* *TXTH TRIMFACT))		 
	(setq FGAP (* GAP 0.5))
	(setq PTB1 (list (- (car LL) GAP) (- (cadr LL) GAP))
		PTB3 (list (+ (car UR) GAP) (+ (cadr UR) GAP))
		PTB2 (list (car PTB3) (cadr PTB1))
		PTB4 (list (car PTB1) (cadr PTB3))
		PTF1 (list (- (car LL) FGAP) (- (cadr LL) FGAP))
		PTF3 (list (+ (car UR) FGAP) (+ (cadr UR) FGAP))
		PTF2 (list (car PTF3) (cadr PTF1))
		PTF4 (list (car PTF1) (cadr PTF3))
	)
	(command "pline" PTB1 PTB2 PTB3 PTB4 "c")
	(setq BX (entlast))
	(command "trim" BX "" "f" PTF1 PTF3 PTF4 PTF1 "" "")
	(entdel BX)
	(redraw TEXTENT)
	(command "ucs" "p")
	(princ)
)
