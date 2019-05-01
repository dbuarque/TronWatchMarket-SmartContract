pragma solidity 0.4.25;


contract Ownable
{
  event TransferOwnership(
    address indexed previousOwner,
    address indexed newOwner
  );

  address private owner;

  constructor(
  ) internal
  {
    owner = msg.sender;
  }

  function transferOwnership(
    address _newOwner
  ) external
    onlyOwner
  {
    require(_newOwner != address(0), "INVALID_ADDRESS");
    _transferOwnership(_newOwner);
  }

  function renounceOwnership(
  ) external
    onlyOwner
  {
    _transferOwnership(address(0));
  }

  function getOwner(
  ) public view
    returns (address)
  {
    return owner;
  }

  modifier onlyOwner(
  )
  {
    require(msg.sender == owner, "ONLY_OWNER");
    _;
  }

  function _transferOwnership(
    address _newOwner
  ) private
  {
    owner = _newOwner;
    emit TransferOwnership(owner, _newOwner);
  }
}
