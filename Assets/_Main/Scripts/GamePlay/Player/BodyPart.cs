using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using Random = UnityEngine.Random;

public class BodyPart : MonoBehaviour
{
    [SerializeField] private BodyPart[] relatedBodyParts;

    [SerializeField] private GameObject containerPrefab = null;

    private Tweener _anim1 = null;

    private Tweener _anim2 = null;
    
    private bool hasBroken = false;

    private bool shouldAnimate = true;
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Obstacle") && hasBroken == false)
        {
            Debug.Log(gameObject.name);
            
            var container = Instantiate(containerPrefab, transform.position, containerPrefab.transform.rotation);
            
            foreach (var bodyPart in relatedBodyParts)
            {
                if(bodyPart.hasBroken) continue;
                
                // The body part has been broken. 
                bodyPart.hasBroken = true;
                
                bodyPart.transform.SetParent(container.transform);

                bodyPart.transform.DOLocalMove(Vector3.zero, .5F).OnComplete(() =>
                    // Animate BodyPart
                    StartCoroutine(bodyPart.Animate()));
            }
            
            // Animate Container
            container.GetComponent<JellContainer>().StartAnimation();
        }
    }

    private IEnumerator Animate()
    {
        Invoke(nameof(StopAllAnimation), 5);
                
        while (shouldAnimate)
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
        shouldAnimate = false;
        
        _anim1.Kill();
        
        _anim2.Kill();
    }
}
