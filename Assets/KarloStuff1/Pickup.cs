using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    public Transform collectibles;
    public float collectionRange;
    
    float dist = float.PositiveInfinity;
    GameObject obj;
    public List<string> inventory;
    public bool win = false;
    public int maxItems;

    void Update()
    {
        for (int i = 0; i < collectibles.childCount; i++)
        {
            collectibles.GetChild(i).GetComponent<BallSwitch>().shadered = 
                Vector3.Distance(collectibles.GetChild(i).position, transform.position) <= collectionRange;
        }
        
        if (Input.GetKeyDown(KeyCode.E))
        {
            for(int i = 0; i < collectibles.childCount; i++)
            {
                float temp = Vector3.Distance(collectibles.GetChild(i).position, transform.position);
                if (temp < dist)
                {
                    dist = temp;
                    obj = collectibles.GetChild(i).gameObject;
                }
            }

            if (dist <= collectionRange)
            {
                inventory.Add(obj.name);
                Destroy(obj);
            }
        }
        dist = float.PositiveInfinity;

        if (maxItems == inventory.Count)
        {
            win = true;
        }
    }
}
