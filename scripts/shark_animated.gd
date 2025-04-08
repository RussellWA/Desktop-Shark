extends AnimatedSprite2D

@export var isHover: bool = false

func _ready():
	self.play("idle")

func is_hovered() -> bool:
	var mouse_pos = get_local_mouse_position()
	var frame_texture = sprite_frames.get_frame_texture(animation, frame)
	var texture_rect = Rect2(Vector2.ZERO, frame_texture.get_size())
	return texture_rect.has_point(mouse_pos)

func get_sprite_texture() -> Texture2D:
	return sprite_frames.get_frame_texture(animation, frame)

func get_sprite_size() -> Vector2:
	var texture = get_sprite_texture()
	return texture.get_size() * scale
	
func get_sprite_rect() -> Rect2:
	var sprite_size = get_sprite_size()
	return Rect2(position - (sprite_size / 2), sprite_size)
