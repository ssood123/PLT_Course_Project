function void isTrue(bool b)
{
  if (b) {
     printStr("true");
  } else {
    printStr("false");
  }
}


function void main()
{
  bool b;
  int i;
  b = true;
  isTrue(b);

  i = 0;
  while (i ~= 7) {
    i = i + 1;
    if (i == 4)
    {
      b = false;
    }
  }
  isTrue(b);

}