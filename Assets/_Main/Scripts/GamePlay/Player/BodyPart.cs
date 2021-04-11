using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BodyPart : MonoBehaviour
{
    [SerializeField] private BodyPart[] relatedBodyParts;
    
    private void OnTriggerEnter(Collider other)
    {
        // TODO
    }
}
