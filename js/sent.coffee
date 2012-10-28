define(['app', 'location', 'exports'], (app, location, exports) ->
	
	Sent = Backbone.View.extend
		
		events: 
			'click .content ul a': @onMessageItemClick
		
		initialize: ->
			
			messages = new messages.Messages()
			
			messages.on('add', (message) => @onMessageAdd(message))
			
			messages.fetch()
			
			@messages = messages
			
			app.on('messageSent', (message) => @onMessageSent(message))
		
		onMessageSent: (message) -> @messages.add(message)
		
		onMessageAdd: (message) ->
			
			list = @$('.content ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
		
		onMessageItemClick: (item) ->
			
			id = item.data('id')
			
			message = @messages.getById(id)
			
			location.Location.instance().show message
	
	instance = null
	
	Sent.instance = -> if instance? then instance else new Sent(el: $('#pg-sent')) 
	
	exports.Sent = Sent
	
	return
)