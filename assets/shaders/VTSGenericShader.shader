Shader "VTS/GenericShader" {
    Properties {
	_Color ("Color", Color) = (1,1,1,1)
	_Tex ("Texture", 2D) = "white" {}
	_TexWP ("WebPanelRender", 2D) = "white" {}
	_Glossiness ("Smoothness", Range(0,1)) = 0.5
	_Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 100

	CGPROGRAM
	#pragma surface surf Standard fullforwardshadows
	#pragma target 3.0

	sampler2D _Tex, _TexWP;

	struct Input {
	    float2 uv_Tex;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	UNITY_INSTANCING_CBUFFER_START(Props)
	UNITY_INSTANCING_CBUFFER_END

	void surf (Input IN, inout SurfaceOutputStandard o) {
	    const float2 x1 = {1.0/8, 0};
	    const float2 y1 = {0, 1.0/8};

	    const int3  hour0 = round(tex2D(_TexWP, x1*7.5+y1*0.5).rgb),  hour1 = round(tex2D(_TexWP, x1*6.5+y1*0.5).rgb);
	    const int3   min0 = round(tex2D(_TexWP, x1*5.5+y1*0.5).rgb),   min1 = round(tex2D(_TexWP, x1*4.5+y1*0.5).rgb);
	    const int3   sec0 = round(tex2D(_TexWP, x1*3.5+y1*0.5).rgb),   sec1 = round(tex2D(_TexWP, x1*2.5+y1*0.5).rgb);
	    const int3    ms0 = round(tex2D(_TexWP, x1*1.5+y1*0.5).rgb),    ms1 = round(tex2D(_TexWP, x1*0.5+y1*0.5).rgb);
	    const int3  year0 = round(tex2D(_TexWP, x1*7.5+y1*1.5).rgb),  year1 = round(tex2D(_TexWP, x1*6.5+y1*1.5).rgb), year2 = round(tex2D(_TexWP, x1*5.5+y1*1.5).rgb);
	    const int3 month0 = round(tex2D(_TexWP, x1*4.5+y1*1.5).rgb), month1 = round(tex2D(_TexWP, x1*3.5+y1*1.5).rgb);
	    const int3  date0 = round(tex2D(_TexWP, x1*2.5+y1*1.5).rgb),  date1 = round(tex2D(_TexWP, x1*1.5+y1*1.5).rgb);
	    const int3   day0 = round(tex2D(_TexWP, x1*0.5+y1*1.5).rgb);
	    const int3   age0 = round(tex2D(_TexWP, x1*7.5+y1*2.5).rgb),   age1 = round(tex2D(_TexWP, x1*6.5+y1*2.5).rgb);

	    const int hour   = hour0.r + hour0.g*2 + hour0.b*4 + hour1.r*8 + hour1.g*16 + hour1.b*32;
	    const int minute =  min0.r +  min0.g*2 +  min0.b*4 +  min1.r*8 +  min1.g*16 +  min1.b*32;
	    const int sec    =  sec0.r +  sec0.g*2 +  sec0.b*4 +  sec1.r*8 +  sec1.g*16 +  sec1.b*32;
	    const int ms     =(  ms0.r +   ms0.g*2 +   ms0.b*4 +   ms1.r*8 +   ms1.g*16 +   ms1.b*32)*1000.0/64;
	    const int year   = year0.r + year0.g*2 + year0.b*4 + year1.r*8 + year1.g*16 + year1.b*32 + year2.r*64 + year2.g*128 + year2.b*256 + 1900;
	    const int month  =month0.r +month0.g*2 +month0.b*4 +month1.r*8 +month1.g*16 +month1.b*32 + 1;
	    const int date   = date0.r + date0.g*2 + date0.b*4 + date1.r*8 + date1.g*16 + date1.b*32 + 1;
	    const int day    =  day0.r +  day0.g*2 +  day0.b*4;
	    const int age    =  age0.r +  age0.g*2 +  age0.b*4 +  age1.r*8 +  age1.g*16 +  age1.b*32;

	    fixed4 c = tex2D(_Tex, IN.uv_Tex) * _Color;
	    o.Albedo = c;
	    o.Metallic = _Metallic;
	    o.Smoothness = _Glossiness;
	    o.Alpha = c.a;
	}
	ENDCG
    }
    FallBack "Diffuse"
}
