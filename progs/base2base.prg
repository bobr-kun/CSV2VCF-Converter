FUNCTION Base2Base  
 *  Base2Base( <cInString>, <nInBase>, <nOutBase> ) --> cNewBaseValue  
 *  ѕреобразует число в виде строки цифр из одной системы счислени€ в  
 *  другую с диапазоном систем счислени€ от 2 до 201  
  lPARAMETERS cInString, nInBase, nOutBase  
  
  T_CHAR		= "C"  
  T_NUM			= "N"  
  T_LOGIC		= "L"  
  T_DATE		= "D"  
  T_TIME		= "T"  
  T_MONEY		= "Y"  
  T_NULL		= "X"  
  T_OBJ			= "O"  
  T_UNKNOWN		= "U"  
  T_GENERAL		= "G"  
  LDS_B2B_DIG 	= '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  LOCAL cNewBaseValue, ln_i, ln_len, DecPos, IntValue, FracValue  
  LOCAL FracProduct, FracCounter, IntProdStr, FracOutStr, IntOutString  
  LOCAL IntStr, FracString, FracLimit, Remainder, Quotient, NegSign  
  cNewBaseValue = ""  
  FracValue = 0.00000000000000000000  
  IntValue = 0  
  && ѕроверка параметров    
  IF VARTYPE(cInString) != T_CHAR
  	cInString = TRANSFORM(cInString)
  ENDIF 
  IF cInString = '0' AND LEN(cInString) = 1
  	RETURN '0'
  ENDIF   
  IF EMPTY(cInString) OR LEN(cInString ) > 20  
  	cNewBaseValue = .F.  
  ELSE  
  	STORE ALLTRIM(cInString) TO cInString  
  	IF EMPTY(nInBase)  
  		STORE 10 TO nInBase  
  	ENDIF  
  	IF EMPTY(nOutBase)  
  		STORE 10 TO nOutBase	  
  	endif  
  	IF varTYPE(nInBase) != T_NUM .OR. varTYPE(nOutBase) != T_NUM  
  		cNewBaseValue=.F.  
  	ELSE  
  		&& ѕроверка на выход из диапазона систем счислени€  
  		IF nInBase > 62 .OR. nOutBase > 62 .OR. nInBase < 2 .OR. nOutBase < 2  
  			cNewBaseValue = .F.  
  		ELSE  
  			&& ѕроверка на соответствие каждой цифры исходного числа системе счислени€  
  			ln_i = 1  
  			STORE LEN(cInString) TO ln_len  
  			DO WHILE ln_i < ln_len .AND. varTYPE(cNewBaseValue) != T_LOGIC  
  				ln_i = ln_i + 1  
  				IF .NOT. SUBSTR(cInString , ln_i , 1) $ (SUBSTR(LDS_B2B_DIG, 1, nInBase) + ".")  
  					cNewBaseValue = .F.  
  				ENDIF  
  			ENDDO  
  		ENDIF  
  	ENDIF  
  ENDIF  
  IF VARTYPE(cNewBaseValue) != T_LOGIC  
  	&& ѕроверка на отрицательное преобразуемое число  
  	NegSign = IIF(Left(cInString, 1) == "-", "-", "")  
  	IF .NOT. EMPTY(NegSign)  
  		cInString = SUBSTR(ALLTRIM(SUBSTR(cInString, 2)), 2)  
  	ENDIF  
  	&& ќпределение позиции дес€тичной точки  
  	DecPos = AT(".", cInString)  
  	IntStr = IIF(DecPos>1, SUBSTR(cInString, 1, DecPos - 1 ), IIF(DecPos = 1, "0", cInString))  
  	FracString = IIF(DecPos>0, SUBSTR(cInString, DecPos + 1 ), "0")  
  	&& ѕреобразование целой части из строковой формы к числовой в дес€тичной системе счислени€  
  	STORE LEN(IntStr) TO ln_len  
  	FOR ln_i = ln_len TO 1 STEP  - 1  
  		IntValue = IntValue + (AT(SUBSTR(IntStr, ln_i, 1), LDS_B2B_DIG) - 1) * (nInBase ** (ln_len - ln_i))  
  	NEXT  
      && ѕреобразование дробной части из строковой формы к числовой в дес€тичной системе счислени€  
      STORE LEN(FracString) TO ln_len  
  	FOR ln_i = 1 TO ln_len  
  		FracValue = FracValue + (AT(SUBSTR(FracString, ln_i, 1), LDS_B2B_DIG) - 1) * (nInBase ** ( - ln_i))  
      NEXT  
  	&& ¬ычисление целой части выходной строки  
  	Quotient = IntValue  
  	IntOutString = ""  
  	DO WHILE Quotient != 0  
  		Remainder = Quotient % nOutBase  
  		Quotient = INT(Quotient / nOutBase)  
  		IntOutString = SUBSTR(LDS_B2B_DIG, Remainder + 1, 1) + IntOutString  
  	ENDDO  
  	IF EMPTY(IntOutstring)  
  		STORE "0" TO IntOutString  
  	endif  
  	&& ¬ычисление дробной части выходной строки  
  	FracLimit = 20 - DecPos  
  	FracProduct = FracValue  
  	FracCounter = 1  
  	FracOutStr = ""  
  	DO WHILE FracCounter < FracLimit .AND. FracProduct < 0.00000000000001  
  		FracCounter = FracCounter + 1  
        	IntProdStr = FracProduct * nOutBase  
  		FracOutStr = FracOutStr + SUBSTR(LDS_B2B_DIG, INT(IntProdStr) + 1, 1)  
  		FracProduct = IntProdStr - INT(IntProdStr)  
  	ENDDO  
  ENDIF  
  IF varTYPE (cNewBaseValue) != T_LOGIC	&& ‘ормирование возвращаемой строки  
  	cNewBaseValue = IIF(DecPos > 0, NegSign + IntOutString + "." + FracOutStr, IntOutString)  
  ENDIF  
RETURN cNewBaseValue