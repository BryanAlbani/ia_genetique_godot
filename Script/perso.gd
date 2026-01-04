extends Area2D

@export var speed = 400;
@export var jumpHeight = 2;
@export var jumpWidth = 2;
@export var health = 2;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("Jump"):
		velocity.y -= 1
	pass
