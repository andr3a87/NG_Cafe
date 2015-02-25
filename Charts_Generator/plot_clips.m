maps = [10,20,30];
strategies = {'FIFO-BASE', 'FIFO-PRO', 'LOW-PENALITY', 'HARD'};
strategies_n = [1,2,3,4,5,6];
histories = {'hdefault', 'hsimple', 'hhard', 'hperson1', 'hperson2','hcheckf'};
histories_n = [1,2,3,4,5,6];

strategies_cnt = length(strategies);
histories_cnt = length(histories);
maps_cnt = length(maps);

for map=1:maps_cnt
    %figure('units','normalized','outerposition',[0 0 1 1]);
    result = zeros(strategies_cnt,histories_cnt);
    
    [pen,ord,plans] = read_output(maps(map),6,6);
    pen
    
    maxo = max(max(pen));
    
    figure; colormap(jet(5));
    
    
    
    h = bar(pen, 1);
    
    % labels
    ylabel('penalty');
    xlabel('history');
    zlabel('penalty');
    
    %set(gca,'xtick',histories)
    
    % Change the x and y axis tick labels
    set(gca,'XTickLabel',histories);
    %%set(gca,'ZTickLabel', strategies);
    
    grid on;
    legend(h,strategies);
    
    % colorbar
    %col=colorbar;
    %colorTitleHandle = get(col,'Title');
    %titleString = 'Strategy';
    %set(colorTitleHandle ,'String',titleString);  
    %axes('position',get(col,'position'),'color','none','ylim',[0 
%100],'xtick',[])
   %colorbar('TickLabels',{'Cold','Cool','Neutral','Warm','Hot'});
   %colorbar('Ticks',linspace(1,maxo,10),...
         %'TickLabels',{'Cold','Cool','Neutral','Warm','Hot'});
 %   labels = strategies;
%lcolorbar(labels,'fontweight','bold');  
    
    %colormap jet;
    %c = colorbar;
    %set(c,'Ticks', [-1,0]);
    %caxis([0 1]);
    title(sprintf('Penalties for Map %i0x%i0 for each strategy and history',map,map));
    
    %get(h,'YData')
    
    shading faceted  
end

