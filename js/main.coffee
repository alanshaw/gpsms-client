onDeviceReady = -> 
	
	console.log 'deviceready'
	
	require(['app'], (app) ->
		app.init()
	)

document.addEventListener('deviceready', onDeviceReady, false)