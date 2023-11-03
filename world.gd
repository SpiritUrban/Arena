# Наследование от базового класса Node.
extends Node

# Функция для обработки входящих событий.
func _unhandled_input(event):
	# Проверяем, было ли только что нажато действие "quit".
	if Input.is_action_just_pressed("quit"):
		# Если это так, завершаем выполнение приложения.
		get_tree().quit()
