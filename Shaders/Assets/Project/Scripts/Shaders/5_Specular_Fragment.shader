﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ai/Beginner/5_Specular_Fragment"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", float) = 10
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
			uniform float4 _SpecColor;
			uniform float _Shininess;

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
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
			};

			vertOut vert (vertIn vIn)
			{
				vertOut o;

				o.posWorld = mul (unity_ObjectToWorld, vIn.vertex);
				o.normalDir = normalize (mul (float4 (vIn.normal, 0.0), unity_WorldToObject).xyz);

				o.pos = UnityObjectToClipPos (vIn.vertex);
				return o;
			}

			float4 frag (vertOut vOut) : COLOR
			{
				float attenuation = 1.0;

				float3 normalDirection = vOut.normalDir;
				float3 viewDirection = normalize (_WorldSpaceCameraPos.xyz - vOut.posWorld.xyz);

				float3 lightDirection = normalize (_WorldSpaceLightPos0.xyz);

				float3 diffuseReflection = max (0.0, dot (normalDirection, lightDirection)) * attenuation * _LightColor0.rgb;
				float3 specularReflection = attenuation * _SpecColor.rgb * max (0.0, dot (normalDirection, lightDirection)) * pow (max (0.0, dot (reflect (-lightDirection, normalDirection), viewDirection)), _Shininess);

				float3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

				return float4 (lightFinal * _Color.rgb, 1.0);
			}

			ENDCG
		}
	}
}