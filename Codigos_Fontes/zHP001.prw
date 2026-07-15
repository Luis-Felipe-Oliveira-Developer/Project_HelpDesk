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

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zHP001
@author Luis Felipe Oliveira
@since 25/03/2026
@version 1.0
@type function
/*/

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP001" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP001" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP001" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP001" OPERATION 5 ACCESS 0

return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zHP001
@author Luis Felipe Oliveira
@since 25/03/2026
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

    //Instanciando o modelo
    oModel := MPFormModel():New('zHP001M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZAMASTER',/*cOwner*/,oStruct)
    oModel:SetDescripition('Cadastro de Departamento Projeto HelpDesk - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZAMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})

return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zHP001
@author Luis Felipe Oliveira
@since 25/03/2026
@version 1.0
@type function
/*/

static function viewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP001')
    local oView

    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZA',oStruct,'ZZAMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZA','TELA')
return oView

