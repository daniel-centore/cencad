;; Inserts a block and then breaks a line around it
;; block - The name of the block to insert
;; symmetrical - 0 if the block is symmetrical, 1 if not (so we prompt for flip)
;; radius - The radius of an imaginary circle around the block for use when breaking
;; mirror - 0 to leave block alone, 1 if we are allowed to mirror over line
(defun insertbreak (block symmetrical radius mirror)
	(begincommand)
	
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
		(command "break" entity "F" (polar (getentdata block 10) (moving-toward entity (line-start entity)) radius) (polar (getentdata block 10) (moving-toward entity (line-end entity)) radius))
		
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

(defun c:test ()
	(insertbreak "plgasv2" 0 4.5 1)
	
)

