FUNCTION error_handler
PARAMETERS silent_mode, err_num, err_mes, err_code_str, err_func_nam, err_stack, err_line
LOCAL log_file_hndl, tmp_str, tmp_str2, transact_level, i, j
DIMENSION err_arr[1, 2]

transact_level = TXNLEVEL() 

IF transact_level != 0
	FOR i = 1 TO transact_level
		ROLLBACK
	ENDFOR 
ENDIF 

tmp_str = ''

IF TYPE('err_code_str') == 'C'
	err_code_str = ALLTRIM(err_code_str)
ELSE 	
	err_code_str = TRANSFORM(err_code_str)	
ENDIF 

TEXT TO tmp_str TEXTMERGE NOSHOW 
Unexpactable exception:
Error number:			<<err_num>>
Error message:  		<<err_mes>>
Error line number:		<<err_line>>
Error occured 
<<CHR(9)>>on line:		<<err_code_str>> 
<<CHR(9)>>in method/function:	<<TRANSFORM(err_func_nam, '@T')>>

ENDTEXT 

tmp_str2 =  TRANSFORM(err_stack,  '@T') + '  ' + TRANSFORM(PROGRAM(2), '@T') + '  ' + ;
			TRANSFORM(PROGRAM(3), '@T') + '  ' + TRANSFORM(PROGRAM(4), '@T') + '  ' + ;
			TRANSFORM(PROGRAM(5), '@T') + '  ' + TRANSFORM(PROGRAM(6), '@T') + '  ' + ;
			TRANSFORM(PROGRAM(7), '@T') + '  ' + TRANSFORM(PROGRAM(8), '@T')

TEXT TO tmp_str TEXTMERGE NOSHOW ADDITIVE 	
Call stack:			<<tmp_str2>>
Current alias:			<<ALIAS()>> 
Current filter:			<<FILTER()>>
Current dirrectory:		<<SYS(2003)>>
Transaction level:		<<transact_level>>
Timestamp:	        	<<DATETIME()>>

STACKINFO:

ENDTEXT 
			
	ASTACKINFO(err_arr)
	
	FOR i = 1 TO ALEN(err_arr, 1)
		FOR j = 1 TO ALEN(err_arr, 2)
			tmp_str = tmp_str + SPACE(2) + TRANSFORM(err_arr[i, j])
		ENDFOR 
		
		tmp_str = tmp_str + CHR(13)
	ENDFOR 

	tmp_str = tmp_str + REPLICATE('_', 77) + CHR(13) + CHR(13)
	
    STRTOFILE(tmp_str, 'error.log', 1)
	
	IF !silent_mode
		MESSAGEBOX('Unexpactable exception: ' + CHR(13) + TRANSFORM(err_num) + ;
				CHR(13) + err_mes + CHR(13) + err_code_str  + CHR(13) + err_func_nam + ;
				CHR(13) + ALIAS() + CHR(13) + 'line: ' + TRANSFORM(err_line), 48, 'General error handler utility')	
	ENDIF 

	tmp_str = TTOC(DATETIME()) + SPACE(4) + 'Erorr memory dump:' + CHR(13) + ;
			  REPLICATE('_', 80)
	STRTOFILE(tmp_str, 'mem.dmp', 1)
	DISPLAY MEMORY TO FILE 'mem.dmp' ADDITIVE NOCONSOLE
	tmp_str = CHR(13) + REPLICATE('_', 80) + CHR(13) + CHR(13)
	STRTOFILE(tmp_str, 'mem.dmp', 1)
RETURN 