#include "ReShade.fxh"

static const int RADIUS = 6;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float3 MaxPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{	
	float3 colors[RADIUS*RADIUS];
	int x = 0, y = 0;

	for (int xoff = -(RADIUS/2); xoff <= (RADIUS/2); xoff++)
	{
		for (int yoff = -(RADIUS/2); yoff < (RADIUS/2); yoff++)
		{
			colors[x + (y * RADIUS)] = Src(xoff, yoff, tex);
			y++;
		}
		y = 0;
		x++;
	}

	float3 maximum = colors[0];
	for (int i = 1; i < RADIUS*RADIUS; i++)
	{
		if ( all(colors[i] > maximum) )
			maximum = colors[i];
	}

	return maximum;
}

technique Maximum
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MaxPass;
	}
}