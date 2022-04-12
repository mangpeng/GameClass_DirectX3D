#pragma once

class MeshGrid final : public Mesh
{
public:
	MeshGrid(Shader* shader, float offsetU = 1.0f, float offsetV = 1.0f);
	~MeshGrid();

private:
	void Create() override;

	float offsetU, offsetV;
};

