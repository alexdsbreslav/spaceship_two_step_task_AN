% Please do not share or use this code without my written permission.
% Author: Alex Breslav

function exit_flag = two_step_task(init, trials, block)

% Initial setup
format shortg
exit_flag = 0;

% find the index of the block
block_idx = find(strcmp(init.block, block));

% index for capturing screenshots
img_idx = block_idx*100;

% file set up; enables flexibility between OSX and Windows
sl = init.slash_convention;

% use the rng from the init but add 1; we don't want the outcomes to be identical to the practice
rng(init.rng_seed + 1);
rng_seed = rng;
rng_seed = rng_seed.Seed;

% Screen setup
Screen('Preference', 'SkipSyncTests', 2); % skip all sync tests; precise sitmulus timing does not matter
Screen('Preference', 'SuppressAllWarnings', 1); % suppress warnings
FlushEvents;
if init.test == 0
    HideCursor;
end
PsychDefaultSetup(1);

% open ptb window
[w, rect] = Screen('OpenWindow', init.pick_screen, [], init.screen_dimensions);
% enable transparent backgrounds for images
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% if we are starting the task from the middle, then we just want to load the structure
if isfile([init.data_file_path init.slash_convention block '.mat'])
    load([init.data_file_path init.slash_convention block '.mat']);
else
    % set up the structure to save all of the variables
    task = struct;
    task.rng_seed = rng_seed; % save the rng seed set at the top of the script
    task.subject = init.sub;
    task.stim_colors_step2 = init.stim_colors_step2(block_idx);
    task.transition_prob = 0.4 + 0.6.*rand(trials,2); %transition probabilities;
    task.transition_det = rand(trials, 2);
    task.block = block;
    task.block_idx = block_idx;
    task.spaceships = init.spaceships(block_idx+2:block_idx+3);
    task.aliens = init.aliens(block_idx+4:block_idx+7);

    % preallocate the variables that will be filled in
    task.position = NaN(trials,3);
    task.action = NaN(trials,3);
    task.click_coord = NaN(trials, 6);
    task.on = NaN(trials,3);
    task.off = NaN(trials,3);
    task.on_datetime = cell(trials,3);
    task.off_datetime = cell(trials,3);
    task.rt = task.off - task.on;
    task.payoff_det = rand(trials,4);
    task.payoff = NaN(trials,1);
    task.state = NaN(trials,1);
end

% save everything
save([init.data_file_path sl block], 'task', '-v6');

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 2 - Define image locations and stimuli used across blocks

% ---- display coordinates setup
r = [0,0,800,600]*init.scale_stim; %stimuli rectangle
r_small = [0,0,600,400]*init.scale_stim; % smaller rect for stimuli and rewards
rc_small = [0,0,600,425]*init.scale_stim;
r_space = [0,0,1920,1080]*init.scale_background;
r_ship = [0,0,400,290]*init.scale_stim;
rects = cell(2,2); % rectangles for touchscreen
r_txt_bg = [0,0,1550,75]*init.scale_stim;
r_next_button = [0,0,144,80]*init.scale_stim;

% ---- text rectangles for intro
txt_bg = CenterRectOnPoint(r_txt_bg, rect(3)*0.5, rect(4)*0.85);
txt_bg_center = CenterRectOnPoint(r_txt_bg, rect(3)*0.5, rect(4)*0.5);
next_button_loc = CenterRectOnPoint(r_next_button, rect(3)*0.95, rect(4)*0.95);

% ---- backgrounds
space_bg = CenterRectOnPoint(r_space, rect(3)*0.5, rect(4)*0.5);
spaceship_out = CenterRectOnPoint(r_ship, rect(3)*0.38, rect(4)*0.4);
spaceship_return = CenterRectOnPoint(r_ship, rect(3)*0.2, rect(4)*0.4);

% ---- locations on the win screen
alien_win = CenterRectOnPoint(r_small, rect(3)*.3, rect(4)*0.5);
treasure_win = CenterRectOnPoint(r_small, rect(3)*.7, rect(4)*0.5);
alien_lose = CenterRectOnPoint(r_small, rect(3)*.5, rect(4)*0.5);

