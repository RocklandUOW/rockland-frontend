using UnityEngine;
using UnityEditor;
using System.IO;

public class CSV_To_SO
{
    private static string questionCSVPath = "/Editor/CSVs/rockTrivia.csv";
    private static string questionsPath = "Assets/Resources/Trivia Questions";
    private static int numberOfAnswers = 4;

    [MenuItem("Utilities/Generate Questions from CSV")]

    public static void GenerateQuestions()
    {

        string[] allLines = File.ReadAllLines(Application.dataPath + questionCSVPath);

        foreach (string s in allLines)
        {
            string[] splitData = s.Split(',');

            // CSV (COMMA SEPARATED VALUE) DATA FORMAT
            // QUESTION, CATEGORY, CORRECT ANSWER, WRONG ANSWER 1, WRONG ANSWER 2, WRONG ANSWER 3

            QuestionData questionData = ScriptableObject.CreateInstance<QuestionData>();
            questionData.Question = splitData[0]; // 1st column from csv file
            questionData.Category = splitData[1];

            // Initialize the array of answers
            questionData.Answers = new string[4];

            // Check if the folder for generating questions does not exist
            if (!Directory.Exists(questionsPath))
            {
                // Create the directory as one does not exist (creates a folder)
                Directory.CreateDirectory(questionsPath);
            }

            for (int i = 0; i < numberOfAnswers; i++)
            {
                questionData.Answers[i] = splitData[2 + i];
            }

            // CREATE THE FILE NAME
            // Remove the "?", file name cannot have that character
            if (questionData.Question.Contains("?"))
            {
                // Questions will be named the same as the question text in this example
                questionData.name = questionData.Question.Remove(questionData.Question.IndexOf("?"));

            }
            else if (questionData.Question.Contains(":"))
            {
                questionData.name = questionData.Question.Remove(questionData.Question.IndexOf(":"));
            }
            else // Does not contain an invalid character, no changes required
            {
                questionData.name = questionData.Question;
            }


            // Save this in the questionsPathfolder to load them later by script
            AssetDatabase.CreateAsset(questionData, $"{questionsPath}/{questionData.name}.asset");
        }

        AssetDatabase.SaveAssets();

        Debug.Log($"Generated Questions");
    }
}
