define((require, exports, module) ->
	
	Inbox = Backbone.View.extend
		
		initialize: ->
			
			@$el
			###
			.one('pageshow', => @render())
			.bind('pageshow', => @watchPosition())
			.bind('pagehide', => @onPageHide())
			###
		
	exports.Inbox = Inbox
	
	return
)