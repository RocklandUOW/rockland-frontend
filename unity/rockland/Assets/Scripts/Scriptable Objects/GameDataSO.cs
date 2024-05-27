using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "GameDataSO", menuName = "ScriptableObjects/GameDataSO", order = 4)]
public class GameDataSO : ScriptableObject
{
    [Header("Difficult settings")]
    public Difficulty difficulty;
    public int Rows;
    public int Columns;

    [Header("Card backgrounds")]
    public Sprite CardBackgroundImage;

    [Header("Grid layout settings")]
    public int PrefferedSidePadding;
    public Vector2 Spacing;
}
