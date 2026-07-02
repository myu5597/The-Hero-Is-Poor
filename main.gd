extends Control

func update_quest_buttons():
	var city_quests = GameManager.quests[GameManager.current_city]
	var buttons = [
		$VBoxContainer/QuestButtons/EasyButton,
		$VBoxContainer/QuestButtons/MediumButton,
		$VBoxContainer/QuestButtons/HardButton,
	]
	for i in range(city_quests.size()):
		var q = city_quests[i]
		buttons[i].text = "%s\n%dg | %d%% | %dt" % [
			q.name,
			q.reward,
			int(q.success_chance * 100),
			q.time_cost
		]
		buttons[i].disabled = false

	# hide unused buttons if a city has fewer than 3 quests
	for i in range(city_quests.size(), buttons.size()):
		buttons[i].disabled = true
		buttons[i].text = "---"

func _ready():
	$VBoxContainer/QuestButtons/EasyButton.pressed.connect(_on_quest.bind(0))
	$VBoxContainer/QuestButtons/MediumButton.pressed.connect(_on_quest.bind(1))
	$VBoxContainer/QuestButtons/HardButton.pressed.connect(_on_quest.bind(2))
	$VBoxContainer/EndTurnButton.pressed.connect(_on_end_turn)
	$VBoxContainer/MapButton.pressed.connect(_on_open_map)
	$VBoxContainer/ShopButton.pressed.connect(_on_open_shop)
	update_quest_buttons()
	update_hud()
	check_game_over()
	log_message("You are in %s. Choose a quest." % GameManager.current_city, "white")
	
	
func _on_open_shop():
	get_tree().change_scene_to_file("res://shop.tscn")
	
func _on_quest(index: int):
	var q = GameManager.quests[GameManager.current_city][index]
	var roll = randf()
	var effective_chance = min(q.success_chance + GameManager.get_success_bonus(), 0.95)
	GameManager.turn += q.time_cost
	GameManager.threat += q.time_cost * 1

	if roll <= effective_chance:
		GameManager.gold += q.reward
		log_message("[Turn %d] %s — SUCCESS → +%dg" % [GameManager.turn, q.name, q.reward], "green")
	else:
		log_message("[Turn %d] %s — FAIL → +0g" % [GameManager.turn, q.name], "red")

	update_hud()
	check_game_over()

func _on_end_turn():
	GameManager.turn += 1
	GameManager.threat += 1
	log_message("--- Turn ended. Threat grows... ---", "orange")
	update_hud()
	check_game_over()

func _on_open_map():
	get_tree().change_scene_to_file("res://map.tscn")

func update_hud():
	$VBoxContainer/HUD/GoldLabel.text = "Gold: %d" % GameManager.gold
	$VBoxContainer/HUD/TurnLabel.text = "Turn: %d | City: %s" % [GameManager.turn, GameManager.current_city]
	$VBoxContainer/HUD/ThreatLabel.text = "Threat: %d / 100" % GameManager.threat
	$VBoxContainer/HUD/BonusLabel.text = "Bonus: +%d%%" % int(GameManager.get_success_bonus() * 100)

func check_game_over():
	if GameManager.threat >= 100:
		log_message("=== DEMON LORD GROWS TOO POWERFUL — GAME OVER ===", "red")
		$VBoxContainer/QuestButtons/EasyButton.disabled = true
		$VBoxContainer/QuestButtons/MediumButton.disabled = true
		$VBoxContainer/QuestButtons/HardButton.disabled = true
		$VBoxContainer/EndTurnButton.disabled = true
		$VBoxContainer/MapButton.disabled = true

func log_message(text: String, color: String):
	var lg = $VBoxContainer/LogBox
	lg.append_text("[color=%s]%s[/color]\n" % [color, text])
	
