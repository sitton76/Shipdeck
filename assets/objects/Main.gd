extends Node

const entry_button_file = preload("res://assets/objects/entry_button.tscn")
const offset_value = 32

onready var L_window = $Left_window/Container
onready var R_window = $Right_window/Container
var loaded_json_file #Holds data pulled from shipofharkinian.json file after being loaded.
var opened_dialog = false
var dia_ref #unintiated reference to the popup dialog box that is used when selecting files/folders
var soh_folder = ""

func _ready():
	load_app_data()

func toggle_main_view(state : bool):
	$L_window_BG.visible = state
	$R_window_BG.visible = state
	$Load_order.visible = state
	$Mod_list.visible = state
	$Left_window.visible = state
	$Middle_window.visible = state
	$Right_window.visible = state
	$msg_label.visible = state

func toggle_tag_view(state : bool):
	$tag_group_view_subwindow.visible = state

func populate_list(entry : String, container : Node, group_name : String):
	#Populates a given field with entry_button nodes representing a .otr file
	var new_instance = entry_button_file.instance()
	new_instance.add_to_group(group_name)
	new_instance.set_text(entry)
	new_instance.mod_file_path = entry
	$tag_group_view_subwindow.add_to_mods_list(entry)
	new_instance.toggle_dir_buttons(false)
	container.add_child(new_instance)
	if group_name == "L-side":
		new_instance.toggle_dir_buttons(true)

func save_app_data(stored_folder : String) -> void:
	#Saves SoH config path, and state of the 3D background to file.
	var save_game = File.new()
	var packed_data = [stored_folder, $"3D_scene_holder".current_state]
	save_game.open("user://shipdeckconfig.sav", save_game.WRITE)
	save_game.store_var(packed_data, true)
	save_game.close()
	
func load_app_data() -> void:
	#Loads SoH config path, and state of the 3D background from file, then attempts to reapply that data
	var load_game = File.new()
	if load_game.file_exists("user://shipdeckconfig.sav"):
		load_game.open("user://shipdeckconfig.sav", load_game.READ)
		var packed_data = load_game.get_var(true)
		if packed_data.size() == 2:
			if packed_data[0].length() > 0:
				setup_lists(packed_data[0])
			if packed_data[1] == $"3D_scene_holder".states.ON:
				$"3D_scene_holder"._on_CheckButton_pressed()
				$"3D_scene_holder".button_toggle()
		load_game.close()

func external_app_save_trigger():
	#Called when a external node triggers a app data save.
	save_app_data(soh_folder)

func handle_offset() -> void:
	#Handles spacing between items in lists.
	var side_groups = ["R-side", "L-side"]
	for group in side_groups:
		var iter_count = 1
		for nodes in get_tree().get_nodes_in_group(group):
			nodes.rect_position.y = offset_value * iter_count
			iter_count += 1
			nodes.get_parent().rect_min_size.y = offset_value * iter_count

func swap_sides(obj_ref : Node) -> void:
	#This is called from the entry_button node via the "Pressed" signal, obj_ref is the sender of the signal
	#This may also be called from the clear load order option to return mods to the folder list if they were pulled from it.
	if obj_ref.is_in_group("L-side"):
		obj_ref.remove_from_group("L-side")
		obj_ref.get_parent().remove_child(obj_ref)
		R_window.add_child(obj_ref)
		obj_ref.add_to_group("R-side")
		obj_ref.toggle_dir_buttons(false)
	elif obj_ref.is_in_group("R-side"):
		obj_ref.remove_from_group("R-side")
		obj_ref.get_parent().remove_child(obj_ref)
		L_window.add_child(obj_ref)
		obj_ref.add_to_group("L-side")
		obj_ref.toggle_dir_buttons(true)
	handle_offset()
	check_if_can_save()

func save_mod_list() -> void:
	#Saves mod list to the .json file
	var stored_data = {}
	var iter_count = 1
	if loaded_json_file.has("Mod-Load-Order"):
		loaded_json_file.erase("Mod-Load-Order")
	for nodes in get_tree().get_nodes_in_group("L-side"):
		stored_data.merge({iter_count : nodes.mod_file_path})
		iter_count += 1
	if iter_count > 0:
		var file_path = soh_folder + "/" + "shipofharkinian.json"
		stored_data.merge({"List-size" : iter_count - 1})
		loaded_json_file.merge({"Mod-Load-Order" : stored_data})
		var file = File.new()
		file.open(file_path, file.WRITE)
		file.store_line(to_json(loaded_json_file))
		file.close()
		$msg_label.display_text("shipofharkinian.json entries added!")
		opened_dialog = false
		save_app_data(soh_folder)

func purge_mod_entries() -> void:
	#Called if Load Order is empty, will delete the "Mod-Load-Order" entry from the .json file
	if loaded_json_file.has("Mod-Load-Order"):
		loaded_json_file.erase("Mod-Load-Order")
		var file_path = soh_folder + "/" + "shipofharkinian.json"
		var file = File.new()
		file.open(file_path, file.WRITE)
		file.store_line(to_json(loaded_json_file))
		file.close()
		$msg_label.display_text("shipofharkinian.json entries removed!")
		opened_dialog = false

