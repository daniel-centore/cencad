(defun getlinestart (entity)
	(getentdata entity 10)
)

(defun getlineend (entity)
	(getentdata entity 11)
)
l
(defun line-start (entity) (getlinestart entity))
(defun line-end (entity)   (getlineend   entity))

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

(defun ptintersection (line1 line2)
	(inters (getlinestart line1) (getlineend line1) (getlinestart line2) (getlineend line2))
)

(defun line-angle (line)
	(angle (line-start line) (line-end line))
)

(defun oppositenum (number)
	(- 0 number)
)

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
(defun breakline (myline pt)
	(breakline2 myline pt pt)
)

(defun closerpoint (pt1 pt2 ref / dist1 dist2 final)
	(setq dist1 (distance pt1 ref))
	(setq dist2 (distance pt2 ref))
	(setq final pt1)
	
	(if (< dist2 dist1) (setq final pt2))
	
	final
)

(defun closerend (line ref)
	(closerpoint (line-start line) (line-end line) ref)
)

(defun fartherpoint (pt1 pt2 ref / dist1 dist2 final)
	(setq dist1 (distance pt1 ref))
	(setq dist2 (distance pt2 ref))
	(setq final pt1)
	
	(if (> dist2 dist1) (setq final pt2))
	
	final
)

(defun fartherend (line ref)
	(fartherpoint (line-start line) (line-end line) ref)
)

(defun greater (compare1 return1 compare2 return2)
	(setq result return2)
	(if (> compare1 compare2) (setq result return1))
	
	result
)

(defun less (compare1 return1 compare2 return2 / result)
	(setq result return2)
	(if (< compare1 compare2) (setq result return1))
	
	result
)

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

(defun middle-of (line)
	(in-between (line-start line) (line-end line))
)

(defun moving-from (line pt)
	(angle (closerpoint (getlinestart line) (getlineend line) pt) (fartherpoint (getlinestart line) (getlineend line) pt))
)

(defun moving-toward (line pt)
	(angle (fartherpoint (getlinestart line) (getlineend line) pt) (closerpoint (getlinestart line) (getlineend line) pt))
)

(defun fillet (line1 pt1 line2 pt2 / fill-inters)
	(setq fill-inters (infiniteptintersection line1 line2))
	(disablesnap) ;;\/
	(command "fillet" "R" 0 "fillet" (in-between fill-inters pt1) (in-between fill-inters pt2))
	(enablesnap)  ;;/\
)

(defun getentdata (entity id)
	(cdr (assoc id (entget-ename entity)))
	;(if (= (type entity) 'ENAME) (cdr (assoc id (entget entity))) (cdr (assoc id (entget (car entity)))))
)

(defun entity-ename (entity / final)
	(if (= (type entity) 'ENAME) (setq final entity) (setq final (car entity)))

	final
)

(defun entget-ename (entity)
	(entget (entity-ename entity))
)

(defun block-insertpt (entity)
	(getentdata entity 10)
)

(defun setent-var (entity id newval / data)
	(setq data (entget-ename entity))
	(setq data (subst (cons id newval) (assoc id data) data))
	(entmod data)
	data
)

(defun layer-color (entity / layer)
	(setq entity (entity-ename entity))
	(setq layer (cdr (assoc 8 (entget entity))))
	
	(cdr (assoc 62 (tblsearch "LAYER" layer)))
)

(defun oppositeang (ang)
	(+ ang 180)
)

(defun deg-angle (pt1 pt2)
	(radians-to-degrees (angle pt1 pt2))
)

(defun radians-to-degrees (rad)
	(rtg rad)
)

(defun rtg (rad)
	(* rad (/ 180 pi))
)

(defun dtr (deg)
	(/ (* deg 180) pi)
)

(defun defblock (path)
	(command "-insert" path (getvar "lastpoint") "1" "1" "0")
	(command "erase" (entlast) "")
)

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

(defun text-size ()
	(* 0.09375 (getvar "dimscale"))
)

(defun ss-inters (SS /
           SSL ;length of SS
           PTS ;returning list
           aObj1 ;Object 1
           aObj2 ;Object 2
           N1  ;Loop counter
           N2  ;Loop counter
           iPts ;intersects
           )
  (setq N1 0 ;index for outer loop
  SSL (sslength SS))
  ; Outer loop, first through second to last
  (while (< N1 (1- SSL))
    ; Get object 1, convert to VLA object type
    (setq aObj1 (ssname SS N1)
    aObj1 (vlax-ename->vla-object aObj1)
    N2 (1+ N1)) ;index for inner loop
    ; Inner loop, go through remaining objects
    (while (< N2 SSL)
      ; Get object 2, convert to VLA object
      (setq aObj2 (ssname SS N2)
      aObj2 (vlax-ename->vla-object aObj2)
      ; Find intersections of Objects
      iPts (vla-intersectwith aObj1 aObj2 0)
      ; variant result
      iPts (vlax-variant-value iPts))
      ; Variant array has values?
      (if (> (vlax-safearray-get-u-bound iPts 1)
       0)
  (progn ;array holds values, convert it
    (setq iPts ;to a list.
     (vlax-safearray->list iPts))
    ;Loop through list constructing points
    (while (> (length iPts) 0)
      (setq Pts (cons (list (car iPts)
          (cadr iPts)
          (caddr iPts))
          Pts)
      iPts (cdddr iPts)))))
      (setq N2 (1+ N2))) ;inner loop end
    (setq N1 (1+ N1))) ;outer loop end
  Pts) ;return list of points found
