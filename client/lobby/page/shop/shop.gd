extends "res://lobby/page/page.gd"

export(NodePath) onready var bottom_left = get_node(bottom_left)

func _ready():
	scroll_max_y = 100
	scroll_min_y = -3200

func _on_Button_pressed():
	$BuyCard.show()

func _on_TextureRect_pressed():
	$BuyItem.show()

func _on_BuyCoin_pressed():
	$BuyCoin.show()
	
func _on_BuyCash_pressed():
	$BuyCash.show()

func _on_TextureButton_pressed():
	$BuyCash.hide()
