# isImagePDF

Batch script to check whether a PDF file contains only images.

Based on PDFToText and PDFInfo executables (not included), you can use it to automate process via errorlevel/exit codes, that are:

* 0: PDF has no text;
* 1: PDF could contain same text in each page (a watermark or similar);
* 2: PDF has a reasonable amount  of text;
* 3: something went wrong.

## Download

Get it [here.][1]


[1]: https://codeload.github.com/ABuffEr/isImagePDF/zip/master
