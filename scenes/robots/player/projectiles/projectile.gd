class_name Projectile
extends Node2D

# spawns and moves in an arc to the overseer coordinates, then generates a lil explosion
var overseer_location : Vector2

var flying_to_overseer := false
var y_speed: float = -30

var progress := 0.0
var spawn_position: Vector2
var target_position: Vector2

func _ready() -> void:
	var part = randi_range(0,2)
	var parts = $AnimatedSprite2D.get_sprite_frames()
	$AnimatedSprite2D.play(parts.get_animation_names().get(part))
	%sfx.pitch_scale = 0.75 * [1.00, 1.12, 1.26, 1.33, 1.50, 1.68, 1.89, 2.00].pick_random()
	
	move_to_overseer()

func _process(delta: float) -> void:
	if flying_to_overseer:
		rotate(delta * -20.0)
		
		progress = minf(progress + delta, 1.0)
		if progress < 1.0:
			global_position.x = lerpf(spawn_position.x, target_position.x, progress)
			global_position.y = lerpf(spawn_position.y, target_position.y, progress) - 50.0 * (
				1 - pow(-1 + 2*progress, 2))
		else:
			flying_to_overseer = false
			_reached_overseer()


func _reached_overseer():
#	explosion animation goes here
	$AnimatedSprite2D.visible = false
	%sfx.play()
	%sfx.finished.connect(queue_free)
	(get_tree().get_first_node_in_group("overseer") as Overseer).take_damage()

func move_to_overseer():
	flying_to_overseer = true
	progress = 0.0
	spawn_position = global_position
	target_position = (get_tree().get_first_node_in_group("overseer") \
		.get_node("%ProjectileDestination") as RectangularArea
	).get_random_global_position()
	
