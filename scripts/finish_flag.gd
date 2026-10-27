class_name FinishFlag
extends Area2D
## Scene: res://scenes/finish_flag.tscn
## Bendera finish. Hanya bisa diselesaikan setelah semua anggota ditemui.
## Gambar: node Sprite (AnimatedSprite2D: wave).

signal reached(flag: FinishFlag)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(b: Node2D) -> void:
	if b is Player:
		reached.emit(self)
