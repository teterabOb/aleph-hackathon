// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../lib/contracts/teleporter/ITeleporterMessenger.sol";
import "../lib/contracts/teleporter/ITeleporterReceiver.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// This contract will be deployed on AVALANCHE
contract DispatchCChain is ITeleporterReceiver{
	uint256 public totalTransfered;
	uint256 public feePercentage = 15;
	uint256 public idCounter;
	IERC20 private immutable _usdcToken =
		IERC20(0x5425890298aed601595a70AB815c96711a31Bc65);
	address public owner;
    bytes public lastMessage;
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

	function payout(address businessAddress, uint256 amount) public {
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
			address(this),
			dispatchStruct.totalAmount
		);

		dispatched[idCounter] = false;
		dispatches[idCounter] = dispatchStruct;
		emit Deposited(idCounter, msg.sender, businessAddress, amount);
	}

    function receiveTeleporterMessage(bytes32, address, bytes calldata message) external {
        require(msg.sender == address(messenger), "ReceiverOnSubnet: unauthorized TeleporterMessenger");
        /*  
            id
            dispatcherAddress
            dispatcherAmount 
        */
        (uint256 id, address dispatcherAddress, uint256 dispatcherAmount) = abi.decode(message[4:], (uint256, address, uint256));
        lastMessage = message;
        finalize(id);
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

	modifier onlyOwner() {
		require(msg.sender == owner, "Dispatch: unauthorized");
		_;
	}
}
