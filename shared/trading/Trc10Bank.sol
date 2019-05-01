pragma solidity 0.4.25;

import "../general/UintSafeMath.sol";


contract Trc10Bank
{
  using UintSafeMath for uint;
  event Trc10Deposit(
    address indexed account,
    uint indexed token,
    uint amount
  );
  event Trc10Withdraw(
    address indexed account,
    uint indexed token,
    uint amount
  );
  event Trc10Transfer(
    address indexed from,
    address indexed to,
    uint indexed token,
    uint amount,
    bool autoWithdraw
  );
  event Trc10Burn(
    address indexed account,
    uint indexed token,
    uint amount
  );

  mapping(address => mapping(uint => uint)) private addressToTrc10ToBalance;

  function getTrc10BalanceOf(
    address _account,
    uint _token
  ) external view
    returns (uint)
  {
    return _getTrc10BalanceOf(_account, _token);
  }

  function withdrawTrc10(
    uint _token,
    uint _amount
  ) public
  {
    uint amount;
    if(_amount == 0 || _amount >= addressToTrc10ToBalance[msg.sender][_token])
    {
      amount = addressToTrc10ToBalance[msg.sender][_token];
      addressToTrc10ToBalance[msg.sender][_token] = 0;
    }
    else
    {
      amount = _amount;
      addressToTrc10ToBalance[msg.sender][_token] -= _amount;
    }

    emit Trc10Withdraw(msg.sender, _token, amount);

    msg.sender.transferToken(amount, _token);
  }

  function _getTrc10BalanceOf(
    address _account,
    uint _token
  ) internal view
    returns (uint)
  {
    return addressToTrc10ToBalance[_account][_token];
  }

  function _getTrc10WalletBalanceOf(
    address _account,
    uint _token
  ) internal view
    returns (uint)
  {
    return _account.tokenBalance(_token);
  }

  function _burnTrc10(
    address _from,
    uint _token,
    uint _amount
  ) internal
  {
    if(_amount > 0)
    {
      addressToTrc10ToBalance[_from][_token] =
        addressToTrc10ToBalance[_from][_token].sub(_amount);
      address(0x77944D19C052B73Ee2286823AA83F8138cb7032f)
        .transferToken(_amount, _token);
      emit Trc10Burn(_from, _token, _amount);
    }
  }

  function _transferTrc10(
    address _from,
    address _to,
    uint _token,
    uint _amount,
    bool _autoWithdraw
  ) internal
  {
    if(_amount > 0)
    {
      addressToTrc10ToBalance[_from][_token] =
        addressToTrc10ToBalance[_from][_token].sub(_amount);

      emit Trc10Transfer(_from, _to, _token, _amount, _autoWithdraw);

      if(_autoWithdraw)
      {
        _to.transferToken(_amount, _token);
      }
      else
      {
        addressToTrc10ToBalance[_to][_token] += _amount;
      }
    }
  }

  function _trc10Deposited(
    address _account,
    uint _token,
    uint _amount
  ) internal
  {
    if(_amount > 0)
    {
      addressToTrc10ToBalance[_account][_token] += _amount;
      emit Trc10Deposit(_account, _token, _amount);
    }
  }
}