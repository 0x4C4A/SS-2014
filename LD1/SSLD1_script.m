% SSLD input variable is <cutoff_SSLD1>
% SSLD outputs  <distance_SSLD1>
%               <norm_sine_pulse_SSLD1>
%               <norm_filtered_sine_pulse_SSLD1>

% This function uses the SSLD1 simulink model to gather data and further
% analyses the results.
function SSLD1_script()    
    %%%% Check if SSLD1 is open, open it if necessary
    if(bdIsLoaded('SSLD1') == 0)
        load_system('SSLD1')
        fprintf('SSLD1 opened!\n');
        close_system_later = 1;
    else 
        close_system_later = 0;
    end
    
    %%%% Filter frequency inputs
    fprintf('<strong>Please input the following variables.\nLeave input blank for default value.</strong>\n');
    high_f = input('Maximum cutoff frequency (default 100)  : ');
    if(check_if_equal_or_below_zero( high_f, 'Maximum cutoff frequency')), return; end
    if( isempty(high_f) ), high_f = 100; end
        
    low_f  = input('Minimum cutoff frequency (default 0.1)  : ');
    if(check_if_equal_or_below_zero( low_f, 'Minimum cutoff frequency')),  return; end
    if( isempty(low_f) ),  low_f  = 0.1; end
        
    if( high_f <= low_f )
        fprintf('Maximum cutoff frequency must be greater than the minimum cutoff frequency!\n');
        return
    end
    
    steps  = input('Logspaced freq. steps    (default 100)  : ');
    if(check_if_equal_or_below_zero( steps, 'Step amount')), return; end
    if( isempty(steps) ),  steps  = 100; end
    
    %%%% Initialize stuff for the main data gathering
    simulation_count   = 1;
    options = simset('SrcWorkspace','base','DstWorkspace','base');
    cutoff_frequencies     = zeros( steps, 1 );
    norms_sine_pulse       = zeros( steps, 1 );
    norms_f_sine_pulse     = zeros( steps, 1 );
    distances              = zeros( steps, 1 );
    sine_pulse_harmonics   = zeros( 10,    1 );
    f_sine_pulse_harmonics = zeros( 10,    steps );
    sine_pulse_arg         = zeros( 10,    1 );
    f_sine_pulse_arg       = zeros( 10,    steps );
    
    SSLD1_waitbar = waitbar( 0, 'Starting simulations!');
    close_waitbar = 1;
    figure(2); clf;
    figure(3); clf;
    for cutoff = logspace(log10(low_f), log10(high_f), steps);
        output_string = sprintf('\nSimulation #%d of %d (%d%%) in progress', simulation_count, steps, round(100*simulation_count/steps) );
        if(~ishandle(SSLD1_waitbar))
            fprintf('\nStopped by user at %d%%!\n', round(100*simulation_count/steps));
            close_waitbar = 0;
            break
        else
            waitbar(simulation_count/steps, SSLD1_waitbar, output_string);
        end
        
        % Set the SSLD1 argument variable
        assignin('base','cutoff_SSLD1',cutoff)
        sim('SSLD1', [0 2], options);
        cutoff_frequencies( simulation_count ) = cutoff;
        % Read the values SSLD1 generated in the workspace
        norms_sine_pulse(   simulation_count ) = evalin('base', 'norm_sine_pulse_SSLD1');
        norms_f_sine_pulse( simulation_count ) = evalin('base', 'norm_filtered_sine_pulse_SSLD1');
        distances(          simulation_count ) = evalin('base', 'distance_SSLD1'); 
        if(simulation_count == 1)
            sine_pulse_harmonics = evalin('base','sine_pulse_FFT_amp_SSLD1([ 3 5 9 13 17 21 25 29 33 37 ],1,2)'); % Read in the specturm amplitudes of the sine pulse
            sine_pulse_arg = evalin('base','sine_pulse_FFT_arg_SSLD1([ 3 5 9 13 17 21 25 29 33 37 ],1,2)'); 
        end
        f_sine_pulse_harmonics(:, simulation_count) = evalin('base','filtered_sine_pulse_FFT_amp_SSLD1([ 3 5 9 13 17 21 25 29 33 37 ],1,2)');
        f_sine_pulse_arg(      :, simulation_count) = evalin('base','filtered_sine_pulse_FFT_arg_SSLD1([ 3 5 9 13 17 21 25 29 33 37 ],1,2)');

        
        simulation_count = simulation_count + 1;
        if(~mod(simulation_count,10))  
            %figure(2); hold on;
            %plot(linspace(0,499,1000),evalin('base','filtered_sine_pulse_FFT_amp_SSLD1(1:1000,1,2)')), grid on; xlim([0 10]);
            %figure(3); hold on;
            %plot(evalin('base','f_sine_pulse_SSLD1'));
        end
    end
    
    %%%% Dump variables to workspace
    assignin('base','cutoffs_SSLD1',                   cutoff_frequencies); 
    assignin('base','norms_sine_pulse_SSLD1',          norms_sine_pulse); 
    assignin('base','norms_filtered_sine_pulse_SSLD1', norms_f_sine_pulse); 
    assignin('base','distances_SSLD1',                 distances);
    assignin('base','sine_pulse_harmonics_SSLD1',      sine_pulse_harmonics);
    assignin('base','f_sine_pulse_harmonics_SSLD1',    f_sine_pulse_harmonics);
    assignin('base','sine_pulse_args_SSLD1',           sine_pulse_arg);
    assignin('base','f_sine_pulse_args_SSLD1',         f_sine_pulse_arg);
    
    %%%% Plot the results
    fprintf('Plotting results.\n');
    figure(1);
    clf;
    subplot(2,1,1);
    semilogx(cutoff_frequencies, norms_sine_pulse, cutoff_frequencies, norms_f_sine_pulse);
    grid on; ylim([0 0.6]); % Must be adjusted depending on the signals used
    legend('Sine pulse norms', 'Filtered sine pulse norms', 'Location', 'SouthEast'); 
    xlabel('Frequency [Hz]'); ylabel('Signal norm'); title('Signal norms');
    
    subplot(2,1,2);
    semilogx(cutoff_frequencies, distances);
    grid on; xlabel('Frequency [Hz]'); ylabel('Distance'); title('Distance between signals');
    
    
    %%%% Clean up
    if(close_waitbar)
        close(SSLD1_waitbar);
    end
    
    if(close_system_later)
        close_system('SSLD1');
        fprintf('SSLD1 closed!\n');
    end

end

%%%% Function to check for input errors
function x = check_if_equal_or_below_zero( var, var_name )
    if( var <= 0 )
        fprintf('%s should be above zero!', var_name);
        x = 1;
    else
        x = 0;
    end
    return
end
