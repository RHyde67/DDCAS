function [ MJI ] = Modified_Jaccard2( Results )
%MODIFIED_JACCARD Cluster quality measure for arbitrarily shaped clusters.
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
%   Many standard cluster quality measures are unsuitable for arbitrary
%   shaped clusters due to their reliance on intra- and inter-cluster
%   distances.
%   This modification to the Jaccard index, sums the Jaccard index for each
%   cluster resulting from the clustering algorithm and provides a single
%   value for the accuracy of the clustering algorithm, i.e. how many data
%   are correctly assigned to a matching cluster.
%   Data is passed in as an array of [Class, Cluster] and the index value is returned.
%   Each class can only have a single cluster mapped to it. This ensures
%   the measure is an index represntig how well the clusters match the
%   original class and penalises the division of a class. This provides a
%   better measure of how the clusters match the classes than other
%   methods,
%   such as purity, which allows the division of classes so long as each
%   cluster consists of a single class.
%   Index value = 1 is perfect match, closer 1 is better.
% For a detailed description, see:
% A new algorithm for initialising online and evolving clustering and eliminating start up times
% R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
% Discovery Jan 2018

TotSamples = size(Results(Results(:,1)~=-1),1); % Total number of non-outliers in hybrid-clustering class
Results(any(Results==-999,2),:)=[]; % remove outliers
Results(any(Results==-1,2),:)=[]; % remove outliers
Results(any(Results==0,2),:)=[]; % remove outliers
Class = Results(:,1);
Cluster = Results(:,2);

for idx1 = unique(Class)'
    JClass(idx1,:) = double(Class == idx1);
end

for idx1 = unique(Cluster)'
    JClus(idx1,:) = double(Cluster == idx1);
end

%%
% for idxClass = 1:size(JClass,1)
%     for idxClus = 1:size(JClus,1)
%         JD(idxClass, idxClus) = 1 - pdist([JClass(idxClass,:) ; JClus(idxClus,:)], 'Jaccard');
%     end
% end
% ### Faster
JD = 1- pdist2(JClass, JClus, 'Jaccard'); % Jaccard index of each Cluster/ Class pair

[~, CM] = max(JD,[],2); % find the cluster that represents the most data for each class
TC=0;
for idx = unique(Class)'
    TC = TC + sum(Class == idx & Cluster == CM(idx)); % total correctly assigned
end

MJI = TC/TotSamples;

