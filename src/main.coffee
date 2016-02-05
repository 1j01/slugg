
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
