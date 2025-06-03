extends Node2D

#===============================================================================
# * Parte que controla os elementos da cena
#===============================================================================
@onready var LineEditRegEx = RegEx.new()
var old_text_pinf = ""
var old_text_pint = ""
var old_text_psup = ""
var old_text_temp = ""
var old_text_efturb_alta = ""
var old_text_efturb_baixa = ""
var old_text_ef_bomba = ""

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

func _on_ef_turb_alta_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfTurbAltaLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efturb_alta = str(new_text)
	else:
		NumberLineEdit.text = old_text_efturb_alta


func _on_ef_turb_baixa_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfTurbBaixaLineEdit
	if LineEditRegEx.search(new_text):
		old_text_efturb_baixa = str(new_text)
	else:
		NumberLineEdit.text = old_text_efturb_baixa


func _on_ef_bomba_line_edit_text_changed(new_text):
	var NumberLineEdit = $EfBombaLineEdit
	if LineEditRegEx.search(new_text):
		old_text_ef_bomba = str(new_text)
	else:
		NumberLineEdit.text = old_text_ef_bomba
	
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
		$EfTurbAltaLineEdit.text = "100"
		$EfTurbBaixaLineEdit.text = "100"
		$EfBombaLineEdit.text = "100"
		$EfTurbAltaLineEdit.hide()
		$EfTurbBaixaLineEdit.hide()
		$EfBombaLineEdit.hide()
	else:
		$EfTurbAltaLineEdit.text = ""
		$EfTurbBaixaLineEdit.text = ""
		$EfBombaLineEdit.text = ""
		$EfTurbAltaLineEdit.show()
		$EfTurbBaixaLineEdit.show()
		$EfBombaLineEdit.show()
		
#===============================================================================
# * Parte que realiza os cálculos
#===============================================================================
#definindo as variaveis que serão utilizadas nos calculos
var output #variável que será utilizada para armazenar o resultado do CoolProp
var p1; var p2; var p3; var p4; var p5; var p6 #pressão
var t1; var t2; var t3; var t4; var t5; var t6 #temperatura
var h1; var h2; var h2r; var h3; var h4; var h4r; var h5; var h6; var h6r #entalpia
var s1; var s2; var s3; var s4; var s4r; var s5; var s6; var s6r #entropia

func call_prop(a, b, c, d, e, f):
	#Define os dados de entrada, chama o exe passando-os como argumento e obtem sua resposta
	var path = "./PropCalc.exe"
	var input = [a, b, c, d, e, f] #argumentos
	output = []
	OS.execute(path, input, output, false)
	return str(output[0])

func rankine_reaquecido(p1, p3, p4, t3, nt1, nt2, nb, fluido):
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
	h2r = h1 + (h2 - h1)/nb

	#---------------------------------------------------------------------
	# * Estado 3: cálculos de entalpia e entropia em 3.
	#---------------------------------------------------------------------
	h3 = float(call_prop('H', 'P|gas', p3, 'T', t3, fluido))
	s3 = float(call_prop('S', 'P|gas', p3, 'T', t3, fluido))

	#---------------------------------------------------------------------
	# * Estado 4: cálculos de entalpia e entropia em 4.
	#---------------------------------------------------------------------
	s4 = s3
	h4 = float(call_prop('H', 'P|gas', p4, 'S', s4, fluido))
	h4r = float(h3 - (h3 - h4) * nt1)
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
	# * Estado 5: cálculos de pressão, temperatura, entalpia e entropia em 5.
	#---------------------------------------------------------------------
	p5 = p4
	t5 = t3
	h5 = float(call_prop('H', 'P|gas', p5, 'T', t5, fluido))
	s5 = float(call_prop('S', 'P|gas', p5, 'T', t5, fluido))
	
	#---------------------------------------------------------------------
	# * Estado 6: cálculos de pressão, temperatura, entalpia e entropia em 5.
	#---------------------------------------------------------------------
	s6 = s5
	p6 = p1
	h6 = float(call_prop('H', 'P|gas', p6, 'S', s6, fluido))
	h6r = float(h5 - (h5 - h6) * nt2)
	s6r = float(call_prop('S', 'H', h6r, 'P|gas', p6, fluido))
	
	#---------------------------------------------------------------------
	# * Título no ponto 6:
	#---------------------------------------------------------------------
	var s6l = float(call_prop('S', 'P|liquid', p6, 'Q', 0, fluido))
	var s6v = float(call_prop('S', 'P|gas', p6, 'Q', 1, fluido))
	var x6
	var x6r
	
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
	# * Saída
	#---------------------------------------------------------------------
	var wb = (float(h2) - float(h1)) / nb                             #Trabalho na bomba
	var wt1 = (float(h3) - float(h4)) * nt1                           #Trabalho na turbina 1
	var wt2 = (float(h5) - float(h6)) * nt2                           #Trabalho na turbina 2
	var wT = float(wt1) + float(wt2)                                  #Trabalho total das turbinas
	var wl = float(wT) - float(wb)                                    #Trabalho líquido
	var q_ent = (float(h3) - float(h2r)) + (float(h5) - float(h4r))   #Calor de entrada
	var q_sai = float(h6r) - float(h1)                                #Calor rejeitado
	var n = (float(q_ent) - float(q_sai))/float(q_ent)                #Rendimento

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
	wt1 = snapped(wt1/1000, 0.01)
	wt1 = snapped(wt2/1000, 0.01)
	wT = snapped(wT/1000, 0.01)
	wb = snapped(wb/1000, 0.01)
	wl = snapped(wl/1000, 0.01)
	q_ent = snapped(q_ent/1000, 0.01)
	q_sai = snapped(q_sai/1000, 0.01)
	
	if x4 is float:
		x4 = snapped(x4 * 100, 0.01)
		
	if x4r is float:
		x4r = snapped(x4r * 100, 0.01)
	
	if x6 is float:
		x6 = snapped(x6 * 100, 0.01)
	
	if x6r is float:
		x6r = snapped(x6r * 100, 0.01)
		
	n = snapped(n * 100, 0.01)
	
	#---------------------------------------------------------------------
	# * Exibindo os resultados
	#---------------------------------------------------------------------
	if $UsarEficienciasCheckBox.button_pressed == true:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\nh1 = %s    h2r = %s    h3 = %s    h4r = %s    h5 = %s    h6r = %s\n
