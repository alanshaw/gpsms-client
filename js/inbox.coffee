define(['app', 'messages', 'location', 'exports'], (app, messages, location, exports) ->
	
	InboxView = Backbone.View.extend
		
		events: 
			'click .content ul a': @onMessageItemClick
		
		initialize: ->
			
			@$el.bind('pageShow', => @onPageShow())
			
			messages = new messages.MessageCollection()
			
			messages.on('add', (message) => @onMessageAdd(message))
			messages.on('change', (message) => @onMessageChange(message))
			
			messages.fetch()
			
			@messages = messages
			
			@lastRequestTime = 0
		
		onPageShow: ->
			
			now = 0
			
			if @lastRequestTime + InboxView.AUTO_REQUEST_MAX_AGE > now
				
				# TODO: Request messages, add to @messages collection
				
				@lastRequestTime = now
		
		onMessageAdd: (message) ->
			
			list = @$('.content ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
		
		onMessageChange: (message) ->
			
			# TODO: Get message element and re-render
			
		
		onMessageItemClick: (item) ->
			
			id = item.data('id')
			
			message = @messages.getById(id)
			
			location.LocationView.instance().show message
	
	InboxView.AUTO_REQUEST_MAX_AGE = 1000 * 60 * 5
	
	instance = null
	
	InboxView.instance = -> if instance? then instance else new InboxView(el: $('#pg-inbox'))
	
	exports.InboxView = InboxView
	
	return
)