
class @Building extends Entity
	constructor: ->
		@w = 16 * ~~(random() * 20 + 5)
		@h = 16 * ~~(random() * 10 + 5)
		super
		@y -= @h
	draw: (ctx, view)->
		return if (@x > view.cx + view.width/2) or (@y > view.cy + view.height/2) or (@x + @w < view.cx - view.width/2) or (@y + @h < view.cy - view.height/2)
		ctx.fillStyle = "rgba(0, 0, 0, 1)"
		ctx.fillRect @x, @y, @w, @h
