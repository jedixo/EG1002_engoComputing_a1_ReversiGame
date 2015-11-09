function move = jc259368_bot(board,player,~)
    %ai bot all code written by jake dixon. the ai passes 200/200 of the
    %tests set in test_your_bot.m provided on learn jcu. the ai works by
    %finding positions where the move would flip over a maximum number of
    %tiles and places the move there.
    max = 0;
    
    where_zero = 1:64;
    atall = zeros(1,(numel(where_zero)));
    for a = 1:numel(where_zero)
        temp = board;
        temp(where_zero(a)) = 5;
        [y x] = find(temp == 5);
        [p, places] = test_move(board,[y, x],player);
        atall(a) = p;
        score{a} = places; %#ok<AGROW>
    end
    
    valid = find(atall == 1);
    for d = 1:numel(valid)
        findmove = find([score{valid(d)}] > 0);
        for c = 1:numel(findmove)
            x = score{valid(d)}(findmove(c));
            if x > max
                premove = valid(d);
            elseif x == max
                decide = randi([1 2],1);
                if decide == 1
                    premove = valid(d);
                else
                end
            end
        end
    end
    temp = board;
    temp(premove) = 5;
    [y x] = find(temp == 5);
    move = [0 0];
    move(1) = y;
    move(2) = x;
    
     function [r places] = test_move(board,move,player)
     % test_move - this function is identical to the function move_is_valid in
     % the main game loop function but becasue the ai was needed to be
     % seperate it had to be copied. this function tests the moves to make
     % sure they are valid and then gives them a score of how many tiles it
     % will flip in the places matrix, this allows the ai to find where the
     % maximum number of tiles will be flipped and makes that the ai move.
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

        if isempty(find(places ~= 0, 1))==1
            r = 0;
        elseif isempty(find(places ~= 0, 1))==0
            r = 1;
        else
            error('failure in umpire occured')
        end
        if board(move(1),move(2))==0
        else
            r = 0;
        end
     end
end