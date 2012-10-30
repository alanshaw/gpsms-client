define(['app', 'location', 'exports'], (app, location, exports) ->
	
	SentView = Backbone.View.extend
		
		events: 
			'click .content ul a': @onMessageItemClick
		
		initialize: ->
			
			messages = new messages.MessageCollection()
			
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
			
			location.LocationView.instance().show message
	
	instance = null
	
	SentView.instance = -> if instance? then instance else new SentView(el: $('#pg-sent')) 
	
	exports.SentView = SentView
	
	return
)