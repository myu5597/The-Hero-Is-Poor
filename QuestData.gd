extends Node

var quest_name: String
var gold_reward: int
var time_cost: int            # turns consumed
var success_chance: float     # 0.0–1.0, modified by party power
var required_class: String    # "" = any  ← Phase 2
