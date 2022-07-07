
extends TextureRect

onready var ninja_class = preload("res://scenes/ninja_base/ninja_base.tscn")
onready var my_hud = preload("res://scenes/HUD/HUD.tscn").instance() 
onready var a_star = preload("res://scenes/a_star/a_star.tscn").instance() 
var sint_colors = {
	0 : Color(1,0,1,1),
	1 : Color(0,1,1,1),
	2 : Color(1,1,0,1)
}
var board_size = Vector2(12,6)
var board_step = 64
var board_offset = Vector2(64,64)
var target = null
var attacker = null
var move_target = null
var target_ability = null
var ninjas = {}
var occupied_cell = [] #только для генерации карты
var player_turn = true
enum ability {HOLD=0,SPEED=1,GUARD=2,SURIKEN=3,KHUNAI=4,FIST=5,SWORD=6,BOMB=7,WHIP=8,HIKICK=9,BOW=10,SPEAR=11,HEALTH=12,
#cпособности теней
SHADOW_KICK=13,SHADOW_FIST=14,SHADOW_SUCK=15,SHADOW_SUMMOM=16,SHADOW_RESPOWN=17,SHADOW_BOOM=18,SHADOW_SURIKEN=19}

enum ability_param {DISTANCE,DAMAGE,CALL,POINTS}
var ability_stats = {
	ability.HOLD : {
		ability_param.DISTANCE : -1,
		ability_param.DAMAGE : 0,
		ability_param.POINTS : -1,
		ability_param.CALL : "hold"
	},
	ability.FIST : {
		ability_param.DISTANCE : 1,
		ability_param.DAMAGE : 3,
		ability_param.POINTS : 2,
		ability_param.CALL : ""
	},
	ability.SURIKEN : {
		ability_param.DISTANCE : 3,
		ability_param.DAMAGE : 1,
		ability_param.POINTS : 2,
		ability_param.CALL : ""
	},
	ability.SPEED : {
		ability_param.DISTANCE : -1,
		ability_param.DAMAGE : 0,
		ability_param.POINTS : -1,
		ability_param.CALL : "move_to_target"
	},
	ability.KHUNAI : {
		ability_param.DISTANCE : 4,
		ability_param.DAMAGE : 3,
		ability_param.POINTS : 5,
		ability_param.CALL : ""
	},
	ability.SWORD : {
		ability_param.DISTANCE : 1,
		ability_param.DAMAGE : 6,
		ability_param.POINTS : 8,
		ability_param.CALL : ""
	},
	ability.SPEAR : {
		ability_param.DISTANCE : 2,
		ability_param.DAMAGE : 6,
		ability_param.POINTS : 9,
		ability_param.CALL : ""
	},
	ability.BOMB : {
		ability_param.DISTANCE : 5,
		ability_param.DAMAGE : 6,
		ability_param.POINTS : -1,
		ability_param.CALL : "use_bomb"
	},
	ability.BOW : {
		ability_param.DISTANCE : 6,
		ability_param.DAMAGE : 3,
		ability_param.POINTS : 7,
		ability_param.CALL : ""
	},
	ability.WHIP : {
		ability_param.DISTANCE : 3,
		ability_param.DAMAGE : 1,
		ability_param.POINTS : 2,
		ability_param.CALL : ""
	},
	ability.HEALTH : {
		ability_param.DISTANCE : -1,
		ability_param.DAMAGE : 1,
		ability_param.POINTS : 6,
		ability_param.CALL : "health"
	},
	ability.GUARD : {
		ability_param.DISTANCE : 1,
		ability_param.DAMAGE : 0,
		ability_param.POINTS : 2,
		ability_param.CALL : ""
	},
	ability.HIKICK : {
		ability_param.DISTANCE : 1,
		ability_param.DAMAGE : 4,
		ability_param.POINTS : 3,
		ability_param.CALL : ""
	}
	
#параметры теней
	,
	ability.SHADOW_FIST : {
		ability_param.DISTANCE : 1,
		ability_param.DAMAGE : 2,
		ability_param.POINTS : 2,
		ability_param.CALL : ""
	},
	ability.SHADOW_KICK : {
		ability_param.DISTANCE : 1,
		ability_param.DAMAGE : 5,
		ability_param.POINTS : 7,
		ability_param.CALL : ""
	},
	ability.SHADOW_RESPOWN : {
		ability_param.DISTANCE : -1,
		ability_param.DAMAGE : 0,
		ability_param.POINTS : -1,
		ability_param.CALL : ""
	},
	ability.SHADOW_SUCK : {
		ability_param.DISTANCE : 4,
		ability_param.DAMAGE : 5,
		ability_param.POINTS : 3,
		ability_param.CALL : ""
	},
	ability.SHADOW_SURIKEN : {
		ability_param.DISTANCE : 4,
		ability_param.DAMAGE : 3,
		ability_param.POINTS : 4,
		ability_param.CALL : ""
	},
	ability.SHADOW_SUMMOM : {
		ability_param.DISTANCE : 8,
		ability_param.DAMAGE : 0,
		ability_param.POINTS : 6,
		ability_param.CALL : ""
	},
	ability.SHADOW_BOOM : {
		ability_param.DISTANCE : -1,
		ability_param.DAMAGE : 0,
		ability_param.POINTS : -1,
		ability_param.CALL : ""
	}
	
	
}
var ninjas_stats = {
	0 : {
		ability.HOLD : 1.5,
		ability.SPEED : 2.1,
		ability.KHUNAI : 1.0,
		ability.FIST : 2.3,
		ability.SURIKEN : 1.0,
		"hp" : 6,
		"points" : 6
	},
	1 : {
		ability.HOLD : 1.5,
		ability.SPEED : 2.1,
		ability.BOMB : 1.0,
		ability.FIST : 2.3,
		ability.SURIKEN : 1.0,
		"hp" : 6,
		"points" : 6
	},
	2 : {
		ability.SWORD : 1.5,
		ability.SPEED : 2.1,
		ability.GUARD : 1.0,
		ability.FIST : 2.3,
		ability.HOLD : 1.0,
		"hp" : 6,
		"points" : 6
	}
}
var ability_atlas =  preload("res://scenes/board/sprite/ability-Sheet.png")
var ability_menu_ids = {}
var ability_atlas_texture = AtlasTexture.new()
var player_stats = {
	ability.HOLD: 0.0,
	ability.SPEED:0.0,
	ability.GUARD:0.0,
	ability.SURIKEN:0.0,
	ability.KHUNAI:0.0,
	ability.FIST:0.0,
	ability.SWORD:0.0,
	ability.BOMB:0.0,
	ability.WHIP:0.0,
	ability.HIKICK:0.0,
	ability.BOW:0.0,
	ability.SPEAR:0.0,
	ability.HEALTH:0.0
 }
