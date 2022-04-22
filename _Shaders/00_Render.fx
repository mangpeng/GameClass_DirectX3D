float4 PS_Sky(MeshOutput input) : SV_Target
{
    return SkyCubeMap.Sample(LinearSampler, input.oPosition);
}
///////////////////////////////////////////////////////////////////////////////

struct VertexMesh
{
    float4 Position : Position;
    float2 Uv : Uv;
    float3 Normal : Normal;
    float3 Tangent : Tangent;

    matrix Transform : Inst1_Transform;
    float4 Color : Inst2_Color;
};

//////////////////////////////////////////////////////////////////////

#define VS_GENERATE \
output.oPosition = input.Position.xyz;\
\
output.Position = WorldPosition(input.Position);\
output.wPosition = output.Position.xyz;\
output.Position = ViewProjection(output.Position);\
output.wvpPosition = output.Position;\
output.wvpPosition_Sub = output.Position;\
\
output.Normal = WorldNormal(input.Normal);\
output.Tangent = WorldTangent(input.Tangent);\
\
output.Uv = input.Uv;\
output.Color = input.Color;

//////////////////////////////////////////////////////////////////////

void SetMeshWorld(inout matrix world, VertexMesh input)
{
    world = input.Transform;
}

MeshOutput VS_Mesh(VertexMesh input)
{
    MeshOutput output;
    
    SetMeshWorld(World, input);
    VS_GENERATE
    
    return output;
}


//////////////////////////////////////////////////////////////////////

struct VertexModel
{
    float4 Position : Position;
    float2 Uv : Uv;
    float3 Normal : Normal;
    float3 Tangent : Tangent;
    float4 BlendIndices : BlendIndices;
    float4 BlendWeights : BlendWeights;
    
    uint InstanceId : SV_InstanceID;
    
    matrix Transform : Inst1_Transform;
    float4 Color : Inst2_Color;
};

Texture2DArray TransformsMaps;
#define MAX_MODEL_TRANSFORMS 250

cbuffer CB_Bone
{
    uint BoneIndex;
};

void SetModelWorld(inout matrix world, VertexModel input)
{
    //world = mul(BoneTransforms[BoneIndex], world);
    
    float4 m0 = TransformsMaps.Load(int4(BoneIndex * 4 + 0, input.InstanceId, 0, 0));
    float4 m1 = TransformsMaps.Load(int4(BoneIndex * 4 + 1, input.InstanceId, 0, 0));
    float4 m2 = TransformsMaps.Load(int4(BoneIndex * 4 + 2, input.InstanceId, 0, 0));
    float4 m3 = TransformsMaps.Load(int4(BoneIndex * 4 + 3, input.InstanceId, 0, 0));
    
    matrix transform = matrix(m0, m1, m2, m3);
    world = mul(transform, input.Transform);
}

MeshOutput VS_Model(VertexModel input)
{
    MeshOutput output;
    
    SetModelWorld(World, input);
    VS_GENERATE
    
    return output;
}

///////////////////////////////////////////////////////////////////
#define MAX_MODEL_KEYFRAMES 500
#define MAX_MODEL_INSTANCE 500


struct AnimationFrame
{
    int clip;
    
    uint CurrFrame;
    uint NextFrame;
    
    float Time;
    float Running;
    
    float3 Padding;
};

struct TweenFrame
{
    float TakeTime;
    float TweenTime;
    float RunningTime;
    float Padding;
    
    AnimationFrame Curr;
    AnimationFrame Next;
};
    
cbuffer CB_TweenFrame
{
    TweenFrame TweenFrames[MAX_MODEL_INSTANCE];
};


