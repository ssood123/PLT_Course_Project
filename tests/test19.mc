function void main()
{
  int array[6] arr;
  int array[6] arr2;
  int array[6] arr3;
  float array[6] arr4;
  float array[6] arr5;
  float array[6] arr6;
  int i;

  arr =  (2,3,4,5,6,7);
  arr2 = (1,2,3,4,5,6);
  arr4 =  (2.2,3.3,4.4,5.5,6.6,7.7);
  arr5 = (1.1,2.1,3.1,4.1,5.1,6.1); 
  
  arr3 = arr +. arr2;
  arr6 = arr4 +. arr5;

  for (i = 0; i < 6; i = i + 1)  {
    print(arr3[i]);
  }
  for (i = 0; i < 6; i = i + 1)  {
    printf(arr6[i]);
  }
  
}
