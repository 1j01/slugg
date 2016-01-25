
images_to_load = 0
images_loaded = 0
loading = no

load_image = (srcID)->
	images_to_load += 1
	image = new Image
	image.srcID = srcID
	image.addEventListener "load", (e)->
		images_loaded += 1
		if images_loaded is images_to_load
			loading = no
		find_dots(image)
	image.addEventListener "error", (e)->
		console.error "Failed to load image: #{srcID}"
	image.src = "images/#{srcID}.png"
	loading = yes
	image

load_silhouette = (srcID)->
	image = load_image(srcID)
	image_canvas = document.createElement("canvas")
	image_ctx = image_canvas.getContext("2d")
	image_canvas.srcID = srcID
	image.addEventListener "load", (e)->
		image_canvas.width = image.width
		image_canvas.height = image.height
		image_ctx.drawImage(image, 0, 0)
		image_ctx.globalCompositeOperation = "source-atop"
		image_ctx.fillRect(0, 0, image.width, image.height)
		image_canvas.dots = image.dots
	image_canvas

load_frame = (srcID)->
	if animation_data?
		animation_data[srcID].srcID = srcID
		animation_data[srcID]
	else
		load_image(srcID)

find_dots = (image)->
	image_canvas = document.createElement("canvas")
	image_ctx = image_canvas.getContext("2d")
	image_canvas.width = image.width
	image_canvas.height = image.height
	image_ctx.drawImage(image, 0, 0)
	image_data = image_ctx.getImageData(0, 0, image_canvas.width, image_canvas.height)
	
	pixel_locations = {}
	for y in [0...image_canvas.height]
		for x in [0...image_canvas.width]
			idx = (y * image_canvas.width + x) * 4
			if (image_data.data[idx+0] isnt 0) or (image_data.data[idx+1] isnt 0) or (image_data.data[idx+2] isnt 0)
				color = "rgb(#{image_data.data[idx+0]}, #{image_data.data[idx+1]}, #{image_data.data[idx+2]})"
				pixel_locations[color] ?= []
				pixel_locations[color].push {x, y}
	
	dots = {}
	for color, points of pixel_locations
		x = 0
		y = 0
		for point in points
			x += point.x
			y += point.y
		x /= points.length
		y /= points.length
		dots[color] = {x, y, color}
		# console.log "%c#{color}", "color: #{color}; background: black"
	
	image.dots = dots


class World
	constructor: ->
		@objects = []
		@gravity = 0.8
		window.addEventListener "hashchange", (e)=>
			@generate()
	
	generate: ->
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
		for [0..random()*10+1]
			@objects.push(new Building({x: 16 * ~~(random()*800-400), y}))
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
		
		@objects.push(@player = new Player({x: 50, y: @objects[0].y}))
		@player.find_free_position(@)
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)

class Entity
	constructor: (props)->
		@x ?= 0
		@y ?= 0
		@w ?= 32
		@h ?= 32
		if props? then @[k] = v for k, v of props
	
	draw: (ctx, view)->
		# TODO: return unless view.inside(x, y, w, h)
		return if (@x > view.cx + view.width/2) or (@y > view.cy + view.height/2) or (@x + @w < view.cx - view.width/2) or (@y + @h < view.cy - view.height/2)
		ctx.fillStyle = "#000"
		ctx.fillRect @x, @y, @w, @h

class Platform extends Entity

	pattern_canvas = document.createElement("canvas")
	pattern_ctx = pattern_canvas.getContext("2d")
	pattern_canvas.width = 10
	pattern_canvas.height = 16
	pattern_ctx.strokeStyle = "#000"
	# TODO: more interesting patterns
	fe = 0
	pattern_ctx.moveTo(fe, 0)
	pattern_ctx.lineTo(pattern_canvas.width-fe, pattern_canvas.height)
	pattern_ctx.moveTo(pattern_canvas.width-fe, 0)
	pattern_ctx.lineTo(fe, pattern_canvas.height)
	# pattern_ctx.moveTo(pattern_canvas.width/2, 0)
	# pattern_ctx.lineTo(pattern_canvas.width/2, pattern_canvas.height)
	pattern_ctx.stroke()
	pattern = ctx.createPattern(pattern_canvas, "repeat")
	
	constructor: ->
		@x ?= 16 * -400
		@w ?= 16 * 800
		@h ?= 16
		super
	
	draw: (ctx)->
		ctx.fillStyle = "#000"
		ctx.fillRect @x, @y, @w, @h
		ctx.fillRect @x, @y-@h, @w, 2
		ctx.fillStyle = pattern
		ctx.fillRect @x, @y-@h, @w, @h

