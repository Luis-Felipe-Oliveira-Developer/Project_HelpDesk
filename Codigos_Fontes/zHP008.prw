#include 'totvs.ch'
#include 'FWMVCDef.ch'

//Variaveis estaticas 
static cTitulo   := 'Amarração de Tipos de Chamado x Categoria x Subcategoria - Projeto HelpDesk'
static cTabPai   := "ZZC"
static cTabFilho := "ZZD"
static cTabNeto  := "ZZE"


/*/{Protheus.doc} zHP008
Cadastro de Tipo de Chamado x Categoria x SubCategoria em MVC Modelo X
@type user function
@author Luis Felipe Oliveira
@since 04/05/2026
@version 1.0
/*/

user function zHP008()
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

    //Adicionando as legendas
	oBrowse:AddLegend( "ZZC_ATIVO == '1' ", "GREEN",   "Ativo"  )
	oBrowse:AddLegend( "ZZC_ATIVO == '2' ", "RED",     "Inativo")

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zHP008
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP008" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP008" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP008" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP008" OPERATION 5 ACCESS 0

return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zHP008
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/

static function ModelDef()
    local oStruPai      := FWFormStruct(1, cTabPai)
    local oStruFilho    := FWFormStruct(1, cTabFilho)
    local oStruNeto     := FWFormStruct(1, cTabNeto)
    local aRelFilho := {}
    local aRelNeto  := {}
    local oModel
    //Cabecalho - Variaveis de Validacao (MASTER)
    local bPre      := nil
    local bPos      := nil
    local bCommit   := nil
    local bCancel   := nil
    //Grid - Variaveis de Validacao (DETAIL)
    local bLinePost1 :=  {|oMdl| u_bLinPZZD(oModel)}
    local bLinePost2 :=  {|oMdl| u_bLinPZZE(oModel)}

    //Instanciando o modelo
    oModel := MPFormModel():New('zHP008M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZCMASTER',/*cOwner*/,oStruPai)
    oModel:AddGrid('ZZDDETAIL','ZZCMASTER',oStruFilho,/*bLinePre*/,bLinePost1,/*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:AddGrid('ZZEDETAIL','ZZDDETAIL',oStruNeto, /*bLinePre*/,bLinePost2,/*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:SetPrimaryKey({})

    //Fazendo o relacionamento (Pai e Filho)
    oStruFilho:SetProperty('ZZD_DESTIP', MODEL_FIELD_INIT, {|| ''}) //Retira o inicializador Padrão
    oStruFilho:SetProperty("ZZD_ID",     MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZD_ID
    oStruFilho:SetProperty("ZZD_DESCR",  MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZD_DESCR
    oStruFilho:SetProperty("ZZD_IDTIPO", MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZD_IDTIPO
    oStruFilho:SetProperty("ZZD_ATIVO",  MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZD_DESTIP
    aAdd(aRelFilho, {"ZZD_FILIAL", "FWxFilial('ZZD')"})
    aAdd(aRelFilho, {"ZZD_IDTIPO", "ZZC_ID"})
    oModel:SetRelation("ZZDDETAIL", aRelFilho, ZZD->(IndexKey(1)) )

    //Fazendo o relacionamento (Filho e Neto)
    oStruNeto:SetProperty('ZZE_DESCAT', MODEL_FIELD_INIT, {|| ''}) //Retira o inicializador Padrão
    oStruNeto:SetProperty("ZZE_ID", MODEL_FIELD_OBRIGAT, .F.)    //Retira a obrigatoriedade do preenchimento do campo ZZE_ID
    oStruNeto:SetProperty("ZZE_DESCR", MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZE_DESCR
    oStruNeto:SetProperty("ZZE_IDCAT", MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZE_IDCAT
    oStruNeto:SetProperty("ZZE_ATIVO", MODEL_FIELD_OBRIGAT, .F.) //Retira a obrigatoriedade do preenchimento do campo ZZE_DESCAT
    aAdd(aRelNeto, {"ZZE_FILIAL", "FWxFilial('ZZE')"})
    aAdd(aRelNeto, {"ZZE_IDCAT", "ZZD_ID"})
    oModel:SetRelation("ZZEDETAIL", aRelNeto, ZZE->(IndexKey(1)) )

    //Definindo campos unicos da linha
    oModel:GetModel("ZZDDETAIL"):SetUniqueLine({'ZZD_ID'   })
    oModel:GetModel("ZZEDETAIL"):SetUniqueLine({'ZZE_ID'   })

    //Definindo como opcional o preenchimento da Grid
    oModel:GetModel("ZZDDETAIL"):SetOptional(.T.)
    oModel:GetModel("ZZEDETAIL"):SetOptional(.T.)

    //Define que o cabecalho nao sera editavel. Ele ficara disponivel apenas para visualizacao
    oModel:GetModel("ZZCMASTER"):SetOnlyView(.T.)     
return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zMVC03
@author Luis Felipe Oliveira
@since 07/05/2026
@version 1.0
@type function
/*/
static function ViewDef()
    local oModel     := FWLoadModel('zHP008')
    local oStruPai   := FWFormStruct(2,cTabPai)
    local oStruFilho := FWFormStruct(2,cTabFilho)
    local oStruNeto  := FWFormStruct(2,cTabNeto)
    local oView

    //Cria a visualizacao do cadastro
    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZC', oStruPai,   'ZZCMASTER')
    oView:AddGrid('VIEW_ZZD',  oStruFilho, 'ZZDDETAIL')
    oView:AddGrid('VIEW_ZZE',  oStruNeto,  'ZZEDETAIL')

    //Partes da Tela
    oView:CreateHorizontalBox('CABEC_PAI',   20)
    oView:CreateHorizontalBox('CABEC_FILHO', 30)
    oView:CreateHorizontalBox('CABEC_NETO',  50)
    oView:SetOwnerView('VIEW_ZZC','CABEC_PAI'  )
    oView:SetOwnerView('VIEW_ZZD','CABEC_FILHO')
    oView:SetOwnerView('VIEW_ZZE','CABEC_NETO' )    

    //Titulos
    oView:EnableTitleView("VIEW_ZZC", "Tipos de Chamado")
    oView:EnableTitleView("VIEW_ZZD", "Categorias do Chamado")
    oView:EnableTitleView("VIEW_ZZE", "SubCategorias do Chamado")

    //Removendo campos
    oStruFilho:RemoveField("ZZD_IDTIPO") //ID Tipo de Chamado
    oStruFilho:RemoveField("ZZD_DESTIP") //Descricao do Tipo
    oStruNeto:RemoveField("ZZE_IDCAT")   //ID Categoria 
    oStruNeto:RemoveField("ZZE_DESCAT")  //Descricao Categoria

    //Adicionando campo incremental na grid
    //Este comando farah com que quando for adicionado um novo item (seta para baixo) seja somado +1 ao numero do item
    oView:AddIncrementField("VIEW_ZZD", "ZZD_ITEM")
    oView:AddIncrementField("VIEW_ZZE", "ZZE_ITEM")
return oView

/*/{Protheus.doc} bLinPZZD
Função chamada ao trocar de linha na grid (bloco bLinePos)
@type function
@author Luis Felipe Oliveira
@since 26/06/2026
@version 1.0
/*/

user function bLinPZZD(oModel)
    local oModelZZD  := oModel:GetModel("ZZDDETAIL")
    local nOperation := oModel:GetOperation()
    local lRet       := .T.
	local cID        := oModelZZD:GetValue("ZZD_ID"   )
	local cDescricao := oModelZZD:GetValue("ZZD_DESCR")
	local cAtivo     := oModelZZD:GetValue("ZZD_ATIVO")
	
    //Se não for exclusão e nem visualização
    if nOperation != MODEL_OPERATION_DELETE .And. nOperation != MODEL_OPERATION_VIEW
	
		//Se algum dos campos na relacao abaixo nao for preenchido, retorna falso.
		if empty(cID) .or. empty(cDescricao) .or. empty(cAtivo)  
            Help(,, "Help", , "Campo obrigatório não preenchido!", 1, 0, , , , , , {"Verifique se há algum campo na linha que não foi preenchido."})
            lRet := .F.		
		endif
	endif

return lRet

/*/{Protheus.doc} bLinPZZE
Função chamada ao trocar de linha na grid (bloco bLinePos)
@type function
@author Luis Felipe Oliveira
@since 26/06/2026
@version 1.0
/*/

user function bLinPZZE(oModel)
    local oModelZZE  := oModel:GetModel("ZZEDETAIL")
    local nOperation := oModel:GetOperation()
    local lRet       := .T.
	local cID        := oModelZZE:GetValue("ZZE_ID"   )
	local cDescricao := oModelZZE:GetValue("ZZE_DESCR")
	local cAtivo     := oModelZZE:GetValue("ZZE_ATIVO")
	
    //Se não for exclusão e nem visualização
    if nOperation != MODEL_OPERATION_DELETE .And. nOperation != MODEL_OPERATION_VIEW
	
		//Se algum dos campos na relacao abaixo nao for preenchido, retorna falso.
		if empty(cID) .or. empty(cDescricao) .or. empty(cAtivo)  
            Help(,, "Help", , "Campo obrigatório não preenchido!", 1, 0, , , , , , {"Verifique se há algum campo na linha que não foi preenchido."})
            lRet := .F.		
		endif
	endif

return lRet
