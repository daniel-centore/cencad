;;************
;;Handles HVAC menu (unstarted)
;;
;;Written for Centek Engineering (http://www.centekeng.com/)
;;Author: Daniel Centore (dcentore@optonline.net)
;;*************

(defun c:to-demo-hvac ()
	(begincommand)
	(changeto "DEMO" "cyan" "HIDDEN2")
	(endcommand)
)
