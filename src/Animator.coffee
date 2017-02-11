
class @Animator
	lerp = (a, b, b_ness)-> a + (b - a) * b_ness
	
	lerp_frames: (frame_a, frame_b, b_ness, srcID)->
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
	
	lerp_animation_frames: (frames, position, srcID)->
		frame_a = frames[(~~(position) + 0) %% frames.length]
		frame_b = frames[(~~(position) + 1) %% frames.length]
		frame_b_ness = position %% 1
		frame = @lerp_frames(frame_a, frame_b, frame_b_ness, srcID)
		frame
	
	flip_frame: (frame, srcID)->
		dots = {}
		for color, dot of frame.dots
			x = frame.width - dot.x
			y = dot.y
			dots[color] = {x, y, color}
		{width, height} = frame
		{dots, width, height, srcID}
	
	constructor: ({@segments})->
		@weights = {}
		@weights_to = {}
	
	weight: (weighty_frame, weight=1)->
		@weights_to[weighty_frame.srcID] = weight
	
	calc: (root_frames, facing=1)->
		for frame in root_frames
			@weights_to[frame.srcID] ?= 0
			@weights[frame.srcID] ?= 0
			@weights[frame.srcID] += (@weights_to[frame.srcID] - @weights[frame.srcID]) / 5
		
		calc_frame = root_frames[0]
		
		cumulative_weight = 0
		for frame in root_frames
			frame_weight = @weights[frame.srcID]
			cumulative_weight += frame_weight
			if cumulative_weight is 0
				calc_frame = frame # avoid divide by 0
			else
				calc_frame = @lerp_frames(calc_frame, frame, frame_weight/cumulative_weight)
		
		calc_frame = @lerp_frames(calc_frame, @flip_frame(calc_frame), (1-facing)/2)
		
		for frame in root_frames
			@weights_to[frame.srcID] = 0
		
		calc_frame
	
	draw: (ctx, draw_height, root_frames, face=1, facing=1)->
		calc_frame = @calc root_frames, facing
		ctx.save()
		ctx.scale(draw_height / calc_frame.height, draw_height / calc_frame.height)
		for segment in @segments
			for color, dot of segment.image.dots
				pivot = dot
				break
			placement = calc_frame.dots[segment.a]
			towards = calc_frame.dots[segment.b]
			ctx.save()
			ctx.translate(placement.x - calc_frame.width/2, placement.y - calc_frame.height)
			ctx.rotate(atan2(towards.y - placement.y, towards.x - placement.x) - TAU/4)
			ctx.scale(face, 1)
			ctx.translate(-pivot.x+segment.image.width/2, -pivot.y)
			ctx.drawImage(segment.image, -segment.image.width/2, 0)
			ctx.restore()
		ctx.restore()
