function void main()
{
  int matrix[3][3] m1;
  int i;
  int j;
  m1 = [[1,2,3],[4,5,6],[7,8,9]];
  m1[0][2] = 30;
  m1[1][2] = 30;
  m1[2][2] = 30;
  
  for (i = 0; i < lenRow(m1); i = i + 1)
  {
    for (j = 0; j < lenCol(m1); j = j + 1)
    {
      print(m1[i][j]);
    }
  }
}
