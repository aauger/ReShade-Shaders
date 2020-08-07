#include "ReShade.fxh"

uniform int Min
<
	ui_type = "input";
	ui_label = "Min";
	ui_min = 0; ui_max = 30;
	ui_tooltip = "Min";
> = 0;

uniform int Max
<
	ui_type = "input";
	ui_label = "Max";
	ui_min = 0; ui_max = 30;
	ui_tooltip = "Max";
> = 10;

static int Area = 5;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
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

float3 DOFPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float depth = ReShade::GetLinearizedDepth(tex);
	Area = (int)Map(depth, 0, 1, Min, Max);
	float rtot = color.r;
	float gtot = color.g;
	float btot = color.b;
	float samples = 1;

	if (Max <= Min)
		return color;

	[loop]
	for (int xoff = -Area; xoff <= Area; xoff++)
	{
		[loop]
		for (int yoff = -Area; yoff <= Area; yoff++)
		{
			if (xoff == 0 && yoff == 0)
				continue;

			float3 colHere = Src((float)xoff, (float)yoff, tex);

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

technique DOFFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DOFPass;
	}
}