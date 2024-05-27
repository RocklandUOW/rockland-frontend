using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class Answer_Button : MonoBehaviour
{
    private bool isCorrect;
    [SerializeField]
    private TextMeshProUGUI answerText;
    [SerializeField]
    private GameEvent loadQuestionEvent;

    private Color defaultColor;
    private void Start()
    {
        defaultColor = GetComponent<Image>().color;
    }

    public void SetAnswerText(string newText)
    {
        answerText.text = newText;
    }

    public void SetIsCorrect(bool newBool)
    {
        isCorrect = newBool;
    }

    public void OnClick()
    {
        if (isCorrect)
        {
            Debug.Log("Correct Answer!");
            GetComponent<Image>().color = Color.green;
            
        }
        else
        {
            Debug.Log("Wrong Answer!");
            GetComponent<Image>().color = Color.red;
        }

        loadQuestionEvent.Raise(this, isCorrect);
        Invoke("ChangeColorBack", 1.0f);
    }

    private void ChangeColorBack()
    {
        GetComponent<Image>().color = defaultColor;
    }
}
