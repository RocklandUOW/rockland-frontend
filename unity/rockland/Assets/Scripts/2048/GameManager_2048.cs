using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using DG.Tweening;

public class GameManager_2048 : MonoBehaviour
{
    [SerializeField] private int _width = 4;
    [SerializeField] private int _height = 4;
    [SerializeField] private Node _nodePrefab;
    [SerializeField] private SpriteRenderer _boardPrefab;
    [SerializeField] private Block _blockPrefab;
    [SerializeField] private List<BlockType> _types;
    [SerializeField, Range(0f, 0.5f)] private float _travelTime = 0.2f;
    public int Score = 0;

    private List<Node> _nodes;
    private List<Block> _blocks;
    private GameState2048 _state;
    private int _round;

    private BlockType getBlockTypeByValue(int val) => _types.First(t=>t.Value == val);

    private void Start()
    {
        ChangeState(GameState2048.GenerateLevel);
    }

    public void SwipeInput(Component component, object data)
    {
        if (data is Vector2)
        {
            Debug.Log("1");
            if (_state != GameState2048.WaitingInput) { return; }
            Debug.Log("2");
            Shift((Vector2)data);
        }
        else
        {
            Debug.LogWarning("Swipe Input Event Error! Data is not in proper format");
            return;
        }
    }

    private void ChangeState(GameState2048 newState)
    {
        _state = newState;

        switch (newState)
        {
            case GameState2048.GenerateLevel:
                GenerateGrid();
                break;
            case GameState2048.SpawningBlocks:
                SpawnBlocks(_round++ == 0 ? 2 : 1);
                break;
            case GameState2048.WaitingInput:
                break;
            case GameState2048.Moving:
                break;
            case GameState2048.Win:
                break;
            case GameState2048.Lose:
                break;
            default:
                throw new ArgumentOutOfRangeException(nameof(newState), newState, null);
        }
    }

    void GenerateGrid()
    {
        Score = 0;
        _round = 0;
        _nodes = new List<Node>();
        _blocks = new List<Block>();
        for (int x = 0; x<_width; x++)
        {
            for (int y = 0; y <_height; y++)
            {
                var node = Instantiate(_nodePrefab, new Vector2(x, y), Quaternion.identity);
                _nodes.Add(node);
            }
        }
        var center = new Vector2((float)_width/2-0.5f, (float)_height /2 -0.5f);

        var board = Instantiate(_boardPrefab, center, Quaternion.identity);
        board.size = new Vector2(_width, _height);

        Camera.main.transform.position = (new Vector3(center.x, center.y, -10));

        ChangeState(GameState2048.SpawningBlocks);
    }

    void SpawnBlocks(int amount)
    {
        var freeNodes = _nodes.Where(n => n.OccupiedBlock == null).OrderBy(b=> UnityEngine.Random.value).ToList();

        foreach(var node in freeNodes.Take(amount))
        {
            SpawnSingularBlock(node, UnityEngine.Random.value > 0.9f ? 4 : 2);
        }

        if (freeNodes.Count() == 1)
        {
            // Lose implementation
            ChangeState(GameState2048.Lose);
            return;
        }

        ChangeState(GameState2048.WaitingInput);
    }

    void SpawnSingularBlock(Node node, int value)
    {
        var block = Instantiate(_blockPrefab, node.Pos, Quaternion.identity);
        block.Init(getBlockTypeByValue(value));
        block.SetBlock(node);
        _blocks.Add(block);
    }

    void Shift(Vector2 dir)
    {
        ChangeState(GameState2048.Moving);

        // Order the blocks properly from left to right, up and down, reverse if right to left, down to up
        var orderedBlocks = _blocks.OrderBy(b => b.Pos.x).ThenBy(b => b.Pos.y).ToList();
        if(dir == Vector2.right || dir == Vector2.up) { orderedBlocks.Reverse(); }

        foreach (var block in orderedBlocks)
        {
            var next = block.Node;
            do {
                block.SetBlock(next);
                var possibleNode = GetNodeAtPosition(next.Pos + dir);
                if(possibleNode != null)
                {
                    // The next node is present

                    // If possible to merge, set merge
                    if(possibleNode.OccupiedBlock != null && possibleNode.OccupiedBlock.CanMerge(block.Value))
                    {
                        block.MergeBlock(possibleNode.OccupiedBlock);
                    }
                    // Otherwise, can be moved to this spot
                    else if(possibleNode.OccupiedBlock == null){ next = possibleNode; }
                    // None hit? End while loop
                }
            } while (next != block.Node);
        }

        var sequence = DOTween.Sequence();

        foreach (var block in orderedBlocks)
        {
            var MovePoint = block.MergingBlock != null ? block.MergingBlock.Node.Pos : block.Node.Pos;

            sequence.Insert(0, block.transform.DOMove(MovePoint, _travelTime).SetEase(Ease.InQuad));
        }

        sequence.OnComplete(() => {
            foreach (var block in orderedBlocks.Where(b => b.MergingBlock != null))
            {
                MergeBlocks(block.MergingBlock, block);
            }

            ChangeState(GameState2048.SpawningBlocks);
        });
    }

    void MergeBlocks(Block baseBlock, Block mergingBlock) {
        SpawnSingularBlock(baseBlock.Node, baseBlock.Value * 2);
        Score += baseBlock.Value * 2;
        RemoveBlock(baseBlock);
        RemoveBlock(mergingBlock);
    }

    void RemoveBlock(Block block)
    {
        _blocks.Remove(block);

        Destroy(block.gameObject);
    }

    Node GetNodeAtPosition(Vector2 pos)
    {
        return _nodes.FirstOrDefault(n =>n.Pos == pos);
    }
}

    [Serializable]
public struct BlockType
{
    public int Value;
    public Color BlockColor;

}

public enum GameState2048
{
    GenerateLevel,
    SpawningBlocks,
    WaitingInput,
    Moving,
    Win,
    Lose
}