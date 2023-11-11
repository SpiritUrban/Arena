# Наследование от базового класса Node.
extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry

const Player = preload("res://player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

# Функция для обработки входящих событий.
func _unhandled_input(event):
	# Проверяем, было ли только что нажато действие "quit".
	if Input.is_action_just_pressed("quit"):
		# Если это так, завершаем выполнение приложения.
		get_tree().quit()

func _on_host_button_pressed():
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	pass # Replace with function body.

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
