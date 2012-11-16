define ['exports'], (exports) ->
	
	###
	# Registers a one time event listener that calls the "instance" function of the the passed view object (if it exists)
	# immediately before the page is changed to the page with ID equal to the "id" property of the view object.
	#
	# This allows us to lazy load singleton Backbone.View's automatically and allows them to take control of the page
	# (register events etc.) before it is shown to the user.
	#
	# @param {Object} view
	# @param {String} view.id ID of the DOM element the view controls
	# @param {Function} view.instance The function that creates a singleton instance of the view
	###
	exports.instantiateViewBeforePageChange = (view) ->
		
		onPageBeforeChange = (event, data) -> 
			
			if data.toPage.indexOf? and data.toPage.indexOf('#' + view.id) isnt -1
				
				view.instance?()
				
				$(document).unbind 'pagebeforechange', onPageBeforeChange
		
		$(document).bind 'pagebeforechange', onPageBeforeChange
		
		view
	
	return