clear
close all

%% Load ECG data
% This raw ECG did not go through the analog notch filter
%data = load('display_buffer_nofilter.mat');

%ECG = data.display_buffer;
ECG = get_ECG()
fs=500
%fs = data.fs;
Npoint = length(ECG);

% calculate t_axis and f_axis
dt = 1 / fs; % time resolution
t_axis = (0 : dt : 1/fs*(Npoint - 1));
df = fs / Npoint; % frequency resolution
f_axis = (0:1:(Npoint-1))*df - fs/2;  % frequency axis (shifted)

% plot signal and its frequency spectrum
figure(1)
plot(t_axis, ECG)
xlabel('Time (sec)')
ylabel('Quantized value')
title("Raw ECG Signal")

figure(2)
plot(f_axis, abs(fftshift(fft(ECG))))
title('Frequency spectrum')

%% (1) Design a digital filter to remove the 60Hz power noise

% filter design
% https://www.mathworks.com/help/signal/filter-design.html
% Hint: you may use moving average filter or fir1() or anything else
% In the report, please describe how you design this filter
LPF = fir1(100,0.2,'low')
Fs = 500; % in Hz
ma = ones(1,8)/8;
[b,a] = iirnotch(0.24,0.1);

figure(3)
plot((0:511)*Fs/512, abs(fft(ma,512)));
xlabel('frequency(Hz)')
ylabel('amplitude')

figure(4)
plot((0:511)*Fs/512, abs(fft(LPF,512)));
xlabel('frequency(Hz)')
ylabel('amplitude')


%figure(5)
fvtool(b,a)
xlabel('frequency(250Hz/per)')
ylabel('amplitude')

ECG_mafiltered = conv(ECG,ma,'same');
figure(6)
subplot(2,1,1)
plot(t_axis, ECG_mafiltered )
xlabel('Time (sec)')
ylabel('amplitude')
title("move average filtered ECG Signal")
subplot(2,1,2)
plot(f_axis, abs(fftshift(fft(ECG_mafiltered ))))
xlabel('Frequency (Hz)')
ylabel('amplitude')
title('Frequency spectrum')
ECG_LPFfiltered = conv(ECG,LPF,'same');
figure(7)
subplot(2,1,1)
plot(t_axis, ECG_LPFfiltered )
xlabel('Time (sec)')
ylabel('amplitude')
title("LPF filtered ECG Signal")
subplot(2,1,2)

plot(f_axis, abs(fftshift(fft(ECG_LPFfiltered))))
xlabel('Frequency (Hz)')
ylabel('amplitude')
title('Frequency spectrum')


ECG_notchfiltered_IIR = filter(b,a,ECG)
figure(8)
subplot(2,1,1)
plot(t_axis, ECG_notchfiltered_IIR )
xlabel('Time (sec)')
ylabel('amplitude')
title("IIR filtered ECG Signal")
subplot(2,1,2)
plot(f_axis, abs(fftshift(fft(ECG_notchfiltered_IIR ))))
xlabel('Frequency (Hz)')
ylabel('amplitude')
title('Frequency spectrum')
% filtering

% Plot the filtered signal and its frequency spectrum

%% (2) Design a digital filter to remove baseline wander noise

% filter design or somehow remove the baseline wander noise
% Hint: you may use high-pass filters or (original signal - low passed signal)
HPF = fir1(200,0.1,'high')
figure(9)
plot((0:511)*Fs/512, abs(fft(HPF,512)));
xlabel('Hz')
ECG_HPfiltered = conv(ECG_mafiltered,HPF,'same');

figure(10)
subplot(2,1,1)
plot(t_axis, ECG_HPfiltered )
xlabel('Time (sec)')
ylabel('amplitude')
title("HPfiltered ECG Signal")
subplot(2,1,2)
plot(f_axis, abs(fftshift(fft(ECG_HPfiltered ))))
title('Frequency spectrum')
% plot the filtered signal

%% (3) Utilizing the ADC dynamic range in 8-bit
% the code should be written in Arduino




function display_buffer = get_ECG()
    clear all;
    fclose('all');
    % Check if serial port object or any communication interface object exists
    serialobj=instrfind;
    if ~isempty(serialobj)
        delete(serialobj)
    end
    clc;
    clear all;
    close all;
    s1 = serial('COM6');  % Construct serial port object
    s1.BaudRate =115200;     % Define baud rate of the serial port
    fopen(s1); % Connect the serial port object to the serial port
    NSample = 3000; % Number of sampling points, i.e., number of data points to acquire
    fs = 500; % Sampling rate, check the setting in Arduino 
    display_length = 3000; % Display buffer length 
    display_buffer = nan(1, display_length); % Display buffer is a first in first out queue
    time_axis =(0:display_length-1)*(1/fs); % Time axis of the display buffer
    % Initialize figure object
    figure
    h_plot = plot(nan,nan);
    hold off 
    tic
    for i = 1:NSample
        data = fscanf(s1); % Read from Arduino
        data = str2double(data);
        disp(data);

        % Add data to display buffer
        if i <= display_length
            display_buffer(i) = data;
        else
            display_buffer = [display_buffer(2:end) data]; % first in first out
        end

        % Update figure plot
        set(h_plot, 'xdata', time_axis, 'ydata', display_buffer)
        %title('test');
        xlabel('Time(sec)');
        %ylabel('Quantized value');
        ylabel('Amplitude');
        drawnow;
    end
    toc
    fclose(s1);
    display_buffer(1)=0;
    %
    save('ECG.mat','display_buffer')
end