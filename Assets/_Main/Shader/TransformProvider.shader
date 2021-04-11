Shader "Raymarching/TransformProvider"
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
_Smooth("Smooth", float) = 1.0
_Scale ("Scale", float) = 0.5   
     
_HeadColor("Head Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoUpperColor("TorsoUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoMidColor("TorsoMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoLowerColor("TorsoLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorsoLowerExtraColor("TorsoLowerExtra Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmUpperColor("LeftArmUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmMidColor("LeftArmMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmLowerColor("LeftArmLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmUpperColor("RightArmUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmMidColor("RightArmMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmLowerColor("RightArmLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegUpperColor("LeftLegUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegLowerColor("LeftLegLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegMidColor("LeftLegMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegUpperColor("RightLegUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegLowerColor("RightLegLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegMidColor("RightLegMid Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
float4x4 _TorsoLowerExtra;
float4x4 _LeftArmUpper;
float4x4 _LeftArmMid;
float4x4 _LeftArmLower;
float4x4 _RightArmUpper;
float4x4 _RightArmMid;
float4x4 _RightArmLower;
float4x4 _LeftLegUpper;
float4x4 _LeftLegLower;
float4x4 _LeftLegMid;
float4x4 _RightLegUpper;
float4x4 _RightLegLower;
float4x4 _RightLegMid;

float _Smooth;
float _Scale;

inline float DistanceFunction(float3 wpos)
{
    float4 headPos = mul(_Head, float4(wpos, 1.0));
    float4 torsoUpperPos = mul(_TorsoUpper, float4(wpos, 1.0));
    float4 torsoMidPos = mul(_TorsoMid, float4(wpos, 1.0));
    float4 torsoLowerPos = mul(_TorsoLower, float4(wpos, 1.0));
    float4 torsoLowerExtraPos = mul(_TorsoLowerExtra, float4(wpos, 1.0));
    float4 leftArmUpperPos = mul(_LeftArmUpper, float4(wpos, 1.0));
    float4 leftArmMidPos = mul(_LeftArmMid, float4(wpos, 1.0));
    float4 leftArmLowerPos = mul(_LeftArmLower, float4(wpos, 1.0));
    float4 rightArmUpperPos = mul(_RightArmUpper, float4(wpos, 1.0));
    float4 rightArmMidPos = mul(_RightArmMid, float4(wpos, 1.0));
    float4 rightArmLowerPos = mul(_RightArmLower, float4(wpos, 1.0));
    float4 leftLegUpperPos = mul(_LeftLegUpper, float4(wpos, 1.0));
    float4 leftLegLowerPos = mul(_LeftLegLower, float4(wpos, 1.0));
    float4 leftLegMidPos = mul(_LeftLegMid, float4(wpos, 1.0));
    float4 rightLegUpperPos = mul(_RightLegUpper, float4(wpos, 1.0));
    float4 rightLegLowerPos = mul(_RightLegLower, float4(wpos, 1.0));
    float4 rightLegMidPos = mul(_RightLegMid, float4(wpos, 1.0));

    float head = Sphere(headPos, _Scale);
    float torsoUpper = Capsule(torsoUpperPos, float3(0, 0, 0), float3(0, .15, 0), .125);
    float torsoMid = Sphere(torsoMidPos, .125);
    float torsoLower = Sphere(torsoLowerPos, .16);
    float torsoLowerExtra =  Sphere(torsoLowerExtraPos, .16);
    
    float leftArmUpper = Capsule(leftArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), .075);
    float leftArmMid =  Sphere(leftArmMidPos, .04);
    float leftArmLower = Capsule(leftArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), .05);
    
    float rightArmUpper = Capsule(rightArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), .075);
    float rightArmMid =  Sphere(rightArmMidPos, .045);
    float rightArmLower = Capsule(rightArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), .05);
    
    float leftLegUpper = Capsule(leftLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float leftLegLower = Capsule(leftLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float leftLegMid =  Sphere(leftLegMidPos, .075);
    
    float rightLegUpper = Capsule(rightLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float rightLegLower = Capsule(rightLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float rightLegMid =  Sphere(rightLegMidPos, .075);

    float result1 = SmoothMin(torsoUpper, torsoLower, _Smooth);
    float result2 = SmoothMin(leftArmUpper, leftArmLower, _Smooth);
    float result3 = SmoothMin(rightArmUpper, rightArmLower, _Smooth);
    float result4 = SmoothMin(leftLegUpper, leftLegLower, _Smooth);
    float result5 = SmoothMin(rightLegUpper, rightLegLower, _Smooth);
    float result6 = SmoothMin(head, torsoMid, _Smooth);
    float result7 = SmoothMin(leftArmMid, rightArmMid, _Smooth);
    float result8 = SmoothMin(leftLegMid, rightLegMid, _Smooth);
    
    float result9 = SmoothMin(result1, torsoLowerExtra, _Smooth);
    float result10 = SmoothMin(result2, result3, _Smooth);
    float result11 = SmoothMin(result4, result5, _Smooth);
    float result12 = SmoothMin(result6, result7, _Smooth);
    
    float result13 = SmoothMin(result8, result9, _Smooth);
    float result14 = SmoothMin(result10, result11, _Smooth);
    
    float result15 = SmoothMin(result12, result13, _Smooth);
    
    return SmoothMin(result14, result15, _Smooth);
}
// @endblock

// @block PostEffect
float4 _HeadColor;
float4 _TorsoUpperColor;
float4 _TorsoMidColor;
float4 _TorsoLowerColor;
float4 _TorsoLowerExtraColor;
float4 _LeftArmUpperColor;
float4 _LeftArmMidColor;
float4 _LeftArmLowerColor;
float4 _RightArmUpperColor;
float4 _RightArmMidColor;
float4 _RightArmLowerColor;
float4 _LeftLegUpperColor;
float4 _LeftLegLowerColor;
float4 _LeftLegMidColor;
float4 _RightLegUpperColor;
float4 _RightLegLowerColor;
float4 _RightLegMidColor;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    float3 wpos = ray.endPos;
    float4 headPos = mul(_Head, float4(wpos, 1.0));
    float4 torsoUpperPos = mul(_TorsoUpper, float4(wpos, 1.0));
    float4 torsoMidPos = mul(_TorsoMid, float4(wpos, 1.0));
    float4 torsoLowerPos = mul(_TorsoLower, float4(wpos, 1.0));
    float4 torsoLowerExtraPos = mul(_TorsoLowerExtra, float4(wpos, 1.0));
    float4 leftArmUpperPos = mul(_LeftArmUpper, float4(wpos, 1.0));
    float4 leftArmMidPos = mul(_LeftArmMid, float4(wpos, 1.0));
    float4 leftArmLowerPos = mul(_LeftArmLower, float4(wpos, 1.0));
    float4 rightArmUpperPos = mul(_RightArmUpper, float4(wpos, 1.0));
    float4 rightArmMidPos = mul(_RightArmMid, float4(wpos, 1.0));
    float4 rightArmLowerPos = mul(_RightArmLower, float4(wpos, 1.0));
    float4 leftLegUpperPos = mul(_LeftLegUpper, float4(wpos, 1.0));
    float4 leftLegMidPos = mul(_LeftLegMid, float4(wpos, 1.0));
    float4 leftLegLowerPos = mul(_LeftLegLower, float4(wpos, 1.0));
    float4 rightLegUpperPos = mul(_RightLegUpper, float4(wpos, 1.0));
    float4 rightLegMidPos = mul(_RightLegMid, float4(wpos, 1.0));
    float4 rightLegLowerPos = mul(_RightLegLower, float4(wpos, 1.0));

    float head = Sphere(headPos, _Scale);
    float torsoUpper = Capsule(torsoUpperPos, float3(0, 0, 0), float3(0, .15, 0), .125);
    float torsoMid = Sphere(torsoMidPos, .125);
    float torsoLower = Sphere(torsoLowerPos, .16);
    float torsoLowerExtra =  Sphere(torsoLowerExtraPos, .16);
    
    float leftArmUpper = Capsule(leftArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), .075);
    float leftArmMid =  Sphere(leftArmMidPos, .04);
    float leftArmLower = Capsule(leftArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), .05);
    
    float rightArmUpper = Capsule(rightArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), .075);
    float rightArmMid =  Sphere(rightArmMidPos, .045);
    float rightArmLower = Capsule(rightArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), .05);
    
    float leftLegUpper = Capsule(leftLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float leftLegLower = Capsule(leftLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float leftLegMid =  Sphere(leftLegMidPos, .075);
    
    float rightLegUpper = Capsule(rightLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float rightLegLower = Capsule(rightLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), .07);
    float rightLegMid =  Sphere(rightLegMidPos, .075);

    float4 result1 = float4(4.0 / head, 4.0 / torsoUpper, 4.0 / torsoMid, 4.0 / torsoLower);
    float4 result2 = float4(4.0 / torsoLowerExtra, 4.0 / leftArmUpper, 4.0 / leftArmMid, 4.0 / leftArmLower);
    float4 result3 = float4(4.0 / rightArmUpper, 4.0 / rightArmMid, 4.0 / rightArmLower, 4.0 / leftLegUpper);
    float4 result4 = float4(4.0 / leftLegLower, 4.0 / leftLegMid, 4.0 / rightLegUpper, 4.0 / rightLegLower);
    float4 result5 = float4(4.0 / rightLegMid, 0, 0, 0);

    fixed3 computeAlbedoPart1 =
        result1.x * _HeadColor +
        result1.y * _TorsoUpperColor +
        result1.z * _TorsoMidColor +
        result1.w * _TorsoLowerColor;

    fixed3 computeAlbedoPart2 =
        result2.x * _TorsoLowerExtraColor +
        result2.y * _LeftArmUpperColor +
        result2.z * _LeftArmMidColor +
        result2.w * _LeftArmLowerColor;

    fixed3 computeAlbedoPart3 =
        result3.x * _RightArmUpperColor +
        result3.y * _RightArmMidColor +
        result3.z * _RightArmLowerColor +
        result3.w * _LeftLegUpperColor;

    fixed3 computeAlbedoPart4 =
        result4.x * _LeftLegLowerColor +
        result4.y * _LeftLegMidColor +
        result4.z * _RightLegUpperColor +
        result4.w * _RightLegLowerColor;

    fixed3 computeAlbedoPart5 =
        result5.x * _RightLegMidColor;

    fixed3 final = normalize(fixed3(
        computeAlbedoPart1 +
        computeAlbedoPart2 +
        computeAlbedoPart3 +
        computeAlbedoPart4 +
        computeAlbedoPart5));

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