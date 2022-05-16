function void main()
{
  int i;
  float j;
  for (i = 0; i < 8; i = i + 1)
  {
    if (i == 6) {
      printStr("iIsEqualToSix");
      j = 10.429;
    }
  }

  if (j >= 10.4) {
    printStr("Yes");
    printf(j);
  }
}