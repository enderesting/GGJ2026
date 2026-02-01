extends Node2D

@onready var label: Label = $Label
@onready var timer: Timer = $Timer
#signal game_over(winner: StringName)

func _ready():
	timer.start()
	#game_over.connect(EventBus.game_over.emit)

func time_left_to_live():
	var time_left = timer.time_left
	var min = floor(time_left /60)
	var sec = int(time_left) % 60
	return [min,sec]

func _process(delta: float) -> void:
	label.text = "%02d:%02d" % time_left_to_live()
