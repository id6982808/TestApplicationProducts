#include <iostream>
#include <stdlib.h>
#include <string>
#include <fstream>

std::string modifyString(std::string str);

int main(int argc, char* argv[])
{
	std::ifstream by_front(argv[1]);
	std::ofstream modifiedCode("modified.code");
	std::string tmp_input;
	int cnt=0;

	if(by_front.fail()){
		std::cerr << "file [by_front.code] does not exist." << std::endl;
		exit(0);
	}

	while(getline(by_front, tmp_input, '\n')){
/*
	if(tmp_input=="L1:") continue;
	if(tmp_input.length()>=7)
		if(tmp_input.substr(tmp_input.length()-4,3)=="L2:") { std::cout <<  tmp_input.substr(0,tmp_input.length()-4) << std::endl; break;}
	if(tmp_input=="minus")
		{ std::cout << tmp_input << std::endl; std::cout << "*" << std::endl; }
	else
		{
			std::cout << tmp_input << std::endl;
		}
*/
	if(modifyString(tmp_input)=="L2:") break;
	else if(cnt==0) modifiedCode << modifyString(tmp_input).substr(4,tmp_input.length());
	else modifiedCode << modifyString(tmp_input);
	cnt++;
	}
	modifiedCode << std::endl;

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

