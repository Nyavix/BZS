extends KinematicBody2D

export var spriteName = "Bob"
export var wallSlideA = "wallslideA"
export var jumpA = "jumpA"
export var walkA = "walkA"
export var landDust = "LandingDust"
export var runDust = "RunningDust"

export var speed = 100
export var jumpForce = -800
export var gravity = 25
export var lerpVal = 0.1

var nearBall
var landed = false
var animFrame = 0
var wJumpCount = 0

var vel = Vector2()

onready var sprite = get_node(spriteName)
onready var wsAudio = get_node(wallSlideA)
onready var jumpAudio = get_node(jumpA)
onready var walkAudio = get_node(walkA)
onready var landingDust = get_node(landDust)
onready var runningDust = get_node(runDust)


#animations
func pRun():
	
	if not is_on_floor() and not is_on_wall():
		if vel.x == 0:
			landed = false
			animFrame = 0
	
	if is_on_floor() and (vel.x > 0 or vel.x < 0):
		landed = true
		sprite.play('run')	
		if not walkAudio.is_playing():	
			walkAudio.play()
	
	if not is_on_floor() and not is_on_wall():
		sprite.play('jump')
		walkAudio.stop()
	
	if is_on_floor() and vel.x == 0:
		if not landed and animFrame < 10:
			sprite.play('land')	
			animFrame = sprite.get_frame()
			if animFrame >= 10:
				landed = true
		elif landed:
			sprite.play('idle')
			walkAudio.stop()
		
	if is_on_wall() and not is_on_floor():
		sprite.play('wallslide')
		walkAudio.stop()
		if not wsAudio.is_playing():
			wsAudio.play()
	else: wsAudio.stop()

func particleUpdate():
	
	if is_on_floor() and not landed:
		landingDust.emitting = true
	
	if vel.x != 0 and is_on_floor():
		runningDust.emitting = true;
	else:
		runningDust.emitting = false;


func _physics_process(delta):
	
	# movement input
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	elif Input.is_action_just_released("move_left"): 
		if not is_on_wall():
			wJumpCount = 0	
		vel.x = 0
		
	if Input.is_action_pressed("move_right"):
		vel.x += speed
	elif Input.is_action_just_released("move_right"): 
		if not is_on_wall():
			wJumpCount = 0
		vel.x = 0
	
	#applying the velocity
	vel = move_and_slide(vel, Vector2.UP)
	
	vel.x = lerp(vel.x, 0, lerpVal)
	
	#gravity
	if is_on_wall() and not is_on_floor():
		vel.y = lerp(0, gravity, 5)
	else:
		vel.y += gravity
	
	
	#jump input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			wJumpCount = 0
			jumpAudio.play()
			vel.y += jumpForce
		if is_on_wall() and wJumpCount < 2:
			wJumpCount += 1
			jumpAudio.play()
			vel.y = jumpForce
			if is_on_wall() and sprite.flip_h == true:
				if is_on_floor():
					vel.y += jumpForce
				else:
					vel.x += -jumpForce * 2
			elif is_on_wall() and sprite.flip_h == false:	
				if is_on_floor():
					vel.y += jumpForce
				else:
					vel.x += jumpForce * 2
	
	#flips the sprite depending what direction player is moving
	if vel.x < 0:
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.flip_h = false
		
	particleUpdate()
	pRun()
	
func near_ball():
	nearBall = true

