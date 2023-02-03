using System;
using UnityEngine;

public class Fog : MonoBehaviour
{
    [SerializeField] private Material fogMaterial;
    [SerializeField] private UnityEngine.Camera mainCamera;

    private void Awake()
    {
        mainCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, fogMaterial);
    }
}
