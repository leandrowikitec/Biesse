#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/{Protheus.doc} RFINA01
(Rotina que centraliza as funcoes de impressao de Boletos)
@author Calabró
@since 14/03/2019
@version 1.0
@param cCodEmp, character, (Empresa a ser considerada)
@param cCodFil, character, (Filial da empresa a ser considerada)
@param cNumTit, character, (Numero do titulo)
@param cPrefixo, character, (Numero do prefixo do titulo)
@return Nil, Nulo
@example
(examples)
@see (links_or_references)
/*/

User Function RFINA01(cCodEmp, cCodFil, cNumTit, cPrefixo)

Local lForceEnv	:= Empty(FunName())			//Verifica se ambiente foi inicializado
Local lJob		:= .F.						//Variavel de conrole se execucao e' via Job
Local lRet		:= .T.						//controle de retorno de processo

Local aAreas 	:= {}

Default cCodEmp 	:= "01"
Default cCodFil		:= "01"
Default cNumTit 	:= "@#"
Default cPrefixo 	:= "@#"

//Se nao existe ambiente, monto novo ambiente
If lForceEnv
    RpcSetType(3)
    RpcSetEnv(cCodEmp, cCodFil,,,"FIN",,{"SE1"})
	lJob := .T.
EndIf

aAreas 	:= {SE1->(GetArea()), GetArea()}

DbSelectArea("SE1")
DbSetOrder(1)
If SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumTit))
	ExecBoleto(cPrefixo, cNumTit, @lRet, lJob)
EndIf

aEval(aAreas, {|x| RestArea(x) })

Return lRet

/*/{Protheus.doc} ExecBoleto
(Rotina que executa a impressao de Boletos)
@author Calabró
@since 14/03/2019
@version 1.0
@param cNumTit, character, (Numero do titulo)
@param cPrefixo, character, (Numero do prefixo do titulo)
@param lRet, logic, (Variavel de retorno com sucesso (.T.) ou falha (.F.) da geracao do boleto)
@param lJob, logic, (Variavel de controle para identificar se processo esta em job ou nao)
@return Nil, Nulo
@example
(examples)
@see (links_or_references)
/*/

Static Function ExecBoleto(cPrefixo, cNumTit, lRet, lJob)

Local cMsg			:= ""
Local __cNomBcoL	:= ""

Local nOpc			:= 0

Local aPergs		:= {}
Local aRet			:= {}
Local aBancos		:= {}

Private oDlg		:= Nil

Private lEnvioBol   := .F. //Verifica se o tipo selecionado na mensagem e envio de [ Boleto ]
Private lEnvBolNF   := .F. //Verifica se o tipo selecionado na mensagem e envio de [ Boleto + Nota Fiscal ]
Private lPDF	    := .F. //Verifica se o tipo de mensagem selecionado [ Imprimir / Envio] caso seja envio gera um arquivo PDF
Private lExec       := .F.
Private cIndexName  := ''
Private cIndexKey   := ''
Private cFilter     := ''

Private aBancos     := {}
Private aBancosRet  := {}
Private cChaveBanco := ""
Private cMod11      := " "     

//Preenche as opcoes de Banco
aAdd(aBancos,"001 - Banco Do Brasil")
aAdd(aBancos,"033 - Banco Santander")
aAdd(aBancos,"237 - Banco Bradesco")
aAdd(aBancos,"341 - Banco Itau")
aAdd(aBancos,"422 - Banco Safra")
aAdd(aBancos,"637 - Banco Sofisa")

Tamanho  := "M"
titulo   := "Impressao de Boleto com Codigo de Barras"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg    := PADR("RFINA01",10)
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

dbSelectArea("SE1")

Aadd(aPergs,{"De Prefixo"		,"","","mv_ch1","C",TamSX3("E1_PREFIXO")[1]	,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo"		,"","","mv_ch2","C",TamSX3("E1_PREFIXO")[1]	,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero"		,"","","mv_ch3","C",TamSX3("E1_NUM")[1]		,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero"		,"","","mv_ch4","C",TamSX3("E1_NUM")[1]		,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela"		,"","","mv_ch5","C",TamSX3("E1_PARCELA")[1]	,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela"		,"","","mv_ch6","C",TamSX3("E1_PARCELA")[1]	,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Portador"		,"","","mv_ch7","C",TamSX3("E1_PORTADO")[1]	,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aPergs,{"Ate Portador"		,"","","mv_ch8","C",TamSX3("E1_PORTADO")[1]	,0,0,"G","","MV_PAR08","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aPergs,{"De Cliente"		,"","","mv_ch9","C",TamSX3("E1_CLIENTE")[1]	,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"Ate Cliente"		,"","","mv_cha","C",TamSX3("E1_CLIENTE")[1]	,0,0,"G","","MV_PAR10","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"De Loja"			,"","","mv_chb","C",TamSX3("E1_LOJA")[1]	,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Loja"			,"","","mv_chc","C",TamSX3("E1_LOJA")[1]	,0,0,"G","","MV_PAR12","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao"		,"","","mv_chd","D",TamSX3("E1_EMISSAO")[1]	,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao"		,"","","mv_che","D",TamSX3("E1_EMISSAO")[1]	,0,0,"G","","MV_PAR14","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento"	,"","","mv_chf","D",TamSX3("E1_VENCTO")[1]	,0,0,"G","","MV_PAR15","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento"	,"","","mv_chg","D",TamSX3("E1_VENCTO")[1]	,0,0,"G","","MV_PAR16","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Do Bordero"		,"","","mv_chh","C",TamSX3("E1_NUMBOR")[1]	,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Bordero"		,"","","mv_chi","C",TamSX3("E1_NUMBOR")[1]	,0,0,"G","","MV_PAR18","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Linha Obs 1"		,"","","mv_chj","C",60						,0,0,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Linha Obs 2"		,"","","mv_chj","C",60						,0,0,"G","","MV_PAR20","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Linha Obs 3"		,"","","mv_chj","C",60						,0,0,"G","","MV_PAR21","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

// AjustaSx1(cPerg,aPergs)

//Preenche parametros para rotina utilizar envio de boleto automatico
If lJob

	MV_PAR01 := SE1->E1_PREFIXO
	MV_PAR02 := SE1->E1_PREFIXO
	MV_PAR03 := SE1->E1_NUM
	MV_PAR04 := SE1->E1_NUM
	MV_PAR05 := ""
	MV_PAR06 := "Z"
	MV_PAR07 := ""
	MV_PAR08 := "ZZZ"
	MV_PAR09 := ""
	MV_PAR10 := "ZZZZZZ"
	MV_PAR11 := ""
	MV_PAR12 := "ZZ"
	MV_PAR13 := SE1->E1_EMIS1
	MV_PAR14 := SE1->E1_EMIS1
	MV_PAR15 := SE1->E1_VENCREA
	MV_PAR16 := SE1->E1_VENCREA
	MV_PAR17 := ""
	MV_PAR18 := "ZZZZZZ"
	MV_PAR19 := ""
	MV_PAR20 := ""
	MV_PAR21 := ""
Else
	
	If !Pergunte (cPerg,.T.)
		Return
	EndIf
EndIf

cIndexName	:= Criatrab(Nil,.F.)
cIndexKey	:= "E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)+E1_PORTADO+E1_CLIENTE"
cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And."
cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
cFilter		+= "E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "'.And."
cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "'.And.E1_CLIENTE<='" + MV_PAR10 + "'.And."
cFilter		+= "E1_LOJA>='" + MV_PAR11 + "'.And.E1_LOJA<='"+MV_PAR12+"'.And."
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"'.And."
cFilter		+= 'DTOS(E1_VENCREA)>="'+DTOS(mv_par15)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mv_par16)+'".And.'
cFilter		+= "E1_NUMBOR>='" + MV_PAR17 + "'.And.E1_NUMBOR<='" + MV_PAR18 + "'.And."
cFilter		+= "!(E1_TIPO$MVABATIM) .And. "
cFilter		+= "( E1_VENCREA >= E1_EMISSAO ) "

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
dbGoTop()

nVlrSel := 0
nQtdSel := 0
lPrim 	:= .T.

//Envio de boleto em tela
//Senao sera envio de boleto em job
If !lJob
	
	//Quando for segunda-via de boleto, imprime direto
	// If !IsInCallStack("U_RFINA01")
		
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK" OBJECT oBrw
		@ 180,050 SAY oSay1 PROMPT "Qtd Selec.: "+AllTrim(Transform(nQtdSel,"@R 999999999")) SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 180,100 SAY oSay2 PROMPT "Vlr Selec.: "+AllTrim(Transform(nVlrSel,"@R 99,999,999.99")) SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL
		@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
		
		If lPrim
			SE1->(dbGoTop())
			While SE1->(!Eof())
				If Marked("E1_OK")
					nQtdSel++
					nVlrSel+=SE1->E1_VLCRUZ
				EndIf
				SE1->(dbSkip())
			Enddo
			SE1->(dbGoTop())
			oBrw:OBROWSE:BLDBLCLICK := {|| IIF( !Marked("E1_OK"),;
											Eval({|| nQtdSel++, nVlrSel+=SE1->E1_VLCRUZ}),;
											Eval({|| nQtdSel--, nVlrSel-=SE1->E1_VLCRUZ}) ),;
			oSay1:CCAPTION := "Qtd Selec.: "+AllTrim(Transform(nQtdSel,"@R 999999999")),;
			oSay2:CCAPTION := "Vlr Selec.: "+AllTrim(Transform(nVlrSel,"@R 99,999,999.99")),;
			RecLock("SE1",.F.),SE1->E1_OK:=IIF(Marked("E1_OK"),oBrw:CCODMARCA,""),MsUnLock(),oBrw:REFRESHLINE() }

			lPrim := .F.
		EndIf
		
		ACTIVATE DIALOG oDlg CENTERED
		
		dbGoTop()
		//Variaveis criadas para consolidacao dos fontes de boletos
		aRet := {}
		aPergs  := {}
		aBancos := {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche as opcoes de Banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aBancos,"001 - Banco Do Brasil")
		aAdd(aBancos,"033 - Banco Santander")
		aAdd(aBancos,"237 - Banco Bradesco")
		aAdd(aBancos,"341 - Banco Itau")
		aAdd(aBancos,"422 - Banco Safra")
		aAdd(aBancos,"637 - Banco Sofisa")
		
		/*
		3 - Radio
		[2] : Descrição
		[3] : Numérico contendo a opção inicial do Radio
		[4] : Array contendo as opções do Radio
		[5] : Tamanho do Radio
		[6] : Validação
		[7] : Flag .T./.F. Parâmetro Obrigatório ?
		[8] : String contendo a validação When
		*/
		aAdd(aPergs,{3,"Selecione o banco para impressão de boletos",1,aBancos,100,,.T.})
		While Empty(aRet)
			ParamBox(aPergs ,"Parametros ",aRet)
		Enddo
		cBanco := Left(aBancos[aRet[1]],3)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se funcao de re-impressao, esta posicionado no SE1                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		__cBanco := cBanco
