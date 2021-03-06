define (require, exports, module) ->
	
	exports['1.2.0 to 2.0.0'] = (tx) ->
		
		tx.executeSql(
			'CREATE TABLE IF NOT EXISTS ACCOUNT (
				id INTEGER PRIMARY KEY,
				number,
				name,
				countryCode,
				password
			)'
		)
		
		tx.executeSql(
			'CREATE TABLE IF NOT EXISTS DEVICE (
				id unique,
				token
			)'
		)
		
		tx.executeSql(
			'CREATE TABLE IF NOT EXISTS CONTACT (
				id unique,
				number,
				name,
				countryCode
			)'
		)
		
		tx.executeSql(
			'CREATE TABLE IF NOT EXISTS MESSAGE (
				id unique,
				account_id,
				sender_id,
				recipients,
				latitude,
				longitude,
				text,
				created,
				read,
				state,
				CONSTRAINT fk_message_account FOREIGN KEY (account_id) REFERENCES ACCOUNT (id) ON DELETE CASCADE,
				CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES CONTACT (id) ON DELETE CASCADE
			)'
		)
	
	return