using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class TerrainGenerator : MonoBehaviour
{
    //Temporary, generate plane on the fly and tesselate via shaders later on
    [SerializeField] private GameObject highDetailPrefab;
    [SerializeField] private GameObject mediumDetailPrefab;
    [SerializeField] private GameObject lowDetailPrefab;
    [SerializeField] private int renderDistance;
    [SerializeField] private Material terrainMaterial;
    
    [SerializeField] private int maxSplits;
    [SerializeField] private Transform playerTransform;
    [SerializeField] private float splitThreshold;
    [SerializeField] private float minScale;
    [SerializeField] private float mediumDetailRange;
    [SerializeField] private float highDetailRange;
    
    private int _numSplits;

    private void Update()
    {
        _numSplits = 0;
        for (int i = 0; i < transform.childCount; i++)
        {
            Destroy(transform.GetChild(i).gameObject);
        }
        
        GameObject rootNode = Instantiate(lowDetailPrefab, transform);
        rootNode.transform.localScale = new Vector3(renderDistance, 1, renderDistance);
        SplitQuads(ref rootNode);
        
        terrainMaterial.SetVector("_PlayerPosition", new Vector2(playerTransform.position.x, playerTransform.position.z));
    }

    void SplitQuads(ref GameObject parentQuad)
    {
        _numSplits++;
        
        Vector3 parentScale = parentQuad.transform.localScale;
        Vector3 parentPosition = parentQuad.transform.position;
        
        Destroy(parentQuad);

        for (int i = 0; i < 4; i++)
        {
            GameObject quadrant;
            
            if ((parentPosition - playerTransform.position).magnitude <= highDetailRange)
            {
                quadrant = Instantiate(highDetailPrefab, transform);
            }
            else if ((parentPosition - playerTransform.position).magnitude <= mediumDetailRange)
            {
                quadrant = Instantiate(mediumDetailPrefab, transform);
            }
            else
            {
                quadrant = Instantiate(lowDetailPrefab, transform);
            }

            quadrant.GetComponent<MeshRenderer>().bounds =
                new Bounds(quadrant.transform.position, new Vector3(100000000000000, 100000000000000, 100000000000000));

            quadrant.transform.localScale = new Vector3(parentScale.x / 2, 1, parentScale.z / 2);
            quadrant.transform.position = i switch
            {
                0 => parentPosition +
                     new Vector3(-quadrant.transform.localScale.x  - 0.1f, 0, -quadrant.transform.localScale.z - 0.1f),
                1 => parentPosition + new Vector3(quadrant.transform.localScale.x - 0.1f, 0, -quadrant.transform.localScale.z - 0.1f),
                2 => parentPosition + new Vector3(quadrant.transform.localScale.x - 0.1f, 0, quadrant.transform.localScale.z - 0.1f),
                3 => parentPosition + new Vector3(-quadrant.transform.localScale.x - 0.1f, 0, quadrant.transform.localScale.z - 0.1f),
                _ => quadrant.transform.position
            };

            if (!(Mathf.Abs(playerTransform.position.x - quadrant.transform.position.x) <=
                  quadrant.transform.localScale.x + splitThreshold) ||
                !(Mathf.Abs(playerTransform.position.z - quadrant.transform.position.z) <=
                  quadrant.transform.localScale.z + splitThreshold)) continue;
            
            if (_numSplits < maxSplits && quadrant.transform.localScale.x > minScale && quadrant.transform.localScale.z > minScale)
            {
                SplitQuads(ref quadrant);
            }
        }
    }
}
