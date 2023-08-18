extends Label

var entry = ""

func set_text(sent_text : String) -> void:
	entry = sent_text
	$move_side_button.text = sent_text

func _on_move_side_button_pressed():
	get_parent().get_parent().get_parent().swap_sides(self)
