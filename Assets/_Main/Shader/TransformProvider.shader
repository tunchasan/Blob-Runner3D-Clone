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
_TorsoLowerColor("TorsoLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmUpperColor("LeftArmUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftArmLowerColor("LeftArmLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmUpperColor("RightArmUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightArmLowerColor("RightArmLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegUpperColor("LeftLegUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_LeftLegLowerColor("LeftLegLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegUpperColor("RightLegUpper Color", Color) = (1.0, 1.0, 1.0, 1.0)
_RightLegLowerColor("RightLegLower Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
    float torsoLower = Sphere(torsoLowerPos, .15);
    
    float leftArmUpper = Capsule(leftArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), .05);
    float leftArmMid =  Sphere(leftArmMidPos, .025);
    float leftArmLower = Capsule(leftArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), .035);
    
    float rightArmUpper = Capsule(rightArmUpperPos, float3(0, 0, 0), float3(0, .15, 0), .05);
    float rightArmMid =  Sphere(rightArmMidPos, .025);
    float rightArmLower = Capsule(rightArmLowerPos, float3(0, 0, 0), float3(0, .15, 0), .035);
    
    float leftLegUpper = Capsule(leftLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), .045);
    float leftLegLower = Capsule(leftLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), .045);
    float leftLegMid =  Sphere(leftLegMidPos, .05);
    
    float rightLegUpper = Capsule(rightLegUpperPos, float3(0, 0, 0), float3(0, .125, 0), .045);
    float rightLegLower = Capsule(rightLegLowerPos, float3(0, 0, 0), float3(0, .125, 0), .045);
    float rightLegMid =  Sphere(rightLegMidPos, .05);

    float result1 = SmoothMin(torsoUpper, torsoLower, _Smooth);
    float result2 = SmoothMin(leftArmUpper, leftArmLower, _Smooth);
    float result3 = SmoothMin(rightArmUpper, rightArmLower, _Smooth);
    float result4 = SmoothMin(leftLegUpper, leftLegLower, _Smooth);
    float result5 = SmoothMin(rightLegUpper, rightLegLower, _Smooth);
    float result6 = SmoothMin(head, torsoMid, _Smooth);
    float result7 = SmoothMin(leftArmMid, rightArmMid, _Smooth);
    float result8 = SmoothMin(leftLegMid, rightLegMid, _Smooth);
    
    float result9 = SmoothMin(result1, result2, _Smooth);
    float result10 = SmoothMin(result3, result4, _Smooth);
    float result11 = SmoothMin(result5, result6, _Smooth);
    float result12 = SmoothMin(result7, result8, _Smooth);
    
    float result13 = SmoothMin(result9, result10, _Smooth);
    float result14 = SmoothMin(result11, result12, _Smooth);
    
    return SmoothMin(result13, result14, _Smooth);
}
// @endblock

// @block PostEffect
// float4 _CubeColor;
// float4 _SphereColor;
// float4 _TorusColor;
// float4 _PlaneColor;
// float4 _Cube1Color;
// float4 _Cube2Color;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    // float3 wpos = ray.endPos;
    // float4 cPos = mul(_Cube, float4(wpos, 1.0));
    // float4 sPos = mul(_Sphere, float4(wpos, 1.0));
    // float4 tPos = mul(_Torus, float4(wpos, 1.0));
    // float4 pPos = mul(_Plane, float4(wpos, 1.0));
    //
    // float4 c1Pos = mul(_Cube1, float4(wpos, 1.0));
    // float4 c2Pos = mul(_Cube2, float4(wpos, 1.0));
    //
    // float s = Sphere(sPos, _Scale);
    // float c = Box(cPos, 0.5);
    // float t = Torus(tPos, float2(0.5, 0.2));
    // float p = Plane(pPos, float3(0, 1, 0));
    //
    // float c1 = Box(c1Pos, 0.5);
    // float c2 = Box(c2Pos, 0.5);
    //
    // float4 a = float4(2.0 / s, 2.0 / c, 2.0 / t, 2.0 / p);
    //
    // float4 b = float4(2.0 / c1, 2.0 / c2, 0, 0);
    //
    // fixed3 computeAlbedo1 =
    //     a.x * _SphereColor +
    //     a.y * _CubeColor +
    //     a.z * _TorusColor +
    //     a.w * _PlaneColor;
    //
    // fixed3 computeAlbedo2 =
    //     b.x * _Cube1Color +
    //     b.y * _Cube2Color;
    //
    // fixed3 result = normalize(fixed3(computeAlbedo1 + computeAlbedo2));
    //
    // o.Albedo =
    //  result;
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