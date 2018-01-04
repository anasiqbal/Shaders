// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ai/Beginner/12_AdditionalMaps_Fragment_Optimised"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}

		_BumpMap ("Normal Texture" , 2D) = "bump" {}
		_BumpDepth ("Bump Depth", Range(0.0, 1.0)) = 1

		_EmitMap ("Emission Texture" , 2D) = "bump" {}
		_EmitStrength ("Emission Strength", Range(0.0, 2.0)) = 0

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
			uniform fixed4 _Color;

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			uniform sampler2D _BumpMap;
			uniform half4 _BumpMap_ST;
			uniform fixed _BumpDepth;

			uniform sampler2D _EmitMap;
			uniform half4 _EmitMap_ST;
			uniform fixed _EmitStrength;

			uniform fixed4 _SpecColor;
			uniform half _Shininess;
			uniform fixed4 _RimColor;
			uniform half _RimPower;

			// unity variables
			uniform half4 _LightColor0;

			struct vertIn
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 tangent : TANGENT;
			};

			struct vertOut
			{
				half4 pos : SV_POSITION;
				half4 tex : TEXCOORD0;

				fixed4 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;

				fixed3 tangentWorld : TEXCOORD3;
				fixed3 normalWorld : TEXCOORD4;
				fixed3 binormalWorld : TEXCOORD5;
			};

			vertOut vert (vertIn vIn)
			{
				vertOut o;

				o.normalWorld = normalize (mul (half4 (vIn.normal, 0.0), unity_WorldToObject).xyz);
				o.tangentWorld = normalize (mul (unity_ObjectToWorld, vIn.tangent).xyz);
				o.binormalWorld = normalize (cross (o.normalWorld, o.tangentWorld) * vIn.tangent.w);

				half4 posWorld = mul (unity_ObjectToWorld, vIn.vertex);
				o.pos = UnityObjectToClipPos (vIn.vertex);
				o.tex = vIn.texcoord;

				o.viewDirection = normalize (_WorldSpaceCameraPos.xyz - posWorld.xyz);

				half3 vertexToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;

				o.lightDirection = fixed4 (
					normalize (lerp (_WorldSpaceLightPos0.xyz, vertexToLightSource, _WorldSpaceLightPos0.w)), // light direction
					lerp(1.0, 1.0/ length (vertexToLightSource), _WorldSpaceLightPos0.w) //attenuation 
				);

				return o;
			}

			fixed4 frag (vertOut vOut) : COLOR
			{
				fixed4 tex = tex2D (_MainTex, _MainTex_ST.xy * vOut.tex.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D (_BumpMap, _BumpMap_ST.xy * vOut.tex.xy + _BumpMap_ST.zw);
				fixed4 texE = tex2D (_EmitMap, _EmitMap_ST.xy * vOut.tex.xy + _EmitMap_ST.zw);

				fixed3 localCoords = float3 (2.0 * texN.ag - fixed2 (1.0, 1.0), _BumpDepth);

				fixed3x3 local2WorldTranspose = fixed3x3 (
					vOut.tangentWorld,
					vOut.binormalWorld,
					vOut.normalWorld
				);
				fixed3 normalDirection = normalize (mul (localCoords, local2WorldTranspose));

				fixed nDotL = saturate (dot (normalDirection, vOut.lightDirection.xyz));

				fixed3 diffuseReflection = vOut.lightDirection.w * _LightColor0.xyz * nDotL;
				fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * pow (saturate (dot (reflect (-vOut.lightDirection.xyz, normalDirection), vOut.viewDirection)), _Shininess);

				fixed rim = 1 - nDotL; //saturate (dot (vOut.viewDirection, normalDirection));
				fixed3 rimLighting = nDotL * _RimColor.xyz * _LightColor0.xyz * pow (rim, _RimPower);

				fixed3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection + (specularReflection * tex.a) + rimLighting + (texE.xyz * _EmitStrength);

				return fixed4 (tex.xyz * lightFinal * _Color.xyz, 1.0);
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
			uniform fixed4 _Color;

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			uniform sampler2D _BumpMap;
			uniform half4 _BumpMap_ST;
			uniform fixed _BumpDepth;

			uniform sampler2D _EmitMap;
			uniform half4 _EmitMap_ST;
			uniform fixed _EmitStrength;

			uniform fixed4 _SpecColor;
			uniform half _Shininess;
			uniform fixed4 _RimColor;
			uniform half _RimPower;

			// unity variables
			uniform half4 _LightColor0;

			struct vertIn
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 tangent : TANGENT;
			};

			struct vertOut
			{
				half4 pos : SV_POSITION;
				half4 tex : TEXCOORD0;

				fixed4 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;

				fixed3 tangentWorld : TEXCOORD3;
				fixed3 normalWorld : TEXCOORD4;
				fixed3 binormalWorld : TEXCOORD5;
			};

			vertOut vert (vertIn vIn)
			{
				vertOut o;

				o.normalWorld = normalize (mul (half4 (vIn.normal, 0.0), unity_WorldToObject).xyz);
				o.tangentWorld = normalize (mul (unity_ObjectToWorld, vIn.tangent).xyz);
				o.binormalWorld = normalize (cross (o.normalWorld, o.tangentWorld) * vIn.tangent.w);

				half4 posWorld = mul (unity_ObjectToWorld, vIn.vertex);
				o.pos = UnityObjectToClipPos (vIn.vertex);
				o.tex = vIn.texcoord;

				o.viewDirection = normalize (_WorldSpaceCameraPos.xyz - posWorld.xyz);

				half3 vertexToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;

				o.lightDirection = fixed4 (
					normalize (lerp (_WorldSpaceLightPos0.xyz, vertexToLightSource, _WorldSpaceLightPos0.w)), // light direction
					lerp(1.0, 1.0/ length (vertexToLightSource), _WorldSpaceLightPos0.w) //attenuation 
				);

				return o;
			}

			fixed4 frag (vertOut vOut) : COLOR
			{
				fixed4 tex = tex2D (_MainTex, _MainTex_ST.xy * vOut.tex.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D (_BumpMap, _BumpMap_ST.xy * vOut.tex.xy + _BumpMap_ST.zw);

				fixed3 localCoords = float3 (2.0 * texN.ag - fixed2 (1.0, 1.0), _BumpDepth);

				fixed3x3 local2WorldTranspose = fixed3x3 (
					vOut.tangentWorld,
					vOut.binormalWorld,
					vOut.normalWorld
				);
				fixed3 normalDirection = normalize (mul (localCoords, local2WorldTranspose));

				fixed nDotL = saturate (dot (normalDirection, vOut.lightDirection.xyz));

				fixed3 diffuseReflection = vOut.lightDirection.w * _LightColor0.xyz * nDotL;
				fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * pow (saturate (dot (reflect (-vOut.lightDirection.xyz, normalDirection), vOut.viewDirection)), _Shininess);

				fixed rim = 1 - nDotL; //saturate (dot (vOut.viewDirection, normalDirection));
				fixed3 rimLighting = nDotL * _RimColor.xyz * _LightColor0.xyz * pow (rim, _RimPower);

				fixed3 lightFinal = diffuseReflection + (specularReflection * tex.a) + rimLighting;

				return fixed4 (lightFinal, 1.0);
			}

			ENDCG
		}
	}
}
