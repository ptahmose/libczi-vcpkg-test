#include <iostream>
#include <sstream>
#include <string>
#include <libCZI/libCZI.h>

using namespace std;

int main() 
{
	int major, minor, patch,tweak;
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

	std::cout << "Available Input-Stream objects:" << std::endl;
	std::cout << std::endl;

	const int stream_object_count = libCZI::StreamsFactory::GetStreamClassesCount();
	ostringstream string_stream;
	bool curl_input_stream_found = false;
	for (int i = 0; i < stream_object_count; ++i)
	{
		libCZI::StreamsFactory::StreamClassInfo stream_class_info;
		libCZI::StreamsFactory::GetStreamInfoForClass(i, stream_class_info);

		string_stream << i + 1 << ": " << stream_class_info.class_name << endl;
		string_stream << "    " << stream_class_info.short_description << endl;

		if (stream_class_info.get_build_info)
		{
			string build_info = stream_class_info.get_build_info();
			if (!build_info.empty())
			{
				string_stream << "    " << "Build: " << build_info << endl;
			}
		}

		if (stream_class_info.class_name == "curl_http_inputstream")
		{
			curl_input_stream_found = true;
		}
	}

	std::cout << string_stream.str() << std::endl;

	return curl_input_stream_found ? EXIT_SUCCESS : EXIT_FAILURE;
}