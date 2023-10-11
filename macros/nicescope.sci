function []=nicescope()

    // On ajuste la vues sur les scopes
    list_fig=winsid();  // On récupere les numéros des figure

    for i=1:length(list_fig)
        h=scf(list_fig(i));
        //En cas de simulation param_var
        if (h.tag=="todemux") then
            legendtxt=h.children(1).children(1).text; //sauvegarde de la légende
            nb_compound=length(h.children(1).children)-1;
            for j=nb_compound+1:-1:2
                unglue(h.children(1).children($));
            end
            for j=1:nb_compound-1
                swap_handles(h.children(1).children(2*(nb_compound-j)),h.children(1).children(2*(nb_compound)-j));
            end
            legend(legendtxt);
            h.tag="nodemux";
        end
        if (h.tag=="") then //nicescope classique
            for j=1:length(h.children)
                if h.children(j) <> [] & h.children(j).type == "Axes"
                    if h.children(j).children <> [] & ~isempty(find(h.children(j).children.type == "Polyline"))
                        if(length(h.children(j).children)==1 & h.children(j).children(1).type == "Polyline") then
                            xmin=min(h.children(j).children.data(:,1))
                            xmax=max(h.children(j).children.data(:,1))
                            ymax=max(h.children(j).children.data(:,2))*1.1
                            ymin=min(h.children(j).children.data(:,2))
                            //                text_legend='Courbe 1';
                            //                legend(text_legend)
                        else
                            xmin=1e8;
                            xmax=-1e8;
                            ymin=1e8;
                            ymax=-1e8;
                            text_legend=[]
                            nb_polylines=0;
                            for k=1:length(h.children(j).children)
                                if h.children(j).children(k).type == "Polyline" then
                                    nb_polylines=nb_polylines+1;
                                    xmin=min(xmin,min(h.children(j).children(k).data(:,1)))
                                    xmax=max(xmax,max(h.children(j).children(k).data(:,1)))
                                    ymin=min(ymin,min(h.children(j).children(k).data(:,2)))
                                    ymax=max(ymax,max(h.children(j).children(k).data(:,2))*1.1)
                                    text_legend($+1)='Courbe '+string(nb_polylines);
                                end
                            end
                            if nb_polylines==length(h.children(j).children) then
                                legend(text_legend)
                            end

                        end
                        if ymin<0 then ymin=ymin*1.2;
                        elseif ymin==0 then ymin=ymin-ymax*0.05*sign(ymax);
                        elseif ymin>0 then ymin=ymin*0.9;
                        end
                        //création des nouvelles valeurs extrèmes et tracé réactualisé
                        rect=[xmin,ymin,xmax,ymax]
                        replot(rect,h.children(j))
                    end
                end
            end
        end
    end
endfunction

