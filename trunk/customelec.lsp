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

(defun panelcommand (name)
	(begincommand)
	
	(setq opensurfaceht (getdist-def opensurfaceht "Length/Height"))
	(insertblock "" "E-AUXL" "YELLOW" "CONTINUOUS" "0" "-1" "-1" "-1")
	
	(defblock (strcat "./DWGs/ELEC/" name ".dwg"))
	
	(command "-insert" name "x" opensurfaceht "y" "1" "z" opensurfaceht pause)
	(command pause)
	
	(endcommand)
)

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

(defun c:customtransformer ()
	(begincommand)
	
	(setq transformerx (getdist-def transformerx "X Size: "))
	(setq transformery (getdist-def transformery "Y Size: "))
	(transformers "exfmr" transformerx transformery)
	
	(endcommand)
)

; keep ang public so we can use it in homerunwires
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

(defun c:homerunqwires ()
	(begincommand)
	
	(homerunwires (setq homerun (getint-def homerun "Wires: ")))
	
	(endcommand)
)

(defun c:cap ()
	(begincommand)
	
	(setq line (entsel-def "\nSelect near end of line:"))
	(setq end (closerend  line (getvar "lastpoint")))
	(setq start (fartherend  line (getvar "lastpoint")))
	
	(defblock "./DWGs/ELEC/ewcap.dwg")
	(disablesnap)
	(command "-insert" "ewcap" end (getvar "dimscale") "" (rtd (angle start end)))
	(enablesnap)
	
	(endcommand)
)



