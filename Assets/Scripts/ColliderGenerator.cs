using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using Random = UnityEngine.Random;

public class ColliderGenerator : MonoBehaviour
{
    [SerializeField] private Material debugMaterial;
    [SerializeField] private Material terrainShader;
    [SerializeField] private int resolution;
    [SerializeField] private int octaves;
    [SerializeField] private ComputeShader heightMapCompute;
    [SerializeField] private int heightMapSize;
    
    private float _scale;
    private float _baseScale;
    private float _octaveUVFalloff;
    private float _heightScale;
    private float _compensation;
    private float _octaveAmplitudeFalloff;
    
    private MeshFilter _collisionFilter;
    private MeshCollider _collider;
    private GameObject _collisionMesh;
    private List<Vector3> _vertices;
    private int[] _triangles;

    private RenderTexture _heightMap;

    private void Awake()
    {
        _heightMap = new RenderTexture(heightMapSize, heightMapSize, 0, GraphicsFormat.R32G32B32A32_SFloat);
        _heightMap.enableRandomWrite = true;
        _heightMap.Create();
    }

    private void Start()
    {
        _collisionMesh = new GameObject();
        _collisionMesh.transform.parent = GameObject.Find("TerrainSystem").transform;
        _collisionMesh.transform.position = transform.position;
        _collisionMesh.transform.localScale = transform.localScale/5/(resolution/10.0f);
        _collisionMesh.transform.localScale = new Vector3(_collisionMesh.transform.localScale.x, 1,
            _collisionMesh.transform.localScale.z);
        _collisionFilter = _collisionMesh.AddComponent<MeshFilter>();
        MeshRenderer collisionRenderer = _collisionMesh.AddComponent<MeshRenderer>();
        collisionRenderer.material = debugMaterial;
        _collider = _collisionMesh.AddComponent<MeshCollider>();
        _collider.convex = false;
        Rigidbody rigidBody = _collisionMesh.AddComponent<Rigidbody>();
        rigidBody.isKinematic = true;
        rigidBody.useGravity = false;
        
        _scale = terrainShader.GetFloat("_MapScale");
        _baseScale = terrainShader.GetFloat("_BaseScale");
        _octaveUVFalloff = terrainShader.GetFloat("_OctaveUVFalloff");
        _octaveAmplitudeFalloff = terrainShader.GetFloat("_OctaveAmplitudeFalloff");
        _compensation = terrainShader.GetFloat("_Compensation");
        _heightScale = terrainShader.GetFloat("_HeightScale");
        
        heightMapCompute.SetTexture(0, "HeightMap", _heightMap);
        heightMapCompute.SetInt("MapResolution", heightMapSize);
        heightMapCompute.SetInt("Octaves", octaves);
        heightMapCompute.SetFloat("OctaveAmplitudeFalloff", _octaveAmplitudeFalloff);
        heightMapCompute.SetFloat("OctaveUVFalloff", _octaveUVFalloff);
        heightMapCompute.SetFloat("BaseScale", _baseScale);
        heightMapCompute.SetFloat("MapScale", _scale);
        heightMapCompute.SetFloat("Compensation", _compensation);
        heightMapCompute.SetFloat("HeightScale", _heightScale);
        heightMapCompute.SetFloats("PlaneScale", new []{transform.localScale.x, transform.localScale.z});
        heightMapCompute.SetFloats("PlanePosition", new []{transform.position.x, transform.position.z});

        heightMapCompute.Dispatch(0, heightMapSize, heightMapSize, 1);
        
        GetComponent<MeshRenderer>().material.SetTexture("_HeightMap", _heightMap);
        GetComponent<MeshRenderer>().material.SetColor("_Colour", new Color(0.05f, 0, 0, 0));

        // Mesh mesh = new Mesh();
        // _collisionFilter.mesh.Clear();
        //
        // _vertices = new List<Vector3>();
        // for (int i = 0; i < resolution + 1; i++)
        // {
        //     for (int v = 0; v < resolution + 1; v++)
        //     {
        //         Vector3 position = new Vector3(i - resolution/2, 1, v - resolution/2);
        //         Vector3 scale = _collisionMesh.transform.localScale;
        //         
        //         Vector3 worldSpacePosition = (new Vector3(position.x * scale.x, 1, position.z * scale.z) + _collisionMesh.transform.position)/_scale;
        //         float displacement = 0.0f;
        //         
        //         for(int j = 1; j < octaves + 1; j++)
        //         {
        //             Vector3 scaledPosition = worldSpacePosition * (_octaveUVFalloff * Mathf.Pow(_baseScale, j + 1));
        //             float noise = Mathf.PerlinNoise(scaledPosition.x, scaledPosition.z);
        //             displacement += noise * 1/Mathf.Pow(_baseScale, j) * _octaveAmplitudeFalloff;
        //         }
        //
        //         displacement = displacement * _heightScale - _compensation;
        //         position = new Vector3(position.x, displacement, position.z);
        //         _vertices.Add(position);
        //     }
        // }
        //
        // _triangles = new int[(resolution * 6) * (resolution * 6)];
        //
        // int triIndex = 0;
        // int vertIndex = 0;
        //
        // for (int i = 0; i < resolution; i++)
        // {
        //     for (int j = 0; j < resolution; j++)
        //     {
        //         _triangles[triIndex + 0] = vertIndex + 0;
        //         _triangles[triIndex + 1] = vertIndex + 1;
        //         _triangles[triIndex + 2] = vertIndex + resolution + 1;
        //
        //         _triangles[triIndex + 3] = vertIndex + 1;
        //         _triangles[triIndex + 4] = vertIndex + resolution + 2;
        //         _triangles[triIndex + 5] = vertIndex + resolution + 1;
        //         
        //         triIndex += 6;
        //         vertIndex++;
        //     }
        //
        //     vertIndex++;
        // }
        //
        // mesh.vertices = _vertices.ToArray();
        // mesh.triangles = _triangles;
        // mesh.RecalculateNormals();
        //
        // _collisionFilter.mesh = mesh;
        // _collider.sharedMesh = mesh;
    }

    private void OnDisable()
    {
        Destroy(_collisionMesh);
    }
}
