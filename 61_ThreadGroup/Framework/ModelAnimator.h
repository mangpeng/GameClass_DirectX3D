#pragma once

class ModelAnimator
{
public:
	ModelAnimator(Shader* shader);
	~ModelAnimator();

	void Update();
	void Render();

private:
	void UpdateTweenMode(UINT index);
	void UpdateBlendMode(UINT index);

public:
	void ReadMesh(wstring file);
	void ReadMaterial(wstring file);
	void ReadClip(wstring file);

	Model* GetModel() { return model; }

	Transform* AddTransform();
	Transform* GetTransform(UINT index) { return transforms[index]; }
	void UpdateTransforms();

	void Pass(UINT pass);
	void PlayTweenMode(UINT index, UINT clip, float speed = 1.0f, float takeTime = 1.0f);
	void PlayBlendMode(UINT index, UINT clip1, UINT clip2, UINT clip3);
	void SetBlendAlpha(UINT index, float alpha);

private:
	
	void CreateTexture();
	void CreateClipTransform(UINT index);

private:
	struct ClipTransform
	{
		Matrix** Transform;

		ClipTransform()
		{
			Transform = new Matrix * [MAX_MODEL_KEYFRAMES];
			 
			for (UINT i = 0; i < MAX_MODEL_KEYFRAMES; i++)
				Transform[i] = new Matrix[MAX_MODEL_TRANSFORMS];
		}

		~ClipTransform()
		{
			for (UINT i = 0; i < MAX_MODEL_KEYFRAMES; i++)
				SafeDeleteArray(Transform[i]);

			SafeDeleteArray(Transform);
		}

	};

	ClipTransform* clipTransforms = NULL;

	ID3D11Texture2D* texture = NULL;
	ID3D11ShaderResourceView* srv = NULL;

private:
	struct KeyframeDesc
	{
		int clip = 0;

		UINT CurrFrame = 0;
		UINT NextFrame = 0;

		float Time = 0.0f;
		float RunningTime = 0.0f;

		float Speed = 1.0f;

		Vector2 Padding;
	}; // keyframeDesc;

	ConstantBuffer* frameBuffer;
	ID3DX11EffectConstantBuffer* sFrameBuffer;

	struct TweenDesc
	{
		float TakeTime = 1.0f;
		float TweenTime = 0.0f;
		float ChangeTime = 0.0f;
		float Padding;

		KeyframeDesc Curr;
		KeyframeDesc Next;

		TweenDesc()
		{
			Curr.clip = 0;
			Next.clip = -1;
		}
	} tweenDesc[MAX_MODEL_INSTANCE];

private:
	struct BlendDesc
	{
		UINT Mode = 0;
		float Alpha = 0;
		Vector2 Padding;

		KeyframeDesc Clip[3];
	} blendDesc[MAX_MODEL_INSTANCE];

	ConstantBuffer* blendBuffer;
	ID3DX11EffectConstantBuffer* sBlendBuffer;

private:
	Shader* shader;
	Model* model;
	

	vector<Transform*> transforms;
	Matrix worlds[MAX_MODEL_INSTANCE];

	VertexBuffer* instanceBuffer;
};

