% Please do not share or use this code without my written permission.
% Author: Alex Breslav

function start
% -----------------------------------settings-----------------------------------
% ------------------------------------------------------------------------------
% testing or running the experiment?
test = 1; % set to 1 for testing

% ONLY SET = 1 DURING TESTING; collects screenshots of all of the instructions
img_collect_on = 0;

% define the names of the researchers
researchers = {'Lucy', 'Other'}; % list the names of the researchers; do not remove 'other' option
researchers_idx = [1 2]; % there should be a number for each option
researchers_text = ['\n\n' ...
  'What is the name of the researcher conducting the study?' '\n' ...
  '1 = Lucy' '\n' ...
  '2 = Other' '\n' ...
  'Response: ' ]; % the list and index numbers above need to match the text here perfectly!

% Text formatting specifications
textsize = 40;
textsize_feedback = 50;
textsize_tickets = 140;

% loading bar formatting
load_bar_dimensions = [400, 15];

% iti distributions N~(mean, sd)
win_iti = [5, 0.5];
loss_iti = [3, 0.5];

% ----------------------------defaults for testing------------------------------
% ------------------------------------------------------------------------------
if test == 1
    testing_on_mac = 1; % testing on the PC, not mac (testing_on_mac = 1 for mac)
    num_trials_practice = 2;
    num_trials_main_task = 2;

    if testing_on_mac == 1
        file_root = '/Users/alex/OneDrive - Duke University/1_research/3_mdt_ants/6_raw_data'; % this is set up to use on Alex's personal computer
        sl = '/'; % Mac convention for the slashes
        input_source = 6; % internal keyboard (5); external keyboard (6)
    else
        file_root = 'NEED FILE ROOT';                                                           % <--------- NEED INPUT
        sl = '\'; % PC convention for slashes
        input_source = 0; % keyboard
    end

    confirm = 99;
    while isempty(confirm) || ~ismember(confirm, [0 1])
       confirm = input(['\n\n' ...
       'You are running in test mode. Here are the options currently selected:' '\n\n' ...
        num2str(testing_on_mac) ' | 1 = Mac (OSX), 0 = PC (Windows)'  '\n' ...
        num2str(input_source) ' | 0 = Internal (or USB) Keyboard, 1 = Touchscreen, 6 = Bluetooth Keyboard'  '\n' ...
        'Practice trials: ' num2str(num_trials_practice) '\n' ...
        'Task trials: ' num2str(num_trials_main_task) '\n' ...
        'Collecting screenshots on? ' num2str(img_collect_on) '\n\n' ...
        'Do these settings look good?' '\n'...
         '0 = No, I need to fix something in settings.' '\n' ...
         '1 = Yes, continue.' '\n' ...
         'Response: ' ]);

       if isempty(confirm) || ~ismember(confirm, [0 1])
         disp('Invalid entry, please try again.')
       end
    end

    if confirm == 0
       disp([ fprintf('\n') ...
       'OK, you should restart the function to try again'])
       sca;
       return
    end

else
% ----------------------------defaults for experiment---------------------------
% ------------------------------------------------------------------------------
    num_trials_practice = 10; % number of trials in the practice round
    num_trials_main_task = 150; % number of trials in the main task
    file_root = 'NEED FILE ROOT'                                                           % <--------- NEED INPUT
    sl = '\'; % PC convention for slashes
    input_source = 0; % keyboard (input_source = 1 for touchscreen)
end

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% clear everything from the workspace
Screen('CloseAll');
FlushEvents;

% get the subject number as a string
sub = input('subject id: ');

% get the visit name
visit = 99
while isempty(visit) || ~ismember(visit, [1 2 3])
    sub_exists = input(['\n\n' ...
    'Subject' filename_subnum ' does not have food rankings yet.' '\n' ...
    'Do you want to enter a new subject number?' '\n\n' ...
     '1 = Baseline visit.' '\n' ...
     '2 = Post single session visit.' '\n' ...
     '3 = Post case series visits.' '\n' ...
     'Response: ' ]);

    if isempty(visit) || ~ismember(visit, [1 2 3])
     disp('Invalid entry, please try again.')
    end
end

% recode the visit name
if visit == 1
    visit = '1_baseline'
elseif visit == 2
    visit = '2_post_single_session'
else
    visit = '3_post_case_series'
end

% create subject folder in the raw data folder
filename_subnum = pad(num2str(sub), 4, 'left', '0');
data_file_path = [file_root sl visit sl 'sub' filename_subnum];
directory = exist(data_file_path); % check if the directory already exists

% if the directory doesn't exist, they haven't done the food rankings yet
if directory == 0
    disp([ fprintf('\n') ...
    'ERROR: This subject has not completed their food rankings yet.'])
    sca;
    return

