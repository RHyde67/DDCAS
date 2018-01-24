function [ ] = Analysis2( handles )
%ANALYSIS2 Compares convergence of Online with Hybrid algorithm
%   Copyright R Hyde 2017
%   Released under the GNU GPLver3.0
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/
%   For a detailed description, see:
%   A new algorithm for initialising online and evolving clustering and eliminating start up times
%   R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
%   Discovery Jan 2018
%   1. Run DDCAS to T2
%   2. Initialise CODAS with DDCAS results
%   3. Run CODAS and Hybrid in parallel
%   4. Test for convergence and halt when achieved
% 

StatusOutput(handles,'Analysis 2 Started...')
drawnow

%% Initialise convergence plot
T2 = str2double(handles.textT2.String);
handles.axesConvergence;
axis(handles.axesConvergence, [0, handles.NumData-T2, 0, 1]);
xlabel('New Data');
ylabel('Convergence');


%% Initialize
IR = str2double(handles.editIR.String); % microC radius
MT = str2double(handles.editMT.String); % Min threshold
T2 = str2double(handles.textT2.String); % read T2
MergeTestRate = str2double(handles.editMergeTest.String);
MergeValue = str2double(handles.editMerge.String);
tMerge = 0; % time to merge
iMerge=0; % index of data at which merge occurs
ClustersCODAS=[]; % intialise clusters
NumClusts = 0; % no cluster generated yet
nData = 0; % number of data samples read; % number of data samples read
ClustersHybrid=[]; % intialise clusters
NumClustsStd = 0; % no cluster generated yet
ConvData = []; % array of data used during the convergence testing phase

%% for convergence, data needs to be randomized.
% If not, sequential data through a non-repeating pattern will never converge.
% insert noise at random times, then randomize data order.
StatusOutput(handles,'Reading and randomizing data...')
drawnow
fName = sprintf('%s.csv',handles.popDataSet.String{handles.popDataSet.Value});
DataIn = csvread(fName,1,0); % ignore first line in case of headers
if handles.popDataSet.Value == 1
    ClassData = DataIn(DataIn(:,end)>0,:);
    % place noise at random points throught data stream
    Noise = DataIn(DataIn(:,4)==0,:);
    Insert = randperm(size(ClassData,1));
    Insert = Insert(1:size(Noise,1));
    c=false(1,size(ClassData,1)+size(Insert,2));
    c(Insert)=true;
    Data = nan(size(c,2),3);
    Data(~c,:) = ClassData(:,1:3);
    Data(c,:) = Noise(:,1:3);
    idxRand = randperm(size(Data,1));
    Data = Data(idxRand,:);
    DataIn = DataIn(idxRand,:);
    StatusOutput(handles,'Chain Link data and noise read and randomized...')
    drawnow
elseif handles.popDataSet.Value == 2
    idxRand = randperm(size(DataIn,1));
    Data = DataIn(idxRand,1:2);
    DataIn = DataIn(idxRand,:);
    StatusOutput(handles,'Gaussian data read and randomized...')
    drawnow
elseif handles.popDataSet.Value ==3
    StatusOutput(handles,'LAQ data read, randomization not required...')
    Data = DataIn(:,1:2);
    drawnow
else
    StatusOutput(handles,'Only available for provided datasets due to randomization. Adjust code for additional data sets...')
    drawnow
end
% Normalise data 0-1
Data = (Data - handles.DataMin) ./ (handles.DataMax - handles.DataMin); % normalise data 0-1

%% Initialize hybrid with DDCAS
StatusOutput(handles,'Initializing Hybrid...')
drawnow
tic;
[ClustersHybrid, ~]=DDCAS_FixedR(Data(1:T2,:), IR, MT, 0); % run DDCAS and return Clusters
tDDCAS = toc;

%% Prepare output for CODAS initialization
[a,~]=find(ClustersHybrid.Global==0);
CurrentMax = max(ClustersHybrid.Global);
ClustersHybrid.Global(a)=CurrentMax+1:size(a,1)+CurrentMax;
NumClustsHyb = size (ClustersHybrid.Centre, 1);
StatusOutput(handles,'DDCAS Complete...');
drawnow

%% Convergence Test
tic % start timer
hWB = waitbar(0, 'Running until convergence, or end of data....');
idx1 = T2;
while idx1 < handles.NumData && handles.btnGo.Value == 1% until end of file
    idx1 = idx1 + 1;
    % read next sample
    Sample = Data(idx1,:); % read next line
    nData = nData + 1;
    % run CODAS and Hybrid on sample
    [ClustersCODAS, NumClustsStd] = CODAS2_ver02_Revised( IR, MT, Sample, ClustersCODAS, NumClustsStd );
    [ClustersHybrid, NumClustsHyb] = CODAS2_ver02_Revised( IR, MT, Sample, ClustersHybrid, NumClustsHyb );
    
    if nData/MergeTestRate == floor(nData/MergeTestRate)
        % check similarity
        [ SimMerge ] = TestConvergence( Data(1:idx1,:), ClustersCODAS, ClustersHybrid, IR, MT);

        ConvData = [ConvData;[nData,SimMerge]];
        plot(handles.axesConvergence, ConvData(:,1), ConvData(:,2), '-b');
        axis(handles.axesConvergence, [0, handles.NumData-T2, 0.5, 1]);
        handles.axesConvergence.XLabel.String = 'New Data';
        handles.axesConvergence.YLabel.String = 'Convergence';
        handles.textConvVal.String = ConvData(end,2);
        
        if SimMerge>MergeValue % if convergence has occured run clustering to obtain actual timing
           tic
           ClustersSimple = [];
           SimpleNumClusts = 0;
           for idxCheck = T2:idx1
               NewSample = Data(idxCheck,:);
               
               [ClustersSimple, SimpleNumClusts]=CODAS2_ver02_Revised(IR, MT, NewSample, ClustersSimple, SimpleNumClusts);
           end
           tMerge = toc; % time to run CODAS over new data, i.e. time to merge
           iMerge = idx1; % number of samples until merge
           idx1 = handles.NumData + 1;
        end
    end
    
    if nData/100 == floor(nData/100)
        waitbar( nData / (handles.NumData - T2) )
    end
        
