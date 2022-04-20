#pragma once

#define MAX_BILLBOARD_COUNT 10000

class Billboard : public Renderer
{
public:
	Billboard(Shader* shader);
	~Billboard();

	void Update();
	void Render();

	void Add(Vector3& position, Vector2& scale);

private:

	struct VertexBillboard
	{
		Vector3 Position;
		Vector2 Uv;
		Vector2 Scale;
	};

private:
	vector<VertexBillboard> vertices;

	Texture* texture;
	ID3DX11EffectShaderResourceVariable* sDiffuseMap;

};