class Roadway extends Platform
	constructor: ->
		@h ?= 16
		super

class Pathway extends Roadway
	constructor: ->
		@h ?= 4
		super

class Building extends Entity
	constructor: ->
		@w = 16 * ~~(random() * 20 + 5)
		@h = 16 * ~~(random() * 10 + 5)
		super
		@y -= @h
	draw: (ctx, view)->
		return if (@x > view.cx + view.width/2) or (@y > view.cy + view.height/2) or (@x + @w < view.cx - view.width/2) or (@y + @h < view.cy - view.height/2)
		ctx.fillStyle = "rgba(0, 0, 0, 1)"
		ctx.fillRect @x, @y, @w, @h

class MobileEntity extends Entity
	constructor: ->
		@vx ?= 0
		@vy ?= 0
		@max_vx = 15
		@max_vy = 20
		@footing = null
		@previous_footing = null
		@grounded = no
		super
	
	friction: 0.3
	running_friction: 0.1
	sliding_friction: 0.025
	air_resistance: 0.001
	step: (world)->
		@vy += world.gravity
		@vy = min(@max_vy, max(-@max_vy, @vy))
		
		@footing = @collision(world, @x, @y + 1)
		@grounded = not not @footing
		
		friction =
			if @grounded
				if @sliding
					@sliding_friction
				else if abs(@controller.x) > 0
					@running_friction
				else
					@friction
			else
				@air_resistance
		
		@vx /= 1 + friction
		
		if @grounded
			@vx = min(@max_vx, max(-@max_vx, @vx))
		
		resolution = 20 # higher is better; if too low, you'll slowly slide backwards when on vehicles due to the remainder
		
		if @footing isnt @previous_footing
			if @previous_footing?.vx
				@vx += @previous_footing.vx
			if @footing?.vx
				@vx -= @footing.vx
		
		# push you back if you're off the front of a vehicle
		# TODO: FIXME: doesn't work very well
		# TODO: move away from both edges of moving and static footing
		# (an exception might need to be added if there are gaps you can walk over)
		if @footing?.vx
			if @footing.vx > 0
				if @x > @footing.x + @footing.w
					@vx -= 1
			else
				if @x < @footing.x
					@vx += 1
		
		xtg = @vx
		if @footing?.vx?
			xtg += @footing.vx
		xtg_per_step = sign(xtg) / resolution
		while abs(xtg) > 1/resolution
			xtg -= xtg_per_step
			if @collision world, @x + xtg_per_step, @y
				@vx *= 0.7
				break
			@x += xtg_per_step
		ytg = @vy
		ytg_per_step = sign(ytg) / resolution
		while abs(ytg) > 1/resolution
			ytg -= ytg_per_step
			if collision = @collision(world, @x, @y + ytg_per_step)
				@vy *= 0.4
				break
			@y += ytg_per_step
		
		@previous_footing = @footing
	
	collision: (world, x, y, {type}={})->
		if @ instanceof Character and not type?
			return yes if x < -400 * 16
			return yes if x + @w > +400 * 16
		for object in world.objects when object isnt @ and not (@ instanceof Character and object instanceof Character)
			if type? and not (object instanceof type)
				continue
			if (
				x < object.x + object.w and
				y < object.y + object.h and
				x + @w > object.x and
				y + @h > object.y
			)
				if object instanceof Platform
					if @descend
						continue
					if object.y < @y + @h
						continue
				if @ instanceof Character and object instanceof Vehicle
					# if you're invincible, treat cars as one way platforms
					if @invincibility > 0 and object.y < @y + @h
						continue
				if @ instanceof Vehicle and object instanceof Building
					continue
				return object
		return no
	
	find_free_position: (world)->
		while @collision(world, @x, @y)
			@x += 16 * ~~(random() * 2 + 1) * (if random() < 0.5 then +1 else -1)

