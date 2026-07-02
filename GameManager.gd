extends Node

var gold = 500
var turn = 0
var threat = 0
var current_city = "Hometown"

#------Quests------

var quests = {
	"Hometown": [
		{"name": "Escort job",   "reward": 100, "success_chance": 0.75, "time_cost": 1},
		{"name": "Rat problem",  "reward": 80,  "success_chance": 0.80, "time_cost": 1},
	],
	"Iron Heights": [
		{"name": "Mine escort",  "reward": 275, "success_chance": 0.65, "time_cost": 2},
		{"name": "Bandit camp",  "reward": 400, "success_chance": 0.50, "time_cost": 3},
	],
	"The Citadel": [
		{"name": "Guild contract", "reward": 600, "success_chance": 0.50, "time_cost": 3},
		{"name": "Smuggler tip",   "reward": 900, "success_chance": 0.30, "time_cost": 4},
	],
}

#------ traveling------

var travel_routes = {
	"Hometown": {"Iron Heights": {"time": 5, "cost": 100}},
	"Iron Heights":  {"Hometown": {"time": 5, "cost": 100}, "The Citadel": {"time": 8, "cost": 500}},
	"The Citadel":    {"Iron Heights": {"time": 8, "cost": 500}},
}


func travel_to(city: String) -> bool:
	var route = travel_routes[current_city][city]
	if gold < route.cost:
		return false
	gold -= route.cost
	turn += route.time
	threat += route.time
	current_city = city
	return true
	
const MAX_THREAT = 100

func can_travel_to(city: String) -> bool:
	if city not in travel_routes[current_city]:
		return false
	if gold < travel_routes[current_city][city].cost:
		return false
	var route = travel_routes[current_city][city]
	if threat + route.time >= MAX_THREAT:
		return false
	return true


#------Equipment------

var equipped = {
	"weapon": null,
	"armor": null,
}

func get_success_bonus() -> float:
	var bonus = 0.0
	for slot in equipped:
		if equipped[slot] != null:
			bonus += equipped[slot].bonus
	return bonus

func buy_item(item: Dictionary) -> bool:
	if gold < item.cost:
		return false
	var slot = item.slot
	gold -= item.cost
	equipped[slot] = item
	return true

var shop_inventory = {
	"Hometown": [
		{"name": "Worn Sword",    "cost": 200,  "bonus": 0.04, "slot" : "weapon"},
		{"name": "Leather Armor", "cost": 300, "bonus": 0.06, "slot" : "armor"},
	],
	"Iron Heights": [
		{"name": "Steel Blade",   "cost": 700, "bonus": 0.12, "slot" : "weapon"},
		{"name": "Chain Mail",    "cost": 1000, "bonus": 0.16, "slot" : "armor"},
	],
	"The Citadel": [
		{"name": "Excalibur", "cost": 2500, "bonus": 0.25, "slot" : "weapon"},
		{"name": "Mage Robes",      "cost": 2000, "bonus": 0.20, "slot" : "armor"},
	],
}

#------Energy System------
var energy: int = 100
const MAX_ENERGY: int = 100

const ENERGY_DRAIN_SUCCESS: int = 10
const ENERGY_DRAIN_FAIL: int = 25

func get_energy_drain(success: bool) -> int:
	# party members will reduce this later
	if success:
		return ENERGY_DRAIN_SUCCESS
	else:
		return ENERGY_DRAIN_FAIL
		
func can_do_quest(quest_index: int) -> bool:
	var q = quests[current_city][quest_index]
	if energy <= 0:
		return false
	# optionally block quests that would be attempted on 0 energy
	return true
	
const ENERGY_REST_RECOVERY: int = 30  # per turn of rest
const FORCED_REST_TURNS: int = 10

var is_forced_resting: bool = false
var forced_rest_turns_remaining: int = 0

func rest(turns: int):
	var actual_turns = min(turns, (MAX_ENERGY - energy) / ENERGY_REST_RECOVERY)
	energy = min(energy + ENERGY_REST_RECOVERY * actual_turns, MAX_ENERGY)
	threat += actual_turns
	turn += actual_turns

func check_exhaustion():
	if energy <= 0:
		energy = 0
		is_forced_resting = true
		forced_rest_turns_remaining = FORCED_REST_TURNS
		threat += FORCED_REST_TURNS
		turn += FORCED_REST_TURNS
