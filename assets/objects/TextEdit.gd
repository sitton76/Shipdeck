extends LineEdit

var active = false
var caller = null
var current_mode

func make_active(mode):
	text = ""
	active = true
	current_mode = mode
	get_parent().show()

func make_inactive():
	active = false
	current_mode = null
	get_parent().hide()

func _on_TextEdit_text_changed(_new_text):
	if get_text().length() > 12:
		editable = false

func _input(_event):
	if active == true:
		if Input.is_action_just_pressed("backspace"):
			editable = true

func _on_Accept_pressed():
	get_parent().get_parent().add_entry(text, current_mode, false)
	make_inactive()

func _on_Cancel_pressed():
	get_parent().get_parent().toggle_items_view(true)
	make_inactive()

