# Minimal Audit Report - English [Jump to Japanese Version]{#japanese}

#

### [S-Low] Pragma version is outdated. Verify there is no breaking changes since then.

**Description:**<br />
pragma version is not the most updated stable version:
// q is this the correct version ?

**Impact:**<br />
Outdated version can lead to exploits and vulnerabilities that has been fixed in the latest version.
Contract: `PasswordStore.sol`

**Proof of Concept:**<br />
0.8.18 -> 0.8.24

**Recommended Mitigation:**<br />
0.8.18 -> 0.8.24

#

### [S-Low] Missing parameter or wrong description in getPassword function, add it or remove it.

**Description:**<br />
// @audit there is no password to be set as parameter. q the below is needed ?

- `PasswordStore:: @param newPassword The new password to set.`

**Impact:**<br />
Low impact if the description is wrong.

**Proof of Concept:**<br />

remove this line -> `PasswordStore:: * @param newPassword The new password to set.`

```solidity
    /*
     * @notice This allows only the owner to retrieve the password.
     * @param newPassword The new password to set.
     */

function getPassword() external view returns (string memory) {
if (msg.sender != s_owner) {
// q only owner can read password ?
revert PasswordStore\_\_NotOwner();
}
return s_password;
}
```

**Recommended Mitigation:**<br />
Add the parameter `PasswordStore:: newPassword` or remove it from the description.

```diff
- * @param newPassword The new password to set.

```

#

### [S-Very-High] No matter the visibility keyword, `PasswordStore:: s_password` is public and visible by anyone.

**Description:**<br />
`PasswordStore:: private` keyword concerns readibility of the variable in the contract, but it is still visible by anyone. Which breaks completly the purpose of the protocol.

- `PasswordStore:: string private s_password;`

