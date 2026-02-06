## The base for both the player and the other NPC robots
##
## Both robots and masker should inherit the movable class. Maybe give it a better name though
class_name Bot
extends CharacterBody2D

## Should be assigned in the Inspector or when instantiating,
## or else we can't randomize positions
@export var play_area: RectangularArea
@export var beep_boop: AudioStream
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0

func _physics_process(_delta: float) -> void:
	# TODO HACK
	get_child(0).flip_h = velocity.x > 0
