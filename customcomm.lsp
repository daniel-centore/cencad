;;*************
;;Handles Common menu
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************

;;Creates a layer for the cloud revision, then puts a cloud on it
(defun revcloud ()
	(begincommand)
	
	(setq revnum (getint-def revnum "Revision Number"))
	
	(insertblock "" (strcat "X-REVC-" (as-string revnum)) "40" "continuous" "0" "0" "-1" "-1")
	(command "revcloud")
	
	(endcommand)
)

;;Same as revcloud but with a triangle thing
(defun xrev ()
	(begincommand)
	
	(setq revnum (getint-def revnum "Revision Number"))
	
	(insertblock "./DWGs/COMM/xrev.dwg" (strcat "X-REVD-" (as-string revnum)) "red" "continuous" "0" "0" "-1" "-1")
	(command (as-string revnum))
	
	(endcommand)
)

;;Sets the drawing scale
(defun drawingsetup ()
	(begincommand)
	
	(setq myscale (getreal (strcat "Enter the drawing scale <" (as-string (getvar "dimscale")) ">: ")))
	(if (= myscale nil) (setq myscale (getvar "dimscale")))
	
	(setvar "dimscale" myscale)
	(setq text-size (/ myscale text-var))	
	
	(command "-style" "CEN-ATT" "romans.shx" text-size "0.75" "0" "no" "no")
	
	(endcommand)
)

;;Came from somewhere...sorry have no credits
;;Draws a shadow box from bottom left to top right
(defun c:shadowbox (/ oldhatch lay osnp p1 p2 len abc p3 p4 p5 p6 p7 p8)
	(begincommand)
	
	(setq oldhatch (getenv "MaxHatch"))
	(setenv "MaxHatch" "10000000")
	(setq lay (getvar "clayer"))
	(setq osnp (getvar "osnapcoord"))
	
	(setq	p1 (getpoint "\nPick BOTTOM LEFT corner: ")
		p2 (getcorner p1 "\nPick TOP RIGHT corner: ")
	)
	
	(setq len (abs (- (car p2) (car p1))))
	(setq abc (* 0.05 len))
	(setq	p3 (list (+ (car p1) abc) (- (cadr p1) abc))
		p4 (list (car p2) (cadr p1))
		p5 (list (+ (car p2) abc) (- (cadr p2) abc))
		p6 (list (+ (car p2) abc) (- (cadr p1) abc))
		p7 (list (car p1) (cadr p2))
		p8 (list (+ (car p1) abc) (- (cadr p1) abc))
	)
	
	(setvar "osnapcoord" 1)
	(command "-layer" "m" "drops" "")
	(command "pline" p1 p3 p6 p5 p2 p4 p1 "")
	(command "pline" p1 p7 p2 "")
	(command "zoom" "w" p1 p8)
	(command "-bhatch" "p" "s" "s" p8 "" "")
	(setvar "osnapcoord" osnp)
	(setvar "clayer" lay)
	(command "zoom" "p")
	(setenv "MaxHatch" oldhatch)
	
	(endcommand)
)

;;Breaks a line in two specified points
(defun c:breakfirst (/ b)
	(begincommand)
	
	(setq b (entsel-def "Select line to break"))
	(command "break" b "F")
	(prompt "\nSpecify first break point")
	(command pause)
	(prompt "\nSpecify second break point")
	(command pause)
	
	(endcommand)
)

;;Continuously copies an entity
(defun c:continuouscopy ()
	(begincommand)

	(command "copy")

	(endcommand)
)

;;Breaks a line at an intersection
;;Precondition: intersection snap is enabled
(defun c:breakatint ()
	(begincommand)
	
	(prompt "\nSelect object to Break: ")
	(command "break" pause "F")
	(prompt "\nSelect intersection to break at: ")
	(command pause "@")
	
	(endcommand)
)

