## ugh...
## why did I write this wrapper
class_name Quadrant
extends Area2D

@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var shape: CollisionShape2D = $Shape

signal animation_finished(anim_name: StringName)

func _ready() -> void:
	anims.animation_finished.connect(animation_finished.emit)
	turn_off()


func get_extents() -> Rect2:
	var rectangle := shape.shape as RectangleShape2D
	return Rect2(position + shape.position - rectangle.size/2, rectangle.size)


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
