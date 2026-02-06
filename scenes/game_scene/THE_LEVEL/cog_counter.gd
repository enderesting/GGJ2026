extends Sprite2D

@onready var cog_anim_player: AnimationPlayer = $AnimationPlayer
@onready var cog_pile: Sprite2D = $CogPile

const MAX_COG: int = 5
const COG_Y_EMPTY: int = 9
const COG_Y_FULL: int = -3

func _ready() -> void:
	EventBus.ammo_picked.connect(on_ammo_pickup)
	EventBus.ammo_used.connect(on_ammo_used)

func on_ammo_pickup(cog_counter: int) -> void:
	print("picked up cog")
	cog_anim_player.play("AddCog")
	cog_pile.position.y =\
	 COG_Y_EMPTY+(COG_Y_FULL-COG_Y_EMPTY)/MAX_COG*cog_counter
	

func on_ammo_used(cog_counter: int) -> void:
	cog_pile.position.y =\
	 COG_Y_EMPTY+(COG_Y_FULL-COG_Y_EMPTY)/MAX_COG*cog_counter	
