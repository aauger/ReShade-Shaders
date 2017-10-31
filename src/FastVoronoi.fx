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

float3 VoronoiPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(sFastVoronoi, tex).rgb;
	float xoff = Map(color.r, 0, 1, -128.0, 127);
	float yoff = Map(color.g, 0, 1, -128.0, 127);
	float3 newColor = Src(ReShade::BackBuffer, xoff, yoff, tex) * (1-color.b);
	return newColor;
}

technique FastVoronoi
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = VoronoiPass;
	}
}