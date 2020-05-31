@ECHO OFF
IF %1 == "" GOTO ERROR1
IF EXIST D:\OUT\SJ31%1.ZIP GOTO Q1
GOTO CONT

:Q1
ECHO Hey, the entry %1 already exists, still continue?
PAUSE
ECHO .
GOTO CONT

:CONT
D:
CD D:\SJ3\CODE\313
D:\code\bp\bin\BPC.EXE -CP -$E- -$G+ -$N+ -$D- -$L- -$Y- -$M49152,0,655360 SJ3.PAS
IF NOT ERRORLEVEL 0 GOTO ERROR2
ECHO .

MOVE D:\SJ3\CODE\313\SJ3.EXE D:\SJ3\CODE\313\REGPACK\
rem @ECHO %1 %rname %_date >> d:\out\packlog.txt

CD D:\SJ3\CODE\313\REGPACK

D:\SYS\PKZIP d:\out\sj31%1.zip @d:\sj3\code\313\packreg.lst

CD ..
GOTO END
:ERROR2
ECHO Error: Could Not Compile.
GOTO END

:ERROR1
ECHO Error: Missing Arguments.
GOTO END

:END
ECHO All done.

