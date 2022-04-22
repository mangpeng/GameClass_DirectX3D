#include "00_Global.fx"
#include "00_Light.fx"
#include "00_Render.fx"


technique11 T0
{
    //1Pass - Depth Rendering
    P_VP(P0, VS_Depth_Mesh, PS_Depth)
    P_VP(P1, VS_Depth_Model, PS_Depth)
    P_VP(P2, VS_Depth_Animation, PS_Depth)
}