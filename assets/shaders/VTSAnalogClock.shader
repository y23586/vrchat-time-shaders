Shader "VTS/AnalogClock" {
    Properties {
	_Color ("Color", Color) = (1,1,1,1)
	_TexHour ("Hour", 2D) = "white" {}
	_TexMin ("Minute", 2D) = "white" {}
	_TexSec ("Second", 2D) = "white" {}
	_TexWP ("WebPanelRender", 2D) = "white" {}
	_Glossiness ("Smoothness", Range(0,1)) = 0.5
	_Metallic ("Metallic", Range(0,1)) = 0.0
	_Cutoff ("Cutoff", Range(0,1)) = 0.5
    }
    SubShader {
	Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha

	CGPROGRAM
	#pragma surface surf Standard fullforwardshadows alpha
	#pragma target 3.0

	sampler2D _TexHour, _TexMin, _TexSec, _TexWP;

	struct Input {
	    float2 uv_TexHour;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	float _Cutoff;

	UNITY_INSTANCING_CBUFFER_START(Props)
	UNITY_INSTANCING_CBUFFER_END

	void surf (Input IN, inout SurfaceOutputStandard o) {
	    const float2 uvo = IN.uv_TexHour - 0.5;
	    clip(0.25-(uvo.x*uvo.x+uvo.y*uvo.y));

	    const float2 x1 = {1.0/8, 0};
	    const float2 y1 = {0, 1.0/8};

	    const int3  sec0 = round(tex2D(_TexWP, x1*3.5+y1*0.5).rgb),  sec1 = round(tex2D(_TexWP, x1*2.5+y1*0.5).rgb);
	    const int3  min0 = round(tex2D(_TexWP, x1*5.5+y1*0.5).rgb),  min1 = round(tex2D(_TexWP, x1*4.5+y1*0.5).rgb);
	    const int3 hour0 = round(tex2D(_TexWP, x1*7.5+y1*0.5).rgb), hour1 = round(tex2D(_TexWP, x1*6.5+y1*0.5).rgb);

	    const float sec    =  sec0.r +  sec0.g*2 +  sec0.b*4 +  sec1.r*8 +  sec1.g*16 +  sec1.b*32;
	    const float minute =  min0.r +  min0.g*2 +  min0.b*4 +  min1.r*8 +  min1.g*16 +  min1.b*32 +    sec/60;
	    const float hour   = hour0.r + hour0.g*2 + hour0.b*4 + hour1.r*8 + hour1.g*16 + hour1.b*32 + minute/60;

	    const float sinhour = sin(  hour/12.0*2*UNITY_PI), coshour = cos(  hour/12.0*2*UNITY_PI);
	    const float sinmin  = sin(minute/60.0*2*UNITY_PI), cosmin  = cos(minute/60.0*2*UNITY_PI);
	    const float sinsec  = sin(   sec/60.0*2*UNITY_PI), cossec  = cos(   sec/60.0*2*UNITY_PI);

	    const float2 uvhour = {uvo.x * coshour - uvo.y * sinhour, uvo.x * sinhour + uvo.y * coshour};
	    const float2 uvmin  = {uvo.x * cosmin  - uvo.y * sinmin,  uvo.x * sinmin  + uvo.y * cosmin };
	    const float2 uvsec  = {uvo.x * cossec  - uvo.y * sinsec,  uvo.x * sinsec  + uvo.y * cossec };

	    const fixed4 chour = tex2D (_TexHour, uvhour + 0.5);
	    const fixed4 cmin  = tex2D (_TexMin,  uvmin  + 0.5);
	    const fixed4 csec  = tex2D (_TexSec,  uvsec  + 0.5);

	    fixed4 c = cmin;
	    c.rgb = c.rgb * clamp(c.a-chour.a,0,1) + chour.rbg * chour.a; c.a = max(cmin.a,  chour.a);
	    c.rgb = c.rgb * clamp(c.a- csec.a,0,1) +  csec.rbg *  csec.a; c.a = max(   c.a,   csec.a);
	    clip(c.a-_Cutoff);

	    o.Albedo = c.rgb;
	    o.Metallic = _Metallic;
	    o.Smoothness = _Glossiness;
	    o.Alpha = c.a;
	}
	ENDCG
    }
    FallBack "Diffuse"
}
