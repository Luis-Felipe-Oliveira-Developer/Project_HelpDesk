#include "totvs.ch"

/*Classe para retornar informacoes referente ao usuario HelpDesk*/
class GetInfoUsuarioHD
	//declaracao de atributo ou propriedades
	data cIdProtheus
  	data cIDHelpDsk
	data cNomeUsr
	data cIDDepto
	data cNomDepto
	data lEhTecnico 
	
    //declaracao do metodo
	method new() constructor //metodo construtor da classe
	method IDUsrHD()   //Retorna o ID do usuario HelpDesk CodUsuario
	method FullName()  //Retorna o nome completo do usuario HelpDesk NomeUsuario
	method IDDepto()   //Retorna o ID do Departamento   CodDepartamento
	method NomeDepto() //Retorna o nome do Departamento NomeDepartamento
	method EhTecnico() //Retorna se o tipo do usuario eh perfil de atendimento 
endclass

/*Metodos*/

//metodo construtor da classe
method new(cIdProtheus) class GetInfoUsuarioHD
    //atribuicao de valor a propriedade
	::cIdProtheus := cIdProtheus
  	::cIDHelpDsk  := RetIDUsrHD(::cIdProtheus) 
	::cNomeUsr    := RetNomeHD(::cIdProtheus)
	::cIDDepto    := RetIDDepto(::cIDHelpDsk)
	::cNomDepto   := RetNomDpto(::cIDDepto)
	::lEhTecnico  := ChkTecnico(::cIDHelpDsk)
return Self


//Retorna o ID do usuario HelpDesk
method IDUsrHD() class GetInfoUsuarioHD
return ::cIDHelpDsk  


//Retorna o nome completo do usuario HelpDesk
method FullName() class GetInfoUsuarioHD
	//::cNomeUsr := RetNomeHD()
return  ::cNomeUsr


//Retorna o ID do Departamento
method IDDepto() class GetInfoUsuarioHD
	//::cIDDepto := RetIDDepto()
return ::cIDDepto


//Retorna o Nome do Departamento
method NomeDepto() class GetInfoUsuarioHD
	//::cNomDepto := RetNomDpto()
return ::cNomDepto

//Retorna se o tipo do usuario eh perfil de atendimento
method EhTecnico() class GetInfoUsuarioHD
return ::lEhTecnico


/*------------------*
 | Funcoes Staticas |
 *------------------*/
 
//Retorna o ID do usuario HelpDesk
static function RetIDUsrHD(cIdProtheus)
	local aArea := FwGetArea()
	local aAreaZZB := ZZB->(FwGetArea())
	local cIDUsrHD := ""

	cIDUsrHD := Posicione("ZZB", 2, FWxFilial("ZZB")+cIdProtheus, "ZZB_ID")

	RestArea(aAreaZZB)
	RestArea(aArea)
return cIDUsrHD


//Retorna o Nome completo do usuario HelpDesk
static function RetNomeHD(cIdProtheus)
	local aArea    := FwGetArea()
	local aAreaZZB := ZZB->(FwGetArea())
	local cxNome   := ""

	//cxNome := USRFULLNAME(POSICIONE("ZZB",1,FWxFilial("ZZB")+FWFLDGET("ZZH_IDSOL"), "ZZB_IDPROT"))
    cxNome := USRFULLNAME(cIdProtheus)

	RestArea(aAreaZZB)
	RestArea(aArea)
return cxNome


//Retorna o ID do Departamento
static function RetIDDepto(cIDHelpDsk)
	local aArea    := FwGetArea()
	local aAreaZZB := ZZB->(FwGetArea())
	local cIDDepto := ""
	
	//cIDDepto := POSICIONE("ZZB",1,FWXFILIAL("ZZB")+FWFLDGET("ZZH_IDSOL"),"ZZB_IDDPTO")
    cIDDepto := POSICIONE("ZZB",1,FWXFILIAL("ZZB")+cIDHelpDsk,"ZZB_IDDPTO")

	RestArea(aAreaZZB)
	RestArea(aArea)
return cIDDepto

//Retorna o ID do Departamento
static function RetNomDpto(cIDDepto)
	local aArea      := FwGetArea()
	local aAreaZZA   := ZZA->(FwGetArea())
	local cNomeDepto := ""

	//cNomeDepto := POSICIONE("ZZA",1,FWXFILIAL("ZZA")+FWFLDGET("ZZH_IDDEP"),"ZZA_DESCR")
    cNomeDepto := POSICIONE("ZZA",1,FWXFILIAL("ZZA")+cIDDepto,"ZZA_DESCR")

	RestArea(aAreaZZA)
	RestArea(aArea)
return cNomeDepto


//Retorna se o usuário eh tecnico
static function ChkTecnico(cIDHelpDsk)
	local aArea := FwGetArea()
	local aAreaZZB := ZZB->(FwGetArea())
	local lTecnico := .F.
	
	lTecnico := iif( POSICIONE("ZZB",1, FWXFILIAL("ZZB")+ cIDHelpDsk, "ZZB_TIPO") <> '1', .T., .F.)

	RestArea(aAreaZZB)
	RestArea(aArea)
return lTecnico

user function zTst999()
	local oUsrHD     := Nil 
	local cIDHelpDsk := ""
	local cxNome     := ""
	local cIDDepto   := ""
	local cNomDepto  := ""
	local lEhTecnico := .F.
	
	oUsrHD := GetInfoUsuarioHD():New(cRetCodUsr())
	
	//Retorna o Nome completo
	cxNome := oUsrHD:FullName()
	
	//Retorna o ID do usuario HelpDesk
	cIDHelpDsk := oUsrHD:IDUsrHD()
	
	//Retorna o ID do Departamento
	cIDDepto := oUsrHD:IDDepto()
	
	//Retorna o nome do Departamento
	cNomDepto := oUsrHD:NomeDepto()
	
	//Retorna se o perfil do usuario eh de atendente
	lEhTecnico := oUsrHD:EhTecnico()
	
	freeobj(oUsrHD)
return
