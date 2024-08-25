// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/contracts/teleporter/ITeleporterMessenger.sol";
import "../lib/contracts/teleporter/ITeleporterReceiver.sol";
import {CCIPSender} from "./CCIPSender.sol";

contract ReceiverCChain is ITeleporterReceiver {
    bool public isSucceded;
    address public immutable owner = msg.sender;
    address public ccipSender;
    bytes public lastMessage;

    uint256 public lastId;
    address public lastReceiver;
    uint256 public lastAmount;    
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    event ReceivedMessage(bytes message);
    event TransferResult(bool success);
    event DataFromTeleporter(uint256 id, address receiver, uint256 amount);

    /**
    * @dev Receives a message from another chain.
     */
    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        // Only the Teleporter receiver can deliver a message.
        //require(msg.sender == address(messenger), "ReceiverOnSubnet: unauthorized TeleporterMessenger");
       // require(ccipSender != address(0), "ReceiverOnSubnet: CCIPSender not set");
        lastMessage = message;
        // This doesn't work because dunno why
        //(bool success, ) = ccipSender.call(message);


        //require(success, "ReceiverOnSubnet: failed to Transfer through Teleporter - CCIP");

        (uint256 id, address receiver, uint256 amount) = abi.decode(message[4:], (uint256, address, uint256));
        lastId = id;
        lastReceiver = receiver;
        lastAmount = amount;
        //(bool success, ) = ccipSender.call(message);
        //CCIPSender(ccipSender).transferUSDCCIP(id, receiver, amount);

        emit DataFromTeleporter(id, receiver, amount);
        emit ReceivedMessage(message);
    }

    /**
     * @dev Sends a message to another chain.
     */
    function sendMessage(address destinationAddress, uint256 id, address receiver, uint256 amount, uint256 gasLimit) external {
        bytes memory encodedFunctionCall = 
        abi.encodeWithSignature("transferUSDCCIP(uint256,address,uint256", id, receiver, amount);
    
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: 0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5, // L1-ECHO
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: gasLimit,
                allowedRelayerAddresses: new address[](0),
                message: encodedFunctionCall
            })
        );
    }

    function updateCCIPSender(address newCCIPSender) external {
        //require(msg.sender == address(owner), "ReceiverOnSubnet: unauthorized Owner");
        require(newCCIPSender != address(0), "ReceiverOnSubnet: invalid CCIPSender address");
        ccipSender = newCCIPSender;
    }
}
    