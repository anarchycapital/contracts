//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;


library WalletEnums {

enum WalletPurpose {
    NATIVE,
    SYSTEM,
    REWARDS,
    LOCKEDFUNDS,
    PROJECTSDISTRIBUTION
}

bytes32 constant private native = keccak256(abi.encode("native"));
bytes32 constant private system =  keccak256(abi.encode("system"));
bytes32 constant private rewards =  keccak256(abi.encode("rewards"));
bytes32 constant private locked =  keccak256(abi.encode("locked"));
bytes32 constant private projects =  keccak256(abi.encode("projects"));

function strToWalpurpose(bytes memory _message) public pure returns(WalletPurpose) {

    bytes32 _msg = keccak256(_message);
    if (_msg == native) {
        return WalletPurpose.NATIVE;
    } else if(_msg == system) {
        return WalletPurpose.SYSTEM;

    } else if(_msg == rewards) {
        return WalletPurpose.REWARDS;

    } else if(_msg == locked) {
        return WalletPurpose.LOCKEDFUNDS;

    } else if(_msg == projects) {

        return WalletPurpose.PROJECTSDISTRIBUTION;

    } 
        revert("no matching wallet purpose found");
    

}






}