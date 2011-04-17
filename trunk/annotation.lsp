;;************
;;Handles annotations (which are in multiple menus)
;;
;;All the commands in here should be put on a corresponding layer
;;so the command in the menu file should be something like: (progn (anot-layer "T") (c:quickarrow))
;;
;;List below:
;;T - tel/data
;;E - electrical
;;P - plumbing
;;M - hvac (mechanical)
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************


;;Draws a quick "what". See user methods.
;;Basically quickarrow but with other arrowheads
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

;;Draws a quick arrow
(defun c:quickarrow ()
	(begincommand)
	
	(quicksomething "")
	
	(endcommand)
)

;;Draws a quick arrow with a dot on the end
(defun c:quickdot ()
	(begincommand)
	
	(defblock "./DWGs/COMM/xldrdot.dwg")
	(quicksomething "xldrdot")
	
	(endcommand)
)

;;Draws a quick arrow with a loop at the end
(defun c:quickloop ()
	(begincommand)
	
	(defblock "./DWGs/COMM/xldrloop.dwg")
	(quicksomething "xldrloop")
	
	(endcommand)
)

;;Draws a quick arrow with no arrowhead
(defun c:quicknone ()
	(begincommand)
	
	(quicksomething "NONE")
	
	(endcommand)
)

;;Creates and loads a layer for use w/ annotation
(defun anot-layer (which / color linetype text)
	(command "._layer" "_M" (strcat which "-NOTE") "")
	(command "-layer" "color" "cyan" "" ^C^C)
)
