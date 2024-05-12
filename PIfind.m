
function [PIind, curve_id] = PIfind(light,time)

% Identify PI curves

PIend = find(light > 30); % Find all data exceeding d/l sequences light levels
PIend = [PIend(diff(PIend) > 1); PIend(end)]; % Find the last point in the PI sequence

% Identify changes in sample
pump_time = [1; diff(time) > datenum(0, 0, 0, 0, 2, 0)]; % time diff > 2 min

figure(1)
plot(time,light,'k'); hold on
rbg = parula(numel(PIend));

PIind = [];
curve_id = [];

for i = 1:numel(PIend)
    PIstart = PIend(i);
    % Count backwards from the end of the PI sequence until you reach the
    % beginning of a sample
    for j = 1:1000
        PIstart = PIstart-1;
        if light(PIstart) == 0 && pump_time(PIstart) 
            break
        end
    end
    
    if numel(PIstart:PIend(i)) < 10
        continue
    end
    
    PIind = [PIind; (PIstart:PIend(i))'];
    curve_id = [curve_id; ones(numel(PIstart:PIend(i)),1) .* i]; 

    
    figure(1) % sanity check
    plot(time(PIstart:PIend(i)), light(PIstart:PIend(i)),'o','color', rbg(i,:))
end


end