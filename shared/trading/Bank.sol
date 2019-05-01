pragma solidity 0.4.25;

import "../exchange/Trc20Exchange.sol";
import "../exchange/TrxExchange.sol";
import "../exchange/Trc10Exchange.sol";
import "./TrxBank.sol";
import "./Trc20Proxy.sol";
import "./Trc10Bank.sol";


contract Bank is
  TrxBank,
  Trc20Proxy,
  Trc10Bank,
  TrxExchange,
  Trc20Exchange,
  Trc10Exchange
{
  uint public constant IS_TOKEN_TRC20 = 2 ** 255;

  function deposit() public payable
  {
    _trxDeposited(msg.sender, msg.value);
    _trc10Deposited(msg.sender, msg.tokenid, msg.tokenvalue);
  }

  function getAvailableBalanceOf(
    uint _token,
    address _account
  ) public view
    returns (uint)
  {
    if(_token == 0)
    {
      return _getTrxBalanceOf(_account);
    }
    else if(_token > IS_TOKEN_TRC20)
    {
      return _getAvailableTrc20BalanceOf(_account, address(_token));
    }
    else
    {
      return _getTrc10BalanceOf(_account, _token);
    }
  }

  function getWalletBalanceOf(
    uint _token,
    address _account
  ) public view
    returns (uint)
  {
    if(_token == 0)
    {
      return _getTrxWalletBalanceOf(_account);
    }
    else if(_token > IS_TOKEN_TRC20)
    {
      return _getTrc20WalletBalanceOf(_account, address(_token));
    }
    else
    {
      return _getTrc10WalletBalanceOf(_account, _token);
    }
  }

  function _fillTrade(
    address _from,
    address _to,
    uint _token,
    uint _amount,
    bool _autoWithdraw,
    uint _houseFee,
    address _affiliate,
    uint _affiliateFee
  ) internal
  {
    if(_token == 0)
    {
      _fillTrxTrade(
        _from,
        _to,
        _affiliate,
        _amount,
        _autoWithdraw,
        _houseFee,
        _affiliateFee
      );
    }
    else if(_token > IS_TOKEN_TRC20)
    {
      _fillTrc20Trade(
        _from,
        _to,
        address(_token),
        _affiliate,
        _amount,
        _houseFee,
        _affiliateFee
      );
    }
    else
    {
      _fillTrc10Trade(
        _token,
        _from,
        _to,
        _affiliate,
        _amount,
        _autoWithdraw,
        _houseFee,
        _affiliateFee
      );
    }
  }
}