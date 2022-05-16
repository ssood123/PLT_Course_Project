function int doMore(int a)
{
  while (a < 4) {
    a = a + 1;
  }
  return a;
}

function void main()
{
  int i;
  int j;
  i = 0;
  if (i ~= 0) {
    printStr("Yes");
    print(i);
  } else {
    printStr("No");
    print(i);
  }
  
  j = doMore(i);
  print(j);
  
}