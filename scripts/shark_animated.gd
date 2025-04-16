extends AnimatedSprite2D

signal pet_or_hit_anim_done()

var last_velocity = Vector2.ZERO

func _ready():
	self.play("idle")

func is_hovered() -> bool:
	var mouse_pos = get_local_mouse_position()
	var frame_texture = get_sprite_texture()
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

func _on_sprite_area_pet_or_hit(is_pet: bool) -> void:
	if is_pet:
		pass
		# play animation
	else:
		pass
		# play animation

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "pet" or anim_name == "hit":
		self.play("idle")
		pet_or_hit_anim_done.emit()
