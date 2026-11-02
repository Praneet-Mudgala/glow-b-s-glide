extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800

enum State {NORMAL, DAMAGED, DEAD}
var current_state: State = State.NORMAL


func _physics_process(delta):
	if current_state == State.DEAD:
		return
	
	velocity.y += GRAVITY * delta
	if is_on_floor():
		$RunCol.disabled = false
	
		if current_state == State.NORMAL:
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("crouch")
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Walk1")
			
	move_and_slide()


func play_damaged():
	if current_state != State.NORMAL:
		current_state = State.NORMAL
		return
	current_state = State.DAMAGED
	$AnimatedSprite2D.play("Damage")
	await get_tree().create_timer(0.4).timeout
	if current_state == State.DAMAGED:
		current_state = State.NORMAL
		$AnimatedSprite2D.play("Walk1")
	
func play_death():
	current_state = State.DEAD
	$AnimatedSprite2D.play("death")
	
func reset_player():
	current_state = State.NORMAL
	$AnimatedSprite2D.play("Walk1")




#
