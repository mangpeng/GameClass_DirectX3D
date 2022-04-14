#pragma once

class MeshQuad final : public Mesh
{
public:
	MeshQuad();
	~MeshQuad();

private:
	void Create() override;
};

