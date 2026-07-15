#include "totvs.ch"
#include "topconn.ch"

/*Classe para retornar informacoes referente ao usuario HelpDesk*/
class DadosUsrHD
	//declaracao de atributo ou propriedades
	data aInfoUsr
	data cIdProtheus
	data cIdHelpDesk
	data cNome
	data cIdDepto
	data cNomeDepto
	data cTipoUsr
	data cNivelAtd
	data cEmail 
	data lEhTecnico
	data cGrupoSLA

    //declaracao do metodo
	method new() constructor //metodo construtor da classe
	method GetIDHelpDesk() 	//Retorna o ID HelpDesk correspondente ao ID Protheus cadastrado na tabela ZZB
	method GetNomeUsr()		//Retorna o nome do usuario
	method GetIdDepto()		//Retorna o ID do Departamento
	method GetNomeDepto()   //Retorna o Nome do Departamento
	method GetTipoUsr()	    //Retorna o Tipo de Usuario
	method GetNivelAtd()    //Retorna o Nivel de Atendimento que o usuario do tipo Atendente pode atender
	method GetEmailUsr()    //Retorna o email do usuario
	method EhTecnico() 		//Retorna se o tipo do usuario eh perfil de atendimento
	method GetGrupoSLA()    //Retorna o Grupo SLA de Atendimento 
endclass

/*------------------*
 | Metodos          |
 *------------------*/

//metodo construtor da classe
method new(cIdProtheus) class DadosUsrHD
    //atribuicao de valor a propriedade
	::cIdProtheus := cIdProtheus
  	::aInfoUsr    := zDadosUsr(::cIdProtheus) 

	::cIdHelpDesk := ::aInfoUsr[1][1]
	::cNome		  := ::aInfoUsr[1][3]	
	::cIdDepto    := ::aInfoUsr[1][4]
	::cNomeDepto  := ::aInfoUsr[1][5]
	::cTipoUsr    := ::aInfoUsr[1][6]
	::cNivelAtd   := ::aInfoUsr[1][7]
	::cEmail      := ::aInfoUsr[1][8]
	::cGrupoSLA   := ::aInfoUsr[1][9]
	::lEhTecnico  := SubStr(::cTipoUsr,1,1) == "2" //1-Solicitante, 2-Atendente 
return Self

//Retorna o ID HelpDesk correspondente ao ID Protheus cadastrado na tabela ZZB
method GetIDHelpDesk() class DadosUsrHD
return ::cIdHelpDesk

//Retorna o nome do usuario
method GetNomeUsr() class DadosUsrHD
return ::cNome

//Retorna o ID do Departamento
method GetIdDepto() class DadosUsrHD
return ::cIdDepto

//Retorna o Nome do Departamento
method GetNomeDepto() class DadosUsrHD
return ::cNomeDepto

//Retorna o Tipo de Usuario
method GetTipoUsr() class DadosUsrHD
return ::cTipoUsr

//Retorna o Nivel de Atendimento que o usuario do tipo Atendente pode atender
method GetNivelAtd() class DadosUsrHD
return ::cNivelAtd

//Retorna o email do usuario
method GetEmailUsr() class DadosUsrHD
return ::cEmail

//Retorna se o tipo do usuario eh perfil de atendimento
method EhTecnico() class DadosUsrHD
return ::lEhTecnico

//Retorna o Grupo SLA de Atendimento
method GetGrupoSLA() class DadosUsrHD
return ::cGrupoSLA

/*-------------------*
 | Funcoes Estaticas |
 *-------------------*/

// funcao responsavel por retornar o array com as informacoes dos dados do usuario HelpDesk. 
static function zDadosUsr(cIdProt)
	local aArea 	:= FwGetArea()
	local aAreaZZB 	:= ZZB->(FwGetArea()) 
	local aRet 	  	:= {}
	local cQryZZB 	:= "" 
	
	//Chama funcao que retornarah a query
	cQryZZB := QryUsrHD(cIdProt)
	
	//Abre o alias em memoria
	TCQuery cQryZZB New Alias "QRY_ZZB"
	
	//Enquanto nao for final de arquivo
	while !(QRY_ZZB->(EoF()))
		aAdd(aRet, {;
		QRY_ZZB->ID_HELPDESK,;
		QRY_ZZB->ID_PROTHEUS,;
		QRY_ZZB->NOME,;
		QRY_ZZB->ID_DEPTO,;
		QRY_ZZB->DEPARTAMENTO,;
		QRY_ZZB->TIPO,;
		QRY_ZZB->NIVEL_ATEND,;
		QRY_ZZB->EMAIL,;
		QRY_ZZB->GRUPO_SLA;
		})

		QRY_ZZB->(DbSkip())
	enddo
	
	//Fecha o Alias
	QRY_ZZB->(DbCloseArea())

	FwRestArea(aAreaZZB)
	FwRestArea(aArea)
