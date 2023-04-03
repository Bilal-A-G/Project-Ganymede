using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FOV : MonoBehaviour
{
    public float pickupDistance;
    public Transform collectibles;

    public List<Transform> visibleTargets = new List<Transform>();

    private void Update()
    {
        FindVisibleTargets();
    }

    void FindVisibleTargets()
    {
        visibleTargets.Clear();
        
        for (int i = 0; i < collectibles.childCount; i++)
        {
            Transform target = collectibles.GetChild(i).transform;
            if (Vector3.Distance(target.position, transform.position) <= pickupDistance)
            {
                visibleTargets.Add(target);
                collectibles.GetChild(i).GetComponent<BallSwitch>().shadered = true;
            }
            else
            {
                collectibles.GetChild(i).GetComponent<BallSwitch>().shadered = false;
            }
        }
    }
}
