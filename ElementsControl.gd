extends Node
#=============================================================
# * Controle e animações dos elementos do MENU PRINCIPAL
#=============================================================

#------------------------------------------------------
# * Reajusta os botões ao entrar em alguma cena
#------------------------------------------------------
func adjust_buttons():
	$RankineSimplesButton.scale = Vector2(1 , 1)
	$RankineReaqButton.scale = Vector2(1 , 1)
	$RankineRegenButton.scale = Vector2(1 , 1)
	$BraytonSimplesButton.scale = Vector2(1 , 1)
	$BraytonRegenButton.scale = Vector2(1 , 1)
	$CalculadoraAguaButton.scale = Vector2(1 , 1)
	$CalculadoraArButton.scale = Vector2(1 , 1)

#------------------------------------------------------
# * Rankine Simples
#------------------------------------------------------
func _on_rankine_simples_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($RankineSimplesButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)
	
func _on_rankine_simples_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($RankineSimplesButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_rankine_simples_button_button_down():
	$".".hide()
	$"../Rankine Simples".show()

#------------------------------------------------------
# * Rankine Reaquecido
#------------------------------------------------------
func _on_rankine_reaq_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($RankineReaqButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_rankine_reaq_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($RankineReaqButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)
	
func _on_rankine_reaq_button_button_down():
	$".".hide()
	$"../Rankine Reaquecido".show()

#------------------------------------------------------
# * Rankine Regenerativo
#------------------------------------------------------
func _on_rankine_regen_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($RankineRegenButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_rankine_regen_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($RankineRegenButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_rankine_regen_button_button_down():
	$".".hide()
	$"../Rankine Regenerativo".show()
	
#------------------------------------------------------
# * Brayton Simples
#------------------------------------------------------
func _on_brayton_simples_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($BraytonSimplesButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)


func _on_brayton_simples_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($BraytonSimplesButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)


func _on_brayton_simples_button_button_down():
	$".".hide()
	$"../Brayton Simples".show()

#------------------------------------------------------
# * Brayton Regenerativo
#------------------------------------------------------
func _on_brayton_regen_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($BraytonRegenButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_brayton_regen_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($BraytonRegenButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_brayton_regen_button_button_down():
	$".".hide()
	$"../Brayton Regenerativo".show()

#------------------------------------------------------
# * Calculadora Água
#------------------------------------------------------
func _on_calculadora_agua_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($CalculadoraAguaButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_calculadora_agua_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($CalculadoraAguaButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_calculadora_agua_button_button_down():
	$".".hide()
	$"../Calculadora Agua".show()
	
#------------------------------------------------------
# * Calculadora Ar
#------------------------------------------------------
func _on_calculadora_ar_button_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property($CalculadoraArButton, "scale", Vector2(1.1,1.1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_calculadora_ar_button_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property($CalculadoraArButton, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_calculadora_ar_button_button_down():
	$".".hide()
	$"../Calculadora Ar".show()
