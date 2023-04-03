using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallSwitch : MonoBehaviour
{
    [SerializeField] Material[] shaders = new Material[2];
    public MeshRenderer render;

    public float min;
    public float max;
    private const float MaxTime = 5.0f;
    [Range(0.0f, 10.0f)]
    public float time;
    public AnimationCurve curve;
    public float value;
    public bool shadered = false;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<MeshRenderer>();
        render.material.shader = Shader.Find("Rim Lighting");
    }

    // Update is called once per frame
    void Update()
    {
        if (!shadered)
        {
            render.material = shaders[0];
            return;
        }
        
        render.material = shaders[1];

        time += Time.smoothDeltaTime;

        float t = time / MaxTime;
        if (t == 1.0f)
        {
            t = 1.0f - t;
        }
        value = Mathf.Lerp(min, max, curve.Evaluate(t * 2));
        render.material.SetFloat("_RimPower", value);
    }
}
