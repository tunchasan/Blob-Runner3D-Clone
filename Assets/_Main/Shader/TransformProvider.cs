using UnityEngine;

[ExecuteInEditMode]
public class TransformProvider : MonoBehaviour
{
    [System.Serializable]
    public class NameTransformPair
    {
        public string name;
        public Transform transform;

        public Vector3 Position => transform.position;
        public Quaternion Rotation => transform.rotation;
        public Vector3 Scale => transform.lossyScale;
    }
    
    [SerializeField] private Renderer targetRenderer = null;

    [SerializeField] private NameTransformPair[] pairs;

    private void Update()
    {
        Validate();
    }

    private void Validate()
    {
        if (!targetRenderer) return;

        var material = targetRenderer.sharedMaterial;
        if (!material) return;
        
        foreach (var pair in pairs)
        {
            var mat = Matrix4x4.TRS(pair.Position, pair.Rotation, pair.Scale);
            var invMat = Matrix4x4.Inverse(mat);
            material.SetMatrix(pair.name, invMat);
        }
    }
}