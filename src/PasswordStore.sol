// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // q is this the correct version ?

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see.
 * You can update your password at any time.
 */
contract PasswordStore {
    /**
     * Errors
     */
    error PasswordStore__NotOwner();

    /**
     * Storage Variables
     */

    address private s_owner;

    // @audit private property doesn't hide informations. high
    string private s_password; // q why us the password stored in a single variable ?
    // q where is the mapping address to string for storing more than one password ?

    /**
     * Events
     */
    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */
    // q why anybody can set a new password ?
    // @audit access control attack. high.
    function setPassword(string memory newPassword) external {
        // @audit high. q why password is not hashed to be encrypted ?
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     // @audit there is no password to be set as parameter. q the below is needed ?
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            // q only owner can read password ?
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
