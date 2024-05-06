extends CharacterBody2D

var player_state

func play_anim(dir_x, dir_y):
	if player_state == "idle":
		$AnimatedSprite2D.play("idle")
	
	if player_state == "walking":
		#check for one directional movement
		if dir_y == -1: #moving north
			$AnimatedSprite2D.play("n-walk")
		if dir_y == +1: #moving south
			$AnimatedSprite2D.play("s-walk")
		if dir_x == -1: #moving west
			$AnimatedSprite2D.play("w-walk")
		if dir_x == +1:
			$AnimatedSprite2D.play("e-walk")
			
		#check for two directional input
		if dir_x > +0.5 and dir_y < -0.5: #north-east
			$AnimatedSprite2D.play("ne-walk")
		if dir_x > +0.5 and dir_y > +0.5: #south-east
			$AnimatedSprite2D.play("se-walk")
		if dir_x < -0.5 and dir_y > -0.5: #south-west
			$AnimatedSprite2D.play("sw-walk")
		if dir_x < -0.5 and dir_y < -0.5: #north-west
			$AnimatedSprite2D.play("nw-walk")
			
func player():
	pass
	

