extends Area2D
class_name Checkpoint

@export var checkpoint_id: int = 0
@export var value: int = 1000

func _on_body_entered(body: Node) -> void:
	if body is Perso:
		body_on_checkpoint(body)

func body_on_checkpoint(bot: Perso) -> void:
	if not bot.has_meta("cp"):
		bot.set_meta("cp", {})
	var cp = bot.get_meta("cp")
	if cp.has(checkpoint_id):
		return
	cp[checkpoint_id] = true
	bot.set_meta("cp", cp)
	bot.checkpoint_score += value
