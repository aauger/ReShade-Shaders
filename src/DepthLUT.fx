#include "ReShade.fxh"

texture FastVoronoi <source="FastVoronoi.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };

sampler sFastVoronoi { Texture = FastVoronoi; };

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

float3 DepthLUTPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float depth = ReShade::GetLinearizedDepth(tex);
	float3 loc = tex2D(sFastVoronoi, tex).rgb;
	float xoff = Map(loc.r, 0, 1, -128.0, 127);
	float yoff = Map(loc.g, 0, 1, -128.0, 127);
	float3 locColor = Src(ReShade::BackBuffer, xoff, yoff, tex);
	return lerp(color, locColor, (depth));
}

technique DepthLUT
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DepthLUTPass;
	}
}