#ifndef _INC_TD_CLASS
#define _INC_TD_CLASS

#include <iostream>
#include <qd/qd_real.h>

class td_real {

  public:
    double x[3];

    td_real();
    td_real(double in);
    td_real(qd_real in);
		
		td_real operator+(td_real obj);
    td_real operator-(td_real obj);
    td_real operator*(td_real obj);
    td_real operator/(td_real obj);
    bool operator=(double obj);
    bool operator=(qd_real obj);
    bool operator=(td_real obj);
    qd_real toQDreal();
    
    friend std::ostream & operator<<(std::ostream & os, const td_real & out);
};

#endif