## This should, eventually, like, give commands to all NPC bots
## For now it just spawns a configured amount of them

extends Node2D

@export var npcs_to_spawn: int = 10

## The robot NPC scene to instance.
## Defaults to "res://scenes/robots/npc/bot_npc.tscn"
@export var robot_npc: PackedScene = preload("res://scenes/robots/npc/bot_npc.tscn")

## Reference to the rectangular area that delineates the valid coordinates for
## the robot NPCs to be in
@export var play_area: CollisionShape2D


func _ready() -> void:
	# Spawn N robots
	for _i in npcs_to_spawn:
		spawn_bot()

func spawn_bot():
	var new_robot := robot_npc.instantiate() as BotNPC
	new_robot.add_to_group(&"npcs")
	new_robot.play_area = play_area
	add_child(new_robot, true)


func _on_overseer_color_picked(blessed_quadrant: Quadrant) -> void:
	for npc in get_children():
		if npc is BotPlayer: continue
		var next_state = npc.states.RUNNING_TO_QUADRANT
		next_state.blessed_quadrant = blessed_quadrant
		npc.change_state(next_state)

	assert(await EventBus.trap_finished == &"trap_color")

	for npc in get_children():
		if npc is BotPlayer:
			continue
		if npc is BotNPC and npc.current_state is NPCDyingState:
			continue
		npc.change_state(npc.states.IDLE)



func _on_overseer_stop_moving() -> void:
	for npc in get_children():
		if npc is BotPlayer: continue
		npc.change_state(npc.states.BUSY)
	assert(await EventBus.trap_finished == &"trap_stop")
	for npc in get_children():
		if npc is BotPlayer: continue
		npc.change_state(npc.states.IDLE)