var shadows_stats = {
	ability.SPEED : 0.0,
	ability.SHADOW_KICK:0.0,
	ability.SHADOW_FIST:0.0,
	ability.SHADOW_SUCK:0.0,
	ability.SHADOW_SUMMOM:0.0,
	ability.SHADOW_RESPOWN:0.0,
	ability.SHADOW_BOOM:0.0,
	ability.SHADOW_SURIKEN:0.0
}
# эти 2 массива нужны чтоб быстро выбирать случайные скилы при генерации 
# у нидзей есть 2 фист и спид, у теней шадов_фист и спид они добавляются всегда, - их тут нет 
var rnd_player_keys = [
	ability.HOLD,
	ability.GUARD,
	ability.SURIKEN,
	ability.KHUNAI,
	ability.SWORD,
	ability.BOMB,
	ability.WHIP,
	ability.HIKICK,
	ability.BOW,
	ability.SPEAR,
	ability.HEALTH
	]
var rnd_shadows_keys = [
	ability.SHADOW_KICK,
	ability.SHADOW_SUCK,
	ability.SHADOW_SUMMOM,
	ability.SHADOW_RESPOWN,
	ability.SHADOW_BOOM,
	ability.SHADOW_SURIKEN
	]
var game_info = {
	"turn" : 0,
	"turn_queue" : [],
	"game_status" : "demo",
	"shadows" : 5,
	"ninja" : 5,
	"speed" : 3
	}

var monitor = {
	"auto_play": 0,
	"attack_on_target" : 0,
	"ai_1": 0
	}	
	
