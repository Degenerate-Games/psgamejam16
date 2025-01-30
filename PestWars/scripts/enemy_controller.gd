## Enemy Controller
# This script is responsible for controlling the enemy's behavior.
# When the action_timer times out, the enemy will choose one of four actions:
	# Send units from one of its bases to one of the player's bases (Attack)
	# Send units from one of its bases to one of the neutral bases (Capture)
	# Send units from one of its bases to another one of its bases (Reinforce)
	# Keep its units at its bases (Defend)
# The enemy will choose the action based on its total units per controlled base and the associated probabilities:
	# Less than 50 units per base:
		# 50% chance to Defend
		# 10% chance to Attack
		# 20% chance to Capture
		# 20% chance to Reinforce
	# Between 50 and 100 units per base:
		# 30% chance to Defend
		# 20% chance to Attack
		# 20% chance to Capture
		# 30% chance to Reinforce
	# Between 100 and 150 units per base:
		# 20% chance to Defend
		# 30% chance to Attack
		# 20% chance to Capture
		# 30% chance to Reinforce
	# More than 150 units per base:
		# 10% chance to Defend
		# 40% chance to Attack
		# 20% chance to Capture
		# 30% chance to Reinforce
# The enemy will also choose the target base based on the following priorities:
	# Attack:
		# The player's base with the fewest units per distance traveled
	# Capture:
		# The neutral base with the fewest units per distance traveled
	# Reinforce:
		# The enemy's base with the fewest units per distance from the player's base with the fewest units per distance traveled
# Certain states on the battle field will trigger special actions that override the normal behavior:
	# If there are no more neutral bases and:
		# 1. either side has more than 50% of the total units on the battlefield, the enemy will send half of its units to the player's base with the fewest units per distance traveled
		# 2. the player has more than 90% of the total units on the battlefield, the enemy will send half of its units to the player's base with the fewest units per distance traveled and the other half
		# to the units to the enemy base closest to the players home base
		# 3. the enemy has more than 90% of the total units on the battlefield, the enemy will send half of its units to the player's base with the fewest units per distance traveled and the other half
		# to the units to the enemy base closest to the center of the players remaining bases
extends Node3D


@onready var action_timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
