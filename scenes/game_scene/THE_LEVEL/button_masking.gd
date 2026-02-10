extends Sprite2D

var blink_lit: Color = Color.WHITE.lerp(GlobalVariables.COLOR_BG, 0.05)
var blink_dim: Color = Color.WHITE.lerp(GlobalVariables.COLOR_BG, 0.95)

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var activated_led: TextureRect = $ActivatedLED

## Drives the "LED" blinking
@onready var led_blink: Tween = (func():
	var t := (create_tween()
		.set_loops() # Infinite blinking
		.set_ignore_time_scale()
		.set_ease(Tween.EASE_OUT)
		.set_trans(Tween.TRANS_EXPO)) # Capacitors have exponential discharge curve

	# Blinking animation sequence
	t.tween_property(activated_led, ^"modulate", blink_lit, 0.15).from(blink_dim)
	t.tween_interval(0.30)
	t.tween_property(activated_led, ^"modulate", blink_dim, 0.25)
	t.tween_interval(0.30)
	# Manually advance some milliseconds, to sync a bit more to the warning signs
	t.custom_step(0.02)
	
	t.stop()
	return t
).call() # Maybe an AnimationPlayer would've made more sense. But it doesn't have TRANS_EXPO!


func _ready() -> void:
	EventBus.trap_started.connect(_on_trap_started)
	EventBus.trap_finished.connect(_on_trap_finished)


func _on_trap_started(trap_name):
	if trap_name == name:
		activated_led.show()
		led_blink.play()


func _on_trap_finished(_trap_name):
	activated_led.hide()
	led_blink.stop()
	(create_tween()
		.tween_property(progress_bar, ^"value", progress_bar.min_value,
			Globals.match_trap_cooldown)
		.from(progress_bar.max_value)
		.set_trans(Tween.TRANS_LINEAR))
