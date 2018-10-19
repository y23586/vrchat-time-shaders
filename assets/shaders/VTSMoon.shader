Shader "VTS/Moon" {
    Properties {
        _TexMoons ("Moons", 2D) = "white" {}
        _TexWP ("WebPanelRender", 2D) = "white" {}
        [MaterialToggle] _IsPanorama ("Panorama", Float) = 1.0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _TexMoons, _TexWP;
            float4 _TexMoons_ST;
            int _IsPanorama;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _TexMoons);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                const float2 x1 = {1.0/8, 0};
                const float2 y1 = {0, 1.0/8};

                const int3 age0 = round(tex2D(_TexWP, x1*7.5+y1*2.5).rgb);
                const int3 age1 = round(tex2D(_TexWP, x1*6.5+y1*2.5).rgb);

                // TODO: support Panorama
                int age = age0.r + age0.g*2 + age0.b*4 + age1.r*8 + age1.g*16 + age1.b*32;
                const int moonId = age/30.0*16;
                const float2 uv = {1-((moonId%8)/8.0+i.uv.x/8), (moonId/8)/2.0+i.uv.y/2};

                return tex2D (_TexMoons, uv);
            }
            ENDCG
        }
    }
}
