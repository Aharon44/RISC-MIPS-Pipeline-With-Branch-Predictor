#include <stdlib.h>
#include <stdio.h>

int bubble(int array[], int size)
{
int i, j, swap;

for (i = 0; i <size; i++)
{
for (j = 0; j < size - i - 1; j++)
{
if (array[j] > array[j + 1]) /* For decreasing order use < */
{
swap = array[j];
array[j] = array[j + 1];
array[j + 1] = swap;
}}}
return 1;
}


int main()
{
int i, a, array[1000];
for (i = 0; i<1000; i++)
{
array[i] = rand() % 10000;
}
a = bubble(array, 1000);

printf("Sorted list in ascending order:\n");

for (i = 0; i <1000; i++)
printf("%d\n", array[i]);

return 0;
}
