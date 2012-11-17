define ['database', 'account', 'util', 'lib/md5', 'exports'], (database, account, util, md5, exports) ->
	
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
							
							acc = if result.rows.length then new AccountModel(result.rows[0]) else null
							
							options.success acc
							
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
		
		@emptyPasswords: [md5(''), md5(null), md5(undefined), '']
		
		sync: database.dbSync
		
		defaults:
			name: 'Unknown'
		
		initialize: -> @repository = AccountRepository.instance()
		
		validate: (attrs) -> 
			
			if 'name' of attrs and ($.type(attrs.name) isnt 'string' or attrs.name is '')
				return 'Invalid name'
			
			if 'number' of attrs and ($.type(attrs.number) isnt 'string' or attrs.number is '')
				return 'Invalid phone number'
			
			if 'countryCode' of attrs and ($.type(attrs.countryCode) isnt 'string' or attrs.countryCode is '')
				return 'Invalid country code'
			
			if 'password' of attrs and ($.type(attrs.password) isnt 'string' or AccountModel.emptyPasswords.indexOf(attrs.password) isnt -1)
				return 'Invalid password'
	
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
			
			@$('form').submit((event) => @onLoginFormSubmit(event))
		
		onPageBeforeShow: ->
			
			console.log 'LoginView onPageBeforeShow'
			
			@$('a[data-icon=delete]').hide()
		
		onLoginFormSubmit: (event) ->
			
			event.preventDefault()
			
			$.mobile.loading 'show'
			
			new account.AccountModel().fetch
				success: (model) =>
					
					data = {}
					
					_.each @$('form').serializeArray(), (i, field) -> data[field.name] = field.value
					
					model.save(
						data,
						success: =>
							
							console.log 'Login details successfully saved'
							
							# TODO: request to server to check credentials
							# TODO: If correct, close dialog, change to inbox view
							
							$.mobile.loading 'hide'
							
						error: (model, error) ->
							
							navigator.notification.alert(error, null, 'Login error')
							
							$.mobile.loading 'hide'
					)
					
		onLoginSuccess: -> console.log 'Login success!'
	
	util.instantiateViewBeforePageChange(LoginView)
	
	exports.LoginView = LoginView
	
	return