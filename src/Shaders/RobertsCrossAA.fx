#include "ReShade.fxh"

uniform float Thresh
<
	ui_type = "input";
	ui_label = "Thresh";
	ui_min = 0; ui_max = 1;
	ui_tooltip = "Thresh";
> = .5;

float3 Src(sampler samp, float a, float b, float2 tex) {
	return tex2D(samp, mad(ReShade::PixelSize, float2(a, b), tex));
}

float3 BW(float3 col)
{
	float nval = (col.r + col.r + col.b)/3;
	return float3(nval, nval, nval);
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

float3 RobertsCrossMaskPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 tl = BW(Src(ReShade::BackBuffer, -1, -1, tex));
	float3 bl = BW(Src(ReShade::BackBuffer, -1,  1, tex));

	float3 tr = BW(Src(ReShade::BackBuffer,  1, -1, tex));
	float3 br = BW(Src(ReShade::BackBuffer,  1,  1, tex));

	float3 gx = (1 * tl) + (-1 * br);
	float3 gy = (1 * tr) + (-1 * bl);

	float3 nc = sqrt((pow(gx,2) + pow(gx,2)));

	if (nc.r > Thresh)
		return float3(0,0,255.0);
	else
		return Src(ReShade::BackBuffer,  0,  0, tex);
}

float3 RobertsCrossFullPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 hm = Src(ReShade::BackBuffer,  0,  0, tex);
	float3 tl = Src(ReShade::BackBuffer, -1, -1, tex);
	float3 bl = Src(ReShade::BackBuffer, -1,  1, tex);

	float3 tr = Src(ReShade::BackBuffer,  1, -1, tex);
	float3 br = Src(ReShade::BackBuffer,  1,  1, tex);

	float3 gx = (1 * BW(tl)) + (-1 * BW(br));
	float3 gy = (1 * BW(tr)) + (-1 * BW(bl));

	float3 nc = sqrt((pow(gx,2) + pow(gx,2)));

	if (nc.r > Thresh)
		return ((hm + tl + bl + tr + br) / float3(5.0,5.0,5.0));
	else
		return hm;
}

technique RobertsCrossMask
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = RobertsCrossMaskPass;
	}
}

technique RobertsCrossFull
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = RobertsCrossFullPass;
	}
}