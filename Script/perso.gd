extends CharacterBody2D
class_name Perso

@export var speed := 180.0

var genome: Genome
var hp: int
var alive := true

var max_x := 0.0
var checkpoint_score := 0
var reached_finish := false

@onready var ground_ray: RayCast2D = $GroundRay

func setup(g: Genome) -> void:
	genome = g
	hp = g.hp
	alive = true
	max_x = global_position.x
	checkpoint_score = 0
	reached_finish = false

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity.x = speed

	if not is_on_floor():
		velocity.y += 1.0 * delta

	if is_on_floor() and (not ground_ray.is_colliding()):
		_do_jump()

	move_and_slide()
	max_x = max(max_x, global_position.x)

func _do_jump() -> void:
	var base_jump := 380.0
	velocity.y = -(base_jump + 120.0 * float(genome.jump_height - 1))
	velocity.x += 40.0 * float(genome.jump_length - 1)

func take_damage(amount := 1) -> void:
	if not alive:
		return
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	alive = false
	velocity = Vector2.ZERO
