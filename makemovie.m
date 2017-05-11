function makemovie

%% Movie Test.
 
%% Set up the movie.
writerObj = VideoWriter('figures/topograph.avi'); % Name it.
writerObj.FrameRate = 60; % How many frames per second.
open(writerObj); 

angledelta = 1;
hold on

for a = angledelta:angledelta:360      
    camorbit(gca,angledelta,0);
    frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
    writeVideo(writerObj, frame);
 
end
hold off
close(writerObj); % Saves the movie.