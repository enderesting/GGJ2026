## An NPC
class_name RobotNPC
extends RoamingRobot

var states: Dictionary[StringName, State] = {
	"IDLE": NPCIdleState.new(),
	"BUSY": NPCBusyState.new(),
	"RUNNING_TO_QUADRANT": NPCGotoQuadrantState.new(),
	"DYING": NPCDyingState.new(),
}

var current_state: State

var goal: Vector2
@export var dist_to_goal: float = 5

func _init() -> void:
	for state_name in states:
		states[state_name].character = self

func _ready() -> void:
	position = random_position()
	change_state(states["IDLE"])

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_process(delta)

	super(delta)
