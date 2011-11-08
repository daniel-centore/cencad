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

;; Shows insert box for hdfsup and uses x and y as scale factors
(defun hdfsup (x y layername color linetype)
	(begincommand)
	
	(hdfhelper x y layername color linetype)
	
	(endcommand)
)

;; do not call as command b/c we do not start and end it. use hdfsup.
(defun hdfhelper (x y layername color linetype)
	(if (/= (equal layername "") t) (command "._layer" "_M"    layername ""))
	(if (/= (equal color "")     t) (command "-layer"  "color" color     "" ""))
	(if (/= (equal linetype "")  t) (command "-layer"  "ltype" linetype  "" ""))
	
	(setq block "hdfsup")
	(setq j (strcat "./DWGs/PLUM/" block ".dwg"))
	(defblock j)
	
	(command "-insert" block "x" x "y" y)
	(prompt "\nInsertion point")
	(command pause)
	(prompt "\nRotation")
	(command pause)
)

(defun hdfcustom (layername color)
	(begincommand)
	
	(setq x (getint "Width: "))
	(setq y (getint "Height: "))
	
	(hdfhelper x y layername color "CONTINUOUS")
	
	(endcommand)
)
