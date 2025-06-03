extends Node2D

#===============================================================================
# * Parte que controla os elementos da cena
#===============================================================================
@onready var LineEditRegEx = RegEx.new()
var old_text_pinf = ""
var old_text_pint = ""
var old_text_psup = ""
var old_text_temp = ""
var old_text_efbomba1 = ""
var old_text_efbomba2 = ""
var old_text_efturb = ""

func _ready() -> void:
	LineEditRegEx.compile("^[0-9.]*$")

func _on_voltar_button_button_down():
	$"../Background".adjust_buttons()
	$"../Background".show()
	$".".hide()

func _on_pressao_inf_line_edit_text_changed(new_text):
	var NumberLineEdit = $PressaoInfLineEdit
	if LineEditRegEx.search(new_text):
		old_text_pinf = str(new_text)
	else:
		NumberLineEdit.text = old_text_pinf
		
func _on_pressao_sup_line_edit_text_changed(new_text):
	var NumberLineEdit = $PressaoSupLineEdit
	if LineEditRegEx.search(new_text):
		old_text_psup = str(new_text)
	else:
		NumberLineEdit.text = old_text_psup

func _on_pressao_inter_line_edit_text_changed(new_text):
	var NumberLineEdit = $PressaoInterLineEdit
	if LineEditRegEx.search(new_text):
		old_text_pint = str(new_text)
	else:
		NumberLineEdit.text = old_text_pint

func _on_temp_line_edit_text_changed(new_text):
	var NumberLineEdit = $TempLineEdit
	if LineEditRegEx.search(new_text):
		old_text_temp = str(new_text)
	else:
		NumberLineEdit.text = old_text_temp

func _on_vapor_saturado_check_box_toggled(button_pressed):
	if button_pressed == true:
		$TempLineEdit.max_length = 10
		$TempLineEdit.text = "Vapor sat."
		$TempLineEdit.editable = false
	else:
		$TempLineEdit.max_length = 4
		$TempLineEdit.text = ""
		$TempLineEdit.editable = true


func _on_limpar_button_button_down():
	$ResultadosLabel.text = ""


func _on_ef_bomba_1_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfBomba1LineEdit
	if LineEditRegEx.search(new_text):
		old_text_efbomba1 = str(new_text)
	else:
		NumberLineEdit.text = old_text_efbomba1


func _on_ef_bomba_2_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfBomba2LineEdit
	if LineEditRegEx.search(new_text):
		old_text_efbomba2 = str(new_text)
	else:
		NumberLineEdit.text = old_text_efbomba2


func _on_ef_turb_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfTurbLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efturb = str(new_text)
	else:
		NumberLineEdit.text = old_text_efturb
		
		
func _on_usar_eficiencias_check_box_toggled(button_pressed):
	if button_pressed == false:
		$EfBomba1LineEdit.text = "100"
		$EfBomba2LineEdit.text = "100"
		$EfTurbLineEdit.text = "100"
		$EfBomba1LineEdit.hide()
		$EfBomba2LineEdit.hide()
		$EfTurbLineEdit.hide()
	else:
		$EfBomba1LineEdit.text = ""
		$EfBomba2LineEdit.text = ""
		$EfTurbLineEdit.text = ""
		$EfBomba1LineEdit.show()
		$EfBomba2LineEdit.show()
		$EfTurbLineEdit.show()
	
#===============================================================================
# * Parte que realiza os cálculos
#===============================================================================
#definindo as variaveis que serão utilizadas nos calculos
var output #variável que será utilizada para armazenar o resultado do CoolProp
var p1; var p2; var p3; var p4; var p5; var p6; var p7 #pressão
var t1; var t2; var t3; var t4; var t5; var t6; var t7 #temperatura
var h1; var h2; var h2r; var h3; var h4; var h4r; var h5; var h6; var h6r; var h7; var h7r #entalpia
var s1; var s2; var s3; var s4; var s5; var s6; var s6r; var s7; var s7r #entropia
var x6; var x6r #titulo

func call_prop(a, b, c, d, e, f):
	#Define os dados de entrada, chama o exe passando-os como argumento e obtem sua resposta
	var path = "./PropCalc.exe"
	var input = [a, b, c, d, e, f] #argumentos
	output = []
	OS.execute(path, input, output, false)
	return str(output[0])

