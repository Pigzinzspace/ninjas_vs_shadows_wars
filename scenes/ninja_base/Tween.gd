extends Tween
var steps =[]
var step = -1
var ninja 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal move_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	ninja = $".."
	pass # Replace with function body.

func move_ninja(init_steps=[]) :
	if init_steps != [] :
		steps = init_steps
		step = 0
	if step >= steps.size() or step == -1:
		steps = []
		step = -1
		emit_signal("move_ended")
		return
	var final_position = ninja.rect_position + steps[step]*ninja.board_step
	ninja.current_cell += steps[step]
	interpolate_property(ninja, "rect_position", ninja.rect_position, final_position, 1/ ninja.moove_speed, TRANS_ELASTIC, EASE_IN)

	step += 1
	start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_all_completed():
	pass # Replace with function body.
	move_ninja()
