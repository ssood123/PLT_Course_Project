int i;

function void main()
{
  i = 7;
  print(i);
  main1();
}

function void main1()
{
  i = i + 1;
  print(i);
  main2();
}

function void main2()
{
  i = i + 2;
  print(i);
}