class Vehicle extends MobileEntity
	
	empty_car_image = load_image "trains/car-empty"
	train_car_images = [
		load_image "trains/car-a"
		load_image "trains/car-b"
		load_image "trains/car-c"
		load_silhouette "trains/box"
	]
	
	constructor: ->
		@heading ?= 0
		@image = train_car_images[~~(random()*train_car_images.length)]
		@collsion_width_on_image = 1491
		@collsion_height_on_image = 627
		if @image.srcID.match /car-a/
			@collsion_width_on_image = 1491
			@collsion_height_on_image = 470
		@w ?= 261.5
		@h ?= 261.5 * @collsion_height_on_image/@collsion_width_on_image
		super
		@y -= @h
	
	friction: 0.06
	step: (world)->
		# (no super)
		@vx += @heading
		@vx /= 1 + @friction
		
		# TODO: let the character pass if they already would have gotten hit but were invincible
		# +FIXME: player can get stuck if the car slows down and stops ontop of player or if player goes inside a stopped car
		object = @collision(world, @x + @vx, @y)
		if object instanceof Character
			unless object.invincibility > 0
				if object.collision(world, object.x - @vx, object.y - 16, type: Vehicle) is @
					object.vx += @vx
					object.vy = -2
					object.invincibility = 50
					object.step?(world)
					density = 9
					@vx *= density * (object.w * object.h) / (@w * @h)
				else
					unless object.collision(world, object.x, @y - object.h)
						object.y = @y - object.h
						#object.vx = -@vx / 5
		else if object instanceof Vehicle
			@vx = min(abs(@vx), abs(object.vx)) * sign(@vx)
			@vx *= 0.8
		
		ahead = @collision(world, @x + @vx * 5, @y)
		if ahead instanceof Vehicle
			@vx *= 0.99
		
		@x += @vx
		
		if @heading < 0
			if @x < 16 * -400 - @w
				@x = 16 * +400 + random() * 500
				@find_free_position(world)
		else
			if @x > 16 * +400
				@x = 16 * -400 - @w - random() * 500
				@find_free_position(world)

	draw: (ctx, view)->
		# FIXME (@x/@y/@w/@h no longer represent the visual boundaries)
		return if (@x > view.cx + view.width/2) or (@y > view.cy + view.height/2) or (@x + @w < view.cx - view.width/2) or (@y + @h < view.cy - view.height/2)
		@facing = +1 if @vx > 0
		@facing = -1 if @vx < 0
		ctx.save()
		ctx.translate(@x + @w/2, @y + @h)
		ctx.scale(-@facing, 1)
		draw_height = @h * @image.height/@collsion_height_on_image
		draw_width = @w * @image.width/@collsion_width_on_image
		ctx.drawImage(@image, -draw_width/2, 5-draw_height, draw_width, draw_height)
		ctx.drawImage(empty_car_image, -draw_width/2, 35-draw_height, draw_width, draw_height)
		ctx.restore()
		

