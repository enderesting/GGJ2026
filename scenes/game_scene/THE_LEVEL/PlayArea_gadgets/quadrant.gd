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
	anims.play("floor_lightning_killing")

	var doomed_bots: Array[RoamingRobot] = []
	for body in get_overlapping_bodies():
		if body is RobotNPC:
			body.states.DYING.animation_name = "lightning_death"
			body.states.DYING.auto_free = false
			body.change_state(body.states.DYING)
		if body is RoamingRobot:
			doomed_bots.push_back(body)

	await get_tree().create_timer(2.0).timeout
	for bot in doomed_bots:
		bot.queue_free()

# Animations

func turn_on():
	anims.play("on")

func turn_off():
	anims.play("off")

func reset():
	anims.play("RESET")

func animate_floor_lightning_charging():
	anims.play(&"floor_lightning_charging")

func animate_dramatic_flicker() -> Signal:
	anims.play("flicker")
	return animation_finished

func animate_turn_on() -> Signal:
	anims.play("turn_on")
	return animation_finished

func animate_turn_off() -> Signal:
	anims.play("turn_off")
	return animation_finished
