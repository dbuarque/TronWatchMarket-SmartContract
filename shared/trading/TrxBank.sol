pragma solidity 0.4.25;

import "../general/UintSafeMath.sol";


contract TrxBank
{
  event TrxDeposit(
    address indexed account,
    uint amount
  );
  event TrxWithdraw(
    address indexed account,
    uint amount
  );
  event TrxTransfer(
    address indexed from,
    address indexed to,
    uint amount,
    bool autoWithdraw
  );

  mapping(address => uint) private trxBalance;

  function withdrawTrx(
    uint _amount
  ) external
  {
    uint amount;
    if(_amount == 0 || _amount >= trxBalance[msg.sender])
    {
      amount = trxBalance[msg.sender];
      trxBalance[msg.sender] = 0;
    }
    else
    {
      amount = _amount;
      trxBalance[msg.sender] -= _amount;
    }

    emit TrxWithdraw(msg.sender, amount);

    msg.sender.transfer(amount);
  }

  function _getTrxBalanceOf(
    address _account
  ) internal view
    returns (uint)
  {
    return trxBalance[_account];
  }

  function _getTrxWalletBalanceOf(
    address _account
  ) internal view
    returns (uint)
  {
    return _account.balance;
  }

  function _trxDeposited(
    address _account,
    uint _amount
  ) internal
  {
    if(_amount > 0)
    {
      trxBalance[_account] += _amount;
      emit TrxDeposit(_account, _amount);
    }
  }

  function _transferTrx(
    address _from,
    address _to,
    uint _amount,
    bool _autoWithdraw
  ) internal
  {
    if(_amount > 0)
    {
      trxBalance[_from] -= _amount;

      emit TrxTransfer(_from, _to, _amount, _autoWithdraw);

      if(_autoWithdraw)
      {
        _to.transfer(_amount);
      }
      else
      {
        trxBalance[_to] += _amount;
      }
    }
  }
}