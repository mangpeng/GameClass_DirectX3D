#include "stdafx.h"
#include "AnimationDemo.h"
#include "Converter.h"

void AnimationDemo::Initialize()
{
	Context::Get()->GetCamera()->RotationDegree(20, 0, 0);
	Context::Get()->GetCamera()->Position(0, 6, -41);

	shader = new Shader(L"45_Animation.fx");

	Kachujin();
}

void AnimationDemo::Update()
{
	if (kachujin != NULL) 
		kachujin->Update();
}

void AnimationDemo::Render()
{
	if (kachujin != NULL)
		kachujin->Render();
}

void AnimationDemo::Kachujin()
{
	kachujin = new ModelAnimator(shader);
	kachujin->ReadMesh(L"Kachujin/mesh");
	kachujin->ReadMaterial(L"Kachujin/mesh");

	kachujin->ReadClip(L"Kachujin/Sword And Shield Idle");
	kachujin->ReadClip(L"Kachujin/Sword And Shield Walk");
	kachujin->ReadClip(L"Kachujin/Sword And Shield Run");
	kachujin->ReadClip(L"Kachujin/Sword And Shield Slash");
	kachujin->ReadClip(L"Kachujin/Salsa Dancing");

	kachujin->GetTransform()->Position(0, 0, -30);
	kachujin->GetTransform()->Scale(0.025f, 0.025f, 0.025f);
}