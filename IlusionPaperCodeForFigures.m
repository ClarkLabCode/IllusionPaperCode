function IlusionPaperCodeForFigures
% This function plots data in all figures of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

%% Figure 1D: Wild-type turning response
load('Figure1D_data.mat')
load('general_parameters.mat')
Figure1D(Figure1D_flyResp,Figure1D_stimulusInfo,general_parameters)

%% Figure 1E: T4- and T5-silenced turning response
load('Figure1E_data.mat')
load('general_parameters.mat')
Figure1E(Figure1E_flyResp,Figure1E_stimulusInfo,general_parameters)

%% Figure 2B: Calcium responses of example T4P, T4R, T5P and T5R regions of
% interest to right and leftward moving light or dark edges.
load('Figure2B_data.mat')
Figure2B(Figure2B_flyResp,Figure2B_stimulusInfo)

%% Figure 2D: Calcium responses of T4 and T5 to single light or dark bars
load('Figure2D_data.mat')
load('general_parameters.mat')
Figure2D(Figure2D_flyResp,Figure2D_stimulusInfo,general_parameters)

%% Figure 2E: Calcium responses of T4 and T5 to stationary sawtooth
% gradients
load('Figure2E_data.mat')
load('general_parameters.mat')
Figure2E(Figure2E_flyResp,Figure2E_stimulusInfo,general_parameters)

%% Figure 2F:Calcium responses of T4 and T5 to stationary white/black 
% square wave gratings
load('Figure2F_data.mat')
load('general_parameters.mat')
Figure2F(Figure2F_flyResp,Figure2F_stimulusInfo,general_parameters)

%% Figure 3A: Calcium responses of T4 and T5 to stationary gray/black and
% gray/white square wave gratings
load('Figure3A_data.mat')
load('general_parameters.mat')
Figure3A(Figure3A_flyResp,Figure3A_stimulusInfo,general_parameters)

%% Figure 3BCDE: Calcium responses of T4 and T5 to pairs of bars
load('Figure3BCDE_data.mat')
load('general_parameters.mat')
Figure3BCDE(Figure3BCDE_flyResp,Figure3BCDE_stimulusInfo,general_parameters)

%% Figure 4B: Responses of synaptic model for T4 to sawtooth gradients and 
% white/black stationary square wave gratings
PlotStaticEdgeResponses('T4original')

%% Figure 4C: Responses of synaptic model for T4 to pairs of bars
PlotBarPairsResponses('T4original')

%% Figure 4D: Responses of synaptic model for T4 to to stationary gray/black and
% gray/white square wave gratings
PlotHalfContrastSquareWaveResponses('T4original')

%% Figure 4F: Responses of modified synaptic model for T4 to sawtooth
% gradients and white/black stationary square wave gratings
PlotStaticEdgeResponses('T4modified')

%% Figure 4G: Responses of modified synaptic model for T4 to pairs of bars
PlotBarPairsResponses('T4modified')

%% Figure 4H: Responses of modified synaptic model for T4 to to stationary 
% gray/black and gray/white square wave gratings
PlotHalfContrastSquareWaveResponses('T4modified')

%% Figure 5D: T5-silenced turning response
load('Figure5D_data.mat')
load('general_parameters.mat')
Figure5D(Figure5D_flyResp,Figure5D_stimulusInfo,general_parameters)

%% Figure 5E: T4-silenced turning response
load('Figure5E_data.mat')
load('general_parameters.mat')
Figure5E(Figure5E_flyResp,Figure5E_stimulusInfo,general_parameters)

%% Figure 6C: Psychometric curves for 2 example subjects
load('Figure6C_data.mat')
Figure6C(Figure6C_data)

%% Figure 6D: Estimated illusory velocity
load('Figure6D_data.mat')
Figure6D(Figure6D_data)

%% Figure 6E: Estimated slope
load('Figure6E_data.mat')
Figure6E(Figure6E_data)

%% Supplementary Figure 1: Wild-type turning at in response to sawtooth 
% gradents moving at a range os slow speeds.
load('SuppFigure1_data.mat')
SuppFigure1(SuppFigure1_data)

%% Supplementary Figure 2A: Calcium responses of T4 and T5 to stationary
% white/black square wave grating presented for 5 seconds.
load('SuppFigure2A_data.mat')
load('general_parameters.mat')
SuppFigure2A(SuppFigure2A_flyResp,SuppFigure2A_stimulusInfo,general_parameters)

%% Supplementary Figure 2B: Calcium responses of T4 and T5 to a row of a 
% stationary naturalist image
load('SuppFigure2B_data.mat')
load('general_parameters.mat')
SuppFigure2B(SuppFigure2B_flyResp,SuppFigure2B_stimulusInfo,SuppFigure2B_natImageProjection,general_parameters)

%% Supplementary Figure 3A: Calcium responses of T4 and T5 to stationary
% gray/black and gray/white square wave gratings
load('SuppFigure3A_data.mat')
load('general_parameters.mat')
SuppFigure3A(SuppFigure3A_flyResp,SuppFigure3A_stimulusInfo,general_parameters)

%% Supplementary Figure 3BCDEFGHI: Calcium responses of T4 and T5 to pairs
% of bars
load('SuppFigure3BCDEFGHI_data.mat')
load('general_parameters.mat')
SuppFigure3BCDEFGHI(SuppFigure3BCDEFGHI_flyResp,SuppFigure3BCDEFGHI_stimulusInfo,general_parameters)

%% Supplementary Figure 4B: Responses of Barlow-Levick model to sawtooth
% gradients and white/black stationary square wave gratings
PlotStaticEdgeResponses('Barlow-Levick')

%% Supplementary Figure 4D: Responses of motion energy model to sawtooth
% gradients and white/black stationary square wave gratings
PlotStaticEdgeResponses('MotionEnergy')

%% Supplementary Figure 5B
PlotStaticEdgeResponses('T5')

%% Supplementary Figure 5C
PlotBarPairsResponses('T5')

%% Supplementary Figure 5D
PlotHalfContrastSquareWaveResponses('T5')

%% Supplementary Figure 5E
PlotSinusoidPowerMap('T4original')
PlotMovingEdgeResponses('T4original')

%% Supplementary Figure 5F
PlotSinusoidPowerMap('T4modified')
PlotMovingEdgeResponses('T4modified')

%% Supplementary Figure 5G
PlotSinusoidPowerMap('T5')
PlotMovingEdgeResponses('T5')

%% Supplementary Figure 7: Psychometric curves for all subjects
load('SuppFigure7_data.mat')
SuppFigure7(SuppFigure7_data)