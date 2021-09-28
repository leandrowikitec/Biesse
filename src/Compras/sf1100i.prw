#Include "Rwmake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} SF1100I
	(Ponto de entrada apos gravação do documento de entrada)
	@type User Function
	@author Calabro'
	@since 22/09/2021
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function SF1100I()

Local lExecAuto		:= IsInCallStack("MSEXECAUTO") as logical

// Se for execucao automatica, se a nota for de importacao, se nota nao for devolucao ou beneficiamento
// Verifica se variavel Private existe para checar se deve adicionar complemento da nota = 1
// Se igual a 1 (adiciona complemento) nao precisa efetuar a pergunta
If lExecAuto .AND. SF1->F1_EST == "EX" .AND. !(SF1->F1_TIPO $ "D/B") .AND. ValType(aParamRCO01) == "A" .AND. aParamRCO01[12] $ "1@#3"

	// Abro tela customizada para preenchimento de complemento de notas (CD5)
	If U_RCOMA02(aParamRCO01[12] == "3") .AND. aParamRCO01[12] == "3"
		// Executo tela de complemento de nota
		Mata926(SD1->D1_DOC,SD1->D1_SERIE,SF1->F1_ESPECIE,SD1->D1_FORNECE,SD1->D1_LOJA,"E",SD1->D1_TIPO,SD1->D1_CF)
	EndIf
EndIf

Return Nil
