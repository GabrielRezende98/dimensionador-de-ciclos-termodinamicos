extends Node2D

#===============================================================================
# * Parte que controla os elementos da cena
#===============================================================================
@onready var LineEditRegEx = RegEx.new()
var old_text_prop = ""
var propriedades = {
	"Temperatura (K)" : "T",
	"Entalpia (kJ/kg)" : "H",
	"Pressão relativa" : "P",
	"Energia interna (kJ/kg)" : "U",
	"Volume específico relativo" : "V",
	"Entropia (kJ/kg.K)" : "S"
}

func preencher_option_buttons():
	for p in propriedades.keys():
		$PropOptionButton.add_item(p)
		
func _ready() -> void:
	LineEditRegEx.compile("^[0-9.]*$")
	preencher_option_buttons()

func _on_voltar_button_button_down():
	$"../Background".adjust_buttons()
	$"../Background".show()
	$".".hide()

func _on_prop_1_line_edit_text_changed(new_text):
	var NumberLineEdit = $PropLineEdit
	if LineEditRegEx.search(new_text):
		old_text_prop = str(new_text)
	else:
		NumberLineEdit.text = old_text_prop

func _on_limpar_button_button_down():
	$ResultadosLabel.text = ""

#===============================================================================
# * Parte que realiza os cálculos
#===============================================================================
var output

func load_data(csv_file):
	var data = {"T": [], "H": [], "P": [], "U": [], "V": [], "S": []}
	var file = FileAccess.open(csv_file, FileAccess.READ)

	if file:
		var line = file.get_line() # Lê a linha do cabeçalho
		while not file.eof_reached():
			line = file.get_line().strip_edges()
			var values = line.split(",")
			if len(values) == 6:
				data["T"].append(values[0].to_float())
				data["H"].append(values[1].to_float())
				data["P"].append(values[2].to_float())
				data["U"].append(values[3].to_float())
				data["V"].append(values[4].to_float())
				data["S"].append(values[5].to_float())
		file.close()
	else:
		print("Arquivo não encontrado")
		
	return data

func linear_interpolation(x_values, y_values, x):
	for i in range(len(x_values) - 1):
		if x_values[i] <= x and x <= x_values[i + 1]:
			var x0 = x_values[i]
			var x1 = x_values[i + 1]
			var y0 = y_values[i]
			var y1 = y_values[i + 1]
			return y0 + (y1 - y0) * (x - x0) / (x1 - x0)
	return null # Valor fora do intervalo

func interpolate(data, target, input_key, input_value):
	if not data.has(target) or not data.has(input_key):
		print("Chaves fornecidas não são válidas.")
		return null
	var x_values = data[input_key]
	var y_values = data[target]
	return linear_interpolation(x_values, y_values, input_value)

func call_prop(a, b, c):
	var data = load_data("res://tabela_a17.csv")
	var target = a # Chave de saída desejada
	var input_key = b # Chave de entrada
	var input_value = c # Valor de entrada
	var result = interpolate(data, target, input_key, input_value)
	return str(result)


func calculate(prop, value):
	#---------------------------------------------------------------------
	# * Cálculo das propriedades
	#---------------------------------------------------------------------
	var T = float(call_prop("T", prop, value))
	var H = float(call_prop("H", prop, value))
	var P = float(call_prop("P", prop, value))
	var U = float(call_prop("U", prop, value))
	var V = float(call_prop("V", prop, value))
	var S = float(call_prop("S", prop, value))
	
	#---------------------------------------------------------------------
	# * Ajuste de unidade e casas decimais
	#---------------------------------------------------------------------
	T = snapped(T, 0.0001)
	H = snapped(H, 0.0001)
	P = snapped(P, 0.0001)
	U = snapped(U, 0.0001)
	S = snapped(S, 0.0001)

	$ResultadosLabel.text  = "[u]Resultados:[/u]\n\nT = %s [K]\n\nh = %s [kJ/kg]\n\nPr = %s\n\nu = %s [kJ/kg]\n\nvr = %s\n\ns = %s [kJ/kg.K]" % [T, H, P, U, V, S]

func _on_calcular_button_button_down():
	if $PropLineEdit.text == "":
		return
	var prop = (propriedades[$PropOptionButton.text])
	var value = float($PropLineEdit.text)

	calculate(prop, value)
