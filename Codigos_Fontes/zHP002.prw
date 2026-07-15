#include 'totvs.ch'
#include 'FWMVCDef.ch'

static cAliasMVC := 'ZZB'
static cTitulo   := 'Cadastro de Usuario - Projeto HelpDesk'

/*/{Protheus.doc} zHP002
Cadastro de Usuario em MVC Modelo 1
@type user function
@author Luis Felipe Oliveira
@since 30/04/2026
@version 1.0

Regra de Negocios - Cadastro de Usuario HelpDesk
    1) Preencher automaticamente a numeracao do campo "ID HelpDesk";

    2) Ao preencher o campo "ID Protheus" a rotina ira validar se jah existe cadastro;

    3) Ao preencher o campo "ID Protheus" a rotina ira consultar a tabela SYS_USR e retornar as informaçoes de: 
    Usuário, Nome Completo e e-mail, e gatilhar essas nos respectivos campos de Usuario, Nome, e-mail;

    4) Habilitar o campo "Nivel" para preenchimento somente se o campo "Tipo Usuario" estiver preenchido diferente 
    de "1-Solicitante";	

    5) Criar gatilho do campo "Tipo Usuario" para preencher o conteúdo do campo "Nivel" para vazio, quando o o Tipo 
    for igual '1-Solicitante';

    6) Ao preencher o campo "ID Depto" posicionar na tabela ZZA, retornar a decricao do departamento e gatilhar no 
    campo "Departamento".
/*/

user function zHP002()
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
	oBrowse:AddLegend( "ZZB_ATIVO == '1' ", "GREEN",   "Ativo"  )
	oBrowse:AddLegend( "ZZB_ATIVO == '2' ", "RED",     "Inativo")

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao zHP002
@author Luis Felipe Oliveira
@since 30/04/2026
@version 1.0
@type function
/*/

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP002" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP002" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP002" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP002" OPERATION 5 ACCESS 0

return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao zHP001
@author Luis Felipe Oliveira
@since 30/04/2026
@version 1.0
@type function
/*/

static function ModelDef()
    local oStruct   := FWFormStruct(1, cAliasMVC)
    local oModel
    local bPre      := nil
    local bPos      := { ||u_zHp2bPos() }
    local bCommit   := nil
    local bCancel   := nil

    //Instanciando o modelo
    oModel := MPFormModel():New('zHP002M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZBMASTER',/*cOwner*/,oStruct)
    oModel:SetDescripition('Dados de Usuario - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZBMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})

return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao zHP001
@author Luis Felipe Oliveira
@since 30/04/2026
@version 1.0
@type function
/*/

static function viewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP002')
    local oView

    //Adicionando os grupos
    oStruct:AddGroup('GRUPO_01', 'Dados Protheus',         '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_02', 'Dados HelpDesk',         '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_03', 'Dados Departamento',     '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_04', 'Dados e-Mail',           '', 1) //1-Janela, 2-Separador por Linha

    //Adicionando os campos aos grupos
    oStruct:SetProperty('ZZB_IDPROT', MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')
    oStruct:SetProperty('ZZB_USERPT', MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')

    oStruct:SetProperty('ZZB_ID',     MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_NOME',   MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_TIPO',   MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_NIVEL',  MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_ATIVO',  MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')

    oStruct:SetProperty('ZZB_IDDPTO', MVC_VIEW_GROUP_NUMBER, 'GRUPO_03')
    oStruct:SetProperty('ZZB_NOMDEP', MVC_VIEW_GROUP_NUMBER, 'GRUPO_03')

    oStruct:SetProperty('ZZB_EMAIL',  MVC_VIEW_GROUP_NUMBER, 'GRUPO_04')

    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('VIEW_ZZB',oStruct,'ZZBMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_ZZB','TELA')
return oView


/*/{Protheus.doc} Hp02Gat1()
Gatilho para preencher o campo "Nivel" igual a branco quando o campo "Tipo" for diferente de Solicitante
@type user function
@author Luis Felipe Oliveira
@since 23/06/2026
@version version
@return cRetorno, Caractere, Retorna vazio se o Tipo do cadastro for Solicitante.
/*/
user function Hp02Gat1()
	local aArea     := FwGetArea()
	local cOpcao    := ""
    local cRetorno  := ""
	local oModelPad := Nil
	local oModelZZB := Nil

	//Instancia o Modelo Ativo
	oModelPad := FwModelActive()

	if oModelPad <> Nil
		//Seta o componente do Modelo no objeto
		oModelZZB := oModelPad:GetModel('ZZBMASTER')
		
		//Pega o valor do conteudo do campo
		cOpcao := oModelZZB:GetValue("ZZB_TIPO")

		//Se o conteudo for diferente de 1-Solicitante, deixa o conteudo campo Nivel vazio e da uma atualizada na tela. 
		if cOpcao <> "1"
            cRetorno := "1" 
		endif 	
	
    endif
	
    FwRestArea(aArea)
return cRetorno


/*/{Protheus.doc} zHp2bPos()
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@type function
@author Luis Felipe Oliveira
@since 07/03/2026
@version 1.0
/*/

User Function zHp2bPos()
    local oModelPad := FWModelActive()
    local cTipoUsr := oModelPad:GetValue('ZZBMASTER', 'ZZB_TIPO')
    local cNivel := oModelPad:GetValue('ZZBMASTER', 'ZZB_NIVEL')
    local lRet    := .T.

    //Se o campo Tipo de usuário estiver preenchido diferente de 1 = Solicitante, eh obrigatorio o preencher o campo.
    if  cTipoUsr <> '1' .and. empty(cNivel)
        Help(,, "Help", , "Campo Nível está sem preenchimento!", 1, 0, , , , , , {"Quando o campo Tipo é preenchido diferente de 1-Solicitante, é obrigatório preencher o campo Nível."})
        lRet := .F.
    endif
Return lRet
