;; Inserts a block and then breaks a line around it
;; block - The name of the block to insert
;; symmetrical - 0 if the block is symmetrical, 1 if not (so we prompt for flip)
;; radius - The radius of an imaginary circle around the block for use when breaking
;; mirror - 0 to leave block alone, 1 if we are allowed to mirror over line
(defun insertbreak (block symmetrical radius mirror)
	(begincommand)
	
	(setq radius (/ (* (dimscale) radius) 96)) ; convert our radii depending on the dimscale
	
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(setq entity (entsel "Pick the line! (or press ENTER)"))
	
	(if (= entity '()) (progn
		(prompt "\nInsertion point?")
		(command "-insert" block "_non" "s" (dimscale) pause)
		(prompt "\nRotation?")
		(command pause)
	) (progn ; else
		(disablesnap) ;\/
		(setq ang1 (rtd (moving-toward entity (line-end entity))))
		(setq ang2 (moving-toward entity (line-start entity)))
		
		(setq point1 (nth 1 entity)) ; where we clicked
		(setq insert (list (nth 0 point1) (getYL entity (nth 0 point1)) 0)) ; KLUDGE KLUDGE KLUDGE!
		
		(command "-insert" block insert (dimscale) (dimscale) ang1)
		(setq block (entlast))
		
		(if (>= radius 0) (progn
			(command "break" entity "F" (polar (getentdata block 10) (moving-toward entity (line-start entity)) radius) (polar (getentdata block 10) (moving-toward entity (line-end entity)) radius))
		))
		
		(if (and (= symmetrical 1) (= (truefalse "Flip symbol?") "y")) (progn
			(setent-var block 41 (- 0 (getentdata block 41)))
			;(setent-var block 50 ang2)
		))
		
		(if (and (= mirror 1) (= (truefalse "Mirror over line?") "y")) (progn
			(setent-var block 41 (- 0 (getentdata block 41)))
			(setent-var block 50 ang2)
		))
		
		(enablesnap) ;/\
	))
	
	(endcommand)
)

;; For inserting isometric stuff
;; DEPRECATED - Isometric has been scrapped :'-(
;;
;; block and radius - see above
;; rotation - Amount to rotate
;; sX and sY - The X and Y scale multipliers (so -1 no multiply dimscale by -1)
(defun insertiso (block radius rotation sX sY)
	(begincommand)
	
	(setq radius (/ (* (dimscale) radius) 96)) ; convert our radii depending on the dimscale
	
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(setq entity (entsel "Pick the line! (or press ENTER)"))
	
	(setq sX (* sX (dimscale)))
	(setq sY (* sY (dimscale)))
	
	(if (= entity '()) (progn
		(prompt "\nInsertion point?")
		(command "-insert" block "_non" "x" sX "y" sY pause)
		(command rotation)
	) (progn ; else
		(disablesnap) ;\/
;		(setq ang1 (rtd (moving-toward entity (line-end entity))))
;		(setq ang2 (moving-toward entity (line-start entity)))
		(setq ang1 rotation)
		
		(setq point1 (nth 1 entity)) ; where we clicked
		(setq insert (list (nth 0 point1) (getYL entity (nth 0 point1)) 0)) ; KLUDGE KLUDGE KLUDGE!
		
		(command "-insert" block insert sX sY ang1)
		(setq block (entlast))
		
		(command "break" entity "F" (polar (getentdata block 10) (moving-toward entity (line-start entity)) radius) (polar (getentdata block 10) (moving-toward entity (line-end entity)) radius))
		
		(enablesnap) ;/\
	))
	
	(endcommand)
)

;; for inserting stuff at the end of a line
;; block - The block to insert
;; symmetrical - 0 if block is symmetrical (do not ask to flip) or 1 if it isn't (so we do ask)
(defun nearend (block symmetrical)
	(begincommand)
	
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(setq entity (entsel "Pick near end of line"))
	
	(setq ang (rtd (moving-toward entity (nth 1 entity))))
	
	(disablesnap) ;\/
	(command "-insert" block (closerend entity (nth 1 entity)) (dimscale) (dimscale) ang)
	(setq block (entlast))
	
	(if (and (= symmetrical 1) (= (truefalse "Flip symbol?") "y")) (progn
		(setent-var block 41 (- 0 (getentdata block 41)))
		(setent-var block 50 (dtr (+ ang 180)))
	))
	(enablesnap) ;/\
	
	(endcommand)	
)

(defun vacuumrelief()
	(begincommand)
	
	(setq block "plvr")
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(prompt "\nInsertion point?")
	(command "-insert" "plvr" "_non" "s" (dimscale) pause)
	(prompt "\nRotation?")
	(command pause)
	
	(endcommand)
)

; quick insert plumbing
(defun qip (block)
	(begincommand)
	
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(prompt "\nInsertion point?")
	(command "-insert" block "_non" "s" (dimscale) pause)
	(prompt "\nRotation?")
	(command pause)
	
	(endcommand)
)