/*		If __cBanco == "341"
				
				If IsInCallStack("U_RFINA01")
					
					If Empty(E1_XAGEBCO)
						cChaveBanco := SE1->E1_XBCOBOL+SE1->E1_XAGEBCO+SE1->E1_XCONBCO
					Else
						cChaveBanco := "3410174 32626-4"
					EndIf
					
				Else
					
					nQtdSel := 0
					If ParamBox(aBancos ,OemToAnsi("Escolha a conta para Geração de Boletos novos"),aBancosRet)
						For ix:=1 to Len(aBancosRet)
							If aBancosRet[ix]
								cChaveBanco := aBancos[ix][2]
								nQtdSel++
							Endif
						Next
					EndIf
					
					If nQtdSel <> 1
						MsgInfo("Seleção inválida. Selecione 1 conta.")
						Return
					EndIf
					
				EndIf
				
			EndIf
		EndIf
*/
		//Posiciona o SA6 (Bancos)   
		DbSelectArea("SA6")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA6") + cChaveBanco)
			MsgInfo("Agência e conta não encontrados no cadastro de banco: " + cChaveBanco)
			Return  
		EndIf  
		
		If cBanco == "001"
			__cBanco    := "001"
			__cDgNumBCO := "-9"
			__cNomBCO   := "Banco do Brasil"
			__cNomBcoU := "DO BRASIL"
			__cNomBcoL := "Brasil"
			__cPrograma := "BLTCDNEW"
			__cCarteira := "17"
			
			cChaveBanco := "0013333 6278"
		ElseIf cBanco == "341"
			__cBanco    := "341"
			__cDgNumBCO := "-7"
			__cNomBCO   := "Banco Itaú SA"
			__cNomBcoU := "ITAÚ"
			__cNomBcoL := "Itaú"
			__cPrograma := "BLTCDITA"
			__cCarteira := "109"
			
			aAdd(aBancos,{5,	'3410174 32626-4   '	,.F., 200,'.T.',.T.})
			aAdd(aBancos,{5,	'3410174 026732    '	,.F., 200,'.T.',.T.})
			aAdd(aBancos,{5,	'3410174 066894    '	,.F., 200,'.T.',.T.})
			aAdd(aBancos,{5,	'3410174 05777     '	,.F., 200,'.T.',.T.})     
		ElseIf cBanco == "237"
		
			__cBanco    := "237"
			__cDgNumBCO := "-2"
			__cNomBCO   := "Banco Bradesco"
			__cNomBcoU  := "BRADESCO"
			__cNomBcoL  := "Bradesco"
			__cPrograma := "RFINA01"
			__cCarteira := "09"
			
			cChaveBanco := "23733677707007"
			
		ElseIf cBanco == "422"
			
			__cBanco    := "422"
			__cDgNumBCO := "-7"
			__cNomBCO   := "Banco Itaú SA"
			__cNomBcoU  := "ITAÚ"
			__cNomBcoL  := "Itaú"
			__cPrograma := "RFINA01"
			__cCarteira := "109"
			
			cChaveBanco := "42202800003525339"
		
		ElseIf cBanco == "637"
			
			__cBanco    := "637"
			__cDgNumBCO := "-7"
			__cNomBCO   := "Banco Santander"
			__cNomBcoU  := "SANTANDER"
			__cNomBcoL  := "Santander"
			__cPrograma := "RFINA01"
			__cCarteira := "5"
			
			cChaveBanco := "637"+"3689 "+"4845013   "
			
		ElseIf cBanco == "033"
			
			__cBanco    := "033"
			__cDgNumBCO := "-7"
			__cNomBCO   := "Banco Santander"
			__cNomBcoU  := "SANTANDER"
			__cNomBcoL  := "Santander"
			__cPrograma := "RFINA01"
			__cCarteira := "101"
			
			cChaveBanco := "0333689 0130065052"
			
		EndIf
	// Else
	// 	lExec := .T.
	// EndIf
	
	dbGoTop()
	
	If lExec
		
		cMsg	:= "Deseja Imprimir ou Enviar via e-mail?"
		If Type("__cPrograma") <> "C"
			__cPrograma := "RFINA01"
		EndIf
//		nOpc 	:= Aviso("",cMsg,{'Imprimir','E-mail'},1,"Impressão Boletos - "+__cPrograma)
		nOpc := 2
		
		If  nOpc == 1 //Imprimir
			lPDF := .F.
			Processa({|lEnd|MontaRel(lJob)})
		Else
			
			//********************************************
			//*Verifica se informou a mesma nota fiscal  *
			//********************************************
/*			If Alltrim(MV_PAR03) <> Alltrim(MV_PAR04)
				MsgInfo("Só é possível enviar 1 Nota por vez. Verifique os parâmetros 'Nota De e Até'",__cPrograma)
				Return
			EndIf*/
			
			cMsg	:= "Deseja Enviar Boleto ou Enviar Boleto + NF ?"
//			nOpc 	:= Aviso("",cMsg,{'&Boleto','Boleto+&Nota'},1,"Impressão Boletos - "+__cPrograma)
			nOpc := 2
			
			If  nOpc == 1 //Boleto
				lPDF := .T.
				lEnvioBol := .T.
				Processa({|lEnd|MontaRel(lJob)})
			Else
				lPDF := .T.
				lEnvioBol := .T.
				lEnvBolNF := .T.
				Processa({|lEnd|MontaRel(lJob)})
			EndIf
		Endif
	EndIf
Else
	
	lPDF      := .T.
	lEnvioBol := .T.
	lEnvBolNF := .T.
	MsgRun("Aguarde...Verificando títulos para impressão de boletos...",__cNomBcoL+" - Emissão de Boletos",{||MontaRel(lJob)})
	
EndIf

RetIndex("SE1")

Ferase(cIndexName+OrdBagExt())

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/{Protheus.doc} MontaRel
(Impressao do boleto laser com codigo de barras)
@type  Static Function
@author Renato Calabro'
@since 20/03/2019
@version 1.0
@param lJob, logic, (Variavel de controle para identificar se processo esta em job ou nao)
@return Nil, Nulo
@example
(examples)
@see (links_or_references)
/*/

Static Function MontaRel(lJob)

Local cFilePrint	:= ""
Local cDirPDF		:= "\boleto\"//AllTrim(GetSrvProfstring("rootpath",""))+"\boleto\"

Local nBolImp 		:= 0
Local nX			:= 0
Local nI           	:= 1
Local nVlrAbat		:= 0

Local aDadosEmp		:= {}
Local aDadosTit		:= {}
Local aDadosBanco	:= {}
Local aDatSacado	:= {}
Local aBolText		:= { MV_PAR19,MV_PAR20,MV_PAR21 }
Local aAreas		:= {SM0->(GetArea()), GetArea() }

Local oPrint		:= Nil

Private cLocal		:= ""

Private cNroDoc		:=  " "
Private nVetor		:= 0
Private nContB		:= 0
Private nTotItau	:= 0
Private nTotSemNN	:= 0
Private nTotImpEnv	:= 0

// Private lNNMadis		:= AllTrim(GetMV("LB_ITGRVNU",, "X")) == "S"		//Nosso Número gerado pela Madis - Parâmetro MV_SQNUMIT

Private dVencRea	:= CTOD("")
Private aTitulo		:= {}

Private aCB_RN_NN	:= {}

Default lJob		:= .F.

/*//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia Modo Grafico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cSession := GetPrinterSession()
Private nDevice
Private aDevice  := {}
Private oSetup
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona o SIGAMAT na filial 01 para que conste os dados da MATRIZ no boleto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
dbGoTop()
SM0->(MsSeek(cEmpAnt+cFilAnt))
aDadosEmp    := {	AllTrim(SM0->M0_NOMECOM),													; //[1]Nome da Empresa
					AllTrim(SM0->M0_ENDCOB),													; //[2]Endereço
					AllTrim(SM0->M0_BAIRCOB),													; //[3]Complemento
					AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB + " - CEP: "+					; //[4]Cidade + Estado
					Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),						; //[4]CEP
					"PABX/FAX: "+SM0->M0_TEL,													; //[5]Telefones
					"CNPJ "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+				; //[6]
					Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+						; //[6]
					Subs(SM0->M0_CGC,13,2),														; //[6]CGC
					"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+				; //[7]
					Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)							} //[7]I.E

aEval(aAreas, {|x| RestArea(x) })

cFilePrint		:= "boleto_IBG_" + AllTrim(SE1->E1_NUM) + AllTrim(SE1->E1_PREFIXO) + Dtos(MSDate()) + StrTran(Time(),":","")	//Left(Time(),2)

oPrint:= FwMSPrinter():New(cFilePrint,6,.T.,cDirPDF,.T.,,,,,,,.F.)
oPrint:SetPortrait() 		// ou SetLandscape()
oPrint:SetResolution(78)

nResult := 0
If !lIsDir(cDirPDF)
	nResult := MakeDir(cDirPDF)
Endif
If nResult <> 0
	Aviso("Inconistência","Não foi possível criar o diretório " + cDirPDF + " para a geração do arquivo do boleto em PDF.",{"Sair"},,"Atenção:")
	Return Nil
Else
	oPrint:cPathPDF := cDirPDF
EndIF

DbSelectArea("SE1")
dbGotop()
ProcRegua(RecCount())

