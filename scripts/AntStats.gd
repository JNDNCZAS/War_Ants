class_name AntStats
extends Resource

@export var nombre: String = ""
@export var especie: String = ""
@export var casta: String = ""

@export var velocidad: float = 100.0
@export var integrantes_max: int = 50
@export var vida_por_hormiga: float = 10.0
@export var daño: float = 10.0
@export var defensa: float = 0.8
@export var capacidad_carga: float = 10.0
@export var reduccion_velocidad_carga: float = 0.5
@export var tiempo_recoleccion: float = 3.0
@export var tiempo_descarga: float = 2.0
@export var costo_hojas: float=50
@export var tiempo_creacion: float = 10.0

@export var sprite_frames: SpriteFrames
