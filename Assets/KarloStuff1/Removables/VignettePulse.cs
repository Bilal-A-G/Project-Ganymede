using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VignettePulse : MonoBehaviour
{
    public float amplitude = 0.5f;
    public float speed = 1f;
    public float valueOffset = 0.75f;
    public MeshRenderer render;
    Pickup itemCheck;

    private float offset;
    public float intensity;

    void Start()
    {

    }

    void Update()
    {
        intensity = amplitude * (Mathf.Sin(Time.time * speed + offset) / 2) + valueOffset;
        offset += Time.deltaTime;
        render.material.SetFloat("_CenterSize", intensity);
    }
}
