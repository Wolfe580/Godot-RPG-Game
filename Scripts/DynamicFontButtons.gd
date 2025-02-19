extends Button

@export var min_font_size: int = 10  # Minimum font size
@export var max_font_size: int = 24  # Maximum font size

func _ready():
	connect("resized", Callable(self, "_on_resized"))
	adjust_font_size()

func _on_resized():
	adjust_font_size()

func adjust_font_size():
	var font = get_theme_font("font")
	var font_size = max_font_size

	# Reduce font size until the text fits within the button
	while font_size >= min_font_size:
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		if text_size <= size.x:
			break
		font_size -= 1

	# Apply the adjusted font size
	add_theme_font_size_override("font_size", font_size)
