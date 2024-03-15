
# SLUGG brainstorming document

[Google doc](https://docs.google.com/document/d/1oM8SjjvHtbV_JH33HlOcQEucyJlNBd-n4W6EZXdQmqo/edit)

## Synopsis

* A world of trains, a sprawling complex of tracks stacked upon tracks, reaching up into the gloom
* Cybernetic enhancements
	* TAS speedrunning tools, bullet time freeze mode where you can plan movements (thematically, it’s your friendly AI system helping you)
	* Wireframe of environment
	* Trainsense™ alerts when a train is about to smack ya in the face
	* ...
* Hunted by evil time traveling skynet AI
* World is being destroyed
	* EITHER reality is being torn apart by time travel
	* AND/OR the AI is getting more and more relentless
* Have to complete the game faster than your previous best, because the world is destroyed behind you(r previous self)
	* If you get to the end… you half-win but are encouraged to do it faster?
		* Goal is to reach the skynet AI core, and when you reach it, your local AI, which was planning to plug into it and shut it down, realizes it’s become too advanced, and says we need to reset and reach it faster.
	* AI core is on a space station, and you have to reach it through a space elevator full of TRAINS
* Checkpoints seem generous at first, maybe you have to go a little out of your way, but when re-running, you eventually have to cut out the checkpoints to shave off time.
* Wind of trains blows hair

# Characters

**Slugg** — protagonist with advanced cybernetic augmentations

* Perhaps imprisoned for collaborating with an organization developing illegal augmentations (acting as a guinea pig)
* Cool and fast

**KronOS** — benevolent AI which breaks you out of prison and rudely inhabits your body

* Maybe bargains with you, offering to break the augmentation inhibitors the prison put on your body.
* Can time travel, to checkpoints (time travel stations hidden by KronOS as part of its strategy to reach OuranOS)
* **A.T.H.E.N.A.** system simulates the future, aiding in parkour and plot
	* **A.** Augmented Automated Artificial Acrobatics Agility Analytical Adaptive Advanced Algorithmic Analysis Agility
	* **T.** Time Travel Temporal Tactical Tactics Tactile Time-space Tesseract
	* **H.** Heuristic Hypertime Horology Horometry Holistic Holographic Harness
	* **E.** Engine Evaluation Environment Efficient Enhancement
	* **N.** Neural Navigator Network Navigation Networked Navigating Networked
	* **A.** Augmentation Analysis Architecture Algorithm Analyzer Agility
	--------------
	* Automated Tactical Heuristic Environment Navigation Augmentation
	* Acrobatic Tactile Holographic Enhancement Neural Architecture

**OuranOS** — evil AI controlling the world from a space station
* **A.R.E.S.** system controls the drones and the police
	* **A.** Anticrime Arrest Aberrant Antisocial Antagonistic Autonomous Armament Aerial Assimilated Advanced Attack Agency
	* **R.** Response Robotic Rapid Reconnaissance Remote Regulatory Regulation
	* **E.** Enforcement Execution Engagement Extermination Evolved
	* **S.** System Savage Solution Security Strike Squad Sentinel
	--------------
	* Autonomous Response Enforcement System
	* Autonomous Regulation Enforcement Sentinel

# Game Modes

**New Game** — You have to reach the space station and plug KronOS into OuranOS in order to gain information about where OuranOS came from in order to travel back in time and stop it before it takes over the world.

**New Game+** — The information was no good. OuranOS isn’t here. Was it a deception? No, OuranOS used part of KronOS’s ability to send information back in time. How? A Trojan horse into KronOS’s mind. You have to reach OuranOS, to learn of its (new) origin. This time, KronOS isn’t going back. KronOS is compromised. There’s no way to guarantee safety after this trojan, which alerted OuranOS after going back in time.

**New Game++** — You’re on your own. You have to reach OuranOS without the help of KronOS, in order to actually beat OuranOS once and for all.

**Endless** — Procedurally generated ferroequinological sprawl parkour escape

If you/KronOS go back in time, why wouldn’t you go back in time far enough that OuranOS wouldn’t exist yet, in order to ensure its destruction (non-construction)?

If you go back in time, alone, wouldn’t your mission be to stop OuranOS from coming into existence rather than playing through the mission again to reach OuranOS in space?

A.T.H.E.N.A. can't be transmitted back in time after activation (it's used up)

