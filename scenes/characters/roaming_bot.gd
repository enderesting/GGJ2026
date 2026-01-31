## The base for both the player and the other NPC robots
##
## Both robots and masker should inherit the movable class. Maybe give it a better name though
class_name RoamingRobot
extends CharacterBody2D

@export var play_area: CollisionShape2D

const SPEED = 100.0


func random_position():
	return Vector2(
		randi_range(play_area.position.x - play_area.shape.size.x/2, play_area.shape.size.x),
		randi_range(play_area.position.y - play_area.shape.size.y/2, play_area.shape.size.y)
	)
	
