extends Sprite2D

@onready var cog_anim_player: AnimationPlayer = $AnimationPlayer
@onready var cog_pile: Sprite2D = $CogPile

const COG_Y_EMPTY: int = 9  ## position.y of cog pile sprite when no ammo
const COG_Y_FULL: int = -3  ## position.y of cog pile sprite when full ammo


func _ready() -> void:
	EventBus.ammo_picked.connect(_on_ammo_pickup)
	EventBus.ammo_used.connect(_on_ammo_used)


func _on_ammo_pickup(cog_counter: int) -> void:
	cog_anim_player.play("AddCog")
	_move_cog_pile(cog_counter)

func _on_ammo_used(cog_counter: int) -> void:
	_move_cog_pile(cog_counter)


## Updates the y position of the cog pile to reflect the given amount of cogs
func _move_cog_pile(cog_counter: int) -> void:
	cog_pile.position.y = remap(cog_counter,
		0, Globals.match_max_ammo,
		COG_Y_EMPTY, COG_Y_FULL)
