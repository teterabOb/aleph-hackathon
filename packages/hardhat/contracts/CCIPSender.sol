// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";

contract CCIPSender {
    /**
    AVAX Fuji
    Router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177
    ChainSelector: 14767482510784806043
    LINK Address: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
    USDC: 
    */
    /**
    Arbitrum Sepolia
    Router: 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165
    ChainSelector: 3478487238524512106
    LINK Address: 
     */
	using SafeERC20 for IERC20;

	struct CCIPConfig {
		address router;
		address chainId;
	}

	struct Messages {
		uint256 id;
		address receiver;
		uint256 amount;
	}

	address public receiverCCIPArbitrum;
    // Info hardcoded for AVAX Fuji
	IERC20 private immutable _linkToken = IERC20(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846);
    IERC20 private immutable _usdcToken = IERC20(0x5425890298aed601595a70AB815c96711a31Bc65);
	IRouterClient public router = IRouterClient(0xF694E193200268f9a4868e4Aa017A0118C9a8177);
    address public owner;
    address public receiverTeleporter;

	mapping(uint256 => bool) public sentMessages;

	event TransferUSDCCIP(uint256 indexed id, address businessAddress, uint256 indexed businessAmount, address dispatcherAddress, uint256 indexed dispatcherAmount);
    event EncodeedData(bytes data);
	event TeleporterSender(address teleporterSender);

    error InvalidUsdcToken();
	error NotEnoughBalanceForFees(uint256 balance, uint256 fees);

    constructor() {
        owner = msg.sender;
    }

    function transferUSDCCIP(
		uint256 id,
		address businessAddress,
		uint256 businessAmount,
		address dispatcherAddress,
		uint256 dispatcherAmount
	) external {
        //require(msg.sender == receiverCChain, "CCIPSender: unauthorized ReceiverCCHain");
		require(receiverCCIPArbitrum != address(0), "CCIPSender: receiver not set");
		require(!sentMessages[id], "CCIPSender: message already sent");
		//Transfer USD CCIP to receiver
		// ChainSelector for Arbitrum Sepolia Hardcoded
		uint64 destinationChainSelector = 3478487238524512106;  
		sentMessages[id] = true;
		bytes memory message = abi
		.encodePacked("ccipReceiver(uint256,address,uint256,address,uint256)", 
		id, businessAddress, businessAmount, dispatcherAddress, dispatcherAmount);
		uint256 finalAmount = businessAmount + dispatcherAmount;
		sendCrossChainMessage(destinationChainSelector, finalAmount, message);
		emit TeleporterSender(msg.sender);
		emit TransferUSDCCIP(id, businessAddress, businessAmount, dispatcherAddress, dispatcherAmount);
	}

	function sendCrossChainMessage(
		uint64 destinationChainSelector,
		uint256 amount,
		bytes memory data
	) public returns (bytes32 messageId) {
		Client.EVM2AnyMessage memory message = _buildCCIPMessage(
			receiverCCIPArbitrum, // receiver ccip contract
			address(_usdcToken), // token USDC
			amount, // monto
			address(_linkToken), // LINK Token
			data
		);

		uint256 fees = router.getFee(destinationChainSelector, message);
		if (fees > _linkToken.balanceOf(address(this))) {
			revert NotEnoughBalanceForFees(_linkToken.balanceOf(address(this)), fees);
		}

		messageId = router.ccipSend(destinationChainSelector, message);
        return messageId;
	}

    function infinitApproveLink() onlyOwner public {
        _linkToken.approve(address(router), type(uint256).max);
    }

    function infinitApproveUSDC() onlyOwner public {
        _usdcToken.approve(address(router), type(uint256).max);
    }

    function withdrawLink() public onlyOwner {
        _linkToken.safeTransfer(owner, _linkToken.balanceOf(address(this)));
    }

    function withdrawUSDC() public onlyOwner {
        _usdcToken.safeTransfer(owner, _usdcToken.balanceOf(address(this)));
    }

    function decodeMessage(bytes calldata data) public pure returns (string memory) {
        return abi.decode(data, (string));
    }

	function updateArbitrumCCIPReceiver(address newReceiver) public onlyOwner {
		require(newReceiver != address(0), "CCIPSender: invalid receiver address");
		receiverCCIPArbitrum = newReceiver;
	}

	function _buildCCIPMessage(
		address receiver,
		address token,
		uint256 amount,
		address feeTokenAddress,
		bytes memory data
	) internal pure returns (Client.EVM2AnyMessage memory) {
		Client.EVMTokenAmount[]
			memory tokenAmounts = new Client.EVMTokenAmount[](1);

		tokenAmounts[0] = Client.EVMTokenAmount({
			token: token,
			amount: amount
		});

		return
			Client.EVM2AnyMessage({
				receiver: abi.encode(receiver),
				data: data,
				tokenAmounts: tokenAmounts,
				extraArgs: Client._argsToBytes(
					Client.EVMExtraArgsV1({ gasLimit: 200_000 })
				),
				feeToken: feeTokenAddress
			});
	}

    modifier onlyReceiverTeleporter(){
        require(msg.sender == receiverTeleporter, "CCIPSender: unauthorized TeleporterMessenger");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "CCIPSender: unauthorized Owner");
        _;
    }
}
