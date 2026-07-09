// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    // Declaring a public integer variable. 
    // Making it public automatically creates a getter function to read it.
    int256 public storedValue;

    // Function to increase the value by 1
    function increment() public {
        storedValue += 1;
    }

    // Function to decrease the value by 1
    function decrement() public {
        storedValue -= 1;
    }
}