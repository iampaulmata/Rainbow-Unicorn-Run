extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -700.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	velocity.y += gravity * delta
	
	if is_on_floor():
		if not get_parent().game_running:
				$AnimatedSprite2D.play("idle")
		else: 
			$RunCol.disabled = false
		# Handle jump.
			if Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) :
				$RunCol.disabled = true
				velocity.y = JUMP_VELOCITY
				$AnimatedSprite2D.play("jumping_animated")
				$JumpSound.play()
			else:
				$AnimatedSprite2D.play("running")
	else:
		$AnimatedSprite2D.play("jumping_animated")

	move_and_slide()
