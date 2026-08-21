extends Node

signal piso_cambiado(nuevo_piso: int)

var piso_actual: int = 0
var pisos: Dictionary = {}
var ultima_posicion: Dictionary = {}  # int -> Vector2

var _camara: Camera2D = null

const SUPERFICIE_CENTRO := Vector2(2048, 1024)
const SUPERFICIE_LIMITES := Rect2(0, 0, 4096, 2048)


signal modo_tipos_cambiado(activo: bool)
var modo_tipos_activo: bool = false

func registrar_piso(indice: int, piso_node: Node):
	pisos[indice] = piso_node

func registrar_camara(camara: Camera2D):
	_camara = camara

func cambiar_a_piso(indice: int):
	if indice == piso_actual:
		return
	if indice != 0 and not pisos.has(indice):
		return
	if _camara:
		ultima_posicion[piso_actual] = _camara.position
	piso_actual = indice
	if _camara == null:
		return
	var centro: Vector2
	var limites: Rect2
	if indice == 0:
		centro = SUPERFICIE_CENTRO
		limites = SUPERFICIE_LIMITES
	else:
		var piso = pisos[indice]
		limites = Rect2(
			piso.limite_izq(), piso.limite_arriba(),
			piso.limite_der() - piso.limite_izq(),
			piso.limite_abajo() - piso.limite_arriba()
		)
		centro = piso.centro_region()
	var pos_final = ultima_posicion.get(indice, centro)
	_camara.ir_a_region(pos_final, limites)
	piso_cambiado.emit(indice)

func piso_de_nodo(indice: int) -> Node:
	return pisos.get(indice)
	
func alternar_modo_tipos():
	modo_tipos_activo = not modo_tipos_activo
	modo_tipos_cambiado.emit(modo_tipos_activo)

func desactivar_modo_tipos():
	if modo_tipos_activo:
		modo_tipos_activo = false
		modo_tipos_cambiado.emit(false)
