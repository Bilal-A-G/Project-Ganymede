using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    // how fast we want our player to move
    public float moveSpeed = 15f;
    // how fast we want our player to rotate
    public float rotateSpeed = 55f;

    private float VerInput;
    private float HorInput;

    private Rigidbody rb;
    public GameObject deathText;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        VerInput = Input.GetAxis("Vertical") * moveSpeed;
        HorInput = Input.GetAxis("Horizontal") * rotateSpeed;

        /*        this.transform.Translate(Vector3.forward * VerInput * Time.deltaTime);
                this.transform.Rotate(Vector3.up * HorInput * Time.deltaTime); */
    }

    void FixedUpdate()
    {
        // store our left and right rotation
        Vector3 rotation = Vector3.up * HorInput;
        // Quaternion vs Euler
        Quaternion angleR = Quaternion.Euler(rotation * Time.fixedDeltaTime);

        rb.MovePosition(this.transform.position + this.transform.forward
            * VerInput * Time.deltaTime);
        rb.MoveRotation(rb.rotation * angleR);
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.name == "DeathCollector")
        {
            StartCoroutine(DeathCall(2));
        }
    }

    IEnumerator DeathCall(float seconds)
    {
        if (!deathText.activeInHierarchy)
            deathText.SetActive(true);

        yield return new WaitForSeconds(seconds);

        deathText.SetActive(false);
        Application.LoadLevel(Application.loadedLevel);
    }
}
