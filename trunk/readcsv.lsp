;;Loads a block using the dwgdata.csv file
(defun loadblockinfo (blockname
/ txtpath fp charlst l mychar firstword wordlst rightsection count columns blockpath layername color linetype rotation position xcommand xscale)
	
	(setq txtpath (findfile "dwgdata.csv"))

	;(initget "L P")

	;; Open the file and create an empty list
	(setq fp (open txtpath "r"))
	(setq charlst '())

	;; Iterate the file, writing each char to
	;; the list
	(while (setq l (read-char fp))
		(setq mychar (chr l))
		
		(if (equal mychar "\n") (setq mychar ","))	;replace newlines with commas
		
		(if (/= (equal mychar "\"") t) (setq charlst (cons mychar charlst)))
	)

	;; Close the file.
	(close fp)

	;; Reverse the list
	(setq charlst (reverse charlst))
	
	(setq firstword "")
	
	(setq wordlst '())
	
	(foreach item charlst
		 (if (/= item ",") (setq firstword (strcat firstword item)))
		 (if (= item ",") (progn (setq wordlst (cons firstword wordlst)) (setq firstword "")))
	)
	
	
	;; Reverse the list
	(setq wordlst (reverse wordlst))
	
	(setq rightsection 0)		;set to 1 after the correct line of data is found
	(setq count 1)
	(setq columns 9)		;final
	(foreach item wordlst
		(if (> count columns) (setq count 1))
		
		;;This is where we process all the stuff from the csv
		;;If you want to add anything change the columns # above to whatever number of
		;;columns there are in the csv (only add to END). Afterwards, follow the pattern below
		;;to process the data (first spot is 1, not 0).
		;;
		;;Important: Finally, update all other methods (as listed in insertblock.txt) so they include a nil variable for it.
		;;==Begin of data processing section
		
		
		(if (= rightsection 1) (progn
			(if (= count 2) (progn
				(if (/= blockpath '()) (alert "ERROR: DUPLICATE CSV ENTRY. Please notify Daniel Centore <dcentore@optonline.net> immediately including which menu item you were going to insert."))
				(setq blockpath item)
			))
			(if (= count 3) (setq layername item))
			(if (= count 4) (setq color	item))
			(if (= count 5) (setq linetype	item))
			(if (= count 6) (setq rotation	item))
			(if (= count 7) (setq position	item))
			(if (= count 8) (setq xcommand	item))
			(if (= count 9) (setq xscale	item))
		))
		
		(if (= count columns) (setq rightsection 0))
		(if (= count 1) (progn
			(if (equal blockname item)(setq rightsection 1))
		))	;set to 1 if were in right section
		
		;;==End of data processing section==
		(setq count (1+ count))
	)

	(if (= blockpath nil) (progn
		;;IF
		(alert (strcat "Invalid block identifier: " blockname))
		) (progn
		;;ELSE
		(insertblock blockpath layername color linetype rotation position xcommand xscale)
	))	
	
)


