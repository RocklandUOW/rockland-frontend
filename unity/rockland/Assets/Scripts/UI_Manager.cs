using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class UI_Manager : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI finalScore;

    // Replace with code that actually quits the game
    public void QuitGame()
    {
        Application.Quit();
    }

    public void FinalScoreUpdate(Component c, object data)
    {
        string[] info = (string[])data;
        finalScore.text = "Final Score: " + info[1];
    }
}