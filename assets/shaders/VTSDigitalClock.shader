Shader "VTS/DigitalClock" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Emissive ("Emission", Color) = (0,0,0,1)
        _TexChars ("Characters", 2D) = "white" {}
        _TexWP ("WebPanelRender", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Cutoff ("Cutoff", Range(0,1)) = 0.5
        [MaterialToggle] _IsPanorama ("Panorama", Float) = 1.0
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
        fixed4 _Emissive;
        float _Cutoff;
        int _IsPanorama;

        UNITY_INSTANCING_CBUFFER_START(Props)
        UNITY_INSTANCING_CBUFFER_END

        void surf (Input IN, inout SurfaceOutputStandard o) {
            const float2 uv = IN.uv_TexChars;
            const float2 uvchar = {fmod(uv.x*8, 1), uv.y};

            const float2 x1 = {1.0/8, 0};
            const float2 y1 = {0, 1.0/8};

            const int hmsWhich = uv.x/(1.0/8*3);

            const int3   sec0 = round(tex2D(_TexWP, x1*3.5+y1*0.5).rgb),   sec1 = round(tex2D(_TexWP, x1*2.5+y1*0.5).rgb);
            const int3   min0 = round(tex2D(_TexWP, x1*5.5+y1*0.5).rgb),   min1 = round(tex2D(_TexWP, x1*4.5+y1*0.5).rgb);
            const int3  hour0 = round(tex2D(_TexWP, x1*7.5+y1*0.5).rgb),  hour1 = round(tex2D(_TexWP, x1*6.5+y1*0.5).rgb);

            const float secf    =  sec0.r +  sec0.g*2 +  sec0.b*4 +  sec1.r*8 +  sec1.g*16 +  sec1.b*32 + (_IsPanorama ? _Time.y : 0);
            const float minutef =  min0.r +  min0.g*2 +  min0.b*4 +  min1.r*8 +  min1.g*16 +  min1.b*32 + secf/60.0;
            const float hourf   = hour0.r + hour0.g*2 + hour0.b*4 + hour1.r*8 + hour1.g*16 + hour1.b*32 + minutef/60.0;

            const int sec    = ((int) secf)%60;
            const int minute = ((int) minutef)%60;
            const int hour   = ((int) hourf)%24;

            const int hms = (hmsWhich == 0 ? hour : (hmsWhich == 1 ? minute : sec));
            const int hmsd = (((int) (uv.x*8))%3) == 0 ? hms/10 : hms%10;

            float2 uv0 = {(hmsd%8+uvchar.x)/8, 1-(floor(hmsd/8.0)+1-uvchar.y)/2};
            const float2 uvcoron = {uvchar.x/8-(5.0+((int)_Time.y%2))/8, uvchar.y/2};
            uv0 = (((int) (uv.x*8))%3) == 2 ? uvcoron : uv0;

            fixed4 c = tex2D(_TexChars, uv0);
            clip(c.a-_Cutoff);
            o.Albedo = c.rgb;
            o.Emission = (_Emissive*((c.r + c.g + c.b)/3));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            const float clipThreshold = 0.01;
            o.Alpha = c.a * ceil(uvchar.xy-clipThreshold) * ceil((1-uvchar.xy)-clipThreshold);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
