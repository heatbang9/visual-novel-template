extends MinigameBase

var player_cards: Array[Dictionary] = []
var enemy_cards: Array[Dictionary] = []
var player_health: int = 100
var enemy_health: int = 100
var current_turn: String = "player"
var card_deck: Array[Dictionary] = []

func _ready() -> void:
	game_name_key = "card_battle_name"
	game_desc_key = "card_battle_desc"
	time_limit = 120.0
	super._ready()

func setup_game() -> void:
	create_card_deck()
	setup_battlefield()
	deal_initial_cards()

func create_card_deck() -> Dictionary:
	var card_types = [
		{"name": "공격", "type": "attack", "cost": 2, "damage": 25},
		{"name": "치료", "type": "heal", "cost": 3, "heal": 20},
		{"name": "방어", "type": "shield", "cost": 1, "shield": 15},
		{"name": "강공격", "type": "heavy", "cost": 4, "damage": 40}
	]
	
	var deck = []
	for i in range(10 + difficulty * 3):
		var card_type = get_random_choice(card_types)
		var card = {
			"id": i,
			"name": card_type.name,
			"type": card_type.type,
			"cost": card_type.cost + get_random_int(-1, 1),
			"value": card_type.get("damage", card_type.get("heal", card_type.get("shield", 10)))
		}
		deck.append(card)
	
	return {"deck": deck}

func setup_battlefield() -> void:
	var player_health_label = Label.new()
	player_health_label.name = "PlayerHealthLabel"
	player_health_label.text = "Player HP: %d" % player_health
	player_health_label.position = Vector2(50, 50)
	player_health_label.size = Vector2(200, 30)
	game_layer.add_child(player_health_label)
	
	var enemy_health_label = Label.new()
	enemy_health_label.name = "EnemyHealthLabel"
	enemy_health_label.text = "Enemy HP: %d" % enemy_health
	enemy_health_label.position = Vector2(350, 50)
	enemy_health_label.size = Vector2(200, 30)
	game_layer.add_child(enemy_health_label)

func deal_initial_cards() -> void:
	var deck_data = create_card_deck()
	card_deck = deck_data.deck.duplicate()
	
	for i in range(5):
		if card_deck.size() > 0:
			var card = card_deck.pop_back()
			player_cards.append(card)
			create_card_button(card, i)

func create_card_button(card: Dictionary, index: int) -> void:
	var button = Button.new()
	button.text = "%s\n%s: %d" % [card.name, card.type, card.value]
	button.size = Vector2(80, 60)
	button.position = Vector2(50 + index * 90, 400)
	button.pressed.connect(_on_card_played.bind(card, button))
	game_layer.add_child(button)

func _on_card_played(card: Dictionary, button: Button) -> void:
	if not is_game_active or current_turn != "player":
		return
	
	match card.type:
		"attack":
			enemy_health -= card.value
			update_score(current_score + 10)
		"heal":
			player_health += card.value
		"shield":
			pass
		"heavy":
			enemy_health -= card.value
			update_score(current_score + 15)
	
	button.queue_free()
	player_cards.erase(card)
	update_health_display()
	
	if enemy_health <= 0:
		end_game(true)
	else:
		current_turn = "enemy"
		enemy_turn()

func enemy_turn() -> void:
	await get_tree().create_timer(1.0).timeout
	if is_game_active:
		var damage = get_random_int(15, 30)
		player_health -= damage
		update_health_display()
		
		if player_health <= 0:
			end_game(false)
		else:
			current_turn = "player"

func update_health_display() -> void:
	var player_label = game_layer.get_node("PlayerHealthLabel")
	var enemy_label = game_layer.get_node("EnemyHealthLabel")
	
	if player_label:
		player_label.text = "Player HP: %d" % player_health
	if enemy_label:
		enemy_label.text = "Enemy HP: %d" % enemy_health