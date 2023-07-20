extends RichTextLabel

func display_text(sent_text : String):
	self.bbcode_text = "[center]" + sent_text + "[/center]"
	$AnimationPlayer.play("fade")
	
func clear():
	self.bbcode_text = ""
