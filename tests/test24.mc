function void main()
{
  int matrix[3][3] mat;
  float matrix[3][4] mat2;
  int i;
  int j;
  mat = [[1,2,3],[4,5,6],[7,8,9]];
  mat2 = [[1.1,2.1,3.1,4.1],[5.1,6.1,7.1,8.1],[9.1,10.1,11.1,12.1]];


  
  for (i = 0; i < lenRow(mat); i = i + 1)
  {
    for (j = 0; j < lenCol(mat); j = j + 1)
    {
      print(mat[i][j]);
    }
  }

  for (i = 0; i < lenRow(mat2); i = i + 1)
  {
    for (j = 0; j < lenCol(mat2); j = j + 1)
    {
      printf(mat2[i][j]);
    }
  }
  

}
