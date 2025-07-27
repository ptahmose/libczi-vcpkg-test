#include <iostream>
#include <libCZI/libCZI.h>

int main() 
{
    int major, minor, patch,tweak;
    libCZI::GetLibCZIVersion(&major, &minor, &patch, &tweak);
    std::cout << "LibCZI Version: " << major << "." << minor << "." << patch << " tweak: " << tweak << std::endl;
    std::cout << std::endl;

    libCZI::BuildInformation build_information;
    libCZI::GetLibCZIBuildInformation(build_information);
    std::cout << "LibCZI Build Information:" << std::endl;
    std::cout << "--------------------------" << std::endl;
    std::cout << "compiler: " << build_information.compilerIdentification << std::endl;
	std::cout << "repository: " << build_information.repositoryUrl << std::endl;
	std::cout << "branch: " << build_information.repositoryBranch << std::endl;
	std::cout << "tag: " << build_information.repositoryTag << std::endl;
    
    return EXIT_SUCCESS;
}