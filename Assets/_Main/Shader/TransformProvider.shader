Shader "Raymarching/TransformProvider"
{

Properties
{
    [Header(PBS)]
    _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
    _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5

    [Header(Pass)]
    [Enum(UnityEngine.Rendering.CullMode)] _Cull("Culling", Int) = 2

    [Toggle][KeyEnum(Off, On)] _ZWrite("ZWrite", Float) = 1

    [Header(Raymarching)]
    _Loop("Loop", Range(1, 100)) = 30
    _MinDistance("Minimum Distance", Range(0.001, 0.1)) = 0.01
    _DistanceMultiplier("Distance Multiplier", Range(0.001, 2.0)) = 1.0
    [PowerSlider(10.0)] _NormalDelta("NormalDelta", Range(0.00001, 0.1)) = 0.0001

// @block Properties
[Header(Additional Parameters)]

[Header(Float Parameters)]
_Smooth("Smooth", float) = 17.5
    
[Header(Color Parameters)]
_BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)

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
float4x4 _TorsoLower;

float4x4 _LeftArmUpper;
float4x4 _LeftArmLower;

float4x4 _RightArmUpper;
float4x4 _RightArmLower;

float4x4 _LeftLegUpper;
float4x4 _LeftLegLower;

float4x4 _RightLegUpper;
float4x4 _RightLegLower;

float _Smooth;

// Global Variables

    float4 headPos;

    float4 torsoUpperPos;
    float4 torsoLowerPos;

    float4 leftArmUpperPos; 
    float4 leftArmLowerPos;

    float4 rightArmUpperPos;
    float4 rightArmLowerPos;

    float4 leftLegUpperPos; 
    float4 leftLegLowerPos;

    float4 rightLegUpperPos;
    float4 rightLegLowerPos;

    float head;

    float torsoUpper;
    float torsoLower; 
    
    float leftArmUpper;
    float leftArmLower;
    
    float rightArmUpper;
    float rightArmLower;
    
    float leftLegUpper;
    float leftLegLower;
    
    float rightLegUpper;
    float rightLegLower;

    float result;

inline float DistanceFunction(float3 wpos)
{
    headPos = mul(_Head, float4(wpos, 1.0));
    
    torsoUpperPos = mul(_TorsoUpper, float4(wpos, 1.0));
    torsoLowerPos = mul(_TorsoLower, float4(wpos, 1.0));
    
    leftArmUpperPos = mul(_LeftArmUpper, float4(wpos, 1.0));
    leftArmLowerPos = mul(_LeftArmLower, float4(wpos, 1.0));
    
    rightArmUpperPos = mul(_RightArmUpper, float4(wpos, 1.0));
    rightArmLowerPos = mul(_RightArmLower, float4(wpos, 1.0));
    
    leftLegUpperPos = mul(_LeftLegUpper, float4(wpos, 1.0));
    leftLegLowerPos = mul(_LeftLegLower, float4(wpos, 1.0));
    
    rightLegUpperPos = mul(_RightLegUpper, float4(wpos, 1.0));
    rightLegLowerPos = mul(_RightLegLower, float4(wpos, 1.0));

    head = Sphere(headPos, 0.1F);
    torsoUpper = Capsule(torsoUpperPos, float3(0, 0, 0), float3(0, .15, 0), 0.125F);
    torsoLower = Sphere(torsoLowerPos, 0.16F);
    
    leftArmUpper = Capsule(leftArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), 0.075F);
    leftArmLower = Capsule(leftArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), 0.05F);
    
    rightArmUpper = Capsule(rightArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), 0.075F);
    rightArmLower = Capsule(rightArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), 0.05F);
    
    leftLegUpper = Capsule(leftLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    leftLegLower = Capsule(leftLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    
    rightLegUpper = Capsule(rightLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);
    rightLegLower = Capsule(rightLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), 0.07F);

    result = SmoothMin(torsoUpper, torsoLower, _Smooth);
    result = SmoothMin(result, head, _Smooth);
    result = SmoothMin(result, torsoUpper, _Smooth);
    result = SmoothMin(result, leftArmUpper, _Smooth);
    result = SmoothMin(result, leftArmLower, _Smooth);
    result = SmoothMin(result, rightArmUpper, _Smooth);
    result = SmoothMin(result, rightArmLower, _Smooth);
    result = SmoothMin(result, leftLegUpper, _Smooth);
    result = SmoothMin(result, leftLegLower, _Smooth);
    result = SmoothMin(result, rightLegUpper, _Smooth);
    result = SmoothMin(result, rightLegLower, _Smooth);
    
    return result;
}
// @endblock

// @block PostEffect

float4 _BaseColor;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    o.Albedo = normalize(_BaseColor);
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