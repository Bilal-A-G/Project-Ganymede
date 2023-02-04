using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Switch : MonoBehaviour
{
    [SerializeField] Material[] shaders = new Material[2];
    MeshRenderer render;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            render.material = shaders[0];
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            render.material = shaders[1];
        }
    }
}