func _ready():
	ability_atlas_texture.atlas = ability_atlas
	ninjas_stats = {}
	randomize()
	var screen_size = get_viewport_rect().size
	board_offset = (screen_size - board_size*board_step)/2
	board_offset = Vector2(int(board_offset.x),int(board_offset.y))
	for i in 5 :
		$YSort.add_child(load_ninja())	
		$YSort.add_child(load_shadow())
	add_child(my_hud)
	
	a_star.board_size = board_size 
	a_star.generate_board()
	var ninjas_points = []
	for i in ninjas.keys() :
		ninjas_points.append(ninjas[i].current_cell)
		
	a_star.switch_points(ninjas_points)
	var ninjas_keys = ninjas.keys()
	ninjas_keys.shuffle()
	game_info["turn_queue"] = ninjas_keys
	
	auto_player()
	

	

func load_ninja() :
	var ninja1 = ninja_class.instance()
	ninja1.board_step = board_step
	while true :
		ninja1.current_cell = Vector2(randi()%int(board_size.x/2),randi()%int(board_size.y))
		if !(ninja1.current_cell in occupied_cell) :
			occupied_cell.append(ninja1.current_cell)
			break 
	
	ninja1.rect_position = board_offset+board_step*ninja1.current_cell
	ninja1.status = "ninja"
	ninja1.board_ID = ninjas.size()
	ninjas[ninja1.board_ID] = ninja1
	ninja1.get_node("shadow_eyes").frame = 0
	var ninja_pix = ninja1.get_node("icon_sprite")
	ninja_pix.animation = "ninja"
	ninja_pix.frame = randi()%3
	ninja1.connect("ninja_selected",self,"on_ninja_selected")
	ninja1.connect("ninja_selected",self,"on_ninja_deselected")
#нам осталось сгенерировать и привязать скилы бег и удар рукой есть у всех 
	var p_summ = 0.0
	for i in 13 :
		p_summ += player_stats[player_stats.keys()[i]]
	var skills_number = int(p_summ+randi()%3)
	ninjas_stats[ninja1.board_ID] ={}
	ninjas_stats[ninja1.board_ID][ability.FIST] = player_stats[ability.FIST] 
	ninjas_stats[ninja1.board_ID][ability.SPEED] = player_stats[ability.SPEED]
# шанс докинуть еще скилов
	for i in skills_number :
		var ability_skill_key = rnd_player_keys[randi()%11]
		ninjas_stats[ninja1.board_ID][ability_skill_key] = player_stats[ability_skill_key]
	
	var ninja_hp = randi()%4+randi()%4+randi()%4 
	if ninjas_stats[ninja1.board_ID].has(ability.HEALTH) :
		ninja_hp+=6* player_stats[ability.HEALTH]
	else :
		ninja_hp+=2* player_stats[ability.HEALTH]
	ninjas_stats[ninja1.board_ID]["hp"] = ninja_hp
	 
	var ninja_points = randi()%4+randi()%4+randi()%4 + randi()%4 
	if ninjas_stats[ninja1.board_ID].has(ability.SPEED) :
		ninja_points+=4* player_stats[ability.SPEED]
	else :
		ninja_points+=2* player_stats[ability.SPEED]
	ninjas_stats[ninja1.board_ID]["points"] = ninja_points
	return ninja1 

func load_shadow() :
	var ninja1 = ninja_class.instance()
	ninja1.board_step = board_step
	while true :
		ninja1.current_cell = Vector2(randi()%int(board_size.x/2)+int(board_size.x/2),randi()%int(board_size.y))
		if !(ninja1.current_cell in occupied_cell) :
			occupied_cell.append(ninja1.current_cell)
			break 
	
	ninja1.rect_position = board_offset+board_step*ninja1.current_cell
	ninja1.status = "shadow"
	ninja1.board_ID = ninjas.size()
	ninjas[ninja1.board_ID] = ninja1
	ninja1.get_node("shadow_eyes").frame = randi()%4
	var ninja_pix = ninja1.get_node("icon_sprite")
	ninja_pix.animation = "shadow"
	ninja_pix.frame = randi()%6
	ninja1.connect("ninja_selected",self,"on_ninja_selected")
	ninja1.connect("ninja_selected",self,"on_ninja_deselected")
#нам осталось сгенерировать и привязать скилы бег и удар рукой есть у всех 
	var p_summ = 0.0
	for i in 7 :
		p_summ += shadows_stats[shadows_stats.keys()[i]]
	var skills_number = randi()%int(2+p_summ)
	ninjas_stats[ninja1.board_ID] ={}
	ninjas_stats[ninja1.board_ID][ability.SHADOW_FIST] = shadows_stats[ability.SHADOW_FIST] 
	ninjas_stats[ninja1.board_ID][ability.SPEED] = shadows_stats[ability.SPEED]
