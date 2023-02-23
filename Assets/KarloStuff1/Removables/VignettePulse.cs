using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VignettePulse : MonoBehaviour
{
    public Material render;
    private float intensity;

    public float min;
    public float max;
    private const float MaxTime = 1.0f;
    [Range(0.0f, 1.0f)]
    public float time;
    public AnimationCurve curve;

    public bool on = false;
    public bool transition = false;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Z) && on == false)
        {
            on = true;
            transition = true;
        }

        else if (Input.GetKeyDown(KeyCode.Z) && on == true)
        {
            on = false;
            transition = true;
        }

        if (on && transition)
        {
            time += Time.smoothDeltaTime;

            float t = time / MaxTime;
            if (t == 1.0f)
            {
                t = 1.0f - t;
            }
            intensity = Mathf.Lerp(min, max, curve.Evaluate(t * 2));
            render.SetFloat("_CenterSize", intensity);

            if (time >= 1)
            {
                time = 1;
                transition = false;
            }
        }

        if (!on && transition)
        {
            time -= Time.smoothDeltaTime;

            float t = time / MaxTime;
            if (t == 1.0f)
            {
                t = 1.0f - t;
            }
            intensity = Mathf.Lerp(min, max, curve.Evaluate(t * 2));
            render.SetFloat("_CenterSize", intensity);

            if (time <= 0)
            {
                time = 0;
                transition = false;
            }
        }
    }
}
