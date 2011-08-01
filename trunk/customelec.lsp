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

(defun c:opensurface ()
	(begincommand)
	
	(setq opensurfaceht (getdist-def opensurfaceht "Length/Height"))
	(insertblock "" "E-AUXL" "YELLOW" "CONTINUOUS" "0" "-1" "-1" "-1")
	
	(defblock "./DWGs/ELEC/eopanel.dwg")
	
	(command "-insert" "eopanel" "x" opensurfaceht "y" "1" "z" opensurfaceht pause)
	
	(command pause)
	
	(endcommand)
)
