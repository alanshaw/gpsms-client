define(['app', 'exports'], (app, exports) ->
	
	Sent = Backbone.View.extend
		
		initialize: ->
			
			messages = new messages.Messages()
			
			messages.on('add', (message) =>
				@onMessageAdd(message)
			)
			
			messages.fetch()
			
			@messages = messages
			
			app.on('messageSent', (message) => 
				@onMessageSent(message)
			)
		
		onMessageSent: (message) -> @messages.add(message)
		
		onMessageAdd: (message) ->
			
			list = @$('.content ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
			
			# TODO: Attach click event
		
		onMessageItemClick: (item) ->
			
			id = item.data('id')
			
			message = @messages.getById(id)
			
			location.Location.instance().show message
)