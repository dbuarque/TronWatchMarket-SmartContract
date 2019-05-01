pragma solidity 0.4.25;


contract LibSignature
{
  struct Signature
  {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  bytes public constant SIG_PREFIX = "\x19TRON Signed Message:\n32";

  function isValidSignature(
    bytes32 _hash,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    address _signer
  ) external pure
    returns (bool)
  {
    return _isValidSignature(_hash, Signature(_v, _r, _s), _signer);
  }

  function _createSignatures(
    uint8[] memory _v,
    bytes32[] memory _rs
  ) internal pure
    returns (Signature[] memory)
  {
    uint count = _v.length;
    Signature[] memory signatures = new Signature[](count);

    for(uint i = 0; i < count; i++)
    {
      signatures[i] = Signature(
        _v[i],
        _rs[i * 2],
        _rs[1 + i * 2]
      );
    }

    return signatures;
  }

  function _isValidSignature(
    bytes32 _hash,
    Signature memory _signature,
    address _signer
  ) internal pure
    returns (bool)
  {
    return _signer != address(0) &&
      ecrecover(
        keccak256(abi.encodePacked(SIG_PREFIX, _hash)),
        _signature.v,
        _signature.r,
        _signature.s
      ) == _signer;
  }

  modifier validSignature(
    bytes32 _hash,
    Signature memory _signature,
    address _signer
  )
  {
    require(_isValidSignature(_hash, _signature, _signer), "INVALID_SIGNATURE");
    _;
  }
}