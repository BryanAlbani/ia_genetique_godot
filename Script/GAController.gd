extends Node2D

@export var population_size := 100
@export var elite_count := 10
@export var mutation_rate := 0.10  # 10%
@export var max_time_per_gen := 20.0

@export var perso_scene: PackedScene
@export var spawn_pos: Vector2
@onready var spawn_point: Marker2D = get_node("../SpawnPoint")

var generation := 0
var bots: Array[Perso] = []
var genomes: Array[Genome] = []

var gen_time := 0.0

func _ready() -> void:
	randomize()
	print("GA ready. perso_scene=", perso_scene)
	spawn_pos = spawn_point.global_position
	_start_first_generation()

func _physics_process(delta: float) -> void:
	if bots.is_empty():
		return

	gen_time += delta

	var alive_count := 0
	for b in bots:
		if b.alive:
			alive_count += 1

	if int(gen_time * 10.0) % 10 == 0: 
		print("gen=", generation, " alive=", alive_count, " time=", gen_time)
		
	if alive_count == 0 or gen_time >= max_time_per_gen:
		print("END GEN TRIGGERED")
		_end_generation()

func _start_first_generation() -> void:
	generation = 1
	genomes.clear()
	for i in range(population_size):
		genomes.append(Genome.random_init())
	_spawn_population(genomes)

func _spawn_population(gens: Array[Genome]) -> void:
	_clear_bots()
	gen_time = 0.0

	for g in gens:
		var bot := perso_scene.instantiate() as Perso
		add_child(bot)
		bot.global_position = spawn_pos
		bot.setup(g)
		bots.append(bot)

func _clear_bots() -> void:
	for b in bots:
		if is_instance_valid(b):
			b.queue_free()
	bots.clear()

func _end_generation() -> void:

	var scored := []
	for b in bots:
		var fitness := _compute_fitness(b)
		scored.append({ "genome": b.genome, "fitness": fitness })

	scored.sort_custom(func(a, b): return a["fitness"] > b["fitness"])

	var elites: Array[Genome] = []
	for i in range(elite_count):
		elites.append((scored[i]["genome"] as Genome).clone())

	var next_gen: Array[Genome] = []
	for e in elites:
		next_gen.append(e.clone())

	while next_gen.size() < population_size:
		var p1 := _tournament_pick(scored)
		var p2 := _tournament_pick(scored)
		var child := _crossover(p1, p2)
		_mutate(child)
		next_gen.append(child)

	generation += 1
	genomes = next_gen
	_spawn_population(genomes)

func _compute_fitness(b: Perso) -> float:
	var base := b.max_x
	var bonus := float(b.checkpoint_score)
	if b.reached_finish:
		bonus += 100000.0
	return base + bonus

func _tournament_pick(scored: Array) -> Genome:
	var k := 5
	var best = scored[randi() % scored.size()]
	for i in range(k - 1):
		var cand = scored[randi() % scored.size()]
		if cand["fitness"] > best["fitness"]:
			best = cand
	return (best["genome"] as Genome)

func _crossover(a: Genome, b: Genome) -> Genome:

	var child := Genome.new()
	if (randf() < 0.5):
		child.jump_height = a.jump_height
	else :
		child.jump_height = b.jump_height
	
	if (randf() < 0.5):
		child.jump_length = a.jump_length
	else :
		child.jump_length = b.jump_length
	
	if (randf() < 0.5):
		child.hp = a.hp
	else :
		child.hp = b.hp
		
	return child

func _mutate(g: Genome) -> void:

	if randf() < mutation_rate:
		g.jump_height += 1
	if randf() < mutation_rate:
		g.jump_length += 1
	if randf() < mutation_rate:
		g.hp += 1

	g.jump_height = min(g.jump_height, 10)
	g.jump_length = min(g.jump_length, 10)
	g.hp = min(g.hp, 10)
