pragma solidity 0.4.25;

import "../general/UintSafeMath.sol";
import "../general/LibSignature.sol";
import "./MessageDateRequirements.sol";


contract OrderStatus is
  LibSignature,
  MessageDateRequirements
{
  event CancelOrder(
    bytes32 indexed orderHash
  );

  mapping(bytes32 => bool) private hashHasBeenConsumed;

  function cancelOrder(
    bytes32 _takerHash,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external
    validSignature(_takerHash, Signature(_v, _r, _s), msg.sender)
  {
    _consumeOrder(_takerHash);
    emit CancelOrder(_takerHash);
  }

  function getOrderIsValid(
    address _taker,
    bytes32 _takerHash,
    uint _creationDate,
    uint _expirationDate,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external view
    returns (bool)
  {
    return _getOrderIsValid(
      _taker,
      _takerHash,
      _creationDate,
      _expirationDate,
      Signature(_v, _r, _s)
    );
  }

  function _consumeOrder(
    bytes32 _takerHash
  ) internal
  {
    hashHasBeenConsumed[_takerHash] = true;
  }

  function _getOrderIsValid(
    address _taker,
    bytes32 _takerHash,
    uint _creationDate,
    uint _expirationDate,
    Signature memory _takerSignature
  ) internal view
    validSignature(_takerHash, _takerSignature, _taker)
    returns (bool)
  {
    if(_isInvalidDateRequirements(_taker, _creationDate, _expirationDate))
    {
      return false;
    }

    return !hashHasBeenConsumed[_takerHash];
  }
}