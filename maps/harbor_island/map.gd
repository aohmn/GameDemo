extends Node3D

const TerrainBuilder: Script = preload("res://maps/harbor_island/builders/terrain_builder.gd")
const PierBuilder: Script = preload("res://maps/harbor_island/builders/pier_builder.gd")
const PropBuilder: Script = preload("res://maps/harbor_island/builders/prop_builder.gd")


func _ready() -> void:
	TerrainBuilder.build(self)
	PierBuilder.build(self)
	PropBuilder.build(self)
