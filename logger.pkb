CREATE OR REPLACE
PACKAGE	BODY &owner..logger
AS

	c_mailhost	CONSTANT VARCHAR2(30) := 'alsrv004.wataniya-algerie.com';

PROCEDURE	log_error
	(
	i_app_name	VARCHAR2,
	i_err_code	NUMBER,
	i_err_message	VARCHAR2,
	i_remark	VARCHAR2 := NULL
	)
IS
PRAGMA	AUTONOMOUS_TRANSACTION;
BEGIN

	INSERT	INTO &owner..runtime_errors
		(
		app_schema,
		app_name,
		sql_code,
		sql_errm,
		remark
		)
	VALUES	(
		SUBSTR( i_app_name, 1, INSTR( i_app_name, '.', 1 ) -1 ),
		SUBSTR( i_app_name, INSTR( i_app_name, '.', 1 ) + 1,
			LENGTH( i_app_name ) - INSTR( i_app_name, '.', 1 ) ),
		i_err_code,
		i_err_message,
		i_remark
		);
	COMMIT;

END	log_error;


PROCEDURE	get_error
	(
	i_app_name	IN VARCHAR2 := NULL,
	o_error_cur	IN OUT error_cur_type
	)
IS
BEGIN

	IF	i_app_name IS NOT NULL
	THEN
		OPEN	o_error_cur
		FOR
		SELECT	*
		FROM	&owner..runtime_errors
		WHERE	app_name = i_app_name;
	ELSE
		OPEN	o_error_cur
		FOR
		SELECT	*
		FROM	&owner..runtime_errors;
	END	IF;

END	get_error;

PROCEDURE who_called_me
	(
	owner		OUT VARCHAR2,
	name		OUT VARCHAR2,
	lineno		OUT NUMBER,
	caller_t	OUT VARCHAR2
	)
IS
	call_stack	VARCHAR2(4096) DEFAULT DBMS_UTILITY.FORMAT_CALL_STACK;
	n		NUMBER;
	found_stack	BOOLEAN DEFAULT FALSE;
	line		VARCHAR2(255);
	cnt		NUMBER := 0;
BEGIN

LOOP
	n := INSTR( call_stack, CHR(10) );

	EXIT WHEN ( cnt = 3 OR n IS NULL OR n = 0 );

	line := SUBSTR( call_stack, 1, n-1 );
	call_stack := substr( call_stack, n+1 );

	IF ( NOT found_stack )
	THEN
		IF ( line LIKE '%handle%number%name%' ) THEN
			found_stack := TRUE;
		END IF;
	ELSE
		cnt := cnt + 1;
		-- cnt = 1 is ME
		-- cnt = 2 is MY Caller
		-- cnt = 3 is Their Caller
		IF	cnt = 3
		THEN
			-- lineno := TO_NUMBER(SUBSTR( line, 13, 6 ));
			line   := SUBSTR( line, 21 );

			IF	( line LIKE 'pr%' )
			THEN
				n := LENGTH( 'procedure ' );
			ELSIF ( line LIKE 'fun%' )
			THEN
				n := LENGTH( 'function ' );
			ELSIF ( line LIKE 'package body%' )
			THEN
				n := LENGTH( 'package body ' );
			ELSIF ( line LIKE 'pack%' )
			THEN
				n := LENGTH( 'package ' );
			ELSIF ( line LIKE 'anonymous%' )
			THEN
				n := LENGTH( 'anonymous block ' );
			ELSE
				n := NULL;
			END	IF;

			IF	n IS NOT NULL
			THEN
			   caller_t := LTRIM( RTRIM( UPPER( SUBSTR( line, 1, n-1 ) ) ) );
			ELSE
			   caller_t := 'TRIGGER';
			END	IF;

			line := SUBSTR( line, NVL(n,1) );
			n := INSTR( line, '.' );
			owner := LTRIM(RTRIM(SUBSTR( line, 1, n-1 )));
			name  := LTRIM(RTRIM(SUBSTR( line, n+1 )));
		END IF;
	END IF;
END LOOP;
END	who_called_me;

FUNCTION	who_am_i
RETURN VARCHAR2
IS
	l_owner		VARCHAR2(30);
	l_name		VARCHAR2(30);
	l_lineno	NUMBER;
	l_type		VARCHAR2(30);
BEGIN

	who_called_me
		(
		l_owner,
		l_name,
		l_lineno,
		l_type
		);

	RETURN	l_owner || '.' || l_name;
END	who_am_i;

PROCEDURE	send_mail
	(
	i_sender	IN VARCHAR2,
	i_recipient	IN VARCHAR2,
	i_message	IN VARCHAR2
	)
IS

	v_mail_conn	UTL_SMTP.CONNECTION;
	v_message	RAW(200);
BEGIN

	v_mail_conn := UTL_SMTP.OPEN_CONNECTION( c_mailhost, 25 );
	UTL_SMTP.HELO( v_mail_conn, c_mailhost );
	UTL_SMTP.MAIL( v_mail_conn, i_sender );
	UTL_SMTP.RCPT( v_mail_conn, i_recipient );
	v_message := UTL_RAW.CAST_TO_RAW (i_message );
	UTL_SMTP.OPEN_DATA( v_mail_conn );
	UTL_SMTP.WRITE_RAW_DATA( v_mail_conn, v_message);
	UTL_SMTP.CLOSE_DATA( v_mail_conn );
	UTL_SMTP.QUIT( v_mail_conn );
END	send_mail;

END	logger;
/

SHOW ERROR

