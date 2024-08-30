extends CharacterBody2D
@export var moveSpeed : float = 100
@onready var lastDirection = 0 #0 - down, 1 - up, 2 - left, 3 - right
@onready var attackDirection = 0
@onready var entityID = "player"
@onready var health = 5
@onready var isAttacking = false
@onready var canWalk = true

@onready var tick : float = 0
@onready var damagedTick : float = 0
@onready var slowDirection : Vector2

@onready var damagedDirection
@onready var isDamaged : bool = false
@onready var flashWhite = true
@onready var deflash = 1
@onready var isDying : bool = false

@onready var path = self.get_path()

func _ready():
	$AnimationPlayer.play("idleDown")

func _input(event):
	if event is InputEventMouseMotion:
		var cursor = event.relative
		
		if(cursor[0] <= -100):
			$attackDirections/downArrow.visible = false
			$attackDirections/upArrow.visible = false
			$attackDirections/leftArrow.visible = true
			$attackDirections/rightArrow.visible = false
			attackDirection = 2
		if(cursor[0] >= 100):
			$attackDirections/downArrow.visible = false
			$attackDirections/upArrow.visible = false
			$attackDirections/leftArrow.visible = false
			$attackDirections/rightArrow.visible = true
			attackDirection = 3
		if(cursor[1] <= -100):
			$attackDirections/downArrow.visible = false
			$attackDirections/upArrow.visible = true
			$attackDirections/leftArrow.visible = false
			$attackDirections/rightArrow.visible = false
			attackDirection = 1
		if(cursor[1] >= 100):
			$attackDirections/downArrow.visible = true
			$attackDirections/upArrow.visible = false
			$attackDirections/leftArrow.visible = false
			$attackDirections/rightArrow.visible = false
			attackDirection = 0
		
		
		
		
func animationPlay():
	if(!isAttacking):
		if(velocity.is_zero_approx() && isDamaged != true && health > 0):
			match lastDirection:
				0:
					$Sprite2D.flip_h = false
					$AnimationPlayer.play("idleDown")
				1:
					$Sprite2D.flip_h = false
					$AnimationPlayer.play("idleUp")
				2:
					$Sprite2D.flip_h = true
					$AnimationPlayer.play("idleRight")
				3:
					$Sprite2D.flip_h = false
					$AnimationPlayer.play("idleRight")
		elif(health > 0):
			match lastDirection:
				2:
					$Sprite2D.flip_h = true
					$AnimationPlayer.play("walkRight")
				3:
					$Sprite2D.flip_h = false
					$AnimationPlayer.play("walkRight")
				0:
					$Sprite2D.flip_h = false
					$AnimationPlayer.play("walkDown")
				1:
					$Sprite2D.flip_h = false
					$AnimationPlayer.play("walkUp")
		elif(health <= 0 && $Sprite2D.frame != 56):
			$AnimationPlayer.play("death")
func attack():
	isAttacking = true
	
	match attackDirection:
			0:
				$damageZone/damageDown.disabled = false
				$Sprite2D.flip_h = false
				$AnimationPlayer.play("attackDown")
			1:
				$damageZone/damageUp.disabled = false
				$Sprite2D.flip_h = false
				$AnimationPlayer.play("attackUp")
			2:
				$damageZone/damageLeft.disabled = false
				$Sprite2D.flip_h = true
				$AnimationPlayer.play("attackRight")
			3:
				$damageZone/damageRight.disabled = false
				$Sprite2D.flip_h = false
				$AnimationPlayer.play("attackRight")

func disableAttacks():
	$damageZone/damageDown.disabled = true
	$damageZone/damageUp.disabled = true
	$damageZone/damageLeft.disabled = true
	$damageZone/damageRight.disabled = true

func _physics_process(_delta):
	var direction = Vector2.ZERO
	
	if(health == 0):
		isDying = true
		canWalk = false
		isAttacking = false
	
	animationPlay()
	if($Sprite2D.frame == 45 || $Sprite2D.frame == 39 || $Sprite2D.frame == 51):
		isAttacking = false
		canWalk = true
		disableAttacks()
	
	elif(isDamaged):
		canWalk = false
		isAttacking = false
		disableAttacks()
		
		$AnimationPlayer.stop()
		#$Sprite2D.frame = 28
		$deathParticles.emitting = true
		if(flashWhite):
			if($Sprite2D.material.get_shader_parameter("flashModifier") >= 1):
				flashWhite = false
			else:
				$Sprite2D.material.set_shader_parameter("flashModifier", (0.50 * damagedTick))
		elif(!flashWhite && $Sprite2D.material.get_shader_parameter("flashModifier") != 0 && damagedTick >= 10):
			$Sprite2D.material.set_shader_parameter("flashModifier", (1 - (0.50 * deflash)))
			deflash = deflash + 1
		else:
			deflash = 1
		
		if(damagedTick == 20):
			damagedTick = 0
			isDamaged = false
			flashWhite = true
			canWalk = true
		elif(damagedTick >= 10):
			velocity = Vector2.ZERO
			damagedTick = damagedTick + 1
		else:
			damagedTick = damagedTick + 1
			move_and_collide(damagedDirection)
		
		
	
	else:
		if(canWalk):
			direction = Input.get_vector("left", "right", "up", "down") #This is basically a long if tree for each key.
			if(direction[0] < 0):
				lastDirection = 2
			elif(direction[0] > 0):
				lastDirection = 3
			elif(direction[1] > 0):
				lastDirection = 0
			elif(direction[1] < 0):
				lastDirection = 1
		if(isAttacking == false):
			if(Input.is_action_pressed("attack")):
				attack()
				canWalk = false
			
	
	
		if(direction.x == 0 && direction.y == 0):
			if(tick > 0.1):
				tick = tick - 0.30
			else: #Friction for slowing down when letting go of walking keys
				tick = 0
				velocity = Vector2.ZERO
			velocity = slowDirection * (moveSpeed * tick) 
		else: #Friction for walking to max speed
			slowDirection = direction
			velocity = direction * (moveSpeed * tick) 
			if(tick < 0.9):
				tick = tick + 0.25
	
		move_and_collide(velocity * _delta)



func damaged(attackedDirection):
	isDamaged = true
	self.damagedDirection = attackedDirection
	$AnimationPlayer.stop()


func _on_damage_zone_body_entered(body):
	if(body.entityID == "slime"):
		var slime = get_node(body.get_path())
		slime.health = slime.health - 1
		slime.damaged(attackDirection)
	elif(body.entityID == "cyclops"):
		var cyclops = get_node(body.get_path())
		cyclops.health = cyclops.health - 1
		cyclops.damaged(attackDirection)
		
		
		
