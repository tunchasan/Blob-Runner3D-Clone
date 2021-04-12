using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using DG.Tweening;
using UnityEngine;
using Random = UnityEngine.Random;

public class LootContainer : MonoBehaviour
{
    [SerializeField] private Transform[] lootPieces;

    [SerializeField] private Color lootColor;
    
    private MeshRenderer _renderer = null;
    
    private List<Tweener> _tweeners = new List<Tweener>();

    private bool _shouldAnimate = true;

    private void Start()
    {
        _renderer = GetComponentInChildren<MeshRenderer>();

        StartIdleAnimation();
    }

    private void StartIdleAnimation()
    {
        foreach (var piece in lootPieces)
        {
            Tweener anim = null;
            
            _tweeners.Add(anim);
            
            StartCoroutine(Animate(piece, anim));
        }
    }

    private IEnumerator Animate(Transform piece, Tweener anim)
    {
        while (_shouldAnimate)
        {
            yield return new WaitForSeconds(Random.Range(0, .75F));

            var randomLocation = 
                new Vector3(Random.Range(-1, 1), Random.Range(-1, 1), Random.Range(-1, 1)) / 6.5F;

            anim = piece.DOLocalMove(randomLocation, .75F);
        
            yield return new WaitForSeconds(.75F);
        }
    }

    private void StopIdleAnimation()
    {
        _shouldAnimate = false;
        
        foreach (var tween in _tweeners)
        {
            tween.Kill();
        }
        
        _tweeners.Clear();
    }

    private void StartInteractAnimation()
    {
        // TODO
    }

    private void OnTriggerEnter(Collider other)
    {
        // TODO
    }
}
