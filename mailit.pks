CREATE	OR REPLACE
PACKAGE	&owner..mailit
AS

/*
|| Package to send e-mail from Oracle.
||
|| Created by Serge Shmygelskyy aka Shmyg
||
|| $Log: mailit.pks,v $
|| Revision 1.3  2008/01/31 07:46:18  shmyg
|| Added some comments
||
*/

	TYPE	addresslist_tab
	IS	TABLE
	OF	VARCHAR2(200)
	INDEX	BY BINARY_INTEGER;


	--Sends mail to specified users
	PROCEDURE	mailusers
		(
		to_list	IN VARCHAR2,
		cc_list	IN VARCHAR2,
		subj	IN VARCHAR2,
		body	IN CLOB
		);

	-- Sends mail to specified usergroups
	PROCEDURE	mailgroups
		(
		to_list	IN VARCHAR2,
		cc_list	IN VARCHAR2,
		subj	IN VARCHAR2,
		body	IN CLOB
		);

END;
/

SHOW ERROR