func rankine_regenerativo(p1, p3, p5, t5, nb1, nb2, nt, fluido):
	#---------------------------------------------------------------------
	# * Estado 1: cálculos de entalpia e entropia em 1.
	#---------------------------------------------------------------------
	h1 = float(call_prop('H', 'P|liquid', p1, 'Q', 0, fluido))
	s1 = float(call_prop('S', 'P|liquid', p1, 'Q', 0, fluido))
	
	#---------------------------------------------------------------------
	# * Estado 2: cálculos de pressão, entalpia e entropia em 2.
	#---------------------------------------------------------------------
	p2 = p3
	s2 = s1
	h2 = float(call_prop('H', 'P|liquid', p2, 'S', s2, fluido))
	h2r = h1 + (h2 - h1)/nb1

	#---------------------------------------------------------------------
	# * Estado 3: cálculos de entalpia e entropia em 3.
	#---------------------------------------------------------------------
	h3 = float(call_prop('H', 'P|liquid', p3, 'Q', 0, fluido))
	s3 = float(call_prop('S', 'P|liquid', p3, 'Q', 0, fluido))

	#---------------------------------------------------------------------
	# * Estado 4: cálculos de entalpia, pressão e entropia em 4.
	#---------------------------------------------------------------------
	s4 = s3
	p4 = p5
	h4 = float(call_prop('H', 'P|liquid', p4, 'S', s4, fluido))
	h4r = h3 + (h4 - h3)/nb2
	
	#---------------------------------------------------------------------
	# * Estado 5: cálculos de entalpia e entropia em 5.
	#---------------------------------------------------------------------
	h5 = float(call_prop('H', 'P|gas', p5, 'T', t5, fluido))
	s5 = float(call_prop('S', 'P|gas', p5, 'T', t5, fluido))
	
	#---------------------------------------------------------------------
	# * Estado 6: cálculos de pressão, entropia e entalpia em 5.
	#---------------------------------------------------------------------
	p6 = p3
	s6 = s5
	h6 = float(call_prop('H', 'P|gas', p6, 'S', s6, fluido))
	h6r = h5 - (h5 - h6) * nt
	s6r = float(call_prop('S', 'H', h6r, 'P|gas', p6, fluido))
	
	#---------------------------------------------------------------------
	# * Título no ponto 6:
	#---------------------------------------------------------------------
	var s6l = float(call_prop('S', 'P|liquid', p6, 'Q', 0, fluido))
	var s6v = float(call_prop('S', 'P|gas', p6, 'Q', 1, fluido))
	
	#Ideal
	if (s6 < s6v):
		x6 = (s6 - s6l)/(s6v - s6l)
	else:
		x6 = 'Saída da turbina superaquecida'
	
	#Real
	if (s6r < s6v):
		x6r = (s6r - s6l)/(s6v - s6l)
	else:
		x6r = 'Saída da turbina superaquecida'

	#---------------------------------------------------------------------
	# * Fração mássica
	#---------------------------------------------------------------------
	var m = float((h3 - h2)/(h6 - h2))
	var mr = float((h3 - h2r)/(h6r - h2r))

	#---------------------------------------------------------------------
	# * Estado 7: cálculos de pressão, entalpia e entropia em 5.
	#---------------------------------------------------------------------
	p7 = p1
	s7 = s6
	h7 = float(call_prop('H', 'P|gas', p7, 'S', s7, fluido))
	h7r = h5 - (h5 - h7) * nt
	s7r = float(call_prop('S', 'H', h7r, 'P|gas', p7, fluido))

	#---------------------------------------------------------------------
	# * Título no ponto 7:
	#---------------------------------------------------------------------
	var s7l = float(call_prop('S', 'P|liquid', p7, 'Q', 0, fluido))
	var s7v = float(call_prop('S', 'P|gas', p7, 'Q', 1, fluido))
	var x7
	var x7r
	
	#Ideal
	if (s7 < s7v):
		x7 = (s7 - s7l)/(s7v - s7l)
	else:
		x7 = 'Saída da turbina superaquecida'
	
	#Real
	if (s7r < s7v):
		x7r = (s7r - s7l)/(s7v - s7l)
	else:
		x7r = 'Saída da turbina superaquecida'
	
	#---------------------------------------------------------------------
	# * Saída
	#---------------------------------------------------------------------
	var wt = float((h5 - h6r) + (1-mr) * (h6r - h7r))           #Trabalho na turbina
	var wb1 = float(h2r - h1)                              #Trabalho na bomba 1
	var wb2 = float(h4r - h3)                              #Trabalho na turbina 2
	var wB = float(wb1 + wb2)                             #Trabalho total nas bombas
	var wl = float(wt - wB)                               #Trabalho líquido
	var q_ent = float(h5 - h4r)                               #Calor de entrada
	var q_sai = float((1-mr) * (h7r - h1))                     #Calor rejeitado
	var n = (float(q_ent - q_sai)/q_ent)                           #Rendimento

	#---------------------------------------------------------------------
	# * Ajuste de unidade e casas decimais
	#---------------------------------------------------------------------
	h1 = snapped(h1/1000, 0.01)
	h2 = snapped(h2/1000, 0.01)
	h2r = snapped(h2r/1000, 0.01)
	h3 = snapped(h3/1000, 0.01)
	h4 = snapped(h4/1000, 0.01)
	h4r = snapped(h4r/1000, 0.01)
	h5 = snapped(h5/1000, 0.01)
	h6 = snapped(h6/1000, 0.01)
	h6r = snapped(h6r/1000, 0.01)
	h7 = snapped(h7/1000, 0.01)
	h7r = snapped(h7r/1000, 0.01)
	wt = snapped(wt/1000, 0.01)
	wB = snapped(wB/1000, 0.01)
	wl = snapped(wl/1000, 0.01)
	q_ent = snapped(q_ent/1000, 0.01)
	q_sai = snapped(q_sai/1000, 0.01)
	n = snapped(n * 100, 0.01)
	m = snapped(m * 100, 0.01)
	mr = snapped(mr * 100, 0.01)
	
	if x6 is float:
		x6 = snapped(x6 * 100, 0.01)
	
	if x7 is float:
		x7 = snapped(x7 * 100, 0.01)
	
	if x6r is float:
		x6r = snapped(x6r * 100, 0.01)
	
	if x7r is float:
		x7r = snapped(x7r * 100, 0.01)
	
	#---------------------------------------------------------------------
	# * Exibindo os resultados
	#---------------------------------------------------------------------
	if $UsarEficienciasCheckBox.button_pressed == true:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\nh1 = %s    h2r = %s    h3 = %s    h4r = %s    h5 = %s    h6r = %s    h7r = %s\n
