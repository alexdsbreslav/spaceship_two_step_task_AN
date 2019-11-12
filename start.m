% Please do not share or use this code without my written permission.
% Author: Alex Breslav

function start(sub_id, qualtrics_response_id)
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

% screen dimensions for the test computer
test_screen_width = 1440;
test_screen_height = 900;

% python path
python_path = '/Users/lucygallop/opt/anaconda3/envs/update2020/bin/python'; % python path on Lucy's computer
test_for_python_path = exist(python_path);
if test_for_python_path == 0
    python_path = '/Users/alex/anaconda3/envs/update2020/bin/python'; % python path on Alex's computer
    test_for_python_path = exist(python_path);
    if test_for_python_path == 0
        disp([ fprintf('\n') ...
        'ERROR: Python path does not exist.'])
        sca;
        return
    end
end

% ----------------------------defaults for testing------------------------------
% ------------------------------------------------------------------------------
if test == 1
    num_trials_practice = 1;
    num_trials_main_task = 1;

    confirm = 99;
    while isempty(confirm) || ~ismember(confirm, [0 1])
       confirm = input(['\n\n' ...
       'You are running in test mode. Here are the options currently selected:' '\n\n' ...
        'Practice trials: ' num2str(num_trials_practice) '\n' ...
        'Task trials: ' num2str(num_trials_main_task) '\n' ...
        'Collecting screenshots on? ' num2str(img_collect_on) '\n\n' ...
        'Do these settings look good?' '\n'...
        '1 = Yes, continue.' '\n' ...
        '0 = No, I need to fix something in settings.' '\n' ...
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
    num_trials_practice = 15; % number of trials in the practice round
    num_trials_main_task = 150; % number of trials in the main task
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

% determine operating system
if ismac == 1
    sl = '/'; % Mac convention for the slashes
else
    sl = '\'; % PC convention for slashes
end

% get file path
directory = fileparts(pwd);
file_root = [directory sl 'raw_data'];

% get the keyboard
keyboards = GetKeyboardIndices;
input_source = keyboards(length(keyboards)); % internal keyboard (1); external keyboard (2)
% get the parameters for the monitor
num_screens = Screen('Screens'); %count the screen
pick_screen = max(num_screens); %select the screen;
[screen_width, screen_height] = Screen('WindowSize', pick_screen);
stimuli_designed_for_screen_width = 1920;
stimuli_designed_for_screen_height = 1080;

% this is checking for Alex's home setup; if testing here, set screen width to test computer
if screen_width == 2560 && screen_height == 1440
    screen_width = test_screen_width;
    screen_height = test_screen_height;
end

% rescale the stimulus if the monitor is less than 1920x1080
scale_stim = min([screen_width/stimuli_designed_for_screen_width screen_height/stimuli_designed_for_screen_height]);
scale_background = max([screen_width/stimuli_designed_for_screen_width screen_height/stimuli_designed_for_screen_height]);

% text formatting specifications
textsize = ceil(40*scale_background);
textsize_feedback = ceil(50*scale_background);

% get the subject number as a string
sub = sub_id;

% get the visit name
visit = 99;
while isempty(visit) || ~ismember(visit, [1 2 3])
    visit = input(['\n\n' ...
    'Which visit is this?' '\n' ...
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
    visit = '1_baseline';
elseif visit == 2
    visit = '2_post_single_session';
else
    visit = '3_post_case_series';
end

% create subject folder in the raw data folder
filename_subnum = pad(num2str(sub), 4, 'left', '0');
data_file_path = [file_root sl visit sl 'sub' filename_subnum];

% randomize the block order for the food and money blocks
block = randi([1,2]);
if block == 1
    block = {'practice' 'food' 'money'};
else
    block = {'practice' 'money' 'food'};
end

% check if the subject already has an init.mat file
sub_intialized = exist([data_file_path sl 'init.mat']);
if sub_intialized == 2
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
    load([data_file_path sl 'init.mat']);
    if isfile([data_file_path sl init.block{2} '.mat']) && isfile([data_file_path sl init.block{3} '.mat'])
        load([data_file_path sl init.block{2} '.mat']);
        block2_complete = init.num_trials(2) == nnz(nansum(task.off(:,2:3),2));

        load([data_file_path sl init.block{3} '.mat']);
        block3_complete = init.num_trials(2) == nnz(nansum(task.off(:,2:3),2));

        if block2_complete && block3_complete
            start_where = 999;
            while isempty(start_where) || ~ismember(start_where, [0 99])
                start_where = input(['\n\n' ...
                'This subject has complete data,' '\n' ...
                'are you sure you want to overwrite it?' '\n\n' ...
                '0 = CANCEL and restart the function' '\n' ...
                '99 = Yes, I want to overwrite the data' '\n' ...
                'Response: ']);

                if isempty(start_where) || ~ismember(start_where, [0 99])
                  disp('Invalid entry, please try again.')
                end
            end
        else
            while isempty(start_where) || ~ismember(start_where, [0 5])
                start_where = input(['\n\n' ...
                'This subject has incomplete data for the ' init.block{3} ' block.' '\n' ...
                'It looks like they completed ' num2str(nnz(nansum(task.off(:,2:3),2))) ' trials.' '\n' ...
                'They still have ' num2str(init.num_trials(2) - nnz(nansum(task.off(:,2:3),2))) ' to go.' '\n' ...
                'Do you want to restart the game where they left off (on trial ' num2str(nnz(nansum(task.off(:,2:3),2)) + 1) ')?' '\n\n' ...
                '5 = Yes, restart the ' init.block{3} ' game at trial ' num2str(nnz(nansum(task.off(:,2:3),2)) + 1) '\n' ...
                '0 = I need to fix something; restart the function.' '\n' ...
                'Response: ']);

                if isempty(start_where) || ~ismember(start_where, [0 5])
                  disp('Invalid entry, please try again.')
                end
            end

            init.trials_start(3) = nnz(nansum(task.off(:,2:3),2)) + 1;
            save([data_file_path sl 'init'], 'init', '-v6');
        end
    elseif isfile([data_file_path sl init.block{2} '.mat']) && ~isfile([data_file_path sl init.block{3} '.mat'])
        load([data_file_path sl 'init.mat']);

        load([data_file_path sl init.block{2} '.mat']);
        block2_complete = init.num_trials(2) == nnz(nansum(task.off(:,2:3),2));

        if block2_complete
            while isempty(start_where) || ~ismember(start_where, [0 6])
                start_where = input(['\n\n' ...
                'This subject has complete data for the ' init.block{2} ' block,' '\n' ...
                'but no data for ' init.block{3} ' block.' '\n' ...
                'Do you want to start from the beginning of the ' init.block{3} ' block?' '\n\n' ...
                '6 = Yes, start from the beginning of the ' init.block{3} ' block.' '\n' ...
                '0 = I need to fix something; restart the function.' '\n' ...
                'Response: ']);

                if isempty(start_where) || ~ismember(start_where, [0 6])
                  disp('Invalid entry, please try again.')
                end
            end
        else
            while isempty(start_where) || ~ismember(start_where, [0 5])
                start_where = input(['\n\n' ...
                'This subject has incomplete data for the ' init.block{2} ' block.' '\n' ...
                'It looks like they completed ' num2str(nnz(nansum(task.off(:,2:3),2))) ' trials.' '\n' ...
                'They still have ' num2str(init.num_trials(2) - nnz(nansum(task.off(:,2:3),2))) ' to go.' '\n' ...
                'Do you want to restart the game where they left off (on trial ' num2str(nnz(nansum(task.off(:,2:3),2)) + 1) ')?' '\n\n' ...
                '5 = Yes, restart the ' init.block{2} ' game at trial ' num2str(nnz(nansum(task.off(:,2:3),2)) + 1) '\n' ...
                '0 = I need to fix something; restart the function.' '\n' ...
                'Response: ']);

                if isempty(start_where) || ~ismember(start_where, [0 5])
                  disp('Invalid entry, please try again.')
                end
            end

            init.trials_start(2) = nnz(nansum(task.off(:,2:3),2)) + 1;
            save([data_file_path sl 'init'], 'init', '-v6');
        end
    end

    if start_where == 99
        while isempty(start_where) || ~ismember(start_where, [0 1 2 3 4 5 6 7])
            start_where = input(['\n\n' ...
            'Where do you want to start?' '\n' ...
            'You will overwrite any existing data on and after the place you choose.' '\n\n' ...
            '0 = CANCEL and restart the function' '\n' ...
            '1 = Re-initialize the subject''s data (this completely starts over)' '\n' ...
            '2 = Tutorial' '\n' ...
            '3 = Practice Game' '\n' ...
            '4 = Comprehension Questions (Qualtrics)' '\n' ...
            '5 = Block 1 (' init.block{2} ')' '\n' ...
            '6 = Block 2 (' init.block{3} ')' '\n' ...
            '7 = Reveal results (Qualtrics)' '\n' ...
            'Response: ']);

            if isempty(start_where) || ~ismember(start_where, [0 1 2 3 4 5 6 7])
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

    if start_where == 1
        % if we are reintializing the subject then delete any existing matlab data
        delete([init.data_file_path '/*.mat'])
    end

else
    start_where = 1;
    mkdir(data_file_path)
end

if start_where <= 1
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

    % save specs for opening ptb windows
    init.pick_screen = pick_screen;
    init.screen_dimensions = [0 0 screen_width screen_height];
    init.scale_stim = scale_stim;
    init.scale_background = scale_background;

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

    % save block order
    init.block = block;

    % stimuli sets
    spaceships = {'cornhusk', 'stingray', 'triangle', 'tripod', 'egg', 'ufo'};
    aliens = {'bubbles', 'eggbert', 'frog', 'fuzz', 'ghost', 'legs', 'nightking', 'penguin', 'rooster', 'sun', 'unicorn', 'viking'};
    step2_color_pairs = {'orange_purple', 'yellow_green', 'red_blue'};
    step2_color = {'warm', 'cool'};

    % create shuffled arrays of each of the symbols and colors
    init.stim_colors_step2 = step2_color_pairs(randperm(numel(step2_color_pairs)));
    init.stim_step2_color_select = step2_color(randperm(numel(step2_color)));
    init.spaceships = spaceships(randperm(numel(spaceships)));
    init.aliens = aliens(randperm(numel(aliens)));

    % input the number of trials per block; 1 = practice trials, 2 = experimental blocks
    init.num_trials = [num_trials_practice num_trials_main_task];

    % set the file root and backslash vs. forwardslash convention
    init.file_root = file_root;
    init.slash_convention = sl;

    % set the text formatting specs
    init.textsize = textsize;
    init.textsize_feedback = textsize_feedback;

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
    init.trials_start = [1 1 1];

    save([data_file_path sl 'init'], 'init', '-v6');


    % --- Double check everything
    double_check = 99;
    while isempty(double_check) || ~ismember(double_check, [0 1])
        double_check = input(['\n\n' ...
          'Researcher = ' init.researcher '\n' ...
          'Subject ID = ' num2str(init.sub) '\n' ...
          '1 = This is correct; continue.' '\n' ...
          '0 = I need to fix something; restart the function.' '\n' ...
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
    exit_flag = two_step_task(init, init.num_trials(1), init.block{1});

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

% start the comprehension questions
if start_where <= 4
    script_path = [directory sl 'scripts' sl 'open_comprehension_questions.py'];

    if sum(isspace(script_path)) > 0
        script_path = ['"' script_path '"']; % if spaces in path, add ""
    end

    cmd_string = [python_path ' ' script_path ' ' sub_id ' ' visit];
    system(cmd_string);

    done_comprehension = 99;
    while isempty(done_comprehension) || ~ismember(done_comprehension, [0 1])
        done_comprehension = input(['\n\n' ...
          'Once you are done the comprehension questions, come back here:' '\n\n' ...
          '1 = I''ve completed the comprehension questions, continue. ' '\n' ...
          '0 = I need to fix something; restart the function.' '\n' ...
          'Response: ' ]);

        if isempty(done_comprehension) || ~ismember(done_comprehension, [0 1])
          disp('Invalid entry, please try again.')
        end
    end

    if done_comprehension == 0
       disp([ fprintf('\n') ...
       'OK, you should restart the function to try again'])
       sca;
       return
    end
end

% start the first block
if start_where <= 5

    explain_block = 99;
    while isempty(explain_block) || ~ismember(explain_block, [0 1])
        explain_block = input(['\n\n' ...
          'Block = ' init.block{2} '\n' ...
          'Remind subject about outcomes of ' init.block{2} ' block:' '\n' ...
          '"You are playing for ' init.block{2} ' rewards...""' '\n' ...
          '"If you win a lot of space treasure..."' '\n' ...
          '"If you do not win a lot of space treasure..."' '\n\n' ...
          '1 = I''ve explained the block outcomes, continue. ' '\n' ...
          '0 = I need to fix something; restart the function.' '\n' ...
          'Response: ' ]);

        if isempty(explain_block) || ~ismember(explain_block, [0 1])
          disp('Invalid entry, please try again.')
        end
    end

    if explain_block == 0
       disp([ fprintf('\n') ...
       'OK, you should restart the function to try again'])
       sca;
       return
    end

    exit_flag = two_step_task(init, init.num_trials(2), init.block{2});

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

% start the second block
if start_where <= 6

  explain_block = 99;
  while isempty(explain_block) || ~ismember(explain_block, [0 1])
      explain_block = input(['\n\n' ...
        'Block = ' init.block{3} '\n' ...
        'Remind subject about outcomes of ' init.block{3} ' block:' '\n' ...
        '"You are playing for ' init.block{3} ' rewards..."' '\n' ...
        '"If you win a lot of space treasure..."' '\n' ...
        '"If you do not win a lot of space treasure..."' '\n\n' ...
        '1 = I''ve explained the block outcomes, continue. ' '\n' ...
        '0 = I need to fix something; restart the function.' '\n' ...
        'Response: ' ]);

      if isempty(explain_block) || ~ismember(explain_block, [0 1])
        disp('Invalid entry, please try again.')
      end
  end

  if explain_block == 0
       disp([ fprintf('\n') ...
       'OK, you should restart the function to try again'])
       sca;
       return
  end

  exit_flag = two_step_task(init, init.num_trials(2), init.block{3});

    if exit_flag == 1
        disp('The script was exited because ESCAPE was pressed')
        sca; return
    end
end

if start_where <= 7
    % load the outcomes and send to post-task survey to reveal outcomes
    load([data_file_path sl 'food.mat'])
    food_wins = sum(nansum(task.payoff));

    load([data_file_path sl 'money.mat'])
    money_wins = sum(nansum(task.payoff));
    clear task

    script_path = ['"' directory sl 'scripts' sl 'get_food_ranks.py' '"'];

    if sum(isspace(script_path)) > 0
        script_path = ['"' script_path '"']; % if spaces in path, add ""
    end

    cmd_string = [python_path ' ' script_path ' ' qualtrics_response_id ' ' num2str(food_wins) ' ' num2str(money_wins)];
    system(cmd_string);
end

end
