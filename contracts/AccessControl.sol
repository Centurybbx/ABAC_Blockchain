// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Management.sol";
import "./Judge.sol";

contract AccessControl {
    
    Management manager;
    Judge judge;

    struct Requester {
        // 0 is initial value, -1 is not requested, 1
        bool isRequested;
        // time of last request
        uint256 ToLR;
    }

    mapping(string => int) private rightTable;

    mapping(string => bool) private blackListIpMap;

    // store ToLR using map: key is addr, value is ToLR
    mapping(address => Requester) private requestMap;

    event AccessControlRet(address from, address to, string action, string result, uint256 accessTime);

    // MC is management contract, JC is judge contract
    function init(address _MCAddr, address _JCAddr) public {
        manager = Management(_MCAddr);
        judge = Judge(_JCAddr);

        // assign right degree, higher number equals higher right.
        rightTable["read"] = 1;
        rightTable["open"] = 2;
        rightTable["close"] = 2;
        rightTable["restart"] = 3;
        rightTable["kill"] = 3;
        blackListIpMap['2.2.2.2'] = true;
    }

    // check if requester have requested, block frequently accessed user
    function checkRequesterStatus() private {
        if(requestMap[msg.sender].isRequested == true) {
            uint256 timeGap = block.timestamp - requestMap[msg.sender].ToLR;
            // request time gap is 10 secs
            if(timeGap <= 10) {
                // give illegal user penalty: block for 10 secs
                judge.setBlackList(msg.sender);
            }
        } else {
            requestMap[msg.sender].isRequested = true;
            requestMap[msg.sender].ToLR = block.timestamp;
        }
    }
    /*
        core function.
    */
    function accessControl(address _objectAddr, string memory action) public returns (bool res) {
        // check if requester have requested
        checkRequesterStatus();

        uint curTime = getCurTime();
        bool isBlocked;
        uint256 ToLB;
        (ToLB, isBlocked) = judge.getBLUByAddr(msg.sender);
        // check if requester is blocked
        if(isBlocked && curTime <= ToLB) {
            emit AccessControlRet(msg.sender, _objectAddr, action, "Still blocked, unable to access!", block.timestamp);

            res = false;
            return res;
        } else {
            // legal user should be unblocked
            judge.unblockUser(msg.sender);
        }

        string memory right = manager.getRight(msg.sender, _objectAddr);
        // check subject's right 
        if(rightTable[action] > rightTable[right]) {
            emit AccessControlRet(msg.sender, _objectAddr, action, "Unauthorized access!", block.timestamp);
            res = false;
            return res;
        }

        string memory subjName;
        string memory subjIP;
        (subjName, subjIP) = manager.getSubjInfo(msg.sender);
        // check subject's ip
        if(blackListIpMap[subjIP]) {
            emit AccessControlRet(msg.sender, _objectAddr, action, "Illegal IP address!", block.timestamp);
            res = false;
            return res;
        }
        // legal user will pass
        emit AccessControlRet(msg.sender, _objectAddr, action, "Access pass!", block.timestamp);
        res = true;
        return res;
    }
    
    function getCurTime() public view returns(uint256) {
        return block.timestamp;
    }

    // function getTimeOfLastRequest(address _sender) public view returns (uint256 time) {
    //     time = requestMap[_sender];
    // }

}