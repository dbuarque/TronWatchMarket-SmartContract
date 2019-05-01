pragma solidity 0.4.25;

import "../token/IERC20.sol";
import "../general/UintMath.sol";
import "../general/Ownable.sol";


contract Trc20Proxy is
  Ownable
{
  using UintMath for uint;

  event Trc20Transfer(
    address indexed from,
    address indexed to,
    address indexed token,
    uint amount
  );

  function withdrawTrc20(
    address _to,
    address _token
  ) external
    onlyOwner
  {
    IERC20 erc20 = IERC20(_token);
    uint amount = _getTrc20BalanceOf(address(this), erc20);
    if(amount > 0)
    {
      emit Trc20Transfer(address(this), _to, _token, amount);

      erc20.transfer(_to, amount);
    }
  }

  function _getAvailableTrc20BalanceOf(
    address _account,
    address _token
  ) internal view
    returns(uint)
  {
    IERC20 erc20 = IERC20(_token);
    return _getTrc20BalanceOf(_account, erc20).min(_getAllowance(_account, erc20));
  }

  function _getTrc20WalletBalanceOf(
    address _account,
    address _token
  ) internal view
    returns(uint)
  {
    IERC20 erc20 = IERC20(_token);
    return _getTrc20BalanceOf(_account, erc20);
  }

  function _transferTrc20(
    address _from,
    address _to,
    address _token,
    uint _amount
  ) internal
  {
    if(_amount > 0)
    {
      IERC20 erc20 = IERC20(_token);
      uint balanceBefore = _getTrc20BalanceOf(_to, erc20);

      emit Trc20Transfer(_from, _to, _token, _amount);

      erc20.transferFrom(_from, _to, _amount);

      require(
        balanceBefore < _getTrc20BalanceOf(_to, erc20),
        "TRC20_TRANSFER_FAILED"
      );
    }
  }

  function _getTrc20BalanceOf(
    address _account,
    IERC20 _token
  ) private view
    returns (uint _balance)
  {
    bytes memory callData = abi.encodeWithSelector(
      _token.balanceOf.selector,
      _account
    );
    assembly
    {
      let success := staticcall(
        gas,
        _token,
        add(callData, 32),
        36,
        callData,
        32
      )

      switch success
      case 1
      {
        _balance := mload(callData)
      }
      default
      {
        revert(0, 0)
      }
    }
  }

  function _getAllowance(
    address _account,
    IERC20 _token
  ) private view
    returns (uint _allowance)
  {
    bytes memory callData = abi.encodeWithSelector(
      _token.allowance.selector,
      _account,
      address(this)
    );
    assembly
    {
      let success := staticcall(
        gas,
        _token,
        add(callData, 32),
        68,
        callData,
        32
      )

      switch success
      case 1
      {
        _allowance := mload(callData)
      }
      default
      {
        revert(0, 0)
      }
    }
  }
}