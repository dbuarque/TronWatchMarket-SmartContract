pragma solidity 0.4.25;


library UintMath
{
  function min(
    uint a,
    uint b
  ) internal pure
    returns (uint)
  {
    if(b < a)
    {
      return b;
    }

    return a;
  }

  function min(
    uint a,
    uint b,
    uint c
  ) internal pure
    returns (uint)
  {
    if(b < a)
    {
      if(c < b)
      {
        return c;
      }
      return b;
    }

    if(c < a)
    {
      return c;
    }

    return a;
  }
}
