extends Control

func _ready():
	$VBoxContainer/BackButton.pressed.connect(_on_back)
	$VBoxContainer/TitleLabel.text = "Shop — %s" % GameManager.current_city
	update_labels()
	build_item_list()

func build_item_list():
	var container = $VBoxContainer/ItemList
	for child in container.get_children():
		child.queue_free()

	var inventory = GameManager.shop_inventory[GameManager.current_city]
	for item in inventory:
		var btn = Button.new()
		var current = GameManager.equipped[item.slot]
		var is_equipped = current != null and current.name == item.name
		var is_upgrade = current != null and not is_equipped

		if is_equipped:
			btn.text = "%s — EQUIPPED" % item.name
			btn.disabled = true
		elif is_upgrade:
			btn.text = "%s | %dg | +%d%% (replaces %s)" % [item.name, item.cost, int(item.bonus * 100), current.name]
			btn.pressed.connect(_on_buy.bind(item))
		else:
			btn.text = "%s | %dg | +%d%% success" % [item.name, item.cost, int(item.bonus * 100)]
			btn.pressed.connect(_on_buy.bind(item))

		container.add_child(btn)

func _on_buy(item: Dictionary):
	if GameManager.buy_item(item):
		log_purchase("Bought %s! Success bonus now +%d%%" % [item.name, int(GameManager.get_success_bonus() * 100)])
	else:
		log_purchase("Not enough gold for %s." % item.name)
	update_labels()
	build_item_list()  # rebuild to show OWNED state

func update_labels():
	$VBoxContainer/GoldLabel.text = "Gold: %d" % GameManager.gold
	$VBoxContainer/BonusLabel.text = "Current bonus: +%d%%" % int(GameManager.get_success_bonus() * 100)
	var weapon = GameManager.equipped["weapon"].name if GameManager.equipped["weapon"] else "None"
	var armor = GameManager.equipped["armor"].name if GameManager.equipped["armor"] else "None"
	$VBoxContainer/OwnedLabel.text = "Weapon: %s | Armor: %s" % [weapon, armor]
	
func log_purchase(text: String):
	# reuse OwnedLabel temporarily, or add a separate MessageLabel if you prefer
	$VBoxContainer/TitleLabel.text = text

func _on_back():
	get_tree().change_scene_to_file("res://main.tscn")
