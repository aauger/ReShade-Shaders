#include "ReShade.fxh"

uniform float Start
<
	ui_type = "input";
	ui_label = "Start";
	ui_min = 0; ui_max = 1;
	ui_tooltip = "Start";
> = 0.0;

uniform float End
<
	ui_type = "input";
	ui_label = "End";
	ui_min = 0; ui_max = 1;
	ui_tooltip = "End";
> = 0.03;

////
// The following functions for color space conversion
// were sourced from: http://www.chilliant.com/rgb2hsv.html
// building off the work of Sam Hocevar, Emil Persson, and Ian Taylor (Chilli Ant)
////

float3 HUEtoRGB(in float H)
{
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);
	return saturate(float3(R,G,B));
}

float3 HSVtoRGB(in float3 HSV)
{
	float3 RGB = HUEtoRGB(HSV.x);
	return ((RGB - 1) * HSV.y + 1) * HSV.z;
}

float Epsilon = 1e-10;
float3 RGBtoHCV(in float3 RGB)
{
	// Based on work by Sam Hocevar and Emil Persson
	float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
	float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
	float C = Q.x - min(Q.w, Q.y);
	float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
	return float3(H, C, Q.x);
}

float3 RGBtoHSV(in float3 RGB)
{
	float3 HCV = RGBtoHCV(RGB);
	float S = HCV.y / (HCV.z + Epsilon);
	return float3(HCV.x, S, HCV.z);
}

float3 SinCityPass(float4 position : SV_Position, float2 tex : TEXCOORD) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, tex).rgb;
	float3 HSVColor = RGBtoHSV(color);
	if (HSVColor.x < Start || HSVColor.x > End)
	{
		HSVColor.y = 0;
	}
	return HSVtoRGB(HSVColor);
}

technique SinCity
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = SinCityPass;
	}
}