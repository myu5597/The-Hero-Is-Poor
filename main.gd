extends Control

func update_quest_buttons():
	var exhausted = GameManager.energy <= 0 or GameManager.is_forced_resting
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
			int((min(q.success_chance + GameManager.get_success_bonus(), 0.95)) * 100),
			q.time_cost
		]
		buttons[i].disabled = exhausted

	for i in range(city_quests.size(), buttons.size()):
		buttons[i].disabled = true
		buttons[i].text = "---"

	# also lock rest button during forced rest
	$VBoxContainer/RestContainer/RestButton.disabled = GameManager.is_forced_resting
	if GameManager.is_forced_resting:
		$VBoxContainer/RestContainer/RestInfoLabel.text = "Forced rest: %d turns remaining" % GameManager.forced_rest_turns_remaining

func _ready():
	$VBoxContainer/QuestButtons/EasyButton.pressed.connect(_on_quest.bind(0))
	$VBoxContainer/QuestButtons/MediumButton.pressed.connect(_on_quest.bind(1))
	$VBoxContainer/QuestButtons/HardButton.pressed.connect(_on_quest.bind(2))
	$VBoxContainer/MapButton.pressed.connect(_on_open_map)
	$VBoxContainer/ShopButton.pressed.connect(_on_open_shop)
	$VBoxContainer/RestContainer/RestButton.pressed.connect(_on_rest)
	$VBoxContainer/RestContainer/RestSpinBox.value_changed.connect(_on_rest_turns_changed)

	update_quest_buttons()
	update_hud()
	check_game_over()
	log_message("You are in %s. Choose a quest." % GameManager.current_city, "white")

func _on_rest_turns_changed(value: float):
	var turns = int(value)
	var recovery = min(GameManager.ENERGY_REST_RECOVERY * turns, GameManager.MAX_ENERGY - GameManager.energy)
	var threat_cost = turns
	$VBoxContainer/RestContainer/RestInfoLabel.text = "+%d energy | Threat +%d" % [recovery, threat_cost]

func _on_rest():
	var turns = int($VBoxContainer/RestContainer/RestSpinBox.value)
	GameManager.rest(turns)
	log_message("Rested for %d turns. Energy: %d | Threat +%d." % [turns, GameManager.energy, turns], "white")
	$VBoxContainer/RestContainer/RestSpinBox.value = 1
	update_hud()
	check_game_over()
	update_quest_buttons()
	
func _on_open_shop():
	get_tree().change_scene_to_file("res://shop.tscn")
	
func _on_quest(index: int):
	var q = GameManager.quests[GameManager.current_city][index]

	if GameManager.energy <= 0:
		GameManager.check_exhaustion()
		log_message("Collapsed from exhaustion! Forced to rest %d turns. Threat +%d." % [GameManager.FORCED_REST_TURNS, GameManager.FORCED_REST_TURNS], "red")
		return

	var roll = randf()
	var effective_chance = min(q.success_chance + GameManager.get_success_bonus(), 0.95)
	GameManager.turn += q.time_cost
	GameManager.threat += q.time_cost

	var success = roll <= effective_chance
	var drain = GameManager.get_energy_drain(success)
	GameManager.energy = max(GameManager.energy - drain, 0)

	if success:
		GameManager.gold += q.reward
		log_message("[Turn %d] %s — SUCCESS → +%dg | Energy -%d" % [GameManager.turn, q.name, q.reward, drain], "green")
	else:
		log_message("[Turn %d] %s — FAIL → +0g | Energy -%d" % [GameManager.turn, q.name, drain], "red")

	update_hud()
	check_game_over()
	update_quest_buttons()

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
	$VBoxContainer/HUD/EnergyLabel.text = "Energy: %d / %d" % [GameManager.energy, GameManager.MAX_ENERGY]

func check_game_over():
	if GameManager.threat >= 100:
		log_message("=== DEMON LORD GROWS TOO POWERFUL — GAME OVER ===", "red")
		$VBoxContainer/QuestButtons/EasyButton.disabled = true
		$VBoxContainer/QuestButtons/MediumButton.disabled = true
		$VBoxContainer/QuestButtons/HardButton.disabled = true
		$VBoxContainer/RestContainer/RestButton.disabled = true
		$VBoxContainer/MapButton.disabled = true

func log_message(text: String, color: String):
	var lg = $VBoxContainer/LogBox
	lg.append_text("[color=%s]%s[/color]\n" % [color, text])
	
