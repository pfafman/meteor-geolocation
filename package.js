Package.describe({
  name: 'pfafman:geolocation',
  version: '0.1.0',
  // Brief, one-line summary of the package.
  summary: 'A Geolocation Abstraction with Manual Starting / Stopping and location storage',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/pfafman/meteor-geolocation',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
    documentation: 'README.md'
});

/*
Cordova.depends({
    "org.apache.cordova.geolocation": "0.3.11"
});
*/

Package.onUse(function(api) {
  api.versionsFrom('1.0.3.1');

  api.use(['reactive-var', 'coffeescript'], 'client');

  api.addFiles('lib/location.coffee');

  api.export('Location');
});

Package.onTest(function(api) {
});