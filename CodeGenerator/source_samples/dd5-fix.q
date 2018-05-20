VARI xx,yy,cnt4;
VARJ x301,gw30;
VARF res;
VAR tt,ramda,fme,fmf,s,one,mone;
LOCAL zz, d;
zz = x301*cnt4;
d = mone*xx*yy*s-tt*zz*(one-xx-yy-zz)+(xx+yy)*ramda*ramda + (one-xx-yy-zz)*(one-xx-yy)*fme*fme+zz*(one-xx-yy)*fmf*fmf;
res = res + gw30/(d*d);
