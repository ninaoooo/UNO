using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private CharacterController _character;
    private Animator _animator;
    public float speed = 1f;
    // Start is called before the first frame update
    void Start()
    {
        _character = GetComponent<CharacterController>();
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 dir = new Vector3(horizontal,0,vertical);
        if (dir != Vector3.zero){
            Vector3 moveDir = dir.normalized *speed *Time.deltaTime;
            Debug.Log("Before Move: " + transform.position);
            _character.Move(moveDir);
            Debug.Log("After Move: " + transform.position);
            transform.rotation = Quaternion.LookRotation(dir);
            _animator.SetBool("isRun",true);
        }
        else{
            _animator.SetBool("isRun",false);
        }  
    }
}
