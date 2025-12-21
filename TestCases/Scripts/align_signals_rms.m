function [bestShift, minRMS, x_long_aligned, t_ref] = align_signals_fmin(t1, x1, t2, x2, doPlot)
% ALIGN_SIGNALS_FMIN
% Align two signals by minimizing RMS error using fminsearch
% The SHORTER signal is used as the reference.
%
%   [bestShift, minRMS, x_long_aligned, t_ref] = align_signals_fmin(t1, x1, t2, x2, doPlot)
%
% Inputs:
%   t1, x1   - time and data of signal 1
%   t2, x2   - time and data of signal 2
%   doPlot   - (optional) true to visualize results [default: false]
%
% Outputs:
%   bestShift       - optimal time shift (applied to longer signal)
%   minRMS          - minimum RMS error between aligned signals
%   x_long_aligned  - shifted version of longer signal interpolated on shorter signal's time
%   t_ref           - reference time vector (from shorter signal)
%
% Written by Omar’s AI Assistant – 2025

    if nargin < 5
        doPlot = false;
    end

    % Ensure column vectors
    t1 = t1(:); x1 = x1(:);
    t2 = t2(:); x2 = x2(:);

    % Determine which signal is shorter in duration
    dur1 = max(t1) - min(t1);
    dur2 = max(t2) - min(t2);

    if dur1 <= dur2
        % Signal 1 is the reference
        t_ref = t1; x_ref = x1;
        t_long = t2; x_long = x2;
        refName = 'x1'; longName = 'x2';
    else
        % Signal 2 is the reference
        t_ref = t2; x_ref = x2;
        t_long = t1; x_long = x1;
        refName = 'x2'; longName = 'x1';
    end

    % Resample the longer signal to match the shorter reference sampling
    x_long_interp = interp1(t_long, x_long, t_ref, 'linear', 'extrap');

    % Define RMS error function handle for fminsearch
    rms_error = @(shift) sqrt(mean((x_ref - interp1(t_ref + shift, x_long_interp, t_ref, 'linear', 'extrap')).^2, 'omitnan'));

    % Initial guess for shift
    initShift = 0;

    % Use fminsearch to find optimal shift
    bestShift = fminsearch(rms_error, initShift, optimset('Display', 'off'));

    % Compute minimum RMS using best shift
    minRMS = rms_error(bestShift);

    % Compute aligned longer signal
    x_long_aligned = interp1(t_ref + bestShift, x_long_interp, t_ref, 'linear', 'extrap');

    % Optional plotting
    if doPlot
        figure;

        subplot(2,1,1);
        plot(t1, x1, 'b', t2, x2, 'r');
        title('Original Signals');
        xlabel('Time [s]'); ylabel('Amplitude');
        legend('x1','x2'); grid on;

        subplot(2,1,2);
        plot(t_ref, x_ref, 'b', t_ref, x_long_aligned, 'r');
        title(sprintf('Aligned Signals (Best Shift = %.6f s, Min RMS = %.6g)', bestShift, minRMS));
        xlabel('Time [s]'); ylabel('Amplitude');
        legend(refName, [longName ' shifted']); grid on;
    end
end
