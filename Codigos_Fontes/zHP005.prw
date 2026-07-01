#include 'totvs.ch'
#include 'FWMVCDef.ch'
#include 'TopConn.ch'

//Variaveis estaticas
static cAliasMVC := 'ZZE'
static cTitulo   := 'Amarração de Categoria x SubCategoria - Projeto HelpDesk'


/*/{Protheus.doc} zHP005
Cadastro de Amarração de Categoria de Chamado x SubCategoria - Projeto HelpDesk em MVC Modelo 1 - Tabela ZZE
@type user function
@author Luis Felipe Oliveira
@since 05/05/2026
@version 1.0

Regra de Negocios
1) Deixar os campos: ID, IDCAT, Descricao e Ativo, como obrigatorios;
2) Criar consulta padrao para o campo IDCAT na tabela ZZE para retornar o ID da Categoria do Chamado;
3) Validar se o conteudo do IDCAT digitado existe na tabela ZZD, se não exister nao deixar cadastrar;
4) Criar gatilho para que ao preencher o campo IDCAT o conteudo do campo Descricao da Categoria seja preenchido com a descricao;
5) Validar se o conteudo digitado no campo ID jah existe no cadastrada, se sim nao deicar cadastrar;
6) Criar ComboBox para o campo Ativo com as opcoes: 1-Ativo e 2-Inativo;
7) Criar inicializador Padrao para o campo Ativo iniciar igual a 1-Ativo.

/*/
user function zHP005()
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
    oBrowse:AddLegend("ZZE_ATIVO=='1'", "GREEN", "Ativo"  )
    oBrowse:AddLegend("ZZE_ATIVO=='2'", "RED",   "Inativo")

    //Ativando o Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP005" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP005" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP005" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP005" OPERATION 5 ACCESS 0
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
    //oStruct:SetProperty('ZZE_ATIVO',     MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ) ) //1-Ativo/2-Inativo

    //----------------------------------------
    // 2-Configuracao do Campo Obrigatorio 
    //----------------------------------------
    //oStruct:SetProperty('ZZE_IDCAT',  MODEL_FIELD_OBRIGAT, .T. ) //ID Categoria do Chamado
    //oStruct:SetProperty('ZZE_ID',     MODEL_FIELD_OBRIGAT, .T. ) //ID Subcategoria do Chamado
    //oStruct:SetProperty('ZZE_DESCR',  MODEL_FIELD_OBRIGAT, .T. ) //Descricao da Subcategoria do Chamado
    //oStruct:SetProperty('ZZE_ATIVO',  MODEL_FIELD_OBRIGAT, .T. ) //Ativo

    //----------------------------------------
    // 3-Configuracao de Validacao do Campo 
    //----------------------------------------
    //oStruct:SetProperty('ZZE_IDCAT',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCPO("ZZD",FwFldGet("ZZE_IDCAT"), 2)' ) ) //ID Categoria, valida se ja existe usuario cadastrado vinculado a esse ID.
    //oStruct:SetProperty('ZZE_ID',     MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistChav("ZZE",FwFldGet("ZZE_ID"),2)'    ) ) //ID Subcategoria, valida se ja existe usuario cadastrado vinculado a esse ID.

    //----------------------------------------
    // 4-Configuracao de Gatilho 
    //----------------------------------------
    
    //Adicionando um gatilho do ZZE_IDCAT (ID Categoria) para preencher o campo ZZE_DESCAT (Descricao Categoria)
    aAdd(aGatilhos, ;
        FwStruTrigger(;
            "ZZE_IDCAT",;         //Campo Origem
            "ZZE_DESCAT"  ,;      //Campo Destino
            "ZZD->ZZD_DESCR",;    //Regra de Preenchimento
            .T.,;                 //Irá Posicionar
            "ZZD",;               //Alias do Posicionamento
            2,;                   //Indice do Posicionamento
            'xFilial("ZZD")+M->ZZE_IDCAT',; //Chave de Posicionamento
            nil,;                 //Condição para execução do gatilho
            "01",;                //Sequência do gatilho
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

    oModel := MPFormModel():New('zHP005M',bPre,bPos,bCommit,bCancel)
    oModel:AddFields('ZZEMASTER', /*cOwner*/, oStruct)
    oModel:SetDescripition('Cadastro de Categoria x SubCategoria - Projeto HelpDesk - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZEMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})
return oModel

static function ViewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP005')
    local oView 

    //Adicionando os grupos
    oStruct:AddGroup('GRUPO_01', 'Dados da Categoria do Chamado',         '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_02', 'Dados da Subcategoria do Chamado',      '', 1) //1-Janela, 2-Separador por Linha

    //Adicionando os campos aos grupos
    oStruct:SetProperty('ZZE_IDCAT', MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')
    oStruct:SetProperty('ZZE_DESCAT',MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')

    oStruct:SetProperty('ZZE_ID',    MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZE_DESCR', MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZE_ATIVO', MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')

    //----------------------------------------
    // 1-Configuracao da Consulta Padrao 
    //----------------------------------------
    //oStruct:SetProperty('ZZE_IDCAT', MVC_VIEW_LOOKUP, 'ZZD') //ID Categoria

    //----------------------------------------
    // 2-Configuracao do ComboBox 
    //----------------------------------------
    //oStruct:SetProperty('ZZE_ATIVO', MVC_VIEW_COMBOBOX, {"1=Ativo","2=Inativo"})

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZE', oStruct, 'ZZEMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZE','TELA')
return oView
