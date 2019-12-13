%% Declare variables/functions
T = 10^-6;
M = 100;
t_sample_cnt = 100;
symbol_to_plot = 10;
No = 1;
t_pt = linspace(0,T,t_sample_cnt); %100 samples per p(t-iT)
pt = rectpuls(t_pt)*1/sqrt(T);

mse = 0;
%% Generate s(t)
a = randi([0 1], 1, M); %Generate random binary array
a(a == 0) = -1; %Make all zeros -1 so that we have random -1 and 1 array
t = linspace(-T, (M+1)*T, t_sample_cnt*(M+2)); %Generate time samples with one period margin on both ends (for shifting)
s = zeros(1, length(t));
s(1:t_sample_cnt) = 0;
s((M+1)*t_sample_cnt:length(t)) = 0;

for i = 0:1:M-1
	s(i*t_sample_cnt+101:(i+1)*t_sample_cnt+100) = a(i+1)*pt;  %Generate s(t) as sums of p(t-iT)
end


for h = 1:1000
	%% Generate r(t)
	possible_tau = cat(2, -1*fliplr(t_pt(2:26)), t_pt(1:t_sample_cnt/4)); %Generate time samples from -0.25T to 0.25T
	pos = randi(length(possible_tau)); %Pick an index
	tau = possible_tau(pos);  %Pick thao as the value for corresponding index
	k = find(t_pt == abs(tau)); %Find how many samples to shift (one period is 100 samples)
	
	if tau < 0
		k = -k;
	end;
	
	r = circshift(s, k); %Shift by Tau
	r = r + sqrt(No*t_sample_cnt/T)*randn(1, length(r)); %Add noise
	
	%% Generate y(t)
	matched_filter = zeros(1, length(t) ); %Generate matched filter p(-t)
	matched_filter(1:length(t_pt)) = rectpuls(t_pt)*1/sqrt(T);
	
	y = conv(r, matched_filter)*(t(101) - t(100) );
	y = y(101:(M+2)*t_sample_cnt+100); %Crop zero values
%         figure;
%         plot(t, y);
%         axis([-T T*(symbol_to_plot) -1.5 1.5]);
%         title(['y(t) with Time Shift of ' num2str(tau) ' Seconds']);
%         xlabel('Time (seconds)');
%         ylabel('Magnitude');
%         grid on;
	
	%% Estimate Tau (MMSE)
	mmse = zeros(1,length(possible_tau) );
	index = 1;
	for n = -length(possible_tau)/2:length(possible_tau)/2-1
		for m = 0:M-1
			mmse(index) = mmse(index) + (y((m+1)*100+n)-a(m+1))^2;
		end
		index = index + 1;
	end
	
	[min_no, index] = min(mmse);
	estimated_tau = possible_tau(index);
	
	mse = mse + (estimated_tau - tau)^2;
end
 


figure;
plot(logspace(2, 4, 10), mse_vector);
grid on;
xlabel('No');
ylabel('MSE');
title('No vs Mean Squared Error of Estimated and Real Time Shift')




