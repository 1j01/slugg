
# 2D world
# bridge-like roadways
# vehicles going along the roadways
# you can jump on the vehicles
# you can jump on the roadways, but can be run over by vehicles
# other players may exist and be controlled by neural networks or input-choice world prediction ("Control Choice Simulation"? "Choice Simulation Control"?)
# you go up

class World
	constructor: ->
		@objects = []
		@gravity = 0.7
	
	generate: ->
		@objects = []
		# TODO: improve layout algorithm
		y = 0
		last_was_pathway = yes
		while y > -1800
			y -= 32 * ~~(random()*4 + 3)
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
		return if (@x > view.cx + view.width/2) or (@y > view.cy + view.height/2) or (@x + @w < view.cx - view.width/2) or (@y + @h < view.cy - view.height/2)
		ctx.fillStyle = "#000"
		ctx.fillRect @x, @y, @w, @h

class Platform extends Entity


class Roadway extends Platform
	
	pattern_canvas = document.createElement("canvas")
	pattern_ctx = pattern_canvas.getContext("2d")
	pattern_canvas.width = 10
	pattern_canvas.height = 16
	#pattern_ctx.fillStyle = "#000"
	#pattern_ctx.fillRect(0, 0, 1, 160)
	pattern_ctx.strokeStyle = "#000"
	pattern_ctx.moveTo(0, 0)
	pattern_ctx.lineTo(pattern_canvas.width, pattern_canvas.height)
	#pattern_ctx.moveTo(pattern_canvas.width, 0)
	#pattern_ctx.lineTo(pattern_canvas.width, pattern_canvas.height)
	pattern_ctx.moveTo(pattern_canvas.width, 0)
	pattern_ctx.lineTo(0, pattern_canvas.height)
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
		@previous_footing = null
		super
	
	friction: 0.1
	air_resistance: 0.001
	step: (world)->
		@vy += world.gravity
		#@vx = min(@max_vx, max(-@max_vx, @vx))
		@vy = min(@max_vy, max(-@max_vy, @vy))
		if @is_grounded(world)
			@vx /= 1 + @friction
			footing = @collision(world, @x, @y + 1)
			#if footing.vx?
				#@vx += footing.vx
			@vx = min(@max_vx, max(-@max_vx, @vx))
		else
			@vx /= 1 + @air_resistance
		resolution = 5
		
		if footing isnt @previous_footing
			if footing?.vx
				@vx *= 0.3
			else if @previous_footing?.vx
				@vx += @previous_footing.vx
		
		if footing?.vx
			#@vx *= 0.99
			if footing.vx > 0
				if @x > footing.x + footing.w
					#@vx *= 0.8
					@vx -= 1
			else
				if @x < footing.x
					#@vx *= 0.8
					@vx += 1
		
		xtg = @vx
		if footing?.vx?
			xtg += footing.vx
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
		
		@previous_footing = footing
	
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
	
	is_grounded: (world)->
		not not @collision(world, @x, @y + 1)
	
	find_free_position: (world)->
		while @collision(world, @x, @y)
			@x += 16 * ~~(random() * 2 + 1) * (if random() < 0.5 then +1 else -1)

class Vehicle extends MobileEntity
	constructor: ->
		@heading ?= 0
		@w ?= 60 + 20 * ~~(random() * 2 + 1)
		@h ?= 50
		super
		@y -= @h
	
	friction: 0.06
	step: (world)->
		@vx += @heading
		#super
		@vx /= 1 + @friction
		
		# TODO: let the character pass if they already would have gotten hit but were invincible
		object = @collision(world, @x + @vx, @y)
		if object instanceof Character
			unless object.invincibility > 0
				if object.collision(world, object.x - @vx, object.y - 16, type: Vehicle) is @
					object.vx += @vx
					object.vy = -2
					object.invincibility = 50
					object.step?(world)
					density = 2
					@vx *= (object.w * object.h) / (@w * @h) * density
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

class Character extends MobileEntity
	constructor: ->
		@jump_velocity ?= 13
		@air_control ?= 0.2
		@invincibility = 0
		@health = 100
		super
		@y -= @h
		@squish = 0
	
	step: (world)->
		@invincibility -= 1
		@controller.update()
		@descend = @controller.descend
		grounded = @is_grounded(world)
		if grounded
			@vx += @controller.x
			
			if @controller.jump
				# consider maxing vx
				#footing = @collision(world, @x, @y + 1)
				@vy = -@jump_velocity
				#if footing?.vx?
					#@vx += footing.vx
				# let's try handling this with previous_footing in MobileEntity
			
			
			# whoops, this isn't supposed to be when jumping
			#@vx = min(abs(@vx), abs(footing.vx)) * sign(@vx)
			#@vx = min(abs(@vx), abs(footing.vx)) * sign(footing.vx)
			#if footing.vx > 0
				#@vx = min(@vx, footing.vx)
			#else
				#@vx = max(@vx, footing.vx)
			
		else if @controller.jump
			if @collision(world, @x + 1, @y) # and collision shifted in y?
				@vx = -@jump_velocity / 4
				#@vy -= @jump_velocity / 2 if @vy < 2
				#@vy = max(-@jump_velocity, @vy * 1.5) if @vy < 0
				@vy = -@jump_velocity if @vy < 2
			else if @collision(world, @x - 1, @y) # and collision shifted in y?
				@vx = @jump_velocity / 4
				#@vy -= @jump_velocity / 2 if @vy < 2 # TODO: more dynamic, less conditional
				#@vy *= 1.5 if @vy < 0
				#@vy = max(-@jump_velocity, @vy * 1.5) if @vy < 0
				@vy = -@jump_velocity if @vy < 2
		else
			@vx += @controller.x * @air_control
		
		@squish += (grounded - @squish) / 4
		
		super

