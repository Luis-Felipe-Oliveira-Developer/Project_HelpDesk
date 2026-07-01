#include "Protheus.ch"
#include "TopConn.ch"

//Constantes
#Define STR_PULA        Chr(13)+Chr(10)

/*/{Protheus.doc} zConsSQL
Função para consulta genérica
@author Daniel Atilio
@since 15/12/2016
@version 1.0
    @param cConsSQLM, Caracter, Consulta SQL
    @param cRetorM, Caracter, Campo que será retornado
    @param cAgrupM, Caracter, Group By do SQL
    @param cOrderM, Caracter, Order By do SQL
    @return lRetorn, retorno se a consulta foi confirmada ou não
    @example
    lOK := u_zConsSQL("SELECT B1_COD, B1_DESC FROM SB1010 WHERE D_E_L_E_T_ = ' ' ", "B1_COD", "", "B1_COD")
    ...
    u_zConsSQL("SELECT * FROM ZA0990", "ZA0_COD", "", "")
    ...
    @obs O retorno da consulta é pública (__cRetorno) para ser usada em consultas específicas
    A consulta não pode ter ORDER BY, pois ele já é especificado em um parâmetro

    Link
    https://terminaldeinformacao.com/2024/11/06/como-criar-uma-consulta-especifica-f3-no-configurador/
    https://terminaldeinformacao.com/2017/05/09/tela-de-consulta-de-dados-atraves-de-uma-query-advpl/
/*/

user function zConsSQL(cConsSQLM, cRetorM, cAgrupM, cOrderM)
    local aArea     := GetArea()
    local nTamBtn   := 50
    local oGrpPesqui
    local oGrpDados
    local oGrpAcoes
    local oBtnConf
    local oBtnLimp
    local oBtnCanc
    //Defaults
    default cConsSQLM   := ""
    default cRetorM     := ""
    default cOrderM     := ""
    //Privates
    private cConsSQL    := cConsSQLM
    private cCampoRet   := cRetorM
    private cAgrup      := cAgrupM
    private cOrder      := cOrderM
    private nTamanRet   := 0
    private aStruAux    := {}
    //MsNewGetDados
    private oMsNew
    private aHeadAux    := {}
    private aColsAux    := {}
    //Tamanho da janela
    private nJanLarg    := 0800
    private nJanAltu    := 0500
    //Gets e Dialog
    private oDlgEspe
    private oGetPesq
    private cGetPesq    := Space(100)
    //Retorno
    private lRetorn     := .F.
    public __cRetorno   := ""

    //Se tiver o alias em branco ou não tiver campos
    if empty(cConsSQLM) .or. empty(cRetorM)
        MsgStop("SQL e / ou retorno em branco!", "Atenção")
        return lRetorn
    endif

    //Criando a estrutura para a MsNewGetDados
    fCriaMsNew()
    __cRetorno := Space(nTamanRet)

    //Criando a janela
    DEFINE MSDIALOG oDlgEspe TITLE "Consulta de Dados" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Pesquisar
        @ 003, 003 GROUP oGrpPesqui TO 025, (nJanLarg/2)-3 PROMPT "Pesquisar: " OF oDlgEspe COLOR 0, 16777215 PIXEL
        @ 010, 006 MSGET oGetPesq VAR cGetPesq SIZE (nJanLarg/2)-12, 010 OF COLORS 0, 16777215 PIXEL VALID (fVldPesq()) PIXEL
        
        //Dados
        @ 028, 003 GROUP oGrpDados TO (nJanAltu/2)-28, (nJanLarg/2)-3 PROMPT "Dados: " OF oDlgEspe COLOR 0, 16777215 PIXEL
            oMsNew  := MsNewGetDados():New(;
                        035,;                               //nTop
                        006,;                               //nLeft
                        (nJanAltu/2)-31,;                   //nBottom
                        (nJanLarg/2)-6,;                    //nRight
                        GD_INSERT+GD_DELETE+GD_UPDATE,;     //nStyle
                        "AllwaysTrue()",;                   //cLinhaOk
                        ,;                                  //cTudoOk
                        "",;                                //cIniCpos
                        ,;                                  //aAlter
                        ,;                                  //nFreeze
                        999,;                               //nMax
                        ,;                                  //cFieldOk
                        ,;                                  //cSuperDel
                        ,;                                  //cDelOk
                        oDlgEspe,;                          //oWnd
                        aHeadAux,;                          //aHeader
                        aColsAux )                          //aCols
            oMsNew:lActive := .F.
            oMsNew:oBrowse:blDblClick := {|| fConfirm()}

            //Populano os dados da MsNewGetDados
            fPopula()

        @ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: " OF oDlgEspe COLOR 0,16777215 PIXEL
            @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fConfirm()) PIXEL
            @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Limpar"    SIZE nTamBtn, 013 OF oDlgEspe ACTION(fLimpar() ) PIXEL
            @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnCanc PROMPT "Cancelar"  SIZE nTamBtn, 013 OF oDlgEspe ACTION(fCancela()) PIXEL

        oMsNew:oBrowse:SetFocus()
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgEspe CENTERED

    RestArea(aArea)
