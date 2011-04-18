;;************
;;Commonly used functions for getting entity information
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************

;;Gets line start
;;Deprecated: use line-start
(defun getlinestart (entity)
	(getentdata entity 10)
)

;;Gets line end
;;Deprecated: use line-end
(defun getlineend (entity)
	(getentdata entity 11)
)

;;Gets line start (point of initialization - don't assume it's on the left)
(defun line-start (entity) (getlinestart entity))

;;Gets line end (last selected point - don't assume it's on the right)
(defun line-end (entity)   (getlineend   entity))

;;Finds the end of a line farthest from intersection between line1 and line2
(defun getfarthertop (line1 line2 / intersection top bottom)

	(setq intersection (ptintersection line1 line2))
	
	(setq top (getlineend line1))
	(setq bottom (getlinestart line1))
	(if (> (distance (getlinestart line1) intersection) (distance (getlineend line1) intersection))
		(progn
		(setq top (getlinestart line1))
		(setq bottom (getlineend line1))
	))
	
	top
)

;;Uses an infiniteptintersection (however this seems to have a bug?) so be cautious
(defun infinitegetfarthertop (line1 line2 / intersection top bottom)

	(setq intersection (infiniteptintersection line1 line2))	;;this is the only line thats changed from getfarthertop
	
	(setq top (getlineend line1))
	(setq bottom (getlinestart line1))
	(if (> (distance (getlinestart line1) intersection) (distance (getlineend line1) intersection))
		(progn
		(setq top (getlinestart line1))
		(setq bottom (getlineend line1))
	))
	
	top
)


;;Finds the intersection between line1 and line2
(defun ptintersection (line1 line2)
	(inters (getlinestart line1) (getlineend line1) (getlinestart line2) (getlineend line2))
)

;;Finds the angle of a line from origin-end
;;Deprecated: moving-from and moving-toward recommended
(defun line-angle (line)
	(angle (line-start line) (line-end line))
)

;;Switches - sign
(defun oppositenum (number)
	(- 0 number)
)

;;Finds the intersection between line1 and line2, even if they are not touching
(defun infiniteptintersection (line1 line2 / ang1 ang2 possiblelength start1 end1 start2 end2)
	(setq ang1 (line-angle line1))
	(setq ang2 (line-angle line2))
	
	(setq possiblelength (distance (getvar "extmin") (getvar "extmax")))
	
	(setq start1 (polar (getlinestart line1) ang1              (distance (getvar "extmin") (getvar "extmax"))))
	(setq end1   (polar (getlinestart line1) ang1 (oppositenum (distance (getvar "extmin") (getvar "extmax")))))
	(setq start2 (polar (getlinestart line2) ang2              (distance (getvar "extmin") (getvar "extmax"))))
	(setq end2   (polar (getlinestart line2) ang2 (oppositenum (distance (getvar "extmin") (getvar "extmax")))))
	
	(inters start1 end1 start2 end2)
)

