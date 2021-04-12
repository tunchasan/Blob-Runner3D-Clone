using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(PController), typeof(PAnimationController))]
public class Player : MonoBehaviour
{
    private BodyPart[] _bodyParts;

    private bool _hasDead = false;

    public Action OnPlayerDead;

    public BodyPart[] BodyParts => _bodyParts;
    
    private void Start()
    {
        _bodyParts = GetComponentsInChildren<BodyPart>();

        StartCoroutine(ValidateState());
    }

    private IEnumerator ValidateState()
    {
        while (true)
        {
            yield return new WaitForSeconds(.2F);

            if (IsAllPartsBroken())
            {
                _hasDead = true;
                
                OnPlayerDead?.Invoke();

                GetComponent<PController>().StopMovement();
            }
        }
    }

    private bool IsAllPartsBroken()
    {
        var check = true;
        
        foreach (var part in _bodyParts)
        {
            if (part.HasBroken == false)
            {
                check = false;

                break;
            }
        }

        return check;
    }
}
