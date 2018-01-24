function [ MJI ] = TestConvergence ( MergeTestData, ClustersSimple, ClustersHybrid, IR, MT)
%TESTCONVERGENCE Tests convergence of two alternative clustering results
%   Copyright R Hyde 2017
%   Released under the GNU GPLver3.0
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/
%   DDCAS_Demo is a GUI for carrying out demonstartion analysis of the
%   DDCAS algorithm.
%   For a detailed description, see:
%   A new algorithm for initialising online and evolving clustering and eliminating start up times
%   R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
%   Discovery Jan 2018
%   When comparing two types of clustering this comparesthe results using
%   the Modified Jaccard Index. For online or evolving clustering into
%   arbitrarily shaped clusters, each technique returns a cluster region
%   and the data is archived. This funtion compares the cluster regions by
%   assigning the archived data to the repective cluster and comparing the
%   results. The value returned, MJI, is a similarity
%   index of the results. Where complete convergence is not expected, this
%   can be used to compare with a threshold, above which convergence is
%   considered to be acceptable.
% Inputs:
%   MergeTestData:
%   ClustersSimple:  cluster regions from cluster technique 1
%   ClustersHybrid: cluster regions from cluster technique 2
%   IR: cluster radius
%   MT: minimum threshold for a micro-cluster to be considered data and not
%       noise
% Outputs:
%   MJI: modified Jaccard Index for the comparison


%% Assign the data to the respective macro-cluster
mCHyb=[];
[mCd, mC] = min(pdist2(ClustersHybrid.Centre, MergeTestData),[],1); % find distance and indices to nearest mC
MCHyb = ClustersHybrid.Global(mC); % Assign MC
MCHyb(ClustersHybrid.Count(mC)<MT)=-1; % remove assign if mC too small, leaves only data assigned to valid mC

[mCd, mC] = min(pdist2(ClustersSimple.Centre, MergeTestData),[],1); % find distance and indices to nearest mC
MCSimple = ClustersSimple.Global(mC);
MCSimple(ClustersSimple.Count(mC)<MT)=-1;
MCSimple(mCd>IR)=-1;

Assign = [MCHyb, MCSimple];

%% Calculate MJI
MJI = Modified_Jaccard2(Assign);

end % end function