using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spin : MonoBehaviour
{
    public Transform trans;

    // Start is called before the first frame update
    void Start()
    {
        trans = GetComponent<Transform>();;
    }

    // Update is called once per frame
    void Update()
    {
        trans.Rotate(0, 0.5f, 0);
    }
}
