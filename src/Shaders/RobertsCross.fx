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

float3 RobertsCrossPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 tl = Src(ReShade::BackBuffer, -1, -1, tex);
	float3 bl = Src(ReShade::BackBuffer, -1,  1, tex);

	float3 tr = Src(ReShade::BackBuffer,  1, -1, tex);
	float3 br = Src(ReShade::BackBuffer,  1,  1, tex);

	float3 gx = (1 * tl) + (-1 * br);
	float3 gy = (1 * tr) + (-1 * bl);

	float3 ret = sqrt((pow(gx,2) + pow(gx,2)));

	return ret;
}

technique RobertsCross
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = RobertsCrossPass;
	}
}