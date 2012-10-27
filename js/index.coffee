onDeviceReady = -> 
	
	console.log 'deviceready'
	
	require(['migrate', 'inbox'], (migrate, inbox) ->
		
		console.log 'Dependencies loaded'
		
		versions = ['1.2.0', '2.0.0']
		latestVersion = _.last(versions)
		version = null
		database = null
		
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
		
		new inbox.Inbox(el: $('#pg-inbox'))
	)
	
	true

document.addEventListener('deviceready', onDeviceReady, false)