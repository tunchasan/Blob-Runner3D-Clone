using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class Mover : MonoBehaviour
{
    private void Start()
    {
        Animate();
    }

    private void Animate()
    {
        var transform1 = transform;
        
        transform.DORotate(new Vector3(0, transform1.eulerAngles.y + 90, 0), 2).OnComplete(Animate);

        transform.DOScale(Vector3.one * 5, 1).OnComplete(() => transform.DOScale(Vector3.one * 3, 1));
    }
}
