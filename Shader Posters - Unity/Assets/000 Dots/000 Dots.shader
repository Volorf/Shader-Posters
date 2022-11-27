Shader "Volorf/Shader Posters/000 Dots"
{
    Properties
    {
        [Header(Colors)]
        _MainColor("Main Color", Color) = (1, 0, 0, 1)
        _BackgroundColor("Background Color", Color) = (1, 1, 0, 1)
        
        [Header(Dot)]
        _EdgeSmoothness("Edge Smoothness", Float) = 0.01
        _MinRadius("Min Radius", Range (0.0, 0.5)) = 0.05
        _MaxRadius("Max Radius", Range (0.01, 0.5)) = 0.25
        
        [Header(Layout)]
        _GridDensity("Grid Density", Int) = 10
        _RandomSeed("Random Seed", Float) = 10000.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
            float _MinRadius;
            float _MaxRadius;
            int _GridDensity;
            float _RandomSeed;

            float circle(float2 pos, float rad)
            {
                float c = length(pos - float2(0.5, 0.5));
                float s = smoothstep(c - _EdgeSmoothness, c + _EdgeSmoothness, rad);
                return s;
            }

            int getIndex(float2 mPos)
            {
                return floor(mPos.x) + floor(mPos.y) + _GridDensity * floor(mPos.x); 
            }

            float getRandomFloat(int ind)
            {
                ind = ind * ind;
                return frac(sin(ind) * _RandomSeed);
            }

            float getRandomAnimatedFloat(int ind)
            {
                float pInd = pow(ind, 2);
                return (sin(pInd * _RandomSeed + _Time.z) + 1) / 2.0;
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
                float2 mUV = i.uv * _GridDensity;
                float2 fUV = frac(mUV);
                float colFac = circle(fUV, (_MaxRadius - _MinRadius) * getRandomAnimatedFloat(getIndex(mUV)) + _MinRadius);
                float4 fCol = lerp(_BackgroundColor, _MainColor, colFac);
                return fCol;
            }
            ENDCG
        }
    }
}
