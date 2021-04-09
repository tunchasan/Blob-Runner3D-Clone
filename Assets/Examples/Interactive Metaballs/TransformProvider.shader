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
_CubeColor("Cube Color", Color) = (1.0, 1.0, 1.0, 1.0)
_SphereColor("Sphere Color", Color) = (1.0, 1.0, 1.0, 1.0)
_TorusColor("Torus Color", Color) = (1.0, 1.0, 1.0, 1.0)
_PlaneColor("Plane Color", Color) = (1.0, 1.0, 1.0, 1.0)
_Cube1Color("Cube1 Color", Color) = (1.0, 1.0, 1.0, 1.0)
_Cube2Color("Cube2 Color", Color) = (1.0, 1.0, 1.0, 1.0)
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
float4x4 _Cube;
float4x4 _Sphere;
float4x4 _Sphere1;
float4x4 _Torus;
float4x4 _Plane; 
float4x4 _Cube1; 
float4x4 _Cube2; 

float _Smooth;
float _Scale;

inline float DistanceFunction(float3 wpos)
{
    float4 cPos = mul(_Cube, float4(wpos, 1.0));
    float4 sPos = mul(_Sphere, float4(wpos, 1.0));
    float4 s1Pos = mul(_Sphere1, float4(wpos, 1.0));
    float4 tPos = mul(_Torus, float4(wpos, 1.0));
    float4 pPos = mul(_Plane, float4(wpos, 1.0));
    float4 c1Pos = mul(_Cube1, float4(wpos, 1.0));
    float4 c2Pos = mul(_Cube2, float4(wpos, 1.0));
    
    float s = Sphere(sPos, _Scale);
    float s1 = Sphere(s1Pos, _Scale);
    float c = Box(cPos, 0.5);
    float c1 = Box(c1Pos, 0.5);
    float c2 = Box(c2Pos, 0.5);
    float t = Torus(tPos, float2(0.5, 0.2));
    float p = Plane(pPos, float3(0, 1, 0));

    float sc = SmoothMin(s, c, _Smooth);
    float tp = SmoothMin(t, p, _Smooth);

    float x = SmoothMin(sc, tp, _Smooth);
    float y = SmoothMin(c1, c2, _Smooth);

    float z = SmoothMin(x, y, _Smooth);

    return SmoothMin(z, s1, _Smooth);
}
// @endblock

// @block PostEffect
float4 _CubeColor;
float4 _SphereColor;
float4 _TorusColor;
float4 _PlaneColor;
float4 _Cube1Color;
float4 _Cube2Color;

inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    float3 wpos = ray.endPos;
    float4 cPos = mul(_Cube, float4(wpos, 1.0));
    float4 sPos = mul(_Sphere, float4(wpos, 1.0));
    float4 tPos = mul(_Torus, float4(wpos, 1.0));
    float4 pPos = mul(_Plane, float4(wpos, 1.0));
    
    float4 c1Pos = mul(_Cube1, float4(wpos, 1.0));
    float4 c2Pos = mul(_Cube2, float4(wpos, 1.0));
    
    float s = Sphere(sPos, _Scale);
    float c = Box(cPos, 0.5);
    float t = Torus(tPos, float2(0.5, 0.2));
    float p = Plane(pPos, float3(0, 1, 0));

    float c1 = Box(c1Pos, 0.5);
    float c2 = Box(c2Pos, 0.5);
    
    float4 a = float4(2.0 / s, 2.0 / c, 2.0 / t, 2.0 / p);

    float4 b = float4(2.0 / c1, 2.0 / c2, 0, 0);

    fixed3 computeAlbedo1 =
        a.x * _SphereColor +
        a.y * _CubeColor +
        a.z * _TorusColor +
        a.w * _PlaneColor;

    fixed3 computeAlbedo2 =
        b.x * _Cube1Color +
        b.y * _Cube2Color;

    fixed3 result = normalize(fixed3(computeAlbedo1 + computeAlbedo2));
    
    o.Albedo =
     result;
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