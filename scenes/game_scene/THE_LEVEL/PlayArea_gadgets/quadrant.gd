## ugh...
## why did I write this wrapper
class_name Quadrant
extends Area2D

@onready var anims: AnimationPlayer = $AnimationPlayer

signal animation_finished(anim_name: StringName)

func _ready() -> void:
	anims.animation_finished.connect(animation_finished.emit)
	turn_off()


func get_extents() -> Rect2:
	return Rect2(
		
	)


func kill_them_all() -> void:
	for body in get_overlapping_bodies():
		if body is RoamingRobot:
			body.queue_free() # TODO dying state

# Animations

func turn_on():
	anims.play("on")
	
func turn_off():
	anims.play("off")

func animate_dramatic_flicker() -> Signal:
	anims.play("flicker")
	return animation_finished

func animate_turn_on() -> Signal:
	anims.play("turn_on")
	return animation_finished

func animate_turn_off() -> Signal:
	anims.play("turn_off")
	return animation_finished
