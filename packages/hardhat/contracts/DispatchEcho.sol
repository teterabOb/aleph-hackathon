// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/contracts/teleporter/ITeleporterMessenger.sol";
import "../lib/contracts/teleporter/ITeleporterReceiver.sol";

contract DispatchEcho is ITeleporterReceiver {
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    enum DispatchStatus {
        Placed,
        Transit,
        Completed,
        Failed
    }

    struct DispatchStruct {
		uint256 id;
		address clientAddress;
		uint256 totalAmount;
		address dispatcherAddress;
		uint256 dispatcherAmount;
		address businessAddress;
		uint256 businessAmount;
	}

    mapping(uint256 => bool) public dispatchAssigned;
    mapping(uint256 => DispatchStruct) public dispatches;

    event ReceivedMessage(bytes message);

    /**
     * @dev Sends a message to another chain.
     */
    function sendMessage(address destinationAddress, uint256 id, address dispatcherAddress, uint256 amount, uint256 gasLimit) external {
        bytes memory encodedFunctionCall = 
        abi.encodeWithSignature("finalize(uint256,address)", id, dispatcherAddress);
    
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: 0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: gasLimit,
                allowedRelayerAddresses: new address[](0),
                message: encodedFunctionCall
            })
        );
    }

    function inputsToMessage(uint256 id, address dispatcherAddress) external pure returns (bytes memory) {
        return 
        abi.encodeWithSignature("finalize(uint256,address)", id, dispatcherAddress);
    }

    //Change to internal
    function placeDispatch(
            uint256 id, 
            address clientAddress, 
            uint256 totalAmount, 
            address dispatcherAddress, 
            uint256 dispatcherAmount, 
            address businessAddress, 
            uint256 businessAmount
        ) public {
        require(!dispatchAssigned[id], "Dispatch already assigned");
        dispatches[id] = DispatchStruct(id, clientAddress, totalAmount, dispatcherAddress, dispatcherAmount, businessAddress, businessAmount);
        dispatchAssigned[id] = true;
    }

    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        // Only the Teleporter receiver can deliver a message.
        require(msg.sender == address(messenger), "ReceiverOnSubnet: unauthorized TeleporterMessenger");
        (uint256 id, address clientAddress, uint256 totalAmount, address dispatcherAddress, uint256 dispatcherAmount, address businessAddress, uint256 businessAmount) = 
        abi.decode(message[4:], (uint256,address,uint256,address,uint256,address,uint256));
        placeDispatch(id, clientAddress, totalAmount, dispatcherAddress, dispatcherAmount, businessAddress, businessAmount);
        emit ReceivedMessage(message);
    }
}

