using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Timer_Script : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI timerText;
    [SerializeField] private float timeLeft = 60.5f;
    [SerializeField] private float maxTime = 60.5f;
    [SerializeField] private GameEvent timesUpEvent;
    [SerializeField] private bool IsTimerActive = true;

    private void OnEnable()
    {
        timeLeft = maxTime;
    }

    private void Update()
    {
        if (IsTimerActive)
        {
            if (timeLeft > 0)
            {
                timeLeft -= Time.deltaTime;
            }
            else
            {
                timeLeft = 0f;
                timesUpEvent.Raise();
            }
            int seconds = Mathf.FloorToInt(timeLeft);
            timerText.text = seconds.ToString();
        }
    }

    public void AddTime(float time)
    {
        if (IsTimerActive)
        {
            timeLeft += time;
            if (timeLeft > maxTime)
            {
                timeLeft = maxTime;
            }
        }
    }
}
