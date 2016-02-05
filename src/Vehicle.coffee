
class @Vehicle extends MobileEntity
	
	empty_car_image = load_image "trains/car-empty"
	train_car_images = [
		load_image "trains/car-a"
		load_image "trains/car-b"
		load_image "trains/car-c"
		load_silhouette "trains/box"
	]
	
	constructor: ->
		@heading ?= 1
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
	
	find_free_position: (world)->
		while @collision(world, @x, @y)
			@x -= 40 * @heading
	
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
		
