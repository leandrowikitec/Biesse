#INCLUDE "PROTHEUS.CH"
// #INCLUDE 'DIRECTRY.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFISA01  บAutor  ณ Renato Calabro'    บ Data ณ  07/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que efetua leitura de arquivos XML e executa uma    บฑฑ
ฑฑบ          ณ execauto para notas fiscais de saida - MATA920             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFISA01()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lRetorno	:= .F.						//Variavel de controle de processamento

Local aAreas	:= {GetArea()}				//Armazena areas abertas
Local aParams	:= {}						//Parametros informado pelo usuario
Local aArquivos	:= {}						//Array com os arquivos de XML

aParams := MyPergunte()

If Len(aParams) > 0
	aArquivos	:= Directory(SubStr(aParams[1], 1, Rat("\", aParams[1])) + "*.XML")

	If Len(aArquivos) > 0
		IniMonitor(aArquivos, {|| ProcArqs(aArquivos, aParams, @lRetorno)} )
	Else
		Aviso(	"Nใo hแ dados", "Nใo existe nenhum arquivo XML na pasta selecionada " + SubStr(aParams[1], 1, Rat("\", aParams[1])),;
				{"&Cancelar"},, "Aten็ใo",, "INFO" )
	EndIf

EndIf

aEval(aAreas, {|x| RestArea(x) })

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMyPergunteบAutor  ณ Renato Calabro'    บ Data ณ  07/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para executar o Parambox da rotina                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MyPergunte()

Local cTitulo	:= "Parโmetros para importar arquivo"		//Titulo a ser apresentado no Parambox

Local aParambox	:= {}										//Array com os tipos de Parambox
Local aRet		:= {}						 				//Array com o retorno do pergunte
Local aAreaAtu	:= GetArea()								//Armazena array atual

aAdd(aParamBox,{6,;
				"Selec.Diret๓rio:",;
				Space(230),;
				"",;
				"",;
				"",;
				80,;
				.T.,;
				Nil/*"Arquivos XLS|*.XLS|Todos os Arquivos|*.*"*/,;
				"\SERVIDOR",;
				GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE})

aAdd(aParamBox,{1,;
				"TES",;
				Space(TamSX3("D2_TES")[1]),;
				"@!",;
				"ExistCpo('SF4',MV_PAR02) .AND. MV_PAR02 >= '501'",;
				"SF4",;
				"",;
				TamSX3("D2_TES")[1],;
				.T. } )

/*aAdd(aParamBox,{1,;
				"Serie",;
				Space(TamSX3("F2_SERIE")[1]),;
				"@!",;
				"!Empty(Posicione('SX5',1,cFilant+'01'+MV_PAR03,'X5_DESCRI'))",;
				"DVO",;
				"",;
				TamSX3("F2_SERIE")[1],;
				.T. } )
*/
aAdd(aParamBox,{1,;
				"Esp้cie",;
				Space(TamSX3("F2_ESPECIE")[1]),;
				"@!",;
				"ExistCpo('SX5','42'+MV_PAR03)",;
				"42",;
				"",;
				TamSX3("F2_ESPECIE")[1],;
				.T. } )

aAdd(aParamBox,{1,;
				"Cond.Pagto",;
				Space(TamSX3("F2_COND")[1]),;
				"@!",;
				"ExistCpo('SE4',MV_PAR04)",;
				"SE4",;
				"",;
				TamSX3("F2_COND")[1],;
				.T. } )

ParamBox(aParamBox, cTitulo, @aRet,,,,,,,, .T., .T.)

RestArea(aAreaAtu)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIniMonitorบ Autor ณ Renato Calabro'    บ Data ณ  07/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que inicia tela de monitor de processamento de      บฑฑ
ฑฑบ          ณ arquivos XML do local informado pelo usuario               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aExp1 - Array contendo os arquivos XML a serem processados บฑฑ
ฑฑบ          ณ bExp2 - Bloco de codigo com a funcao a ser executada       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IniMonitor(aArquivos, bProcesso)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aTamDlg	:= GetScreenRes()									//Dimensoes da resolucao da tela
Local aButtons  := {}												//Array contendo os botoes a serem adicionados nos Acoes Relacionadas

Local bCancel	:= {|| IIf(Aviso("Aviso","Deseja encerrar o processamento ?",{"Sim","Nใo"},,"Aten็ใo:",,"BMPPERG")== 1,(oDlg:End()),) }		//Bloco de codigo ao cancelar dialog

Private nMeter      := 0											//Variavel de controle da regua

Private aLista		:= {}											//Array com a lista de arquivos a serem processados

Private oAway		:= LoadBitMap(GetResources(),"BR_AMARELO")		//Objeto com semaforo amarelo
Private oOk			:= LoadBitMap(GetResources(),"BR_VERDE")		//Objeto com semaforo verde
Private oErro		:= LoadBitMap(GetResources(),"BR_VERMELHO")		//Objeto com semaforo vermelho
Private oDlg 		:= Nil											//Objeto para a Dialog
Private oListBox	:= Nil											//Objeto para o ListBox
Private oSayMeter	:= Nil											//Objeto para a descicao da regua
Private oMeter		:= Nil											//Objeto para a regua

Default aArquivos	:= {}

Default bProcesso	:= {|| .T.}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega lista com arquivos a serem processados                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aEval(aArquivos, {|x| aAdd(aLista, {"", x[1], "", ""}) })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Crio botoes para adicionar funcoes na opcao ACOES RELACIONADAS              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aButtons, {"RELATORIO"	, {|| GerRelLstBox(oListBox) }	, "Imp. Relat๓rio"	, "Imp. Relat๓rio"	, {|| .T.} })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a tela de controle das threads                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE "Monitor de processamento" From 0,0 To aTamDlg[2] * 0.52/*29*/, aTamDlg[1] * 0.5 /*90*/ OF oMainWnd STYLE DS_MODALFRAME
	oDlg:lEscClose := .F.
	oDlg:lMaximized := .T. 

	oSayMeter	:= TSay():New(002,010,{|| ""},oDlg,,,,,,.T.,CLR_GREEN,CLR_WHITE,aTamDlg[1] * 0.463, 15)
	oMeter		:= TMeter():New(012,010,{|u|if(Pcount()>0,nMeter:=u,nMeter)},108,oDlg,aTamDlg[1] * 0.463, 7,,.T.) // cria a r้gua
  
	@25,05 LISTBOX oListBox VAR cListBox Fields ;
			HEADER  "",;
				OemtoAnsi("A Importar"),;
				OemtoAnsi("Importado"),;
				OemtoAnsi("Motivo erro"),;
	            SIZE aTamDlg[1] * 0.477,aTamDlg[2] * 0.37  PIXEL//NOSCROLL
	oListBox:SetArray(aLista)
	oListBox:bLine := { || {	IIf(ValType(aLista[oListBox:nAt,1]) == "C",oAway,If(aLista[oListBox:nAt,1],oOk,oErro)),;
								aLista[oListBox:nAt,2],;
								aLista[oListBox:nAt,3],;
								aLista[oListBox:nAt,4] }}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bProcesso/*bOk*/ , bCancel,,aButtons)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ProcArqs บ Autor ณ Renato Calabro'    บ Data ณ  07/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que executa processamento de arquivos XML           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aExp1 - Array contendo os arquivos XML a serem processados บฑฑ
ฑฑบ          ณ aExp2 - Parametros informados pelo usuario                 บฑฑ
ฑฑบ          ณ lExp3 - Variavel de controle de retorno da funcao          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcArqs(aArquivos, aParams, lRetorno)

Local cArq			:= 	""								//Arquivo posicionado no array de arquivos XML

Local nLoop			:=	0								//Variavel de controle de loop

Local aErros		:= {}								//Array contendo erros encontrados no processamento

Default lRetorno	:= .F.

Default aArquivos	:= {}

oMeter:SetTotal(Len(aArquivos))
oSayMeter:nClrText := CLR_GREEN

For nLoop := 1 to Len(aArquivos)

	oSayMeter:SetText("Processando arquivo de pedidos... " + cValToChar(nLoop) + "/" + cValToChar(Len(aArquivos)))
	oSayMeter:Refresh()
	oMeter:Set(nLoop)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCopia o arquivo para a แrea de trabalho do Protheusณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cArq	:= aArquivos[nLoop][1]

	lRetorno := .F.
	aErros := {}
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcessa o arquivo                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRetorno := GerNfSaida(cArq, aParams, lRetorno, @aErros)
	AtuMonitor(cArq, lRetorno, aErros)

Next nLoop

oSayMeter:nClrText := CLR_RED
oSayMeter:SetText("IMPORTAวรO FINALIZADA!")
oSayMeter:Refresh()
oMeter:Set(Len(aArquivos))
oMeter:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGerNfSaidaบ Autor ณ Renato Calabro'    บ Data ณ  07/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que gera notas de saida a partir dos arquivos XML   บฑฑ
ฑฑบ          ณ informados                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aExp1 - Array contendo os arquivos XML a serem processados บฑฑ
ฑฑบ          ณ aExp2 - Parametros informados pelo usuario                 บฑฑ
ฑฑบ          ณ lExp3 - Variavel de controle de retorno da funcao          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lExpR - .T.-Gerada nota com sucesso / .F. - Falhou         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GerNfSaida(cArq, aParams, lRetorno, aErros)

Local cDir		:= ""					//Diretorio origem dos arquivos XML 
Local cError	:= ""					//Erros encontrados no XmlParserFile
Local cWarning	:= ""					//Avisos encontrados no XML
Local cNumDoc	:= ""					//Numero do documento de saida
Local cSerDoc	:= ""					//Serie do documento de saida
Local cErros	:= ""					//Variavel para adicionar erros encontrados 
Local cRootPath	:= "\RFISA01\"			//Pasta a ser utilizada para processamento de arquivos
Local cCodCli	:= ""					//Codigo do cliente
Local cCodLj	:= ""					//Loja do cliente
Local cCNPJCPF	:= ""					//Tag para identificar se o cliente e' juridico/fisico

Local nLoop		:= 0					//Variavel de controle de loop
Local nX		:= 0					//Variavel de controle de loop
Local nResult	:= 0					//Resultado de criacao e gravacao de diretorio e arquivos

Local aCabec	:= {}					//Array de cabecalho de documento de saida
Local aLinha	:= {}					//Array de suporte para criacao dos itens do documento de saida
Local aItens	:= {}					//Array de itens de documento de saida
Local aDados	:= {}					//Array de suporte com os dados dos itens do XML
Local aDados2	:= {}					//Array de suporte com os dados dos itens do XML - situacao de mais de 1 item
Local aRetDad	:= {}					//Array de suporte do retorno de funcao para converter objeto para array
Local aAutoErro	:= {}					//Array contendo os erros de processamento de ExecAuto

Local oXML		:= Nil					//Objeto de retorno do XML processado

Private lMsErroAuto	:= .F.				//Variavel necessaria para processamento de ExecAuto
Private lMsHelpAuto	:= .T.				//Variavel necessaria para processamento de ExecAuto - apresenta Help

Default cArq		:= ""

Default lRetorno	:= .F.

Default aErros		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Continua processo se encontrar arquivo            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aParams) > 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria diretorio especifico para processamento      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lIsDir(cRootPath)
		nResult := MakeDir(cRootPath)
	Endif

	cDir := SubStr(aParams[1], 1, Rat("\", aParams[1]))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se arquivo origem estiver no client do usuaio,    ณ
	//ณ envio arquivo para o servidor                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If At(":", cDir) > 0 
		If !CpyT2S( cDir + cArq, cRootPath, .F. )
			nResult := 1
		EndIf
	Else
		__Copyfile(cDir + cArq, cRootPath + cArq)
		nResult := If(File(cRootPath + cArq), 0, 1)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Somente continua se conseguir enviar arquivo para ณ
	//ณ servidor. Necessario para utilizar funcao         ณ
	//ณ XmlParserFile, que funciona se estiver RootPath   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nResult == 0

		If File(AllTrim(cRootPath) + AllTrim(cArq))

			oXML := XmlParserFile(cRootPath+cArq, "_", @cError, @cWarning )

			If !Empty(cError) .Or. !Empty(cWarning)
				aAdd(aErros, If(!Empty(cError), cError, cWarning))
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Continua somente se atributo NFEPROC existir no   ณ
			//ณ XML                                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If AttIsMemberOf( oXML, "_NFEPROC" )
				DbSelectArea("SA1")
				DbSetOrder(3)			//A1_FILIAL+A1_CGC

				cCNPJCPF := If(AttIsMemberOf( oXML:_NFEPROC:_NFE:_INFNFE:_DEST, "_CNPJ" ), oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT,;
									If(AttIsMemberOf( oXML:_NFEPROC:_NFE:_INFNFE:_DEST, "_CPF" ), oXML:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT, ""))

				If !Empty(cCNPJCPF) .AND. ValType(cCNPJCPF) == "C"
					If !SA1->(DbSeek(xFilial("SA1") + cCNPJCPF))
//Cadastra cliente se nao encontrar - Removido, pois usuario ira' cadastrar manualmente - alinhado com Rafael
//						CriaCli(oXML:_NFEPROC:_NFE:_INFNFE:_DEST, @aErros)
						aAdd(aErros, "Cliente nใo cadastrado. O cliente do CNPJ/CPF " + cCNPJCPF + " nใo estแ " +;
									"cadastrado no sistema.")
					EndIf

					cCodCli := SA1->A1_COD 
					cCodLj := SA1->A1_LOJA
				Else
					aAdd(aErros, "XML invแlido. Nใo encontrado na estrutura de XML o CNPJ do destinatแrio.")
				EndIf
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Adiciona produtos em array.                       ณ
				//ณ 1 item apenas, retorna objeto. Mais que 1, array  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Valtype(oXML:_NFEPROC:_NFE:_INFNFE:_DET) == "O"
					aRetDad := ClassDataArr(oXML:_NFEPROC:_NFE:_INFNFE:_DET)
					For nLoop := 1 to Len(aRetDad)
						If Alltrim(aRetDad[nLoop,1]) == "_PROD"
							aDados2 := ClassDataArr(aRetDad[nLoop,2])
							If Len(aDados2) > 0
								aAdd(aDados,{aDados2[04,02]:TEXT,;			//Cod.Produto
											 aDados2[14,02]:TEXT,;			//Descricao
											 Upper(aDados2[09,02]:TEXT),;	//UM
											 aDados2[06,02]:TEXT,;			//NCM
											 aDados2[03,02]:TEXT,;			//CFOP
											 Val(aDados2[07,02]:TEXT),;		//Quantidade
											 Val(aDados2[12,02]:TEXT),;		//Preco
											 Val(aDados2[11,02]:TEXT) })	//Total
							EndIf
						EndIf
					Next nLoop
				ElseIf ValType(oXML:_NFEPROC:_NFE:_INFNFE:_DET) == "A"  
					For nLoop := 1 to Len(oXML:_NFEPROC:_NFE:_INFNFE:_DET)
						aRetDad := ClassDataArr(oXML:_NFEPROC:_NFE:_INFNFE:_DET[nLoop])
						For nX := 1 to Len(aRetDad)
							If Alltrim(aRetDad[nX,1]) == "_PROD"
								aDados2 := ClassDataArr(aRetDad[nX,2])
								If Len(aDados2) > 0 .AND. aScan(aDados, {|x| x[1] == aDados2[4][2]:TEXT}) == 0
									aAdd(aDados,{aDados2[04,02]:TEXT,;			//01-Cod.Produto
												 aDados2[14,02]:TEXT,;			//02-Descricao
												 Upper(aDados2[09,02]:TEXT),;	//03-UM
												 aDados2[06,02]:TEXT,;			//04-NCM
												 aDados2[03,02]:TEXT,;			//05-CFOP
												 Val(aDados2[07,02]:TEXT),;		//06-Quantidade
												 Val(aDados2[12,02]:TEXT),;		//07-Preco
												 Val(aDados2[11,02]:TEXT) })	//08-Total
								EndIf
							EndIf
						Next nX
					Next nLoop
				EndIf

/*Cadastra produto se nao encontrar - Removido, pois usuario ira' cadastrar manualmente - alinhado com Rafael
				For nLoop := 1 To Len(aDados)
					If !SB1->(DbSeek(xFilial("SB1")+aDados[nLoop][1]))
						CriaProd(aDados[nLoop], @aErros)
					EndIf
				Next nLoop
*/
				cNumDoc := StrZero(Val(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_nNF:TEXT),9)
				cSerDoc := PadR(AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT), TamSX3("F2_SERIE")[1])

				If ValType("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT") <> "U" .AND. !Empty(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT) .AND.;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT <> "55"
					aAdd(aErros, "Modelo de XML invแlido. Somente modelos tipo 55 sใo suportados. Modelo deste XML: '" + oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT + "'.")
				EndIf
			Else
				aAdd(aErros, "XML invแlido. Nใo encontrado estrutura de XML compatํvel de nota fiscal para importa็ใo.")
			EndIf

			If SF2->( DbSeek(xFilial("SF2")+cNumDoc+cSerDoc+PadR(cCodCli, TamSX3("F2_CLIENTE")[1])+PadR(cCodLj, TamSX3("F2_LOJA")[1]) ))
				aAdd(aErros, "N๚mero/Serie da nota '" + cNumDoc + "/" + cSerDoc + "' jแ cadastrada no sistema.")
			EndIf

			If Len(aErros) == 0

				aAdd(aCabec,{"F2_TIPO"		, "N"				, Nil })
				aAdd(aCabec,{"F2_FORMUL"	, "N"				, Nil })
				aAdd(aCabec,{"F2_DOC"		, cNumDoc			, Nil })
				aAdd(aCabec,{"F2_SERIE"		, cSerDoc			, Nil })
				aAdd(aCabec,{"F2_EMISSAO"	, dDataBase			, Nil })
				aAdd(aCabec,{"F2_CLIENTE"	, cCodCli			, Nil }) 
				aAdd(aCabec,{"F2_LOJA"		, cCodLj			, Nil })
				aAdd(aCabec,{"F2_COND"		, aParams[4]		, Nil })
				aAdd(aCabec,{"F2_ESPECIE"	, aParams[3]		, Nil })
				If ValType("oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT") <> "U" .AND. !Empty(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)
					aAdd(aCabec,{"F2_FRETE"		, Val(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)			, Nil })
				Else
					aAdd(aCabec,{"F2_FRETE"		, 0																		, Nil })
				EndIf
				If ValType("oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT") <> "U" .AND. !Empty(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT)
					aAdd(aCabec,{"F2_SEGURO"	, Val(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT)			, Nil })
				Else
					aAdd(aCabec,{"F2_SEGURO"	, 0																		, Nil })
				EndIf
				aAdd(aCabec,{"F2_DESPESA"		, 0																		, Nil }) 
//				aAdd(aCabec,{"F2_TIPOCLI"	, SA1->A1_PESSOA	, Nil }) 
//				aAdd(aCabec,{"F2_VALBRUT"		, oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT				, Nil }) 
				aAdd(aCabec,{"F2_VALMERC"		, Val(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)			, Nil }) 
//				aAdd(aCabec,{"F2_VALFAT"		, oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT				, Nil })
				If ValType("oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT") <> "U" .AND. !Empty(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT)
					aAdd(aCabec,{"F2_DESCONT"	, Val(oXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT)			, Nil })
				Else
					aAdd(aCabec,{"F2_DESCONT"	, 0																		, Nil })
				EndIf
//				aAdd(aCabec,{"F2_HORA"		, Time()							, Nil })
				If ValType("oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT") <> "U" .AND. !Empty(oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
					aAdd(aCabec,{"F2_CHVNFE"	, oXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT							, Nil })
				EndIf

				For nLoop := 1 To Len(aDados)
					aLinha := {}
					aAdd(aLinha,{"D2_ITEM"		, StrZero(nLoop, TamSX3("D2_ITEM")[1])	, Nil})
					aAdd(aLinha,{"D2_COD"		, aDados[nLoop][1]						, Nil })
					aAdd(aLinha,{"D2_QUANT"		, aDados[nLoop][6]						, Nil })
					aAdd(aLinha,{"D2_PRCVEN"	, aDados[nLoop][7]						, Nil })
					aAdd(aLinha,{"D2_TOTAL"		, aDados[nLoop][8]						, Nil })
					aAdd(aLinha,{"D2_TES"		, aParams[2]							, Nil })
					aAdd(aLinha,{"D2_CF"		, aDados[nLoop][5]						, Nil })
					aAdd(aItens, aLinha)
				Next nLoop

				lMsErroAuto := .F.
				aAutoErro := {}
				cErros := ""
				MsgRun("Gerando Nota " + cNumDoc + "...","Processando", {|| lMsErroAuto := MSExecAuto({|x,y| mata920(x,y)},aCabec,aItens,3) }) //Inclusao

				If !SF2->(DbSeek(xFilial("SF2")+cNumDoc+cSerDoc+cCodCli+cCodLj))
					RollBackSX8()
					DisarmTransaction()
					MostraErro(cRootPath, FileNoExt(cArq) + ".log")
					aAutoErro := MyGetAutoLog(cRootPath, FileNoExt(cArq) + ".log")
					aEval(aAutoErro, {|x| cErros += x + "|" })
					aAdd(aErros, cErros)
				Else
					ConfirmSX8()
					lRetorno := .T.
				EndIf
			EndIf
		Else
			aAdd(aErros, "Diret๓rio + Arquivo " + cDir + cArq + " nใo localizado para processamento.")
		EndIf
	Else
		aAdd(aErros, "Falha ao enviar arquivo " + cDir + " para o servidor para importa็ใo de nota fiscal ou pasta " +;
					cRootPath + " nใo existe no servidor.")
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Remove arquivos e diretorio de processamento      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lIsDir(cRootPath)
		aEval(Directory(AllTrim(cRootPath) + "*.*"), { |aFile| FERASE(AllTrim(cRootPath) + AllTrim(aFile[1])) })
		DirRemove(cRootPath)
	Endif
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuMonitorบ Autor ณ Renato Calabro'    บ Data ณ  07/25/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que atualiza monitor de processamento de arquivos   บฑฑ
ฑฑบ          ณ XML                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cExp1 - Arquivo XML posicionado e que foi processado       บฑฑ
ฑฑบ          ณ lExp2 - Variavel que informa se houve sucesso ou nao       บฑฑ
ฑฑบ          ณ aExp3 - Array contendo erros de processamento, se houver   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AtuMonitor(cArq, lRetorno, aErros)

Local nPosArq	:= 0						//Variavel de posicao do arquivo processado

Default cArq	:= ""

Default lRetorno	:= .F.

Default aErros	:= {}

nPosArq := aScan(aLista, {|x| AllTrim(x[2]) == AllTrim(cArq) })

If !Empty(cArq) .AND. nPosArq > 0
	aLista[nPosArq][3] := cArq
	aLista[nPosArq][1] := If(lRetorno, .T., .F.)
	If !lRetorno
		aEval(aErros, {|x| aLista[nPosArq][4] += x + "|" })
	EndIf
EndIf

oListBox:SetArray(aLista)
oListBox:bLine := { || {	IIf(ValType(aLista[oListBox:nAt,1]) == "C",oAway,If(aLista[oListBox:nAt,1],oOk,oErro)),;
							aLista[oListBox:nAt,2],;
							aLista[oListBox:nAt,3],;
							If(Len(aLista[oListBox:nAt,4]) <= 8190, aLista[oListBox:nAt,4], Left(aLista[oListBox:nAt,4], 8190)) }}
oListBox:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaCli  บ Autor ณ Renato Calabro'    บ Data ณ  07/28/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para criar o cliente, caso nao encontre na base de  บฑฑ
ฑฑบ          ณ dados                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oExp1 - Objeto com os dados do cliente                     บฑฑ
ฑฑบ          ณ aExp2 - Array contendo erros de processamento, se houver   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lExpR - .T. - cliente criado com sucesso / .F. - falhou    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaCli(oCliente, aErros)

Local cQuery	:= ""						//Query utilizada para consulta ao Banco de Dados
Local cCodCli	:= ""						//Codigo do cliente
Local cLojCli	:= ""						//Loja do cliente
Local cCGC		:= ""						//CGC do cliente
Local cErros	:= ""						//Erros encontrados no processamento

Local aClient	:= {}						//Array com dados do cliente a ser criado
Local aAutoErro	:= {}						//Array contendo os erros de processamento de ExecAuto

Private lMsErroAuto	:= .F.					//Variavel necessaria para processamento de ExecAuto
Private lMsHelpAuto	:= .T.					//Variavel necessaria para processamento de ExecAuto - apresenta Help

Default oCliente	:= Nil

If Type(oCliente:_CNPJ:TEXT) <> "U" .AND. !Empty(oCliente:_CNPJ:TEXT)

	cCGC := oCliente:_CNPJ:TEXT

	If Substr(cCGC,1,8) <> '00000000' .AND. !Empty(cCGC)

		cAlias := GetNextAlias()

		cQuery := "SELECT A1_COD, MAX(A1_LOJA) NLOJA FROM "+ RetSqlName("SA1")
		cQuery += " WHERE SUBSTR(A1_CGC,1,8) = SUBSTR('"+cCGC+"',1,8) "
		cQuery += " GROUP BY A1_COD "

		If Select(cAlias) > 0
			dbSelectArea(cAlias)
			(cAlias)->(dbCloseArea())
		EndIf

		DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), cAlias, .F., .T.)
		dbSelectArea(cAlias)

		//SE HOUVER CLIENTE CADASTRADO ELE ADICIONA LOJA
		If (cAlias)->(EOF())
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1") + Substr(cCGC, 1, 8) )
				cCodCli := (cAlias)->A1_COD
				cLojCli := PadL(Soma1((cAlias)->NLOJA), TamSX3("A1_LOJA")[1], "0")
			Else
				cLojCli := PadL("1", TamSX3("A1_LOJA")[1], "0")
			EndIf
		EndIf
		If Select(cAlias) > 0
			DbSelectArea(cAlias)
			(cAlias)->(dbCloseArea())
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava็ใo das Informa็๕es no Array que serแ enviado para o Execautoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aClient := {}
	If !Empty(cCodCli)
		aAdd(aClient,{"A1_COD"	,	cCodCli																						,Nil})
	EndIf

	aAdd(aClient,{"A1_LOJA"		, cLojCli																						,Nil})
	aAdd(aClient,{"A1_NOME"		, UPPER(AllTrim(oCliente:_XNOME:TEXT))														,Nil})
	aAdd(aClient,{"A1_PESSOA"	, If(Len(oCliente:_CNPJCPF:TEXT) > 11, "J", "F")												,Nil})
	aAdd(aClient,{"A1_NREDUZ"	, Left(UPPER(oCliente:_XNOME:TEXT), TamSX3("A1_NREDUZ")[1])									,Nil})
	aAdd(aClient,{"A1_CEP"		, oCliente:_ENDERDEST:_CEP:TEXT																,Nil})
	aAdd(aClient,{"A1_END"		, Upper(NoAcento(oCliente:_ENDERDEST:_XLGR:TEXT))																,Nil})
	aAdd(aClient,{"A1_XENDNUM"	, oCliente:_ENDERDEST:_XNRO:TEXT																,Nil}) //Numero do endereco
//	aAdd(aClient,{"A1_COMPLEM"	, oCliente:_XNOME:TEXT								,Nil})
	aAdd(aClient,{"A1_BAIRRO"	, Upper(NoAcento(oCliente:_ENDERDEST:_XBAIRRO:TEXT))															,Nil})
	aAdd(aClient,{"A1_EST"		, oCliente:_ENDERDEST:_UF:TEXT																,Nil})
	aAdd(aClient,{"A1_ESTADO"	, Posicione("SX5", 1, xFilial("SX5")+"12"+oCliente:_ENDERDEST:_UF:TEXT,"X5_DESCRI")			,Nil})
	aAdd(aClient,{"A1_COD_MUN"	, Substr(oCliente:_ENDERDEST:_CMUN:TEXT, 3, TamSX3("CC2_CODMUN")[1])							,Nil})
	aAdd(aClient,{"A1_MUN"		, Upper(NoAcento(oCliente:_ENDERDEST:_XMUN:TEXT))																,Nil})
	aAdd(aClient,{"A1_DDD"		, Left(oCliente:_ENDERDEST:_FONE:TEXT, 2)														,Nil})
//	aAdd(aClient,{"A1_DDI"		, (_cArqTmp)->A1_DDI										,Nil})
	If Type("oCliente:_ENDERDEST:_FONE") <> "U" .AND. !Empty(oCliente:_ENDERDEST:_FONE)
		aAdd(aClient,{"A1_TEL"	, Substr(oCliente:_ENDERDEST:_FONE:TEXT, 2, Len(oCliente:_FONE:TEXT) - 2 )					,Nil})
	EndIf
//	aAdd(aClient,{"A1_FAX"		, (_cArqTmp)->A1_FAX										,Nil})
	aAdd(aClient,{"A1_TIPO"		, If(Len(oCliente:_CNPJCPF:TEXT) > 11, "J", "R")												,Nil})
	aAdd(aClient,{"A1_PAIS"		, Upper(NoAcento(oCliente:_ENDERDEST:_XPAIS:TEXT))																,Nil})
//	aAdd(aClient,{"A1_PAISDES"	, _cCodPs													,Nil})
	aAdd(aClient,{"A1_CODPAIS"	, Left(oCliente:_ENDERDEST:_CPAIS:TEXT, 3)													,Nil})
	aAdd(aClient,{"A1_CGC"		, cCGC																						,Nil})
	aAdd(aClient,{"A1_ENDCOB"	, Upper(NoAcento(oCliente:_ENDERDEST:_XLGR:TEXT))																,Nil})
//	aAdd(aClient,{"A1_CONTATO"	, (_cArqTmp)->A1_CONTATO									,Nil})
	aAdd(aClient,{"A1_ENDENT"	, Upper(NoAcento(oCliente:_ENDERDEST:_XLGR:TEXT))																,Nil})
	If Type("oCliente:_ENDERDEST:_IM") <> "U" .AND. !Empty(oCliente:_ENDERDEST:_IM)
		aAdd(aClient,{"A1_INSCRM", oCliente:_ENDERDEST:_IM:TEXT									,Nil})
	EndIf
	If Type("oCliente:_ENDERDEST:_IE") <> "U" .AND. !Empty(oCliente:_ENDERDEST:_IE)
		aAdd(aClient,{"A1_INSCR", oCliente:_ENDERDEST:_IE:TEXT													,Nil})
	EndIf
//	aAdd(aClient,{"A1_TPESSOA"	, AllTrim((_cArqTmp)->A1_TPESSOA)							,Nil})
	If Type("oCliente:_ENDERDEST:_EMAIL") <> "U" .AND. !Empty(oCliente:_ENDERDEST:_EMAIL)
		aAdd(aClient,{"A1_EMAIL", oCliente:_ENDERDEST:_EMAIL:TEXT							,Nil})
	EndIf
//	aAdd(aClient,{"A1_MSBLQL"	, _cMsblq													,Nil})
//	aAdd(aClient,{"A1_CONTA"	, AllTrim((_cArqTmp)->A1_CONTA)							,Nil})

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Os valores abaixo foram considerados dos dados passados pela     ณ
	//ณ view (TT_I29A_PEDIDOS_SATELITES) de integracao da rotina de      ณ
	//ณ carga GENI018                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aClient,{"A1_RECPIS"	, "N"																							,Nil})
	aAdd(aClient,{"A1_RECCSLL"	, "N"																							,Nil})
	aAdd(aClient,{"A1_RECCOFI"	, "N"																							,Nil})
	aAdd(aClient,{"A1_RECISS"	, "N"																							,Nil})
//	aAdd(aClient,{"A1_XCLIPRE"	, cValToChar((_cArqTmp)->A1_XCLIPRE)						,Nil}) //Cliente Premium
	aAdd(aClient,{"A1_XTIPCLI"	, If(Len(oCliente:_CNPJCPF:TEXT) > 11, "001", "020")											,Nil}) //Tipo de Cliente (GEN)
	aAdd(aClient,{"A1_XCANALV"	, If(Len(oCliente:_CNPJCPF:TEXT) > 11, "1", "3")												,Nil}) //Canal de Venda
	aAdd(aClient,{"A1_VEND"		, "000018"																					,Nil})
	aAdd(aClient,{"A1_XTPDES"	, "2"																							,Nil}) //Tipo desconto
	aAdd(aClient,{"A1_TRANSP"	, If(oCliente:_ENDERDEST:_UF:TEXT == "EX", "000291", "000373")								,Nil})
	aAdd(aClient,{"A1_XCONDPG"	, "000"																						,Nil}) //Condicao Pagto (GEN)
	aAdd(aClient,{"A1_COND"		, GetMv("GEN_FAT065")																			,Nil})
	aAdd(aClient,{"A1_TABELA"	, GetMv("GEN_FAT064")																			,Nil})
	aAdd(aClient,{"A1_LC"		, If(Len(oCliente:_CNPJCPF:TEXT) == 11 .OR. oCliente:_ENDERDEST:_UF:TEXT == "EX", 5000, 0)	,Nil}) //Limite de Cr้dito 
	aAdd(aClient,{"A1_BLEMAIL"	, "1"																							,Nil}) //Boleto por Email
	aAdd(aClient,{"A1_RISCO"	, GetMv("GEN_FAT066")																			,Nil}) //Limite de Cr้dito

	lMsErroAuto := .F.
	lMsErroAuto := MSExecAuto({|x,y| Mata030(x,y)},aClient, 3)
	
	If lMsErroAuto
		RollBackSX8()
		DisarmTransaction()
		aAutoErro := GetAutoGrLog()
		aEval(aAutoErro, {|x| cErros += x + "|" })
		aAdd(aErros, cErros)
	Else
		ConfirmSX8()
		//REMOVE ASPAS SIMPLES DO CADASTRO DE CLIENTE E FORNECEDOR
		TcSqlExec("update SA1000 set A1_NOME = upper(replace(A1_NOME,'''',' ')), A1_NREDUZ = upper(replace(A1_NREDUZ,'''',' ')) where A1_NOME like '%''%' or A1_NREDUZ like '%''%'")
	EndIf

EndIf

Return lMsErroAuto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaProd บ Autor ณ Renato Calabro'    บ Data ณ  07/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para criar o produto, caso nao encontre na base de  บฑฑ
ฑฑบ          ณ dados                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aExp1 - Array com os dados do produto                      บฑฑ
ฑฑบ          ณ aExp2 - Array contendo erros de processamento, se houver   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lExpR - .T. - cliente criado com sucesso / .F. - falhou    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaProd(aDados, aErros)

Local cErros	:= ""						//Erros encontrados no processamento

Local aProduto	:= {}						//Array com os dados do produto a ser criado
Local aAutoErro	:= {}						//Array contendo os erros de processamento de ExecAuto

Private lMsErroAuto	:= .F.					//Variavel necessaria para processamento de ExecAuto
Private lMsHelpAuto	:= .T.					//Variavel necessaria para processamento de ExecAuto - apresenta Help

//	aAdd(aProduto, {"B1_PESBRU", (cAlias)->B1_PESO						, Nil})
	aAdd(aProduto, {"B1_COD"	, aDados[1]									, Nil})
	aAdd(aProduto, {"B1_DESC"	, aDados[2]					, Nil})
	aAdd(aProduto, {"B1_TIPO"	, "PA"					, Nil})
	aAdd(aProduto, {"B1_UM", aDados[3]						, Nil})
	aAdd(aProduto, {"B1_LOCPAD", "01"				, Nil})
	aAdd(aProduto, {"B1_GRUPO", cValToChar((cAlias)->B1_GRUPO)				, Nil})
	aAdd(aProduto, {"B1_ORIGEM", alltrim((cAlias)->B1_ORIGEM)				, Nil})
	aAdd(aProduto, {"B1_TNATREC", alltrim((cAlias)->B1_TNATREC)			, Nil})
	aAdd(aProduto, {"B1_MSBLQL", alltrim((cAlias)->B1_MSBLQL)				, Nil})
	aAdd(aProduto, {"B1_CODBAR", substr(alltrim((cAlias)->B1_CODBAR),1,12)	, Nil})
	aAdd(aProduto, {"B1_ISBN", alltrim((cAlias)->B1_ISBN)					, Nil})
	aAdd(aProduto, {"B1_XSITOBR", alltrim((cAlias)->B1_XSITOBR)			, Nil})
	aAdd(aProduto, {"B1_XEMPRES", alltrim((cAlias)->B1_XEMPRES)			, Nil})
	aAdd(aProduto, {"B1_XIDMAE", strzero((cAlias)->B1_XIDMAE,7)			, Nil})
	aAdd(aProduto, {"B1_XIDTPPU", alltrim((cAlias)->B1_XIDTPPU)			, Nil})
	aAdd(aProduto, {"B1_XPERCRM", alltrim((cAlias)->B1_XPERCRM)			, Nil})
	aAdd(aProduto, {"B1_XPSITEG", alltrim((cAlias)->B1_XPSITEG)			, Nil})
	aAdd(aProduto, {"B1_CC", (cAlias)->B1_CC								, Nil})
	aAdd(aProduto, {"B1_TS", _cTs											, Nil}) //TES DE SAIDA = VENDA
	aAdd(aProduto, {"B1_PESO", (cAlias)->B1_PESO							, Nil})
	aAdd(aProduto, {"B1_PESBRU", (cAlias)->B1_PESO 						, Nil})
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCleuto Lima - 24/02/2016                      ณ
	//ณ                                              ณ
	//ณincluido tratamento para produtos tipo Servi็oณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cAlias)->B1_TIPO $ cTipoServ
		aAdd(aProduto, {"B1_CODISS"		, cCODISS 	, Nil	})
		aAdd(aProduto, {"B1_ALIQISS"	, cALIQISS 	, Nil 	})
		aAdd(aProduto, {"B1_CNAE"		, cCNAE 	, Nil	})
		aAdd(aProduto, {"B1_TRIBMUN"	, cTRIBMUN	, Nil	})
		aAdd(aProduto, {"B1_POSIPI"		, cPISIPI	, Nil	})			
	Else	
		aAdd(aProduto, {"B1_POSIPI", alltrim((cAlias)->B1_POSIPI)	, Nil})	
	EndIF
	
	cLoj := "01"
	If (cAlias)->B1_PROC = 1 //EDITORA GUANABARA KOOGAN LTDA
		cFab := "0380795"
	ElseIf (cAlias)->B1_PROC = 2 //LTC-LIVROS TEC. CIENTIFICOS LTDA
		cFab := "0380796"
	ElseIf (cAlias)->B1_PROC = 4 //GEN - GRUPO EDITORIAL NACIONAL PARTICIPA
		cFab := "378803 "
	ElseIf (cAlias)->B1_PROC = 12 //EDITORA FORENSE LTDA
		cFab := "0380794"
	ElseIf (cAlias)->B1_PROC = 28 //EDITORA FORENSE UNIVERSITARIA LTDA
		cFab := "0380794"
	ElseIf (cAlias)->B1_PROC = 30 //AC FARMACEUTICA LTDA
		cFab := "031811 "
		cLoj := "02"
	ElseIf (cAlias)->B1_PROC = 41 //FORUM
		cFab := "0382982"
	ElseIf (cAlias)->B1_PROC = 42 //ATLAS
		cFab := "0378128"
		cLoj := "07"
	Else
		cFab := Space(0)
	Endif
	aAdd(aProduto, {"B1_PROC", cFab, Nil}) //FORNECEDOR PADRAO
	aAdd(aProduto, {"B1_LOJPROC", cLoj, Nil}) //LOJA FORNECEDOR PADRAO
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y| Mata010(x,y)},aProduto,nOpt)
	
	If lMSErroAuto
		RollBackSX8()
		DisarmTransaction()
		aAutoErro := GetAutoGrLog()
		aEval(aAutoErro, {|x| cErros += x + "|" })
		aAdd(aErros, cErros)
	Else
		ConfirmSX8()
	EndIf

