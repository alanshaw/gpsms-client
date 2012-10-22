require(['inbox'], (inbox) ->
	
	$(document).one('deviceready', ->
		console.log 'deviceready'
	)
	
	new inbox.Inbox(el: $('#pg-inbox'))
)