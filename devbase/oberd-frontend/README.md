### Introduction to Backbone + React


#### Why Backbone?

#### Why React?


#### Installing dependencies

```sh
jspm init -y

npm install --save dev gulp require-dir jspm koa koa-static gulp-watch

jspm install jquery
jspm install jsx
jspm install css
jspm install underscore
jspm install backbone=github:jashkenas/backbone
jspm install backbone-filtered-collection=github:jmorrell/backbone-filtered-collection -o '{"main": "backbone-filtered-collection.js", "shim":{"deps":["backbone"]}}'
jspm install react=github:reactjs/react-bower -o '{"main": "react-with-addons", "format":"global"}'
jspm install react.backbone=github:clayallsopp/react.backbone -o '{"shim":{"deps":["react","backbone"]}}'
jspm install react-router=github:rackt/react-router -o '{"shim":{"deps":["react"]}}'

```
