using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;

public class Timer : MonoBehaviour
{
    public float timer;
    [SerializeField] TMP_Text timeText;
    Pickup allItems;

    // Start is called before the first frame update
    void Start()
    {
        allItems = GetComponent<Pickup>();
    }

    // Update is called once per frame
    void Update()
    {
        if (timer > 0 && allItems.win == false)
        {
            timer -= Time.deltaTime;
            timeText.text = $"Remaining time: {timer} \n {allItems.inventory.Count}/{allItems.maxItem} items found";
        }
        else if (timer <= 0 && allItems.win == false)
        {
            timeText.text = $"You have lost the game, press 'R' to restart";
            if (Input.GetKeyDown(KeyCode.R))
            {
                Debug.Log("E");
                SceneManager.LoadScene("Game");
            }
        }
        else if (timer > 0 && allItems.win == true)
        {
            timeText.text = $"You have won the game, press 'R' to restart";
            if (Input.GetKeyDown(KeyCode.R))
            {
                SceneManager.LoadScene("Game");
            }
        }
    }
}
