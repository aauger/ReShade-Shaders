#include "ReShade.fxh"

uniform int Levels
<
	ui_type = "input";
	ui_label = "Levels";
	ui_min = 1; ui_max = 1000;
	ui_tooltip = "Number of levels to separate colors into";
> = 7;

uniform float Amount
<
	ui_type = "input";
	ui_label = "Amount";
	ui_min = 0; ui_max = 1;
	ui_tooltip = "Amount of effect to apply";
> = .5;

float3 PosterizePass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	int bs = 255 / Levels;

	int bigR = (int)(color.r*255.0);
	int bigG = (int)(color.g*255.0);
	int bigB = (int)(color.b*255.0);

	int newR = (int)(round(bigR/(float)bs)*bs);
	int newG = (int)(round(bigG/(float)bs)*bs);
	int newB = (int)(round(bigB/(float)bs)*bs);

	float3 newColor = float3(newR/255.0, newG/255.0, newB/255.0);

	return lerp(color, newColor, Amount);
}

technique Posterize
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PosterizePass;
	}
}