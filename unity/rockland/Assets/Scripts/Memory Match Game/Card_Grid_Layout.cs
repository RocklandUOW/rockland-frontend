using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Card_Grid_Layout : LayoutGroup
{
    public int Rows;
    public int Columns;

    public Vector2 CardSize;
    public Vector2 Spacing;

    public int prefferedSidePadding;

    public override void CalculateLayoutInputVertical()
    {
        if (Rows == 0) { Rows = 1; }
        if(Columns == 0){ Columns = 1;}

        float parentWidth = rectTransform.rect.width;
        float parentHeight = rectTransform.rect.height;

        float cardWidth = (parentWidth - 2 * prefferedSidePadding - (Spacing.y * (Columns - 1))) / Columns;
        float cardHeight = cardWidth;

        if (cardHeight * Rows + Spacing.y * (Rows - 1) > parentHeight)
        {
            cardHeight = (parentHeight - 2 * prefferedSidePadding - (Rows - 1) * Spacing.y) / Rows;
            cardWidth = cardHeight;
        }

        CardSize = new Vector2(cardWidth, cardHeight);

        padding.top = Mathf.FloorToInt((parentHeight - Rows * cardHeight - Spacing.y*(Rows -1)) / 2);
        padding.left = Mathf.FloorToInt((parentWidth - Columns * cardWidth - Spacing.x*(Columns - 1))/2);
        padding.right = padding.left;

        for (int i = 0; i <rectChildren.Count; i++)
        {
            int rowCount = i / Columns;
            int columnCount = i % Columns;

            var item = rectChildren[i];

            var xPos = padding.left + CardSize.x * columnCount + Spacing.x * columnCount;
            var yPos = padding.top + CardSize.y * rowCount + Spacing.y * rowCount;

            SetChildAlongAxis(item, 0, xPos, CardSize.x);
            SetChildAlongAxis(item, 1, yPos, CardSize.y);
        }
    }

    public override void SetLayoutHorizontal()
    {

    }

    public override void SetLayoutVertical()
    {

    }
}
