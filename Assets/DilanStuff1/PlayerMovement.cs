using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    //Player's speed.
    public float moveSpeed = 15f;
    //Player's rotation speed.
    public float rotateSpeed = 55f;

    //Variable for jumping
    public float jumpVelocity = 5f;

    public float groundDistance = 0.1f;
    public LayerMask grndLayer;

    private CapsuleCollider col;

    private float VerInput;
    private float HorInput;

    private Rigidbody rb;
    public GameObject deathText;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        col = GetComponent<CapsuleCollider>();
    }

    // Update is called once per frame
    void Update()
    {
        VerInput = Input.GetAxis("Vertical") * moveSpeed;//These establish the movement and rotation axes for each type of movement.
        HorInput = Input.GetAxis("Horizontal") * rotateSpeed;

        if (Input.GetKeyDown(KeyCode.Space) && IsTouchingGround())//When the button is pushed, there's a force on the player to make 
        {                                                         //them jump.
            rb.AddForce(Vector3.up * jumpVelocity, ForceMode.Impulse);
        }
    }

    void FixedUpdate()
    {
        Vector3 rotation = Vector3.up * HorInput;//This allows the player to rotate horizontally with Euler Angles and move in a forward
        Quaternion angleR = Quaternion.Euler(rotation * Time.fixedDeltaTime);                                                  //motion.

        rb.MovePosition(this.transform.position + this.transform.forward * VerInput * Time.deltaTime);
        rb.MoveRotation(rb.rotation * angleR);
    }

    private bool IsTouchingGround()//A boolean value of the bottom of the player's collider touching an object with the layer of grndLayer.
    {
        Vector3 playerBottom = new Vector3(col.bounds.center.x, col.bounds.min.y, col.bounds.center.z);
        bool touchingGround = Physics.CheckCapsule(col.bounds.center, playerBottom, groundDistance, grndLayer, QueryTriggerInteraction.Ignore);
        return touchingGround;
    }


    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.name == "DeathCollector")
        {
            StartCoroutine(DeathCall(2));//This calls the below coroutine.
        }
    }

    //When the player collides with the death plane below, the deathText is set to true and after a period of time, it is set to false.
    //Then the game restarts.
    IEnumerator DeathCall(float seconds)
    {
        if (!deathText.activeInHierarchy)
            deathText.SetActive(true);

        yield return new WaitForSeconds(seconds);

        deathText.SetActive(false);
        Application.LoadLevel(Application.loadedLevel);
    }
}
