;;************
;;Handles electrical menu
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************

;; Allows one to draw a prewired wiremold
(defun c:wiremoldprewired ()
	(begincommand)
	
	(setq first (getpoint "Select first point: "))
	(setq second (getpoint first "Select second point: "))
	
	(setq plugdist (fix (getdist-def plugdist "Plug Spacing")))
	
	(insertblock "" "E-POWR" "YELLOW" "CONTINUOUS" "0" "-1" "-1" "-1")
	
	(setq dist (distance first second))
	
	(defblock "./DWGs/ELEC/erwmold.dwg")
	
	(setq columns (fix (/ dist plugdist)))
	
	(setq ang (deg-angle first second))

	;draw the inner part	
	(disablesnap)
	(command "minsert")
	(command "erwmold")
	(command first)
	(command 4 4)
	(command ang)
	(command 1)
	(command columns)
	(command plugdist)
	(enablesnap)
	
	;draw outside rectangle
	
	(setq innerdist (- dist (* plugdist (- columns 1))))
	(setq offset (/ innerdist 2))
	
	
	(defblock "./DWGs/ELEC/erwmoldo.dwg")
	
	(disablesnap)
	(command "-insert" "erwmoldo" (polar first (angle first second) (oppositenum offset)) dist 4 ang)
	(enablesnap)
	
	(endcommand)
)

;; Helper for the different panel commands
(defun panelcommand (name)
	(begincommand)
	
	(setq opensurfaceht (getdist-def opensurfaceht "Length/Height"))
	(insertblock "" "E-AUXL" "YELLOW" "CONTINUOUS" "0" "-1" "-1" "-1")
	
	(defblock (strcat "./DWGs/ELEC/" name ".dwg"))
	
	(command "-insert" name "x" opensurfaceht "y" "1" "z" opensurfaceht pause)
	(command pause)
	
	(endcommand)
)

;; Helper for drawing different size tranformers
(defun transformers (name x y)
	(begincommand)
	
	(insertblock "" "E-AUXL" "YELLOW" "CONTINUOUS" "0" "-1" "-1" "-1")
	(defblock (strcat "./DWGs/ELEC/" name ".dwg"))
	
	(command "-insert" name "x" x "y" y "z" x pause)
	(command pause "T")
	
	(set-attribute-height (entity-ename (entlast)) text-size)
	(set-attribute-width (entity-ename (entlast)) 0.75)
	
	
	(endcommand)
)

;; Command for drawing a custom sized transformer
(defun c:customtransformer ()
	(begincommand)
	
	(setq transformerx (getdist-def transformerx "X Size: "))
	(setq transformery (getdist-def transformery "Y Size: "))
	(transformers "exfmr" transformerx transformery)
	
	(endcommand)
)

; Helps draw a homerun
; Keep vars public so we can use them in homerunwires
(defun c:homerun ()
	(begincommand)	
	
	(insertblock "" "E-AUXL" "YELLOW" "CONTINUOUS" "0" "-1" "-1" "-1")
	
	(command "line")
	(while (/= (getvar "cmdactive") 0) (prompt "\nNext point: ") (command pause))
	
	(setq wire (entlast))
	(setq ang (rtd (angle (line-start wire) (line-end wire))))
	
	(defblock "./DWGs/ELEC/ehrunarw.dwg")
	(command "-insert" "ehrunarw" (line-end wire) (getvar "dimscale") "" ang)
	
	(endcommand)
)

; Draws a homerun with &wires wires
(defun homerunwires (wires)
	(begincommand)
	
	(c:homerun)
	
	(setq middle (middle-of wire))
	
	(setq wir "")
	
	(while (< (strlen wir) wires) (setq wir (strcat wir "/")))
	
	(defblock "./DWGs/ELEC/ewires.dwg")
	(disablesnap)
	(command "-insert" "ewires" middle (getvar "dimscale") "" ang wir)
	(enablesnap)
	
	(endcommand)
)

;; Command for drawing a homerun with x wires (we ask for them)
(defun c:homerunqwires ()
	(begincommand)
	
	(homerunwires (setq homerun (getint-def homerun "Wires: ")))
	
	(endcommand)
)

;; Inserts $block on the end of the line selected
(defun nearend (block)
	(begincommand)
	
	(setq line (entsel-def "\nSelect near end of line:"))
	(setq end (closerend  line (getvar "lastpoint")))
	(setq start (fartherend  line (getvar "lastpoint")))
	
	(defblock (strcat "./DWGs/ELEC/" block ".dwg"))
	
	(disablesnap)
	(command "-insert" block end (getvar "dimscale") "" (rtd (angle start end)))
	(enablesnap)
	
	(endcommand)
)

;; Draws a cap
;; Deprecated: Just do (nearend "ewcap")
(defun c:cap ()
	(begincommand)
	
	(nearend "ewcap")
	
	(endcommand)
)



