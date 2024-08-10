extends Control

const MAIN = preload("res://scenes/main.tscn")

@onready var level_label = $MarginContainer/VB/LevelLabel
@onready var attempts_label = $MarginContainer/VB/AttemptsLabel
@onready var game_sound = $GameSound
@onready var vb_2 = $MarginContainer/VB2

func _ready():
	level_label.text = "LEVEL %s" % ScoreManager.get_level_selected()
	update_attempts(0)
	SignalManager.on_score_updated.connect(update_attempts)
	SignalManager.on_level_complete.connect(on_level_complete)
	pass
	
func _process(delta):
	if(Input.is_action_just_pressed("Menu")):
		get_tree().change_scene_to_packed(MAIN)
		pass

func update_attempts(attempts: int) -> void:
	attempts_label.text = "Attempts %s" % attempts
	pass

func on_level_complete() -> void:
	vb_2.show()
	game_sound.play()
	pass
