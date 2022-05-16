function void main()
{
  int i;
  float f;
  bool b;
  string s;
  i = 10;
  f = 10.234;
  b = true;
  s = "this is a string";
  print(i);
  printf(f);
  printb(b);
  printStr(s);
  print(i * 4);
  printf(f - 8.2);
  printb(b and not b);
  printMore(); 
}

function void printMore() {
  int matrix[4][4] mat1;
  float array[3] arr1;
  float array[3] arr2;
  float array[3] arr3;
  int i;
  int j;
  arr1 = (8.8,9.9,10.10);
  arr2 = (7.7,8.8,9.9);
  arr3 = arr1 -. arr2;
  mat1 = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]];
  print(8 + 9);
  print(3 - 8);
  print(4 * 97);
  print(20 / 2);
  printf(-7.0 + 8.43);
  printf(8.43 - 7.0);
  printf(2.0 * 3.1);
  printf(15.8 / 9.6);
  printb(true);
  printb(false);
  printb(not true);
  printb(not false);
  printb(true and true);
  printb(true and false);
  printb(false and false);
  printb(true or true);
  printb(true or false);
  printb(false or false);
  printStr("printing arr3");
  for (i = 0; i < lenArr(arr3); i = i + 1)
  {
    printf(arr3[i]);
  }
  printStr("printing mat1");
  for (i = 0; i < lenRow(mat1); i = i + 1)
  {
    for (j = 0; j < lenCol(mat1); j = j + 1)
    {
      print(mat1[i][j]);
    }
  }
}