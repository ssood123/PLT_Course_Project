import os
import subprocess


print("TEST 1")
os.system("./integraph.native -l tests/test1.mc > tests/test1.out")
subprocess = subprocess.Popen("lli tests/test1.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '2\n3\n11\n9\n'):
	print("TEST 1 HAS PASSED")


import os
import subprocess

print("TEST 2")
os.system("./integraph.native -l tests/test2.mc > tests/test2.out")
subprocess = subprocess.Popen("lli tests/test2.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '230\n6238.43\nthisIsATest\n108\n0.09\nNew\nLast\n'):
	print("TEST 2 HAS PASSED")


import os
import subprocess

print("TEST 3")
os.system("./integraph.native -l tests/test3.mc > tests/test3.out")
subprocess = subprocess.Popen("lli tests/test3.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '4\n0\n4\n1\n4\n0\n4\n1\n1\n0\n0\n1\n1\n0\n1\n1\n'):
	print("TEST 3 HAS PASSED")


import os
import subprocess

print("TEST 4")
os.system("./integraph.native -l tests/test4.mc > tests/test4.out")
subprocess = subprocess.Popen("lli tests/test4.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '0\n1\n2\n3\n4\n2\n3\n4\n5\n6\n4\n5\n6\n7\n8\n'):
	print("TEST 4 HAS PASSED")


import os
import subprocess

print("TEST 5")
os.system("./integraph.native -l tests/test5.mc > tests/test5.out")
subprocess = subprocess.Popen("lli tests/test5.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == 'No\n0\n4\n'):
	print("TEST 5 HAS PASSED")


import os
import subprocess

print("TEST 6")
os.system("./integraph.native -l tests/test6.mc > tests/test6.out")
subprocess = subprocess.Popen("lli tests/test6.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == 'true\nfalse\n'):
	print("TEST 6 HAS PASSED")


import os
import subprocess

print("TEST 7")
os.system("./integraph.native -l tests/test7.mc > tests/test7.out")
subprocess = subprocess.Popen("lli tests/test7.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == 'iIsEqualToSix\nYes\n10.429\n'):
	print("TEST 7 HAS PASSED")


import os
import subprocess

print("TEST 8")
os.system("./integraph.native -l tests/test8.mc > tests/test8.out")
subprocess = subprocess.Popen("lli tests/test8.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '0\n1\n2\n3\n'):
	print("TEST 8 HAS PASSED")


import os
import subprocess

print("TEST 9")
os.system("./integraph.native -l tests/test9.mc > tests/test9.out")
subprocess = subprocess.Popen("lli tests/test9.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '7\n8\n10\n'):
	print("TEST 9 HAS PASSED")

import os
import subprocess

print("TEST 10")
os.system("./integraph.native -l tests/test10.mc > tests/test10.out")
subprocess = subprocess.Popen("lli tests/test10.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '7.8\n-82.43\n'):
	print("TEST 10 HAS PASSED")

import os
import subprocess

print("TEST 11")
os.system("./integraph.native -l tests/test11.mc > tests/test11.out")
subprocess = subprocess.Popen("lli tests/test11.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '88.88\n90.91\n'):
	print("TEST 11 HAS PASSED")

import os
import subprocess

print("TEST 12")
os.system("./integraph.native -l tests/test12.mc > tests/test12.out")
subprocess = subprocess.Popen("lli tests/test12.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '5\n'):
	print("TEST 12 HAS PASSED")

import os
import subprocess

print("TEST 13")
os.system("./integraph.native -l tests/test13.mc > tests/test13.out")
subprocess = subprocess.Popen("lli tests/test13.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '3\n'):
	print("TEST 13 HAS PASSED")

import os
import subprocess

print("TEST 14")
os.system("./integraph.native -l tests/test14.mc > tests/test14.out")
subprocess = subprocess.Popen("lli tests/test14.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == 'true\n'):
	print("TEST 14 HAS PASSED")

import os
import subprocess

print("TEST 15")
os.system("./integraph.native -l tests/test15.mc > tests/test15.out")
subprocess = subprocess.Popen("lli tests/test15.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n0\n1\n'):
	print("TEST 15 HAS PASSED")

import os
import subprocess

print("TEST 16")
os.system("./integraph.native -l tests/test16.mc > tests/test16.out")
subprocess = subprocess.Popen("lli tests/test16.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '7\n'):
	print("TEST 16 HAS PASSED")

import os
import subprocess

print("TEST 17 (NOTE: AN ERROR IS EXPECTED IN THIS TEST)")
os.system("./integraph.native -l tests/test17.mc > tests/test17.out")
subprocess = subprocess.Popen("lli tests/test17.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == ''):
	print("TEST 17 HAS PASSED")

import os
import subprocess

print("TEST 18")
os.system("./integraph.native -l tests/test18.mc > tests/test18.out")
subprocess = subprocess.Popen("lli tests/test18.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n2\n3\n4\n5\n6\n1.1\n2.2\n3.3\n4.4\n5.5\n6.6\n7.7\n'):
	print("TEST 18 HAS PASSED")

import os
import subprocess

print("TEST 19")
os.system("./integraph.native -l tests/test19.mc > tests/test19.out")
subprocess = subprocess.Popen("lli tests/test19.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '3\n5\n7\n9\n11\n13\n3.3\n5.4\n7.5\n9.6\n11.7\n13.8\n'):
	print("TEST 19 HAS PASSED")

import os
import subprocess

print("TEST 20")
os.system("./integraph.native -l tests/test20.mc > tests/test20.out")
subprocess = subprocess.Popen("lli tests/test20.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n1\n1\n1\n1\n1\n1.1\n1.2\n1.3\n1.4\n1.5\n1.6\n'):
	print("TEST 20 HAS PASSED")

import os
import subprocess

print("TEST 21")
os.system("./integraph.native -l tests/test21.mc > tests/test21.out")
subprocess = subprocess.Popen("lli tests/test21.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '2\n6\n12\n20\n30\n42\n2.42\n6.93\n13.64\n22.55\n33.66\n46.97\n'):
	print("TEST 21 HAS PASSED")

import os
import subprocess

print("TEST 22")
os.system("./integraph.native -l tests/test22.mc > tests/test22.out")
subprocess = subprocess.Popen("lli tests/test22.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '2\n1\n1\n1\n1\n1\n2\n1.57143\n1.41935\n1.34146\n1.29412\n1.2623\n'):
	print("TEST 22 HAS PASSED")

import os
import subprocess

print("TEST 23")
os.system("./integraph.native -l tests/test23.mc > tests/test23.out")
subprocess = subprocess.Popen("lli tests/test23.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '6\n5\n4\n3\n2\n1\n7.7\n6.6\n5.5\n4.4\n3.3\n2.2\n1.1\n'):
	print("TEST 23 HAS PASSED")

import os
import subprocess

print("TEST 24")
os.system("./integraph.native -l tests/test24.mc > tests/test24.out")
subprocess = subprocess.Popen("lli tests/test24.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n2\n3\n4\n5\n6\n7\n8\n9\n1.1\n2.1\n3.1\n4.1\n5.1\n6.1\n7.1\n8.1\n9.1\n10.1\n11.1\n12.1\n'):
	print("TEST 24 HAS PASSED")

import os
import subprocess

print("TEST 25")
os.system("./integraph.native -l tests/test25.mc > tests/test25.out")
subprocess = subprocess.Popen("lli tests/test25.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '3\n5\n7\n9\n11\n13\n15\n17\n19\n'):
	print("TEST 25 HAS PASSED")

import os
import subprocess

print("TEST 26")
os.system("./integraph.native -l tests/test26.mc > tests/test26.out")
subprocess = subprocess.Popen("lli tests/test26.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n'):
	print("TEST 26 HAS PASSED")

import os
import subprocess

print("TEST 27")
os.system("./integraph.native -l tests/test27.mc > tests/test27.out")
subprocess = subprocess.Popen("lli tests/test27.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '2\n6\n12\n20\n'):
	print("TEST 27 HAS PASSED")

import os
import subprocess

print("TEST 28")
os.system("./integraph.native -l tests/test28.mc > tests/test28.out")
subprocess = subprocess.Popen("lli tests/test28.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n1\n1\n1\n1\n1\n'):
	print("TEST 28 HAS PASSED")

import os
import subprocess

print("TEST 29")
os.system("./integraph.native -l tests/test29.mc > tests/test29.out")
subprocess = subprocess.Popen("lli tests/test29.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n4\n7\n2\n5\n8\n3\n6\n9\n'):
	print("TEST 29 HAS PASSED")

import os
import subprocess

print("TEST 30")
os.system("./integraph.native -l tests/test30.mc > tests/test30.out")
subprocess = subprocess.Popen("lli tests/test30.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n5\n9\n2\n6\n10\n3\n7\n11\n4\n8\n12\n'):
	print("TEST 30 HAS PASSED")

import os
import subprocess

print("TEST 31")
os.system("./integraph.native -l tests/test31.mc > tests/test31.out")
subprocess = subprocess.Popen("lli tests/test31.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '3\n6\n9\n2\n5\n8\n1\n4\n7\n'):
	print("TEST 31 HAS PASSED")

import os
import subprocess

print("TEST 32")
os.system("./integraph.native -l tests/test32.mc > tests/test32.out")
subprocess = subprocess.Popen("lli tests/test32.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '-72.8\n1\n'):
	print("TEST 32 HAS PASSED")

import os
import subprocess

print("TEST 33")
os.system("./integraph.native -l tests/test33.mc > tests/test33.out")
subprocess = subprocess.Popen("lli tests/test33.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '10\n10.234\n1\nthis is a string\n40\n2.034\n0\n17\n-5\n388\n10\n1.43\n1.43\n6.2\n1.64583\n1\n0\n0\n1\n1\n0\n0\n1\n1\n0\nprinting arr3\n1.1\n1.1\n0.2\nprinting mat1\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n'):
	print("TEST 33 HAS PASSED")

import os
import subprocess

print("TEST 34")
os.system("./integraph.native -l tests/test34.mc > tests/test34.out")
subprocess = subprocess.Popen("lli tests/test34.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1.1\n2.1\n3.1\n4.1\n5.1\n6.1\n7.1\n8.1\n9.1\n'):
	print("TEST 34 HAS PASSED")


import os
import subprocess

print("TEST 35")
os.system("./integraph.native -l tests/test35.mc > tests/test35.out")
subprocess = subprocess.Popen("lli tests/test35.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1\n2\n30\n4\n5\n30\n7\n8\n30\n'):
	print("TEST 35 HAS PASSED")


import os
import subprocess

print("TEST 36")
os.system("./integraph.native -l tests/test36.mc > tests/test36.out")
subprocess = subprocess.Popen("lli tests/test36.out", shell=True, stdout=subprocess.PIPE)
lliOutputBytes = subprocess.stdout.read()
lliOutput = lliOutputBytes.decode()
if (lliOutput == '1.11111\n1.22222\n1.33333\n68.4329\n1.55556\n1.66667\n489.432\n1.88889\n'):
	print("TEST 36 HAS PASSED")





