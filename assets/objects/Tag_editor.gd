extends Node2D

var current_mode = null
var working_obj = null
var list = null
const offset_value = 32
onready var otr_sel_file = load("res://assets/objects/otr_sel_button.tscn")

func start_edit(sel_mode, obj):
	working_obj = obj
	current_mode = sel_mode
	var main_group
	match current_mode:
		0:
			main_group = "tags"
		1:
			main_group = "groups"
	for entry in get_parent().current_mods_list:
		var found_in_list = false
		if get_parent().group_tag_list[main_group].has(str(obj.entry)):
			list = get_parent().group_tag_list[main_group][str(obj.entry)]
			for listing in list.keys():
				if get_parent().group_tag_list[main_group][str(obj.entry)][listing] == entry:
					populate_list($R_list/Container, "R_OTR", entry)
					found_in_list = true
					break
		if found_in_list == false:
			populate_list($L_list/Container, "L_OTR", entry)
	handle_offset()
	self.show()

func swap_sides(obj_ref : Node) -> void:
	#This is called from the entry_button node via the "Pressed" signal, obj_ref is the sender of the signal
	#This may also be called from the clear load order option to return mods to the folder list if they were pulled from it.
	if obj_ref.is_in_group("L_OTR"):
		obj_ref.remove_from_group("L_OTR")
		obj_ref.get_parent().remove_child(obj_ref)
		$R_list/Container.add_child(obj_ref)
		obj_ref.add_to_group("R_OTR")
	elif obj_ref.is_in_group("R_OTR"):
		obj_ref.remove_from_group("R_OTR")
		obj_ref.get_parent().remove_child(obj_ref)
		$L_list/Container.add_child(obj_ref)
		obj_ref.add_to_group("L_OTR")
	handle_offset()

func handle_offset() -> void:
	#Handles spacing between items in lists.
	var side_groups = ["R_OTR", "L_OTR"]
	for group in side_groups:
		var iter_count = 1
		for nodes in get_tree().get_nodes_in_group(group):
			nodes.rect_position.y = offset_value * iter_count
			iter_count += 1
			nodes.get_parent().rect_min_size.y = offset_value * iter_count

func populate_list(obj, side_Godot_group, entry):
	var new_instance = otr_sel_file.instance()
	new_instance.add_to_group(side_Godot_group)
	new_instance.set_text(entry)
	obj.add_child(new_instance)

func construct_dic() -> Dictionary:
	var sent_list = {}
	var iter_count = 0
	for nodes in get_tree().get_nodes_in_group("R_OTR"):
		sent_list.merge({str(iter_count) : nodes.entry})
		iter_count += 1
	return sent_list

func end_edit():
	self.hide()
	current_mode = null
	working_obj = null
	get_parent().toggle_items_view(true)

func _on_Accept_pressed():
	end_edit()

func _on_save_list_pressed():
	match current_mode:
		0:
			get_parent().group_tag_list["tags"].erase(str(working_obj.entry))
			get_parent().group_tag_list["tags"].merge({str(working_obj.entry) : construct_dic()})
			get_tree().current_scene.send_msg("Tag entry updated")
		1:
			get_parent().group_tag_list["groups"].erase(str(working_obj.entry))
			get_parent().group_tag_list["groups"].merge({str(working_obj.entry) : construct_dic()})

			get_tree().current_scene.send_msg("Group entry updated")
	for nodes in get_tree().get_nodes_in_group("R_OTR"):
		nodes.queue_free()
	for nodes in get_tree().get_nodes_in_group("L_OTR"):
		nodes.queue_free()
	end_edit()
