#Include "Rwmake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} RCOMA01
(Ponto de entrada utilizado para inserir novas opções no array aRotina)
@author Renato Calabro'
@since 26/05/2021
@return Nil
@see (links_or_references)
/*/

User Function MTA103MNU()

Local aSubRots		:= {} as array

// Adiciono rotinas de notas fiscais de importacao
aAdd(aSubRots,{"Importa NF por CSV", "U_RCOMA01()", 0, 37})
aAdd(aSubRots,{"Relaciona Nf x Complem.", "U_RCOMA02()", 0, 40})
aAdd(aSubRots,{"Vis. Complementos", "U_MyMT103Posicione()", 0, 38})
aAdd(aSubRots,{"NFe SEFAZ", "SPEDNFE()", 0, 39})

aAdd(aRotina, {"* Funções de Importação", aSubRots, , 0, 36})

Return Nil

/*/{Protheus.doc} MyMT103Posicione
(Funcao para posicionar o SD1 e executar rotina de complemneto de nota fiscal de importacao)
@author Renato Calabro'
@since 26/05/2021
@return Nil
@see (links_or_references)
/*/

User Function MyMT103Posicione()

DbSelectArea("SD1")
DbSetOrder(1)		// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
If SD1->(DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	Mata926(SD1->D1_DOC,SD1->D1_SERIE,SF1->F1_ESPECIE,SD1->D1_FORNECE,SD1->D1_LOJA,'E',SD1->D1_TIPO,SD1->D1_CF)
EndIf

Return Nil
