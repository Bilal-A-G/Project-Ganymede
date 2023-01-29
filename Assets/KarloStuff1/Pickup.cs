using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{
    FOV vision;

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

                }
                Destroy(vision.visibleTargets[1]);
            }
        }
    }
}
