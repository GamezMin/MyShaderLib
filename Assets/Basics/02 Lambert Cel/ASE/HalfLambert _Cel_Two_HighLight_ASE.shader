// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Basic/HalfLambert_Cel_HighLight_ASE"
{
	Properties
	{
		_RampTex("RampTex", 2D) = "white" {}
		_HighLightOffset1("HighLightOffset1", Vector) = (-0.85,-0.01,-0.03,0)
		_HighLightOffset2("HighLightOffset2", Vector) = (-0.85,-0.01,-0.03,0)
		_HighLightRange1("HighLightRange1", Range( 0.5 , 1)) = 0.5
		_HighLightRange2("HighLightRange2", Range( 0.5 , 1)) = 0.5
		_HighLightColor1("HighLightColor1", Color) = (0.8962264,0.8719332,0.6552599,0)
		_FresnelPower("FresnelPower", Range( 1 , 10)) = 5

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform sampler2D _RampTex;
			uniform float4 _HighLightColor1;
			uniform float _HighLightRange1;
			uniform float3 _HighLightOffset1;
			uniform float _HighLightRange2;
			uniform float3 _HighLightOffset2;
			uniform float _FresnelPower;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float dotResult3 = dot( ase_worldNormal , worldSpaceLightDir );
				float2 appendResult10 = (float2((0.0 + (dotResult3 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , 0.2));
				float3 normalizeResult17 = normalize( ( _HighLightOffset1 + ase_worldNormal ) );
				float dotResult14 = dot( normalizeResult17 , worldSpaceLightDir );
				float3 normalizeResult32 = normalize( ( _HighLightOffset2 + ase_worldNormal ) );
				float dotResult33 = dot( normalizeResult32 , worldSpaceLightDir );
				float clampResult38 = clamp( max( step( _HighLightRange1 , dotResult14 ) , step( _HighLightRange2 , dotResult33 ) ) , 0.0 , 1.0 );
				float4 lerpResult22 = lerp( tex2D( _RampTex, appendResult10 ) , _HighLightColor1 , clampResult38);
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV39 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode39 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV39, _FresnelPower ) );
				float4 temp_cast_0 = (fresnelNode39).xxxx;
				float4 blendOpSrc45 = lerpResult22;
				float4 blendOpDest45 = temp_cast_0;
				
				
				finalColor = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc45 ) * ( 1.0 - blendOpDest45 ) ) ));
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.CommentaryNode;23;-1698,-706;Inherit;False;1147;619;法线偏移 得到一个高光点;9;15;11;16;17;12;14;19;18;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1696,16;Inherit;False;1147;619;法线偏移 得到一个高光点2;8;36;34;33;32;31;30;29;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;11;-1632,-464;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;15;-1648,-624;Inherit;False;Property;_HighLightOffset1;HighLightOffset1;1;0;Create;True;0;0;0;False;0;False;-0.85,-0.01,-0.03;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;28;-1616,256;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;29;-1632,96;Inherit;False;Property;_HighLightOffset2;HighLightOffset2;2;0;Create;True;0;0;0;False;0;False;-0.85,-0.01,-0.03;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;5;-1472,-1200;Inherit;False;1153.013;417.2741;半兰伯特光照模型 N dot L;6;9;10;8;3;2;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1296,-576;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1280,144;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-1408,-1152;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1424,-976;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;12;-1648,-288;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;17;-1152,-576;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;31;-1632,432;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;32;-1136,144;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-1168,-1120;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;14;-1216,-352;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1040,-432;Inherit;False;Property;_HighLightRange1;HighLightRange1;3;0;Create;True;0;0;0;False;0;False;0.5;0;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;33;-1200,368;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1024,288;Inherit;False;Property;_HighLightRange2;HighLightRange2;4;0;Create;True;0;0;0;False;0;False;0.5;0;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;46;-386,-162;Inherit;False;436;211;合并两个高光点;2;37;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1008,-1152;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;18;-736,-368;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;36;-720,352;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;-114,110;Inherit;False;756;435;菲尼尔;4;40;41;42;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-624,-1152;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;37;-336,-112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;40;-32,160;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;41;-64,304;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;42;144,432;Inherit;False;Property;_FresnelPower;FresnelPower;6;0;Create;True;0;0;0;False;0;False;5;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-672,-1008;Inherit;True;Property;_RampTex;RampTex;0;0;Create;True;0;0;0;False;0;False;-1;a0a4d32a86cb7da4d85c23115557925f;a0a4d32a86cb7da4d85c23115557925f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;21;-832,-656;Inherit;False;Property;_HighLightColor1;HighLightColor1;5;0;Create;True;0;0;0;False;0;False;0.8962264,0.8719332,0.6552599,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ClampOpNode;38;-128,-112;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;39;400,192;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;22;32,-832;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;45;528,-672;Inherit;False;Screen;True;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;800,-496;Float;False;True;-1;2;ASEMaterialInspector;100;5;Basic/HalfLambert_Cel_HighLight_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;16;0;15;0
WireConnection;16;1;11;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;17;0;16;0
WireConnection;32;0;30;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;14;0;17;0
WireConnection;14;1;12;0
WireConnection;33;0;32;0
WireConnection;33;1;31;0
WireConnection;8;0;3;0
WireConnection;18;0;19;0
WireConnection;18;1;14;0
WireConnection;36;0;34;0
WireConnection;36;1;33;0
WireConnection;10;0;8;0
WireConnection;37;0;18;0
WireConnection;37;1;36;0
WireConnection;9;1;10;0
WireConnection;38;0;37;0
WireConnection;39;0;40;0
WireConnection;39;4;41;0
WireConnection;39;3;42;0
WireConnection;22;0;9;0
WireConnection;22;1;21;0
WireConnection;22;2;38;0
WireConnection;45;0;22;0
WireConnection;45;1;39;0
WireConnection;0;0;45;0
ASEEND*/
//CHKSM=E749EA239A236C6090708019213B15BF78FD3E79