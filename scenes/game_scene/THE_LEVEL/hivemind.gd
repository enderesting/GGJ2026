## This should, eventually, like, give commands to all NPC bots
## For now it just spawns a configured amount of them

extends Node2D

@export var npcs_to_spawn: int = 10

## The robot NPC scene to instance.
## Defaults to "res://scenes/characters/robot/robot_npc.tscn"
@export var robot_npc: PackedScene = preload("uid://bqy50s757ncyw")

## Reference to the rectangular area that delineates the valid coordinates for
## the robot NPCs to be in
@export var play_area: CollisionShape2D


func _ready() -> void:
	# Spawn N robots
	for _i in npcs_to_spawn:
		var new_robot := robot_npc.instantiate() as RobotNPC
		new_robot.play_area = play_area
		new_robot.add_to_group(&"npcs")
		add_child(new_robot)


func _on_overseer_color_picked(blessed_quadrant: Quadrant) -> void:
	for npc in get_children():
		var next_state = npc.states.RUNNING_TO_QUADRANT
		next_state.blessed_quadrant = blessed_quadrant
		npc.change_state(next_state)
