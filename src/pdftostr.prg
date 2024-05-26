*
*   ИЗВЛЕЧЕНИЕ СТРАНИЦЫ n1 ИЛИ ИНТЕРВАЛА СТРАНИЦ ОТ n1 ДО n2 ИЗ pdf 
*   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*   Примечание: На выходе переменная, которая может быть передана
*               через интернет или сохранена в файл.pdf.
*   Автор: Корниенко Аркадий Борисович
*   Дата:  26.05.2024
*
para pdf,n1,n2
  priv ALL
  x=""
  i1=1
  if type("m.pdf")="C" and file(m.pdf)
    bc='cPdf'  && константы
    bk='cKids'
    bp="%"
    bu="<<"
    bz=">>"
    bs="/"
    b1="["
    b2="]"
    b0="0"
    b=" "
    i2=2
    i3=3
    i4=4
    i5=5
    ia=10
    i13=13
    i32=32
    i48=48
    i57=57
    stor 0 to i0,g,i,j,k,m,s,v,xref1,xref2,nObj,iInfo,iRoot,iCat,iKids
    zR=" 0 R"
    ba=" B A"
    eoff="OFF"
    bobj=" 0 obj"
    eobj="endobj"
    xf=" 65536 f"
    xn=" 00000 n"
    trailer="trailer"
    sxref="startxref"
    stream="stream"
    tipe="/Type"
    info="/Info"
    root="/Root"
    cat="/Catalog"
    enc="/Encrypt"
    pgs="/Pages"
    kids="/Kids"
    xref="xref"
    f10="@L "+replic("9",m.ia)
    c10=chr(m.ia)
    c13=chr(m.i13)
    oPdf=createObj(m.bc)
    dime aTmp(m.i1),c(m.i1),y(m.i1)
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
    ** вместо массивов, которые могут быть очень большими
    crea curs pdf (a N(m.ia),q N(m.ia),k N(m.ia),c M)
    
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

    ** 3. если число объектов не реально мало, восстанавливаем массив ссылок
    eobj=m.eobj+m.c13
    if m.nObj<m.i3
      do b_pdf
    endi
    if m.nObj>m.i2

      ** 4. Чтение нужных, включая "Info", "Root", "Kids", объектов
      c=m.x
      index on a tag a
      =fseek(m.nf,m.xref2)
      do whil not feof(m.nf)
        y=fget(m.nf)
        if m.y=m.sxref
          exit
        endi
        i=at(m.stream,m.y)
        if m.i>m.i0
          y=left(m.y,m.i-m.i1)
          exit
        endi
        c=m.c+m.y
      endd
      vpole2(m.c,m.enc)
      iEnc=m.v
      =oPdf.scan(@m.c,m.i0)
      =fclo(m.nf)
      nf=-m.i1
      set orde to
      if m.n1>m.i0 and m.g>m.i0

        ** 5. переиндексирование объектов
        k=m.i1
        na=m.nObj
        do whil m.na>m.k
          go m.na
          if pdf.k<m.i0
            s=pdf.k
            for j=m.k to m.na-m.i1
              go m.j
              if empt(pdf.k)
                repl pdf.k with m.na
                go m.na
                repl pdf.k with m.j
                k=m.j+m.i1
                exit
              endi
            endf
          endi
          na=m.na-m.i1
        endd
        go m.na
        do whil pdf.k<m.i0
          na=m.na+m.i1
          skip
        endd

        ** 6. формирование строки m.x
        x=m.verPdf+m.c10+m.bp+"MS VFP"+m.c10
        for i=m.i1 to m.na-m.i1
          go m.i
          if not empt(pdf.k)
            repl pdf.a with len(m.x)
            if pdf.k= -m.i1
              * ничего не меняем
              x=m.x+pdf.c
            else
              * меняем ссылку в первой строке
              k=iif(pdf.k>m.i0,pdf.k,m.i)
              go m.k
              c=subs(pdf.c,at(" obj",pdf.c)+m.i1)
              * меняем ссылки в остальных строках
              j=m.i1
              do whil m.k>m.i0
                k=at(m.zR,m.c,m.j)
                if m.k>m.i0
                  =vd2(rtri(left(m.c,m.k)))
                  go m.v
                  if m.v>=m.na and m.v<=m.nObj
                    * было m.v, стало kObj(m.v)
                    c=stuf(m.c,m.m,m.k-m.m,tran(pdf.k))
                  endi
                  j=m.j+m.i1
                endi
              endd
              x=m.x+tran(m.i)+m.b+m.b0+m.b+m.c
            endi
          else
            * свободный объект предусмотрен, но их не должно их быть
            repl pdf.a with m.i0
          endi
        endf
        k=len(m.x)
        x=m.x+m.xref+m.c10+m.b0+m.b+tran(m.na)+m.c10+replic(m.b0,m.ia)+m.xf+m.b+m.c10
        for i=m.i1 to m.na-m.i1
          go m.i
          if empt(pdf.a)
            x=m.x+tran(m.i,m.f10)+m.xf+m.b+m.c10
          else
            x=m.x+tran(pdf.a,m.f10)+m.xn+m.b+m.c10
          endi
        endf
        =corInd(@m.iInfo)
        =corInd(@m.iRoot)
        =corInd(@m.iEnc)
        x=m.x+m.trailer+m.c10+m.bu+m.info+m.b+tran(m.iInfo)+m.zR+m.b+m.root+m.b+tran(m.iRoot)+m.zR+ ;
          iif(empt(m.iEnc),m.b,m.b+m.enc+m.b+tran(m.iEnc)+m.zR+m.b)+"/Size "+tran(m.na)+m.bz+m.c10+ ;
          m.sxref+m.c10+tran(m.k)+m.c10+"%%EOF"+m.c10
      endi
    endi
    if m.nf>=m.i0
      =fclo(m.nf)
    endi
    if m.exact
      set exact off
    endi
    if empt(m.n1)
      retu m.g
    endi
  else
    retu -m.i1
  endi
