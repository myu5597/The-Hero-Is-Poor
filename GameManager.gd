extends Node

var gold = 500
var turn = 0
var threat = 0
var current_city = "Hometown"

var quests = {
	"Hometown": [
		{"name": "Escort job",   "reward": 100, "success_chance": 0.85, "time_cost": 1},
		{"name": "Rat problem",  "reward": 80,  "success_chance": 0.90, "time_cost": 1},
	],
	"Iron_Heights": [
		{"name": "Mine escort",  "reward": 225, "success_chance": 0.65, "time_cost": 2},
		{"name": "Bandit camp",  "reward": 350, "success_chance": 0.50, "time_cost": 3},
	],
	"The_Citadel": [
		{"name": "Guild contract", "reward": 450, "success_chance": 0.55, "time_cost": 3},
		{"name": "Smuggler tip",   "reward": 700, "success_chance": 0.35, "time_cost": 4},
	],
}

var travel_routes = {
	"Hometown": {"Iron_Heights": {"time": 2, "cost": 50}},
	"Iron_Heights":  {"Hometown": {"time": 2, "cost": 50}, "The_Citadel": {"time": 3, "cost": 80}},
	"The_Citadel":    {"Iron_Heights": {"time": 3, "cost": 80}},
}

func can_travel_to(city: String) -> bool:
	return city in travel_routes[current_city]

func travel_to(city: String):
	var route = travel_routes[current_city][city]
	gold -= route.cost
	turn += route.time
	threat += route.time * 5
	current_city = city