Return lMsErroAuto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGerRelLstBบAutor  ณ Renato Calabro'    บ Data ณ  07/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para gerar o relatorio de acordo com os dados apre- บฑฑ
ฑฑบ          ณ sentados na tela                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oExp1 - Objeto contendo as informacoes do listbox          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GerRelLstBox(oListBox)

Local oReport := Nil				//Objeto para instanciar o TReport

Default oListBox	:= Nil

If Valtype(oListBox) <> "U"
	oReport := ReportDef(oListBox:aArray, oListBox:aHeaders)

	If oReport <> Nil
		oReport:PrintDialog()
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ReportDefบAutor  ณRenato Calabro'     บ Data ณ  07/29/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para gerar o relatorio de acordo com os dados apre- บฑฑ
ฑฑบ          ณ sentados na tela                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aExp1 - Array contendo as informacoes do listbox           บฑฑ
ฑฑบ          ณ aExp2 - Array contendo o cabecalho do listbox              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ oExpR - Objeto TReport gerado                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportDef(aArray, aHeader)

Local cTitulo		:= "Relat๓rio de consist๊ncias"									//Titulo do relatorio

Local aOrder		:= {}															//Array com as ordens possiveis no relatorio

Local oReport		:= Nil															//Objejto com propriedades do relatorio
Local oSection1		:= Nil															//Objejto com propriedades da secao cabecalho do relatorio

