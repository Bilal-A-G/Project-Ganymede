using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LUTSwitch : MonoBehaviour
{
    public LUTCameraFilter filter;
    public myDOF depthOfField;
    public Material[] LUTs;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.H))
        {
            filter.enabled = !filter.enabled;
        }

        if (Input.GetKeyDown(KeyCode.P))
        {
            depthOfField.enabled = !depthOfField.enabled;
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
