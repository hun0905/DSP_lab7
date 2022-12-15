import numpy as np
r1=10*1e6
r2=10*1e6
r3=5*1e6
c1=135*1e-12
c2=270*1e-12
c3=270*1e-12
a = [1,1/c1*(1/r1+1/r2),1/(c1*r1*r2)*(1/c3+1/c2),1/(c1*c2*c3*r1*r2*r3)]
b = [1,1/(c1*r1)+1/(c1*r2)+1/(c2*r2)+1/(c2*r3)+1/(c3*r2),1/(c2*r3*c1*r1)+1/(c2*r3*c1*r2)+1/(c3*c1*r1*r2)+1/(c1*c2*r1*r2)+1/(c2*c3*r3*r2),1/(c1*c2*c3*r1*r2*r3)]
print(a)
print(b)

print(np.roots(b))