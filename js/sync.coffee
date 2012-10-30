require(['exports'], (exports) ->
	
	logArgs = -> console.log(arguments)
	
	defaultSyncOptions = success: logArgs, error: logArgs
	
	localSync = (method, model, options) ->
		
		options = _.extend(defaultSyncOptions, options)
		
		repository = model.repository
		
		switch method
			when 'create' then repository.create(model, options)
			when 'read' then repository.read(model, options)
			when 'update' then repository.update(model, options)
			when 'delete' then repository.delete(model, options)
	
	exports.localSync = localSync
	
	return
)