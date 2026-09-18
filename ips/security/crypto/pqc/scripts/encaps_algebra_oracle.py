"""Offline independent Encaps check using direct ring convolution, not RTL NTT.
FIPS 203 Algorithms 8/12/14/15/16/17: q=3329, n=256. Never imported by UVM.
The inverse transform is evaluated as a 128-point inverse Vandermonde sum;
there are no butterflies, twiddle ROMs or Montgomery representations here.
"""
import hashlib
Q=3329
ROOTS=[pow(17,2*int(f'{i:07b}'[::-1],2)+1,Q) for i in range(128)]
INV_ROWS=[[pow(g,-j,Q)*pow(128,-1,Q)%Q for g in ROOTS] for j in range(128)]
def inverse(a):
    result=[0]*256
    for j,row in enumerate(INV_ROWS):
        for parity in range(2):result[2*j+parity]=sum(row[i]*a[2*i+parity] for i in range(128))%Q
    return result
def product(a,b):
    out=[0]*256
    for i,x in enumerate(a):
        for j,y in enumerate(b):
            if i+j<256:out[i+j]+=x*y
            else:out[i+j-256]-=x*y
    return [v%Q for v in out]
def unpack(data,d):
    x=int.from_bytes(data,'little');return [(x>>(d*i))&((1<<d)-1) for i in range(256)]
def pack(a,d):return sum(x<<(d*i) for i,x in enumerate(a)).to_bytes(32*d,'little')
def noise(r,nonce,eta):
    bits=int.from_bytes(hashlib.shake_256(r+bytes([nonce])).digest(64*eta),'little')
    return [sum((bits>>(2*eta*i+j))&1 for j in range(eta))-sum((bits>>(2*eta*i+eta+j))&1 for j in range(eta)) for i in range(256)]
def matrix(rho,i,j):
    stream=hashlib.shake_128(rho+bytes([i,j])).digest(4096);out=[]
    for off in range(0,len(stream)-2,3):
        x=int.from_bytes(stream[off:off+3],'little')
        for v in (x&4095,x>>12):
            if v<Q:out.append(v)
            if len(out)==256:return inverse(out)
    raise ValueError('matrix sampling bound exhausted')
def encaps(pk,m,k):
    g=hashlib.sha3_512(m+hashlib.sha3_256(pk).digest()).digest();r=g[32:];rho=pk[-32:]
    y=[noise(r,j,3 if k==2 else 2) for j in range(k)]
    def compress(a,d):return [(((x%Q)*(1<<d)+Q//2)//Q)% (1<<d) for x in a]
    ct=b''
    for i in range(k):
        a=noise(r,k+i,2)
        for j in range(k):a=[x+z for x,z in zip(a,product(matrix(rho,i,j),y[j]))]
        ct+=pack(compress(a,11 if k==4 else 10),11 if k==4 else 10)
    v=[x+1665*((m[i//8]>>(i%8))&1) for i,x in enumerate(noise(r,2*k,2))]
    for j in range(k):v=[x+z for x,z in zip(v,product(inverse(unpack(pk[j*384:(j+1)*384],12)),y[j]))]
    ct+=pack(compress(v,5 if k==4 else 4),5 if k==4 else 4)
    return g[:32],ct