While SE1->(!EOF())
	
	IncProc()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄğ
	//³Rotina MDFIN13 utilizada para envio de boleto automatico³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄğ
	// If !AllTRIM(FunName()) == "MDFIN13".And. !IsInCallStack("U_RFINA01")
	// 	//Quando nao estiver selecionado despreza o registro
	// 	If !Marked("E1_OK")
	// 		SE1->(DbSkip())
	// 		Loop
	// 	EndIf
	// EndIf
	If Type("__cBanco") <> "C"
		// cBanco := SE1->E1_XBCOBOL
		cBanco := SE1->E1_PORTADO
	EndIf
	
	If cBanco == "001"
		__cBanco    := "001"
		__cDgNumBCO := "-9"
		__cNomBCO   := "Banco do Brasil"
		__cNomBcoU := "DO BRASIL"
		__cNomBcoL := "Brasil"
		__cPrograma := "RFINA01"
		__cCarteira := "17"
		
		cChaveBanco := "0013333 6278"
	ElseIf cBanco == "341"
		__cBanco    := "341"
		__cDgNumBCO := "-7"
		__cNomBCO   := "Banco Itaú SA"
		__cNomBcoU := "ITAÚ"
		__cNomBcoL := "Itaú"
		__cPrograma := "BLTCDITA"
		__cCarteira := "109"
		
		aAdd(aBancos,{5,	'3410174 32626-4   '	,.F., 200,'.T.',.T.})
		aAdd(aBancos,{5,	'3410174 026732    '	,.F., 200,'.T.',.T.})
		aAdd(aBancos,{5,	'3410174 066894    '	,.F., 200,'.T.',.T.})
		aAdd(aBancos,{5,	'3410174 05777     '	,.F., 200,'.T.',.T.})     
	ElseIf cBanco == "237"
	
		__cBanco    := "237"
		__cDgNumBCO := "-2"
		__cNomBCO   := "Banco Bradesco"
		__cNomBcoU  := "BRADESCO"
		__cNomBcoL  := "Bradesco"
		__cPrograma := "RFINA01"
		__cCarteira := "09"
		
		cChaveBanco := "23733677707007"
		
	ElseIf cBanco == "422"
		
		__cBanco    := "422"
		__cDgNumBCO := "-7"
		__cNomBCO   := "Banco Itaú SA"
		__cNomBcoU  := "ITAÚ"
		__cNomBcoL  := "Itaú"
		__cPrograma := "RFINA01"
		__cCarteira := "109"
		
		cChaveBanco := "42202800003525339"
	
	ElseIf cBanco == "637"
		
		__cBanco    := "637"
		__cDgNumBCO := "-7"
		__cNomBCO   := "Banco Santander"
		__cNomBcoU  := "SANTANDER"
		__cNomBcoL  := "Santander"
		__cPrograma := "RFINA01"
		__cCarteira := "5"
		
		cChaveBanco := "637"+"3689 "+"4845013   "
		
	ElseIf cBanco == "033"
		
		__cBanco    := "033"
		__cDgNumBCO := "-7"
		__cNomBCO   := "Banco Santander"
		__cNomBcoU  := "SANTANDER"
		__cNomBcoL  := "Santander"
		__cPrograma := "RFINA01"
		__cCarteira := "ELETR C/ REG"
		
		cChaveBanco := "0333689 0130065423"
	EndIf

	IF !Vazio(SE1->E1_PORTADO)
		If ALLTRIM(SE1->E1_PORTADO) # __cBanco
			SE1->(DbSkip())
			Loop
		EndIf
	EndIf
	
	If __cBanco == "341"
		//Verifica se boleto já tem conta selecionada
		// If !Vazio(SE1->E1_XAGEBCO)
			// cChaveBanco := "341"+SE1->E1_XCONBCO+SE1->E1_XAGEBCO
		// Else
			//Se ainda não gravou, posiciona no banco selecionado no parâmetro de abertura
			cChaveBanco := "341"+SubStr(cChaveBanco,4,5)+SubStr(cChaveBanco,9,10)
		// EndIf
		
	EndIf
	
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA6")+cChaveBanco)
		msgInfo("Agência e conta não encontrados no cadastro de banco")
		SE1->(DbSkip())
		Loop
	EndIf
	
	//Posiciona o SA1 (Cliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	DbSelectArea("SE1")

	aDadosBanco  := {	SA6->A6_COD,			;// [1]Numero do Banco
						SA6->A6_NREDUZ,			;// [2]Nome do Banco
						,						;// [3]Agência
						,						;// [4]Conta Corrente
						,						;// [5]Dígito da conta corrente
						__cCarteira				}// [6]Codigo da Carteira 109 -> Diretas (nosso Número gerado pela Madis)/ 112-> Escriturais (nosso Número gerado pelo banco)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes dos bancos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __cBanco=="422"
		aDadosBanco[1] := "341"
		aDadosBanco[2] := __cNomBCO
		aDadosBanco[3] := "1248 "
		aDadosBanco[4] := "2341" //Conta
		aDadosBanco[5] := "6" //Digito da Conta
	ElseIf __cBanco $ "637/@/033"
		If __cBanco=="637"
			aDadosBanco[1] := "033"
			aDadosBanco[2] := __cNomBCO
		EndIf
		aDadosBanco[3] := SUBSTR(SA6->A6_AGENCIA, 1, 4)
		aDadosBanco[4] := ALLTRIM(SA6->A6_NUMCON)
		aDadosBanco[5] := " " //Digito da Conta
	ElseIf __cBanco=="001"
		aDadosBanco[3] := SUBSTR(SA6->A6_AGENCIA, 1, 4)+"-"+SUBSTR(SA6->A6_AGENCIA, 5, 5)
		aDadosBanco[4] := AllTrim(SA6->A6_NUMCON)
		aDadosBanco[5] := AllTrim(SA6->A6_DVCTA)
	ElseIf __cBanco=="237"
		aDadosBanco[3] := ALLTRIM(SA6->A6_AGENCIA)//+"-"+"4"
		aDadosBanco[4] := Left(SA6->A6_NUMCON, Len(SA6->A6_NUMCON)-1)	// SUBSTR(SA6->A6_NUMCON,2,6)
		aDadosBanco[5] := Right(SA6->A6_NUMCON,1)	//SUBSTR(SA6->A6_NUMCON,8,1)
	ElseIf __cBanco=="341"
		aDadosBanco[3] := SUBSTR(SA6->A6_AGENCIA, 1, 4)
		aDadosBanco[4] := AllTrim(SA6->A6_NUMCON)
		aDadosBanco[5] := SA6->A6_DVCTA
	EndIf

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
		AllTrim(SA1->A1_MUN )                            ,;  		// [4]Cidade
		SA1->A1_EST                                      ,;     	// [5]Estado
		SA1->A1_CEP                                      ,;      	// [6]CEP
		SA1->A1_CGC										 ,;			// [7]CGC
		SA1->A1_PESSOA									}  			// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)            	,; 		// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,; 	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;		// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                            ,; 		// [4]Cidade
		SA1->A1_ESTC	                                    ,; 		// [5]Estado
		SA1->A1_CEPC                                        ,; 		// [6]CEP
		SA1->A1_CGC											,;		// [7]CGC
		SA1->A1_PESSOA									}			// [8]PESSOA
	Endif
	
	//Soma abatimentos do título
	//nVlrAbat   :=  SomaAbat		(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nVlrAbat:=  0
	SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",,@nVlrAbat)
	nVlrAbat   +=  SE1->E1_DECRESC
	
	IF __cBanco=="237"
		//Nosso Numero + Digito Verificador
		cNroDoc := CalcNoNu()
	Else
		//Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo.
		//Abaixo apenas uma sugestao
		cNroDoc	:= Strzero(Val(Alltrim(SE1->E1_NUM)),6)+StrZERO(Val(Alltrim(SE1->E1_PARCELA)),2)
		cNroDoc	:= STRZERO(Val(cNroDoc),11)
	EndIf
	
	nVlrBol := E1_SALDO - nVlrAbat
	nVlrBol += SE1->E1_ACRESC
	
	dVencRea := SE1->E1_VENCREA//U_GetNewVFI2('*1',E1_VENCREA)
	
	If __cBanco == "237"
		//Monta codigo de barras e calcula o nosso numero com digito verificador
		aCB_RN_NN := Ret_cB(Subs(aDadosBanco[1],1,3), aDadosBanco[3], aDadosBanco[4], cNroDoc, nVlrBol ,dVencRea/*U_GetNewVFI2('*1',E1_VENCREA)*/)
	Else
		//Monta codigo de barras
		aCB_RN_NN := Ret_cBarra(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,nVlrBol,"18","9")
	EndIf
	
	DbSelectArea("SE1")
	aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
	E1_EMISSAO                              				,;	// [2] Data da emissão do título
	dDataBase                    							,;	// [3] Data da emissão do boleto
	dVencRea												,;	// [4] Data do vencimento
	nVlrBol               									,;  // [5] Valor do título
	aCB_RN_NN[3]                            				,;	// [6] Nosso número (Ver fórmula para calculo)
	E1_PREFIXO                              				,;	// [7] Prefixo da NF
	E1_TIPO	                           						,;	// [8] Tipo do Titulo
	E1_PARCELA}													//[9] Parcela
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄğ
	//³Rotina MDFIN13 utilizada para envio de boleto automatico³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄğ
	If lJob//AllTRIM(FunName()) == "MDFIN13" .Or. IsInCallStack("U_RFINA01")
		
		If __cBanco == "001"
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN, cFilePrint)
			nX := nX + 1
		ElseIf __cBanco == "341"
			
			
			// If !lNNMadis .And. Vazio(SE1->E1_NUMBCO) 	//Apenas quando já houve retorno do banco do Nosso Número
				
				//Se o Nosso Número estiver definido para ser gerado pelo banco (lNNMadis = .F.),
				//não imprime caso esteja com o Nosso Número em branco
				//(ou seja, ainda não teve o retorno cnab do banco com o Nosso Número)
				// nTotSemNN++
				
			// Else
				nTotImpEnv++
				Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN, cFilePrint)
				nX := nX + 1
			// EndIf
			
		ElseIf __cBanco $ "237,422,637,033"
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN, cFilePrint)
		EndIf
		
	Else
		
		DbSelectArea("SE1")
		If Marked("E1_OK")
			
			If nVlrBol > 0
				If __cBanco == "001"
					Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN, cFilePrint)
					nX := nX + 1
					
				Else
					
					// If !lNNMadis .And. Vazio(SE1->E1_NUMBCO)
						
						//Se o Nosso Número estiver definido para ser gerado pelo banco (lNNMadis = .F.),
						//não imprime caso esteja com o Nosso Número em branco
						//(ou seja, ainda não teve o retorno cnab do banco com o Nosso Número)
						// nTotSemNN++
						
					// Else
						
						nTotImpEnv++
						
						Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN, cFilePrint)
						nX := nX + 1
					// Endif
				Endif
			Else
				MsgInfo("Valor do boleto <= 0. Título: " + SE1->E1_FILIAL + " - " + SE1->E1_PREFIXO + SE1->E1_NUM + E1_PARCELA)
			EndIf
			
		EndIf
		
	EndIf
	
	If __cBanco == "001"
		
		DbSelectArea("SE1")
		RecLock("SE1", .F.)
		SE1->E1_NUMBCO	:=	aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
		SE1->E1_HIST	:= "BOLETO BB GERADO"
		// SE1->E1_XBCOBOL	:= "001"
		// SE1->E1_XNOMBCO	:= "BANCO DO BRASIL"
		MsUnlock()
		
	ElseIf __cBanco == "341"
		
		//If Vazio(SE1->E1_XBCOBOL)
			
			DbSelectArea("SE1")
			If RecLock("SE1", .F.)
				
				//Nosso Número gerado pela Madis - Parâmetro MV_SQNUMIT
				// If lNNMadis
					SE1->E1_NUMBCO	:= Substr(aCB_RN_NN[3],1,8)   // Nosso número
				// EndIf
				
				SE1->E1_HIST	:= "BOLETO ITAU GERADO"
				// SE1->E1_XBCOBOL	:= "341"
				// SE1->E1_XNOMBCO	:= "BANCO ITAU SA"
				// SE1->E1_XAGEBCO := SA6->A6_NUMCON 		//INVERTER
				// SE1->E1_XCONBCO := SA6->A6_AGENCIA
				
				MsUnlock()
				
				nTotItau++	//Total de títulos passados ao portador Itaú
			EndIf
		//EndIf
		
	ElseIf __cBanco == "237"
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º Atualiza titulo com informacao do nosso numero.                       º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		DbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO 	:= Substr(cNroDoc,1,12)
		SE1->E1_HIST 	:= "BOLETO BRADESCO GERADO"
		// SE1->E1_XBCOBOL	:= "237"
		// SE1->E1_XNOMBCO	:= "BANCO BRADESCO"
		MsUnlock()
		
	ElseIf __cBanco == "422"
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º Atualiza titulo com informacao do nosso numero.                       º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		DbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO 	:= Left(aCB_RN_NN[3],8)
		SE1->E1_HIST 	:= "BOLETO SAFRA GERADO"
		// SE1->E1_XBCOBOL	:= "422"
		// SE1->E1_XNOMBCO	:= "BANCO SAFRA"
		MsUnlock()
		
	ElseIf __cBanco == "637"

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º Atualiza titulo com informacao do nosso numero.                       º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		DbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO 	:= aCB_RN_NN[3]
		SE1->E1_HIST 	:= "BOLETO SOFISA GERADO"
		// SE1->E1_XBCOBOL	:= "637"
		// SE1->E1_XNOMBCO	:= "BANCO SOFISA"
		MsUnlock()	

	ElseIf __cBanco == "033"

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º Atualiza titulo com informacao do nosso numero.                       º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		DbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO 	:= aCB_RN_NN[3]
		SE1->E1_HIST 	:= "BOLETO SANTANDER GERADO"
		// SE1->E1_XBCOBOL	:= "033"
		// SE1->E1_XNOMBCO	:= "BANCO SANTANDER"
		MsUnlock()	
	EndIf
	
	SE1->(DbSkip())
	
	nI++
	
EndDo

If !lJob//!AllTRIM(FunName()) == "MDFIN13"
	
	If nTotItau > 0
		msgInfo("Total de títulos novos selecionados para recebimento no Itaú: " + AllTrim(Str(nTotItau)))
	EndIf
	
	If nTotSemNN > 0
		msgInfo("Total de títulos sem o Nosso Número informado: " + AllTrim(Str(nTotSemNN)))
	EndIf
	
	If nTotImpEnv > 0
		msgInfo("Total de títulos impressos/enviados: " + AllTrim(Str(nTotImpEnv)))
	EndIf
	
EndIf

//********************************
//*Verifica se é Envio de Email  *
//*para geração de Arquivo PDF   *
//********************************
If lPDF
	
	If !Empty(cFilePrint)
		oPrint:Preview()
		If File(oPrint:cFilePrint)
		 	FClose(oPrint:nHandle)                                                               
		 	File2Printer(oPrint:cFilePrint, "PDF" )
		 	sleep(1000)                     
		 	FErase(oPrint:cFilePrint)
	//	 	FErase(FileNoExt(oPrint:cFilePrint) + ".PDF")
		Endif
	Endif

	//*****************************************************
	//* Chama rotina de envio de e-mail [ RFA01EnvBol() ] *
	//*****************************************************
	RFA01EnvBol(cDirPDF,lEnvioBol,aTitulo,lEnvBolNF)
	SE1->(DBCLEARFILTER()) //Limpa o Filtro da tabela SE1
	
	FreeObj(oPrint)
	oPrint := Nil
Else
	oPrint:EndPage()     // Finaliza a página
	oPrint:Preview()     // Visualiza antes de imprimir
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASERDO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN, cFilePrint)

Local oFont8
Local oFont9
Local oFont7
Local oFont9n
Local oFont11c
Local oFont11
Local oFont10
Local oFont13
Local oFont14
Local oFont16n
Local oFont15
Local oFont14n
Local oFont18
Local oFont24
Local oBrush

Local _cNum     := SE1->E1_NUM
Local _cPrefix  := SE1->E1_PREFIXO
Local _cParcel  := SE1->E1_PARCELA
//Local cNomArq   := IIF(AllTrim(SE1->E1_NFELETR) == "" ,_cPrefix +'_'+ _cNum  + _cParcel,SE1->E1_NFELETR)
Local cCodCli   := SE1->E1_CLIENTE
Local cLojaCli  := SE1->E1_LOJA
Local cNomCli   := ALLTRIM(SE1->E1_NOMCLI)
Local _cPortado := ""
Local cXFil	    := SE1->E1_FILIAL
Local cXTipo	:= SE1->E1_TIPO
Local cLogo		:= "\system\bradesco.png"
Local nI := 0
Local nPosVet   := 0 
Local dDtProtes	:= CtoD("")

