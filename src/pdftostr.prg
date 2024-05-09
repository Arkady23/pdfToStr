*
*   ИЗВЛЕЧЕНИЕ СТРАНИЦЫ n1 ИЛИ ИНТЕРВАЛА СТРАНИЦ ОТ n1 ДО n2 ИЗ pdf 
*   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*   Примечание: На выходе переменная, которая может быть передана
*               через интернет или сохранена в файл.pdf.
*   Автор: Корниенко Аркадий Борисович
*   Дата:  09.05.2024
*
para pdf,n1,n2
  priv ALL
  x=""
  if file(m.pdf)
    bc='cPdf' && константы
    bp="%"
    bu="<<"
    bz=">>"
    bs="/"
    b1="["
    b2="]"
    b0="0"
    b=" "
    i1=1
    i2=2
    i3=3
    i4=4
    ia=10
    i13=13
    i23=23
    stor 0 to i0,g,k,v,xref1,xref2,nObj,iInfo,iRoot,iKids
    zR=" 0 R"
    ba=" B A"
    eoff="OFF"
    xf=" 65536 f"
    xn=" 00000 n"
    trailer="trailer"
    sxref="startxref"
    stream="stream"
    info="/Info"
    root="/Root"
    kids="/Kids"
    xref="xref"
    f10="@L "+replic("9",m.ia)
    c10=chr(m.ia)
    c13=chr(m.i13)
    oPdf=createObj(m.bc)
    dime aTmp(m.i1)
    exact= set("exact")=m.eoff
    if m.exact
      set exact on
    endi
    if empt(m.n1)
      n1=m.i0
    endi
    if type("m.n2")<>"N"
      n2=m.n1
    endi
    
    ** 1. чтение хвоста pdf
    nf=fopen(m.pdf)
    do e_pdf
    
    ** 2. чтение начала
    =fseek(m.nf,m.i0)
    verPdf=fget(m.nf)
    =fseek(m.nf,-m.i2,m.i1)
    c13=fread(m.nf,m.i2)
    if asc(m.c13)>m.i13
      m.c13=right(m.c13,m.i1)
    endi
    if m.nObj>m.i2
      =fseek(m.nf,m.xref2)

      ** 3. считываем массив ссылок на объекты
      dime aObj(m.nObj),qObj(m.nObj),cObj(m.nObj),kObj(m.nObj)
      stor m.i0 to kObj
      j=m.nObj
      for i=m.i1 to m.nObj
        if feof(m.nf)
          aObj(m.j)=m.i0
        else
          c=fget(m.nf)
          aObj(m.j)=iif(subs(m.c,18,1)="n",val(m.c),m.i0)
        endi
        ** исправляем проблему отсутствия нулевого индекса массива на VFP
        if m.j=m.nObj
          j=m.i0
        endi
        j=m.j+m.i1
      endf
    else
      ** если число объектов не реально мало, восстанавливаем массив ссылок
      dime aObj(m.i1),cObj(m.i1)
      do b_pdf
      dime aObj(m.nObj),qObj(m.nObj),cObj(m.nObj),kObj(m.nObj)
      for i=m.i1 to m.nObj
        if empt(aObj(m.i))
          aObj(m.i)=m.i0
        endi
      endf
      stor m.i0 to kObj
      =fseek(m.nf,m.xref2)
    endi
    if m.nObj>m.i2

      ** 4. Формируем массив размеров объектов
      k=m.nObj-m.i1
      for i=m.i1 to m.k
        v=m.xref1
        for j=m.i1 to m.k
          if aObj(m.j)>aObj(m.i) and aObj(m.j)<m.v and m.j<>m.i
            v=aObj(m.j)
          endi
        endf
        qObj(m.i)=m.v-aObj(m.i)
      endf

      ** 5. Чтение нужных, включая "Info", "Root", "Kids", объектов
      c=m.x
      do whil not feof(m.nf)
        y=fget(m.nf)
        if m.y=m.stream or m.y=m.sxref
          exit
        endi
        c=m.c+m.y
      endd
      =oPdf.scan(@c,m.i0)
      =fclo(m.nf)
      nf=-m.i1
      if empt(m.n1)
        retu m.g
      endi

      ** 6. переиндексирование объектов
      k=m.i3
      na=m.nObj
      do whil m.na>m.k
        if kObj(m.na)>m.i0
          for j=m.k to m.na-m.i1
            if kObj(m.j)=m.i0
              kObj(m.na)=m.j
              kObj(m.j)=m.na
              k=m.j+m.i1
              exit
            endi
          endf
        endi
        na=m.na-m.i1
      endd
      do whil kObj(m.na)=m.i1 or kObj(m.na)=m.i2
        na=m.na+m.i1
      endd

      ** 7. формирование строки m.x
      x=m.verPdf+m.c10
      for i=m.i1 to m.na-m.i1
        if kObj(m.i)>m.i0
          aObj(m.i)=len(m.x)
          if kObj(m.i)>m.i1
            * меняем ссылку в первой строке
            k=iif(kObj(m.i)>m.i2,kObj(m.i),m.i)
            c=subs(cObj(m.k),at(" obj",cObj(m.k))+m.i1)
            * меняем ссылки в остальных строках
            j=m.i1
            do whil m.k>m.i0
              k=at(m.zR,m.c,m.j)
              if m.k>m.i0
                y=rtri(left(m.c,m.k))
                m=rat(m.b,m.y)+m.i1
                v=val(subs(m.y,m.m))
                if qObj(m.v)<m.i0
                  * было m.v, стало -qObj(m.v)
                  v= -qObj(m.v)
                  if m.v<m.na
                    c=stuf(m.c,m.m,m.k-m.m,tran(m.v))
                  endi
                endi
                if m.v>=m.na and m.v<=m.nObj
                  * было m.v, стало kObj(m.v)
                  c=stuf(m.c,m.m,m.k-m.m,tran(kObj(m.v)))
                endi
                j=m.j+m.i1
              endi
            endd
            x=m.x+tran(m.i)+m.b+m.b0+m.b+m.c
          else
            * ничего не меняем
            x=m.x+cObj(m.i)
          endi
        else
          * свободный объект предусмотрен, но их не должно их быть
          aObj(m.i)=m.i0
        endi
      endf
      k=len(m.x)
      x=m.x+m.xref+m.c10+m.b0+m.b+tran(m.na)+m.c10+replic(m.b0,m.ia)+m.xf+m.b+m.c10
      for i=m.i1 to m.na-m.i1
        if empt(aObj(m.i))
          x=m.x+tran(m.i,m.f10)+m.xf+m.b+m.c10
        else
          x=m.x+tran(aObj(m.i),m.f10)+m.xn+m.b+m.c10
        endi
      endf
      x=m.x+m.trailer+m.c10+m.bu+m.info+m.b+tran(iif(m.iInfo>m.na,kObj(m.iInfo),m.iInfo))+ ;
        m.zR+m.b+m.root+m.b+tran(iif(m.iRoot>m.na,kObj(m.iRoot),m.iRoot))+m.zR+" /Size "+ ;
        tran(m.na)+m.bz+m.c10+m.sxref+m.c10+tran(m.k)+m.c10+"%%EOF"+m.c10
    endi
    if m.exact
      set exact off
    endi
    if m.nf>=m.i0
      =fclo(m.nf)
    endi
  endi
