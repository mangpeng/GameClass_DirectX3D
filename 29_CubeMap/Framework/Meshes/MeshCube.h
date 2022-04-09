#pragma once

class MeshCube final : public Mesh
{
public:
	MeshCube(Shader* shader);
	~MeshCube();

private:
	void Create() override;
};

