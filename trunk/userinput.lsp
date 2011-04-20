;;************
;;Handles user input.
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************

;;Loads default value collection.
;;This *needs* to be called before using any other functions
(defun loaddefaults ()
	;begin default value collection
	(setq revnum         1)
	(setq intbreakdist   1)
	(setq refval         1)
	(setq scaleval       1)
	(setq chamdist       1)
	(setq taperdist45    1)
	(setq taperdist      1)
	(setq plugdist       5)
	;end default value collection
)

;;Gets a floating point number
;;Uses default as the default value assuming no inputted value
(defun getreal-def (default prompt)
	(setq val (getreal (strcat "\n" prompt " <" (rtos default 2 2) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

;;Gets a string
;;Uses default as the default value assuming no inputted value
(defun getstring-def (default prompt)
	(setq val (getstring (strcat "\n" prompt " <" default ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

;;Gets a distance
;;Uses default as the default value assuming no inputted value
(defun getdist-def (default prompt)
	(print default)
	(setq val (getdist (strcat "\n" prompt " <" (as-string default) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

;;Gets an angle
;;Uses default as the default value assuming no inputted value
(defun getangle-def (default prompt)
	(setq val (getangle (strcat "\n" prompt " <" (rtos default 2 2) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

;;Gets an integer
;;Uses default as the default value assuming no inputted value
(defun getint-def (default prompt)
	(setq val (getint (strcat "\n" prompt " <" (as-string default) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

;;Gets an entity
(defun entsel-def (prompt)
	(setq final (entsel prompt))
	(while (= final nil) (setq final (entsel (strcat "You missed (haha) please try again ==> " prompt))))
	
	final
)

