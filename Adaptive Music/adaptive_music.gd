
## Adaptive music system
##
## @tutorial https://docs.google.com/document/d/1P3tQaZl7iD5_aL2ZEIxGA0mr4AaJxtJet7LknBPQDG8/edit?usp=sharing
class_name AdaptiveMusic extends Node

# look at tutorial to understand these
signal half_beat
signal beat
signal half_bar
signal bar
signal four_bar
signal eight_bar

@export var master_track : AudioStreamPlayer
@export var trans_in_player : AudioStreamPlayer
@export var trans_out_player : AudioStreamPlayer

## Set this value to the bpm of whatever your master track is
@export var bpm: float = 159.0

var _beat_duration: float
var _beat_index : int = 0 
var _last_beat_index: int = 0
var _bar_index: int = 0


func _ready() -> void:
	start()


func _process(_delta: float) -> void:
	if !master_track.playing:
		return
	
	_beat_index = int( master_track.get_playback_position() / _beat_duration )
	
	if !(_beat_index > _last_beat_index or _beat_index == 0 and _last_beat_index > _beat_index):
		return
	
	half_beat.emit()
	_last_beat_index = _beat_index
	_bar_index += 1
	if _bar_index % 2 == 0:
		beat.emit()
	if _bar_index % 4 == 0:
		half_bar.emit()
	if _bar_index % 8 == 0:
		bar.emit()
	if _bar_index % (8 * 4) == 0:
		four_bar.emit()
	if _bar_index % (8 * 8) == 0:
		eight_bar.emit()


func start() -> void:
	_beat_duration = 60.0 / bpm
	if !master_track.is_node_ready():
		await master_track.ready
	
	if !trans_in_player == null && !trans_in_player.is_node_ready():
		await trans_in_player.ready
	
	await transition_in()
	master_track.play()


func transition_out() -> void:
	await bar
	master_track.stop()
	trans_in_player.play()
	await trans_in_player.finished


func transition_in() -> void:
	await bar
	master_track.stop()
	trans_in_player.play()
	await trans_in_player.finished
