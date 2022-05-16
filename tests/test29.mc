function void main()
{
  int matrix[3][3] m1;
  int matrix[3][3] m2;
  int i;
  int j;

  m1 = [[1,2,3],[4,5,6],[7,8,9]];
  m2 = transpose(m1);
  
  for(i = 0; i < lenRow(m2); i = i + 1)
  {
    for (j = 0; j < lenCol(m2); j = j + 1)
    {
      print(m2[i][j]);
    }
  }
  

}