end % end for
tEndCODAS = toc;
close(hWB);
if ~iMerge
    iMerge = idx1;
end

if handles.btnGo.Value == 0
    StatusOutput(handles,'User interrupt.')
    return
end

%% Display Results
StatusOutput(handles,'Analysis complete')
if tMerge > 0
    StatusOutput(handles, sprintf('Merged after %i samples.', iMerge-T2) )
    StatusOutput(handles, sprintf('CODAS takes %.3f s to merge.', tMerge) )
else
    StatusOutput(handles, sprintf('Failed to merge, maximum similarity: %.2f', max(ConvData(:,2))) )
end    
drawnow

StatusOutput(handles,'Plotting clusters...')
drawnow
PlotClusters(ClustersHybrid, str2double(handles.editIR.String),...
    str2double(handles.editMT.String), handles.axesHybClusters,...
    'Hybrid Analysis Clusters at Convergence', 'Normalised X-Data', 'Normalised Y-Data', 'Normalised Z-Data',...
    [], handles.popTestSelect.Value) % Plot Hybrid mC

PlotClusters(ClustersCODAS, str2double(handles.editIR.String),...
    str2double(handles.editMT.String), handles.axesStdClusters,...
    'Standard Analysis Clusters at Convergence', 'Normalised X-Data', 'Normalised Y-Data', 'Normalised Z-Data',...
    [], handles.popTestSelect.Value) % plot CODAS mC

StatusOutput(handles,'Plotting data...')
drawnow
[AssignedCODAS] = PlotData(handles, DataIn(1:iMerge,:), ClustersCODAS, IR, MT, handles.axesStdData,...
    'Standard Analysis Clustered Data at Convergence', 'X-Data', 'Y-Data', 'Z-Data',...
    [], handles.popTestSelect.Value); % Assigned = [Data, Class, Cluster]

[AssignedHybrid] = PlotData(handles, DataIn(1:iMerge,:), ClustersHybrid, IR, MT, handles.axesHybData,...
    'Hybrid Analysis Clustered Data at Convergence', 'X-Data', 'Y-Data', 'Z-Data',...
    [], handles.popTestSelect.Value); % Assigned = [Data, Class, Cluster]
drawnow

if handles.checkClass.Value
    StatusOutput(handles,'Calculating purity...')
    [PurityCODAS] = PurityCalc(AssignedCODAS);
    handles.textPurityStd.String = sprintf('%.3f',PurityCODAS(2,PurityCODAS(1,:)==-9999));
    handles.listPurityStd.String = PurityCODAS(2,PurityCODAS(1,:)~=-9999 & PurityCODAS(1,:)~=-1);

    [PurityHyb] = PurityCalc(AssignedHybrid);
    handles.textPurityHyb.String = sprintf('%.3f',PurityHyb(2,PurityHyb(1,:)==-9999));
    handles.listPurityHyb.String = PurityHyb(2,PurityHyb(1,:)~=-9999 & PurityHyb(1,:)~=-1);
else
    handles.textPurityStd.String = sprintf('N/A, No Classes');
    handles.listPurityStd.String = sprintf('N/A, No Classes');
    
    handles.textPurityHyb.String = sprintf('N/A, No Classes');
    handles.listPurityHyb.String = sprintf('N/A, No Classes');
end

StatusOutput(handles,'Calculating Jaccard accuracy...')
if handles.checkClass.Value % if class, then Jaccard CODAS to class
    [JaccardCODAS] = Modified_Jaccard2(AssignedCODAS(:,end-1:end)); % pass [class, cluster]
    handles.textJaccardStd.String = sprintf('%.4f',JaccardCODAS);
    [JaccardHybrid] = Modified_Jaccard2(AssignedHybrid(:,end-1:end)); % pass [class, cluster]
    handles.textJaccardHyb.String = sprintf('%.4f',JaccardHybrid);
    [JaccardHybStd] = Modified_Jaccard2([AssignedHybrid(:,end), AssignedCODAS(:,end)]); % pass [class, cluster]
    handles.textJaccardHybStd.String = sprintf('%.4f',JaccardHybStd);
else
    handles.textJaccardStd.String = sprintf('N/A, no classes');
    handles.textJaccardHyb.String = sprintf('N/A, no classes');
    [JaccardHybStd] = Modified_Jaccard2([AssignedHybrid(:,end), AssignedCODAS(:,end)]); % pass [class, cluster]
    handles.textJaccardHybStd.String = sprintf('%.4f',JaccardHybStd);
end

handles.textStdTime.String = sprintf('Num samples to converge:\n%.0f', iMerge-T2);
handles.textHybridTime.String = sprintf('Merge Time:\n %.3f s',tMerge);

StatusOutput(handles,'Analysis complete!')
StatusOutput(handles,'# # #')

%% Restore controls
set(findall(handles.uipanelSetup, '-property', 'enable'), 'enable', 'on');
end

