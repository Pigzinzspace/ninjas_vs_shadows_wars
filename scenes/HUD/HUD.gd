extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TextureRect_gui_input(event):
	if event.is_action_released("ui_select") :
		if $log/RichTextLabel.visible :
			$log/RichTextLabel.visible = false
			$log/TextureRect.texture.region = Rect2(64,0,64,64)
		else :
			$log/RichTextLabel.visible = true
			$log/TextureRect.texture.region = Rect2(0,0,64,64)
		
	



