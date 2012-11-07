define ['database', 'account', 'inbox', 'exports'], (database, account, inbox, exports) ->
	
	console.log 'Dependencies loaded'
	
	# Give the app module ability to bind and trigger custom named events
	_.extend(exports, Backbone.Events)
	
	# The application versions (previous to current)
	versions = ['1.2.0', '2.0.0']
	
	###
	# @return {String}
	###
	exports.getVersion = -> _.last(versions)
	
	###
	# Initialises the application
	###
	exports.init = ->
		
		console.log "GPSMS #{exports.getVersion()}"
		
		database.migrate(versions)
		
		# Does the user have an account?
		new account.AccountModel().fetch(success: (model) ->
			
			if model?
				view = inbox.InboxView.instance()
			else
				view = account.RegistrationView.instance()
			
			$.mobile.changePage(view.el)
		)
		
		delete exports.init
	
	return