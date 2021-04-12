using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class PAnimationController : MonoBehaviour
{
    private const string speedRate = "speed"; 
    
    private const string shouldOnStand = "shouldOnStand";

    private const string shouldOnRight = "shouldOnRight";
    
    private const string shouldOnLeft = "shouldOnLeft";
    
    private const string shouldOnCrawl = "shouldOnCrawl";

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

    public void StartStandAnimation()
    {
        ResetAllState();
        
        _animator.SetBool(shouldOnStand, true);
    }
    
    public void StartLeftWalkAnimation()
    {
        ResetAllState();
        
        _animator.SetBool(shouldOnLeft, true);
    }
    
    public void StartRightWalkAnimation()
    {
        ResetAllState();
        
        _animator.SetBool(shouldOnRight, true);
    }
    
    public void StartCrawlWalkAnimation()
    {
        ResetAllState();
        
        _animator.SetBool(shouldOnCrawl, true);
    }

    private void ResetAllState()
    {
        _animator.SetBool(shouldOnCrawl, false);
        _animator.SetBool(shouldOnStand, false);
        _animator.SetBool(shouldOnLeft, false);
        _animator.SetBool(shouldOnRight, false);
    }

    public void DisableAnimator()
    {
        _animator.enabled = false;
    }
}
