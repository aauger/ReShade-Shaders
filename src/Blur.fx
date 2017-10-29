#include "ReShade.fxh"

uniform int Area
<
	ui_type = "input";
	ui_label = "Area";
	ui_min = 1; ui_max = 30;
	ui_tooltip = "Area";
> = 5;

uniform int SkipSource
<
	ui_type = "input";
	ui_label = "Skip Source";
	ui_min = 0; ui_max = 1;
	ui_tooltip = "Skip source (center) pixel?";
> = 1;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float Clamp(float inp, float min, float max)
{
	if (inp < min)
		return min;
	if (inp > max)
		return max;
	return inp;
}

float3 BlurPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float rtot = 0;
	float gtot = 0;
	float btot = 0;
	float samples = 0; 

	for (float xoff = -Area; xoff <= Area; xoff += 1.0)
	{
		for (float yoff = -Area; yoff <= Area; yoff += 1.0)
		{
			if (yoff == 0.0 && xoff == 0.0 && SkipSource)
				continue;

			float3 colHere = Src(xoff, yoff, tex);

			rtot += colHere.r;
			gtot += colHere.g;
			btot += colHere.b;
			samples += 1.0;
		}
	}

	float3 newColor = float3(
			Clamp(rtot/samples, 0, 1),
			Clamp(gtot/samples, 0, 1),
			Clamp(btot/samples, 0, 1)
		);

	return newColor;
}

technique BlurFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = BlurPass;
	}
}