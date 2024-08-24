// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// This contract will be deployed on AVALANCHE
contract Dispatch {
	uint256 public transfered;
	uint256 public feePercentage = 15;
	uint256 public idCounter;
	IERC20 private immutable _usdcToken =
		IERC20(0x5425890298aed601595a70AB815c96711a31Bc65);

	struct DispatchStruct {
		uint256 id;
		address clientAddress;
		uint256 totalAmount;
		address dispatcherAddress;
		uint256 dispatcherAmount;
		address businessAddress;
		uint256 businessAmount;
	}

	mapping(uint256 => DispatchStruct) public dispatches;
	mapping(uint256 => bool) public dispatched;

	event Deposited(uint256 indexed id, address indexed clientAddress, address indexed businessAddress,uint256 amount);

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

	function payout(
		address businessAddress,
		uint256 amount
	) public {
		idCounter++;
		DispatchStruct memory dispatchStruct = getDispatchStruct(
			idCounter,
			businessAddress,
			amount
		);

        require(_usdcToken.balanceOf(msg.sender) > dispatchStruct.totalAmount, "Dispatch CChain: Insufficient USDC");

		_usdcToken.transferFrom(
			msg.sender,
			address(this),
			dispatchStruct.totalAmount
		);

		dispatched[idCounter] = false;
		dispatches[idCounter] = dispatchStruct;
		emit Deposited(idCounter, msg.sender, businessAddress, amount);
	}

    function finalize(uint256 id) public { 
        DispatchStruct storage dispatchStruct = dispatches[id];
        require(!dispatched[id], "Dispatch: already dispatched");
        require(dispatchStruct.clientAddress == msg.sender, "Dispatch: unauthorized");
        _usdcToken.transfer(dispatchStruct.businessAddress, dispatchStruct.businessAmount);
        _usdcToken.transfer(dispatchStruct.dispatcherAddress, dispatchStruct.dispatcherAmount);
        dispatched[id] = true;
        transfered += dispatchStruct.businessAmount;
    }

	function approveInfinite() public {
		_usdcToken.approve(address(this), type(uint256).max);
	}
}
