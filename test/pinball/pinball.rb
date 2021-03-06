$n = $native
$n.import "Box2D.Dynamics.*"
$n.import "Box2D.Collision.*"
$n.import "Box2D.Collision.Shapes.*"
$n.import "Box2D.Dynamics.Joints.*"
$n.import "Box2D.Dynamics.Contacts.*"
$n.import "Box2D.Common.Math.*"
$n.import "flash.events.*"
$n.import "flash.display.*"
$n.import "flash.text.*"
$n.import "General.*"
$n.import "TestBed.*"

class Pinball
	def initialize
		add_fps_counter
		add_sprite
		add_instructions_text
		add_input_fix_sprite
		init_world
		add_listener
	end

	def add_listener
		listener = Proc.new{|evt|
			# clear for rendering
			@sprite.graphics.clear
			
			# reset(R)
			if $n.Input.isKeyPressed 82 then
				init_world
			end
			
			# update
			@world.Update
			$n.Input.update
			@fps_counter.update
		}
		# add event listener
		$n._root.addEventListener $n.Event.ENTER_FRAME, listener, false, 0, true
	end

	def init_world
		@world = $n.Test.new
		
		add_wall 430, 300, 5, 150, 0, 0.3
		add_wall 480, 300, 5, 200, 0, 0.3
		add_wall 480, 100, 5, 100, 0.8, 0.3
		add_wall 110, 300, 5, 200, 0, 0.3
		add_wall 110, 100, 5, 100, 0.2, 0.3
		
		wall_l = add_wall 145, 285, 40, 5, 0.2, 1.5
		wall_r = add_wall 395, 285, 40, 5, 0.8, 1.5

		add_flap 207, 310, 44, 5, 0, wall_l, 1
		add_flap 333, 310, 44, 5, 0, wall_r, -1

		add_super_ball 160, 200, 10
		add_super_ball 210, 100, 10
		add_super_ball 260, 150, 10
		add_super_ball 310, 200, 10
		add_super_ball 360, 120, 10

		5.times {
			add_box
		}
	end
	
	def add_wall(x, y, w, h, rotation, restituion)
		boxDef = $n.b2BoxDef.new
		bodyDef = $n.b2BodyDef.new

		boxDef.density = 0.0
		boxDef.friction = 0.4
		boxDef.restitution = restituion
		
		physScale = @world.m_physScale
		boxDef.extents.Set w / physScale, h / physScale
		bodyDef.position.Set x / physScale, y / physScale
		bodyDef.rotation = rotation * $n.Math.PI
		bodyDef.AddShape boxDef

		@world.m_world.CreateBody bodyDef
	end
	
	def add_flap(x, y, w, h, rotation, attach_wall, lr)
		boxDef = $n.b2BoxDef.new
		bodyDef = $n.b2BodyDef.new

		boxDef.density = 2.0
		boxDef.friction = 0.4
		boxDef.restitution = 0.3
		
		physScale = @world.m_physScale
		boxDef.extents.Set w / physScale, h / physScale
		bodyDef.position.Set x / physScale, y / physScale
		bodyDef.rotation = rotation * $n.Math.PI
		bodyDef.AddShape boxDef

		flap = @world.m_world.CreateBody bodyDef

		# Joint
		jd = $n.b2RevoluteJointDef.new
		jd.enableLimit = true
		if lr == 1 then
			jd.lowerAngle = -40 / (180 / $n.Math.PI)
			jd.upperAngle = 0
		else
			jd.lowerAngle = 0
			jd.upperAngle = 40 / (180 / $n.Math.PI)
		end
		jd.anchorPoint.Set ((x - lr * w / 2) / physScale, y / physScale)
		jd.body1 = attach_wall
		jd.body2 = flap
		@world.m_world.CreateJoint jd
	end
	
	def add_super_ball(x, y, radius)
		boxDef = $n.b2CircleDef.new
		bodyDef = $n.b2BodyDef.new

		boxDef.density = 0.0
		boxDef.friction = 0.3
		boxDef.restitution = 2.0
		
		physScale = @world.m_physScale
		boxDef.radius = radius / physScale
		bodyDef.position.Set x / physScale, y / physScale
		bodyDef.rotation = $n.Math.random * $n.Math.PI
		bodyDef.AddShape boxDef

		@world.m_world.CreateBody bodyDef
	end

	def add_box
		boxDef = $n.b2BoxDef.new
		bodyDef = $n.b2BodyDef.new

		boxDef.density = 1.0
		boxDef.friction = 0.3
		boxDef.restitution = 0.1
		
		w = $n.Math.random * 5 + 10
		h = $n.Math.random * 5 + 10
		x = 455
		y = $n.Math.random * 150 + 70
			
		physScale = @world.m_physScale
		boxDef.extents.Set w / physScale, h / physScale
		bodyDef.position.Set x / physScale, y / physScale
		bodyDef.rotation = $n.Math.random * $n.Math.PI
		bodyDef.AddShape boxDef

		@world.m_world.CreateBody bodyDef
	end
	
	def add_fps_counter
		@fps_counter = $n.FpsCounter.new
		@fps_counter.x = 7
		@fps_counter.y = 5
		$n.Main.m_fpsCounter = @fps_counter
		$n._root.addChildAt @fps_counter, 0
		# limit framerate
		$n.FRateLimiter.limitFrame 30
	end
	
	def add_sprite
		@sprite = $n.Sprite.new
		$n.Main.m_sprite = @sprite
		$n._root.addChild @sprite

		@input = $n.Input.new @sprite
	end

	#Instructions Text
	def add_instructions_text
		instructions_text = $n.TextField.new

		instructions_text_format = $n.TextFormat.new "Arial", 16, 0xffffff, false, false, false
		instructions_text_format.align = $n.TextFormatAlign.RIGHT

		instructions_text.defaultTextFormat = instructions_text_format
		instructions_text.x = 140
		instructions_text.y = 4.5
		instructions_text.width = 495
		instructions_text.height = 61
		instructions_text.text = "Pinball: \nDrag to move.\n'R' to reset."
		$n._root.addChild instructions_text
	end

	# textfield pointer
	def add_about_text
		aboutTextFormat = $n.TextFormat.new "Arial", 16, 0x00CCFF, true, false, false
		aboutTextFormat.align = $n.TextFormatAlign.RIGHT

		about_text = $n.TextField.new
		about_text.defaultTextFormat = aboutTextFormat
		about_text.x = 194
		about_text.y = 71
		about_text.width = 200
		about_text.height = 30
		$n.Main.m_aboutText = about_text
		$n._root.addChild about_text
	end

	# Make a big invisible box to cover the stage so that input focus doesn't change when mousing over the textfields
	# (Please let me know if there's a better way to solve this problem) (:
	def add_input_fix_sprite
		inputFixSprite = $n.Sprite.new
		inputFixSprite.graphics.lineStyle 0,0,0
		inputFixSprite.graphics.beginFill 0,0
		inputFixSprite.graphics.moveTo -10000, -10000
		inputFixSprite.graphics.lineTo 10000, -10000
		inputFixSprite.graphics.lineTo 10000, 10000
		inputFixSprite.graphics.lineTo -10000, 10000
		inputFixSprite.graphics.endFill
		$n._root.addChild inputFixSprite
	end
end

Pinball.new
