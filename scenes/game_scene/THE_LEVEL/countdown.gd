extends Node2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer
#signal game_over(winner: StringName)

func _ready():
	timer.start()
	#game_over.connect(EventBus.game_over.emit)

func time_left_to_live():
	var time_left = timer.time_left
	var mins = floor(time_left /60)
	var secs = int(time_left) % 60
	return [mins, secs]

func _process(_delta: float) -> void:
	label.text = "%02d:%02d" % time_left_to_live()
