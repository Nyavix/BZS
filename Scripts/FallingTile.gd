extends KinematicBody2D

var isFalling = false
var gravity = 35
var vel = Vector2()


func _physics_process(_delta):
	if isFalling == true:
		vel.y += lerp(0, gravity, .25)
	else:
		vel.y = 0
	
	vel = move_and_slide(vel, Vector2.UP)


#func _on_Area2D_body_entered(_body):
#	isFalling = true


func _on_Area2D_body_exited(body):
	isFalling = true
