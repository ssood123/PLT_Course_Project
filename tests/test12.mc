function void main()
{
  int i;
  i = 7;

  if (i == 7) {
    i = i - 3;
    if (i > 10)
    {
      i = i - 3;
      print(i);
    } else {
      i = i + 1;
      print(i);
    }
  } else {
    i = i + 3;
    print(i);
  }
}