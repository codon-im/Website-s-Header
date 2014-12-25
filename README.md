Website's Header
================

This is the Processing.js code responsible for our website's (www.codon.im) interactive header. 

If you want it to run in Processing's (java) IDE, you'd have to replace "window.innerWidth / window.innerHeight" with pre-defined dimensions. The "window" object is there so we can have a resizable and responsive view for the sketch. Also the lines below take care of making the tab button's color in sync with the header's logo's color (since it changes randomly each time), so remove that if you'd like to run the sketch in Processing IDE.
- var hex= {
-     "#276276", "#467E7E", "#ED8813", "#6F4FA0"
-   };
- document.getElementById("tab").firstElementChild.style.backgroundColor= hex[mLogoPalletNum];

Sorry about the code being unorganized and dirty. We'll try to give it a clean up soon.
