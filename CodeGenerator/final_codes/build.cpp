#include <iostream>
#include <stdlib.h>
#include <string>
#include <fstream>
#include <sstream>
#include "../middle_cpp/option.h"

std::string modifyModname(std::string str);

int main(int argc, char* argv[])
{
	std::stringstream ss;
	std::string modname(argv[1]); modname = modifyModname(modname);
	std::ifstream countFile("count");
	std::ifstream operandsFile("clope.code");
	std::ifstream globalOutFile("globout.code");
	std::ifstream forinitFile("forinit.code");
	std::ifstream countTempFile("temp_counter.code");
	std::ofstream finalCode((modname+".cl").c_str());
	std::ofstream semifin("semifin.code");
	std::string temp, decl, operands;
	int cnt_src;
	int cnt=0;
	int max_temp=0, i_temp=0;

	getline(countFile, temp);
	cnt_src = atoi(temp.c_str());
	std::string funcs[cnt_src];

	while(getline(countTempFile,temp))
	{
		i_temp = atoi(temp.c_str());
		if(i_temp > max_temp) max_temp = i_temp;
	}
	
	for(int i=0; i<cnt_src; i++)
	{
		ss << i;
		std::ifstream inputFunc((std::string("calc")+ss.str()+std::string(".src_func.code")).c_str());
		while(getline(inputFunc, temp)) funcs[i] += temp+"\n";
		ss.str("");
    ss.clear(std::stringstream::goodbit);
	}

	std::ifstream inputDecl("cldecl-2.code");
	while(getline(inputDecl, temp)) decl += temp+"\n";
	getline(operandsFile, operands);

	semifin << "__kernel void " << modname << "(" ;
	semifin << operands;
	semifin << ")" << std::endl;
	semifin << "{" << std::endl;
	semifin << "int id3;" << std::endl;
	semifin << "int id1 = get_global_id(0) \% n;" << std::endl;
	semifin << "int id2 = get_global_id(0) / n;" << std::endl;
	semifin << "double t[" << max_temp << "][";
	if(_prec=="d") semifin << "1];\n";
	else if(_prec=="dd") semifin << "2];\n";
	else if(_prec=="td") semifin << "3];\n";
	else if(_prec=="qd") semifin << "4];\n";
	semifin << decl << std::endl;
	semifin << "for(id3=0; id3<";
	if(_prec=="d") semifin << "n";
	else if(_prec=="dd") semifin << "n*2";
	else if(_prec=="td") semifin << "n*3";
	else if(_prec=="qd") semifin << "n*4";
	semifin << "; id3++){" << std::endl;
	while(getline(forinitFile, temp)) semifin << temp << std::endl;
	for(int i=0; i<cnt_src; i++) semifin << funcs[i] << std::endl;
	semifin << "}" << std::endl;
	while(getline(globalOutFile, temp)) semifin << temp << std::endl;
	//semifin << "}" << std::endl;

	std::ifstream fin("semifin.code");
	while(getline(fin, temp))
	{
		if(cnt > 1) finalCode << "\t" << temp << std::endl;
		else finalCode << temp << std::endl;

		cnt++;
	}
	finalCode << "}" << std::endl;

	return 0;
}

std::string modifyModname(std::string str)
{
	char tmp[str.length()];
	for(int i=0; i<str.length()+1; i++)
	{	
		if(str[i]=='.') tmp[i]='_';
		else if(str[i]=='-') tmp[i]='_';
		else tmp[i]=str[i];
	}

	return std::string(tmp);
}
