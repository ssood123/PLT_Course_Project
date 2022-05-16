function void main()
{
  int i;
  bool b;
  bool c;
  b = false;
  i = 1;
  if (i == 1) {
    c = second(b);
    if (c) {
      printStr("true");
    } else {
      printStr("false");
    }
  }
}

function bool second(bool b)
{
  return not b;
}