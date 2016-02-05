
class @NPC extends Character
	constructor: ->
		super
		# TODO
		@controller = new NPCBrain(iq: 50)