;;Cuts a line at every intersection
(defun c:intersectionbreak (/ breakline objects obj item intersection myset pt)
	(begincommand)
	
	(setq intbreakdist (getdist-def intbreakdist "Break Distance"))
	
	(setq breakline (entsel-def "Pick Break Line: "))
	(setq objects '())
	(while (/= (setq obj (entsel "Select Objects: ")) nil) (progn
		(if (equal (getentdata obj 0) "LINE") (progn
			;;IF
			(breakmyline obj intbreakdist (infiniteptintersection obj breakline) breakline)
			) (progn
			;;ELSE
			(setq pt (getpoint "\nPlease pick the intersection: "))
			(breakmyline obj intbreakdist pt breakline)
		))
	))
	
	
	(endcommand)
)

;;intersectionbreak --> helper
(defun breakmyline (tobreak mydistance intersection breakline / length breakstart breakend)

	(command "break" tobreak "F")
	
	;find two points to break at
	(setq length mydistance);(distance 2))
	;(setq breakstart (polar intersection (angle (getlinestart tobreak) intersection) length))
	;(setq breakend   (polar intersection (angle (getlineend   tobreak) intersection) length))
	
	(setq breakstart (polar intersection (oppositeang (angle (getlinestart breakline) intersection)) length))
	(setq breakend   (polar intersection (oppositeang (angle (getlineend   breakline) intersection)) length))
	
	
	;end find two points
	
	(disablesnap) ;;\/
	(command breakstart breakend)
	(enablesnap)  ;;/\
)

;;Quickly copies an object
(defun c:quickcopy ()
	(begincommand)
	
	(prompt "\nSelect Object: ")
	(command "copy" pause "" "O" "M")
	(command (getvar "lastpoint"))
	
	(endcommand)
)

;;Quickly moves an object
(defun c:quickmove ()
	(begincommand)
	
	(prompt "\nSelect Object: ")
	(command "move" pause "")
	(command (getvar "lastpoint"))
	
	(endcommand)
)

;;Glues 2 lines together
(defun c:glue (/ glline1 glline2)
	(begincommand)
	
	(setq glline1 (entsel-def "Select first line: "))
	(setq glline2 (entsel-def "Select second line: "))
	
	(glue glline1 glline2)
	
	(endcommand)
)

;;Glues 2 lines together
;;
;;glline1	Lines to glue together
;;glline2
(defun glue (glline1 glline2 / start end)

	(disablesnap) ;;\/
	
	(setq start (greater (distance (getlinestart glline1) (getlinestart glline2)) (getlinestart glline1) (distance (getlineend glline1) (getlinestart glline2)) (getlineend glline1)))
	(setq end   (greater (distance (getlinestart glline2) (getlinestart glline1)) (getlinestart glline2) (distance (getlineend glline2) (getlinestart glline1)) (getlineend glline2)))
	
	(command "line" start end "")
	(command "erase" glline1 glline2 "")
	
	(enablesnap)  ;;/\
)

;;Glues multiple lines together until nil is returned
(defun c:glue-multiple ()
	(c:glue)
	(while t (glue (entlast) (entsel-def "Pick next line: ")))
)

;;Quickly scales an object based on scale and value
(defun c:quickscale (/ scalefactor)
	(begincommand)
	
	(setq refval (getdist-def refval "Reference Value"))
	(setq scaleval (getdist-def scaleval "Scale Value"))
	
	(setq scalefactor (/ scaleval refval))
	
	(disablesnap) ;;\/
	(while (/= (setq obj (entsel-def "Pick Object to Rescale: ")) nil)
		(command "scale" obj "" (getvar "lastpoint") scalefactor))
	(enablesnap)  ;;/\
		
	(endcommand)
)

