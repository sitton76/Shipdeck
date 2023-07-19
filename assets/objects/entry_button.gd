extends Label

var mod_file_path = ""

func set_text(sent_text : String):
	$Button.text = sent_text

func get_text() -> String:
	return $Button.text

func _on_Button_pressed():
	get_tree().current_scene.swap_sides(self)
