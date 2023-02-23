using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadMove : MonoBehaviour
{
    public float amplitude = 1f;
    public float speed = 1f;

    private float offset;
    private Vector3 startPosition;

    void Start()
    {
        startPosition = transform.position;
    }

    void Update()
    {
        float x = amplitude * Mathf.Sin(Time.time * speed + offset);
        transform.position = startPosition + new Vector3(x, 0f, 0f);
        offset += Time.deltaTime;
    }
}
