#include 'totvs.ch'
#include 'topConn.ch'
#include 'FWMVCDef.ch'

static cTabPai   := 'ZZF'
static cTabFilho := 'ZZG'
static cTitulo   := 'Amarracoes Grupo SLA x Prioridade x Hora - Projeto HelpDesk'


/*/{Protheus.doc} zHP005
Amarracoes Grupo SLA x Prioridade x Hora - Projeto HelpDesk em MVC Modelo 2
@type user function
@author Luis Felipe Oliveira
@since 29/04/2026
@version 1.0
/*/

user function zHP005()
    local aArea := FwGetArea()
    local oBrowse := Nil
    private aRotina := {}

    //Definindo o Menu
    aRotina := MenuDef()

    //Definindo o Browse
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias(cTabPai)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zHP005
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP005" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP005" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP005" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP005" OPERATION 5 ACCESS 0

return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zHP005
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function ModelDef()
    local oStruPai   := FWFormStruct(1, cTabPai)
    local oStruFilho := FWFormStruct(1, cTabFilho)
    local aRelFilho  := {}
    local oModel
    local bPre      := nil
    local bPos      := nil
    local bCommit   := nil
    local bCancel   := nil

    //-----------------------------------------
    // Retira Campo obrigatorio
    //-----------------------------------------
    oStruFilho:SetProperty('ZZG_IDGRUP',  MODEL_FIELD_OBRIGAT, .F. ) //ID Grupo SLA

    //Instanciando o modelo
    oModel := MPFormModel():New('zHP005M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZFMASTER',/*cOwner*/,oStruPai)
    oModel:AddGrid('ZZGDETAIL','ZZFMASTER',oStruFilho,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:SetPrimaryKey({})

    //Fazendo o relacionamento (Pai e Filho)
    aAdd(aRelFilho, {"ZZG_FILIAL", "FWxFilial('ZZG')"})
    aAdd(aRelFilho, {"ZZG_IDGRUP", "ZZF_ID"})
    oModel:SetRelation("ZZGDETAIL", aRelFilho, ZZG->(IndexKey(1)))

return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zHP005
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function viewDef()
    local oModel     := FWLoadModel('zHP005')
    local oStruPai   := FWFormStruct(2,cTabPai)
    local oStruFilho := FWFormStruct(2,cTabFilho)
    local oView

    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZF', oStruPai,  'ZZFMASTER')
    oView:AddGrid('VIEW_ZZG', oStruFilho, 'ZZGDETAIL')

    //Partes da tela
    oView:CreateHorizontalBox('CABEC_PAI',   30)
    oView:CreateHorizontalBox('CABEC_FILHO', 70)
    oView:SetOwnerView('VIEW_ZZF','CABEC_PAI'  )
    oView:SetOwnerView('VIEW_ZZG','CABEC_FILHO')

    //Titulos
    oView:EnableTitleView("VIEW_ZZF", "Informações do Grupo SLA")
    oView:EnableTitleView("VIEW_ZZG", "Definições de Prioridade e Horas de SLA")

    //Removendo campos
    oStruFilho:RemoveField("ZZG_IDGRUP")

    //Adicionando campo incremental na grid
    //Este comando fará que quando for adicionado um novo item (seta para baixo na grid) seja somado +1 ao número do item.
    oView:AddIncrementField("VIEW_ZZG", "ZZG_ITEM")

return oView

/*-------------------------------------------------------------------*
 | Funcoes Customizadas                                             |
 *-------------------------------------------------------------------*/

/*/{Protheus.doc} zListPri()
Retorna a lista de opcoes de Prioridades para o campo ZZG_PRIORI.
@type user function
@author Luis Felipe Oliveira
@since 13/07/2026
@return cRet, Caractere, Retorna a lista de opcoes de Prioridades.
https://tdn.totvs.com/display/public/PROT/ADV0069_FUN_CAMPOS_COM_LISTA_OPCOES
/*/
user function zListPri()
    private cLista := ""

    cLista := "001BXA=Prioridade Baixa;" +;
              "002MED=Prioridade Media;" +;
              "003ALT=Prioridade Alta;" +;
              "004CRI=Prioridade Critica;" +;
              "005PRJ=Prioridade Projeto" 

    //Se a chamada da funcao nao estiver sendo feita a partir da rotina da Amarracao Grupo x Prioridade x Hora SLA 
    //nao apresente o restante das opcoes.
    if FWIsInCallStack("U_zHP005") 
        cLista += ";" + "006PBX=1º Atendimento/Prioridade Baixa;" +;
                        "007PMD=1º Atendimento/Prioridade Media;" +;
                        "008PAL=1º Atendimento/Prioridade Alta;" +;
                        "009PCR=1º Atendimento/Prioridade Critica;" +;
                        "010PPJ=1º Atendimento/Projeto"
    endif

return cLista
