define(['app', 'exports'], (app, exports) ->
	
	MessageModel = Backbone.Model.extend
		initialize: ->
	
	exports.MessageModel = MessageModel
	
	MessageCollection = Backbone.Collection.extend
		model: MessageModel
	
	exports.MessageCollection = MessageCollection
)