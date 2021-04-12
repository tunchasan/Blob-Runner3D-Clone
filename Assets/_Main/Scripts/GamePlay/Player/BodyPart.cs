using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using Random = UnityEngine.Random;

public class BodyPart : MonoBehaviour
{
    [SerializeField] private GameObject containerPrefab = null;

    [SerializeField] private string shaderParam = "";

    [SerializeField] private string shaderColorParam = "";
    
    [SerializeField] private BodyPart[] relatedBodyParts;
    
    [SerializeField] private BodyPart[] requiredBodyParts;

    [SerializeField] private bool hasBroken = false;
    
    private Tweener _anim1 = null;

    private Tweener _anim2 = null;

    private bool _shouldAnimate = true;

    public string ShaderParam => shaderParam;

    public string ShaderColorParam => shaderColorParam;

    public BodyPart[] relatedBodyPart => requiredBodyParts;

    public bool HasBroken => hasBroken;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Obstacle") && hasBroken == false)
        {
            var container = Instantiate(containerPrefab, transform.position, containerPrefab.transform.rotation);
            
            foreach (var bodyPart in relatedBodyParts)
            {
                if(bodyPart.HasBroken) continue;
                
                // The body part has been broken. 
                bodyPart.UpdateBrokenStatus(true);
                
                bodyPart.transform.SetParent(container.transform);

                bodyPart.transform.DOLocalMove(Vector3.zero, .5F).OnComplete(() =>
                    // Animate BodyPart
                    StartCoroutine(bodyPart.Animate()));
            }
            
            // Animate Container
            container.GetComponent<JellyContainer>().StartAnimation();
        }
    }

    private IEnumerator Animate()
    {
        Invoke(nameof(StopAllAnimation), 5);
                
        while (_shouldAnimate)
        {
            var randomLocation = 
                new Vector3(Random.Range(-1, 1), Random.Range(-1, 1), Random.Range(-1, 1)) / (5 * transform.parent.lossyScale.x);
        
            _anim1 = transform.DOLocalMove(randomLocation, Random.Range(.5F, 1)).OnComplete(() =>
            {
                _anim2 = transform.DOLocalMove(Vector3.zero, Random.Range(.5F, 1));
            });

            yield return new WaitForSeconds(2);
        }
    }

    public void StopAllAnimation()
    {
        _shouldAnimate = false;
        
        _anim1.Kill();
        
        _anim2.Kill();
    }

    public void SetScale(float targetScale, Material renderer)
    {
        renderer.SetFloat(shaderParam, targetScale);
    }

    public void AnimateScaleToInitial(float targetScale, Material renderer, Action onComplete = null)
    {
        DOTween.To(() => renderer.GetFloat(shaderParam), 
            x => renderer.SetFloat(shaderParam, x), targetScale, .75F). 
            OnComplete(() => onComplete?.Invoke());
    }

    public void UpdateBrokenStatus(bool state = false)
    {
        hasBroken = state;
    }
}
