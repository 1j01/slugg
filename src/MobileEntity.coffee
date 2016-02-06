
class @MobileEntity extends Entity
	constructor: ->
		@vx ?= 0
		@vy ?= 0
		@max_vx = 15
		@max_vy = 20
		@footing = null
		@previous_footing = null
		@grounded = no
		super
		@level_y ?= @y
	
	friction: 0.3
	running_friction: 0.1
	sliding_friction: 0.025
	air_resistance: 0.001
	step: (world)->
		@vy += world.gravity
		@vy = min(@max_vy, max(-@max_vy, @vy))
		
		for object in world.objects when object instanceof Platform
			if @y + @h < object.y - object.fence_height
				if @level_y > object.y
					@level_y = object.y
		
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
	
	collision: (world, x, y, {type, detecting_footing}={})->
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
					if object.y < @level_y
						continue
					else if @descend > 0 and not @descended_wall and not detecting_footing
						@descended = yes
						@level_y = object.y + 1 if @level_y <= object.y
						continue
				if @ instanceof Character and object instanceof Vehicle
					# if you're invincible, treat cars as one way platforms
					if @invincibility > 0 and object.y < @y + @h
						continue
					if object.level_y < @level_y
					# if object.y < @level_y
						continue
				if @ instanceof Vehicle and object instanceof Building
					continue
				return object
		return no
	
	find_free_position: (world)->
		while @collision(world, @x, @y)
			@x += 16 * ~~(random() * 2 + 1) * (if random() < 0.5 then +1 else -1)
