extends Label

func set_text(sent_text : String) -> void:
	$move_side_button.text = sent_text

func _on_remove_button_pressed():
	self.hide()
	get_parent().get_parent().get_parent().start_delay($move_side_button.text, 0)
	queue_free()
