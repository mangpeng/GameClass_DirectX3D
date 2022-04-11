#include "stdafx.h"
#include "Converter.h"

Converter::Converter()
{
	importer = new Assimp::Importer();
}

Converter::~Converter()
{
	SafeDelete(importer);
}

void Converter::ReadFile()
{
	this->file = L"../../_Assets/" + file;

	scene = importer->ReadFile
	(
		String::ToString(this->file),
		aiProcess_ConvertToLeftHanded | 
		aiProcess_Triangulate | 
		aiProcess_GenUVCoords | aiProcess_GenNormals | 
		aiProcess_CalcTangentSpace
	);

	assert(scene != NULL);
}
