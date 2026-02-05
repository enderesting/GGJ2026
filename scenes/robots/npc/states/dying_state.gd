extends State
class_name DyingState

var animation_name: StringName = "sawblade_death"
var auto_free: bool = false


func enter():
	var anim := character.animated_sprite_2d as AnimatedSprite2D
	anim.play(animation_name)
	if auto_free:
		anim.sprite_frames.set_animation_loop(animation_name, false)
		anim.animation_finished.connect(character.queue_free) # hack
	else:
		anim.sprite_frames.set_animation_loop(animation_name, true) # hack
