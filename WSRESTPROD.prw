#include "totvs.ch"
#include "RESTFUL.ch"

WSRESTFUL WSRESTPROD DESCRIPTION "Serviço REST para manupulação de produtos/SB1"

WSDATA CODPRODUTO AS STRING

WSMETHOD GET buscarproduto DESCRIPTION "Retorna dados do Produto" WSSYNTAX "/buscarproduto" PATH "buscarproduto" PRODUCES APPLICATION_JSON

WSMETHOD POST inserirproduto DESCRIPTION "Inserir dados Produto" WSSYNTAX "/inserirproduto" PATH "inserirproduto" PRODUCES APPLICATION_JSON

WSMETHOD PUT atualizarproduto DESCRIPTION "Altera dados Produto" WSSYNTAX "/atualizarproduto" PATH "atualizarproduto" PRODUCES APPLICATION_JSON

WSMETHOD DELETE deletarproduto DESCRIPTION "Deletar dados Produto" WSSYNTAX "/deletarproduto" PATH "deletarproduto" PRODUCES APPLICATION_JSON


ENDWSRESTFUL

WSMETHOD GET buscarproduto WSRECEIVE CODPRODUTO WSREST WSRESTPROD 
Local lRET      := .T.   
Local cCodProd  := Self:CODPRODUTO
//Local aArea     := GetArea()
Local oJson     := JsonObject():New()
Local cJson     := ""
Local oReturn
Local cReturn 
Local aProd     :={}

Local cStatus   := ""
Local cGrupo    := ""

DbselectArea("SB1")
SB1->(DbSetOrder(1))
IF SB1_>(DbSeek(xFilial("SB1")+cCodProd))
    cStatus:= IIF(SB1->B1_MSBLQL == "1", "Bloqueado", "Desbloqueado")

    CGrupo:= Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")

    aAdd(aProd,JsonObject():New())

    aProd[1]['prodcod']     := AllTrim(SB1->B1_COD)
    aProd[1]['proddesc']    := AllTrim(SB1->B1_DESC)
    aProd[1]['produm']      := AllTrim(SB1->B1_UM)
    aProd[1]['prodtipo']    := AllTrim(SB1->B1_TIPO)
    aProd[1]['prodncm']     := AllTrim(SB1->B1_POSIPI)
    aProd[1]['prodgrupo']   := cGrupo
    aProd[1]['prodstatus']  := cStatus

    oReturn := JsonObject():New()
    oReturn ['cRet']    := "200"
    oReturn ['cmessage']:= "Produto encontrado com sucesso"
    cReturn := FwJSonSerialize(oReturn)

    oJson["produtos"] := aProd
    cJson := FwJSonSerialize(oJson)
    ::SetResponse(cJson)
    ::SetResponse(cReturn)


ELSE
    SetRestFault(400,'codigo do produto não encontrado')
    lRet := .F.
    Return(lRET)

ENDIF

SB1 ->(dbClosArea())


WSMETHOD POST inserirproduto WSRECEIVE WSREST WSRESTPROD 
Local lRet  := .T.
Local aArea := GetArea()

Local oJson := JsonObject():New()

Local oReturn := JsonObject():New()

oJson:FromJson(Self:GetContent())

DbselectArea("SB1")
SB1->(DbSetOrder(1))

IF SB1 ->(DbSeek(xFilial("SB1")+AllTrim(oJson["produtos"]:GetJsonObject("prodcod"))))
    SetRestFault(400,'CODIGO DO PRODUTO JA EXISTE!')
    lRet := .F.
    Return(lRet)
