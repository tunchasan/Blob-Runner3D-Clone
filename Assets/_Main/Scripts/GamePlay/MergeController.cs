using System.Collections.Generic;
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

    [SerializeField]
    private List<MergeInfo> mergeParts = new List<MergeInfo>();

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

    [ContextMenu("MERGE")]
    public void Merge()
    {
        // TODO
    }

    public void GetBodyParts(int count = 3)
    {
        // TODO
    }
}