retu m.x

proc e_pdf
  ** чтение хвоста pdf
  =fseek(m.nf,-40,m.i2)
  do whil not feof(m.nf)
    c=fget(m.nf)
    if left(m.c,m.i1)<>m.bp
      do case
      case m.xref1=m.i0
        if m.c=m.sxref
          xref1=m.i1
        endi
      case m.xref1=m.i1
        xref1=val(m.c)
        =fseek(m.nf,m.xref1)
      case m.c=m.xref
        nObj=m.i1
      case m.c=m.trailer
        nObj=m.i2
        xref2=fseek(m.nf,m.i0,m.i1)
      case m.nObj=m.i1
        nObj=val(wd2(@c,m.i2))
        if m.nObj>0
          xref2=fseek(m.nf,m.i0,m.i1)
          exit
        endi
      case m.nObj=m.i2
        vpole2(@c,"/Prev")
        if m.v>m.i0
          xref1=m.v
          =fseek(m.nf,m.xref1)
        else
          xref2=m.v
          exit
        endi
      other
        xref2=m.xref1
        exit
      endc
    endi
  endd

proc b_pdf
  ** формирование массива ссылок
  local eobj,nc,ac(m.i1)
  c=m.x
  k=fsee(m.nf,0,m.i1)
  do whil not feof(m.nf)
    c=fget(m.nf)
    if left(m.c,1)<>m.bp
      exit
    endi
    k=fsee(m.nf,0,m.i1)
  endd
  j=m.i0
  c=m.c+m.c13
  bobj=" obj"
  eobj="endobj"+m.c13
  do whil not feof(m.nf)
    nc=aline(ac,fread(m.nf,16000000),16,m.eobj)
    if m.nc>m.i0
      ac(m.i1)=m.c+ac(m.i1)
      c=m.x
      for i=m.i1 to m.nc-m.i1
        y=left(ac(m.i),m.i23)
        if m.b+wd2(@y,m.i3)=m.bobj
          j=val(m.y)
          if m.j>m.nObj
            nObj=m.j
            dime aObj(m.nObj)
          endi
          aObj(m.j)=m.k
          k=m.k+len(ac(m.i))
        else
          j=m.i0
        endi
      endf
      c=ac(m.nc)
    endi
  endd
  nObj=m.nObj+m.i1
  xref1=m.k

