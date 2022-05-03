Shader "Raymarching/TransformProvider_Light"
{

Properties
{
    [Header(PBS)]
    _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
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

[Header(Float Parameters)]
_Smooth("Smooth", float) = 17.5
_HeadScale ("HeadScale", float) = 0.1   
_TorsoUpperScale ("TorsoUpperScale", float) = 0.1   
_TorsoMidScale ("TorsoMidScale", float) = 0.1   
_TorsoLowerScale ("TorsoLowerScale", float) = 0.1   
_TorsoMidExtraScale ("TorsoMidExtraScale", float) = 0.1   
    
 [Header(Color Parameters)]
_HeadColor("Head Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoUpperColor("TorsoUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoMidColor("TorsoMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoLowerColor("TorsoLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoMidExtraColor("TorsoMidExtra Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
float4x4 _Head;
float4x4 _TorsoUpper;
float4x4 _TorsoMid;
float4x4 _TorsoLower;
float4x4 _TorsoMidExtra;

float _Smooth;
float _HeadScale;
float _TorsoUpperScale;
float _TorsoMidScale;
float _TorsoLowerScale;
float _TorsoMidExtraScale;

inline float DistanceFunction(float3 wpos)
{
    float4 headPos = mul(_Head, float4(wpos, 1.0));
    float4 torsoUpperPos = mul(_TorsoUpper, float4(wpos, 1.0));
    float4 torsoMidPos = mul(_TorsoMid, float4(wpos, 1.0));
    float4 torsoLowerPos = mul(_TorsoLower, float4(wpos, 1.0));
    float4 torsoMidExtraPos = mul(_TorsoMidExtra, float4(wpos, 1.0));

    float head = Sphere(headPos, _HeadScale);
    float torsoUpper = Capsule(torsoUpperPos, float3(0, 0, 0), float3(0, .15, 0), _TorsoUpperScale);
    float torsoMid = Sphere(torsoMidPos, _TorsoMidScale);
    float torsoLower = Sphere(torsoLowerPos, _TorsoLowerScale);
    float torsoMidExtra =  Sphere(torsoMidExtraPos, _TorsoMidExtraScale);

    float result1 = SmoothMin(torsoUpper, torsoLower, _Smooth);
    float result2 = SmoothMin(torsoMid, torsoMidExtra, _Smooth);
    float result3 = SmoothMin(result1, result2, _Smooth);
    
    return SmoothMin(head, result3, _Smooth);
}
// @endblock

// @block PostEffect
float4 _HeadColor;
float4 _TorsoUpperColor;
float4 _TorsoMidColor;
float4 _TorsoLowerColor;
float4 _TorsoMidExtraColor;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    float3 wpos = ray.endPos;
    float4 headPos = mul(_Head, float4(wpos, 1.0));
    float4 torsoUpperPos = mul(_TorsoUpper, float4(wpos, 1.0));
    float4 torsoMidPos = mul(_TorsoMid, float4(wpos, 1.0));
    float4 torsoLowerPos = mul(_TorsoLower, float4(wpos, 1.0));
    float4 torsoMidExtraPos = mul(_TorsoMidExtra, float4(wpos, 1.0));

    float head = Sphere(headPos, _HeadScale);
    float torsoUpper = Capsule(torsoUpperPos, float3(0, 0, 0), float3(0, .15, 0), _TorsoUpperScale);
    float torsoMid = Sphere(torsoMidPos, _TorsoMidScale);
    float torsoLower = Sphere(torsoLowerPos, _TorsoLowerScale);
    float torsoMidExtra =  Sphere(torsoMidExtraPos, _TorsoMidExtraScale);
    
    float4 result1 = float4(2.0 / head, 2.0 / torsoUpper, 2.0 / torsoMid, 2.0 / torsoLower);
    float4 result2 = float4(2.0 / torsoMidExtra, 0, 0, 0);

    fixed3 computeAlbedoPart1 =
        result1.x * _HeadColor +
        result1.y * _TorsoUpperColor +
        result1.z * _TorsoMidColor +
        result1.w * _TorsoLowerColor;

    fixed3 computeAlbedoPart2 =
        result2.x * _TorsoMidExtraColor;

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