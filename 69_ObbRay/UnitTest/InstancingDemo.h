#pragma once
#include "Systems/IExecute.h"

#define INSTANCE_COUNT 1000

class InstancingDemo : public IExecute
{
public:
	virtual void Initialize() override;
	virtual void Ready() override {}
	virtual void Destroy() override {}
	virtual void Update() override;
	virtual void PreRender() override {}
	virtual void Render() override;
	virtual void PostRender() override {}
	virtual void ResizeScreen() override {}

private:
	void CreateMesh();

private:
	Shader* shader;
	Material* material;

	vector<Mesh::MeshVertex> vertices;
	vector<UINT> indices;

	VertexBuffer* vertexBuffer; //0
	VertexBuffer* instanceBuffer; //1

	IndexBuffer* indexBuffer;

	PerFrame* perFrame;

	Transform* transforms[INSTANCE_COUNT];
	Matrix worlds[INSTANCE_COUNT];
};