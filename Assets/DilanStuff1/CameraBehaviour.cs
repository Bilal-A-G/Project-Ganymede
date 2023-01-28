using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBehaviour : MonoBehaviour
{
    public Transform player;
    public float sensitivity = 2f;
    float cameraVertRot = 0f;

    // Start is called before the first frame update
    void Start()
    {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        float moveX = Input.GetAxisRaw("Mouse X") * sensitivity;
        float moveY = Input.GetAxisRaw("Mouse Y") * sensitivity;

        //Vertical Rotation
        cameraVertRot -= moveY;
        cameraVertRot = Mathf.Clamp(cameraVertRot, -90f, 90f);
        transform.localEulerAngles = Vector3.right * cameraVertRot;

        //Horizontal Rotation
        player.Rotate(Vector3.up * moveX);
    }
}
