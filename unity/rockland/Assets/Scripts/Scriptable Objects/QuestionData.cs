using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "TriviaQuestionData", menuName = "ScriptableObjects/TriviaQuestion", order = 1)]
public class QuestionData : ScriptableObject
{
    public string Question;
    public string Category;
    [Tooltip("The correct answer should always be first in the array! They will be randomized")]
    public string[] Answers;
}
