extends Node


const BGM_RESTORE_TIME: float = 5
const UNDERWATER_PHASER_DEPTH: float = 0.3
const UNDERWATER_NOTCH_CUTOFF: float = 800
const UNDERWATER_TWEEN_TIME: float = 0.2

@onready var main_bus_idx: int = AudioServer.get_bus_index("Main")

@onready var bgm: AudioStreamPlayer = $BGM
@onready var bgm_start_vol: float = bgm.volume_linear

@onready var victory: AudioStreamPlayer = $Victory
@onready var victory_start_vol: float = victory.volume_linear

@onready var intro_jingle: AudioStreamPlayer = $IntroJingle

var fade_tween: Tween
var victory_tween: Tween
var water_tween: Tween
var is_underwater: bool
var stop_restore: bool


func fade_bgm() -> void:
	if is_instance_valid(fade_tween):
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(bgm, "volume_linear", 0.0, 0.75)
	fade_tween.tween_callback(bgm.set_stream_paused.bind(true)).set_delay(0.75)


func play_victory_theme() -> void:
	if is_instance_valid(victory_tween):
		victory_tween.kill()
	
	victory_tween = create_tween()
	victory_tween.set_parallel()
	
	if not stop_restore:
		victory_tween.tween_callback(restore_bgm).set_delay(BGM_RESTORE_TIME)

	victory_tween.tween_property(victory, "volume_linear", victory_start_vol, 0.25)
	victory_tween.tween_callback(victory.play).set_delay(0.25)


func restore_bgm() -> void:
	if is_instance_valid(victory_tween):
		victory_tween.kill()
	
	victory_tween = create_tween()
	victory_tween.set_parallel()
	
	bgm.stream_paused = false
	victory_tween.tween_property(bgm, "volume_linear", bgm_start_vol, 0.75)
	victory_tween.tween_property(victory, "volume_linear", 0.0, 0.75)


func set_underwater(new_underwater: bool) -> void:
	if is_instance_valid(water_tween):
		water_tween.kill()
	
	is_underwater = new_underwater
	var phaser_filter: AudioEffectPhaser = AudioServer.get_bus_effect(main_bus_idx, 0)
	var notch_filter: AudioEffectNotchFilter = AudioServer.get_bus_effect(main_bus_idx, 1)
	
	if is_underwater:
		water_tween = create_tween()
		water_tween.set_parallel()
		water_tween.tween_property(phaser_filter, "depth", UNDERWATER_PHASER_DEPTH, UNDERWATER_TWEEN_TIME)
		water_tween.tween_property(notch_filter, "cutoff_hz", UNDERWATER_NOTCH_CUTOFF, UNDERWATER_TWEEN_TIME)
		#AudioServer.set_bus_effect_enabled(main_bus_idx, 0, true)
		#AudioServer.set_bus_effect_enabled(main_bus_idx, 1, true)
	else:
		water_tween = create_tween()
		water_tween.tween_property(phaser_filter, "depth", 0.1, UNDERWATER_TWEEN_TIME)
		water_tween.tween_property(notch_filter, "cutoff_hz", 20, UNDERWATER_TWEEN_TIME)
		#water_tween.finished.connect(disable_effects, CONNECT_ONE_SHOT)


func disable_effects() -> void:
	AudioServer.set_bus_effect_enabled(main_bus_idx, 0, false)
	AudioServer.set_bus_effect_enabled(main_bus_idx, 1, false)
