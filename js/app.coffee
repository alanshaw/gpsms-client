define ['database', 'account', 'inbox', 'exports'], (database, account, inbox, exports) ->
	
	# Give the app module ability to bind and trigger custom named events
	#_.extend(exports, Backbone.Events)
	
	# The application versions (previous to current)
	versions = ['1.2.0', '2.0.0']
	
	###
	# @return {Array<String>} The application versions (previous to current)
	###
	exports.getVersions = -> versions.slice()
	
	###
	# @return {String} The current application version
	###
	exports.getVersion = -> _.last(versions)
	
	###
	# Initialises the application
	###
	exports.init = ->
		
		$.mobile.loading 'show'
		
		console.log "GPSMS #{exports.getVersion()}"
		
		database.migrate()
		
		# Does the user have an account?
		new account.AccountModel(id: 1).fetch
			success: (model) ->
				
				# Set the currently logged in user account
				account.set model
				
				console.log "Hi #{model.get('name')}"
				
				$.mobile.changePage inbox.InboxView.instance().$el
				
				$.mobile.loading 'hide'
				
			error: -> 
				
				$.mobile.changePage account.LoginView.instance().$el
				
				$.mobile.loading 'hide'
		
		delete exports.init
	
	return