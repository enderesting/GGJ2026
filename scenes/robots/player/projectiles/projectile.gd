extends Node2D

# spawns and moves in an arc to the overseer coordinates, then generates a lil explosion
var overseer_location : Vector2

func _ready() -> void:
	var part = randi_range(0,2)
	var parts = $AnimatedSprite2D.get_sprite_frames()
	$AnimatedSprite2D.play(parts.get_animation_names().get(part))
	move_to_overseer()

func _process(delta: float) -> void:
	rotate(delta * 10.0)

func _reached_overseer():
#	explosion animation goes here
	$AnimatedSprite2D.visible = false
	%sfx.play()
	%sfx.finished.connect(queue_free)

func move_to_overseer():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position",
		(get_tree().get_first_node_in_group("overseer") \
			.get_node("%ProjectileDestination") as RectangularArea
		).get_random_global_position(),
		1.0)
	tween.finished.connect(_reached_overseer)
