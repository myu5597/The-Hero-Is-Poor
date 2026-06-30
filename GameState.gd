extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
var gold: int = 500
var turn: int = 0
var threat: int = 0          # 0–100; hits 100 = final battle
var party: Array[HeroData]
var gear_owned: Array[ItemData]