# шанс докинуть еще скилов
	for i in skills_number :
		var ability_skill_key = rnd_shadows_keys[randi()%6]
		ninjas_stats[ninja1.board_ID][ability_skill_key] = shadows_stats[ability_skill_key]
	
	var ninja_hp = randi()%4+randi()%4+randi()%4+randi()%4 

	ninjas_stats[ninja1.board_ID]["hp"] = ninja_hp
	 
	var ninja_points = randi()%4+randi()%4+randi()%4 + randi()%4 + int(p_summ*4) 
	
	ninjas_stats[ninja1.board_ID]["points"] = ninja_points
	return ninja1 


func on_ninja_selected(ninja) :
#	printt(ninja,atacker,target)
	if attacker == null :
		attacker = ninja
		ninja.select(Color(0,1,0,1))
		
	elif target == null  and ninja != attacker  :
		target = ninja
		ninja.select(Color(1,0,0,1))
		move_target = null
		$TextureRect3.material.set_shader_param("frame_color",Color(0,0,1,0))
	elif target == ninja  :
		ninja.select(Color(0,0,0,0))
		target = null
	
		
	elif attacker == ninja :
		ninja.select(Color(0,0,0,0))
		attacker = null
		move_target = null
		$TextureRect3.material.set_shader_param("frame_color",Color(0,0,1,0))
		
		if target != null :
			target.select(Color(0,0,0,0))
			target = null
	
#случай если выбирают более третьего ниндзю когда уже есть и цель и атакующий
	elif attacker != ninja and  ninja != target : 
		target.select(Color(0,0,0,0))
		target = ninja
		target.select(Color(1,0,0,1))
		move_target = null
		$TextureRect3.material.set_shader_param("frame_color",Color(0,0,1,0))
	
	load_ninja_menu(attacker)
	
	
func on_ninja_deselected(ninj) :
	pass
	



func _on_TextureRect_gui_input(event):
	
#позиция в точках на доске без смещения 
#	printt(get_local_mouse_position(),board_offset)
	var position_on_board = get_local_mouse_position() - board_offset
	var cursor_cell = Vector2(int(position_on_board.x)/board_step,int(position_on_board.y)/board_step)
	if cursor_cell.x >= board_size.x or cursor_cell.x < 0 or cursor_cell.y >= board_size.y or cursor_cell.y < 0 :
		$YSort/TextureRect.material.set_shader_param("frame_color",Color(0,0,0,0))
		return
	if event.is_action_released("ui_select") and attacker!=null:
		var cell_empty = true
		for i in ninjas.keys() :
			if cursor_cell==ninjas[i].current_cell:
				cell_empty = false 
#			printt((cursor_cell==ninjas[i].current_cell),ninjas[i].current_cell,cursor_cell)
		if cell_empty :
			if move_target == cursor_cell :
				move_target = null
				$TextureRect3.rect_position = board_offset+cursor_cell*board_step
				$TextureRect3.material.set_shader_param("frame_color",Color(0,0,1,0))
		
			else:
				move_target = cursor_cell
				$TextureRect3.rect_position = board_offset+cursor_cell*board_step
				$TextureRect3.material.set_shader_param("frame_color",Color(0,0,1,1))
		
			if target != null :
				target.select(Color(0,0,0,0))
				target = null
			
			
	$YSort/TextureRect.rect_position = board_offset+cursor_cell*board_step
	$YSort/TextureRect.material.set_shader_param("frame_color",Color(1,1,0,1))




func _on_TextureRect2_gui_input(event):
	if event.is_action_released("ui_select") :
		if player_turn :
			$TextureRect2.texture.region = Rect2(64,0,64,64)
			player_turn = false
# обработка ходв
			apply_ability(attacker,target,move_target,target_ability)
		else :
			$TextureRect2.texture.region = Rect2(0,0,64,64)
			player_turn = true
			
func load_ninja_menu(_attacker) :
	$ItemList.clear()
	ability_menu_ids.clear()
	if _attacker == null :
		return
	var ninjas_abilityes = ninjas_stats[_attacker.board_ID]
	
	for i in ninjas_abilityes.keys() :
		if typeof(i) != TYPE_STRING or i in [ability.HEALTH]:
			var ability_icon = ability_atlas_texture.duplicate()
