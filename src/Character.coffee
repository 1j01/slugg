
class @Character extends MobileEntity
	
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
		{name: "front-upper-arm", a: "rgb(28, 13, 251)", b: "rgb(228, 53, 252)"}
		{name: "front-forearm", a: "rgb(228, 53, 252)", b: "rgb(60, 255, 175)"}
		{name: "front-hand", a: "rgb(60, 255, 175)", b: "rgb(79, 210, 157)"}
		{name: "back-upper-arm", a: "rgb(44, 77, 92)", b: "rgb(93, 43, 91)"}
		{name: "back-forearm", a: "rgb(93, 43, 91)", b: "rgb(44, 152, 40)"}
		{name: "back-hand", a: "rgb(44, 152, 40)", b: "rgb(79, 149, 75)"}
		{name: "front-upper-leg", a: "rgb(226, 0, 19)", b: "rgb(253, 107, 29)"}
		{name: "front-lower-leg", a: "rgb(253, 107, 29)", b: "rgb(224, 239, 105)"}
		{name: "front-foot", a: "rgb(228, 255, 51)", b: "rgb(224, 239, 105)"}
		{name: "back-upper-leg", a: "rgb(226, 0, 19)", b: "rgb(151, 70, 35)"}
		{name: "back-lower-leg", a: "rgb(151, 70, 35)", b: "rgb(126, 119, 24)"}
		{name: "back-foot", a: "rgb(170, 161, 30)", b: "rgb(126, 119, 24)"}
	]
	for segment in segments
		segment.image = load_silhouette "segments/#{segment.name}"
	
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
		@descend_pressed_last = no
		@descend = 0
		@descended = no
		@descended_wall = no
		@animator = new Animator {segments}
	
	step: (world)->
		@invincibility -= 1
		@controller.update()
		if @controller.descend
			if (not @descend_pressed_last) or @descend > 0
				@descend = 15
		else if @descended_wall
			@descend = 0
			@descended_wall = no
		if @descended
			@descend = 0
			@descended = no
		@descend -= 1
		@descend_pressed_last = @controller.descend
		
		@footing = @collision(world, @x, @y + 1, detecting_footing: yes)
		@grounded = not not @footing
		@against_wall_left = @collision(world, @x - 1, @y) and @collision(world, @x - 1, @y - @h + 5)
		@against_wall_right = @collision(world, @x + 1, @y) and @collision(world, @x + 1, @y - @h + 5)
		@against_wall = @against_wall_left or @against_wall_right
		
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
			@face = sign(@vx) unless sign(@vx) is 0
		else
			# air control
			@vx += @controller.x * @air_control
			if @controller.extend_jump
				@vy -= @jump_velocity_air_control
			if @against_wall
				if @descend > 0
					@descended_wall = yes
				else
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
				@sliding = no
		
		super
	
	draw: (ctx, view)->
		@face = +1 if @controller.x > 0
		@face = -1 if @controller.x < 0
		@facing += (@face - @facing) / 6
		
		unless window.animation_data?
			data = {}
			for image in images
				data[image.srcID] = {width: image.width, height: image.height, dots: image.dots}
			window.animation_data = data
			console.log "animation_data = #{JSON.stringify window.animation_data, null, "\t"};\n"
		
		run_frame = @animator.lerp_animation_frames(run_frames, @run_animation_time, "run")
		# liveliness_frame = @animator.lerp_animation_frames(run_frames, @liveliness_animation_time, "liveliness")
		# @liveliness_animation_time += 1/20
		
		fall_frame = @animator.lerp_frames(fall_downwards_frame, fall_forwards_frame, min(1, max(0, abs(@vx)/12)), "fall")
		air_frame = @animator.lerp_frames(jump_frame, fall_frame, min(1, max(0, 1-(6-@vy)/12)), "air")
		
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
				if @against_wall
					wall_slide_frame
				else
					air_frame
		
		@animator.weight weighty_frame, 1
		# @animator.weight liveliness_frame, 0.1 unless weighty_frame is run_frame
		# @animator.weight liveliness_frame, 0.3 if weighty_frame in [jump_frame, fall_forwards_frame, fall_downwards_frame]
		
		ctx.save()
		ctx.translate(@x + @w/2, @y + @h + 2)
		root_frames = [stand_frame, stand_wide_frame, crouch_frame, slide_frame, wall_slide_frame, air_frame, run_frame]
		draw_height = @normal_h * 1.6
		@animator.draw ctx, draw_height, root_frames, @face, @facing
		ctx.restore()
		
		if window.debug_levels
			ctx.save()
			ctx.font = "16px sans-serif"
			ctx.fillStyle = "#f0f"
			ctx.fillText @level_y, @x, @y
			ctx.restore()
