using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class TerrainGenerator : MonoBehaviour
{
    [SerializeField] private GameObject terrainPrefab;
    [SerializeField] private float chunkSize;

    [SerializeField] private int renderDistance;
    private GameObject[,] _instantiatedChunks;

    private void Start()
    {
        for (int i = 0; i < renderDistance * 2; i++)
        {
            for (int j = 0; j < renderDistance * 2; j++)
            {
                GameObject instantiatedTerrain = Instantiate(terrainPrefab, transform);
                instantiatedTerrain.transform.position = new Vector3((i - renderDistance) * chunkSize * 2, 0, 
                    (j - renderDistance) * chunkSize * 2);
                instantiatedTerrain.transform.localScale = new Vector3(chunkSize, 1, chunkSize);
                instantiatedTerrain.GetComponent<MeshFilter>().mesh.bounds = new Bounds(
                    instantiatedTerrain.transform.position,
                    new Vector3(100000000, 100000000, 100000000));
            }
        }
    }

    private void Update()
    {
        
    }
}


