
images_to_load = 0
images_loaded = 0

window.loading = no

@load_image = (srcID)->
	images_to_load += 1
	image = new Image
	image.srcID = srcID
	image.addEventListener "load", (e)->
		images_loaded += 1
		if images_loaded is images_to_load
			window.loading = no
		find_dots(image)
	image.addEventListener "error", (e)->
		console.error "Failed to load image: #{srcID}"
	image.src = "images/#{srcID}.png"
	window.loading = yes
	image

@load_silhouette = (srcID)->
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

@load_frame = (srcID)->
	if animation_data?
		animation_data[srcID].srcID = srcID
		animation_data[srcID]
	else
		load_image(srcID)

@find_dots = (image)->
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
