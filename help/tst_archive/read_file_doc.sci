
function data=read_file_doc(file_name)
    fd=mopen(file_name); //open file
    txt=mgetl(fd,-1); //read all lines
    err=mclose(fd);

    //items to read (respect this order )
    items_to_read=["\name","\smalldescription","\palette","\description","\dialogbox","\example1","\example2","\example3","\seealso"];
    lign_of_items=0*ones(1,size(items_to_read,2));
    nb_items=size(items_to_read,'*')
    //definition de la structure de donnee
    for i=1:size(txt,'*')
        for j=1:nb_items

            if ~isempty(strindex(txt(i),items_to_read(j))) then
                lign_of_items(j)=i;
            end
        end
    end

    //to use if the ordre is not respected
    [temp,order]=gsort(lign_of_items,'g','i');

    //extract data by items
    data_by_items=cell(nb_items,1);
    for j=1:nb_items-1
        data_by_items(j).entries=txt(lign_of_items(order(j))+1:lign_of_items(order(j+1))-1);
    end
    data_by_items(nb_items).entries=txt(lign_of_items(order(nb_items))+1:$);
    data_by_items2=data_by_items;
    data_by_items2(order)=data_by_items;
    data.name=stripblanks(strcat(data_by_items2(1).entries),%t);
    data.smalldescription=strcat(data_by_items2(2).entries);
    data.palette=stripblanks(strcat(data_by_items2(3).entries),%t);
    data.seealso=data_by_items2(9).entries;
    data.description=data_by_items2(4).entries;
    data.dialogbox=data_by_items2(5).entries;
    data.example1=data_by_items2(6).entries;
    data.example2=data_by_items2(7).entries;
    data.example3=data_by_items2(8).entries;   
    data.to_replace=cell(5,1);
    data.to_replace=data_by_items2(4:8);

endfunction

function data=change_keyword(data)


    for d=1:size(data.to_replace,1)
        to_replace=data.to_replace(d).entries;
        
        //add <par> </par> for each non empty lign
        for i=1:size(to_replace,'*')
            if ~isempty(to_replace(i)) then
                to_replace(i)='<para> '+to_replace(i)+' </para>';
            end
        end    
        
       //replace \bold{} by <emphasis role="bold">Step Time</emphasis>            
        for i=1:size(to_replace,'*')
            ind_bold=strindex(to_replace(i),"\bold")
            ind_acc1=strindex(to_replace(i),"{")
            ind_acc2=strindex(to_replace(i),"}")
            n=0
            ind_bold_acc=[]
            for j=ind_bold
                n=n+1;
                for k=ind_acc1
                    if k==j+5 then
                        ind_bold_acc($+1)=ind_acc2(n);
                        continue
                    end
                end
            end

            sizestr=length(to_replace(i))
            if ~isempty(ind_bold) then
                new_str=[];
                ind_ini=1;
                for j=1:size(ind_bold,2)
                    new_str=new_str+part(to_replace(i),ind_ini:ind_bold(j)-1);
                    new_str=new_str+"<emphasis role='"bold'">";                
                    new_str=new_str+part(to_replace(i),ind_bold(j)+6:ind_bold_acc(j)-1);
                    new_str=new_str+"</emphasis>";
                    ind_ini=ind_bold_acc(j)+1;
                end
                to_replace(i)=new_str+part(to_replace(i),ind_bold_acc($)+1:sizestr);
            end
        end

        //replace \image  by xml code
        for i=1:size(to_replace,'*')
            ind_image=strindex(to_replace(i),"\image")
            ind_acc=strindex(to_replace(i),"}")
            if ~isempty(ind_image) then
                name=stripblanks(part(to_replace(i),ind_image+7:ind_acc-1));
                to_replace(i) = "<inlinemediaobject> <imageobject> <imagedata fileref='""+name+"'" align='"center'"/> </imageobject> </inlinemediaobject>"
            end

        end
        

        data.to_replace(d).entries=to_replace;

        
    end
    
    data.description=data.to_replace(1).entries
    data.dialogbox=data.to_replace(2).entries;
    data.example1=data.to_replace(3).entries;
    data.example2=data.to_replace(4).entries;
    data.example3=data.to_replace(5).entries;     
    //data.seealso=data.to_replace(6).entries;

endfunction

