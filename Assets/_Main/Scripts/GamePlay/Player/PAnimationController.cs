using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class PAnimationController : MonoBehaviour
{
    private const string speedRate = "speed"; 
    
    private Animator _animator = null;

    private void Start()
    {
        _animator = GetComponentInChildren<Animator>();
    }

    public void IncreaseRunAnimationRate(float rate = 1)
    {
        DOTween.To(() => _animator.GetFloat(speedRate), 
            x => _animator.SetFloat(speedRate, x), rate, 4).SetEase(Ease.InCirc);
    }

    public void DisableAnimator()
    {
        _animator.enabled = false;
    }
}
