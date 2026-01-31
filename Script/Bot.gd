extends CharacterBody2D

signal died(bot)

@export var base_speed: float = 90.0
@export var gravity: float = 1200.0
@export var jump_base: float = 200.0     
@export var jump_step: float = 70.0      
@export var air_speed_bonus: float = 0.10 
@export var stuck_time_limit: float = 1.0   
@export var min_progress_px: float = 2.0    

var _stuck_time := 0.0
var _last_x := 0.0

var jump_height: int = 1
var jump_length: int = 1
var hp: int = 1

var best_checkpoint: int = -1
var finished_run: bool = false
var jump_cooldown := 0.0

@onready var ray: RayCast2D = $GroundAheadRay
@onready var wall_ray: RayCast2D = get_node_or_null("WallRay")

func setup(stats: Dictionary) -> void:
	jump_height = stats.get("jump_height", 1)
	jump_length = stats.get("jump_length", 1)
	hp = stats.get("hp", 1)

	best_checkpoint = -1
	finished_run = false
	jump_cooldown = 0.0
	
	_last_x = global_position.x
	_stuck_time = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var speed := base_speed
	if not is_on_floor():
		speed *= (1.0 + air_speed_bonus * float(jump_length - 1))
	velocity.x = speed

	jump_cooldown = max(0.0, jump_cooldown - delta)

	if is_on_floor() and jump_cooldown <= 0.0:
		if not ray.is_colliding():
			do_jump()
			jump_cooldown = 0.15
		elif wall_ray.is_colliding():
			do_jump()
			jump_cooldown = 0.2


	move_and_slide()
	var dx = abs(global_position.x - _last_x)

	if dx < min_progress_px:
		_stuck_time += delta
	else:
		_stuck_time = 0.0
		_last_x = global_position.x

	if _stuck_time >= stuck_time_limit:
		die()
		return

func do_jump() -> void:
	velocity.y = -(jump_base + jump_step * float(jump_height - 1))

func take_damage(amount: int = 1) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	emit_signal("died", self)
	queue_free()

func get_fitness() -> float:
	var checkpoint_score = float(best_checkpoint + 1) * 10000.0
	var progress_score = global_position.x
	var finish_bonus = 1000000.0 if finished_run else 0.0
	return checkpoint_score + progress_score + finish_bonus

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("spikes"):
		take_damage(1)
		return

	if area.is_in_group("checkpoints"):
		if "checkpoint_index" in area:
			best_checkpoint = max(best_checkpoint, area.checkpoint_index)

	if area.is_in_group("finish"):
		finished_run = true
		emit_signal("died", self)
		queue_free()
