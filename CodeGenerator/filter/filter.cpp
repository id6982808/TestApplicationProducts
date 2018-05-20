#include <iostream>
#include <stdlib.h>
#include <string>
#include <fstream>
#include <sstream>

std::string filter(std::string str);

int main(int argc, char* argv[])
{
	std::ifstream rawCode(argv[1]);
	std::ofstream filteredCode((std::string(argv[1])+".kernel").c_str());
	std::string temp_str;
	int through=0;
	
	while(getline(rawCode, temp_str, '\n'))
	{
		if(temp_str.substr(0,4)=="VARI" || temp_str.substr(0,4)=="VARJ" || temp_str.substr(0,4)=="VARF" || temp_str.substr(0,3)=="VAR" || temp_str.substr(0,5)=="LOCAL")
			filteredCode << filter(temp_str) << "\n";
		else
			{
				if(through==0) { filteredCode << "{\n" << temp_str << "\n"; through=1; }
				else { filteredCode << temp_str << "\n"; }
			}
	}
	filteredCode << "}\n";

	return 0;
}

std::string filter(std::string str)
{
	std::string ret;

	for(int i=0; i<str.length(); i++)
	{
		if(str[i]==',') { if(str[i+1] != ' ') ret += std::string(" "); else; }
		else if(str[i]==';') { if(str[i-1] != ' ') ret += std::string(" ;"); else ret += std::string(";"); }
		else ret += str.substr(i,1);
	}

	return ret;
}
