# Matlab Script's for Engineering Analysys
## Summary
In this folder there are a couples of scripts that i designed, most of them used for engineering analysis and simulation: 

- **ADC Quantization Error Analysis**: Serves more as a pedagogical view of how the Quantization Error Sequence behaves as a result of sampling a periodic signal, and gives the possibility to change some parameters to see how it's affected.

- **IIR Filtering Freq Analysis**: Allows to see the frequency response of IIR filters by studying its corresponding Z-transforms. In this particular case the IIR's are all EMA(Exponential Moving Average). And also you can compare the implementations using both Doubles and Floats, it's interesting to notice how for some case scenarios the Float implementation is Unstable while its counterpart isn´t. This is important if you´re analyzing to implement a filter in an embedded device, as it would surely use Fixed Point or Float representations.

- **PID 2nd Ziegler-Nichols**: This script is an analytical approach to apply the 2nd method. As PID is used usually when you don´t have a model of the plant or system you´re attempting to control, this analysis serves merely as a pedagogical view of how the method actually works.
