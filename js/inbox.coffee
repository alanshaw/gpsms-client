define(['app', 'messages', 'location', 'exports'], (app, messages, location, exports) ->
	
	Inbox = Backbone.View.extend
		
		initialize: ->
			
			@$el.bind('pageShow', => @onPageShow())
			
			messages = new messages.Messages()
			
			messages.on('add', (message) =>
				@onMessageAdd(message)
			)
			
			messages.on('change', (message) =>
				@onMessageChange(message)
			)
			
			messages.fetch()
			
			@messages = messages
			
			@lastRequestTime = 0
		
		onPageShow: ->
			
			now = 0
			
			if @lastRequestTime + Inbox.AUTO_REQUEST_MAX_AGE > now
				
				# TODO: Request messages, add to @messages collection
				
				@lastRequestTime = now
		
		onMessageAdd: (message) ->
			
			list = @$('.content ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
			
			# TODO: Attach click event
		
		onMessageChange: (message) ->
			
			# TODO: Get message element and re-render
			
		
		onMessageItemClick: (item) ->
			
			id = item.data('id')
			
			message = @messages.getById(id)
			
			location.Location.instance().show message
	
	Inbox.AUTO_REQUEST_MAX_AGE = 1000 * 60 * 5
	
	instance = null
	
	Inbox.instance = -> if instance? then instance else new Inbox(el: $('#pg-inbox'))
	
	exports.Inbox = Inbox
	
	return
)