extends Control
enum places {HAND,DECK,BOARD}
enum condition {CHOOS,TARGET,DEAD}
var board_step = 64
var current_cell = Vector2(1,0)
var place = places.BOARD  
var moove_speed = 1.7 # клеток в секудну при перемещении
var board_ID = 0
var status = "ninja" 
signal ninja_selected(ninja)
signal ninja_deselected(ninja)

func _ready():
	select(Color(0,0,0,0))
#	complete_steps([Vector2(1,0),Vector2(1,1),Vector2(0,1)])


func select(_color) :
	match place:
		places.BOARD :
			$TextureRect.rect_size = Vector2(board_step,board_step)
			$TextureRect.rect_position = Vector2(0,0)
			$TextureRect.material.set_shader_param("frame_color",_color)

func complete_steps(steps):
	$Tween.move_ninja(steps)
	
func show_ability(ability=0):
	pass
func aim_field_square(square=-1):
	pass
func select_field_cell(square=-1):
	pass
func choose_ability(ability=0):
	pass
func use_ability(square=-1,ability=0):
	pass





func _on_TextureRect_gui_input(event):
	if event.is_action_released("ui_select") :
		emit_signal("ninja_selected",self)
	if event.is_action_released("ui_cancel") :
		emit_signal("ninja_deselected",self)
#	emit_signal("ninja_dead",self)
	pass # Replace with function body.


func _on_Tween_move_ended():
	get_parent().get_parent().auto_player()
	pass # Replace with function body.
