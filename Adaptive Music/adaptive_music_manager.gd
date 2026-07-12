
## Manager for transitioning between adaptive music players. This system essentially holds a bunch of 
##
## @tutorial https://docs.google.com/document/d/1P3tQaZl7iD5_aL2ZEIxGA0mr4AaJxtJet7LknBPQDG8/edit?usp=sharing
class_name AdaptiveMusicManager extends Node

var current_player : AdaptiveMusic
var is_transitioning : bool = false
var can_transition : bool = false

@export var adaptive_music_players : Array[AdaptiveMusic]

# look at tutorial to understand these. the manager will always be the player to connect to when conncting outside nodes
# because the signals pass thru from the currently playing adaptive music player
signal half_bar
signal half_beat
signal beat
signal bar
signal four_bar
signal eight_bar


func _ready() -> void:
	connect_signals_from(current_player)
	current_player.start()
	can_transition = false


func disconnect_signals_from(adaptive_music : AdaptiveMusic) -> void:
	if adaptive_music == null:
		return
	
	adaptive_music.half_bar.disconnect(_on_half_bar)
	adaptive_music.half_beat.disconnect(_on_half_beat)
	adaptive_music.beat.disconnect(_on_beat)
	adaptive_music.bar.disconnect(_on_bar)
	adaptive_music.four_bar.disconnect(_on_four_bar)
	adaptive_music.eight_bar.disconnect(_on_eight_bar)


func connect_signals_from(adaptive_music : AdaptiveMusic) -> void:
	if adaptive_music == null:
		return
	
	adaptive_music.half_bar.connect(_on_half_bar)
	adaptive_music.half_beat.connect(_on_half_beat)
	adaptive_music.beat.connect(_on_beat)
	adaptive_music.bar.connect(_on_bar)
	adaptive_music.four_bar.connect(_on_four_bar)
	adaptive_music.eight_bar.connect(_on_eight_bar)


func transition_to(next_player : AdaptiveMusic):
	if is_transitioning:
		return
	
	is_transitioning = true
	await current_player.transition_out()
	is_transitioning = false
	
	current_player.stop()
	
	disconnect_signals_from(current_player)
	connect_signals_from(next_player)
	
	next_player.transition_in()
	current_player = next_player


func _on_half_bar() -> void:
	half_bar.emit()

func _on_half_beat() -> void:
	half_beat.emit()

func _on_beat() -> void:
	beat.emit()

func _on_bar() -> void:
	bar.emit()

func _on_four_bar() -> void:
	four_bar.emit()

func _on_eight_bar() -> void:
	eight_bar.emit()