func read_json_file() -> void:
	#parses existing shipofharkinian.json file if it exists.
	var dir =  Directory.new()
	if dir.file_exists(soh_folder + "/shipofharkinian.json") == true:
		var file = File.new()
		file.open(soh_folder + "/shipofharkinian.json", File.READ)
		loaded_json_file = JSON.parse(file.get_as_text()).result
		file.close()
		check_if_mods_is_on_list()

func check_if_mods_is_on_list() -> void:
	#When loading the .json file, it will read through it and add mods already in the load order in the file to the
	#Load order list in the application
	if loaded_json_file.has("Mod-Load-Order"):
		if loaded_json_file.get("Mod-Load-Order").has("List-size"):
			var mod_count = loaded_json_file.get("Mod-Load-Order").get("List-size")
			var iter_count = 1
			while iter_count <= mod_count:
				if loaded_json_file.get("Mod-Load-Order").has(str(iter_count)):
					var found_mod = loaded_json_file.get("Mod-Load-Order").get(str(iter_count))
					populate_list(found_mod, L_window, "L-side")
					handle_offset()
				iter_count += 1


func find_soh_config(path : String) -> bool:
	#Checks if it can find the .json config file
	var config_file_name = "/shipofharkinian.json"
	var file = File.new()
	if file.file_exists(path + config_file_name) == true:
			return true
	return false
	
func clear_selection(group : String) -> void:
	for nodes in get_tree().get_nodes_in_group(group):
		nodes.queue_free()

func check_if_can_save() -> void:
	#Prevents clearing list when empty, and saving when no soh_path is found
	if L_window.get_child_count() != 0:
		$Middle_window/VBoxContainer/clear_load_list.disabled = false
	else:
		$Middle_window/VBoxContainer/clear_load_list.disabled = true
	
	if soh_folder != "":
		$Middle_window/VBoxContainer/save_list.disabled = false
	else:
		$Middle_window/VBoxContainer/save_list.disabled = true

func check_if_on_list(file_name : String, group : String) -> bool:
	#Checks to see if a element is already on the a list, if so it will not be added on the other list
	for nodes in get_tree().get_nodes_in_group(group):
		if nodes.get_text() == file_name:
			return true
	return false

func setup_lists(path : String) -> void:
	#Called either when loading a folder, or when loading from stored folder path when loaded.
	var dir = Directory.new()
	if find_soh_config(path) == true:
		soh_folder = path
		clear_selection("R-side")
		clear_selection("L-side")
		yield(get_tree().create_timer(0.5), "timeout")
		read_json_file()
		$soh_path.bbcode_text = "[center]     Ship of Harknian folder path:\n " + soh_folder + "[/center]"
		if dir.open(soh_folder + "/mods") == OK:
			$tag_group_view_subwindow.clear_mods_list()
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".otr"):
					if check_if_on_list(file_name, "L-side") == false:
						populate_list(file_name, R_window, "R-side")
						handle_offset()
				file_name = dir.get_next()
			check_if_can_save()
			save_app_data(path)
			$msg_label.display_text("shipofharkinian.json file found!")
	else:
		$msg_label.display_text("Folder selected does not contain shipofharknian.json file.")

func on_soh_folder_select(opened_path : String) -> void:
	#Opens dialog to select folder containing shipofharkinian.json file.
	dia_ref.queue_free()
	opened_dialog = false
	setup_lists(opened_path)

func on_dialog_close() -> void:
	#In the event the player closes a dialog box, frees it then allows the player to spawn more.
	dia_ref.queue_free()
	opened_dialog = false

func _on_save_list_pressed() -> void:
	#Button to start either Adding/editing entries for mod load order, or removing it.
	if soh_folder != "":
		if L_window.get_child_count() != 0:
			save_mod_list()
		else:
			purge_mod_entries()
	else:
		$msg_label.display_text("Please select a SoH folder first.")

func _on_clear_load_list_pressed() -> void:
	#Empties Load order list and repopulatates the Mods list
	for nodes in get_tree().get_nodes_in_group("L-side"):
		swap_sides(nodes)

func _on_soh_folder_pressed() -> void:
	#File dialog for selecting SoH config path
	if opened_dialog == false:
		opened_dialog = true
		var dialog = FileDialog.new()
		dialog.mode = FileDialog.MODE_OPEN_DIR
		dialog.access = FileDialog.ACCESS_FILESYSTEM
		dialog.connect("dir_selected", self, "on_soh_folder_select")
		dialog.connect("popup_hide", self, "on_dialog_close")
		self.add_child(dialog)
		dia_ref = dialog
		dialog.popup(Rect2(0, 0, 700, 500))

func _on_Get_Mods_pressed() -> void:
	#Opens the Gamebanana page on the users default web browser.
	# warning-ignore:return_value_discarded
	OS.shell_open("https://gamebanana.com/games/16121")

func _on_Manage_tags_pressed():
	toggle_main_view(false)
	toggle_tag_view(true)
