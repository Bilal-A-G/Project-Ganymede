using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class NightVisionController : MonoBehaviour
{
    [SerializeField] private PostProcessVolume volume;

    private bool _nightVisionOn;

    private void Awake()
    {
        volume.weight = 0;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.G))
        {
            Toggle();
        }
    }

    private void Toggle()
    {
        _nightVisionOn = !_nightVisionOn;

        volume.weight = _nightVisionOn ? 1 : 0;
    }
}
