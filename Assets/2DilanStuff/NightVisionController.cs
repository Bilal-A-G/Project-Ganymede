using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[RequireComponent(typeof(PostProcessVolume))]
public class NightVisionController : MonoBehaviour
{
    [SerializeField] private Color defaultColor;
    [SerializeField] private Color boostedColor;

    private bool nightVisionOn;
    private PostProcessVolume vol;

    // Start is called before the first frame update
    void Start()
    {
        RenderSettings.ambientLight = defaultColor;
        vol = gameObject.GetComponent<PostProcessVolume>();
        vol.weight = 0;

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.G))
        {
            Toggler();
        }
    }

    void Toggler()
    {
        nightVisionOn = !nightVisionOn;
        if (nightVisionOn)
        {
            RenderSettings.ambientLight = boostedColor;
            vol.weight = 1;
        }
        else
        {
            RenderSettings.ambientLight = defaultColor;
            vol.weight = 0;
        }
    }
}
