class_name Genome

var jump_height: int
var jump_length: int
var hp: int

func _init(h := 1, l := 1, p := 1):
	jump_height = h
	jump_length = l
	hp = p

static func random_init() -> Genome:
	return Genome.new(
		randi_range(1, 2),
		randi_range(1, 2),
		randi_range(1, 2)
	)

func clone() -> Genome:
	return Genome.new(jump_height, jump_length, hp)
