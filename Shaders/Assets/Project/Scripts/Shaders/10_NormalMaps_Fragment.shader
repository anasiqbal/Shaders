// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ai/Beginner/10_NormalMaps_Fragment"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Bump" , 2D) = "bump" {}

		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", float) = 10

		_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
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

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			uniform sampler2D _BumpMap;
			uniform float4 _BumpMap_ST;

			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float4 _RimColor;
			uniform float _RimPower;

			// unity variables
			uniform float4 _LightColor0;

			struct vertIn
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct vertOut
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;

				float4 posWorld : TEXCOORD1;

				float3 tangentWorld : TEXCOORD2;
				float3 normalWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
			};

			vertOut vert (vertIn vIn)
			{
				vertOut o;

				o.tex = vIn.texcoord;
				o.posWorld = mul (unity_ObjectToWorld, vIn.vertex);

				o.tangentWorld = normalize (mul (unity_ObjectToWorld, float4 (vIn.tangent.xyz, 0.0)).xyz);
				o.normalWorld = normalize (mul (float4 (vIn.normal, 0.0), unity_WorldToObject).xyz);
				o.binormalWorld = normalize (cross (o.normalWorld, o.tangentWorld).xyz * vIn.tangent.w);

				o.pos = UnityObjectToClipPos (vIn.vertex);
				return o;
			}

			float4 frag (vertOut vOut) : COLOR
			{
				float4 tex = tex2D (_MainTex, _MainTex_ST.xy * vOut.tex.xy + _MainTex_ST.zw);
				float4 texN = tex2D (_BumpMap, _BumpMap_ST.xy * vOut.tex.xy + _BumpMap_ST.zw);
				float3 localCoords = float3 (2.0 * texN.ag - float2 (1.0, 1.0), 0.0);
				localCoords.z = 1.0 - 0.5 * dot(localCoords, localCoords);

				float3x3 local2WorldTranspose = float3x3 (vOut.tangentWorld, vOut.binormalWorld, vOut.normalWorld);

				float attenuation = 1.0;

				float3 normalDirection = normalize (mul (localCoords, local2WorldTranspose));
				float3 viewDirection = normalize (_WorldSpaceCameraPos.xyz - vOut.posWorld.xyz);

				float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - vOut.posWorld.xyz;
				float lightDistance = length (fragmentToLightSource);
				float3 lightDirection = normalize (lerp (_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w));

				attenuation = lerp(1.0, 1.0/ lightDistance, _WorldSpaceLightPos0.w);

//				float3 lightDirection;
//				if(_WorldSpaceLightPos0.w == 0.0)
//				{
//					// directional light
//					lightDirection = normalize (_WorldSpaceLightPos0.xyz);
//				}
//				else
//				{
//					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - vOut.posWorld.xyz;
//					float lightDistance = length(vertexToLightSource);
//					attenuation = 1.0/ lightDistance;
//					lightDirection = normalize(vertexToLightSource);
//				}

				float3 diffuseReflection = max (0.0, dot (normalDirection, lightDirection)) * attenuation * _LightColor0.rgb;
				float3 specularReflection = attenuation * _SpecColor.rgb * max (0.0, dot (normalDirection, lightDirection)) * pow (max (0.0, dot (reflect (-lightDirection, normalDirection), viewDirection)), _Shininess);

				half rim = 1 - saturate (dot (normalize (viewDirection), normalDirection));
				float3 rimLighting = attenuation * _LightColor0.rgb * _RimColor.xyz * saturate (dot (normalDirection, lightDirection)) * pow (rim, _RimPower);

				float3 lightFinal = diffuseReflection + specularReflection + rimLighting + UNITY_LIGHTMODEL_AMBIENT.xyz;

				return float4 (tex.rgb * lightFinal * _Color.rgb, 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One
			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// custom variable
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float4 _RimColor;
			uniform float _RimPower;

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

				float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - vOut.posWorld.xyz;
				float lightDistance = length (fragmentToLightSource);
				float3 lightDirection = normalize (lerp (_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w));

				attenuation = lerp(1.0, 1.0/ lightDistance, _WorldSpaceLightPos0.w);

//				float3 lightDirection;
//				if(_WorldSpaceLightPos0.w == 0.0)
//				{
//					// directional light
//					lightDirection = normalize (_WorldSpaceLightPos0.xyz);
//				}
//				else
//				{
//					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - vOut.posWorld.xyz;
//					float lightDistance = length(vertexToLightSource);
//					attenuation = 1.0/ lightDistance;
//					lightDirection = normalize(vertexToLightSource);
//				}

				float3 diffuseReflection = max (0.0, dot (normalDirection, lightDirection)) * attenuation * _LightColor0.rgb;
				float3 specularReflection = attenuation * _SpecColor.rgb * max (0.0, dot (normalDirection, lightDirection)) * pow (max (0.0, dot (reflect (-lightDirection, normalDirection), viewDirection)), _Shininess);

				half rim = 1 - saturate (dot (normalize (viewDirection), normalDirection));
				float3 rimLighting = attenuation * _LightColor0.rgb * _RimColor.xyz * saturate (dot (normalDirection, lightDirection)) * pow (rim, _RimPower);

				float3 lightFinal = diffuseReflection + specularReflection + rimLighting + UNITY_LIGHTMODEL_AMBIENT.xyz;

				return float4 (lightFinal * _Color.rgb, 1.0);
			}

			ENDCG
		}
	}
}