func wd2(c,k)
  ** выделение k-го слова из текста, k=0 - последнее слово в строке, -1 предпоследнее и т.д.
  local z
  na=aline(aTmp,m.c,m.i4,m.b,m.bu,m.b1,m.c13)
  do case
  case m.k>m.i0
    z=iif(m.k>m.na,m.b,aTmp(m.k))
  case empt(m.k)
    z=iif(m.na=m.i0,m.b,aTmp(m.na))
  othe
    k=m.k+m.na
    z=iif(m.k>m.i0,aTmp(m.k),m.b)
  endc
retu m.z

func pole2(c,k)
** поиск конца поля значений в m.c за позицией k
retu m.k+at(m.bs,strt(subs(m.c,k+m.i1),">",m.bs)+m.bs)

proc vpole2(c,key)
  ** значение после символьного ключа
  v=rat(m.key,m.c)
  if m.v>m.i0
    v=val(subs(m.c,m.v+len(m.key)))
  endi

defi class cPdf as custom
  Func scan(c,iObj)
    local ac1(m.i1),ac2(m.i1),d,e,f,h,i,j,k,m,y,c2,oPdf2
    k=aline(ac1,strt(stre(m.c,m.bu,m.stream,m.i1,m.i2),m.b1,m.b)+m.ba,m.i1,m.zR)
    if m.k>m.i1
      if m.iKids=m.i0
        ** А если в этой строке список страниц, то его надо модифицировать
        ** в соответствии с заданным интервалом вывода нужных страниц
        f=at(m.kids,m.c)
        if m.f>m.i0
          for i=m.i1 to m.k-m.i1
            h=at(m.kids,ac1(m.i))
            if m.h>m.i0
              iKids=m.iObj
              j=val(wd2(ac1(m.i),m.i0))
              if m.j>m.i0 and m.j<=m.nObj
                ** изменяем список объектов согласно параметров
                ac1(m.i)=subs(ac1(m.i),m.h+6)
                h=m.i0
                y=m.b
                for m=m.i to m.k-m.i1
                  ** заглянем в этот объект на случай, если там скрывается дочерний Kids
                  d=val(ac1(m.m))
                  =fseek(m.nf,aObj(m.d))
                  c2=iif(feof(m.nf),m.x,stre(fread(m.nf,qObj(m.d)),m.kids,m.b2,m.i1,m.i2))
                  if len(m.c2)>m.i0
                    ** Объект d удаляем, ссылки на него переводим на iKids
                    qObj(m.d)= -m.iKids
                    d=aline(ac2,stre(m.c2,m.b1,m.b2,m.i1,m.i2),m.i1,m.zR)
                  else
                    ac2(m.i1)=ac1(m.m)
                    d=m.i1
                  endi
                  ** формируем новый список страниц
                  for e=m.i1 to m.d
                    if m.h<m.n2 or empt(m.n2)
                      h=m.h+m.i1
                      if m.h>=m.n1
                        g=m.g+m.i1
                        y=m.y+tran(val(ac2(m.e)))+m.zR+m.b
                      endi
                    else
                      exit
                    endi
                  endf
                endf
                h=pole2(@c,@f)
                c=left(m.c,m.f+m.i4)+m.b+m.b1+m.y+m.b2+subs(m.c,m.h)
                ** изменяем количество страниц в /Count
                m=at("/Count",m.c)
                h=pole2(@c,@m)
                c=left(m.c,m.m+5)+m.b+tran(m.g)+subs(m.c,m.h)
                exit
              endi
            endi
          endf
          k=aline(ac1,strt(m.c,m.b1,m.b)+m.ba,m.i1,m.zR)
          if empt(m.n1)
            retu
          endi
        endi
      endi
      for i=m.i1 to m.k-m.i1
        j=val(wd2(ac1(m.i),m.i0))
        if m.j>m.i0 and m.j<=m.nObj
          if type("cObj(m.j)")<>"C"
            if m.iInfo=m.i0 and m.info $ ac1(m.i)
              iInfo=m.j
            endi
            if m.iRoot=m.i0 and m.root $ ac1(m.i)
              iRoot=m.j
            endi
            if qObj(m.j)>m.i0
              ** прочитать объект
              =fseek(m.nf,aObj(m.j))
              cObj(m.j)=m.x
              c2=iif(feof(m.nf),m.x,fread(m.nf,qObj(m.j)))
              ** cмотреть содержание объекта дальше
              oPdf2=createObj(m.bc)
              oPdf2.scan(m.c2,m.j)
              rele oPdf2
            endi
          endi
        endi
      endf
      if m.iObj>m.i0
        kObj(m.iObj)=m.i2
        cObj(m.iObj)=m.c
      endi
    else
      if m.iObj>m.i0
        kObj(m.iObj)=m.k
        cObj(m.iObj)=m.c
      endi
    endi
  endFunc
endDef
