#include 'totvs.ch'
#include 'topConn.ch'
#include 'FWMVCDef.ch'

static cAliasMVC := 'ZZG'
static cTitulo   := 'Definicao do SLA x Amarracoes - Projeto HelpDesk'


/*/{Protheus.doc} zHP007
Definicao do SLA x Amarracoes - Projeto HelpDesk em MVC Modelo 1
@type user function
@author Luis Felipe Oliveira
@since 29/04/2026
@version 1.0
/*/

user function zHP007()
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

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP007" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP007" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP007" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP007" OPERATION 5 ACCESS 0

return aRotina

static function ModelDef()
    local oStruct   := FWFormStruct(1, cAliasMVC)
    local oModel
    local bPre      := nil
    local bPos      := nil
    local bCommit   := nil
    local bCancel   := nil

    //Instanciando o modelo
    oModel := MPFormModel():New('zHP007M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZGMASTER',/*cOwner*/,oStruct)
    oModel:SetDescripition('Definicao do SLA x Amarracoes - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZGMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})

return oModel

static function viewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP007')
    local oView

    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZG',oStruct,'ZZGMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZG','TELA')
return oView

