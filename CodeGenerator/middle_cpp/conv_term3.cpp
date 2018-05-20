#include <iostream>
#include <stdlib.h>
#include <string>
#include <fstream>

//#define D /* double precision */
//#define DD /* double-double precision */
//#define TD /* triple-double precision */
//#define QD /* quad-double precision */

#include "option.h"

void setDecl(int cnt, std::ofstream &clfuncCode);

int main(int argc, char* argv[])
{
	std::string clout(argv[1]);
	std::ifstream term3Code("term3.code");
	std::ofstream clfuncCode((clout+std::string("_func.code")).c_str());
	std::ofstream cldeclCode((clout+std::string("_decl.code")).c_str());
	std::string tmp_input;
	std::string term1, term2, term3, op;
	int cnt=0;

	if(term3Code.fail()){
		std::cerr << "file [term3.code] does not exist." << std::endl;
		exit(0);
	}

	while(getline(term3Code, tmp_input, '\n')){
		if(cnt % 5 == 0) term3 = tmp_input;
		else if(cnt % 5 == 1) ;
		else if(cnt % 5 == 2) term1 = tmp_input;
		else if(cnt % 5 == 3) op = tmp_input;
		else if(cnt % 5 == 4) term2 = tmp_input;

		if(cnt%5 == 4){
		if(op == "+") clfuncCode << _add << "(" << term1 << ", " << term2 << ", " << term3 << ");" << std::endl;
		else if(op == "-") clfuncCode << _sub << "(" << term1 << ", " << term2 << ", " << term3 << ");" << std::endl;
		else if(op == "*") clfuncCode << _mul << "(" << term1 << ", " << term2 << ", " << term3 << ");" << std::endl;
		else if(op == "/") clfuncCode << _div << "(" << term1 << ", " << term2 << ", " << term3 << ");" << std::endl;
		}

		cnt++;
	}

	setDecl(cnt/5, cldeclCode);

	return 0;
}

void setDecl(int cnt, std::ofstream &clfuncCode)
{
	if(_prec == "d") clfuncCode << "double one=1.0, mone=-1.0, t[" << cnt << "];" << std::endl;
	else if(_prec == "dd") clfuncCode << "double one[2]={1.0, 0.0}, mone[2]={-1.0, 0.0}, t[" << cnt << "][2];" << std::endl;
	else if(_prec == "td") clfuncCode << "double one[3]={1.0, 0.0, 0.0}, mone[3]={-1.0, 0.0, 0.0}, t[" << cnt << "][3];" << std::endl;
	else if(_prec == "qd") clfuncCode << "double one[4]={1.0, 0.0, 0.0, 0.0}, mone[4]={-1.0, 0.0, 0.0, 0.0}, t[" << cnt << "][4];" << std::endl;
}
