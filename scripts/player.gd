extends KinematicBody2D

var ray_top
var ray_right
var ray_bottom
var ray_left

var ray_check_top
var ray_check_right
var ray_check_bottom
var ray_check_left

var ray_overlap

var collider_top = ""
var collider_right = ""
var collider_bottom = ""
var collider_left = ""

var check_top = ""
var check_right = ""
var check_bottom = ""
var check_left = ""

var check_overlap = ""

var movement = 0
var move_left = false
var move_right = false
var move_down = false

var tilemap
var current_position
export var TILE_LADDER = 1
var move_up = 0
var collider_name

func _ready():
	set_fixed_process(true)
	tilemap = get_node("../tilemap")
	ray_top = get_node("ray_top")
	ray_right = get_node("ray_right")
	ray_bottom = get_node("ray_bottom")
	ray_left = get_node("ray_left")
	ray_check_top = get_node("ray_check_top")
	ray_check_right = get_node("ray_check_right")
	ray_check_bottom = get_node("ray_check_bottom")
	ray_check_left = get_node("ray_check_left")
	
	ray_overlap = get_node("ray_overlap")
	
	ray_top.add_exception(self)
	ray_right.add_exception(self)
	ray_bottom.add_exception(self)
	ray_left.add_exception(self)
	
	ray_overlap.add_exception(self)
	
	#fix position
	move(Vector2(0,-4))
	
func _fixed_process(delta):
	
	if movement == 0 and move_up == 0:
		current_position = get_pos()/64
		#allow to move right
		check_right = tilemap.get_cell(current_position.x + 1, current_position.y)
		move_right = (check_right == -1 || check_right == TILE_LADDER)
		if ray_check_right.is_colliding():
			var collider_name = ray_check_right.get_collider().get_name()
			if collider_name.substr(0,3) == "box":
				move_right = false
		#allow to move left
		check_left = tilemap.get_cell(current_position.x - 1, current_position.y)
		move_left = (check_left == -1 || check_left == TILE_LADDER)
		if ray_check_left.is_colliding():
			var collider_name = ray_check_left.get_collider().get_name()
			if collider_name.substr(0,3) == "box":
				move_left = false
		#check overlap
		check_overlap = tilemap.get_cell(current_position.x, current_position.y)
		#check down
		check_bottom = tilemap.get_cell(current_position.x, current_position.y + 1)
		move_down = (check_bottom == -1)
		if ray_check_bottom.is_colliding():
			var collider_name = ray_check_bottom.get_collider().get_name()
			if collider_name.substr(0,3) == "box":
				move_down = false
	
		#ask to move right
		if !move_down and move_right:
			if Input.is_action_pressed("btn_right"):
				get_node("Sprite").set_flip_h(false)
				movement = 64
				
		#ask to move left
		if !move_down and move_left:
			if Input.is_action_pressed("btn_left"):
				get_node("Sprite").set_flip_h(true)
				movement = -64
				
		#ask to climb
		if check_overlap == TILE_LADDER:
			if Input.is_action_pressed("btn_up"):
				move_up = 64
				
		#ask to lower
		if check_bottom == TILE_LADDER:
			if Input.is_action_pressed("btn_down"):
				move_up = -64

		#fall
		if move_down || int(get_pos().y)%64 > 0:
			move(Vector2(0,4))
	
	else:
		if movement > 0:
			get_node("Sprite").set_flip_h(false)
			movement -= 4
			move(Vector2(4,0))
		elif movement < 0:
			get_node("Sprite").set_flip_h(true)
			movement += 4
			move(Vector2(-4,0))
		if move_up > 0:
			move_up -= 4
			move(Vector2(0,-4))
		elif move_up < 0:
			move_up += 4
			move(Vector2(0,4))
