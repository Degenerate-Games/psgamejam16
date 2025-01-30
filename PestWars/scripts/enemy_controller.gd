## Enemy Controller
# This script is responsible for controlling the enemy's behavior.
# When the action_timer times out, the enemy will choose one of four actions:
# 	Send units from one of its bases to one of the player's bases (Attack)
# 	Send units from one of its bases to one of the neutral bases (Capture)
# 	Send units from one of its bases to another one of its bases (Reinforce)
# 	Keep its units at its bases (Defend)
# The enemy will choose the action based on its total units per controlled base and the associated probabilities:
# 	Less than 50 units per base:
# 		50% chance to Defend
# 		10% chance to Attack
# 		20% chance to Capture
# 		20% chance to Reinforce
# 	Between 50 and 100 units per base:
# 		30% chance to Defend
# 		20% chance to Attack
# 		20% chance to Capture
# 		30% chance to Reinforce
# 	Between 100 and 150 units per base:
# 		20% chance to Defend
# 		30% chance to Attack
# 		20% chance to Capture
# 		30% chance to Reinforce
# 	More than 150 units per base:
# 		10% chance to Defend
# 		40% chance to Attack
# 		20% chance to Capture
# 		30% chance to Reinforce
# The enemy will also choose the target base based on the following priorities:
# 	Attack:
# 		The player's base with the fewest units per distance traveled
# 	Capture:
# 		The neutral base with the fewest units per distance traveled
# 	Reinforce:
# 		The enemy's base with the fewest units per distance from the player's base with the fewest units per distance traveled
# Certain states on the battle field will trigger special actions that override the normal behavior:
# 	If there are no more neutral bases and:
# 		A. either side has more than 50% of the total units on the battlefield, the enemy will send half of its units to the player's base with the fewest units per distance traveled
# 		B. the player has more than 90% of the total units on the battlefield, the enemy will send half of its units to the player's base with the fewest units per distance traveled and the other half
# 		to the units to the enemy base closest to the players home base
# 		C. the enemy has more than 90% of the total units on the battlefield, the enemy will send half of its units to the player's base with the fewest units per distance traveled and the other half
# 		to the units to the enemy base closest to the center of the players remaining bases
extends Node3D

enum Action {DEFEND, ATTACK, CAPTURE, REINFORCE, SPECIALA, SPECIALB, SPECIALC}

@onready var action_timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_cycle()


func start_cycle() -> void:
	action_timer.wait_time = randf_range(3, 6)
	action_timer.start()


func choose_action(units_per_base: int) -> Action:
	var action = Action.DEFEND

	if get_tree().get_nodes_in_group("neutral_base").size() == 0:
		return choose_special_action()

	var action_probabilities = [Action.DEFEND, Action.ATTACK, Action.CAPTURE, Action.REINFORCE]
	var action_weights = [0.5, 0.1, 0.2, 0.2]

	if units_per_base >= 50 and units_per_base < 100:
		action_weights = [0.3, 0.2, 0.2, 0.3]
	elif units_per_base < 150:
		action_weights = [0.2, 0.3, 0.2, 0.3]
	else:
		action_weights = [0.1, 0.4, 0.2, 0.3]
	
	action = choose_weighted_action(action_probabilities, action_weights)
	return action


func choose_special_action() -> Action:
	var action = Action.SPECIALA
	var total_units = 0
	for base in get_tree().get_nodes_in_group("enemy_base"):
		total_units += base.units_parent.get_child_count()
	var player_units = 0
	for base in get_tree().get_nodes_in_group("bot_base"):
		player_units += base.units_parent.get_child_count()
	if player_units > total_units * 0.9:
		action = Action.SPECIALA
	elif total_units > player_units * 0.9:
		action = Action.SPECIALB
	else:
		action = Action.SPECIALC
	return action


func choose_weighted_action(actions: Array, weights: Array) -> Action:
	var total_weight = 0
	for weight in weights:
		total_weight += weight
	var random_weight = randf_range(0, total_weight)
	var current_weight = 0
	for i in range(actions.size()):
		current_weight += weights[i]
		if random_weight < current_weight:
			return actions[i]
	return actions[actions.size() - 1]


func choose_target_base(from_base: Node3D, action: Action) -> Node3D:
	var target_base = null
	var base_controller = get_tree().get_first_node_in_group("base_controller")
	var base_group = ""

	if action == Action.ATTACK or action == Action.SPECIALA:
		base_group = "bot_base"
	elif action == Action.CAPTURE:
		base_group = "neutral_base"
	elif action == Action.REINFORCE:
		base_group = "enemy_base"
	
	var closest_base = base_controller.find_closest_base(from_base.global_transform.origin, base_group)
	target_base = closest_base
	var min_units_per_distance = 1e6
	var units_count = base_controller.units_parent.get_child_count()
	for base in get_tree().get_nodes_in_group(base_group):
		var units_per_distance = units_count / base.global_transform.origin.distance_to(closest_base.global_transform.origin)
		if units_per_distance < min_units_per_distance:
			target_base = base
			min_units_per_distance = units_per_distance
	return target_base


func _on_timer_timeout() -> void:
	var total_units = 0
	var total_bases = 0
	var base_controller = get_tree().get_first_node_in_group("base_controller")
	var enemy_bases = get_tree().get_nodes_in_group("enemy_base")

	for base in enemy_bases:
		total_units += base_controller.units_parent.get_child_count()
		total_bases += 1
	var units_per_base = total_units / total_bases
	var action = choose_action(units_per_base)
	var from_base = enemy_bases[randi() % enemy_bases.size()]
	var target_base = choose_target_base(from_base, action)
	var send_units = [0.5, 1.0][randi() % 2]
	if from_base == target_base:
		start_cycle()
		return
	if action == Action.ATTACK or action == Action.REINFORCE or action == Action.CAPTURE:
		from_base.send_units(target_base, send_units, base_controller.units_parent)
	elif action == Action.SPECIALA:
		from_base.send_units(target_base, 0.5, base_controller.units_parent)
	elif action == Action.SPECIALB:
		from_base.send_units(target_base, 0.5, base_controller.units_parent)
		var closest_base = base_controller.find_closest_base(target_base.global_transform.origin, "enemy_base")
		from_base.send_units(closest_base, 0.5, base_controller.units_parent)
	elif action == Action.SPECIALC:
		from_base.send_units(target_base, 0.5, base_controller.units_parent)
		var player_bases = get_tree().get_nodes_in_group("player_base")
		var center_position = Vector3()
		for base in player_bases:
			center_position += base.global_transform.origin
		center_position /= player_bases.size()
		var center_base = base_controller.find_closest_base(center_position, "enemy_base")
		from_base.send_units(center_base, 0.5, base_controller.units_parent)

	start_cycle()