;; for doing intersectionstuff like teedown
(defun teedown (block radius)
	(begincommand)
	
	(setq radius (/ (* (dimscale) radius) 96)) ; convert our radii depending on the dimscale
	
	(setq main (entsel-def "Pick main: "))
	(setq branch (entsel-def "Now for the branch: "))
	
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(disablesnap) ;\/
	(setq ang1 (rtd (moving-toward main (line-end main))))
		
	(setq insert (infiniteptintersection main branch))
		
	(command "-insert" block insert (dimscale) (dimscale) ang1)
	(setq block (entlast))
	(command "break" branch "F" (polar (getentdata block 10) (moving-toward branch (line-start branch)) radius) (polar (getentdata block 10) (moving-toward branch (line-end branch)) radius))
		
	(enablesnap);/\
	(endcommand)
)

(defun teeofftop() ;;I didn't like making this one
	(begincommand)
	
	(setq main (entsel-def "Pick main: "))
	(setq branch (entsel-def "Now for the branch: "))
	
	(setq block "plpteeot")
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(disablesnap) ;\/
	(setq ang1 (rtd (moving-toward main (line-end main))))
	(setq ang2 (moving-toward main (line-start main)))
	
	(setq top (line-start branch))
	(setq bottom (line-end branch))
	
	(setq insert (infiniteptintersection main branch))
		
	(command "-insert" block insert (dimscale) (dimscale) ang1)
	(setq block (entlast))
	
	(command "break" main "F" (polar (getentdata block 10) (moving-toward main (line-start main)) 3) (polar (getentdata block 10) (moving-toward main (line-end main)) 3))
	(if (= (truefalse "Flip symbol?") "y") (progn
		(setent-var block 41 (- 0 (getentdata block 41)))
		(setent-var block 50 ang2)
	))
	
	(disablesnap)
	(command "break" branch "F" (polar (getentdata block 10) (moving-toward branch (line-start branch)) 0) (polar (getentdata block 10) (moving-toward branch (line-end branch)) 0))
	(enablesnap)

	(entdel (entity-ename (entsel-def "Pick line to remove")))
		
	(enablesnap);/\
	
	(endcommand)
)

; pipe break 2 points
(defun pbtp ()
	(begincommand)
	
	(setq entity (entsel-def "Pick the first point"))
	(command "_none")
	(setq pt2 (getpoint (nth 1 entity) "Second one?"))
	
	(disablesnap) ;; \/
	(command "break" (nth 1 entity) pt2)
	(setq last (entlast))
	(enablesnap)  ;; /\
	
	
	(setq block "plsquig")
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(setq ang (rtd (moving-toward entity (nth 1 entity))))
	
	(disablesnap) ;\/
	(command "-insert" block (closerend entity (nth 1 entity)) (dimscale) (dimscale) ang)
	
	(command "-insert" block (closerend last (nth 1 entity)) (dimscale) (dimscale) ang)
	
	(enablesnap) ;/\
	
	(endcommand)
)

(defun slope()
	(begincommand)
	(setq mt (getvar "mirrtext"))
	(setvar "mirrtext" 0)
	
	(setq block "plslope")
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)

	(setq line (entsel-def "Pick line at insert point: "))
	
	(disablesnap)
	(command "-insert" block (nth 1 line) (dimscale) "" (rtd (line-angle line)))
	(prompt "\nPipe slope: ")
	(command pause)
	(enablesnap)
	
	(setq pt (nth 1 line))
	(setq ang (rtd (line-angle line)))
	(setq secondPt (polar pt (dtr (+ ang 90)) 1))
	
	(disablesnap)
	(if (= (truefalse "Flip symbol?") "y")
		(command "mirror" (entlast) "" (nth 1 line) secondPt "yes")
	)
	(enablesnap)
	
	(setvar "mirrtext" mt)
	(endcommand)
)

;; fire hose distance
(defun fhd ()
	(begincommand)
	
	(setq dist 0)
	(setq pt1 (getpoint "Start of fire hose distance: "))
	
	
	
	(while (and (>= dist 0) (< dist 100))
		(setq pt2 (getpoint "To: "))
		(if (= pt2 nil)
			;if
			(setq dist -1)
			
			;else
			(progn
				(setq dist (+ dist (distance pt1 pt2)))
				(setq pt1 pt2)
				(prompt (as-string dist))
			)
		)

	)
	
	(if (> dist 10)
		; if
		(prompt "\nNote: Fire hose distance over 100 ft!")
	)
	
	(endcommand)
)

(defun trenchdrain ()
	(begincommand)
	
	(cleanprint "This command is not yet available because of a problem. Sorry.")
	
	;; --										--;;
	;; I am waiting for Bricscad to get back to be regarding the following bug	  ;;
	;; https://www.bricsys.com/protected/common/meetingpoint/srEdit.jsp?id=32148      ;;
	;; --										--;;
	
;	(setq pt1 (getpoint "First point of rectangle: "))
;	(setq pt2 (getcorner pt1 "Second Point of Rectangle: "))
;	
;	(disablesnap)
;	(command "rectangle" pt1 pt2)
;	(enablesnap)
;	
;	(setq rect (entlast))
;	
;	(command "-hatch" "p" "LINE,_Ire" "0" (dimscale) "N" "s" rect "")
;	(setq hatch (entlast))
;	
;	(if (= (truefalse "Rotate 90 degrees? ") "y")
;		(entdel hatch)
;		(command "-hatch" "p" "LINES" "90" (dimscale) "N" "s" rect "")
;	)
	(endcommand)
)
