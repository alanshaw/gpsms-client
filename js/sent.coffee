define ['app', 'location', 'util', 'exports'], (app, location, util, exports) ->
	
	class SentView extends Backbone.View
		
		@id: 'pg-sent'
		
		@instance: (=> 
			instance = null
			=>
				instance = new @(el: '#' + @id) if not instance
				instance
		)()
		
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
	
	util.instantiateViewBeforePageChange(SentView)
	
	exports.SentView = SentView
	
	return