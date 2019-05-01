pragma solidity 0.4.25;

import "../general/Ownable.sol";
import "./AbstractExchange.sol";
import "../trading/Trc10Bank.sol";


contract Trc10Exchange is
  Ownable,
  Trc10Bank,
  AbstractExchange
{
  function _fillTrc10Trade(
    uint _token,
    address _fromAccount,
    address _toAccount,
    address _affiliate,
    uint _amount,
    bool _autoWithdraw,
    uint _houseFee,
    uint _affiliateFee
  ) internal
  {
    _transferTrc10(
      _fromAccount,
      _affiliate,
      _token,
      _affiliateFee,
      false
    );
    _transferTrc10(
      _fromAccount,
      getOwner(),
      _token,
      _houseFee,
      false
    );
    _transferTrc10(
      _fromAccount,
      _toAccount,
      _token,
      _amount - _houseFee - _affiliateFee,
      _autoWithdraw);
  }
}