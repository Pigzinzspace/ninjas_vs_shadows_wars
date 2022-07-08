extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func stretch_animftion(direction,frame):
	$sprite1.frame=frame
	$sprite1.rotation =direction.angle()+PI/2
	$sprite1.material.set_shader_param("frame_color",Color(randf(),randf(),randf(),1))
	$sprite1.material.set_shader_param("frame_color",Color(1,1,0,1))
	var final_position = direction
#	var final_scale = Vector2(1,direction.length()/64)
	$Tween.interpolate_property($sprite1, "position", $sprite1.position, final_position, 1, Tween.TRANS_ELASTIC, Tween.EASE_IN)
#	$Tween.interpolate_property($sprite1, "scale", $sprite1.scale, final_scale, 1, Tween.TRANS_ELASTIC, Tween.EASE_IN)
	$Tween.start()
	pass
	
func move_animation(disrction,frame):
	pass
# растянуть, до точки, переместить до точки


func _on_Tween_tween_all_completed():
	$"..".auto_player()
	$".".queue_free()
	pass # Replace with function body.
