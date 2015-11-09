function umpire
%% umpire - Reversi written by Jake Dixon for eg1002. the game  runs inside
% a gui that is designed to be clean and elegant featuring an ai that can
% be toggled, a hint function and the ability to pit the ai against
% another. version 1.019.58 (built 19.06.13)

clear all;                      %clears everything (may run slow otherwise)
fig = figure('name','Written by Jake Dixon','color',[1 1 1],...
    'Menubar','none','numbertitle','off');          % sets up the figure window.

set(fig,'ResizeFcn',@resize_callback);              % instant resize

%% - sets up the menubar
topbar = uimenu(fig,'Label','Reversi'); % creates a new menu bar named opt
new_game = uimenu(topbar,'label','New game','callback',@newGame);% % newgame
high_scores = uimenu(topbar,'label','High Score','callback',@highScore);
ai_on = uimenu(topbar,'label','AI on','callback',@ai_on_toggle,...
    'checked','on');            % % ai toggle button in menu
Hint_Button = uimenu(topbar,'label','Hint on','callback',@Hint,...
    'checked','off');           % % hint toggle button in menu
bot_vs_bot = uimenu(topbar,'label','Spectate','callback',@botvsbot,...
    'checked','off');          % disabled... does not work properly
about_button = uimenu(topbar,'label','About','callback',@About...
    );                          % % about button in menu... displays info.
exit = uimenu(topbar,'label','Exit','callback',@Exitbutton); % % closes window

%% - sets up the board and default toggle values
ai_toggle = 1;                  % default value for ai toggle (on by def)
hint_toggle = 0;                % default value for hint toggle (off)
bgmusic = 0;                    % background music default toggle
gameisover = 0;                 % game is over toggle
botvsbot_toggle = 0;            % 0player toggle
bot2handle = @bot2;             % 2nd bot handle
board = zeros(8,8);             % inital board setup

if randi([1 2],1) == 1          % sets initial peices randomly
    board(29) = 1;
    board(28) = -1;
    board(36) = 1;
    board(37) = -1;
else
    board(29) = -1;
    board(28) = 1;
    board(36) = -1;
    board(37) = 1;
end

%% - sets up the buttons displayes and player values and scores
buttons = zeros(8,8);           % initial buttons setup
new_game_button = uicontrol('units','normalized','position',...
    [0.403,0.008,0.194,0.08],'string','New Game','callback',@newGame,...
    'Fontsize',10.0,'Fontweight','bold','fontunits',...
    'normalized');   % % new game button

player = 1;                     % default player value
red = 0;                        % initial buttons
blue = 0;                       % initial buttons
wld = [0 0 0];                  % initial win loss draw values
b1 = 0;

% loads pictures
button_pic = imread(fullfile('resources','buttons.ycr'));
pic_x = button_pic(1:500,1:500,1:3);
pic_o = button_pic(500:1000,1:500,1:3);
pic_blank = button_pic(1:2,1:2,1:3);

