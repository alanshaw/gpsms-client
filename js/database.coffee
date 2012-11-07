define ['migrate', 'exports'], (migrate, exports) ->
	
	database = null
	
	###
	# @return {Database}
	###
	exports.get = -> database
	
	###
	# Migrate the database from the current state to the latest version. 
	#
	# @param {Array<String>} versions The application versions (previous to current) 
	###
	exports.migrate = (versions) ->
		
		latestVersion = _.last(versions)
		
		# Work forwards from first version until we open a database of the correct version
		for version in versions
			try
				database = window.openDatabase('gpsms', version, 'GPSMS', 1000000)
				break
			catch invalidStateError
				console.log "Database isn't version #{version}"
		
		console.log "App version is #{latestVersion}, database version is #{version}"
		
		# Are we going to have to transition the database?
		if version isnt latestVersion
			
			# Get a list of versions we're going to have to transition through
			transitionVersions = versions.slice(versions.indexOf(version) + 1)
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
			
			onMigrateDbSuccess = -> database.changeVersion(version, latestVersion)
			
			onMigrateDbError = (tx, error) -> 
				
				console.error tx
				
				console.error error
				
				alert "Error upgrading GPSMS database"
				
				throw error
			
			database.transaction(migrateDb, onMigrateDbError, onMigrateDbSuccess)
	
	###
	# CRUD repository interface
	###
	exports.CrudRepository = class
		create: (model, options) -> 
		read: (model, options) -> 
		update: (model, options) -> 
		delete: (model, options) -> 
	
	logArgs = -> console.log arguments
	
	defaultSyncOptions = success: logArgs, error: logArgs
	
	###
	# A Backbone.sync function that makes use of a CrudRepository
	###
	dbSync = (method, model, options) ->
		
		options = _.extend(defaultSyncOptions, options)
		
		repository = model.repository
		
		switch method
			when 'create' then repository.create(model, options)
			when 'read' then repository.read(model, options)
			when 'update' then repository.update(model, options)
			when 'delete' then repository.delete(model, options)
	
	exports.dbSync = dbSync
	
	return