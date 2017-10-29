#include "ReShade.fxh"

uniform int Area
<
	ui_type = "input";
	ui_label = "Area";
	ui_min = 1; ui_max = 8;
	ui_tooltip = "Area";
> = 5;

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

float Collapse(float3 color)
{
	return color.x + color.y + color.z;
}

float3 ConservativePass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float3 min = color;
	float3 max = color;

	for (float xoff = -Area; xoff <= Area; xoff += 1.0)
	{
		for (float yoff = -Area; yoff <= Area; yoff += 1.0)
		{
			if (yoff == 0.0 && xoff == 0.0)
				continue;

			float3 colHere = Src(xoff, yoff, tex);

			float colHereCollapse = Collapse(colHere);
			float minCollapse = Collapse(min);
			float maxCollapse = Collapse(max);

			if (colHereCollapse < minCollapse)
				min = colHere;

			if (colHereCollapse > maxCollapse)
				max = colHere;
		}
	}

	float3 newColor = float3(Clamp(color.r, min.r, max.r), 
		Clamp(color.g, min.g, max.g),
		Clamp(color.b, min.b, max.b));

	return newColor;
}

technique ConservativeFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = ConservativePass;
	}
}