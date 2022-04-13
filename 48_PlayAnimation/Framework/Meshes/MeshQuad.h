#pragma once

class MeshQuad final : public Mesh
{
public:
	MeshQuad(Shader* shader);
	~MeshQuad();

private:
	void Create() override;
};

