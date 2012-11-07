define ['database', 'exports'], (database, exports) ->
	
	exports.State = State = RECEIVED: 0, DRAFT: 1, UNSENT: 2, SENT: 3
	
	###
	# Message repositories operate on messages in a particular state
	###
	class MessageRepository extends database.CrudRepository
		
		constructor: (state = State.RECEIVED) -> @state = state
		
		create: (model, options) -> 
			
			fields = 'id,sender_id,recipients,latitude,longitude,text,created,read,state'
			values = _.map(fields.split(','), (field) -> model.get(field)) # Array of values
			places = _.map(values, -> '?').join() # String of ?'s
			
			database.get().transaction(
				(tx) -> tx.executeSql("INSERT INTO MESSAGE (#{fields}) VALUES (#{places})", values)
				options.success
				options.error
			)
		
		read: (model, options) ->
			
			if model.id?
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id,sender_id,recipients,latitude,longitude,text,created,read,state FROM MESSAGE WHERE id = ?'
							[model.get('id')]
							(tx, result) ->
								
								message = if !result.rows.length then null else new MessageModel(result.rows[0])
								
								options.success message
									
							options.error
						)
				)
				
			else
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id,sender_id,recipients,latitude,longitude,text,created,read,state FROM MESSAGE'
							[]
							(tx, result) ->
								
								messages = _.map(result.rows, (row) -> new MessageModel(row))
								
								options.success messages
								
							options.error
						)
				)
		
		update: (model, options) ->
			
			fields = 'sender_id,recipients,latitude,longitude,text,created,read,state,id'
			values = _.map(fields.split(','), (field) -> model.get(field)) # Array of values
			
			database.get().transaction(
				(tx) -> tx.executeSql('UPDATE MESSAGE SET name = ?, number = ?, countryCode = ?, password = ? WHERE id = ?', values)
				options.success
				options.error
			)
		
		delete: (model, options) ->
			
			database.get().transaction(
				(tx) -> tx.executeSql('DELETE FROM MESSAGE WHERE id = ?', [model.get('id')])
				options.success
				options.error
			)
	
	MessageModel = Backbone.Model.extend
		
		sync: database.dbSync
		
		initialize: -> @repository = new MessageRepository(State.RECEIVED)
	
	exports.MessageModel = MessageModel
	
	DraftMessageModel = MessageModel.extend
		initialize: -> @repository = new MessageRepository(State.RECEIVED)
	
	UnsentMessageModel = MessageModel.extend
		initialize: -> @repository = new MessageRepository(State.UNSENT)
	
	SentMessageModel = MessageModel.extend
		initialize: -> @repository = new MessageRepository(State.SENT)
	
	MessageCollection = Backbone.Collection.extend
		model: MessageModel
	
	exports.MessageCollection = MessageCollection
	
	exports.DraftMessageCollection = MessageCollection.extend model: DraftMessageModel
	
	exports.UnsentMessageCollection = MessageCollection.extend model: UnsentMessageModel
	
	exports.UnsentMessageCollection = MessageCollection.extend model: SentMessageModel
	
	return