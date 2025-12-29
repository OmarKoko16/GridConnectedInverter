function [time_shift, t_grid, x1_grid, x2_shifted, debug_info] = estimate_time_shift_robust(t1, x1, t2, x2, doPlot, maxLagSec)
% ESTIMATE_TIME_SHIFT_ROBUST Estimates delay between two signals with NaN handling.
%
% Usage:
%   [shift, t_common, x1a, x2a] = estimate_time_shift_robust(t1, x1, t2, x2, true, 5);
%
%   time_shift: Value to ADD to t2 to align it with t1 (t2_new = t2 + shift)
%               or subtract from t2 if defining lag relative to t1.
%               (Here: positive lag => x1 matches x2 shifted by lag).
%
% Algorithm:
%   1. Cleans inputs (removes NaNs).
%   2. Resamples both onto a uniform grid defined by the union of time ranges.
%   3. Performs Cross-Correlation (normalized) to find the lag.
%   4. Refines peak using parabolic interpolation.

    if nargin < 5, doPlot = false; end
    if nargin < 6, maxLagSec = inf; end

    %% 1. Input Cleaning
    % Remove NaNs from original vectors to allow clean interpolation
    mask1 = ~isnan(x1) & ~isnan(t1);
    t1 = t1(mask1); x1 = x1(mask1);
    
    mask2 = ~isnan(x2) & ~isnan(t2);
    t2 = t2(mask2); x2 = x2(mask2);
    
    if isempty(t1) || isempty(t2)
        error('Input signals contain no valid data after removing NaNs.');
    end

    %% 2. Uniform Grid Generation
    % Determine sampling periods
    dt1 = median(diff(t1));
    dt2 = median(diff(t2));
    dt = min(dt1, dt2); % Use the finer resolution
    
    if dt <= 0 || isnan(dt), dt = 1e-3; end % Fallback safety
    
    % Create common time grid covering the overlap
    t_min = max(min(t1), min(t2));
    t_max = min(max(t1), max(t2));
    
    % If no overlap, use the union (cross-correlation will just handle the offset)
    if t_min >= t_max
        t_min = min(min(t1), min(t2));
        t_max = max(max(t1), max(t2));
    end
    
    t_grid = (t_min:dt:t_max)';
    
    %% 3. Resampling
    % Interpolate onto grid. Using 'linear' handles gaps where NaNs used to be.
    % Extrapolating with 0 ensures signals fade out outside their range.
    x1_grid = interp1(t1, x1, t_grid, 'linear', 0);
    x2_grid = interp1(t2, x2, t_grid, 'linear', 0);
    
    % Normalize (Z-score) to make correlation amplitude independent of signal scale
    % (Avoiding divide by zero for constant signals)
    std1 = std(x1_grid); if std1==0, std1=1; end
    std2 = std(x2_grid); if std2==0, std2=1; end
    
    x1_norm = (x1_grid - mean(x1_grid)) / std1;
    x2_norm = (x2_grid - mean(x2_grid)) / std2;

    %% 4. Cross Correlation
    % Limit lags if requested
    if isinf(maxLagSec)
        maxLagSamples = length(t_grid) - 1;
    else
        maxLagSamples = ceil(maxLagSec / dt);
    end
    
    [r, lags] = xcorr(x1_norm, x2_norm, maxLagSamples, 'normalized');
    
    % Find peak
    [max_corr, peak_idx] = max(abs(r)); % Absolute to handle inverted signals
    raw_lag_samples = lags(peak_idx);
    
    % Parabolic Interpolation for Sub-sample accuracy
    if peak_idx > 1 && peak_idx < length(r)
        y1 = abs(r(peak_idx-1));
        y2 = abs(r(peak_idx));
        y3 = abs(r(peak_idx+1));
        denom = 2 * (2*y2 - y1 - y3);
        if denom ~= 0
            delta = (y1 - y3) / denom;
            refined_lag_samples = raw_lag_samples + delta;
        else
            refined_lag_samples = raw_lag_samples;
        end
    else
        refined_lag_samples = raw_lag_samples;
    end
    
    time_shift = refined_lag_samples * dt;
    
    %% 5. Output Preparation
    % To visualize the alignment, we shift x2 to match x1.
    % If time_shift is positive, it means x1 is "ahead" of x2 (x2 is delayed).
    % To align, we shift x2 "left" (subtract delay) or simply sample at shifted times.
    
    % Create aligned x2 for return
    % We interpolate the original (non-grid) x2 at times (t_grid - time_shift)
    x2_shifted = interp1(t2, x2, t_grid - time_shift, 'linear', NaN);

    debug_info.max_corr = max_corr;
    debug_info.dt = dt;
    debug_info.lags = lags;
    debug_info.r = r;
    
    %% 6. Plotting
    if doPlot
        figure('Name', 'Robust Time Shift Estimation', 'Color', 'w');
        
        subplot(2,1,1);
        plot(t_grid, x1_grid, 'b', 'DisplayName', 'Sig 1 (Ref)');
        hold on;
        plot(t_grid, x2_shifted, 'r--', 'DisplayName', 'Sig 2 (Aligned)');
        title(sprintf('Aligned Signals (Shift: %.4f s)', time_shift));
        grid on; legend;
        
        subplot(2,1,2);
        plot(lags*dt, r, 'k');
        hold on;
        xline(time_shift, 'r', 'Max Corr');
        title(['Cross Correlation (Max: ' num2str(max_corr, '%.2f') ')']);
        xlabel('Lag (s)'); grid on;
    end
end