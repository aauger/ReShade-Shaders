#include "ReShade.fxh"

float3 Src(sampler samp, float a, float b, float2 tex) {
	return tex2D(samp, mad(ReShade::PixelSize, float2(a, b), tex));
}

float Map(float x, float in_min, float in_max, float out_min, float out_max)
{
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

float Clamp(float inp, float min, float max)
{
	if (inp < min)
		return min;
	if (inp > max)
		return max;
	return inp;
}

float3 DepthInvertPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float3 inv = float3(1 - color.r, 1 - color.g, 1 - color.b);
	float depth = ReShade::GetLinearizedDepth(tex);
	return lerp(color, inv, (depth));
}

technique DepthInvert
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthInvertPass;
	}
}