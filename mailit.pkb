/*
|| Package to send e-mails directly from the database
|| Metalink
|| $Log: mailit.pkb,v $
|| Revision 1.3  2006/03/16 12:27:04  shmyg
|| Working version for RA system
||
|| Revision 1.2  2005-02-16 14:23:50  serge
|| *** empty log message ***
||
|| Revision 1.1  2004/11/03 11:53:52  serge
|| *** empty log message ***
||
||
*/
CREATE	OR REPLACE
PACKAGE	BODY &owner..mailit
AS

	c_mailhost CONSTANT VARCHAR2(30) := 'domino.umc.com.ua';

PROCEDURE	mailusers
	(
	to_list	IN VARCHAR2,
	cc_list	IN VARCHAR2,
	subj	IN VARCHAR2,
	body	IN CLOB
	)
IS

	conn	UTL_SMTP.CONNECTION;
	crlf	VARCHAR2(2):= CHR( 13 ) || CHR( 10 );
	mesg	VARCHAR2( 4000 );
	usrname	VARCHAR2( 30 );
	usraddr	VARCHAR2( 100 );

	CURSOR	get_user
	IS
	SELECT	user_fname,
		user_email
	FROM	user_mailids
	WHERE	user_alias = LOWER( USER );

	CURSOR	get_list
		(
		v_tempstr	IN VARCHAR2
		)
	IS
	SELECT	user_fname,
		user_email
	FROM	user_mailids
	WHERE	v_tempstr LIKE '%' || user_alias || '%';

	addrlist	addresslist_tab;
	addrcnt		BINARY_INTEGER:= 0;

BEGIN

	OPEN	get_user;

		FETCH	get_user
		INTO	usrname,
			usraddr;

		IF	get_user%NOTFOUND
		THEN
			CLOSE	get_user;
			RAISE_APPLICATION_ERROR( -20015, 'User not entered in USER_MAILIDS' );
		END	IF;

	CLOSE	get_user;

	conn:= UTL_SMTP.OPEN_CONNECTION( c_mailhost, 25 );
	utl_smtp.helo( conn, c_mailhost );
	utl_smtp.mail( conn, usraddr );

	FOR	listrec IN get_list( to_list )
	LOOP
		utl_smtp.rcpt( conn, listrec.user_email );
		addrcnt:= addrcnt + 1;
		addrlist( addrcnt ):= 'To: ' || listrec.user_fname ||
			'<' || listrec.user_email || '>' || crlf;

	END	LOOP;

	IF	addrcnt = 0
	THEN
		RAISE_APPLICATION_ERROR( -20016, 'No To: list generated' );
	END	IF;

	FOR listrec IN get_list( cc_list )
	LOOP
		utl_smtp.rcpt( conn, 'cc:' || listrec.user_email );
		addrcnt:= addrcnt + 1;
		addrlist( addrcnt ):= 'Cc: ' || listrec.user_fname ||
			'<' || listrec.user_email || '>' || crlf;
	END	LOOP;

	mesg:= 'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' ) || crlf ||
		'From: ' || usrname || ' <' || usraddr || '>' || crlf ||
		'Subject: ' || subj || crlf;

	FOR	i IN 1 .. addrcnt
	LOOP
		mesg:= mesg || addrlist( i );
	END	LOOP;

	mesg := mesg || '' || crlf || body;
	utl_smtp.data( conn, mesg );
	utl_smtp.quit( conn );

END;

PROCEDURE	mailgroups
	(
	to_list	IN VARCHAR2,
	cc_list	IN VARCHAR2,
	subj	IN VARCHAR2,
	body	IN CLOB
	)
IS

	conn	UTL_SMTP.CONNECTION;
	crlf	VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
	mesg	VARCHAR2( 4000 );
	usrname	VARCHAR2( 30 );
	usraddr	VARCHAR2( 100 );

	CURSOR	get_user
	IS
	SELECT	user_fname,
		user_email
	FROM	user_mailids
	WHERE	user_alias = LOWER( USER );

	CURSOR	get_list
		(
		v_tempstr	IN VARCHAR2
		)
	IS
	SELECT	user_fname,
		user_email
	FROM	user_mailids
	WHERE	v_tempstr LIKE '%' || user_group || '%';

	addrlist	addresslist_tab;

	addrcnt	BINARY_INTEGER:= 0;

BEGIN

	OPEN	get_user;

		FETCH	get_user
		INTO	usrname,
			usraddr;
		IF	get_user%NOTFOUND
		THEN
			CLOSE get_user;
			RAISE_APPLICATION_ERROR( -20015,
				'User not entered in USER_MAILIDS' );
		END	IF;

	CLOSE	get_user;

	conn:= utl_smtp.open_connection( c_mailhost, 25 );
	utl_smtp.helo( conn, c_mailhost );
	utl_smtp.mail( conn, usraddr );

	FOR	listrec IN get_list( to_list )
	LOOP
		utl_smtp.rcpt( conn, listrec.user_email );
		addrcnt:= addrcnt + 1;
		addrlist( addrcnt ):= 'To: ' || listrec.user_fname ||
			'<' || listrec.user_email || '>' || crlf;
	END	LOOP;

	IF	addrcnt = 0
	THEN
		RAISE_APPLICATION_ERROR( -20016, 'No To: list generated' );
	END	IF;

	FOR	listrec IN get_list( cc_list )
	LOOP
		utl_smtp.rcpt( conn, 'cc:' || listrec.user_email );
		addrcnt:= addrcnt + 1;
		addrlist( addrcnt ):= 'Cc: ' || listrec.user_fname ||
			'<' || listrec.user_email || '>' || crlf;
	END	LOOP;

	mesg:= 'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' ) || crlf ||
		'From: ' || usrname || ' <' || usraddr || '>' || crlf ||
		'Subject: ' || subj || crlf;

	FOR	i IN 1 .. addrcnt
	LOOP
		mesg:= mesg || addrlist( i );
	END	LOOP;

	mesg:= mesg || '' || crlf || body;
	utl_smtp.data( conn, mesg );
	utl_smtp.quit( conn );

END	mailgroups;
END;
/ 

SHOW ERROR
