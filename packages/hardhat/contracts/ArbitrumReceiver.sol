// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

contract ArbitrumReceiver is CCIPReceiver{

    struct Messages { 
        uint256 id;
        address businessAddress;
        uint256 businessAmount;
        address dispatcherAddress;
        uint256 dispatcherAmount;
    }

    mapping(uint256 => Messages) public messages;

	constructor(address router) CCIPReceiver(router){}

	function _ccipReceive(
		Client.Any2EVMMessage memory message
	) internal override {
		(uint256 id, address businessAddress, uint256 businessAmount, address dispatcherAddress, uint256 dispatcherAmount) = 
        abi.decode(message.data, (uint256,address,uint256,address,uint256));
		messages[id] = Messages(id, businessAddress, businessAmount, dispatcherAddress, dispatcherAmount);
        
	}
}
