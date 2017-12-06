#include "ReShade.fxh"

static const int RADIUS = 8;

float3 Src(float a, float b, float2 tex) {
	return tex2D(ReShade::BackBuffer, mad(ReShade::PixelSize, float2(a, b), tex));
}

float Collapse(float3 inp)
{
	return inp.x + inp.y + inp.z;
}

int Median(int arr[42])
{
	int ldx, rdx, tot;
	ldx = 0;
	rdx = 41;
	tot = 0;

	for (int i = 0; i < 42; i++)
	{
		tot += arr[i];
	}

	while (tot > 0)
	{
		if (arr[ldx] > 0)
		{
			arr[ldx]--;
			tot--;
		}
		else
			ldx++;

		if(arr[rdx] > 0)
		{
			arr[rdx]--;
			tot--;
		}
		else
			rdx--;
	}

	return ldx;
}

float3 MedianPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	int rcolor[42];
	int gcolor[42];
	int bcolor[42];

	for(int i = 0; i < 42; i++)
	{
		rcolor[i] = 0;
		gcolor[i] = 0;
		bcolor[i] = 0;
	}

	[unroll]
	for (int xoff = -(RADIUS/2); xoff <= (RADIUS/2); xoff++)
	{
		[unroll]
		for (int yoff = -(RADIUS/2); yoff < (RADIUS/2); yoff++)
		{
			float3 color = Src(xoff, yoff, tex).rgb;
			int rc = (int)(color.r * 41.0);
			int gc = (int)(color.g * 41.0);
			int bc = (int)(color.b * 41.0);
			rcolor[rc]++;
			gcolor[gc]++;
			bcolor[bc]++;
		}
	}

	return float3( Median(rcolor)/41.0, Median(gcolor)/41.0, Median(bcolor)/41.0  );
}

technique MedianFilter
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MedianPass;
	}
}