return aRet


/*Query zone*/

static function QryUsrHD(cIDProt)
	local cQuery := ""

	//Monta a query 	 
	cQuery := " SELECT " + CRLF 
	cQuery += "		ZZB.ZZB_ID AS [ID_HELPDESK], " + CRLF 
	cQuery += "		ZZB.ZZB_IDPROT AS [ID_PROTHEUS], " + CRLF 
	cQuery += "		ZZB.ZZB_NOME AS [NOME], " + CRLF 
	cQuery += "		ZZB.ZZB_IDDPTO AS [ID_DEPTO], " + CRLF 
	cQuery += "		ZZA.ZZA_DESCR  AS [DEPARTAMENTO], " + CRLF  
	cQuery += "		IIF(ZZB.ZZB_TIPO = '1', '1-SOLICITANTE', '2-ATENDENTE') AS [TIPO], " + CRLF 
	cQuery += "		CASE  " + CRLF 
	cQuery += "			WHEN ZZB.ZZB_NIVEL = '1' THEN 'BAIXA COMPLEXIDADE' " + CRLF 
	cQuery += "			WHEN ZZB.ZZB_NIVEL = '2' THEN 'MEDIA COMPLEXIDADE' " + CRLF 
	cQuery += "			WHEN ZZB.ZZB_NIVEL = '3' THEN 'ALTA COMPLEXIDADE' " + CRLF 
	cQuery += "			WHEN ZZB.ZZB_NIVEL = '4' THEN 'CRITICA COMPLEXIDADE' " + CRLF 
	cQuery += "			ELSE '' " + CRLF 
	cQuery += "		END AS [NIVEL_ATEND], " + CRLF 
	cQuery += "		ZZB.ZZB_EMAIL AS [EMAIL], " + CRLF
	cQuery += "		ZZA.ZZA_GRUPO  AS [GRUPO_SLA] " + CRLF 
	cQuery += "	FROM " + RetSqlName("ZZB") + " ZZB WITH(NOLOCK) " + CRLF
	cQuery += "	INNER JOIN " + RetSqlName("ZZA") + " ZZA WITH(NOLOCK) " + CRLF
	cQuery += "		ON  ZZA.ZZA_FILIAL = '" + FWxFilial("ZZA") + "' " + CRLF
	cQuery += "		AND ZZA.ZZA_ID = ZZB.ZZB_IDDPTO " + CRLF
	cQuery += "		AND ZZA.D_E_L_E_T_ = ZZB.D_E_L_E_T_ " + CRLF
	cQuery += "	WHERE ZZB.D_E_L_E_T_ = '' " + CRLF
	cQuery += "		AND ZZB.ZZB_FILIAL = '" + FWxFilial("ZZB") + "' " + CRLF
	cQuery += "		AND ZZB.ZZB_IDPROT = '" + cIDProt + "'" + CRLF 
return cQuery 


/*teste zone*/
user function zTst999()
	local oUsrHD     := Nil 
	local cIDHelpDsk := ""
	local cxNome     := ""
	local cIDDepto   := ""
	local cNomDepto  := ""
	local lEhTecnico := .F.
	
	oUsrHD := DadosUsrHD():New(RetCodUsr())
	
	//Retorna o Nome do usuario HelpDesk
	cxNome := oUsrHD:GetNomeUsr()
	
	//Retorna o ID do usuario HelpDesk
	cIDHelpDsk := oUsrHD:GetIDHelpDesk()
	
	//Retorna o ID do Departamento
	cIDDepto := oUsrHD:GetIdDepto()
	
	//Retorna o nome do Departamento
	cNomDepto := oUsrHD:GetNomeDepto()
	
	//Retorna se o perfil do usuario eh de atendente
	lEhTecnico := oUsrHD:EhTecnico()
	
	freeobj(oUsrHD)
return
