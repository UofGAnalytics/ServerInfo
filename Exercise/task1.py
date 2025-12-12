

import random as rd


f = open("results_python.csv","w")



## Write a simple random csv file using standard libs
f.write("Name,Value")
for i in range(100):
    name = "".join(chr(rd.randint(65,65+25)) for _ in range(6))
    value = rd.random()
    f.write(f"\n{name},{value}")
f.close()


