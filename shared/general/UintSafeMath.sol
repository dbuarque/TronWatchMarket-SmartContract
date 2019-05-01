pragma solidity 0.4.25;


library UintSafeMath
{
  function mul(
    uint a,
    uint b
  ) internal pure
    returns (uint)
  {
    if (a == 0)
    {
      return 0;
    }

    uint c = a * b;
    require(c / a == b, "SAFE_MUL");

    return c;
  }

  function sub(
    uint a,
    uint b
  ) internal pure
    returns (uint)
  {
    require(b <= a, "SAFE_SUB");
    uint c = a - b;

    return c;
  }

  function add(
    uint a,
    uint b
  ) internal pure
    returns (uint)
  {
    uint c = a + b;
    require(c >= a, "SAFE_ADD");

    return c;
  }
}