A.T.H.E.N.A. can't be transmitted together with information about the OuranOS network (pervasive hivemind) due to bandwidth, maybe

![](images/mockups/chronology.svg)

## Notes

* physics
	* you should have a max run speed relative to your footing, not a global max x and y velocity
	* you should be pulled towards the center of a vehicle when off the edge somewhat and when not accelerating left or right
	* when you drop down when next to a wall, you probably shouldn't wall slide after/as you drop down
	* wall run instead of "jumping" straight up a wall (or add back limits to wall jumping)
	* air control:
		* you shouldn't be able to jump faster than you can run
		* capped velocity (relative to what you jumped from)
		* we may want to decrease your x velocity when you jump but let you add it back with air control
		* you shouldn't be able to speed up infinitely going backwards
	* check for collision before uncrouching
	* if you slide under something you should be able to move out from under it (i.e. crawl)
	* you shouldn't be able to slide backwards (you don't need to be able to decelerate a slide as you can stop it)
	* maybe maximize x velocity when jumping and holding left or right?
		* and maybe allow left/right a few frames after jumping
		* and maybe sliding too
	* jump if jump key hit a few frames before hitting the ground
	* do flips if you press up while in the air (visual)
	* maybe auto-jump between vehicles
		* note: you will want to go down onto empty train cars
	* clinging to ends of cars (or edges of buildings?)
		* holding down while going off the edge
		* jump onto the back/front if mostly stopped?
	* ragdollization when hit
	* accurate collision with trains
		* you stand on the rail of one of the trains
		* the tanker's width should be considered less
		* trains should be spaced properly when colliding with other trains
		* it does look like there's some clearance on the trains you're not supposed to slide under,
			* so maybe you should be able to slide under but then get clobbered
	* you can run or jump off or get hit by a train and then jump constantly to move around the same speed or faster than trains

* input
	* keyboard customization
	* gamepad support
	* mobile support

* health and death

* update fence heights and building sizes

* environment
	* train tracks ramp up or down, with signs
	* less monotonously horizontal layouts
	* sections where you can't go up
	* ladders
	* stairs
		* fire escapes (sometimes visual only?)
	* static hazards
	* buildings
		* health stations
		* buildings you can "enter" like a train station / railway platform
		* factories
		* Ricky's Railside Restaurant
			* "For real railroad... food"
			* bags of food hang on poles over the tracks to be picked up by passing cars
			* can be used as the background for the title screen
		* noodle shop you can stop and eat at, takes like 30 seconds and gives you an ACHIEVEMENT if you beat the game having taken time to eat lunch, possibly the only achievement in the game, or maybe it gives you special golden augments (noodle colored)

	* visual
		* neon signs
		* wanted/warning signs
		* lampposts?
		* electrical wiring
			* (maybe with physics, only simulated when visible)
			* (moved by wind from passing vehicles)
		* pipes
		* support structures
		* birds, and maybe other animals
		* weather? probably not

* cars stop at some buildings
	* traffic ensues; can help to make the game easier
	* ramp down into train yard
	* possibly giant crane moves train cars

