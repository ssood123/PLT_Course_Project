int a;
int b;
bool c;
bool d;

a = 18;
b = 9;

/*
loop body
*/
while (a != b) {
  if (b < a) a = a - b;
  else b = b - a;
}

a = a;

c = true;
d = true;
if (c && d == c || d) {
  a = a + b;
  b = 1;
} else
  a = 1;
