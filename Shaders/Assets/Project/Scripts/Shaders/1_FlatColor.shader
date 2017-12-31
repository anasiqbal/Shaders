// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ai/Beginner/1_FlatColor"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;

			struct vertIn
			{
				float4 vertex : POSITION;
			};

			struct vertOut
			{
				float4 pos : SV_POSITION;
			};

			vertOut vert (vertIn vIn)
			{
				vertOut o;

				o.pos = UnityObjectToClipPos (vIn.vertex);

				return o;
			}

			float4 frag (vertOut vOut) : COLOR
			{
				return _Color;
			}

			ENDCG
		}
	}
}
