#include "Framework.h"
#include "ModelMesh.h"

ModelBone::ModelBone()
{

}

ModelBone::~ModelBone()
{

}

///////////////////////////////////////////////////////////////////////////////

ModelMesh::ModelMesh()
{
	boneBuffer = new ConstantBuffer(&boneDesc, sizeof(BoneDesc));
}

ModelMesh::~ModelMesh()
{
	SafeDelete(perFrame);

	SafeDelete(material);

	SafeDeleteArray(vertices);
	SafeDeleteArray(indices);

	SafeDelete(vertexBuffer);
	SafeDelete(indexBuffer);

	SafeDelete(boneBuffer);
}

void ModelMesh::Binding(Model* model)
{
	vertexBuffer = new VertexBuffer(vertices, vertexCount, sizeof(Model::ModelVertex));
	indexBuffer = new IndexBuffer(indices, indexCount);


	Material* srcMaterial = model->MaterialByName(materialName);

	material = new Material();
	material->CopyFrom(srcMaterial);
}

void ModelMesh::SetShader(Shader* shader)
{
	this->shader = shader;

	SafeDelete(perFrame);
	perFrame = new PerFrame(shader);

	sBoneBuffer = shader->AsConstantBuffer("CB_Bone");

	material->SetShader(shader);
	sTransformSRV = shader->AsSRV("TransformsMaps");
}

void ModelMesh::Update()
{
	boneDesc.Index = boneIndex;

	perFrame->Update();
}

void ModelMesh::Render(UINT drawCount)
{
	boneBuffer->Render();
	sBoneBuffer->SetConstantBuffer(boneBuffer->Buffer());

	perFrame->Render();
	material->Render();

	vertexBuffer->Render();
	indexBuffer->Render();

	// null 이면 일반 모델, 아니면 애니메이션 모델
	if (transformSRV != NULL)
		sTransformSRV->SetResource(transformSRV);

	D3D::GetDC()->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

	shader->DrawIndexedInstanced(0, pass, indexCount, drawCount);
}




