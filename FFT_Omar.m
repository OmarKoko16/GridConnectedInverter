function [THD, WTHD, Fund, HarmSel] = FFT_Omar(Data, Frq, Fs, Name, NoPlot, Sel)
% FFT_OMAR  Compute THD, Weighted THD, and Fundamental RMS from signal
%
% Inputs:
%   Data   - Vector or matrix (each row = signal)
%   Frq    - Fundamental frequency [Hz] (NaN to auto-detect)
%   Fs     - Sampling frequency [Hz]
%   Name   - Signal name for plot title
%   NoPlot - 0 to plot, 1 to suppress plots (Optional, default 0)
%   Sel    - Harmonic order to monitor specifically (Optional, default 0)
%
% Outputs:
%   THD, WTHD, Fund, HarmSel - arrays per signal

    % --- Default Arguments ---
    if nargin < 6 || isempty(Sel), Sel = 0; end
    if nargin < 5 || isempty(NoPlot), NoPlot = 0; end

    % --- Initialization ---
    [nRows, nCols] = size(Data);
    THD     = zeros(1, nRows);
    WTHD    = zeros(1, nRows);
    Fund    = zeros(1, nRows);
    HarmSel = zeros(1, nRows);

    if ~NoPlot
        figure('Color', 'w', 'Position', [200 200 900 600]);
    end

    for i = 1:nRows
        x = Data(i, :);
        x = x - mean(x);             % Remove DC offset

        % Use a local frequency variable so we don't overwrite the input 'Frq' 
        % when processing multiple rows with auto-detection.
        currentFrq = Frq;

        % --- Ensure integer number of cycles if Frequency is known ---
        if ~isnan(currentFrq)
            samplesPerCycle = round(Fs / currentFrq);
            if samplesPerCycle > 0
                nCycles = floor(length(x) / samplesPerCycle);
                L = nCycles * samplesPerCycle;
                x = x(1:L);
            else
                L = length(x);
            end
        else
            L = length(x);
        end

        % --- Apply window (Hann) to reduce leakage ---
        w = hann(L)';
        xw = x .* w;

        % --- FFT computation ---
        Y = fft(xw);
        
        % --- Normalization ---
        % 1. Normalize by L (standard FFT)
        % 2. Multiply by 2 for One-Sided Spectrum (Negative freqs added to positive)
        % 3. Multiply by 2 for Hanning Window Amplitude Correction (Coherent Gain = 0.5)
        % Total Factor: 4 / L
        
        P2 = abs(Y / L);
        P1 = P2(1:floor(L/2)+1);
        
        % Convert to One-Sided Spectrum (multiply AC components by 2)
        P1(2:end-1) = 2 * P1(2:end-1);
        
        % Correct for Hanning Window Attenuation (Amplitude Restoration)
        P1 = P1 * 2; 

        f = Fs * (0:floor(L/2)) / L;

        % --- Identify fundamental & harmonics ---
        if isnan(currentFrq)
            % Auto-detect dominant frequency (ignore DC at index 1)
            [~, idxFund] = max(P1(2:end)); 
            currentFrq = f(idxFund + 1);
        end

        % Define frequency masks
        % Fundamental: +/- 10% around detected freq
        fundMask = (f > 0.9 * currentFrq) & (f < 1.1 * currentFrq);
        
        % Specific Harmonic Selection (Sel)
        if Sel > 0
            SecMask = (f > 0.95 * Sel * currentFrq) & (f < 1.05 * Sel * currentFrq);
        else
            SecMask = false(size(f));
        end
        
        % Harmonics: Everything above 1.1x Fundamental
        harmMask = f > 1.1 * currentFrq;

        % --- Calculations ---
        % RMS of Fundamental
        Fund(i) = sqrt(sum(P1(fundMask).^2));
        
        % RMS of Selected Harmonic
        HarmSel(i) = sqrt(sum(P1(SecMask).^2));
        
        % Distortion Calculations
        Harmonics = P1(harmMask);
        HarmFrqs = f(harmMask);

        if Fund(i) > 0
            THD(i)  = 100 * sqrt(sum(Harmonics.^2)) / Fund(i);
            % Weighted THD (often used for inductive currents)
            WTHD(i) = 100 * sqrt(sum((Harmonics ./ (2*pi*HarmFrqs)).^2)) / Fund(i);
        else
            THD(i) = 0;
            WTHD(i) = 0;
        end

        % --- Plot if requested ---
        if ~NoPlot
            t_us = (0:L-1) / Fs * 1e6;

            % Time domain
            subplot(2,1,1);
            plot(t_us, x, 'LineWidth', 1); hold on;
            xlabel('Time [μs]');
            ylabel('Amplitude');
            title(sprintf('Time-domain Signal: %s', Name), 'Interpreter', 'none');
            grid on;

            % Frequency domain
            subplot(2,1,2);
            semilogx(f, P1, 'LineWidth', 1.2); hold on;
            grid on;
            xlabel('Frequency [Hz]');
            ylabel('Amplitude');
            title(sprintf('FFT Spectrum of %s | Fund=%.2f | THD=%.2f%%', ...
                Name, Fund(i), THD(i)), 'Interpreter', 'none');
            
            % Limit x-axis to relevant range (e.g., up to 100th harmonic or Nyquist)
            xlim([currentFrq/2, min(Fs/2, currentFrq*100)]);

            % Show fundamental line
            xline(currentFrq, '--r', sprintf('Fund = %.1f Hz', currentFrq), ...
                'LabelVerticalAlignment','bottom', 'LabelOrientation', 'horizontal');
        end
    end
end