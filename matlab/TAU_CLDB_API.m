%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TAU CLDB example code for REST API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;

username = 'UserName';   % TAU-CLDB client username
password = 'PassWord';  % TAU-CLDB client password


%% send a query to the server (search hops)
options = weboptions('MediaType','application/json');
options.Username = username;
options.Password = password;
options.RequestMethod = 'post'; % use POST as HTTP method

obj_type = 'tau_cldb.Hop';
search1 = struct('property', 'length', 'operator', '<', 'value', 0.3);
search2 = struct('property', 'length', 'operator', '>', 'value', 0.28);
my_search = {{search1, search2}};

obj_query = struct('type', obj_type, 'where', struct('all', my_search));
request_body = struct('query', obj_query); 

% send request to server
api_url = 'http://132.66.54.148/omnisol/api';
object_query_url = [api_url, '/objects/query'];
response = webwrite(object_query_url, request_body, options);

% print the response in a cell array (one row for every hop/link/site)
columns = fieldnames(response.objects);
data = struct2cell(response.objects);
data = [columns'; data'];
fprintf('******** Found the following hops:\n');
disp(data);


%% create a query for DailyMeasurements objects
options = weboptions('MediaType','application/json');
options.Username = username;
options.Password = password;
options.RequestMethod = 'get'; % use GET as HTTP method

obj_id = 628331;

% send request to server
api_url = 'http://132.66.54.148/omnisol/api';
object_url = [api_url, '/objects/', num2str(obj_id)];
response = webread(object_url, options);
fprintf('******** DailyMeasurements object from server:\n');
disp(response);

% get the data file's id and request the data file's object
data_file_id = response.data_file;
object_url = [api_url, '/objects/', num2str(data_file_id)];
data_file = webread(object_url, options);

% get the raw data using the data file's uri number
options.ContentType = 'text';
uri = data_file.uri;
file_url = [api_url, '/files/', uri];
rawdata_file = webread(file_url, options); % returns a string

% convert string in rawdata_file to a cell array in variable rawdata
A = strsplit(rawdata_file, '\n');
B = cellfun(@(row) strsplit(row,','), A, 'un', 0);
rawdata = cell([size(B,2), size(B{1},2)]);
for i = 1:size(C,1)
    rawdata(i,:) = B{i};
end
fprintf('*** the variable rawdata contains measurements.\n');
% now the rawdata variable contains the link's measurements