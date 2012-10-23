require(['migrate', 'inbox'], (migrations, inbox) ->
	
	$(document).one('deviceready', ->
		console.log 'deviceready'
		
		# IMPORTANT!: When adding a new version, add it to the FRONT of this array
		versions = ['2.0.0', '1.2.0']
		version = null
		database = null
		
		# Work backwards from current version until we open a database of the correct version
		for version in versions
			try
				database = window.openDatabase('gpsms', version, 'GPSMS', 1000000)
				break
			catch invalidStateError
				console.error invalidStateError
		
		# Are we going to have to transition the database?
		if version isnt versions[0]
			
			# Get a list of versions we're going to have to transition through
			transitionVersions = versions.slice(0, versions.indexOf(version)).reverse()
			currentTransitionVersion = version
			
			# Perform schema migrations
			migrateDb = (tx) -> for transitionVersion in transitionVersions
				
				# Migration functions must follow the following naming convention
				migrationName = "#{currentTransitionVersion} to #{transitionVersion}"
				
				# Call the migration function if it exists
				migrations[migrationName]?(tx)
				
				# We are now at the next version
				currentTransitionVersion = transitionVersion
			
			onMigrateDbSuccess = -> database.changeVersion(version, versions[0])
			onMigrateDbError = (tx, error) -> alert "Error upgrading GPSMS database: #{error}"; throw error
			
			database.transaction(migrateDb, onMigrateDbError, onMigrateDbSuccess);
		
		new inbox.Inbox(el: $('#pg-inbox'))
	)
)