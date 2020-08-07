#include "ReShade.fxh"

texture prevTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };
sampler prevColor { Texture = prevTex; };

float4 BlendFrames(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 curr = tex2D(ReShade::BackBuffer, texcoord);
	float4 prev = tex2D(prevColor, texcoord);

	float4 new_color = (curr + prev) / 2;

	return new_color;
}

float4 CopyFrame(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	return tex2D(ReShade::BackBuffer, texcoord);
}

technique MotionBlur
{
	pass BlendFrames
	{
		VertexShader = PostProcessVS;
		PixelShader = BlendFrames;
	}
	pass CopyFrame
	{
		VertexShader = PostProcessVS;
		PixelShader = CopyFrame;
		RenderTarget = prevTex;
	}
}