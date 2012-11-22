###
# Account module
#
# Events: 
# 	accountChange - Fired when the current account is changed, listener is passed the AccountModel of the new account
###
define ['database', 'inbox', 'util', 'lib/md5', 'exports'], (database, inbox, util, md5, exports) ->
	
	_.extend(exports, Backbone.Events);
	
	account = null
	
	###
	# @return {AccountModel} The current user account
	###
	exports.get = -> account
	
	###
	# Set the account of the currently logged in user. Fires the accountChange event.
	#
	# @param {AccountModel} newAccount The account of the currently logged in user
	###
	exports.set = (newAccount) -> 
		account = newAccount
		exports.trigger 'accountChange', newAccount
	
	
	class AccountRepository
		
		@instance: (=> 
			instance = null
			=>
				instance = new @() if not instance
				instance
		)()
		
		create: (model, options) -> 
			
			console.log 'AccountRepository create'
			
			fields = 'name,number,countryCode,password'
			values = _.map(fields.split(','), (field) -> model.get(field)) # Array of values
			places = _.map(values, -> '?').join() # String of ?'s
			
			accountId = null
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						"INSERT INTO ACCOUNT (#{fields}) VALUES (#{places})"
						values
						(tx, result) -> accountId = result.insertId
						options.error
					)
				options.error
				-> 
					console.log "New account id = #{accountId}"
					
					model.set 'id', accountId
					
					options.success model
			)
			
		read: (model, options) ->
			
			console.log 'AccountRepository read'
			
			rows = []
			
			if model.get('id')?
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id, name, number, countryCode, password FROM ACCOUNT WHERE id = ?'
							[model.get('id')]
							(tx, result) -> rows = result.rows
							options.error
						)
					options.error
					->
						if rows.length
							
							model.set rows[0]
							
							options.success model
							
						else
							
							console.log 'No account with id ' + model.get('id')
							
							options.error(new Error('No account with id ' + model.get('id')))
				)
			
			else
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id, name, number, countryCode, password FROM ACCOUNT'
							[]
							(tx, result) -> rows = result.rows
							options.error
						)
					options.error
					-> 
						accs = new AccountModel(row) for row in rows
						
						options.success accs
				)
			
		update: (model, options) ->
			
			console.log 'AccountRepository update'
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						'UPDATE ACCOUNT SET name = ?, number = ?, countryCode = ?, password = ? WHERE id = ?',
						[model.get('name'), model.get('number'), model.get('countryCode'), model.get('password'), model.get('id')]
						(tx, result) ->
						options.error
					)
				options.error
				-> options.success model
			)
			
		delete: (model, options) ->
			
			console.log 'AccountRepository delete'
			
			database.get().transaction(
				(tx) -> 
					tx.executeSql(
						'DELETE FROM ACCOUNT WHERE id = ?'
						[model.get('id')]
						(tx, result) ->
						options.error
					)
				options.error
				options.success
			)
	
	
	class AccountModel extends Backbone.Model
		
		@emptyPasswords: [md5(''), md5(null), md5(undefined), '']
		
		sync: database.dbSync
		
		defaults:
			name: 'Unknown'
		
		initialize: -> @repository = AccountRepository.instance()
		
		validate: (attrs) -> 
			
			console.log 'AccountModel validate'
			
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
			
			console.log 'LoginView onLoginFormSubmit'
			
			event.preventDefault()
			
			$.mobile.loading 'show'
			
			data = 
				number: @$('input[name=number]').val()
				countryCode: @$('select[name=country-code]').val()
				password: md5(@$('input[name=password]').val())
			
			new AccountModel(id: 1).fetch
				success: (model) => @login(data, model)
				error: => @login(data)
		
		###
		# Login the user using the passed credentials
		#
		# @param {Object} credentials Login data required to login
		# @param {String} credentials.number The user's phone number
		# @param {String} credentials.countryCode The user's country code
		# @param {String} credentials.password The user's encrypted password
		# @param {AccountModel} [existingAccount] The existing account (if the user has one). Must be passed if the
		# user DOES have an account otherwise a new account will be created. Updated with the loginData.
		###
		login: (credentials, existingAccount) ->
			
			existingAccount = new AccountModel() if not existingAccount?
			action = if existingAccount.isNew() then 'create' else 'update'
			
			existingAccount.save(
				credentials
				success: =>
					
					console.log "Account details #{action}d"
					
					# TODO: request to server to check credentials
					
					exports.set existingAccount
					
					@loginSuccess()
					
				error: (error) ->
					
					navigator.notification.alert(error.message, null, "Account details #{action} error")
					
					$.mobile.loading 'hide'
			)
		
		loginSuccess: ->
			
			console.log 'Login success!'
			
			$.mobile.loading 'hide'
			
			@$el.dialog 'close'
			
			setTimeout(-> $.mobile.changePage inbox.InboxView.instance().$el, 1000)
			
	
	util.instantiateViewBeforePageChange(LoginView)
	
	exports.LoginView = LoginView
	
	return