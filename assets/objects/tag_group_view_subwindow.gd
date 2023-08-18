extends Node2D

enum modes{TAG, GROUP}
const offset_value = 32
var current_mods_list = []
var group_tag_list = {
		"tags" : {
	},
		"groups" : {
	},
}
onready var containers = [$L_list/Container, $R_list/Container]
onready var tag_button_file = load("res://assets/objects/tag_button.tscn")
onready var group_button_file = load("res://assets/objects/group_button.tscn")

func _ready():
	read_json_data()

func clear_mods_list():
	current_mods_list = []

func clear_group_list():
	group_tag_list.clear()
	group_tag_list = {
		"tags" : {
	},
		"groups" : {
	},
}

func add_to_mods_list(entry : String):
	current_mods_list.append(entry)

func populate_list(mode, container : Node, entry : String):
	var new_instance
	match mode:
		modes.TAG:
			new_instance = tag_button_file.instance()
			new_instance.add_to_group("L-side-sub")
		modes.GROUP:
			new_instance = group_button_file.instance()
			new_instance.add_to_group("R-side-sub")
	new_instance.set_text(entry)
	container.add_child(new_instance)
	handle_offset()

func handle_offset() -> void:
	#Handles spacing between items in lists.
	var side_groups = ["R-side-sub", "L-side-sub"]
	for group in side_groups:
		var iter_count = 1
		for nodes in get_tree().get_nodes_in_group(group):
			nodes.rect_position.y = offset_value * iter_count
			iter_count += 1
			nodes.get_parent().rect_min_size.y = offset_value * iter_count

func otr_tag_group_editor_toggle(caller, sent_mode):
	toggle_items_view(false)
	$Tag_group_editor.start_edit(sent_mode, caller)

func save_json_data() -> void:
	#Saves group_tag_data.json.
	var save_game = File.new()
	save_game.open("user://group_tag_data.json", save_game.WRITE)
	save_game.store_line(to_json(group_tag_list))
	save_game.close()
	get_parent().send_msg("Saved Tag/Group data!")
	
func read_json_data() -> void:
	#parses existing group_tag_data.json file if it exists.
	var dir =  Directory.new()
	if dir.file_exists("user://group_tag_data.json") == true:
		#clear_group_list()
		var file = File.new()
		file.open("user://group_tag_data.json", File.READ)
		var loaded_list = JSON.parse(file.get_as_text()).result
		for entry in loaded_list["tags"].keys():
			add_entry(entry, modes.TAG, true)
		for entry in loaded_list["groups"].keys():
			add_entry(entry, modes.GROUP, true)
		group_tag_list.merge(loaded_list, true)
		file.close()

func start_delay(text, type):
	$delay_timer.start()
	match type:
		modes.TAG:
			group_tag_list["tags"].erase(str(text))
		modes.GROUP:
			group_tag_list["groups"].erase(str(text))

func toggle_items_view(state : bool):
	$L_window_BG.visible = state
	$R_window_BG.visible = state
	$R_list.visible = state
	$L_list.visible = state
	$tag_options_container.visible = state
	$group_options_container.visible = state
	$return_to_main_menu.visible = state
	$save_to_json.visible = state

func toggle_name_entry(sel_mode):
	toggle_items_view(false)
	$name_entry/TextEdit.make_active(sel_mode)

func add_entry(entry, sel_mode, on_load):
	match sel_mode:
		modes.TAG:
			if group_tag_list["tags"].has(entry) == false:
				if on_load == false:
					group_tag_list["tags"].merge({str(entry) : {}}, false)
				populate_list(sel_mode, containers[0], entry)
		modes.GROUP:
			if group_tag_list["tags"].has(entry) == false:
				if on_load == false:
					group_tag_list["groups"].merge({str(entry) : {}}, false)
				populate_list(sel_mode, containers[1], entry)
	toggle_items_view(true)

func store_sub_entry(main_dir, entry, sub_entry):
	group_tag_list[str(main_dir)][str(entry)].merge(sub_entry, false)
	print(group_tag_list[str(main_dir)][str(entry)])

func _on_return_to_main_menu_pressed():
	get_parent().toggle_tag_view(false)
	get_parent().toggle_main_view(true)

func _on_add_tag_pressed():
	toggle_name_entry(modes.TAG)

func _on_add_group_pressed():
	$delay_timer.stop()
	toggle_name_entry(modes.GROUP)

func _on_delay_timer_timeout():
	handle_offset()

func _on_save_to_json_pressed():
	save_json_data()
