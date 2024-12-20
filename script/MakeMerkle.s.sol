//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string;

    Merkle private merkle = new Merkle();

    string private inputPath = string.concat(vm.projectRoot(), "/script/results/input.json");
    string private outputPath = string.concat(vm.projectRoot(), "/script/results/output.json");

    string private elements = vm.readFile(inputPath);
    string[] private types = elements.readStringArray(".types");
    uint256 private count = elements.readUint(".count");
    bytes32[] private leafs = new bytes32[](count);
    string[] inputs = new string[](count);
    string[] outputs = new string[](count);

    function run() public { 

        //to generate the leaf nodes
        for (uint256 i = 0; i < count; i++) {
        string[] memory input = new string[](types.length);
        bytes32[] memory data = new bytes32[](types.length);
            //convert to bytes
            for (uint256 j = 0; j < types.length; j++) {
                if(compareStrings(types[j], "address")) {
                    //get address
                    address user = elements.readAddress(_getValuesByIndex(i, j));
                    data[j] = bytes32(uint256(uint160(user)));
                    input[j] = vm.toString(user);
                }else{
                    //get uint
                    uint256 value = elements.readUint(_getValuesByIndex(i, j));
                    data[j] = bytes32(value);
                    input[j] = vm.toString(value);
                }
            }

            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
            inputs[i] = stringArrayToString(input);
        }

        //need to make the merkle tree and proofs for each leaf node
        for(uint256 i = 0; i < count; i++){
            string memory root = vm.toString(merkle.getRoot(leafs));
            string memory proof = bytes32ArrayToString(merkle.getProof(leafs, i));
            string memory leaf = vm.toString(leafs[i]);
            string memory input = inputs[i];

            //make the JSON Entries
            outputs[i] = _createJSONEntries(input, proof, root, leaf);
        }

        //write to the output file
        vm.writeFile(outputPath, stringArrayToArrayString(outputs));
    }

    function _getValuesByIndex(uint256 i, uint256 j) private pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    function _createJSONEntries(string memory _input, string memory _proof, string memory _root, string memory _leaf) private pure returns (string memory) {
        return string.concat(
            '{"inputs":', _input, ',', '"proof":', _proof, ',', '"root":"', _root, '"', ',', '"leaf":"', _leaf, '"}' 
        );
    }
}