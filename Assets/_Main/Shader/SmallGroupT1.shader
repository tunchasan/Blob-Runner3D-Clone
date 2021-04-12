Shader "Raymarching/TransformProvider"
{

Properties
{
    [Header(PBS)]
    _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5

    [Header(Pass)]
    [Enum(UnityEngine.Rendering.CullMode)] _Cull("Culling", Int) = 2

    [Toggle][KeyEnum(Off, On)] _ZWrite("ZWrite", Float) = 1

    [Header(Raymarching)]
    _Loop("Loop", Range(1, 100)) = 30
    _MinDistance("Minimum Distance", Range(0.001, 0.1)) = 0.01
    _DistanceMultiplier("Distance Multiplier", Range(0.001, 2.0)) = 1.0
    _ShadowLoop("Shadow Loop", Range(1, 100)) = 30
    _ShadowMinDistance("Shadow Minimum Distance", Range(0.001, 0.1)) = 0.01
    _ShadowExtraBias("Shadow Extra Bias", Range(0.0, 0.1)) = 0.0
    [PowerSlider(10.0)] _NormalDelta("NormalDelta", Range(0.00001, 0.1)) = 0.0001

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

float _Smooth;
float _Scale;

inline float DistanceFunction(float3 wpos)
{
    float4 part1Pos = mul(_Part1, float4(wpos, 1.0));
    float4 part2Pos = mul(_Part2, float4(wpos, 1.0));
    float4 part3Pos = mul(_Part3, float4(wpos, 1.0));
    float4 part4Pos = mul(_Part4, float4(wpos, 1.0));
    float4 part5Pos = mul(_Part5, float4(wpos, 1.0));
    
    float part1 = Sphere(part1Pos, _Scale * 1.25F);
    float part2 = Sphere(part2Pos, _Scale);
    float part3 = Sphere(part3Pos, _Scale / .75F);
    float part4 = Sphere(part4Pos, _Scale);
    float part5 =  Sphere(part5Pos, _Scale);
    
    float result1 = SmoothMin(part1, part2, _Smooth);
    float result2 = SmoothMin(part3, part4, _Smooth);
    
    float result3 = SmoothMin(part5, result1, _Smooth);
    
    return SmoothMin(result2, result3, _Smooth);
}
// @endblock

// @block PostEffect
float4 _ShapeColor;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    float3 wpos = ray.endPos;
    
    float4 part1Pos = mul(_Part1, float4(wpos, 1.0));
    float4 part2Pos = mul(_Part2, float4(wpos, 1.0));
    float4 part3Pos = mul(_Part3, float4(wpos, 1.0));
    float4 part4Pos = mul(_Part4, float4(wpos, 1.0));
    float4 part5Pos = mul(_Part5, float4(wpos, 1.0));
    
    float part1 = Sphere(part1Pos, _Scale);
    float part2 = Sphere(part2Pos, _Scale);
    float part3 = Sphere(part3Pos, _Scale);
    float part4 = Sphere(part4Pos, _Scale);
    float part5 =  Sphere(part5Pos, _Scale);
    
    float4 result1 = float4(2.0 / part1, 2.0 / part2, 2.0 / part3, 2.0 / part4);
    float4 result2 = float4(2.0 / part5, 0, 0, 0);

    fixed3 computeAlbedoPart1 =
        result1.x * _ShapeColor +
        result1.y * _ShapeColor +
        result1.z * _ShapeColor +
        result1.w * _ShapeColor;

    fixed3 computeAlbedoPart2 =
        result2.x * _ShapeColor;

    fixed3 final = normalize(fixed3(
        computeAlbedoPart1 +
        computeAlbedoPart2));

    o.Albedo = final;
}
// @endblock

ENDCG

Pass
{
    Tags { "LightMode" = "ForwardBase" }

    ZWrite [_ZWrite]

    CGPROGRAM
    #include "Assets\uRaymarching\Shaders\Include\Legacy/ForwardBaseStandard.cginc"
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
    #include "Assets\uRaymarching\Shaders\Include\Legacy/ForwardAddStandard.cginc"
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
    #include "Assets\uRaymarching\Shaders\Include\Legacy/ShadowCaster.cginc"
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