#class NonPlayerCharacter extends Character
	#constructor: ->
		#super
		# TODO
		#@controller = new NeuralNetworkTrainedNonPlayerCharacterMobileEntityControlOperatorBrainObjectInstance.Thing...Idea

class KeyboardController
	constructor: ->
		@prev_keys = {}
		@keys = {}
		window.addEventListener "keydown", (e)=>
			@keys[e.keyCode] = yes
		window.addEventListener "keyup", (e)=>
			delete @keys[e.keyCode]
	
	update: ->
		pressed = (keyCode)=>
			@keys[keyCode]?
		just_pressed = (keyCode)=>
			@keys[keyCode]? and not @prev_keys[keyCode]?
		
		@x = pressed(39) - pressed(37) # right minus left
		@jump = just_pressed(32) or just_pressed(38) # space or up
		@descend = just_pressed(40) # down
		# consider having a sort of "queue" of "descensions" (that timeout eventually) so you can double-tap down to go down twice
		
		delete @prev_keys[k] for k, v of @prev_keys
		@prev_keys[k] = v for k, v of @keys

class Player extends Character
	constructor: ->
		@w ?= 16*1.7
		@h ?= 16*3
		super
		@controller = new KeyboardController
	
	draw: (ctx)->
		ctx.save()
		ctx.translate(@x + @w/2, @y + @h/2)
		r = @w / 2
		c = r * 4 * (sqrt(2)-1) / 3
		ctx.beginPath()
		ctx.scale(1, @h/@w)
		ctx.rotate(-TAU/4)
		ctx.moveTo(+0, +r)
		s = (@squish)/4 * r
		#ctx.bezierCurveTo(+c,+r,  +r,+c,  +r,+0)
		#ctx.bezierCurveTo(+r,-c,  +c,-r,  +0,-r)
		#ctx.bezierCurveTo(-c-s,-r,  -r-s,-c,  -r-s,+0)
		#ctx.bezierCurveTo(-r-s,+c,  -c-s,+r,  +0-s,+r)
		ctx.bezierCurveTo(+c,+r,  +r,+c,  +r,+0)
		ctx.bezierCurveTo(+r,-c,  +c,-r,  +0,-r)
		ctx.bezierCurveTo(-c-s,-r-s,  -r-s,-c-s,  -r-s,+0)
		ctx.bezierCurveTo(-r-s,+c+s,  -c-s,+r+s,  +0-s,+r)
		#ctx.bezierCurveTo(+c,+r,  +r,+c,  +r,+0)
		#ctx.bezierCurveTo(+r,-c,  +c,-r,  +0,-r)
		#ctx.bezierCurveTo(-c-s,-r,  -r-s,-c,  -r-s,+0)
		#ctx.bezierCurveTo(-r-s,+c,  -c-s,+r,  +0-s,+r)
		
		ctx.restore()
		ctx.fillStyle = "#000"
		ctx.fill()



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

animate ->
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
	view.cx += (move_view_to_cx - view.cx) / 5
	view.cy += (move_view_to_cy - view.cy) / 5
	#ctx.clearRect(0, 0, canvas.width, canvas.height)
	ctx.fillStyle = gloom # "#233"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.fillStyle = sunset
	#ctx.globalAlpha = (sin(Date.now() / 5000) + 1) / 2
	#ctx.globalAlpha = (-player.y / (200*16))
	ctx.globalAlpha = min(1, max(0, -view.cy / (500*16)))
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.fillStyle = "#000"
	ctx.globalAlpha = min(1, max(0, view.cy / (100*16)))
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.globalAlpha = 1
	ctx.save()
	#ctx.translate(view.cx - canvas.width/2, view.cy - canvas.height/2)
	ctx.translate(canvas.width/2 - view.cx, canvas.height/2 - view.cy)
	world.draw(ctx, view)
	ctx.restore()
	ctx.save()
	#ctx.globalCompositeOperation = "darken"
	ctx.fillStyle = "rgba(255, 0, 0, #{player.invincibility/150})"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.restore()
	
	if player.y > 100 * 16
		#player.y = world.objects[0].y - player.h
		#player.find_free_position(world)
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
	#console.log e.keyCode
	if e.keyCode is 80 # P
		toggle_pause()
