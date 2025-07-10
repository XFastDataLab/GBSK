% Please kindly cite the paper Junyi Guan, Sheng li, Xiongxiong He, Jinhui Zhu, and Jiajia Chen 
%"Fast hierarchical clustering of local density peaks via an association degree transfer method," 
% Neurocomputing,2021,Doi:10.1016/j.neucom.2021.05.071

% The code was written by Junyi Guan in 2021.

clear all;close all;clc;
%% load dataset
% load dataset/jain
% data = jain;
data = importdata('dataset/covertype.txt');
%data = importdata('L:\N-BaIoT Dataset\sample data\4W.txt');
%data = importdata('L:\3M2D5\data.txt');
%data = importdata('data/covertype_data.txt');
%data = importdata('L:\train.csv\PCA_data.txt');  
%answer = data(:,end);  % 标签
%answer = importdata('dataset/pendigits_labels.txt');
tic
%data = data(:,1:end-1);
%% parameter setting
k = 5;
C = 7;
%% FHC_LPD clustering
[cl] = FHC_LPD(data,k,C);
%dlmwrite('L:\train.csv\labels_by_FHCLDP.txt', cl');
toc
dlmwrite('labels/labels_by_FHCLDP.txt', cl');

%{
%% evaluation
[AMI,ARI] = Evaluation(cl,answer);
%% show result
Result = struct;
Result.k = k;
Result.C = C;
Result.AMI = AMI;
Result.ARI = ARI;
Result
%}