function write_xml(data)
    
    fd = mopen(data.name+'.xml','w+');

    //write entete
    entete=['<?xml version='"1.0'" encoding='"UTF-8'"?>'
            '<refentry xmlns='"http://docbook.org/ns/docbook'" xmlns:xlink='"http://www.w3.org/1999/xlink'" xmlns:svg='"http://www.w3.org/2000/svg'" xmlns:mml='"http://www.w3.org/1998/Math/MathML'" xmlns:db='"http://docbook.org/ns/docbook'" version='"5.0-subset Scilab'" xml:id='""+data.name+"'"> ']
    mputl(entete,fd);
    towrite= ['<refnamediv>' 
              '  <refname>'+data.name+'</refname>'
              '  <refpurpose>'+data.smalldescription+'</refpurpose> '
              '</refnamediv>']
    mputl(towrite,fd);
  
    towrite=['<refsection>'
           '  <title>Aperçu</title>'
           '    <para>'
           '       <inlinemediaobject>'
           '          <imageobject>'
           '             <imagedata fileref='"../../images/gif/'+data.name'+'.gif'" align='"center'" valign='"middle'"/>'
           '          </imageobject>'
           '       </inlinemediaobject>'
           '    </para>'
           '</refsection>'
            ]
    mputl(towrite,fd);
    
    linkend=[]
    linkend_name=[];
    linkend_data=cell(7,1);
    n=1;
    if ~isempty(data.palette) then
        linkend($+1)='Palette_'+data.name;
        linkend_name($+1)='Palette';
        linkend_data(n).entries=data.palette
        n=n+1
    end
    if ~isempty(data.description) then
        linkend($+1)='Description_'+data.name;
        linkend_name($+1)='Description';
        linkend_data(n).entries=data.description
        n=n+1
    end
    if ~isempty(data.dialogbox) then
        linkend($+1)='Dialogbox_'+data.name;
        linkend_name($+1)='Boite de dialogue';
        linkend_data(n).entries=data.dialogbox;
        n=n+1
    end
    if ~isempty(data.example1) then
        linkend($+1)='Example1_'+data.name;
        linkend_name($+1)='Exemple 1';
        linkend_data(n).entries=data.example1;
        n=n+1
    end
    if ~isempty(data.example2) then
        linkend($+1)='Example2_'+data.name;
        linkend_name($+1)='Exemple 2';
        linkend_data(n).entries=data.example2;
        n=n+1        
    end
    if ~isempty(data.example3) then
        linkend($+1)='Example3_'+data.name;
        linkend_name($+1)='Exemple 3';
        linkend_data(n).entries=data.example3;
        n=n+1
    end
    if ~isempty(data.seealso) then
        linkend($+1)='Seealso_'+data.name;
        linkend_name($+1)='Voir aussi';
        linkend_data(n).entries=data.seealso;
        n=n+1
    end    
    
   towrite=[
  '<refsection id='"Contents_'+data.name+''">'
  '  <title>Contenu</title>'
  '  <itemizedlist>'
  '    <listitem>'
  '      <para>'
  '        <link linkend='"'+data.name'+''">'+data.smalldescription+'</link>'
  '      </para>'
  '    </listitem>'
  '    <listitem>'  
  '      <itemizedlist>'
  ]
  mputl(towrite,fd)
  
  for i=1:size(linkend,1)
      towrite=[
  '        <listitem>'
  '          <para>'
  '            <xref linkend='"'+linkend(i)+''">'+linkend_name(i)+'</xref>'
  '          </para>'
  '        </listitem>'      
      ]
       mputl(towrite,fd) 
  end
  
  towrite=[
  '      </itemizedlist>'
  '    </listitem>'
  '  </itemizedlist>'
  '</refsection>  '
  ]
  mputl(towrite,fd)
  
  for i=1:size(linkend,1)-1
  towrite=[
  '<refsection id='"'+linkend(i)+''">'
  '  <title>'+linkend_name(i)+'</title>'
 // '  <itemizedlist>'
 // '    <listitem>'
  //'      <para>'
  linkend_data(i).entries
  //'      </para>'
  //'    </listitem>'
  //'  </itemizedlist>'
  '</refsection>'      
  ]
  mputl(towrite,fd)
  end

  //specific for see_also
  towrite=[
  '<refsection id='"'+linkend($)+''">'
  '  <title>'+linkend_name(size(linkend,1))+'</title>'  
  ]
  mputl(towrite,fd)

  for j=1:size(linkend_data(size(linkend,1)).entries,'*')
   towrite=[   
    '      <para>'
  '        <link linkend='"'+linkend_data(size(linkend,1)).entries(j)+''">'+linkend_data(size(linkend,1)).entries(j)+'</link>'
  '      </para>'  
    ]
    mputl(towrite,fd)
  end
   towrite=[
  '</refsection>'      
  ]
  mputl(towrite,fd)
  

towrite='</refentry>'
mputl(towrite,fd)
  
    
  mclose(fd);
    
endfunction


function create_xml(filename)
    disp('Creation du fichier xml associé à '+filename)
    data=read_file_doc(filename);
    data=change_keyword(data);
    write_xml(data);
endfunction

function create_all()
    files=findfiles('./','*.tst')
    for i=1:length(length(files))
        if strindex(files(i),'~') ==[]
            create_xml(files(i))
        end
    end
endfunction
