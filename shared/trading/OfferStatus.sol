pragma solidity 0.4.25;

import "../general/UintSafeMath.sol";
import "../general/LibSignature.sol";
import "./MessageDateRequirements.sol";


contract OfferStatus is
  LibSignature,
  MessageDateRequirements
{
  event CancelOffer(
    bytes32 indexed offerHash
  );

  mapping(bytes32 => uint) private hashToAmountConsumed;

  function cancelOffer(
    bytes32 _makerHash,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external
    validSignature(_makerHash, Signature(_v, _r, _s), msg.sender)
  {
    hashToAmountConsumed[_makerHash] =
      115792089237316195423570985008687907853269984665640564039457584007913129639935;
    emit CancelOffer(_makerHash);
  }

  function _getOfferAmountRemaining(
    bytes32 _makerHash,
    address _maker,
    uint _offerAmount,
    uint _creationDate,
    uint _expirationDate
  ) internal view
    returns (uint)
  {
    if(hashToAmountConsumed[_makerHash] >= _offerAmount ||
      _isInvalidDateRequirements(_maker, _creationDate, _expirationDate))
    {
      return 0;
    }

    return _offerAmount - hashToAmountConsumed[_makerHash];
  }

  function _consumeOffer(
    bytes32 _makerHash,
    uint _amountConsumed
  ) internal
  {
    hashToAmountConsumed[_makerHash] += _amountConsumed;
  }
}