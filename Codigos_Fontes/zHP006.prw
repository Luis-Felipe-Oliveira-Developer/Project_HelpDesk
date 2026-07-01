#include 'totvs.ch'
#include 'FWMVCDef.ch'

//Variaveis estaticas
static cAliasMVC := 'ZZF'
static cTitulo   := 'Cadastro Horas de SLA - Projeto HelpDesk'


/*/{Protheus.doc} zHP006
Cadastro Horas de SLA - Projeto HelpDesk em MVC Modelo 1 - Tabela ZZF
@type user function
@author Luis Felipe Oliveira
@since 05/05/2026
@version 1.0
/*/
user function zHP006()
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

    //Ativando o Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP006" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP006" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP006" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP006" OPERATION 5 ACCESS 0
return aRotina

static function ModelDef()
    local oStruct   := FWFormStruct(1,cAliasMVC)
    local oModel
    local bPre      := nil
    local bPos      := nil
    local bCommit   := nil
    local bCancel   := nil

    oModel := MPFormModel():New('zHP006M',bPre,bPos,bCommit,bCancel)
    oModel:AddFields('ZZFMASTER', /*cOwner*/, oStruct)
    oModel:SetDescripition('Cadastro de Horas de SLA - Projeto HelpDesk - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZFMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})
return oModel

static function ViewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP006')
    local oView 

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZF', oStruct, 'ZZFMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZF','TELA')
return oView