% ---- define touchscreen rectangles to click (top/bottom)
rects{2,1} = [rect(3)*0.75 - rc_small(3)/2, rect(4)*0.25 - rc_small(4)/2, rect(3)*0.75 + rc_small(3)/2, rect(4)*0.25 + rc_small(4)/2];
rects{2,2} = [rect(3)*0.75 - rc_small(3)/2, rect(4)*0.75 - rc_small(4)/2, rect(3)*0.75 + rc_small(3)/2, rect(4)*0.75 + rc_small(4)/2];

% ---- location of the aliens
alien_Lpoint = CenterRectOnPoint(r, rect(3)*0.25, rect(4)*0.5);
alien_Rpoint = CenterRectOnPoint(r, rect(3)*0.75, rect(4)*0.5);

% ---- frames - white during every trial; green when chosen
alien_Lframe = CenterRectOnPoint(r, rect(3)*0.25, rect(4)*0.5);
alien_Rframe = CenterRectOnPoint(r, rect(3)*0.75, rect(4)*0.5);

% ---- define touchscreen rectangles to click (left/right)
rects{1,1} = [rect(3)*0.25 - r(3)/2, rect(4)*0.5 - r(4)/2, rect(3)*0.25 + r(3)/2, rect(4)*0.5 + r(4)/2];
rects{1,2} = [rect(3)*0.75 - r(3)/2, rect(4)*0.5 - r(4)/2, rect(3)*0.75 + r(3)/2, rect(4)*0.5 + r(4)/2];

% ---- read/draw the treasure and next button
treasure = imread(['stimuli' sl 'treasure.png'],'png');
return_home = imread(['stimuli' sl 'return_home.png'],'png');
[next_button, ~, alpha] = imread(['stimuli' sl 'next_button.png'],'png');
next_button(:, :, 4) = alpha;

treasure = Screen('MakeTexture', w, treasure);
return_home = Screen('MakeTexture', w, return_home);
next_button = Screen('MakeTexture', w, next_button);



% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 4 - Load and create images

% assign the indices for the stimuli that I want to pull

if block_idx == 1
    spaceship_idx = [1 2];
    alien_idx = [1 2 3 4];
elseif block_idx == 2
    spaceship_idx = [3 4];
    alien_idx = [5 6 7 8];
else
    spaceship_idx = [5 6];
    alien_idx = [9 10 11 12];
end

% --- spaceships
A1 = imread(['stimuli' sl 'spaceships' sl ...
   char(init.spaceships(spaceship_idx(1))) sl 'docked.png'],'png');
B1 = imread(['stimuli' sl 'spaceships' sl ...
   char(init.spaceships(spaceship_idx(2))) sl 'docked.png'],'png');

A1_out = imread(['stimuli' sl 'spaceships' sl ...
   char(init.spaceships(spaceship_idx(1))) sl 'out.png'],'png');
A1_return = imread(['stimuli' sl 'spaceships' sl ...
   char(init.spaceships(spaceship_idx(1))) sl 'return.png'],'png');

B1_out = imread(['stimuli' sl 'spaceships' sl ...
   char(init.spaceships(spaceship_idx(2))) sl 'out.png'],'png');
B1_return = imread(['stimuli' sl 'spaceships' sl ...
   char(init.spaceships(spaceship_idx(2))) sl 'return.png'],'png');

% ---- aliens
A2 = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl char(init.stim_step2_color_select(1)) sl ...
  char(init.aliens(alien_idx(1))) '.png'],'png');
B2 = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl char(init.stim_step2_color_select(1)) sl ...
  char(init.aliens(alien_idx(2))) '.png'],'png');

A3 = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl char(init.stim_step2_color_select(2)) sl ...
  char(init.aliens(alien_idx(3))) '.png'],'png');
B3 = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl char(init.stim_step2_color_select(2)) sl ...
  char(init.aliens(alien_idx(4))) '.png'],'png');

% read and draw background stimuli
space = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl 'space.png'],'png');
planet_home = imread(['stimuli' sl 'home_planet.png'],'png');
planet_2 = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl char(init.stim_step2_color_select(1)) sl 'planet.png'],'png');
planet_3 = imread(['stimuli' sl 'aliens' sl char(init.stim_colors_step2(block_idx)) sl char(init.stim_step2_color_select(2)) sl 'planet.png'],'png');

