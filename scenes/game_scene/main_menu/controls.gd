## THIS IS A HACK
## I have other transition ideas
## If you like this, I can reimplement this in a more orthodox way
## and @tomi can have fun trying to create a more interesting "swoosh" sfx
## in Audacity so we can keep this "100% brain-coded" (don't read below line 44)
extends Button

const DURATION: float = 0.25

const CONTROLS_SCENE: PackedScene = preload("res://scenes/game_scene/controls/controls.tscn")

var controls_screen := CONTROLS_SCENE.instantiate() as Control
var back_btn := controls_screen.find_children("*", "BaseButton")[0] as BaseButton

@onready var this_screen := get_tree().current_scene
@onready var swoosh := setup_swoosh_effect()

func _init() -> void:
	# Position controls screen above the current scene
	controls_screen.anchor_bottom = -1
	
	# HACK the back button
	back_btn.position.y += 140
	back_btn.set_script(null)
	back_btn.tree_entered.connect(back_btn.grab_focus)

func _pressed() -> void:
	this_screen.add_sibling(controls_screen)
	back_btn.pressed.connect(_on_controls_back_pressed, CONNECT_ONE_SHOT)
	swoosh.play()
	create_tween().tween_property(
		get_tree().root, ^"canvas_transform:origin:y",
		get_viewport_rect().size.y, DURATION
	).set_trans(Tween.TRANS_SINE)
	tween_labels()

func _on_controls_back_pressed() -> void:
	swoosh.play()
	await create_tween().tween_property(
		get_tree().root, ^"canvas_transform:origin:y",
		0, DURATION
	).set_trans(Tween.TRANS_SINE).finished
	grab_focus()
	controls_screen.get_parent().remove_child(controls_screen)


func tween_labels():
	var tween := create_tween().set_parallel()
	var delay := 0.0
	
	for label in controls_screen.find_children("*", "Label"):
		# Fade in
		label.modulate.a = 0
		tween.tween_property(label, ^"modulate:a", 1, 0.5).set_delay(delay)
		
		# Bounce from joypad
		var original_position = label.position
		label.position = Vector2(66, 90) if label.name != "Label6" else Vector2(240, 90)
		tween.tween_property(label, ^"position", original_position, 0.5) \
			.set_trans(Tween.TRANS_SPRING) \
			.set_ease(Tween.EASE_OUT) \
			.set_delay(delay)
		
		# Typing effect
		label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
		tween.tween_property(label, ^"visible_ratio", 1, 0.5).from(0).set_delay(delay)
		
		# Stagger the label animations a bit
		delay += 0.04


#region of code by Claude-kun
# https://claude.ai/share/dfaae040-aba3-4aff-baa6-f5b5a9f2c6f1

# 2. PINK NOISE - More power in low frequencies (1/f noise)
# Requires state variables
var pink_state = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
func pink_noise() -> float:
	var white = randf() * 2.0 - 1.0
	pink_state[0] = 0.99886 * pink_state[0] + white * 0.0555179
	pink_state[1] = 0.99332 * pink_state[1] + white * 0.0750759
	pink_state[2] = 0.96900 * pink_state[2] + white * 0.1538520
	pink_state[3] = 0.86650 * pink_state[3] + white * 0.3104856
	pink_state[4] = 0.55000 * pink_state[4] + white * 0.5329522
	pink_state[5] = -0.7616 * pink_state[5] - white * 0.0168980
	var pink = pink_state[0] + pink_state[1] + pink_state[2] + pink_state[3] + pink_state[4] + pink_state[5] + pink_state[6] + white * 0.5362
	pink_state[6] = white * 0.115926
	return pink * 0.11  # Scale down

# 7. VELVET NOISE - Sparse impulses (good for reverb/texture)
var velvet_counter = 0
var velvet_density = 100  # Lower = more sparse
func velvet_noise() -> float:
	velvet_counter += 1
	if velvet_counter >= velvet_density:
		velvet_counter = 0
		return (randf() * 2.0 - 1.0)
	return 0.0

func my_noise() -> float:
	return 0.4 * pink_noise() + 0.6 * velvet_noise()

# Generate a swoosh sound effect
func generate_swoosh() -> AudioStreamWAV:
	var sample_rate = 44100
	var duration = DURATION  # Half second swoosh
	var num_samples = int(sample_rate * duration)
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)  # 2 bytes per 16-bit sample
	
	for i in range(num_samples):
		var progress = float(i) / num_samples
		
		# Add some noise for texture
		var noise = my_noise()
		var sample = noise * 0.4
		
		# Envelope: quick attack, sustained, quick decay
		var envelope = 1.0
		if progress < 0.1:
			envelope = progress / 0.1  # Attack
		elif progress > 0.8:
			envelope = (1.0 - progress) / 0.2  # Decay
		
		# Convert to 16-bit PCM (-32768 to 32767)
		var sample_16bit = int(clamp(sample * envelope, -1.0, 1.0) * 32767.0)
		
		# Store as little-endian 16-bit
		data.encode_s16(i * 2, sample_16bit)
	
	# Create AudioStreamWAV
	var stream = AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	return stream

# Example usage
# func _ready():
func setup_swoosh_effect() -> AudioStreamPlayer:
	var swoosh_sound = generate_swoosh()
	
	# Play it using an AudioStreamPlayer
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = swoosh_sound
	player.volume_db = -10
	return player

#endregion
