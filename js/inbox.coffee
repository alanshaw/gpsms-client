define ['messages', 'location', 'exports'], (messages, location, exports) ->
	
	InboxView = Backbone.View.extend
		
		events: 
			'click .content ul a': @onMessageItemClick
		
		initialize: ->
			
			console.log 'InboxView initialize'
			
			@$el.bind 'pageshow', => @onPageShow()
			
			messages = new messages.MessageCollection()
			
			messages.on 'reset', => @onMessagesReset()
			messages.on 'add', (message) => @onMessageAdd(message)
			messages.on 'change', (message) => @onMessageChange(message)
			
			@messages = messages
			
			@lastRequestTime = 0
		
		onPageShow: ->
			
			console.log 'InboxView onPageShow'
			
			@messages.fetch 
				success: -> 
					console.log 'Messages fetch success'
					
					now = 0
					
					if @lastRequestTime + InboxView.AUTO_REQUEST_MAX_AGE > now
						
						# TODO: Request messages, add to @messages collection
						
						@lastRequestTime = now
				error: -> console.log arguments
		
		onMessageAdd: (message) ->
			
			console.log 'InboxView onMessageAdd'
			
			list = @$('[data-role=content] ul')
			
			# TODO: Template for message
			
			# TODO: Insert at correct position
		
		onMessageChange: (message) ->
			
			console.log 'InboxView onMessageChange'
			
			# TODO: Get message element and re-render
		
		onMessagesReset: -> @$('[data-role=content] ul').empty()
		
		onMessageItemClick: (item) ->
			
			console.log 'InboxView onMessageItemClick'
			
			id = item.data('id')
			
			message = @messages.getById(id)
			
			location.LocationView.instance().show message
	
	InboxView.AUTO_REQUEST_MAX_AGE = 1000 * 60 * 5
	
	instance = null
	
	InboxView.instance = -> if instance? then instance else new InboxView(el: $('#pg-inbox'))
	
	exports.InboxView = InboxView
	
	return