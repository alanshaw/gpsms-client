define ['database', 'account', 'inbox', 'util', 'lib/md5', 'exports'], (database, account, inbox, util, md5, exports) ->
	
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
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						"INSERT INTO ACCOUNT (#{fields}) VALUES (#{values})"
						values
					)
				options.success
				options.error
			)
			
		read: (model, options) ->
			
			console.log 'AccountRepository read'
			
			if model.get('id')?
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id, name, number, countryCode, password FROM ACCOUNT WHERE id = ?'
							[model.get('id')]
							(tx, result) ->
								
								if result.rows.length
									
									model.set(result.rows[0])
									
									options.success model
									
								else
									
									console.log 'No account with id ' + model.get('id')
									
									options.error(model)
						)
					-> options.error(model)
					null
				)
			
			else
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id, name, number, countryCode, password FROM ACCOUNT'
							[]
							(tx, result) ->
								
								accs = new AccountModel(row) for row in result.rows
								
								options.success accs
						)
					-> options.error(model)
					null
				)
			
		update: (model, options) ->
			
			console.log 'AccountRepository update'
			
			console.log [model.get('name'), model.get('number'), model.get('countryCode'), model.get('password'), model.get('id')]
			
			database.get().transaction(
				(tx) ->
					tx.executeSql(
						'UPDATE ACCOUNT SET name = ?, number = ?, countryCode = ?, password = ? WHERE id = ?',
						[model.get('name'), model.get('number'), model.get('countryCode'), model.get('password'), model.get('id')]
					)
				-> options.error(model)
				-> options.success(model)
			)
			
		delete: (model, options) ->
			
			console.log 'AccountRepository delete'
			
			database.get().transaction(
				(tx) -> tx.executeSql('DELETE FROM ACCOUNT WHERE id = ?', [model.get('id')])
				-> options.error(model)
				-> options.success(model)
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
			
			new account.AccountModel(id: 1).fetch
				success: (model) =>
					
					console.log 'Account details fetch success'
					
					model.save(
						data
						success: =>
							
							console.log 'Account details saved'
							
							# TODO: request to server to check credentials
							
							@loginSuccess()
							
						error: (model, error) ->
							
							navigator.notification.alert(error, null, 'Account details update error')
							
							$.mobile.loading 'hide'
					)
					
				error: =>
					
					console.log 'Account details fetch error'
					
					new account.AccountModel().save(
						data
						success: =>
							
							console.log 'Account details created'
							
							# TODO: request to server to check credentials
							
							@loginSuccess()
							
						error: (model, error) ->
							
							navigator.notification.alert(error, null, 'Account details create error')
							
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