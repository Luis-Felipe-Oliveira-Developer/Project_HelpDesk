#include 'Totvs.ch'
#include 'FWMVCDef.ch'

//Variaveis estaticas
static cTitulo   := "Chamados HelpDesk"
static cTabPai   := "ZZH"
static cTabFilho := "ZZI"


/*/{Protheus.doc} zHP006
Funcao responsavel pelo gerenciamento de chamados utilizando o Modelo 3 em MVC.
@type user function
@author Luis Felipe Oliveira
@since 14/05/2026
@version 1.0
/*/
user function zHP006()
    local aArea     := FwGetArea()
    local cIdProt   := RetCodUsr()
    local cIDHelpDsk:= ""  
    local lEhTecnico:= .F.
    local cCondicao := ""
    local oBrowse
    local oDadosUsrHD
    private aRotina := {}

    //Chama classe responsavel por retornar os dados do usuario HelpDesk.
    oDadosUsrHD := DadosUsrHD():New(cIdProt)
    cIDHelpDsk  := oDadosUsrHD:GetIDHelpDesk()
    lEhTecnico  := oDadosUsrHD:EhTecnico()

    //Definindo o Menu
    aRotina := MenuDef()

    //Definindo o Browse
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias(cTabPai)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    //Verifica se o usuario corrente possui cadastro na rotina de usuarios do HelpDesk.
    if !Empty(cIDHelpDsk)
        
        //Se nao for tecnico restringe a visualizacao dos chamados apenas aos que foram abertos pelo usuario        
        if !lEhTecnico
            //Adicionando Filtro
            cCondicao := "ZZH->ZZH_IDSOL=="+cIDHelpDsk
            oBrowse:SetFilterDefault(cCondicao) 
        endif

        //Adicionando as legendas
        oBrowse:AddLegend("ZZH_STATUS=='A'", "PINK",    "Aberto sem atendimento")
        oBrowse:AddLegend("ZZH_STATUS=='B'", "YELLOW",  "Em atendimento"        )
        oBrowse:AddLegend("ZZH_STATUS=='C'", "WHITE",   "Pausado"               ) 
        oBrowse:AddLegend("ZZH_STATUS=='D'", "RED",     "Finalizado"            )
        oBrowse:AddLegend("ZZH_STATUS=='E'", "BLACK",   "Cancelado"             )

        //Ativando a Browse
        oBrowse:Activate()
    else
        //Apresenta mensagem informando que o usuario nao possui cadastro no HelpDesk
        Help(,, "Help", , "ID Protheus não cadastrado!", 1, 0, , , , , , {"Solicite o seu acesso para o departamento de Tecnologia da Informação."})

        //Desativando a Browse
        oBrowse:DeActivate()
    endif

    FwRestArea(aArea)
return

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zHP006
@author Luis Felipe Oliveira
@since 14/05/2026
@version 1.0
@type function
/*/

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP006" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP006" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP006" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP006" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Anexo"         ACTION "MsDocument('ZZH',ZZH->(RecNo()),4)"   OPERATION 6 ACCESS 0

    /*
      A funcao MsDocument no Advpl eh utilizada para abrir a tela de banco de conhecimento vinculada a um registro
      especifico de uma tabela, permitindo visualizar, incluir ou editar documentos anexados (como Word, PDF, etc).

      A sintaxe basica eh:
      MsDocument( cAlias, nRecNo, nOpcao)

      Parametros Essencias
      - cAlias: Nome da tabela onde o registro esta posicionado (ex: SA1,SC7).
      - nRecno: Numero do registro atual (Recno()) da tabela.
      - nOpcao: Define a acao do menu:
            - 2: Visualizacao (somente leitura).
            - 4: Alteracao (permite inclusao e edicao).
    
      Integracao em Rotinas Personalizadas (MenuDef)
      Para adicionar o Banco de Conhecimento em uma rotina customizada, inclua a opcao no array aRotina do MenuDef:
      Ex: Aadd(aRotina, {"Conhecimento", "MsDocument('ALIAS', ALIAS->(RecNo()), 4)", 0, 4, 0, Nil})   

      Exemplo de Uso Direto
      #include "Totvs.ch"

      User Function ExemploMsDocument()
        Local cAlias := "SA1"
        Local cCod   := "000001"
        Local cLoja  := "01"
    
        // Posiciona na tabela SA1
        DbSelectArea(cAlias)
        SA1->(DbSetOrder(1)) // Ordem: Filial + Código + Loja

        If SA1->(MsSeek(FWxFilial(cAlias) + cCod + cLoja))
            // Abre o banco de conhecimento em modo de alteração (4)
            MsDocument(cAlias, SA1->(RecNo()), 4)
        EndIf
      Return   

      Pontos de Atencao
      - Tabelas Customizadas: Se a tabela nao for padrao do Protheus, eh necessario utilizar o ponto de entrada
      FTMSREL para definir o relacionamento correto com as tabelas do Banco de Conhecimento (ACB/AC9).

      - Ambiente Portal: A funcao nao funciona via TOTVS Portal (web), pois possui componentes visuais de interface que
      nao sao suportados em jobs sem interface grafica.

      - Extensoes: Nao ha limitacao de extensao de arquivo; o sistema operacional deve ter um aplicativo associado para
      abrir o tipo de arquivo desejado.
    */

