function [Kp,Ki] = PiTune(L,R,tau,Amp_Sym)
T1 = L/R;
T0 = T1;
Sig = tau;
KP = 1/R;
switch Amp_Sym
    case 0
        a0 = 1/(Sig*KP) + 1/(T1*KP) - 1/((T1+Sig)*KP);
        a1 = T1/(Sig*KP) + Sig/(T1*KP) ;
        Kp = a1/2;
        Ki = a0/2;
    case 1
        T0 = T1;
        Kp = (4*Sig*T0)/(8*KP*Sig^2);
        Ki = T0/(8*KP*Sig^2);
end

end