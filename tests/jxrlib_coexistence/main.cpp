#include <iostream>
#include <cstdint>
#include <libCZI/libCZI.h>
#include <jxrlib/JXRGlue.h>

int main()
{
	PKFactory* pFactory = nullptr;
	ERR err = PKCreateFactory(&pFactory, 0);
	if (err != WMP_errSuccess)
	{
		std::cerr << "Failed to create PKFactory: " << err << std::endl;
		return EXIT_FAILURE;
	}

	std::uint8_t stream_data[32] = { 0 };
	WMPStream* pStream = nullptr;
	err = pFactory->CreateStreamFromMemory(&pStream, stream_data, sizeof(stream_data));
	if (err != WMP_errSuccess)
	{
		std::cerr << "Failed to create WMPStream: " << err << std::endl;
		return EXIT_FAILURE;
	}

	pStream->Close(&pStream);
	pFactory->Release(&pFactory);

	std::cout << "WMPStream created successfully." << std::endl;

	PKImageEncode* pIE = nullptr;
	err = PKImageEncode_Create_WMP(&pIE);
	if (err != WMP_errSuccess)
	{
		std::cerr << "Failed to create PKImageEncode: " << err << std::endl;
		return EXIT_FAILURE;
	}

	// we are leaking the PKImageEncode object here intentionally, because we seem to crash if the object is not initialized with a stream object
	//pIE->Release(&pIE);

	std::cout << "PKImageEncode created successfully." << std::endl;

	int major, minor, patch, tweak;
	libCZI::GetLibCZIVersion(&major, &minor, &patch, &tweak);
	std::cout << "LibCZI Version: " << major << "." << minor << "." << patch << " tweak: " << tweak << std::endl;
	std::cout << std::endl;

	libCZI::BuildInformation build_information;
	libCZI::GetLibCZIBuildInformation(build_information);
	std::cout << "LibCZI Build Information:" << std::endl;
	std::cout << "-------------------------" << std::endl;
	std::cout << "compiler: " << build_information.compilerIdentification << std::endl;
	std::cout << "repository: " << build_information.repositoryUrl << std::endl;
	std::cout << "branch: " << build_information.repositoryBranch << std::endl;
	std::cout << "tag: " << build_information.repositoryTag << std::endl;

	return EXIT_SUCCESS;
}