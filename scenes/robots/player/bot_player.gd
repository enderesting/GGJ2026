## THE PLAYER
extends Bot
class_name BotPlayer

@export var spriteAnimator : AnimatedSprite2D
@export var beep_boop_sound : AudioStreamPlayer
@export var throw_sound : AudioStreamPlayer

var states: Dictionary[StringName, State] = {
	"IDLE": IdleState.new(),
	"DYING": DyingState.new(),
	#"SHOOTING": ShootingState.new(),
}
var current_state: State

func _ready() -> void:
	# Randomize initial player position
	position = play_area.get_random_position()
	for state in states.values():
		state.character = self
	change_state(states["IDLE"])

func _exit_tree() -> void:
	EventBus.player_killed.emit()


func _physics_process(_delta: float) -> void:
	current_state.physics_process(_delta)
	
func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)
	
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
