- run in top level of a web dev project
- installs sass, postcss and bootstrap in node_modules
    - installed bootstrap to have access to its source files for customization
    - installed sass and postcss so we can run them as scripts from package.json
    - postcss needs browserslist property set within package.json file
- adapts the package.json file so can run sass and postcss from cmd line via npm
- $> npm run compile:sass
- $> npm run compile:sassmin
- $> npm run compile:prefix
- perl file created to run these npm commands consecutively
- note: no npm for latest fontawesome version, so described manual install procedure
