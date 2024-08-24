// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/contracts/teleporter/ITeleporterMessenger.sol";

contract SenderSubnet {
    // Address of Teleporter Messenger contract is the same for all chains
    ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

    /**
     * @dev Sends a message to another chain.
     */
    function sendMessage(address destinationAddress, uint256 id, address receiver, uint256 amount) external {
        bytes memory encodedFunctionCall = 
        abi.encodeWithSignature("transferUSDCCIP(uint256,address,uint256", id, receiver, amount);
    
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: 0x7fc93d85c6d62c5b2ac0b519c87010ea5294012d1e407030d6acd0021cac10d5,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: 250_000,
                allowedRelayerAddresses: new address[](0),
                message: encodedFunctionCall
            })
        );
    }

    function inputsToMessage(uint256 id, address receiver, uint256 amount) external pure returns (bytes memory) {
        return 
        abi.encodeWithSignature("transferUSDCCIP(uint256,address,uint256)", id, receiver, amount);
    }
}