[u]Trabalhos total das turbinas, na bomba e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wT = %s    wb = %s    wl = %s   q_ent = %s   q_sai = %s\n
[u]Título nos pontos 4, 6 e rendimento (%%):[/u]\nx4r = %s   x6r = %s   n = %s" % [h1, h2r, h3, h4r, h5, h6r, wT, wb, wl, q_ent, q_sai, x4r, x6r, n]
	else:
		$ResultadosLabel.text  = "[u]Resultados:[/u]\n\n[u]Entalpias (kJ/kg):[/u]\nh1 = %s    h2 = %s    h3 = %s    h4 = %s    h5 = %s    h6 = %s\n
[u]Trabalhos total das turbinas, na bomba e líquido (kJ/kg); Calores de entrada e rejeitado (kJ/kg):[/u]\n wT = %s    wb = %s    wl = %s   q_ent = %s   q_sai = %s\n
[u]Título nos pontos 4, 6 e rendimento (%%):[/u]\nx4 = %s   x6 = %s   n = %s" % [h1, h2, h3, h4, h5, h6, wT, wb, wl, q_ent, q_sai, x4, x6, n]


#=================================================================
# * Botão Calcular Rankine Reaquecido
#=================================================================
func _on_calcular_reaq_button_button_down():
	if $PressaoInfLineEdit.text == "" or $PressaoSupLineEdit.text == "" or ($TempLineEdit.text == "" and $VaporSaturadoCheckBox.button_pressed == false) or $EfTurbAltaLineEdit.text == "" or $EfTurbBaixaLineEdit.text == "" or $EfBombaLineEdit.text == "":
		return
	var pressao_inf  = float($PressaoInfLineEdit.text) * 1000
	var pressao_inter  = float($PressaoInterLineEdit.text) * 1000
	var pressao_sup  = float($PressaoSupLineEdit.text) * 1000
	var temperatura = 0.0
	if $VaporSaturadoCheckBox.button_pressed == true:
		temperatura = call_prop('T', 'P|gas', pressao_sup, 'Q', 1, 'Water') #temperatura vapor saturado
	else:
		temperatura  = float($TempLineEdit.text) + 273.15
	var eficiencia_turbina_alta = float($EfTurbAltaLineEdit.text)/100
	var eficiencia_turbina_baixa = float($EfTurbBaixaLineEdit.text)/100
	var eficiencia_bomba = float($EfBombaLineEdit.text)/100
	
	
	rankine_reaquecido(pressao_inf, pressao_sup, pressao_inter, temperatura, eficiencia_turbina_alta, eficiencia_turbina_baixa, eficiencia_bomba, 'Water')
