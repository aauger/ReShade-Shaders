#include "ReShade.fxh"

float3 InvertPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float3 newColor = float3(1.0 - color.r,  1.0 - color.g,  1.0 - color.b);
	return newColor;
}

technique Invert
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = InvertPass;
	}
}