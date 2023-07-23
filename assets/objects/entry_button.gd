extends Label

var mod_file_path = ""

func set_text(sent_text : String):
	$move_side_button.text = sent_text

func get_text() -> String:
	return $move_side_button.text

func toggle_dir_buttons(state : bool):
	#toggles visibility of the up and down buttons, intended to only be used on the Load Order list
	$Up_button.visible = state
	$Down_button.visible = state

func _on_move_side_button_pressed():
	#When clicked, it will tell the main scene to move this object to the other side.
	get_tree().current_scene.swap_sides(self)

func _on_Up_button_pressed():
	#Moves item up one level on the Load Order List if it is not the top
	if get_index() != 0:
		get_parent().move_child(self, get_index() - 1)
		get_tree().current_scene.handle_offset()

func _on_Down_button_pressed():
	#Move item down one level on the Load Order List
	get_parent().move_child(self, get_index() + 1)
	get_tree().current_scene.handle_offset()
