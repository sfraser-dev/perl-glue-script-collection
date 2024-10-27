# Setting up TailwindCSS

Links:
- New Age Coder
  - <https://www.youtube.com/watch?v=DZvO_omwQ_0>
- NetNinja
  - <https://www.youtube.com/watch?v=bxmDnn7lrnk>

## New Age Coder Notes

```bash
# (0)
mkdir ./public
touch ./public/index.html

# (1) - get package.json
npm init -y

# (2) - get node_modules
npm install -D tailwindcss

# (3) - get tailwind.config.js
npx tailwindcss init

# (4) - edit tailwind.config.js content line:
from:
content: [],
to:
content: ["./public/**/*.{html,js}"],

# (5) - new folder and files
mkdir ./public/css
touch ./public/css/style.css
touch ./public/css/tailwind.css

# (6) boiler
# hit "!<ent>" for boiler plate index.html

# (7) link to tailwind.css in index.html
\<link rel="stylesheet" href="./css/tailwind.css"\>

# (8) - add 3 lines to style.css
@tailwind base;
@tailwind components;
@tailwind utilities;
echo "@tailwind base;" >> ./public/css/style.css
echo "@tailwind components;" >> ./public/css/style.css
echo "@tailwind utilities;" >> ./public/css/style.css

# (9) run this command:
npx tailwindcss -i ./public/css/style.css -o ./public/css/tailwind.css --watch


# (10) in package.json, change "scripts" key/value line:
from:
"test": "echo \"Error: no test specified\" && exit 1"
to:
"dev": "npx tailwindcss -i ./public/css/style.css -o ./public/css/tailwind.css --watch"
```

## NetNinja Notes

```bash
# Run npm init (creates package.json which keeps track of our node
# dependencies of which TailwindCSS is one)
qx(npm init -y);

# Install Tailwind as a development dependency (creates node_modules/,
# node_modules is where Tailwind is located along with its dependencies).
qx(npm install -D tailwindcss);

# Can use TailwindCSS on its own or as a plugin with PostCSS
# How does Tailwind actually work?
# SRC-CSS-FILE(styles.css) -> TAILWIND -> PUBLIC-CSS-FILE(styles.css)
# SRC-CSS-FILE has all the Tailwind core styles and functionality, we can also write
# our own CSS inside this file if we want to. Tailwind then processes this SRC-CSS-FILE
# into a vanilla PUBLIC-CSS-FILE at build time with all of the final CSS rules. We can
# link to this output PUBLIC file from our index.html file. But as Tailwind mostly uses
# utility classes within index.html, Tailwind rarely has to process the SRC-CSS-FILE
# into a PUBLIC-CSS-FILE.
# The SRC-CSS-FILE (CSS written with Tailwind)
# The PUBLIC-CSS-FILE will be vanilla CSS.
# The PUBLIC-CSS-FILE will be in the PUBLIC-DIR.
# PUBLIC-DIR also has our HTML and JS code.
# PUBLIC-DIR is what will eventually be depolyed to a webhost on the internet.
# src/style.css (three line Tailwind directives base, components, utilities)
```

