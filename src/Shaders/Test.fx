#include "ReShade.fxh"

uniform int random_value < source = "random"; min = 0; max = 20; >;

float4 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float rand(in float2 uv)
{
    float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
    return abs(noise.x + noise.y) * 0.5;
}

// float4 TestPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
// {
// 	int2 pos = (int2)position.xy;
// 	if(any(pos % 20 == 0))
// 		return float4(1.0, 0, 0, 0);
// 	else
// 		return tex2D(ReShade::BackBuffer, tex);
// }



float4 TestPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float2 pos = (float2)position.xy;
	pos.x += (float)random_value;
	pos.y += (float)random_value;
	float rand_val = rand(pos);

	return Src(rand_val * 3, rand_val * 3, tex);
}

technique Test
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = TestPass;
	}
}