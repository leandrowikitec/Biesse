#Include 'Protheus.ch'
#include "topconn.ch"

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PE01NFESEFAZ ³ Autor ³ Montes - Wikitec   ³ Data ³05.03.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada utilizado no NFESEFAZ.PRW para tratamento  ³±±
±±³          ³dos dados para geração do XML da NF-e Eletronica.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com detalhamento da Nota Eletronica                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

User Function PE01NFESEFAZ

/*
// aRetorno[1] -> aProd
// aRetorno[2] -> cMensCli
// aRetorno[3] -> cMensFis
// aRetorno[4] -> aDest
// aRetorno[5] -> aNota
// aRetorno[6] -> aInfoItem
// aRetorno[7] -> aDupl
// aRetorno[8] -> aTransp
// aRetorno[9] -> aEntrega
// aRetorno[10] -> aRetirada
// aRetorno[11] -> aVeiculo
// aRetorno[12] -> aReboque
// aRetorno[13] -> aNfVincRur
// aRetorno[14] -> aEspVol
// aRetorno[15] -> aNfVinc
// aRetorno[16] -> AdetPag
// aRetorno[16] -> AObsCont
*/
Local aProd		:= Paramixb[1]
Local cMensCli	:= Paramixb[2]
Local cMensFis	:= Paramixb[3]
Local aDest 	:= Paramixb[4]
Local aNota		:= Paramixb[5]
Local aInfoItem	:= Paramixb[6]
Local aDupl		:= Paramixb[7]
Local aTransp	:= Paramixb[8]
Local aEntrega	:= Paramixb[9]
Local aRetirada	:= Paramixb[10]
Local aVeiculo	:= Paramixb[11]
Local aReboque	:= Paramixb[12]
Local aNfVincRur:= Paramixb[13]
Local aEspVol	:= Paramixb[14]
LocaL aNfVinc	:= Paramixb[15]
LocaL aDetPag	:= Paramixb[16] 
Local aObsCont  := Paramixb[17] 
Local aArea		:= GetArea()
Local aRet 		:= {}
Local nI		:= 0

dbSelectArea("SB5")
dbSetOrder(1)

For nI := 1 To Len(aProd)
	
	If SB5->(dbSeek(xFilial("SB5") + aProd[nI][2]))
		If !Empty(SB5->B5_CEME)
			aProd[nI][4] := AllTrim(SB5->B5_CEME)
		EndIf
	EndIf
	
Next nI

aRet := {aProd, cMensCli, cMensFis, aDest, aNota, aInfoItem, aDupl, aTransp, aEntrega, aRetirada, aVeiculo, aReboque, aNfVincRur, aEspVol, aNfVinc,aDetPag,aObsCont} 

RestArea(aArea)
Return aRet