using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cavas_Manager : MonoBehaviour
{
    public GameObject CardPrefab;
    public CardCollectionSO collection;

    public GameDataSO EasyData;
    public GameDataSO MediumData;
    public GameDataSO HardData;

    GameDataSO currentDifficultyData;
    List<Card_Controller> cardControllers;

    private void Awake()
    {
        cardControllers = new List<Card_Controller>();

        GetGameDifficulty();
        SetCardGridLayout();
        GenerateCards();
    }

    private void GenerateCards()
    {
        int cardCount = currentDifficultyData.Rows * currentDifficultyData.Columns;
        for (int i = 0; i < cardCount; i++)
        {
            GameObject card = Instantiate(CardPrefab, transform);
            card.transform.name = "Card No." + (i+1);

            cardControllers.Add(card.GetComponent<Card_Controller>());
        }
    }

    private void SetCardGridLayout()
    {
        Card_Grid_Layout cardGridLayout = GetComponent<Card_Grid_Layout>();

        cardGridLayout.prefferedSidePadding = currentDifficultyData.PrefferedSidePadding;
        cardGridLayout.Rows = currentDifficultyData.Rows;
        cardGridLayout.Columns = currentDifficultyData.Columns;
        cardGridLayout.Spacing = currentDifficultyData.Spacing;
    }

    private void GetGameDifficulty()
    {
        Difficulty difficulty = (Difficulty)PlayerPrefs.GetInt("Difficulty", (int)Difficulty.NORMAL);

        switch (difficulty){
            case Difficulty.EASY:
                currentDifficultyData = EasyData;
                break;
            case Difficulty.NORMAL:
                currentDifficultyData = MediumData;
                break;
            case Difficulty.HARD:
                currentDifficultyData = HardData;
                break;
        }
    }
}
