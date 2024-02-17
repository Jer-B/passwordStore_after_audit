# my understanding of the project

- store any passwords that users register.
- Users should be able to store a password and then retrieve it later.
- Other persons than the user who registered a password, should not be able to access the password.

# To verify

pragma version is not the most updated stable version：
// q is this the correct version ?
0.8.18 -> 0.8.24

// q why us the password stored in a single variable ?

// q where is the mapping address to string for storing more than one password ?

// q why anybody can set a new password ?
// @audit access control attack. high.

// q why password is not hashed to be encrypted ?

// @audit there is no password to be set as parameter. q the below is needed ?

// q only owner can read password ?
if (msg.sender != s_owner) {
revert PasswordStore\_\_NotOwner();
}

# Vector of attack

Ownership / Access control attack

- only owner can see password, users can't.
- Password isnt hidden anyway

{
"storage": [
{
"astId": 43436,
"contract": "src/PasswordStore.sol:PasswordStore",
"label": "s_owner",
"offset": 0,
"slot": "0",
"type": "t_address"
},
{
"astId": 43438,
"contract": "src/PasswordStore.sol:PasswordStore",
"label": "s_password",
"offset": 0,
"slot": "1",
"type": "t_string_storage"
}
],
"types": {
"t_address": {
"encoding": "inplace",
"label": "address",
"numberOfBytes": "20"
},
"t_string_storage": {
"encoding": "bytes",
"label": "string",
"numberOfBytes": "32"
}
}
}
