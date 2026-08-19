extends Node

## Autoload: coordina qué piso se está viendo, mueve la cámara entre
## pisos, y guarda el registro de los nodos Piso ya creados.

signal piso_cambiado(nuevo_piso: int)

var piso_actual: int = 0  # 0 = superficie
var pisos: Dictionary = {}  # int -> nodo Piso

var _camara: Camera2D = null

const SUPERFICIE_CENTRO := Vector2(2048, 1024)
const SUPERFICIE_LIMITES := Rect2(0, 0, 4096, 2048)

func registrar_piso(indice: int, piso_node: Node):
	pisos[indice] = piso_node

func registrar_camara(camara: Camera2D):
	_camara = camara

func cambiar_a_piso(indice: int):
	if indice == piso_actual:
		return
	if indice != 0 and not pisos.has(indice):
		return # ese piso todavía no existe
	piso_actual = indice
	if _camara == null:
		return
	if indice == 0:
		_camara.ir_a_region(SUPERFICIE_CENTRO, SUPERFICIE_LIMITES)
	else:
		var piso = pisos[indice]
		var limites = Rect2(
			piso.limite_izq(), piso.limite_arriba(),
			piso.limite_der() - piso.limite_izq(),
			piso.limite_abajo() - piso.limite_arriba()
		)
		_camara.ir_a_region(piso.centro_region(), limites)
	piso_cambiado.emit(indice)

func piso_de_nodo(indice: int) -> Node:
	return pisos.get(indice)