;;breakline --> Helper
(defun breakline2 (myline pt1 pt2 / lines start end)
	(disablesnap) ;;\/
	(setq lines '())
	
	(setq start (getlinestart myline))
	(setq end   (getlineend myline))
	
	(command "erase" myline "")
	(command "line" start (closerpoint pt1 pt2 start) "")
	
	(setq lines (cons (entlast) lines))
	(command "line" (closerpoint pt1 pt2 end) end "")
	
	(setq lines (cons (entlast) lines))
	
	(enablesnap)  ;;/\
	
	lines
)

;;Breaks a line and returns the two halves
(defun breakline (myline pt)
	(breakline2 myline pt pt)
)

;;Returns the closest of the 2 points to ref
(defun closerpoint (pt1 pt2 ref / dist1 dist2 final)
	(setq dist1 (distance pt1 ref))
	(setq dist2 (distance pt2 ref))
	(setq final pt1)
	
	(if (< dist2 dist1) (setq final pt2))
	
	final
)

;;Returns the end of the line closest to ref
(defun closerend (line ref)
	(closerpoint (line-start line) (line-end line) ref)
)

;;Opposite of closetpoint
(defun fartherpoint (pt1 pt2 ref / dist1 dist2 final)
	(setq dist1 (distance pt1 ref))
	(setq dist2 (distance pt2 ref))
	(setq final pt1)
	
	(if (> dist2 dist1) (setq final pt2))
	
	final
)

;;Opposite of closerend
(defun fartherend (line ref)
	(fartherpoint (line-start line) (line-end line) ref)
)

;;Finds the greater of the compares, then returns its corresponding return
(defun greater (compare1 return1 compare2 return2)
	(setq result return2)
	(if (> compare1 compare2) (setq result return1))
	
	result
)

;;Opposite of greater
(defun less (compare1 return1 compare2 return2 / result)
	(setq result return2)
	(if (< compare1 compare2) (setq result return1))
	
	result
)

;;Returns the center point of pt1 and pt2
;;Deprecated: Most cases call for middleof
(defun in-between (pt1 pt2 / final count item2 diff final)
	(setq final '())
	
	(setq count 0)
	(foreach item1 pt1
		(setq item2 (nth count pt2))
		(setq diff (- (max item1 item2) (min item1 item2)))
		(setq final (cons (+ (/ diff 2) (min item1 item2)) final))
		(setq count (1+ count))
	)
	
	(setq final (reverse final))
	
	final
)

;;Returns the point in the center of line
(defun middle-of (line)
	(in-between (line-start line) (line-end line))
)

;;Finds the angle of line moving away from pt
(defun moving-from (line pt)
	(angle (closerpoint (getlinestart line) (getlineend line) pt) (fartherpoint (getlinestart line) (getlineend line) pt))
)

;;Finds the angle of line moving toward pt
(defun moving-toward (line pt)
	(angle (fartherpoint (getlinestart line) (getlineend line) pt) (closerpoint (getlinestart line) (getlineend line) pt))
)

;;Fillets line1 and line2
;;TODO: Check how this works and comment it
(defun fillet (line1 pt1 line2 pt2 / fill-inters)
	(setq fill-inters (infiniteptintersection line1 line2))
	(disablesnap) ;;\/
	(command "fillet" "R" 0 "fillet" (in-between fill-inters pt1) (in-between fill-inters pt2))
	(enablesnap)  ;;/\
)

;;Returns an entity's data based on its group code (available online)
(defun getentdata (entity id)
	(cdr (assoc id (entget-ename entity)))
	;(if (= (type entity) 'ENAME) (cdr (assoc id (entget entity))) (cdr (assoc id (entget (car entity)))))
)

;;Returns the entity's ENAME regardless of whether it is an entity or an ENAME
;;Uses car if it is an entity
(defun entity-ename (entity / final)
	(if (= (type entity) 'ENAME) (setq final entity) (setq final (car entity)))

	final
)

;;Returns an entity's information (via entget) wrapping it with an entity-ename
(defun entget-ename (entity)
	(entget (entity-ename entity))
)

;;Finds the point at which an entity was inserted
(defun block-insertpt (entity)
	(getentdata entity 10)
)

;;Sets an entity's value based on its group code
(defun setent-var (entity id newval / data)
	(setq data (entget-ename entity))
	(setq data (subst (cons id newval) (assoc id data) data))
	(entmod data)
	data
)

;;Returns the color of the layer that entity is on
(defun layer-color (entity / layer)
	(setq entity (entity-ename entity))
	(setq layer (cdr (assoc 8 (entget entity))))
	
	(cdr (assoc 62 (tblsearch "LAYER" layer)))
)

;;Finds the opposite angle (ang + 180)
(defun oppositeang (ang)
	(+ ang 180)
)

;;Finds the angle from pt1 to pt2 in degrees
(defun deg-angle (pt1 pt2)
	(radians-to-degrees (angle pt1 pt2))
)

;;Returns a radian number in degress
;;Deprecated: use rtg
(defun radians-to-degrees (rad)
	(rtg rad)
)

;;Returns a radian number in degress
(defun rtg (rad)
	(* rad (/ 180 pi))
)

;;Returns a degrees number in radians
(defun dtr (deg)
	(/ (* deg 180) pi)
)

;;Allows you to reference a block by name rather than path
;;Kind of kludgy --> Inserts it then erases it via entlast
(defun defblock (path)
	(command "-insert" path (getvar "lastpoint") "1" "1" "0")
	(command "erase" (entlast) "")
)

;;Source: http://forums.augi.com/showthread.php?t=58198
;;Sets an entity's height
(defun set-attribute-height (entity height / BS BSL CT NOFUV NOFNU LP NE NEL NEAET NEA OFNU NNEL)
	(setq BS (ssadd entity))
	(SETQ BSL (SSLENGTH BS))
	(SETQ CT (- BSL 1))
	(setq NOFUV height)
	(SETQ NOFNU (CONS 40 NOFUV))
	(SETQ LP 1)
	(WHILE LP
		(SETQ NE (SSNAME BS CT))
		(SETQ CT2 0)
		(SETQ LP2 1)
		(WHILE LP2
			(if (/= NE nil) (SETQ NE (ENTNEXT NE)))
			(if (/= NE nil) (progn
				(SETQ NEL (ENTGET NE))
				(SETQ NEAET (CDR (ASSOC 0 NEL)))
				(SETQ NEA (ASSOC 40 NEL))
				(IF (= NEAET "ATTRIB") 
					(PROGN
					(IF (/= NEA NIL)
						(PROGN
						(SETQ OFNU NEA)
						(SETQ NNEL (SUBST NOFNU OFNU NEL))
						(ENTMOD NNEL)
						(ENTUPD NE)
					))
				))
				(IF (= NEAET "SEQEND") (SETQ LP2 NIL))
			))
			
			(if (= NE nil) (progn (setq LP nil) (setq LP2 nil)))
		)
		(SETQ CT (- CT 1))
		(IF (< CT 0) (SETQ LP NIL))
	)
)

;;Returns the size of text
(defun text-size ()
	(* 0.09375 (getvar "dimscale"))
)

;;Bill Kramer (http://forums.cadalyst.com/showthread.php?p=19880)
;;Find all intersections between objects in the selection set SS.
;;TODO: Clean this up!
(defun ss-inters (SS / SSL PTS aObj1 aObj2 N1 N2 iPts)
	(setq N1 0 SSL (sslength SS))

	(while (< N1 (1- SSL))
		(setq aObj1 (ssname SS N1) aObj1 (vlax-ename->vla-object aObj1) N2 (1+ N1))
		(while (< N2 SSL)
			(setq aObj2 (ssname SS N2) aObj2 (vlax-ename->vla-object aObj2) iPts (vla-intersectwith aObj1 aObj2 0) iPts (vlax-variant-value iPts))
			(if (> (vlax-safearray-get-u-bound iPts 1) 0) (progn
				(setq iPts (vlax-safearray->list iPts))
				(while (> (length iPts) 0)
					(setq Pts (cons (list (car iPts) (cadr iPts) (caddr iPts)) Pts) iPts (cdddr iPts))
				)
			))
      			(setq N2 (1+ N2))
      		)
		(setq N1 (1+ N1))
	)
	Pts
)
