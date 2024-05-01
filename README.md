# pdfToStr
Reading a single page or an interval of pdf pages into a variable without third-party libraries using the example of the Visual FoxPro language.  
Чтение отдельной страницы или интервала страниц pdf в переменную без сторонних библиотек на примере языка Visual FoxPro
### Пример обращения к функции
```
* извлечение одной страницы:
stroka=pdfToStr("D:\work\Вождение\Ezgu bez avarii.pdf",11)
=strToF(m.stroka,"my11.pdf")
* или для интервала страниц:
stroka=pdfToStr("D:\work\Вождение\Ezgu bez avarii.pdf",11,14)
=strToF(m.stroka,"my11-14.pdf")
```
