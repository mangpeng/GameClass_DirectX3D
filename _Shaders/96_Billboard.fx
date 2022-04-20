#include "00_Global.fx"
#include "00_Light.fx"
#include "00_Render.fx"

float4 PS(MeshOutput input) : SV_Target
{
    return PS_AllLight(input);
}

////////////////////////////////////////////////////////////////////////////////////////////

struct VertexBillboard
{
    float4 Position : Position;
    float2 Scale : Scale;
};

struct VertexOutput
{
    float4 Position : Position;
    float2 Scale : Scale; 
};

VertexOutput VS(VertexInput input)
{
    VertexOutput output;
    
    output.Position = WorldPosition(input.Position);
    output.Scale = input.Scale;
    
    return output;
}

technique11 T0
{
    P_DSS_BS_VP(P0, DepthRead_Particle, OpaqueBlend, VS, PS)
    P_DSS_BS_VP(P1, DepthRead_Particle, AdditiveBlend_Particle, VS, PS)
    P_DSS_BS_VP(P2, DepthRead_Particle, AlphaBlend, VS, PS)
}