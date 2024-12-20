//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";

contract GenerateInput is Script {
    uint256 airdropAmount = 1 ether;
    string[] types = new string[](2);
    string[] whitelist = new string[](4);
    string constant INPUT_PATH = "/script/results/input.json";

    function run() public {
        // types[0] = "address";
        // types[1] = "uint";
        types = ["address", "uint"];
        whitelist[0] = "0x72cF9c43Ca09Df8b11ae56903cD05011B2Df8F6F";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";

        string memory input = _createJSON();
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log(string.concat(vm.projectRoot(), INPUT_PATH));
    }
    
    function _createJSON() internal view returns (string memory) {
        string memory count = vm.toString(whitelist.length);
        string memory amount = vm.toString(airdropAmount);
        string memory json = string.concat(
            '{',
                ' "types": [',
                    ' "address", ',
                    '"uint"',
                '],',
                '"count":', count, ',',
                '"values": {'
        );

        for(uint256 i = 0; i < whitelist.length; i++){
            if(i != whitelist.length - 1){
            json = string.concat(json, '"', vm.toString(i), '":', '{', '"0":', '"', whitelist[i], '"', ',', '"1":', '"', amount, '"', '},');
            }else{
            json = string.concat(json, '"', vm.toString(i), '":', '{', '"0":', '"', whitelist[i], '"', ',', '"1":', '"', amount, '"', '}');                
            }
        }
        json = string.concat(json, "}", "}");
        return json;
    }
}