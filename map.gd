extends Control

var selected_city = ""

func _ready():
	$BackButton.pressed.connect(_on_back)
	$Cities/Hometown.pressed.connect(_on_city_selected.bind("Hometown"))
	$Cities/Iron_Heights.pressed.connect(_on_city_selected.bind("Iron Heights"))
	$Cities/The_Citadel.pressed.connect(_on_city_selected.bind("The Citadel"))
	$InfoPanel.hide()
	get_node("Cities/" + city_to_node_name(GameManager.current_city)).disabled = true

	for city in ["Hometown", "Iron Heights", "The Citadel"]:
		if city == GameManager.current_city:
			continue
		if not GameManager.can_travel_to(city):
			get_node("Cities/" + city_to_node_name(city)).modulate = Color(1, 0.4, 0.4)
		
func city_to_node_name(city: String) -> String:
	return city.replace(" ", "_")
	
func _on_city_selected(city: String):
	if city == GameManager.current_city:
		return

	$InfoPanel.show()
	$InfoPanel/VBoxContainer/TravelButton.disabled = true

	if city not in GameManager.travel_routes[GameManager.current_city]:
		$InfoPanel/VBoxContainer/CityLabel.text = "No direct route to %s" % city
		$InfoPanel/VBoxContainer/CostLabel.text = ""
		return

	var route = GameManager.travel_routes[GameManager.current_city][city]

	if GameManager.gold < route.cost:
		$InfoPanel/VBoxContainer/CityLabel.text = "Can't afford travel to %s" % city
		$InfoPanel/VBoxContainer/CostLabel.text = "Need %dg, have %dg" % [route.cost, GameManager.gold]
		return

	if GameManager.threat + route.time >= GameManager.MAX_THREAT:
		$InfoPanel/VBoxContainer/CityLabel.text = "Not enough time to reach %s" % city
		$InfoPanel/VBoxContainer/CostLabel.text = "Would hit threat limit mid-travel"
		return

	selected_city = city
	$InfoPanel/VBoxContainer/CityLabel.text = "Travel to %s" % city
	$InfoPanel/VBoxContainer/CostLabel.text = "Cost: %dg | Time: %d turns" % [route.cost, route.time]
	$InfoPanel/VBoxContainer/TravelButton.disabled = false
	$InfoPanel/VBoxContainer/TravelButton.pressed.connect(_on_travel, CONNECT_ONE_SHOT)

func _on_travel():
	if GameManager.travel_to(selected_city):
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		$InfoPanel/VBoxContainer/CityLabel.text = "Not enough gold to travel!"
		$InfoPanel/VBoxContainer/TravelButton.disabled = true

func _on_back():
	get_tree().change_scene_to_file("res://main.tscn")
