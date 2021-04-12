using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PController : MonoBehaviour
{
    [SerializeField] private float speed = 2;
    
    [SerializeField] private float rotationSpeed = 5;
    
    [SerializeField] private Vector2 movementLimit = Vector2.one;
    
    private PAnimationController _animationController = null;

    private Player _player = null;

    private bool _canMove = true;

    private Vector2 _direction = Vector2.zero;
    
    private void Start()
    {
        _player = GetComponent<Player>();
        
        _animationController = GetComponent<PAnimationController>();
    }

    private void FixedUpdate()
    {
        if (CanMove())
        {
            // Handle Movement
            var direction = new Vector3(_direction.x * speed, 0, speed);

            transform.position += direction * Time.fixedDeltaTime;
            
            // Handle Rotation
            var currRotation = transform.rotation;

            var targetRotation = Quaternion.Euler(new Vector3(0, Mathf.Atan2(_direction.x, _direction.y) * 90 / Mathf.PI, 0));

            transform.rotation = Quaternion.Lerp(currRotation, targetRotation, Time.fixedDeltaTime * rotationSpeed);
        }
        
        ValidateLocation();
    }

    private bool CanMove()
    {
        return _canMove;
    }
    
    private void OnDragged(Vector2 direction)
    {
        _direction = direction;
    }

    private void OnReleased()
    {
        _direction = Vector2.zero;
    }

    private void OnPressed()
    {
        // TODO
    }

    private void ValidateLocation()
    {
        var currentLocation = transform.position;

        if (currentLocation.x >= movementLimit.y)
        {
            currentLocation.x = movementLimit.y;
            
            _direction = Vector2.zero;
        }
            
        else if (currentLocation.x <= movementLimit.x)
        {
            currentLocation.x = movementLimit.x;
            
            _direction = Vector2.zero;
        }

        transform.position = currentLocation;
    }

    private void OnEnable()
    {
        Joystick.OnJoystickDrag += OnDragged;
        Joystick.OnJoystickPress += OnPressed;
        Joystick.OnJoystickRelease += OnReleased;
    }
    
    private void OnDisable()
    {
        Joystick.OnJoystickDrag -= OnDragged;
        Joystick.OnJoystickPress -= OnPressed;
        Joystick.OnJoystickRelease -= OnReleased;
    }
}
