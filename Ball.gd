extends Area2D

signal score(player)
signal ball_hit(what)

export var active: bool = false

export var max_velocity: float = 300 # in px/s

export var spawn_pos_x: int = 512 # px
export var spawn_min_y: int = 100 # px

export var screen_width: int = 1024 # px
export var screen_height: int = 600 # px

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	# spawn in the middle and fly randomly left/right. i think that's fair.
	if randi() % 2 == 0:
		spawn(-1, false)
	else:
		spawn(1, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not active:
		return

	position += velocity * delta
	
	if position.x < 0:
		# right player scored
		emit_signal("score", "right")
		spawn(-1, true)
	elif position.x > screen_width:
		emit_signal("score", "left")
		spawn(1, true)


func spawn(x_direction: float, y_random: bool):
	# fly in a 45° angle like in: https://www.youtube.com/watch?v=fiShX2pTz9A
	position.x = spawn_pos_x
	if y_random:
		position.y = spawn_min_y + randi() % (screen_height - spawn_min_y)
	else:
		position.y = screen_height / 2.0
	velocity.x = x_direction * max_velocity * sqrt(2)
	velocity.y = max_velocity * sqrt(2)


func _on_WallUp_area_entered(area: Area2D):
	if area.name == name:
		velocity.y = abs(velocity.y)
		emit_signal("ball_hit", "wall")


func _on_WallDown_area_entered(area: Area2D):
	if area.name == name:
		velocity.y = -abs(velocity.y)
		emit_signal("ball_hit", "wall")


func _on_PaddleLeft_area_entered(area: Area2D):
	if area.name == name:
		velocity.x = abs(velocity.x)
		emit_signal("ball_hit", "paddle")


func _on_PaddleRight_area_entered(area: Area2D):
	if area.name == name:
		velocity.x = -abs(velocity.x)
		emit_signal("ball_hit", "paddle")
