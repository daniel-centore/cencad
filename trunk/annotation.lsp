;;All the ones in annotation should be put on their corresponding layer
;;so the command should be something like: (progn (anot-layer "T") (c:quickarrow))
;;
;;List below:
;;T - tel/data
;;E - electrical
;;P - plumbing
;;M - hvac (mechanical)

(defun quicksomething (what)
	(setvar "DIMLDRBLK" what)
	
	(prompt "\nPick first point: ")
	(command "dimleader" pause)
	(prompt "\nPick next point: ")
	(command pause)
	(setq centerpt (getvar "lastpoint"))
	(prompt "\nPick 3rd point: ")
	(setq oldortho (getvar "orthomode"))
	(setvar "orthomode" "1")
	(command pause)
	(setvar "orthomode" oldortho)
	
	(command "" "" "N")
	(setq ang (deg-angle centerpt (getvar "lastpoint")))
	
	(if (or (and (<= ang 90) (>= ang 0)) (> ang 270))
		;;if
		(command "text" "J" "ML" (getvar "lastpoint") "0")
		;;else
		(command "text" "J" "MR" (getvar "lastpoint") "0")
	)
)

(defun c:quickarrow ()
	(begincommand)
	
	(quicksomething "")
	
	(endcommand)
)

(defun c:quickdot ()
	(begincommand)
	
	(defblock "./DWGs/COMM/xldrdot.dwg")
	(quicksomething "xldrdot")
	
	(endcommand)
)

(defun c:quickloop ()
	(begincommand)
	
	(defblock "./DWGs/COMM/xldrloop.dwg")
	(quicksomething "xldrloop")
	
	(endcommand)
)

(defun c:quicknone ()
	(begincommand)
	
	(quicksomething "NONE")
	
	(endcommand)
)

(defun anot-layer (which / color linetype text)
	(command "._layer" "_M" (strcat which "-NOTE") "")
	(command "-layer" "color" "cyan" "" ^C^C)
)
