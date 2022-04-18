// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Judge {

    struct BlackListUser {
        address addr;
        // 0 is normal, 1 is illegral IP, 2 is request too much, 3 is unauthorized
        // uint status;

        // time of last block
        uint256 ToLB;
        // if a user is blocked => true
        bool blocked;
    }

    // if the user is blocked, blackList[user] == true
    mapping(address => BlackListUser) private blackList;

    // log blocked user's info
    event BlockUserInfo(address blockedUser, uint256 ToLB);

    function setBlackList(address _userAddr) public {
        blackList[_userAddr].addr = _userAddr;
        // block for 10 seconds
        blackList[_userAddr].ToLB = block.timestamp + 10;
        blackList[_userAddr].blocked = true;

        emit BlockUserInfo(_userAddr, blackList[_userAddr].ToLB);
    }

    function unblockUser(address _userAddr) public {
        blackList[_userAddr].blocked = false;
    }

    // BLU is black list user
    function getBLUByAddr(address _userAddr) public view returns (uint256 _ToLB, bool _blocked) {
        _ToLB = blackList[_userAddr].ToLB;
        _blocked = blackList[_userAddr].blocked;
    }

    function getCurTime() public view returns (uint256 curTime) {
        curTime = block.timestamp;
    }

}