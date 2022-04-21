// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Management {

    struct DeviceInfo {
        address deviceAddr;
        string deviceName;
        string deviceType;
        string status;
    }

    struct SubjInfo {
        address subjectAddr;
        string subjectName;
        // store the access right of subj to obj
        mapping(address => string) rightTable; 
        string ipAddr;
    }

    // store device info using map
    mapping(address => DeviceInfo) private deviceInfoMap;

    mapping(address => SubjInfo) public subjInfoMap;

    function setDeviceInfo(address _deviceAddr, string memory _deviceName, string memory _deviceType, string memory _status) public {
        deviceInfoMap[_deviceAddr].deviceAddr = _deviceAddr;
        deviceInfoMap[_deviceAddr].deviceName = _deviceName;
        deviceInfoMap[_deviceAddr].deviceType = _deviceType;
        deviceInfoMap[_deviceAddr].status = _status;
    }

    function setSubjInfo(string memory _subjectName, string memory _ipAddr) public {
        address _subjectAddr = msg.sender;
        subjInfoMap[_subjectAddr].subjectAddr = _subjectAddr;
        subjInfoMap[_subjectAddr].subjectName = _subjectName;
        subjInfoMap[_subjectAddr].ipAddr = _ipAddr;
    }

    // subject register for their right
    function register4Right(address _deviceAddr, string memory right) public {
        // datatype consisting nested mapping(s) must be declared in storage!!!
        subjInfoMap[msg.sender].rightTable[_deviceAddr] = right;
    }
 
    function getDeviceInfoByAddr(address _addr) public view returns (DeviceInfo memory) {
        return deviceInfoMap[_addr];
    }

    function getRight(address _subjectAddr, address _objectAddr) public view returns (string memory) {
        return subjInfoMap[_subjectAddr].rightTable[_objectAddr];
    }

    function getSubjInfo(address _subjectAddr) public view returns (string memory subjName, string memory ipAddr) {
        subjName = subjInfoMap[_subjectAddr].subjectName;
        ipAddr = subjInfoMap[_subjectAddr].ipAddr;
    }

    // hard-code for test
    function init() public {
        // device info
        address device1;
        address device2;
        address device3;
        (device1, device2, device3) = (0xb4d18d483b641200Aa096558C9bA63aeb243002b, 
        0xfF5d2fe96548E05E49C67FcC36C7dBecA2f501f2, 0xbE7186f383961Cc24Ad8012A2F2942667a72788F);
        setDeviceInfo(device1, "d1", "Bulb", "on");
        setDeviceInfo(device2, "d2", "Transformer", "off");
        setDeviceInfo(device3, "d3", "Sensor", "on");


    }

}