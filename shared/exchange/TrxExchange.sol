pragma solidity 0.4.25;

import "../general/Ownable.sol";
import "./AbstractExchange.sol";
import "../trading/TrxBank.sol";


contract TrxExchange is
  Ownable,
  TrxBank,
  AbstractExchange
{
  function _fillTrxTrade(
    address _fromAccount,
    address _toAccount,
    address _affiliate,
    uint _amount,
    bool _autoWithdraw,
    uint _houseFee,
    uint _affiliateFee
  ) internal
  {
    _transferTrx(
      _fromAccount,
      _affiliate,
      _affiliateFee,
      false
    );
    _transferTrx(
      _fromAccount,
      getOwner(),
      _houseFee,
      false
    );
    _transferTrx(
      _fromAccount,
      _toAccount,
      _amount - _houseFee - _affiliateFee,
      _autoWithdraw);
  }
}