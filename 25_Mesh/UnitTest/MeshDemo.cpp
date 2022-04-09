#include "stdafx.h"
#include "MeshDemo.h"


void MeshDemo::Initialize()
{
	Context::Get()->GetCamera()->RotationDegree(20, 0, 0);
	Context::Get()->GetCamera()->Position(0, 36, -85);

	shader = new Shader(L"25_Mesh.fx");
	sDirection = shader->AsVector("Directoin");

	quad = new MeshQuad(shader);
	quad->Scale(2, 2, 2);
	quad->Position(0.0f, 1.0f, 0.0f);
	quad->DiffuseMap(L"Box.png");

	cube = new MeshCube(shader);
	cube->Position(0, 5, 0);
	cube->Scale(20, 10, 20);
	cube->DiffuseMap(L"Stones.png");

	grid = new MeshGrid(shader, 6 ,6);
	grid->Scale(12, 1, 12);
	grid->DiffuseMap(L"Floor.png");
}

void MeshDemo::Destroy()
{
	SafeDelete(shader);
	SafeDelete(quad);
	SafeDelete(cube);
	SafeDelete(grid);
}

void MeshDemo::Update()
{
	//Vector3 scale;
	//quad->Scale(&scale);

	//ImGui::SliderFloat2("Scale", scale, -3, 3);
	//quad->Scale(scale);

	quad->Update();

	cube->Update();
	grid->Update();
}


void MeshDemo::Render()
{
	sDirection->SetFloatVector(direction);
	quad->Render();
	//cube->Render();

	static int pass = 1;
	ImGui::InputInt("Pass", &pass);
	pass %= 2;

	grid->Pass(pass);
	grid->Render();
}