#			printt(i,ninjas_abilityes.keys(),ninjas_abilityes.keys()[i],ability)
			ability_icon.region = Rect2( i%4*32,i/ 4 * 32,	32,	32)
			$ItemList.add_icon_item(ability_icon)
			ability_menu_ids[ability_menu_ids.size()] = i 
		



func _on_ItemList_item_selected(index):
#	printt(index,ability_menu_ids,ability)
	target_ability = ability_menu_ids[index]
#	print( ability.keys()[ability.values().find(target_ability)] )
#	pass # Replace with function body.

func apply_ability(_attacker,_target,_move_target,_ability):
	if _ability == ability.SPEED :
		var attacker_point = _attacker.current_cell
		var final_point = null
		if 	_target != null :
			final_point = _target.current_cell
		elif _move_target != null:
			final_point = _move_target
		else :
			return
# надо переписать чтоб бежал пока не кончатся очки, и не забыть их отнять
		_attacker.complete_steps(a_star.finde_path(attacker_point,final_point))
	if _ability in [ability.FIST,ability.SURIKEN,ability.KHUNAI,ability.SWORD,ability.WHIP,ability.HIKICK,ability.BOW,ability.SPEAR]:
#		проверяем есть ли цель 
#		проверь дистанцию 
#		проверь акшен поинты 
#		применить
		if _target == null:
#сообщение, не выбрана цель атаки
			return
		 
		var target_distance = get_distance(_target.current_cell,_attacker.current_cell)
		if  target_distance > ability_stats[_ability][ability_param.DISTANCE] :
#сообщение дистанция для этого действия слишком большая
			return
		if ninjas_stats[_attacker.board_ID]["points"]<target_distance:
# сообщение, не хватает пунктов действия  
			return
		apply_attack_on_target(_attacker,_target,target_distance,_ability)
	
	if _ability in [ability.SHADOW_KICK,ability.SHADOW_FIST,ability.SHADOW_SUCK,ability.SHADOW_SURIKEN] :
		if _target == null:
#сообщение, не выбрана цель атаки
			return
		var target_distance = get_distance(_target.current_cell,_attacker.current_cell)
		if  target_distance > ability_stats[_ability][ability_param.DISTANCE] :
#сообщение дистанция для этого действия слишком большая
			return
		if ninjas_stats[_attacker.board_ID]["points"]<target_distance:
# сообщение, не хватает пунктов действия  
			return
		apply_attack_on_target(_attacker,_target,target_distance,_ability)
		if _ability == ability.SHADOW_FIST :
			ninjas_stats[_attacker.board_ID]["hp"] += int(ninjas_stats[_attacker.board_ID][_ability]) +randi()%3
# сообщение, и восстановил N здороаья
		if _ability == ability.SHADOW_SUCK :
			ninjas_stats[_target.board_ID]["points"] = 0
			
# сообщение и высосал из цели все очки действий 
		
	
func apply_attack_on_target(_attacker,_target,target_distance,_ability) :
	monitor["attack_on_target"] += 1
#сообщить атакующий нанес цели ххх повреждений оружием
	var attack_damage = randi()%ability_stats[_ability][ability_param.DAMAGE] +1+ int(ninjas_stats[_attacker.board_ID][_ability]) 
	ninjas_stats[_attacker.board_ID]["points"] -= ability_stats[_ability][ability_param.POINTS]
	
	if _ability in [ability.SHADOW_SUCK] :
		ninjas_stats[_target.board_ID]["points"] =0
	elif  _ability in [ability.SHADOW_FIST]  :
		ninjas_stats[_target.board_ID]["hp"] -= attack_damage
		ninjas_stats[_attacker.board_ID]["hp"] += 2
	else:
		ninjas_stats[_target.board_ID]["hp"] -= attack_damage
#анимация
#
#	ninjas_stats.erase(ninjas.keys()[i])
#	a_star.switch_points([ninjas[ninjas.keys()[i]].current_cell],false)
#	ninjas.erase(ninjas.keys()[i])
#	my_ninja.queue_free()
	print("удар ",attack_damage ,"HP осталось ",ninjas_stats[_target.board_ID]["hp"]) 
	if ninjas_stats[_target.board_ID]["hp"] <=0 :
#сообщение анимация смерти 
		target = null
		var game_info_key = game_info["turn_queue"].find(_target.board_ID)
		game_info["turn_queue"].remove(game_info_key)
		ninjas_stats.erase(_target.board_ID)
		a_star.switch_points([ninjas[_target.board_ID].current_cell],false)
		ninjas.erase(_target.board_ID)
		_target.queue_free()
		
	
	auto_player()
	return
	