% check if the subject already has an init.mat file
sub_intialized = exist(data_file_path sl 'init.mat')
if sub_intialized == 7
    sub_exists = 99;
    while isempty(sub_exists) || ~ismember(sub_exists, [0 1])
        sub_exists = input(['\n\n' ...
        'Subject' filename_subnum ' already exists for this visit.' '\n' ...
        'Do you want to enter a new subject number?' '\n\n' ...
        '1 = Yes, I''ll restart and enter a new subject number.' '\n' ...
        '0 = No, I need to alter this subject''s data' '\n' ...
        'Response: ' ]);

        if isempty(sub_exists) || ~ismember(sub_exists, [0 1])
         disp('Invalid entry, please try again.')
       end
    end
else
   sub_exists = 99;
end

if sub_exists == 1
   disp([ fprintf('\n') ...
   'OK, you should restart the function to try again'])
   sca;
   return

elseif sub_exists == 0
  % this is looking for complete data other than on the main task; all files should exist but the number of trials doesn't match
  % the number of trials with an iti_actual. I am using iti_actual as the indicator of a complete trial because it doesn't populate
  % until the very end of the code for each trial.
    start_where = 99;
    % I NEED TO UPDATE ALL OF THIS TO HANDLE MULTIPLE BLOCKS
    % I NEED TO PICK A NEW INDICATOR FOR TRIALS COMPLETE

    % if isfile([data_file_path sl 'init.mat']) && isfile([data_file_path sl 'practice.mat']) && isfile([data_file_path sl 'task.mat'])
    %     load([data_file_path sl 'init.mat']);
    %     load([data_file_path sl 'task.mat']);
    %     if init.num_trials(2) == nnz(task.iti_actual)
    %         while isempty(start_where) || ~ismember(start_where, [0 99])
    %             start_where = input(['\n\n' ...
    %             'This subject has complete data,' '\n' ...
    %             'are you sure you want to overwrite it?' '\n\n' ...
    %             '0 = CANCEL and restart the function' '\n' ...
    %             '99 = Yes, I want to overwrite the data' '\n' ...
    %             'Response: ']);
    %
    %             if isempty(start_where) || ~ismember(start_where, [0 99])
    %               disp('Invalid entry, please try again.')
    %             end
    %         end
    %     else
    %         while isempty(start_where) || ~ismember(start_where, [0 5])
    %             start_where = input(['\n\n' ...
    %             'This subject has incomplete data for the main game.' '\n' ...
    %             'It looks like they completed ' num2str(nnz(task.iti_actual)) ' trials.' '\n' ...
    %             'They still have ' num2str(init.num_trials(2) - nnz(task.iti_actual)) ' to go.' '\n' ...
    %             'Do you want to restart the game where they left off (on trial ' num2str(nnz(task.iti_actual) + 1) ')?' '\n\n' ...
    %             '0 = I need to fix something; restart the function.' '\n' ...
    %             '5 = Yes, restart the main game at trial ' num2str(nnz(task.iti_actual) + 1) '\n' ...
    %             'Response: ']);
    %
    %             if isempty(start_where) || ~ismember(start_where, [0 5])
    %               disp('Invalid entry, please try again.')
    %             end
    %         end
    %
    %         init.trials_start = nnz(task.iti_actual) + 1;
    %         save([data_file_path sl 'init'], 'init', '-v6');
    %     end
    % end

    if start_where == 99
        load([data_file_path sl 'init.mat']);
        if init.block(2) == 1
            block1_text = 'Money';
            block2_text = 'Food';
        else
            block1_text = 'Food';
            block2_text = 'Money';
        end

        while isempty(start_where) || ~ismember(start_where, [0 1 2 3 4 5])
            start_where = input(['\n\n' ...
            'Where do you want to start?' '\n' ...
            'You will overwrite any existing data on and after the place you choose.' '\n\n' ...
            '0 = CANCEL and restart the function' '\n' ...
            '1 = Re-initialize the subject''s data (this completely starts over)' '\n' ...
            '2 = Tutorial' '\n' ...
            '3 = Practice Game' '\n' ...
            '4 = Block 1 (' block1_text ')' '\n' ...
            '5 = Block 1 (' block2_text ')' '\n' ...
            'Response: ']);

            if isempty(start_where) || ~ismember(start_where, [0 1 2 3 4 5])
              disp('Invalid entry, please try again.')
            end
        end
    end

    if start_where == 0
         disp([fprintf('\n') ...
         'OK, you should restart the function to try again'])
         sca;
         return
    end

else
    start_where = 1;
end

