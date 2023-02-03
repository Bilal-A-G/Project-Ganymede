using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] private float speed;
    [SerializeField] private float rotationSpeed;
    [SerializeField] private Transform player;
    [SerializeField] private Fog fog;
    [SerializeField] private LUT2 lut;
    [SerializeField] private Material terrainMaterial;
    [SerializeField] private List<GameObject> uiElements;
    [SerializeField] private GameObject disabledUI;
    [SerializeField] private GameObject wonUI;
    [SerializeField] private GameObject lostUI;

    private Vector3 _moveDirection;
    private Vector2 _mousePositionLastFrame;
    private Vector2 _mouseDelta;
    private bool _isLooking;
    private bool _doLighting;
    private bool _overlayActive;
    private GameObject _activeUI;
    
    private void Awake()
    {
        _doLighting = true;
        _overlayActive = true;
        _activeUI = null;
    }

    void Update()
    {
        _moveDirection = new Vector3(0, 0, 0);
        
        if (Input.GetKey(KeyCode.A))
        {
            _moveDirection.x = -1;
        }
        if(Input.GetKey(KeyCode.D))
        {
            _moveDirection.x = 1;
        }
        
        if (Input.GetKey(KeyCode.W))
        {
            _moveDirection.z = 1;
        }
        if (Input.GetKey(KeyCode.S))
        {
            _moveDirection.z = -1;
        }

        if (Input.GetKey(KeyCode.Space))
        {
            _moveDirection.y = 1;
        }
        if (Input.GetKey(KeyCode.LeftControl))
        {
            _moveDirection.y = -1;
        }

        if (Input.GetMouseButtonDown(1))
        {
            _isLooking = true;
            Cursor.visible = false;
        }
        else if(Input.GetMouseButtonUp(1))
        {
            _isLooking = false;
            Cursor.visible = true;
        }

        if (Input.GetKeyDown(KeyCode.F))
        {
            fog.doFog = !fog.doFog;
        }

        if (Input.GetKeyDown(KeyCode.L))
        {
            _doLighting = !_doLighting;
        }

        if (Input.GetKeyDown(KeyCode.O))
        {
            _overlayActive = !_overlayActive;
        }

        if (_overlayActive)
        {
            foreach (GameObject ui in uiElements)
            {
                ui.SetActive(true);
            }
            
            disabledUI.SetActive(false);
        }
        else
        {
            foreach (GameObject ui in uiElements)
            {
                ui.SetActive(false);
            }
            
            disabledUI.SetActive(true);
        }

        if (Input.GetKeyDown(KeyCode.V))
        {
            _activeUI = wonUI;
            wonUI.SetActive(true);
        }

        if (Input.GetKeyDown(KeyCode.J))
        {
            _activeUI = lostUI;
            lostUI.SetActive(true);
        }

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (_activeUI != null)
            {
                _activeUI.SetActive(false);
                _activeUI = null;
            }
        }

        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            lut.lutType = 1;
        }

        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            lut.lutType = 2;
        }

        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            lut.lutType = 3;
        }

        Vector2 currentMousePosition = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
        _mouseDelta = currentMousePosition - _mousePositionLastFrame;

        Vector3 positionVector = (_moveDirection.z * player.forward + _moveDirection.y * player.up + _moveDirection.x * player.right).normalized;
        player.position +=  positionVector * (speed * Time.deltaTime);

        if (_isLooking)
        {
            player.eulerAngles += new Vector3(-_mouseDelta.y * rotationSpeed * Time.deltaTime, 
                _mouseDelta.x * rotationSpeed * Time.deltaTime, 0);
        }

        _mousePositionLastFrame = currentMousePosition;
        terrainMaterial.SetInt("_DoLighting", _doLighting ? 1 : 0);
    }
}
