function void main()
{
  [* This program rotates the matrix 4 times, so the expected output is the original array *]
  float matrix[3][3] m1;
  int i;
  int j;
  m1 = [[1.1,2.1,3.1],[4.1,5.1,6.1],[7.1,8.1,9.1]];
  for (i = 0; i < 4; i = i + 1)
  {
    m1 = rot90(m1);
  }
  for (i = 0; i < lenRow(m1); i = i + 1)
  {
    for (j = 0; j < lenCol(m1); j = j + 1)
    {
      printf(m1[i][j]);
    }
  }
}
