;;Some kludgy functions for working with strings

;;Returns an array of chars
(defun char-array (string / final count)
	(setq final '())
	
	(setq count 1)
	(repeat (strlen string) (progn
		(setq final (cons (substr string count 1) final))
		
		(setq count (1+ count))
	))
	(setq final (reverse final))
	
	final
)

;;Replaces the first instance of replace inside string with with. (ie HELLO,ELL,!!! ~~> H!!!O)
(defun replace-first (string replace with
/ replaceC length sArray count runs first howfar continue s r begin end final)
	(setq final nil)
	(if (/= (strlen replace) 1) (progn
	(setq replaceC (char-array replace))
	
	(setq length (strlen replace))
	(setq sArray (char-array string))
	
	(setq count 0)
	(setq runs  0)
	(setq first -1)
	(setq howfar 0)
	(setq continue t)
	(foreach s sArray (if continue (progn
		(setq r (nth count replaceC))
		
		(if (/= first -1) (progn
			;(print (strcat r " " s))
			(if (equal r s) (progn (setq howfar (1+ howfar)) (setq count (1+ count))) (progn (setq first -1) (setq howfar 0) (setq count 0)))
			(if (= howfar length) (progn		;;weve found the full char match
				(setq continue '())
			))
		))
		
		(if continue (progn
		
		(setq r (nth count replaceC))	;;we do this again in case count was changed above
		
		(if (= first -1) (progn
			;(print "in first")
			(if (equal r s) (progn (setq first runs) (setq howfar 1) (setq count 1)))
		))
		
		(setq runs (1+ runs))))
	)))
	
	(setq begin "")
	(setq end "")
	(setq count 0)
	(foreach s sArray
		(if (< count first) (setq begin (strcat begin s)))
		(if (>= count (+ first howfar)) (setq end (strcat end s)))
		
		(setq count (1+ count))
	)
	
	(setq final (strcat begin with end))))
	
	final
)

(defun char2string (chararray / final)
	(setq final "")
	(foreach item chararray (setq final (strcat final item)))
	final
)

(defun replace-last (string replace with / Rstring Rreplace Rwith final)
	(setq Rstring (char2string (reverse (char-array string))))
	(setq Rreplace (char2string (reverse (char-array replace))))
	(setq Rwith (char2string (reverse (char-array with))))
	(setq final (replace-first Rstring Rreplace Rwith))
	(setq final (char2string (reverse (char-array final))))
	final
)

(defun replace-all (string replace with)
	(if (/= (equal replace with) t)
	(while (contains string replace)
		(setq string (replace-first string replace with))
	))
	
	string
)

(defun contains (string replace
/ replaceC length sArray count runs first howfar continue)
	(setq replaceC (char-array replace))
	
	(setq length (strlen replacew))
	(setq sArray (char-array string))
	
	(setq count 0)
	(setq runs  0)
	(setq first -1)
	(setq howfar 0)
	(setq continue t)
	(foreach s sArray (if continue (progn
		(setq r (nth count replaceC))
		
		(if (/= first -1) (progn
			(if (equal r s) (progn (setq howfar (1+ howfar)) (setq count (1+ count))) (progn (setq first -1) (setq howfar 0) (setq count 0)))
			(if (= howfar length) (progn		;;weve found the full char match
				(setq continue '())
			))
		))
		
		(setq r (nth count replaceC))	;;we do this again in case count was changed above
		
		(if (= first -1) (progn
			;(print "in first")
			(if (equal r s) (progn (setq first runs) (setq howfar 1) (setq count 1)))
		))
		
		(setq runs (1+ runs))
	)))
	
	(setq final '())
	
	(if (or (= howfar length) (and (= howfar 0) (= length 1))) (setq final t))
	
	final
)

(defun split (string delimeter)
	(setq string (strcat string delimeter))		;;so we break include the last one, bit of a hack
	
	(setq stringc (char-array string))
	
	(setq array '())
	(setq string "")
	(foreach item stringc (progn
	
		(if (equal item delimeter) (progn
			;;if
			(setq array (cons string array))
			(setq string "")
		) (progn
			;;else
			(setq string (strcat string item))
		))
	))
	
	(setq array (reverse array))
	
	array
)


(defun replace (array n newval)
	
	(setq firstpart '())
	(setq endpart   '())
	
	(setq count 0)
	(foreach item array (progn
		(if (< count n) (setq firstpart (cons item firstpart)))
		(if (> count n) (setq endpart   (cons item endpart)))
		
		(setq count (1+ count))
	))
	
	(setq firstpart (reverse firstpart))
	(setq endpart (reverse endpart))
	
	(append firstpart (cons newval nil) endpart)	;;return
)
