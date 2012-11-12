define ['app', 'migrate', 'exports'], (app, migrate, exports) ->
	
	database = null
	
	###
	# Migrate the database from the current state to the latest version. 
	#
	# @param {Array<String>} versions The application versions (previous to current) 
	###
	exports.migrate = ->
		
		appVersions = app.getVersions()
		appVersion = app.getVersion()
		
		# Work forwards from first app version until we open a database of the correct version
		for dbVersion in appVersions
			try
				database = window.openDatabase('gpsms', dbVersion, 'GPSMS', 1000000)
				break
			catch invalidStateError
				console.log "Database isn't version #{dbVersion}"
		
		if not database then throw new Error 'Web SQL Database API unavailable'
		
		console.log "App version is #{appVersion}, database version is #{dbVersion}"
		
		# Are we going to have to transition the database?
		if dbVersion isnt appVersion
			
			# Get a list of versions we're going to have to transition through
			transitionVersions = appVersions.slice(appVersions.indexOf(dbVersion) + 1)
			currentTransitionVersion = version
			
			# Perform schema migrations
			migrateDb = (tx) -> for transitionVersion in transitionVersions
				
				# Migration functions must follow the following naming convention
				migrationName = "#{currentTransitionVersion} to #{transitionVersion}"
				
				console.log "Migrating #{migrationName}"
				
				# Call the migration function if it exists
				migrate[migrationName]?(tx)
				
				# We are now at the next version
				currentTransitionVersion = transitionVersion
			
			onMigrateDbSuccess = -> database.changeVersion(dbVersion, appVersion)
			
			onMigrateDbError = (tx, error) -> 
				
				console.error tx
				
				console.error error
				
				alert "Error upgrading GPSMS database"
				
				throw error
			
			database.transaction(migrateDb, onMigrateDbError, onMigrateDbSuccess)
	
	###
	# Get a connection to the database.
	#
	# @return {Database}
	###
	exports.get = -> 
		if not database then exports.migrate()
		database
	
	logArgs = -> console.log arguments
	
	defaultSyncOptions = success: logArgs, error: logArgs
	
	###
	# A Backbone.sync function that makes use of a CrudRepository
	###
	exports.dbSync = (method, model, options) ->
		
		_.defaults options, defaultSyncOptions
		
		repository = model.repository
		
		switch method
			when 'create' then repository.create(model, options)
			when 'read' then repository.read(model, options)
			when 'update' then repository.update(model, options)
			when 'delete' then repository.delete(model, options)
		
		return
	
	return