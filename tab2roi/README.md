# tab2roi

This script generates images where an entire region of the brain has the same intensity.

Given a text file that looks like this:

```
Beta Weights	ROI			
-0.0945362	186|PSMG_L|posterior middle temporal gyrus left|1			
-0.0852231	31|AG_L|angular gyrus left|1			
-0.0845473	182|PIns_L|posterior insula left|1			
...
```

Generate a NIfTI image where each region has the intensity specified.

The user should specify the name of the text file and the name of the NiiStat region of interest, for example:

``` 
txtname = 'tab.txt';
roi = 'jhu';
```

Note that this code has very little error checking: if your text file includes region numbers for the JHU atlas but you set the `roi` to the AICHA atlas, you will get the wrong results.