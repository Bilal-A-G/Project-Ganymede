using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Switch : MonoBehaviour
{
    [SerializeField] Material[] shaders = new Material[3];
    MeshRenderer render;
    public bool isOn = false;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<MeshRenderer>();
        render.material = shaders[0];
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            render.material = shaders[0];
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            render.material = shaders[1];
        }
        if (Input.GetKeyDown(KeyCode.Z) && !isOn)
        {
            render.material = shaders[2];
            isOn = true;
        }
        else if (Input.GetKeyDown(KeyCode.Z) && isOn)
        {
            render.material = shaders[0];
            isOn = false;
        }
    }
}