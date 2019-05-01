pragma solidity 0.4.25;

import "../general/UintSafeMath.sol";


contract MessageDateRequirements
{
  event SetOfferMinCreationDate(
    address indexed account,
    uint minimumCreationDate
  );

  mapping(address => uint) private accountToMinimumCreationDate;

  function setMinCreationDate(
    uint _minimumCreationDate
  ) external
  {
    accountToMinimumCreationDate[msg.sender] = _minimumCreationDate;
    emit SetOfferMinCreationDate(msg.sender, _minimumCreationDate);
  }

  function getMinCreationDate(
    address _account
  ) external view
    returns (uint)
  {
    return accountToMinimumCreationDate[_account];
  }

  function _isInvalidDateRequirements(
    address _account,
    uint _creationDate,
    uint _expirationDate
  ) internal view
    returns (bool)
  {
    return _expirationDate <= now ||
      accountToMinimumCreationDate[_account] >= _creationDate;
  }
}