[https://docs.soliditylang.org/en/v0.8.24/cheatsheet.html#function-visibility-specifiers](https://docs.soliditylang.org/en/v0.8.24/cheatsheet.html#function-visibility-specifiers)

**Impact:**<br />
No password is safe in the contract.

**Proof of Concept:**<br />

Proof of Code showing how to read a private variable in a contract:

run a local chain

```
anvil
```

deploy contract

```
make deploy
```

Get storage value of `s_password`

```
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1
```

returned bytes:

```
0x6d7950617373776f726400000000000000000000000000000000000000000014
```

Bytes to string

```
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

Returned string:

```
myPassword
```

**Recommended Mitigation:**<br />
Other questions:<br />
// q why us the password stored in a single variable ?<br />
// q where is the mapping address to string for storing more than one password ?<br />
// q why password is not hashed to be encrypted ?<br />
<br />
Idea to mitigate the issue:<br />

Architecture should be reworked. Password should be hashed and encrypted. A mapping should be used to store multiple passwords from many users as possible or for many password per users as possible.<br />
Could encrypt off-chain and store the hash on-chain.<br />

- Requires to remember another password.
- And remove the view function that should show the decrypted password.

As it is a whole rework of the architecture, I am not writing a fix for this issue.

#

### [S-Very-High] Access control attack. Anyone can set a new password.

**Description:**<br />
// q why anybody can set a new password ?<br />
// @audit access control attack. high.

```solidity
    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:**<br />

Previously chosen password will be overwritten, and can be change by anyone.<br />
Leading to loosing control over the password in one instant and deal with the consequences.

**Proof of Concept:**<br />
Test Case `PasswordStore.t.sol`:

- When deploying the contract the password is set to `myPassword`.
- Using another address than the Owner address,I call the `PasswordStore::setPassword` function using a different password as input: `myNewPassword`.
- Then after, using the Owner address, I call the `PasswordStore::getPassword` function to retrieve the password.
- If the password is `myNewPassword`, then it is a success ↓(succeeded)

<details>
<summary>Code</summary>

```solidity
    function test_anyone_can_change_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.startPrank(randomAddress);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);

        vm.startPrank(owner);
        string memory actualPassword = passwordStore.getPassword();
        console.log(actualPassword);
        assertEq(actualPassword, expectedPassword);
    }
```

</details>

**Recommended Mitigation:**<br />

Could use a library like OpenZeppelin's Ownable to manage access control. <br />
Could use a library like OpenZeppelin's Pausable to pause the contract in case of emergency. <br />
Add a modifier or Only Owner check.

```solidity
if (msg.sender != s_owner) {
    revert PasswordStore__NotOwner();
}
```

```solidity
    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */
    function setPassword(string memory newPassword) external {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        s_password = newPassword;
        emit SetNetPassword();
    }
```

#

### [S-Very-High] Ownership / Access control attack. Only owner can see password, users can't.

**Description:**<br />

The Code documentations says:
`PasswordStore:: @notice This allows only the owner to retrieve the password.`

The project documentation says:
`Users should be able to store a password and then retrieve it later. Others should not be able to access the password.`

- So the owner should'nt be allowed to see users passwords.

**Impact:**<br />

Password are not accessible by other users.
Leading to a possible password leaks by the owner.

```solidity
   function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
```

**Recommended Mitigation:**<br />

Rework the architecture or explicitly change the documentation. <br />
Not safe for users.

<a name="japanese"></a>

# 最小限の監査レポート・日本語版

- S = Severity: 深刻度

#

### [S-低い] プラグマのバージョンが古いです。その後に破壊的な変更がないか確認してください。

**説明:**<br />
プラグマのバージョンは最新の安定版ではありません:
// これは正しいバージョンですか？

**影響:**<br />
古いバージョンは,最新バージョンで修正されたエクスプロイトや脆弱性につながる可能性があります。
コントラクト:`PasswordStore.sol`

**概念実証:**<br />
0.8.18 -> 0.8.24

**推奨される軽減策:**<br />
0.8.18 -> 0.8.24

#

### [S-低い] getPassword 関数にパラメーターが欠けているか,説明が間違っています。それを追加するか,または削除してください。

**説明:**<br />
// @audit パラメータとして設定するパスワードはありません。以下が必要ですか？

```
PasswordStore:: @param newPassword 新しく設定するパスワード
```

**影響:**<br />
説明が間違っていても影響は小さい。それ以外の場合は,関数の修正が必要です。

**概念実証:**<br />

この行を削除,

```
@param newPassword 新しく設定するパスワード
```

```solidity
/*
* @notice これにより,所有者のみがパスワードを取得できます。
* @param newPassword 新しく設定するパスワード。
*/

function getPassword() external view returns (string memory) {
if (msg.sender != s_owner) {
// q 所有者のみがパスワードを読むことができますか？
revert PasswordStore__NotOwner();
}
return s_password;
}
```

**推奨される軽減策:**<br />
パラメータ `PasswordStore:: newPassword` を追加するか,説明からそれを削除してください。

```diff
- * @param newPassword 新しく設定するパスワード

```

#

### [S-Very-High] 可視性キーワードに関わらず,PasswordStore:: s_password は誰にでも公開されて見えます。

**説明:**<br />
`PasswordStore:: private` キーワードはコントラクト内の変数の可読性に関するものですが,それでも誰にでも見えます。これはプロトコルの目的を完全に破壊します。

`PasswordStore:: string private s_password;`

[https://docs.soliditylang.org/en/v0.8.24/cheatsheet.html#function-visibility-specifiers](https://docs.soliditylang.org/en/v0.8.24/cheatsheet.html#function-visibility-specifiers)

**影響:**<br />
コントラクト内のパスワードは安全ではありません。

**概念実証:**<br />

コントラクト内のプライベート変数を読む方法を示す証拠コード:

ローカルチェーンを実行

```
anvil
```

コントラクトを導入する

```
make deploy
```

`s_password`のストレージ値を取得

```
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1
```

返されたバイト:

```
0x6d7950617373776f726400000000000000000000000000000000000000000014
```

バイトを文字列に

```
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

返された文字列:

```
myPassword
```

**推奨される軽減策:**<br />
その他の質問:<br />
// q なぜパスワードは単一の変数に格納されていますか？<br />
// q 複数のパスワードを格納するためのアドレスから文字列へのマッピングはどこにありますか？<br />
// q なぜパスワードは暗号化されていませんか？<br />
<br />
問題を解決する方法のアイデア:<br />

アーキテクチャは再検討されるべきです。パスワードはハッシュ化され,暗号化されるべきです。マッピングは,できるだけ多くのユーザーからの複数のパスワードを格納するために使用されるべきです。<br />
オフチェーンで暗号化し,オンチェーンにハッシュを格納することができます。<br />

- 別のパスワードを覚える必要があります。
- 復号化されたパスワードを表示するビュー関数を削除してください。

これはアーキテクチャの全面的な再検討であるため,この問題に対する修正は書いていません。

#

### [S-非常に高い] アクセス制御攻撃。誰でも新しいパスワードを設定できます。

**説明:**<br />
// q なぜ誰でも新しいパスワードを設定できますか？<br />
// @audit アクセス制御攻撃。高い。

```solidity
/*
 * @notice この関数は,所有者のみが新しいパスワードを設定できるようにします。
 * @param newPassword 設定する新しいパスワード。
 */
function setPassword(string memory newPassword) external {
    s_password = newPassword;
    emit SetNetPassword();
}
```

**影響:**<br />

以前選択されたパスワードは上書きされ,誰でも変更することができます。<br />
一瞬でパスワードの制御を失い,その結果に対処することになります。

**概念実証:**<br />

テストーケース `PasswordStore.t.sol`:

- コントラクトが導入される時に,パスワードは`myPassword`。
- 所有者以外のアドレスを使って,`PasswordStore::setPassword`の関数に別なパラメーター内容を入力する。`myNewPassword`
- そのあとは,所有者として,`PasswordStore::getPassword`の関数からパスワードを読み取る。
- もし,パスワードが`myNewPassword`となっている場合は,テストが成功です。↓(成功)

<details>
<summary>Code</summary>

```solidity
    function test_anyone_can_change_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.startPrank(randomAddress);
        string memory expectedPassword = "myNewPassword";
        passwordStore.setPassword(expectedPassword);

        vm.startPrank(owner);
        string memory actualPassword = passwordStore.getPassword();
        console.log(actualPassword);
        assertEq(actualPassword, expectedPassword);
    }
```

</details>

**推奨される軽減策:**<br />

アクセス制御を管理するために,OpenZeppelin の Ownable のようなライブラリを使用することができます。<br />
緊急時にコントラクトを一時停止するために,OpenZeppelin の Pausable のようなライブラリを使用することができます。<br />
`modifier`または所有者のみのチェックを追加します。

```solidity
if (msg.sender != s_owner) {
    revert PasswordStore__NotOwner();
}
```

```solidity
/*
 * @notice この関数は,所有者のみが新しいパスワードを設定できるようにします。
 * @param newPassword 設定する新しいパスワード。
 */
function setPassword(string memory newPassword) external {
    if (msg.sender != s_owner) {
        revert PasswordStore__NotOwner();
    }
    s_password = newPassword;
    emit SetNetPassword();
}
```

#

### [S-非常に高い] 所有権/アクセス制御攻撃。パスワードを見ることができるのは所有者だけで,ユーザーはできません。

**説明:**<br />

コードドキュメンテーションには,次のように記載されています:

```
PasswordStore:: @notice これにより,所有者のみがパスワードを取得できます。
```

プロジェクトドキュメンテーションには,次のように記載されています:

```
ユーザーはパスワードを保存し,後でそれを取得できるようにする必要があります。他の人がパスワードにアクセスすることはできません。
```

- したがって,所有者はユーザーのパスワードを見ることができません。
  **影響:**<br />

他のユーザーによるパスワードのアクセスはできません。
所有者による可能なパスワードの漏洩につながります。

```solidity
   function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
```

**推奨される軽減策:**<br />

アーキテクチャを再検討するか,明確にドキュメンテーションを変更してください。<br />
ユーザーにとって安全ではありません。

#
