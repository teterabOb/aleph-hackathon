// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../lib/contracts/teleporter/ITeleporterMessenger.sol";
import "../lib/contracts/teleporter/ITeleporterReceiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CCIPSender} from "./CCIPSender.sol";
import {DispatchEcho} from "./DispatchEcho.sol";

// This contract will be deployed on AVALANCHE
contract DispatchCChain is ITeleporterReceiver {
	uint256 public immutable feePercentage = 15;
	uint256 public totalTransfered;
	uint256 public idCounter;
	address public owner;
    address public ccipSender;
	bytes public lastMessage;
	address public dispatchEcoContrat;
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
                destinationBlockchainID: 0x9f3be606497285d0ffbb5ac9ba24aa60346a9b1812479ed66cb329f394a4b1c7,
                destinationAddress: destinationAddress,
                feeInfo: TeleporterFeeInfo({feeTokenAddress: address(0), amount: 0}),
                requiredGasLimit: gasLimit,
                allowedRelayerAddresses: new address[](0),
                message: encodedFunctionCall
            })
        );
    }

	function sendMessageMockUp(
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
		DispatchEcho(dispatchEcoContrat).receiveTeleporterMessageMockUp(
			encodedFunctionCall
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

		/*
		require(
			_usdcToken.balanceOf(msg.sender) > dispatchStruct.totalAmount,
			"Dispatch CChain: Insufficient USDC"
		);
		*/

		// Remember to execute approve before calling this function
		/*
		_usdcToken.transferFrom(
			msg.sender,
			ccipSender, // CCIPSender will handle Cross-Chain Transfer
			dispatchStruct.totalAmount
		);
		*/

		dispatched[idCounter] = false;
		dispatches[idCounter] = dispatchStruct;
		emit Deposited(idCounter, msg.sender, businessAddress, amount);

		// Send message to Dispatcher
		// We are using the mockup function to simulate the message
		// because teleporter is out of funds cuz of us
		sendMessageMockUp(
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
	}

	function receiveTeleporterMessage(
		bytes32,
		address,
		bytes calldata message
	) external {
		(uint256 id, address dispatcherAddress) = abi
			.decode(message[4:], (uint256, address));
		completeOrder(id, dispatcherAddress);
		emit ReceivedMessage(message);
	}

	function receiveTeleporterMessageMockUp(
		bytes calldata message
	) external {
		(uint256 id, address dispatcherAddress) = abi
			.decode(message[4:], (uint256, address));
		completeOrder(id, dispatcherAddress);
		emit ReceivedMessage(message);
	}

	// @param id The id of the dispatch
	function completeOrder(uint256 id, address dispatcherAddress) public {
		DispatchStruct storage ds = dispatches[id];
		ds.dispatcherAddress = dispatcherAddress;
		require(!dispatched[id], "Dispatch: already dispatched");		
		dispatched[id] = true;
		totalTransfered += ds.businessAmount;
		//CCIPSender(ccipSender).transferUSDCCIP(id, ds.businessAddress, ds.businessAmount, ds.dispatcherAddress, ds.dispatcherAmount);
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

	function updateDispatchEchoContract(address newDispatchEchoContract) external onlyOwner() {
		require(newDispatchEchoContract != address(0), "ReceiverOnSubnet: invalid DispatchEcho address");
		dispatchEcoContrat = newDispatchEchoContract;
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "ReceiverOnSubnet: only owner");
		_;
	}
}