oFont7  	:= TFont():New("Arial",9,7,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8  	:= TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9  	:= TFont():New("Arial",9,9,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9n  	:= TFont():New("Arial",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11c 	:= TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  	:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13  	:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  	:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont18  	:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  	:= TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  	:= TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n 	:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  	:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n 	:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n 	:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  	:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush 		:= TBrush():New("",9)

oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/


nRow1 := -100

oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)



// oPrint:SayBitmap(nRow1+0114,100,cLogo,400,090) 													// o arquivo com o logo deve estar abaixo do rootpath (Data\system)
oPrint:SayBitmap(nRow1+0054,100,cLogo,380,090) 													// o arquivo com o logo deve estar abaixo do rootpath (Data\system)
// oPrint:Say  (nRow1+0114,100,__cNomBCO,oFont11 )	    // [2]Nome do Banco
oPrint:Say  (nRow1+0115,513,aDadosBanco[1]+__cDgNumBCO,oFont21 )	// [1]Numero do Banco

oPrint:Say  (nRow1+0104,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0170,100 ,OemToansi("Beneficiário:"),oFont8)
If __cBanco=="422"
	oPrint:Say  (nRow1+0220,100 ,"BANCO SAFRA S/A",oFont10)				//Nome + CNPJ
ElseIf __cBanco=="637"
	oPrint:Say  (nRow1+0220,100 ,OemToAnsi("BANCO SOFISA SP CNPJ 60.889.128/0001-80"),oFont10)				//Nome + CNPJ
Else
	oPrint:Say  (nRow1+0190,100 ,aDadosEmp[1]+" - "+aDadosEmp[6],oFont9)				//Nome + CNPJ
	oPrint:Say  (nRow1+0215,100 ,aDadosEmp[2],oFont9)									//End
	oPrint:Say  (nRow1+0240,100 ,aDadosEmp[3] + " - " + aDadosEmp[4],oFont9)			//Bairro + CEP + Compl
	// oPrint:Say  (nRow1+0220,100 ,aDadosEmp[1],oFont10)				//Nome
EndIf

oPrint:Say  (nRow1+0170,1060,OemToansi("Agência/Código Beneficiário:"),oFont8)
oPrint:Say  (nRow1+0220,1060,StrTran(aDadosBanco[3]+"/"+aDadosBanco[4]+IIF(Empty(aDadosBanco[5])," ","-"+aDadosBanco[5]),'--','-'),oFont10)

oPrint:Say  (nRow1+0170,1510,"Nro.Documento:",oFont8)
oPrint:Say  (nRow1+0220,1510,"  "+aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0270,100 ,"Pagador:",oFont8)
oPrint:Say  (nRow1+0320,100 ,SUBSTR(aDatSacado[1],1,40),oFont10)				//Nome

oPrint:Say  (nRow1+0270,1060,"Vencimento",oFont8)
oPrint:Say  (nRow1+0320,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

oPrint:Say  (nRow1+0270,1510,"Valor do Documento",oFont8)
oPrint:Say  (nRow1+0320,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0420,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say  (nRow1+0470,0100,"com as características acima.",oFont10)
oPrint:Say  (nRow1+0370,1060,"Data",oFont8)
oPrint:Say  (nRow1+0370,1410,"Assinatura",oFont8)
oPrint:Say  (nRow1+0470,1060,"Data",oFont8)
oPrint:Say  (nRow1+0470,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 )
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0185,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0225,1910,"(  )Ausente"                                  ,oFont8)
oPrint:Say  (nRow1+0265,1910,"(  )Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0305,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0345,1910,"(  )Não procurado"                            ,oFont8)
oPrint:Say  (nRow1+0385,1910,"(  )Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0425,1910,"(  )Desconhecido"                             ,oFont8)
oPrint:Say  (nRow1+0465,1910,"(  )Falecido"                                 ,oFont8)
oPrint:Say  (nRow1+0505,1910,"(  )Outros(anotar no verso)"                  ,oFont8)


/*****************/
/* SEGUNDA PARTE */
/*****************/

nRow2 := -80


//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(0500, nI,0500, nI+30)
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

// oPrint:SayBitmap(nRow2+0674,100,cLogo,400,090) 													// o arquivo com o logo deve estar abaixo do rootpath (Data\system)
oPrint:SayBitmap(nRow2+0610,100,cLogo,380,090) 													// o arquivo com o logo deve estar abaixo do rootpath (Data\system)
// oPrint:Say  (nRow2+0674,100,__cNomBCO,oFont11 ) 	// [2]Nome do Banco
oPrint:Say  (nRow2+0685,513,aDadosBanco[1]+__cDgNumBCO,oFont21 )	// [1]Numero do Banco
oPrint:Say  (nRow2+0694,1800,"Recibo do Pagador",oFont10)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say  (nRow2+0730,100 ,"Local de Pagamento:",oFont8)
oPrint:Say  (nRow2+0745,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ A DATA DO VENCIMENTO",oFont10)
If __cBanco != "422"
	oPrint:Say  (nRow2+0785,400 ,"APÓS O VENCIMENTO, SOMENTE NO BANCO "+__cNomBcoU,oFont10)
EndIf
oPrint:Say  (nRow2+0730,1810,"Vencimento:"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0770,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0830,100 ,OemToansi("Beneficiário:"),oFont8)
If __cBanco=="422"
	oPrint:Say  (nRow2+0870,100 ,"BANCO SAFRA S/A",oFont10)				//Nome + CNPJ
ElseIf __cBanco=="637"
	oPrint:Say  (nRow2+0870,100 ,OemToAnsi("BANCO SOFISA SP CNPJ 60.889.128/0001-80"),oFont10)				//Nome + CNPJ
Else
	oPrint:Say  (nRow2+0850,100 ,AllTrim(aDadosEmp[1]+" - "+aDadosEmp[6] ) ,oFont9) //Nome + CNPJ
	oPrint:Say  (nRow2+0875,100 ,aDadosEmp[2],oFont9)								//End + Bairro
	oPrint:Say  (nRow2+0900,100 ,aDadosEmp[3] + " - " + aDadosEmp[4],oFont9)		//CEP + Compl
	// oPrint:Say  (nRow2+0870,100 ,aDadosEmp[1],oFont10)				//Nome
EndIf

oPrint:Say  (nRow2+0830,1810,"Agência/Código "+OemToansi("Beneficiário:"),oFont8)
cString := StrTran(Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+IIF(Empty(aDadosBanco[5])," ","-"+aDadosBanco[5])),'--','-')
nCol := 1818+(374-(len(cString)*22))
oPrint:Say  (nRow2+0870,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0930,100 ,"Data do Documento:"                              ,oFont8)
oPrint:Say  (nRow2+0960,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

oPrint:Say  (nRow2+0930,505 ,"Nro.Documento:"                                  ,oFont8)
oPrint:Say  (nRow2+0960,605 ,aDadosTit[1]						,oFont10) //Numero+Parcela
//oPrint:Say  (nRow2+0940,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0930,1005,"Espécie Doc.:"                                   ,oFont8)
oPrint:Say  (nRow2+0960,1050,"DM"										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0930,1305,"Aceite:"                                         ,oFont8)
oPrint:Say  (nRow2+0960,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow2+0930,1485,"Data do Processamento:"                          ,oFont8)
oPrint:Say  (nRow2+0960,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

oPrint:Say  (nRow2+0930,1810,"Nosso Número:"                                   ,oFont8)
If __cBanco == "341" .Or. __cBanco == "422"
	cString := aDadosBanco[6] + "/" + Alltrim(substr(aDadosTit[6],1,8)) + "-" + Alltrim(substr(aDadosTit[6],9,1))
ElseIf __cBanco == "001"
	//cString := Alltrim(Substr(aDadosTit[6],0,0)+"122523300"+Substr(aDadosTit[1],1,6)+"0"+Substr(aDadosTit[1],7,1))
	cString := Alltrim("1225233"+aDadosTit[6])
ElseIf __cBanco == "237"
	cString := '09/'+Substr(cNroDoc,1,11)+'-'+Substr(cNroDoc,12,1)
ElseIf __cBanco $ "637/@/033"
	cString := aDadosTit[6]+'-'+Modulo11(aDadosTit[6])
EndIf

nCol := 1854+(374-(len(cString)*22))
oPrint:Say  (nRow2+0960,nCol,cString,oFont11c)

oPrint:Say  (nRow2+1000,100 ,"Uso do Banco:"                                   ,oFont8)

oPrint:Say  (nRow2+1000,505 ,"Carteira:"                                       ,oFont8)
oPrint:Say  (nRow2+1030,555 ,aDadosBanco[6]                                  	,oFont10)

oPrint:Say  (nRow2+1000,755 ,"Espécie:"                                        ,oFont8)
oPrint:Say  (nRow2+1030,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+1000,1005,"Quantidade:"                                     ,oFont8)
oPrint:Say  (nRow2+1000,1485,"Valor:"                                          ,oFont8)

oPrint:Say  (nRow2+1000,1810,"(=) Valor do Documento:"                         ,oFont8)

cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))

nCol := 1796+(374-(len(cString)*22))
oPrint:Say  (nRow2+1030,nCol,cString ,oFont11c)

//oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
If __cBanco != "422"
	oPrint:Say  (nRow2+1070,100 ,OemToAnsi("Instruções de responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO."),oFont8)
EndIf
// oPrint:Say  (nRow2+1120,120 ,"APÓS VENCIMENTO COBRAR:",oFont10)
oPrint:Say  (nRow2+1120,120 ,"^ ^ VALORES EXPRESSOS EM REAIS ^^^^ ^",oFont10)
// oPrint:Say  (nRow2+1120,1000,IIF(SE1->E1_NUM <> SE1->E1_NFELETR .And. !Empty(SE1->E1_NFELETR),"Boleto Ref. NFS-e : "+SE1->E1_NFELETR,"" ),oFont10)
oPrint:Say  (nRow2+1170,120 ,"JUROS POR DIA DE ATRASO..........." + Alltrim(Transform(Round(aDadosTit[5]/300,2),"@E 99,999,999.99")) ,oFont10)
oPrint:Say  (nRow2+1220,120,"Boleto Ref. NF "+SE1->E1_PREFIXO + "-" + SE1->E1_NUM + " SUJEITO A PROTESTO APÓS VENCIMENTO",oFont10)
// oPrint:Say  (nRow2+1220,120 ,"MULTA 2%",oFont10)

// If __cBanco == "001"
// 	dDtProtes := aDadosTit[4] + 4
// ElseIf __cBanco == "033"
// 	dDtProtes := aDadosTit[4] + 5
// Else
// 	dDtProtes := aDadosTit[4]
// EndIf
// If DoW(dDtProtes) = 1
// 	dDtProtes := dDtProtes + 1
// EndIf
// oPrint:Say  (nRow2+1270,120 ,"PROTESTO AUTOMÁTICO APÓS 5º DIA DO VENCIMENTO - " + DToC(dDtProtes) + ".",oFont10)
// If __cBanco == "422"
// 	oPrint:Say  (nRow2+1320,120 ,"Este boleto representa duplicata cedida fiduciariamente ao banco Safra S/A,",oFont10)
// 	oPrint:Say  (nRow2+1370,120 ,"ficando vedado o pagamento de qualquer outra forma que não através do presente boleto.",oFont10)
// Else
// 	oPrint:Say  (nRow2+1320,120 ,"SR. CAIXA, FAVOR SEGUIR AS ORIENTAÇÕES ACIMA.",oFont10)
// EndIf

oPrint:Say  (nRow2+1070,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+1140,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow2+1210,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+1280,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow2+1350,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow2+1420,100 ,"Pagador:"                                         ,oFont8)
oPrint:Say  (nRow2+1450,370 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+1503,370 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1566,370 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1450,1750 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow2+1450,1750 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow2+1625,100 ,"Pagador/Avalista",oFont8)

If __cBanco == "422"
	oPrint:Say  (nRow2+1625,370 ,"MADIS RODBEL SOL PONTO AC LTDA",oFont10)
EndIf

oPrint:Say  (nRow2+1665+20,1500,"Autenticação Mecânica",oFont8)

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640+20,100 ,nRow2+1640+20,2300 )

/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := -180

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1890, nI, nRow3+1890, nI+30)
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

// oPrint:SayBitmap(nRow3+1964,100,cLogo,400,090) 													// o arquivo com o logo deve estar abaixo do rootpath (Data\system)
oPrint:SayBitmap(nRow3+1900,100,cLogo,380,090) 													// o arquivo com o logo deve estar abaixo do rootpath (Data\system)
// oPrint:Say  (nRow3+1964,100,__cNomBCO,oFont11) 			//Nome do Banco
oPrint:Say  (nRow3+1970,513,aDadosBanco[1]+__cDgNumBCO,oFont21 )		//Numero do Banco

If __cBanco == "237"
	//Linha Digitavel
	cLinDig := MontaLinha(aDadosTit[4])
	oPrint:Say  (nRow3+1934,740,cLinDig,oFont14n)				//	Linha Digitavel do Codigo de Barras
Else
	oPrint:Say  (nRow3+1964,755,aCB_RN_NN[2],oFont15n)			//		Linha Digitavel do Codigo de Barras
EndIf

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2020,100 ,"Local de Pagamento:",oFont8)
oPrint:Say  (nRow3+2035,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ A DATA DO VENCIMENTO",oFont10)
If  __cBanco != "422"
	oPrint:Say  (nRow3+2075,400 ,"APÓS O VENCIMENTO, SOMENTE NO BANCO "+__cNomBcoU,oFont10)
EndIf

oPrint:Say  (nRow3+2020,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2060,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2120,100 ,OemToansi("Beneficiário:"),oFont8)
If __cBanco=="422"
	oPrint:Say  (nRow3+2160,100 ,"BANCO SAFRA S/A",oFont10)				//Nome + CNPJ
ElseIf __cBanco=="637"
	oPrint:Say  (nRow3+2160,100 ,OemToAnsi("BANCO SOFISA SP CNPJ 60.889.128/0001-80"),oFont10)				//Nome + CNPJ
Else
	oPrint:Say  (nRow3+2140,100 ,AllTrim(aDadosEmp[1]+" - "+aDadosEmp[6] )	,oFont9)	//Nome + CNPJ
	oPrint:Say  (nRow3+2165,100 ,aDadosEmp[2],oFont9)									//End + Bairro
	oPrint:Say  (nRow3+2190,100 ,aDadosEmp[3] + " - " + aDadosEmp[4],oFont9)			//CEP + Compl
	// oPrint:Say  (nRow3+2160,100 ,aDadosEmp[1],oFont10)				//Nome
EndIf

oPrint:Say  (nRow3+2120,1810,"Agência/Código "+OemToansi("Beneficiário:"),oFont8)

cString := StrTran(Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+IIF(Empty(aDadosBanco[5])," ","-"+aDadosBanco[5])),'--','-')
nCol 	:= 1818+(374-(len(cString)*22))
oPrint:Say  (nRow3+2160,nCol,cString ,oFont11c)

oPrint:Say (nRow3+2220,100 ,"Data do Documento:"                              ,oFont8)
oPrint:Say (nRow3+2250,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)


oPrint:Say  (nRow3+2220,505 ,"Nro.Documento:"                                  ,oFont8)
oPrint:Say  (nRow3+2250,605 ,aDadosTit[1]						,oFont10) //Numero+Parcela
//oPrint:Say  (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2220,1005,"Espécie Doc.:"                                   ,oFont8)
oPrint:Say  (nRow3+2250,1050,"DM"	  									,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2220,1305,"Aceite:"                                         ,oFont8)
oPrint:Say  (nRow3+2250,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+2220,1485,"Data do Processamento:"                          ,oFont8)
oPrint:Say  (nRow3+2250,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+2220,1810,"Nosso Número:"                                   ,oFont8)
If __cBanco == "341" .Or. __cBanco == "422"
	cString := aDadosBanco[6]+"/"+Alltrim(substr(aDadosTit[6],1,8))+"-"+Alltrim(substr(aDadosTit[6],9,1))
ElseIf __cBanco == "001"
	//cString := Alltrim(Substr(aDadosTit[6],0,0)+"122523300"+Substr(aDadosTit[1],1,6)+"0"+Substr(aDadosTit[1],7,1))
	cString := Alltrim("1225233"+aDadosTit[6])
ElseIf __cBanco == "237"
	cString := '09/'+Substr(cNroDoc,1,11)+'-'+Substr(cNroDoc,12,1)
ElseIf __cBanco == "637/@/033"
	cString := aDadosTit[6]+'-'+Modulo11(aDadosTit[6])
EndIf
nCol 	 := 1854+(374-(len(cString)*22))
oPrint:Say  (nRow3+2250,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2290,100 ,"Uso do Banco:"        ,oFont8)

oPrint:Say  (nRow3+2290,505 ,"Carteira:"            ,oFont8)
oPrint:Say  (nRow3+2320,555 ,aDadosBanco[6]                  ,oFont10)

oPrint:Say  (nRow3+2290,755 ,"Espécie:"             ,oFont8)
oPrint:Say  (nRow3+2320,805 ,"R$"                   ,oFont10)

oPrint:Say  (nRow3+2290,1005,"Quantidade:"          ,oFont8)
oPrint:Say  (nRow3+2290,1485,"Valor:"               ,oFont8)

oPrint:Say  (nRow3+2290,1810,"(=) Valor do Documento:" ,oFont8)

cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1796+(374-(len(cString)*22))
oPrint:Say  (nRow3+2320,nCol,cString,oFont11c)

//oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
IF __cBanco != "422"
	oPrint:Say  (nRow3+2360,100 ,OemToAnsi("Instruções de responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO."),oFont8)
EndIf

// oPrint:Say  (nRow3+2410,120 ,"APÓS VENCIMENTO COBRAR:",oFont10)
oPrint:Say  (nRow3+2410,120 ,"^ ^ VALORES EXPRESSOS EM REAIS ^^^^ ^",oFont10)
// oPrint:Say  (nRow3+2410,1000,IIF(SE1->E1_NUM <> SE1->E1_NFELETR .And. !Empty(SE1->E1_NFELETR),"Boleto Ref. NFS-e : "+SE1->E1_NFELETR,"" ),oFont10)
//oPrint:Say  (nRow3+2460,120 ,"JUROS/MORA 1% A.M.",oFont10)
// oPrint:Say  (nRow3+2510,120 ,"MULTA 2%",oFont10)
oPrint:Say  (nRow3+2460,120 ,"JUROS POR DIA DE ATRASO..........." + Alltrim(Transform(Round(aDadosTit[5]/300,2),"@E 99,999,999.99")) ,oFont10)
oPrint:Say  (nRow3+2510,120,"Boleto Ref. NF "+SE1->E1_PREFIXO + "-" + SE1->E1_NUM + " SUJEITO A PROTESTO APÓS VENCIMENTO",oFont10)

// If __cBanco == "001"
// 	dDtProtes := aDadosTit[4] + 4
// ElseIf __cBanco == "033"
// 	dDtProtes := aDadosTit[4] + 5
// Else
// 	dDtProtes := aDadosTit[4]
// EndIf
// If DoW(dDtProtes) = 1
// 	dDtProtes := dDtProtes + 1
// EndIf
// oPrint:Say  (nRow3+2560,120 ,"PROTESTO AUTOMÁTICO APÓS 5º DIA DO VENCIMENTO - " + DToC(dDtProtes) + ".",oFont10)
// If __cBanco == "422"
// 	oPrint:Say  (nRow3+2610,120 ,"Este boleto representa duplicata cedida fiduciariamente ao banco Safra S/A,",oFont10)
// 	oPrint:Say  (nRow3+2660,120 ,"ficando vedado o pagamento de qualquer outra forma que não através do presente boleto.",oFont10)
// Else
// 	oPrint:Say  (nRow3+2610,120 ,"SR. CAIXA, FAVOR SEGUIR AS ORIENTAÇÕES ACIMA.",oFont10)
// EndIf

oPrint:Say  (nRow3+2360,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2430,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+2500,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2570,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow3+2640,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2710,100 ,"Pagador:"                                         ,oFont8)
oPrint:Say  (nRow3+2720,370 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2720,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow3+2720,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2773,370 ,aDatSacado[3], oFont10)
oPrint:Say  (nRow3+2826,370 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5], oFont10) // CEP+Cidade+Estado

oPrint:Say  (nRow3+2885,100 ,"Pagador/Avalista", oFont8)

/*If __cBanco == "422"
	oPrint:Say  (nRow3+2885,370 ,"MADIS RODBEL SOL PONTO AC LTDA",oFont10)
ElseIf __cBanco == "637"
	oPrint:Say  (nRow3+2885,370 ,"MADIS RODBEL SOL. DE PONTO E ACESSO LTDA - CNPJ 61.092.565/0001-30",oFont10)
ELSE
	oPrint:Say  (nRow3+2885,370 ,"NECESSARIO VERIFICAR ONDE ESTÁ APRESENTANDO - CNPJ 61.092.565/0001-30",oFont10)
EndIf
*/
oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2930,100,nRow3+2930,2300  )