func get_distance(cell_1,cell_2) :
	var delta_cell = cell_1 - cell_2
	return abs(delta_cell.x) + abs(delta_cell.y) -1

#алгоритм АИ 
#
#измерь расстояние до всех целей, 
#для всех своих скилов посчитай 
# Д_ДС(дистанцию - Дистанцию  скила) - это сколько тебе нужно пройти чтоб выстрелить
# О_КС(очки движений  - каст скила)  - это сколько у тебя есть чтоб подбежать
# выбери  О_КС >= Д_ДС  - это скилы которые ты можешь использовать хотябы 1 раз (ХС)
#всем хорошим скилам дай рейтинг 1 , посчитай мат ожидание урона по цели
#
#среди хороших скилов найди те у которых матожидание атаки > ХП - добавь им в рейтинг 10,
#
#выбери максимальный, ретинг выбери минмальный ДДС
#выполни

func ai_1(board_id,enemy_status="ninja"):
	monitor["ai_1"] +=1
	var e_ataking_skills = {
		"ninja" : [ability.SHADOW_KICK,ability.SHADOW_FIST,ability.SHADOW_SUCK,ability.SHADOW_SURIKEN],
		"shadow" : [ability.FIST,ability.SURIKEN,ability.KHUNAI,ability.SWORD,ability.WHIP,ability.HIKICK,ability.BOW,ability.SPEAR] 
		}
	var	my_points = ninjas_stats[board_id]["points"]
	
	if my_points <=0 :
		return null
	var enemeis = {}
	var my_skills = {}
	for i in ninjas_stats[board_id].keys():
		if i in e_ataking_skills[enemy_status] :
			my_skills[i] = { 
				ability_param.DISTANCE : ability_stats[i][ability_param.DISTANCE],
				ability_param.DAMAGE : ability_stats[i][ability_param.DAMAGE],
				ability_param.POINTS : ability_stats[i][ability_param.POINTS],
				}
			
	var best_enemy = null
	var best_D_SR = 20
	var best_skill = null
	var best_score =0
	var best_CtATT = false
	for i in ninjas.keys() :
		var enemy = ninjas[i] 
		if enemy.status == enemy_status and ninjas_stats[i]["hp"] > 0  :
						
			if best_enemy == null:
				best_enemy = i
			
			
			for j in my_skills.keys() :
				var score = 0
# D_SR - дистанция минус рэнж скила
# P_SC - акшенпоинтс минус рэндж скила 
# H_MOS - HP минус матожидание скила
				var D_SR = a_star.path_length(ninjas[board_id].current_cell,enemy.current_cell)-my_skills[j][ability_param.DISTANCE]
				var P_SC = my_points -  my_skills[j][ability_param.POINTS]
				var H_MOS = ninjas_stats[i]["hp"]-  (my_skills[j][ability_param.DAMAGE]+1)/2
				var cant_attack_this_turn = false
				if D_SR <= 0 and P_SC < 0 :
					cant_attack_this_turn = true
					
				if H_MOS <= 0 :
					score = 10
				elif D_SR <= P_SC :
					score = 1
#
#				print("++++++++++++++++++++++++++ было")
#				printt("Я ",ninjas[board_id].status,"медведь ",enemy.status,best_enemy,best_D_SR,best_skill, best_score)
#				printt("Я ",ninjas[board_id].status,"медведь ",enemy.status,enemy,D_SR,j, score)
#				print("++++++++++++++++++++++++++ стало")
				if score == 10 and best_score <= 10 :
					if D_SR < best_D_SR :
						best_enemy = enemy
						best_D_SR = D_SR
						best_skill = j
						best_score = score
						best_CtATT = cant_attack_this_turn
				elif  score == 1 and best_score <= 1 :
					if D_SR < best_D_SR :
						best_enemy = enemy
						best_D_SR = D_SR
						best_skill = j
						best_score = score
						best_CtATT = cant_attack_this_turn
				elif score ==0 and best_score <= 0: 
					if D_SR < best_D_SR :
						best_enemy = enemy
						best_D_SR = D_SR
						best_skill = j
						best_score = score
						best_CtATT = cant_attack_this_turn
				
