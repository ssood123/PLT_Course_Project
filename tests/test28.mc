function void main()
{
  float matrix[2][3] mat;
  float matrix[2][3] mat2;
  float matrix[2][3] mat3;
  int i;
  int j;
  mat = [[1.0,2.0,3.0],[4.0,5.0,6.0]];
  mat2 = [[1.0,2.0,3.0],[4.0,5.0,6.0]];
  mat3 = mat /.. mat2;


  
  for (i = 0; i < lenRow(mat3); i = i + 1)
  {
    for (j = 0; j < lenCol(mat3); j = j + 1)
    {
      printf(mat3[i][j]);
    }
  }
  

}
