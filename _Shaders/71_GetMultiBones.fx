#include "00_Global.fx"
#include "00_Light.fx"
#include "00_Render.fx"

struct WorldDesc
{
    matrix Transform;
};
StructuredBuffer<WorldDesc> InputWorlds;

struct BoneDesc
{
    matrix Transform;
};
StructuredBuffer<BoneDesc> InputBones;

RWTexture2DArray<float4> Output;


void SetTweenBones(inout matrix world, uint3 id)
{
    int Clip[2];
    int currFrame[2];
    int nextFrame[2];
    float time[2];
    
    Clip[0] = TweenFrames[id.y].Curr.clip;
    currFrame[0] = TweenFrames[id.y].Curr.CurrFrame;
    nextFrame[0] = TweenFrames[id.y].Curr.NextFrame;
    time[0] = TweenFrames[id.y].Curr.Time;
    
    Clip[1] = TweenFrames[id.y].Next.clip;
    currFrame[1] = TweenFrames[id.y].Next.CurrFrame;
    nextFrame[1] = TweenFrames[id.y].Next.NextFrame;
    time[1] = TweenFrames[id.y].Next.Time;
    
    
    
    float4 c0, c1, c2, c3;
    float4 n0, n1, n2, n3;
    
    matrix curr = 0, next = 0;
    matrix currAnim = 0;
    matrix nextAnim = 0;
    
    
    c0 = TransformsMaps.Load(int4(id.x * 4 + 0, currFrame[0], Clip[0], 0));
    c1 = TransformsMaps.Load(int4(id.x * 4 + 1, currFrame[0], Clip[0], 0));
    c2 = TransformsMaps.Load(int4(id.x * 4 + 2, currFrame[0], Clip[0], 0));
    c3 = TransformsMaps.Load(int4(id.x * 4 + 3, currFrame[0], Clip[0], 0));
    curr = matrix(c0, c1, c2, c3);
        
    n0 = TransformsMaps.Load(int4(id.x * 4 + 0, nextFrame[0], Clip[0], 0));
    n1 = TransformsMaps.Load(int4(id.x * 4 + 1, nextFrame[0], Clip[0], 0));
    n2 = TransformsMaps.Load(int4(id.x * 4 + 2, nextFrame[0], Clip[0], 0));
    n3 = TransformsMaps.Load(int4(id.x * 4 + 3, nextFrame[0], Clip[0], 0));
    next = matrix(n0, n1, n2, n3);
        
    currAnim = lerp(curr, next, time[0]);
        
        
    [flatten]
    if (Clip[1] > -1)
    {
        c0 = TransformsMaps.Load(int4(id.x * 4 + 0, currFrame[1], Clip[1], 0));
        c1 = TransformsMaps.Load(int4(id.x * 4 + 1, currFrame[1], Clip[1], 0));
        c2 = TransformsMaps.Load(int4(id.x * 4 + 2, currFrame[1], Clip[1], 0));
        c3 = TransformsMaps.Load(int4(id.x * 4 + 3, currFrame[1], Clip[1], 0));
        curr = matrix(c0, c1, c2, c3);
        
        n0 = TransformsMaps.Load(int4(id.x * 4 + 0, nextFrame[1], Clip[1], 0));
        n1 = TransformsMaps.Load(int4(id.x * 4 + 1, nextFrame[1], Clip[1], 0));
        n2 = TransformsMaps.Load(int4(id.x * 4 + 2, nextFrame[1], Clip[1], 0));
        n3 = TransformsMaps.Load(int4(id.x * 4 + 3, nextFrame[1], Clip[1], 0));
        next = matrix(n0, n1, n2, n3);
        
        nextAnim = lerp(curr, next, time[1]);
            
        currAnim = lerp(currAnim, nextAnim, TweenFrames[id.y].TweenTime);
    }
        
    
    world = mul(currAnim, world);
}

void SetBlendBones(inout matrix world, uint3 id)
{
    float4 c0, c1, c2, c3;
    float4 n0, n1, n2, n3;
    
    matrix curr = 0, next = 0;
    matrix currAnim[3];
    matrix anim = 0;
    
    BlendFrame frame = BlendFrames[id.y];
    
    
    
    [unroll(3)]
    for (int k = 0; k < 3; k++)
    {
        c0 = TransformsMaps.Load(int4(id.x * 4 + 0, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
        c1 = TransformsMaps.Load(int4(id.x * 4 + 1, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
        c2 = TransformsMaps.Load(int4(id.x * 4 + 2, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
        c3 = TransformsMaps.Load(int4(id.x * 4 + 3, frame.Clip[k].CurrFrame, frame.Clip[k].clip, 0));
        curr = matrix(c0, c1, c2, c3);
        
        n0 = TransformsMaps.Load(int4(id.x * 4 + 0, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
        n1 = TransformsMaps.Load(int4(id.x * 4 + 1, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
        n2 = TransformsMaps.Load(int4(id.x * 4 + 2, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
        n3 = TransformsMaps.Load(int4(id.x * 4 + 3, frame.Clip[k].NextFrame, frame.Clip[k].clip, 0));
        next = matrix(n0, n1, n2, n3);
        
        currAnim[k] = lerp(curr, next, frame.Clip[k].Time);
    }
       
    int clipA = (int) frame.alpha;
    int clipB = clipA + 1;
        
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
    
    world = mul(anim, world);
}

[numthreads(MAX_MODEL_TRANSFORMS, 1, 1)]
void CS(uint3 id : SV_DispatchThreadID)
{
    //기준본 * 애니메이션 * 월드
    
    matrix world = InputWorlds[id.y].Transform;
    
    if (BlendFrames[id.y].Mode == 0)
        SetTweenBones(world, id);
    else
        SetBlendBones(world, id);
    
    world = mul(InputBones[id.x].Transform, world);
    
    
    float4 m0 = world._11_12_13_14;
    float4 m1 = world._21_22_23_24;
    float4 m2 = world._31_32_33_34;
    float4 m3 = world._41_42_43_44;
    
    Output[int3(id.x * 4 + 0, id.y, id.z)] = m0;
    Output[int3(id.x * 4 + 1, id.y, id.z)] = m1;
    Output[int3(id.x * 4 + 2, id.y, id.z)] = m2;
    Output[int3(id.x * 4 + 3, id.y, id.z)] = m3;
}

technique11 T0
{
    pass P0
    {
        SetVertexShader(NULL);
        SetPixelShader(NULL);

        SetComputeShader(CompileShader(cs_5_0, CS()));
    }
}