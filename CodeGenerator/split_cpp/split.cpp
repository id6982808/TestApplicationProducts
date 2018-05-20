#include <iostream>
#include <stdlib.h>
#include <string>
#include <fstream>
#include <sstream>
#include "../middle_cpp/option.h"

std::string modifyString(std::string str);
#define var_size 15

int main(int argc, char* argv[])
{
	std::ifstream inputCode(argv[1]);
	std::ofstream fixedCode("fixed.temp");
	std::ofstream cldeclCode("cldecl-2.code");
	std::ofstream clopeCode("clope.code");
	std::ofstream globalOutCode("globout.code");
	std::ofstream forinitCode("forinit.code");
	std::stringstream ss;
	std::string tmp_input;
	std::string nn[var_size],n[var_size],nnf[var_size],s[var_size],lcl[var_size];
	int cnt_nn=0, cnt_n=0, cnt_nnf=0, cnt_s=0, cnt_lcl=0;

	if(inputCode.fail()){
		std::cerr << "file does not exist. (split.cpp)" << std::endl;
		exit(0);
	}

	while(getline(inputCode, tmp_input, '\n')){
		//std::cout << modifyString(tmp_input) << std::endl;
		if(tmp_input=="{") break;
		fixedCode << modifyString(tmp_input) << std::endl;
	}

	std::ifstream inputCode2("fixed.temp");
	while(getline(inputCode2, tmp_input, '\n')){
		if(tmp_input=="VARI")
			while(getline(inputCode2, tmp_input, '\n') && tmp_input != ";") { nn[cnt_nn]=tmp_input; cnt_nn++; }
		if(tmp_input=="VARJ")
			while(getline(inputCode2, tmp_input, '\n') && tmp_input != ";") { n[cnt_n]=tmp_input; cnt_n++; }
		if(tmp_input=="VARF")
			while(getline(inputCode2, tmp_input, '\n') && tmp_input != ";") { nnf[cnt_nnf]=tmp_input; cnt_nnf++; }
		if(tmp_input=="VAR")
			while(getline(inputCode2, tmp_input, '\n') && tmp_input != ";") { s[cnt_s]=tmp_input; cnt_s++; }
		if(tmp_input=="LOCAL")
			while(getline(inputCode2, tmp_input, '\n') && tmp_input != ";") { lcl[cnt_lcl]=tmp_input; cnt_lcl++; }
	}
	
	for(int i=0; i<cnt_nn; i++)
	{
		clopeCode << "__global double * " << "g_"+nn[i];
		if(i+1<cnt_nn) clopeCode << ", ";
	}
	if(cnt_n > 0) clopeCode << ", ";
	for(int i=0; i<cnt_n; i++)
	{
		clopeCode << "__global double * " << "g_"+n[i];

		if(i+1<cnt_n) clopeCode << ", ";
	}
	if(cnt_nnf > 0) clopeCode << ", ";
	for(int i=0; i<cnt_nnf; i++)
	{
		clopeCode << "__global double * " << "g_"+nnf[i];

		if(i+1<cnt_nnf) clopeCode << ", ";
	}
	if(cnt_s > 0) clopeCode << ", ";
	for(int i=0; i<cnt_s; i++)
	{
		clopeCode << "__global double * " << "g_"+s[i];

		if(i+1<cnt_s) clopeCode << ", ";
	}


	if(cnt_nn > 0) cldeclCode << "double ";
	for(int i=0; i<cnt_nn; i++)
	{
		cldeclCode << nn[i];
		if(_prec=="d");
		else if(_prec=="dd") cldeclCode << "[2]";
		else if(_prec=="td") cldeclCode << "[3]";
		else if(_prec=="qd") cldeclCode << "[4]";

		if(i+1<cnt_nn) cldeclCode << ", ";
		else cldeclCode << ";" << std::endl;
	}

	if(cnt_n > 0) cldeclCode << "double ";
	for(int i=0; i<cnt_n; i++)
	{
		cldeclCode << n[i];
		if(_prec=="d");
		else if(_prec=="dd") cldeclCode << "[2]";
		else if(_prec=="td") cldeclCode << "[3]";
		else if(_prec=="qd") cldeclCode << "[4]";

		if(i+1<cnt_n) cldeclCode << ", ";
		else cldeclCode << ";" << std::endl;
	}

	if(cnt_nnf > 0) cldeclCode << "double ";
	for(int i=0; i<cnt_nnf; i++)
	{
		cldeclCode << nnf[i];
		if(_prec=="d");
		else if(_prec=="dd") cldeclCode << "[2]";
		else if(_prec=="td") cldeclCode << "[3]";
		else if(_prec=="qd") cldeclCode << "[4]";

		if(i+1<cnt_nnf) cldeclCode << ", ";
		else cldeclCode << ";" << std::endl;
	}

	if(cnt_s > 0) cldeclCode << "double ";
	for(int i=0; i<cnt_s; i++)
	{
		cldeclCode << s[i];
		if(_prec=="d");
		else if(_prec=="dd") cldeclCode << "[2]";
		else if(_prec=="td") cldeclCode << "[3]";
		else if(_prec=="qd") cldeclCode << "[4]";

		if(i+1<cnt_s) cldeclCode << ", ";
		else cldeclCode << ";" << std::endl;
	}

	if(cnt_lcl > 0) cldeclCode << "double ";
	for(int i=0; i<cnt_lcl; i++)
	{
		cldeclCode << lcl[i];
		if(_prec=="d");
		else if(_prec=="dd") cldeclCode << "[2]";
		else if(_prec=="td") cldeclCode << "[3]";
		else if(_prec=="qd") cldeclCode << "[4]";

		if(i+1<cnt_lcl) cldeclCode << ", ";
		else cldeclCode << ";" << std::endl;
	}

	cldeclCode << std::endl;
	for(int i=0; i<cnt_nn; i++)
	{
		if(_prec=="d")
		{
			cldeclCode << nn[i] + " = " + "g_" + nn[i]+"[id1*n +id2]; ";
		}
		else if(_prec=="dd")
		{
			cldeclCode << nn[i]+"[0] = g_"+nn[i]+"[id1*n*2 +id2*2 +0]; ";
			cldeclCode << nn[i]+"[1] = g_"+nn[i]+"[id1*n*2 +id2*2 +1];\n";
		}
		else if(_prec=="td")
		{
			cldeclCode << nn[i]+"[0] = g_"+nn[i]+"[id1*n*3 +id2*3 +0]; ";
			cldeclCode << nn[i]+"[1] = g_"+nn[i]+"[id1*n*3 +id2*3 +1]; ";
			cldeclCode << nn[i]+"[2] = g_"+nn[i]+"[id1*n*3 +id2*3 +2];\n";
		}
		else if(_prec=="qd")
		{
			cldeclCode << nn[i]+"[0] = g_"+nn[i]+"[id1*n*4 +id2*4 +0]; ";
			cldeclCode << nn[i]+"[1] = g_"+nn[i]+"[id1*n*4 +id2*4 +1]; ";
			cldeclCode << nn[i]+"[2] = g_"+nn[i]+"[id1*n*4 +id2*4 +2]; ";
			cldeclCode << nn[i]+"[3] = g_"+nn[i]+"[id1*n*4 +id2*4 +3];\n";
		}
	}
	for(int i=0; i<cnt_n; i++)
	{
		if(_prec=="d")
		{
			forinitCode << n[i] + " = " + "g_" + n[i]+"[id3]; ";
		}
		else if(_prec=="dd")
		{
			forinitCode << n[i]+"[0] = g_"+n[i]+"[id3*2 +0]; ";
			forinitCode << n[i]+"[1] = g_"+n[i]+"[id3*2 +1];\n";
		}
		else if(_prec=="td")
		{
			forinitCode << n[i]+"[0] = g_"+n[i]+"[id3*3 +0]; ";
			forinitCode << n[i]+"[1] = g_"+n[i]+"[id3*3 +1]; ";
			forinitCode << n[i]+"[2] = g_"+n[i]+"[id3*3 +2];\n";
		}
		else if(_prec=="qd")
		{
			forinitCode << n[i]+"[0] = g_"+n[i]+"[id3*4 +0]; ";
			forinitCode << n[i]+"[1] = g_"+n[i]+"[id3*4 +1]; ";
			forinitCode << n[i]+"[2] = g_"+n[i]+"[id3*4 +2]; ";
			forinitCode << n[i]+"[3] = g_"+n[i]+"[id3*4 +3];\n";
		}
	}

	for(int i=0; i<cnt_nnf; i++)
	{
		if(_prec=="d")
		{
			globalOutCode << "g_"+nnf[i] + "[id1*n +id2] = " + "g_" + nnf[i];
		}
		else if(_prec=="dd")
		{
			globalOutCode << "g_"+nnf[i]+"[id1*n*2 +id2*2 +0] = "+nnf[i]+"[0]; ";
			globalOutCode << "g_"+nnf[i]+"[id1*n*2 +id2*2 +1] = "+nnf[i]+"[1];\n";
		}
		else if(_prec=="td")
		{
			globalOutCode << "g_"+nnf[i]+"[id1*n*3 +id2*3 +0] = "+nnf[i]+"[0]; ";
			globalOutCode << "g_"+nnf[i]+"[id1*n*3 +id2*3 +1] = "+nnf[i]+"[1]; ";
			globalOutCode << "g_"+nnf[i]+"[id1*n*3 +id2*3 +2] = "+nnf[i]+"[2];\n";
		}
		else if(_prec=="qd")
		{
			globalOutCode << "g_"+nnf[i]+"[id1*n*4 +id2*4 +0] = "+nnf[i]+"[0]; ";
			globalOutCode << "g_"+nnf[i]+"[id1*n*4 +id2*4 +1] = "+nnf[i]+"[1]; ";
			globalOutCode << "g_"+nnf[i]+"[id1*n*4 +id2*4 +2] = "+nnf[i]+"[2]; ";
			globalOutCode << "g_"+nnf[i]+"[id1*n*4 +id2*4 +3] = "+nnf[i]+"[3];\n";
		}
	}
	for(int i=0; i<cnt_nnf; i++)
	{
		if(_prec=="d")
		{
			cldeclCode << nnf[i] + " = 0.0; ";
		}
		else if(_prec=="dd")
		{
			cldeclCode << nnf[i]+"[0] = 0.0; ";
			cldeclCode << nnf[i]+"[1] = 0.0;\n";
		}
		else if(_prec=="td")
		{
			cldeclCode << nnf[i]+"[0] = 0.0; ";
			cldeclCode << nnf[i]+"[1] = 0.0; ";
			cldeclCode << nnf[i]+"[2] = 0.0;\n";
		}
		else if(_prec=="qd")
		{
			cldeclCode << nnf[i]+"[0] = 0.0; ";
			cldeclCode << nnf[i]+"[1] = 0.0; ";
			cldeclCode << nnf[i]+"[2] = 0.0; ";
			cldeclCode << nnf[i]+"[3] = 0.0;\n";
		}
	}

	for(int i=0; i<cnt_s; i++)
	{
		if(_prec=="d")
		{
			cldeclCode << s[i] + " = " + "g_" + s[i];
		}
		else if(_prec=="dd")
		{
			cldeclCode << s[i]+"[0] = g_"+s[i]+"[0]; ";
			cldeclCode << s[i]+"[1] = g_"+s[i]+"[1];\n";
		}
		else if(_prec=="td")
		{
			cldeclCode << s[i]+"[0] = g_"+s[i]+"[0]; ";
			cldeclCode << s[i]+"[1] = g_"+s[i]+"[1]; ";
			cldeclCode << s[i]+"[2] = g_"+s[i]+"[2];\n";
		}
		else if(_prec=="qd")
		{
			cldeclCode << s[i]+"[0] = g_"+s[i]+"[0]; ";
			cldeclCode << s[i]+"[1] = g_"+s[i]+"[1]; ";
			cldeclCode << s[i]+"[2] = g_"+s[i]+"[2]; ";
			cldeclCode << s[i]+"[3] = g_"+s[i]+"[3];\n";
		}
	}


	
	int cnt_calc=0;
	while(getline(inputCode, tmp_input, '\n')){
		if(tmp_input=="}") break;
		//std::cout << modifyString(tmp_input) << std::endl;
		ss << cnt_calc;
		std::ofstream calcCode(std::string("../input_source/calc" + ss.str() + ".src").c_str());
		calcCode << "{" << std::endl;
		for(int i=0; i<cnt_nn; i++) { calcCode << "float " << nn[i] << ";" << std::endl; }
		for(int i=0; i<cnt_n; i++) { calcCode << "float " << n[i] << ";" << std::endl; }
		for(int i=0; i<cnt_nnf; i++) { calcCode << "float " << nnf[i] << ";" << std::endl; }
		for(int i=0; i<cnt_s; i++) { calcCode << "float " << s[i] << ";" << std::endl; }
		for(int i=0; i<cnt_lcl; i++) { calcCode << "float " << lcl[i] << ";" << std::endl; }
		
		calcCode << tmp_input << std::endl;
		calcCode << "}" << std::endl;
		ss.str("");
    ss.clear(std::stringstream::goodbit);
		cnt_calc++;
	}
	

	return 0;
}

std::string modifyString(std::string str)
{
	char modified[str.length()+1];

	for(int i=0; i<str.length(); i++)
	{
		if(str[i]=='\t' || str[i]==' ') modified[i]='\n';
		else modified[i]=str[i];
	}
	modified[str.length()]='\0';
	
	return std::string(modified);
	//return str;
}
