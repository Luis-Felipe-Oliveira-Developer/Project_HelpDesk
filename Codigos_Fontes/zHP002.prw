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

    //Ativando a Browse
    oBrowse:Activate()

    FwRestArea(aArea)
return

static function MenuDef()
    local aRotina := {}

    //Adicionando opcoes do Menu
    ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.zHP002" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"       ACTION "VIEWDEF.zHP002" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"       ACTION "VIEWDEF.zHP002" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"       ACTION "VIEWDEF.zHP002" OPERATION 5 ACCESS 0

return aRotina

static function ModelDef()
    local oStruct   := FWFormStruct(1, cAliasMVC)
    local oModel
    local bPre      := nil
    local bPos      := { ||u_zHp2bPos() }
    local bCommit   := nil
    local bCancel   := nil
    local aGatilhos := {} 
    local nAtual    := 0

    //----------------------------------------
    // 1-Configuracao do Inicializador Padrao 
    //----------------------------------------
    //oStruct:SetProperty('ZZB_ID',     MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GETSXENUM("ZZB","ZZB_ID")' ) ) //ID Protheus
    //oStruct:SetProperty('ZZB_USERPT', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI, "", USRRETNAME(FWFLDGET("ZZB_IDPROT")) )'  ) ) //Usuario Protheus
    //oStruct:SetProperty('ZZB_TIPO',   MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ) ) //Tipo de usuario 1-Solicitante/2-Atendente
    //oStruct:SetProperty('ZZB_ATIVO',  MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '1' ) ) //Usuario esta ativo? 1-Ativo/2-Inativo

    //----------------------------------------
    // 2-Configuracao do Campo Obrigatorio 
    //----------------------------------------
    //oStruct:SetProperty('ZZB_IDPROT',  MODEL_FIELD_OBRIGAT, .T. ) //ID Protheus
    //oStruct:SetProperty('ZZB_IDDPTO',  MODEL_FIELD_OBRIGAT, .T. ) //ID Departamento
    //oStruct:SetProperty('ZZB_TIPO',    MODEL_FIELD_OBRIGAT, .T. ) //Tipo do Usuario
    //oStruct:SetProperty('ZZB_ATIVO',   MODEL_FIELD_OBRIGAT, .T. ) //Usuario Ativo    

    //----------------------------------------
    // 3-Configuracao do Modo de Edicao 
    //----------------------------------------
    //oStruct:SetProperty('ZZB_NIVEL', MODEL_FIELD_WHEN, { || fwfldget('ZZB_TIPO') <> '1' } ) //Nivel de Atendimento

    //----------------------------------------
    // 4-Configuracao de Validacao do Campo 
    //----------------------------------------
    //oStruct:SetProperty('ZZB_IDPROT',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistChav("ZZB", FWFldGet("M->ZZB_IDPROT"),2)' ) ) //ID Protheus, valida se ja existe usuario cadastrado vinculado a esse ID.

    //----------------------------------------
    // 5-Configuracao do Gatilho 
    //----------------------------------------
    aAdd(aGatilhos, ;
        FwStruTrigger(;
            "ZZB_IDPROT",;        //Campo Origem
            "ZZB_USERPT"  ,;      //Campo Destino
            'UsrRetName(FwFldGet("ZZB_IDPROT"))',;     //Regra de Preenchimento
            .F.,;                 //Irá Posicionar
            "",;                  //Alias do Posicionamento
            0,;                   //Indice do Posicionamento
            '',;                  //Chave de Posicionamento
            nil,;                 //Condição para execução do gatilho
            "01",;                //Sequência do gatilho
        );
    )

    //Adicionando Gatilho
    aAdd(aGatilhos, ;
        FwStruTrigger(;
            "ZZB_IDPROT",;        //Campo Origem
            "ZZB_NOME"  ,;        //Campo Destino
            'UsrFullName(FwFldGet("ZZB_IDPROT"))',;     //Regra de Preenchimento
            .F.,;                 //Irá Posicionar
            "",;                  //Alias do Posicionamento
            0,;                   //Indice do Posicionamento
            '',;                  //Chave de Posicionamento
            nil,;                 //Condição para execução do gatilho
            "02",;                //Sequência do gatilho
        );
    )

    //Adicionando Gatilho
    aAdd(aGatilhos, ;
        FwStruTrigger(;
            "ZZB_IDPROT",;        //Campo Origem
            "ZZB_EMAIL"  ,;       //Campo Destino
            'UsrRetMail(FwFldGet("ZZB_IDPROT"))',;     //Regra de Preenchimento
            .F.,;                 //Irá Posicionar
            "",;                  //Alias do Posicionamento
            0,;                   //Indice do Posicionamento
            '',;                  //Chave de Posicionamento
            nil,;                 //Condição para execução do gatilho
            "03",;                //Sequência do gatilho
        );
    )


    //Adicionando um gatilho do ZZB_IDDPTO (ID Departamento) para preencher o campo ZZB_NOMDEP (Descricao Departamento)
    aAdd(aGatilhos, ;
        FWStrutrigger(;
            "ZZB_IDDPTO",;          //Campo Origem
            "ZZB_NOMDEP",;          //Campo Destino
            "ZZA->ZZA_DESCR",;      //Regra de Preenchimento
            .T.,;                   //Irá Posicionar?
            "ZZA",;                 //Alias de Posicioamento
            1,;                     //Índice de Posicionamento
            'xFilial("ZZA")+M->ZZB_IDDPTO',; //Chave de Posicionamento
            nil,;                   //Condição para execução do gatilho
            "01",;                  //Sequência do gatilho
        );
    )

    //Adicionando um gatilho do ZZB_TIPO (Tipo de Cadastro) para preencher o campo ZZB_NIVEL (Nivel de Atendimento)
    aAdd(aGatilhos, ;
        FwStruTrigger(;
            "ZZB_TIPO",;          //Campo Origem
            "ZZB_NIVEL"  ,;       //Campo Destino
            "u_Hp02Gat1()",;      //Regra de Preenchimento
            .F.,;                 //Irá Posicionar
            "",;                  //Alias do Posicionamento
            0,;                   //Indice do Posicionamento
            '',;                  //Chave de Posicionamento
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


    //Instanciando o modelo
    oModel := MPFormModel():New('zHP002M', bPre, bPos, bCancel, bCommit)
    oModel:AddFields('ZZBMASTER',/*cOwner*/,oStruct)
    oModel:SetDescripition('Dados de Usuario - Tabela ' + cAliasMVC)
    oModel:GetModel('ZZBMASTER'):SetDescripition('Dados de - ' + cTitulo)
    oModel:SetPrimaryKey({})

return oModel

static function viewDef()
    local oStruct := FWFormStruct(2,cAliasMVC)
    local oModel  := FWLoadModel('zHP002')
    local oView

    //Adicionando os grupos
    oStruct:AddGroup('GRUPO_01', 'Dados Protheus',         '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_02', 'Dados HelpDesk',         '', 1) //1-Janela, 2-Separador por Linha
    oStruct:AddGroup('GRUPO_03', 'Dados Departamento',     '', 1) //1-Janela, 2-Separador por Linha

    //Adicionando os campos aos grupos
    oStruct:SetProperty('ZZB_IDPROT', MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')
    oStruct:SetProperty('ZZB_USERPT', MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')
    oStruct:SetProperty('ZZB_NOME',   MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')
    oStruct:SetProperty('ZZB_EMAIL',  MVC_VIEW_GROUP_NUMBER, 'GRUPO_01')

    oStruct:SetProperty('ZZB_ID',     MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_TIPO',   MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_NIVEL',  MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')
    oStruct:SetProperty('ZZB_ATIVO',  MVC_VIEW_GROUP_NUMBER, 'GRUPO_02')

    oStruct:SetProperty('ZZB_IDDPTO', MVC_VIEW_GROUP_NUMBER, 'GRUPO_03')
    oStruct:SetProperty('ZZB_NOMDEP', MVC_VIEW_GROUP_NUMBER, 'GRUPO_03')

    //----------------------------------------
    // 1-Configuracao da Consulta Padrao 
    //----------------------------------------
    //oStruct:SetProperty('ZZB_IDPROT', MVC_VIEW_LOOKUP, 'USR') //ID Protheus
    //oStruct:SetProperty('ZZB_IDDPTO', MVC_VIEW_LOOKUP, 'ZZA') //ID Departamento

    //----------------------------------------
    // 2-Configuracao do ComboBox 
    //----------------------------------------
    //oStruct:SetProperty('ZZB_TIPO',  MVC_VIEW_COMBOBOX, {"1=Solicitante","2=Atendente"})
    //oStruct:SetProperty('ZZB_NIVEL', MVC_VIEW_COMBOBOX, {"1=Baixa Complexidade","2=Media Complexidade","3=Alta Complexidade",""})
    //oStruct:SetProperty('ZZB_ATIVO', MVC_VIEW_COMBOBOX, {"1=Sim","2=Nao"})


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
