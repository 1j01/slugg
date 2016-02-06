
class @Platform extends Entity

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
		@fence_height ?= 0
		super
	
	draw: (ctx, view)->
		ctx.fillStyle = "#000"
		ctx.fillRect @x, @y, @w, @h
		ctx.fillRect @x, @y - max(@fence_height, 4), @w, 2
		ctx.fillStyle = pattern
		ctx.fillRect @x, @y - max(@fence_height, 4), @w, @h
		
		if window.debug_levels
			ctx.save()
			ctx.font = "16px sans-serif"
			ctx.fillStyle = "#fff"
			ctx.fillText @y, view.cx, @y
			ctx.restore()
			# ctx.globalAlpha = 0.7