oPrint:Say  (nRow3+2950,1500,"Autenticação Mecânica - Ficha de Compensação", oFont8)

oPrint:FWMSBAR("INT25",68,2,aCB_RN_NN[1],oPrint,.F., Nil,.T.,0.020,0.75,.F.,"Arial",'',.F.,0.5,0.5,.T. )

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+3065, nI, nRow3+3065, nI+30)
Next nI

oPrint:EndPage() // Finaliza a página

_cPortado := SE1->E1_PORTADO

//******************************************************
//* Guarda todos os titulos Gerados no vetor [ aTitulo]*
//******************************************************
//****************************************
//*Verifia se o Envio e somente de Boleto *
//*Caso contrario envia Boleto + Nota     *
//*****************************************
If lPDF
	
	nPosVet:=aScan(aTitulo, {|x| x[1] == cFilePrint}) //Pesquisa no vetor1
	
	If nPosVet == 0
		aAdd(aTitulo,{cFilePrint, _cNum, _cPrefix, _cParcel, cCodCli, cLojaCli, cNomCli, _cPortado, oPrint, cXFil, cXTipo })
	EndIf
	
EndIf

Return Nil

/************************************************************
* Define nosso numero para calculo e impressao de boletos.  -------- usado no boleto do bradesco
************************************************************/
Static Function CalcNoNu()

If Empty( SE1->E1_NUMBCO )
	cNroDoc := SUBS(SE1->E1_CLIENTE,2,5) + STRZERO(SE1->(RECNO()),6)
Else
	cNroDoc := Substr(SE1->E1_NUMBCO,1,11)
EndIf

//cNroDoc  := "09" + cNroDoc		// Carteira + nosso numero
cNroDoc  := __cCarteira + cNroDoc		// Carteira + nosso numero

cCombina := "2765432765432"		// 13 posicoes
aResulta := {}

For nCont := 1 To 13
	
	nVal1 := Val( SubStr( cNroDoc,  nCont, 1 ) )
	nVal2 := Val( SubStr( cCombina, nCont, 1 ) )
	
	AAdd( aResulta, nVal1 * nVal2 )
Next

nTotProd  := 0
For nCont := 1 To Len(aResulta)
	nTotProd := nTotProd + aResulta[ nCont ]
Next

nResulta := Int(nTotProd / 11)
nResto   := nTotProd - ( nResulta * 11 )

If nResto >= 1
	
	_cDigito := Alltrim(Str( 11 - nResto))
	
	if _cDigito == "10"
		cDigVerif := "P"
	Else
		cDigVerif := Alltrim(Str( 11 - nResto))
	Endif
Else
	cDigVerif := "0"
Endif

cNroDoc  := Substr(cNroDoc,3,11) + cDigVerif

Return cNroDoc

/*****************************************************************
* Montagem do código de barras                                   *
*****************************************************************/
Static Function Ret_CB(cBanco, cAgencia, cConta, cNroDoc, nValor, dVencto)

Local cCodigoBar	:= ""

Local cValorFinal   := StrZero(nValor * 100,10)
Local cNN			:= StrZero(Val(Substr(cNroDoc,1,11)),11)
Local cFator      	:= StrZero(dVencto - ctod("07/10/97"),4)
Local cDigBar 		:= " " 	//dígito verificador do código de barras

//Primeira parte - Posição 01 a 19
cCodigoBar := cBanco + "9" + cDigBar + cFator + cValorFinal

//Segunda parte - Campo Livre
cCodigoBar += SubStr(cAgencia,1,4)		//Tamanho 04 - Posição 20 a 23
cCodigoBar += "09"						//Tamanho 02 - Posição 24 a 25
cCodigoBar += cNN						//Tamanho 11 - Posição 26 a 36
cCodigoBar += "0118788"					//Tamanho 07 - Posição 37 a 43
cCodigoBar += "0"						//Tamanho 01 - Posição 44

//Adiciona dígito verificador a posição 5
cCodigoBar := calcDigBar(cCodigoBar)

Return {cCodigoBar,"",cNN}

/********************************************************
* Cálculo do dígito verificador do código de barras     *
********************************************************/
Static Function calcDigBar(cCodCalc)

Local nFator
Local nTot 		:= 0
Local nDigito
Local nResto

//Retira posição 5 para cálculo do dígito verificador
cCodCalc := SubStr(cCodCalc,1,4) + SubStr(cCodCalc,6,39)

n := Len(cCodCalc)  //quantidade de posições (43)
nFator := 2			//Fator inicial

//Varre as posições da direita para a esquerda
While n > 0
	
	If nFator == 10
		nFator := 2
	EndIf
	
	nTot += Val(SubStr(cCodCalc, n, 1)) * nFator
	
	nFator++
	n--
EndDo

//Resto da divisão por 11
nResto := Mod(nTot,11)

//Subtrai de 11
nDigito := 11 - nResto

If nDigito == 0 .Or. nDigito == 10 .Or. nDigito == 11
	nDigito := 1
EndIf

//Adiciona dígito verificador
cCodCalc := SubStr(cCodCalc,1,4) + AllTrim(Str(nDigito)) + SubStr(cCodCalc,5,39)

Return cCodCalc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera SE1                        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
cBanco		,cAgencia	,cConta		,cDacCC	,;
cNroDoc		,nValor		,cCart		,cMoeda	)

