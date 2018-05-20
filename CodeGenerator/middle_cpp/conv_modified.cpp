#include <iostream>
#include <stdlib.h>
#include <string>
#include <fstream>
#include <sstream>

#define temp_size 100

std::string modifyArray(std::string str);

int main()
{
	std::ifstream modifiedCode("modified.code");
	std::ofstream term3Code("term3.code");
	std::string tmp_input;
	int cnt=0;

	if(modifiedCode.fail()){
		std::cerr << "file [modified.code] does not exist." << std::endl;
		exit(0);
	}

	while(getline(modifiedCode, tmp_input, '\n')){
		if(tmp_input == "minus") term3Code << "mone" << std::endl << "*" << std::endl;
		else term3Code << modifyArray(tmp_input) << std::endl;
	}

	return 0;
}

std::string modifyArray(std::string str)
{
	std::stringstream ss;
	std::string array_type;
	int flag=0;
	static int count_temp=0;
 
	for(int i=1; i<temp_size; i++){
		ss << i;
		if(("t"+ss.str()) == str)
		{
			ss.str("");
			ss.clear(std::stringstream::goodbit);
			ss << i-1;
			array_type = "t[" + ss.str() + "]";
			flag=1;
			if(i > count_temp)
			{
				count_temp = i;
				std::cout << count_temp << "\n";
			}
			break;
		}
		ss.str("");
    ss.clear(std::stringstream::goodbit);
	}
	if(flag == 0) array_type = str;

	return array_type;
}
