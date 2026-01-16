extends Area2D

func _on_body_entered(body: Node) -> void:
	if body is Perso:
		body.reached_finish = true
		body.die()
