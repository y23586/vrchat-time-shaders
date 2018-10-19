Shader "VTS/Skybox" {
    Properties {
        _CubeNoon ("Noon", Cube) = "white" {}
        _CubeNight ("Night", Cube) = "white" {}
        _CubeSunset ("Sunset", Cube) = "white" {}
        _TexWP ("WebPanelRender", 2D) = "white" {}
        _SunriseHour ("Sunrise hour", Range(0,24)) = 6
        _SunsetHour ("Sunset hour", Range(0,24)) = 18
        _ChangeHour ("Time to change color in hours", Range(0,10)) = 0.5
        [MaterialToggle] _IsPanorama ("Panorama", Float) = 1.0
    }

    SubShader {
        Tags { "Queue"="Background" }

        Pass {
            ZWrite Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            samplerCUBE _CubeNoon, _CubeNight, _CubeSunset;
            sampler2D _TexWP;
            float _SunriseHour, _SunsetHour, _ChangeHour;
            int _IsPanorama;

            struct vertexInput {
                float4 vertex : POSITION;
                float3 texcoord : TEXCOORD0;
            };

            struct vertexOutput {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
            };

            vertexOutput vert(vertexInput input) {
                vertexOutput output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.texcoord = input.texcoord;
                return output;
            }

            fixed4 frag (vertexOutput input) : COLOR {
                const float2 x1 = {1.0/8, 0};
                const float2 y1 = {0, 1.0/8};

                const int3  min0 = round(tex2D(_TexWP, x1*5.5+y1*0.5).rgb),  min1 = round(tex2D(_TexWP, x1*4.5+y1*0.5).rgb);
                const int3 hour0 = round(tex2D(_TexWP, x1*7.5+y1*0.5).rgb), hour1 = round(tex2D(_TexWP, x1*6.5+y1*0.5).rgb);
                const float minute =  min0.r +  min0.g*2 +  min0.b*4 +  min1.r*8 +  min1.g*16 +  min1.b*32 + (_IsPanorama ? _Time.y : 0)/60.0;
                const float hour   = hour0.r + hour0.g*2 + hour0.b*4 + hour1.r*8 + hour1.g*16 + hour1.b*32 + minute/60;

                float pNoon = 0, pNight = 0, pSunset = 0;
                if(hour <= _SunriseHour-_ChangeHour) {
                    pNight = 1;
                } else if(hour <= _SunriseHour) {
                    pSunset = (hour-(_SunriseHour-_ChangeHour)) / _ChangeHour;
                    pNight = 1-pSunset;
                } else if(hour <= _SunriseHour+_ChangeHour) {
                    pNoon = (hour-_SunriseHour) / _ChangeHour;
                    pSunset = 1-pNoon;
                } else if(hour <= _SunsetHour-_ChangeHour) {
                    pNoon = 1;
                } else if(hour <= _SunsetHour) {
                    pSunset = (hour-(_SunsetHour-_ChangeHour)) / _ChangeHour;
                    pNoon = 1-pSunset;
                } else if(hour <= _SunsetHour+_ChangeHour) {
                    pNight = (hour-_SunsetHour) / _ChangeHour;
                    pSunset = 1-pNight;
                } else {
                    pNight = 1;
                }


                fixed4 cNoon  = texCUBE (_CubeNoon,   input.texcoord);
                fixed4 cNight = texCUBE (_CubeNight,  input.texcoord);
                fixed4 cSunset= texCUBE (_CubeSunset, input.texcoord);
                return cNoon*pNoon+cNight*pNight+cSunset*pSunset;
            }
            ENDCG
        }
    }
}