#best_enemy- враг если нет то все мертвы,best_D_SR-лучший- на сколько надо подойти,
#best_skill - лучшая способность 
# best_CtATT- если на дитанции атаки лучшей чели и нет очков на выстрел то просто жди следующий ход
	if best_CtATT :
		ninjas_stats[board_id]["points"] = 0
	return [best_enemy,min(best_D_SR,my_points),best_skill]
		
func auto_player():
	monitor["auto_play"] +=1 
	var ninja_survived = false
	var shadow_survived	= false
	var i = ninjas.keys().size()-1
	while i >= 0 :
#		 printt("ninjas_keys", i, )
		var my_ninja = ninjas[ninjas.keys()[i]]		
		if my_ninja.status == "ninja" and ninjas_stats[ninjas.keys()[i]]["hp"]>0 :
			ninja_survived = true
		elif my_ninja.status == "shadow" and ninjas_stats[ninjas.keys()[i]]["hp"]>0 :
			shadow_survived = true
#			else :
#				ninjas_stats.erase(ninjas.keys()[i])
#				a_star.switch_points([ninjas[ninjas.keys()[i]].current_cell],false)
#				ninjas.erase(ninjas.keys()[i])
#				my_ninja.queue_free()
		i-=1
	if	!shadow_survived and ninja_survived:
			
#сообщение
			print ("ninjas win")
			return
			
	elif !ninja_survived and  shadow_survived:
			print ("shadows win")
			return	
	
	if game_info["turn_queue"].size() == 0 :
		for j in ninjas_stats.keys().size() :
			print( ninjas_stats[ninjas_stats.keys()[j]])
#делаем новый 
# проверим не закончились ли нпс одной из сторон - если да то закончим игру 
# удалим из списка всех кто с 0 и меньше хп
# сгенерируем мз оставшихся новую очередь 
		
		
#сообщение
		
		var ninjas_keys =ninjas.keys()
		ninjas_keys.shuffle()
		game_info["turn_queue"] = ninjas_keys
		game_info["turn"] += 1
		printt (ninjas_keys)
		
		for k in  ninjas_keys :
			if ninjas[k].status == "ninja" :
				var ninja_points = randi()%4+randi()%4+randi()%4 + randi()%4 
				if ninjas_stats[k].has(ability.SPEED) :
					ninja_points+=int(4* ninjas_stats[k][ability.SPEED])
				else :
					ninja_points+=int(2* player_stats[ability.SPEED])
				ninjas_stats[k]["points"] = ninja_points
				
			elif ninjas[k].status == "shadow":
				var p_summ = 0.0
				for j in 7 :
					p_summ += shadows_stats[shadows_stats.keys()[j]]
				var ninja_points = randi()%4+randi()%4+randi()%4 + randi()%4 + int(p_summ*4) 
				ninjas_stats[k]["points"] = ninja_points 
		auto_player()
		return	
		
#	var cur_attacker = game_info["turn_queue"][0]
	
		
	elif ninjas[game_info["turn_queue"][0]].status == "ninja" and game_info["game_status"] != "demo" :
		return
	else :
		if  ninjas_stats[game_info["turn_queue"][0]]["points"]<=0 :
			game_info["turn_queue"].remove(0)
				
		if 	game_info["turn_queue"].size() <= 0 :
			auto_player()
			return
		else :
			var cur_attacker = game_info["turn_queue"][0]
			var cur_enenmy = "ninja"
			if ninjas[cur_attacker].status == "ninja" :
				cur_enenmy = "shadow"
				
			var ai_tick = ai_1(cur_attacker,cur_enenmy)
					 
			if ai_tick[1] <=0 and ai_tick[2]!=null :
				attacker = ninjas[cur_attacker]
				target = ai_tick[0]
				target_ability = ai_tick[2]
				apply_attack_on_target(attacker,target,0,ai_tick[2])
			else :
		# если дистанция - ренж скила <= 0 то надо на нее подойти, только сперва узнать нужную точку
				
				attacker = ninjas[cur_attacker]
				var path_to_position =a_star.finde_N_point_of_path(attacker.current_cell,ai_tick[0].current_cell,ai_tick[1])	
				
				attacker.complete_steps(path_to_position)
				ninjas_stats[attacker.board_ID]["points"] -= path_to_position.size()
				


func _on_Timer_timeout():
	var monitor_label = my_hud.get_node("log/Label") 
	monitor_label.text =""
	for i in monitor.keys() :
		monitor_label.text += str(i)+" "+str(monitor[i])+ "\n"
	pass # Replace with function body.
