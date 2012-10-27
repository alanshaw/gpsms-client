define(['app', 'exports'], (app, exports) ->
	
	Message = Backbone.Model.extend
		initialize: ->
	
	exports.Message = Message
	
	Messages = Backbone.Collection.extend
		model: Message
	
	exports.Messages = Messages
)