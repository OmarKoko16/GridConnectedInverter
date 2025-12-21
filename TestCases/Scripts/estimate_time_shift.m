function [time_shift, t_common, x1_aligned, x2_aligned, info] = estimate_time_shift_robust(t1, x1, t2, x2, doPlot, maxLagSec)
% Robust estimation of time delay between two signals.
% Tries edge-based matching first (best for step-like signals) then GCC-PHAT.
%
% Usage:
%   [time_shift, t_common, x1a, x2a, info] = estimate_time_shift_robust(t1,x1,t2,x2,true,5);
% Outputs:
%   time_shift : estimated delay (s), positive means x1 leads x2
%   t_common   : common time vector (overlap)
%   x1_aligned : x1 resampled (normalized)
%   x2_aligned : x2 resampled and shifted to align with x1
%   info       : struct with details (method used, candidates, etc.)

    if nargin < 5, doPlot = false; end
    if nargin < 6, maxLagSec = inf; end

    % Prepare and find overlap
    t1 = t1(:); x1 = x1(:);
    t2 = t2(:); x2 = x2(:);
    valid1 = ~isnan(t1) & ~isnan(x1);
    valid2 = ~isnan(t2) & ~isnan(x2);
    t1 = t1(valid1); x1 = x1(valid1);
    t2 = t2(valid2); x2 = x2(valid2);
    t_start = max(t1(1), t2(1));
    t_end   = min(t1(end), t2(end));
    if t_end <= t_start
        error('No overlapping time region between signals.');
    end

    dt = min([mean(diff(t1)), mean(diff(t2))]);
    t_common = (t_start:dt:t_end)';
    x1r = interp1(t1, x1, t_common, 'linear', 'extrap');
    x2r = interp1(t2, x2, t_common, 'linear', 'extrap');

    % Normalize (for methods)
    x1n = (x1r - mean(x1r,'omitnan')) ./ std(x1r, 'omitnan');
    x2n = (x2r - mean(x2r,'omitnan')) ./ std(x2r, 'omitnan');

    info = struct();

    % 1) Try edge/event-based matching
    try
        [shift_edge, events1, events2] = align_by_edges(t_common, x1n, t_common, x2n);
        % If user provided a maxLagSec, check it's within bounds
        if abs(shift_edge) <= maxLagSec
            time_shift = shift_edge;
            info.method = 'edge';
            info.events1 = events1;
            info.events2 = events2;
        else
            error('Edge shift too large, fallback');
        end
    catch
        % 2) Fallback to GCC-PHAT
        [shift_gcc] = align_by_gccphat(x1n, x2n, dt, maxLagSec);
        time_shift = shift_gcc;
        info.method = 'gcc-phat';
        info.events1 = [];
        info.events2 = [];
    end

    % Create aligned signals (shift x2 by time_shift)
    x1_aligned = x1n;
    x2_aligned = interp1(t_common + time_shift, x2n, t_common, 'linear', NaN);

    % Final plotting if requested
    if doPlot
        figure('Name','Robust Alignment','NumberTitle','off','Position',[100 100 1000 600]);
        subplot(2,1,1);
        plot(t_common, x1n, 'b.'); hold on;
        plot(t_common, x2n, 'r.');
        title('Before Alignment'); xlabel('Time [s]'); ylabel('Normalized'); legend('x1','x2');
        if ~isempty(info.events1)
            plot(info.events1, zeros(size(info.events1)), 'bo','MarkerFaceColor','b','MarkerSize',8);
            plot(info.events2, zeros(size(info.events2)), 'ro','MarkerFaceColor','r','MarkerSize',8);
        end
        subplot(2,1,2);
        plot(t_common, x1_aligned, 'b.'); hold on;
        plot(t_common, x2_aligned, 'r.');
        title(sprintf('After Alignment (Shift = %.6f s) — method: %s', time_shift, info.method));
        xlabel('Time [s]'); ylabel('Normalized'); legend('x1','x2 shifted');
        hold off;
    end
end
