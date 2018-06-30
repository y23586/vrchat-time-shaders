Shader "VTS/DigitalClock" {
    Properties {
	_Color ("Color", Color) = (1,1,1,1)
	_TexChars ("Characters", 2D) = "white" {}
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

	sampler2D _TexChars, _TexWP;

	struct Input {
	    float2 uv_TexChars;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	float _Cutoff;

	UNITY_INSTANCING_CBUFFER_START(Props)
	UNITY_INSTANCING_CBUFFER_END

	void surf (Input IN, inout SurfaceOutputStandard o) {
	    const float2 uv = IN.uv_TexChars;
	    const float2 uvchar = {fmod(uv.x*8, 1), uv.y};

	    const float2 x1 = {1.0/8, 0};
	    const float2 y1 = {0, 1.0/8};

	    const int hmsWhich = uv.x/(1.0/8*3);

	    const int3 hms0 = round(tex2D(_TexWP, x1*(7.5-hmsWhich*2)+y1*0.5).rgb);
	    const int3 hms1 = round(tex2D(_TexWP, x1*(6.5-hmsWhich*2)+y1*0.5).rgb);

	    const int hms = hms0.r + hms0.g*2 + hms0.b*4 + hms1.r*8 + hms1.g*16 + hms1.b*32;
	    const int hmsd = (((int) (uv.x*8))%3) == 0 ? hms/10 : hms%10;

	    float2 uv0 = {(hmsd%8+uvchar.x)/8, 1-(floor(hmsd/8.0)+1-uvchar.y)/2};
	    const float2 uvcoron = {uvchar.x/8-(5.0+((int)_Time.y%2))/8, uvchar.y/2};
	    uv0 = (((int) (uv.x*8))%3) == 2 ? uvcoron : uv0;

	    fixed4 c = tex2D(_TexChars, uv0);
	    clip(c.a-_Cutoff);
	    o.Albedo = c.rgb;
	    o.Metallic = _Metallic;
	    o.Smoothness = _Glossiness;
	    const float clipThreshold = 0.01;
	    o.Alpha = c.a * ceil(uvchar.xy-clipThreshold) * ceil((1-uvchar.xy)-clipThreshold);
	}
	ENDCG
    }
    FallBack "Diffuse"
}
