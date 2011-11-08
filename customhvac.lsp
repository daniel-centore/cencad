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
(defun hdfhelper (x y layername color block)
	(if (/= (equal layername "") t) (command "._layer" "_M"    layername ""))
	(if (/= (equal color "")     t) (command "-layer"  "color" color     "" ""))
	
;	(setq block "hdfsup")
	(setq j (strcat "./DWGs/HVAC/" block ".dwg"))
	(defblock j)
	
	(command "-insert" block "x" x "y" y)
	(prompt "\nInsertion point")
	(command pause)
	(prompt "\nRotation")
	(command pause)
)

(defun hdfcustom (layername color block)
	(begincommand)
	
	(setq x (getint "Width: "))
	(setq y (getint "Height: "))
	
	(hdfhelper x y layername color block)
	
	(endcommand)
)

;; this is a helper. do not directly call.
(defun terminalinsert (block layer color)
	(insertblock (strcat "./DWGs/HVAC/" block ".dwg") layer color "CONTINUOUS" "-1" "0" "-1" "1")
)

; vcv-cv w/ heat coil
(defun vcvcvhc (num)
	(terminalinsert (strcat "hvtb" (as-string num) "c") "M-SUPP-TRBX" "BLUE")
)

(defun vvwohc (num)
	(terminalinsert (strcat "hvtb" (as-string num)) "M-SUPP-TRBX" "BLUE")
)

(defun vvrr (num)
	(terminalinsert (strcat "hvtb" (as-string num) "e") "M-RTRN-TRBX" "GREEN")
)

(defun vvee (num)
	(terminalinsert (strcat "hvtb" (as-string num) "e") "M-EXHS-TRBX" "YELLOW")
)


















