define ['database', 'util', 'lib/md5', 'exports'], (database, util, md5, exports) ->
	
	class AccountRepository
		
		@instance: (=> 
			instance = null
			=>
				instance = new @() if not instance
				instance
		)()
		
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
							
							account = if result.rows.length then new AccountModel(result.rows[0]) else null
							
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
	
	
	class AccountModel extends Backbone.Model
		
		sync: database.dbSync
		
		defaults:
			name: 'Unknown'
		
		initialize: -> @repository = AccountRepository.instance()
	
	exports.AccountModel = AccountModel
	
	
	###
	# Registration view
	###
	class RegistrationView extends Backbone.View
		
		@id: 'dlg-registration'
		
		@instance: (=> 
			instance = null
			=>
				instance = new @(el: '#' + @id) if not instance
				instance
		)()
		
		initialize: ->
			console.log 'RegistrationView initialize'
			
			@$el.bind 'pagebeforeshow', => @onPageBeforeShow()
		
		onPageBeforeShow: ->
			
			console.log 'RegistrationView onPageBeforeShow'
			
			@$('a[data-icon=delete]').hide()
	
	# Have this view singleton created automatically as the login form links to it
	util.instantiateViewBeforePageChange(RegistrationView)
	
	exports.RegistrationView = RegistrationView
	
	
	###
	# Login view
	###
	class LoginView extends Backbone.View
		
		@id: 'dlg-login'
		
		@instance: (=> 
			instance = null
			=>
				instance = new @(el: '#' + @id) if not instance
				instance
		)()
		
		initialize: ->
			console.log 'LoginView initialize'
			
			@$el.bind 'pagebeforeshow', => @onPageBeforeShow()
		
		onPageBeforeShow: ->
			
			console.log 'LoginView onPageBeforeShow'
			
			@$('a[data-icon=delete]').hide()
	
	util.instantiateViewBeforePageChange(LoginView)
	
	exports.LoginView = LoginView
	
	return