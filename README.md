# Symbol-Synchronization-BPAM

This script estimates the time shift of an baseband PAM system where the signal sent is
s(t) = sum of (a_i * p(t - iT) ) i from 0 to M-1 where p(t) is a rectangular pulse. The received signal is r(t) = s(t - tau) + n(t) where tau is the time delay (restricted to -0.25T to 0.25T for the sake of argument) and n(t) is the Gaussian noise. Timing recovery is done based of MMSE method.