Local cNosso		:= ""
Local cDigNosso	:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra	:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1		:= ""
Local cParte2		:= ""
Local cDig2		:= ""
Local cParte3		:= ""
Local cDig3		:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital	:= ""
Local aRet			:= {}

cAgencia:=STRZERO(Val(cAgencia),4)
cCart 	:= __cCarteira
cNosso 	:= ""

If __cBanco == "001"
	
	//Nosso Numero
	If !Empty(SE1->E1_NUMBCO)
		nNum   := SE1->E1_NUMBCO
		cNosso := SE1->E1_NUMBCO
	Else
		cNosso := GetMV("ES_SQNUMBB",, "0")
		cNosso := StrZero(Val(cNosso)+1,10) //nNUM + cDigNosso
		nNum   := cNosso
		
		//Gravo o numero sequencia do Banco do Brasil no Arquivo de Parametros
		DbSelectArea("SX6")
		DbSetOrder(1)
		If !DbSeek(Space(Len(cFilAnt))+"ES_SQNUMBB")
			DbSeek(cFilAnt+"ES_SQNUMBB")
		EndIf
		Reclock("SX6",.F.)
		PutMV("ES_SQNUMBB", cNosso)
		MsUnlock()
	EndIf
	
	
	cFatorValor  := fator1() + Strzero(nValor * 100,10)
	cConvenio := "1225233"
	
	cCampoL := "000000" + cConvenio + alltrim(NNUM) + cCart
	
	cLivre 	:= cBanco + cMoeda + cFatorValor + cCampoL
	
	// campo do codigo de barra
	cDigBarra := CALC_Dp( cLivre )
	
	
	//	Código Banco (3) + Moeda (1) + DAC código barras (1) + Fator Venc (4) + Valor (10) + cCampoL
	cBarra    := Substr(cLivre,1,4) + cDigBarra + cFatorValor + Substr(cCampoL,1,25)
	
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + SUBSTR(cCampoL,1,5)
	cDig1    := DIGIT0001( cParte1 )
	cParte2  := SUBSTR(cCampoL,6,10)
	cDig2    := DIGIT0001( cParte2 )
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT0001( cParte3 )
	
	cParte4  := " " + cDigBarra + " "
	cParte5  := cFatorValor
	
	cDigital := substr(cParte1,1,5) + "." + substr(cparte1,5,4) + cDig1 + " "
	cDigital += substr(cParte2,1,5)	+ "." + substr(cparte2,6,5) + cDig2 + " "
	cDigital += substr(cParte3,1,5)	+ "." + substr(cparte3,6,5) + cDig3 + " "
	cDigital += cParte4
	cDigital += cParte5
	
	
ElseIf __cBanco == "341"
	
	//Nosso Numero
	If !Empty(SE1->E1_NUMBCO)
		cNosso 		:= alltrim(SE1->E1_NUMBCO)
		cDigNosso  	:= CALC_diE(cCart + cNosso)
		nNum     	:= cNosso
		cNosso		:= cNosso + cDigNosso
	Else
		
		// If lNNMadis
			cNosso   := GetMV("ES_SQNUMIT",, "0")
		// EndIf
		
		cDigNosso:= CALC_diE(cCart + cNosso)
		
		nNum    := cNosso
		cNosso	:= cNosso + cDigNosso
		
		// If lNNMadis
			//Gravo o numero sequencia do Banco do Itau no Arquivo de Parametros
		// 	DbSelectArea("SX6")
		// 	DbSetOrder(1)
		// 	If !DbSeek(Space(Len(cFilAnt))+"ES_SQNUMIT")
		// 		DbSeek(cFilAnt+"ES_SQNUMIT")
		// 	EndIf
		// 	Reclock("SX6",.F.)
		// 	SX6->X6_CONTEUD := strzero(val(nNum) + 1,8)
		// 	MsUnlock()
		// Endif
	EndIf
	
	cNosso := Alltrim(cNosso)
	
	If nValor > 0
		cFatorValor  := fator1() + Strzero(nValor * 100,10)
	Else
		cFatorValor  := fator1() + strzero(SE1->E1_VALOR * 100,10)
	EndIf
	
	//	Carteira (3) + Nosso Número (8) + DAC [Agência /Conta/Carteira/Nosso Número](1) + Agencia (4) + Conta (5) + DAC [Agência/Conta Corrente] (1) + 3 zeros
	cCampoL := cCart + cNosso + "0174326264000"
	
	cLivre 	:= cBanco + cMoeda + cFatorValor + cCampoL
	
	// campo do codigo de barra
	cDigBarra := CALC_Dp( cLivre )
	
	
	//	Código Banco (3) + Moeda (1) + DAC código barras (1) + Fator Venc (4) + Valor (10) + cCampoL
	cBarra := cBanco + cMoeda + cDigBarra + cFatorValor + Substr(cCampoL,1,25)
	
	
	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + SUBSTR(cCampoL,1,5)
	cDig1    := DIGIT0001( cParte1 )
	cParte2  := SUBSTR(cCampoL,6,10)
	cDig2    := DIGIT0001( cParte2 )
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT0001( cParte3 )
	
	cParte4  := " " + cDigBarra + " "
	cParte5  := cFatorValor
	
	cDigital := substr(cParte1,1,5)	+ "." + substr(cparte1,6,4) + cDig1 + " "
	cDigital += substr(cParte2,1,5)	+ "." + substr(cparte2,6,5) + cDig2 + " "
	cDigital += substr(cParte3,1,5)	+ "." + substr(cparte3,6,5) + cDig3 + " "
	cDigital += cParte4
	cDigital += cParte5
	
ElseIf __cBanco == "422"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do NOSSO NUMERO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SE1->E1_NUMBCO)
		cNosso := Left(SE1->E1_NUMBCO,8)
	Else
		cNosso := GetMV("ES_SQNUMSF",, "0")
		cNosso := StrZero(Val(cNosso)+1,8)
		
		//Gravo o numero sequencia do Banco Safra no Arquivo de Parametros
		PutMV("ES_SQNUMSF",cNosso)
	EndIf
	
	//Complementa o digito do Nosso Numero
	cNosso := cNosso+Modulo10("1248"+"02341"+"109"+cNosso)
	cNosso := Alltrim(cNosso)
	
	//Composicao da informacao do codigo de barras
	cB001003 := "341"
	cB004004 := "9"
	//cB005005 :=
	CB006009 := Fator1()
	cB010019 := Strzero(nValor * 100,10)
	cB020044 := "109"+cNosso+"1248023416"+"000"
	cB005005 := CALC_Dp(cB001003+cB004004+cB006009+cB010019+cB020044)
	
	//Codigo de barras completo
	cBarra  := cB001003+cB004004+cB005005+cB006009+cB010019+cB020044
	
	//Composicao da Linha digitavel
	cDigital := Substr(cBarra,01,03)
	cDigital += Substr(cBarra,04,01)
	cDigital += Substr(cBarra,20,05)
	cDigital += DIGIT0001(Substr(cBarra,01,03)+Substr(cBarra,04,01)+Substr(cBarra,20,05))
	cDigital += Substr(cBarra,25,10)
	cDigital += DIGIT0001(Substr(cBarra,25,10))
	cDigital += Substr(cBarra,35,10)
	cDigital += DIGIT0001(Substr(cBarra,35,10))
	cDigital += Substr(cBarra,05,01)
	cDigital += Substr(cBarra,06,14)
	
	//Composicao / Formatacao da Linha digitavel
	//422970040-8 0000278247-2 2617300111-1 8 1001000008084
	//42297.00408 00002.782472 26173.001111 8 1001000008084
	//XXXXX.XXXXX XXXXX.XXXXXX XXXXX.XXXXXX X XXXXXXXXXXXXX
	cDigital :=;
	Substr(cDigital,01,05) + "." + ;
	Substr(cDigital,06,05) + " " + ;
	Substr(cDigital,11,05) + "." + ;
	Substr(cDigital,16,06) + " " + ;
	Substr(cDigital,22,05) + "." + ;
	Substr(cDigital,27,06) + " " + ;
	Substr(cDigital,33,01) + " " + ;
	Substr(cDigital,34,14)
	
ElseIf __cBanco $ "033/#/637"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem do NOSSO NUMERO³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SE1->E1_NUMBCO)
		cNosso := Left(SE1->E1_NUMBCO,12)
	Else
		If __cBanco == "033" 
			//Gravo o numero sequencia do Banco Santander no Arquivo de Parametros
			cNosso := GetMV("ES_SQNUMSA",, "0")
			cNosso := StrZero(Val(cNosso)+1,12)
			PutMV("ES_SQNUMSA",cNosso)
		Else
			//Gravo o numero sequencia do Banco Sofisa no Arquivo de Parametros
			cNosso := GetMV("ES_SQNUMSO",, "0")
			cNosso := StrZero(Val(cNosso)+1,12)
			PutMV("ES_SQNUMSO",cNosso)
		EndIf
	EndIf
	
	cB001003 := "033"
	cB004004 := "9"
	CB006009 := Strzero(dVENCREA - STOD("19971007"),4)
	cB010019 := Strzero(nValor * 100,10)
	cB020020 := "9"
	cB021027 := "4845013"
	cB028040 := cNosso+Modulo11(cNosso)
	cB041041 := "0"
	cB042044 := "102"
	cB005005 := Modulo11(cB001003+cB004004+CB006009+cB010019+cB020020+cB021027+cB028040+cB041041+cB042044)
	
	//6379?xxxx000000000094845013xxxxxxxxxxxxy0102
	
	//Codigo de barras completo
	cBarra  := cB001003+cB004004+cB005005+CB006009+cB010019+cB020020+cB021027+cB028040+cB041041+cB042044
	
	//Composicao da Linha digitavel
	_cBloco1 := cB001003+cB004004+cB020020+Substr(cB021027,01,04)
	//          XXX      X         X        XXXX
	_cBloco1 += Modulo10(_cBloco1)
	//          X
	_cBloco2 := Substr(cB021027,05,03)+Left(cB028040,7)
	//          XXX                     XXXXXXX
	_cBloco2 += Modulo10(_cBloco2)
	//          X
	_cBloco3 := Substr(cB028040,08,06)+cB041041+cB042044
	//          XXXXXX                  X        XXX
	_cBloco3 += Modulo10(_cBloco3)
	//          X
	_cBloco4 := cB005005
	//          X
	_cBloco5 := CB006009+cB010019
	//          XXXX      XXXXXXXXXX
	
	//Composicao / Formatacao da Linha digitavel
	//422970040-8 0000278247-2 2617300111-1 8 1001000008084
	//42297.00408 00002.782472 26173.001111 8 1001000008084
	//XXXXX.XXXXX XXXXX.XXXXXX XXXXX.XXXXXX X XXXXXXXXXXXXX
	cDigital += _cBloco1+_cBloco2+_cBloco3+_cBloco4+_cBloco5
	cDigital :=;
	Substr(cDigital,01,05) + "." + ;
	Substr(cDigital,06,05) + " " + ;
	Substr(cDigital,11,05) + "." + ;
	Substr(cDigital,16,06) + " " + ;
	Substr(cDigital,22,05) + "." + ;
	Substr(cDigital,27,06) + " " + ;
	Substr(cDigital,33,01) + " " + ;
	Substr(cDigital,34,14)
		
EndIf

Aadd(aRet,cBarra)		//Código de Barras
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_diE  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do banco do brasil             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_diE(cNosso)

Local _cCodigo := "017432626" + cNosso

Local _nSoma := 0
Local _nItem := 0
Local auxi	 := 0
Local _cDac	 := ""

For i:=1 to Len(_cCodigo)
	
	_nItem := val(substr(_cCodigo,i,1))
	
	//Quando estiver em uma casa par, multiplica por dois
	If mod(i,2) == 0
		If _nItem*2 >= 10
			_nSoma += (_nItem * 2) - 9	//Exemplo do calculo 6*2 = 12 logo 1+2 = 3 ou 12 - 9 = 3
		Else
			_nSoma += _nItem * 2
		Endif
	Else
		_nSoma += _nItem
	Endif
Next i

auxi := mod(_nSoma,10)

//Se resto da divisão for zero, dac é zero
If auxi == 0
	_cDac := "0"
Else
	_cDac := alltrim(str(10 - auxi))
Endif

Return(_cDac)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT0001  ºAutor  ³Microsiga           º Data ³  02/13/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIGIT0001(cVariavel)

Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   	:= Val(SubStr(cBase, idig, 1)) * umdois
	sumdig 	:= SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois 	:= 3 - umdois
	iDig	:= iDig-1
EndDo
cValor	:= AllTrim(STR(sumdig,12))
nDezena	:= VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
auxi 	:= nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf

Return str(auxi,1,0)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR1  de vencimento para linha digitavel.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function Fator1()

