% animate_1dof.m
% Run this script after running your Simulink simulation!

% 1. Extract data from the Timeseries object
if exist('out', 'var')
    try
        sim_data = out.x_out;
    catch
        error('The "out" structure exists, but "x_out" was not found inside it.');
    end
elseif exist('x_out', 'var')
    sim_data = x_out;
else
    error('Could not find "x_out" or "out.x_out" in the workspace. Please run the simulation first.');
end

time_vec = sim_data.Time;
pos_vec  = sim_data.Data;

% 2. Setup Figure Canvas (Minimalist Muted Aesthetics)
fig = figure('Color', 'w', 'Position', [200, 200, 750, 350]);
hold on; grid on;
axis([0 1.2 -0.4 0.4]);
xlabel('Position (meters)', 'FontSize', 11, 'FontWeight', 'bold');
set(gca, 'YTick', [], 'Color', [0.98 0.98 0.98], 'GridColor', [0.8 0.8 0.8]);
title('1-DOF Impedance Control Physical Interaction', 'FontSize', 13, 'FontWeight', 'bold');

% 3. Geometry Dimensions
mass_w = 0.12; 
mass_h = 0.20;
wall_x = 0.50;
target_x = 1.00;

% 4. Draw Environment Elements
% The Hard Stop Wall (Muted Red/Gray)
fill([wall_x, 1.2, 1.2, wall_x], [-0.4, -0.4, 0.4, 0.4], [0.9 0.85 0.85], 'EdgeColor', [0.7 0.2 0.2], 'LineWidth', 1.5);
text(wall_x + 0.02, 0.3, 'HARD STOP (0.5m)', 'Color', [0.7 0.2 0.2], 'FontWeight', 'bold', 'FontSize', 10);

% The Unreachable Intended Target
line([target_x, target_x], [-0.4, 0.4], 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 1.5);
text(target_x - 0.12, -0.32, 'Target (1.0m)', 'Color', [0.4 0.4 0.4], 'FontAngle', 'italic');

% Initialize Visual Components
mass_rect = rectangle('Position', [pos_vec(1)-mass_w, -mass_h/2, mass_w, mass_h], ...
    'FaceColor', [0.22 0.44 0.66], 'EdgeColor', [0.1 0.2 0.3], 'LineWidth', 2, 'Curvature', 0.1);
spring_line = plot([0, pos_vec(1)-mass_w], [0, 0], 'Color', [0.3 0.3 0.3], 'LineWidth', 2);

% GIF Generation Setup
gif_filename = 'sim_interaction.gif';
export_to_gif = true; % Set to false if you just want to watch it run without saving

% 5. Interactive Animation Loop
disp('Generating animation framework...');
frame_stride = max(1, round(length(time_vec) / 80)); % Downsample slightly for a smooth, lightweight GIF

for i = 1:frame_stride:length(time_vec)
    current_x = pos_vec(i);

    % Update the sliding block location
    set(mass_rect, 'Position', [current_x - mass_w, -mass_h/2, mass_w, mass_h]);

    % Update the virtual software spring extension line
    set(spring_line, 'XData', [0, current_x - mass_w]);

    drawnow;

    % Append frames to create the GIF file
    if export_to_gif
        frame = getframe(fig);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        if i == 1
            imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.04);
        else
            imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.04);
        end
    end
end
disp(['Success! Animation saved as: ', gif_filename]);