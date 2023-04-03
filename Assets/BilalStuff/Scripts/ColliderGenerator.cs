using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using Random = UnityEngine.Random;

public class ColliderGenerator : MonoBehaviour
{
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
    private Texture2D _cpuTexture;

    public void GenerateColliders()
    {
        _heightMap = new RenderTexture(heightMapSize, heightMapSize, 0, GraphicsFormat.R16G16B16A16_SFloat);
        _heightMap.enableRandomWrite = true;
        _heightMap.Create();

        _cpuTexture = new Texture2D(heightMapSize, heightMapSize, GraphicsFormat.R16G16B16A16_SFloat, TextureCreationFlags.None);
        
        _collisionMesh = new GameObject();
        _collisionMesh.transform.parent = GameObject.Find("TerrainSystem").transform;
        _collisionMesh.transform.position = transform.position;
        _collisionMesh.transform.localScale = transform.localScale/5/(resolution/10.0f);
        _collisionMesh.transform.localScale = new Vector3(_collisionMesh.transform.localScale.x, 1,
            _collisionMesh.transform.localScale.z);
        _collisionFilter = _collisionMesh.AddComponent<MeshFilter>();
        _collider = _collisionMesh.AddComponent<MeshCollider>();
        _collisionMesh.AddComponent<MeshRenderer>();
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
        GetComponent<MeshRenderer>().material.SetTexture("_HeightMapS", _heightMap);
        RenderTexture.active = _heightMap;
        _cpuTexture.ReadPixels(new Rect(0, 0, _heightMap.width,  _heightMap.height), 0, 0);
        _cpuTexture.Apply();
        
        Mesh mesh = new Mesh();
        
        _vertices = new List<Vector3>();
        for (int i = 0; i < resolution + 1; i++)
        {
            for (int v = 0; v < resolution + 1; v++)
            {
                Vector3 position = new Vector3(i - (resolution)/2.0f, 1, v - (resolution)/2.0f);
                float displacement = _cpuTexture.GetPixelBilinear(-position.x/((resolution)/2.0f) * 0.5f + 0.5f, -position.z/((resolution)/2.0f) * 0.5f + 0.5f).r;

                if (i == resolution || v == resolution || i == 0 || v == 0)
                    displacement = -100;
                position = new Vector3(position.x, displacement, position.z);
                _vertices.Add(position);
            }
        }
        
        _triangles = new int[(resolution * 6) * (resolution * 6)];
        
        int triIndex = 0;
        int vertIndex = 0;
        
        for (int i = 0; i < resolution; i++)
        {
            for (int j = 0; j < resolution; j++)
            {
                _triangles[triIndex + 0] = vertIndex + 0;
                _triangles[triIndex + 1] = vertIndex + 1;
                _triangles[triIndex + 2] = vertIndex + resolution + 1;
        
                _triangles[triIndex + 3] = vertIndex + 1;
                _triangles[triIndex + 4] = vertIndex + resolution + 2;
                _triangles[triIndex + 5] = vertIndex + resolution + 1;
                
                triIndex += 6;
                vertIndex++;
            }
        
            vertIndex++;
        }

        mesh.vertices = _vertices.ToArray();
        mesh.triangles = _triangles;
        mesh.RecalculateNormals();
        
        _collisionFilter.sharedMesh = mesh;
        _collider.sharedMesh = mesh;
    }
}
