// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract ArbitrumReceiver is CCIPReceiver{
    address public _usdcToken = 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d;

    struct Messages { 
        uint256 id;
        address businessAddress;
        uint256 businessAmount;
        address dispatcherAddress;
        uint256 dispatcherAmount;
    }

    mapping(uint256 => Messages) public messages;
    mapping(address => uint256) public balances;

	constructor() CCIPReceiver(0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165){}

	function _ccipReceive(
		Client.Any2EVMMessage memory message
	) internal override {
		(uint256 id, address businessAddress, uint256 businessAmount, address dispatcherAddress, uint256 dispatcherAmount) = 
        abi.decode(message.data, (uint256,address,uint256,address,uint256));
		messages[id] = Messages(id, businessAddress, businessAmount, dispatcherAddress, dispatcherAmount);
        balances[dispatcherAddress] += dispatcherAmount;
        balances[businessAddress] -= businessAmount;
	}

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        IERC20(_usdcToken).transfer(msg.sender, amount);
    }

    function converBytes(bytes memory data) public pure returns (uint256, address, uint256, address, uint256) {
        return abi.decode(data, (uint256,address,uint256,address,uint256));
    }
    
    function ccipInputsToBytes(
		uint256 id,
		address businessAddress,
		uint256 businessAmount,
		address dispatcherAddress,
		uint256 dispatcherAmount
	) public pure returns (bytes memory) {
		return abi.encode("(uint256,address,uint256,address,uint256)", 
            id, businessAddress, businessAmount, dispatcherAddress, dispatcherAmount);
	}
}