ELSEIF Empty(oJson["produtos"]:GetJsonObject("prodcod"))
    SetRestFault(401,'CODIGO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet)   

ELSEIF Empty(oJson["produtos"]:GetJsonObject("proddesc"))
    SetRestFault(402,'DESCICAO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet)   

ELSEIF Empty(oJson["produtos"]:GetJsonObject("produm"))
    SetRestFault(403,'UNIDADE DE MEDIDA DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet) 

ELSEIF Empty(oJson["produtos"]:GetJsonObject("prodgrupo"))
    SetRestFault(404,'CODIGO DO GRUPO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet) 

ELSEIF Empty(oJson["produtos"]:GetJsonObject("prodtipo"))
    SetRestFault(405,'O TIPO DO GRUPO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet) 
ELSE 
    RecLock("SB1",.T.)
        SB1->B1_COD     := oJson["produtos"]:GetJsonObject("prodcod")
        SB1->B1_DESC    := oJson["produtos"]:GetJsonObject("proddesc")
        SB1->B1_TIPO    := oJson["produtos"]:GetJsonObject("prodtipo")
        SB1->B1_UM      := oJson["produtos"]:GetJsonObject("produm")
        SB1->B1_GRUPO   := oJson["produtos"]:GetJsonObject("prodgrupo")
        SB1->B1_MSBLQL  := "1"
    SB1->(MsUnlock())

    oReturn["prodcod"] := oJson["produtos"]:GetJsonObject("prodcod")
    oReturn["proddesc"] := oJson["produtos"]:GetJsonObject("proddesc")
    oReturn["cRet"]     := "201 - Sucesso!"
    oReturn["cMessage"] := "Registro incluido com sucesso no bando de dados, por favor insira o restante dos dados via protheus"

    Self:SetStatus(201)
    Self:SetContentType(APPLICATION_JSON)
    Self:SetResponse(FwJSonSerialize(oReturn))
ENDIF

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return lRet


WSMETHOD PUT atualizarproduto WSRECEIVE WSREST WSRESTPROD 
Local lRet  := .T.
Local aArea := GetArea()

Local oJson := JsonObject():New()

Local oReturn := JsonObject():New()

oJson:FromJson(Self:GetContent())

DbselectArea("SB1")
SB1->(DbSetOrder(1))

IF !SB1 ->(DbSeek(xFilial("SB1")+AllTrim(oJson["produtos"]:GetJsonObject("prodcod"))))
    SetRestFault(400,'CODIGO DO PRODUTO JA EXISTE!')
    lRet := .F.
    Return(lRet)
ELSEIF Empty(oJson["produtos"]:GetJsonObject("prodcod"))
    SetRestFault(401,'CODIGO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet)   

ELSEIF Empty(oJson["produtos"]:GetJsonObject("proddesc"))
    SetRestFault(402,'DESCICAO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet)   

ELSEIF Empty(oJson["produtos"]:GetJsonObject("produm"))
    SetRestFault(403,'UNIDADE DE MEDIDA DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet) 

ELSEIF Empty(oJson["produtos"]:GetJsonObject("prodgrupo"))
    SetRestFault(404,'CODIGO DO GRUPO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet) 

ELSEIF Empty(oJson["produtos"]:GetJsonObject("prodtipo"))
    SetRestFault(405,'O TIPO DO GRUPO DO PRODUTO ESTA EM BRANCO!')
    lRet := .F.
    Return(lRet) 
ELSE 
    RecLock("SB1",.F.)
        SB1->B1_COD     := oJson["produtos"]:GetJsonObject("prodcod")
        SB1->B1_DESC    := oJson["produtos"]:GetJsonObject("proddesc")
        SB1->B1_TIPO    := oJson["produtos"]:GetJsonObject("prodtipo")
        SB1->B1_UM      := oJson["produtos"]:GetJsonObject("produm")
        SB1->B1_GRUPO   := oJson["produtos"]:GetJsonObject("prodgrupo")
    SB1->(MsUnlock())
    SB1->(dbClosArea())

    oReturn["prodcod"] := oJson["produtos"]:GetJsonObject("prodcod")
    oReturn["proddesc"] := oJson["produtos"]:GetJsonObject("proddesc")
    oReturn["cRet"]     := "201 - Sucesso!"
    oReturn["cMessage"] := "Registro alterado com sucesso no bando de dados, por favor atualize o restante dos dados via protheus"

    Self:SetStatus(201)
    Self:SetContentType(APPLICATION_JSON)
    Self:SetResponse(FwJSonSerialize(oReturn))
ENDIF

RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return lRet

//METODO DELETE

WSMETHOD DELETE deletarproduto WSRECEIVE CODPRODUTO WSREST WSRESTPROD

Local lRet := .T.
Local cCodProd := Self:CODPRODUTO
Local cDescProd := ""
Local aArea := GetArea()
Local oJson := JsonObject():New()
Local oReturn := JsonObject():New()

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

IF !SB1->(DbSeek(xFilial("SB1") + cCodProd))
    SetRestFault(401, 'O CODIGO DE PRODUTO informado nao existe')
    lRet := .F.

    SB1->(dbCloseArea())
    RestArea(aArea)
    FreeObj(oJson)
    FreeObj(oReturn)

    Return lRet
ELSE
    cDescProd := SB1->B1_DESC
    RecLock("SB1", .F.)
        DbDelete()
    SB1->(MsUnlock())

    oReturn["prodcod"] := cCodProd
    oReturn["proddesc"] := cDescProd
    oReturn["cRet"]     := "201 - Sucesso!"
    oReturn["cMessage"] := "Registro EXCLUIDO COM SUCESSO"

    Self:SetStatus(201)
    Self:SetContentType(APPLICATION_JSON)
    Self:SetResponse(FwJSonSerialize(oReturn))
ENDIF

SB1->(dbCloseArea())
RestArea(aArea)
FreeObj(oJson)
FreeObj(oReturn)

Return lRet

/*
{
    "produtos": {
        "prodcod": "AAAA0003",
        "proddesc": "PRODUTO3",
        "produm": "UM",
        "prodtipo": "ME",
        "prodgrupo": "0010"
    }
}

*/
