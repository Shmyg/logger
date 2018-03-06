CREATE OR REPLACE
PACKAGE &owner..logger
AS

/*
|| Package to log any errors occuring during BSCS workarounds execution
|| Calls to the package should be added into EXCEPTION section of any SQL unit
|| in the Oracle database
|| Created by Serge Shmygelskyy aka Shmyg
||
|| $Log: logger.pks,v $
|| Revision 1.6  2008/01/31 07:46:18  shmyg
|| Added some comments
||
*/

	TYPE	error_cur_type
	IS	REF CURSOR
	RETURN	&owner..runtime_errors%ROWTYPE;

	/*
	Procedure to log any errors during the program units execution.
	Usage:
	log_error (logger.who_am_i, SQLCODE, SQLERRM, <remark>)
	remark is optional and could contain any relevant information
	The data is inserted in RUNTIME_ERRORS table in AUTONOUMOUS_TRANSACTION
	and is independent from main transaction.
	Should be used in any module to log errors in common storage
	*/
	PROCEDURE	log_error
		(
		i_app_name	VARCHAR2,
		i_err_code	NUMBER,
		i_err_message	VARCHAR2,
		i_remark	VARCHAR2 DEFAULT NULL
		);

	/*
	Procedure to look at the information about runtime errors. If I_APP_NAME
	is empty, returns all the errors from RUNTIME_ERRORS table
	*/
	PROCEDURE	get_error
		(
		i_app_name	IN VARCHAR2 DEFAULT NULL,
		o_error_cur	IN OUT error_cur_type
		);

	/*
	Procedure to see who called the module being run from AskTom
	*/
	PROCEDURE	who_called_me
		(
		owner		OUT VARCHAR2,
		name		OUT VARCHAR2,
		lineno		OUT NUMBER,
		caller_t	OUT VARCHAR2
		);

	/*
	Function to return the name of the module being run from AskTom
	*/
	FUNCTION	who_am_i
	RETURN VARCHAR2;

	/*
	Mail procedure. Can be used to send e-mail notification about any event
	directly from the database
	*/
	PROCEDURE	send_mail
		(
		i_sender	IN VARCHAR2,
		i_recipient	IN VARCHAR2,
		i_message	IN VARCHAR2
		);
END;
/

SHOW ERROR
