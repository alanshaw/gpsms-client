# Setup requirejs
requirejs.config
	paths:
		lib: '../lib'

# Listen for and log ALL errors
window.onerror = (msg, url, ln) ->
	console.log "[ERROR] #{JSON.stringify(msg: msg, url: url, ln: ln)}"

onDeviceReady = -> 
	
	console.log 'deviceready'
	
	require ['app'], (app) -> app.init()

document.addEventListener('deviceready', onDeviceReady, false)

#require ['app'], (app) -> app.init()