space = Screen('MakeTexture', w, space);
planet_home = Screen('MakeTexture', w, planet_home);
planet_2 = Screen('MakeTexture', w, planet_2);
planet_3 = Screen('MakeTexture', w, planet_3);
[state2_color, state2_name, state3_color, state3_name] = task_func.get_planet_text(init, block_idx);

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 6 - Additional set up
% ---- Keyboard
KbName('UnifyKeyNames');
L = KbName('LeftArrow');
R = KbName('RightArrow');
U = KbName('UpArrow');
D = KbName('DownArrow');

% ---- Colors
black = 0;
white = [253 252 250];
chosen_color = [0 220 0];
frame_color = white;

% ---- Waiting screen
Screen('FillRect', w, black);
Screen('TextSize', w, init.textsize);

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% intro screen for practice block
if strcmp(block,'practice')
    DrawFormattedText(w,[
        'Let''s practice!' '\n\n' ...
         'You will have ' num2str(trials) ' days to explore this galaxy.' '\n' ...
        'When you are ready, press SPACE to start the training quest.'...
        ], 'center','center', white, [], [], [], 1.6);
    Screen('DrawTexture', w, next_button, [], next_button_loc);
    Screen('Flip',w); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
    task_func.advance_screen(init.input_source)
else
    % intro screens for food and money blocks
    if init.trials_start(block_idx) == 1 % only show the into screens if we're starting from trial 1
        type = 0;
        picL = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,type,1);
        picR = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,1-type,1);

        DrawFormattedText(w,[
            'Welcome back Space Captain,' '\n\n' ...
            'We are sending you on a ' num2str(trials) ' day quest to' '\n' ...
            'find as much space treasure as you can.' ...
            ], 'center','center', white, [], [], [], 1.6);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        DrawFormattedText(w,[
            'At the end of the study you will trade the treasure' '\n' ...
            'that you win during this quest for ' upper(block) ' rewards.'
            ], 'center','center', white, [], [], [], 1.6);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        Screen('DrawTexture', w, planet_home, [], space_bg);
        Screen('DrawTexture', w, picL, [], alien_Lpoint);
        Screen('DrawTexture', w, picR, [], alien_Rpoint);
        Screen('FrameRect',w,frame_color,alien_Lframe,10);
        Screen('FrameRect',w,frame_color,alien_Rframe,10);
        Screen('FillRect', w, black, txt_bg);
        DrawFormattedText(w,[
            'We have given you two new spaceships to explore a new galaxy.'
            ],'center','center', white, [], [], [], 1.6, [], txt_bg);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        Screen('DrawTexture', w, space, [], space_bg);
        Screen('FillRect', w, black, txt_bg_center);
        DrawFormattedText(w,[
            'This galaxy is home to Planet ' state2_name ' and Planet ' state3_name '.' ...
            ], 'center','center', white, [], [], [], 1.6);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        picL = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,type,2);
        picR = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,1-type,2);

        Screen('DrawTexture', w, planet_2, [], space_bg);
        Screen('DrawTexture', w, picL, [], alien_Lpoint);
        Screen('DrawTexture', w, picR, [], alien_Rpoint);
        Screen('FrameRect',w,white,alien_Lframe,10);
        Screen('FrameRect',w,white,alien_Rframe,10);
        Screen('FillRect', w, black, txt_bg);
        DrawFormattedText(w,[
            'The ' state2_color ' aliens live on Planet ' state2_name '.'...
            ],'center','center', white, [], [], [], 1.6, [], txt_bg);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        picL = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,type,3);
        picR = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,1-type,3);

        Screen('DrawTexture', w, planet_3, [], space_bg);
        Screen('DrawTexture', w, picL, [], alien_Lpoint);
        Screen('DrawTexture', w, picR, [], alien_Rpoint);
        Screen('FrameRect',w,white,alien_Lframe,10);
        Screen('FrameRect',w,white,alien_Rframe,10);
        Screen('FillRect', w, black, txt_bg);
        DrawFormattedText(w,[
            'The ' state3_color ' aliens live on Planet ' state3_name '.'...
            ],'center','center', white, [], [], [], 1.6, [], txt_bg);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        DrawFormattedText(w,[
            'Remember your training, Space Captain!' '\n' ...
            'All of the rules from the training quest are the same in this quest.' ...
            ],'center','center', white, [], [], [], 1.6);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen('Flip',w);
        WaitSecs(init.pause_to_read); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        task_func.advance_screen(init.input_source);

        DrawFormattedText(w,[
            'Before you start your quest, what questions do you have for ' init.researcher '?' ...
            ],'center','center', white, [], [], [], 1.6);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen(w, 'Flip'); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        WaitSecs(init.pause_to_read);
        task_func.advance_screen(init.input_source);

        DrawFormattedText(w,[
            'When you are ready, press SPACE to start the quest.' ...
            ],'center','center', white, [], [], [], 1.6);
        Screen('DrawTexture', w, next_button, [], next_button_loc);
        Screen(w, 'Flip'); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
        WaitSecs(init.pause_to_read);
        task_func.advance_screen(init.input_source);
    else
      DrawFormattedText(w,[
          'When you are ready, press SPACE to restart your quest.' '\n'...
          'You will start right where you left off!' '\n'...
          ],'center','center', white, [], [], [], 1.6);
      Screen('DrawTexture', w, next_button, [], next_button_loc);
      Screen(w, 'Flip'); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
      WaitSecs(init.pause_to_read);
      task_func.advance_screen(init.input_source);
    end