class Character extends MobileEntity
	
	run_frames =
		for n in [1..6]
			load_frame "run/#{n}"
	
	images = run_frames.concat [
		stand_frame = load_frame "stand"
		stand_wide_frame = load_frame "stand-wide"
		crouch_frame = load_frame "crouch"
		slide_frame = load_frame "floor-slide"
		jump_frame = load_frame "jump"
		wall_slide_frame = load_frame "wall-slide"
		fall_forwards_frame = load_frame "fall-forwards"
		fall_downwards_frame = load_frame "fall-downwards"
	]
	
	segments = [
		{name: "head", a: "rgb(174, 55, 58)", b: "rgb(253, 31, 43)"}
		{name: "torso", a: "rgb(253, 31, 43)", b: "rgb(226, 0, 19)"}
		{name: "front_upper_arm", a: "rgb(28, 13, 251)", b: "rgb(228, 53, 252)"}
		{name: "front_forearm", a: "rgb(228, 53, 252)", b: "rgb(60, 255, 175)"}
		{name: "front_hand", a: "rgb(60, 255, 175)", b: "rgb(79, 210, 157)"}
		{name: "back_upper_arm", a: "rgb(44, 77, 92)", b: "rgb(93, 43, 91)"}
		{name: "back_forearm", a: "rgb(93, 43, 91)", b: "rgb(44, 152, 40)"}
		{name: "back_hand", a: "rgb(44, 152, 40)", b: "rgb(79, 149, 75)"}
		{name: "front_upper_leg", a: "rgb(226, 0, 19)", b: "rgb(253, 107, 29)"}
		{name: "front_lower_leg", a: "rgb(253, 107, 29)", b: "rgb(224, 239, 105)"}
		{name: "front_foot", a: "rgb(228, 255, 51)", b: "rgb(224, 239, 105)"}
		{name: "back_upper_leg", a: "rgb(226, 0, 19)", b: "rgb(151, 70, 35)"}
		{name: "back_lower_leg", a: "rgb(151, 70, 35)", b: "rgb(126, 119, 24)"}
		{name: "back_foot", a: "rgb(170, 161, 30)", b: "rgb(126, 119, 24)"}
	]
	for segment in segments
		segment.image = load_silhouette "segments/#{segment.name.replace /_/g, "-"}"
	
	lerp = (a, b, b_ness)-> a + (b - a) * b_ness
	lerp_frames = (frame_a, frame_b, b_ness, srcID)->
		dots = {}
		for color, dot of frame_a.dots
			x = lerp(dot.x, frame_b.dots[color].x, b_ness)
			y = lerp(dot.y, frame_b.dots[color].y, b_ness)
			dots[color] = {x, y, color}
		{width, height} = frame_a
		{dots, width, height, srcID}
		# NOTE: interpolating frames *can* produce bad states where a limb
		# is shorter than it's supposed to be, potentially jutting out.
		# This can be remedied by stretching the limbs when drawing if need be.
	
	lerp_animation_frames = (frames, position, srcID)->
		frame_a = frames[(~~(position) + 0) %% frames.length]
		frame_b = frames[(~~(position) + 1) %% frames.length]
		frame_b_ness = position %% 1
		frame = lerp_frames(frame_a, frame_b, frame_b_ness, srcID)
		frame
	
	flip_frame = (frame, srcID)->
		dots = {}
		for color, dot of frame.dots
			x = frame.width - dot.x
			y = dot.y
			dots[color] = {x, y, color}
		{width, height} = frame
		{dots, width, height, srcID}
	
	constructor: ->
		@jump_velocity ?= 12
		@jump_velocity_air_control ?= 0.36
		@air_control ?= 0.1
		@health ?= 100
		super
		@normal_h = @h
		@crouched_h = @h / 2
		@crouched = no
		@sliding = no
		@y -= @h
		@invincibility = 0
		# @liveliness_animation_time = 0
		@run_animation_time = 0
		@face = 1
		@facing = 1
		@weights = {}
		@weights_to = {}
	
	step: (world)->
		@invincibility -= 1
		@controller.update()
		@descend = @controller.descend
		
		@footing = @collision(world, @x, @y + 1)
		@grounded = not not @footing
		@against_wall_left = @collision(world, @x - 1, @y) and @collision(world, @x - 1, @y - @h + 5)
		@against_wall_right = @collision(world, @x + 1, @y) and @collision(world, @x + 1, @y - @h + 5)
		
		if @grounded
			if @controller.start_jump
				# normal jumping
				@vy = -@jump_velocity
				@vx += @controller.x
			else if @controller.genuflect
				unless @crouched
					@h = @crouched_h
					@y += @normal_h - @crouched_h
					@crouched = yes
					@sliding = abs(@vx) > 5
			else
				# normal movement
				@vx += @controller.x
		else if @controller.start_jump
			# wall jumping
			if @against_wall_right
				@vx = @jump_velocity * -0.7 unless @controller.x > 0
				@vy = -@jump_velocity
			else if @against_wall_left
				@vx = @jump_velocity * +0.7 unless @controller.x < 0
				@vy = -@jump_velocity
			@face = sign(@vx)
		else
			# air control
			@vx += @controller.x * @air_control
			if @controller.extend_jump
				@vy -= @jump_velocity_air_control
			if @against_wall_right or @against_wall_left
				@vy *= 0.5 if @vy > 0
			if @against_wall_right
				@face = +1
			if @against_wall_left
				@face = -1
		
		if @crouched
			unless @controller.genuflect and @grounded and ((not @sliding) or (@sliding and abs(@vx) > 2))
				# TODO: check for collision before uncrouching
				@h = @normal_h
				@y -= @normal_h - @crouched_h
				@crouched = no
				@sliding = no # or else hilarity ensues
		
		super
	
	draw: (ctx, view)->
		@face = +1 if @controller.x > 0
		@face = -1 if @controller.x < 0
		@facing += (@face - @facing) / 6
		ctx.save()
		ctx.translate(@x + @w/2, @y + @h + 2)
		
		unless window.animation_data?
			data = {}
			for image in images
				data[image.srcID] = {width: image.width, height: image.height, dots: image.dots}
			window.animation_data = data
			console.log "animation_data = #{JSON.stringify window.animation_data, null, "\t"};\n"
		
		run_frame = lerp_animation_frames(run_frames, @run_animation_time, "run")
		# liveliness_frame = lerp_animation_frames(run_frames, @liveliness_animation_time, "liveliness")
		
		# @liveliness_animation_time += 1/20
		
		fall_frame = lerp_frames(fall_downwards_frame, fall_forwards_frame, min(1, max(0, abs(@vx)/12)), "fall")
		air_frame = lerp_frames(jump_frame, fall_frame, min(1, max(0, 1-(6-@vy)/12)), "air")
		
		weighty_frame =
			if @grounded
				if abs(@vx) < 2
					if @crouched
						crouch_frame
					else if @footing?.vx
						stand_wide_frame
					else
						stand_frame
				else
					if @sliding
						slide_frame
					else
						@run_animation_time += abs(@vx) / 60
						run_frame
			else
				@run_animation_time = 0
				if @against_wall_right or @against_wall_left
					wall_slide_frame
				else 
					air_frame
		
		frames = [stand_frame, stand_wide_frame, crouch_frame, slide_frame, wall_slide_frame, air_frame, run_frame]
		
		for frame in frames
			@weights[frame.srcID] ?= 0
			@weights_to[frame.srcID] = 0
		
		@weights_to[weighty_frame.srcID] = 1
		# @weights_to.liveliness = 0.1 unless weighty_frame is run_frame
		# @weights_to.liveliness = 0.3 if weighty_frame in [jump_frame, fall_forwards_frame, fall_downwards_frame]
		
		# runningness = min(1, abs(@vx / @max_vx))
		# # @weights_to.run *= runningness
		# # @weights_to.stand += (1 - min(1, abs(@vx / @max_vx))) * @weights_to.run
		# @weights_to.stand += @weights_to.run * (1 - runningness) * 0.4
		# @weights_to.run *= runningness
		
		for frame in frames
			@weights[frame.srcID] += (@weights_to[frame.srcID] - @weights[frame.srcID]) / 5
		
		calc_frame = stand_frame
		
		cumulative_weight = 0
		for frame in frames
			frame_weight = @weights[frame.srcID]
			cumulative_weight += frame_weight
			calc_frame = lerp_frames(calc_frame, frame, frame_weight/cumulative_weight)
		
		calc_frame = lerp_frames(calc_frame, flip_frame(calc_frame), (1-@facing)/2)
		
		draw_height = @normal_h * 1.6
		ctx.scale(draw_height / calc_frame.height, draw_height / calc_frame.height)
		for segment in segments
			for color, dot of segment.image.dots
				pivot = dot
				break
			placement = calc_frame.dots[segment.a]
			towards = calc_frame.dots[segment.b]
			ctx.save()
			ctx.translate(placement.x - calc_frame.width/2, placement.y - calc_frame.height)
			ctx.rotate(atan2(towards.y - placement.y, towards.x - placement.x) - TAU/4)
			ctx.scale(@face, 1)
			ctx.translate(-pivot.x+segment.image.width/2, -pivot.y)
			ctx.drawImage(segment.image, -segment.image.width/2, 0)
			ctx.restore()
		ctx.restore()
		

