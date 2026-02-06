## THE PLAYER
extends Bot
class_name BotPlayer

const PROJECTILE_SCENE : PackedScene = preload("res://scenes/robots/player/projectiles/projectile.tscn")

@export var spriteAnimator : AnimatedSprite2D
@export var beep_boop_sound : AudioStreamPlayer
@export var throw_sound : AudioStreamPlayer

#region ammo

var ammo: int = 0
signal ammo_picked(ammo_count:int)
signal ammo_used(ammo_count:int)

func pickup_ammo():
	if ammo >= GlobalVariables.MAX_AMMO:
		return
	ammo += 1
	print("pickup_ammo(), ammo count = " , ammo)
	ammo_picked.emit(ammo)

func throw_ammo():
	if not ammo:
		return
	ammo -= 1
	ammo_used.emit(ammo)
	
	throw_sound.play()
	var projectile := PROJECTILE_SCENE.instantiate() as Node2D
	projectile.top_level = true
	projectile.global_position = global_position
	projectile.z_index = 1000
	projectile.z_as_relative = false
	add_child(projectile)

#endregion

#region state machine

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
	ammo_picked.connect(EventBus.ammo_picked.emit)
	ammo_used.connect(EventBus.ammo_used.emit)
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

#endregion
