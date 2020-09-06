#include "ReShade.fxh"

uniform int RandomValue < source = "random"; min = 0; max = 20; >;
uniform float Multiplier
<
	ui_type = "input";
	ui_label = "Distance multiplier";
	ui_min = 1.0;
	ui_tooltip = "Multiplier for the random distance";
> = 3.0;

float4 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float rand(in float2 uv)
{
    float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
    return abs(noise.x + noise.y) * 0.5;
}

float4 FuzzerPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float2 pos = (float2)position.xy;
	pos.x += (float)RandomValue;
	pos.y += (float)RandomValue;
	float rand_val = rand(pos);

	return Src(rand_val * Multiplier, rand_val * Multiplier, tex);
}

technique Test
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = FuzzerPass;
	}
}
