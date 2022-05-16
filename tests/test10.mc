float f;

function void main()
{
  f = 7.80;
  printf(f);
  f = main1(f);
  printf(f);
}

function float main1(float f)
{
  return f - 90.23;
}
