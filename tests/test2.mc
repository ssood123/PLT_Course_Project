function void printOneMore()
{
  printStr("Last");
}


function void printMore()
{
  print(108);
  printf(99.9-99.81);
  printStr("New");
  printOneMore();
}


function void main()
{
  int a;
  float b;
  string c;
  a = 110 + 120;
  b = 110.0253 * 56.7;
  c = "thisIsATest";
  print(a);
  printf(b);
  printStr(c);
  printMore();
}