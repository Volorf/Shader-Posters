Shader "Unlit/000 Dots"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1, 0, 0, 1)
        _BackgroundColor("Background Color", Color) = (1, 1, 0, 1)
        _EdgeSmoothness("Edge Smoothness", Float) = 0.01
        _Radius("Radius", Range (0.01, 0.5)) = 0.25
        _Density("Density", Int) = 10
        _RandomMultiplier("Random Multiplier", Float) = 10000.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;
            float4 _BackgroundColor;
            float _EdgeSmoothness;
            float _Radius;
            int _Density;
            float _RandomMultiplier;

            float circle(float2 pos, float rad)
            {
                float c = length(pos - float2(0.5, 0.5));
                float s = smoothstep(c - _EdgeSmoothness, c + _EdgeSmoothness, rad);
                // float s = step(rad, c);
                return s;
            }

            int getIndex(float2 mPos)
            {
                return floor(mPos.x) + floor(mPos.y) + _Density * floor(mPos.x); 
            }

            float getRandomFloat(int ind)
            {
                return frac(sin(ind) * _RandomMultiplier);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 mUV = i.uv * _Density;
                float2 fUV = frac(mUV);
                float colFac = circle(fUV, _Radius * getRandomFloat(getIndex(mUV)));
                float4 fCol = lerp(_MainColor, _BackgroundColor, colFac);
                return fCol;
            }
            ENDCG
        }
    }
}
