pragma solidity 0.4.25;

import "./AbstractExchange.sol";
import "../general/Ownable.sol";
import "../trading/Trc20Proxy.sol";


contract Trc20Exchange is
  Ownable,
  Trc20Proxy,
  AbstractExchange
{
  function _fillTrc20Trade(
    address _fromAccount,
    address _toAccount,
    address _token,
    address _affiliate,
    uint _amount,
    uint _houseFee,
    uint _affiliateFee
  ) internal
  {
    _transferTrc20(_fromAccount, _affiliate, _token, _affiliateFee);
    _transferTrc20(_fromAccount, getOwner(), _token, _houseFee);
    _transferTrc20(
      _fromAccount,
      _toAccount,
      _token,
      _amount - _houseFee - _affiliateFee);
  }
}