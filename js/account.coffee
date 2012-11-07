define ['database', 'exports'], (database, exports) ->
	
	class AccountRepository extends database.CrudRepository
		
		create: (model, options) -> 
			
			fields = 'id,name,number,countryCode,password'
			values = _.map(fields.split(','), (field) -> model.get(field)) # Array of values
			places = _.map(values, -> '?').join() # String of ?'s
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						"INSERT INTO ACCOUNT (#{fields}) VALUES (#{values})",
						values
					)
				options.success
				options.error
			)
			
		# No read by ID (only ONE account in GPSMS)
		read: (model, options) ->
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						'SELECT id, name, number, countryCode, password FROM ACCOUNT'
						[]
						(tx, result) ->
							
							account = if !result.rows.length then null else new AccountModel(result.rows[0])
							
							options.success account
							
						options.error
					)
			)
			
		update: (model, options) ->
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						'UPDATE ACCOUNT SET name = ?, number = ?, countryCode = ?, password = ?',
						[model.get('name'), model.get('number'), model.get('countryCode'), model.get('password')]
					)
				options.success
				options.error
			)
			
		delete: (model, options) ->
			
			database.get().transaction(
				(tx) -> tx.executeSql('DELETE FROM ACCOUNT WHERE id = ?', [model.get('id')])
				options.success
				options.error
			)
	
	repositoryInstance = null
	
	AccountRepository.instance = -> if repositoryInstance? then repositoryInstance else new AccountRepository()
	
	
	AccountModel = Backbone.Model.extend
		
		sync: database.dbSync
		
		defaults:
			name: 'Unknown'
			number: ''
			countryCode: ''
			password: ''
			
		initialize: -> @repository = AccountRepository.instance()
	
	exports.AccountModel = AccountModel
	
	
	RegistrationView = Backbone.View.extend
		initialize: ->
	
	regViewInstance = null
	
	RegistrationView.instance = -> if regViewInstance? then regViewInstance else new RegistrationView(el: '#dlg-registration')
	
	exports.RegistrationView = RegistrationView
	
	return