retu m.x

proc e_pdf
  ** чтение хвоста pdf
  =fseek(m.nf,-m.i32,m.i2)
  do whil not feof(m.nf)
    c=fget(m.nf)
    if left(m.c,m.i1)<>m.bp
      do case
      case m.c=m.trailer
        m=m.i2
        k=m.i0
        if empt(m.xref2)
          ** позиция начала просмотра pdf
          xref2=fseek(m.nf,m.i0,m.i1)
        endi
      case m.k>m.i0
        if not eof()
          if subs(m.c,18,1)="n"
            repl pdf.a with val(m.c)
          endi
          if empt(m.j)
            ** проблема с нулевым индексом на VFP и с нулевой строкой
            j=m.i1
          else
            skip
          endi
        endi
      case m.m=m.i2
        vpole2(@m.c,"/Prev")
        if m.v>m.i0
          m=m.v
          =fseek(m.nf,m.m)
          if m.m>m.xref1
            xref1=m.m
          endi
        else
          nObj=recc()
          exit
        endi
      case m.c=m.sxref
        m=m.i1
      case m.c=m.xref
        s=fseek(m.nf,m.i0,m.i1)
      case m.m=m.i1
        m=val(m.c)
        =fseek(m.nf,m.m)
        if m.m>m.xref1
          xref1=m.m
        else
          if m.xref1=m.m
            ** избавляет от зацикливания в некоторых случаях
            exit
          endi
        endi
      case m.s>m.i2
        j=val(m.c)
        k=val(wd2(@m.c,m.i1,m.i2))
        for i=m.i1 to m.j+m.k-recc()
          appe blan
        endf
        do case
        case empt(m.j)
          go top
        case m.j<recc()
          go m.j
        othe
          go bott
          skip
        endc
      endc
    endi
  endd
  if recc()>m.i0
    go bott
    repl pdf.a with m.xref1
  endi
  if empt(m.xref2)
    xref2=m.xref1
  endi

