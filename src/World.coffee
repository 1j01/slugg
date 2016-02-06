
class @World
	constructor: ->
		@objects = []
		@gravity = 0.8
		window.addEventListener "hashchange", (e)=>
			@generate()
	
	generate: ->
		window.debug_levels = location.hash.match /debug-levels/
		
		if location.hash.match /test/
			return @generate_test_map()
		
		@objects = []
		# TODO: improve layout algorithm
		y = 0
		last_was_pathway = yes
		while y > -1800
			y -= 32 * ~~(random()*(if last_was_pathway then 2 else 4) + 5)
			if random() < 0.2 and not last_was_pathway
				@objects.push(new Pathway({y}))
				last_was_pathway = yes
			else
				@objects.push(new Roadway({y}))
				last_was_pathway = no
				for [0..random()*10+1]
					@objects.push(new Building({x: 16 * ~~(random()*800-400), y}))
				direction = if random() < 0.5 then +1 else -1
				direction *= 0.7 + random()/3
				for [0..random()*10+10]
					vehicle = new Vehicle({x: 16 * ~~(random()*800-400), y: y, heading: direction})
					vehicle.find_free_position(@)
					@objects.push(vehicle)
		
		@objects.push(@player = new Player({x: 50, y: @objects[0].y}))
		@player.find_free_position(@)
	
	generate_test_map: ->
		@objects = []
		y = 0
		
		@objects.push(new Pathway({y}))
		
		y -= 32 * 5
		
		@objects.push(new Pathway({y}))
		for [0..random()*10+1]
			@objects.push(new Building({x: 16 * ~~(random()*800-400), y}))
		
		@objects.push(@player = new Player({x: 50, y}))
		@player.find_free_position(@)
		
		y -= 32 * 5
		
		@objects.push(new Roadway({y}))
		for [0..random()*10+1]
			@objects.push(new Building({x: 16 * ~~(random()*800-400), y}))
		direction = if random() < 0.5 then +1 else -1
		direction *= 0.7 + random()/3
		for [0..random()*10+10]
			vehicle = new Vehicle({x: 16 * ~~(random()*800-400), y: y, heading: direction})
			vehicle.find_free_position(@)
			@objects.push(vehicle)
		
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)
