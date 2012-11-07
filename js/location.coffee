define ['app', 'exports'], (app, exports) ->
	
	LocationView = Backbone.View.extend
		
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
	
	LocationView.instance = -> if instance? then instance else new LocationView(el: $('pg-location'))
	
	exports.LocationView = LocationView
	
	return