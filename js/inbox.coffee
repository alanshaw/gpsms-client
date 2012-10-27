define(['app', 'messages', 'exports'], (app, messages, exports) ->
	
	Inbox = Backbone.View.extend
		
		initialize: ->
			
			@$el.one('pageShow', => @render())
			
			messages = new messages.Messages()
			
			messages.on('add', (message) =>
				@renderMessage(message)
			)
			
			@messages = messages
		
		render: ->
			
			list = @$('.content ul')
			
			list.empty()
			
			@messages.each((message) =>
				@renderMessage(message)
			)
		
		###
		# @param {Message} The message Model to render
		###
		renderMessage: (message) ->
			
			list = @$('.content ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
			
			# TODO: Attach click event
		
		
	exports.Inbox = Inbox
	
	return
)