end
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 8 - Begin trials
t0 = GetSecs;
for trial = init.trials_start(block_idx):trials

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 9.1 - Stage 1
% ---- Signal a short break every 30 trials
    RestrictKeysForKbCheck([]);
    if (trial == (trials/5) + 1 || trial == (2*trials/5) + 1 || trial == (3*trials/5) + 1 || trial == (4*trials/5) + 1) && trial ~= init.trials_start(block_idx)
        Screen('FillRect', w, black);
        Screen('TextSize', w, init.textsize);
        DrawFormattedText(w, [
            'Let''s pause the game and take a short break!' '\n' ...
            'After the break, you will restart the quest right where you left off.' '\n\n' ...
            'When you are ready, press SPACE to get back to your quest!' ...
            ],'center', 'center', white, [], [], [], 1.6);
        Screen(w, 'Flip');
        task_func.advance_screen(init.input_source)
    end

    % ---- Drawimage indicators
    Screen(w, 'FillRect', black);
    Screen('TextSize', w, init.textsize_feedback);
    task.position(trial,1) = round(rand); %randomizing images positions
    type = task.position(trial,1);

    % ---- Draw original stimuli using a function that Arkady wrote: drawimage
    picL = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,type,1);
    picR = task_func.drawimage(w, A1, B1, A2, B2, A3, B3,1-type,1);

    % ---- Draw trial screen
    % draw background
    Screen('DrawTexture', w, planet_home, [], space_bg);
    % draw original stimuli
    Screen('DrawTexture', w, picL, [], alien_Lpoint);
    Screen('DrawTexture', w, picR, [], alien_Rpoint);
    % draw frames around original stimuli
    Screen('FrameRect',w,frame_color,alien_Lframe,10);
    Screen('FrameRect',w,frame_color,alien_Rframe,10);
    Screen('Flip', w);

    % ---- start reaction timer
    task.on(trial,1) = GetSecs - t0;
    task.on_datetime{trial,1} = clock;

    % ---- capture key press
    [selection, x, y] = task_func.selection(init.input_source, [L,R], w, rects);
    task.click_coord(trial, 1) = x;
    task.click_coord(trial, 2) = y;

    % ---- stop reaction timer
    task.off(trial,1) = GetSecs - t0;
    task.off_datetime{trial,1} = clock;
    task.rt(trial, 1) = task.off(trial,1) - task.on(trial,1);

    % ---- capture selection
    [task.action(trial,1), choice_loc] = task_func.choice(type, [L,R], selection, x, y);

    % ---- feedback screen
    if choice_loc == L
        % draw background
        Screen('DrawTexture', w, planet_home, [], space_bg);
        % draw original stimuli
        Screen('DrawTexture', w, picL, [], alien_Lpoint);
        Screen('DrawTexture', w, picR, [], alien_Rpoint);
        % draw frames around original stimuli
        Screen('FrameRect',w,chosen_color,alien_Lframe,10);
        Screen('FrameRect',w,frame_color,alien_Rframe,10);
        Screen('Flip', w);

    elseif choice_loc == R
       % draw background
       Screen('DrawTexture', w, planet_home, [], space_bg);
       % draw original stimuli
       Screen('DrawTexture', w, picL, [], alien_Lpoint);
       Screen('DrawTexture', w, picR, [], alien_Rpoint);
       % draw frames around original stimuli
       Screen('FrameRect',w,frame_color,alien_Lframe,10);
       Screen('FrameRect',w,chosen_color,alien_Rframe,10);
       Screen('Flip', w);

    end

    % ---- wait 1 second on the feedback screen
    WaitSecs(init.feedback_time);

    % ---- space exploration page
    Screen('DrawTexture', w, space, [], space_bg);
    ship = task_func.drawspaceship(w, A1_out, A1_return, B1_out, B1_return, task.action(trial,1), 'out');
    Screen('DrawTexture', w, ship, [], spaceship_out);
    Screen('Flip', w);
    WaitSecs(init.explore_time);


    % ---- Determine the state for the second state
    % ---- task.transition_prob ~ U[0.4,1]
    % ---- task.transition_det ~ U[0,1]
    % ---- p(r < task.transition_prob) = 0.70
    % ---- p(r > task.transition_prob) = 0.30
    % ---- If we discretize the task.transition_prob distribution, remember that there is a 1/7
    % ---- chance of task.transition_prob taking the any value [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

    if task.action(trial,1) == 0
        if  task.transition_det(trial, 1) < task.transition_prob(trial,1)
            task.state(trial,1) = 2;
        else task.state(trial,1) = 3;
        end
    else
        if  task.transition_det(trial, 2) > task.transition_prob(trial,2)
            task.state(trial,1) = 2;
        else task.state(trial,1) = 3;
        end
    end

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 9.2A State 2

    if task.state(trial,1) == 2

    % ---- Randomize the left/right position of the original stimuli
        Screen(w, 'FillRect', black);
        task.position(trial,2) = round(rand);
        type = task.position(trial,2);

    % ---- Draw original stimuli using a function that Arkady wrote: drawimage
        picL = task_func.drawimage(w, A1, B1, A2, B2, A3, B3, type,2);
        picR = task_func.drawimage(w, A1, B1, A2, B2, A3, B3, 1-type,2);

    % ---- Draw trial screen
        % draw background
        Screen('DrawTexture', w, planet_2, [], space_bg);
        % draw original stimuli
        Screen('DrawTexture', w, picL, [], alien_Lpoint);
        Screen('DrawTexture', w, picR, [], alien_Rpoint);
        % draw frames around original stimuli
        Screen('FrameRect',w,white,alien_Lframe,10);
        Screen('FrameRect',w,white,alien_Rframe,10);

        Screen('Flip', w);

    % ---- start reaction timer
        task.on(trial,2) = GetSecs - t0;
        task.on_datetime{trial,2} = clock;

    % ---- capture key press
        [selection, x, y] = task_func.selection(init.input_source, [L,R], w, rects);
        task.click_coord(trial, 3) = x;
        task.click_coord(trial, 4) = y;

    % ---- stop reaction timer
        task.off(trial,2) = GetSecs - t0;
        task.off_datetime{trial,2} = clock;
        task.rt(trial, 2) = task.off(trial,2) - task.on(trial,2);

    % ---- capture selection and determine payoff
        [task.action(trial,2), choice_loc] = task_func.choice(type, [L,R], selection, x, y);

        if task.action(trial,2) == 0
            if task.payoff_det(trial, 1) <  init.payoff_prob(trial,1)
                task.payoff(trial,1) = 1;
            else
                task.payoff(trial,1) = 0;
            end
        elseif task.action(trial,2) == 1
            if task.payoff_det(trial, 2) <  init.payoff_prob(trial,2)
                task.payoff(trial,1) = 1;
            else
                task.payoff(trial,1) = 0;
            end
        end

    % ---- feedback screen
    if choice_loc == L
          % draw background
          Screen('DrawTexture', w, planet_2, [], space_bg);
          % draw original stimuli
          Screen('DrawTexture', w, picL, [], alien_Lpoint);
          Screen('DrawTexture', w, picR, [], alien_Rpoint);
          % draw frames around original stimuli
          Screen('FrameRect',w,chosen_color,alien_Lframe,10);
          Screen('FrameRect',w,white,alien_Rframe,10);
          Screen('Flip', w);
          % wait 1 second
          WaitSecs(init.feedback_time);

        elseif choice_loc == R
          % draw background
          Screen('DrawTexture', w, planet_2, [], space_bg);
          % draw original stimuli
          Screen('DrawTexture', w, picL, [], alien_Lpoint);
          Screen('DrawTexture', w, picR, [], alien_Rpoint);
          % draw frames around original stimuli
          Screen('FrameRect',w,white,alien_Lframe,10);
          Screen('FrameRect',w,chosen_color,alien_Rframe,10);
          Screen('Flip', w);
          % wait 1 second
          WaitSecs(init.feedback_time);
     end

        % ---- payoff screen
        % ---- show feedback
        picD = task_func.drawimage(w, A1, B1, A2, B2, A3, B3, task.action(trial,2),2);
        if task.payoff(trial,1) == 1
            Screen('DrawTexture', w, picD, [], alien_win);
            Screen('DrawTexture', w, treasure, [], treasure_win);
            DrawFormattedText(w, 'Win!', 'center', rect(4)*0.8, white);
        else
            Screen('DrawTexture', w, picD, [], alien_lose);
            DrawFormattedText(w, 'Lose', 'center', rect(4)*0.8, white);
        end
        Screen('Flip', w);
        WaitSecs(init.feedback_time);

    % -----------------------------------------------------------------------------
    % -----------------------------------------------------------------------------
    % -----------------------------------------------------------------------------
    % -----------------------------------------------------------------------------
    % State 3
    else

    % Randomize the left/right position of the original stimuli
        Screen(w, 'FillRect', black);
        task.position(trial,3) = round(rand);
        type = task.position(trial,3);

    % ---- Draw original stimuli using a function that Arkady wrote: drawimage
        picL = task_func.drawimage(w, A1, B1, A2, B2, A3, B3, type,3);
        picR = task_func.drawimage(w, A1, B1, A2, B2, A3, B3, 1-type,3);

    % ---- Draw trial screen
        % draw background
        Screen('DrawTexture', w, planet_3, [], space_bg);
        % draw original stimuli
        Screen('DrawTexture', w, picL, [], alien_Lpoint);
        Screen('DrawTexture', w, picR, [], alien_Rpoint);
        % draw frames around original stimuli
        Screen('FrameRect',w,white,alien_Lframe,10);
        Screen('FrameRect',w,white,alien_Rframe,10);

        Screen('Flip', w);

    % ---- start reaction timer
        task.on(trial,3) = GetSecs - t0;
        task.on_datetime{trial,3} = clock;

    % ---- capture key press
        [selection, x, y] = task_func.selection(init.input_source, [L,R], w, rects);
        task.click_coord(trial, 5) = x;
        task.click_coord(trial, 6) = y;

    % ---- stop reaction timer
        task.off(trial,3) = GetSecs - t0;
        task.off_datetime{trial,3} = clock;
        task.rt(trial, 3) = task.off(trial,3) - task.on(trial,3);

    % ---- capture selection and determine payoff
        [task.action(trial,3), choice_loc] = task_func.choice(type, [L,R], selection, x, y);

        if task.action(trial,3) == 0
            if task.payoff_det(trial, 3) <  init.payoff_prob(trial,3)
                task.payoff(trial,2) = 1;
            else
                task.payoff(trial,2) = 0;
            end
        elseif task.action(trial,3) == 1
            if task.payoff_det(trial, 4) <  init.payoff_prob(trial,4)
                task.payoff(trial,2) = 1;
            else
                task.payoff(trial,2) = 0;
            end
        end

    % ---- feedback screen
        if choice_loc == L
          % draw background
          Screen('DrawTexture', w, planet_3, [], space_bg);
          % draw original stimuli
          Screen('DrawTexture', w, picL, [], alien_Lpoint);
          Screen('DrawTexture', w, picR, [], alien_Rpoint);
          % draw frames around original stimuli
          Screen('FrameRect',w,chosen_color,alien_Lframe,10);
          Screen('FrameRect',w,white,alien_Rframe,10);
          Screen('Flip', w);
          % wait 1 second
          WaitSecs(init.feedback_time);

        elseif choice_loc == R
          % draw background
          Screen('DrawTexture', w, planet_3, [], space_bg);
          % draw original stimuli
          Screen('DrawTexture', w, picL, [], alien_Lpoint);
          Screen('DrawTexture', w, picR, [], alien_Rpoint);
          % draw frames around original stimuli
          Screen('FrameRect',w,white,alien_Lframe,10);
          Screen('FrameRect',w,chosen_color,alien_Rframe,10);
          Screen('Flip', w);
          % wait 1 second
          WaitSecs(init.feedback_time);
        end

    % ---- payoff screen
    % ---- determine second step choice
        picD = task_func.drawimage(w, A1, B1, A2, B2, A3, B3, task.action(trial,3),3);
        if task.payoff(trial,2) == 1
            Screen('DrawTexture', w, picD, [], alien_win);
            Screen('DrawTexture', w, treasure, [], treasure_win);
            DrawFormattedText(w, 'Win!', 'center', rect(4)*0.8, white);
        else
            Screen('DrawTexture', w, picD, [], alien_lose);
            DrawFormattedText(w, 'Lose', 'center', rect(4)*0.8, white);
        end
        Screen('Flip', w);
        WaitSecs(init.feedback_time);
    end % close the if/else for state

    % ---- Return Home Screen
    Screen('TextSize', w, init.textsize);
    Screen('DrawTexture', w, return_home, [], space_bg);
    ship = task_func.drawspaceship(w, A1_out, A1_return, B1_out, B1_return, task.action(trial,1), 'return');
    Screen('DrawTexture', w, ship, [], spaceship_return);
    DrawFormattedText(w, [
        'Returning home!' ...
        ], 'center', 'center', white, [], [], [], 1.6);
    Screen('Flip', w);
    WaitSecs(init.explore_time);
    % saving the data every trial
    save([init.data_file_path sl block], 'task', '-v6');

end % close the entire for loop
RestrictKeysForKbCheck([]);

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 9 - final save of the data
save([init.data_file_path sl block], 'task', '-v6');

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% 9 - Payoff screens
% ---- Practice block end screens
if strcmp(block,'practice')
    Screen('TextSize', w, init.textsize);
    Screen(w, 'FillRect', black);
    DrawFormattedText(w,[
        'Congratulations Space Captain, you are done with the training quest!' '\n'...
        'Please tell ' init.researcher ' that you are done with the training quest.' ...
        ],'center','center', white, [], [], [], 1.6);
    Screen('DrawTexture', w, next_button, [], next_button_loc);
    Screen(w, 'Flip'); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
    WaitSecs(init.pause_to_read);
    task_func.advance_screen(init.input_source);
else
    Screen('TextSize', w, init.textsize);
    Screen(w, 'FillRect', black);
    Screen('DrawTexture', w, treasure, [], CenterRectOnPoint(r_small, rect(3)*.5, rect(4)*0.3));
    DrawFormattedText(w, [
        'Congratulations Space Captain, you finished your quest!' '\n\n' ...
        'You collected ' num2str(sum(nansum(task.payoff))) ' pieces of treasure.' '\n' ...
        'At the end, you will trade your ' num2str(sum(nansum(task.payoff))) ' pieces' '\n' ...
        'of treasure for ' upper(block) ' rewards.' '\n\n' ...
        'Please tell ' init.researcher ' that you completed the quest.' ...
        ], 'center', rect(4)*0.5, white, [], [], [], 1.6);
    Screen('DrawTexture', w, next_button, [], next_button_loc);
    Screen(w, 'Flip'); img_idx = task_func.get_img(img_idx, init, init.img_collect_on, w);
    WaitSecs(init.pause_to_read);
    task_func.advance_screen(init.input_source)
end

ShowCursor;
Screen('CloseAll');
FlushEvents;

end
