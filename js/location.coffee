define(['app', 'exports'], (app, exports) ->
	
	Location = Backbone.View.extend
		
		initialize: -> 
			# TODO: Load google maps, pinpint location
			map = @$('.map')
		
		show: (message) ->
			
	
	instance = null
	
	Location.instance = -> if instance? then instance else new Location(el: $('pg-location'))
	
	exports.Location = Location
	
	return
)