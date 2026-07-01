#include 'totvs.ch'
#include 'topConn.ch'
#include 'FWMVCDef.ch'

static cAliasMVC := 'ZZA'
static cTitulo   := 'Cadastro de Departamento - Projeto HelpDesk'


/*/{Protheus.doc} zHP001
Cadastro de Departamentos em MVC Modelo 1
@type user function
@author Luis Felipe Oliveira
@since 25/03/2026
@version 1.0
/*/

user function zHP001()
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
	oBrowse:AddLegend( "ZZA_ATIVO == '1' ", "GREEN",   "Ativo"  )
	oBrowse:AddLegend( "ZZA_ATIVO == '2' ", "RED",     "Inativo")

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP001" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP001" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP001" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP001" OPERATION 5 ACCESS 0

return aRotina

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
    //oStruct:SetProperty('ZZA_ID',     MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GETSXENUM("ZZA","ZZA_ID")' ) ) //ID Departamento
    //oStruct:SetProperty('ZZA_ATIVO',  MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ) ) //1-Ativo/2-Inativo

    //----------------------------------------
    // 2-Configuracao do Campo Obrigatorio 
    //----------------------------------------
    //oStruct:SetProperty('ZZA_DESCR',  MODEL_FIELD_OBRIGAT, .T. ) //Descricao Departamento
    //oStruct:SetProperty('ZZA_ATIVO',  MODEL_FIELD_OBRIGAT, .T. ) //Descricao Departamento

    //----------------------------------------
    // 3-Configuracao de Validacao do Campo 
    //----------------------------------------
    //oStruct:SetProperty('ZZA_DESCR',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistChav("ZZA", FWFldGet("M->ZZA_DESCR"),2)' ) ) //Descricao do Departamento, valida se ja existe a descricao cadastrada.

    //Instanciando o modelo
    oModel := MPFormModel():New('zHP001M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZAMASTER',/*cOwner*/,oStruct)
    oModel:SetDescripition('Cadastro de Departamento Projeto HelpDesk - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZAMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})

return oModel

static function viewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP001')
    local oView

    //----------------------------------------
    // 1-Configuracao do ComboBox 
    //----------------------------------------
    //oStruct:SetProperty('ZZA_ATIVO',  MVC_VIEW_COMBOBOX, {"1=Ativo","2=Inativo"})


    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZA',oStruct,'ZZAMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZA','TELA')
return oView