If Len(ALLTRIM(SUBSTR(DTOC(dVENCREA),7,4))) = 4
	cData := SUBSTR(DTOC(dVENCREA),7,4)+SUBSTR(DTOC(dVENCREA),4,2)+SUBSTR(DTOC(dVENCREA),1,2)
Else
	cData := "20"+SUBSTR(DTOC(dVENCREA),7,2)+SUBSTR(DTOC(dVENCREA),4,2)+SUBSTR(DTOC(dVENCREA),1,2)
EndIf
cFator := STR(1000+(STOD(cData) - STOD("20000703")),4)

Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_Dp   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_Dp(cVariavel)

Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase

While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo

auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf

Return str(auxi,1,0)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. &("X1_TIPO") <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+&("AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)")+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

Return
*/
/*************************************************************
* Monta linha digitavel para impressao de boletos do bco     *
* bradesco.                                                  *
*************************************************************/
Static Function MontaLinha(dDataCalc)

Local cDvLinh, cLineDig
//Local dDataCalc  := U_GetNewVFI2('*1',E1_VENCREA)
Local cFatorVcto := CToD("")

Default dDataCalc	:= dDatabase

cFatorVcto := Str( ( dDataCalc - Ctod("07/10/1997") ),4 )

Private cPedaco := ""

//Código de barras
cCodBarras := aCB_RN_NN[1]

//Digito Verificador do Codigo de Barras
cDVercb := SubStr(cCodBarras,5,1)

//Primeiro Campo
//Codigo do Banco (3) + Moeda (1) + 5 primeiras posições do campo livre do Cod Barras --> Tamanho 9 +  dígito verificador
cPedaco := Substr(cCodBarras,1,3) + Substr(cCodBarras,4,1) + Substr(cCodBarras,20,5)
cDvLinh := DV_LINHA()

cLineDig := Substr(cCodBarras,1,3) + Substr(cCodBarras,4,1) + Substr(cCodBarras,20,1) + "." + Substr(cCodBarras,21,4) + cDvLinh + Space(2)


//Segundo Campo
//Posições 6 a 15 do campo livre --> tamanho 10 + digito verificador
cPedaco    := Substr(cCodBarras,25,10)
cDvLinh    := DV_LINHA()
cLineDig   += Substr(cPedaco,1,5) + "." + Substr(cPedaco,6,5) + cDvLinh + Space(2)


//Terceiro Campo
//Posições 6 a 15 do campo livre --> tamanho 10 + digito verificador
cPedaco  := Substr(cCodBarras,35,10)
cDvLinh  := DV_LINHA()
cLineDig += Substr(cPedaco,1,5) + "." + Substr(cPedaco,6,5) + cDvLinh + Space(2)


//Quarto Campo
//Dígito verificador do código de barras --> Tamanho 1
cLineDig += cDVercb + Space(2)


//Quinto Campo
//Fator de vencimento (4) + valor do documento (10)
cLineDig  := cLineDig + cFatorVcto + StrZero(Round(nVlrBol,2) * 100,10)

Return cLineDig

/**************************************************************
* Calculo do Digito da Linha Digitavel                        *
**************************************************************/
Static Function DV_LINHA()

Local nPeso := 2 	//Inicia peso em 2
Local nCont := 0
Local i, nDigito, Resto, Dezena

//Varre do fim ao início
For i := Len(cPedaco) to 1 Step -1
	
	//Se a soma der 10 ou mais, soma os algarítmos (exemplo: 2x7 = 14 --> 1+4 = 5)
	If Val(SUBSTR(cPedaco,i,1)) * nPeso >= 10
		
		nVal  := Val(SUBSTR(cPedaco,i,1)) * nPeso
		nCont += Val(SUBSTR(Str(nVal,2),1,1)) + Val(SUBSTR(Str(nVal,2),2,1))
	Else
		nCont += Val(SUBSTR(cPedaco,i,1)) * nPeso
	Endif
	
	If nPeso == 1
		nPeso := 2
	Else
		nPeso := 1
	Endif
Next

Dezena  := Substr(Str(nCont,2),1,1)
Resto   := ( (Val(Dezena)+1) * 10) - nCont

If Resto == 10
	nDigito := "0"
Else
	nDigito := Str(Resto,1)
Endif

Return nDigito

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BLTCDITA  ºAutor  ³Microsiga           º Data ³  07/31/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Modulo11(cStr,nMultIni,nMultFim)
Local i, nModulo := 0, cChar, nMult

nMultIni := Iif( nMultIni==Nil,2,nMultIni )
nMultFim := Iif( nMultFim==Nil,9,nMultFim )
nMult := nMultIni
cStr := AllTrim(cStr)

For i := Len(cStr) to 1 Step -1
	cChar := Substr(cStr,i,1)
	If isAlpha( cChar )
		Help(" ", 1, "ONLYNUM")
		Return .f.
	End
	nModulo += Val(cChar)*nMult
	nMult:= IIf(nMult==nMultfim,2,nMult+1)
Next

nRest := nModulo % 11

//nRest := IIf(nRest==0 .or. nRest==1,0,11-nRest)
nRest := IIf(nRest==0 .or. nRest==1,1,11-nRest)

