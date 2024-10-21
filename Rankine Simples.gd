extends Node2D

#===============================================================================
# * Parte que controla os elementos da cena
#===============================================================================
@onready var LineEditRegEx = RegEx.new()
var old_text_pinf = ""
var old_text_psup = ""
var old_text_temp = ""
var old_text_efbomba = ""
var old_text_efturbina = ""

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

func _on_temp_line_edit_text_changed(new_text):
	var NumberLineEdit = $TempLineEdit
	if LineEditRegEx.search(new_text):
		old_text_temp = str(new_text)
	else:
		NumberLineEdit.text = old_text_temp

func _on_ef_bomba_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfBombaLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efbomba = str(new_text)
	else:
		NumberLineEdit.text = old_text_efbomba
		
func _on_ef_turbina_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfTurbinaLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efturbina = str(new_text)
	else:
		NumberLineEdit.text = old_text_efturbina

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

func _on_usar_eficiencias_check_box_toggled(button_pressed):
	if button_pressed == false:
		$EfBombaLineEdit.text = "100"
		$EfTurbinaLineEdit.text = "100"
		$EfBombaLineEdit.hide()
		$EfTurbinaLineEdit.hide()
	else:
		$EfBombaLineEdit.text = ""
		$EfTurbinaLineEdit.text = ""
		$EfBombaLineEdit.show()
		$EfTurbinaLineEdit.show()
		

#===============================================================================
# * Parte que realiza os cálculos
#===============================================================================
var output #variável que será utilizada para armazenar o resultado do CoolProp
var p1; var p2; var p3; var p4; var p5; var p6 #pressão
var t1; var t2; var t3; var t4; var t5; var t6 #temperatura
var h1; var h2; var h3; var h4; var h2r; var h4r #entalpia
var s1; var s2; var s3; var s4; var s4r; var s5; var s6 #entropia

func call_prop(a, b, c, d, e, f):
	#Define os dados de entrada, chama o exe passando-os como argumento e obtem sua resposta
	var path = "./PropCalc.exe"
	var input = [a, b, c, d, e, f] #argumentos
	output = []
	OS.execute(path, input, output, false)
	return str(output[0])

func rankine_simples(p1, p3, t3, nb, nt, fluido):
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
	h2r = h1 + (h2 - h1) / nb
	
	#---------------------------------------------------------------------
	# * Estado 3: cálculos de entalpia e entropia em 3.
	#---------------------------------------------------------------------
	h3 = float(call_prop('H', 'P|gas', p3, 'T', t3, fluido))
	s3 = float(call_prop('S', 'P|gas', p3, 'T', t3, fluido))

	#---------------------------------------------------------------------
	# * Estado 4: cálculos de pressão, entalpia e entropia em 4.
	#---------------------------------------------------------------------
	p4 = p1
	s4 = s3
	h4 = float(call_prop('H', 'P|gas', p4, 'S', s4, fluido))
	h4r = h3 - (h3 - h4) * nt
	s4r = float(call_prop('S', 'H', h4r, 'P|gas', p4, fluido))
	
	#---------------------------------------------------------------------
	# * Título no ponto 4:
	#---------------------------------------------------------------------
	var s4l = float(call_prop('S', 'P|liquid', p4, 'Q', 0, fluido))
	var s4v = float(call_prop('S', 'P|gas', p4, 'Q', 1, fluido))
	var x4
	var x4r
	#Ideal
	if (s4 < s4v):
		x4 = (s4 - s4l)/(s4v - s4l)
	else:
		x4 = 'Saída da turbina superaquecida'

	#Real
	if (s4r < s4v):
		x4r = (s4r - s4l)/(s4v - s4l)
	else:
		x4r = 'Saída da turbina superaquecida'

	#---------------------------------------------------------------------
	# * Parâmetros de Saída
	#---------------------------------------------------------------------
	var wb = (float(h2) - float(h1)) / nb                 #Trabalho na bomba
	var wt = (float(h3) - float(h4)) * nt                 #Trabalho na turbina
	var wl = float(wt) - float(wb)                        #Trabalho líquido
	var q_ent = float(h3) - float(h2r)                    #Calor de Entrada
	var q_sai = float(h4r) - float(h1)                    #Calor rejeitado
	var n = float(wl)/float(q_ent)                        #Rendimento

	#---------------------------------------------------------------------
	# * Ajuste de unidade e casas decimais
	#---------------------------------------------------------------------
	h1 = snapped(h1/1000, 0.01)
	h2 = snapped(h2/1000, 0.01)
	h2r = snapped(h2r/1000, 0.01)
	h3 = snapped(h3/1000, 0.01)
	h4 = snapped(h4/1000, 0.01)
	h4r = snapped(h4r/1000, 0.01)
	wt = snapped(wt/1000, 0.01)
	wl = snapped(wl/1000, 0.01)
	wb = snapped(wb/1000, 0.01)
	q_ent = snapped(q_ent/1000, 0.01)
	q_sai = snapped(q_sai/1000, 0.01)
	if x4 is float:
		x4 = snapped(x4 * 100, 0.01)
	if x4r is float:
		x4r = snapped(x4r * 100, 0.01)
	n = snapped(n * 100, 0.01)
	
	#---------------------------------------------------------------------
	# * Exibindo os resultados
	#---------------------------------------------------------------------
	if $UsarEficienciasCheckBox.button_pressed == true:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\nh1 = %s    h2r = %s    h3 = %s    h4r = %s\n
[u]Trabalhos da turbina, da bomba e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wt = %s    wb = %s    wl = %s   q_ent = %s   q_sai = %s\n
[u]Título no ponto 4 e rendimento (%%):[/u]\n x4r = %s   n = %s" % [h1, h2r, h3, h4r, wt, wb, wl, q_ent, q_sai, x4r, n]
	else:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\nh1 = %s    h2 = %s    h3 = %s    h4 = %s\n
[u]Trabalhos da turbina, da bomba e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wt = %s    wb = %s    wl = %s   q_ent = %s   q_sai = %s\n
[u]Título no ponto 4 e rendimento (%%):[/u]\n x4 = %s   n = %s" % [h1, h2, h3, h4, wt, wb, wl, q_ent, q_sai, x4, n]


func _on_calcular_simples_button_button_down():
	if $PressaoInfLineEdit.text == "" or $PressaoSupLineEdit.text == "" or $EfBombaLineEdit.text == "" or $EfTurbinaLineEdit.text == "" or ($TempLineEdit.text == "" and $VaporSaturadoCheckBox.button_pressed == false):
		return
	var pressao_inf  = float($PressaoInfLineEdit.text) * 1000
	var pressao_sup  = float($PressaoSupLineEdit.text) * 1000
	var temperatura = 0.0
	if $VaporSaturadoCheckBox.button_pressed == true:
		temperatura = call_prop('T', 'P|gas', pressao_sup, 'Q', 1, 'Water') #temperatura vapor saturado
	else:
		temperatura  = float($TempLineEdit.text) + 273.15
	var ef_bomba = float($EfBombaLineEdit.text)/100
	var ef_turbina = float($EfTurbinaLineEdit.text)/100
	
	rankine_simples(pressao_inf, pressao_sup, temperatura, ef_bomba, ef_turbina, 'Water')


