define(['app', 'exports'], (app, exports) ->
	
	Location = Backbone.View.extend
		
		initialize: -> 
			
			@$el
				.bind('pageShow', => @onPageShow())
				.bind('pageHide', => @onPageHide())
			
			# TODO: Load google maps, pinpoint location
			map = @$('.map')
		
		show: (message) ->
			# TODO: Add current location pin, message sender pin, centre map
		
		onPageShow: ->
			# TODO: Start following location
		
		onPageHide: ->
			# TODO: Stop following location
	
	instance = null
	
	Location.instance = -> if instance? then instance else new Location(el: $('pg-location'))
	
	exports.Location = Location
	
	return
)