return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zHP006
@author Luis Felipe Oliveira
@since 14/05/2026
@version 1.0
@type function
/*/

static function ModelDef()
    local oStruPai   := FWFormStruct(1, cTabPai)
    local oStruFilho := FWFormStruct(1, cTabFilho)
    local aRelFilho  := {}
    local oModel
    local bPre       := Nil                 //Antes de abrir a tela, no carregamento do modelo de dados
    local bPos       := {|| u_Hp09bPos()}   //Validacao ao clicar no Confirmar do modelo de dados
    local bCommit    := Nil                 //Funcao chamado ao clicar no botao Salvar
    local bCancel    := Nil                 //Funcao chamado ao clicar no botao Cancelar
    local cIdProt    := RetCodUsr() 
    local lEhTecnico := .F. 
    local oDadosUsrHD

    //Chama classe responsavel por retornar os dados do usuario HelpDesk.
    oDadosUsrHD := DadosUsrHD():New(cIdProt)
    lEhTecnico := oDadosUsrHD:EhTecnico() 

    //-----------------------------------------
    // 2-Configuracao da validacao
    //-----------------------------------------
    //oStruPai:SetProperty('ZZH_IDTIPO',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCPO("ZZC",FwFldGet("M->ZZH_IDTIPO"),1)'))      //Tipo de Chamado
    //oStruPai:SetProperty('ZZH_IDCAT',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCPO("ZZD",FwFldGet("M->ZZH_IDCAT" ),2)'))      //Categoria	
    //oStruPai:SetProperty('ZZH_IDSUBC',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCPO("ZZE",FwFldGet("M->ZZH_IDSUBC"),2)'))      //Subcategoria



    //Se o usuario nao tiver o perfil de tecnico nao deixa alterar o campo de ID Solicitante.
    if !lEhTecnico
        oStruPai:SetProperty('ZZH_IDSOL', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN,".F.") ) //ID do Solicitante
    endif


    //Instanciando o modelo
    oModel := MPFormModel():New('zHP006M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZHMASTER',/*cOwner*/,oStruPai)
    oModel:AddGrid('ZZIDETAIL','ZZHMASTER',oStruFilho,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:SetPrimaryKey({})

    //Fazendo o relacionamento (Pai e Filho)
    aAdd(aRelFilho, {"ZZI_FILIAL", "FWxFilial('ZZI')"})
    aAdd(aRelFilho, {"ZZI_ID", "ZZH_ID"})
    oModel:SetRelation("ZZIDETAIL", aRelFilho, ZZI->(IndexKey(1)))

return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zHP006
@author Luis Felipe Oliveira
@since 14/05/2026
@version 1.0
@type function
/*/

static function ViewDef()
    local oModel     := FWLoadModel('zHP006')
    local oStruPai   := FWFormStruct(2,cTabPai)
    local oStruFilho := FWFormStruct(2,cTabFilho)
    local oView
    local oDadosUsrHD 
    local cIdProt    := RetCodUsr()
    local lEhTecnico := ""

    //Cria a visualizacao do cadastro
    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZH', oStruPai,  'ZZHMASTER')
    oView:AddGrid('VIEW_ZZI', oStruFilho, 'ZZIDETAIL')

    //Partes da tela
    oView:CreateHorizontalBox('CABEC_PAI',   60)
    oView:CreateHorizontalBox('CABEC_FILHO', 40)
    oView:SetOwnerView('VIEW_ZZH','CABEC_PAI'  )
    oView:SetOwnerView('VIEW_ZZI','CABEC_FILHO')

    //Titulos
    oView:EnableTitleView("VIEW_ZZH", "Informações do Chamado")
    oView:EnableTitleView("VIEW_ZZI", "Histórico do Atendimento")

    //Removendo campos
    oStruFilho:RemoveField("ZZI_ID")

    //Adicionando campo incremental na grid
    //Este comando fará que quando for adicionado um novo item (seta para baixo na grid) seja somado +1 ao número do item.
    oView:AddIncrementField("VIEW_ZZI", "ZZI_ITEM")

    //Chama classe responsavel por retornar os dados do usuario HelpDesk.
    oDadosUsrHD := DadosUsrHD():New(cIdProt)
    lEhTecnico  := oDadosUsrHD:EhTecnico()

    //Adiciona botões direto no Outras Ações da ViewDef
    if lEhTecnico
        //Parâmetros do método addUserButton - (<cTitle>, <cResource>, <bBloco>, [cToolTip], [nShortCut], [aOptions], [lShowBar] )
        oView:addUserButton("Anexo"         , "MAGIC_BMP" , {|| MsDocument('ZZH',ZZH->(RecNo()),4) }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)
        oView:addUserButton("Assumir"       , "MAGIC_BMP" , {|| zAssumiChd()                       }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)
        oView:addUserButton("Transferir"    , "MAGIC_BMP" , {|| Alert("Em construção")             }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)
        oView:addUserButton("Reclassificar" , "MAGIC_BMP" , {|| Alert("Em construção")             }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)
    endif

    oView:addUserButton("Cancelar" , "MAGIC_BMP" , {|| Alert("Em construção")             }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)
    oView:addUserButton("Encerrar" , "MAGIC_BMP" , {|| Alert("Em construção")             }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.)

    //Definindo que não irá usar o "Salvar e Criar Novo"
    oView:SetCloseOnOk({|| .T.})
return oView

/*/{Protheus.doc} User Function FTMSREL
Define tabelas customizadas que podem utilizar o banco de conhecimento padrão
@type  Function
@author Luis Felipe Oliveira
@since 15/05/2026
@see https://tdn.totvs.com/display/public/framework/FTMSREL
/*/
user function FTMSREL()
    local aArea    := FwGetArea()
    local aChave   := {}
    local bMostra  := {||}
    local cTabela  := ""
    local aFields  := {}
    local aRetorno := {}
    
    // Tabela do usuario
    cTabela := "ZZH"

    // Campos que compoe a chave na ordem. Nao passar filial (automatico)
    aChave := {'ZZH_ID'}

    // Bloco de codigo a ser exibido
    bMostra := {|| " Chamado: " + ZZH->ZZH_ID + " - " + "Assunto: " + ZZH->ZZH_ASSUNT}

    // Array com os campos que identificam os campos utilizados na descricao
    aFields := {'ZZH_ID','ZZH_ASSUNT'}

    // Funcoes do sistema para identificar o registro
    aAdd(aRetorno, { cTabela, aChave, bMostra, aFields} )

    FwRestArea(aArea)
return aRetorno


/*-------------------------------------------------------------------*
 | Area das Funcoes das Validacoes.                                  |
 *-------------------------------------------------------------------*/

/*/{Protheus.doc} Hp09bPos()
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@type user function
@author Luis Felipe Oliveira
@since 27/05/2026
@version 1.0
@param param_name, param_type, param_descr
@return lRet, Logico , Retorna .T. ou .F.
@see (links_or_references)
/*/
user function Hp09bPos()
    local lRet          := .T.
    local oModelPad     := FWModelActive()
    local cHora         := SUBSTR(TIME(),1,5)
    local oModelZZH     := Nil
    local oModelZZI     := Nil
    local nOperation    := ""
    local nHorasSLA     := 0
    local aInfVencto    := {}
    local cDataVenct    := ""
    local cHoraVenct    := ""
    local cPrioridad    := ""

    local oUsrHD        := Nil
    local cIdProt       := "" 
    local cGrupoSLA     := ""
    
    if ! oModelPad == Nil
        
        // Pega a operacao que esta a ser executada.
        nOperation := oModelPad:GetOperation()
        /*
        Inclusao  = MODEL_OPERATION_INSERT (3)
        Alteracao = MODEL_OPERATION_UPDATE (4)
        Exclusao  = MODEL_OPERATION_DELETE (5)
        Copia     = MODEL_OPERATION_COPY   (9)
        */

        //Se for uma operação de inclusao, preenche o campo de hora de abertura do chamado.
        if nOperation = MODEL_OPERATION_INSERT

            //Pega o modelo referente ao cabecalho
            oModelZZH := oModelPad:GetModel("ZZHMASTER")
            
            //Seta o horario da abertura do chamado apos clicar no botao confirmar.
            oModelZZH:SetValue("ZZH_HRABER", cHora) //Hora da abertura.

            //Obtem as informacoes para efetuar o calculo da Data e Hora do vencimento do chamado segundo o SLA.
            dDataAbert := oModelZZH:GetValue("ZZH_DTABER") // Data da Abertura
            cHoraAbert := oModelZZH:GetValue("ZZH_HRABER") // Hora da Abertura
            cPrioridad := oModelZZH:GetValue("ZZH_PRIORI") // Prioridade 

            //Obtem o ID Protheus do solicitante para chamar a classe que retorna todas as informacoes do usuario HelpDesk.
            cIdProt := Posicione("ZZB", 1 , xFilial("ZZB") + oModelZZH:GetValue("ZZH_IDSOL"),"ZZB_IDPROT")            
            
            //Pega o Grupo SLA do Usuario HelpDesk
            oUsrHD := DadosUsrHD():New(cIdProt)
            cGrupoSLA := oUsrHD:GetGrupoSLA()
        
            //Consulta a tabela de amarracao de Grupo x Prioridade x Hora SLA
		    nHorasSLA  := Val(Posicione("ZZG",1,FWxFilial("ZZG")+ cGrupoSLA + cPrioridad, "ZZG_HORA")) // Quantidade de horas do SLA

            //Chama funcao para preencher os campos de Data e Hora de Vencimento do Chamado.
            aInfVencto := CalcSLA(dDataAbert, cHoraAbert, nHorasSLA)
            oModelZZH:SetValue("ZZH_DTVENC", aInfVencto[1][1]) //Data de Vencimento
            oModelZZH:SetValue("ZZH_HRVENC", aInfVencto[1][2]) //Hora de Vencimento

            cDataVenct := DtoC(oModelZZH:GetValue("ZZH_DTVENC"))
            cHoraVenct := oModelZZH:GetValue("ZZH_HRVENC")

            if !empty(cDataVenct) .and. !empty(cHoraVenct) 
                //Apresenta mensagem informando a data e hora da previsao de encerramento do prazo do SLA.
                FWAlertInfo(" O prazo para o encerramento do SLA é para: " + CRLF + "- Dia: " + cDataVenct + " às "+ cHoraVenct + " horas.",; 
                "Chamado incluído com sucesso!")
                
                //Help(,, "Informação", , "O prazo de vencimento do SLA está previsto para ", 1, 0, , , , , , {"Solicite o seu acesso para o departamento de Tecnologia da Informação."})
            endif

            //Pega o modelo referente ao item
            oModelZZI := oModelPad:GetModel("ZZIDETAIL")
            oModelZZI:SetValue("ZZI_HORA",   cHora) // Hora da abertura no item.

        else
            if nOperation = MODEL_OPERATION_UPDATE
                oModelZZI := oModelPad:GetModel("ZZIDETAIL")
                oModelZZI:SetValue("ZZI_HORA",   cHora) // Hora da interaçao no item do chamado.
            endif
        endif
    endif

return lRet

/*/{Protheus.doc} CalcSLA
Calcula a Data e Hora de Vencimento do SLA considerando apenas dias úteis e horário de expediente.
@param dDataAbert Data de abertura do chamado
@param cHoraAbert Hora de abertura do chamado (formato "HH:MM")
@param nHorasSLA  Quantidade de horas do SLA (ex: 96)
@return aRetorno  Array com [1] Data de Vencimento e [2] Hora de Vencimento
/*/
static function CalcSLA(dDataAbert, cHoraAbert, nHorasSLA)
	local aArea      := FwGetArea()
	local aAreaZZF   := ZZF->(FwGetArea())
	local aAreaZZG   := ZZG->(FwGetArea())
	
    local dDataFim   := dDataAbert
	local cHoraFim   := cHoraAbert
    local nMinSLA     := nHorasSLA * 60
	local aRetorno   := {}

    // Definição da janela de expediente em segundos
    Local nSecIniExp  := Time2Sec("08:00:00")
    Local nSecFimExp  := Time2Sec("18:00:00")
    Local nMinDiaExp  := (nSecFimExp - nSecIniExp) / 60 // 600 minutos (10 horas)
    Local nMinRestDia := 0

    // 1. Ajusta a hora de abertura se o chamado foi aberto fora da janela de expediente
    if Time2Sec(cHoraFim + ":00") < nSecIniExp
        cHoraFim := "08:00"
    elseif Time2Sec(cHoraFim + ":00") >= nSecFimExp
        dDataFim += 1
        cHoraFim := "08:00"
    endif

    // 2. Garante que a data inicial seja um dia útil
    // O .T. no segundo parâmetro faz com que pule para o próximo dia útil se for FDS ou feriado
    dDataFim := DataValida(dDataFim, .T.)

    // 3. Calcula quantos minutos restam para acabar o expediente no dia atual
    nMinRestDia := (nSecFimExp - Time2Sec(cHoraFim + ":00")) / 60

    // 4. Lógica de consumo do SLA
    if nMinSLA <= nMinRestDia
        // Se o SLA é curto o suficiente para ser resolvido no mesmo dia
        cHoraFim := SubStr(Sec2Time(Time2Sec(cHoraFim + ":00") + (nMinSLA * 60)), 1, 5)
    else
        // Subtrai o tempo que foi consumido no primeiro dia
        nMinSLA -= nMinRestDia

        // Avança para o próximo dia útil
        dDataFim += 1
        dDataFim := DataValida(dDataFim, .T.)

        // Consome dias inteiros de expediente (em blocos de 600 minutos)
        while nMinSLA >= nMinDiaExp
            nMinSLA -= nMinDiaExp
            dDataFim += 1
            dDataFim := DataValida(dDataFim, .T.)
        enddo

        // O saldo que sobrou em minutos é somado a partir das 08:00 do último dia útil
        if nMinSLA > 0
            cHoraFim := SubStr(Sec2Time(nSecIniExp + (nMinSLA * 60)), 1, 5)
        else
            cHoraFim := "08:00" // Se o saldo zerou exato, termina na abertura do dia
        endIf
    endif

    aAdd(aRetorno, { dDataFim, cHoraFim }) 

	FwRestArea(aAreaZZG)
	FwRestArea(aAreaZZF)
	FwRestArea(aArea)
return aRetorno

/*/{Protheus.doc} Time2Sec
Converte uma string de hora (HH:MM:SS ou HH:MM) para segundos totais.
@param cTime String com a hora
@return nSegundos Quantidade de segundos
/*/
Static Function Time2Sec(cTime)
    Local nSec := 0
    Default cTime := "00:00:00"

    // Garante o formato HH:MM:SS caso venha apenas HH:MM
    If Len(Trim(cTime)) == 5 
        cTime += ":00"
    EndIf

    // Extrai horas, minutos e segundos convertendo para numérico
    nSec += Val(SubStr(cTime, 1, 2)) * 3600
    nSec += Val(SubStr(cTime, 4, 2)) * 60
    nSec += Val(SubStr(cTime, 7, 2))

Return nSec

/*/{Protheus.doc} Sec2Time
Converte uma quantidade de segundos em uma string de hora (HH:MM:SS).
@param nSec Quantidade de segundos
@return cTime String com a hora formatada
/*/
Static Function Sec2Time(nSec)
    Local nHoras   := 0
    Local nMinutos := 0
    Local nSegundos:= 0
    Local cRet     := ""

    // Calcula as frações de tempo
    nHoras    := Int(nSec / 3600)
    nMinutos  := Int((nSec % 3600) / 60)
    nSegundos := (nSec % 3600) % 60

    // Formata com zeros à esquerda
    cRet := StrZero(nHoras, 2) + ":" + StrZero(nMinutos, 2) + ":" + StrZero(nSegundos, 2)

Return cRet

/*-------------------------------------------------------------------*
 | Funcoes de Gatilhos.                                              |
 *-------------------------------------------------------------------*/

/*/{Protheus.doc} GatZZH01
    Funcao responsavel por retornar o nome do usuario atraves do gatilho do campo ZZH_IDSOL para o ZZH_NOMSOL.
    @type  Function
    @author Luis Felipe Oliveira
    @since 05/06/2026
    @version version
    @return cRet, Caractere, Retorna o nome do usuario conforme o preenchimento do campo ZZH_IDSOL.
    /*/
user function GatZZH01()
    local aArea      := FwGetArea()
    local aAreaZZB   := ZZB->(FwGetArea())
    local cIDHelpDsk := ""
    local cIdProt    := ""
    local cRet       := ""
    local oModel     := FwModelActive()

    //Retorna o ID HelpDesk do Solicitante escolhido.
    cIDHelpDsk := oModel:GetModel("ZZHMASTER"):GetValue("ZZH_IDSOL")

    //Retorna o ID Protheus do usuario solicitante para pegar o nome completo.
    cIDProt    := Posicione("ZZB",1, FWXFILIAL("ZZB")+ cIDHelpDsk, "ZZB_IDPROT") 
    
    //Retorna o nome completo do usuario.
    cNomeUsr   := USRFULLNAME(cIDProt)        
    cRet := cNomeUsr

    FwRestArea(aAreaZZB)
    FwRestArea(aArea)
return cRet


/*/{Protheus.doc} GatZZH02
    Funcao responsavel por retornar o ID e o Nome do Departamento atraves do gatilho do campo ZZH_IDSOL para o ZZH_IDDEP.
    @type  Function
    @author Luis Felipe Oliveira
    @since 10/06/2026
    @version version
    @return cRet, Caractere, Retorna o ID e o Nome do Departamento conforme o preenchimento do campo ZZH_IDSOL.
    /*/
user function GatZZH02()
    local aArea      := FwGetArea()
    local aAreaZZA   := ZZA->(FwGetArea())
    local aAreaZZB   := ZZB->(FwGetArea())
    local cIDHelpDsk := ""
    local cIdDepto   := ""
    local cNomeDepto := ""
    local cRet       := ""
    local oModel     := FwModelActive()
    local oView      := FwViewActive()

    //Retorna o ID HelpDesk do Solicitante escolhido.
    cIDHelpDsk := oModel:GetModel("ZZHMASTER"):GetValue("ZZH_IDSOL")

    //Retorna o ID do Departamento do usuario solicitante.
    cIdDepto := Posicione("ZZB",1, FWXFILIAL("ZZB")+ cIDHelpDsk, "ZZB_IDDPTO") 

    //Retorna o nome completo do usuario.        
    cRet := cIdDepto

    //Retorna o nome do departamento e sobrescreve a descricao no campo ZZH_DESDEP que eh virtual.
    cNomeDepto := Posicione("ZZA",1, FWXFILIAL("ZZA")+ cIdDepto, "ZZA_DESCR") 
    oModel:GetModel("ZZHMASTER"):SetValue("ZZH_DESDEP", cNomeDepto)

    //Atualiza a tela
    oView:Refresh()

    FwRestArea(aAreaZZA)
    FwRestArea(aAreaZZB)
    FwRestArea(aArea)
return cRet


/*/{Protheus.doc} GatZZH03
    Funcao responsavel por retornar a descricao do tipo de chamado por meio do gatilho do campo ZZH_IDTIPO para ZZH_DESTIP,
    e tambem por deixar os valores dos campos (ZZH_IDCAT, ZZH_DESCAT, ZZH_IDSUBC e ZZH_DESSUC) em branco.
    @type  Function
    @author Luis Felipe Oliveira
    @since 05/06/2026
    @version version
    @return cRet, Caractere, Descricao do Tipo de Chamado.
    /*/
user function GatZZH03()
    local aArea      := FwGetArea()
    local aAreaZZC   := ZZC->(FwGetArea())
    local cIdTipo    := ""
    local cDescTipo  := ""
    local cRet       := ""
    local oModelPad  := Nil 
    local oModelZZH  := Nil
    //local oView      := Nil

    //Instancia o Modelo ativo no objeto
    oModelPad:= FwModelActive()
    oModelZZH:= oModelPad:GetModel("ZZHMASTER")

    //Pega a View ativa
    oView := FwViewActive()

    //Pega o ID do Tipo de Chamado e posiciona na tabela ZZC para retornar a descricao.
    cIdTipo   :=  oModelZZH:GetValue("ZZH_IDTIPO")
    cDescTipo :=  Posicione("ZZC",1, FWXFILIAL("ZZC")+cIdTipo, "ZZC_DESCR")

    //Retorna a decricao do Tipo.
    cRet := cDescTipo

    //Diferença entre SetValue e LoadValue
    //SetValue:  Alem de limpar o campo, dispara gatilhos e outras validacoes vinculadas ao campo alterado.
    //LoadValue: altera o valor diretamente no modelo. É o mais recomendado para limpezas em validacoes,
    //pois nao dispara gatilhos e novas validacoes em cadeia, evitando loops.
    
    //Realiza a limpeza dos campos. Obs: Com SetValue nao funcionou porque os campos sao obrigatorios.
    oModelZZH:LoadValue("ZZH_IDCAT",  "")
    oModelZZH:LoadValue("ZZH_DESCAT", "")
    oModelZZH:LoadValue("ZZH_IDSUBC", "")
    oModelZZH:LoadValue("ZZH_DESSUC", "")

    //Atualiza a tela.
    oView:Refresh()

    FwRestArea(aAreaZZC)
    FwRestArea(aArea)
return cRet


/*-------------------------------------------------------------------*
 | Funcoes dos Inicializadores Padroes                               |
 *-------------------------------------------------------------------*/

/*/{Protheus.doc} IniPdZZI03()
Retorna o Tipo de Interacao do chamado.
Preenche o campo ZZI_TIPINT (Tipo de Interacao).
@type user function
@author Luis Felipe Oliveira
@since 31/05/2026
@return cRet, Caractere, Retorna a o tipo de interacao
/*/
user function InPZZI03()
	local aArea      := FwGetArea()
	local aAreaZZB   := ZZB->(FwGetArea())
	local oModelPad  := FWModelActive()
	local oModelGrid := oModelPad:GetModel("ZZIDETAIL")
	local nLinha     := oModelGrid:nLine //Retorna a posicao da linha posicionada.
	local nTamanho   := 0
	local cIDProt    := ""
	local cIDHelpDsk := ""
    local lEhTecnico := .F.
    local cRetorno   := ""

	//Retorna o ID do usuario Protheus
	cIdProt := RetCodUsr()
	
	//Retorna o ID do usuario HelpDesk
	cIDHelpDsk := Posicione("ZZB", 2, FWxFilial("ZZB")+cIdProt, "ZZB_ID")

	//Verifica se o ID do usuario possui perfil de atendente
	lEhTecnico := POSICIONE("ZZB",1, FWXFILIAL("ZZB")+ cIDHelpDsk, "ZZB_TIPO") <> '1'

	nTamanho := oModelGrid:Length()
	if nTamanho == 0
		cRetorno := "1" //Relato Inicial
	else
		oModelGrid:GoLine(nLinha) //Posiciona na linha da Grid
		//Se o usuario tiver perfil de atendente
		if lEhTecnico
			cRetorno := "2" //Resposta Atendente
		else
			cRetorno := "3" //Resposta Solicitante
		endif
	endif
	
    FwRestArea(aAreaZZB)
    FwRestArea(aArea)
return cRetorno

/*-------------------------------------------------------------------*
 | Area das Funcoes dos Botoes e Opcoes Customizadas.                |
 *-------------------------------------------------------------------*/

/*/{Protheus.doc} zAssumiChd
    Ao clicar no botao "Assumir Chamador" em outras acoes, essa funcao sera aberta e os campos referentes a Atendente e
    Status do Chamado serao atualizados. O campo atendente ficarah com o ID HelpDesk do Atendente que clicou no botao,
    e o Status do chamado ficarah como "B" (Em atendimento).
    @type  Static Function
    @author Luis Felipe Oliveira
    @since 22/05/2026
    @version version
    @see 
       https://terminaldeinformacao.com/2024/08/28/adicionar-botoes-em-uma-tela-em-mvc-somente-em-determinadas-operacoes/ 
       https://www.youtube.com/watch?v=xgWmg9DVXo4
       https://terminaldeinformacao.com/2024/02/06/manipulando-campos-em-mvc-com-fwfldget-e-fwfldput-maratona-advpl-e-tl-219/
/*/
static function zAssumiChd() 
    local aArea      := FwGetArea()
    local cIDProt    := RetCodUsr() //ID Protheus
    local cIDHelpDsk := "" 
    local czNome     := ""
    local nOperacao  := 0
    local oModel     := FWModelActive()
    local oView      := FwViewActive()    
    local oUsrHD     := Nil

    //Chama classe para pegar todas as informacoes do usuario HelpDesk.
    oUsrHD := DadosUsrHD():New(cIDProt)
    cIDHelpDsk := oUsrHD:GetIDHelpDesk() //Retorna o ID HelpDesk.
    czNome     := oUsrHD:GetNomeUsr()    //Retorna o Nome do Usuario HelpDesk.
    
    /*
    //Ponto de atencao para uma futura implementacao de niveis para atendimento.
    //Pega o nivel de prioridade setado no chamado. (001BXA=Baixa, 002MED=Media, 003ALT=Alta, 004CRI=Critica, 005PRJ=Projeto) 
    //cNivPriori := oModel:GetModel("ZZHMASTER"):GetValue("ZZH_PRIORI")
    
    Regra:    
        Nivel de Atendimento = '1' (Complexidade Baixa)  somente chamado de Prioridade = 001BXA=Baixa;
        Nivel de Atendimento = '2' (Complexidade Media), chamados de Prioridade <= 002MED=Media;
        Nivel de Atendimento = '3' (Complexidade Alta e Critica), chamados de Prioridade <= 004CRI=Critica;
        Chamados de Prioridade <= 005PRJ=Projeto podem ser atendido inicialmente por qualquer nível.
    */ 

    //Se a operacao for de inclusao ou alteracao.
    nOperacao := oModel:GetOperation() 
    if nOperacao ==  MODEL_OPERATION_INSERT .or. nOperacao = MODEL_OPERATION_UPDATE
        //Altera um campo da memória 
        oModel:SetValue("ZZHMASTER","ZZH_STATUS", u_StatsZZH('Codigo', 2 )) //Status do Chamado (2 = Em atendimento)
        oModel:SetValue("ZZHMASTER","ZZH_IDTEC",  cIDHelpDsk              ) //ID HelpDesk
        oModel:SetValue("ZZHMASTER","ZZH_NOMTEC", czNome                  ) //Nome do Atendente

        /*
        //Outra forma de obter o mesmo resultado.
        FwFldPut("ZZH_STATUS", "B"                  ) //ID HelpDesk
        FwFldPut("ZZH_IDTEC",  cIDHelpDsk           ) //Nome do Atendente
        FwFldPut("ZZH_NOMTEC", USRFULLNAME(cIDProt) ) //Status do Chamado
        */

        //Atualiza a tela
        oView:Refresh()
    else
        Help(,, "Help", , "Não é possível assumir o chamado a partir desta operação.", 1, 0, , , , , , ;
        {"Para assumir o chamado, escolha a operação de inclusão ou alteração."})
    endif
    
    FwRestArea(aArea)
return 


/*/{Protheus.doc} StatsZZH(cModo, nOpcao)
Retorna o conteudo para preencher o campo de Status do Chamado HelpDesk.
Preenche o campo ZZH_STATUS (Status do Chamado) e o campo virtual ZZH_DESSTS (Descricao do Status).
@type user function
@author user
@since 31/05/2026
@param  cModo  , Caractere , "Codigo": Retorna o Codigo; " ": Retorna a Descricao
@param  nOpcao , Numerico  , Codigo da opcao numerica para retornar o status
@return cRet   , Caractere , Status do Chamado ou a Descricao do Status
/*/
user function StatsZZH(cModo, nOpcao)  
    local aArea     := FwGetArea()
    local oModel    := Nil
    local oModelZZH := Nil
    local cStatus   := ""
    local cRet      := ""
    default cModo   := "Codigo"
    default nOpcao  := 0

    // Retorna o Codigo do Status baseado na opcao numerica
    if cModo == "Codigo" 
        do case
            case nOpcao == 1
                cRet := "A" // Aberto sem atendimento
            case nOpcao == 2 
                cRet := "B" // Em atendimento
            case nOpcao == 3
                cRet := "C" // Pausado
            case nOpcao == 4 
                cRet := "D" // Finalizado
            otherwise 
                cRet := "E" // Cancelado
        endcase
        
    else 
        // Retorna a Descricao do Status baseado no Model
        oModel := FwModelActive()

        // Garante que existe um MVC ativo antes de tentar ler o valor
        if oModel != Nil 
            oModelZZH := oModel:GetModel("ZZHMASTER")
            
            if oModelZZH != Nil
                cStatus := oModelZZH:GetValue("ZZH_STATUS")
            
                // Retorna a descricao correspondente ao status atual
                do case
                    case cStatus == "A"
                        cRet := "Aberto sem atendimento"
                    case cStatus == "B"
                        cRet := "Em atendimento"
                    case cStatus == "C"
                        cRet := "Pausado"
                    case cStatus == "D"
                        cRet := "Finalizado"
                    case cStatus == "E"
                        cRet := "Cancelado"
                    otherwise
                        cRet := "" // Status vazio ou nao identificado na tela
                endcase            
            endif
        
        endif
    
    endif
    
    FwRestArea(aArea)
return cRet
