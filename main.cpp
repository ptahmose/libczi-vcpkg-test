#include <iostream>
#include <libCZI/libCZI.h>

int main() {
	libCZI::BuildInformation build_information;
    libCZI::GetLibCZIBuildInformation(build_information);
    std::cout << "compiler: " << build_information.compilerIdentification << std::endl;
	std::cout << "repository: " << build_information.repositoryUrl << std::endl;
	std::cout << "branch: " << build_information.repositoryBranch << std::endl;
	std::cout << "tag: " << build_information.repositoryTag << std::endl;
    return 0;
}