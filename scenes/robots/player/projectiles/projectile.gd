extends Node2D

# spawns and moves in an arc to the overseer coordinates, then generates a lil explosion
@export var overseer_location = PackedScene

func _ready() -> void:
	var part = randi_range(0,2)
	var parts = $AnimatedSprite2D.get_sprite_frames()
	$AnimatedSprite2D.play(parts.get_animation_names().get(part))
	move_to_overseer()
#	explosion animation goes here
	queue_free()

func move_to_overseer():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", overseer_location.position, 1.0)
