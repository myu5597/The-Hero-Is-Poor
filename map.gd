extends Control

var selected_city = ""

func _ready():
	$BackButton.pressed.connect(_on_back)
	$Cities/Hometown.pressed.connect(_on_city_selected.bind("Hometown"))
	$Cities/Iron_Heights.pressed.connect(_on_city_selected.bind("Iron_Heights"))
	$Cities/The_Citadel.pressed.connect(_on_city_selected.bind("The_Citadel"))
	$InfoPanel.hide()

	# Grey out current city
	get_node("Cities/" + GameManager.current_city).disabled = true
	
	if GameManager.threat >= 100:
		$Cities/Hometown.disabled = true
		$Cities/Iron_Heights.disabled = true
		$Cities/The_Citadel.disabled = true

func _on_city_selected(city: String):
	if not GameManager.can_travel_to(city):
		$InfoPanel/VBoxContainer/CityLabel.text = "No direct route to %s" % city
		$InfoPanel/VBoxContainer/CostLabel.text = ""
		$InfoPanel/VBoxContainer/TravelButton.disabled = true
		$InfoPanel.show()
		return

	selected_city = city
	var route = GameManager.travel_routes[GameManager.current_city][city]
	$InfoPanel/VBoxContainer/CityLabel.text = "Travel to %s" % city
	$InfoPanel/VBoxContainer/CostLabel.text = "Cost: %dg | Time: %d turns" % [route.cost, route.time]
	$InfoPanel/VBoxContainer/TravelButton.disabled = false
	$InfoPanel/VBoxContainer/TravelButton.pressed.connect(_on_travel, CONNECT_ONE_SHOT)
	$InfoPanel.show()

func _on_travel():
	GameManager.travel_to(selected_city)
	get_tree().change_scene_to_file("res://main.tscn")

func _on_back():
	get_tree().change_scene_to_file("res://main.tscn")
