extends Label

var entry = ""

func set_text(sent_text : String) -> void:
	entry = sent_text
	$move_side_button.text = sent_text

func _on_remove_button_pressed():
	self.hide()
	get_parent().get_parent().get_parent().start_delay($move_side_button.text, 0)
	queue_free()

func _on_move_side_button_pressed():
	get_parent().get_parent().get_parent().otr_tag_group_editor_toggle(self, 0)
