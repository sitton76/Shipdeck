extends Spatial

const moving_scene_files = preload("res://assets/objects/3D_ship_obj.tscn")
enum states{OFF, ON}
var current_state = states.OFF
var current_3D_scene

func button_toggle() -> void:
	$CheckButton.pressed = true

func _on_CheckButton_pressed() -> void:
	match current_state:
		states.OFF:
			$ShipImage.hide()
			var new_instance = moving_scene_files.instance()
			self.add_child(new_instance)
			current_3D_scene = new_instance
			current_state = states.ON
			get_parent().external_app_save_trigger()
		states.ON:
			current_state = states.OFF
			current_3D_scene.queue_free()
			$ShipImage.show()
			current_state = states.OFF
			get_parent().external_app_save_trigger()
