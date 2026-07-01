#include 'totvs.ch'
#include 'FWMVCDef.ch'

//Variaveis estaticas
static cAliasMVC := 'ZZD'
static cTitulo   := 'Cadastro de Categoria - Projeto HelpDesk'


/*/{Protheus.doc} zHP004
Cadastro de Categoria em MVC Modelo 1 - Tabela ZZD
@type user function
@author Luis Felipe Oliveira
@since 22/04/2026
@version 1.0

Regra de Negocio
1) Deixar os campos: ID, IDTIPO, Descricao e Ativo, como obrigatorios;
2) Criar consulta padrao para o campo IDTIPO na tabela ZZC para retornar o ID do Tipo de Chamado;
3) Validar se o conteudo do IDTIPO digitado existe na tabela ZZC, se não exister nao deixar cadastrar;
4) Criar gatilho para que ao preencher o campo IDTIPO o conteudo do campo Descricao do Tipo seja preenchido com a descricao;
5) Validar se o conteudo digitado no campo ID jah existe no cadastrada, se sim nao deicar cadastrar;
6) Criar ComboBox para o campo Ativo com as opcoes: 1-Ativo e 2-Inativo;
7) Criar inicializador Padrao para o campo Ativo iniciar igual a 1-Ativo.

/*/
user function zHP004()
    local aArea := FwGetArea()
    local oBrowse 
    private aRotina := {}

    //Definindo o Menu
    aRotina := MenuDef()

    //Instanciando o Browse
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescripition(cTitulo)
    oBrowse:DisableDetails()

    //Adicionando as legendas
	oBrowse:AddLegend( "ZZD_ATIVO == '1' ", "GREEN",   "Ativo"  )
	oBrowse:AddLegend( "ZZD_ATIVO == '2' ", "RED",     "Inativo")


    //Ativando o Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP004" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP004" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP004" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP004" OPERATION 5 ACCESS 0
return aRotina

static function ModelDef()
    local oStruct   := FWFormStruct(1,cAliasMVC)
    local oModel
    local bPre      := nil
    local bPos      := nil
    local bCommit   := nil
    local bCancel   := nil
    local aGatilhos := {}
    local nAtual    := 0

    //----------------------------------------
    // 1-Configuracao do Inicializador Padrao 
    //----------------------------------------
    //oStruct:SetProperty('ZZD_ATIVO',     MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ) ) //1-Ativo/2-Inativo

    //----------------------------------------
    // 2-Configuracao do Campo Obrigatorio 
    //----------------------------------------
    //oStruct:SetProperty('ZZD_IDTIPO',  MODEL_FIELD_OBRIGAT, .T. ) //ID Tipo de Chamado
    //oStruct:SetProperty('ZZD_ID',      MODEL_FIELD_OBRIGAT, .T. ) //ID Categoria
    //oStruct:SetProperty('ZZD_DESCR',   MODEL_FIELD_OBRIGAT, .T. ) //Descricao Categoria
    //oStruct:SetProperty('ZZD_ATIVO',   MODEL_FIELD_OBRIGAT, .T. ) //Ativo

    //----------------------------------------
    // 3-Configuracao de Validacao do Campo 
    //----------------------------------------
    //oStruct:SetProperty('ZZD_IDTIPO',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCPO("ZZC",FwFldGet("ZZD_IDTIPO"), 1)' ) ) //ID Tipo de Chamado, valida se ja existe cadastro vinculado ao ID que foi digitado.
    //oStruct:SetProperty('ZZD_ID',       MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistChav("ZZD",FwFldGet("ZZD_ID"),2)'     ) ) //ID Categoria de Chamado, valida se ja existe cadastro vinculado ao ID que foi digitado.

    //----------------------------------------
    // 4-Configuracao de Gatilho 
    //----------------------------------------

    //Adicionando um gatilho do ZZB_IDDPTO (ID Departamento) para preencher o campo ZZF_NOMDEP (Descricao Departamento)
    aAdd(aGatilhos, ;
        FWStrutrigger(;
            "ZZD_IDTIPO",;          //Campo Origem
            "ZZD_DESTIP",;          //Campo Destino
            "ZZC->ZZC_DESCR",;      //Regra de Preenchimento
            .T.,;                   //Irá Posicionar?
            "ZZC",;                 //Alias de Posicioamento
            1,;                     //Índice de Posicionamento
            'xFilial("ZZC")+M->ZZD_IDTIPO',; //Chave de Posicionamento
            nil,;                   //Condição para execução do gatilho
            "01",;                  //Sequência do gatilho
        );
    )

    //Percorrendo os gatilhos e adicionando na Struct
    For nAtual := 1 to Len(aGatilhos)
        oStruct:AddTrigger(;
            aGatilhos[nAtual][01],; //Campo Origem
            aGatilhos[nAtual][02],; //Campo Destino
            aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
            aGatilhos[nAtual][04],; //Bloco de código de execução do gatilho
        )
    Next


    oModel := MPFormModel():New('zHP004M',bPre,bPos,bCommit,bCancel)
    oModel:AddFields('ZZDMASTER', /*cOwner*/, oStruct)
    oModel:SetDescripition('Cadastro de Categoria - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZDMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})
return oModel

static function ViewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP004')
    local oView 

    //Adicionando os grupos
    oStruct:AddGroup('GRUPO_01', 'Dados do Tipo do Chamado',         '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_02', 'Dados da Categoria do Chamado',    '', 1) //1-Janela, 2-Separador por Linha

    //Adicionando os campos aos grupos
    oStruct:SetProperty('ZZD_IDTIPO',MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')
    oStruct:SetProperty('ZZD_DESTIP',MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')

    oStruct:SetProperty('ZZD_ID',    MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZD_DESCR', MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZD_ATIVO', MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')

    //----------------------------------------
    // 1-Configuracao da Consulta Padrao 
    //----------------------------------------
    //oStruct:SetProperty('ZZD_IDTIPO', MVC_VIEW_LOOKUP, 'ZZC') //ID Tipo de Chamado

    //----------------------------------------
    // 2-Configuracao do ComboBox 
    //----------------------------------------
    //oStruct:SetProperty('ZZD_ATIVO', MVC_VIEW_COMBOBOX, {"1=Ativo","2=Inativo"})


    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZD', oStruct, 'ZZDMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZD','TELA')
return oView
