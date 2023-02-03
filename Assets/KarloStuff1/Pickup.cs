using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    FOV vision;
    float dist = float.PositiveInfinity;
    GameObject obj;
    public List<string> inventory;
    public bool win = false;
    public float maxItem;

    // Start is called before the first frame update
    void Start()
    {
        vision = GetComponent<FOV>();
    }

    // Update is called once per frame
    void Update()
    {
        if(vision.visibleTargets.Count > 0)
        {
            if (Input.GetKeyDown(KeyCode.E))
            {
                foreach (Transform item in vision.visibleTargets)
                {
                    float temp = Vector3.Distance(item.position, transform.position);
                    if (temp < dist)
                    {
                        dist = temp;
                        obj = item.gameObject;
                    }
                }
                inventory.Add(obj.name);
                Destroy(obj);
            }
            dist = float.PositiveInfinity;
        }

        if (maxItem == inventory.Count)
        {
            win = true;
        }
    }
}
