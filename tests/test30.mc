function void main()
{
  float matrix[3][4] m1;
  float matrix[4][3] m2;
  int i;
  int j;

  m1 = [[1.0,2.0,3.0,4.0],[5.0,6.0,7.0,8.0],[9.0,10.0,11.0,12.0]];
  m2 = transpose(m1);
  
  for(i = 0; i < lenRow(m2); i = i + 1)
  {
    for (j = 0; j < lenCol(m2); j = j + 1)
    {
      printf(m2[i][j]);
    }
  }
  

}
