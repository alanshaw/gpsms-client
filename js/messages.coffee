define ['database', 'exports'], (database, exports) ->
	
	exports.State = State = RECEIVED: 0, DRAFT: 1, UNSENT: 2, SENT: 3
	
	###
	# Message repositories operate on messages in a particular state
	###
	class MessageRepository
		
		constructor: (state = State.RECEIVED) -> @state = state
		
		create: (model, options) -> 
			
			fields = 'id,sender_id,recipients,latitude,longitude,text,created,read'
			values = _.map(fields.split(','), (field) -> model.get(field)) # Array of values
			places = _.map(values, -> '?').join() # String of ?'s
			
			messageId = null
			
			database.get().transaction(
				(tx) -> tx.executeSql(
					"INSERT INTO MESSAGE (#{fields},state) VALUES (#{places},#{@state})",
					values
					(tx, result) -> messageId = result.insertId
					options.error
				)
				options.error
				-> 
					console.log "New account id = #{messageId}"
					
					model.set 'id', messageId
					
					options.success model
			)
		
		read: (model, options) ->
			
			rows = []
			
			if model.get('id')?
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id,sender_id,recipients,latitude,longitude,text,created,read FROM MESSAGE WHERE id = ? AND state = ?'
							[model.get('id'), @state]
							(tx, result) -> rows = result.rows
							options.error
						)
					options.error
					->
						
						if rows.length
							
							model.set rows[0]
							
							options.success model
							
						else
							
							options.error(new Error('No message with id ' + model.get('id')))
				)
				
			else
				
				database.get().transaction(
					(tx) ->
						tx.executeSql(
							'SELECT id,sender_id,recipients,latitude,longitude,text,created,read FROM MESSAGE WHERE state = ?'
							[@state]
							(tx, result) -> rows = result.rows
							options.error
						)
					options.error
					-> 
						messages = new MessageModel(row) for row in rows
						
						options.success messages
				)
		
		update: (model, options) ->
			
			fields = 'sender_id,recipients,latitude,longitude,text,created,read,id'
			values = _.map(fields.split(','), (field) -> model.get(field)).push(@state) # Array of values
			
			database.get().transaction(
				(tx) -> tx.executeSql(
					'UPDATE MESSAGE SET name = ?, number = ?, countryCode = ?, password = ? WHERE id = ? AND state = ?'
					values
				)
				-> options.error(model)
				-> options.success(model)
			)
		
		delete: (model, options) ->
			
			database.get().transaction(
				(tx) -> tx.executeSql('DELETE FROM MESSAGE WHERE id = ? AND state = ?', [model.get('id'), @state])
				-> options.error(model)
				-> options.success(model)
			)
	
	class MessageModel extends Backbone.Model
		
		sync: database.dbSync
		
		repository: new MessageRepository(State.RECEIVED)
	
	exports.MessageModel = MessageModel
	
	class DraftMessageModel extends MessageModel
		repository: new MessageRepository(State.DRAFT)
	
	class UnsentMessageModel extends MessageModel
		repository: new MessageRepository(State.UNSENT)
	
	class SentMessageModel extends MessageModel
		repository: new MessageRepository(State.SENT)
	
	class MessageCollection extends Backbone.Collection
		
		sync: database.dbSync
		
		repository: new MessageRepository(State.RECEIVED)
		
		model: MessageModel
	
	exports.MessageCollection = MessageCollection
	
	class DraftMessageCollection extends MessageCollection
		
		model: DraftMessageModel
		
		repository: new MessageRepository(State.DRAFT)
	
	exports.DraftMessageCollection = DraftMessageCollection
	
	class UnsentMessageCollection extends MessageCollection
		
		model: UnsentMessageModel
		
		repository: new MessageRepository(State.UNSENT)
	
	exports.UnsentMessageCollection = UnsentMessageCollection
	
	class SentMessageCollection extends MessageCollection
		
		model: SentMessageModel
		
		repository: new MessageRepository(State.SENT)
	
	exports.SentMessageCollection = SentMessageCollection
	
	return