#class NonPlayerCharacter extends Character
	#constructor: ->
		#super
		# TODO
		#@controller = new NPCBrain(iq: 50)

class KeyboardController
	constructor: ->
		@prev_keys = {}
		@keys = {}
		window.addEventListener "keydown", (e)=>
			@keys[e.keyCode] = yes
		window.addEventListener "keyup", (e)=>
			delete @keys[e.keyCode]
	
	update: ->
		# arrow keys, WASD, IJKL
		key_codes =
			right: [39, 68, 76] # right, D, L
			left: [37, 65, 74] # left, A, J
			jump: [38, 87, 73, 32] # up, W, I, space
			descend: [40, 83, 75] # down, S, K
			genuflect: [16, 17, 90] # ctrl, shift, Z
		
		pressed = (key)=>
			for keyCode in key_codes[key]
				return yes if @keys[keyCode]?
			return no
		just_pressed = (key)=>
			for keyCode in key_codes[key]
				return yes if @keys[keyCode]? and not @prev_keys[keyCode]?
			return no
		
		@x = pressed("right") - pressed("left")
		@start_jump = just_pressed("jump")
		@extend_jump = pressed("jump")
		@descend = just_pressed("descend")
		@genuflect = pressed("genuflect")
		
		delete @prev_keys[k] for k, v of @prev_keys
		@prev_keys[k] = v for k, v of @keys

