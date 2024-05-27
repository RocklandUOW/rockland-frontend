using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using TMPro;
using System;
using System.Linq;
using FlutterUnityIntegration;

public class RestAPI : MonoBehaviour
{
    private static string getURL = "https://rockland-app-service.onrender.com/get_all_leaderboards/";
    private static string postURL = "https://rockland-app-service.onrender.com/add_leaderboard_score/";

    [SerializeField, Header("Events")] private GameEvent errorEvent;
    [SerializeField] private GameEvent successEvent;
    [SerializeField] private List<UserScores> _userScores;
    [SerializeField] private TextMeshProUGUI userIdText;

    public string CurrentUserID = "User1";
    public string CurrentGame = "Trivia";
    public List<UserScores> CurrentScores;

    public void GetData(string gameName) => StartCoroutine(getAllData(gameName));

    IEnumerator sendMessageToFlutter()
    {
        while (true)
        {
            UnityMessageManager.Instance.SendMessageToFlutter("Trivia scene loaded");
            yield return new WaitForSeconds(1f);
        }
    }

    private void Start()
    {
        GetData(CurrentGame);
        StartCoroutine(sendMessageToFlutter());
    }

    public void ReceiveData(Component c, object data)
    {
        if(data is string[])
        {
            string[] info = (string[])data;

            string gameName = info[0];
            int score = int.Parse(info[1]);

            if(CheckIfHigherScore(CurrentUserID, score))
            {
                return;
            }
            else
            {
                PostData(gameName, score);
            }
        }
    }

    public void PostData(string gameName, int score)
    {
        if (CurrentUserID == "") return;
        StartCoroutine(postData(CurrentUserID, gameName, score));
    }

    public void SetCurrentUser(String message)
    {
        CurrentUserID = message;
        String censored;
        if (message != "")
            censored = message[..5] + "***" + message[^5..];
        else
            censored = message;
        userIdText.text = censored;
    }

    [Serializable]
    public struct UserScores
    {
        public string user_id;
        public string user_name;
        public string game;
        public int score;
    }

    public struct UserData
    {
        public string first_name;
        public string last_name;
    }

    public struct GetUserById
    {
        public string id;
    }

    // Getting data should be refreshed every scene change?
    IEnumerator getAllData(string gameName)
    {
        Debug.Log("Getting data...");
        _userScores = new List<UserScores>();
        CurrentScores = new List<UserScores>();
        using (UnityWebRequest request = UnityWebRequest.Get(getURL))
        {
            yield return request.SendWebRequest();

            if (request.result == UnityWebRequest.Result.ConnectionError || request.result == UnityWebRequest.Result.ProtocolError)
            {
                // Raise a not online warning for the user
                errorEvent.Raise();
                Debug.LogWarning(request.error);
                yield break;
            }

            if (request.isDone)
            {
                Debug.Log("Success!");
                // Get all data and put it in a list
                UserScores[] userScoresArray;
                userScoresArray = JsonHelper.GetArray<UserScores>(request.downloadHandler.text);
                List<UserScores> tempData = new List<UserScores>();

                foreach (UserScores userScores in userScoresArray)
                {
                    GetUserById data = new()
                    {
                        id = userScores.user_id
                    };
                    string bruh = JsonUtility.ToJson(data);
                    byte[] autism = new System.Text.UTF8Encoding().GetBytes(bruh);
                    using UnityWebRequest getUserName = new UnityWebRequest("https://rockland-app-service.onrender.com/get_account_by_id/", "POST");
                    getUserName.uploadHandler = new UploadHandlerRaw(autism);
                    getUserName.downloadHandler = new DownloadHandlerBuffer();
                    getUserName.SetRequestHeader("Content-Type", "application/json");

                    yield return getUserName.SendWebRequest();

                    if (getUserName.isDone)
                    {
                        UserScores current;
                        if (getUserName.responseCode == 200)
                        {
                            UserData userData = JsonUtility.FromJson<UserData>(getUserName.downloadHandler.text);
                            current = new()
                            {
                                game = userScores.game,
                                score = userScores.score,
                                user_id = userScores.user_id,
                                user_name = userData.first_name + " " + userData.last_name,
                            };
                        }
                        else
                        {
                            current = new()
                            {
                                game = userScores.game,
                                score = userScores.score,
                                user_id = userScores.user_id,
                                user_name = userScores.user_id,
                            };
                        }
                        tempData.Add(current);

                        //Debug.Log(getUserName.downloadHandler.text);
                        //Debug.Log(getUserName.responseCode);
                        //_userScores.Add(userScores);
                    } 
                }

                //_userScores = userScoresArray.ToList();
                _userScores = tempData;
                GetCurrentGameScores(gameName);
                SortByHighestScore();
                successEvent.Raise();
            }
        }
    }

    // Function to post data
    // Should check first if the data already exists or not
    IEnumerator postData(string id, string gameName, int score)
    {
        Debug.Log("Sending Data...");
        //byte[] data = System.Text.Encoding.UTF8.GetBytes();
        using (UnityWebRequest request = UnityWebRequest.Put(postURL, "{\"user_id\":\""+ id + "\",\"game\":\"" + gameName + "\",\"score\":" + score + "}"))
        {
            request.SetRequestHeader("Content-Type", "application/json");
            yield return request.SendWebRequest();
            if (request.result == UnityWebRequest.Result.ConnectionError || request.result == UnityWebRequest.Result.ProtocolError)
            {
                // Raise a not online warning for the user
                errorEvent.Raise();
                Debug.LogWarning(request.error);
            }

            if (request.isDone)
            {
                Debug.Log(request.downloadHandler);
            }
        }
    }
    // Function to get current game data
    private void GetCurrentGameScores(string gameName)
    {
        CurrentScores = _userScores.FindAll(us => us.game.Equals(gameName));
    }


    // Function to sort data based on score
    private void SortByHighestScore()
    {
        CurrentScores = CurrentScores.OrderBy(t => t.score).Reverse().ToList();
    }

    private bool CheckIfHigherScore(string name, int score)
    {
        Debug.Log("Checking...");
        Debug.Log(CurrentScores.Find(us => us.user_id.Equals(name)).score);
        if (CurrentScores.Exists(us => us.user_id.Equals(name)))
        {
            Debug.Log(CurrentScores.Find(us => us.user_id.Equals(name)).score);
            if(CurrentScores.Find(us => us.user_id.Equals(name)).score >= score)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }
    }
}