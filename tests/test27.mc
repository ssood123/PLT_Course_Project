function void main()
{
  int matrix[2][2] mat;
  int matrix[2][2] mat2;
  int matrix[2][2] mat3;
  int i;
  int j;
  mat = [[1,2],[3,4]];
  mat2 = [[2,3],[4,5]];
  mat3 = mat *.. mat2;


  
  for (i = 0; i < lenRow(mat3); i = i + 1)
  {
    for (j = 0; j < lenCol(mat3); j = j + 1)
    {
      print(mat3[i][j]);
    }
  }
  

}
