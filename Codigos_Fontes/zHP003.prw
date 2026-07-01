#include 'totvs.ch'
#include 'FWMVCDef.ch'

//Variaveis estáticas
static cAliasMVC := 'ZZC' 
static cTitulo   := 'Cadastro Tipos de Chamado - Projeto HelpDesk'

/*/{Protheus.doc} zHP003
Cadastro de SubCategoria em MVC Modelo 1
@type user function
@author Luis Felipe Oliveira
@since 04/05/2026
@version 1.0

Regra de Negocio
1) Deixar os campos ID, Descricao e Ativo como obrigatorios;
2) Validar se a ID digitada no momento da inclusao jah existe, se sim nao deixa incluir;
3) Criar combobox para o campo Ativo com as opcoes: 1-Ativo e 2-Inativo.

/*/

user function zHP003()
    local aArea := FwGetArea()
    local oBrowse := Nil
    private aRotina := {}

    //Definindo o Menu
    aRotina := MenuDef()

    //Definindo o Browse
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    //Adicionando as legendas
	oBrowse:AddLegend( "ZZC_ATIVO == '1' ", "GREEN",   "Ativo"  )
	oBrowse:AddLegend( "ZZC_ATIVO == '2' ", "RED",     "Inativo")

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zHP003
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP003" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP003" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP003" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP003" OPERATION 5 ACCESS 0

return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zHP003
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function ModelDef()
    local oStruct   := FWFormStruct(1, cAliasMVC)
    local oModel
    local bPre      := nil
    local bPos      := nil
    local bCommit   := nil
    local bCancel   := nil 

    //----------------------------------------
    // 1-Configuracao do Inicializador Padrao 
    //----------------------------------------
    //oStruct:SetProperty('ZZC_ATIVO',     MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ) ) //1-Ativo/2-Inativo

    //----------------------------------------
    // 2-Configuracao do Campo Obrigatorio 
    //----------------------------------------
    //oStruct:SetProperty('ZZC_ID',      MODEL_FIELD_OBRIGAT, .T. ) //ID Tipo Chamado
    //oStruct:SetProperty('ZZC_DESCR',   MODEL_FIELD_OBRIGAT, .T. ) //Descricao
    //oStruct:SetProperty('ZZC_ATIVO',   MODEL_FIELD_OBRIGAT, .T. ) //Ativo

    //----------------------------------------
    // 3-Configuracao de Validacao do Campo 
    //----------------------------------------
    //oStruct:SetProperty('ZZC_ID',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistChav("ZZC", FWFldGet("M->ZZC_ID"),1)' ) ) //ID , valida se ja existe um Tipo cadastrado vinculado a esse ID.


    //Instanciando o modelo
    oModel := MPFormModel():New('zHP003M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZCMASTER',/*cOwner*/,oStruct)
    oModel:SetDescripition('Cadastro de Tipo de Chamado - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZCMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zHP003
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/
static function ViewDef()
    local oModel     := FWLoadModel('zHP003')
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oView

    //----------------------------------------
    // 1-Configuracao do ComboBox 
    //----------------------------------------
    //oStruct:SetProperty('ZZC_ATIVO', MVC_VIEW_COMBOBOX, {"1=Ativo","2=Inativo"})


    //Cria a visualizacao do cadastro
    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZC', oStruct,   'ZZCMASTER')

    //Partes da Tela
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZC','TELA')
return oView
