/*/{Protheus.doc} A265nacd
Habilita endere�amento via Protheus ou ACD
@type function
@version  1
@author lfabi
@since 19/05/2022
@return Logic
/*/
User Function A265NACD()

Local lRet := Aviso("Teste","Retorna V/F",{".T.",".F."}) == 1// Valida��es do usu�rio

Return lRet