return lRetorn

/*---------------------------------------------------------------------*
 | Func:  fCriaMsNew                                                   |
 | Autor: Daniel Atilio                                                |
 | Data:  15/12/2016                                                   |
 | Desc:  Função para criar a estrutura da MsNewGetDados               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

 static function fCriaMsNew()
    local aAreaX3 := SX3->(GetArea())
    local cQuery  := ""
    local nAtual  := 0

    //Zerando o cabecalho e a estrutura
    aHeadAux := {}
    aColsAux := {}

    //Monta a consulta e pega a estrutura
    cQuery := cConsSQL

    //Group by
    if !empty(cAgrup)
        cQuery += cAgrup + STR_PULA
    endif

    //Order by
    cQuery += " ORDER BY" + STR_PULA
    if !empty(cOrder)
        cQuery += " "+cOrder
    else
        cQuery += " "+cCampoRet
    endif

    TCQuery cQuery New Alias "QRY_DAD"
    aStruAux := QRY_DAD->(DbStruct())
    QRY_DAD->(DbCloseArea())

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2)) //Campo
    SX3->(DbGoTop())

    //Percorrendo os campos
    For nAtual := 1 to len(aStruAux)
        cCampoAtu := aStruAux[nAtual][1]

        //Se conseguir posicionar no campo
        if SX3->(DbSeek(cCampoAtu))
            //Cabecalho      Titulo      Campo      Mask                                  Tamanho,         Decimal,        Valid  Usado   Tip          F3   CBOx
            aAdd(aHeadAux, { X3Titulo(), cCampoAtu, PesqPict(SX3->X3_ARQUIVO, cCampoAtu), SX3->X3_TAMANHO, SX3->X3_DECIMAL, ".F.", ".F.", SX3->X3_TIPO, "", ""})

            //Se o campo atual for retornar, aumenta o tamanho do retorno
            if cCampoAtu $ cCampoRet
                nTamanRet += SX3->X3_TAMANHO
            endif
        else
            //Cabeçalho ...    Titulo                                    Campo        Mask    Tamanho                    Dec                        Valid    Usado    Tip                        F3    CBOX
            aAdd(aHeadAux,{    Capital(StrTran(cCampoAtu, '_', ' ')),    cCampoAtu,    "",        aStruAux[nAtual][3],    aStruAux[nAtual][4],    ".F.",    ".F.",    aStruAux[nAtual][2],    "",    ""})
             
            //Se o campo atual for retornar, aumenta o tamanho do retorno
            if cCampoAtu $ cCampoRet
                nTamanRet += aStruAux[nAtual][3]
            endif
        endif
    next

    RestArea(aAreaX3)
return

/*---------------------------------------------------------------------*
 | Func:  fPopula                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  15/12/2016                                                   |
 | Desc:  Função que popula a tabela auxiliar da MsNewGetDados         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

 static function fPopula()
    local cQuery := ""
    local nAtual := 0
    aColsAux := {}
    nCampAux := 1

    //Faz a consulta
    cQuery := cConsSQL + STR_PULA

    //Se tiver filtro
    If !empty(cGetPesq)
        if 'WHERE' $ cQuery
            cQuery += "     AND "
        else
            cQuery += "     WHERE "
        endif
        cQuery += " ( "
        for nAtual := 1 to len(aStruAux)
            cCampoAtu := aStruAux[nAtual][1]
            if aStruAux[nAtual][2] == 'C'
                cQuery += " UPPER("+cCampoAtu+") LIKE '%"+UPPER(alltrim(cGetPesq))+"%' OR"
            endif
        next
        cQuery := SUBSTR(cQuery, 1, len(cQuery)-2)
        cQuery += ")"+STR_PULA
    endif

    //Group By
    if !empty(cAgrup)
        cQuery += cAgrup +STR_PULA
    endif

    //Order by
    cQuery += "ORDER BY " +STR_PULA
    if !empty(cOrder)
        cQuery += " "+cOrder
    else
        cQuery += " "+cCampoRet
    endif
    TCQuery cQuery New Alias "QRY_DAD"

    //Percorrendo a estrutura, procurando campos de data
    For nAtual := 1 To Len(aHeadAux)
        //Se for data
        If aHeadAux[nAtual][8] == "D"
            TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'D')
        //Se for data
        ElseIf aHeadAux[nAtual][8] == "N"
            TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'N', aHeadAux[nAtual][4], aHeadAux[nAtual][5])
        EndIf
    Next
     
    //Enquanto tiver dados
    While ! QRY_DAD->(EoF())
        nCampAux := 1
        aAux := {}
        //Percorrendo os campos e adicionando no acols e com o delet
        For nAtual := 1 To Len(aStruAux)
            cCampoAtu := aStruAux[nAtual][1]
             
            If aStruAux[nAtual][2] $ "N;D"
                aAdd(aAux,  &("QRY_DAD->"+cCampoAtu) )
            Else
                aAdd(aAux, cValToChar( &("QRY_DAD->"+cCampoAtu) ))
            EndIf
        Next
        aAdd(aAux, .F.)
     
        aAdd(aColsAux, aClone(aAux))
        QRY_DAD->(DbSkip())
    EndDo
    QRY_DAD->(DbCloseArea())
     
    //Se não tiver dados, adiciona linha em branco
    If Len(aColsAux) == 0
        aAux := {}
         
        //Percorrendo os campos e adicionando no acols e com o delet
        For nAtual := 1 To Len(aStruAux)
            aAdd(aAux, '')
        Next
        aAdd(aAux, .F.)
     
        aAdd(aColsAux, aClone(aAux))
    EndIf
     
    //Posiciona no topo e atualiza grid
    oMsNew:SetArray(aColsAux)
    oMsNew:oBrowse:Refresh()
Return
 
/*---------------------------------------------------------------------*
 | Func:  fConfirm                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  15/12/2016                                                   |
 | Desc:  Função de confirmação da rotina                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fConfirm()
    Local aAreaX3 := SX3->(GetArea())
    Local cAux := ""
    Local aColsNov := oMsNew:aCols
    Local nLinAtu  := oMsNew:nAt
    Local nAtual
 
    //Percorrendo os campos
    For nAtual := 1 To Len(aHeadAux)
        cCampoAtu := aHeadAux[nAtual][2]
     
        //Se o campo atual for retornar, soma com o auxiliar
        If cCampoAtu $ cCampoRet
            cAux += aColsNov[nLinAtu][nAtual]
        EndIf
    Next
 
    //Setando o retorno conforme auxiliar e finalizando a tela
    lRetorn := .T.
    __cRetorno := cAux
     
    //Se tiver retorno
    If Len(__cRetorno) != 0
        //Se o tamanho for menor, adiciona
        If Len(__cRetorno) < nTamanRet
            __cRetorno += Space(nTamanRet - Len(__cRetorno))
         
        //Senão se for maior, diminui
        ElseIf Len(__cRetorno) > nTamanRet
            __cRetorno := SubStr(__cRetorno, 1, nTamanRet)
        EndIf
    EndIf
     
    oDlgEspe:End()
    RestArea(aAreaX3)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fLimpar                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  15/12/2016                                                   |
 | Desc:  Função que limpa os dados da rotina                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fLimpar()
    //Zerando gets
    cGetPesq := Space(100)
    oGetPesq:Refresh()
 
    //Atualiza grid
    fPopula()
     
    //Setando o foco na pesquisa
    oGetPesq:SetFocus()
Return
 
/*---------------------------------------------------------------------*
 | Func:  fCancela                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  15/12/2016                                                   |
 | Desc:  Função de cancelamento da rotina                             |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fCancela()
    //Setando o retorno em branco e finalizando a tela
    lRetorn := .F.
    __cRetorno := Space(nTamanRet)
    oDlgEspe:End()
Return
 
/*---------------------------------------------------------------------*
 | Func:  fVldPesq                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  15/12/2016                                                   |
 | Desc:  Função que valida o campo digitado                           |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function fVldPesq()
    Local lRet := .T.
     
    //Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
    If "'" $ cGetPesq .Or. "%" $ cGetPesq
        lRet := .F.
        MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
    EndIf
     
    //Se houver retorno, atualiza grid
    If lRet
        fPopula()
    EndIf
Return lRet

