DLTS Viewer distro
============

Make sure you have <a href="https://www.mongodb.org/">MongoDB</a> installed and your <a href="https://en.wikipedia.org/wiki/LAMP_(software_bundle)">LAMP</a> set-up with <a href="http://php.net/manual/en/mongo.installation.php">PHP MongoDB extension</a>.

<a href="https://github.com/drush-ops/drush">Drush</a> is require to run the script (./bin/build.sh), you also need to have <a href="http://compass-style.org/">Compass</a> to compile the default theme SASS into CSS.

Configure and build
============

Configure the build script by copying the default template default.project.conf as project.conf and fill out the blanks

	cp default.project.conf project.conf

Build the drupal distribution, e.g.

	./bin/build.sh -m site.make -c site.conf
