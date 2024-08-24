// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../lib/contracts/teleporter/ITeleporterMessenger.sol";
import "../lib/contracts/teleporter/ITeleporterReceiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CCIPSender} from "./CCIPSender.sol";

// This contract will be deployed on AVALANCHE
contract DispatchCChain is ITeleporterReceiver {
	uint256 public immutable feePercentage = 15;
	uint256 public totalTransfered;
	uint256 public idCounter;
	address public owner;
    address public ccipSender;
	bytes public lastMessage;
	IERC20 private immutable _usdcToken = IERC20(0x5425890298aed601595a70AB815c96711a31Bc65);
	ITeleporterMessenger public immutable messenger = ITeleporterMessenger(0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf);

	struct DispatchStruct {
		uint256 id;
		address clientAddress;
		uint256 totalAmount;
		address dispatcherAddress;
		uint256 dispatcherAmount;
		address businessAddress;
		uint256 businessAmount;
	}

	constructor() {
		owner = msg.sender;
	}

	mapping(uint256 => DispatchStruct) public dispatches;
	mapping(uint256 => bool) public dispatched;

	event Deposited(
		uint256 indexed id,
		address indexed clientAddress,
		address indexed businessAddress,
		uint256 amount
	);
	event ReceivedMessage(bytes message);

	function calculateFee(uint256 amount) public view returns (uint256) {
		return (amount * feePercentage) / 100;
	}

	function getDispatchStruct(
		uint256 id,
		/* totalAmount */
		/* dispatcherAddress  */
		/* dispatcherAmount */
		address businessAddress,
		uint256 amount /* + Fee = businessAmount */
	) public view returns (DispatchStruct memory) {
		uint256 fee = calculateFee(amount);
		uint256 totalAmount = amount + fee;

		DispatchStruct memory dispatchStruct = DispatchStruct({
			id: id,
			clientAddress: msg.sender,
			totalAmount: totalAmount,
			dispatcherAddress: address(0),
			dispatcherAmount: fee,
			businessAddress: businessAddress,
			businessAmount: amount
		});

		return dispatchStruct;
	}

	function sendMessage(
			address destinationAddress, 
			uint256 id, 
			address clientAddress,
			uint256 totalAmount,
			address dispatcherAddress,
			uint256 dispatcherAmount,
			address businessAddress,
			uint256 businessAmount,
			uint256 gasLimit
	) public {
        bytes memory encodedFunctionCall = 
        abi.encodeWithSignature("placeDispatch(uint256,address,uint256,address,uint256,address,uint256)", 
		id, clientAddress, totalAmount,dispatcherAddress, dispatcherAmount, businessAddress, businessAmount);
    
        messenger.sendCrossChainMessage(
            TeleporterMessageInput({
                destinationBlockchainID: 0x1278d1be4b987e847be3465940eb5066c4604a7fbd6e086900823597d81af4c1,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: gasLimit,
                allowedRelayerAddresses: new address[](0),
                message: encodedFunctionCall
            })
        );
    }

    // @param businessAddress The address of the business
	// @param destinationAddress The address of the contract on the destination chain
    // @dev first function that has to be called
	function payout(address businessAddress, uint256 amount, address destinationAddress, uint256 gasLimit) public {
        require(ccipSender != address(0), "ReceiverOnSubnet: CCIPSender not set");
		idCounter++;
		DispatchStruct memory dispatchStruct = getDispatchStruct(
			idCounter,
			businessAddress,
			amount
		);

		require(
			_usdcToken.balanceOf(msg.sender) > dispatchStruct.totalAmount,
			"Dispatch CChain: Insufficient USDC"
		);

		// Remember to execute approve before calling this function
		_usdcToken.transferFrom(
			msg.sender,
			ccipSender, // CCIPSender will handle Cross-Chain Transfer
			dispatchStruct.totalAmount
		);

		dispatched[idCounter] = false;
		dispatches[idCounter] = dispatchStruct;
		emit Deposited(idCounter, msg.sender, businessAddress, amount);

		// Send message to Dispatcher
		sendMessage(
			destinationAddress,
			idCounter,
			msg.sender,
			dispatchStruct.totalAmount,
			address(0),
			dispatchStruct.dispatcherAmount,
			businessAddress,
			amount,
			gasLimit
		);
		/* 
			address destinationAddress, 
			uint256 id, 
			address clientAddress,
			uint256 totalAmount,
			address dispatcherAddress,
			uint256 dispatcherAmount,
			address businessAddress,
			uint256 businessAmount,
			uint256 gasLimit
		*/
	}

	function receiveTeleporterMessage(
		bytes32,
		address,
		bytes calldata message
	) external {
		require(msg.sender == address(messenger),"ReceiverOnSubnet: unauthorized TeleporterMessenger");
		(uint256 id, address dispatcherAddress) = abi
			.decode(message[4:], (uint256, address));
		lastMessage = message;
		finalize(id, dispatcherAddress);
		emit ReceivedMessage(message);
	}

	// @param id The id of the dispatch
	function finalize(uint256 id, address dispatcherAddress) public {
		DispatchStruct storage dispatchStruct = dispatches[id];
		dispatchStruct.dispatcherAddress = dispatcherAddress;
		require(!dispatched[id], "Dispatch: already dispatched");

		require(
			dispatchStruct.clientAddress == msg.sender,
			"Dispatch: unauthorized"
		);

		dispatched[id] = true;
		totalTransfered += dispatchStruct.businessAmount;
		// Transfer USDC to business by CCIP
		// Call CCIP Function
	}

	function emergencyWithdrawUSDC() public onlyOwner {
		_usdcToken.transfer(msg.sender, _usdcToken.balanceOf(address(this)));
	}

	function approveInfinite() public {
		_usdcToken.approve(address(this), type(uint256).max);
	}

    function updateCCIPSender(address newCCIPSender) external onlyOwner() {
        require(newCCIPSender != address(0), "ReceiverOnSubnet: invalid CCIPSender address");
        ccipSender = newCCIPSender;
    }

	modifier onlyOwner() {
		require(msg.sender == owner, "Dispatch: unauthorized");
		_;
	}
}
