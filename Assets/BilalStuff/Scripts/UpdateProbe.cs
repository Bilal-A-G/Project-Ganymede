using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateProbe : MonoBehaviour
{
    [SerializeField] private List<ProbeTextureMap> probeTextures;
    private void Update()
    {
        for (int i = 0; i < probeTextures.Count; i++)
        {
            probeTextures[i].probe.RenderProbe(probeTextures[i].texture);
        }
    }
}

[System.Serializable]
public struct ProbeTextureMap
{
    public RenderTexture texture;
    public ReflectionProbe probe;
}
