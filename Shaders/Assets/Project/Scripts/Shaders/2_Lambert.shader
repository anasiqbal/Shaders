// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ai/Beginner/2_Lambert"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// custom variable
			uniform float4 _Color;

			// unity variables
			uniform float4 _LightColor0;

			struct vertIn
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertOut
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertOut vert (vertIn vIn)
			{
				vertOut o;

				float attenuation = 1.0;

				float3 normalDirection = normalize(mul(float4(vIn.normal, 0.0), unity_WorldToObject).xyz);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				float3 diffuseReflection = attenuation * _LightColor0.xyz * _Color.rgb *  max(0.0, dot(normalDirection, lightDirection));

				o.col = float4(diffuseReflection, 1.0);
				o.pos = UnityObjectToClipPos (vIn.vertex);

				return o;
			}

			float4 frag (vertOut vOut) : COLOR
			{
				return vOut.col;
			}

			ENDCG
		}
	}
}