Default aArray	:= {}
Default aHeader	:= {}

If Len(aArray) > 0 .AND. Len(aHeader) > 0

	aAdd( aOrder, "" )

	oReport := TReport():New(FunName(), cTitulo, /*cPerg*/,;
								{|oReport| PrintRpt(oReport, aOrder, cTitulo, aArray, aHeader)},	"Este relat๓rio irแ imprimir as inconsist๊ncias da " +;
																									"importa็ใo de arquivos XML.")

	oSection1 := TRSection():New(oReport,"Inconsist๊ncias",, /*{cCombo}*/)
	oSection1:SetTotalInLine(.F.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSecao Detalhes ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TRCell():New(oSection1	, Upper(aHeader[1])	,, aHeader[1]	, "@!"	, 05,,)

	For nI := 2 To Len(aHeader)
		If ValType(aHeader[nI]) <> "U"
			TRCell():New(oSection1	, Upper(aHeader[nI])	,, aHeader[nI]	, "@!"	, Len(aArray[1][nI]),,)
		EndIf
	Next nI
Else
	Aviso(	"Nใo hแ dados exibidos!", "Nใo foi possํvel gerar o relat๓rio, pois nใo existem dados disponํveis na tela." + CRLF +;
			"Por favor, altere os parโmetros de filtro, para que a tela apresente dados e processe o relat๓rio novamente.",;
			{"&Cancelar"},, "Aten็ใo",, "MSGHIGH" )
EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PrintRpt บAutor  ณ Renato Calabro'    บ Data ณ  08/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que gera e atribui as definicoes do relatorio       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oExp1 - Objeto do report a ser atribuido/definido dados    บฑฑ
ฑฑบ          ณ aExp2 - Array com a ordem dos campos que serao utilizados  บฑฑ
ฑฑบ          ณ         na query                                           บฑฑ
ฑฑบ          ณ cExp3 - Titulo do relatorio                                บฑฑ
ฑฑบ          ณ aExp4 - Array contendo as divergencias apresentadas na telaบฑฑ
ฑฑบ          ณ aExp5 - Array contendo o cabecalho das divergencias        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nil                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PrintRpt(oReport, aOrder, cTitulo, aArray, aHeader)

Local nI		:= 0										//Variavel de controle do loop
Local nJ		:= 1										//Variavel de controle de regua do oReport

Local aAreaAtu	:= GetArea()								//Armazena a area atual

Local oSection1	:= oReport:Section(1)						//objeto da Secao 1

Default aArray	:= {}
Default aHeader	:= {}

oReport:SetMeter(Len(aArray))

For nI := 1 To Len(aArray)

	If !oReport:Cancel()

		oSection1:Init()
		oReport:IncMeter(nI)

		oSection1:Cell(Upper(aHeader[1]))	:SetValue( If(ValType(aArray[nI][1]) == "L", If(aArray[nI][1], "OK", "ERRO"), "Nใo imp.") ) 

		For nJ := 2 To Len(aHeader)
			If ValType(aHeader[nJ]) <> "U"
				oSection1:Cell(Upper(aHeader[nJ]))	:SetValue( AllTrim(aArray[nI][nJ]) )
			EndIf
		Next nJ 

		oSection1:PrintLine()
	EndIf
Next nI

oSection1:SetTitle(cTitulo + " - Por ordem de: " + aOrder[oSection1:GetOrder()])

oSection1:Finish()

RestArea(aAreaAtu)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaProd บ Autor ณ Renato Calabro'    บ Data ณ  08/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para apurar o erro da ExecAuto em arquivo de LOG    บฑฑ
ฑฑบ          ณ gerado pela funcao MostraErro                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cExp1 - Caminho que se encontra o arquivo .LOG             บฑฑ
ฑฑบ          ณ cExp2 - Nome do arquivo .LOG gerado pela rotina            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aExpR - Array com as informacoes do LOG gerado             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GEN                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MyGetAutoLog(cPath, cArqLog)

Local nHandle	:= 0					//Numero de referencia do Handle do arquivo aberto

Local aAutoErro	:= {}					//Array contendo as informacoes de log encontradas

Default cPath	:= ""
Default cArqLog	:= ""

If !Empty(cArqLog) .AND. File(cPath + cArqLog)

	nHandle := FT_FUSE(cPath + cArqLog)

	If nHandle <> Nil .and. nHandle > 0
		FT_FGOTOP()

		While !FT_FEOF() .AND. !lEnd

			aAdd(aAutoErro, FT_FREADLN())	//leitura de linha do arq texto
			FT_FSKIP()
		EndDo
	EndIf
	FT_FUSE()
EndIf

Return aAutoErro