;;|          |
;;|    -->   |
;;|_         \_
;;
(defun c:chamfer45 (/ line1 line2 intersection top1 ang1 top2 ang2)
	(begincommand)
	
	(setq chamdist (getdist-def chamdist "Offset distance of Through"))
	(setq line1  (entsel-def "Pick first line: "))
	(setq line2  (entsel-def "Pick second line: "))
	
	(setq intersection (infiniteptintersection line1 line2))
	
	(setq top1 (infinitegetfarthertop line1 line2))
	(setq ang1 (angle intersection top1))
	
	(setq top2 (infinitegetfarthertop line2 line1))
	(setq ang2 (angle intersection top2))
	
	(disablesnap) ;;\/
	(command "break" line1 "F" intersection (polar intersection ang1 chamdist))
	(command "break" line2 "F" intersection (polar intersection ang2 chamdist))
	
	(command "line" (polar intersection ang1 chamdist) (polar intersection ang2 chamdist) "")
	(enablesnap)  ;;/\
	
	(endcommand)
)

;;Continuously changes objects to hidden2 linetype
(defun c:hidden2 ()
	(begincommand)
	
	(while (/= (setq obj (entsel-def "Select Objects: ")) nil)
		(command "change" obj "" "P" "LT" "HIDDEN2" ""))
	
	(endcommand)
)

;;Taper45 for double lines
(defun c:taper45dbl (/ branch1 branch2 main between intersection1 pt1 pt2 closer main1 ang line1start line1end line1endrev line1 line2)
	(begincommand)
	
	(setq taperdist45 (getdist-def taperdist45 "\nTaper Distance: "))
	(setq branch1 (entsel-def "Select BRANCH (side to taper toward): "))
	(setq branch2 (entsel-def "Select BRANCH (the other one): "))
	(setq main (entsel-def "Select MAIN: "))
	
	(setq between (distance (getlinestart branch1) (getlinestart branch2)))
	
	(setq intersection1 (infiniteptintersection branch1 main))
	(setq main (breakline main intersection1))
	
	(setq pt1 (polar intersection1 (line-angle (nth 0 main)) taperdist45))
	(setq pt2 (polar intersection1 (line-angle (nth 1 main)) taperdist45))
	
	(setq closer (closerpoint pt1 pt2 (getlinestart branch1)))
	
	(setq main1 (nth 0 main))
	(if (= closer pt2) (setq main1 (nth 1 main)))
	
	(setq ang (angle intersection1 (getlinestart branch1)))
	
	(disablesnap) ;;\/
	(command "break" branch1 "F" intersection1 (polar intersection1 ang taperdist45))
	(enablesnap)  ;;/\
	
	(setq line1start (closerpoint (getlinestart branch1) (getlineend branch1) intersection1))
	(setq ang (line-angle main1))
	(setq line1end (polar intersection1 ang taperdist45))
	(setq line1endrev (polar intersection1 ang (oppositenum taperdist45)))
	
	(disablesnap) ;;\/
	(command "line" line1start line1end "")
	(enablesnap)  ;;/\
	
	(setq line1 (entlast))
	
	(disablesnap) ;;\/
	(if (/= (ptintersection line1 branch2) nil) (progn (command "erase" line1 "") (command "line" line1start line1endrev "")))
	(enablesnap)  ;;/\
	
	(setq line1 (entlast))
	
	;; just finished doing line1 here
	
	(glue (nth 0 main) (nth 1 main))	;glue main back together
	(setq main (entlast))
	
	(disablesnap) ;;\/
	(command "offset" between line1 intersection1 "" ^C^C)
	(setq line2 (entlast))
	(command "scale" line2 "" (middle-of line2) "2.5" ^C^C)
	(enablesnap)  ;;/\
	
	(fillet line2 (ptintersection line2 main) branch2 (infinitegetfarthertop branch2 main))
	
	(setq main (breakline main (ptintersection main line2)))
	
	(fillet line2 (ptintersection line2 branch2) (nth 1 main) (middle-of (nth 1 main)))
	
	(if (/=(ptintersection (nth 0 main) line1) nil) (setq to-del (breakline (nth 0 main) (ptintersection (nth 0 main) line1))) (setq to-del (breakline (nth 1 main) (ptintersection (nth 1 main) line1))))
	
	(foreach item to-del
		(if (/= (ptintersection item line2) nil) (command "erase" item ""))
	)
	
	(endcommand)
)

