extends StaticBody2D

@onready var animation_player = $AnimationPlayer

func die() -> void:
	animation_player.play("vanish")
pass


func _on_animation_player_is_finished(anim_name):
	SignalManager.on_cup_destroyed.emit()
	queue_free()
	pass
