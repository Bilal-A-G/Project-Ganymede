using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LUT2 : MonoBehaviour
{
    [SerializeField] private Material lutMaterial;
    public int lutType;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        lutMaterial.SetInt("_LUTType", lutType);
        Graphics.Blit(src, dest, lutMaterial);
    }
}