[u]Trabalhos da turbina, total das bombas e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wt = %s    wB = %s    wl = %s   q_ent = %s   q_sai = %s\n
[u]Título nos pontos 6, 7, rendimento e fração mássica (%%):[/u]\nx6r = %s   x7r = %s   n = %s   m = %s" % [h1, h2r, h3, h4r, h5, h6r, h7r, wt, wB, wl, q_ent, q_sai, x6r, x7r, n, mr]
	else:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\nh1 = %s    h2 = %s    h3 = %s    h4 = %s    h5 = %s    h6 = %s    h7 = %s\n
[u]Trabalhos da turbina, total das bombas e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wt = %s    wB = %s    wl = %s   q_ent = %s   q_sai = %s\n
[u]Título nos pontos 6, 7, rendimento e fração mássica (%%):[/u]\nx6 = %s   x7 = %s   n = %s   m = %s" % [h1, h2, h3, h4, h5, h6, h7, wt, wB, wl, q_ent, q_sai, x6, x7, n, m]


#=================================================================
# * Botão Calcular Rankine Regenerativo
#=================================================================
func _on_calcular_regen_button_button_down():
	if $PressaoInfLineEdit.text == "" or $PressaoSupLineEdit.text == "" or ($TempLineEdit.text == "" and $VaporSaturadoCheckBox.button_pressed == false or $EfBomba1LineEdit.text == "" or $EfBomba2LineEdit.text == "" or $EfTurbLineEdit.text == ""):
		return
	var pressao_inf  = float($PressaoInfLineEdit.text) * 1000
	var pressao_inter  = float($PressaoInterLineEdit.text) * 1000
	var pressao_sup  = float($PressaoSupLineEdit.text) * 1000
	var temperatura = 0.0
	if $VaporSaturadoCheckBox.button_pressed == true:
		temperatura = call_prop('T', 'P|gas', pressao_sup, 'Q', 1, 'Water') #temperatura vapor saturado
	else:
		temperatura  = float($TempLineEdit.text) + 273.15
	var efbomba1 = float($EfBomba1LineEdit.text)/100
	var efbomba2 = float($EfBomba2LineEdit.text)/100
	var efturbina = float($EfTurbLineEdit.text)/100
	
	rankine_regenerativo(pressao_inf, pressao_sup, pressao_inter, temperatura, efbomba1, efbomba2, efturbina, 'Water')