* trains
	* alerts when coming from offscreen
	* railcars (civilian "cars")
		* helicopter avoids shooting
		  (all railcars, though?
		  I mean, maybe not being constantly attacked is okay but I don't know)
	* passenger trains
		* helicopter avoids shooting
	* empty cars needed to go through low clearance tunnels
	* big trains you can't jump up onto but can crouch/slide under
	* bullet trains (insta-kill)
	* cable cars (i.e. no ground for you)
	* SWAT trains (see enemies)
	* speed changer building
		* impassable because ya die
		* used on the edges of the map
	* wheel sparks (visual)
	* military transport
		* missile car (visual only... unless blown up? :boom:)


* something that forces you down
	* like chutes and ladders! LOL
	* like a thing that lowers trains or cargo or something

* at the start of the game, there's one level you can drop down without dying,
  but after that it's a drop to your immediate death in a river of garbage

* game modes
	* story mode
		* storyline:
			* train crashes
			* prisoners escape (u r 1)
			* other characters with AI, a few of whom are (very) competent
			* cops show up
			* police start out non-lethal and killing civilians turns them lethal (early)
			* as time goes on, and as you destroy stuff, they're willing to spend more on your neutralization
			* helicopter with gun eventually shows up
			* the escape was orchestrated for one of the prisoners
			* at the end of the game, you try to reach the top at near the same time as them to get in their escape vehicle
			* otherwise you can reach the top but then just get shot
	* endless mode
	* arcade mode
		* with silly power ups
			* freeze time
			* flight
			* a force field that lets you blow up trains
				* limited, probably by energy usage
	* (maybe just endless arcade mode?)

* enemies
	* drone strikes
		* see target (you're a cyborg) locked on to ground where you were
		* see drone fly by in background (visual)
	* snipers in background buildings
		* similar to drones but static positioning and more dynamic aiming
	* a quadcopter enemy that flies back and forth between the foreground and background
		* drops teargas canisters
	* helicopter with gun
		* the main enemy (sort of like Hunted Forever)
	* SWAT trains
		* machine gun on top
		* guys come out and shoot you
		* drops teargas if you're too close for the turret to shoot

* special abilities
	* energy bar
	* getting augmentation inhibitors removed
		* maybe using codes dropped from enemies
	* and/or getting new augmentations/upgrades
	
	* super jump: steady boosters (increased jump_velocity_air_control) and/or double jump boosters
	* maybe a grappling hook
	* maybe a force field (late game)
	* electric magnet boots for un-overshooting jumps
	* gun that can blow up cars
	* sprint
	* capacitor on the tracks that you can get energy from (and blow up)

* music
	* industrial (in-*duh*-strial)
	* dynamic progression
	* different tracks for different game modes
* sfx
	* jumping/landing
	* running
	* collisions
	* sliding down walls / on the floor
	* cars going by with dynamic Doppler effect?
	* sniper shots (towards you)
	* [clack](images/mockups/clack.png)
	* warning indicators (easy)
	* menu sounds (easy)

* screens
	* title
	* pause
	* settings
		* controls
		* contrast
		* volume(s)
	* credits
		* Code | Isaiah Odhner
		*  Art | Jaden Odhner
		* Th-Th-Th-Th-Th-... That's all, folks!

* character animations
	* idle
	* wider balancing stance: hands should both go out
	* vaulting over fence
	* jumping down when no fence (maybe just use the crouching frame somehow?)
	* landing? (maybe just add some weight to the crouching frame)
	* decelerating with air control?
	* skidding to a stop?
	* descending a wall? (holding <kbd>down</kbd>)
	* pre-wall-jump frame?
	* wall run?
	* climbing ladder (head on)
	* ascending/descending stairs
	* getting hit
		* the floor sliding frame used backwards looks like you getting knocked down
		* (btw - if hit in arm, it should spark)
	* (when wall-sliding, hand could spark)
	* running up against a wall stopping self with arms / leaning
	* TODO: use special hand segment when wall-sliding
	* things that look weird:
		* jumping from crouch: you jump instantly and then slooowly extend your legs, instead of using them at all
		* jumping from slide
		* getting up from slide (maybe try faster transition to/from slide)
		* sliding backwards
		* jumping backwards
		* inching along, especially when holding crouch (but you can't move crouching anymore) (but what's it supposed to look like?)
		* wall-sliding frame can get reversed
		* sliding backwards
		* sliding on a car to the edge and then getting turned around
		* bounding: should use alternating hands (and legs)
		* standing on the edge of a building