Return(Str(nRest,1))
`
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFA01EnvBoº Autor ³ Rento Calabro'     º Data ³ 12/07/15    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que envia e-mail de boletos ou boletos + DANFE      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cExp1 - Diretorio onde encontra os boletos PDF gerados     º±±
±±º          ³ lExp2 - .T. - Envia Boleto / .F. - Nao envia o boleto      º±±
±±º          ³ aExp3 - Array com as informacoes dos titulos a serem envi- º±±
±±º          ³         ados por e-mail.                                   º±±
±±º          ³ lExp4 - .T.-Envia Boleto e NF / .F.-Nao envia boleto e NF  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RFA01EnvBol(cLocal,lEnvioBol,aTitulo,lEnvBolNF)

Local cTitulo		:= ""										//registro
Local cArqPDF		:= ""										//Nome do arquivo
Local cCadWF		:= AllTrim(GetMV("MV_WFMLBOX",, ""))		//Nome da conta Workflow cadastrada
Local cPopAdd		:= ""										//Endereço do Servidor POP
Local cSmtpAdd	:= ""											//Endereço do Servidor SMTP
Local cUser		:= "distribuicao@ibg.com.br"
Local cPass		:= ""											//Senha do Servidor
Local cEmailCCo	:= ""											//Email a qual irá a copia oculta
Local cRecebe													//Retorno -> Utilizado para verificar qual o tipo de email o usuario selecionou através da rotina (MDTEC02)
Local cChaveNfe := ""											//Guarda a chave da Nota Fiscal
Local cHtml     := ""											//Guarda o Texto feito em HTML
Local cNFEs     := ""											//Pega o Numero da Nota Fiscal de Serviço
Local _cCliente := ""
Local _cLoja    := ""

Local nCont		:= 0											//Contador
Local nX			:= 0										//Contador
Local nPos			:= ""										//Posicao do vetor
Local nErro       := 0											//Erro da funcao
Local nPopPort	:= 0											//Porta do Servidor POP     (110)
Local nSmtpPort	:= 0											//Porta do Servidor SMTP    (587)
Local nConfirmou												//Retorno -> Verifica se o usuario confirmou ou cancelou através da rotina
Local nOpc			:= 0 

Local lAuth		:= GetMV( 'MV_RELAUTH',, .F. )
Local lPermite	:= .F.											//Parâmetro que permite ou não envio de link de RPS com o campo Chave de Acesso em branco //.T. Envia link com chave em branco (solicitação Eyder)

Local aFiles		:= {}										//Localiza todos os registros contigos na na pasta informada
Local aTotArq		:= {}										//Verifica a quantidade de registro na pasta
Local aBolEnv		:= {}										//Vetor que verifica se existe boletos a serem enviados
Local aFilBol		:= {}										//Vetor que armazena os registros que serão enviados e excluidos
Local aEmails		:= {}										//Array para o Parambox para adicionar mais e-mails

Local oMailServer := TMailManager():New()						 // Objeto função de enviar e-mail
Local oMessage    := TMailMessage():New()						 // Atributo do Objeto

//Vetor [aRotina] utilizado na rotina [ MDTEC02 ]
/*Private aRotina := {{"Pesquisar","AxPesqui",0,1},;
{"Visualizar","U_MAT16VIS()",0,2},;
{"Incluir","U_MAT16INC()",0,3},;
{"Alterar","U_MAT16ALT()",0,4},;
{"Excluir","U_MAT16EXC()",0,5}}

Private INCLUI := .T.  //Utilizado na rotina de Filtro de contatos
*/

DbSelectArea("WF7")
DbSetOrder(1)		//WF7_FILIAL+WF7_PASTA
If WF7->( DbSeek(xFilial("WF7")+cCadWF))
	cPopAdd := AllTrim(WF7->WF7_POP3SR)
	cSmtpAdd := AllTrim(WF7->WF7_SMTPSR)
	nPopPort := WF7->WF7_POP3PR
	nSmtpPort := WF7->WF7_SMTPPR
	cUser := AllTrim(WF7->WF7_CONTA)
	cPass := AllTrim(WF7->WF7_SENHA)
Else
	cPopAdd := "mail.ita.locamail.com.br"
	cSmtpAdd := ""
	nPopPort := 0
	nSmtpPort := 110
	cUser := "distribuicao@ibg.com.br"
	cPass := "ththsenha00"
EndIf

aFiles  := Directory(cLocal + "*.PDF", "D") //BUSCA TODOS OS ARQUIVOS DO LOCAL EM PDF E GUARDA NO VETOR

//**********************************
// Apresenta os dados dos arquivos *
// Encontrado na pasta             *
//**********************************
nCont := Len( aFiles )
For nX := 1 to nCont
	cArq := aFiles[nX,1]
	aAdd(aTotArq, cArq )
Next nX

nCont := Len(aTitulo)
nX := 1

While nX <= nCont
	
	cTitulo:= AllTrim(aTitulo[nX][1])+".PDF"
	nPos:= aScan(aTotArq, {|x| Upper(x) == Upper(cTitulo)}) //Pesquisa no vetor
	
	If nPos == 0
		MsgAlert("Não foi possivel enviar o boleto [ "+cTitulo+" ] pois o mesmo não encontra - se na pasta [ "+cLocal+" ] ")
	Else
		aAdd(aBolEnv,{cTitulo})
	EndIf
		
	nX++
	
EndDo

nX:= 1
nCont := Len(aBolEnv)
nPos := 0

While nX <= nCont
	
	cArqPDF := aBolEnv[nX][1]
	
	nPos:= aScan(aFilBol, {|x| x == cArqPDF}) //Pesquisa no vetor
	
	If nPos == 0
		aAdd(aFilBol,cLocal+cArqPDF)
	EndIf
	
	nX++
	
EndDo

nCont := Len(aBolEnv)

//**********************************************
//*Verifica se exitem boletos a serem enviados *
//**********************************************
If nCont > 0
	
	//**********************************
	//*Posiciona na tabela de SA1 para *
	//*pegar os dados do cliente       *
	//**********************************
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xfilial("SA1")+aTitulo[1][5]+aTitulo[1][6])
		
		//************************************************
		//*Pega as configurações informadas do servidor   *
		//*************************************************
		oMailServer:Init( cPopAdd, cSmtpAdd, cUser, cPass, nPopPort, nSmtpPort )
		
		//**********************************************************
		//*Valida as configurações do servidor para envio de e-mail*
		//**********************************************************
		If( (nErro := oMailServer:SmtpConnect()) != 0 )
			conout( "Não conectou.", oMailServer:GetErrorString( nErro ) )
			Return
		EndIf
		
		//***********************************
		//*Autenticação do Servidor         *
		//***********************************
		If nErro == 0 .And. lAuth
			nErro := oMailServer:smtpAuth(cUser, cPass)
			If nErro <> 0
				conOut("[ERROR]Falha ao autenticar: " + oMailServer:getErrorString(nErro))
				oMailServer:smtpDisconnect()
				Return
			Endif
		EndIf
		
		//***********************************************
		//Limpa o objeto caso existe alguma informação  *
		//***********************************************
		oMessage:Clear()

			//******************************************************************************
			//Traz o e-mail do contato do cliente filtrado pela codigo do cliente e loja   *
			// atraves da rotina MDTEC02 -> filtro de contatos cadastrado para o cliente   *
			//******************************************************************************

			nConfirmou 	:= 1
			
			//Busca email do cadastro de cliente
			cRecebe 	:= Alltrim(SA1->A1_EMAIL) //Email
			cRecebe 	:= "renato.calabro@wikitec.com.br" //REMOVER NO FIM DO DESENV.

			If Vazio(cRecebe)
				msgInfo("Cadastro de email selecionado em branco.","MDGEN03")
				nConfirmou := 0
			EndIf

			//Se for email do cliente ou usuário selecionou um email de contato, nConfirmou == 1
			If nConfirmou == 1 .AND. !lJob

				aAdd(aEmails,{1,"e-mails:",Space(100),"","","","",80,.T.})
				While nOpc == 0 .OR. nOpc == 3 
					cAlert 	:= "Os dados do cliente para envio do Boleto estão corretos ? "+CRLF+CRLF
					
					cAlert 	+= "Codigo:  " + SA1->A1_COD +" Loja: "+SA1->A1_LOJA +CRLF
					cAlert 	+= "Cliente: " + SA1->A1_NOME +CRLF
					
					cAlert 	+= "Email: "   + cRecebe + CRLF
					
					cAlert 	+= "Titulo: "  + aTitulo[1][2]+CRLF
					cAlert 	+= "Prefixo: " + aTitulo[1][3]+CRLF
					
					nOpc 	:= Aviso("Aviso", cAlert ,{'Sim','Não','&Adic. E-mails'},3, "Envio de Boleto - EnviaEmail")
					If nOpc == 3
						ParamBox(aEmails ,"Parametros ",aRet)
						If Len(aRet) > 0 .And. !Empty(aRet[1])
							cRecebe += ";" + AllTrim(aRet[1])
						EndIf
					EndIf
				EndDo
			EndIf

			//***********************************************************************
			//Caso a Opção seja "Não"      											*
			//Exclui os Boletos/O.S Gerados											*
			//nConfirmou == 0 indica que usuário não selecionou email do contato    *
			//nOpc == 2 indica que usuário cancelou     							*
			//***********************************************************************
			If nConfirmou == 0 .Or. nOpc == 2
				
				//*******************************
				//Exclui O.S e Boletos Enviada  *
				//*******************************
				For nX:= 1 to len(aFilBol)
					If FERASE(aFilBol[nX]) == -1
						MsgStop('Falha ao tentar deletar o Arquivo ( FError'+str(ferror(),4)+ ')')
					EndIf
				Next nX
				
				//Retorna função - não envia email
				Return
				
			EndIf
			
//		EndIf

		_cCliente := Alltrim(SA1->A1_COD )
		_cLoja    :=Alltrim(SA1->A1_LOJA )

		oMessage:cFrom := cUser//GetMv("ES_BOLFROM",,"boletocobranca@laborimport.com.br")

		//***************************************
		//*Rotina de Envio Automatico de Boleto *
		//***************************************

		oMessage:cTo := cRecebe //E-mail do Cadastro de Clientes
		//cEmailCCo           +=  "; teste@teste.com.br" //Email de Copia Oculta

		oMessage:cBcc    := cEmailCCo //Email de Copia Oculta

		oMessage:cCc := GetMailCont(_cCliente,_cLoja)
		oMessage:cCc += cRecebe//GetMv("ES_BOLFROM",,"")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa as condicoes em que o envio pode ocorrer sem chaveNFE³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lPermite 	:= .F.   	//Parâmetro que permite ou não envio de link de RPS com o campo Chave de Acesso em branco //	.T. Envia link com chave em branco
		cChaveNfe 	:= ""

		//*********************
		//Localiza Chave Nfe  *
		//*********************
		__aArea := GetArea()
		
		__lRPS  := .F.
		dbSelectArea("SF2")
		dbSetOrder(1)
		If dbSeek(xFilial("SF2") + aTitulo[1][2] + aTitulo[1][3])
			
			//Se nota de serviço
			If Upper(AllTrim(SF2->F2_ESPECIE)) == 'RPS'
				
				__lRPS := .T.
				
				//Envio de Link de RPS apenas para filiais com Link Preenchido
//				cChaveNfe := GetMV("MD_LINKNFS",.F.," ")
				If !Empty(cChaveNfe) 
				
					//Se não permite envio de link de chave eletrônica em branco, e F2_CODNFE estiver em branco
					If !lPermite .And. Vazio(SF2->F2_CODNFE)
						cChaveNfe := ""
						
					   //	Return
					Else
						cChaveNfe := StrTran(cChaveNfe,'SM0->M0_INSCM',AllTrim(SM0->M0_INSCM))
						cChaveNfe := StrTran(cChaveNfe,'SF2->F2_NFELETR',AllTrim(SF2->F2_NFELETR))
						cChaveNfe := StrTran(cChaveNfe,'SF2->F2_CODNFE',StrTran(Upper(AllTrim(SF2->F2_CODNFE)),'-',''))
						
						cNFEs := AllTrim(SF2->F2_NFELETR)
					EndIf
				EndIf
				
			Else
				
				cChaveNfe := SF2->F2_CHVNFE
			EndIf
		EndIf

		RestArea(__aArea)
		
		
		//*************************************************
		//* Texto em Html que ira no corpo do E-mail      *
		//* Boleto + Nota Fiscal                          *
		//*************************************************
		cHtml:= "<html>"
		cHtml+= "	<head>"
		cHtml+= "		<title>Email_Madis</title>"
		cHtml+= "	</head>"
		cHtml+= "	<body>"
		cHtml+= "		<table border = '0' width='100%'>"
		cHtml+= "		<tr>"
		cHtml+= "			<td>"
		cHtml+= "				<font face='Arial' size='2' color='Black'>"
		
		If lEnvBolNF .And. !Vazio(cChaveNfe)//-> Se Envia Boleto com link da Nota
			cHtml+= "Atenção: Ref. Boleto(s) e Link de Nota Fiscal Nº "+IIF(cNFEs == "" ,aTitulo[1][2],cNFEs)+" - "+aTitulo[1][3]
		Else
			cHtml+= "Atenção: Ref. Boleto(s) e Link de Nota Fiscal Nº "+IIF(cNFEs == "" ,aTitulo[1][2],cNFEs)+" - "+aTitulo[1][3]
		EndIf
		
		If lEnvBolNF .And. !Vazio(cChaveNfe) //-> Se Envia Boleto com link da Nota
			cHtml+= "				</font>"
			cHtml+= "				<br><br>"
			cHtml+= "				<font face='Arial' size='2' color='Black'>"
			If __lRPS
				cHtml+= "					Link de Consulta NFe: <a href='"+cChaveNfe+"' title='Consulta Nota Fiscal Eletronica'>Consulta NFe</a>"
			Else
				cHtml+= "					Link de Consulta NFe: <a href='http://www.nfe.fazenda.gov.br/PORTAL/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=' title='Consulta Nota Fiscal Eletronica'>Consulta NFe</a>"
			Endif
			cHtml+= "				</font>"
			cHtml+= "				<br><br>"
			cHtml+= "				<font face='Arial' size='2' color='Black'>"
			cHtml+= "					Chave de acesso da NFe: "+cChaveNfe+" "
			cHtml+= "				</font>"
		EndIf
		
		cHtml+= "				<br><br>"
		cHtml+= "				<font face='Arial' size='2' color='Black'>"
		cHtml+= "					Dúvidas, favor entrar em contato através do telefone: (011) 3652-2525 ou no e-mail boletocobranca@laborimport.com.br."
		cHtml+= "				</font>"
		cHtml+= "				<br></br>"
		cHtml+= "				<font face='Arial' size='2' color='Black'>"
		cHtml+= "					<b>Setor de Crédito e Cobrança</b>"
		cHtml+= "				</font>"
		cHtml+= "				<br></br>"
		cHtml+= "				<font face='Arial' size='2' color='Black'>"
		cHtml+= "					Labor Import Comercial Importadora Exportadora Ltda"
		cHtml+= "				</font>"
		cHtml+= "				<br></br>"
		cHtml+= "				<font face='Arial' size='2' color='Black'>"
		cHtml+= "					<b>Este e-mail de boleto substitui o boleto físico.</b>"
		cHtml+= "				</font>"
		cHtml+= "			</td>"
		cHtml+= "		</tr>"
		cHtml+= "		</table>"
		cHtml+= "	</body>"
		cHtml+= "</html>"

/*		_cParam := GetMv("ES_CCOMAIL",,"")
		_Vend	:= ";"
		If SA3->(dbSeek(xFilial("SA3")+SA1->A1_VEND))
			_Vend += SA3->A3_EMAIL
		EndIf
		If !Empty(oMessage:cBcc)
			oMessage:cBcc += ";"+_cParam+_Vend
		Else
			oMessage:cBcc := _cParam+_Vend
		EndIf*/

		oMessage:cSubject        := "Atenção: Ref. Boleto(s) e Link de Nota Fiscal Nº "+IIF(cNFEs == "" ,aTitulo[1][2],cNFEs)+" - "+aTitulo[1][3]

		If lEnvBolNF //-> Se Envia Boleto com link da Nota
			
			oMessage:cBody       := cHtml // -> Boleto + Nota
		Else
			
			oMessage:cBody       := cHtml // -> Boleto			
		EndIf

		// Para solicitar confimação de envio
		//oMessage:SetConfirmRead( .T. )
		
		// Adiciona um anexo
		For nX := 1 to len(aFilBol)
			oMessage:AttachFile( aFilBol[nX] )
		Next nX
		
		// Essa tag, é a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		// oMessage:AddAttHTag( ‘Content-ID: ‘ )
		
		ConfirmMailRead({||.T.})
		If( (nErro := oMessage:Send( oMailServer )) != 0 )
			conout( "Não enviou o e-mail.", oMailServer:GetErrorString( nErro ) )
			Return
		Else
		    //Grava log de envio e reenvio dos titulos - Flavio Macieira
			DbSelectArea("SE1")
			DbSetOrder(1)
			For nX := 1 to len(aTitulo)
			    If DbSeek(aTitulo[nX][10]+aTitulo[nX][3]+aTitulo[nX][2]+aTitulo[nX][4]+aTitulo[nX][11])

					If SE1->(FieldPos("E1_XDENBOL")) > 0

						RecLock("SE1",.F.)
							SE1->E1_XDENBOL  := DATE() //Grava a data do Envio do Boleto
						SE1->(MsUnlock()) 
					EndIf
				EndIf
			Next nX

			//***************************************
			//*Rotina de Envio Automatico de Boleto *
			//***************************************
			//************************************************
			//*Grava a data que foi enviada para o cliente   *
			//************************************************
			//Inibido devido novas funcionalidades, gravando no SE1 a data de envio  - Flavio Macieira 14/08/2015
			/*
			If AllTrim(FunName()) == "MDFIN13"
				DbSelectArea("SF2")
				DbSetOrder(1)
				If DbSeek(xFilial("SF2")+aTitulo[1][2]+aTitulo[1][3])
					If RecLock("SF2",.F.)
						SF2->F2_X_DTENV  := DATE() //Grava a data do Envio do Boleto
						SF2->(MsUnlock())
					EndIf
				EndIf
			EndIf
			*/
			
			//*******************************
			//Exclui O.S e Boletos Enviada  *
			//*******************************
			For nX := 1 to len(aFilBol)
				If FERASE(aFilBol[nX]) == -1
					MsgStop('Falha ao tentar deletar o Arquivo ( FError'+str(ferror(),4)+ ')')
				EndIf
			Next nX
		EndIf
		
		If( (nErro := oMailServer:SmtpDisconnect()) != 0 )

			conout( "Não desconectou.", oMailServer:GetErrorString( nErro ) )
			Return
		EndIf
		
		
	Else

		MsgInfo("Cliente não encontrado !")
	EndIf
EndIf

Return

//***************************************************************
//* Rotina que coleta os Emails do cadastro doContato *
//***************************************************************

Static Function GetMailCont(_cCliente,_cLoja)

Local cRetMail := ""
Local cAlias   := GetNextAlias()
Local cQuery   := ""


cQuery	:= " SELECT U5_EMAIL  " + CRLF
cQuery  += " FROM " + RetSQLTab("AC8") + CRLF
cQuery  += " JOIN " + RetSQLTab("SU5") + CRLF
cQuery  += "   ON SU5.U5_CODCONT = AC8.AC8_CODCON " + CRLF
cQuery  += "  AND SU5.D_E_L_E_T_<>'*'  " + CRLF
cQuery  += "WHERE AC8.D_E_L_E_T_<>'*' " + CRLF
cQuery  += "  AND AC8_CODENT = '"+_cCliente+"'+'"+_cLoja+"' " + CRLF
cQuery  += "  AND SU5.U5_EMAIL LIKE '%@%' " + CRLF


dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)

dbSelectArea(cAlias)
dbGoTop()
While (cAlias)->( !EOF())
	
	If !Vazio(cRetMail)
		cRetMail += "; "
	EndIf
	
	cRetMail += Alltrim((cAlias)->U5_EMAIL)
	
	(cAlias)->(DbSkip())
	
EndDo

Return cRetMail
