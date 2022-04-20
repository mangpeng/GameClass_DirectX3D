#pragma once

class MeshCube final : public Mesh
{
public:
	MeshCube();
	~MeshCube();

private:
	void Create() override;
};

