using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : Singleton<GameManager>
{
    [SerializeField] private Player player = null;

    public void RestartGame(float delay = 2)
    {
        StartCoroutine(WaitAndRestart(delay));
    }
    
    public void RestartGame()
    {
        StartCoroutine(WaitAndRestart());
    }
    
    private IEnumerator WaitAndRestart(float delay = 2)
    {
        yield return new WaitForSeconds(delay);
        
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    private void OnEnable()
    {
        player.OnPlayerDead += RestartGame;
    }
    
    private void OnDisable()
    {
        player.OnPlayerDead -= RestartGame;
    }
}
