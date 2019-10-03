#include "protheus.ch"

// Função de exemplo
User Function HelloWorld()
    Local cText := "Hello World"
Return FWLogMsg('INFO','LAST','SMART','HelloWorld','','01',cText,0,1,{})
