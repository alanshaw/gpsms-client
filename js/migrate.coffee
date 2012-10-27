define((require, exports, module) ->
	
	exports['1.2.0 to 2.0.0'] = (tx) ->
		
		console.log 'Starting migration from 1.2.0 to 2.0.0'
		
		tx.executeSql(
			'CREATE TABLE IF NOT EXISTS ACCOUNT (
				id unique,
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
				sender_id,
				recipients,
				latitude,
				longitude,
				text,
				created,
				read,
				state,
				CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES CONTACT.id ON DELETE CASCADE
			)'
		)
		
		console.log 'Completed migration from 1.2.0 to 2.0.0'
	
	return
)