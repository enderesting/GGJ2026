## EventBus autoload
extends Node

# Trap signals
signal trap_started(name: StringName)
signal trap_finished(name: StringName)
signal trap_cooldown()
signal trap_color_picked(blessed_quadrant: Quadrant)
