define ['util', 'exports'], (util, exports) ->
	
	class LocationView extends Backbone.View
		
		@id: 'pg-location'
		
		@instance: (=> 
			instance = null
			=>
				instance = new @(el: '#' + @id) if not instance
				instance
		)()
		
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
	
	util.instantiateViewBeforePageChange(LocationView)
	
	exports.LocationView = LocationView
	
	return