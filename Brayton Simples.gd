extends Node2D

#===============================================================================
# * Parte que controla os elementos da cena
#===============================================================================
@onready var LineEditRegEx = RegEx.new()
var old_text_tempinf = ""
var old_text_tempsup = ""
var old_text_razaodepressao = ""
var old_text_efcompressor = ""
var old_text_efturbina = ""

func _ready() -> void:
	LineEditRegEx.compile("^[0-9.]*$")

func _on_voltar_button_button_down():
	$"../Background".adjust_buttons()
	$"../Background".show()
	$".".hide()

func _on_temp_inf_line_edit_text_changed(new_text):
	var NumberLineEdit = $TempInfLineEdit
	if LineEditRegEx.search(new_text):
		old_text_tempinf = str(new_text)
	else:
		NumberLineEdit.text = old_text_tempinf

func _on_temp_sup_line_edit_text_changed(new_text):
	var NumberLineEdit = $TempSupLineEdit
	if LineEditRegEx.search(new_text):
		old_text_tempsup = str(new_text)
	else:
		NumberLineEdit.text = old_text_tempsup

func _on_razao_de_pressao_line_edit_text_changed(new_text):
	var NumberLineEdit = $RazaoDePressaoLineEdit
	if LineEditRegEx.search(new_text):
		old_text_razaodepressao = str(new_text)
	else:
		NumberLineEdit.text = old_text_razaodepressao

func _on_ef_compressor_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfCompressorLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efcompressor = str(new_text)
	else:
		NumberLineEdit.text = old_text_efcompressor

func _on_ef_turbina_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfTurbinaLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efturbina = str(new_text)
	else:
		NumberLineEdit.text = old_text_efturbina

func _on_limpar_button_button_down():
	$ResultadosLabel.text = ""

func _on_usar_eficiencias_check_box_toggled(button_pressed):
	if button_pressed == false:
		$EfCompressorLineEdit.text = "100"
		$EfTurbinaLineEdit.text = "100"
		$EfCompressorLineEdit.hide()
		$EfTurbinaLineEdit.hide()
	else:
		$EfCompressorLineEdit.text = ""
		$EfTurbinaLineEdit.text = ""
		$EfCompressorLineEdit.show()
		$EfTurbinaLineEdit.show()

#===============================================================================
# * Parte que realiza os cálculos
#===============================================================================
var output #variável que será utilizada para armazenar o resultado do CoolProp
var p1; var p2; var p3; var p4 #pressão
var t1; var t2; var t3; var t4 #temperatura
var h1; var h2; var h3; var h4; var h2r; var h4r #entalpia

func load_data(csv_file):
	var data = {"T": [], "H": [], "P": []}
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

func brayton_simples(t1:float, t3:float, rp:float, nc:float, nt:float):
	#---------------------------------------------------------------------
	# * Estado 1: cálculos de entalpia e pressão em 1.
	#---------------------------------------------------------------------
	h1 = float(call_prop('H', 'T', t1))
	p1 = float(call_prop('P', 'T', t1)) #pressão relativa 1
	
	#---------------------------------------------------------------------
	# * Estado 2: cálculos de pressão, temperatura e entalpias em 2 e 2r.
	#---------------------------------------------------------------------
	p2 = rp * p1
	t2 = float(call_prop('T', 'P', p2))
	h2 = float(call_prop('H', 'T', t2))
	h2r = h1 + (h2 - h1)/nc
	
	#---------------------------------------------------------------------
	# * Estado 3: cálculos de entalpia e pressão em 3.
	#---------------------------------------------------------------------
	h3 = float(call_prop('H', 'T', t3))
	p3 = float(call_prop('P', 'T', t3))

	#---------------------------------------------------------------------
	# * Estado 4: cálculos de pressão, temperatura e entalpias em 4 e 4r.
	#---------------------------------------------------------------------
	p4 = (1/rp) * p3
	t4 = float(call_prop('T', 'P', p4))
	h4 = float(call_prop('H', 'T', t4))
	h4r = h3 - (h3 - h4) * nt
	
	#---------------------------------------------------------------------
	# * Parâmetros de Saída
	#---------------------------------------------------------------------
	var wc = (float(h2) - float(h1)) / nc        #Trabalho no compressor
	var wt = (float(h3) - float(h4)) * nt        #Trabalho na turbina
	var wl = float(wt) - float(wc)               #Trabalho líquido
	var rct = float(wc) / float(wt)              #Razão de consumo de trabalho
	var q_ent = float(h3) - float(h2r)           #Calor de Entrada
	var q_sai = float(h4r) - float(h1)           #Calor rejeitado
	var n = (float(wl))/float(q_ent)             #Rendimento

	#---------------------------------------------------------------------
	# * Ajuste de unidade e casas decimais
	#---------------------------------------------------------------------
	h1 = snapped(h1, 0.01)
	h2 = snapped(h2, 0.01)
	h2r = snapped(h2r, 0.01)
	h3 = snapped(h3, 0.01)
	h4 = snapped(h4, 0.01)
	h4r = snapped(h4r, 0.01)
	wt = snapped(wt, 0.01)
	wl = snapped(wl, 0.01)
	wc = snapped(wc, 0.01)
	wt = snapped(wt, 0.01)
	rct = snapped(rct * 100, 0.01)
	q_ent = snapped(q_ent, 0.01)
	q_sai = snapped(q_sai, 0.01)
	n = snapped(n * 100, 0.01)
	
	#---------------------------------------------------------------------
	# * Exibindo os resultados
	#---------------------------------------------------------------------
	if $UsarEficienciasCheckBox.button_pressed == true:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\n h1 = %s     h2r = %s     h3 = %s     h4r = %s\n
[u]Trabalhos na turbina, no compressor e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wt = %s     wc = %s     wl = %s    q_ent = %s    q_sai = %s\n
[u]Razão de consumo de trabalho (%%); Rendimento (%%):[/u]\n rct = %s     n = %s" % [h1, h2r, h3, h4r, wt, wc, wl, q_ent, q_sai, rct, n]
	else:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\n h1 = %s     h2 = %s     h3 = %s     h4 = %s\n
[u]Trabalhos na turbina, no compressor e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wt = %s     wc = %s     wl = %s    q_ent = %s    q_sai = %s\n
[u]Razão de consumo de trabalho (%%); Rendimento (%%):[/u]\n rct = %s     n = %s" % [h1, h2, h3, h4, wt, wc, wl, q_ent, q_sai, rct, n]

func _on_calcular_simples_button_button_down():
	if $TempInfLineEdit.text == "" or $TempSupLineEdit.text == "" or $RazaoDePressaoLineEdit.text == "" or $EfCompressorLineEdit.text == "" or $EfTurbinaLineEdit.text == "":
		return
	var temp_inf  = float($TempInfLineEdit.text)
	var temp_sup  = float($TempSupLineEdit.text)
	var razao_de_pressao = float($RazaoDePressaoLineEdit.text)
	var eficiencia_do_compressor = float($EfCompressorLineEdit.text)/100
	var eficiencia_da_turbina = float($EfTurbinaLineEdit.text)/100

#	brayton_simples(300, 1300, 8, 1, 1)
	brayton_simples(temp_inf, temp_sup, razao_de_pressao, eficiencia_do_compressor, eficiencia_da_turbina)
