# Expand the template into multiple files, one for each item to be processed.
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 
do
  cat dc-training.tmpl.yaml | sed "s/\$ITEM/$i/" > ./jobs/dc-training-$i.yaml 
  #cat job-tmpl.yaml | sed "s/\$ITEM/$i/" > ./jobs/job-$i.yaml
done

