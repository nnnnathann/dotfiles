/*global document */
'use strict';

import Backbone from 'backbone';
import FilteredCollection from 'backbone-filtered-collection';
import React from 'react.backbone';
import Router from 'react-router';
import login from 'oberd/login-js';

let {Route, DefaultRoute} = Router;

import Layout from './Pages/Layout.jsx!';
import Home from './Pages/Home.jsx!';

React.initializeTouchEvents(true);

// Global Library Config
React.BackboneMixin.ConsiderAsCollection = function(modelOrCollection) {
    return modelOrCollection instanceof Backbone.Collection || modelOrCollection instanceof FilteredCollection;
};

function routes() {
    return (
      <Route handler={Layout} path="/">
        <DefaultRoute handler={Home} />
      </Route>
    );
}
login().then(function() {
    Router.run(routes(), function(Handler) {
        React.render(<Handler/>, document.getElementById('main'));
    });
}, function() {
    window.location = window.env.url.replace('{prefix}', 'login') + '?returl=' + encodeURIComponent(window.location.toString());
});
