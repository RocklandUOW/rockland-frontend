using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "CardCollectionSO", menuName = "ScriptableObjects/CardCollectionSO", order = 3)]
public class CardCollectionSO : ScriptableObject
{
    public List<CardSO> cards;
}
