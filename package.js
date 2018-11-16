Package.describe({
  name: 'pfafman:geolocation',
  version: '1.4.3',
  // Brief, one-line summary of the package.
  summary: 'A Geolocation Abstraction with Manual Starting / Stopping and location storage',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/pfafman/meteor-geolocation',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
    documentation: 'README.md'
});


Cordova.depends({
  "cordova-plugin-geolocation": "4.0.1"
});


Package.onUse(function(api) {
  
  api.use(['reactive-var', 'coffeescript'], 'client');

  api.addFiles('lib/location.coffee', 'client');

  api.export('Location');
});

Package.onTest(function(api) {
});