if start_where <= 1;
    init = struct;

    % Identify the researcher
    researcher = 99;
    while isempty(researcher) || ~ismember(researcher, researchers_idx)
        researcher = input(researchers_text);

        if isempty(researcher) || ~ismember(researcher, researchers_idx)
            disp('Invalid entry, please try again.')
        end

        if researcher == max(researchers_idx)
          researcher_specify = input(['\n\n' ...
            'You chose Other. Please type the first name of the researcher conducting the study?' '\n' ...
            'Make sure to capitalize your name (e.g. Alex not alex)' '\n' ...
            'Name: ' ], 's');
        end

    end

    % save whether this is a test or not
    init.test = test;
    init.input_source = input_source;

    % shuffle the rng and save the seed
    rng('shuffle');
    init_rng_seed = rng;
    init_rng_seed = init_rng_seed.Seed;

    % create stimuli structure
    init.sub = sub; % save the subject number into the structure
    init.data_file_path = data_file_path; % save the data file path
    init.rng_seed = init_rng_seed; % save the rng seed for the init

    if researcher == max(researchers_idx)
        init.researcher = researcher_specify;
    else
        init.researcher = researchers{researcher}; % save the name of the researcher who conducted the study
    end

    % stimuli sets
    spaceships = {'cornhusk', 'stingray', 'triangle', 'tripod'};
    aliens = {'gizmo', 'sully', 'bear', 'vlad', 'piglet', 'elmo', 'mac', 'sid'};
    step1_colors = {'blue', 'orange'};
    step2_color_pairs = {'red_purple', 'yellow_green'};
    step2_color = {'warm', 'cool'};

    % create shuffled arrays of each of the symbols and colors
    init.stim_color_step1 = step1_colors(randperm(numel(step1_colors)));
    init.stim_colors_step2 = step2_color_pairs(randperm(numel(step2_color_pairs)));
    init.stim_step2_color_select = step2_color(randperm(numel(step2_color)));
    init.spaceships = spaceships(randperm(numel(spaceships)));
    init.aliens = aliens(randperm(numel(aliens)));

    % randomize the block order for the food and money blocks
    block = randi([1,2]);
    init.block = [0 block 3-block];

    % input the number of trials per block; 1 = practice trials, 2 = experimental blocks
    init.num_trials = [num_trials_practice num_trials_main_task];

    % set the file root and backslash vs. forwardslash convention
    init.file_root = file_root;
    init.slash_convention = sl;

    % set the text formatting specs
    init.textsize = textsize;
    init.textsize_feedback = textsize_feedback;
    init.textsize_tickets = textsize_tickets;

    % set the load bar formaating
    init.load_bar_dimensions = load_bar_dimensions;

    % create the ITIs
    iti_init = zeros(150,6);
    % loss iti
    iti_init(:,1) = normrnd(loss_iti(1),loss_iti(2),150,1);
    % win iti
    iti_init(:,2) = normrnd(win_iti(1),win_iti(2),150,1);
    % number of frames per iti; subtract 24 frames because the chosen stimulus is shown for 1 second before the loading bar
    iti_init(:,3:4) = floor(iti_init(:,1:2)*24) - 24;
    %number of pixels per frame
    iti_init(:,5:6) = (ones(150,2)*load_bar_dimensions(1))./iti_init(:,3:4);
    init.iti_init = iti_init;

    % load the walk
    load(['walks.mat']);
    walk_idx = randi(length(walks.payoff_prob));
    init.walk_idx = walk_idx;
    init.payoff_prob = walks.payoff_prob(:,:,walk_idx);
    init.walk_seed = walks.seed(walk_idx);
    init.img_collect_on = img_collect_on;
    init.pause_to_read = 0.5;
    init.explore_time = 1;
    init.feedback_time = 1;
    init.trials_start = 1;

    save([data_file_path sl 'init'], 'init', '-v6');


    % --- Double check everything
    double_check = 99;
    while isempty(double_check) || ~ismember(double_check, [0 1])
        double_check = input(['\n\n' ...
          'Researcher = ' init.researcher '\n' ...
          'Subject ID = ' num2str(init.sub) '\n' ...
          '0 = I need to fix something; restart the function.' '\n' ...
          '1 = This is correct; continue.' '\n' ...
          'Response: ' ]);

        if isempty(double_check) || ~ismember(double_check, [0 1])
          disp('Invalid entry, please try again.')
        end
    end

    if double_check == 0
       disp([fprintf('\n') ...
       'OK, you should restart the function to try again'])
       sca;
       return
    end
else
    load([data_file_path sl 'init.mat']);
end

% start the tutorial
if start_where <= 2
    exit_flag = tutorial(init);

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

% start the practice trials
if start_where <= 3
    exit_flag = practice_trials(init, init.num_trials(1), init.block(1));

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

% start the first block
if start_where <= 4
    exit_flag = main_task(init, init.num_trials(2), init.block(2));

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

if start_where <= 5
    exit_flag = main_task(init, init.num_trials(2), init.block(3));

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

% --- display winnings
load([data_file_path sl 'task.mat']);
task_func.output_for_food_choice(init);
disp([fprintf('\n\n\n') ...
'The participant earned ' num2str(task.ticket_sum) ' tickets'])

end
