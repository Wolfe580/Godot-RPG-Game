# InventoryUI.gd
class_name InventoryUI
extends Control

@onready var inventory: InventorySystem = get_node("/root/GlobalInventorySystem")
@onready var category_list: ItemList
@onready var item_list: ItemList
@onready var item_details: VBoxContainer
@onready var save_status_label: Label


var current_category: String = ""

func _ready() -> void:
	inventory.inventory_changed.connect(_on_inventory_changed)
	setup_categories()
	inventory.save_completed.connect(_on_save_completed)
	inventory.load_completed.connect(_on_load_completed)
	# Try to load saved inventory when the game starts
	inventory.load_inventory()
	
func setup_categories() -> void:
	category_list.clear()
	# Add your categories here
	category_list.add_item("WEAPONS")
	category_list.add_item("APPAREL")
	category_list.add_item("AID")
	category_list.add_item("MISC")

func _on_category_selected(index: int) -> void:
	current_category = category_list.get_item_text(index)
	update_item_list()

func update_item_list() -> void:
	item_list.clear()
	var category_items = inventory.get_items_by_category(current_category)
	
	for item in category_items:
		var display_text = "%s (%d)" % [item.name, item.quantity]
		item_list.add_item(display_text)

func _on_inventory_changed() -> void:
	update_item_list()

func _on_save_completed() -> void:
	if save_status_label:
		save_status_label.text = "Game Saved"
		# Create a timer to clear the status
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func(): save_status_label.text = "")

func _on_load_completed() -> void:
	if save_status_label:
		save_status_label.text = "Game Loaded"
		var timer = get_tree().create_timer(2.0)
	update_item_list()
