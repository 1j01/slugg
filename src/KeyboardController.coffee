
class @KeyboardController
	constructor: ->
		@prev_keys = {}
		@keys = {}
		window.addEventListener "keydown", (e)=>
			@keys[e.keyCode] = yes
		window.addEventListener "keyup", (e)=>
			delete @keys[e.keyCode]
	
	update: ->
		# arrow keys, WASD, IJKL
		key_codes =
			right: [39, 68, 76] # right, D, L
			left: [37, 65, 74] # left, A, J
			jump: [38, 87, 73, 32] # up, W, I, space
			descend: [40, 83, 75] # down, S, K
			genuflect: [16, 17, 90] # ctrl, shift, Z
		
		pressed = (key)=>
			for keyCode in key_codes[key]
				return yes if @keys[keyCode]?
			return no
		just_pressed = (key)=>
			for keyCode in key_codes[key]
				return yes if @keys[keyCode]? and not @prev_keys[keyCode]?
			return no
		
		@x = pressed("right") - pressed("left")
		@start_jump = just_pressed("jump")
		@extend_jump = pressed("jump")
		@descend = pressed("descend")
		@genuflect = pressed("genuflect")
		
		delete @prev_keys[k] for k, v of @prev_keys
		@prev_keys[k] = v for k, v of @keys
