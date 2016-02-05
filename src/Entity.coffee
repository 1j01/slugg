
class @Entity
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
