DLTS Viewer_distro
============

<a href="https://github.com/drush-ops/drush">Drush</a> is require to run the script, you also need to have <a href="http://compass-style.org/">Compass</a> to compile the default theme SASS into CSS.

Make sure you have <a href="https://www.mongodb.org/">MongoDB</a> installed and Have your <a href="https://en.wikipedia.org/wiki/LAMP_(software_bundle)">LAMP</a> set-up with <a href="http://php.net/manual/en/mongo.installation.php">PHP MongoDB extension</a>.

Configure and build
============

Configure the build script by copying the default template default.project.conf as project.conf and fill out the blanks

	cp default.project.conf project.conf

Build the drupal distribution, e.g.

	./bin/build.sh -m mediacommons.make -c site.conf
