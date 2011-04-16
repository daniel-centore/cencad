(defun loaddefaults ()
	;begin default value collection
	(setq revnum         1)
	(setq intbreakdist   1)
	(setq refval         1)
	(setq scaleval       1)
	(setq chamdist       1)
	(setq taperdist45    1)
	(setq taperdist      1)
	;end default value collection
)

(defun getreal-def (default prompt)
	(setq val (getreal (strcat "\n" prompt " <" (rtos default 2 2) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

(defun getstring-def (default prompt)
	(setq val (getstring (strcat "\n" prompt " <" default ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

(defun getdist-def (default prompt)
	(print default)
	(setq val (getdist (strcat "\n" prompt " <" (as-string default) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

(defun getangle-def (default prompt)
	(setq val (getangle (strcat "\n" prompt " <" (rtos default 2 2) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

(defun getint-def (default prompt)
	(setq val (getint (strcat "\n" prompt " <" (as-string default) ">: ")))
	(if (= val nil) (setq val default))
	
	val
)

(defun entsel-def (prompt)
	(setq final (entsel prompt))
	(while (= final nil) (setq final (entsel (strcat "You missed (haha) please try again ==> " prompt))))
	
	final
)
