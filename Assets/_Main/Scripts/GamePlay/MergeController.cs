using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class MergeController : MonoBehaviour
{
    [System.Serializable]
    public class MergeInfo
    {
        public Transform parent = null;
        public BodyPart bodyPart = null;
        public Vector3 mergePosition = Vector3.zero;
        public Vector3 mergeRotation = Vector3.zero;
        public Vector3 mergeScale = Vector3.zero;
    }
    
    [SerializeField] private ShaderSetting mergeScaleTargetInfo;

    [SerializeField] private Transform mergeSpawnPoint = null;

    [SerializeField]
    private List<MergeInfo> mergeParts = new List<MergeInfo>();
    
    [SerializeField]
    private List<MergeInfo> debug = new List<MergeInfo>();
    
    private Material _renderer = null;

    private void Start()
    {
        _renderer = GetComponentInChildren<MeshRenderer>().sharedMaterial;
        
        Initialize();
    }

    private void Initialize()
    {
        foreach (var bPart in GetComponentsInChildren<BodyPart>())
        {
            var bTransform = bPart.transform;
            
            mergeParts.Add(new MergeInfo()
            {
                bodyPart = bPart,
                parent = bTransform.parent,
                mergePosition = bTransform.localPosition,
                mergeRotation = bTransform.localEulerAngles,
                mergeScale = bTransform.localScale
            });
        }
    }

    public void Merge(Color targetColor)
    {
        var list = GetValidMergeTargetParts();

        foreach (var targetPart in list)
        {
            var partTransform = targetPart.bodyPart.transform;
            
            // Set color
           _renderer.SetColor(targetPart.bodyPart.ShaderColorParam, targetColor);
            
            // Set scale to zero
            targetPart.bodyPart.SetScale(-.2F, _renderer);
        
            // Set parent
            partTransform.SetParent(targetPart.parent);
        
            // Set position ,rotation, scale
            partTransform.position = transform.position;
            partTransform.localEulerAngles = targetPart.mergeRotation;
            partTransform.localScale = targetPart.mergeScale;
            
            // Stop animations
            targetPart.bodyPart.StopAllAnimation();
            
            // Scale Animation
            targetPart.bodyPart.AnimateScaleToInitial(
                mergeScaleTargetInfo.ValueByString(targetPart.bodyPart.ShaderParam), _renderer, null);

            // Move Animation
            partTransform.DOLocalMove(targetPart.mergePosition, 1.5F).OnComplete(() =>
            {
                targetPart.bodyPart.UpdateBrokenStatus();
            });
        }
    }

    private List<MergeInfo> GetValidMergeTargetParts()
    {
        var list = new List<MergeInfo>();

        foreach (var part in mergeParts)
        {
            if (part.bodyPart.HasBroken)
            {
                list.Add(part);
                
                // foreach (var bodyPart in part.bodyPart.relatedBodyPart)
                // {
                //     if (bodyPart.HasBroken == false)
                //     {
                //         list.Add(part);
                //         
                //         break;
                //     }
                // }
            }

            debug = list;
        }

        return list;
    }
}
