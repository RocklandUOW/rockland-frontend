using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Linq;

public class Leaderboard : MonoBehaviour
{
    [SerializeField] private List<TextMeshProUGUI> names;
    [SerializeField] private List<TextMeshProUGUI> scores;
    [SerializeField] private string gameName = "Trivia";
    public RestAPI restAPI;

    private void OnEnable()
    {
        restAPI.GetData(gameName);
    }

    public void generateLeaderBoard()
    {
        // Loop over names
        for(int i = 0; i < names.Count; i++)
        {
            if(i >= restAPI.CurrentScores.Count)
            {
                names[i].text = "-";
            }
            else
            {
                names[i].text = restAPI.CurrentScores.ElementAt(i).user_name;
            }
            
        }

        // Loop over scores
        for (int i = 0; i < scores.Count; i++)
        {
            if (i >= restAPI.CurrentScores.Count)
            {
                scores[i].text = "0";
            }
            else
            {
                scores[i].text = restAPI.CurrentScores.ElementAt(i).score.ToString();
            }

        }
    }
}
