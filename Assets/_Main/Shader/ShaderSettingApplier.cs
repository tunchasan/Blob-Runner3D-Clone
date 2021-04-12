using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderSettingApplier : MonoBehaviour
{
    [SerializeField] private ShaderSetting setting = null;

    private void OnDestroy()
    {
        var renderer = GetComponent<MeshRenderer>().sharedMaterial;
        
        renderer.SetFloat("_Smooth", setting.Smooth);
        
        renderer.SetFloat("_HeadScale", setting.HeadScale);
        renderer.SetFloat("_TorsoUpperScale", setting.TorsoUpperScale);
        renderer.SetFloat("_TorsoMidScale", setting.TorsoMidScale);
        renderer.SetFloat("_TorsoLowerScale", setting.TorsoLowerScale);
        renderer.SetFloat("_TorsoMidExtraScale", setting.TorsoMidExtraScale);
        renderer.SetFloat("_LeftArmUpperScale", setting.LeftArmUpperScale);
        renderer.SetFloat("_LeftArmMidScale", setting.LeftArmMidScale);
        renderer.SetFloat("_LeftArmLowerScale", setting.LeftArmLowerScale);
        renderer.SetFloat("_RightArmUpperScale", setting.RightArmUpperScale);
        renderer.SetFloat("_RightArmMidScale", setting.RightArmMidScale);
        renderer.SetFloat("_RightArmLowerScale", setting.RightArmLowerScale);
        renderer.SetFloat("_LeftLegUpperScale", setting.LeftLegUpperScale);
        renderer.SetFloat("_LeftLegLowerScale", setting.LeftLegLowerScale);
        renderer.SetFloat("_LeftLegMidScale", setting.LeftLegMidScale);
        renderer.SetFloat("_RightLegUpperScale", setting.RightLegUpperScale);
        renderer.SetFloat("_RightLegLowerScale", setting.RightLegLowerScale);
        renderer.SetFloat("_RightLegMidScale", setting.RightLegMidScale);
        
        renderer.SetColor(name:"_HeadColor", setting.TotalColor);
        renderer.SetColor(name:"_TorsoUpperColor", setting.TotalColor);
        renderer.SetColor(name:"_TorsoMidColor", setting.TotalColor);
        renderer.SetColor(name:"_TorsoLowerColor", setting.TotalColor);
        renderer.SetColor(name:"_TorsoMidExtraColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftArmUpperColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftArmMidColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftArmLowerColor", setting.TotalColor);
        renderer.SetColor(name:"_RightArmUpperColor", setting.TotalColor);
        renderer.SetColor(name:"_RightArmMidColor", setting.TotalColor);
        renderer.SetColor(name:"_RightArmLowerColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftLegUpperColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftLegLowerColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftLegMidColor", setting.TotalColor);
        renderer.SetColor(name:"_RightLegUpperColor", setting.TotalColor);
        renderer.SetColor(name:"_RightLegLowerColor", setting.TotalColor);
        renderer.SetColor(name:"_RightLegMidColor", setting.TotalColor);
    }
}
