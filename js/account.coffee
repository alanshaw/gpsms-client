define(['app', 'sync', 'exports'], (app, sync, exports) ->
	
	AccountRepository = ->
	
	_.extend AccountRepository,
		create: (model, options) -> 
			
			app.getDatabase().transaction(
				(tx) ->
					tx.executeSql(
						'INSERT INTO ACCOUNT (id, name, number, countryCode, password) VALUES (?, ?, ?, ?, ?)',
						[model.get('id'), model.get('name'), model.get('number'), model.get('countryCode'), model.get('password')]
					)
				options.success
				options.error
			)
			
		# No read by ID (only ONE account in GPSMS)
		read: (model, options) ->
			
			app.getDatabase().transaction(
				(tx) ->
					tx.executeSql(
						'SELECT id, name, number, countryCode, password FROM ACCOUNT'
						[]
						(tx, result) ->
							
							if !result.rows.length
								options.success null
							else 
								
								account = new AccountModel()
								row = result.rows[0]
								
								account.id = row.id
								account.name = row.name
								account.number = row.number
								account.countryCode = row.countryCode
								account.password = row.password
								
								options.success account
								
						options.error
					)
			)
			
		update: (model, options) ->
			
			app.getDatabase().transaction(
				(tx) ->
					tx.executeSql(
						'UPDATE ACCOUNT SET name = ?, number = ?, countryCode = ?, password = ?',
						[model.get('name'), model.get('number'), model.get('countryCode'), model.get('password')]
					)
				options.success
				options.error
			)
			
		delete: (model, options) ->
			
			app.getDatabase().transaction(
				(tx) -> tx.executeSql('DELETE FROM ACCOUNT WHERE id = ?', [model.get('id')])
				options.success
				options.error
			)
	
	repositoryInstance = null
	
	AccountRepository.instance = -> if repositoryInstance? then repositoryInstance else new AccountRepository()
	
	
	AccountModel = Backbone.Model.extend
		
		sync: sync.localSync
		
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
)