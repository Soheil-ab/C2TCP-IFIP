for i in *.svg
do
    inkscape -D -z --file=$i --export-pdf=${i%.svg}.pdf --export-latex
done

