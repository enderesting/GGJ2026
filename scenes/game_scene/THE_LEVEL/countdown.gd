extends Node2D

const RUNNING_OUT_OF_TIME_AT: int = 20 # seconds
const BLINK_FREQ: int = 2

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

@onready var timer_fg_colors: Array[Color] = [
	label.get_theme_color(&"font_color"),  # Default color
	Color.RED,  # The alternating color when running out of time
]

#signal game_over(winner: StringName)

func _ready():
	timer.start()
	#game_over.connect(EventBus.game_over.emit)

func time_left_to_live():
	var time_left = timer.time_left
	var mins = floor(time_left / 60)
	var secs = int(time_left) % 60
	return [mins, secs]

func _process(_delta: float) -> void:
	# Update text, formatted as MINS:SECS
	label.text = "%02d:%02d" % time_left_to_live()
	
	# Update foreground color, making it blink when running out of time
	if timer.time_left <= RUNNING_OUT_OF_TIME_AT:
		var color_i := int(timer.time_left * BLINK_FREQ) % len(timer_fg_colors)
		label.add_theme_color_override(&"font_color", timer_fg_colors[color_i])
