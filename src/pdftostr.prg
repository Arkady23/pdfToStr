*
*   ИЗВЛЕЧЕНИЕ СТРАНИЦЫ n1 ИЛИ ИНТЕРВАЛА СТРАНИЦ ОТ n1 ДО n2 ИЗ pdf 
*   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*   Примечание: На выходе переменная, которая может быть передана
*               через интернет или сохранена в файл.pdf.
*   Автор: Корниенко Аркадий Борисович
*   Дата:  02.05.2024
*
para pdf,n1,n2
  priv i,j,k,m,b,c,na,nf,nObj,exact,eoff,xref,xref2,verPdf,v,x,y
  x=""
  if file(m.pdf)
    bc='cPdf' && константы
    bu="<<"
    bz=">>"
    bs="/"
    b1="["
    b0="0"
    b=" "
    i1=1
    i2=2
    stor 0 to i0,xref,xref2,nObj,iInfo,iRoot,iKids
    zR=" 0 R"
    ba=" B A"
    eoff="OFF"
    xf=" 65536 f"
    xn=" 00000 n"
    trailer="trailer"
    sxref="startxref"
    info="/Info"
    root="/Root"
    kids="/Kids"
    f10="@L "+replic("9",10)
    c10=chr(10)
    oPdf=createObj(m.bc)
    exact= set("exact")=m.eoff
    if m.exact
      set exact on
    endi
    if type("m.n2")<>"N"
      n2=m.n1
    endi
    
    ** 1. чтение хвоста pdf
    nf=fopen(m.pdf)
    =fseek(m.nf,-40,m.i2)
    do e_pdf
    
    ** 2. чтение начала
    =fseek(m.nf,m.i0)
    verPdf=fget(m.nf)
    if m.xref2=m.i0
      ** если маркер startxref в конце файла не найден, ищем с начала
      do e_pdf
    endi
    if m.nObj>m.i0
      =fseek(m.nf,m.xref2)

      ** 3. Формируем массив ссылок на объекты
      dime aObj(m.nObj),qObj(m.nObj),cObj(m.nObj),kObj(m.nObj),aTmp(m.i1)
      stor m.i0 to kObj
      j=m.nObj
      for i=m.i1 to m.nObj
        c=iif(feof(m.nf),m.b,fget(m.nf))
        aObj(m.j)=val(m.c)
        ** исправляем проблему отсутствия нулевого индекса массива на VFP
        if m.j=m.nObj
          j=m.i0
        endi
        j=m.j+m.i1
      endf

      ** 4. Формируем массив размеров объектов
      k=m.nObj-m.i1
      for i=m.i1 to m.k
        v=m.xref
        for j=m.i to m.k
          if aObj(m.j)>aObj(m.i) and aObj(m.j)<m.v
            v=aObj(m.j)
          endi
        endf
        qObj(m.i)=m.v-aObj(m.i)
      endf

      ** 5. Чтение нужных, включая "Info", "Root", "Kids", объектов
      c=iif(feof(m.nf),m.b,fget(m.nf))
      if m.c=m.trailer
        do whil not feof(m.nf)
          c=fget(m.nf)
          =oPdf.scan(@c,m.i0)
          if righ(m.c,m.i2)=m.bz
            exit
          endi
        endd
        =fclo(m.nf)
        nf=-m.i1

        ** 6. переиндексирование объектов
        k=3
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
          na=m.na+1
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
        x=m.x+"xref"+m.c10+m.b0+m.b+tran(m.na)+m.c10+replic(m.b0,10)+m.xf+m.c10
        for i=m.i1 to m.na-m.i1
          if empt(aObj(m.i))
            x=m.x+tran(m.i,m.f10)+m.xf+m.c10
          else
            x=m.x+tran(aObj(m.i),m.f10)+m.xn+m.c10
          endi
        endf
        x=m.x+m.trailer+m.c10+m.bu+m.info+m.b+tran(iif(m.iInfo>m.na,kObj(m.iInfo),m.iInfo))+ ;
          m.zR+m.b+m.root+m.b+tran(iif(m.iRoot>m.na,kObj(m.iRoot),m.iRoot))+m.zR+" /Size "+ ;
          tran(m.na)+m.bz+m.c10+m.sxref+m.c10+tran(m.k)+m.c10+"%%EOF"+m.c10
      endi
    endi
    if m.nf>=m.i0
      =fclo(m.nf)
    endi
    if m.exact
      set exact off
    endi
  endi
retu m.x

proc e_pdf
  ** чтение хвоста pdf
  do whil not feof(m.nf)
    c=fget(m.nf)
    if left(m.c,m.i1)<>"%"
      do case
      case m.xref=m.i0
        if m.c=m.sxref
          xref=m.i1
        endi
      case m.xref=m.i1
        xref=val(m.c)
        =fseek(m.nf,m.xref)
      othe
        nObj=val(wd2(@c,m.i2))
        if m.nObj>m.i0
          xref2=fseek(m.nf,m.i0,m.i1)
          exit
        endi
      endc
    endi
  endd

func wd2(c,k)
  ** выделение k-го слова из текста, k=0 - последнее слово в строке, -1 предпоследнее и т.д.
  local z
  na=aline(aTmp,m.c,4,m.b)
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

defi class cPdf as custom
  Func scan(c,iObj)
    local ac(m.i1),i,j,k,m,f,g,h,y,c2,oPdf2
    k=aline(ac,strt(stre(m.c,m.bu,"stream",1,2),m.b1,m.b)+m.ba,m.i1,m.zR)
    if m.k>m.i1
      if m.iKids=m.i0
        ** А если в этой строке список страниц, то его надо модифицировать
        ** в соответствии с заданным интервалом вывода нужных страниц
        f=at(m.kids,m.c)
        if m.f>m.i0
          for i=m.i1 to m.k-m.i1
            h=at(m.kids,ac(m.i))
            if m.h>m.i0
              iKids=m.iObj
              j=val(wd2(ac(m.i),m.i0))
              if m.j>m.i0 and m.j<=m.nObj
                ** изменяем список объектов согласно параметров
                ac(m.i)=subs(ac(m.i),m.h+6)
                stor m.i0 to g,h
                y=m.b
                for m=m.i to m.k
                  h=m.h+m.i1
                  if m.h>=m.n1
                    g=m.g+m.i1
                    y=m.y+tran(val(ac(m.m)))+m.zR+m.b
                  endi
                  if m.h>=m.n2
                    exit
                  endi
                endf
                h=pole2(@c,m.f)
                c=left(m.c,m.f+4)+m.b+m.b1+m.y+"]"+subs(m.c,m.h)
                ** изменяем количество страниц в /Count
                m=at("/Count",m.c)
                h=pole2(@c,m.m)
                c=left(m.c,m.m+5)+m.b+tran(m.g)+subs(m.c,m.h)
                exit
              endi
            endi
          endf
          k=aline(ac,strt(m.c,m.b1,m.b)+m.ba,m.i1,m.zR)
        endi
      endi
      for i=m.i1 to m.k-m.i1
        j=val(wd2(ac(m.i),m.i0))
        if m.j>m.i0 and m.j<=m.nObj
          if type("cObj(m.j)")<>"C"
            if m.iInfo=m.i0 and m.info $ ac(m.i)
              iInfo=m.j
            endi
            if m.iRoot=m.i0 and m.root $ ac(m.i)
              iRoot=m.j
            endi
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
