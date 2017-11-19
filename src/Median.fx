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
	float3 colors[RADIUS*RADIUS];
	int x = 0, y = 0;

	for (int xoff = -(RADIUS/2); xoff <= (RADIUS/2); xoff++)
	{
		for (int yoff = -(RADIUS/2); yoff < (RADIUS/2); yoff++)
		{
			colors[x + (y * RADIUS)] = Src(xoff, yoff, tex);
			y++;
		}
		x++;
		y = 0;
	}

	for (int i = 0; i <= (RADIUS*RADIUS)/2; i++)
	{
		int minIndex = i;
		float3 minValue = colors[i];
		for (int j = i+1; j < (RADIUS*RADIUS); j++)
		{
			if ( Collapse(colors[j]) < Collapse(minValue) )
			{
				minIndex = j;
				minValue = colors[j];
			}
		}
		colors[minIndex] = colors[i];
		colors[i] = minValue;
	}

	return colors[(RADIUS*RADIUS)/2];
}

technique MedianFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MedianPass;
	}
}