extends Node2D


# Called when the node enters the scene tree for the first time.



func _ready() -> void:
	var label = $GameOverUI/GameOverLabel

	label.text = "GAME OVER"
	label.add_theme_color_override("font_color", Color.WHITE)
	label.self_modulate = Color("#EF4444")



# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
