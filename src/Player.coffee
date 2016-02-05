
class @Player extends Character
	constructor: ->
		@w ?= 16*1.7
		@h ?= 16*2
		super
		@controller = new KeyboardController
