using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderSwitch : MonoBehaviour
{
    private MeshRenderer meshes;
    public Material[] myShaders = new Material[4];
    // Start is called before the first frame update
    void Start()
    {
        meshes = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            meshes.material = myShaders[0];
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            meshes.material = myShaders[1];
        }
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            meshes.material = myShaders[2];
        }
        if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            meshes.material = myShaders[3];
        }
    }
}
