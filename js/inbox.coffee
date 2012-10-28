define(['app', 'messages', 'exports'], (app, messages, exports) ->
	
	instance = null
	
	Inbox = Backbone.View.extend
		
		instance: ->
			if instance? then instance else new Inbox(el: $('#pg-inbox'))
		
		initialize: ->
			
			@$el.bind('pageShow', => @onPageShow())
			
			messages = new messages.Messages()
			
			messages.on('add', (message) =>
				@renderMessage(message)
			)
			
			messages.fetch()
			
			@messages = messages
			
			@lastRequestTime = 0
		
		onPageShow: ->
			
			now = 0
			
			if @lastRequestTime + Inbox.AUTO_REQUEST_MAX_AGE > now
				
				# TODO: Request messages, add to @messages collection
				
				@lastRequestTime = now
		
		###
		# @param {Message} The message Model to render
		###
		renderMessage: (message) ->
			
			list = @$('.content ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
			
			# TODO: Attach click event
		
	
	Inbox.AUTO_REQUEST_MAX_AGE = 1000 * 60 * 5
	
	exports.Inbox = Inbox
	
	return
)