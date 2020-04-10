classdef task_func
    methods(Static)
% -----------------------------------------------------------------------------
        function f = drawimage(w, A1, B1, A2, B2, A3, B3, type, state)
            if state == 1

                if type == 0
                X = A1;
                else
                X = B1;
                end

            end

            if state == 2

                if type == 0
                X = A2;
                else
                X = B2;
                end

            end

            if state == 3

                if type == 0
                X = A3;
                else
                X = B3;
                end

            end

            f = Screen('MakeTexture', w, X);
        end

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
        function f = drawspaceship(w, A1_out, A1_return, B1_out, B1_return, type, direction)
            if type == 0
                if strcmp(direction, 'out')
                    X = A1_out;
                else
                    X = A1_return;
                end
            else
                if strcmp(direction, 'out')
                    X = B1_out;
                else
                    X = B1_return;
                end
            end

            f = Screen('MakeTexture', w, X);
        end

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
        function advance_screen(input_source)
            if input_source == 1
                KbWait(input_source, 2);
            else
                RestrictKeysForKbCheck(KbName('space'));
                KbWait(input_source, 2);
            end
        end

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
        function [selection, x, y]  = selection(input_source, keys, w, rects)
            % the code below is adapted from code written by Rosa Li (Duke University)
            if input_source == 1

                  % ---- choose the rects
                  if keys(1) == KbName('LeftArrow')
                      rects_idx = 1;
                  else
                      rects_idx = 2;
                  end

                  % ---- capture useful key clicks
                  KbQueueStart(input_source);
                  useable_click = 0;
                  while useable_click == 0 %wait for click inside designated area
                      pressed = KbQueueCheck(input_source);
                      if pressed %if touched
                          [x, y, buttons] = GetMouse(w); %get touch location
                          if (x > rects{rects_idx, 1}(1) && x < rects{rects_idx, 1}(3) && y > rects{rects_idx, 1}(2) && y < rects{rects_idx, 1}(4)) %click inside chosen box
                              useable_click = 1;
                              selection_idx = 1;
                          elseif (x > rects{rects_idx, 2}(1) && x < rects{rects_idx, 2}(3) && y > rects{rects_idx, 2}(2) && y < rects{rects_idx, 2}(4))
                              useable_click = 1;
                              selection_idx = 2;
                          end %click inside chosen box
                      end %if touched
                  end %click inside a designated area

                  selection = keys(selection_idx);
                  KbQueueStop(input_source);
                  KbQueueFlush(input_source);

            else
                % ---- capture selection
                key_is_down = 0;
                FlushEvents;
                RestrictKeysForKbCheck(keys);
                [key_is_down, secs, key_code] = KbCheck(input_source);

                if length(keys) == 2
                    while key_code(keys(1)) == 0 && key_code(keys(2)) == 0
                            [key_is_down, secs, key_code] = KbCheck(input_source);
                    end
                else
                    while key_code(keys(1)) == 0
                            [key_is_down, secs, key_code] = KbCheck(input_source);
                    end
                end

                down_key = find(key_code,1);
                selection = down_key;
                x = NaN;
                y = NaN;
            end
        end

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
        function [action, choice_loc] = choice(type, keys, selection, x, y)
            if (selection==keys(1) && type == 0) || (selection==keys(2) && type == 1)
                action = 0;
            elseif (selection==keys(1) && type == 1) || (selection==keys(2) && type == 0)
                action = 1;
            end

            choice_loc = selection;
        end

% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
        function img_idx = get_img(img_idx, init, img_collect_on, w)
            if img_collect_on == 1
                imageArray = Screen('GetImage', w);
                imwrite(imageArray, [init.file_root '/tutorial_screen_' num2str(img_idx) '.jpg'], 'Quality', 50);
                img_idx = img_idx + 1;
            end
        end
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
% -----------------------------------------------------------------------------
        function [state2_color, state2_name, state3_color, state3_name] = get_planet_text(init, block_idx)
            if strcmp(char(init.stim_step2_color_select(1)), 'warm') == 1
                if strcmp(char(init.stim_colors_step2(block_idx)), 'red_blue') == 1
                    state2_color = 'red';
                    state2_name = 'Rigel';
                    state3_color = 'blue';
                    state3_name = 'Benzar';
                elseif strcmp(char(init.stim_colors_step2(block_idx)), 'orange_purple') == 1
                    state2_color = 'orange';
                    state2_name = 'Omicron';
                    state3_color = 'purple';
                    state3_name = 'Pentarus';
                else
                    state2_color = 'yellow';
                    state2_name = 'Yadera';
                    state3_color = 'green';
                    state3_name = 'Gaspar';
                end
            else
                if strcmp(char(init.stim_colors_step2(block_idx)), 'red_blue') == 1
                    state2_color = 'blue';
                    state2_name = 'Benzar';
                    state3_color = 'red';
                    state3_name = 'Rigel';
                elseif strcmp(char(init.stim_colors_step2(block_idx)), 'orange_purple') == 1
                    state2_color = 'purple';
                    state2_name = 'Pentarus';
                    state3_color = 'orange';
                    state3_name = 'Omicron';
                else
                    state2_color = 'green';
                    state2_name = 'Gaspar';
                    state3_color = 'yellow';
                    state3_name = 'Yadera';
                end
            end
        end

% -----------------------------------------------------------------------------
    end
end
