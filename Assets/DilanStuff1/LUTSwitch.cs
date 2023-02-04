using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LUTSwitch : MonoBehaviour
{
    LUTCameraFilter filter;
    public Material[] LUTs;
    // Start is called before the first frame update
    void Start()
    {
        filter = GetComponent<LUTCameraFilter>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.H))
        {
            filter.enabled = !filter.enabled;
        }

        if (Input.GetKeyDown(KeyCode.J))
        {
            filter.m_renderMaterial = LUTs[0];
        }
        if (Input.GetKeyDown(KeyCode.K))
        {
            filter.m_renderMaterial = LUTs[1];
        }
        if (Input.GetKeyDown(KeyCode.L))
        {
            filter.m_renderMaterial = LUTs[2];
        }
    }
}
