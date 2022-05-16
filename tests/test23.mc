function void main()
{
  int array[6] arr;
  float array[7] arr1;
  int array[6] arr2;
  float array[7] arr3;
  int i;
  arr = (1,2,3,4,5,6);
  arr2 = reverse(arr);
  for (i = 0; i < lenArr(arr); i = i + 1) {
    print(arr2[i]);
  }

  arr1 = (1.1,2.2,3.3,4.4,5.5,6.6,7.7);
  arr3 = reverse(arr1);
  for (i = 0; i < lenArr(arr1); i = i + 1) {
    printf(arr3[i]);
  }
}