void SetTweenWorld(inout matrix world, VertexModel input)
{
    float indices[4] = { input.BlendIndices.x, input.BlendIndices.y, input.BlendIndices.z, input.BlendIndices.w };
    float weights[4] = { input.BlendWeights.x, input.BlendWeights.y, input.BlendWeights.z, input.BlendWeights.w };
    
    int clip[2];
    int currFrame[2];
    int nextFrame[2];
    float time[2];
    
    clip[0] = TweenFrames[input.InstanceId].Curr.clip;
    currFrame[0] = TweenFrames[input.InstanceId].Curr.CurrFrame;
    nextFrame[0] = TweenFrames[input.InstanceId].Curr.NextFrame;
    time[0] = TweenFrames[input.InstanceId].Curr.Time;
    
    clip[1] = TweenFrames[input.InstanceId].Next.clip;
    currFrame[1] = TweenFrames[input.InstanceId].Next.CurrFrame;
    nextFrame[1] = TweenFrames[input.InstanceId].Next.NextFrame;
    time[1] = TweenFrames[input.InstanceId].Next.Time;

    float4 c0, c1, c2, c3;
    float4 n0, n1, n2, n3;
    
    matrix curr = 0, next = 0;
    matrix currAnim = 0;
    matrix nextAnim = 0;
    
    matrix transform = 0;
    
    [unroll(4)]
    for (int i = 0; i < 4; i++)
    {
        c0 = TransformsMaps.Load(int4(indices[i] * 4 + 0, currFrame[0], clip[0], 0));
        c1 = TransformsMaps.Load(int4(indices[i] * 4 + 1, currFrame[0], clip[0], 0));
        c2 = TransformsMaps.Load(int4(indices[i] * 4 + 2, currFrame[0], clip[0], 0));
        c3 = TransformsMaps.Load(int4(indices[i] * 4 + 3, currFrame[0], clip[0], 0));
        curr = matrix(c0, c1, c2, c3);
        
        n0 = TransformsMaps.Load(int4(indices[i] * 4 + 0, nextFrame[0], clip[0], 0));
        n1 = TransformsMaps.Load(int4(indices[i] * 4 + 1, nextFrame[0], clip[0], 0));
        n2 = TransformsMaps.Load(int4(indices[i] * 4 + 2, nextFrame[0], clip[0], 0));
        n3 = TransformsMaps.Load(int4(indices[i] * 4 + 3, nextFrame[0], clip[0], 0));
        next = matrix(n0, n1, n2, n3);
        
        currAnim = lerp(curr, next, time[0]);
        
        [flatten]
        if (clip[1] > -1)
        {
            c0 = TransformsMaps.Load(int4(indices[i] * 4 + 0, currFrame[1], clip[1], 0));
            c1 = TransformsMaps.Load(int4(indices[i] * 4 + 1, currFrame[1], clip[1], 0));
            c2 = TransformsMaps.Load(int4(indices[i] * 4 + 2, currFrame[1], clip[1], 0));
            c3 = TransformsMaps.Load(int4(indices[i] * 4 + 3, currFrame[1], clip[1], 0));
            curr = matrix(c0, c1, c2, c3);
        
            n0 = TransformsMaps.Load(int4(indices[i] * 4 + 0, nextFrame[1], clip[1], 0));
            n1 = TransformsMaps.Load(int4(indices[i] * 4 + 1, nextFrame[1], clip[1], 0));
            n2 = TransformsMaps.Load(int4(indices[i] * 4 + 2, nextFrame[1], clip[1], 0));
            n3 = TransformsMaps.Load(int4(indices[i] * 4 + 3, nextFrame[1], clip[1], 0));
            next = matrix(n0, n1, n2, n3);
        
            nextAnim = lerp(curr, next, time[1]);
            
            currAnim = lerp(currAnim, nextAnim, TweenFrames[input.InstanceId].TweenTime);

        }
        
        transform += mul(weights[i], currAnim);
    }
    
    world = mul(transform, input.Transform);
}

struct BlendFrame
{
    uint Mode;
    float alpha;
    float2 Padding;
    
    AnimationFrame Clip[3];
};

cbuffer CB_BlendFrame
{
    BlendFrame BlendFrames[MAX_MODEL_INSTANCE];
};

void SetBlendWorld(inout matrix world, VertexModel input)
{
    float indices[4] = { input.BlendIndices.x, input.BlendIndices.y, input.BlendIndices.z, input.BlendIndices.w };
    float weights[4] = { input.BlendWeights.x, input.BlendWeights.y, input.BlendWeights.z, input.BlendWeights.w };

    float4 c0, c1, c2, c3;
    float4 n0, n1, n2, n3;
    
    matrix curr = 0, next = 0;
    matrix currAnim[3];
    
    matrix anim = 0;
    matrix transform = 0;
    
    BlendFrame frame = BlendFrames[input.InstanceId];
    
    [unroll(4)]
    for (int i = 0; i < 4; i++)
    {
        [unroll(3)]
        for (int k = 0; k < 3; k++)
        {
            c0 = TransformsMaps.Load(int4(indices[i] * 4 + 0, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
            c1 = TransformsMaps.Load(int4(indices[i] * 4 + 1, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
            c2 = TransformsMaps.Load(int4(indices[i] * 4 + 2, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
            c3 = TransformsMaps.Load(int4(indices[i] * 4 + 3, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
            curr = matrix(c0, c1, c2, c3);
        
            n0 = TransformsMaps.Load(int4(indices[i] * 4 + 0, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
            n1 = TransformsMaps.Load(int4(indices[i] * 4 + 1, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
            n2 = TransformsMaps.Load(int4(indices[i] * 4 + 2, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
            n3 = TransformsMaps.Load(int4(indices[i] * 4 + 3, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
            next = matrix(n0, n1, n2, n3);
        
            currAnim[k] = lerp(curr, next, frame.Clip[k].Time);
        }
        
        int clipA = (int) frame.alpha;
        int clipB = clipA + 1;
        clipB %= 3;
    
        float alpha = frame.alpha;
        if (alpha >= 1.0f)
        {
            alpha = frame.alpha - 1.0f;
        
            if (frame.alpha >= 2.0f)
            {
                clipA = 1;
                clipB = 2;
            }
        }
    
        anim = lerp(currAnim[clipA], currAnim[clipB], alpha);
        transform += mul(weights[i], anim);
    }
    
    world = mul(transform, input.Transform);
}


MeshOutput VS_Animation(VertexModel input)
{
    MeshOutput output;
    
    if (BlendFrames[input.InstanceId].Mode == 0)
        SetTweenWorld(World, input);
    else
        SetBlendWorld(World, input);
    
    VS_GENERATE
    
    return output;
}

