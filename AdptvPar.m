%% CFDL Parameters
ADPTV.delta     = single(1.6111);          % 0     ~   2
ADPTV.eta       = single(2.0067);               % 0.2   ~   5
ADPTV.k         = single(84.2608);                % > 0
ADPTV.psi0      = single([-1.502144202543479e+02,-1.375488133187245e+02;-1.707257983829520e+02,-1.934004548610360e+02]);  % > ADPTV.k

%% e*(k+1) estimation
ADPTV.mio_0     = single(1.7184);
ADPTV.mio_inf   = single(1.7184);
ADPTV.a         = single(13.2888);
ADPTV.ro        = single(0.4656);              % 0     ~   1
%% DESO
ADPTV.wo        = single(0.1213);              % 0     ~   0.5
ADPTV.Lamda0    = single(97.1044);             % >3*LamdaInf > 0
ADPTV.LamdaInf  = single(97.1044);           % > 0
ADPTV.b0        = single(1.0000e-03);             % < 10
ADPTV.h         = single(1/1e6);
ADPTV.b_D_ui    = single(1.1934);

   
  
   
   %% Optimize

    ADPTV.delta     = single( 0.2053 );
    ADPTV.eta       = single( 4.6050 );
    ADPTV.k         = single(13.8624);
    ADPTV.psi0      = single([ 125.4639  -19.7834; 40.7928 -87.0851]);
    ADPTV.mio_0     = single( 0.7945 );
    ADPTV.mio_inf   = single(ADPTV.mio_0);
    ADPTV.a         = single(14.4045);
    ADPTV.ro        = single( 0.3685);
    ADPTV.wo        = single( 0.2830);
    ADPTV.Lamda0    = single(42.4167);
    ADPTV.LamdaInf  = ADPTV.Lamda0;
    ADPTV.b0        = single(5);
    ADPTV.h         = single(1/1e6);
    ADPTV.b_D_ui    = single(12.9328);


    %% Trial
% ADPTV.delta     = single(0.5377);          % 0     ~   2
% ADPTV.eta       = single(1.8339);               % 0.2   ~   5
% ADPTV.k         = single(1.0000e-06);                % > 0
% ADPTV.psi0      = single([-21.472732543945312,-9.734508514404297;9.252717018127441,-9.727250099182129]);  % > ADPTV.k
% ADPTV.mio_0     = single(0.3426);
% ADPTV.mio_inf   = single(0.3426);
% ADPTV.a         = single(3.5784);
% ADPTV.ro        = single(1);              % 0     ~   1
% ADPTV.wo        = single(0.1000);              % 0     ~   0.5
% ADPTV.Lamda0    = single(3.0349);             % >3*LamdaInf > 0
% ADPTV.LamdaInf  = single(3.0349);           % > 0
% ADPTV.b0        = single(1.0000e-03);             % < 10
% ADPTV.h         = single(1/1e6);
% ADPTV.b_D_ui    = single(0.7254);

ADPTV.delta     = single(1.3912);          % 0     ~   2
ADPTV.eta       = single(2.6286);               % 0.2   ~   5
ADPTV.k         = single(3.3772);                % > 0
ADPTV.psi0      = single([9.018474134109660e+02,1.222957698118742e+03;-1.260734719503456e+03,8.335989364447744e+02]);  % > ADPTV.k
ADPTV.mio_0     = single(18.3132);
ADPTV.mio_inf   = single(18.3132);
ADPTV.a         = single(44.0085);
ADPTV.ro        = single(0.6135);              % 0     ~   1
ADPTV.wo        = single(0.1967);              % 0     ~   0.5
ADPTV.Lamda0    = single(88.4281);             % >3*LamdaInf > 0
ADPTV.LamdaInf  = single(88.4281);           % > 0
ADPTV.b0        = single(1.0000e-03);             % < 10
ADPTV.h         = single(1/1e6);
ADPTV.b_D_ui    = single(0.2547);

    