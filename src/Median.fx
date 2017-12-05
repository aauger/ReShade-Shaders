#include "ReShade.fxh"

static const int RADIUS = 8;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float Collapse(float3 inp)
{
	return inp.x + inp.y + inp.z;
}

float3 MedianPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float ETA = 1/(float)(RADIUS*RADIUS);
	float rmean = 0;
	float rmedian = 0;
	float gmean = 0;
	float gmedian = 0;
	float bmean = 0;
	float bmedian = 0;

	[unroll]
	for (int xoff = -(RADIUS/2); xoff <= (RADIUS/2); xoff++)
	{
		[unroll]
		for (int yoff = -(RADIUS/2); yoff < (RADIUS/2); yoff++)
		{
			float3 color = Src(xoff, yoff, tex).rgb;
			rmean += ETA * (color.r - rmean);
			rmedian += ETA * sign(color.r - rmedian);
			gmean += ETA * (color.g - gmean);
			gmedian += ETA * sign(color.g - gmedian);
			bmean += ETA * (color.b - bmean);
			bmedian += ETA * sign(color.b - bmedian);
		}
	}

	return float3(rmedian, gmedian, bmedian);
}

technique MedianFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MedianPass;
	}
}