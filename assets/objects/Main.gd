extends Node

const entry_button_file = preload("res://assets/objects/entry_button.tscn")

onready var L_window = $Left_window/VBoxContainer
onready var R_window = $Right_window/VBoxContainer
var opened_dialog = false
var dia_ref #unintiated reference to the popup dialog box that is used when selecting files/folders
var current_folder_path = ""

#TODO:
#	Pretty it up to look presentable.
#	Add a way to move a item up and down the list without having to remove a item.

func populate_list(entry : String, folder_path : String, container : Node, group_name : String):
	#Populates a given field with entry_button nodes representing a .otr file
	var new_instance = entry_button_file.instance()
	new_instance.add_to_group(group_name)
	new_instance.set_text(entry)
	new_instance.mod_file_path = folder_path + "/" + entry
	container.add_child(new_instance)

func swap_sides(obj_ref):
	#This is called from the entry_button node via the "Pressed" signal, obj_ref is the sender of the signal
	#This may also be called from the clear load order option to return mods to the folder list if they were pulled from it.
	if obj_ref.is_in_group("L-side"):
		obj_ref.remove_from_group("L-side")
		obj_ref.get_parent().remove_child(obj_ref)
		R_window.add_child(obj_ref)
		obj_ref.add_to_group("R-side")
	elif obj_ref.is_in_group("R-side"):
		obj_ref.remove_from_group("R-side")
		obj_ref.get_parent().remove_child(obj_ref)
		L_window.add_child(obj_ref)
		obj_ref.add_to_group("L-side")

func save_mod_list(file_path):
	#Saves mod list to a .json file
	dia_ref.queue_free()
	var stored_data = {}
	var iter_count = 0
	for nodes in get_tree().get_nodes_in_group("L-side"):
		stored_data.merge({iter_count : nodes.mod_file_path})
		iter_count += 1
	if iter_count > 0:
		stored_data.merge({"List-size" : str(iter_count - 1)})
		var file = File.new()
		file.open(file_path, file.WRITE)
		file.store_line(to_json(stored_data))
		file.close()
		opened_dialog = false

func check_if_on_load_list(file_name : String) -> bool:
	#Checks to see if a element is already on the Mod Load Order List, which will then prevent it
	#From loading into the Mod List when another folder is selected.
	for nodes in get_tree().get_nodes_in_group("L-side"):
		if nodes.get_text() == file_name:
			return true
	return false

func on_folder_select(opened_path):
	#Selects the folder containing .otr files
	dia_ref.queue_free()
	for nodes in get_tree().get_nodes_in_group("R-side"):
		nodes.queue_free()
	opened_dialog = false
	var dir = Directory.new()
	if dir.open(opened_path) == OK:
		current_folder_path = opened_path
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".otr"):
				if check_if_on_load_list(file_name) == false:
					populate_list(file_name, opened_path, R_window, "R-side")
			file_name = dir.get_next()

func on_dialog_close():
	#In the event the player closes a dialog box, frees it then allows the player to spawn more.
	dia_ref.queue_free()
	opened_dialog = false

func _on_load_folder_pressed():
	#Folder dialog for selecting a folder
	if opened_dialog == false:
		opened_dialog = true
		var dialog = FileDialog.new()
		dialog.mode = FileDialog.MODE_OPEN_DIR
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.connect("dir_selected", self, "on_folder_select")
		dialog.connect("popup_hide", self, "on_dialog_close")
		self.add_child(dialog)
		dia_ref = dialog
		dialog.popup(Rect2(0, 0, 700, 500))

func _on_save_list_pressed():
	#File dialog for selecting save path for .json file
	if opened_dialog == false:
		opened_dialog = true
		var dialog = FileDialog.new()
		dialog.mode = FileDialog.MODE_SAVE_FILE
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.add_filter("*.json")
		dialog.connect("file_selected", self, "save_mod_list")
		dialog.connect("popup_hide", self, "on_dialog_close")
		self.add_child(dialog)
		dia_ref = dialog
		dialog.popup(Rect2(0, 0, 700, 500))

func _on_clear_load_list_pressed():
	for nodes in get_tree().get_nodes_in_group("L-side"):
		if current_folder_path != "":
			if nodes.mod_file_path.begins_with(current_folder_path) == true:
				swap_sides(nodes)
			else:
				nodes.queue_free()
		else:
			nodes.queue_free()

func _on_clear_mod_list_pressed():
	for nodes in get_tree().get_nodes_in_group("R-side"):
		current_folder_path = ""
		nodes.queue_free()