proc b_pdf
  ** формирование массива ссылок
  local nc,ac(m.i1)
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
  do whil not feof(m.nf)
    nc=aline(ac,fread(m.nf,16000),16,m.eobj)
    if m.nc>m.i0
      ac(m.i1)=m.c+ac(m.i1)
      c=m.x
      for i=m.i1 to m.nc-m.i1
        vpos1(@ac,@m.i)
        if m.v>m.i0
          j=val(subs(ac(m.i),m.v,m.i32))
          if m.j>m.nObj
            for m=m.i1 to m.j-m.nObj
              appe blan
            endf
            nObj=m.j
          else
            go m.j
          endi
          repl pdf.a with m.k+m.v-m.i1
          k=m.k+len(ac(m.i))
        else
          j=m.i0
        endi
      endf
      c=ac(m.nc)
    endi
  endd
  xref1=m.k
  nObj=m.nObj+m.i1
  inse into pdf (a) valu (m.k)

proc corInd(ind)
  if m.ind>m.na
    go m.ind
    ind=pdf.k
  endi

func wd2(c,i,k)
  ** выделение k-го слова из текста c(i), k=0 - последнее слово в строке, -1 предпоследнее и т.д.
  local z
  na=aline(aTmp,c(m.i),m.i4,m.b,m.bu,m.b1,m.c13)
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

proc vd2(y)
  ** определить число справа как m.v и поместить его позицию в m.m
  local k
  for m=len(m.y) to m.i1 step -m.i1
    k=asc(subs(m.y,m.m,m.i1))
    if m.k>m.i57 or m.k<=m.i32
      exit
    endi
  endf
  m=m.m+m.i1
  v=val(subs(m.y,m.m))

func pole2(c,k)
** поиск конца поля значений в m.c за позицией k
  local j,j1,j2,c2
  c2=strt(strt(subs(m.c,m.k+m.i1),">",m.bs),"<",m.bs)+m.bs
  j=m.i1
  j1=at(m.bs,m.c2)
  j2=at(m.b1,m.c2)
  if m.j2>m.i0 and m.j2<m.j1
    ** редкий случай, но внутри поля могут быть "[","/" и "]"
    j2=at(m.b2,m.c2)
    do while m.j1<m.j2
      j=m.j+1
      j1=at(m.bs,m.c2,m.j)
    endd
  endi
retu m.j1

proc vpole2(c,key)
  ** значение после символьного ключа
  v=rat(m.key,m.c)
  if m.v>m.i0
    v=val(subs(m.c,m.v+len(m.key)))
  endi

proc vpos1(A,i)
  ** найти начало объекта в строке элемента массива
  v=rat(m.bobj,A(m.i))
  if m.v>m.i0
    for j=m.v-m.i1 to m.i1 step -m.i1
      m=asc(subs(A(m.i),m.j,m.i1))
      if m.m<m.i48 or m.m>m.i57
        exit
      endi
    endf
    v=m.j+m.i1
  endi

proc vpos2(A,i)
  ** найти первый печатный символ в строке элемента массива
  for v=m.i1 to len(A(m.i))
    if asc(subs(A(m.i),m.v,m.i1))>m.i32
      exit
    endi
  endf

proc delPole(c,key)
  ** удалить поле из строки
  v=at(m.key,m.c)
  if m.v>m.i0
    c=stuff(m.c,m.v,pole2(@m.c,m.v),m.x)
  endi

func goObj(j,k)
  ** подогнать позицию в курсоре под объект j, если в курсоре объекта нет, то прочитать из pdf
  ** вернуть признак чтения или сам объект для варианта без m.k
  if m.j>m.i0 and m.j<m.nObj
    go m.j
    if empt(pdf.c)
      if empt(pdf.q)
        skip
        v=pdf.a
        go m.j
        v=m.v-pdf.a
        repl pdf.q with m.v
      endi
      =fseek(m.nf,pdf.a)
      if empt(m.k)
        retu fread(m.nf,pdf.q)
      else
        repl pdf.c with fread(m.nf,pdf.q)
        retu m.b1
      endi
    else
      if empt(m.k)
        retu pdf.c
      else
        if empt(pdf.q)
          repl pdf.q with len(pdf.c)
          retu m.b1
        endi
      endi
    endi
  endi
