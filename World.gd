extends Node2D


export var mute_music_default = false
export var mute_fx_default = false
export var single_player_default = true
export var ai_level_default: int = 5

export var ball_spawn_x = 512 # px
export var paddle_spawn_y = 300 # px

var state = "init"

var score_left: int = 0
var score_right: int = 0


func _ready():
	# set defaults and update ui
	mute_music(mute_music_default)
	$Menu/Panel/Menu/CheckMusic.pressed = !mute_music_default
	mute_fx(mute_fx_default)
	$Menu/Panel/Menu/CheckFX.pressed = !mute_fx_default
	
	$Physics.set_ai_level(ai_level_default)
	$Menu/Panel/Menu/AI/Level.value = ai_level_default
	$Physics.ai_player_left = false	# :)
	$Physics.ai_player_right = single_player_default
	$Menu/Panel/Menu/AI/CheckOnePlayer.pressed = single_player_default
	
	reset_game()
	switch_state("menu")
	
	$Sounds/Theme.play()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if state == "menu":
			switch_state("play")
		else:
			switch_state("menu")


func pause_game(paused: bool):
	if paused:
		$Physics/Ball.active = false
	else:
		$Physics/Ball.active = true


func reset_game():
	score_left = 0
	score_right = 0
	update_scores()
	$Physics/PaddleLeft.position.y = paddle_spawn_y
	$Physics/PaddleRight.position.y = paddle_spawn_y
	$Physics/Ball.position = Vector2(ball_spawn_x, paddle_spawn_y)


func switch_state(new_state: String):
	match state:
		"init":
			match new_state:
				"menu":
					state = "menu"
					pause_game(true)
					show_menu()
		"menu":
			match new_state:
				"play":
					state = "play"
					hide_menu()
					pause_game(false)
		"play":
			match new_state:
				"menu":
					state = "menu"
					pause_game(true)
					show_menu()
	
	
func show_menu():
	$Physics/PaddleLeft.hide()
	$Physics/PaddleRight.hide()
	$Physics/Ball.hide()
	$Menu.show()


func hide_menu():
	$Menu.hide()
	$Physics/PaddleLeft.show()
	$Physics/PaddleRight.show()
	$Physics/Ball.show()


func mute_music(muted: bool):
	AudioServer.set_bus_mute(1, muted)


func mute_fx(muted: bool):
	AudioServer.set_bus_mute(2, muted)
	
	
func _on_Ball_score(player: String):
	match player:
		"left":
			score_left += 1
		"right":
			score_right += 1
			
	update_scores()
	$Sounds/Goal.play()


func update_scores():
	$Decoration/ScoreL.text = "%d" % score_left
	$Decoration/ScoreR.text = "%d" % score_right


func _on_Ball_ball_hit(_what):
	$Sounds/BallHit.play()


func _on_ButtonStart_button_up():
	switch_state("play")
	
	
func _on_ButtonReset_button_up():
	reset_game()


func _on_CheckMusic_toggled(button_pressed):
	mute_music(!button_pressed)


func _on_CheckFX_toggled(button_pressed):
	mute_fx(!button_pressed)


func _on_CheckOnePlayer_toggled(button_pressed):
	$Physics.ai_player_right = button_pressed


func _on_Level_value_changed(value):
	$Physics.set_ai_level(round(value))