;; |         |
;; |    -->  |
;;_|_      __\_
;;
(defun c:taper45 (/ branch main intersection side start end line)
	(begincommand)
	
	(setq taperdist (getdist-def taperdist "Taper Distance: "))
	(setq branch (entsel-def "Select BRANCH to taper: "))
	(setq main (entsel-def "Select MAIN"))
	
	(setq intersection (infiniteptintersection branch main))
	(setq main (breakline main intersection))
	(setq side (entsel-def "Select side of MAIN to taper to: "))
	
	(setq start (polar intersection (moving-from branch intersection) taperdist))
	(setq end   (polar intersection (moving-from side intersection) taperdist))
	
	(disablesnap) ;;\/
	(command "line" start end "")
	(enablesnap)  ;;/\
	(setq line (entlast))
	(glue (nth 0 main) (nth 1 main))
	
	(fillet line (middle-of line) branch (getfarthertop branch line))
	
	(endcommand)
)

;;Grabs a single source block and continuously replaces o/s with it
(defun c:blockswap (/ source replace)
	(begincommand)
	
	(setq source (entsel-def "Select Source Block: "))
	(while (/= (setq replace (entsel "Select block to replace: ")) nil) (progn
		(setq pt (block-insertpt replace))
		(command "erase" replace "")
		(disablesnap) ;;\/
		(command "copy" source "" (block-insertpt source) pt)
		(enablesnap)  ;;/\
	))
	
	(endcommand)
)

;;changeto --> Helper
(defun changeto2 (text color linetype entity)
	(command "._layer" "_M" (strcat (getentdata obj 8) "-" text) "")
	(if (/= color nil) (command "-layer" "color" color "" ^C^C) (command "-layer" "color" (layer-color obj) "" ^C^C))
	(if (/= linetype nil) (command "-linetype" "S" linetype ""))
	(command "change" obj "" "P" "LT" linetype "")
	(setent-var obj 8 (getvar "clayer"))
)

;;Changes a block to be on it's (layername + "-" + text)
(defun changeto (text color linetype / obj)
	(while (/= (setq obj (entsel "Select Objects: ")) nil) (progn
		(changeto2 text color linetype obj)
	))
)

;;Opposite of changeto
(defun removefrom (text / obj layern)
	(while (/= (setq obj (entsel "Select Objects: ")) nil) (progn
		(setq layern (replace-last (getentdata obj 8) (strcat "-" text) ""))
		(setent-var obj 8 layern)
	))
)

;;Moves object to layer suffixed by -PHS1
(defun c:to-phs1 ()
	(begincommand)
	(changeto "PHS1" nil nil)
	(endcommand)
)

;;Removes object from layer suffixed by -PHS1
(defun c:from-phs1 ()
	(begincommand)
	(removefrom "PHS1")
	(endcommand)
)

;;Moves object to layer suffixed by -PHS2
(defun c:to-phs2 ()
	(begincommand)
	(changeto "PHS2" nil nil)
	(endcommand)
)

;;etc...
(defun c:from-phs2 ()
	(begincommand)
	(removefrom "PHS2")
	(endcommand)
)

(defun c:to-exist ()
	(begincommand)
	(changeto "EXST" 9 nil)
	(endcommand)
)

(defun c:to-demo ()
	(begincommand)
	(changeto "DEMO" "cyan" nil)
	(endcommand)
)

;;Sets active layer to that of a selected object
(defun c:layerset (/ obj)
	(begincommand)
	
	(setq obj (entsel-def "Pick an entity: "))
	(command "-layer" "S" (getentdata obj 8) "")
	
	(endcommand)
)

;;Replaces an mtext string with another
(defun c:matchstring ()
	(begincommand)
	
	(setq source (getentdata (entsel-def "Select source text: ") 1))
	(while (/= (setq obj (entsel "Select MText to REPLACE: ")) nil) (progn
		(setent-var obj 1 source)
	))
	
	
	(endcommand)
)


