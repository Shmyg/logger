/*
|| Script to create utilities to log errors, send mail etc
||
|| $Log: dbsetup.sql,v $
|| Revision 1.4  2008/01/31 07:46:18  shmyg
|| Added some comments
||
|| Revision 1.3  2006-03-16 12:27:04  shmyg
|| Working version for RA system
||
|| Revision 1.2  2004-11-03 11:53:52  serge
|| *** empty log message ***
||
|| Revision 1.1.1.1  2004/11/01 16:45:51  serge
*/

SET ECHO ON
SET SERVEROUTPUT ON
SET VERIFY ON
SPOOL /tmp/logger.txt

CREATE  TABLE &owner..runtime_errors
        (
	app_schema	VARCHAR2(30),
	app_name	VARCHAR2(30),
        sql_code        NUMBER,
        sql_errm        VARCHAR2(400),
	remark		VARCHAR2(2000),
	err_date	DATE DEFAULT SYSDATE
        )
/

COMMENT	ON TABLE &owner..runtime_errors IS 'Log-table for errors occuring during workarounds execution.
Does not belong to BSCS installation. Created by Serge Shmygelskyy'
/

CREATE TABLE &owner..user_mailids
	(
	user_alias	VARCHAR2(30),
	user_fname	VARCHAR2(100),
	user_email	VARCHAR2(100),
	user_group	VARCHAR2(30)
	)
/

COMMENT	ON TABLE &owner..runtime_errors IS 'Contains e-mails to send messages in case of errors in workaround.
Does not belong to BSCS installation. Created by Serge Shmygelskyy'
/

INSERT	INTO &owner..user_mailids
VALUES	(
	'&owner.',
	'Oracle daemon',
	'oracle@umc.ua',
	'daemons'
	);

COMMIT
/

@logger.pks
@logger.pkb
@mailit.pks
@mailit.pkb

SPOOL OFF
