extends Node

@export var bot_scene: PackedScene
@export var spawn_point: Node2D

@export var population_size: int = 100
@export var elite_size: int = 10
@export var mutation_rate: float = 0.10
@export var max_round_time: float = 15.0

var generation: int = 0
var population_info: Array[Dictionary] = []
var round_time := 0.0
var round_running := false

func _ready() -> void:
	randomize()
	call_deferred("start_first_generation")


func _process(delta: float) -> void:
	if not round_running:
		return

	round_time += delta
	if round_time >= max_round_time:
		end_round()

	if get_alive_count() == 0:
		end_round()

func get_alive_count() -> int:
	var c := 0
	for p in population_info:
		if p.alive:
			c += 1
	return c

func start_first_generation() -> void:
	generation = 1
	var genomes: Array[Dictionary] = []

	for i in range(population_size):
		genomes.append(random_genome_1_2())

	start_round(genomes)

func random_genome_1_2() -> Dictionary:
	return {
		"jump_height": randi_range(1, 2),
		"jump_length": randi_range(1, 2),
		"hp": randi_range(1, 2),
	}

func start_round(genomes: Array[Dictionary]) -> void:
	for p in population_info:
		var b = p.get("bot")
		if is_instance_valid(b):
			b.queue_free()

	population_info.clear()

	round_time = 0.0
	round_running = true

	for g in genomes:
		var bot = bot_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", bot)
		var idx := population_info.size()
		var col := idx % 10
		var row := idx / 10
		
		bot.global_position = spawn_point.global_position + Vector2(col * 14, -row * 14)
		bot.setup(g)
		bot.died.connect(_on_bot_died)


		population_info.append({
			"genome": g.duplicate(true),
			"bot": bot,
			"fitness": 0.0,
			"alive": true,
		})

	print("GEN ", generation, " started")

func _on_bot_died(bot) -> void:
	for p in population_info:
		if p.bot == bot and p.alive:
			p.fitness = bot.get_fitness()
			p.alive = false
			return



func end_round() -> void:
	if not round_running:
		return
	round_running = false

	for p in population_info:
		if p.alive and is_instance_valid(p.bot):
			p.fitness = p.bot.get_fitness()
			p.alive = false
			p.bot.queue_free()

	population_info.sort_custom(func(a, b): return a.fitness > b.fitness)

	var elites: Array[Dictionary] = []
	for i in range(min(elite_size, population_info.size())):
		elites.append(population_info[i].genome)

	print("GEN ", generation, " best fitness: ", population_info[0].fitness, " genome: ", elites[0])
	
	generation += 1
	var next_gen: Array[Dictionary] = []
	for e in elites:
		next_gen.append(e.duplicate(true))

	while next_gen.size() < population_size:
		var parent_a = elites[randi_range(0, elites.size() - 1)]
		var parent_b = elites[randi_range(0, elites.size() - 1)]

		var child = crossover(parent_a, parent_b)
		mutate(child)
		next_gen.append(child)

	start_round(next_gen)

func crossover(a: Dictionary, b: Dictionary) -> Dictionary:
	var child := {}
	child.jump_height = a.jump_height if randf() < 0.5 else b.jump_height
	child.jump_length = a.jump_length if randf() < 0.5 else b.jump_length
	child.hp = a.hp if randf() < 0.5 else b.hp
	return child

func mutate(g: Dictionary) -> void:
	if randf() < mutation_rate:
		g.jump_height += 1
	if randf() < mutation_rate:
		g.jump_length += 1
	if randf() < mutation_rate:
		g.hp += 1
