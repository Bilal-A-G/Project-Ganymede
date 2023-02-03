using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LUT_Manager : MonoBehaviour
{
    LUT _switch;
    [SerializeField] Material[] _texture;

    // Start is called before the first frame update
    void Start()
    {
        _switch = GetComponent<LUT>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha7))
        {
            _switch.enabled = !_switch.enabled;
        }

        if (Input.GetKeyDown(KeyCode.Alpha8))
        {
            _switch.m_renderMaterial = _texture[0];
        }
        if (Input.GetKeyDown(KeyCode.Alpha9))
        {
            _switch.m_renderMaterial = _texture[1];
        }
        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            _switch.m_renderMaterial = _texture[2];
        }
    }
}
