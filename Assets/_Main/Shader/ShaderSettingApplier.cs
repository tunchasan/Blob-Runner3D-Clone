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
        renderer.SetFloat("_TorsoLowerScale", setting.TorsoLowerScale);
        renderer.SetFloat("_LeftArmUpperScale", setting.LeftArmUpperScale);
        renderer.SetFloat("_LeftArmLowerScale", setting.LeftArmLowerScale);
        renderer.SetFloat("_RightArmUpperScale", setting.RightArmUpperScale);
        renderer.SetFloat("_RightArmLowerScale", setting.RightArmLowerScale);
        renderer.SetFloat("_LeftLegUpperScale", setting.LeftLegUpperScale);
        renderer.SetFloat("_LeftLegLowerScale", setting.LeftLegLowerScale);
        renderer.SetFloat("_RightLegUpperScale", setting.RightLegUpperScale);
        renderer.SetFloat("_RightLegLowerScale", setting.RightLegLowerScale);
        
        renderer.SetColor(name:"_HeadColor", setting.TotalColor);
        renderer.SetColor(name:"_TorsoColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftArmColor", setting.TotalColor);
        renderer.SetColor(name:"_RightArmColor", setting.TotalColor);
        renderer.SetColor(name:"_LeftLegColor", setting.TotalColor);
        renderer.SetColor(name:"_RightLegColor", setting.TotalColor);
    }
}
