//半兰伯特 Ramp Texture 卡通渲染 + 法线外扩轮廓描边
Shader "Basic/HalfLambert_Cel_Outline"
{
	Properties
	{
		//渐变纹理
		_RampTex("RampTex", 2D) = "white" {}
		//轮廓颜色
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		//轮廓宽度
		_OutlineWidth("Outline Width", Range(0, 1)) = 0.01
	}
	
	SubShader
	{
		
		Pass
		{
			Name "Unlit"

			Tags { "RenderType"="Opaque"   "LightMode"="ForwardBase" }
			LOD 100

			Blend Off
			AlphaToMask Off
			Cull Back
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
		

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct VertextInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct VertexOutput
			{
				float4 vertexCS : SV_POSITION;
				float3 vertexWS : TEXCOORD0;
				float4 uv0 : TEXCOORD1;
			};


			uniform sampler2D _RampTex;
			
			VertexOutput vert ( VertextInput v )
			{
				VertexOutput o;
		
				//世界法线位置
				float3 normalWS = UnityObjectToWorldNormal(v.normal);
				o.uv0 = float4(normalize(normalWS), 1);

				//裁剪空间顶点坐标位置
				o.vertexCS = UnityObjectToClipPos(v.vertex);
				//世界空间顶点坐标位置
				o.vertexWS = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (VertexOutput i ) : SV_Target
			{
				//世界空间法线
				float3 normalWS = i.uv0.xyz;
				//世界空间光照方向
				float3 lightDirWS = UnityWorldSpaceLightDir(i.vertexWS);
				//半兰伯特光照计算
				float nDotL = dot( normalWS , lightDirWS );
				nDotL = nDotL * 0.5 + 0.5;
				//将光照值映射到纹理坐标
				float2 uv = float2( nDotL, 0.5 );
				//从纹理中获取颜色	
				float4 finalColor = tex2D( _RampTex, uv );
				return finalColor;
			}

			ENDCG
		}


		Pass
		{
			Name "Outline"

			Tags {}
            Cull Front  //注意 法线外扩轮廓描边需要设置Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma target 3.0	
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct VertextInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct VertexOutput
			{
				float4 vertexCS : SV_POSITION;
				float3 vertexWS : TEXCOORD0;
			};

			uniform float4 _OutlineColor;
			uniform float _OutlineWidth;

			
			VertexOutput vert ( VertextInput v )
			{
				VertexOutput o;
				
				float3 normalOS =  normalize(v.normal);
				//裁剪空间顶点坐标位置
				o.vertexCS = UnityObjectToClipPos(v.vertex + normalOS * _OutlineWidth); //法线外扩
				return o;
			}
			
			fixed4 frag (VertexOutput i ) : SV_Target
			{
				return float4(_OutlineColor.rgb, 0);
			}

			ENDCG
		}
	}

	Fallback Off
}
