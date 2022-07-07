extends Node2D

var board_navigator = AStar2D.new()
var board_size = Vector2(8,5)

func generate_board(b_size=null):
	if b_size :
		board_size =  b_size
	for j in board_size.y:
		for i in board_size.x:
			board_navigator.add_point(i+j*board_size.x,Vector2(i,j))
	for j in board_size.y: 
		for i in board_size.x:
			if i != board_size.x-1 :
				board_navigator.connect_points(i+j*board_size.x,i+1+j*board_size.x)
			if j != board_size.y-1 :
				board_navigator.connect_points(i+j*board_size.x,i+(1+j)*board_size.x)
	
func switch_points(points,set_disabled = true) :
	for i in points.size() :
		board_navigator.set_point_disabled(points[i].x+points[i].y*board_size.x,set_disabled)
		
			
func check_point(cell):
	return !board_navigator.is_point_disabled(cell.x+cell.y*board_size.x)


func finde_path(cell_1 =Vector2(0,0),cell_2=Vector2(0,0)) :
	var cell_1_ID = board_size.x*cell_1.y+cell_1.x
	var cell_2_ID = board_size.x*cell_2.y+cell_2.x
#по умолчанию обе точки отрублены так так как мы ищем путь от игрока к игроку 
#точка 1 всегда отрублена, но вторая не всегда так как мы можем идти к пустой 
#клетке, проверим это и запомним чтоб в конце не закрыть ее 
	var cell_2_ID_disabled = board_navigator.is_point_disabled(cell_2_ID)
	board_navigator.set_point_disabled(cell_2_ID,false)
	board_navigator.set_point_disabled(cell_1_ID,false)
	var point_path = board_navigator.get_point_path(cell_1_ID,cell_2_ID)
#если точка изначально занята значит нужен путь не на нее а подойти к ней вплотную 
	if cell_2_ID_disabled :
		board_navigator.set_point_disabled(cell_2_ID,true)
		point_path.remove(point_path.size()-1)
	var final_point = point_path[point_path.size()-1].x + point_path[point_path.size()-1].y*board_size.x	
	board_navigator.set_point_disabled(final_point,true)	
	var offset_path = []
	if point_path.size() < 2 :
		return offset_path
	var step_point =  point_path[0]
	point_path.remove(0)	
	for i in point_path.size() :
		offset_path.append(point_path[i]-step_point)
		step_point = point_path[i]
#	
	return offset_path
	
func path_length(cell_1 =Vector2(0,0),cell_2=Vector2(0,0)) :
	var cell_1_ID = board_size.x*cell_1.y+cell_1.x
	var cell_2_ID = board_size.x*cell_2.y+cell_2.x
#по умолчанию обе точки отрублены так так как мы ищем путь от игрока к игроку 
#точка 1 всегда отрублена, но вторая не всегда так как мы можем идти к пустой 
#клетке, проверим это и запомним чтоб в конце не закрыть ее 
	var cell_2_ID_disabled = board_navigator.is_point_disabled(cell_2_ID)
	var cell_1_ID_disabled = board_navigator.is_point_disabled(cell_1_ID)
	board_navigator.set_point_disabled(cell_2_ID,false)
	board_navigator.set_point_disabled(cell_1_ID,false)
	var point_path = board_navigator.get_point_path(cell_1_ID,cell_2_ID)
#если точка изначально занята значит нужен путь не на нее а подойти к ней вплотную 
	if cell_2_ID_disabled :
		board_navigator.set_point_disabled(cell_2_ID,true)
		point_path.remove(point_path.size()-1)
	if cell_1_ID_disabled :
		board_navigator.set_point_disabled(cell_1_ID,true)
		
	return max(point_path.size() -1,0)

func finde_N_point_of_path(cell_1 =Vector2(0,0),cell_2=Vector2(0,0),n_point=0) :
	var cell_1_ID = board_size.x*cell_1.y+cell_1.x
	var cell_2_ID = board_size.x*cell_2.y+cell_2.x
#по умолчанию обе точки отрублены так так как мы ищем путь от игрока к игроку 
#точка 1 всегда отрублена, но вторая не всегда так как мы можем идти к пустой 
#клетке, проверим это и запомним чтоб в конце не закрыть ее 
	var cell_2_ID_disabled = board_navigator.is_point_disabled(cell_2_ID)
	board_navigator.set_point_disabled(cell_2_ID,false)
	board_navigator.set_point_disabled(cell_1_ID,false)
	var point_path = board_navigator.get_point_path(cell_1_ID,cell_2_ID)
#если точка изначально занята значит нужен путь не на нее а подойти к ней вплотную 
	if cell_2_ID_disabled :
		board_navigator.set_point_disabled(cell_2_ID,true)
		point_path.remove(point_path.size()-1)
#мы посчитали путь, теперь надо сравнить его длину с длинной которую надо пройти и если он больше уменьшить его  
	var path_diff =	max(point_path.size() - 1 - n_point,0)
	for i in path_diff :
		if point_path.size()>0 :
			point_path.remove(point_path.size()-1)
	var final_point = point_path[point_path.size()-1].x + point_path[point_path.size()-1].y*board_size.x	
	board_navigator.set_point_disabled(final_point,true)	
	var offset_path = []
	if point_path.size() < 2 :
		return offset_path
	var step_point =  point_path[0]
	point_path.remove(0)	
	for i in point_path.size() :
		offset_path.append(point_path[i]-step_point)
		step_point = point_path[i]
#	
	return offset_path

func _ready():
	pass 

