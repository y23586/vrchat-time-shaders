Shader "VTS/NoonNight" {
    Properties {
	_Color ("Color", Color) = (1,1,1,1)
	_TexNoon ("Texture in daytime", 2D) = "white" {}
	_TexNight ("Texture in nighttime", 2D) = "white" {}
	_TexWP ("WebPanelRender", 2D) = "white" {}
	_Glossiness ("Smoothness", Range(0,1)) = 0.5
	_Metallic ("Metallic", Range(0,1)) = 0.0
	_SunriseHour ("Sunrise hour", Range(0,24)) = 6
	_SunsetHour ("Sunset hour", Range(0,24)) = 18
    }
    SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 100

	CGPROGRAM
	#pragma surface surf Standard fullforwardshadows
	#pragma target 3.0

	sampler2D _TexNoon, _TexNight, _TexWP;
	float _SunriseHour, _SunsetHour;

	struct Input {
	    float2 uv_TexNoon;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	UNITY_INSTANCING_CBUFFER_START(Props)
	UNITY_INSTANCING_CBUFFER_END

	void surf (Input IN, inout SurfaceOutputStandard o) {
	    const float2 x1 = {1.0/8, 0};
	    const float2 y1 = {0, 1.0/8};

	    const int3 hour0 = round(tex2D(_TexWP, x1*7.5+y1*0.5).rgb), hour1 = round(tex2D(_TexWP, x1*6.5+y1*0.5).rgb);
	    const int hour = hour0.r + hour0.g*2 + hour0.b*4 + hour1.r*8 + hour1.g*16 + hour1.b*32;

	    fixed4 c = ((hour >= _SunriseHour && hour < _SunsetHour) ? tex2D(_TexNoon, IN.uv_TexNoon) : tex2D(_TexNight, IN.uv_TexNoon)) * _Color;
	    o.Albedo = c;
	    o.Metallic = _Metallic;
	    o.Smoothness = _Glossiness;
	    o.Alpha = c.a;
	}
	ENDCG
    }
    FallBack "Diffuse"
}
