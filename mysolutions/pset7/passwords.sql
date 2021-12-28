/*
1a) Create a table called user_info that will store the data for this 
password mechanism. There are three string values the table needs to store:
o Usernames, in a column named username, will be up to 20 characters long 
o Salt values, in a column named salt
o The hashed value of the password, called password_hash
*/

CREATE TABLE user_info (
  username VARCHAR(20) PRIMARY KEY,
  salt VARCHAR(20) NOT NULL,
  password_hash VARCHAR(64) NOT NULL
);

/*
Create a stored procedure sp_add_user(new_username, password). 
This procedure is very simple:
o Generate a new salt.
o Add a new record to your user_info table with the username, salt, 
and salted password.
*/
DELIMITER !
CREATE PROCEDURE 
  sp_add_user(new_username VARCHAR(20), password VARCHAR(20))
  BEGIN
    DECLARE salt CHAR(6) DEFAULT make_salt(6);
    INSERT INTO user_info 
      VALUES (new_username, salt, sha2(CONCAT(salt, password), 256));
  END !
DELIMITER ;

/*  
Create a stored procedure sp_change_password(username, new_password). 
This procedure is virtually identical to the previous procedure, 
except that an existing user record will be updated, rather than 
adding a new record.
*/
DELIMITER !
CREATE PROCEDURE 
  sp_change_password(username VARCHAR(20), new_password VARCHAR(20))
  BEGIN
    DECLARE salt CHAR(6) DEFAULT make_salt(6);
    UPDATE user_info AS ui 
    SET ui.salt = salt, 
        ui.password_hash = sha2(CONCAT(salt, new_password), 256)
    WHERE ui.username = username;
  END !
DELIMITER ;
 
/*
1d) Create a function (not a procedure) called 
authenticate(username, password), which returns a BOOLEAN value of TRUE 
or FALSE, based on whether a valid username and password have been 
provided. The function should return TRUE iff:
o The username actually appears in the user_info table, and
o When the specified password is salted and hashed, the resulting hash 
matches the hash stored in the database
*/

DELIMITER !
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS VARCHAR(64) BEGIN
  DECLARE salt CHAR(6);
  DECLARE password_hash VARCHAR(64);
  
  SELECT ui.salt , ui.password_hash 
    INTO salt, password_hash
    FROM user_info AS ui
    WHERE ui.username = username
    ;
  RETURN IF(password_hash = sha2(CONCAT(salt, password), 256), 1, 0);
END !
DELIMITER ;

CALL sp_add_user('alice', 'hello'); 
CALL sp_add_user('bob', 'goodbye');

SELECT authenticate('carl', 'hello');    -- Should return 0/FALSE 
SELECT authenticate('alice', 'goodbye'); -- Should return 0/FALSE
SELECT authenticate('alice', 'hello');   -- Should return 1/TRUE
SELECT authenticate('bob', 'goodbye');   -- Should return 1/TRUE

CALL sp_change_password('alice', 'greetings');

SELECT authenticate('alice', 'hello');     -- Should return 0/FALSE
SELECT authenticate('alice', 'greetings'); -- Should return 1/TRUE
SELECT authenticate('bob', 'greetings');   -- Should return 0/FALSE
