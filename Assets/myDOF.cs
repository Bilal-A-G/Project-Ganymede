using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class myDOF : MonoBehaviour
{
    const int circleOfConfusionPass = 0, preFilterPass = 1, bokehPass = 2, postFilterPass = 3, combinePass = 4;

    public Shader dofShader;

    [Range(0.1f, 100f)] public float focusDistance = 10f, focusRange = 3f, bokehRadius = 4f;
    [SerializeField] bool farSighted; //if true, camera will focus on object further away than the focusDistance

    [NonSerialized]
    Material dofMaterial;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (dofMaterial == null)
        {
            dofMaterial = new Material(dofShader);
            dofMaterial.hideFlags = HideFlags.HideAndDontSave;
        }

        //Set variables in the sub surface shader
        dofMaterial.SetFloat("_FocusDistance", focusDistance);
        dofMaterial.SetFloat("_FocusRange", focusRange);
        dofMaterial.SetFloat("_BokehRadius", bokehRadius);

        dofMaterial.SetInt("_FarSighted", farSighted ? 1 : -1); // if farSighted is true, set to 1, else set to -1

        //Get the camera's projectied render texture
        RenderTexture coc = RenderTexture.GetTemporary(
            source.width, source.height, 0,
            RenderTextureFormat.RHalf, RenderTextureReadWrite.Linear
        );

        //Collect the format and set the coc and dof of the subsurface shader
        int width = source.width / 2;
        int height = source.height / 2;
        RenderTextureFormat format = source.format;
        RenderTexture dof0 = RenderTexture.GetTemporary(width, height, 0, format);
        RenderTexture dof1 = RenderTexture.GetTemporary(width, height, 0, format);

        dofMaterial.SetTexture("_CoCTex", coc);
        dofMaterial.SetTexture("_DoFTex", dof0);

        //Blits
        Graphics.Blit(source, coc, dofMaterial, circleOfConfusionPass);
        Graphics.Blit(source, dof0, dofMaterial, preFilterPass);
        Graphics.Blit(dof0, dof1, dofMaterial, bokehPass);
        Graphics.Blit(dof1, dof0, dofMaterial, postFilterPass);
        Graphics.Blit(source, destination, dofMaterial, combinePass);

        RenderTexture.ReleaseTemporary(coc);
        RenderTexture.ReleaseTemporary(dof0);
        RenderTexture.ReleaseTemporary(dof1);
    }
}
