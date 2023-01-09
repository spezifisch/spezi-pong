extends CanvasLayer


export var ai_player_left = false
export var ai_player_right = false

export var paddle_speed: float = 600 # pixels per second
export var paddle_limit_y: int = 80 # min. distance to screen edge

export var ai_paddle_speed_max: float = 300 # px/s
export var ai_p_gain: float = 6


func set_ai_level(level: int):
	if level == 0:
		ai_p_gain = 1
		ai_paddle_speed_max = 600
	elif level < 5:
		ai_p_gain = level
		ai_paddle_speed_max = 300
	elif level == 5:
		ai_p_gain = 6
		ai_paddle_speed_max = 300
	elif level >= 6:
		ai_p_gain = level
		ai_paddle_speed_max = 400
		if level >= 9:
			ai_paddle_speed_max = 600

	print("ai level %d (p=%f, vmax=%f)" % [level, ai_p_gain, ai_paddle_speed_max])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if ai_player_left:
		ai_move($PaddleLeft, delta)
	elif Input.is_action_pressed("paddle_left_up") or (ai_player_right and Input.is_action_pressed("paddle_right_up")):
		move_paddle($PaddleLeft, -paddle_speed*delta)
	elif Input.is_action_pressed("paddle_left_down") or (ai_player_right and Input.is_action_pressed("paddle_right_down")):
		move_paddle($PaddleLeft, paddle_speed*delta)
		
	if ai_player_right:
		ai_move($PaddleRight, delta)
	elif Input.is_action_pressed("paddle_right_up"):
		move_paddle($PaddleRight, -paddle_speed*delta)
	elif Input.is_action_pressed("paddle_right_down"):
		move_paddle($PaddleRight, paddle_speed*delta)


func move_paddle(paddle: Area2D, distance: float):
	paddle.move_local_y(distance)
	paddle.position.y = clamp(paddle.position.y, paddle_limit_y, 600 - paddle_limit_y)


func ai_move(paddle: Area2D, delta: float):
	var ball_y = $Ball.position.y
	var paddle_y = paddle.position.y
	var velocity = (ball_y - paddle_y) * ai_p_gain
	velocity = clamp(velocity, -ai_paddle_speed_max, ai_paddle_speed_max)
	move_paddle(paddle, velocity*delta)
