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
        CCIPSender(ccipSender).transferUSDCCIP(id, receiver, amount);

        emit DataFromTeleporter(id, receiver, amount);
        emit ReceivedMessage(message);
    }

    function updateCCIPSender(address newCCIPSender) external {
        //require(msg.sender == address(owner), "ReceiverOnSubnet: unauthorized Owner");
        require(newCCIPSender != address(0), "ReceiverOnSubnet: invalid CCIPSender address");
        ccipSender = newCCIPSender;
    }
}
    