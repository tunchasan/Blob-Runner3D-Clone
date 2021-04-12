using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class JellyContainer : MonoBehaviour
{
    public void StartAnimation(float delay = 0)
    {
        StartCoroutine(Animate(delay));
    }

    private IEnumerator Animate(float delay)
    {
        yield return new WaitForSeconds(delay);

        var targetLocation = transform.forward * 2F + transform.position;

        targetLocation.y = .25F;
        
        transform.DOMove(targetLocation, 2F);
    }
}
