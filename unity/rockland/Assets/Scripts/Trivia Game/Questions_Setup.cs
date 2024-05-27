using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Questions_Setup : MonoBehaviour
{
    [SerializeField]
    private List<QuestionData> questions;
    private QuestionData currentQuestion;

    [SerializeField]
    private TextMeshProUGUI questionText;
    [SerializeField]
    private TextMeshProUGUI categoryText;
    [SerializeField]
    private Answer_Button[] answerButtons;
    [SerializeField]
    private TextMeshProUGUI scoreText;
    [SerializeField]
    private int score = 0;
    [SerializeField]
    private bool currentQuestionAnswered = false;
    [SerializeField]
    private Timer_Script timer;

    [SerializeField]
    private int correctAnswerChoice;

    [SerializeField] private GameEvent SendScoreEvent;

    private bool SendingData = false;

    private void OnEnable()
    {
        // Temporarily used on Awake, use whenever you want to load questions
        GetQuestionAssets();
        SendingData = false;
        score = 0;
        scoreText.text = "Score: " + score;
    }

    private void Start()
    {
        SelectNewQuestion();
    }

    public void nextQuestion(Component component, object data)
    {
        if (!currentQuestionAnswered)
        {
            currentQuestionAnswered = true;

            UpdateScore(data);
            Invoke("SelectNewQuestion", 1f);
        }
    }

    private void SelectNewQuestion()
    {
        if(questions.Count != 0)
        {
            // Pick random question
            int randomQuestionIndex = Random.Range(0, questions.Count);
            currentQuestion = questions[randomQuestionIndex];

            // Removes the question from the list until next question load
            questions.RemoveAt(randomQuestionIndex);

            SetQuestionValues();
            SetAnswerValues();

            currentQuestionAnswered = false;
        }
    }

    private void SetQuestionValues()
    {
        questionText.SetText(currentQuestion.Question);
        categoryText.SetText(currentQuestion.Category);
    }

    private void SetAnswerValues()
    {
        List<string> answers = RandomizeAnswers(new List<string>(currentQuestion.Answers));
        for(int i = 0; i < answerButtons.Length; i++)
        {
            bool isCorrect = false;
            if (i == correctAnswerChoice)
            {
                isCorrect = true;
            }
            answerButtons[i].SetAnswerText(answers[i]);
            answerButtons[i].SetIsCorrect(isCorrect);
        }
    }

    private List<string> RandomizeAnswers(List<string> originalList)
    {
        bool correctValueChosen = false;
        List<string> newList = new List<string>();
        for (int i = 0; i < answerButtons.Length; i++)
        {
            int random = Random.Range(0, originalList.Count);

            if (random == 0 && !correctValueChosen)
            {
                correctAnswerChoice = i;
                correctValueChosen = true;
            }

            newList.Add(originalList[random]);
            originalList.RemoveAt(random);
        }

        return newList;
    }

    private void UpdateScore(object success)
    {
        if(success is bool)
        {
            if ((bool)success)
            {
                score++;
                scoreText.text = "Score: " + score;
                timer.AddTime(2f);
            }
            else
            {
                timer.AddTime(-5f);
            }
        }
    }

    private void GetQuestionAssets()
    {
        questions = new List<QuestionData>(Resources.LoadAll<QuestionData>("Trivia Questions"));
    }

    public void SendScore()
    {
        if (!SendingData)
        {
            string[] d = { "Trivia", score.ToString() };
            SendScoreEvent.Raise(this, d);
            SendingData = !SendingData;
        }
    }
}