class Player extends Character
	constructor: ->
		@w ?= 16*1.7
		@h ?= 16*2
		super
		@controller = new KeyboardController


@world = new World()
world.generate()

view = {cx: world.player.x, cy: world.player.y}

sunset = ctx.createLinearGradient 0, 0, 0, canvas.height

sunset.addColorStop 0.000, 'rgb(0, 255, 242)'
sunset.addColorStop 0.442, 'rgb(107, 99, 255)'
sunset.addColorStop 0.836, 'rgb(255, 38, 38)'
#sunset.addColorStop 0.934, 'rgb(255, 135, 22)'
#sunset.addColorStop 1.000, 'rgb(255, 252, 0)'
sunset.addColorStop 1, 'rgb(255, 60, 30)'

gloom = ctx.createLinearGradient 0, 0, 0, canvas.height

#gloom.addColorStop 0.000, 'rgb(0, 155, 242)'
#gloom.addColorStop 0.442, 'rgb(107, 99, 255)'
#gloom.addColorStop 0, '#434'
gloom.addColorStop 0, '#133'
gloom.addColorStop 1, '#122'

paused = no

view_slowness = 8

animate ->
	return if loading
	world.step() unless paused
	{player} = world
	view.width = canvas.width
	view.height = canvas.height
	#view_bound_x = canvas.width / 3
	#view_bound_y = canvas.height / 3
	#move_view_to_x = (view.cx + player.x - max(min(player.x, view_bound_x), -view_bound_x))
	move_view_to_cx = player.x # (view.cx + max(min(player.x - view.cx, view_bound_x), -view_bound_x))
	move_view_to_cy = player.y
	move_view_to_cx = min(400*16 - view.width/2, max(-400*16 + view.width/2, move_view_to_cx))
	#move_view_to_cy = min(400*16, max(-400*16, move_view_to_cy))
	view.cx += (move_view_to_cx - view.cx) / view_slowness
	view.cy += (move_view_to_cy - view.cy) / view_slowness
	ctx.fillStyle = gloom # "#233"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.fillStyle = sunset
	ctx.globalAlpha = min(1, max(0, -view.cy / (500*16)))
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.fillStyle = "#000"
	ctx.globalAlpha = min(1, max(0, view.cy / (100*16)))
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.globalAlpha = 1
	ctx.save()
	ctx.translate(canvas.width/2 - view.cx, canvas.height/2 - view.cy)
	world.draw(ctx, view)
	ctx.restore()
	ctx.save()
	# ctx.globalCompositeOperation = "screen"
	ctx.fillStyle = "rgba(255, 0, 0, #{player.invincibility/150})"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.restore()
	
	if player.y > 100 * 16
		world.generate()

pause = ->
	paused = yes
	document.body.classList.add "paused"

unpause = ->
	paused = no
	document.body.classList.remove "paused"

toggle_pause = ->
	if paused then unpause() else pause()

window.addEventListener "keydown", (e)->
	console.log e.keyCode if e.altKey
	if e.keyCode is 80 # P
		toggle_pause()
