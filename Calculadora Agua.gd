extends Node2D

#===============================================================================
# * Parte que controla os elementos da cena
#===============================================================================
@onready var LineEditRegEx = RegEx.new()
var old_text_prop1 = ""
var old_text_prop2 = ""
var propriedades = {
	"Temperatura (ºC)" : "T",
	"Entalpia (kJ/kg)" : "H",
	"Entropia (kJ/kg.K)" : "S",
	"Pressão (kPa)" : "P",
	"Densidade (kg/m³)" : "D",
	"Energia interna (kJ/kg)" : "U",
	"Líquido Saturado" : "LS",
	"Vapor Saturado" : "VS"
}

func preencher_option_buttons():
	for p in propriedades.keys():
		$Prop1OptionButton.add_item(p)
		$Prop2OptionButton.add_item(p)
		
func _ready() -> void:
	LineEditRegEx.compile("^[0-9.]*$")
	preencher_option_buttons()

func _on_voltar_button_button_down():
	$"../Background".adjust_buttons()
	$"../Background".show()
	$".".hide()

func _on_prop_1_line_edit_text_changed(new_text):
	var NumberLineEdit = $Prop1LineEdit
	if LineEditRegEx.search(new_text):
		old_text_prop1 = str(new_text)
	else:
		NumberLineEdit.text = old_text_prop1

func _on_prop_2_line_edit_text_changed(new_text):
	var NumberLineEdit = $Prop2LineEdit
	if LineEditRegEx.search(new_text):
		old_text_prop2 = str(new_text)
	else:
		NumberLineEdit.text = old_text_prop2

func _on_limpar_button_button_down():
	$ResultadosLabel.text = ""

func _on_prop_1_option_button_item_selected(index):
	if $Prop1OptionButton.text == "Líquido Saturado" or $Prop1OptionButton.text == "Vapor Saturado":
		$Prop1LineEdit.text = ""
		$Prop1LineEdit.editable = false
	else:
		$Prop1LineEdit.editable = true

func _on_prop_2_option_button_item_selected(index):
	if $Prop2OptionButton.text == "Líquido Saturado" or $Prop2OptionButton.text == "Vapor Saturado":
		$Prop2LineEdit.text = ""
		$Prop2LineEdit.editable = false
	else:
		$Prop2LineEdit.editable = true


#===============================================================================
# * Parte que realiza os cálculos
#===============================================================================
var output

func call_prop(a, b, c, d, e, f):
	#Define os dados de entrada, chama o exe passando-os como argumento e obtem sua resposta
	var path = "./PropCalc.exe"
	var input = [a, b, c, d, e, f] #argumentos
	output = []
	OS.execute(path, input, output, false)
	return str(output[0])

func calculate(prop1, value1, prop2, value2):
	#---------------------------------------------------------------------
	# * Cálculo das propriedades
	#---------------------------------------------------------------------
	var T = float(call_prop("T", prop1, value1, prop2, value2, "Water"))
	var H = float(call_prop("H", prop1, value1, prop2, value2, "Water"))
	var S = float(call_prop("S", prop1, value1, prop2, value2, "Water"))
	var P = float(call_prop("P", prop1, value1, prop2, value2, "Water"))
	var D = float(call_prop("D", prop1, value1, prop2, value2, "Water"))
	var U = float(call_prop("U", prop1, value1, prop2, value2, "Water"))
	
	# Título
	var X
	var sl = float(call_prop('S', 'P|liquid', P, 'Q', 0, "Water"))
	var sv = float(call_prop('S', 'P|gas', P, 'Q', 1, "Water"))
	if (S < sv):
		X = clamp((S - sl)/(sv - sl), 0, 1)
	else:
		X = 'Saída superaquecida'
	
	#---------------------------------------------------------------------
	# * Ajuste de unidade e casas decimais
	#---------------------------------------------------------------------
	T = snapped(T - 273.15, 0.0001)
	H = snapped(H/1000, 0.0001)
	S = snapped(S/1000, 0.0001)
	P = snapped(P/1000, 0.0001)
	D = snapped(D, 0.0001)
	U = snapped(U/1000, 0.0001)
	if X is float:
		X = snapped(X * 100, 0.01)
	
	$ResultadosLabel.text  = "[u]Resultados:[/u]\n\nT = %s [ºC]\n\nh = %s [kJ/kg]\n\ns = %s [kJ/kg.K]\n\nP = %s [kPa]\n\nD = %s [kg/m³]\n\nu = %s [kJ/kg]\n\nx = %s [%%]" % [T, H, S, P, D, U, X]

func _on_calcular_button_button_down():
	if (($Prop1OptionButton.text != "Líquido Saturado" and $Prop1OptionButton.text != "Vapor Saturado" and $Prop1LineEdit.text == "") or ($Prop2OptionButton.text != "Líquido Saturado" and $Prop2OptionButton.text != "Vapor Saturado" and $Prop2LineEdit.text == "") or $Prop1OptionButton.text == $Prop2OptionButton.text):
		return
	var prop1 = (propriedades[$Prop1OptionButton.text])
	var prop2 = (propriedades[$Prop2OptionButton.text])
	var value1 = float($Prop1LineEdit.text)
	var value2 = float($Prop2LineEdit.text)
	
	# Ajuste dos dados de entrada
	if prop1 == "H" or prop1 == "S" or prop1 == "P" or prop1 == "U":
		value1 *= 1000
	elif prop1 == "T":
		value1 += 273.15
	elif prop1 == "LS":
		prop1 = "Q"
		value1 = 0
	elif prop1 == "VS":
		prop1 = "Q"
		value1 = 1
		
	if prop2 == "H" or prop2 == "S" or prop2 == "P" or prop2 == "U":
		value2 *= 1000
	elif prop2 == "T":
		value2 += 273.15
	elif prop2 == "LS":
		prop2 = "Q"
		value2 = 0
	elif prop2 == "VS":
		prop2 = "Q"
		value2 = 1
		
	calculate(prop1, value1, prop2, value2)