retu m.x

defi class cPdf as custom
  func scan(c,iObj)
    local ac1(m.i1),i,j,k,oPdf1,oPdf2
    if empt(m.iCat)
      if at(m.cat,m.c)>m.i0
        iCat=m.i1
        ** эти поля лучше удалить:
        delPole(@m.c,"/Names")
        delPole(@m.c,"/OpenAction")
        delPole(@m.c,"/PageLabels")
        delPole(@m.c,"/StructTreeRoot")
        go m.iObj
        repl pdf.c with m.c
      endi
    endi
    if empt(m.iKids)
      ** А если в этой строке список страниц, то его надо модифицировать
      ** в соответствии с заданным интервалом вывода нужных страниц
      ** Упс... Kids бывает вложенным, поэтому организуем класс
      if at(m.kids,m.c)>m.i0
        y=m.x
        s=m.i0
        iKids=m.iObj
        oPdf1=createObj(m.bk)
        oPdf1.scan(@m.c,m.i0)
        rele oPdf1
        if empt(m.n1)
          retu
        endi
        c=tran(m.iObj)+m.bobj+m.c13+m.bu+m.tipe+m.pgs+"/Count "+tran(m.g)+m.kids+m.c13+ ;
          m.b1+m.y+m.b2+m.c13+m.bz+m.c13+m.eobj
        go m.iObj
        repl pdf.c with m.c
      endi
    endi
    k=aline(ac1,strt(stre(m.c,m.bu,m.stream,m.i1,m.i2),m.b1,m.b)+m.ba,m.i1,m.zR)
    if m.k>m.i1
      for i=m.i1 to m.k-m.i1
        j=val(wd2(@ac1,@m.i,m.i0))
        if not empt(goObj(@m.j,m.i1))
          if m.iInfo=m.i0 and m.info $ ac1(m.i)
            iInfo=m.j
          endi
          if m.iRoot=m.i0 and m.root $ ac1(m.i)
            iRoot=m.j
          endi
          ** cмотреть содержание объекта дальше
          oPdf2=createObj(m.bc)
          oPdf2.scan(pdf.c,@m.j)
          rele oPdf2
        endi
      endf
      if m.iObj>m.i0
        go m.iObj
        repl pdf.k with -m.i2
      endi
    else
      if m.iObj>m.i0
        go m.iObj
        repl pdf.k with -m.i1
      endi
    endi
  endfunc
enddef

defi class cKids as custom
  func scan(c,ik)
    local i,k,z,oPdf3,ac3(m.i1)
    if empt(m.ik)
      i=at(m.kids,m.c)+m.i5
      if m.i>m.i5
        k=aline(ac3,subs(m.c,m.i),m.i1,m.b2,m.bs,m.bz)
      endi
    else
      z=goObj(m.ik)
      i=at(m.kids,m.z)+m.i5
      if m.i>m.i5
        k=aline(ac3,subs(m.z,m.i),m.i1,m.b2,m.bs,m.bz)
      endi
    endi
    if empt(m.k)
      s=m.s+m.i1
      if (m.s>=m.n1 and m.s<=m.n2) or empt(m.n1)
        g=m.g+m.i1
        y=iif(empt(m.y),m.y,m.y+m.b)+tran(m.ik)+m.zR
        if not empt(m.ik)
          i=at("/Parent",m.z)+7
          if not empt(m.i)
            repl pdf.q with m.i0, pdf.c with stuff(m.z,m.i,pole2(@m.z,m.i),m.b+tran(m.iKids)+m.zR)
          endi
        endi
      endi
    else
      k=aline(ac3,subs(ac3(m.i1),at(m.b1,ac3(m.i1))+m.i1),m.i1,m.zR)
      for i=m.i1 to m.k
        =vpos2(@ac3,i)
        oPdf3=createObj(m.bk)
        oPdf3.scan(@m.x,val(subs(ac3(m.i),m.v)))
        if m.s>=m.n2 and not empt(m.n1)
          exit
        endi
      endf
    endi
  endfunc
enddef
