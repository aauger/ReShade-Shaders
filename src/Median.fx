#include "ReShade.fxh"

static const int RADIUS = 6;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float Collapse(float3 inp)
{
	return inp.x + inp.y + inp.z;
}

float3 MedianPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
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

	[unroll]
	for(int tmax = (RADIUS*RADIUS) - 2; tmax > 2; tmax -= 2)
	{
		int minInd, maxInd;
		minInd = 0;
		maxInd = 0;

		[unroll]
		for(int i = 1; i < tmax; i++)
		{
			if ( all(colors[i] < colors[minInd]) )
				minInd = i;
			if ( all(colors[i] > colors[maxInd]) )
				maxInd = i;
		}

		colors[minInd] = colors[tmax];
		colors[maxInd] = colors[tmax+1];
	}

	return colors[0];
}

technique MedianFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MedianPass;
	}
}