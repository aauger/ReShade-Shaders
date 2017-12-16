#include "ReShade.fxh"

static const int RADIUS = 6;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float3 MinPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
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

	float3 minimum = colors[0];
	for (int i = 1; i < RADIUS*RADIUS; i++)
	{
		if ( all(colors[i] < minimum) )
			minimum = colors[i];
	}

	return minimum;
}

technique Minimum
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MinPass;
	}
}