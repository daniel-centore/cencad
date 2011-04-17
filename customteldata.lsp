;;************
;;Handles Tel/Data menu
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************

;;Puts a ~ at the end of a line
(defun c:wirebreakend (/ line)
	(begincommand)
	
	(setq line (entsel-def "Pick the line end: "))
	(setq ins_pt (closerend line (getvar "lastpoint")))
	(insertblock "./DWGs/TELD/tmbrk1.dwg" "" "" "" (as-string (line-angle line)) "1" "-1" "-1")
	
	(endcommand)
)

;;like wirebreakend but cuts to points from center and does it there
(defun c:wirebreakline ()
	(begincommand)
	
	(setq line (entsel-def "Pick your line: "))
	(setq pt1  (getpoint "\nPick first point: "))
	(setq pt2  (getpoint "\nPerhaps the second now?: "))
	
	(setq wawa (breakline2 line pt1 pt2))
	
	(setq ins_pt (closerend (nth 0 wawa) (line-start (nth 1 wawa))))
	(insertblock "./DWGs/TELD/tmbrk1.dwg" "" "" "" (as-string (line-angle (nth 0 wawa))) "1" "-1" "-1")
	(setq ins_pt (closerend (nth 1 wawa) (line-start (nth 0 wawa))))
	(insertblock "./DWGs/TELD/tmbrk1.dwg" "" "" "" (as-string (line-angle (nth 1 wawa))) "1" "-1" "-1")
	
	(endcommand)
)

;;Similar to wirebreakend
(defun c:objectbreakend (/ line)
	(begincommand)
	
	(setq line (entsel-def "Pick the object end: "))
	(setq ins_pt (closerend line (getvar "lastpoint")))
	(insertblock "./DWGs/TELD/tmobrk.dwg" "" "" "" (as-string (line-angle line)) "1" "-1" "-1")
	
	(endcommand)
)

;;similar to objectbreakline
(defun c:objectbreakline (/ line pt1 pt2 wawa)
	(begincommand)
	
	(setq line (entsel-def "Pick your object: "))
	(setq pt1  (getpoint "\nPick first point: "))
	(setq pt2  (getpoint "\nPerhaps the second now?: "))
	
	(setq wawa (breakline2 line pt1 pt2))
	
	(setq ins_pt (closerend (nth 0 wawa) (line-start (nth 1 wawa))))
	(insertblock "./DWGs/TELD/tmobrk.dwg" "" "" "" (as-string (line-angle (nth 0 wawa))) "1" "-1" "-1")
	(setq ins_pt (closerend (nth 1 wawa) (line-start (nth 0 wawa))))
	(insertblock "./DWGs/TELD/tmobrk.dwg" "" "" "" (as-string (line-angle (nth 1 wawa))) "1" "-1" "-1")
	
	(endcommand)
)

;;Puts a symbol between 2 points
(defun c:objbreakdbl ()
	(begincommand)
	
	(setq pt1 (getpoint "\nFirst point: "))
	(setq pt2 (getpoint "\nSecond point: "))
	
	(setq dist (distance pt1 pt2))
	
	(command "-insert" "./DWGs/TELD/tm2lobrk.dwg" (in-between pt1 pt2) dist dist (+ 90 (deg-angle pt1 pt2)))
	
	(endcommand)
)
