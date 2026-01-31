extends RoamingRobot

var states: Dictionary
var current_state: State

func _ready():
	super._ready()
	states = {
		"IDLE": NPCIdleState.new(),
		"BUSY": NPCBusyState.new(),
		"DYING": NPCDyingState.new()
	}
	for state_name in states:
		states[state_name].character = self

	change_state(states["IDLE"])

func change_state(new_state: State):
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func _physics_process(delta):
	if current_state:
		current_state.physics_process(delta)