%% - sets up the background
% This creates the 'background' axes
background = axes('units','normalized', ...
    'position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(background,'bottom');

% Load in a background image and display it using the correct colors
woodgrain=imread(fullfile('resources','background.jpg'));
imagesc(woodgrain);
colormap gray

% Turn the handlevisibility off so that we don't inadvertently plot into the axes again
% Also, make the axes invisible
set(background,'handlevisibility','off', ...
    'visible','off')

% Now we can use the figure
axes('position',[0.3,0.35,0.4,0.4])

% sounds       % background music file
win_sound = wavread(fullfile('resources','tada.wav'));                % win file
win_player = audioplayer(win_sound, 44000);
new_game_sound = wavread(fullfile('resources','new_game.wav'));
new_game_player = audioplayer(new_game_sound, 44100);

%% - sets up the text displayed on screen
Title = text('string', 'Reversi' , 'position', [.300 1.511 9.16],...
    'color',[1 1 1],'FontName','Magneto','FontSize',...
    16.0','fontunits','normalized');    % % sets title text
Num_of_o = text('units','normalized','position',[-0.369 1.511 0],...
    'string',sprintf('Blue: %i',blue),'FontSize',12.0,'FontWeight',...
    'bold','color',[0 1 1],'fontunits','normalized');% sets number of blue text
Num_of_x = text('units','normalized','position',[1.167 1.511 0],...
    'string',sprintf('Red: %i',red),'FontSize',12.0,'FontWeight',...
    'bold','color',[1 0 0],'fontunits','normalized');
currentWLD = text('units','normalized','position',[1.043 -0.738 0],...
    'string',sprintf('Red - %i   Blue - %i\n        Draw - %i',wld),'FontSize',9.0,'FontWeight',...
    'bold','color',[1 1 1],'fontunits','normalized');% sets number of red text
currentPlayer = text('units','normalized','position',[-0.43 -0.732 0],...
    'string','Reds','FontSize',9.0,'FontWeight',...
    'bold','color',[1 0 0],'fontunits','normalized');% sets current player text
%% - draws the buttons initially

for count_i = 1:8           % draws buttons and scales them to size
    for count_j = 1:8
        buttons(count_i,count_j) = uicontrol('units','normalized',...
            'position',[0.1 * (count_i-1)+0.1, 0.1 * ((8-count_j))+0.1, 0.1, 0.1], ...
            'userdata', 8 * (count_j-1) + count_i,...
            'callback', @buttonPress,'backgroundcolor',[.9 .9 .9]);
    end
end
play(new_game_player);
drawScreen();

% callbacks
    function buttonPress(hObject, ~)
        %% main unpire function, this function controlls the game rules
        % along with how the ai operates and all 3 player types
        
        [p1, p2] = does_player_pass(board); % checks to see if a player
        % needs to pass first
        if p1 == 1                          % if player 1 doesnt pass
            if botvsbot_toggle == 1         % checks if its 0player
                player_move = [0 0];
                player_move = bot2handle(board,1,1);% calls bot
            else                            % else its grabs players move
                player_move = get(hObject,'userdata');
                temp = board;           % the following code converts from
                temp(player_move) = 5;  % linear indexing
                [y x] = find(temp == 5);
                player_move = [0 0];
                player_move(1) = y;
                player_move(2) = x;
            end
            
            [r,~,board] = move_is_valid(board,player_move,player);% flips peices
            if r == 1   % checks for valid move
                if botvsbot_toggle == 0
                    board(get(hObject,'userdata')) = player; % places move
                else
                    board(player_move(1),player_move(2)) = 1;% places move
                end
                if ai_toggle == 0
                    player = player * -1;           % if ai is off changes player
                else
                end
                
                drawScreen();                       % draws the screen
                [~,y] = does_player_pass(board);    % checks if p2 passes
                if y == 1
                    if ai_toggle == 1
                        drawnow();
                        player = 1;                 % makes sure player is 1
                        setAllInactive();
                        ai_move = jc259368_bot(board,-1,1);% ai move
                        board(ai_move(1),ai_move(2)) = -1; % ai move
                        [~, ~, board] = move_is_valid(board,ai_move,-1);% flips
                        drawScreen();               % draws the screen
                    else
                    end
                else
                    player = 1;
                end
            else
                set(currentPlayer,'string','Invalid move',...
                    'color',[1 1 1]);
            end
        elseif p2==1        % same as player 2 above just used for errors
            if ai_toggle == 0
                player = player*-1;
            else
                drawnow();
                player = 1;
                setAllInactive();
                ai_move = jc259368_bot(board,-1,1);
                board(ai_move(1),ai_move(2)) = -1;
                [~, ~, board] = move_is_valid(board,ai_move,-1);
                drawScreen();
            end
        end
        [p1,p2] = does_player_pass(board);  %checks for moves
        if p1==0 && p2==0                   % if cond met game is over
            gameisover = 1;
            winner = calculate_winner(board);
            winner_string = {'Player Blue won!','Game is a draw!',...
                'Player Red won!'};
            set(currentPlayer,'string',winner_string(winner + 2),...
                'color',[1 1 1]);
            setAllInactive();
            if winner == 1
               % pause(background_player);
                play(win_player);   % win sound played
                wld(1) = wld(1) + 1;
                load(fullfile('resources','highscore.mat'));
                high = cell2mat(highscore(2)); %#ok<NODEF>
                if high < red
                    name = inputdlg('New High score, please enter your name',...
                        'Name',1);
                    highscore(2) =  {red};
                    highscore(1) = name; %#ok<*NASGU>
                    save(fullfile('resources','highscore'),'highscore');
                else
                end
            elseif winner == -1
                %stop(background_player);
                play(win_player); % win sound
                wld(2) = wld(2) + 1;
            else
                wld(3) = wld(3) + 1;
            end
            set(currentWLD,'string',sprintf('Red - %i   Blue - %i\n        Draw - %i',...
                wld));
        else
        end
        if botvsbot_toggle == 0 % this code is special featues only available in 1p or 2p
            if get(hObject,'userdata')==1   % thanks nick
                b1 = b1 + 1;
                if b1 == 20
                    pic_x = button_pic(1000:1500,1:500,1:3);
                    set(Title,'string','Bronversi');
                    drawScreen();
                    
                end
            end
            
            if p1 == 0 && p2 == 1     % makes the button press loop if red still
                buttonPress(hObject,1);% cant make a move
                
            end
        else
        end
        
        if botvsbot_toggle == 1 && gameisover ~= 1      % this continues loop for bots
            buttonPress(buttons,1);% recalls function if botvbot
        end
        if p1 == 0 && p2 == 1 && gameisover ~=1 &&botvsbot_toggle == 1    % makes the button press loop if red still
            buttonPress(buttons,1);% cant make a move
        end
        
        
        function [valid_red valid_blue] = does_player_pass(board)
            %% sub-sub function determine who will pass
            
            blu = zeros(8,8);   %sets a grid for both players
            rd = zeros(8,8);
            for z = 1:8
                for y = 1:8 %#ok<FXUP>
                    rd(y,z) = move_is_valid(board,[y z],1);% finds valid moves for red
                    blu(y,z) = move_is_valid(board,[y z],-1);% finds valid moves for bluw
                end
            end
            a = find(blu == 1, 1); % finds if there are valid moves
            b = find(rd == 1, 1);  % finds if there are valid moves
            if isempty(a)   %if there arent any valid moves for blue
                valid_blue = 0;      % blue passes
            else
                valid_blue = 1;      %else the game continues
            end
            if isempty(b)
                valid_red = 0;          % same for red
            else
                valid_red = 1;
            end
        end
        
    end

    function newGame(~, ~)
        %% newgame - new game callback prompts to reset scores or not and
        % resets the game board.
        b1 = 0;                 % rsets
        gameisover = 0;         % resets
        botvsbot_toggle = 0;    % resets
        bot2handle = @bot2;     % resets
        yn = questdlg('Wold you like to reset scores?','New Game',...
            'Yes','No','No');   % prompts to reset socres
        if strcmp(yn,'No')==1   % if no then just resets the board
            set(bot_vs_bot, 'Checked', 'off');   % turns off bot v bot
            for i = 1:8
                for j = 1:8
                    board = zeros(8,8);
                    if randi([1 2],1) == 1
                        board(29) = 1;
                        board(28) = -1;
                        board(36) = 1;
                        board(37) = -1;
                    else
                        board(29) = -1;
                        board(28) = 1;
                        board(36) = -1;
                        board(37) = 1;
                    end
                    
                    player = 1;         % makes sure player 1 is human
                    play(new_game_player);
                    drawScreen();       % draws screen
                end
            end
        else                        % else resets scores
            set(bot_vs_bot, 'Checked', 'off');
            for i = 1:8
                for j = 1:8
                    board = zeros(8,8);
                    if randi([1 2],1) == 1
                        board(29) = 1;
                        board(28) = -1;
                        board(36) = 1;
                        board(37) = -1;
                    else
                        board(29) = -1;
                        board(28) = 1;
                        board(36) = -1;
                        board(37) = 1;
                    end
                end
            end
            wld = [0 0 0];  % score reset
            set(currentWLD,'string',sprintf('Red - %i   Blue - %i\n        Draw - %i',wld));
            player = 1;
            play(new_game_player);
            drawScreen();
        end
       
    end

    function Hint(~, ~)
        %% hint function.... change background color of possibe move to player
        % color
        
        if strcmp(get(gcbo, 'Checked'),'off')   % toggle option
            set(gcbo, 'Checked', 'on');         % changes toggle
            hint_toggle = 1;                    % hint on
            drawScreen();                       % draws screen
        else
            set(gcbo,'Checked','off');          % changes toggle
            hint_toggle = 0;                    % hint off
            drawScreen();                       % draws screen
        end
        
    end

    function About(~, ~)
        %% about - displays reversi information
        
        msgbox('Reversi written by Jake Dixon for EG1002. for a list of reversi rules visit: http://www.flyordie.com/games/help/reversi/en/games_rules_reversi.html','About','help');
    end

    function ai_on_toggle(~, ~)
        %% ai toggle function - toggles weather or not the ai is playing
        % alos adjusts game to make sure that if the ai is turned on no
        % illegal moves are made and that the ai is always 2nd player
        
        if strcmp(get(gcbo, 'Checked'),'on')    %changes toggle from on to
            set(gcbo, 'Checked', 'off');        % off and continues game
            ai_toggle = 0;
            
        else
            set(gcbo, 'Checked', 'on');         % changes ai back to on
            ai_toggle = 1;                      % also avoids illegal moves
            if player == -1                     % by making the ai take a move
                player = 1;                     % if it is blue playes go.
                drawnow();
                set(currentPlayer,'string','blue players go','color',[0 0 1]);
                setAllInactive();
                ai_move = jc259368_bot(board,-1,1);
                board(ai_move(1),ai_move(2)) = -1;
                [~, ~, board] = move_is_valid(board,ai_move,-1);
                if game_is_over(board)
                    winner = calculate_winner(board);
                    winner_string = {'Player Blue won!','Game is a draw!','Player Red won!'};
                    set(currentPlayer,'string',winner_string(winner + 2),'color',[0 0 0]);
                    setAllInactive()
                    if winner == 1
                        wld(1) = wld(1) + 1;
                    elseif winner == -1
                        %wld(2) = wld(2) +1;
                    else
                        wld(3) = wld(3) +1;
                    end
                    set(currentWLD,'string',sprintf('Red - %i   Blue - %i\n        Draw - %i',wld));
                end
                drawScreen();
            else
            end
            
        end
    end

    function botvsbot(~, ~)
        %% bot vs bot function. askes for 2nd bot then proceeds to play the
        %game till either of them win.
        
        
        if strcmp(get(gcbo, 'Checked'),'off');
            set(gcbo, 'Checked', 'on');
            seccondbot = uigetfile('*.m','Open bot file');  % lets you select 2nd bot file
            botvsbot_toggle = 1;
            if seccondbot==0                    % if no bot file was selected disregardes
                set(gcbo, 'Checked', 'off');    % bot v bot function and continues
                botvsbot_toggle = 0;
            else
                matches = regexp(seccondbot, '^(jc\d{6}_bot)\.m$',...
                    'tokens');          % makes sure bot matches asssingment specs
                if isempty(matches)     % spits out error if it doesnt match
                    set(gcbo, 'Checked', 'off');
                    botvsbot_toggle = 0;
                    errordlg('The file you selected does not match the assignment specifications and therefore has been rejected. please select a correctly formatted file',seccondbot)
                else
                    bot2handle = str2func(seccondbot(1:end-2)); % converts 2nd bot to a function
                    set(ai_on, 'Checked', 'on');
                    ai_toggle = 1;                              % makes sure ai is on
                    buttonPress(buttons,1);                     % starts loop
                end
            end
            
            
        else strcmp(get(gcbo, 'checked'),'on'); % toggles bot v bot off
            set(gcbo,'checked','off');
            botvsbot_toggle = 0;
            drawScreen();
        end
    end

    function highScore(~, ~)
        %% displays the high score.
        
        file = load(fullfile('resources','highscore.mat'));
        name = cell2mat(file.highscore(1));
        number = cell2mat(file.highscore(2));
        hgh = figure('position',[500 500 350 100],'color',...
            [.9 .9 .9],'name','High Score','menubar','none','numbertitle','off',...
            'resize','off'); %#ok<NASGU>
        score = uicontrol('units','normalized','position',...
            [0.060,0.59,0.849,0.228],'string',sprintf('held by %s with a score of %i',name,number),'style','text',...
            'backgroundcolor',[.9 .9 .9]); %#ok<NASGU>
        Ok = uicontrol('units','normalized','position',...
            [0.234,0.24,0.234,0.228],'string','ok','callback',@Okbutton,...
            'Fontsize',10.0);   %#ok<NASGU> % ok button
        Clear = uicontrol('units','normalized','position',...
            [0.48,0.24,0.234,0.228],'string','Clear scores','callback',@Clearbutton,...
            'Fontsize',10.0);   %#ok<NASGU> % clear score button
        
        function Okbutton(~, ~)
            %% closes figure
            
            close(gcf)
        end
        
        function Clearbutton(~, ~)
            %% clears high score
            
            highscore = {'Player 1' 0};
            save(fullfile('resources','highscore'),'highscore');
            close(gcf)
        end
        
    end

    function Exitbutton(~, ~)
        %% closes reversi.
        
        close(gcf)
    end

% GUI functions

    function drawScreen()
        %% the function that is responsible for redrawing the screen and
        % showing hints and resizing the player images.
        
        size = returnLargerSize();      %calls sizer functions to get size
        s_x = imresize(pic_x,size/500); %scales red peice to size
        s_o = imresize(pic_o,size/500); % scales blue peice to size
        red = numel(find(board == 1));  % locates where board is red
        blue = numel(find(board == -1));% locates where board is blue
        s_blank = imresize(pic_blank,size/500); %scales blank size (dummypic)
        if player == 1  %updates vadious strings for each players turn
            set(currentPlayer,'string','Red players go','color',[1 0 0])
            set(Num_of_x,'string',sprintf('Red: %i',red))
            set(Num_of_o,'string',sprintf('Blue: %i',blue))
        else
            set(currentPlayer,'string','Blue players go','color',[0 1 1])
            set(Num_of_x,'string',sprintf('Red: %i',red))
            set(Num_of_o,'string',sprintf('Blue: %i',blue))
        end
        if hint_toggle == 1 % if the hint function is on
            r = zeros(8,8); % the function finds where ther are valid moves bellow
            tilestoflip = zeros(8,8);
            for z = 1:8
                for y = 1:8
                    
                    [r(y,z),numbermvs,~] = move_is_valid(board,[y z],player);
                    thingstosub = find(numbermvs ~= 0);
                    totalsub = numel(thingstosub);
                    for jake = 1:totalsub
                        numbermvs(thingstosub(jake)) = numbermvs(thingstosub(jake)) - 1;
                    end
                    tilestoflip(y,z) = sum(numbermvs);
                end
            end
        else
            r = board;  % else there are no hints
        end
        for i = 1:8 % this part of code draws pictures over the buttons
            for j = 1:8
                if board(i,j) == 1  %for red buttons
                    set(buttons(i,j),'string','','cdata',s_x,'enable','inactive','background',[.9 .9 .9]);
                elseif board(i,j) == -1 %for blue buttons
                    set(buttons(i,j),'string','','cdata',s_o,'enable','inactive','background',[.9 .9 .9]);
                elseif r(i,j) == 1  %where hints are located
                    %toflip = num2str(tilestoflip(i,j));
                    set(buttons(i,j),'string',tilestoflip(i,j),'background',[.7 .7 .7],'enable','on',...
                        'fontweight','bold','fontsize',14);
                elseif r(i,j) == 0  % clears old hints back to clear
                    set(buttons(i,j),'string','','cdata',s_blank,'background',[.9 .9 .9],'enable','on');
                else    % anything else is cleared just in case
                    set(buttons(i,j),'string','','cdata',s_blank,'enable','on','background',[.9 .9 .9]);
                end
            end
        end
    end

    function size = returnLargerSize()
        %% resets the size of the buttons.
        
        set(buttons(1,1),'units','pixels'); % sets button 1 to pixels
        size = get(buttons(1,1), 'position');   % gets its size vector
        size = min(size(3:4));                  % finds min size
        set(buttons(1,1),'units','normalized')  % sets back to normalized
        
        
    end

    function setAllInactive()
        %% sets all the buttons to inactive so they cant be clicked on.
        
        for i = 1:8
            for j = 1:8
                set(buttons(i,j),'enable','inactive'); %the inactive property
            end
        end
    end

    function resize_callback(~,~)
        %% instant resize of the screen
        
        drawScreen();
    end

% Other functions

    function [r places boardout] = move_is_valid(board,move,player)
        %% needs to check if valid move by finding if players peice is behind
        % opponents peices in all directions.
        opp = player*-1;
        places = [0 0 0 0 0 0 0 0];     %[R L U D RU RD LU LD}
        if move(2)~=8           % finds if valid move right
            if board(move(1),move(2)+1)==opp
                if move(2)+1 ~= 8
                    if board(move(1),move(2)+2)==opp
                        if move(2)+2 ~= 8
                            if board(move(1),move(2)+3)==opp
                                if move(2)+3 ~= 8
                                    if board(move(1),move(2)+4)==opp
                                        if move(2)+4 ~= 8
                                            if board(move(1),move(2)+5)==opp
                                                if move(2)+5 ~= 8
                                                    if board(move(1),move(2)+6)==opp
                                                        if move(2)+6 ~= 8
                                                            if board(move(1),move(2)+7)==opp
                                                            elseif board(move(1),move(2)+7)==player
                                                                places(1) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1),move(2)+6)==player
                                                        places(1) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1),move(2)+5)==player
                                                places(1) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1),move(2)+4)==player
                                        places(1) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1),move(2)+3)==player
                                places(1) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1),move(2)+2)==player
                        places(1) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(2) ~= 1         %checks for valid move left
            if board(move(1),move(2)-1)==opp
                if move(2)-1 ~= 1
                    if board(move(1),move(2)-2)==opp
                        if move(2)-2 ~= 1
                            if board(move(1),move(2)-3)==opp
                                if move(2)-3 ~= 1
                                    if board(move(1),move(2)-4)==opp
                                        if move(2)-4 ~= 1
                                            if board(move(1),move(2)-5)==opp
                                                if move(2)-5 ~= 1
                                                    if board(move(1),move(2)-6)==opp
                                                        if move(2)-6 ~= 1
                                                            if board(move(1),move(2)-7)==opp
                                                            elseif board(move(1),move(2)-7)==player
                                                                places(2) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1),move(2)-6)==player
                                                        places(2) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1),move(2)-5)==player
                                                places(2) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1),move(2)-4)==player
                                        places(2) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1),move(2)-3)==player
                                places(2) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1),move(2)-2)==player
                        places(2) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(1) ~= 1         % checks for valid move up
            if board(move(1)-1,move(2))==opp
                if move(1)-1 ~= 1
                    if board(move(1)-2,move(2))==opp
                        if move(1)-2 ~= 1
                            if board(move(1)-3,move(2))==opp
                                if move(1)-3 ~= 1
                                    if board(move(1)-4,move(2))==opp
                                        if move(1)-4 ~= 1
                                            if board(move(1)-5,move(2))==opp
                                                if move(1)-5 ~= 1
                                                    if board(move(1)-6,move(2))==opp
                                                        if move(1)-6 ~= 1
                                                            if board(move(1)-7,move(2))==opp
                                                            elseif board(move(1)-7,move(2))==player
                                                                places(3) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1)-6,move(2))==player
                                                        places(3) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1)-5,move(2))==player
                                                places(3) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1)-4,move(2))==player
                                        places(3) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1)-3,move(2))==player
                                places(3) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1)-2,move(2))==player
                        places(3) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(1) ~= 8         % checks for valid move down
            if board(move(1)+1,move(2))==opp
                if move(1)+1 ~= 8
                    if board(move(1)+2,move(2))==opp
                        if move(1)+2 ~= 8
                            if board(move(1)+3,move(2))==opp
                                if move(1)+3 ~= 8
                                    if board(move(1)+4,move(2))==opp
                                        if move(1)+4 ~= 8
                                            if board(move(1)+5,move(2))==opp
                                                if move(1)+5 ~= 8
                                                    if board(move(1)+6,move(2))==opp
                                                        if move(1)+6 ~= 8
                                                            if board(move(1)+7,move(2))==opp
                                                            elseif board(move(1)+7,move(2))==player
                                                                places(4) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1)+6,move(2))==player
                                                        places(4) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1)+5,move(2))==player
                                                places(4) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1)+4,move(2))==player
                                        places(4) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1)+3,move(2))==player
                                places(4) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1)+2,move(2))==player
                        places(4) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(1)~=1 && move(2)~=8         % checks diagonly up right
            if board(move(1)-1,move(2)+1)==opp
                if move(1)-1~=1 && move(2)+1~=8
                    if board(move(1)-2,move(2)+2)==opp
                        if move(1)-2~=1 && move(2)+2~=8
                            if board(move(1)-3,move(2)+3)==opp
                                if move(1)-3~=1 && move(2)+3~=8
                                    if board(move(1)-4,move(2)+4)==opp
                                        if move(1)-4~=1 && move(2)+4~=8
                                            if board(move(1)-5,move(2)+5)==opp
                                                if move(1)-5 ~=1 && move(2)+5~=8
                                                    if board(move(1)-6,move(2)+6)==opp
                                                        if move(1)-6~=1 && move(2)+6~=8
                                                            if board(move(1)-7,move(2)+7)==opp
                                                            elseif board(move(1)-7,move(2)+7)==player
                                                                places(5) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1)-6,move(2)+6)==player
                                                        places(5) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1)-5,move(2)+5)==player
                                                places(5) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1)-4,move(2)+4)==player
                                        places(5) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1)-3,move(2)+3)==player
                                places(5) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1)-2,move(2)+2)==player
                        places(5) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(1)~=8 && move(2)~=8         % checks diagonly down right
            if board(move(1)+1,move(2)+1)==opp
                if move(1)+1~=8 && move(2)+1~=8
                    if board(move(1)+2,move(2)+2)==opp
                        if move(1)+2~=8 && move(2)+2~=8
                            if board(move(1)+3,move(2)+3)==opp
                                if move(1)+3~=8 && move(2)+3~=8
                                    if board(move(1)+4,move(2)+4)==opp
                                        if move(1)+4~=8 && move(2)+4~=8
                                            if board(move(1)+5,move(2)+5)==opp
                                                if move(1)+5 ~=8 && move(2)+5~=8
                                                    if board(move(1)+6,move(2)+6)==opp
                                                        if move(1)+6~=8 && move(2)+6~=8
                                                            if board(move(1)+7,move(2)+7)==opp
                                                            elseif board(move(1)+7,move(2)+7)==player
                                                                places(6) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1)+6,move(2)+6)==player
                                                        places(6) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1)+5,move(2)+5)==player
                                                places(6) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1)+4,move(2)+4)==player
                                        places(6) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1)+3,move(2)+3)==player
                                places(6) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1)+2,move(2)+2)==player
                        places(6) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(1)~=1 && move(2)~=1         % checks diagonly up left
            if board(move(1)-1,move(2)-1)==opp
                if move(1)-1~=1 && move(2)-1~=1
                    if board(move(1)-2,move(2)-2)==opp
                        if move(1)-2~=1 && move(2)-2~=1
                            if board(move(1)-3,move(2)-3)==opp
                                if move(1)-3~=1 && move(2)-3~=1
                                    if board(move(1)-4,move(2)-4)==opp
                                        if move(1)-4~=1 && move(2)-4~=1
                                            if board(move(1)-5,move(2)-5)==opp
                                                if move(1)-5~=1 && move(2)-5~=1
                                                    if board(move(1)-6,move(2)-6)==opp
                                                        if move(1)-6~=1 && move(2)-6~=1
                                                            if board(move(1)-7,move(2)-7)==opp
                                                            elseif board(move(1)-7,move(2)-7)==player
                                                                places(7) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1)-6,move(2)-6)==player
                                                        places(7) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1)-5,move(2)-5)==player
                                                places(7) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1)-4,move(2)-4)==player
                                        places(7) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1)-3,move(2)-3)==player
                                places(7) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1)-2,move(2)-2)==player
                        places(7) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if move(1)~=8 && move(2)~=1         % checks diagonly down left
            if board(move(1)+1,move(2)-1)==opp
                if move(1)+1~=8 && move(2)-1~=1
                    if board(move(1)+2,move(2)-2)==opp
                        if move(1)+2~=8 && move(2)-2~=1
                            if board(move(1)+3,move(2)-3)==opp
                                if move(1)+3~=8 && move(2)-3~=1
                                    if board(move(1)+4,move(2)-4)==opp
                                        if move(1)+4~=8 && move(2)-4~=1
                                            if board(move(1)+5,move(2)-5)==opp
                                                if move(1)+5 ~=8 && move(2)-5~=1
                                                    if board(move(1)+6,move(2)-6)==opp
                                                        if move(1)+6~=8 && move(2)-6~=1
                                                            if board(move(1)+7,move(2)-7)==opp
                                                            elseif board(move(1)+7,move(2)-7)==player
                                                                places(5) = 7;
                                                            else
                                                            end
                                                        else
                                                        end
                                                    elseif board(move(1)+6,move(2)-6)==player
                                                        places(8) = 6;
                                                    else
                                                    end
                                                else
                                                end
                                            elseif board(move(1)+5,move(2)-5)==player
                                                places(8) = 5;
                                            else
                                            end
                                        else
                                        end
                                    elseif board(move(1)+4,move(2)-4)==player
                                        places(8) = 4;
                                    else
                                    end
                                else
                                end
                            elseif board(move(1)+3,move(2)-3)==player
                                places(8) = 3;
                            else
                            end
                        else
                        end
                    elseif board(move(1)+2,move(2)-2)==player
                        places(8) = 2;
                    else
                    end
                else
                end
            else
            end
        else
        end
        
        if isempty(find(places ~= 0, 1))==1 % if there are no valid places
            r = 0;  % no vlaid moves
        elseif isempty(find(places ~= 0, 1))==0 % if ther are valid places
            r = 1;  % are valid moves
        else
            error('failure in umpire occured')
        end
        if board(move(1),move(2))==0    % makes sure board is empty
        else
            r = 0;
        end
        boardout = flipper(board,move,places,player);   %initiates flipper function
    end

    function board = flipper(board,move,places,player)
        %% flips opponents tiles
        % places(directions) = [R L U D RU RD LU LD]
        
        if places(1) ~= 0 % if there are tiles that can be flipped
            for t1 = 1:places(1)
                board(move(1),move(2)+t1)= player; %flips tiles
            end
        end
        if places(2) ~= 0 % tiles able to be flipped
            for t2 = 1:places(2)
                board(move(1),move(2)-t2) = player;% flips tiles
            end
        end
        if places(3) ~= 0 % tiles can be flipped
            for t3 = 1:places(3)
                board(move(1)-t3,move(2)) = player; % flips tiles
            end
        end
        if places(4) ~= 0 % tiles can be flipped
            for t4 = 1:places(4)
                board(move(1)+t4,move(2)) = player; % flips tiles
            end
        end
        if places(5) ~= 0 % tiles can be flipped
            for t5 = 1:places(5)
                board(move(1)-t5,move(2)+t5) = player; % flips tiles
            end
        end
        if places(6) ~= 0 % tiles can be flipped
            for t6 = 1:places(6)
                board(move(1)+t6,move(2)+t6) = player; % flips tiles
            end
        end
        if places(7) ~= 0 % tiles can be flipped
            for t7 = 1:places(7)
                board(move(1)-t7,move(2)-t7) = player; % flips tiles
            end
        end
        if places(8) ~= 0 % tiles can be flipped
            for t8 = 1:places(8)
                board(move(1)+t8,move(2)-t8) = player; % flips tiles
            end
        end
    end

    function winner = calculate_winner(board)
        %% calculates which player has won
        
        x_peices = numel(find(board == 1)); %calculates red peices
        o_peices = numel(find(board == -1));%calculates blue peices
        
        if x_peices == o_peices
            winner = 0; % if both are equal it is a draw
        elseif x_peices > o_peices
            winner = 1; % if red is greater then blue red wins
        else
            winner = -1;% if blue is breater then red blue wins
        end
    end

    function r = game_is_over(board)
        %% determine if the game is over or not
        blu = zeros(8,8);   %sets a grid for both players
        rd = zeros(8,8);
        for z = 1:8
            for y = 1:8
                rd(y,z) = move_is_valid(board,[y z],1);% finds valid moves for red
                blu(y,z) = move_is_valid(board,[y z],-1);% finds valid moves for bluw
            end
        end
        a = find(blu == 1, 1); % finds if there are valid moves
        b = find(rd == 1, 1);  % finds if there are valid moves
        if isempty(a)   %if there arent any valid moves for blue
            r = 1;      % the game is over
        else
            r = 0;      %else the game continues
        end
        if r == 0       % if the game is continuing must check red
            if isempty(b)% if there is no valid moves for red
                r = 1;   % the game is over
            else         % else the game can indeed continue
                
                
            end
        else
        end
        zer = find(board == 0, 1);  %not needed but checks for zeros
        if isempty(zer)==1          % if there arent any empty spaces then
            r = 1;                  % the game is over
        else
        end
        
    end

end