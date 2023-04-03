using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TerrainGenerator : MonoBehaviour
{
    [SerializeField] private GameObject terrainPrefab;
    [SerializeField] private float chunkSize;
    [SerializeField] private Transform player;
    [SerializeField] private float chunkUpdateThreshold;
    [SerializeField] private int renderDistance;
    
    private List<GameObject> _instantiatedChunks;

    private void Start()
    {
        GenerateTerrain();
    }

    [ContextMenu("Generate Terrain")]
    private void GenerateTerrain()
    {
        _instantiatedChunks = new List<GameObject>();

        for (int i = 0; i < renderDistance * 2; i++)
        {
            for (int j = 0; j < renderDistance * 2; j++)
            {
                GameObject instantiatedTerrain = Instantiate(terrainPrefab, transform);
                instantiatedTerrain.transform.position = new Vector3((i - renderDistance) * chunkSize * 2, 0, 
                    (j - renderDistance) * chunkSize * 2) + new Vector3(player.position.x, 0, player.position.z);
                instantiatedTerrain.transform.localScale = new Vector3(chunkSize + 2, 1, chunkSize + 2);
                instantiatedTerrain.GetComponent<MeshFilter>().sharedMesh.bounds = new Bounds(
                    instantiatedTerrain.transform.position,
                    new Vector3(100000000, 100000000, 100000000));
                _instantiatedChunks.Add(instantiatedTerrain);
                instantiatedTerrain.GetComponent<ColliderGenerator>().GenerateColliders();
            }
        }
    }
    
}


