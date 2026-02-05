## The base for both the player and the other NPC robots
##
## Both robots and masker should inherit the movable class. Maybe give it a better name though
class_name Bot
extends CharacterBody2D

@export var play_area: CollisionShape2D

const SPEED = 100.0


func _physics_process(_delta: float) -> void:
	# TODO HACK
	get_child(0).flip_h = velocity.x > 0


func random_position():
	var play_size := (play_area.shape as RectangleShape2D).size
	var play_topright := -play_size/2
	return Vector2(
		randf_range(play_topright.x, play_topright.x + play_size.x),
		randf_range(play_topright.y, play_topright.y + play_size.y)
	)
