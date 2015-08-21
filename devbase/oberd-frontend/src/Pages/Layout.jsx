import React from 'react';
import Router from 'react-router';

let {RouteHandler} = Router;

class Layout extends React.Component {
    render() {
        return <RouteHandler/>;
    }
}

export default Layout;
