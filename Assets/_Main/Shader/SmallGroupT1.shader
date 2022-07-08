Shader "Raymarching/TransformProvider"
{

Properties
{
    [Header(PBS)]
    _BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5

    [HideInInspector] [Enum(UnityEngine.Rendering.CullMode)] _Cull("Culling", Int) = 2
    [HideInInspector] [Toggle][KeyEnum(Off, On)] _ZWrite("ZWrite", Float) = 1

    [HideInInspector]_Loop("Loop", Range(1, 100)) = 25
    [HideInInspector]_MinDistance("Minimum Distance", Range(0.001, 0.1)) = 0.1
    [HideInInspector]_DistanceMultiplier("Distance Multiplier", Range(0.001, 2.0)) = 1.0
    [HideInInspector] [PowerSlider(10.0)] _NormalDelta("NormalDelta", Range(0.00001, 0.1)) = 0.0001
 
    // @block Properties
    [Header(Additional Parameters)]
    _Smooth("Smooth", float) = 1.0
    _Scale ("Scale", float) = 0.5   
    _ShapeColor("ShapeColor", Color) = (1.0, 1.0, 1.0, 1.0)
    // @endblock
}

SubShader
{

Tags
{
    "RenderType" = "Opaque"
    "Queue" = "Geometry"
    "DisableBatching" = "True"
}

Cull [_Cull]

CGINCLUDE

#define WORLD_SPACE

#define OBJECT_SHAPE_CUBE

#define USE_RAYMARCHING_DEPTH

#define SPHERICAL_HARMONICS_PER_PIXEL

#define DISTANCE_FUNCTION DistanceFunction
#define PostEffectOutput SurfaceOutputStandard
#define POST_EFFECT PostEffect

#include "Assets\uRaymarching\Shaders\Include\Legacy/Common.cginc"

// @block DistanceFunction
// These inverse transform matrices are provided
// from TransformProvider script
float4x4 _Part1;
float4x4 _Part2;
float4x4 _Part3;
float4x4 _Part4;
float4x4 _Part5;

float4 part1Pos;
float4 part2Pos;
float4 part3Pos;
float4 part4Pos;
float4 part5Pos;

float part1;
float part2;
float part3;
float part4;
float part5;

float result1;
float result2;
float result3;
float _Smooth;

float _Scale;

inline float DistanceFunction(float3 wpos)
{
    part1Pos = mul(_Part1, float4(wpos, 1.0));
    part2Pos = mul(_Part2, float4(wpos, 1.0));
    part3Pos = mul(_Part3, float4(wpos, 1.0));
    part4Pos = mul(_Part4, float4(wpos, 1.0));
    part5Pos = mul(_Part5, float4(wpos, 1.0));
     
    part1 = Sphere(part1Pos, _Scale * 1.25F);
    part2 = Sphere(part2Pos, _Scale);
    part3 = Sphere(part3Pos, _Scale / .75F);
    part4 = Sphere(part4Pos, _Scale);
    part5 =  Sphere(part5Pos, _Scale);
    
    result1 = SmoothMin(part1, part2, _Smooth);
    result2 = SmoothMin(part3, part4, _Smooth);
    result3 = SmoothMin(part5, result1, _Smooth);
    
    return SmoothMin(result2, result3, _Smooth);
}
// @endblock

// @block PostEffect
float4 _ShapeColor;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    o.Albedo = normalize(_ShapeColor);
}
// @endblock

ENDCG

Pass
{
    Tags { "LightMode" = "ForwardBase" }

    ZWrite [_ZWrite]

    CGPROGRAM
    #include "Assets/uRaymarching/Shaders/Include/Legacy/ForwardBaseStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile_fwdbase
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ForwardAdd" }
    ZWrite Off 
    Blend One One

    CGPROGRAM
    #include "Assets/uRaymarching/Shaders/Include/Legacy/ForwardAddStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma skip_variants INSTANCING_ON
    #pragma multi_compile_fwdadd_fullshadows
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ShadowCaster" }

    CGPROGRAM
    #include "Assets/uRaymarching/Shaders/Include/Legacy/ShadowCaster.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma fragmentoption ARB_precision_hint_fastest
    #pragma multi_compile_shadowcaster
    ENDCG
}

}

Fallback Off

CustomEditor "uShaderTemplate.MaterialEditor"

}