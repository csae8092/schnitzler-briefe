# Arthur Schnitzler – Briefwechsel mit Autorinnen und Autoren

Quellcode der Website mit den Briefwechseln zwischen dem österreichischen Schriftsteller Arthur Schnitzler (1862–1931) und literarische arbeitenden Kolleginnen und Kollegen. 

In Entwicklung.  Vorabveröffentlichung unter:
https://schnitzler-briefe.acdh-dev.oeaw.ac.at

Die Edition stammt von Martin Anton Müller (@martinantonmueller) und Gerd-Hermann Susen. 

Die Web-Applikation basierend auf der DSE Base App (https://github.com/KONDE-AT/dsebaseapp) wurde unterstützt durch: 
* Peter Andorfer (@csae8092)
* Ingo Börner (@ingoboerner)
* Thomas Klampfl (@tklampfl)

## Funding

FWF-Projekt P31277 (https://pf.fwf.ac.at/de/wissenschaft-konkret/project-finder?search%5Bwhat%5D=&search%5Bpromotion_category_id%5D%5B%5D=&search%5Bcall%5D=&search%5Bproject_number%5D=P+31277&search%5Bdecision_board_ids%5D=&search%5Bproject_title%5D=&search%5Blead_firstname%5D=&search%5Blead_lastname%5D=&search%5Bresearch_place_kind%5D%5B%5D=&search%5Binstitute_name%5D=&search%5Bstart_date%5D=&search%5Bend_date%5D=&search%5Bgrant_years%5D%5B%5D=&search%5Bstatus_id%5D=&search%5Bscience_discipline_id%5D=&search%5Bper_page%5D=10#search-results)


## Install (no docker)

1. clone the repo `git clone https://github.com/acdh-oeaw/schnitzler-briefe.git`
2. enter the repo and init and update the submodules `cd schnitzler-briefe && git submodule init && git submodule update`
3. build the application `ant` -> creates a `.xar` in the `build` directory
4. install this `.xar` package via eXist-db Package Manager

## Install (with docker)